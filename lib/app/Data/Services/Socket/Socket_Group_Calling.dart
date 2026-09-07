import 'dart:async';
import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:get/get.dart';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class Socket_GroupCallService {
  Socket_GroupCallService._();
  static final instance = Socket_GroupCallService._();

  Socket? socket;
  String? _selfUserId;
  String? currentCallId;
  String? currentGroupId;

  MediaStream? localStream;
  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  final Map<String, List<RTCIceCandidate>> _pendingIce = {};
  final Set<String> remoteUsers = {};

  // UI callbacks
  Function()? onParticipantsUpdated;
  Function()? onCallEnded;
  Function(String userId)? onParticipantJoined;
  Function(String userId)? onParticipantLeft;
  Function(String userId)? onParticipantRejected;
  Function(Map<String, dynamic> data)? onIncomingCallReceived;

  bool _listenersBound = false;
  bool _isDisposed = false;

  String? get selfUserId => _selfUserId;

  static const Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {'urls': ['stun:stun.l.google.com:19302']},
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
  };

  void _log(String message) {
    log('[GroupCallService] $message');
  }

  // ============================================================
  // EVENT 1: connection
  // ============================================================
  void init(String userId) {
    if (socket != null && socket!.connected && _selfUserId == userId) {
      _log('Already initialized for $userId');
      return;
    }

    if (socket != null) {
      socket?.disconnect();
      socket?.dispose();
      socket = null;
    }

    _selfUserId = userId;
    _isDisposed = false;

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

    // EVENT 15: disconnect
    socket?.onDisconnect((_) {
      _log('🔴 Socket Disconnected');
      _listenersBound = false;
    });

    socket?.onAny((event, dynamic data) {
      _log('📡 Event: $event'); // Kept short to avoid console spam, expand if needed
    });
  }

  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    final events = [
      "group_call_started",
      "group_call_participant_joined",
      "group_call_participant_left",
      "group_call_participant_rejected",
      "group_call_offer",
      "group_call_answer",
      "group_call_ice",
      "group_call_ended",
    ];
    for (final e in events) {
      socket?.off(e);
    }

    // EVENT 3: group_call_started
    socket?.on("group_call_started", (data) {
      _log("📞 onCallStarted received:${data}");
      if (data == null) return;

      final callerId = data['callerId']?.toString();
      if (callerId == _selfUserId) {
        _log("Self-triggered call event, ignoring.");
        return;
      }

      currentCallId = data['callId']?.toString();
      currentGroupId = data['groupId']?.toString();

      final currentRoute = Get.currentRoute;
      if (currentRoute == Routes.groupCallingScreen ||
          currentRoute == Routes.groupIncomingCallScreen) {
        _log("⚠️ Already in a call screen, ignoring popup.");
        return;
      }

      _log("🚀 Navigating to Incoming Call Screen");
      Get.toNamed(
        Routes.groupIncomingCallScreen,
        arguments: {
          "callId": data['callId']?.toString(),
          "groupId": data['groupId']?.toString() ?? "",
          "groupName": data['groupName']?.toString() ?? "Group Call",
          "callerName": data['callerName']?.toString() ?? "Someone",
          "groupProfile": data['groupProfile']?.toString() ?? data['callerProfileImage']?.toString() ?? "",
          "activeMemberCount": 1,
          "totalMemberCount": data['totalMembers'] ?? 0,
          "isVideo": data['isVideo'] == true,
        },
      );

      onIncomingCallReceived?.call(Map<String, dynamic>.from(data));
    });

    // EVENT 5: group_call_participant_joined
    socket?.on("group_call_participant_joined", (data) {
      _log("👤 onParticipantJoined: $data");
      final joinedUserId = data['userId']?.toString();
      if (joinedUserId != null && joinedUserId != _selfUserId) {
        onParticipantJoined?.call(joinedUserId);
      }
    });

    // EVENT 7: group_call_participant_rejected
    socket?.on("group_call_participant_rejected", (data) {
      _log("🚫 onParticipantRejected: $data");
      final rejectedUserId = data['userId']?.toString();
      if (rejectedUserId != null) {
        onParticipantRejected?.call(rejectedUserId);
      }
    });

    // EVENT 12: group_call_participant_left
    socket?.on("group_call_participant_left", (data) async {
      _log("👋 onParticipantLeft: $data");
      final leftUserId = data['userId']?.toString();
      if (leftUserId != null) {
        await _removeRemotePeer(leftUserId);
      }
    });

    // EVENT 14: group_call_ended
    socket?.on("group_call_ended", (data) async {
      _log("📵 onCallEnded: $data");
      if (Get.currentRoute == Routes.groupIncomingCallScreen) {
        Get.back();
      }
      onCallEnded?.call();
      await endCallLocalCleanup(navigate: true);
    });

    // EVENT 8 (Listen): group_call_offer
    socket?.on("group_call_offer", (data) async {
      _log("📥 onOffer received");
      try {
        await _handleOffer(Map<String, dynamic>.from(data));
      } catch (error) {
        _log("Handle offer error: $error");
      }
    });

    // EVENT 9 (Listen): group_call_answer
    socket?.on("group_call_answer", (data) async {
      _log("📥 onAnswer received");
      try {
        await _handleAnswer(Map<String, dynamic>.from(data));
      } catch (error) {
        _log("Handle answer error: $error");
      }
    });

    // EVENT 10 (Listen): group_call_ice
    socket?.on("group_call_ice", (data) async {
      _log("❄️ onIce received");
      try {
        await _handleRemoteIce(Map<String, dynamic>.from(data));
      } catch (error) {
        _log("Handle ICE error: $error");
      }
    });
  }

  // ============================================================
  // EVENT 2: start_group_call
  // ============================================================
  Future<void> startGroupCall({
    required String groupId,
    required bool isVideo,
    required String callerName,
    required String callerProfileImage,
    required Function(bool success, String? callId, String? message) onResponse,
  }) async {
    _log('🚀 starting group call: group=$groupId');
    currentGroupId = groupId;

    if (socket == null || !socket!.connected) {
      onResponse(false, null, "Socket disconnected");
      return;
    }

    socket?.emitWithAck(
      "start_group_call",
      {
        "groupId": int.tryParse(groupId) ?? groupId,
        "isVideo": isVideo,
        "callerName": callerName,
        "callerProfileImage": callerProfileImage,
      },
      ack: (response) {
        _log('start_group_call Response: $response');
        if (response is Map) {
          if (response['success'] == true) {
            currentCallId = response['callId']?.toString();
            onResponse(true, currentCallId, null);
          } else {
            onResponse(false, null, response['message']?.toString());
          }
        } else {
          onResponse(false, null, "Malformed response");
        }
      },
    );
  }

  // ============================================================
  // EVENT 4: join_group_call
  // ============================================================
  Future<void> joinGroupCall(String callId, String groupId, Function(bool success) onComplete) async {
    _log('🚀 Joining group call: $callId');
    currentCallId = callId;
    currentGroupId = groupId;

    if (socket == null || !socket!.connected) {
      onComplete(false);
      return;
    }

    socket?.emitWithAck(
      "join_group_call",
      {
        "callId": int.tryParse(callId) ?? callId,
        "groupId": int.tryParse(groupId) ?? groupId,
      },
      ack: (response) async {
        _log('join_group_call Response: $response');
        if (response is Map && response['success'] == true) {
          currentCallId = response['callId']?.toString();

          int retries = 0;
          while (localStream == null && retries < 15) {
            await Future.delayed(const Duration(milliseconds: 200));
            retries++;
          }

          if (localStream != null) {
            final participants = (response['existingParticipants'] as List?) ?? [];
            for (final p in participants) {
              final remoteUserId = p['userId']?.toString();
              if (remoteUserId == null || remoteUserId == _selfUserId) continue;
              await _createOfferTo(remoteUserId);
            }
          }
          onComplete(true);
        } else {
          onComplete(false);
        }
      },
    );
  }

  // ============================================================
  // EVENT 6: reject_group_call
  // ============================================================
  void rejectGroupCall(String callId, String groupId) {
    _log('🚀 Emitting reject_group_call');
    socket?.emitWithAck(
      "reject_group_call",
      {
        "callId": int.tryParse(callId) ?? callId,
        "groupId": int.tryParse(groupId) ?? groupId,
      },
      ack: (response) => _log('reject_group_call Response: $response'),
    );
  }

  // ============================================================
  // EVENT 11: leave_group_call
  // ============================================================
  void leaveGroupCall() {
    if (currentCallId == null || currentGroupId == null) return;
    _log('🚀 Emitting leave_group_call');
    socket?.emitWithAck(
      "leave_group_call",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (response) => _log('leave_group_call Response: $response'),
    );
    endCallLocalCleanup(navigate: false);
  }

  // ============================================================
  // EVENT 13: end_group_call
  // ============================================================
  void endGroupCall() {
    if (currentCallId == null || currentGroupId == null) return;
    _log('🚀 Emitting end_group_call');
    socket?.emitWithAck(
      "end_group_call",
      {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
      },
      ack: (response) => _log('end_group_call Response: $response'),
    );
    endCallLocalCleanup(navigate: false);
  }

  // ============================================================
  // WEBRTC PEER CONNECTION HANDSHAKES
  // ============================================================

  Future<RTCPeerConnection> _createPeerConnection(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    if (_peers.containsKey(remoteId)) {
      return _peers[remoteId]!;
    }

    final pc = await createPeerConnection(_rtcConfig);

    if (localStream != null) {
      for (final track in localStream!.getTracks()) {
        await pc.addTrack(track, localStream!);
      }
    }

    // EVENT 10 (Emit): group_call_ice
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
      _log("REMOTE TRACK from peer $remoteId: streams count = ${event.streams.length}");
      if (event.streams.isEmpty) return;
      final remoteStream = event.streams.first;

      _addRemoteUser(remoteId);

      if (!remoteRenderers.containsKey(remoteId)) {
        final renderer = RTCVideoRenderer();
        await renderer.initialize();
        remoteRenderers[remoteId] = renderer;
      }

      remoteRenderers[remoteId]!.srcObject = remoteStream;
      onParticipantsUpdated?.call();
    };

    pc.onConnectionState = (state) {
      _log("PC State change for $remoteId => ${state.name}");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _removeRemotePeer(remoteId);
      }
    };

    _peers[remoteId] = pc;
    _addRemoteUser(remoteId);
    return pc;
  }

  // EVENT 8 (Emit): group_call_offer
  Future<void> _createOfferTo(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    if (remoteId == _selfUserId) return;

    _log("Creating offer to peer: $remoteId");
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

  // EVENT 9 (Emit): group_call_answer
  Future<void> _handleOffer(Map<String, dynamic> data) async {
    final remoteUserId = data['fromUserId'].toString();
    final pc = await _createPeerConnection(remoteUserId);
    final description = data['description'];

    _log("Handling remote offer from peer: $remoteUserId");
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
    if (pc == null) {
      _log("Error: Peer connection not found during answer from $remoteUserId");
      return;
    }

    final description = data['description'];
    _log("Applying remote answer from peer: $remoteUserId");
    await pc.setRemoteDescription(
      RTCSessionDescription(description['sdp'], description['type']),
    );

    await _flushPendingIce(remoteUserId);
  }

  Future<void> _handleRemoteIce(Map<String, dynamic> data) async {
    final remoteUserId = data['fromUserId'].toString();
    final candidateData = data['candidate'];

    final candidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid']?.toString(),
      candidateData['sdpMLineIndex'] is int
          ? candidateData['sdpMLineIndex']
          : int.tryParse(candidateData['sdpMLineIndex']?.toString() ?? ''),
    );

    final pc = _peers[remoteUserId];
    final remoteDesc = pc != null ? await pc.getRemoteDescription() : null;

    if (pc == null || remoteDesc == null) {
      _log("Buffering ICE candidate for peer: $remoteUserId (remoteDescription is null)");
      _pendingIce.putIfAbsent(remoteUserId, () => []).add(candidate);
      return;
    }

    _log("Adding remote ICE candidate for peer: $remoteUserId");
    await pc.addCandidate(candidate);
  }

  Future<void> _flushPendingIce(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    final pc = _peers[remoteId];
    final remoteDesc = pc != null ? await pc.getRemoteDescription() : null;

    if (pc == null || remoteDesc == null) return;

    final pending = _pendingIce.remove(remoteId) ?? [];
    _log("Flushing ${pending.length} pending ICE candidates for peer: $remoteId");
    for (final candidate in pending) {
      try {
        await pc.addCandidate(candidate);
      } catch (e) {
        _log("Failed to add flushed ICE: $e");
      }
    }
  }

  void _addRemoteUser(String remoteUserId) {
    if (remoteUserId == _selfUserId) return;
    remoteUsers.add(remoteUserId);
  }

  Future<void> _removeRemotePeer(String remoteUserId) async {
    final remoteId = remoteUserId.toString();
    _log("Removing remote peer: $remoteId");

    final pc = _peers.remove(remoteId);
    if (pc != null) {
      await pc.close();
    }

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
    _log("Cleaning up active call session resources");
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

    try {
      localStream?.getTracks().forEach((track) => track.stop());
      await localStream?.dispose();
    } catch (_) {}
    localStream = null;

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