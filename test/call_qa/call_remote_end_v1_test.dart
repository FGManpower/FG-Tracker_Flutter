// Calling module: the other side hangs up, but its socket `callEnded` is
// lost (socket reconnecting, app in background, server hiccup). Before this
// fix the call sat on "Reconnecting..." for the full 25 s give-up.
//
// Cases RE-01 ... RE-14. Pure logic with fake time; call screen behaviour
// with the real socket client against the local fake server. No WebRTC, no
// backend (FakeCallPlatform), so the logic is the same on Android and iOS.
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/call_kit_handlers.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/modules/mediaStream/Bindings/call_binding.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_connection_monitor.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_end_probe.dart';
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
    (MethodCall call) async =>
        call.method == 'activeCalls' ? <dynamic>[] : null,
  );
}

Map<String, dynamic> outgoing() => <String, dynamic>{
      'callerId': me,
      'remoteUserId': peer,
      'offer': null,
      'is_video': false,
      'callerName': 'Peer',
      'callType': 'outGoing',
    };

CallServerState st(String s, {bool ended = false}) =>
    CallServerState(status: s, hasEndedAt: ended);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------ pure rules
  group('isServerCallOver', () {
    test('RE-01 unknown (null / empty) is never "over"', () {
      expect(isServerCallOver(null, linkDown: true), isFalse);
      expect(isServerCallOver(st(''), linkDown: true), isFalse);
      expect(isServerCallOver(st('  '), linkDown: true), isFalse);
    });

    test('RE-02 hard end statuses are over, link up or down', () {
      for (final String s in <String>[
        'ended',
        'callended',
        'rejected',
        'declined',
        'cancelled',
        'canceled',
        'disconnected',
        'ENDED',
        ' Ended ',
      ]) {
        expect(isServerCallOver(st(s), linkDown: false), isTrue, reason: s);
        expect(isServerCallOver(st(s), linkDown: true), isTrue, reason: s);
      }
    });

    test('RE-03 a running call ("completed", no end time) is not over', () {
      expect(isServerCallOver(st('completed'), linkDown: true), isFalse);
      expect(isServerCallOver(st('completed'), linkDown: false), isFalse);
    });

    test('RE-04 "completed" with an end time is over', () {
      expect(isServerCallOver(st('completed', ended: true), linkDown: false),
          isTrue);
    });

    test('RE-05 "missed" never ends a HEALTHY call (server marks answered '
        'calls missed at 45 s)', () {
      expect(isServerCallOver(st('missed', ended: true), linkDown: false),
          isFalse);
      expect(isServerCallOver(st('missed'), linkDown: true), isFalse);
      expect(isServerCallOver(st('missed', ended: true), linkDown: true),
          isTrue);
    });

    test('RE-06 other statuses (ringing, accepted, ongoing) are not over', () {
      for (final String s in <String>['ringing', 'accepted', 'ongoing', 'busy']) {
        expect(isServerCallOver(st(s, ended: true), linkDown: true), isFalse,
            reason: s);
      }
    });
  });

  // ------------------------------------------------------- probe with time
  group('CallEndProbe', () {
    testWidgets('RE-07 no check before 4 s; ends once the server says so',
        (tester) async {
      int checks = 0;
      int ended = 0;
      bool answer = false;
      final p = CallEndProbe(
        check: () async {
          checks++;
          return answer;
        },
        onEnded: () => ended++,
      );
      p.start();
      await tester.pump(const Duration(seconds: 3));
      expect(checks, 0, reason: 'short blips recover on their own');
      await tester.pump(const Duration(seconds: 1));
      expect(checks, 1);
      expect(ended, 0);
      answer = true;
      await tester.pump(const Duration(seconds: 4));
      expect(checks, 2);
      expect(ended, 1);
      await tester.pump(const Duration(seconds: 20));
      expect(ended, 1, reason: 'ends exactly once');
      expect(checks, 2, reason: 'stops asking after the end');
      expect(p.isRunning, isFalse);
    });

    testWidgets('RE-08 link back (stop): no more checks', (tester) async {
      int checks = 0;
      final p = CallEndProbe(
        check: () async {
          checks++;
          return false;
        },
        onEnded: () => fail('must not end'),
      );
      p.start();
      await tester.pump(const Duration(seconds: 9));
      expect(checks, 2);
      p.stop();
      await tester.pump(const Duration(seconds: 30));
      expect(checks, 2);
      // Can run again on the next drop.
      p.start();
      await tester.pump(const Duration(seconds: 4));
      expect(checks, 3);
      p.dispose();
    });

    testWidgets('RE-09 a failing check counts as "not over"', (tester) async {
      int ended = 0;
      final p = CallEndProbe(
        check: () async => throw const SocketException('offline'),
        onEnded: () => ended++,
      );
      p.start();
      await tester.pump(const Duration(seconds: 20));
      expect(ended, 0);
      p.dispose();
    });

    testWidgets('RE-10 start twice = one probe; disposed = never again',
        (tester) async {
      int checks = 0;
      final p = CallEndProbe(
        check: () async {
          checks++;
          return false;
        },
        onEnded: () {},
      );
      p.start();
      p.start();
      await tester.pump(const Duration(seconds: 4));
      expect(checks, 1);
      p.dispose();
      p.start();
      await tester.pump(const Duration(seconds: 20));
      expect(checks, 1);
    });
  });

  // ------------------------------------------------- call screen (socket)
  group('Call screen: remote hang-up with a lost callEnded', () {
    late FakeSocketIoServer server;
    late FakeCallPlatform platform;

    List<FakeClientEvent> sent(String name) =>
        server.receivedNamed(name, nsp: nsp);

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
      mockPlugins();
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefConst.userId: me,
        PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
      });
      Global.storageServices = await StorageServices().init();
      platform = FakeCallPlatform();
      CallPlatform.instance = platform;
      CallPermissionBackend.instance = FakeCallPermissionBackend.allGranted();
      CallingController.lastEndInfo = null;
      setupCallKitHandlers();

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
      CallKitService.instance.onRemoteEndPush = null;
    });

    Future<CallingController> liveCall() async {
      Get.routing.args = outgoing();
      StreamBinding().dependencies();
      final c = Get.find<CallingController>();
      server.emit(nsp, 'callCreated', {'callId': 501, 'sessionId': 's501'});
      expect(await waitFor(() => c.callId == 501), isTrue);
      return c;
    }

    bool gone() => !Get.isRegistered<CallingController>();

    test('RE-11 link down + server "ended": the call ends in seconds, '
        'not after 25 s, and does not send endCall back', () async {
      final c = await liveCall();
      platform.serverState = st('ended', ended: true);
      c.debugLinkState(CallLinkState.connected);
      c.debugLinkState(CallLinkState.disconnected);
      expect(c.debugEndProbeRunning, isTrue);
      expect(await waitFor(gone, timeout: const Duration(seconds: 8)), isTrue);
      expect(platform.serverChecks, contains('501'));
      expect(sent('endCall'), isEmpty,
          reason: 'the other side already ended; no echo');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(platform.serviceStops, 1, reason: 'cleaned up exactly once');
    });

    test('RE-12 link down + server still running: the call stays '
        '(network blip, ICE restart can recover)', () async {
      final c = await liveCall();
      platform.serverState = st('completed');
      c.debugLinkState(CallLinkState.connected);
      c.debugLinkState(CallLinkState.disconnected);
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(platform.serverChecks, isNotEmpty);
      expect(c.isCallLive, isTrue);
      c.debugLinkState(CallLinkState.connected);
      expect(c.debugEndProbeRunning, isFalse, reason: 'recovered: stop asking');
    });

    test('RE-13 endCall push for THIS call while the link is down: ends now',
        () async {
      final c = await liveCall();
      c.debugLinkState(CallLinkState.connected);
      c.debugLinkState(CallLinkState.disconnected);
      await CallKitService.handlePush(<String, dynamic>{
        'screen_name': 'callEnded',
        'callId': '501',
        'sessionId': 's501',
        'signal_type': 'endCall',
      });
      expect(await waitFor(gone, timeout: const Duration(seconds: 3)), isTrue);
    });

    test('RE-14 endCall push for ANOTHER call or with a healthy link and a '
        'running server call: the call stays', () async {
      final c = await liveCall();
      c.debugLinkState(CallLinkState.connected);
      platform.serverState = st('completed');
      // Another (old) call.
      await CallKitService.handlePush(<String, dynamic>{
        'screen_name': 'callEnded',
        'callId': '37',
        'sessionId': 'old-37',
        'signal_type': 'endCall',
      });
      // This call, link healthy: the server is asked first and says running.
      await CallKitService.handlePush(<String, dynamic>{
        'callId': '501',
        'sessionId': 's501',
        'signal_type': 'endCall',
      });
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(platform.serverChecks, <String>['501']);
      expect(c.isCallLive, isTrue);

      // Same push once the server confirms the end: ends.
      platform.serverState = st('completed', ended: true);
      await CallKitService.handlePush(<String, dynamic>{
        'callId': '501',
        'sessionId': 's501',
        'signal_type': 'endCall',
      });
      expect(await waitFor(gone, timeout: const Duration(seconds: 3)), isTrue);
    });

    test('RE-15 signaling reconnect: server says ended, the call ends',
        () async {
      await liveCall();
      platform.serverState = st('ended', ended: true);
      await server.dropAll(); // the client reconnects by itself
      expect(await waitFor(gone, timeout: const Duration(seconds: 10)), isTrue);
    });
  });

  // -------------------------------------------- native incoming-call colours
  group('Android system incoming screen', () {
    test('RE-16 uses the app call colours, not the old blue', () {
      expect(kCallKitBackgroundColor(isVideo: false), kCallKitAudioBackground);
      expect(kCallKitBackgroundColor(isVideo: true), kCallKitVideoBackground);
      for (final String c in <String>[
        kCallKitAudioBackground,
        kCallKitVideoBackground,
        kCallKitAcceptColor,
      ]) {
        expect(RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(c), isTrue, reason: c);
        expect(c.toLowerCase(), isNot('#0955fa'));
      }
    });
  });
}
