// Test-only fake Socket.IO v4 server (Engine.IO v4, websocket transport only).
//
// Just enough of the protocol for `socket_io_client` 3.1.x:
//   open    0{"sid":..}                      server -> client
//   connect 40/nsp,{auth}  ->  40/nsp,{"sid":..}
//   event   42/nsp,["name",data]   (both directions)
//   ack     42/nsp,<id>["name",..] ->  43/nsp,<id>[..]
//   kick    41/nsp,                ("io server disconnect" on the client)
//   ping    2 / pong 3
//
// Lets QA tests drive the real SocketMessageService against a local server
// with no backend and no change to app code.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class FakeClientEvent {
  FakeClientEvent(this.namespace, this.name, this.data, this.ackId);
  final String namespace;
  final String name;
  final dynamic data;
  final int? ackId;
  @override
  String toString() => '$namespace <= $name $data';
}

class _Conn {
  _Conn(this.ws, this.id);
  final WebSocket ws;
  final int id;
  final Set<String> namespaces = {};
  final Map<String, dynamic> auth = {};
}

class FakeSocketIoServer {
  HttpServer? _server;
  final List<_Conn> _conns = [];
  int _nextId = 1;

  /// Every event any client emitted, in order.
  final List<FakeClientEvent> received = [];

  /// Number of namespace connects seen per namespace (counts reconnects).
  final Map<String, int> connectCount = {};

  /// Auth payloads sent on namespace connect, newest last.
  final List<Map<String, dynamic>> authPayloads = [];

  /// Optional automatic ack replies: event name -> reply payload.
  final Map<String, dynamic> ackReplies = {};

  final _eventController = StreamController<FakeClientEvent>.broadcast();
  Stream<FakeClientEvent> get events => _eventController.stream;

  String get url => 'http://127.0.0.1:${_server!.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((req) async {
      if (!WebSocketTransformer.isUpgradeRequest(req)) {
        req.response.statusCode = 400;
        await req.response.close();
        return;
      }
      final ws = await WebSocketTransformer.upgrade(req);
      final conn = _Conn(ws, _nextId++);
      _conns.add(conn);
      ws.add('0${jsonEncode({
            'sid': 'eio${conn.id}',
            'upgrades': [],
            'pingInterval': 25000,
            'pingTimeout': 60000,
            'maxPayload': 1000000,
          })}');
      ws.listen(
        (msg) => _onMessage(conn, msg as String),
        onDone: () => _conns.remove(conn),
        onError: (_) => _conns.remove(conn),
      );
    });
  }

  void _onMessage(_Conn conn, String msg) {
    if (msg == '2') {
      conn.ws.add('3');
      return;
    }
    if (!msg.startsWith('4')) return; // only socket.io packets matter
    final type = msg[1];
    var rest = msg.substring(2);
    var nsp = '/';
    if (rest.startsWith('/')) {
      final comma = rest.indexOf(',');
      if (comma == -1) {
        nsp = rest;
        rest = '';
      } else {
        nsp = rest.substring(0, comma);
        rest = rest.substring(comma + 1);
      }
    }
    switch (type) {
      case '0': // connect
        conn.namespaces.add(nsp);
        connectCount[nsp] = (connectCount[nsp] ?? 0) + 1;
        if (rest.isNotEmpty) {
          final auth = jsonDecode(rest);
          if (auth is Map) {
            authPayloads.add(Map<String, dynamic>.from(auth));
          }
        }
        conn.ws.add('40$nsp,${jsonEncode({'sid': 's${conn.id}$nsp'})}');
        break;
      case '1': // client disconnect from namespace
        conn.namespaces.remove(nsp);
        break;
      case '2': // event
        final m = RegExp(r'^(\d*)(\[.*)$', dotAll: true).firstMatch(rest);
        if (m == null) return;
        final ackId = m.group(1)!.isEmpty ? null : int.parse(m.group(1)!);
        final arr = jsonDecode(m.group(2)!) as List;
        final name = arr.first as String;
        final data = arr.length > 1 ? arr[1] : null;
        final ev = FakeClientEvent(nsp, name, data, ackId);
        received.add(ev);
        _eventController.add(ev);
        if (ackId != null && ackReplies.containsKey(name)) {
          conn.ws.add('43$nsp,$ackId${jsonEncode([ackReplies[name]])}');
        }
        break;
    }
  }

  /// Number of live client connections joined to [nsp].
  int clientsOn(String nsp) =>
      _conns.where((c) => c.namespaces.contains(nsp)).length;

  /// Server -> every client connected to [nsp].
  void emit(String nsp, String event, [dynamic data]) {
    final payload = data == null ? [event] : [event, data];
    for (final c in List.of(_conns)) {
      if (c.namespaces.contains(nsp)) {
        c.ws.add('42$nsp,${jsonEncode(payload)}');
      }
    }
  }

  /// Server-side namespace disconnect: client sees "io server disconnect".
  void kick(String nsp) {
    for (final c in List.of(_conns)) {
      if (c.namespaces.remove(nsp)) c.ws.add('41$nsp,');
    }
  }

  /// Drop every transport (like a network loss). Clients may auto-reconnect.
  Future<void> dropAll() async {
    for (final c in List.of(_conns)) {
      await c.ws.close();
    }
    _conns.clear();
  }

  List<FakeClientEvent> receivedNamed(String name, {String? nsp}) => received
      .where((e) => e.name == name && (nsp == null || e.namespace == nsp))
      .toList();

  Future<void> stop() async {
    await dropAll();
    await _server?.close(force: true);
    await _eventController.close();
  }
}

/// Polls [cond] until true or [timeout]; returns the final value.
Future<bool> waitFor(bool Function() cond,
    {Duration timeout = const Duration(seconds: 3)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (cond()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  return cond();
}
