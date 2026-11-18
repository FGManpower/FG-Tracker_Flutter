// Calling module, Phase 1 (reliability): every call starts clean.
// Bugs: docs/testing/calling/bug_tracker.md (BUG-CALL-xx). Cases: CT-xx in
// docs/testing/calling/unit_testing/unit_test_report.md.
//
// Real socket.io client (SignallingService) against a local fake server; no
// backend, no WebRTC (FakeCallPlatform.mediaEnabled = false). Pure Dart, so
// the same logic runs on Android and iOS.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/call_kit_handlers.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Model/call_model.dart';
import 'package:fgtracker/app/modules/mediaStream/Bindings/call_binding.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/incoming_call_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_foreground_service.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_socket_handlers.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat_qa/fakes/fake_socket_io_server.dart';
import 'fakes/fake_call_permissions.dart';
import 'fakes/fake_call_platform.dart';

const String me = '101';
const String peer = '202';
const String nsp = '/callSignaling';

final List<MethodCall> callkitCalls = <MethodCall>[];
List<dynamic> callkitActiveCalls = <dynamic>[];

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
      if (call.method == 'activeCalls') return callkitActiveCalls;
      return null;
    },
  );
}

Future<void> prefs() async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    PrefConst.userId: me,
    PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
  });
  Global.storageServices = await StorageServices().init();
}

Map<String, dynamic> outgoing({String remote = peer, bool video = false}) =>
    <String, dynamic>{
      'callerId': me,
      'remoteUserId': remote,
      'offer': null,
      'is_video': video,
      'callerName': 'Peer',
      'callType': 'outGoing',
    };

Map<String, dynamic> incomingFromCallKit({String session = 's9'}) =>
    incomingCallArgs(
      callerId: peer,
      callId: 9,
      sessionId: session,
      isVideo: false,
      callerName: 'Peer',
      profileImage: '',
      offer: null,
      fromCallKit: true,
    );

/// Opens a call screen the way the route does: arguments + StreamBinding.
CallingController openCall(Map<String, dynamic> args) {
  Get.routing.args = args;
  StreamBinding().dependencies();
  return Get.find<CallingController>();
}

IncomingCallModel incomingModel() => IncomingCallModel(
      callerId: peer,
      receiverId: me,
      isVideo: false,
      callerName: 'Peer',
      callerProfileImage: '',
      sdpOfferCompressed: null,
      callId: 88,
    );

