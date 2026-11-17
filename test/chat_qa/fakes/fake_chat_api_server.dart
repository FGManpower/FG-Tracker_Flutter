// A tiny local HTTP server that stands in for the chat REST API in tests
// (F-1.2.9). Point the app's Dio client at it with [FakeChatApiServer.attach];
// every other host stays blocked (see [LoopbackOnlyHttpOverrides]).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';

/// What one route answers.
class FakeRoute {
  FakeRoute({
    this.body = const {'status': true, 'data': []},
    this.status = 200,
    this.delay = Duration.zero,
    this.failTimes = 0,
    this.failStatus = 503,
    this.offline = false,
  });

  /// JSON body for a successful answer (or a function of the request).
  Object? body;
  Object? Function(Uri uri)? bodyFor;
  int status;
  Duration delay;

  /// The first [failTimes] calls fail ([failStatus], or a dropped
  /// connection when [failStatus] is 0), then the route answers normally.
  int failTimes;
  int failStatus;

  /// Every call drops the connection (like airplane mode).
  bool offline;
}

class FakeChatApiServer {
  FakeChatApiServer._(this._server);

  final HttpServer _server;

  /// Routes by path, e.g. `/api/chat-list`.
  final Map<String, FakeRoute> routes = {};

  /// Calls per path.
  final Map<String, int> calls = {};
  final List<Uri> requests = [];

  static Future<FakeChatApiServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = FakeChatApiServer._(server);
    server.listen(fake._handle);
    return fake;
  }

  String get baseUrl => 'http://127.0.0.1:${_server.port}/api/';

  /// Points the app's Dio client at this server; returns the old base URL.
  String attach() {
    final dio = HttpUtil().api.sendRequest;
    final old = dio.options.baseUrl;
    dio.options.baseUrl = baseUrl;
    // Dio caches its HttpClient: a fresh adapter picks up the current
    // HttpOverrides (an earlier test may have blocked every host).
    dio.httpClientAdapter = IOHttpClientAdapter();
    return old;
  }

  int callsTo(String path) => calls[path] ?? 0;

  Future<void> _handle(HttpRequest req) async {
    final path = req.uri.path.replaceAll(RegExp(r'/+'), '/');
    calls[path] = (calls[path] ?? 0) + 1;
    requests.add(req.uri);
    final route = routes[path];
    if (route == null) {
      req.response
        ..statusCode = 404
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'status': false, 'message': 'no route $path'}));
      await req.response.close();
      return;
    }
    if (route.delay > Duration.zero) await Future<void>.delayed(route.delay);
    if (route.offline || (route.failTimes > 0 && route.failStatus == 0)) {
      if (!route.offline) route.failTimes--;
      final socket = await req.response.detachSocket(writeHeaders: false);
      socket.destroy(); // connection error on the client
      return;
    }
    if (route.failTimes > 0) {
      route.failTimes--;
      req.response
        ..statusCode = route.failStatus
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'status': false, 'message': 'server error'}));
      await req.response.close();
      return;
    }
    final body = route.bodyFor?.call(req.uri) ?? route.body;
    req.response
      ..statusCode = route.status
      ..headers.contentType = ContentType.json
      ..write(body is String ? body : jsonEncode(body));
    await req.response.close();
  }

  Future<void> close() => _server.close(force: true);
}

/// Only loopback is reachable: real hosts (the const production API and
/// socket URLs) go to a dead proxy, so no test ever talks to a server.
class LoopbackOnlyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..findProxy = (uri) =>
            (uri.host == '127.0.0.1' || uri.host == 'localhost')
                ? 'DIRECT'
                : 'PROXY 127.0.0.1:9';
}
