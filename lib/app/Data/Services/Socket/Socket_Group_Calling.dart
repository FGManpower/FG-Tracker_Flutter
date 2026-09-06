import 'dart:async';
import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:get/get.dart';
// Replace with your actual project imports
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
  final Set<String> _makingOffer = {};

  Function()? onParticipantsUpdated;
  Function()? onCallEnded;
  Function(String userId)? onParticipantJoined;
  Function(String userId)? onParticipantLeft;

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
    log('📞[GroupCallService] $message');
  }

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
      _log('🟢 Connected to Group Call Namespace');
      _listenersBound = false;
      _bindSocketListeners();
    });

    socket?.onDisconnect((_) {
      _log('🔴 Disconnected');
      _listenersBound = false;
    });

    socket?.onConnectError((err) => _log('❌ Connect Error: $err'));
    socket?.onError((err) => _log('❌ Error: $err'));
  }

  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    // Unbind existing to avoid duplicate triggers
    final events = [
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

    socket?.on("group_call_participant_joined", (data) async {
      final joinedUserId = data['userId']?.toString();
      _log('👤 Participant joined: $joinedUserId');

      if (joinedUserId == null || joinedUserId == _selfUserId) return;

      if (currentCallId != null && localStream != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _createPeerAndSendOffer(joinedUserId);
      }
      onParticipantJoined?.call(joinedUserId);
    });

    socket?.on("group_call_participant_left", (data) async {
      final leftUserId = data['userId']?.toString();
      _log('👋 Participant left: $leftUserId');
      if (leftUserId != null) {
        await _closePeer(leftUserId);
        onParticipantLeft?.call(leftUserId);
      }
    });

    socket?.on("group_call_offer", (data) async {
      _log('📥 Offer received');
      final fromUserId = data['fromUserId']?.toString();
      final description = data['description'];
      final incomingCallId = data['callId']?.toString();

      if (fromUserId == null || description == null) return;
      await _handleOffer(fromUserId, description, incomingCallId ?? currentCallId ?? "");
    });

    socket?.on("group_call_answer", (data) async {
      _log('📥 Answer received');
      final fromUserId = data['fromUserId']?.toString();
      final description = data['description'];

      if (fromUserId == null || description == null) return;
      await _handleAnswer(fromUserId, description);
    });

    socket?.on("group_call_ice", (data) async {
      final fromUserId = data['fromUserId']?.toString();
      final candidate = data['candidate'];
      if (fromUserId == null || candidate == null) return;
      await _handleIce(fromUserId, candidate);
    });

    socket?.on("group_call_ended", (data) async {
      _log('📵 Call ended by remote');
      onCallEnded?.call();
      await endCallLocalCleanup(navigate: true);
    });
  }

  // ============================================================
  // OUTGOING FLOW
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
          onResponse(false, null, "Malformed server response");
        }
      },
    );
  }

  // ============================================================
  // INCOMING FLOW
  // ============================================================
  Future<void> joinGroupCall(String callId, String groupId, Function(bool success) onComplete) async {
    _log('🚀 Joining Group Call: $callId');
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
          final participants = (response['existingParticipants'] as List?) ?? [];

          // Wait up to 3 seconds for local user media stream initialization
          int retries = 0;
          while (localStream == null && retries < 15) {
            await Future.delayed(const Duration(milliseconds: 200));
            retries++;
          }

          if (localStream != null) {
            for (final p in participants) {
              final targetUserId = p['userId']?.toString();
              if (targetUserId == null || targetUserId == _selfUserId) continue;
              await _createPeerAndSendOffer(targetUserId);
            }
          }
          onComplete(true);
        } else {
          onComplete(false);
        }
      },
    );
  }

  void rejectGroupCall(String callId, String groupId) {
    socket?.emit("reject_group_call", {
      "callId": int.tryParse(callId) ?? callId,
      "groupId": int.tryParse(groupId) ?? groupId,
    });
  }

  void leaveGroupCall() {
    if (currentCallId == null || currentGroupId == null) return;
    socket?.emit("leave_group_call", {
      "callId": int.tryParse(currentCallId!) ?? currentCallId,
      "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
    });
    endCallLocalCleanup(navigate: false);
  }

  void endGroupCall() {
    if (currentCallId == null || currentGroupId == null) return;
    socket?.emit("end_group_call", {
      "callId": int.tryParse(currentCallId!) ?? currentCallId,
      "groupId": int.tryParse(currentGroupId!) ?? currentGroupId,
    });
    endCallLocalCleanup(navigate: false);
  }

  // ============================================================
  // WEBRTC SIGNALING LOGIC
  // ============================================================
  Future<RTCPeerConnection> _createPeer(String remoteUserId) async {
    if (_peers.containsKey(remoteUserId)) {
      final state = await _peers[remoteUserId]!.getConnectionState();
      if (state != RTCPeerConnectionState.RTCPeerConnectionStateClosed &&
          state != RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        return _peers[remoteUserId]!;
      }
      await _closePeer(remoteUserId);
    }

    final pc = await createPeerConnection(_rtcConfig);

    if (localStream != null) {
      for (final track in localStream!.getTracks()) {
        await pc.addTrack(track, localStream!);
      }
    }

    pc.onTrack = (event) async {
      if (!remoteRenderers.containsKey(remoteUserId)) {
        final renderer = RTCVideoRenderer();
        await renderer.initialize();
        remoteRenderers[remoteUserId] = renderer;
      }

      final renderer = remoteRenderers[remoteUserId]!;
      if (event.streams.isNotEmpty) {
        renderer.srcObject = event.streams.first;
      } else {
        final stream = await createLocalMediaStream('remote_$remoteUserId');
        await stream.addTrack(event.track);
        renderer.srcObject = stream;
      }
      onParticipantsUpdated?.call();
    };

    pc.onIceCandidate = (candidate) {
      if (candidate.candidate == null || currentCallId == null) return;
      socket?.emit("group_call_ice", {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "targetUserId": remoteUserId,
        "candidate": {
          "candidate": candidate.candidate,
          "sdpMid": candidate.sdpMid,
          "sdpMLineIndex": candidate.sdpMLineIndex,
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

  Future<void> _createPeerAndSendOffer(String remoteUserId) async {
    if (_makingOffer.contains(remoteUserId)) return;
    _makingOffer.add(remoteUserId);

    try {
      final pc = await _createPeer(remoteUserId);
      final offer = await pc.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1,
      });

      await pc.setLocalDescription(offer);

      socket?.emit("group_call_offer", {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "targetUserId": remoteUserId,
        "description": {
          "type": offer.type,
          "sdp": offer.sdp,
        },
      });
    } catch (e) {
      _log("Error offering: $e");
    } finally {
      _makingOffer.remove(remoteUserId);
    }
  }

  Future<void> _handleOffer(String fromUserId, dynamic description, String callId) async {
    try {
      currentCallId ??= callId;
      final pc = await _createPeer(fromUserId);
      await pc.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));

      final answer = await pc.createAnswer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1,
      });
      await pc.setLocalDescription(answer);

      socket?.emit("group_call_answer", {
        "callId": int.tryParse(currentCallId!) ?? currentCallId,
        "targetUserId": fromUserId,
        "description": {
          "type": answer.type,
          "sdp": answer.sdp,
        },
      });
    } catch (e) {
      _log("Error answering: $e");
    }
  }

  Future<void> _handleAnswer(String fromUserId, dynamic description) async {
    final pc = _peers[fromUserId];
    if (pc == null) return;
    try {
      await pc.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));
    } catch (e) {
      _log("Error setting remote answer: $e");
    }
  }

  Future<void> _handleIce(String fromUserId, dynamic candidate) async {
    final ice = RTCIceCandidate(
      candidate['candidate'],
      candidate['sdpMid']?.toString(),
      candidate['sdpMLineIndex'] is int ? candidate['sdpMLineIndex'] : int.tryParse(candidate['sdpMLineIndex']?.toString() ?? ''),
    );

    final pc = _peers[fromUserId];
    if (pc == null || (await pc.getRemoteDescription()) == null) {
      _pendingIce.putIfAbsent(fromUserId, () => []).add(ice);
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

    if (pc != null) {
      pc.onTrack = null;
      pc.onIceCandidate = null;
      pc.onConnectionState = null;
      await pc.close();
    }

    final renderer = remoteRenderers.remove(userId);
    if (renderer != null) {
      renderer.srcObject = null;
      await renderer.dispose();
    }
    onParticipantsUpdated?.call();
  }

  Future<void> endCallLocalCleanup({bool navigate = true}) async {
    for (final userId in _peers.keys.toList()) {
      await _closePeer(userId);
    }
    _peers.clear();
    _pendingIce.clear();
    _makingOffer.clear();

    try {
      localStream?.getTracks().forEach((t) => t.stop());
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