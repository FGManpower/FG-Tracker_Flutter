import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_invite_dialog.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:socket_io_client/socket_io_client.dart';

enum WalkieAudioRoute { speaker, earpiece, bluetooth, headset }

class GroupWalkieService {
  GroupWalkieService._();
  static final instance = GroupWalkieService._();

  Socket? socket;
  String? _selfUserId;
  String? _currentGroupId;

  MediaStream? _localStream;

  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final Map<String, List<RTCIceCandidate>> _pendingIce = {};
  final Set<String> _makingOffer = {};
  final Set<String> _offeredTo = {};

  bool _isTalking = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _listenersBound = false;
  bool _isDisposed = false;

  Timer? _pingTimer;
  StreamSubscription? _devicesSub;

  final Rx<WalkieAudioRoute> audioRoute = WalkieAudioRoute.speaker.obs;

  bool get isTalking => _isTalking;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  String? get currentGroupId => _currentGroupId;

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
    // ignore: avoid_print
    print('WALKIE[${_selfUserId ?? "?"}][g=${_currentGroupId ?? "-"}] $msg');
  }

  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    _isDisposed = false;
    _selfUserId = selfUserId;

    _log('INIT start url=$websocketUrl');
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
      _log('SOCKET connected id=${socket?.id}');
      _listenersBound = false;
      _bindSocketListeners();
      _startPing();

      if (_currentGroupId != null) {
        _log('SOCKET reconnect -> rejoin $_currentGroupId');
        socket?.emit('join_walkie_session', {'groupId': _currentGroupId});
      }
    });

    socket!.onDisconnect((_) {
      _log('SOCKET disconnected');
      _listenersBound = false;
      _stopPing();
    });

    socket!.onConnectError((e) => _log('SOCKET connect_error: $e'));


    socket!.onError((e) => _log('SOCKET error: $e'));
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

  Future<void> _configureAudioSession({required bool speakerOn}) async {
    _log('AUDIO session configure speakerOn=$speakerOn');
    final session = await AudioSession.instance;

    if (Platform.isIOS) {
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionMode: AVAudioSessionMode.videoChat,
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
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
          androidAudioAttributes: AndroidAudioAttributes(
            usage: speakerOn
                ? AndroidAudioUsage.media
                : AndroidAudioUsage.voiceCommunication,
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
      _log('AUDIO setSpeakerphoneOn($speakerOn) OK');
    } catch (e) {
      _log('AUDIO setSpeakerphoneOn error: $e');
    }
  }

  Future<void> _listenAudioDevices() async {
    final session = await AudioSession.instance;
    await _devicesSub?.cancel();
    _devicesSub = session.devicesStream.listen(_updateRoute);
    _updateRoute(await session.getDevices());
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

    _log('AUDIO route=${audioRoute.value} speakerOn=$_isSpeakerOn');

    if (Get.isRegistered<GroupWalkieController>()) {
      final c = Get.find<GroupWalkieController>();
      c.setAudioRoute(audioRoute.value);
      c.isSpeakerOn.value = _isSpeakerOn;
    }
  }

  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;
    _log('SOCKET bind listeners');

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

    socket?.onAny((event, [data]) {
      if (event == 'walkie_webrtc_ice') {
        _log('RX event=$event (ice)');
      } else {
        _log('RX event=$event data=$data');
      }
    });

    socket?.on('walkie_invite', (data) {
      final groupId = data['groupId']?.toString() ?? '';
      final groupName = data['groupName'] ?? 'Group';
      final speakerName = data['speakerName'] ?? 'Someone';
      final speakerImage = data['speakerImage'] ?? '';

      _log('INVITE group=$groupId speaker=$speakerName current=$_currentGroupId route=${Get.currentRoute}');

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
      _log('FORCE LOGOUT');
      await dispose();
    });

    socket?.on('walkie_existing_peers', (data) async {
      final peers = (data['peers'] as List?) ?? [];
      _log('EXISTING_PEERS raw=$peers');

      for (final p in peers) {
        final id = p.toString();
        if (id.isEmpty || id == _selfUserId) continue;
        if (_offeredTo.contains(id)) continue;

        _offeredTo.add(id);
        _log('EXISTING_PEERS create offer to $id');

        // create peer first
        await _createPeer(id);
        // small yield for plugin state
        await Future.delayed(const Duration(milliseconds: 50));
        await _createOfferTo(id);
      }
    });

    socket?.on('walkie_peer_joined', (data) {
      _log('PEER_JOINED ${data['userId']} (wait their offer)');
    });

    socket?.on('walkie_peer_left', (data) async {
      final id = data['userId']?.toString();
      _log('PEER_LEFT $id');
      if (id != null) await _closePeer(id);
    });

    socket?.on('walkie_webrtc_offer', (data) async {
      final from = data['fromUserId']?.toString();
      final sdp = data['sdp'];
      _log('RX OFFER from=$from hasSdp=${sdp != null} type=${sdp is Map ? sdp['type'] : sdp.runtimeType}');
      if (from == null || sdp == null) return;
      await _handleOffer(from, sdp);
    });

    socket?.on('walkie_webrtc_answer', (data) async {
      final from = data['fromUserId']?.toString();
      final sdp = data['sdp'];
      _log('RX ANSWER from=$from hasSdp=${sdp != null} type=${sdp is Map ? sdp['type'] : sdp.runtimeType}');
      if (from == null || sdp == null) return;
      await _handleAnswer(from, sdp);
    });

    socket?.on('walkie_webrtc_ice', (data) async {
      final from = data['fromUserId']?.toString();
      final ice = data['iceCandidate'] ?? data['candidate'];
      _log('RX ICE from=$from hasIce=${ice != null}');
      if (from == null || ice == null) return;
      await _handleIce(from, ice);
    });

    socket?.on('ptt_granted', (_) async {
      _log('PTT_GRANTED -> enable mic');
      await _enableMic(true);
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().startTalking();
      }
    });

    socket?.on('ptt_denied', (data) async {
      _log('PTT_DENIED $data');
      _isTalking = false;
      await _enableMic(false);
      if (Get.isRegistered<GroupWalkieController>()) {
        final c = Get.find<GroupWalkieController>();
        c.stopTalking();
        final reason = data['reason']?.toString();
        if (reason == 'BUSY') {
          c.showBusyMessage(data['speakerName'] ?? 'Someone');
        } else if (reason == 'LOCKED') {
          c.showLockedMessage();
        }
      }
    });

    socket?.on('walkie_speaker_active', (data) {
      _log('SPEAKER_ACTIVE $data');
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerActive(
          speakerId: data['speakerId']?.toString() ?? '',
          speakerName: data['speakerName'] ?? 'User',
          speakerImage: data['speakerImage'] ?? '',
        );
      }
    });

    socket?.on('walkie_speaker_stopped', (_) {
      _log('SPEAKER_STOPPED');
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }
    });

    socket?.on('walkie_participants_update', (data) {
      final listRaw = (data['participants'] as List? ?? []);
      _log('PARTICIPANTS count=${listRaw.length} activeSpeaker=${data['activeSpeaker']}');
      if (!Get.isRegistered<GroupWalkieController>()) return;
      final list = listRaw
          .map((p) => WalkieParticipant.fromMap(Map<String, dynamic>.from(p)))
          .toList();
      Get.find<GroupWalkieController>().updateParticipants(
        list,
        activeSpeaker: data['activeSpeaker']?.toString(),
      );
    });

    socket?.on('walkie_channel_locked', (data) {
      _log('CHANNEL_LOCKED $data');
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>()
            .onChannelLocked(isLocked: data['isLocked'] == true);
      }
    });

    socket?.on('walkie_error', (data) {
      _log('ERROR ${data['code']} ${data['message']}');
    });
  }

  Future<void> _ensureLocalStream() async {
    if (_localStream != null) {
      _log('LOCAL_STREAM already exists tracks=${_localStream!.getAudioTracks().length}');
      return;
    }

    _log('LOCAL_STREAM getUserMedia...');
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    for (final t in _localStream!.getAudioTracks()) {
      t.enabled = false;
      _log('LOCAL_STREAM track id=${t.id} enabled=${t.enabled}');
    }
  }

  Future<RTCPeerConnection> _createPeer(String remoteUserId) async {
    _log('CREATE_PEER $remoteUserId existing=${_peers.containsKey(remoteUserId)}');

    if (_peers.containsKey(remoteUserId)) {
      final existing = _peers[remoteUserId]!;
      final st = existing.connectionState;
      _log('CREATE_PEER existing state=$st');
      if (st == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          st == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await _closePeer(remoteUserId);
      } else {
        return existing;
      }
    }

    final pc = await createPeerConnection(_rtcConfig);
    await _ensureLocalStream();

    for (final t in _localStream!.getTracks()) {
      await pc.addTrack(t, _localStream!);
      _log('CREATE_PEER addTrack kind=${t.kind} enabled=${t.enabled} -> $remoteUserId');
    }

    pc.onTrack = (event) async {
      _log('ON_TRACK from=$remoteUserId kind=${event.track.kind} streams=${event.streams.length} muted=$_isMuted');
      if (event.track.kind != 'audio') return;

      event.track.enabled = !_isMuted;

      if (!_remoteRenderers.containsKey(remoteUserId)) {
        final r = RTCVideoRenderer();
        await r.initialize();
        _remoteRenderers[remoteUserId] = r;
        _log('ON_TRACK renderer initialized for $remoteUserId');
      }

      final renderer = _remoteRenderers[remoteUserId]!;
      if (event.streams.isNotEmpty) {
        renderer.srcObject = event.streams[0];
        _log('ON_TRACK srcObject=event.streams[0] id=${event.streams[0].id}');
      } else {
        final stream = await createLocalMediaStream('remote_$remoteUserId');
        await stream.addTrack(event.track);
        renderer.srcObject = stream;
        _log('ON_TRACK srcObject=manual stream');
      }

      await Helper.setSpeakerphoneOn(_isSpeakerOn);
      await _configureAudioSession(speakerOn: _isSpeakerOn);
      _log('AUDIO ATTACHED/PLAYING from $remoteUserId speakerOn=$_isSpeakerOn');
    };

    pc.onIceCandidate = (c) {
      if (c.candidate == null || _currentGroupId == null) return;
      _log('ICE_OUT to=$remoteUserId cand=${c.candidate?.substring(0, 40)}...');
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

    pc.onIceGatheringState = (s) => _log('ICE_GATHER $remoteUserId => $s');
    pc.onIceConnectionState = (s) => _log('ICE_CONN $remoteUserId => $s');
    pc.onConnectionState = (state) async {
      _log('PC_STATE $remoteUserId => $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        await _closePeer(remoteUserId);
      }
    };
    pc.onSignalingState = (s) => _log('SIGNAL $remoteUserId => $s');

    _peers[remoteUserId] = pc;

    final pending = _pendingIce.remove(remoteUserId) ?? [];
    _log('CREATE_PEER flush pending ICE count=${pending.length} for $remoteUserId');
    for (final ice in pending) {
      try {
        await pc.addCandidate(ice);
      } catch (e) {
        _log('CREATE_PEER pending ICE error: $e');
      }
    }

    return pc;
  }

  Future<void> _createOfferTo(String remoteUserId) async {
    if (remoteUserId == _selfUserId) return;
    if (_makingOffer.contains(remoteUserId)) {
      _log('OFFER skip in-progress $remoteUserId');
      return;
    }

    _makingOffer.add(remoteUserId);
    try {
      final pc = await _createPeer(remoteUserId);

      final signal = pc.signalingState;
      final conn = pc.connectionState;
      _log('OFFER begin $remoteUserId signal=$signal conn=$conn');

      // ✅ ONLY skip if clearly not stable.
      // null can happen briefly on some devices/plugins — do NOT skip.
      if (signal != null &&
          signal != RTCSignalingState.RTCSignalingStateStable) {
        _log('OFFER skip bad state $signal');
        return;
      }

      if (conn == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          conn == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _log('OFFER skip closed/failed conn=$conn');
        await _closePeer(remoteUserId);
        return;
      }

      final offer = await pc.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });

      if (_peers[remoteUserId] != pc) {
        _log('OFFER abort peer replaced');
        return;
      }

      await pc.setLocalDescription(offer);
      _log('OFFER localDescription set type=${offer.type}');

      socket?.emit('walkie_webrtc_offer', {
        'groupId': _currentGroupId,
        'targetUserId': remoteUserId,
        'sdp': offer.toMap(),
      });

      _log('OFFER emitted -> $remoteUserId sdpLen=${offer.sdp?.length ?? 0}');
    } catch (e, st) {
      _log('OFFER error: $e');
      _log('$st');
    } finally {
      _makingOffer.remove(remoteUserId);
    }
  }

  Future<void> _handleOffer(String from, dynamic sdp) async {
    try {
      _log('HANDLE_OFFER from=$from type=${sdp['type']}');
      final pc = await _createPeer(from);

      if (pc.signalingState == RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        final self = _selfUserId ?? '';
        if (self.compareTo(from) > 0) {
          _log('HANDLE_OFFER glare ignore from $from');
          return;
        }
      }

      if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
        _log('HANDLE_OFFER peer closed');
        return;
      }

      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
      _log('HANDLE_OFFER remote set, signal=${pc.signalingState}');

      final answer = await pc.createAnswer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });

      if (_peers[from] != pc) return;
      if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) return;

      await pc.setLocalDescription(answer);
      _log('HANDLE_OFFER local answer set');

      socket?.emit('walkie_webrtc_answer', {
        'groupId': _currentGroupId,
        'targetUserId': from,
        'sdp': answer.toMap(),
      });
      _log('HANDLE_OFFER answer emitted -> $from');
    } catch (e) {
      _log('HANDLE_OFFER error: $e');
    }
  }

  Future<void> _handleAnswer(String from, dynamic sdp) async {
    final pc = _peers[from];
    if (pc == null) {
      _log('HANDLE_ANSWER no peer for $from');
      return;
    }

    final state = pc.signalingState;
    _log('HANDLE_ANSWER from=$from signal=$state type=${sdp['type']}');

    // Accept null or have-local-offer; ignore only clearly wrong states
    if (state != null &&
        state != RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      _log('HANDLE_ANSWER ignore wrong state=$state');
      return;
    }

    try {
      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
      _log('HANDLE_ANSWER applied OK from $from now=${pc.signalingState}');
    } catch (e) {
      _log('HANDLE_ANSWER error: $e');
    }
  }

  Future<void> _handleIce(String from, dynamic iceMap) async {
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
      _log('ICE buffer (no peer yet) from=$from pending=${_pendingIce[from]?.length}');
      return;
    }

    final remote = await pc.getRemoteDescription();
    if (remote == null) {
      _pendingIce.putIfAbsent(from, () => []).add(ice);
      _log('ICE buffer (no remote desc) from=$from');
      return;
    }

    try {
      await pc.addCandidate(ice);
      _log('ICE added from=$from');
    } catch (e) {
      _log('ICE add error: $e');
    }
  }

  Future<void> _closePeer(String userId) async {
    _log('CLOSE_PEER $userId');
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
      } catch (e) {
        _log('CLOSE_PEER pc error: $e');
      }
    }

    final r = _remoteRenderers.remove(userId);
    try {
      r?.srcObject = null;
      await r?.dispose();
    } catch (_) {}
  }

  Future<void> _enableMic(bool enabled) async {
    if (_localStream == null) {
      _log('ENABLE_MIC skip localStream null');
      return;
    }
    for (final t in _localStream!.getAudioTracks()) {
      t.enabled = enabled;
      _log('ENABLE_MIC track=${t.id} enabled=${t.enabled}');
    }
  }

  Future<void> joinGroup(String groupId) async {
    _log('JOIN_GROUP request $groupId socketConnected=${socket?.connected}');
    _currentGroupId = groupId;
    _offeredTo.clear();

    await _ensureLocalStream();
    await _configureAudioSession(speakerOn: true);
    await Helper.setSpeakerphoneOn(true);

    socket?.emit('join_walkie_session', {'groupId': groupId});
    _log('JOIN_GROUP emitted join_walkie_session');
  }

  Future<void> leaveGroup() async {
    _log('LEAVE_GROUP current=$_currentGroupId talking=$_isTalking');
    if (_currentGroupId == null) return;

    if (_isTalking) {
      await stopTalking();
    }

    socket?.emit('leave_walkie_session', {'groupId': _currentGroupId});

    for (final id in _peers.keys.toList()) {
      await _closePeer(id);
    }

    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;

    _currentGroupId = null;
  }

  Future<void> exitGroupMembership(String groupId) async {
    await leaveGroup();
    socket?.emit('exit_group_membership', {'groupId': groupId});
  }

  Future<void> startTalking() async {
    _log('START_TALKING group=$_currentGroupId talking=$_isTalking peers=${_peers.keys.toList()}');
    if (_currentGroupId == null || _isTalking) return;
    _isTalking = true;
    await _ensureLocalStream();
    socket?.emit('ptt_request', {'groupId': _currentGroupId});
  }

  Future<void> stopTalking() async {
    _log('STOP_TALKING');
    if (!_isTalking) return;
    _isTalking = false;
    await _enableMic(false);
    socket?.emit('ptt_release', {'groupId': _currentGroupId});
    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().stopTalking();
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    _log('TOGGLE_MUTE $_isMuted');
    socket?.emit('walkie_toggle_mute', {
      'groupId': _currentGroupId,
      'isMuted': _isMuted,
    });

    for (final r in _remoteRenderers.values) {
      r.srcObject?.getAudioTracks().forEach((t) => t.enabled = !_isMuted);
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

  void toggleLockChannel(bool isLocked) {
    socket?.emit('walkie_lock_channel', {
      'groupId': _currentGroupId,
      'isLocked': isLocked,
    });
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _log('DISPOSE');

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

    await _devicesSub?.cancel();
    socket?.clearListeners();
    socket?.disconnect();
    socket?.dispose();
    socket = null;

    _currentGroupId = null;
    _listenersBound = false;
  }
}