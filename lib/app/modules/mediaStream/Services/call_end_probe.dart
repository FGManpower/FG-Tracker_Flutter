import 'dart:async';

/// The server's view of a 1:1 call (`GET /api/getCallDetail`).
class CallServerState {
  const CallServerState({required this.status, this.hasEndedAt = false});

  /// `callDetail.status`, lower case (e.g. `completed`, `ended`, `missed`).
  final String status;

  /// True when the server recorded an end time (`ended_at` / `endedAt`).
  final bool hasEndedAt;

  @override
  String toString() => 'CallServerState($status, endedAt=$hasEndedAt)';
}

/// Statuses that always mean "this call is over".
const Set<String> kHardEndedCallStatuses = <String>{
  'ended',
  'callended',
  'rejected',
  'declined',
  'cancelled',
  'canceled',
  'disconnected',
};

/// Decides from the server state whether a LIVE call is over.
///
/// - `ended`, `rejected`, `declined`, `cancelled`, `disconnected`: over.
/// - `completed` with an end time: over (a normal hang-up of a connected
///   call; while the call runs the server reports `completed` with no end
///   time, seen in the call history).
/// - `missed` with an end time: over only while the media link is down
///   ([linkDown]). The server has been seen marking an ANSWERED call
///   `missed` at the 45 s ring timeout while it was still running; a healthy
///   call must never be ended because of that.
/// - anything else, or unknown (`null`): not over.
bool isServerCallOver(CallServerState? s, {required bool linkDown}) {
  if (s == null) return false;
  final String status = s.status.trim().toLowerCase();
  if (status.isEmpty) return false;
  if (kHardEndedCallStatuses.contains(status)) return true;
  if (status == 'completed') return s.hasEndedAt;
  if (status == 'missed' || status == 'missedcall') {
    return linkDown && s.hasEndedAt;
  }
  return false;
}

/// While the call shows "Reconnecting…", asks the server whether the other
/// side already hung up, so the screen does not wait for the 25 s give-up.
///
/// Why: the hang-up normally arrives on the signaling socket (`callEnded`).
/// When that event is lost (socket reconnecting, app in background, server
/// hiccup), the media link simply dies and the call used to sit on
/// "Reconnecting…" until the give-up timer. Pure Dart + timers, unit-tested
/// with fake time.
class CallEndProbe {
  CallEndProbe({
    required this.check,
    required this.onEnded,
    this.firstCheckAfter = const Duration(seconds: 4),
    this.checkEvery = const Duration(seconds: 4),
  });

  /// True when the server says the call is over. Must never throw; return
  /// false when unsure.
  final Future<bool> Function() check;

  /// Called once when [check] returned true.
  final void Function() onEnded;

  /// Short blips (Wi-Fi to 4G) usually recover within a few seconds.
  final Duration firstCheckAfter;
  final Duration checkEvery;

  Timer? _timer;
  bool _inFlight = false;
  bool _done = false;

  bool get isRunning => _timer != null;

  /// The link went down: start asking (no-op when already running).
  void start() {
    if (_done || _timer != null) return;
    _timer = Timer(firstCheckAfter, () {
      if (_done) return;
      _timer = Timer.periodic(checkEvery, (_) => _tick());
      _tick();
    });
  }

  /// The link is back: stop asking.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// The call ended for another reason.
  void dispose() {
    _done = true;
    stop();
  }

  Future<void> _tick() async {
    if (_done || _inFlight) return;
    _inFlight = true;
    bool over = false;
    try {
      over = await check();
    } catch (_) {
      over = false;
    } finally {
      _inFlight = false;
    }
    if (over && !_done && _timer != null) {
      dispose();
      onEnded();
    }
  }
}
