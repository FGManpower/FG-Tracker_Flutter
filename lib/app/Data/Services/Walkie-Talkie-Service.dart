import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_invite_dialog.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart';

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

  bool get isTalking => _isTalking;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get hasMicPermission => _hasMicPermission;
  String? get currentGroupId => _currentGroupId;
  String? get selfUserId => _selfUserId;

  static final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {
        'urls': ['stun:stun.l.google.com:19302'],
      },
      {
        'urls': [
          'turn:89.116.23.2:3478?transport=udp',
          'turn:89.116.23.2:3478?transport=tcp',
          'turns:89.116.23.2:443?transport=tcp',
        ],
        'username': 'fgtracker',
        'credential': 'FGM_Tracker@2025',
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
    _isDisposed = false;
    _selfUserId = selfUserId;

    await _configureAudioSession(speakerOn: true);
    await _listenAudioDevices();

    socket = io(
      "$websocketUrl/groupWalkie",
      OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': selfUserId})
          .enableForceNew()
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .build(),
    );

    socket!.onConnect((_) {
      _listenersBound = false;
      _bindSocketListeners();
      _startPing();
      _notifyConnectionState(true);

      if (_currentGroupId != null) {
        socket?.emit('join_walkie_session', {'groupId': _currentGroupId});
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
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      socket?.emit('ping_walkie');
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<bool> _requestMicPermission() async {
    try {
      final status = await Permission.microphone.request();
      _hasMicPermission = status.isGranted;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setMicPermission(_hasMicPermission);
      }
      return _hasMicPermission;
    } catch (e) {
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
      try {
        await Helper.setSpeakerphoneOn(speakerOn);
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> _listenAudioDevices() async {
    try {
      final session = await AudioSession.instance;
      await _devicesSub?.cancel();
      _devicesSub = session.devicesStream.listen(_updateRoute);
      _updateRoute(await session.getDevices());
    } catch (_) {}
  }

  void _updateRoute(Set<AudioDevice> devices) {
    final hasBT = devices.any((d) =>
    d.type == AudioDeviceType.bluetoothA2dp ||
        d.type == AudioDeviceType.bluetoothSco ||
        d.type == AudioDeviceType.bluetoothLe);
    final hasHeadset = devices.any((d) =>
    d.type == AudioDeviceType.wiredHeadset ||
        d.type == AudioDeviceType.wiredHeadphones);

    if (hasBT) {
      audioRoute.value = WalkieAudioRoute.bluetooth;
      _isSpeakerOn = false;
    } else if (hasHeadset) {
      audioRoute.value = WalkieAudioRoute.headset;
      _isSpeakerOn = false;
    } else if (_isSpeakerOn) {
      audioRoute.value = WalkieAudioRoute.speaker;
    } else {
      audioRoute.value = WalkieAudioRoute.earpiece;
    }

    if (Get.isRegistered<GroupWalkieController>()) {
      final c = Get.find<GroupWalkieController>();
      c.setAudioRoute(audioRoute.value);
      c.isSpeakerOn.value = _isSpeakerOn;
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
      'walkie_error',
      'force_logout',
      'exit_group_success',
      'pong_walkie',
    ]) {
      socket?.off(e);
    }

    socket?.on('walkie_invite', (data) {
      if (_isDisposed || data == null) return;
      final groupId = data['groupId']?.toString() ?? '';
      final groupName = data['groupName']?.toString() ?? 'Group';
      final speakerName = data['speakerName']?.toString() ?? 'Someone';
      final speakerImage = data['speakerImage']?.toString() ?? '';

      if (groupId.isEmpty) return;
      if (_currentGroupId == groupId) return;
      if (Get.currentRoute == Routes.groupWalkieScreen) return;

      WalkieInviteDialog.show(
        groupId: groupId,
        groupName: groupName,
        speakerName: speakerName,
        speakerImage: speakerImage,
      );
    });

    socket?.on('force_logout', (_) async {
      await dispose();
    });

    socket?.on('walkie_existing_peers', (data) async {
      if (_isDisposed || data == null) return;
      final peers = (data['peers'] as List?) ?? [];

      for (final p in peers) {
        final id = p.toString();
        if (id.isEmpty || id == _selfUserId) continue;
        if (_offeredTo.contains(id)) continue;

        _offeredTo.add(id);
        await _createPeer(id);
        await Future.delayed(const Duration(milliseconds: 50));
        await _createOfferTo(id);
      }
    });

    socket?.on('walkie_peer_joined', (data) {});

    socket?.on('walkie_peer_left', (data) async {
      if (_isDisposed || data == null) return;
      final id = data['userId']?.toString();
      if (id != null) await _closePeer(id);
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

    // CRITICAL RACE-CONDITION FIX (Single Tap Glitch Resolved)
    socket?.on('ptt_granted', (_) async {
      if (_isDisposed) return;
      _log('PTT_GRANTED received');

      // Check if user has already released the button before server granted the request
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
        final reason = data?['reason']?.toString();
        if (reason == 'BUSY') {
          c.showBusyMessage(data['speakerName']?.toString() ?? 'Someone');
        } else if (reason == 'LOCKED') {
          c.showLockedMessage();
        }
      }
    });

    socket?.on('walkie_speaker_active', (data) {
      if (_isDisposed || data == null) return;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerActive(
          speakerId: data['speakerId']?.toString() ?? '',
          speakerName: data['speakerName']?.toString() ?? 'User',
          speakerImage: data['speakerImage']?.toString() ?? '',
        );
      }
    });

    socket?.on('walkie_speaker_stopped', (_) {
      if (_isDisposed) return;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }
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

    socket?.on('walkie_error', (data) {});
  }

  Future<bool> _ensureLocalStream() async {
    if (_localStream != null) return true;
    if (_streamCompleter != null) return _streamCompleter!.future;

    _streamCompleter = Completer<bool>();

    try {
      final granted = await _requestMicPermission();
      if (!granted) {
        _streamCompleter!.complete(false);
        final result = await _streamCompleter!.future;
        _streamCompleter = null;
        return result;
      }

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });

      for (final t in _localStream!.getAudioTracks()) {
        t.enabled = false;
      }

      _streamCompleter!.complete(true);
      final result = await _streamCompleter!.future;
      _streamCompleter = null;
      return result;
    } catch (e) {
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
          st == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
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

      event.track.enabled = !_isMuted;

      if (event.streams.isNotEmpty) {
        _remoteStreams[remoteUserId] = event.streams[0];
      } else {
        final stream = await createLocalMediaStream('remote_$remoteUserId');
        await stream.addTrack(event.track);
        _remoteStreams[remoteUserId] = stream;
      }
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

    pc.onConnectionState = (state) async {
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
        return;
      }

      if (conn == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          conn == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await _closePeer(remoteUserId);
        return;
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
    } catch (_) {
    } finally {
      _makingOffer.remove(remoteUserId);
    }
  }

  Future<void> _handleOffer(String from, dynamic sdp) async {
    if (_isDisposed) return;
    try {
      final pc = await _createPeer(from);
      if (pc == null) return;

      if (pc.signalingState ==
          RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        final self = _selfUserId ?? '';
        if (self.compareTo(from) > 0) return;
      }

      if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
        return;
      }

      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );

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
    } catch (_) {}
  }

  Future<void> _handleAnswer(String from, dynamic sdp) async {
    if (_isDisposed) return;
    final pc = _peers[from];
    if (pc == null) return;

    final state = pc.signalingState;
    if (state != null &&
        state != RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      return;
    }

    try {
      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
    } catch (_) {}
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

    final s = _remoteStreams.remove(userId);
    try {
      s?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
  }

  Future<void> _enableMic(bool enabled) async {
    if (_localStream == null) return;
    final actualState = enabled && !_isMuted;
    for (final t in _localStream!.getAudioTracks()) {
      t.enabled = actualState;
    }
  }

  Future<bool> joinGroup(String groupId) async {
    if (_isDisposed) return false;
    _currentGroupId = groupId;
    _offeredTo.clear();

    final ok = await _ensureLocalStream();
    if (!ok) {
      _currentGroupId = null;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().showPermissionDeniedMessage();
      }
      return false;
    }

    await _configureAudioSession(speakerOn: _isSpeakerOn);
    socket?.emit('join_walkie_session', {'groupId': groupId});
    return true;
  }

  Future<void> leaveGroup() async {
    if (_currentGroupId == null) return;

    final groupId = _currentGroupId;
    _currentGroupId = null;

    if (_isTalking) {
      _isTalking = false;
      await _enableMic(false);
      socket?.emit('ptt_release', {'groupId': groupId});
    }

    socket?.emit('leave_walkie_session', {'groupId': groupId});

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
    socket?.emit('exit_group_membership', {'groupId': groupId});
  }

  Future<bool> startTalking() async {
    if (_isDisposed) return false;
    if (_currentGroupId == null || _isTalking) return false;
    if (_isMuted) return false;

    final ok = await _ensureLocalStream();
    if (!ok) {
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().showPermissionDeniedMessage();
      }
      return false;
    }

    _isTalking = true;
    socket?.emit('ptt_request', {'groupId': _currentGroupId});
    return true;
  }

  // FORCE_SYNC FIX: Emits release always to prevent stuck on peer side
  Future<void> stopTalking() async {
    _isTalking = false;
    await _enableMic(false);
    if (_currentGroupId != null) {
      socket?.emit('ptt_release', {'groupId': _currentGroupId});
    }
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

    socket?.emit('walkie_toggle_mute', {
      'groupId': _currentGroupId,
      'isMuted': _isMuted,
    });

    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().setMuteFromService(_isMuted);
    }
  }

  Future<void> toggleSpeaker(bool speakerOn) async {
    if (audioRoute.value == WalkieAudioRoute.bluetooth ||
        audioRoute.value == WalkieAudioRoute.headset) {
      return;
    }
    await _configureAudioSession(speakerOn: speakerOn);
    audioRoute.value =
    speakerOn ? WalkieAudioRoute.speaker : WalkieAudioRoute.earpiece;
    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().setAudioRoute(audioRoute.value);
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _isTalking = false;
    _stopPing();

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