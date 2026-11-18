import 'dart:async';

/// Media link state, simplified from the WebRTC ICE / peer states.
enum CallLinkState { connected, disconnected, failed, closed }

/// What the call screen must do (BUG-CALL-06, doc 02 §7).
enum CallLinkAction {
  /// Show "Reconnecting…" (audio keeps running if it can).
  showReconnecting,

  /// Send an ICE-restart offer (new network path, e.g. Wi-Fi → 4G).
  iceRestart,

  /// The link is back: hide "Reconnecting…", the timer keeps running.
  recovered,

  /// No recovery within [CallConnectionMonitor.giveUpAfter]: end the call
  /// with the reason "connection_lost".
  connectionLost,
}

/// Decides when to restart ICE and when to give up. Pure Dart + timers, so
/// it is unit-tested with fake time.
///
/// Before: ICE `disconnected` waited 30 s and `failed` 12 s, then the call
/// was hung up, with no ICE restart at all.
///
/// Now (WhatsApp-like):
/// - `disconnected` / `failed`: "Reconnecting…" at once;
/// - the original caller ([isInitiator]) sends an ICE restart after
///   [firstRestartAfter] (`failed`: at once), the other side only after
///   [retryEvery] (so both do not offer at the same time); then every
///   [retryEvery] while still down;
/// - back to `connected`: recovered;
/// - still down after [giveUpAfter]: connection lost.
class CallLinkMonitor {
  CallLinkMonitor({
    required this.onAction,
    required this.isInitiator,
    this.firstRestartAfter = const Duration(seconds: 2),
    this.retryEvery = const Duration(seconds: 6),
    this.giveUpAfter = const Duration(seconds: 25),
  });

  final void Function(CallLinkAction action) onAction;
  final bool isInitiator;
  final Duration firstRestartAfter;
  final Duration retryEvery;
  final Duration giveUpAfter;

  bool _down = false;
  bool _closed = false;
  bool _everConnected = false;
  Timer? _restartTimer;
  Timer? _giveUpTimer;

  bool get isReconnecting => _down;
  bool get everConnected => _everConnected;

  void onState(CallLinkState state) {
    if (_closed) return;
    switch (state) {
      case CallLinkState.connected:
        _everConnected = true;
        if (_down) {
          _down = false;
          _cancelTimers();
          onAction(CallLinkAction.recovered);
        }
        return;
      case CallLinkState.closed:
        dispose();
        return;
      case CallLinkState.disconnected:
      case CallLinkState.failed:
        if (!_down) {
          _down = true;
          onAction(CallLinkAction.showReconnecting);
          _giveUpTimer = Timer(giveUpAfter, () {
            if (!_down || _closed) return;
            _cancelTimers();
            onAction(CallLinkAction.connectionLost);
          });
          _scheduleRestart(
            immediate: state == CallLinkState.failed && isInitiator,
          );
        } else if (state == CallLinkState.failed && isInitiator) {
          // Got worse while waiting: try now instead of at the next tick.
          _restartNow();
        }
    }
  }

  /// The signaling socket reconnected during the call: if the media link is
  /// down, restart ICE right away (the old ICE credentials may be stale).
  void onSignalingReconnected() {
    if (_closed || !_down) return;
    _restartNow();
  }

  void _scheduleRestart({required bool immediate}) {
    _restartTimer?.cancel();
    if (immediate) {
      _restartNow();
      return;
    }
    _restartTimer = Timer(isInitiator ? firstRestartAfter : retryEvery, () {
      _restartNow();
    });
  }

  void _restartNow() {
    if (!_down || _closed) return;
    _restartTimer?.cancel();
    onAction(CallLinkAction.iceRestart);
    _restartTimer = Timer.periodic(retryEvery, (Timer t) {
      if (!_down || _closed) {
        t.cancel();
        return;
      }
      onAction(CallLinkAction.iceRestart);
    });
  }

  void _cancelTimers() {
    _restartTimer?.cancel();
    _giveUpTimer?.cancel();
    _restartTimer = null;
    _giveUpTimer = null;
  }

  void dispose() {
    _closed = true;
    _cancelTimers();
  }
}
