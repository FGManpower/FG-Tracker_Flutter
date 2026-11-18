import 'package:socket_io_client/socket_io_client.dart';

/// Socket handlers owned by one call screen or controller.
///
/// `socket.off(event)` without a handler removes EVERY listener of that event,
/// including the global ones in `SignallingService` (callRejected, callEnded,
/// newCall). This class only ever removes the handlers it registered itself,
/// so global handlers survive any number of calls (BUG-CALL-03, doc 02 §5).
class CallSocketHandlers {
  CallSocketHandlers(this._socket);

  /// Always read the CURRENT socket (it is re-created on login, BUG-CALL-02).
  final Socket? Function() _socket;
  final List<_Entry> _entries = <_Entry>[];

  /// Registers [handler] for [event] on the current socket.
  void on(String event, dynamic Function(dynamic) handler) {
    final Socket? s = _socket();
    if (s == null) return;
    s.on(event, handler);
    _entries.add(_Entry(s, event, handler));
  }

  /// Removes only this owner's handlers for [event].
  void off(String event) {
    _entries.removeWhere((e) {
      if (e.event != event) return false;
      e.socket.off(e.event, e.handler);
      return true;
    });
  }

  /// Removes every handler this owner registered.
  void offAll() {
    for (final _Entry e in _entries) {
      e.socket.off(e.event, e.handler);
    }
    _entries.clear();
  }

  /// Number of handlers currently registered by this owner (tests).
  int get length => _entries.length;
}

class _Entry {
  _Entry(this.socket, this.event, this.handler);
  final Socket socket;
  final String event;
  final dynamic Function(dynamic) handler;
}
