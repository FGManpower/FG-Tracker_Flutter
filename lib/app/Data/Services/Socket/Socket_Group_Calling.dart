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


  final Map<String, Map<String, dynamic>> participantMeta = {};

  Function()? onParticipantsUpdated;
  Function()? onCallEnded;
  Function(String userId)? onParticipantJoined;
  Function(String userId)? onParticipantLeft;
  Function(String userId)? onParticipantRejected;
  Function(String userId, bool isMuted)? onParticipantMuteChanged;
  Function(Map<String, dynamic> data)? onIncomingCallReceived;

  bool _listenersBound = false;
  bool _isDisposed = false;

  String? get selfUserId => _selfUserId;

  static const Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {
        'urls': ['stun:stun.l.google.com:19302']
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
    return 'User $name';
  }

  String? getParticipantProfileImage(String userId) {
    return participantMeta[userId]?['profileImage']?.toString();
  }

  bool getParticipantMuted(String userId) {
    return participantMeta[userId]?['isMuted'] == true;
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
      _log('Connected to /groupCall');
      _listenersBound = false;
      _bindSocketListeners();
    });

    socket?.onDisconnect((_) {
      _log('Socket Disconnected');
      _listenersBound = false;
    });

    socket?.onAny((event, dynamic data) {
      _log('GroupSocketAllEvent: $event | Data: $data');
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
      "group_call_participant_mute",
      "group_call_offer",
      "group_call_answer",
      "group_call_ice",
      "group_call_ended",
    ];
    for (final e in events) {
      socket?.off(e);
    }

    socket?.on("group_call_started", (raw) {
      // _log(" group_call_started: $raw");
      // if (raw == null) return;
      //
      // final Map<String, dynamic> data = raw is Map && raw['data'] is Map
      //     ? Map<String, dynamic>.from(raw['data'])
      //     : Map<String, dynamic>.from(raw);
      //
      // final callerId = (data['callerId'] ?? data['userId'])?.toString();
      // if (callerId == null || callerId == _selfUserId) {
      //   _log('Ignore self/invalid group_call_started');
      //   return;
      // }
      //
      // final callerName = (data['name'] ??
      //     data['callerName'] ??
      //     'Someone')
      //     .toString();
      // final callerProfile = (data['profileImage'] ??
      //     data['callerProfileImage'] ??
      //     '')
      //     .toString();
      //
      // currentCallId = data['callId']?.toString();
      // currentGroupId = data['groupId']?.toString();
      //
      // _saveParticipantMeta(
      //   callerId,
      //   name: callerName,
      //   profileImage: callerProfile,
      //   isMuted: false,
      // );
      //
      // final currentRoute = Get.currentRoute;
      // if (currentRoute == Routes.groupCallingScreen ||
      //     currentRoute == Routes.groupIncomingCallScreen) {
      //   _log('Already in call UI, skip navigation');
      //   return;
      // }
      //
      // Get.toNamed(
      //   Routes.groupIncomingCallScreen,
      //   arguments: {
      //     "callId": data['callId']?.toString(),
      //     "groupId": data['groupId']?.toString() ?? "",
      //     "groupName": (data['groupName'] ?? "Group Call").toString(),
      //     "callerName": callerName,
      //     "groupProfile": (data['groupProfile'] ?? callerProfile).toString(),
      //     "callerProfileImage": callerProfile,
      //     "activeMemberCount": 1,
      //     "totalMemberCount": data['totalMembers'] ?? 0,
      //     "isVideo": data['isVideo'] == true,
      //     "callType": "incoming",
      //   },
      // );
      //
      // onIncomingCallReceived?.call(data);
    });


    socket?.on("group_call_participant_joined", (raw) {
      _log("👤 group_call_participant_joined: $raw");
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
      _log("👋 group_call_participant_left: $raw");
      final leftUserId = raw is Map ? raw['userId']?.toString() : null;
      if (leftUserId != null) {
        await _removeRemotePeer(leftUserId);
      }
    });

    socket?.on("group_call_ended", (raw) async {
      _log("📵 group_call_ended: $raw");
      if (Get.currentRoute == Routes.groupIncomingCallScreen) {
        Get.back();
      }
      onCallEnded?.call();
      await endCallLocalCleanup(navigate: true);
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

    if (socket == null || !socket!.connected) {
      onResponse(false, null, "Socket disconnected");
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
        // also send new keys for backend compatibility
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
    _log(' emit join_group_call callId=$callId');
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
        _log('join_group_call ACK: $response');
        if (response is! Map || response['success'] != true) {
          onComplete(false);
          return;
        }

        currentCallId = response['callId']?.toString() ?? callId;

        // existingParticipants can be:
        // [{userId,name,profileImage,status}] OR [{userId,status}]
        final participants = (response['existingParticipants'] as List?) ?? [];
        for (final p in participants) {
          if (p is! Map) continue;
          final uid = p['userId']?.toString();
          if (uid == null || uid == _selfUserId) continue;

          _saveParticipantMeta(
            uid,
            name: (p['name'] ?? p['userName'])?.toString(),
            profileImage: (p['profileImage'] ?? p['userProfileImage'])?.toString(),
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

  // ============================================================
  // 6) reject_group_call
  // ============================================================
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

  // ============================================================
  // NEW: group_call_mute (emit)
  // ============================================================
  void emitMute({required bool isMuted}) {
    if (currentCallId == null || currentGroupId == null) {
      _log('⚠️ emitMute skipped: no active call');
      return;
    }

    _log('🚀 emit group_call_mute isMuted=$isMuted');

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
  // 11) leave_group_call
  // ============================================================
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

  // ============================================================
  // 13) end_group_call
  // ============================================================
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
      for (final track in localStream!.getTracks()) {
        await pc.addTrack(track, localStream!);
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
    // keep meta optional; remove if you want hard cleanup:
    // participantMeta.remove(remoteId);

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