List<FakeClientEvent> sent(FakeSocketIoServer s, String name) =>
    s.receivedNamed(name, nsp: nsp);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSocketIoServer server;
  late FakeCallPlatform platform;

  Future<void> connectSignaling() async {
    SignallingService.instance.init(
      websocketUrl: server.url,
      selfCallerID: me,
    );
    expect(
      await waitFor(() => SignallingService.instance.socket?.connected == true),
      isTrue,
    );
    expect(await waitFor(() => server.clientsOn(nsp) == 1), isTrue);
  }

  Future<void> baseSetUp() async {
    HttpOverrides.global = null;
    Get.reset();
    Get.testMode = true; // navigation without a navigator is a no-op
    // The overlay service sizes its bubble with ScreenUtil.
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(375, 812)),
      designSize: const Size(375, 812),
      splitScreenMode: false,
      minTextAdapt: false,
    );
    callkitCalls.clear();
    callkitActiveCalls = <dynamic>[];
    mockPlugins();
    await prefs();
    platform = FakeCallPlatform();
    CallPlatform.instance = platform;
    // Phase 2: the call screen checks permissions first; grant them here.
    CallPermissionBackend.instance = FakeCallPermissionBackend.allGranted();
  }

  void dropCallController() {
    if (Get.isRegistered<CallingController>()) {
      Get.find<CallingController>().isMinimized.value = false;
      Get.delete<CallingController>(force: true);
    }
  }

  group('with the signaling socket', () {
    setUp(() async {
      await baseSetUp();
      server = FakeSocketIoServer();
      await server.start();
      await connectSignaling();
    });

    tearDown(() async {
      dropCallController();
      SignallingService.instance.disconnect();
      // Let the client's disconnect packet arrive before the server closes.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await server.stop();
      CallPlatform.instance = CallPlatform();
      CallPermissionBackend.instance = CallPermissionBackend();
    });

    group('BUG-CALL-01 every call gets a fresh controller', () {
      test('CT-01 end, missed, rejected, remote missed: never reused',
          () async {
        // 1. Own hang-up.
        final CallingController c1 = openCall(outgoing());
        server.emit(nsp, 'callCreated', {'callId': 501, 'sessionId': 's501'});
        expect(await waitFor(() => c1.callId == 501), isTrue);
        await c1.endCall();
        expect(Get.isRegistered<CallingController>(), isFalse,
            reason: 'hang-up must release the controller');
        expect(
            await waitFor(() => sent(server, 'endCall').length == 1), isTrue);
        expect(sent(server, 'endCall').single.data['remoteUserId'], peer);

        // 2. Missed (caller timeout). Fresh instance, fresh args and flags.
        final CallingController c2 = openCall(outgoing(remote: '303'));
        expect(identical(c1, c2), isFalse);
        expect(c2.args['remoteUserId'], '303');
        expect(c2.isCallLive, isTrue);
        await c2.missedCall();
        expect(Get.isRegistered<CallingController>(), isFalse);
        expect(
            await waitFor(() => sent(server, 'missCall').length == 1), isTrue);
        expect(await waitFor(() => sent(server, 'endCall').length == 2), isTrue,
            reason: 'the 2nd call must reach the other side too');

        // 3. Rejected by the other side.
        final CallingController c3 = openCall(outgoing(remote: '404'));
        expect(identical(c2, c3), isFalse);
        server.emit(nsp, 'callRejected', {'callId': 503});
        expect(await waitFor(() => !Get.isRegistered<CallingController>()),
            isTrue);

        // 4. missedCall from the server.
        openCall(outgoing(remote: '505'));
        server.emit(nsp, 'missedCall', {'callId': 504, 'sessionId': 's504'});
        expect(await waitFor(() => !Get.isRegistered<CallingController>()),
            isTrue);
      });

      test('CT-16 a second end (e.g. system End after hang-up) sends nothing',
          () async {
        final CallingController c = openCall(outgoing());
        await c.endCall();
        await c.endCall(type: 'callkit');
        await c.missedCall();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(sent(server, 'endCall').length, 1);
        expect(sent(server, 'missCall'), isEmpty);
        expect(platform.serviceStops, 1);
      });
    });

    group('BUG-CALL-21 starting a call never kills a live minimized call', () {
      test('live minimized call is kept; a finished one is cleared', () async {
        final CallingController live = openCall(outgoing());
        live.isMinimized.value = true;

        expect(CallingController.prepareForNewCall(), isFalse);
        expect(Get.isRegistered<CallingController>(), isTrue);
        expect(identical(Get.find<CallingController>(), live), isTrue);
        expect(live.isCallLive, isTrue);
        expect(sent(server, 'endCall'), isEmpty);

        // Opening the route again (expand) reuses the same live call.
        expect(identical(openCall(outgoing()), live), isTrue);

        await live.endCall();
        expect(CallingController.prepareForNewCall(), isTrue);
      });
    });

    group('BUG-CALL-02 the current socket is always used', () {
      test('CT-02 socket re-created after the controller was built', () async {
        final CallingController c = openCall(outgoing());
        final oldSocket = SignallingService.instance.socket;

        // Login again: SignallingService disposes the socket and makes a new one.
        await connectSignaling();
        expect(
            identical(SignallingService.instance.socket, oldSocket), isFalse);
        expect(identical(c.socket, SignallingService.instance.socket), isTrue);

        await c.endCall();
        expect(await waitFor(() => sent(server, 'endCall').length == 1), isTrue,
            reason: 'endCall must go out on the NEW socket');
      });

      test('ensureConnected returns the live socket', () async {
        final s = await SignallingService.instance.ensureConnected(
          timeout: const Duration(seconds: 2),
        );
        expect(s, isNotNull);
        expect(identical(s, SignallingService.instance.socket), isTrue);
      });
    });

    group('BUG-CALL-03 global handlers survive any number of calls', () {
      test('CT-03 incoming screen + call, 5 times each', () async {
        final socket = SignallingService.instance.socket!;
        // Stand-ins for the global handlers (SignallingService / other modules).
        final Map<String, int> hits = <String, int>{};
        for (final String ev in <String>[
          'callEnded',
          'callRejected',
          'newCall'
        ]) {
          socket.on(ev, (_) => hits[ev] = (hits[ev] ?? 0) + 1);
        }

        for (int i = 0; i < 5; i++) {
          Get.routing.args = <String, dynamic>{'callDetail': incomingModel()};
          Get.put(IncomingCallController());
          Get.delete<IncomingCallController>();

          final CallingController c = openCall(outgoing());
          await c.endCall();
        }

        server.emit(nsp, 'callEnded', {'callId': 1, 'sessionId': 'x1'});
        server.emit(nsp, 'callRejected', {'callId': 1});
        server.emit(nsp, 'newCall', {'callId': 2, 'callerId': '999'});
        expect(
          await waitFor(() =>
              hits['callEnded'] == 1 &&
              hits['callRejected'] == 1 &&
              hits['newCall'] == 1),
          isTrue,
          reason: 'hits=$hits',
        );
      });

      test('CallSocketHandlers removes only its own handlers', () async {
        final socket = SignallingService.instance.socket!;
        int global = 0;
        int own = 0;
        socket.on('callEnded', (_) => global++);
        final CallSocketHandlers bag = CallSocketHandlers(() => socket);
        bag.on('callEnded', (_) => own++);
        bag.off('callEnded');
        server.emit(nsp, 'callEnded', {'callId': 3});
        expect(await waitFor(() => global == 1), isTrue);
        expect(own, 0);
        expect(bag.length, 0);
      });
    });

    group('BUG-CALL-04 in-app reject reaches the caller', () {
      test('CT-04 rejectCall payload remoteUserId = caller id', () async {
        Get.routing.args = <String, dynamic>{'callDetail': incomingModel()};
        final IncomingCallController c = Get.put(IncomingCallController());
        c.rejectCall();
        expect(await waitFor(() => sent(server, 'rejectCall').length == 1),
            isTrue);
        final dynamic data = sent(server, 'rejectCall').single.data;
        expect(data['remoteUserId'], peer);
        expect(data['callId'], 88);
        Get.delete<IncomingCallController>();
      });
    });

    group('BUG-CALL-09 system End always ends the call', () {
      test('CT-11 End from CallKit while still connecting', () async {
        final CallingController c = openCall(incomingFromCallKit());
        expect(c.callTimer, isNull, reason: 'still connecting');
        await handleSystemEndCall(callId: '9', uuid: 's9');
        expect(Get.isRegistered<CallingController>(), isFalse);
        expect(
            await waitFor(() => sent(server, 'endCall').length == 1), isTrue);
        expect(sent(server, 'endCall').single.data['remoteUserId'], peer);
      });
    });

    group('BUG-CALL-14 one incoming argument shape', () {
      test('remoteUserId is the caller, both avatar keys present', () {
        final Map<String, dynamic> a = incomingCallArgs(
          callerId: peer,
          callId: 5,
          isVideo: true,
          callerName: 'Peer',
          profileImage: 'p.png',
          offer: null,
          fromCallKit: false,
        );
        expect(a['remoteUserId'], peer);
        expect(a['callerId'], peer);
        expect(a['profileImage'], 'p.png');
        expect(a['callerProfile'], 'p.png');
        expect(a['callType'], 'Incoming');
        expect(a.containsKey('sessionId'), isFalse);
      });
    });

    group('BUG-CALL-15 foreground service from the first second', () {
      test('started in onInit (voice / video), stopped once at the end',
          () async {
        final CallingController voice = openCall(outgoing());
        expect(platform.serviceStarts, <bool>[false]);
        await voice.endCall();
        expect(platform.serviceStops, 1);

        openCall(outgoing(video: true));
        expect(platform.serviceStarts, <bool>[false, true]);
      });

      test(
          'service types: microphone (+camera only when granted), no phoneCall',
          () {
        expect(callForegroundServiceTypes(video: false, cameraGranted: true),
            <ForegroundServiceTypes>[ForegroundServiceTypes.microphone]);
        expect(
            callForegroundServiceTypes(video: true, cameraGranted: true),
            <ForegroundServiceTypes>[
              ForegroundServiceTypes.microphone,
              ForegroundServiceTypes.camera,
            ]);
        expect(callForegroundServiceTypes(video: true, cameraGranted: false),
            <ForegroundServiceTypes>[ForegroundServiceTypes.microphone]);
      });
    });

    group('BUG-CALL-08 one ring timeout', () {
      test('CT-10 caller timer = CallKit duration', () async {
        final CallingController c = openCall(outgoing());
        expect(c.missCallDurationSeconds.value, kCallRingTimeout.inSeconds);

        await CallKitService.showIncoming(
          sessionId: 'ring-1',
          callId: '61',
          callerName: 'Peer',
          isVideo: false,
        );
        final MethodCall show = callkitCalls
            .firstWhere((MethodCall m) => m.method == 'showCallkitIncoming');
        final int duration =
            ((show.arguments as Map)['duration'] as num).toInt();
        expect(duration, c.missCallDurationSeconds.value * 1000,
            reason: 'callee may not ring longer or shorter than the caller');
        await c.endCall();
      });
    });

    group('BUG-CALL-10 / 24 stale ringing calls', () {
      MockClient api(int code, Object body, {Duration delay = Duration.zero}) =>
          MockClient((http.Request r) async {
            await Future<void>.delayed(delay);
            expect(r.url.path.contains('//'), isFalse,
                reason: r.url.toString());
            expect(r.url.path, endsWith('/getCallDetail'));
            expect(r.url.queryParameters['callId'], '55');
            return http.Response(jsonEncode(body), code);
          });

      test('CT-12 getCallStatus is wired to the server status', () async {
        setupCallKitHandlers();
        final String? status = await http.runWithClient(
          () => CallKitService.instance.getCallStatus!('55'),
          () => api(200, {
            'callDetail': {'status': 'Ended'},
          }),
        );
        expect(status, 'ended');
      });

      test('unknown (error / non-200 / timeout) is null, never "ended"',
          () async {
        expect(
          await http.runWithClient(
            () => CallRepo.fetchCallStatus('55'),
            () => api(500, {'x': 1}),
          ),
          isNull,
        );
        expect(
          await http.runWithClient(
            () => CallRepo.fetchCallStatus('55',
                timeout: const Duration(milliseconds: 50)),
            () => api(
                200,
                {
                  'callDetail': {'status': 'ended'},
                },
                delay: const Duration(milliseconds: 300)),
          ),
          isNull,
        );
      });

      test('restoreActiveCalls dismisses an ended call, keeps it when unknown',
          () async {
        setupCallKitHandlers();
        callkitActiveCalls = <dynamic>[
          <String, dynamic>{
            'id': 's55',
            'isAccepted': false,
            'extra': <String, dynamic>{'callId': '55', 'session_id': 's55'},
          },
        ];

        await http.runWithClient(
          () => CallKitService.instance.restoreActiveCalls(),
          () => api(500, {}),
        );
        expect(callkitCalls.where((MethodCall m) => m.method == 'endCall'),
            isEmpty,
            reason: 'offline must not dismiss a real ringing call');

        await http.runWithClient(
          () => CallKitService.instance.restoreActiveCalls(),
          () => api(200, {
            'callDetail': {'status': 'missed'},
          }),
        );
        expect(callkitCalls.where((MethodCall m) => m.method == 'endCall'),
            isNotEmpty);
      });
    });

    group('BUG-CALL-18 no side effects in getters, no prompts in a call', () {
      test('formattedDuration does not touch the ringtone', () async {
        final CallingController c = openCall(outgoing());
        platform.log.clear();
        expect(c.formattedDuration, '00:00');
        expect(platform.log, isEmpty);
        await c.endCall();
      });

      test('tracking keep-alive goes through the no-prompt path once',
          () async {
        final CallingController c = openCall(outgoing());
        expect(platform.trackingKeepAlive, 1);
        await c.endCall();
      });
    });
  }); // with the signaling socket

  group('BUG-CALL-22 overlay End keeps the user on their page', () {
    setUp(() async {
      await baseSetUp();
      Get.testMode = false; // real navigator below
      SignallingService.instance.disconnect(); // navigation only, no socket
    });
    tearDown(() {
      dropCallController();
      CallPlatform.instance = CallPlatform();
      CallPermissionBackend.instance = CallPermissionBackend();
    });

    testWidgets('end a minimized call while on another page', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: <GetPage<dynamic>>[
            GetPage<dynamic>(
              name: '/',
              page: () => const Scaffold(body: Text('home page')),
            ),
            GetPage<dynamic>(
              name: '/chat',
              page: () => const Scaffold(body: Text('chat page')),
            ),
            GetPage<dynamic>(
              name: Routes.callScreen,
              page: () => const Scaffold(body: Text('call page')),
              binding: StreamBinding(),
            ),
          ],
        ),
      );

      Get.toNamed(Routes.callScreen, arguments: outgoing());
      await tester.pumpAndSettle();
      final CallingController c = Get.find<CallingController>();

      // Minimize (what minimizeCall does, without the overlay widget).
      c.isMinimized.value = true;
      Get.back();
      await tester.pumpAndSettle();
      Get.toNamed('/chat');
      await tester.pumpAndSettle();
      expect(find.text('chat page'), findsOneWidget);

      unawaited(c.endCall(type: 'UserEndedFromOverlay'));
      await tester.pumpAndSettle();

      expect(find.text('chat page'), findsOneWidget,
          reason: 'ending from the overlay must not pop the chat page');
      expect(Get.isRegistered<CallingController>(), isFalse);
      // Phase 3: Recent calls are refreshed 2 s after the call ends.
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
