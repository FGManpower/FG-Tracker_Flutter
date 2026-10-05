import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Services/walkie_notification_manager.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_invite_dialog.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Data/Services/walkie_foreground_service.dart';

enum WalkieAudioRoute { speaker, earpiece, bluetooth, headset }

class GroupWalkieService {
  GroupWalkieService._();
  static final instance = GroupWalkieService._();

  Socket? socket;
  String? _selfUserId;
  String? _currentGroupId;
  MediaStream? _localStream;
  Completer<bool>? _streamCompleter;
  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, MediaStream> _remoteStreams = {};
  final Map<String, RTCDataChannel> _dataChannels = {};
  final Map<String, List<RTCIceCandidate>> _pendingIce = {};
  final Set<String> _makingOffer = {};
  final Set<String> _offeredTo = {};
  bool _isTalking = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _listenersBound = false;
  bool _isDisposed = false;
  bool _hasMicPermission = false;

  Timer? _pingTimer;
  StreamSubscription? _devicesSub;

  final Rx<WalkieAudioRoute> audioRoute = WalkieAudioRoute.speaker.obs;
  final RxBool hasBluetoothDevice = false.obs;
  final RxString bluetoothDeviceName = "Bluetooth".obs;
  final RxBool hasHeadsetDevice = false.obs;
  final RxString headsetDeviceName = "Headset".obs;

  bool get isTalking => _isTalking;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get hasMicPermission => _hasMicPermission;
  String? get currentGroupId => _currentGroupId;
  String? get selfUserId =>
      _selfUserId ?? Global.storageServices.get(PrefConst.userId)?.toString();

