import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Repositories/package_api_error.dart';
import 'package:fgtracker/app/Data/Repositories/package_pricing_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

DioException _dio(DioExceptionType type, {int? status, dynamic data}) {
  final req = RequestOptions(path: 'http://fgtracker.in:3000/api/packages');
  return DioException(
    requestOptions: req,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: req, statusCode: status, data: data),
  );
}

/// Answers every request with a fixed status + body, and records the request
class _FakeAdapter implements HttpClientAdapter {
  final int status;
  final String body;
  RequestOptions? last;

  _FakeAdapter(this.status, this.body);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('PackageApiException.fromDio', () {
    test('timeouts → timeout', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(PackageApiException.fromDio(_dio(t)).kind,
            PackageErrorKind.timeout);
      }
    });

    test('connection error / socket → offline', () {
      expect(
          PackageApiException.fromDio(_dio(DioExceptionType.connectionError))
              .kind,
          PackageErrorKind.offline);
      final socket = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.unknown,
        error: const SocketException('down'),
      );
      expect(PackageApiException.fromDio(socket).isOffline, isTrue);
    });

    test('status codes map to kinds', () {
      PackageErrorKind k(int s) => PackageApiException.fromDio(
              _dio(DioExceptionType.badResponse, status: s))
          .kind;
      expect(k(401), PackageErrorKind.unauthorized);
      expect(k(403), PackageErrorKind.unauthorized);
      expect(k(404), PackageErrorKind.notFound);
      expect(k(409), PackageErrorKind.conflict);
      expect(k(500), PackageErrorKind.server);
      expect(k(502), PackageErrorKind.server);
      expect(k(400), PackageErrorKind.unknown);
    });

    test('raw server text is kept for logs but never in the user message', () {
      const raw = "Can't find /api/packages on the server!";
      final e = PackageApiException.fromDio(_dio(DioExceptionType.badResponse,
          status: 404, data: {'status': false, 'message': raw}));
      expect(e.debugMessage, contains(raw));
      expect(e.debugMessage, contains('HTTP 404'));
      expect(e.userMessage, isNot(contains('/api/')));
      expect(e.userMessage, isNot(contains("Can't find")));
    });

    test('every kind has a friendly, non-empty message', () {
      for (final kind in PackageErrorKind.values) {
        final msg = PackageApiException(kind).userMessage;
        expect(msg.trim(), isNotEmpty);
        expect(msg, isNot(contains('Exception')));
      }
    });
  });

  group('PackagePricingRepo response handling', () {
    late HttpClientAdapter original;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      Global.storageServices = await StorageServices().init();
      original = PackagePricingRepo.dio.httpClientAdapter;
    });

    tearDown(() => PackagePricingRepo.dio.httpClientAdapter = original);

    Future<Object?> call(int status, Object body) async {
      PackagePricingRepo.dio.httpClientAdapter =
          _FakeAdapter(status, body is String ? body : jsonEncode(body));
      try {
        await PackagePricingRepo.getPackages();
        return null;
      } catch (e) {
        return e;
      }
    }

    test('200 + status:true parses packages', () async {
      PackagePricingRepo.dio.httpClientAdapter = _FakeAdapter(
          200,
          jsonEncode({
            'status': true,
            'data': {
              'packages': [
                {'moduleKey': 'walkie_talkie', 'title': 'Walkie-Talkie'},
              ],
            },
          }));
      final res = await PackagePricingRepo.getPackages();
      expect(res.packages.single.moduleKey, 'walkie_talkie');
    });

    test('sends GET to /api/packages without a token header when logged out',
        () async {
      final fake = _FakeAdapter(200, jsonEncode({'status': true, 'data': []}));
      PackagePricingRepo.dio.httpClientAdapter = fake;
      await PackagePricingRepo.getPackages();
      expect(fake.last!.method, 'GET');
      expect(fake.last!.uri.path, '/api/packages');
      expect(fake.last!.headers.containsKey('authorization'), isFalse);
    });

    test('404 (route missing) → notFound', () async {
      final e = await call(404,
          {'status': false, 'message': "Can't find /api/packages on the server!"});
      expect((e as PackageApiException).kind, PackageErrorKind.notFound);
    });

    test('500 → server', () async {
      final e = await call(500, {'status': false, 'message': 'boom'});
      expect((e as PackageApiException).kind, PackageErrorKind.server);
    });

    test('200 + status:false → rejected', () async {
      final e = await call(200, {'status': false, 'message': 'nope'});
      expect((e as PackageApiException).kind, PackageErrorKind.rejected);
      expect(e.debugMessage, 'nope');
    });

    test('200 with a non-object body → malformed', () async {
      final e = await call(200, [1, 2, 3]);
      expect((e as PackageApiException).kind, PackageErrorKind.malformed);
    });
  });
}
