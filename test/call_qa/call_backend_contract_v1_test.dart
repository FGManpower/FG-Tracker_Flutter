// Calling module: app side of the backend answers (doc 02 §8.6).
// B-01 socket token on the /callSignaling handshake, B-13 native decline URL.
import 'dart:io';

import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('B-01 /callSignaling handshake', () {
    test('sends the token in auth and keeps callerId for old servers', () {
      final o = callSocketOptions(selfCallerID: '202', authToken: 'jwt.abc');
      expect(o['auth'], {'token': 'jwt.abc'});
      expect(o['query'], {'callerId': '202'});
      expect(o['transports'], ['websocket']);
    });

    test('token is never put in the URL query', () {
      final o = callSocketOptions(selfCallerID: '202', authToken: 'jwt.abc');
      expect((o['query'] as Map).containsKey('token'), isFalse);
    });

    test('no token (logged out, tests) -> old handshake, no auth key', () {
      for (final t in [null, '', '   ', 'null']) {
        final o = callSocketOptions(selfCallerID: '202', authToken: t);
        expect(o.containsKey('auth'), isFalse, reason: 'token=$t');
        expect(o['query'], {'callerId': '202'});
      }
    });
  });

  group('B-13 native decline API', () {
    const legacy = 'http://fgtracker.in:3000';
    const prod = 'https://api.fgtracker.fgmanpower.co.in/api';

    test('Android CallDeclineReceiver uses the HTTPS production host', () {
      final src = File(
        'android/app/src/main/kotlin/com/example/fgtracker/CallDeclineReceiver.kt',
      ).readAsStringSync();
      expect(src, contains('BASE_URL = "$prod"'));
      expect(src, isNot(contains('BASE_URL = "$legacy')));
      expect(src, contains('reason=declined'));
    });

    test('iOS AppDelegate uses the HTTPS production host', () {
      final src = File('ios/Runner/AppDelegate.swift').readAsStringSync();
      expect(src, contains('private let apiBaseUrl = "$prod"'));
      expect(src, isNot(contains('private let apiBaseUrl = "$legacy')));
      expect(src, contains('name: "reason", value: "declined"'));
    });
  });
}
