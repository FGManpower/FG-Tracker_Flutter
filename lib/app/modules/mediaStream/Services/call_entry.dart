/// One argument shape for every incoming-call entry (in-app screen, CallKit /
/// full-screen accept, accept after a second call). BUG-CALL-14, doc 02 §5.
///
/// `remoteUserId` is always the CALLER (never "me"), so every payload the call
/// screen sends goes to the other user.
Map<String, dynamic> incomingCallArgs({
  required String callerId,
  required dynamic callId,
  String? sessionId,
  required bool isVideo,
  dynamic callerName,
  dynamic profileImage,
  dynamic offer,
  required bool fromCallKit,
}) {
  return <String, dynamic>{
    'callerId': callerId,
    'remoteUserId': callerId,
    'callId': callId,
    if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
    'is_video': isVideo,
    'callerName': callerName,
    // Both keys: older screens read `callerProfile`, CallKit used `profileImage`.
    'profileImage': profileImage,
    'callerProfile': profileImage,
    'callType': 'Incoming',
    'fromCallKit': fromCallKit,
    'offer': offer,
  };
}

/// Payload for declining an incoming call: the server routes it to
/// `remoteUserId`, which must be the caller (BUG-CALL-04).
Map<String, dynamic> rejectCallPayload({
  required dynamic callId,
  required String callerId,
}) {
  return <String, dynamic>{
    'callId': callId,
    'remoteUserId': callerId,
  };
}

/// A second incoming call that arrives while the user is on a call
/// (BUG-CALL-05). Parsed from a socket `newCall` or an FCM / VoIP push.
class WaitingCall {
  const WaitingCall({
    required this.callerId,
    required this.callId,
    this.sessionId,
    required this.callerName,
    this.avatar,
    required this.isVideo,
    this.offer,
  });

  final String callerId;
  final String callId;
  final String? sessionId;
  final String callerName;
  final String? avatar;
  final bool isVideo;

  /// SDP offer if the server sent one; otherwise the accept path asks for it
  /// (`acceptCallFromCallKit` → `sdpOfferFromCaller`).
  final dynamic offer;

  /// [decodeCallData] / [decodeOffer]: CallKitService helpers (injected to
  /// keep this file free of plugin imports).
  static WaitingCall? parse(
    dynamic data, {
    required Map<String, dynamic> Function(dynamic raw) decodeCallData,
    required dynamic Function(dynamic compressed) decodeOffer,
  }) {
    if (data is! Map) return null;
    final Map<dynamic, dynamic> m = data;
    final Map<String, dynamic> cd = decodeCallData(m['callData']);
    String s(dynamic v) => (v == null || v.toString() == 'null') ? '' : v.toString();

    final String callId = s(m['callId'] ?? m['call_id'] ?? cd['callId'] ?? cd['call_id']);
    final String callerId = s(m['callerId'] ?? m['caller_id'] ?? cd['callerId'] ?? cd['caller_id']);
    if (callId.isEmpty || callerId.isEmpty) return null;

    final String sessionId = s(m['session_id'] ?? m['sessionId'] ?? cd['session_id'] ?? cd['sessionId']);
    final dynamic video = m['isVideo'] ?? m['is_video'] ?? cd['isVideo'] ?? cd['is_video'];
    final dynamic offer = m['sdpOffer'] ?? decodeOffer(m['sdpOfferCompressed'] ?? cd['sdpOfferCompressed']);
    return WaitingCall(
      callerId: callerId,
      callId: callId,
      sessionId: sessionId.isEmpty ? null : sessionId,
      callerName: s(m['caller_name'] ?? m['callerName'] ?? cd['callerName'] ?? cd['caller_name']),
      avatar: s(m['caller_profile_image'] ?? m['profileImage'] ?? cd['callerProfileImage'] ?? cd['profileImage']),
      isVideo: video == true || video.toString() == 'true' || video.toString() == '1',
      offer: offer,
    );
  }
}

/// Why a call ended, for the end screen (Call again / Cancel).
enum CallEndOutcome { noAnswer, declined, busy, unavailable, connectionLost }

/// What the end screen needs (the controller is gone by then).
class CallEndInfo {
  const CallEndInfo({
    required this.outcome,
    required this.remoteUserId,
    required this.name,
    this.avatar,
    required this.isVideo,
  });

  final CallEndOutcome outcome;
  final String remoteUserId;
  final String name;
  final String? avatar;
  final bool isVideo;
}

/// Outcome of a `callRejected` / `callStatus: rejected`: busy when the
/// callee declined a waiting call or is on another call.
CallEndOutcome rejectOutcome(dynamic data) {
  if (data is Map) {
    final String reason =
        (data['reason'] ?? data['status'] ?? data['callingStatus'] ?? '')
            .toString()
            .toLowerCase();
    if (reason == 'busy') return CallEndOutcome.busy;
    // Backend reasons (callRejected): timeout = nobody answered;
    // permission_denied / failed = the other phone could not take it.
    if (reason == 'timeout' || reason == 'missed') {
      return CallEndOutcome.noAnswer;
    }
    if (reason == 'permission_denied' || reason == 'failed') {
      return CallEndOutcome.unavailable;
    }
  }
  return CallEndOutcome.declined;
}

/// Mic / camera / app-in-background state sent to the other side
/// ("X muted", "Video paused", "X's camera is off"). Sent through the
/// existing `upgradeToVideo` relay (works with today's server) and, once the
/// backend adds it, a dedicated `mediaState` event (doc 02 §8).
Map<String, dynamic> mediaStatePayload({
  required dynamic callId,
  required String to,
  required String me,
  required bool micMuted,
  required bool cameraOn,
  required bool videoPaused,
}) {
  return <String, dynamic>{
    'callId': callId,
    'call_id': callId,
    'remoteUserId': to,
    'remote_user_id': to,
    'receiverId': to,
    'callerId': me,
    'micMuted': micMuted,
    'cameraOn': cameraOn,
    'videoPaused': videoPaused,
    'mediaState': <String, dynamic>{
      'micMuted': micMuted,
      'cameraOn': cameraOn,
      'videoPaused': videoPaused,
    },
  };
}