  static final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {
        'urls': ['stun:stun.l.google.com:19302'],
      },
      {
        'urls': Urls.rtcUrl,
        'username': Urls.rtcUserName,
        'credential': Urls.rtcCredential,
      }
    ],
    'iceTransportPolicy': 'all',
    'sdpSemantics': 'unified-plan',
  };

  void _log(String msg) {
    log('WALKIE[$_selfUserId][g=$_currentGroupId] $msg');
  }

  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    if (socket != null && socket!.connected && _selfUserId == selfUserId) {
      _log('Socket already initialized and connected for $selfUserId');
      return;
    }

    if (socket != null) {
      try {
        socket?.clearListeners();
        socket?.disconnect();
        socket?.dispose();
      } catch (_) {}
      socket = null;
    }

    _isDisposed = false;
    _selfUserId = selfUserId;
    _log('GroupWalkieService init called with user: $selfUserId');

    WalkieForegroundService.init();
    await _configureAudioSession(speakerOn: true);
    await _listenAudioDevices();

    socket = io(
      "$websocketUrl/groupWalkie",
      OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': selfUserId})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(500)
          .setTimeout(10000)
          .build(),
    );

    socket!.onConnect((_) {
      _listenersBound = false;
      _bindSocketListeners();
      _startPing();
      _notifyConnectionState(true);

      if (_currentGroupId != null) {
        _offeredTo.clear();
        _makingOffer.clear();
        final parsedGroupId = int.tryParse(_currentGroupId!) ?? _currentGroupId;
        final parsedUserId = int.tryParse(_selfUserId ?? '') ?? _selfUserId;
        socket?.emit('join_walkie_session', {
          'groupId': parsedGroupId,
          'groupIdStr': _currentGroupId,
          'userId': parsedUserId,
          'fromUserId': _selfUserId,
        });
      }
    });

    socket!.onReconnect((_) {
      _log('🔄 Socket reconnected to /groupWalkie');
      _listenersBound = false;
      _bindSocketListeners();
      _startPing();
      _notifyConnectionState(true);

      if (_currentGroupId != null) {
        _offeredTo.clear();
        _makingOffer.clear();
        final parsedGroupId = int.tryParse(_currentGroupId!) ?? _currentGroupId;
        final parsedUserId = int.tryParse(_selfUserId ?? '') ?? _selfUserId;
        socket?.emit('join_walkie_session', {
          'groupId': parsedGroupId,
          'groupIdStr': _currentGroupId,
          'userId': parsedUserId,
          'fromUserId': _selfUserId,
        });
      }
    });

    socket!.onDisconnect((_) {
      _listenersBound = false;
      _stopPing();
      _notifyConnectionState(false);
    });

    socket!.onConnectError((e) => _log('connect_error: $e'));
    socket!.onError((e) => _log('error: $e'));
  }

  void _notifyConnectionState(bool connected) {
    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().setConnected(connected);
    }
  }

  void _startPing() {
    _stopPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (socket != null && socket!.connected) {
        socket?.emit('ping_walkie');
      } else if (socket != null && !socket!.connected) {
        _log('⚠️ Socket disconnected during health check, reconnecting...');
        socket?.connect();
      }
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<bool> requestMicPermission() async {
    try {
      var status = await Permission.microphone.status;
      _log('Mic permission status: $status');

      if (!status.isGranted) {
        status = await Permission.microphone.request();
        _log('Requested mic permission: $status');
      }

      _hasMicPermission = status.isGranted;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setMicPermission(_hasMicPermission);
      }
      return _hasMicPermission;
    } catch (e) {
      _log('⚠️ Error during Permission.microphone check: $e');
      return false;
    }
  }

  Future<void> _configureAudioSession({required bool speakerOn}) async {
    if (_isDisposed) return;
    try {
      final session = await AudioSession.instance;

      if (Platform.isIOS) {
        await session.configure(
          AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionMode: AVAudioSessionMode.voiceChat,
            avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.allowBluetoothA2dp |
            AVAudioSessionCategoryOptions.allowAirPlay |
            AVAudioSessionCategoryOptions.mixWithOthers |
            (speakerOn
                ? AVAudioSessionCategoryOptions.defaultToSpeaker
                : AVAudioSessionCategoryOptions.none),
          ),
        );
      } else {
        await session.configure(
          const AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionMode: AVAudioSessionMode.voiceChat,
            androidAudioAttributes: AndroidAudioAttributes(
              usage: AndroidAudioUsage.voiceCommunication,
              contentType: AndroidAudioContentType.speech,
            ),
            androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          ),
        );
      }

      await session.setActive(true);
      _isSpeakerOn = speakerOn;
      if (Platform.isAndroid) {
        try {
          final am = AndroidAudioManager();
          await am.setMode(AndroidAudioHardwareMode.inCommunication);
          await am.setSpeakerphoneOn(speakerOn);
        } catch (_) {}
      }
      try {
        await Helper.setSpeakerphoneOn(speakerOn);
      } catch (_) {}
      _log('🎧 AudioSession configured: speakerOn=$speakerOn');
    } catch (e) {
      _log('❌ AudioSession configure error: $e');
    }
  }

  Future<void> _listenAudioDevices() async {
    try {
      final session = await AudioSession.instance;
      await _devicesSub?.cancel();
      _devicesSub = session.devicesStream.listen((devices) async {
        await _updateRoute(devices);
      });
      await _updateRoute(await session.getDevices());
    } catch (_) {}
  }

  Future<void> _updateRoute(Set<AudioDevice> devices) async {
    bool hasBT = devices.any((d) =>
    d.type == AudioDeviceType.bluetoothA2dp ||
        d.type == AudioDeviceType.bluetoothSco ||
        d.type == AudioDeviceType.bluetoothLe);

    String btName = "Bluetooth";
    for (final d in devices) {
      if ((d.type == AudioDeviceType.bluetoothA2dp ||
          d.type == AudioDeviceType.bluetoothSco ||
          d.type == AudioDeviceType.bluetoothLe) &&
          d.name.trim().isNotEmpty) {
        btName = d.name.trim();
        break;
      }
    }

    final headsetList = devices.where((d) =>
    d.type == AudioDeviceType.wiredHeadset ||
        d.type == AudioDeviceType.wiredHeadphones).toList();
    final hasHeadset = headsetList.isNotEmpty;
    final headsetName = (hasHeadset && headsetList.first.name.trim().isNotEmpty)
        ? headsetList.first.name.trim()
        : "Headset";

    final bool prevHasBT = hasBluetoothDevice.value;
    final bool prevHasHeadset = hasHeadsetDevice.value;

    hasBluetoothDevice.value = hasBT;
    bluetoothDeviceName.value = btName;
    hasHeadsetDevice.value = hasHeadset;
    headsetDeviceName.value = headsetName;

    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().updateAvailableRoutes(
        hasBt: hasBT,
        btName: btName,
        hasHeadset: hasHeadset,
        headsetName: headsetName,
      );
    }

    if (!prevHasBT && hasBT) {
      await setAudioRoute(WalkieAudioRoute.bluetooth);
      return;
    }

    if (prevHasBT && !hasBT && audioRoute.value == WalkieAudioRoute.bluetooth) {
      await setAudioRoute(WalkieAudioRoute.speaker);
      return;
    }

    if (!prevHasHeadset && hasHeadset) {
      await setAudioRoute(WalkieAudioRoute.headset);
      return;
    }

    if (prevHasHeadset && !hasHeadset &&
        audioRoute.value == WalkieAudioRoute.headset) {
      await setAudioRoute(WalkieAudioRoute.speaker);
      return;
    }
  }

  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    for (final e in [
      'walkie_invite',
      'walkie_existing_peers',
      'walkie_peer_joined',
      'walkie_peer_left',
      'walkie_webrtc_offer',
      'walkie_webrtc_answer',
      'walkie_webrtc_ice',
      'ptt_granted',
      'ptt_denied',
      'walkie_speaker_active',
      'walkie_speaker_stopped',
      'walkie_participants_update',
      'walkie_channel_locked',
      'walkie_toggle_mute',
      'walkie_user_mute',
      'walkie_user_muted',
      'walkie_peer_mute',
      'walkie_peer_muted',
      'walkie_mute',
      'toggle_mute',
      'group_walkie_mute',
      'group_walkie_participant_mute',
      'group_call_participant_mute',
      'walkie_participant_muted',
      'walkie_error',
      'force_logout',
      'exit_group_success',
      'pong_walkie',
    ]) {
      socket?.off(e);
    }

    // socket?.on('walkie_invite', (data) {
    //   if (data == null) return;
    //
    //   WalkieInviteDialog.show(
    //     groupId: data['groupId']?.toString() ?? '',
    //     groupName: data['groupName']?.toString() ?? 'Group',
    //     speakerName: data['speakerName']?.toString() ?? 'Someone',
    //     speakerImage: data['speakerImage']?.toString() ?? '',
    //   );
    // });

    /*
    socket?.on('walkie_invite', (data) async {
      if (_isDisposed || data == null) return;
      final groupId = data['groupId']?.toString() ?? '';
      final groupName = data['groupName']?.toString() ?? 'Group';
      final speakerName = data['speakerName']?.toString() ?? 'Someone';
      final speakerImage = data['speakerImage']?.toString() ?? '';

      if (groupId.isEmpty) return;
      if (_currentGroupId == groupId && WalkieLaunchTracker.fromWalkieCall) return;

      if (_currentGroupId != null) {
        await leaveGroup();
      }

      Get.to(
            () => const GroupWalkieScreen(),
        routeName: Routes.groupWalkieScreen,
        arguments: {
          "groupId": groupId,
          "groupName": groupName,
          "speakerName": speakerName,
          "speakerImage": speakerImage,
          "autoOpened": true,
        },
      );
    });

     */

    socket?.on('force_logout', (_) async {
      await dispose();
    });

    socket?.on('walkie_existing_peers', (data) async {
      if (_isDisposed || data == null) return;
      _log('👥 walkie_existing_peers received: $data');
      final peers = (data is Map ? (data['peers'] ?? data['participants']) : null) as List? ??
          (data is List ? data : []);

      for (final p in peers) {
        String id = '';
        String name = 'User';
        String image = '';
        bool isPeerMuted = false;
        if (p is Map) {
          id = p['userId']?.toString() ?? p['user_id']?.toString() ?? p['id']?.toString() ?? '';
          name = p['name']?.toString() ?? p['userName']?.toString() ?? 'User';
          image = p['image']?.toString() ?? p['profileImage']?.toString() ?? p['userImage']?.toString() ?? '';
          isPeerMuted = (p['isMuted'] ?? p['muted'] ?? p['is_muted'] ?? (p['status'] == 'muted')) == true;
        } else {
          id = p.toString();
        }

        if (id.isEmpty || id == _selfUserId) continue;

        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>().addOrUpdateParticipant(
            WalkieParticipant(
              userId: id,
              name: name,
              image: image,
              isMuted: isPeerMuted,
              isSpeaking: false,
              isListening: true,
            ),
          );
        }

        if (_offeredTo.contains(id)) continue;

        _offeredTo.add(id);
        await _createPeer(id);
        await Future.delayed(const Duration(milliseconds: 50));
        await _createOfferTo(id);
      }
    });

    socket?.on('walkie_peer_joined', (data) async {
      if (_isDisposed || data == null) return;
      _log('👋 walkie_peer_joined received: $data');
      String id = '';
      String name = 'User';
      String image = '';
      bool isPeerMuted = false;
      if (data is Map) {
        id = data['userId']?.toString() ?? data['user_id']?.toString() ?? data['id']?.toString() ?? '';
        name = data['name']?.toString() ?? data['userName']?.toString() ?? 'User';
        image = data['image']?.toString() ?? data['profileImage']?.toString() ?? data['userImage']?.toString() ?? '';
        isPeerMuted = (data['isMuted'] ?? data['muted'] ?? data['is_muted'] ?? (data['status'] == 'muted')) == true;
      } else {
        id = data.toString();
      }
      if (id.isEmpty || id == _selfUserId) return;

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().addOrUpdateParticipant(
          WalkieParticipant(
            userId: id,
            name: name,
            image: image,
            isMuted: isPeerMuted,
            isSpeaking: false,
            isListening: true,
          ),
        );
      }

      // Existing peer pre-creates peer connection so it is ready to receive offer/candidates
      await _createPeer(id);
    });

    socket?.on('walkie_peer_left', (data) async {
      if (_isDisposed || data == null) return;
      _log('👋 walkie_peer_left received: $data');
      final id = data is Map ? (data['userId'] ?? data['id'])?.toString() : data.toString();
      if (id != null && id.isNotEmpty) {
        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>().removeParticipant(id);
        }
        await _closePeer(id);
      }
    });

    socket?.on('walkie_webrtc_offer', (data) async {
      if (_isDisposed || data == null) return;
      final from = data['fromUserId']?.toString();
      final sdp = data['sdp'];
      if (from == null || sdp == null) return;
      await _handleOffer(from, sdp);
    });

    socket?.on('walkie_webrtc_answer', (data) async {
      if (_isDisposed || data == null) return;
      final from = data['fromUserId']?.toString();
      final sdp = data['sdp'];
      if (from == null || sdp == null) return;
      await _handleAnswer(from, sdp);
    });

    socket?.on('walkie_webrtc_ice', (data) async {
      if (_isDisposed || data == null) return;
      final from = data['fromUserId']?.toString();
      final ice = data['iceCandidate'] ?? data['candidate'];
      if (from == null || ice == null) return;
      await _handleIce(from, ice);
    });

    socket?.on('ptt_granted', (_) async {
      if (_isDisposed) return;
      _log('PTT_GRANTED received');

      if (Get.isRegistered<GroupWalkieController>()) {
        final c = Get.find<GroupWalkieController>();
        if (!c.isPressed.value && !c.isSelfLocked.value) {
          _log('PTT_GRANTED auto-cancelled: user finger is already up');
          _isTalking = false;
          await _enableMic(false);
          socket?.emit('ptt_release', {'groupId': _currentGroupId});
          c.stopTalking();
          return;
        }
      }

      await _enableMic(true);

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().startTalking();
      }
    });

    socket?.on('ptt_denied', (data) async {
      if (_isDisposed) return;
      _isTalking = false;
      await _enableMic(false);
      if (Get.isRegistered<GroupWalkieController>()) {
        final c = Get.find<GroupWalkieController>();
        c.forceUnlockAndReset();
        final reason = (data is Map
                ? (data['reason'] ?? data['error'] ?? data['message'])
                : data)
            ?.toString()
            .toUpperCase() ??
            '';
        _log('⚠️ PTT denied by server: $reason | payload: $data');

        if (reason == 'BUSY') {
          c.showBusyMessage(data is Map ? data['speakerName']?.toString() ?? 'Someone' : 'Someone');
        } else if (reason == 'LOCKED') {
          c.showLockedMessage();
        } else if (reason.contains('NO_SEAT') ||
            reason.contains('NOT_ASSIGNED') ||
            reason.contains('UNASSIGNED') ||
            reason.contains('NO_VOICE')) {
          c.showNoVoiceSeatMessage();
        } else if (reason.contains('PLAN') ||
            reason.contains('SUBSCRIB') ||
            reason.contains('EXPIRED') ||
            reason.contains('TRIAL') ||
            reason.contains('UNAUTHORIZED')) {
          c.showTrialEndedMessage();
        } else if (reason.isNotEmpty) {
          c.showGenericErrorMessage(data is Map && data['message'] != null ? data['message'].toString() : "Cannot speak on this channel");
        } else {
          c.showGenericErrorMessage("Voice transmission not permitted");
        }
      }
    });

    // socket?.on('walkie_speaker_active', (data) {
    //   if (_isDisposed || data == null) return;
    //   final gId = data is Map ? data['groupId']?.toString() : null;
    //   if (gId != null && _currentGroupId != null && gId != _currentGroupId) {
    //     return;
    //   }
    //   final speakerId = data['speakerId']?.toString() ?? '';
    //   if (Get.isRegistered<GroupWalkieController>()) {
    //     Get.find<GroupWalkieController>().onSpeakerActive(
    //       speakerId: speakerId,
    //       speakerName: data['speakerName']?.toString() ?? 'User',
    //       speakerImage: data['speakerImage']?.toString() ?? '',
    //     );
    //   }
    // });


    socket?.on('walkie_speaker_active', (data) async {
      if (_isDisposed || data == null) return;

      final speakerId = data['speakerId']?.toString() ?? '';
      final speakerName = data['speakerName']?.toString() ?? 'User';
      final speakerImage = data['speakerImage']?.toString() ?? '';
      final groupId = data['groupId']?.toString() ?? _currentGroupId ?? '';
      final groupName = data['groupName']?.toString() ?? '';

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerActive(
          speakerId: speakerId,
          speakerName: speakerName,
          speakerImage: speakerImage,
        );
      }

      await WalkieNotificationManager.instance.onSomeoneStartedTalking(
        speakerId: speakerId,
        speakerName: speakerName,
        groupId: groupId,
        groupName: groupName,
      );
    });

    socket?.on('ptt_release', (data) {
      if (_isDisposed) return;
      final gId = data is Map ? data['groupId']?.toString() : null;
      if (gId != null && _currentGroupId != null && gId != _currentGroupId) {
        return;
      }
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }
    });

    // socket?.on('walkie_speaker_stopped', (data) {
    //   if (_isDisposed) return;
    //   final gId = data is Map ? data['groupId']?.toString() : null;
    //   if (gId != null && _currentGroupId != null && gId != _currentGroupId) {
    //     return;
    //   }
    //   if (Get.isRegistered<GroupWalkieController>()) {
    //     Get.find<GroupWalkieController>().onSpeakerStopped();
    //   }
    // });

    socket?.on('walkie_speaker_stopped', (data) async {
      if (_isDisposed) return;

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }

      await WalkieNotificationManager.instance.onSomeoneStoppedTalking(
        speakerId: data is Map ? data['speakerId']?.toString() : null,
        speakerName: data is Map ? data['speakerName']?.toString() : null,
      );
    });

    socket?.on('walkie_participants_update', (data) {
      if (_isDisposed || data == null) return;
      final listRaw = (data['participants'] as List? ?? []);
      if (!Get.isRegistered<GroupWalkieController>()) return;
      final list = listRaw
          .map((p) =>
          WalkieParticipant.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
      Get.find<GroupWalkieController>().updateParticipants(
        list,
        activeSpeaker: data['activeSpeaker']?.toString(),
      );
    });

    socket?.on('walkie_channel_locked', (data) {
      if (_isDisposed || data == null) return;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>()
            .onChannelLocked(isLocked: data['isLocked'] == true);
      }
    });

    void handleMuteEvent(dynamic data) {
      if (_isDisposed || data == null) return;
      String userId = '';
      bool isMuted = false;
      if (data is Map) {
        userId = (data['userId'] ??
                data['user_id'] ??
                data['fromUserId'] ??
                data['peerId'] ??
                data['speakerId'] ??
                data['id'])
            ?.toString() ??
            '';
        isMuted = (data['isMuted'] == true ||
            data['muted'] == true ||
            data['is_muted'] == true ||
            data['status'] == 'muted' ||
            data['mute'] == true);
      } else {
        userId = data.toString();
        isMuted = true;
      }
      _log('🔇 Mute event received: raw=$data, parsed userId=$userId, isMuted=$isMuted');
      if (userId.isNotEmpty && Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setParticipantMuted(userId, isMuted);
      }
    }

    socket?.on('walkie_toggle_mute', handleMuteEvent);
    socket?.on('walkie_user_mute', handleMuteEvent);
    socket?.on('walkie_user_muted', handleMuteEvent);
    socket?.on('walkie_peer_mute', handleMuteEvent);
    socket?.on('walkie_peer_muted', handleMuteEvent);
    socket?.on('walkie_mute', handleMuteEvent);
    socket?.on('toggle_mute', handleMuteEvent);
    socket?.on('group_walkie_mute', handleMuteEvent);
    socket?.on('group_walkie_participant_mute', handleMuteEvent);
    socket?.on('group_call_participant_mute', handleMuteEvent);
    socket?.on('group_call_mute', handleMuteEvent);
    socket?.on('walkie_participant_muted', handleMuteEvent);
    socket?.on('walkie_participant_mute', handleMuteEvent);

    socket?.on('walkie_error', (data) {
      if (_isDisposed || data == null) return;
      final msg = data is Map
          ? (data['message'] ?? data['error'] ?? 'Walkie Talkie Error').toString()
          : data.toString();
      _log('❌ walkie_error received: $msg');
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().showGenericErrorMessage(msg);
      }
    });
  }

  // FIXED: Direct fallback to getUserMedia if permission_handler is restricted
  Future<bool> _ensureLocalStream() async {
    if (_localStream != null) return true;
    if (_streamCompleter != null) return _streamCompleter!.future;

    _streamCompleter = Completer<bool>();

    try {
      _log('Acquiring local media stream via getUserMedia...');

      final Map<String, dynamic> mediaConstraints = {
        'audio': Platform.isIOS
            ? {
                'echoCancellation': true,
                'noiseSuppression': true,
              }
            : {
                'echoCancellation': true,
                'noiseSuppression': true,
                'autoGainControl': true,
                'googEchoCancellation': true,
                'googAutoGainControl': true,
                'googNoiseSuppression': true,
                'googHighpassFilter': false,
                'googAudioMirroring': false,
              },
        'video': false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      for (final t in _localStream!.getAudioTracks()) {
        t.enabled = false;
      }

      _hasMicPermission = true;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setMicPermission(true);
      }

      _log('✅ Successfully acquired local audio stream');
      _streamCompleter!.complete(true);
      final result = await _streamCompleter!.future;
      _streamCompleter = null;
      return result;
    } catch (e) {
      _log('❌ getUserMedia execution failed: $e');
      _localStream = null;
      if (!_streamCompleter!.isCompleted) {
        _streamCompleter!.complete(false);
      }
      _streamCompleter = null;
      return false;
    }
  }

  Future<RTCPeerConnection?> _createPeer(String remoteUserId) async {
    if (_isDisposed) return null;

    if (_peers.containsKey(remoteUserId)) {
      final existing = _peers[remoteUserId]!;
      final st = existing.connectionState;
      if (st == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          st == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          st == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        await _closePeer(remoteUserId);
      } else {
        return existing;
      }
    }

    final ok = await _ensureLocalStream();
    if (!ok) return null;

    final pc = await createPeerConnection(_rtcConfig);

    for (final t in _localStream!.getTracks()) {
      await pc.addTrack(t, _localStream!);
    }

    pc.onTrack = (event) async {
      if (_isDisposed) return;
      if (event.track.kind != 'audio') return;

      _log('🎧 [AudioTrack] Remote track received from $remoteUserId');

      try {
        event.track.enabled = true;
      } catch (_) {}

      if (event.streams.isNotEmpty) {
        _remoteStreams[remoteUserId] = event.streams[0];
        for (final t in event.streams[0].getAudioTracks()) {
          try {
            t.enabled = true;
            t.enableSpeakerphone(_isSpeakerOn);
          } catch (_) {}
        }
      } else {
        final stream = await createLocalMediaStream('remote_$remoteUserId');
        await stream.addTrack(event.track);
        _remoteStreams[remoteUserId] = stream;
        try {
          event.track.enableSpeakerphone(_isSpeakerOn);
        } catch (_) {}
      }

      await setAudioRoute(audioRoute.value);
    };

    pc.onDataChannel = (channel) {
      _log('📡 Received remote DataChannel from $remoteUserId: ${channel.label}');
      _setupDataChannel(remoteUserId, channel);
    };

    pc.onIceCandidate = (c) {
      if (_isDisposed) return;
      if (c.candidate == null || _currentGroupId == null) return;
      socket?.emit('walkie_webrtc_ice', {
        'groupId': _currentGroupId,
        'targetUserId': remoteUserId,
        'iceCandidate': {
          'id': c.sdpMid,
          'label': c.sdpMLineIndex,
          'candidate': c.candidate,
        },
      });
    };

    pc.onIceConnectionState = (state) async {
      _log('❄️ ICE state for $remoteUserId: ${state.name}');
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        _log('⚠️ ICE failed for $remoteUserId, resetting peer for recovery');
        await _closePeer(remoteUserId);
      }
    };

    pc.onConnectionState = (state) async {
      _log('📡 Peer $remoteUserId connection state: ${state.name}');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        await _closePeer(remoteUserId);
      }
    };

    _peers[remoteUserId] = pc;

    final pending = _pendingIce.remove(remoteUserId) ?? [];
    for (final ice in pending) {
      try {
        await pc.addCandidate(ice);
      } catch (_) {}
    }

    return pc;
  }

  Future<void> _createOfferTo(String remoteUserId) async {
    if (_isDisposed) return;
    if (remoteUserId == _selfUserId) return;
    if (_makingOffer.contains(remoteUserId)) return;

    _makingOffer.add(remoteUserId);
    try {
      final pc = await _createPeer(remoteUserId);
      if (pc == null) return;

      final signal = pc.signalingState;
      final conn = pc.connectionState;

      if (signal != null &&
          signal != RTCSignalingState.RTCSignalingStateStable) {
        _log('⚠️ Skip createOfferTo $remoteUserId: signalingState is $signal');
        return;
      }

      if (conn == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          conn == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await _closePeer(remoteUserId);
        return;
      }

      _log('📡 Creating SDP Offer to peer: $remoteUserId');

      try {
        final dcInit = RTCDataChannelInit()..ordered = true;
        final dc = await pc.createDataChannel('walkie_control', dcInit);
        _setupDataChannel(remoteUserId, dc);
      } catch (e) {
        _log('⚠️ Error creating DataChannel to $remoteUserId: $e');
      }

      final offer = await pc.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });

      if (_peers[remoteUserId] != pc) return;

      await pc.setLocalDescription(offer);

      socket?.emit('walkie_webrtc_offer', {
        'groupId': _currentGroupId,
        'targetUserId': remoteUserId,
        'sdp': offer.toMap(),
      });
      _log('📤 Emitted walkie_webrtc_offer to $remoteUserId');
    } catch (e) {
      _log('❌ Error creating offer to $remoteUserId: $e');
    } finally {
      _makingOffer.remove(remoteUserId);
    }
  }

  Future<void> _handleOffer(String from, dynamic sdp) async {
    if (_isDisposed) return;
    try {
      _log('📥 Handling walkie_webrtc_offer from $from');
      final pc = await _createPeer(from);
      if (pc == null) return;

      if (pc.signalingState != RTCSignalingState.RTCSignalingStateStable) {
        final self = _selfUserId ?? '';
        final bool isPolite = self.compareTo(from) < 0;
        if (!isPolite) {
          _log('⚠️ Offer collision with $from: impolite peer ignoring offer');
          return;
        }

        _log('🔄 Offer collision with $from: polite peer rolling back local offer');
        try {
          await pc.setLocalDescription(RTCSessionDescription('', 'rollback'));
        } catch (e) {
          _log('⚠️ Rollback error: $e');
        }
      }

      if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
        return;
      }

      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
      await _flushPendingIce(from);

      final answer = await pc.createAnswer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });

      if (_peers[from] != pc) return;
      if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
        return;
      }

      await pc.setLocalDescription(answer);

      socket?.emit('walkie_webrtc_answer', {
        'groupId': _currentGroupId,
        'targetUserId': from,
        'sdp': answer.toMap(),
      });
      _log('📤 Emitted walkie_webrtc_answer to $from');
    } catch (e) {
      _log('❌ Error in _handleOffer from $from: $e');
    }
  }

  Future<void> _handleAnswer(String from, dynamic sdp) async {
    if (_isDisposed) return;
    _log('📥 Handling walkie_webrtc_answer from $from');
    final pc = _peers[from];
    if (pc == null) return;

    final state = pc.signalingState;
    if (state != RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      _log('⚠️ _handleAnswer ignored for $from: signalingState is $state');
      return;
    }

    try {
      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
      await _flushPendingIce(from);
      _log('✅ WebRTC connection handshake completed with $from');
    } catch (e) {
      _log('❌ Error setting remote description answer from $from: $e');
    }
  }

  Future<void> _flushPendingIce(String from) async {
    final pc = _peers[from];
    if (pc == null) return;
    final remoteDesc = await pc.getRemoteDescription();
    if (remoteDesc == null) return;

    final pending = _pendingIce.remove(from) ?? [];
    for (final ice in pending) {
      try {
        await pc.addCandidate(ice);
      } catch (e) {
        _log('⚠️ Error adding flushed ICE candidate: $e');
      }
    }
  }

  Future<void> _handleIce(String from, dynamic iceMap) async {
    if (_isDisposed) return;
    final candidate = iceMap['candidate'];
    final id = iceMap['id'] ?? iceMap['sdpMid'];
    final label = iceMap['label'] ?? iceMap['sdpMLineIndex'];

    final ice = RTCIceCandidate(
      candidate,
      id?.toString(),
      label is int ? label : int.tryParse(label?.toString() ?? ''),
    );

    final pc = _peers[from];
    if (pc == null) {
      _pendingIce.putIfAbsent(from, () => []).add(ice);
      return;
    }

    final remote = await pc.getRemoteDescription();
    if (remote == null) {
      _pendingIce.putIfAbsent(from, () => []).add(ice);
      return;
    }

    try {
      await pc.addCandidate(ice);
    } catch (_) {}
  }

  Future<void> _closePeer(String userId) async {
    final pc = _peers.remove(userId);
    _pendingIce.remove(userId);
    _makingOffer.remove(userId);
    _offeredTo.remove(userId);

    if (pc != null) {
      pc.onTrack = null;
      pc.onIceCandidate = null;
      pc.onConnectionState = null;
      pc.onIceConnectionState = null;
      pc.onIceGatheringState = null;
      pc.onSignalingState = null;
      try {
        await pc.close();
      } catch (_) {}
    }

    final dc = _dataChannels.remove(userId);
    try {
      await dc?.close();
    } catch (_) {}

    final s = _remoteStreams.remove(userId);
    try {
      s?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
  }

  void _setupDataChannel(String remoteUserId, RTCDataChannel channel) {
    _dataChannels[remoteUserId] = channel;
    channel.onMessage = (message) {
      if (message.isBinary) return;
      try {
        final data = jsonDecode(message.text);
        if (data is Map) {
          final type = data['type']?.toString();
          if (type == 'mute_update' || type == 'mute_state') {
            final userId = data['userId']?.toString() ?? remoteUserId;
            final isMuted = data['isMuted'] == true ||
                data['muted'] == true ||
                data['is_muted'] == true ||
                data['status'] == 'muted';
            _log('📡 Direct WebRTC DataChannel mute message: userId=$userId, isMuted=$isMuted');
            if (userId.isNotEmpty && Get.isRegistered<GroupWalkieController>()) {
              Get.find<GroupWalkieController>().setParticipantMuted(userId, isMuted);
            }
          }
        }
      } catch (e) {
        _log('⚠️ Error parsing DataChannel message: $e');
      }
    };
    channel.onDataChannelState = (state) {
      _log('📡 DataChannel state for $remoteUserId: ${state.name}');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        try {
          channel.send(
            RTCDataChannelMessage(
              jsonEncode({
                'type': 'mute_update',
                'userId': _selfUserId,
                'isMuted': _isMuted,
              }),
            ),
          );
          _log('📡 Sent initial DataChannel mute state ($_isMuted) to $remoteUserId');
        } catch (e) {
          _log('⚠️ Failed to send initial DataChannel mute state to $remoteUserId: $e');
        }
      }
    };
  }

  Future<void> _enableMic(bool enabled) async {
    if (_localStream == null) return;
    final actualState = enabled && !_isMuted;
    _log('🎤 _enableMic called: enabled=$enabled, _isMuted=$_isMuted => actualState=$actualState');
    for (final t in _localStream!.getAudioTracks()) {
      try {
        t.enabled = actualState;
      } catch (_) {}
    }
    for (final pc in _peers.values) {
      try {
        final senders = await pc.getSenders();
        for (final sender in senders) {
          if (sender.track?.kind == 'audio') {
            sender.track?.enabled = actualState;
          }
        }
      } catch (_) {}
    }
  }

  Future<bool> joinGroup(String groupId, {String groupName = 'Walkie-Talkie'}) async {
    _isDisposed = false;
    _currentGroupId = groupId;
    _offeredTo.clear();
    _makingOffer.clear();
    _log('Joining walkie group: $groupId');

    try {
      WalkieForegroundService.start(groupName: groupName);
    } catch (e) {
      _log('⚠️ WalkieForegroundService.start error: $e');
    }

    final savedUserId = _selfUserId ??
        Global.storageServices.get(PrefConst.userId)?.toString();
    if (savedUserId != null && savedUserId.isNotEmpty) {
      _selfUserId = savedUserId;
    }

    if (socket == null || socket?.connected != true) {
      if (savedUserId != null && savedUserId.isNotEmpty) {
        _log('Re-initializing socket in joinGroup for user: $savedUserId');
        await init(
          websocketUrl: ConstRes.socketUrl,
          selfUserId: savedUserId,
        );
      }
      int waitCount = 0;
      while ((socket == null || socket?.connected != true) && waitCount < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
    }

    await _configureAudioSession(speakerOn: _isSpeakerOn);

    final ok = await _ensureLocalStream();
    if (!ok) {
      _log('❌ joinGroup: Failed to ensure local stream');
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().showPermissionDeniedMessage();
      }
      return false;
    }

    // Emit join session ONLY after localStream and socket are fully ready
    final parsedGroupId = int.tryParse(groupId) ?? groupId;
    final parsedUserId = int.tryParse(_selfUserId ?? '') ?? _selfUserId;
    final joinPayload = {
      'groupId': parsedGroupId,
      'groupIdStr': groupId,
      'userId': parsedUserId,
      'fromUserId': _selfUserId,
    };
    socket?.emit('join_walkie_session', joinPayload);
    _log('✅ Emitted join_walkie_session: $joinPayload (socket connected: ${socket?.connected})');

    WalkieNotificationManager.instance.setWalkieJoined(
      true,
      groupId: groupId,
      groupName: groupName,
    );
    return true;
  }

  Future<void> leaveGroup() async {
    if (_currentGroupId == null) return;

    final groupId = _currentGroupId;
    _currentGroupId = null;

    try {
      await WalkieForegroundService.stop();
    } catch (_) {}

    final parsedGroupId = int.tryParse(groupId ?? '') ?? groupId;
    final parsedUserId = int.tryParse(_selfUserId ?? '') ?? _selfUserId;
    final leavePayload = {
      'groupId': parsedGroupId,
      'groupIdStr': groupId,
      'userId': parsedUserId,
      'fromUserId': _selfUserId,
    };

    if (_isTalking) {
      _isTalking = false;
      await _enableMic(false);
      socket?.emit('ptt_release', leavePayload);
    }

    socket?.emit('leave_walkie_session', leavePayload);

    for (final id in _peers.keys.toList()) {
      await _closePeer(id);
    }

    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    _streamCompleter = null;
  }

  Future<void> exitGroupMembership(String groupId) async {
    await leaveGroup();
    final parsedGroupId = int.tryParse(groupId) ?? groupId;
    final parsedUserId = int.tryParse(_selfUserId ?? '') ?? _selfUserId;
    socket?.emit('exit_group_membership', {
      'groupId': parsedGroupId,
      'groupIdStr': groupId,
      'userId': parsedUserId,
      'fromUserId': _selfUserId,
    });
    WalkieNotificationManager.instance.setWalkieJoined(false);
    await WalkieNotificationManager.instance.hideNotification();
  }

  // FIXED: Explicit debugging guards to catch why PTT returns false
  Future<bool> startTalking() async {
    if (_isDisposed) {
      _isDisposed = false;
    }
    if (_currentGroupId == null && Get.isRegistered<GroupWalkieController>()) {
      final cGroupId = Get.find<GroupWalkieController>().currentGroupId;
      if (cGroupId != null && cGroupId.isNotEmpty) {
        _currentGroupId = cGroupId;
      }
    }
    _log('startTalking() requested. State => disposed: $_isDisposed, groupId: $_currentGroupId, isTalking: $_isTalking, isMuted: $_isMuted');

    if (_currentGroupId == null || _currentGroupId!.isEmpty) {
      _log('❌ startTalking failed: _currentGroupId is null/empty');
      return false;
    }
    if (_isTalking) {
      _log('❌ startTalking failed: Already talking');
      return false;
    }
    if (_isMuted) {
      _log('❌ startTalking failed: User is muted');
      return false;
    }

    if (_localStream == null) {
      final ok = await _ensureLocalStream();
      if (!ok) {
        _log('❌ startTalking failed: Could not get audio stream');
        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>().showPermissionDeniedMessage();
        }
        return false;
      }
    }

    final parsedGroupId = int.tryParse(_currentGroupId ?? '') ?? _currentGroupId;
    final parsedUserId = int.tryParse(_selfUserId ?? '') ?? _selfUserId;
    final pttPayload = {
      'groupId': parsedGroupId,
      'groupIdStr': _currentGroupId,
      'userId': parsedUserId,
      'fromUserId': _selfUserId,
    };

    // Re-ensure room presence on socket before requesting speech grant
    socket?.emit('join_walkie_session', pttPayload);

    _isTalking = true;
    _log('🚀 Emitting ptt_request: $pttPayload');
    socket?.emit('ptt_request', pttPayload);
    await _enableMic(true);

    WalkieForegroundService.updateNotification(
      text: '🎤 Transmitting voice... (Active)',
    );

    return true;
  }

  Future<void> stopTalking() async {
    _isTalking = false;
    await _enableMic(false);
    if (_currentGroupId != null) {
      final parsedGroupId = int.tryParse(_currentGroupId ?? '') ?? _currentGroupId;
      final parsedUserId = int.tryParse(_selfUserId ?? '') ?? _selfUserId;
      socket?.emit('ptt_release', {
        'groupId': parsedGroupId,
        'groupIdStr': _currentGroupId,
        'userId': parsedUserId,
        'fromUserId': _selfUserId,
      });
    }

    WalkieForegroundService.updateNotification(
      text: '👂 Listening on walkie channel',
    );

    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().stopTalking();
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;

    if (_isMuted) {
      await _enableMic(false);

      if (_isTalking) {
        _isTalking = false;
        socket?.emit('ptt_release', {'groupId': _currentGroupId});

        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>().forceUnlockAndReset();
        }
      }
    }

    final payload = {
      'groupId': int.tryParse(_currentGroupId ?? '') ?? _currentGroupId,
      'groupIdStr': _currentGroupId,
      'callId': int.tryParse(_currentGroupId ?? '') ?? _currentGroupId,
      'userId': int.tryParse(selfUserId ?? '') ?? selfUserId,
      'userIdStr': selfUserId,
      'fromUserId': selfUserId,
      'isMuted': _isMuted,
      'muted': _isMuted,
      'is_muted': _isMuted,
      'status': _isMuted ? 'muted' : 'unmuted',
    };
    socket?.emit('walkie_toggle_mute', payload);
    socket?.emit('toggle_mute', payload);
    socket?.emit('walkie_user_mute', payload);
    socket?.emit('walkie_mute', payload);
    socket?.emit('group_walkie_mute', payload);
    socket?.emit('group_call_mute', payload);
    socket?.emit('group_call_participant_mute', payload);
    socket?.emit('walkie_participant_mute', payload);
    socket?.emit('walkie_participant_muted', payload);

    for (final peerId in _peers.keys) {
      socket?.emit('walkie_toggle_mute', {
        ...payload,
        'targetUserId': peerId,
      });
      socket?.emit('walkie_peer_mute', {
        ...payload,
        'targetUserId': peerId,
      });
    }

    final dcPayload = jsonEncode({
      'type': 'mute_update',
      'userId': selfUserId,
      'isMuted': _isMuted,
    });
    for (final entry in _dataChannels.entries) {
      try {
        if (entry.value.state == RTCDataChannelState.RTCDataChannelOpen) {
          entry.value.send(RTCDataChannelMessage(dcPayload));
          _log('📡 Sent direct DataChannel mute update to ${entry.key}: $_isMuted');
        }
      } catch (e) {
        _log('⚠️ Error sending DataChannel mute update to ${entry.key}: $e');
      }
    }

    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().setMuteFromService(_isMuted);
    }
  }

  Future<void> setAudioRoute(WalkieAudioRoute route) async {
    if (_isDisposed) return;
    audioRoute.value = route;
    _isSpeakerOn = (route == WalkieAudioRoute.speaker);
    _log('🎧 [AudioRoute] setAudioRoute -> target: $route (isSpeaker: $_isSpeakerOn)');

    try {
      if (Platform.isAndroid) {
        final am = AndroidAudioManager();
        try {
          await am.setMode(AndroidAudioHardwareMode.inCommunication);
        } catch (e) {
          _log('⚠️ [AudioRoute] setMode error: $e');
        }

        if (route == WalkieAudioRoute.speaker) {
          try {
            await am.stopBluetoothSco();
            await am.setBluetoothScoOn(false);
          } catch (_) {}
          try {
            await Helper.setSpeakerphoneOn(true);
          } catch (e) {
            _log('⚠️ [AudioRoute] Helper.setSpeakerphoneOn(true) error: $e');
          }
          try {
            await am.setSpeakerphoneOn(true);
          } catch (_) {}
          try {
            await ProximityScreenLock.setActive(false);
          } catch (_) {}
        } else if (route == WalkieAudioRoute.bluetooth) {
          try {
            await Helper.setSpeakerphoneOn(false);
          } catch (_) {}
          try {
            await am.setSpeakerphoneOn(false);
          } catch (_) {}
          try {
            await am.startBluetoothSco();
            await Future.delayed(const Duration(milliseconds: 150));
            await am.setBluetoothScoOn(true);
          } catch (e) {
            _log('⚠️ [AudioRoute] BluetoothSco error: $e');
          }
          try {
            await ProximityScreenLock.setActive(false);
          } catch (_) {}
        } else if (route == WalkieAudioRoute.earpiece) {
          try {
            await am.stopBluetoothSco();
            await am.setBluetoothScoOn(false);
          } catch (_) {}
          try {
            await Helper.setSpeakerphoneOn(false);
          } catch (e) {
            _log('⚠️ [AudioRoute] Helper.setSpeakerphoneOn(false) error: $e');
          }
          try {
            await am.setSpeakerphoneOn(false);
          } catch (_) {}
          try {
            await ProximityScreenLock.setActive(false);
          } catch (_) {}
        } else if (route == WalkieAudioRoute.headset) {
          try {
            await am.stopBluetoothSco();
            await am.setBluetoothScoOn(false);
          } catch (_) {}
          try {
            await Helper.setSpeakerphoneOn(false);
          } catch (_) {}
          try {
            await am.setSpeakerphoneOn(false);
          } catch (_) {}
          try {
            await ProximityScreenLock.setActive(false);
          } catch (_) {}
        }

        for (final stream in _remoteStreams.values) {
          for (final track in stream.getAudioTracks()) {
            try {
              track.enableSpeakerphone(route == WalkieAudioRoute.speaker);
            } catch (_) {}
          }
        }
      } else if (Platform.isIOS) {
        try {
          await Helper.setSpeakerphoneOn(_isSpeakerOn);
          for (final stream in _remoteStreams.values) {
            for (final track in stream.getAudioTracks()) {
              try {
                track.enableSpeakerphone(_isSpeakerOn);
              } catch (_) {}
            }
          }
          _log('🎧 [AudioRoute] iOS WebRTC Speakerphone applied: $_isSpeakerOn');
        } catch (e) {
          _log('❌ [AudioRoute] iOS WebRTC Speakerphone error: $e');
        }
      }
    } catch (e) {
      _log('❌ [AudioRoute] Error setting audio route $route: $e');
    }

    if (Get.isRegistered<GroupWalkieController>()) {
      final c = Get.find<GroupWalkieController>();
      c.setAudioRoute(route);
      c.isSpeakerOn.value = _isSpeakerOn;
    }
  }

  Future<void> toggleSpeaker(bool speakerOn) async {
    await setAudioRoute(
        speakerOn ? WalkieAudioRoute.speaker : WalkieAudioRoute.earpiece);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _isTalking = false;
    _stopPing();

    try {
      await WalkieForegroundService.stop();
    } catch (_) {}

    try {
      if (Platform.isAndroid) {
        final am = AndroidAudioManager();
        await am.stopBluetoothSco();
        await am.setBluetoothScoOn(false);
        await am.setMode(AndroidAudioHardwareMode.normal);
      }
      await ProximityScreenLock.setActive(false);
    } catch (_) {}

    try {
      if (_currentGroupId != null) {
        socket?.emit('leave_walkie_session', {'groupId': _currentGroupId});
      }
    } catch (_) {}

    for (final id in _peers.keys.toList()) {
      await _closePeer(id);
    }

    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    _streamCompleter = null;

    await _devicesSub?.cancel();
    _devicesSub = null;

    try {
      socket?.clearListeners();
      socket?.disconnect();
      socket?.dispose();
    } catch (_) {}
    socket = null;
    _currentGroupId = null;
    _listenersBound = false;
  }
}