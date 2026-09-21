import 'dart:async';
import 'dart:developer';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
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

  /// Current outgoing video track (camera OR screen)
  MediaStreamTrack? activeVideoTrack;

  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  final Map<String, List<RTCIceCandidate>> _pendingIce = {};
  final Set<String> remoteUsers = {};

  final Map<String, Map<String, dynamic>> participantMeta = {};

  Function()? onParticipantsUpdated;
  Function()? onCallEnded;
  Function(String userId)? onParticipantJoined;
  Function(String userId)? onParticipantLeft;
  Function(String userId)? onParticipantRejected;
  Function(String userId, bool isMuted)? onParticipantMuteChanged;
  Function(Map<String, dynamic> data)? onIncomingCallReceived;

  // Screen share callbacks
  Function(String userId)? onScreenShareStarted;
  Function(String userId)? onScreenShareStopped;

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
      _log('🟢 Connected to /groupCall Namespace');
      _listenersBound = false;
      _bindSocketListeners();
    });

    socket?.onDisconnect((reason) {
      _log('🔴 Socket Disconnected: $reason');
      _listenersBound = false;
    });

    socket?.onAny((event, dynamic data) {
      _log('GroupSocketAllEvent: $event | Data: $data');
    });
  }

  /// Waits for socket connection dynamically if launched from Terminated state
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

    _log('⏳ Waiting for Socket connection (App Cold Start)...');
    int waitedMs = 0;
    const intervalMs = 200;
    final maxWaitMs = timeoutSeconds * 1000;

    while (waitedMs < maxWaitMs) {
      if (socket != null && socket!.connected) {
        _log('🟢 Socket connected successfully after ${waitedMs}ms');
        return true;
      }
      await Future.delayed(const Duration(milliseconds: intervalMs));
      waitedMs += intervalMs;
    }

    _log('❌ Socket connection timed out after $timeoutSeconds seconds');
    return socket != null && socket!.connected;
  }

  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    final events = [
      "group_call_started",
      "group_call_participant_joined",
      "group_call_participant_left",
      "group_call_participant_rejected",
      "group_call_participant_mute",
      "group_call_offer",
      "group_call_answer",
      "group_call_ice",
      "group_call_ended",
      // screen share
      "group_call_screen_share_started",
      "group_call_screen_share_stopped",
    ];
    for (final e in events) {
      socket?.off(e);
    }

    socket?.on("group_call_started", (raw) {
      // kept commented as in your current file
    });

    socket?.on("group_call_participant_joined", (raw) {
      _log("group_call_participant_joined: $raw");
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

      onParticipantJoined?.call(joinedUserId);
      onParticipantsUpdated?.call();
    });

    socket?.on("group_call_participant_rejected", (raw) {
      _log(" group_call_participant_rejected: $raw");
      final userId = raw is Map ? raw['userId']?.toString() : null;
      if (userId != null) onParticipantRejected?.call(userId);
    });

    socket?.on("group_call_participant_mute", (raw) {
      _log("🔇 group_call_participant_mute: $raw");
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

    socket?.on("group_call_participant_left", (raw) async {
      _log(" group_call_participant_left: $raw");
      final leftUserId = raw is Map ? raw['userId']?.toString() : null;
      if (leftUserId != null) {
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

    // ===================== SCREEN SHARE LISTEN =====================
    socket?.on("group_call_screen_share_started", (raw) {
      _log("🖥️ group_call_screen_share_started: $raw");
      if (raw == null) return;
      final data = Map<String, dynamic>.from(raw);
      final userId = data['userId']?.toString();
      if (userId == null || userId == _selfUserId) return;
      onScreenShareStarted?.call(userId);
      onParticipantsUpdated?.call();
    });

    socket?.on("group_call_screen_share_stopped", (raw) {
      _log("🖥️ group_call_screen_share_stopped: $raw");
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
      _log("❄ group_call_ice");
      try {
        await _handleRemoteIce(Map<String, dynamic>.from(data));
      } catch (e) {
        _log("ice error: $e");
      }
    });
  }

  Future<void> startGroupCall({
    required String groupId,
    required bool isVideo,
    required String callerName,
    required String callerProfileImage,
    required Function(bool success, String? callId, String? message) onResponse,
  }) async {
    _log('emit start_group_call group=$groupId');
    currentGroupId = groupId;

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
        }

        int retries = 0;
        while (localStream == null && retries < 15) {
          await Future.delayed(const Duration(milliseconds: 200));
          retries++;
        }

        if (localStream != null) {
          for (final p in participants) {
            if (p is! Map) continue;
            final remoteUserId = p['userId']?.toString();
            if (remoteUserId == null || remoteUserId == _selfUserId) continue;
            await _createOfferTo(remoteUserId);
          }
        }

        onParticipantsUpdated?.call();
        onComplete(true);
      },
    );
  }

  void rejectGroupCall(String callId, String groupId) {
    _log('🚀 emit reject_group_call');
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

  // ============================================================
  // SCREEN SHARE EMIT
  // ============================================================

  /// Emit: start_group_screen_share
  /// Params: callId, groupId
  void emitStartScreenShare() {
    if (currentCallId == null || currentGroupId == null) {
      _log('emitStartScreenShare skipped: no active call');
      return;
    }

    _log('🖥️ emit start_group_screen_share');
    socket?.emitWithAck(
      "start_group_screen_share",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (r) => _log('start_group_screen_share ACK: $r'),
    );
  }

  /// Emit: stop_group_screen_share
  /// Params: callId, groupId
  void emitStopScreenShare() {
    if (currentCallId == null || currentGroupId == null) {
      _log('emitStopScreenShare skipped: no active call');
      return;
    }

    _log('🖥️ emit stop_group_screen_share');
    socket?.emitWithAck(
      "stop_group_screen_share",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (r) => _log('stop_group_screen_share ACK: $r'),
    );
  }

  /// Replace camera track with screen track (or back to camera)
  /// without renegotiation restart.
  Future<void> replaceVideoTrack(MediaStreamTrack newTrack) async {
    activeVideoTrack = newTrack;
    _log('🔄 replaceVideoTrack kind=${newTrack.kind}');

    for (final entry in _peers.entries) {
      final pc = entry.value;
      try {
        final senders = await pc.getSenders();
        final videoSender =
        senders.firstWhereOrNull((s) => s.track?.kind == 'video');

        if (videoSender != null) {
          await videoSender.replaceTrack(newTrack);
          _log('✅ track replaced for peer ${entry.key}');
        } else if (localStream != null) {
          // if no video sender exists yet, add it
          await pc.addTrack(newTrack, localStream!);
          _log('➕ video track added for peer ${entry.key}');
        }
      } catch (e) {
        _log('❌ replaceVideoTrack error for ${entry.key}: $e');
      }
    }
  }

  void leaveGroupCall() {
    if (currentCallId == null || currentGroupId == null) return;
    _log('🚀 emit leave_group_call');
    socket?.emitWithAck(
      "leave_group_call",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (r) => _log('leave_group_call ACK: $r'),
    );
    endCallLocalCleanup(navigate: false);
  }

  void endGroupCall() {
    if (currentCallId == null || currentGroupId == null) return;
    _log('🚀 emit end_group_call');
    socket?.emitWithAck(
      "end_group_call",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (r) => _log('end_group_call ACK: $r'),
    );
    endCallLocalCleanup(navigate: false);
  }

  // ============================================================
  // WebRTC
  // ============================================================
  Future<RTCPeerConnection> _createPeerConnection(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    if (_peers.containsKey(remoteId)) return _peers[remoteId]!;

    final pc = await createPeerConnection(_rtcConfig);

    if (localStream != null) {
      // audio always from localStream
      for (final track in localStream!.getAudioTracks()) {
        await pc.addTrack(track, localStream!);
      }

      // video: prefer activeVideoTrack (screen/camera), fallback to local video
      final videoTrack =
          activeVideoTrack ?? localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        await pc.addTrack(videoTrack, localStream!);
      }
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
      _log("REMOTE TRACK $remoteId streams=${event.streams.length}");
      if (event.streams.isEmpty) return;

      _addRemoteUser(remoteId);

      if (!remoteRenderers.containsKey(remoteId)) {
        final renderer = RTCVideoRenderer();
        await renderer.initialize();
        remoteRenderers[remoteId] = renderer;
      }

      remoteRenderers[remoteId]!.srcObject = event.streams.first;
      onParticipantsUpdated?.call();
    };

    pc.onConnectionState = (state) {
      _log("PC $remoteId => ${state.name}");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _removeRemotePeer(remoteId);
      }
    };

    _peers[remoteId] = pc;
    _addRemoteUser(remoteId);
    return pc;
  }

  Future<void> _createOfferTo(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    if (remoteId == _selfUserId) return;

    _log("Creating offer -> $remoteId");
    final pc = await _createPeerConnection(remoteId);
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    if (currentCallId == null) return;

    socket?.emit("group_call_offer", {
      "callId": int.tryParse(currentCallId!) ?? currentCallId,
      "targetUserId": remoteId,
      "description": {
        "type": offer.type,
        "sdp": offer.sdp,
      }
    });
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    final remoteUserId = data['fromUserId'].toString();
    final pc = await _createPeerConnection(remoteUserId);
    final description = data['description'];

    await pc.setRemoteDescription(
      RTCSessionDescription(description['sdp'], description['type']),
    );
    await _flushPendingIce(remoteUserId);

    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    socket?.emit("group_call_answer", {
      "callId": data['callId'],
      "targetUserId": remoteUserId,
      "description": {
        "type": answer.type,
        "sdp": answer.sdp,
      }
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
    if (pc != null) await pc.close();

    _pendingIce.remove(remoteId);

    final renderer = remoteRenderers.remove(remoteId);
    if (renderer != null) {
      renderer.srcObject = null;
      await renderer.dispose();
    }

    remoteUsers.remove(remoteId);

    onParticipantLeft?.call(remoteId);
    onParticipantsUpdated?.call();
  }

  Future<void> endCallLocalCleanup({bool navigate = true}) async {
    for (final pc in _peers.values) {
      await pc.close();
    }
    _peers.clear();
    _pendingIce.clear();

    for (final renderer in remoteRenderers.values) {
      renderer.srcObject = null;
      await renderer.dispose();
    }
    remoteRenderers.clear();
    remoteUsers.clear();
    participantMeta.clear();

    try {
      localStream?.getTracks().forEach((t) => t.stop());
      await localStream?.dispose();
    } catch (_) {}
    localStream = null;
    activeVideoTrack = null;

    currentCallId = null;
    currentGroupId = null;

    if (navigate && Get.currentRoute == Routes.groupCallingScreen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
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