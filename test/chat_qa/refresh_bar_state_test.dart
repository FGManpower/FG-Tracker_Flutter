// RefreshBarState truth table (F-1.2.9): when "Couldn't refresh · Retry"
// shows on the chat list and the chat screens.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final timeout = TimeoutException('x');
  final offline = HttpGetException('offline',
      dioType: DioExceptionType.connectionError);
  final server5xx = HttpGetException('down',
      dioType: DioExceptionType.badResponse, statusCode: 503);
  final notFound = HttpGetException('nf',
      dioType: DioExceptionType.badResponse, statusCode: 404);
  final unauthorized = HttpGetException('401',
      dioType: DioExceptionType.badResponse, statusCode: 401);
  final parseBug = TypeError();

  group('isStaleDataFailure', () {
    test('timeout, connection error, 5xx, status:false count', () {
      expect(RefreshBarState.isStaleDataFailure(timeout), isTrue);
      expect(RefreshBarState.isStaleDataFailure(offline), isTrue);
      expect(RefreshBarState.isStaleDataFailure(server5xx), isTrue);
      expect(RefreshBarState.isStaleDataFailure(ServerAnswerFailure('no')),
          isTrue);
      expect(
          RefreshBarState.isStaleDataFailure(HttpGetException('x',
              dioType: DioExceptionType.receiveTimeout)),
          isTrue);
    });
    test('4xx, 401 and parse / processing errors do not', () {
      expect(RefreshBarState.isStaleDataFailure(notFound), isFalse);
      expect(RefreshBarState.isStaleDataFailure(unauthorized), isFalse);
      expect(RefreshBarState.isStaleDataFailure(parseBug), isFalse);
      expect(RefreshBarState.isStaleDataFailure(StateError('x')), isFalse);
    });
    test('HttpGetException keeps the old message (toString)', () {
      expect(offline.toString(), 'offline');
    });
  });

  group('failure()', () {
    late RefreshBarState s;
    final changes = <bool>[];
    setUp(() {
      changes.clear();
      s = RefreshBarState(onChanged: (v, _) => changes.add(v));
    });

    RefreshBarAction fail(Object e,
            {bool fg = true, bool data = true, bool user = false, int? at}) =>
        s.failure(
            error: e,
            foreground: fg,
            hasData: data,
            userRetry: user,
            attempt: at ?? s.startAttempt());

    test('data + foreground: 1st failure quiet retry, 2nd shows the bar', () {
      expect(fail(offline), RefreshBarAction.quietRetry);
      expect(s.visible, isFalse);
      expect(fail(offline), RefreshBarAction.showBar);
      expect(s.visible, isTrue);
      expect(changes, [true]);
    });

    test('empty screen: full error at once (any error)', () {
      expect(fail(offline, data: false), RefreshBarAction.fullError);
      expect(s.visible, isTrue);
      s.reset();
      expect(fail(parseBug, data: false), RefreshBarAction.fullError);
    });

    test('background failures never raise it', () {
      expect(fail(offline, fg: false), RefreshBarAction.none);
      expect(fail(offline, fg: false), RefreshBarAction.none);
      expect(s.visible, isFalse);
    });

    test('a 4xx / parse error with data never raises it', () {
      expect(fail(notFound), RefreshBarAction.none);
      expect(fail(parseBug), RefreshBarAction.none);
      expect(fail(unauthorized), RefreshBarAction.none);
      expect(s.visible, isFalse);
    });

    test('after a success, a foreground failure is silent', () {
      s.success('loaded');
      expect(fail(offline), RefreshBarAction.none);
      expect(fail(offline), RefreshBarAction.none);
      expect(s.visible, isFalse);
    });

    test('user retry that fails shows the bar at once', () {
      s.success('loaded');
      s.retrying();
      expect(fail(timeout, user: true), RefreshBarAction.showBar);
      expect(s.visible, isTrue);
    });

    test('the same attempt counts once (join timeout + API failure)', () {
      final at = s.startAttempt();
      expect(fail(offline, at: at), RefreshBarAction.quietRetry);
      expect(fail(TimeoutException('join'), at: at), RefreshBarAction.none);
      expect(s.visible, isFalse);
    });

    test('any success clears the bar', () {
      fail(offline);
      fail(offline);
      expect(s.visible, isTrue);
      s.success('incremental sync');
      expect(s.visible, isFalse);
      expect(changes, [true, false]);
      expect(s.loadedOnce, isTrue);
    });

    test('reset clears everything (logout / Back)', () {
      fail(offline);
      fail(offline);
      s.reset();
      expect(s.visible, isFalse);
      expect(s.loadedOnce, isFalse);
      expect(fail(offline), RefreshBarAction.quietRetry);
    });
  });

  group('softTimeout', () {
    test('fires once after the timeout but still returns a late answer',
        () async {
      var fired = 0;
      final late = Completer<int>();
      final f = ChatScreenRules.softTimeout(late.future,
          timeout: const Duration(milliseconds: 20), onSoftTimeout: () => fired++);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(fired, 1);
      late.complete(7);
      expect(await f, 7);
    });
    test('does not fire when the answer is in time', () async {
      var fired = 0;
      final v = await ChatScreenRules.softTimeout(Future.value(3),
          timeout: const Duration(milliseconds: 50), onSoftTimeout: () => fired++);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(v, 3);
      expect(fired, 0);
    });
  });
}
