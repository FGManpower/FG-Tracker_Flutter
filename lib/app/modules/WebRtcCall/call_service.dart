// lib/services/call_service.dart
import 'dart:async';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


/// Replace with your server address (no trailing slash), e.g. "http://192.168.1.50:3000"
final String SIGNALING_SERVER = ConstRes.socketUrl;

class CallService {
  final String userId;
  final bool debug;

  CallService({required this.userId, this.debug = false});

  IO.Socket? _socket;
  RTCPeerConnection? _pc;
  MediaStream? localStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  // callbacks (assign from UI)
  void Function(Map callData)? onIncomingCall; // receives payload from server
  void Function(String callId)? onCallInitiated; // for caller ack
  void Function(String callId)? onCallAccepted; // for caller notified
  void Function(String callId)? onCallRejected;
  void Function()? onCallEnded;
  void Function(String userId)? onUserOnline;
  void Function(String userId)? onUserOffline;

  // internal
  final Map<String, dynamic> _pendingOffers = {};     // fromUserId -> offerMap
  final Map<String, List<dynamic>> _pendingCandidates = {}; // fromUserId -> list of candidate maps
  String? _currentPeerId; // remote user id in current call (string)
  String? _currentCallId;
  bool _isCaller = false;

  Future<void> init() async {
    // initialize renderers
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _connectSocket();
  }

