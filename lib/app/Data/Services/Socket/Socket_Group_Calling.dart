import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/urls.dart' show Urls;
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Services/CallStateTracker.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:get/get.dart';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class Socket_GroupCallService {
  Socket_GroupCallService._();
  static final instance = Socket_GroupCallService._();

  Socket? socket;
  String? _selfUserId;
  String? currentCallId;
  String? currentGroupId;

  MediaStream? localStream;
  MediaStreamTrack? activeVideoTrack;

  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  final Map<String, List<RTCIceCandidate>> _pendingIce = {};
  final Set<String> remoteUsers = {};
  final Map<String, bool> remoteCameraStates = {};
  final Map<String, Map<String, dynamic>> participantMeta = {};

  final Set<String> _pendingOfferUserIds = <String>{};
  final Map<String, String> participantStatus = {};
  int totalParticipants = 0;

  // ---------------------------------------------------------------------------
  // Video slot management
  // ---------------------------------------------------------------------------
  static const int maxVideoSlots = 4;
  bool callIsVideo = true;

  /// Camera intent per user (including self).
  final Map<String, bool> wantsVideo = {};

  /// Roster order from the server (same on all devices).
  List<String> joinOrder = [];
  Set<String> videoSlotHolders = {};
  bool? _lastEmittedEffective;
  bool? _lastEmittedWants;
  Function(bool effectiveVideoOn, bool wantsVideo)? onLocalVideoSlotChanged;

  // ---------------------------------------------------------------------------
  // Stable transceivers / remote streams
  // ---------------------------------------------------------------------------
  final Map<String, RTCRtpSender> _audioSenders = {};
  final Map<String, RTCRtpSender> _videoSenders = {};
  final Map<String, MediaStream> _remoteStreams = {};
  final Map<String, Future<RTCPeerConnection>> _pcFutures = {};

  Function()? onParticipantsUpdated;
  Function()? onCallEnded;
  Function(String userId)? onParticipantJoined;
  Function(String userId)? onParticipantLeft;
  Function(String userId, String? userName, String? userProfile)?
  onParticipantRejected;
  Function(String userId, bool isMuted)? onParticipantMuteChanged;
  Function(String userId, bool isVideoOn)? onParticipantCameraChanged;
  Function(Map<String, dynamic> data)? onIncomingCallReceived;

  Function(String userId)? onScreenShareStarted;
  Function(String userId)? onScreenShareStopped;

  Function(List<Map<String, dynamic>> participants, int total)?
  onParticipantsRosterUpdated;

  bool _listenersBound = false;
  bool _isDisposed = false;

  String? get selfUserId => _selfUserId;

  static const Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {
        'urls': ['stun:stun.l.google.com:19302']
      },
      {
        'urls': Urls.rtcUrl,
        'username': Urls.rtcUserName,
        'credential': Urls.rtcCredential,
      }
    ],
    'iceTransportPolicy': 'all',
  };

  void _log(String message) => log('[GroupCallService] $message');

  // ---------------------------------------------------------------------------
  // Video slot logic
  // ---------------------------------------------------------------------------
  bool get localVideoEffective {
    final me = _selfUserId;
    if (me == null) return false;
    return (wantsVideo[me] ?? callIsVideo) && videoSlotHolders.contains(me);
  }

  bool isRemoteVideoOn(String id) =>
      remoteCameraStates[id] ??
          ((wantsVideo[id] ?? callIsVideo) && videoSlotHolders.contains(id));

  void setLocalWantsVideo(bool wants) {
    final me = _selfUserId;
    if (me == null) return;
    wantsVideo[me] = wants;
    recomputeVideoSlots(force: true);
  }

  /// Deterministic: first [maxVideoSlots] participants in roster order whose
  /// camera intent is ON get live video. Same result on every device.
  void recomputeVideoSlots({bool force = false}) {
    final me = _selfUserId;
    if (me == null) return;

    final inCall = <String>{...connectedRemoteIds, me};
    final unknown =
    inCall.where((id) => !joinOrder.contains(id)).toList()..sort();
    final ordered = <String>[...joinOrder.where(inCall.contains), ...unknown];

    final holders = <String>{};
    for (final id in ordered) {
      if (holders.length >= maxVideoSlots) break;
      if (wantsVideo[id] ?? callIsVideo) holders.add(id);
    }
    videoSlotHolders = holders;

    final wants = wantsVideo[me] ?? callIsVideo;
    final effective = wants && holders.contains(me);

    if (force ||
        _lastEmittedEffective != effective ||
        _lastEmittedWants != wants) {
      onLocalVideoSlotChanged?.call(effective, wants);
      if (currentCallId != null) {
        _lastEmittedEffective = effective;
        _lastEmittedWants = wants;
        emitCameraChange(isVideoOn: effective, wantsVideo: wants);
      }
    }
    onParticipantsUpdated?.call();
  }

  // ---------------------------------------------------------------------------
  // Meta helpers
  // ---------------------------------------------------------------------------
  void _saveParticipantMeta(
      String userId, {
        String? name,
        String? profileImage,
        bool? isMuted,
      }) {
    final existing = participantMeta[userId] ?? <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) {
      existing['name'] = name.trim();
    }
    if (profileImage != null) {
      existing['profileImage'] = profileImage;
    }
    if (isMuted != null) {
      existing['isMuted'] = isMuted;
    }
    participantMeta[userId] = existing;

    _log(
      "PARTICIPANT META SAVED => "
          "userId=$userId | "
          "meta=${participantMeta[userId]}",
    );
  }

  Set<String> get connectedRemoteIds {
    final ids = <String>{};
    ids.addAll(remoteUsers);
    ids.addAll(_peers.keys);
    ids.addAll(remoteRenderers.keys);
    // roster in-call
    participantStatus.forEach((id, status) {
      if (id != _selfUserId && _isInCallStatus(id, status)) {
        ids.add(id);
      }
    });
    return ids;
  }

  String getParticipantName(String userId) {
    final name = participantMeta[userId]?['name']?.toString();
    if (name != null && name.isNotEmpty) return name;
    return 'User $userId';
  }

  String? getParticipantProfileImage(String userId) {
    return participantMeta[userId]?['profileImage']?.toString();
  }

  bool getParticipantMuted(String userId) {
    return participantMeta[userId]?['isMuted'] == true;
  }

  String getParticipantStatus(String userId) {
    return participantStatus[userId] ?? '';
  }

  bool _isInCallStatus(String userId, String status) {
    final s = status.toLowerCase().trim();
    final isMatch = s.isEmpty ||
        s == 'accepted' ||
        s == 'accept' ||
        s == 'joined' ||
        s == 'connected' ||
        s == 'in_call' ||
        s == 'in-call' ||
        s == 'active' ||
        s == 'on_call';
    return isMatch;
  }

  // ---------------------------------------------------------------------------
  // Socket init
  // ---------------------------------------------------------------------------
  void init(String userId) {
    if (socket != null && socket!.connected && _selfUserId == userId) {
      _log('Already initialized and connected for $userId');
      return;
    }

    if (socket != null) {
      socket?.disconnect();
      socket?.dispose();
      socket = null;
    }

    _selfUserId = userId;
    _isDisposed = false;

    _log('Initializing socket for $userId at ${ConstRes.socketUrl}/groupCall');

    socket = io(
      "${ConstRes.socketUrl}/groupCall",
      OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .enableForceNew()
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .build(),
    );

    socket?.onConnect((_) {
      _log('Connected to /groupCall Namespace');
      _listenersBound = false;
      _bindSocketListeners();
    });

    socket?.onDisconnect((reason) {
      _log('Socket Disconnected: $reason');
      _listenersBound = false;
    });

    socket?.onAny((event, dynamic data) {
      // _log('GroupSocketAllEvent: $event | Data: $data');
    });
  }

  Future<bool> _ensureConnected({int timeoutSeconds = 10}) async {
    if (socket != null && socket!.connected) return true;

    if (_selfUserId == null || _selfUserId!.isEmpty) {
      final storedId = Global.storageServices.get(PrefConst.userId)?.toString();
      if (storedId != null && storedId.isNotEmpty) {
        _selfUserId = storedId;
      }
    }

    if (_selfUserId != null && _selfUserId!.isNotEmpty) {
      if (socket == null) {
        init(_selfUserId!);
      } else if (!socket!.connected) {
        socket!.connect();
      }
    }

    _log(' Waiting for Socket connection (App Cold Start)...');
    int waitedMs = 0;
    const intervalMs = 200;
    final maxWaitMs = timeoutSeconds * 1000;

    while (waitedMs < maxWaitMs) {
      if (socket != null && socket!.connected) {
        _log('Socket connected successfully after ${waitedMs}ms');
        return true;
      }
      await Future.delayed(const Duration(milliseconds: intervalMs));
      waitedMs += intervalMs;
    }

    _log('Socket connection timed out after $timeoutSeconds seconds');
    return socket != null && socket!.connected;
  }

  // ---------------------------------------------------------------------------
  // Socket listeners
  // ---------------------------------------------------------------------------
  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    final events = [
      "group_call_started",
      "group_call_participant_joined",
      "group_call_participant_left",
      "group_call_participant_rejected",
      "group_call_participant_mute",
      "group_call_camera_changed",
      "group_call_offer",
      "group_call_answer",
      "group_call_ice",
      "group_call_ended",
      "group_call_screen_share_started",
      "group_call_screen_share_stopped",
      "group_call_participants_update",
    ];
    for (final e in events) {
      socket?.off(e);
    }

    socket?.on("group_call_started", (raw) {});

    socket?.on("group_call_participant_joined", (raw) async {
      if (raw == null) return;
      final data = Map<String, dynamic>.from(raw);
      final joinedUserId = data['userId']?.toString();
      if (joinedUserId == null || joinedUserId == _selfUserId) return;

      final name = (data['name'] ?? data['userName'] ?? '').toString();
      final profileImage =
      (data['profileImage'] ?? data['userProfileImage'] ?? '').toString();

      _saveParticipantMeta(
        joinedUserId,
        name: name.isEmpty ? null : name,
        profileImage: profileImage,
        isMuted: data['isMuted'] == true,
      );

      participantStatus[joinedUserId] = 'accepted';
      if (data.containsKey('wantsVideo')) {
        wantsVideo[joinedUserId] = data['wantsVideo'] == true;
      }
      if (!joinOrder.contains(joinedUserId)) joinOrder.add(joinedUserId);

      final isNewUser = !remoteUsers.contains(joinedUserId);
      _addRemoteUser(joinedUserId);
      if (isNewUser) onParticipantJoined?.call(joinedUserId);

      await _connectToParticipant(joinedUserId);
      recomputeVideoSlots();
    });

    socket?.on("group_call_participant_rejected", (raw) {
      _log("group_call_participant_rejected: $raw");
      if (raw == null) return;

      final data = Map<String, dynamic>.from(raw);
      final userId = data['userId']?.toString();
      if (userId == null || userId.isEmpty) return;

      final userName = (data['userName'] ?? data['name'])?.toString();
      final userProfile =
      (data['userProfile'] ?? data['profileImage'])?.toString();

      _saveParticipantMeta(
        userId,
        name: userName,
        profileImage: userProfile,
      );

      onParticipantRejected?.call(userId, userName, userProfile);
    });

    socket?.on("group_call_participant_mute", (raw) {
      _log("group_call_participant_mute: $raw");
      if (raw == null) return;

      final data = Map<String, dynamic>.from(raw);
      final userId = data['userId']?.toString();
      if (userId == null) return;

      final isMuted = data['isMuted'] == true ||
          data['muted'] == true ||
          data['is_muted'] == true;

      _saveParticipantMeta(userId, isMuted: isMuted);
      onParticipantMuteChanged?.call(userId, isMuted);
      onParticipantsUpdated?.call();
    });

    socket?.on("group_call_camera_changed", (raw) {
      _log("group_call_camera_changed: $raw");

      if (raw is! Map) return;

      final data = Map<String, dynamic>.from(raw);
      final userId = data['userId']?.toString();

      if (userId == null || userId.isEmpty || userId == _selfUserId) return;

      final isVideoOn = data['isVideoOn'] == true;
      wantsVideo[userId] =
      data.containsKey('wantsVideo') ? data['wantsVideo'] == true : isVideoOn;
      remoteCameraStates[userId] = isVideoOn;

      recomputeVideoSlots();
      onParticipantCameraChanged?.call(userId, isVideoOn);
    });

    socket?.on("group_call_participant_left", (raw) async {
      final leftUserId = raw is Map ? raw['userId']?.toString() : null;
      if (leftUserId != null) {
        participantStatus[leftUserId] = 'left';
        _pendingOfferUserIds.remove(leftUserId);
        await _removeRemotePeer(leftUserId);
      }
    });

    socket?.on("group_call_ended", (raw) async {
      _log(" group_call_ended: $raw");
      if (Get.currentRoute == Routes.groupIncomingCallScreen) {
        CallStateTracker.isIncomingCallScreenOpen = false;
        Get.back();
      }
      onCallEnded?.call();
      await endCallLocalCleanup(navigate: true);
      CallSessionState.reset();
    });

    socket?.on("group_call_screen_share_started", (raw) {
      _log("group_call_screen_share_started: $raw");
      if (raw == null) return;
      final data = Map<String, dynamic>.from(raw);
      final userId = data['userId']?.toString();
      if (userId == null || userId == _selfUserId) return;
      onScreenShareStarted?.call(userId);
      onParticipantsUpdated?.call();
    });

    socket?.on("group_call_screen_share_stopped", (raw) {
      _log("group_call_screen_share_stopped: $raw");
      if (raw == null) return;
      final data = Map<String, dynamic>.from(raw);
      final userId = data['userId']?.toString();
      if (userId == null || userId == _selfUserId) return;
      onScreenShareStopped?.call(userId);
      onParticipantsUpdated?.call();
    });

    socket?.on("group_call_offer", (data) async {
      _log(" group_call_offer");
      try {
        await _handleOffer(Map<String, dynamic>.from(data));
      } catch (e) {
        _log("offer error: $e");
      }
    });

    socket?.on("group_call_answer", (data) async {
      _log(" group_call_answer");
      try {
        await _handleAnswer(Map<String, dynamic>.from(data));
      } catch (e) {
        _log("answer error: $e");
      }
    });

    socket?.on("group_call_ice", (data) async {
      _log(" group_call_ice");
      try {
        await _handleRemoteIce(Map<String, dynamic>.from(data));
      } catch (e) {
        _log("ice error: $e");
      }
    });

    socket?.on("group_call_participants_update", (raw) async {
      await _handleParticipantsUpdate(raw);
    });
  }

  // ---------------------------------------------------------------------------
  // Roster
  // ---------------------------------------------------------------------------
  Future<void> _handleParticipantsUpdate(dynamic raw) async {
    if (raw == null) return;

    try {
      final data = Map<String, dynamic>.from(raw);
      _log("group_call_participants_update: $data");

      final callId = data['callId']?.toString();
      final groupId = data['groupId']?.toString();

      if (currentCallId != null &&
          callId != null &&
          callId.isNotEmpty &&
          callId != currentCallId) {
        _log("Ignoring participants_update for other callId=$callId");
        return;
      }

      if (callId != null && callId.isNotEmpty) {
        currentCallId = callId;
      }
      if (groupId != null && groupId.isNotEmpty) {
        currentGroupId = groupId;
      }

      totalParticipants =
          int.tryParse(data['totalParticipants']?.toString() ?? '') ??
              totalParticipants;

      final list = (data['participants'] as List?) ?? [];
      final parsed = <Map<String, dynamic>>[];
      final acceptedIds = <String>{};
      final allIds = <String>{};

      for (final item in list) {
        if (item is! Map) continue;
        final p = Map<String, dynamic>.from(item);

        final uid = p['userId']?.toString();
        if (uid == null || uid.isEmpty) continue;

        final status = (p['status'] ?? 'accepted').toString().toLowerCase();
        final name = (p['name'] ?? p['userName'] ?? '').toString();
        final profileImage =
        (p['profileImage'] ?? p['userProfileImage'] ?? '').toString();
        final isMuted =
            p['isMuted'] == true || p['muted'] == true || p['is_muted'] == true;

        allIds.add(uid);
        participantStatus[uid] = status;

        if (uid != _selfUserId) {
          if (p.containsKey('wantsVideo')) {
            wantsVideo[uid] = p['wantsVideo'] == true;
          } else if (p['isVideoOn'] == true) {
            wantsVideo[uid] = true;
          }
          if (p.containsKey('isVideoOn')) {
            remoteCameraStates[uid] = p['isVideoOn'] == true;
          }
        }

        _saveParticipantMeta(
          uid,
          name: name.isEmpty ? null : name,
          profileImage: profileImage,
          isMuted: isMuted,
        );

        parsed.add({
          'userId': uid,
          'status': status,
          'name': name,
          'profileImage': profileImage,
          'isMuted': isMuted,
        });

        if (_isInCallStatus(uid, status)) {
          if (uid != _selfUserId) {
            acceptedIds.add(uid);
          }
        }
      }

      // Server roster order = join order (same on every device)
      joinOrder = parsed.map((e) => e['userId'] as String).toList();

      final staleStatus =
      participantStatus.keys.where((id) => !allIds.contains(id)).toList();
      for (final id in staleStatus) {
        participantStatus.remove(id);
      }

      final toRemove = remoteUsers
          .where((id) => !acceptedIds.contains(id))
          .toList(growable: false);

      for (final id in toRemove) {
        _log("Roster: removing peer $id (left or not accepted)");
        _pendingOfferUserIds.remove(id);
        await _removeRemotePeer(id);
      }

      for (final id in acceptedIds) {
        if (!remoteUsers.contains(id)) {
          _addRemoteUser(id);
          onParticipantJoined?.call(id);
        }
        if (!_peers.containsKey(id)) await _connectToParticipant(id);
      }

      recomputeVideoSlots();

      onParticipantsRosterUpdated?.call(parsed, totalParticipants);
      onParticipantsUpdated?.call();
    } catch (e, st) {
      _log("group_call_participants_update error: $e\n$st");
    }
  }

  bool _shouldCreateOfferTo(String remoteUserId) {
    final me = _selfUserId ?? '';
    if (me.isEmpty) return true;
    final a = int.tryParse(me);
    final b = int.tryParse(remoteUserId);
    if (a != null && b != null) return a < b;
    return me.compareTo(remoteUserId) < 0;
  }

  // ---------------------------------------------------------------------------
  // Connection management
  // ---------------------------------------------------------------------------
  Future<void> _connectToParticipant(String id) async {
    if (id == _selfUserId) return;
    _addRemoteUser(id);
    if (_peers.containsKey(id) || _pcFutures.containsKey(id)) return;
    if (localStream == null) {
      _pendingOfferUserIds.add(id);
      return;
    }
    if (!_shouldCreateOfferTo(id)) return; // they will offer us
    try {
      await _createOfferTo(id);
    } catch (e) {
      _log("connect $id error: $e");
    }
  }

  Future<void> onLocalStreamReady() async {
    _log("onLocalStreamReady localStream=${localStream != null}");
    if (localStream == null) return;

    for (final id in _peers.keys.toList()) {
      try {
        await _attachLocalTracks(id);
      } catch (e) {
        _log("attach $id: $e");
      }
    }

    final pending = _pendingOfferUserIds.toList();
    _pendingOfferUserIds.clear();
    for (final id in pending) {
      await _connectToParticipant(id);
    }

    recomputeVideoSlots();
    onParticipantsUpdated?.call();
  }

  /// Puts our mic/camera on the fixed senders. No renegotiation needed.
  Future<void> _attachLocalTracks(String id) async {
    final ls = localStream;
    if (ls == null) return;
    final audio = ls.getAudioTracks().firstOrNull;
    final video = activeVideoTrack ?? ls.getVideoTracks().firstOrNull;
    final as = _audioSenders[id];
    final vs = _videoSenders[id];
    if (as != null && audio != null) await as.replaceTrack(audio);
    if (vs != null && video != null) await vs.replaceTrack(video);
  }

  /// Answerer side: map transceivers created by the remote offer to senders.
  Future<void> _mapSenders(String id, RTCPeerConnection pc) async {
    final ts = await pc.getTransceivers();
    for (final t in ts) {
      final kind = t.receiver.track?.kind;
      if (kind == 'audio') _audioSenders[id] ??= t.sender;
      if (kind == 'video') _videoSenders[id] ??= t.sender;
      try {
        await t.setDirection(TransceiverDirection.SendRecv);
      } catch (_) {}
    }
  }

  Future<RTCPeerConnection> _getOrCreatePeer(String id,
      {required bool asOfferer}) {
    final existing = _peers[id];
    if (existing != null) return Future.value(existing);
    return _pcFutures.putIfAbsent(
      id,
          () => _buildPeer(id, asOfferer: asOfferer)
          .whenComplete(() => _pcFutures.remove(id)),
    );
  }

  Future<RTCPeerConnection> _buildPeer(String remoteId,
      {required bool asOfferer}) async {
    final pc = await createPeerConnection(_rtcConfig);
    _addRemoteUser(remoteId);

    if (!remoteRenderers.containsKey(remoteId)) {
      try {
        final r = RTCVideoRenderer();
        await r.initialize();
        remoteRenderers[remoteId] = r;
      } catch (e) {
        _log('renderer init failed $remoteId: $e');
      }
    }

    if (asOfferer) {
      final at = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
      );
      final vt = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
      );
      _audioSenders[remoteId] = at.sender;
      _videoSenders[remoteId] = vt.sender;
    }

    pc.onIceCandidate = (candidate) {
      if (candidate.candidate == null || currentCallId == null) return;
      socket?.emit("group_call_ice", {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "targetUserId": remoteId,
        "candidate": {
          "candidate": candidate.candidate,
          "sdpMid": candidate.sdpMid,
          "sdpMLineIndex": candidate.sdpMLineIndex,
        }
      });
    };

    pc.onTrack = (event) async {
      _log(
        "REMOTE TRACK $remoteId kind=${event.track.kind} "
            "streams=${event.streams.length} muted=${event.track.muted} "
            "enabled=${event.track.enabled}",
      );
      _addRemoteUser(remoteId);
      try {
        event.track.enabled = true;
      } catch (_) {}

      var renderer = remoteRenderers[remoteId];
      if (renderer == null) {
        renderer = RTCVideoRenderer();
        await renderer.initialize();
        remoteRenderers[remoteId] = renderer;
      }

      // One managed stream per remote user holding BOTH tracks.
      var stream = _remoteStreams[remoteId];
      stream ??= _remoteStreams[remoteId] =
      await createLocalMediaStream('remote_$remoteId');
      if (!stream.getTracks().any((t) => t.id == event.track.id)) {
        await stream.addTrack(event.track);
      }

      try {
        if (renderer.srcObject?.id != stream.id) {
          renderer.srcObject = stream;
        } else if (event.track.kind == 'video') {
          // Same stream, new video track: force texture rebind.
          renderer.srcObject = null;
          renderer.srcObject = stream;
        }
      } catch (e) {
        _log('onTrack attach error $remoteId: $e');
      }

      // NOTE: remoteCameraStates is NOT touched here. Receivers always exist,
      // camera state comes only from socket events.
      onParticipantsUpdated?.call();
    };

    pc.onConnectionState = (state) async {
      _log("PC $remoteId => ${state.name}");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        _addRemoteUser(remoteId);
        onParticipantsUpdated?.call();
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _log("PC failed $remoteId — ice restart");
        try {
          if (_shouldCreateOfferTo(remoteId) && currentCallId != null) {
            final offer = await pc.createOffer({'iceRestart': true});
            await pc.setLocalDescription(offer);
            socket?.emit("group_call_offer", {
              "callId": int.tryParse(currentCallId!) ?? currentCallId,
              "targetUserId": remoteId,
              "description": {"type": offer.type, "sdp": offer.sdp},
            });
          }
        } catch (e) {
          _log("ice restart failed $remoteId: $e");
          await _removeRemotePeer(remoteId);
        }
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        await _removeRemotePeer(remoteId);
      }
    };

    _peers[remoteId] = pc;
    if (asOfferer) await _attachLocalTracks(remoteId);
    return pc;
  }

  Future<void> _createOfferTo(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    if (remoteId == _selfUserId || currentCallId == null) return;

    _log("Creating offer -> $remoteId");
    final pc = await _getOrCreatePeer(remoteId, asOfferer: true);
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    socket?.emit("group_call_offer", {
      "callId": int.tryParse(currentCallId!) ?? currentCallId,
      "targetUserId": remoteId,
      "description": {"type": offer.type, "sdp": offer.sdp},
    });
  }

  Future<void> _resetPeer(String id) async {
    final pc = _peers.remove(id);
    _audioSenders.remove(id);
    _videoSenders.remove(id);
    _remoteStreams.remove(id);
    _pendingIce.remove(id);
    remoteRenderers[id]?.srcObject = null;
    try {
      await pc?.close();
    } catch (_) {}
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    final remoteId = data['fromUserId'].toString();
    final description = data['description'];
    if (description == null) return;

    var pc = _peers[remoteId];
    if (pc != null &&
        pc.signalingState ==
            RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      final polite = !_shouldCreateOfferTo(remoteId);
      if (!polite) {
        _log("glare: ignore offer from $remoteId (we are impolite)");
        return; // keep our offer
      }
      _log("glare: reset local offer, accept $remoteId");
      await _resetPeer(remoteId); // polite: drop ours, answer theirs
      pc = null;
    }
    pc ??= await _getOrCreatePeer(remoteId, asOfferer: false);

    await pc.setRemoteDescription(
      RTCSessionDescription(description['sdp'], description['type']),
    );
    await _mapSenders(remoteId, pc);
    await _flushPendingIce(remoteId);
    await _attachLocalTracks(remoteId);

    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    socket?.emit("group_call_answer", {
      "callId": data['callId'],
      "targetUserId": remoteId,
      "description": {"type": answer.type, "sdp": answer.sdp},
    });
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    final remoteUserId = data['fromUserId'].toString();
    final pc = _peers[remoteUserId];
    if (pc == null) return;

    final description = data['description'];
    await pc.setRemoteDescription(
      RTCSessionDescription(description['sdp'], description['type']),
    );
    await _flushPendingIce(remoteUserId);
  }

  Future<void> replaceVideoTrack(MediaStreamTrack newTrack) async {
    activeVideoTrack = newTrack;
    _log('replaceVideoTrack kind=${newTrack.kind}');
    for (final e in _videoSenders.entries) {
      try {
        await e.value.replaceTrack(newTrack);
      } catch (err) {
        _log('replaceVideoTrack ${e.key}: $err');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Emitters
  // ---------------------------------------------------------------------------
  Future<void> startGroupCall({
    required String groupId,
    required bool isVideo,
    required String callerName,
    required String callerProfileImage,
    required Function(bool success, String? callId, String? message) onResponse,
  }) async {
    _log('emit start_group_call group=$groupId');
    currentGroupId = groupId;
    callIsVideo = isVideo;

    bool connected = await _ensureConnected(timeoutSeconds: 8);
    if (!connected) {
      onResponse(false, null, "Socket connection timeout");
      return;
    }

    if (_selfUserId != null) {
      _saveParticipantMeta(
        _selfUserId!,
        name: callerName,
        profileImage: callerProfileImage,
        isMuted: false,
      );
    }

    socket?.emitWithAck(
      "start_group_call",
      {
        "groupId": int.tryParse(groupId) ?? groupId,
        "isVideo": isVideo,
        "callerName": callerName,
        "callerProfileImage": callerProfileImage,
        "name": callerName,
        "profileImage": callerProfileImage,
      },
      ack: (response) {
        _log('start_group_call ACK: $response');
        if (response is Map && response['success'] == true) {
          currentCallId = response['callId']?.toString();
          onResponse(true, currentCallId, null);
        } else if (response is Map) {
          onResponse(false, null, response['message']?.toString());
        } else {
          onResponse(false, null, "Malformed response");
        }
      },
    );
  }

  Future<void> joinGroupCall(
      String callId,
      String groupId,
      Function(bool success) onComplete,
      ) async {
    _log('emit join_group_call callId=$callId, groupId=$groupId');
    currentCallId = callId;
    currentGroupId = groupId;

    bool connected = await _ensureConnected(timeoutSeconds: 8);
    if (!connected) {
      _log('Socket connection timed out during joinGroupCall');
      Utils().fluttertoast(
          "Unable to connect to call server. Please check your network.");
      onComplete(false);
      return;
    }

    var data = {
      "callId": int.tryParse(callId) ?? callId,
      "groupId": int.tryParse(groupId) ?? groupId,
    };

    socket?.emitWithAck(
      "join_group_call",
      data,
      ack: (response) async {
        _log('join_group_call ACK: $response');
        if (response is! Map || response['success'] != true) {
          onComplete(false);
          return;
        }

        currentCallId = response['callId']?.toString() ?? callId;

        final participants = (response['existingParticipants'] as List?) ?? [];
        for (final p in participants) {
          if (p is! Map) continue;
          final uid = p['userId']?.toString();
          if (uid == null || uid == _selfUserId) continue;

          _saveParticipantMeta(
            uid,
            name: (p['name'] ?? p['userName'])?.toString(),
            profileImage:
            (p['profileImage'] ?? p['userProfileImage'])?.toString(),
            isMuted: p['isMuted'] == true,
          );

          if (p.containsKey('wantsVideo')) {
            wantsVideo[uid] = p['wantsVideo'] == true;
          } else if (p['isVideoOn'] == true) {
            wantsVideo[uid] = true;
          }
          if (p.containsKey('isVideoOn')) {
            remoteCameraStates[uid] = p['isVideoOn'] == true;
          }
          if (!joinOrder.contains(uid)) joinOrder.add(uid);

          final st = (p['status'] ?? 'accepted').toString();
          participantStatus[uid] = st;

          if (_isInCallStatus(uid, st)) {
            final isNew = !remoteUsers.contains(uid);
            _addRemoteUser(uid);
            if (isNew) onParticipantJoined?.call(uid);
            await _connectToParticipant(uid);
          }
        }

        recomputeVideoSlots();
        onParticipantsUpdated?.call();
        onComplete(true);
      },
    );
  }

  void rejectGroupCall(String callId, String groupId) {
    _log('emit reject_group_call');
    socket?.emitWithAck(
      "reject_group_call",
      {
        "callId": int.tryParse(callId) ?? callId,
        "groupId": int.tryParse(groupId) ?? groupId,
      },
      ack: (r) => _log('reject_group_call ACK: $r'),
    );
  }

  void emitMute({required bool isMuted}) {
    if (currentCallId == null || currentGroupId == null) {
      _log(' emitMute skipped: no active call');
      return;
    }

    _log(' emit group_call_mute isMuted=$isMuted');

    if (_selfUserId != null) {
      _saveParticipantMeta(_selfUserId!, isMuted: isMuted);
    }

    socket?.emitWithAck(
      "group_call_mute",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
        "isMuted": isMuted,
      },
      ack: (r) => _log('group_call_mute ACK: $r'),
    );
  }

  void emitCameraChange({required bool isVideoOn, bool? wantsVideo}) {
    if (currentCallId == null || currentGroupId == null) {
      _log('emitCameraChange skipped: no active call');
      return;
    }

    _log('emit group_call_camera_change isVideoOn=$isVideoOn wants=$wantsVideo');

    socket?.emitWithAck(
      "group_call_camera_change",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
        "isVideoOn": isVideoOn,
        "wantsVideo": wantsVideo ?? isVideoOn,
      },
      ack: (r) => _log('group_call_camera_change ACK: $r'),
    );
  }

  void emitStartScreenShare() {
    if (currentCallId == null || currentGroupId == null) {
      _log('emitStartScreenShare skipped: no active call');
      return;
    }

    _log('emit start_group_screen_share');
    socket?.emitWithAck(
      "start_group_screen_share",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (r) => _log('start_group_screen_share ACK: $r'),
    );
  }

  void emitStopScreenShare() {
    if (currentCallId == null || currentGroupId == null) {
      _log('emitStopScreenShare skipped: no active call');
      return;
    }

    _log('emit stop_group_screen_share');
    socket?.emitWithAck(
      "stop_group_screen_share",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (r) => _log('stop_group_screen_share ACK: $r'),
    );
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------
  /// Full media teardown. Safe to call multiple times.
  Future<void> cleanupCallMedia() async {
    await endCallLocalCleanup(navigate: false);
  }

  Future<void> _stopAndDisposeStream(MediaStream? stream) async {
    if (stream == null) return;
    try {
      final tracks = stream.getTracks();
      for (final t in tracks) {
        try {
          t.enabled = false;
        } catch (_) {}
        try {
          await t.stop();
        } catch (_) {
          try {
            t.stop();
          } catch (_) {}
        }
      }
      try {
        await stream.dispose();
      } catch (_) {}
    } catch (e) {
      _log('_stopAndDisposeStream error: $e');
    }
  }

  Future<void> endCallLocalCleanup({bool navigate = true}) async {
    _log('endCallLocalCleanup start');

    // 1) Stop creating new offers / ignore late roster
    _pendingOfferUserIds.clear();
    _pendingIce.clear();

    // 2) Close peer connections FIRST (drop senders holding camera track)
    final pcs = Map<String, RTCPeerConnection>.from(_peers);
    _peers.clear();
    for (final entry in pcs.entries) {
      try {
        try {
          final senders = await entry.value.getSenders();
          for (final s in senders) {
            try {
              await entry.value.removeTrack(s);
            } catch (_) {}
          }
        } catch (_) {}
        await entry.value.close();
        try {
          await entry.value.dispose();
        } catch (_) {}
      } catch (e) {
        _log('PC close error ${entry.key}: $e');
      }
    }

    // 3) Dispose remote renderers
    final renderers = Map<String, RTCVideoRenderer>.from(remoteRenderers);
    remoteRenderers.clear();
    for (final r in renderers.values) {
      try {
        r.srcObject = null;
      } catch (_) {}
      try {
        await r.dispose();
      } catch (_) {}
    }

    remoteUsers.clear();
    _audioSenders.clear();
    _videoSenders.clear();
    _remoteStreams.clear();
    _pcFutures.clear();
    wantsVideo.clear();
    joinOrder = [];
    videoSlotHolders = {};
    _lastEmittedEffective = null;
    _lastEmittedWants = null;

    remoteCameraStates.clear();
    participantStatus.clear();
    participantMeta.clear();
    totalParticipants = 0;

    final ls = localStream;
    localStream = null;
    activeVideoTrack = null;
    await _stopAndDisposeStream(ls);

    currentCallId = null;
    currentGroupId = null;

    _log('endCallLocalCleanup done (localStream stopped)');

    if (navigate && Get.currentRoute == Routes.groupCallingScreen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  void leaveGroupCall() {
    // Save IDs before cleanup destroys them
    final id = currentCallId;
    final gid = currentGroupId;

    _log('emit leave_group_call');

    if (id != null && gid != null) {
      socket?.emitWithAck(
        "leave_group_call",
        {
          "callId": int.tryParse(id) ?? id,
          "groupId": int.tryParse(gid) ?? gid,
        },
        ack: (r) => _log('leave_group_call ACK: $r'),
      );
    }

    unawaited(endCallLocalCleanup(navigate: false));
  }

  void endGroupCall() {
    final id = currentCallId;
    final gid = currentGroupId;

    _log('emit end_group_call');

    if (id != null && gid != null) {
      socket?.emitWithAck(
        "end_group_call",
        {
          "callId": int.tryParse(id) ?? id,
          "groupId": int.tryParse(gid) ?? gid,
        },
        ack: (r) => _log('end_group_call ACK: $r'),
      );
    }

    unawaited(endCallLocalCleanup(navigate: false));
  }

  // ---------------------------------------------------------------------------
  // ICE
  // ---------------------------------------------------------------------------
  Future<void> _handleRemoteIce(Map<String, dynamic> data) async {
    final remoteUserId = data['fromUserId'].toString();
    final c = data['candidate'];

    final candidate = RTCIceCandidate(
      c['candidate'],
      c['sdpMid']?.toString(),
      c['sdpMLineIndex'] is int
          ? c['sdpMLineIndex']
          : int.tryParse(c['sdpMLineIndex']?.toString() ?? ''),
    );

    final pc = _peers[remoteUserId];
    final remoteDesc = pc != null ? await pc.getRemoteDescription() : null;

    if (pc == null || remoteDesc == null) {
      _pendingIce.putIfAbsent(remoteUserId, () => []).add(candidate);
      return;
    }

    await pc.addCandidate(candidate);
  }

  Future<void> _flushPendingIce(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    final pc = _peers[remoteId];
    final remoteDesc = pc != null ? await pc.getRemoteDescription() : null;
    if (pc == null || remoteDesc == null) return;

    final pending = _pendingIce.remove(remoteId) ?? [];
    for (final ice in pending) {
      try {
        await pc.addCandidate(ice);
      } catch (_) {}
    }
  }

  void _addRemoteUser(String remoteUserId) {
    if (remoteUserId == _selfUserId) return;
    remoteUsers.add(remoteUserId);
  }

  Future<void> _removeRemotePeer(String remoteUserId) async {
    final remoteId = remoteUserId.toString();

    final pc = _peers.remove(remoteId);
    final hadState = pc != null ||
        remoteUsers.contains(remoteId) ||
        remoteRenderers.containsKey(remoteId);

    if (pc != null) {
      try {
        await pc.close();
      } catch (_) {}
    }

    _pendingIce.remove(remoteId);
    remoteCameraStates.remove(remoteId);
    final renderer = remoteRenderers.remove(remoteId);
    if (renderer != null) {
      renderer.srcObject = null;
      try {
        await renderer.dispose();
      } catch (_) {}
    }

    remoteUsers.remove(remoteId);
    _audioSenders.remove(remoteId);
    _videoSenders.remove(remoteId);
    _remoteStreams.remove(remoteId);
    _pcFutures.remove(remoteId);
    wantsVideo.remove(remoteId);
    participantStatus[remoteId] = 'left';

    // Frees the slot -> next waiting user is promoted
    if (currentCallId != null) recomputeVideoSlots();

    if (!hadState) return;
    onParticipantLeft?.call(remoteId);
    onParticipantsUpdated?.call();
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await endCallLocalCleanup(navigate: false);
    socket?.clearListeners();
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    _listenersBound = false;
  }
}