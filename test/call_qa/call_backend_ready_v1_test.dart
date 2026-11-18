// Calling module: app side of the backend request "1:1 calling – backend
// changes" (doc 02 §B). The app must work with TODAY's backend and with the
// agreed one: new event names (callCancelled / call_cancelled, callAccepted)
// and server ring deadlines (expiresAt). Cases BR-01 ... BR-14.
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/modules/mediaStream/Bindings/call_binding.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_end_probe.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_events.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/turn_credentials.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat_qa/fakes/fake_socket_io_server.dart';
import 'fakes/fake_call_permissions.dart';
import 'fakes/fake_call_platform.dart';

const String me = '101';
const String peer = '202';
const String nsp = '/callSignaling';

final List<MethodCall> callkitCalls = <MethodCall>[];

void mockPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('PonnamKarthik/fluttertoast'),
    (_) async => true,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('flutter_ringtone_player'),
    (_) async => null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('flutter_callkit_incoming'),
    (MethodCall call) async {
      callkitCalls.add(call);
      return call.method == 'activeCalls' ? <dynamic>[] : null;
    },
  );
}

List<MethodCall> shown() =>
    callkitCalls.where((c) => c.method == 'showCallkitIncoming').toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------ names
  group('event names (today + agreed)', () {
    test('BR-01 today\'s and the agreed end names are recognised', () {
      for (final String s in <String>[
        'endCall',
        'callEnded',
        'cancelCall',
        'callRejected',
        'missedCall',
        'callCancelled',
        'call_cancelled',
      ]) {
        expect(isCallEndSignal(s), isTrue, reason: s);
      }
      expect(isCallEndSignal('startCall'), isFalse);
      expect(isCallEndSignal('upgradeToVideo'), isFalse);
      expect(isCallEndSignal(null), isFalse);
    });

    test('BR-02 a push end signal is read from signal_type, action or type',
        () {
      expect(endSignalOf(<String, dynamic>{'signal_type': 'endCall'}),
          'endCall');
      expect(endSignalOf(<String, dynamic>{'type': 'call_cancelled'}),
          'call_cancelled');
      expect(endSignalOf(<String, dynamic>{'action': 'callCancelled'}),
          'callCancelled');
    });

    test('BR-03 "type" that is not an end signal is ignored (video, audio)',
        () {
      expect(endSignalOf(<String, dynamic>{'type': 'video'}), isNull);
      expect(endSignalOf(<String, dynamic>{'type': 'startCall'}), isNull);
    });

    test('BR-04 a push saying "missed" / "rejected" never counts as an end '
        'on its own (server marked a running call missed)', () {
      expect(endSignalOf(<String, dynamic>{'signal_type': 'missedCall'}),
          isNull);
      expect(endSignalOf(<String, dynamic>{'signal_type': 'callRejected'}),
          isNull);
    });
  });

  // ------------------------------------------------------------ ring time
  group('server ring deadline (expiresAt)', () {
    final DateTime now = DateTime.utc(2026, 11, 18, 8, 0, 0);

    test('BR-05 no / bad timestamp: app default (null)', () {
      expect(remainingRingTime(expiresAt: null, now: now), isNull);
      expect(remainingRingTime(expiresAt: '', now: now), isNull);
      expect(remainingRingTime(expiresAt: 'not a date', now: now), isNull);
      expect(remainingRingTime(expiresAt: 0, now: now), isNull);
    });

    test('BR-06 ISO, epoch seconds and epoch ms all parse', () {
      final DateTime exp = now.add(const Duration(seconds: 30));
      for (final dynamic v in <dynamic>[
        exp.toIso8601String(),
        exp.millisecondsSinceEpoch ~/ 1000,
        exp.millisecondsSinceEpoch,
        '${exp.millisecondsSinceEpoch}',
      ]) {
        expect(remainingRingTime(expiresAt: v, now: now),
            const Duration(seconds: 30),
            reason: '$v');
      }
    });

    test('BR-07 time left is clamped to 10 s .. 45 s', () {
      expect(
          remainingRingTime(
              expiresAt: now.add(const Duration(seconds: 3)), now: now),
          const Duration(seconds: 10));
      expect(
          remainingRingTime(
              expiresAt: now.add(const Duration(minutes: 5)), now: now),
          const Duration(seconds: 45));
    });

    test('BR-08 a few seconds past expiry (clock skew) still rings; '
        'a minute past is stale', () {
      expect(
          remainingRingTime(
              expiresAt: now.subtract(const Duration(seconds: 20)), now: now),
          const Duration(seconds: 10),
          reason: 'phone clock may run ahead: never drop a real call');
      expect(
          remainingRingTime(
              expiresAt: now.subtract(const Duration(seconds: 61)), now: now),
          Duration.zero);
    });
  });

  // ------------------------------------------------- system incoming UI
  group('incoming call UI with expiresAt', () {
    setUp(() {
      callkitCalls.clear();
      mockPlugins();
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('BR-09 a long-expired push does not ring', () async {
      await CallKitService.showIncoming(
        sessionId: 'br09',
        callId: '9001',
        callerName: 'Peer',
        isVideo: false,
        expiresAt: DateTime.now()
            .toUtc()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
      );
      expect(shown(), isEmpty);
    });

    test('BR-10 rings only for the time left', () async {
      await CallKitService.showIncoming(
        sessionId: 'br10',
        callId: '9002',
        callerName: 'Peer',
        isVideo: false,
        extra: <String, dynamic>{
          'expiresAt': DateTime.now()
              .toUtc()
              .add(const Duration(seconds: 20))
              .toIso8601String(),
        },
      );
      expect(shown(), hasLength(1));
      final int duration =
          ((shown().single.arguments as Map)['duration'] as num).toInt();
      expect(duration, inInclusiveRange(18000, 20000));
    });

    test('BR-11 no timestamps: today\'s 45 s', () async {
      await CallKitService.showIncoming(
        sessionId: 'br11',
        callId: '9003',
        callerName: 'Peer',
        isVideo: true,
      );
      final int duration =
          ((shown().single.arguments as Map)['duration'] as num).toInt();
      expect(duration, kCallRingTimeout.inMilliseconds);
    });

    test('BR-12 push type "call_cancelled" stops the ringing', () async {
      final bool handled = await CallKitService.handlePush(<String, dynamic>{
        'type': 'call_cancelled',
        'callId': '9004',
        'sessionId': 'br12',
      });
      expect(handled, isTrue);
      expect(
        callkitCalls.map((c) => c.method),
        anyOf(contains('endCall'), contains('endAllCalls'),
            contains('hideCallkitIncoming')),
      );
    });
  });

  // ------------------------------------------------- call screen (socket)
  group('call screen with the agreed events', () {
    late FakeSocketIoServer server;
    late FakeCallPlatform platform;

    setUp(() async {
      HttpOverrides.global = null;
      Get.reset();
      Get.testMode = true;
      ScreenUtil.configure(
        data: const MediaQueryData(size: Size(375, 812)),
        designSize: const Size(375, 812),
        splitScreenMode: false,
        minTextAdapt: false,
      );
      callkitCalls.clear();
      mockPlugins();
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefConst.userId: me,
        PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
      });
      Global.storageServices = await StorageServices().init();
      platform = FakeCallPlatform();
      CallPlatform.instance = platform;
      CallPermissionBackend.instance = FakeCallPermissionBackend.allGranted();
      server = FakeSocketIoServer();
      await server.start();
      SignallingService.instance
          .init(websocketUrl: server.url, selfCallerID: me);
      expect(await waitFor(() => server.clientsOn(nsp) == 1), isTrue);
    });

    tearDown(() async {
      if (Get.isRegistered<CallingController>()) {
        Get.find<CallingController>().isMinimized.value = false;
        Get.delete<CallingController>(force: true);
      }
      SignallingService.instance.disconnect();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await server.stop();
      CallPlatform.instance = CallPlatform();
      CallPermissionBackend.instance = CallPermissionBackend();
    });

    CallingController open(Map<String, dynamic> args) {
      Get.routing.args = args;
      StreamBinding().dependencies();
      return Get.find<CallingController>();
    }

    Future<CallingController> outgoingCall() async {
      final c = open(<String, dynamic>{
        'callerId': me,
        'remoteUserId': peer,
        'offer': null,
        'is_video': false,
        'callerName': 'Peer',
        'callType': 'outGoing',
      });
      server.emit(nsp, 'callCreated', {'callId': 601, 'sessionId': 's601'});
      expect(await waitFor(() => c.callId == 601), isTrue);
      return c;
    }

    bool gone() => !Get.isRegistered<CallingController>();

    test('BR-13 callAccepted stops the 45 s no-answer timer', () async {
      final c = await outgoingCall();
      c.startMissedCallTimer(); // the media path (skipped in tests) starts it
      expect(c.missedCallTimer, isNotNull);
      server.emit(nsp, 'callAccepted', {'callId': 601, 'sessionId': 's601'});
      expect(await waitFor(() => c.missedCallTimer == null), isTrue);
      expect(c.callStatus.value, 'Connecting');
      expect(c.isCallLive, isTrue);
    });

    test('BR-14 callAccepted for ANOTHER call changes nothing', () async {
      final c = await outgoingCall();
      c.startMissedCallTimer(); // the media path (skipped in tests) starts it
      expect(c.missedCallTimer, isNotNull);
      server.emit(nsp, 'callAccepted', {'callId': 999, 'sessionId': 'x'});
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(c.missedCallTimer, isNotNull);
    });

    test('BR-15 callee: callCancelled before the answer closes the call, '
        'nothing sent back', () async {
      final c = open(incomingCallArgs(
        callerId: peer,
        callId: 602,
        sessionId: 's602',
        isVideo: false,
        callerName: 'Peer',
        profileImage: '',
        offer: null,
        fromCallKit: true,
      ));
      expect(c.isCallLive, isTrue);
      server.emit(nsp, 'callCancelled',
          {'callId': 602, 'sessionId': 's602', 'reason': 'timeout'});
      expect(await waitFor(gone), isTrue);
      expect(server.receivedNamed('endCall', nsp: nsp), isEmpty);
    });

    test('BR-16 call_cancelled for another call is ignored', () async {
      final c = await outgoingCall();
      server.emit(nsp, 'call_cancelled', {'callId': 777, 'sessionId': 'old'});
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(c.isCallLive, isTrue);
    });

    // ---- backend reply (Nov 2026): events now go to BOTH sides
    test('BR-17 missedCall for ANOTHER call is ignored (sent to both sides)',
        () async {
      final c = await outgoingCall();
      server.emit(nsp, 'missedCall',
          {'callId': 555, 'sessionId': 'old', 'reason': 'timeout'});
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(c.isCallLive, isTrue);
    });

    test('BR-18 server ring timeout (missedCall) shows "No answer" to the '
        'caller', () async {
      await outgoingCall();
      CallingController.lastEndInfo = null;
      server.emit(nsp, 'missedCall',
          {'callId': 601, 'sessionId': 's601', 'reason': 'timeout'});
      expect(await waitFor(gone), isTrue);
      expect(CallingController.lastEndInfo?.outcome, CallEndOutcome.noAnswer);
    });

    test('BR-19 rejoinCall reply callStatus "connected": "Connecting", '
        'never the raw word', () async {
      final c = await outgoingCall();
      c.startMissedCallTimer();
      server.emit(nsp, 'callStatus',
          {'callId': 601, 'sessionId': 's601', 'status': 'connected'});
      expect(await waitFor(() => c.callStatus.value == 'Connecting'), isTrue);
      expect(c.missedCallTimer, isNull);
      expect(c.isCallLive, isTrue);
    });

    test('BR-20 callStatus "ended" for ANOTHER call is ignored; for this '
        'call it ends', () async {
      final c = await outgoingCall();
      server.emit(nsp, 'callStatus',
          {'callId': 9, 'sessionId': 'old', 'status': 'ended'});
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(c.isCallLive, isTrue);
      server.emit(nsp, 'callStatus',
          {'callId': 601, 'sessionId': 's601', 'status': 'ended'});
      expect(await waitFor(gone), isTrue);
    });

    test('BR-21 rejoinCall reply callEnded (call already over) ends it',
        () async {
      await outgoingCall();
      server.emit(nsp, 'callEnded',
          {'callId': 601, 'sessionId': 's601', 'status': 'ended'});
      expect(await waitFor(gone), isTrue);
    });
  });

  group('backend payloads', () {
    test('BR-22 callRejected reasons map to the right end screen', () {
      expect(rejectOutcome({'reason': 'busy'}), CallEndOutcome.busy);
      expect(rejectOutcome({'reason': 'timeout'}), CallEndOutcome.noAnswer);
      expect(rejectOutcome({'reason': 'declined'}), CallEndOutcome.declined);
      expect(rejectOutcome({'reason': 'permission_denied'}),
          CallEndOutcome.unavailable);
      expect(rejectOutcome({'reason': 'failed'}), CallEndOutcome.unavailable);
      expect(rejectOutcome(null), CallEndOutcome.declined);
    });

    test('BR-23 the backend TURN response (as sent) gives a relay server',
        () {
      final parsed = TurnCredentialService.parse(<String, dynamic>{
        'status': true,
        'urls': <String>[
          'turn:sfu.fgtracker.fgmanpower.co.in:3478?transport=udp',
          'turn:sfu.fgtracker.fgmanpower.co.in:3478?transport=tcp',
          'turns:sfu.fgtracker.fgmanpower.co.in:443?transport=tcp',
        ],
        'username': '1731950000:42',
        'credential': 'c2VjcmV0',
        'ttl': 86400,
      });
      expect(parsed, isNotNull);
      final Map<String, dynamic> turn = parsed!.servers.last;
      expect(turn['urls'], hasLength(3));
      expect((turn['urls'] as List).last, startsWith('turns:'),
          reason: 'TURN over TLS 443 for networks that block 3478');
      expect(turn['username'], '1731950000:42');
      expect(parsed.ttl, const Duration(seconds: 86400));
    });

    test('BR-24 server statuses: "accepted" running, "ended" over, '
        '"missed" only when the link is down', () {
      expect(
          isServerCallOver(const CallServerState(status: 'accepted'),
              linkDown: true),
          isFalse);
      expect(
          isServerCallOver(
              const CallServerState(status: 'ended', hasEndedAt: true),
              linkDown: false),
          isTrue);
      expect(
          isServerCallOver(
              const CallServerState(status: 'missed', hasEndedAt: true),
              linkDown: false),
          isFalse);
    });
  });
}