  /// Open camera + mic
  Future<void> openUserMedia() async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = localStream;
  }

  /// Create peer connection
  Future<void> startConnection() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _pc = await createPeerConnection(configuration);

    // Add local stream to peer connection
    localStream?.getTracks().forEach((track) {
      _pc?.addTrack(track, localStream!);
    });

    // Listen for remote stream
    _pc?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };
  }

  void _log(String msg) {
    if (debug) print('[CallService] $msg');
  }

  void _connectSocket() {
    // Connect to namespace /call (match your backend)
    final uri = '$SIGNALING_SERVER/call';
    _log('Connecting to $uri');

    // Pass userId in query so server can map socket <-> userId immediately
    _socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': userId},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _log('Socket connected: ${_socket!.id}');
      // server may still want explicit register
      _socket!.emit('register', {'userId': userId});
    });

    _socket!.on('registered', (data) {
      _log('Registered ack: $data');
    });

    // Presence
    _socket!.on('user_online', (data) {
      final uid = data?['userId']?.toString();
      if (uid != null) onUserOnline?.call(uid);
    });

    _socket!.on('user_offline', (data) {
      final uid = data?['userId']?.toString();
      if (uid != null) onUserOffline?.call(uid);
    });

    // incoming_call from server (UI should show Accept/Reject)
    _socket!.on('incoming_call', (data) {
      _log('incoming_call: $data');
      if (data is Map) {
        onIncomingCall?.call(Map<String, dynamic>.from(data));
      } else {
        onIncomingCall?.call(Map<String, dynamic>.from(data));
      }
    });

    // server ack for caller
    _socket!.on('call_initiated', (data) {
      _log('call_initiated: $data');
      onCallInitiated?.call(data['callId']?.toString() ?? '');
    });

    // call accepted notification (from server to caller)
    _socket!.on('call_accepted', (data) {
      _log('call_accepted: $data');
      onCallAccepted?.call(data['callId']?.toString() ?? '');
    });

    _socket!.on('call_rejected', (data) {
      _log('call_rejected: $data');
      onCallRejected?.call(data['callId']?.toString() ?? '');
    });

    _socket!.on('call_ended', (data) {
      _log('call_ended: $data');
      onCallEnded?.call();
      _cleanupPeer();
    });

    // Signaling handlers
    _socket!.on('offer', (data) async {
      _log('offer received raw: $data');
      final from = (data['fromUserId'] ?? data['from'])?.toString();
      final offer = data['offer'] ?? (data['sdp'] != null ? {'sdp': data['sdp'], 'type': data['type']} : null);

      if (from == null || offer == null) {
        _log('Malformed offer ignored');
        return;
      }

      // store incoming offer (in case UI hasn't accepted yet)
      _pendingOffers[from] = offer;
      _log('Stored offer from $from');

      // If we already created PC and are not the caller, immediately set remote and answer
      if (_pc != null && !_isCaller) {
        try {
          await _pc!.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));
          _log('Set remote description from offer (immediate)');

          final answer = await _pc!.createAnswer();
          await _pc!.setLocalDescription(answer);
          _socket!.emit('answer', {
            'toUserId': from,
            'fromUserId': userId,
            'answer': {'sdp': answer.sdp, 'type': answer.type}
          });
          _log('Sent answer back to $from (immediate)');
        } catch (e) {
          _log('Error while auto-answering: $e');
        }
      }
    });

    _socket!.on('answer', (data) async {
      _log('answer received: $data');
      final from = (data['fromUserId'] ?? data['from'])?.toString();
      final answer = data['answer'] ?? (data['sdp'] != null ? {'sdp': data['sdp'], 'type': data['type']} : null);
      if (from == null || answer == null) return;

      if (_pc != null) {
        try {
          await _pc!.setRemoteDescription(RTCSessionDescription(answer['sdp'], answer['type']));
          _log('Remote description set (answer)');
        } catch (e) {
          _log('Failed to set remote description (answer): $e');
        }
      } else {
        _log('No peerConnection to set answer on; discarding');
      }
    });

    _socket!.on('ice_candidate', (data) async {
      _log('ice_candidate received: $data');
      final from = (data['fromUserId'] ?? data['from'])?.toString();
      final candidate = data['candidate'];
      if (from == null || candidate == null) return;

      // if pc exists, add immediately; otherwise queue
      if (_pc != null) {
        try {
          await _pc!.addCandidate(RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']));
          _log('Candidate added from $from');
        } catch (e) {
          _log('addCandidate failed: $e');
        }
      } else {
        _pendingCandidates.putIfAbsent(from, () => []).add(candidate);
        _log('Stored candidate for $from (pc not ready)');
      }
    });

    _socket!.onDisconnect((_) {
      _log('socket disconnected');
    });

    _socket!.onError((err) {
      _log('socket error: $err');
    });
  }

  Future<void> startCall({required String receiverId, bool isVideo = true, String? callerName}) async {
    _isCaller = true;
    _currentPeerId = receiverId;

    // create DB record and notify receiver via server
    _socket!.emit('call_user', {
      'caller_id': userId,
      'receiver_id': receiverId,
      'is_video': isVideo,
      'caller_name': callerName ?? userId,
    });

    // create local pc & stream
    await _createPeerConnection(remoteUserId: receiverId, isVideo: isVideo);

    // create offer
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);

    // send offer
    _socket!.emit('offer', {
      'toUserId': receiverId,
      'fromUserId': userId,
      'offer': {'sdp': offer.sdp, 'type': offer.type}
    });

    _log('Offer sent to $receiverId');
  }

  /// Called when user accepts a call (UI should call this)
  Future<void> acceptCall({required Map incomingCall}) async {
    final callerId = (incomingCall['from'] ?? incomingCall['caller_id'])?.toString();
    final callId = incomingCall['callId']?.toString();
    final isVideo = incomingCall['is_video'] == true || incomingCall['is_video'] == 'true';

    if (callerId == null) {
      _log('acceptCall: missing callerId in incomingCall payload');
      return;
    }

    _currentPeerId = callerId;
    _currentCallId = callId;
    _isCaller = false;

    // create pc & local stream BEFORE setting remote desc so tracks are ready
    await _createPeerConnection(remoteUserId: callerId, isVideo: isVideo);

    // Process stored offer (if present)
    final offer = _pendingOffers.remove(callerId);
    if (offer != null) {
      try {
        await _pc!.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));
        _log('Remote description set (offer) from $callerId');

        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);

        _socket!.emit('answer', {
          'toUserId': callerId,
          'fromUserId': userId,
          'answer': {'sdp': answer.sdp, 'type': answer.type}
        });

        _log('Answer sent to $callerId');
      } catch (e) {
        _log('Error processing offer on accept: $e');
      }
    } else {
      _log('No stored offer for $callerId at accept time');
    }

    // apply any pending candidates for this peer
    final pendCandidates = _pendingCandidates.remove(callerId) ?? [];
    for (var c in pendCandidates) {
      try {
        await _pc!.addCandidate(RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
      } catch (e) {
        _log('failed adding pending candidate: $e');
      }
    }

    // notify server caller accepted (DB/status)
    _socket!.emit('accept_call', {'callId': callId ?? null, 'from': callerId, 'to': userId});
  }

  Future<void> rejectCall({required Map incomingCall, String reason = 'rejected'}) async {
    final callerId = (incomingCall['from'] ?? incomingCall['caller_id'])?.toString();
    final callId = incomingCall['callId']?.toString();
    if (callerId == null) return;
    _socket!.emit('reject_call', {'callId': callId ?? null, 'from': callerId, 'to': userId, 'reason': reason});
  }

  Future<void> endCall({String? reason}) async {
    if (_currentCallId != null && _currentPeerId != null) {
      _socket!.emit('end_call', {'callId': _currentCallId, 'from': userId, 'to': _currentPeerId, 'reason': reason ?? 'ended'});
    }
    _cleanupPeer();
    onCallEnded?.call();
  }

  Future<void> _createPeerConnection({required String remoteUserId, bool isVideo = true}) async {
    // cleanup existing
    if (_pc != null) {
      try {
        await _pc!.close();
      } catch (e) {}
      _pc = null;
    }

    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        // add TURN here for production
      ]
    };

    _pc = await createPeerConnection(configuration);

    // prepare local stream
    try {
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': isVideo ? {'facingMode': 'user'} : false
      });
    } catch (e) {
      _log('getUserMedia failed: $e');
      rethrow;
    }

    // attach local preview
    localRenderer.srcObject = localStream;

    // add tracks
    localStream!.getTracks().forEach((track) {
      _pc!.addTrack(track, localStream!);
    });

    // remote track handler
    _pc!.onTrack = (RTCTrackEvent event) {
      _log('onTrack event, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
        _log('remoteRenderer.srcObject set');
      }
    };

    // onAddStream fallback (some platforms)
    _pc!.onAddStream = (MediaStream stream) {
      _log('onAddStream: ${stream.id}');
      remoteRenderer.srcObject = stream;
    };

    // ICE candidate handling
    _pc!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null && remoteUserId.isNotEmpty) {
        _socket!.emit('ice_candidate', {
          'toUserId': remoteUserId,
          'fromUserId': userId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex
          }
        });
        _log('Emitted ICE candidate to $remoteUserId');
      }
    };

    // connection state
    _pc!.onConnectionState = (state) {
      _log('PC connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        onCallEnded?.call();
        _cleanupPeer();
      }
    };

    // After creating pc, if we have stored candidates for remoteUserId, apply them
    final pend = _pendingCandidates.remove(remoteUserId) ?? [];
    for (var c in pend) {
      try {
        await _pc!.addCandidate(RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
      } catch (e) {
        _log('failed adding pending candidate after pc created: $e');
      }
    }
  }

  Future<void> dispose() async {
    try {
      await localRenderer.dispose();
      await remoteRenderer.dispose();
    } catch (e) {}
    try {
      await _pc?.close();
    } catch (e) {}
    try {
      await localStream?.dispose();
    } catch (e) {}
    try {
      _socket?.disconnect();
      _socket?.close();
    } catch (e) {}
  }

  void _cleanupPeer() {
    try {
      _pc?.close();
    } catch (e) {}
    _pc = null;
    try {
      localStream?.getTracks().forEach((t) => t.stop());
      localStream?.dispose();
    } catch (e) {}
    localStream = null;
    remoteRenderer.srcObject = null;
    localRenderer.srcObject = null;
    _currentPeerId = null;
    _currentCallId = null;
    _isCaller = false;
    _pendingCandidates.clear();
    _pendingOffers.clear();
  }
}
