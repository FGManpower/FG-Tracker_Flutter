/// One place for the 1:1 call event / push names the app understands.
///
/// Holds today's backend names AND the names agreed in the backend request
/// (doc 02 §B, "1:1 calling – backend changes"), so the app works before and
/// after the backend ships them. Compared case-sensitively on purpose: they
/// are protocol names.
library;

/// The call is over for whatever reason: hang-up, caller cancel, reject,
/// missed / ring timeout. Used for socket events, FCM `signal_type` /
/// `type` and iOS VoIP push `signal_type` / `type`.
const Set<String> kCallEndSignals = <String>{
  // today
  'endCall',
  'callEnded',
  'call_ended',
  'cancelCall',
  'callRejected',
  'missedCall',
  'missCall',
  // agreed with the backend (points 4, 5, 7)
  'callCancelled',
  'call_cancelled',
  'callCanceled',
  'call_canceled',
};

/// Before an answer: the caller gave up or the ring timed out. The callee's
/// ringing screen must close; nothing is sent back.
const Set<String> kCallCancelSignals = <String>{
  'cancelCall',
  'callCancelled',
  'call_cancelled',
  'callCanceled',
  'call_canceled',
};

/// True when [signal] (an event name, `signal_type` or `type`) ends a call.
bool isCallEndSignal(String? signal) =>
    signal != null && kCallEndSignals.contains(signal.trim());

/// Reads the end signal from a push payload: `signal_type`, `type_signal`,
/// `action`, or `type` (the backend request uses `type: "call_cancelled"`).
/// `type` only counts when it is an end signal (it can mean other things).
///
/// [accepted] defaults to [kPushEndSignals]: NOT `missedCall` /
/// `callRejected`, because the server has sent a wrong `missed` for an
/// answered, running call; on a push that would close CallKit mid-call.
String? endSignalOf(
  Map<dynamic, dynamic> payload, {
  Set<String> accepted = kPushEndSignals,
}) {
  for (final String k in const <String>['signal_type', 'type_signal', 'action', 'type']) {
    final String? v = payload[k]?.toString().trim();
    if (v != null && accepted.contains(v)) return v;
  }
  return null;
}

/// End signals trusted on a push for a call that may already be answered:
/// a real hang-up or a caller cancel.
const Set<String> kPushEndSignals = <String>{
  'endCall',
  'callEnded',
  'call_ended',
  ...kCallCancelSignals,
};

/// Ring window for an incoming call from the server timestamps
/// (`createdAt` / `expiresAt`, UTC, point 3).
///
/// Returns:
/// - `null` = no usable timestamps: keep the app default.
/// - [Duration.zero] = clearly stale (a push delivered long after the call
///   expired, e.g. phone was off): do not ring.
/// - otherwise the time left, clamped to [min] .. [max].
///
/// Phone clocks can be off by tens of seconds, so a call is only "stale"
/// when it expired more than [staleAfter] ago; a short skew must never
/// swallow a real call.
Duration? remainingRingTime({
  required dynamic expiresAt,
  required DateTime now,
  Duration max = const Duration(seconds: 45),
  Duration min = const Duration(seconds: 10),
  Duration staleAfter = const Duration(seconds: 60),
}) {
  final DateTime? exp = parseServerTime(expiresAt);
  if (exp == null) return null;
  final Duration left = exp.difference(now.toUtc());
  if (left <= -staleAfter) return Duration.zero;
  if (left < min) return min;
  if (left > max) return max;
  return left;
}

/// ISO-8601 string, or epoch seconds / milliseconds. `null` when unusable.
DateTime? parseServerTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v.toUtc();
  final String s = v.toString().trim();
  if (s.isEmpty || s == 'null') return null;
  final int? n = int.tryParse(s);
  if (n != null) {
    if (n <= 0) return null;
    // Seconds until year 2286; anything bigger is milliseconds.
    return n < 10000000000
        ? DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true)
        : DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
  }
  return DateTime.tryParse(s)?.toUtc();
}
