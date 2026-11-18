// Calling module, Phase 2: permissions on the calling screen (P-01 … P-12).
// Cases PM-xx in docs/testing/calling/unit_testing/unit_test_report.md.
//
// CallPermissionPolicy is pure Dart; the flow runs against a scriptable
// device (FakeCallPermissionBackend) and sheet (FakeCallPermissionUi).
// Controller cases use the real socket client against the local fake server.
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/modules/call/widget/call_ring_readiness_banner.dart';
import 'package:fgtracker/app/modules/mediaStream/Bindings/call_binding.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_permission_sheet.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat_qa/fakes/fake_socket_io_server.dart';
import 'fakes/fake_call_permissions.dart';
import 'fakes/fake_call_platform.dart';

const String me = '101';
const String peer = '202';
const String nsp = '/callSignaling';

const CallPermStatus G = CallPermStatus.granted;
const CallPermStatus A = CallPermStatus.canAsk;
const CallPermStatus B = CallPermStatus.blocked;

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

FakeCallPermissionBackend device(Map<Permission, CallPermStatus> s) =>
    FakeCallPermissionBackend(statuses: Map<Permission, CallPermStatus>.of(s));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> baseSetUp() async {
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
    callkitActiveCalls = <dynamic>[];
    mockPlugins();
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefConst.userId: me,
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
    });
    Global.storageServices = await StorageServices().init();
  }

  tearDown(() {
    CallPermissionBackend.instance = CallPermissionBackend();
    CallPermissionUi.instance = null;
    CallPlatform.instance = CallPlatform();
  });

  // ---------------------------------------------------------------- policy
  group('CallPermissionPolicy (pure decision table)', () {
    CallPermStep d(CallPermStatus mic, CallPermStatus cam,
            {bool video = false,
            bool incoming = false,
            bool micAsked = false,
            bool camAsked = false}) =>
        CallPermissionPolicy.decide(
          mic: mic,
          camera: cam,
          video: video,
          incoming: incoming,
          micAsked: micAsked,
          cameraAsked: camAsked,
        );

    test('outgoing', () {
      expect(d(G, A), CallPermStep.start); // voice: camera not needed
      expect(d(A, G), CallPermStep.askMic); // P-01
      expect(d(A, G, micAsked: true), CallPermStep.askMic); // P-02
      expect(d(B, G), CallPermStep.micSettings); // P-03
      expect(d(G, G, video: true), CallPermStep.start);
      expect(d(G, A, video: true), CallPermStep.askCamera);
      expect(d(G, A, video: true, camAsked: true),
          CallPermStep.voiceOrSettings); // P-04 after a refusal
      expect(d(G, B, video: true), CallPermStep.voiceOrSettings); // P-04
    });

    test('incoming', () {
      expect(d(A, G, incoming: true), CallPermStep.askMic); // P-05
      expect(d(A, G, incoming: true, micAsked: true), CallPermStep.fail);
      expect(d(B, G, incoming: true), CallPermStep.micSettings);
      expect(d(G, B, video: true, incoming: true),
          CallPermStep.startCameraOff); // P-06
      expect(d(G, A, video: true, incoming: true), CallPermStep.askCamera);
      expect(d(G, A, video: true, incoming: true, camAsked: true),
          CallPermStep.startCameraOff);
    });

    test('camera during a call (P-07)', () {
      expect(CallPermissionPolicy.decideCameraMidCall(camera: G),
          CallPermStep.start);
      expect(CallPermissionPolicy.decideCameraMidCall(camera: A),
          CallPermStep.askCamera);
      expect(
          CallPermissionPolicy.decideCameraMidCall(
              camera: A, cameraAsked: true),
          CallPermStep.voiceOrSettings);
      expect(CallPermissionPolicy.decideCameraMidCall(camera: B),
          CallPermStep.voiceOrSettings);
    });
  });

  // ------------------------------------------------------------ flow: P-xx
  group('CallPermissionFlow', () {
    setUp(baseSetUp);

    test('PM-01 mic never asked: explain, ask, start only after grant',
        () async {
      final b = device({Permission.microphone: A})
        ..onRequest[Permission.microphone] = G;
      final ui = FakeCallPermissionUi([CallPermChoice.allow]);
      final r = await CallPermissionFlow(backend: b, ui: ui)
          .beforeCall(video: false, incoming: false);
      expect(ui.shown, [CallPermSheet.micExplain]);
      expect(b.requests, [Permission.microphone]);
      expect(r.proceed, isTrue);
    });

    test('PM-01b "Not now" on the explainer: no system dialog, no call',
        () async {
      final b = device({Permission.microphone: A});
      final ui = FakeCallPermissionUi([CallPermChoice.cancel]);
      final r = await CallPermissionFlow(backend: b, ui: ui)
          .beforeCall(video: false, incoming: false);
      expect(r.proceed, isFalse);
      expect(b.requests, isEmpty);
    });

    test('PM-02 mic denied: sheet with Allow again; cancel = no call',
        () async {
      final b = device({Permission.microphone: A}); // dialog keeps denying
      final ui = FakeCallPermissionUi(
          [CallPermChoice.allow, CallPermChoice.cancel]);
      final r = await CallPermissionFlow(backend: b, ui: ui)
          .beforeCall(video: false, incoming: false);
      expect(ui.shown, [CallPermSheet.micExplain, CallPermSheet.micExplain]);
      expect(b.requests, [Permission.microphone]);
      expect(r.proceed, isFalse);
    });

    test('PM-03 / PM-12 mic blocked: Settings, back with mic = call goes on',
        () async {
      final b = device({Permission.microphone: B})
        ..afterSettings[Permission.microphone] = G;
      final ui = FakeCallPermissionUi([CallPermChoice.openSettings]);
      final r = await CallPermissionFlow(backend: b, ui: ui)
          .beforeCall(video: false, incoming: false);
      expect(ui.shown, [CallPermSheet.micBlocked], reason: 'one tap only');
      expect(b.settingsOpened, 1);
      expect(b.resumes, 1, reason: 're-checked after coming back');
      expect(r.proceed, isTrue);
    });

    test('PM-04 video, camera blocked: "Start voice call instead"', () async {
      final b = device({
        Permission.microphone: G,
        Permission.camera: B,
      });
      final ui = FakeCallPermissionUi([CallPermChoice.voiceInstead]);
      final r = await CallPermissionFlow(backend: b, ui: ui)
          .beforeCall(video: true, incoming: false);
      expect(ui.shown, [CallPermSheet.cameraBlocked]);
      expect(r.proceed, isTrue);
      expect(r.video, isFalse);
    });

    test('PM-04b camera refused in the dialog -> same choice', () async {
      final b = device({Permission.microphone: G, Permission.camera: A});
      final ui = FakeCallPermissionUi([CallPermChoice.cancel]);
      final r = await CallPermissionFlow(backend: b, ui: ui)
          .beforeCall(video: true, incoming: false);
      expect(b.requests, [Permission.camera]);
      expect(ui.shown, [CallPermSheet.cameraBlocked]);
      expect(r.proceed, isFalse);
    });

    test('PM-05 accept, mic refused: one dialog, no sheet, stop', () async {
      final b = device({Permission.microphone: A}); // stays denied
      final ui = FakeCallPermissionUi();
      final r = await CallPermissionFlow(backend: b, ui: ui)
          .beforeCall(video: false, incoming: true);
      expect(b.requests, [Permission.microphone]);
      expect(ui.shown, isEmpty);
      expect(r.proceed, isFalse);
    });

    test('PM-05b new user (only location + notification granted) answers on '
        'a locked iPhone, the mic prompt never shows: the call stops after '
        'the limit instead of hanging on "Connecting"', () async {
      final Duration old = CallPermissionFlow.incomingMicAskTimeout;
      CallPermissionFlow.incomingMicAskTimeout =
          const Duration(milliseconds: 200);
      addTearDown(() => CallPermissionFlow.incomingMicAskTimeout = old);
      final b = device(<Permission, CallPermStatus>{
        Permission.notification: G,
      }) // mic + camera never asked
        ..android = false
        ..hangOnRequest.add(Permission.microphone);
      final r = await CallPermissionFlow(backend: b, ui: FakeCallPermissionUi())
          .beforeCall(video: false, incoming: true);
      expect(b.requests, [Permission.microphone], reason: 'asked once');
      expect(r.proceed, isFalse);
    });

    test('PM-05c same user, prompt answered "Allow": the call goes on '
        '(Android and iOS)', () async {
      for (final bool android in <bool>[true, false]) {
        final b = device(<Permission, CallPermStatus>{
          Permission.notification: G,
        })
          ..android = android
          ..onRequest[Permission.microphone] = G;
        final r =
            await CallPermissionFlow(backend: b, ui: FakeCallPermissionUi())
                .beforeCall(video: false, incoming: true);
        expect(r.proceed, isTrue, reason: 'android=$android');
      }
    });

    test('PM-05d same user, VIDEO call accepted, camera never asked: '
        'mic then camera asked; camera refused = joins with camera off',
        () async {
      final b = device(<Permission, CallPermStatus>{
        Permission.notification: G,
      })
        ..onRequest[Permission.microphone] = G
        ..onRequest[Permission.camera] = A;
      final r = await CallPermissionFlow(backend: b, ui: FakeCallPermissionUi())
          .beforeCall(video: true, incoming: true);
      expect(b.requests, [Permission.microphone, Permission.camera]);
      expect(r.proceed, isTrue);
      expect(r.video, isFalse);
    });

    test('PM-06 accept video, camera blocked: join as voice, camera off',
        () async {
      final b = device({Permission.microphone: G, Permission.camera: B});
      final r = await CallPermissionFlow(backend: b, ui: FakeCallPermissionUi())
          .beforeCall(video: true, incoming: true);
      expect(r.proceed, isTrue);
      expect(r.video, isFalse);
      expect(r.cameraBlocked, isTrue);
    });

    test('PM-07 camera mid-call blocked: sheet; call not affected', () async {
      final b = device({Permission.camera: B})
        ..afterSettings[Permission.camera] = G;
      final f = CallPermissionFlow(
          backend: b, ui: FakeCallPermissionUi([CallPermChoice.cancel]));
      expect(await f.cameraDuringCall(), isFalse);

      final f2 = CallPermissionFlow(
          backend: b, ui: FakeCallPermissionUi([CallPermChoice.openSettings]));
      expect(await f2.cameraDuringCall(), isTrue);
    });

    test('PM-08 Bluetooth: asked only with a device; denied = hidden',
        () async {
      final b = device({Permission.bluetoothConnect: A})
        ..onRequest[Permission.bluetoothConnect] = B;
      final f = CallPermissionFlow(backend: b, ui: FakeCallPermissionUi());
      expect(await f.bluetoothForRoutes(devicePresent: false), isTrue);
      expect(b.requests, isEmpty);
      expect(await f.bluetoothForRoutes(devicePresent: true), isFalse);
      expect(b.requests, [Permission.bluetoothConnect]);

      final ios = device({Permission.bluetoothConnect: A})..android = false;
      expect(
          await CallPermissionFlow(backend: ios, ui: FakeCallPermissionUi())
              .bluetoothForRoutes(devicePresent: true),
          isTrue);
      expect(ios.requests, isEmpty);
    });

    test('PM-09 ring readiness: notifications + full-screen intent', () async {
      final b = device({Permission.notification: A})
        ..onRequest[Permission.notification] = G
        ..fullScreenAllowed = false;
      final f = CallPermissionFlow(backend: b, ui: FakeCallPermissionUi());
      expect(await f.incomingCallsCanRing(), isFalse);
      expect(await f.fixIncomingRinging(), isTrue);
      expect(b.requests, [Permission.notification]);
      expect(b.fullScreenRequests, 1);
    });

    test('PM-10 mic primer: once, only if never asked', () async {
      final b = device({Permission.microphone: A})
        ..onRequest[Permission.microphone] = G;
      final ui = FakeCallPermissionUi([CallPermChoice.allow]);
      final f = CallPermissionFlow(backend: b, ui: ui);
      await f.primeMicOnce();
      await f.primeMicOnce();
      expect(ui.shown, [CallPermSheet.answerReady]);
      expect(b.requests, [Permission.microphone]);

      final granted = device({Permission.microphone: G});
      final ui2 = FakeCallPermissionUi();
      await CallPermissionFlow(backend: granted, ui: ui2).primeMicOnce();
      expect(ui2.shown, isEmpty);
    });

    test('PM-01c CallService: no call arguments before the mic is granted',
        () async {
      CallPermissionBackend.instance = device({Permission.microphone: A});
      CallPermissionUi.instance = FakeCallPermissionUi([CallPermChoice.cancel]);
      expect(
        await CallService().prepareOutgoingCall(
            callerId: me, remoteUserId: peer, is_video: false),
        isNull,
      );

      CallPermissionBackend.instance = device({
        Permission.microphone: G,
        Permission.camera: B,
      });
      CallPermissionUi.instance =
          FakeCallPermissionUi([CallPermChoice.voiceInstead]);
      final args = await CallService().prepareOutgoingCall(
          callerId: me, remoteUserId: peer, is_video: true);
      expect(args, isNotNull);
      expect(args!['is_video'], isFalse, reason: 'P-04 voice instead');
    });
  });

  // ---------------------------------------------- controller (call screen)
  group('Call screen at accept (P-05 / P-06 / P-07)', () {
    late FakeSocketIoServer server;

    setUp(() async {
      await baseSetUp();
      CallPlatform.instance = FakeCallPlatform();
      server = FakeSocketIoServer();
      await server.start();
      SignallingService.instance.init(
        websocketUrl: server.url,
        selfCallerID: me,
      );
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
    });

    CallingController accept({bool video = false}) {
      Get.routing.args = incomingCallArgs(
        callerId: peer,
        callId: 9,
        sessionId: 's9',
        isVideo: video,
        callerName: 'Peer',
        profileImage: '',
        offer: null,
        fromCallKit: true,
      );
      StreamBinding().dependencies();
      return Get.find<CallingController>();
    }

    test('PM-05 mic refused at accept: call ends, caller gets the reason',
        () async {
      CallPermissionBackend.instance = device({Permission.microphone: A});
      CallPermissionUi.instance = FakeCallPermissionUi();
      accept();
      expect(
          await waitFor(() => !Get.isRegistered<CallingController>()), isTrue,
          reason: 'no silent drop: ended through the normal end path');
      expect(
          await waitFor(() => server.receivedNamed('endCall').length == 1),
          isTrue);
      final dynamic data = server.receivedNamed('endCall').single.data;
      expect(data['reason'], 'permission_denied');
      expect(data['remoteUserId'], peer);
    });

    test('PM-06 video accept, camera blocked: live call, camera off + chip',
        () async {
      CallPermissionBackend.instance =
          device({Permission.microphone: G, Permission.camera: B});
      CallPermissionUi.instance = FakeCallPermissionUi();
      final c = accept(video: true);
      expect(await waitFor(() => c.cameraBlockedByPermission.value), isTrue);
      expect(c.isVideoOn, isFalse);
      expect(c.isVideoCall.value, isTrue, reason: 'still shows remote video');
      expect(c.isCallLive, isTrue);
      expect(server.receivedNamed('endCall'), isEmpty);
    });

    test('PM-07 chip: Settings, back with camera = chip gone, call live',
        () async {
      final b = device({Permission.microphone: G, Permission.camera: B})
        ..afterSettings[Permission.camera] = G;
      CallPermissionBackend.instance = b;
      CallPermissionUi.instance =
          FakeCallPermissionUi([CallPermChoice.openSettings]);
      final c = accept(video: true);
      expect(await waitFor(() => c.cameraBlockedByPermission.value), isTrue);
      await c.allowCameraFromChip();
      expect(c.cameraBlockedByPermission.value, isFalse);
      expect(c.isCallLive, isTrue);
    });
  });

  // ------------------------------------------------------------- widgets
  group('Widgets', () {
    setUp(baseSetUp);

    Widget app(Widget child) => GetMaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, __) => Scaffold(body: child),
          ),
        );

    testWidgets('sheet: camera blocked shows 3 localized choices',
        (tester) async {
      Get.testMode = false;
      await tester.pumpWidget(app(const SizedBox()));
      CallPermChoice? choice;
      const GetCallPermissionUi()
          .show(CallPermSheet.cameraBlocked)
          .then((CallPermChoice c) => choice = c);
      await tester.pumpAndSettle();

      expect(find.text(appL10n.call_permCameraTitle), findsOneWidget);
      expect(find.text(appL10n.call_permVoiceInstead), findsOneWidget);
      expect(find.text(appL10n.permission_openSettings), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>(
          'call_perm_voiceInstead')));
      await tester.pumpAndSettle();
      expect(choice, CallPermChoice.voiceInstead);
    });

    testWidgets('PM-09 banner: shown when calls may not ring, Allow fixes it',
        (tester) async {
      Get.testMode = false;
      final b = device({Permission.notification: A})
        ..onRequest[Permission.notification] = G;
      CallPermissionBackend.instance = b;
      await tester.pumpWidget(
          app(const CallRingReadinessBanner(primeMic: false)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('call_ring_banner')),
          findsOneWidget);
      expect(find.text(appL10n.call_permRingBanner), findsOneWidget);

      await tester
          .tap(find.byKey(const ValueKey<String>('call_ring_banner_allow')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('call_ring_banner')),
          findsNothing);
    });

    testWidgets('PM-12 waitForResume completes when the app comes back',
        (tester) async {
      await tester.pumpWidget(const SizedBox());
      bool done = false;
      CallPermissionBackend()
          .waitForResume(timeout: const Duration(minutes: 5))
          .then((_) => done = true);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(done, isFalse);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(done, isTrue);
    });
  });

  // ------------------------------------------------------------- P-11
  group('PM-11 relaunch after the app was killed during a call', () {
    setUp(baseSetUp);

    test('accepted call already ended on the server: dismissed, not reopened',
        () async {
      callkitActiveCalls = <dynamic>[
        <String, dynamic>{
          'id': 'u77',
          'isAccepted': true,
          'extra': <String, dynamic>{'callId': '77', 'session_id': 's77'},
        },
      ];
      final CallKitService ck = CallKitService.instance;
      ck.pendingAccept = null;
      ck.getCallStatus = (String id) async => id == '77' ? 'ended' : null;
      await ck.init();
      expect(ck.pendingAccept, isNull, reason: 'no ghost call reopened');
      expect(callkitCalls.where((MethodCall m) => m.method == 'endCall'),
          isNotEmpty);
    });
  });
}
