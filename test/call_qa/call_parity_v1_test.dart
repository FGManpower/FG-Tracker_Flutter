// Calling module, Phase 3: WhatsApp / IMO parity.
// Cases CT-05 … CT-14, UI-01 in docs/testing/calling/unit_testing/.
//
// Pure logic (link monitor, quality, parsers) with fake time; call screen
// behaviour with the real socket client against the local fake server.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/voip_token_uploader.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/modules/mediaStream/Bindings/call_binding.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_connection_monitor.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_pip.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_quality.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/turn_credentials.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/call_ended_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
const String third = '303';
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
      if (call.method == 'activeCalls') return <dynamic>[];
      return null;
    },
  );
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

CallingController openCall(Map<String, dynamic> args) {
  Get.routing.args = args;
  StreamBinding().dependencies();
  return Get.find<CallingController>();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCallPlatform platform;

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
  }

  void dropCall() {
    if (Get.isRegistered<CallingController>()) {
      Get.find<CallingController>().isMinimized.value = false;
      Get.delete<CallingController>(force: true);
    }
  }

  tearDown(() {
    CallPlatform.instance = CallPlatform();
    CallPermissionBackend.instance = CallPermissionBackend();
    final CallKitService ck = CallKitService.instance;
    ck.isInCall = null;
    ck.onCallWaiting = null;
  });

  // ------------------------------------------------- reconnect (CT-07 / 08)
  group('CallLinkMonitor (BUG-CALL-06)', () {
    testWidgets('CT-07 caller: Reconnecting, ICE restart, recovered',
        (tester) async {
      final List<CallLinkAction> a = <CallLinkAction>[];
      final m = CallLinkMonitor(onAction: a.add, isInitiator: true);
      m.onState(CallLinkState.connected);
      m.onState(CallLinkState.disconnected);
      expect(a, [CallLinkAction.showReconnecting]);
      await tester.pump(const Duration(seconds: 2));
      expect(a.last, CallLinkAction.iceRestart);
      await tester.pump(const Duration(seconds: 6));
      expect(a.where((x) => x == CallLinkAction.iceRestart).length, 2);
      m.onState(CallLinkState.connected);
      expect(a.last, CallLinkAction.recovered);
      final int n = a.length;
      await tester.pump(const Duration(seconds: 30));
      expect(a.length, n, reason: 'no restart / give-up after recovery');
      m.dispose();
    });

    testWidgets('CT-08 failed: restart at once; give up after 25 s',
        (tester) async {
      final List<CallLinkAction> a = <CallLinkAction>[];
      final m = CallLinkMonitor(onAction: a.add, isInitiator: true);
      m.onState(CallLinkState.failed);
      expect(a, [CallLinkAction.showReconnecting, CallLinkAction.iceRestart]);
      await tester.pump(const Duration(seconds: 24));
      expect(a.contains(CallLinkAction.connectionLost), isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(a.last, CallLinkAction.connectionLost);
      final int n = a.length;
      await tester.pump(const Duration(seconds: 20));
      expect(a.length, n);
      m.dispose();
    });

    testWidgets('callee waits longer before its own restart (no glare)',
        (tester) async {
      final List<CallLinkAction> a = <CallLinkAction>[];
      final m = CallLinkMonitor(onAction: a.add, isInitiator: false);
      m.onState(CallLinkState.disconnected);
      await tester.pump(const Duration(seconds: 3));
      expect(a.contains(CallLinkAction.iceRestart), isFalse);
      await tester.pump(const Duration(seconds: 4));
      expect(a.contains(CallLinkAction.iceRestart), isTrue);
      m.dispose();
    });

    testWidgets('signaling reconnect restarts ICE only while down',
        (tester) async {
      final List<CallLinkAction> a = <CallLinkAction>[];
      final m = CallLinkMonitor(onAction: a.add, isInitiator: false);
      m.onSignalingReconnected();
      expect(a, isEmpty);
      m.onState(CallLinkState.disconnected);
      m.onSignalingReconnected();
      expect(a.last, CallLinkAction.iceRestart);
      m.dispose();
      await tester.pump(const Duration(seconds: 30));
    });
  });

  // ------------------------------------------------------ quality
  group('Call quality', () {
    test('stats reader: loss from counter deltas, RTT and jitter in ms', () {
      final r = CallStatsReader();
      MapEntry<String, Map<dynamic, dynamic>> inb(int lost, int recv) =>
          MapEntry('inbound-rtp', {
            'kind': 'audio',
            'packetsLost': lost,
            'packetsReceived': recv,
            'jitter': 0.02,
          });
      const pair = MapEntry<String, Map<dynamic, dynamic>>('candidate-pair', {
        'nominated': true,
        'currentRoundTripTime': 0.25,
      });
      r.read([inb(0, 100), pair]);
      final s = r.read([inb(10, 190), pair]);
      expect(s.lossPercent, closeTo(10, 0.01));
      expect(s.rttMs, closeTo(250, 0.01));
      expect(s.jitterMs, closeTo(20, 0.01));
    });

    test('evaluator: two poor to show, two good to hide, camera tip once', () {
      final e = CallQualityEvaluator();
      const bad = CallQualitySample(rttMs: 900);
      const good = CallQualitySample(rttMs: 80, lossPercent: 0, jitterMs: 5);
      expect(e.add(bad), isFalse);
      expect(e.add(bad), isTrue);
      expect(e.isPoor, isTrue);
      e.add(bad);
      e.add(bad);
      expect(e.takeCameraOffSuggestion(videoOn: true), isTrue);
      expect(e.takeCameraOffSuggestion(videoOn: true), isFalse);
      e.add(good);
      expect(e.add(good), isTrue);
      expect(e.isPoor, isFalse);
    });
  });

  // ------------------------------------------------------ parsers
  group('Parsers', () {
    test('waiting call from a socket newCall and from a push', () {
      final w = WaitingCall.parse(
        {'callId': 900, 'callerId': 303, 'caller_name': 'Third', 'isVideo': 'true'},
        decodeCallData: CallKitService.decodeCallData,
        decodeOffer: CallKitService.decodeOffer,
      )!;
      expect(w.callId, '900');
      expect(w.callerId, '303');
      expect(w.callerName, 'Third');
      expect(w.isVideo, isTrue);

      final p = WaitingCall.parse(
        {
          'screen_name': 'incomingCall',
          'callData': jsonEncode({
            'callId': 901,
            'callerId': '304',
            'callerName': 'Push',
            'session_id': 's901',
          }),
        },
        decodeCallData: CallKitService.decodeCallData,
        decodeOffer: CallKitService.decodeOffer,
      )!;
      expect(p.callId, '901');
      expect(p.sessionId, 's901');
      expect(p.callerName, 'Push');
      expect(WaitingCall.parse({'x': 1},
              decodeCallData: CallKitService.decodeCallData,
              decodeOffer: CallKitService.decodeOffer),
          isNull);
    });

    test('reject outcome and media state payload', () {
      expect(rejectOutcome({'reason': 'busy'}), CallEndOutcome.busy);
      expect(rejectOutcome({'callId': 1}), CallEndOutcome.declined);
      final p = mediaStatePayload(
          callId: 5, to: peer, me: me, micMuted: true, cameraOn: false, videoPaused: true);
      expect(p['remoteUserId'], peer);
      expect(p['mediaState'], {'micMuted': true, 'cameraOn': false, 'videoPaused': true});
    });

    test('CT-14 CallKit system actions mapping', () {
      expect(
          CallKitService.mapSystemAction('actioncalltogglemute', {'id': 'u1', 'isMuted': true})
              .toString(),
          CallKitSystemAction(CallKitSystemActionKind.mute, 'u1', true).toString());
      final h = CallKitService.mapSystemAction('actioncalltogglehold', {'id': 'u1', 'isOnHold': 'true'})!;
      expect(h.kind, CallKitSystemActionKind.hold);
      expect(h.value, isTrue);
      expect(CallKitService.mapSystemAction('actioncallcallback', {})!.kind,
          CallKitSystemActionKind.callback);
      expect(CallKitService.mapSystemAction('actioncallaccept', {}), isNull);
      expect(CallKitService.newUuid(),
          matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    });

    test('auto PiP only for a connected, visible, non-sharing video call', () {
      expect(CallPip.shouldAutoPip(video: true, connected: true, minimized: false, screenSharing: false), isTrue);
      expect(CallPip.shouldAutoPip(video: false, connected: true, minimized: false, screenSharing: false), isFalse);
      expect(CallPip.shouldAutoPip(video: true, connected: false, minimized: false, screenSharing: false), isFalse);
      expect(CallPip.shouldAutoPip(video: true, connected: true, minimized: true, screenSharing: false), isFalse);
      expect(CallPip.shouldAutoPip(video: true, connected: true, minimized: false, screenSharing: true), isFalse);
    });
  });

  // ------------------------------------------------------ HTTP pieces
  group('VoIP token and TURN credentials', () {
    setUp(baseSetUp);

    test('CT-13 VoIP token uploaded once per new token; failure retried',
        () async {
      final List<Map<String, dynamic>> posts = <Map<String, dynamic>>[];
      int status = 200;
      final client = MockClient((http.Request r) async {
        expect(r.url.path, endsWith('/update-voip-token'));
        posts.add(jsonDecode(r.body) as Map<String, dynamic>);
        return http.Response('{}', status);
      });
      await http.runWithClient(() async {
        expect(await VoipTokenUploader.instance.upload('tok-A'), isTrue);
        expect(await VoipTokenUploader.instance.upload('tok-A'), isTrue);
        expect(posts.length, 1, reason: 'same token: no second upload');
        status = 500;
        expect(await VoipTokenUploader.instance.upload('tok-B'), isFalse);
        status = 200;
        expect(await VoipTokenUploader.instance.upload('tok-B'), isTrue);
      }, () => client);
      expect(posts.map((p) => p['voipToken']), ['tok-A', 'tok-B', 'tok-B']);
      expect(posts.first['platform'], 'ios');
    });

    test('TURN: short-lived credentials when the endpoint answers, cached',
        () async {
      TurnCredentialService.instance.clearCache();
      int calls = 0;
      final client = MockClient((http.Request r) async {
        calls++;
        expect(r.url.path, endsWith('/calls/turn-credentials'));
        return http.Response(
            jsonEncode({
              'urls': ['turns:turn.example:443?transport=tcp'],
              'username': 'u',
              'credential': 'c',
              'ttl': 600,
            }),
            200);
      });
      final servers = await http.runWithClient(
          () => TurnCredentialService.instance.iceServers(), () => client);
      expect(servers.last['urls'], ['turns:turn.example:443?transport=tcp']);
      await http.runWithClient(
          () => TurnCredentialService.instance.iceServers(), () => client);
      expect(calls, 1, reason: 'cached until shortly before the TTL');
    });

    test('TURN: endpoint missing (404) = static fallback incl. turns:443',
        () async {
      TurnCredentialService.instance.clearCache();
      final servers = await http.runWithClient(
        () => TurnCredentialService.instance.iceServers(),
        () => MockClient((_) async => http.Response('not found', 404)),
      );
      final List<String> urls =
          (servers.last['urls'] as List).map((e) => e.toString()).toList();
      expect(urls.any((u) => u.startsWith('turns:') && u.contains(':443')), isTrue);
      expect(TurnCredentialService.parse({'urls': [], 'username': 'u'}), isNull);
    });
  });

  // ------------------------------------------------- call screen + socket
  group('Call screen (socket)', () {
    late FakeSocketIoServer server;

    List<FakeClientEvent> sent(String name) => server.receivedNamed(name, nsp: nsp);

    setUp(() async {
      await baseSetUp();
      server = FakeSocketIoServer();
      await server.start();
      SignallingService.instance.init(websocketUrl: server.url, selfCallerID: me);
      expect(await waitFor(() => server.clientsOn(nsp) == 1), isTrue);
    });

    tearDown(() async {
      dropCall();
      SignallingService.instance.disconnect();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await server.stop();
    });

    Future<CallingController> liveCall() async {
      final c = openCall(outgoing());
      server.emit(nsp, 'callCreated', {'callId': 501, 'sessionId': 's501'});
      expect(await waitFor(() => c.callId == 501), isTrue);
      return c;
    }

    test('CT-05 second call while in a call: "busy" to its caller, banner, '
        'current call untouched', () async {
      final c = await liveCall();
      server.emit(nsp, 'newCall', {'callId': 900, 'callerId': 303, 'caller_name': 'Third'});
      expect(await waitFor(() => c.waitingCall.value != null), isTrue);
      expect(await waitFor(() => sent('CallingStatus').isNotEmpty), isTrue);
      final dynamic st = sent('CallingStatus').single.data;
      expect(st['callingStatus'], 'busy', reason: 'never a fake "Ringing"');
      expect(st['callId'], '900');
      expect(c.isCallLive, isTrue);
      expect(sent('endCall'), isEmpty);
    });

    test('CT-06a Decline the waiting call: rejectCall reason busy', () async {
      final c = await liveCall();
      server.emit(nsp, 'newCall', {'callId': 900, 'callerId': 303});
      expect(await waitFor(() => c.waitingCall.value != null), isTrue);
      c.declineWaitingCall();
      expect(await waitFor(() => sent('rejectCall').length == 1), isTrue);
      final dynamic r = sent('rejectCall').single.data;
      expect(r['remoteUserId'], third);
      expect(r['reason'], 'busy');
      expect(c.waitingCall.value, isNull);
      expect(c.isCallLive, isTrue);
    });

    test('CT-08b connection lost: endCall reason, end screen info', () async {
      final c = await liveCall();
      c.debugLinkAction(CallLinkAction.connectionLost);
      expect(await waitFor(() => sent('endCall').length == 1), isTrue);
      expect(sent('endCall').single.data['reason'], 'connection_lost');
      expect(await waitFor(() => !Get.isRegistered<CallingController>()), isTrue);
      expect(CallingController.lastEndInfo?.outcome, CallEndOutcome.connectionLost);
    });

    test('CT-09 signaling reconnect: rejoinCall once, no duplicate handlers',
        () async {
      await liveCall();
      await server.dropAll(); // network drop: the client reconnects by itself
      expect(
          await waitFor(() => sent('rejoinCall').isNotEmpty,
              timeout: const Duration(seconds: 10)),
          isTrue);
      expect(sent('rejoinCall').first.data['callId'], 501);
      server.emit(nsp, 'callEnded', {'callId': 501, 'sessionId': 's501'});
      expect(await waitFor(() => !Get.isRegistered<CallingController>()), isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(platform.serviceStops, 1, reason: 'ended exactly once');
    });

    test('UI-01 end outcomes: no answer, declined, busy', () async {
      final c1 = await liveCall();
      await c1.missedCall(timedOut: true);
      expect(CallingController.lastEndInfo?.outcome, CallEndOutcome.noAnswer);

      openCall(outgoing());
      server.emit(nsp, 'callRejected', {'callId': 1, 'reason': 'busy'});
      expect(await waitFor(() => !Get.isRegistered<CallingController>()), isTrue);
      expect(CallingController.lastEndInfo?.outcome, CallEndOutcome.busy);

      openCall(outgoing());
      server.emit(nsp, 'callRejected', {'callId': 2});
      expect(await waitFor(() => !Get.isRegistered<CallingController>()), isTrue);
      expect(CallingController.lastEndInfo?.outcome, CallEndOutcome.declined);

      final c4 = openCall(outgoing());
      await c4.missedCall(); // user cancelled: no end screen
      expect(CallingController.lastEndInfo, isNull);
    });

    test('BUG-CALL-37 late callEnded / callRejected of an older call is ignored',
        () async {
      final c = await liveCall();
      server.emit(nsp, 'callEnded', {'callId': 499, 'sessionId': 's499'});
      server.emit(nsp, 'callRejected', {'callId': 498});
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(c.isCallLive, isTrue, reason: 'older call ids must not end this call');
      expect(CallSessionState.sessionId, 's501',
          reason: 'BUG-CALL-38: live session id kept');
      server.emit(nsp, 'callEnded', {'callId': 501, 'sessionId': 's501'});
      expect(await waitFor(() => !Get.isRegistered<CallingController>()), isTrue);
    });

    test('callee busy: caller shows "On another call", keeps waiting', () async {
      final c = await liveCall();
      server.emit(nsp, 'callStatus', {'callId': 501, 'status': 'busy'});
      expect(await waitFor(() => c.callStatus.value == 'On another call'), isTrue);
      expect(c.isCallLive, isTrue);
    });

    test('CT-14 media state both ways; CallKit mute does not echo', () async {
      final c = await liveCall();
      c.toggleMic();
      expect(await waitFor(() => sent('upgradeToVideo').isNotEmpty), isTrue);
      expect(sent('upgradeToVideo').last.data['mediaState']['micMuted'], isTrue);
      expect(platform.callKitMute, [true], reason: 'lock screen in sync');

      c.setMutedFromSystem(false); // from CallKit
      expect(c.isAudioOn, isTrue);
      expect(platform.callKitMute, [true], reason: 'no echo back to CallKit');

      server.emit(nsp, 'upgradeToVideo', {
        'callId': 501,
        'mediaState': {'micMuted': true, 'videoPaused': true},
      });
      expect(await waitFor(() => c.remoteMicMuted.value && c.remoteVideoPaused.value), isTrue);
      server.emit(nsp, 'mediaState', {'mediaState': {'micMuted': false}});
      expect(await waitFor(() => !c.remoteMicMuted.value), isTrue);
    });

    test('CallKit hold mutes and restores', () async {
      final c = await liveCall();
      c.setOnHoldFromSystem(true);
      expect(c.isOnHold.value, isTrue);
      expect(c.isAudioOn, isFalse);
      c.setOnHoldFromSystem(false);
      expect(c.isAudioOn, isTrue);
    });

    test('poor connection badge from stats', () async {
      final c = await liveCall();
      c.debugQualitySample(const CallQualitySample(lossPercent: 20));
      c.debugQualitySample(const CallQualitySample(lossPercent: 20));
      expect(c.isPoorConnection.value, isTrue);
    });

    test('iOS CallKit: outgoing reported, incoming not', () async {
      await liveCall();
      expect(platform.callKitOutgoing.length, kReportOutgoingCallsToCallKit ? 1 : 0);
    });

    test('push of a second call while in a call goes to the banner', () async {
      final c = await liveCall();
      final ck = CallKitService.instance;
      ck.isInCall = () => true;
      ck.onCallWaiting = c.showWaitingCall;
      await CallKitService.handlePush({
        'screen_name': 'incomingCall',
        'callData': jsonEncode({'callId': 902, 'callerId': '305', 'callerName': 'P'}),
      });
      expect(c.waitingCall.value?.callId, '902');
      expect(callkitCalls.where((m) => m.method == 'showCallkitIncoming'), isEmpty);
    });
  });

  // ------------------------------------------------- widgets
  group('Widgets', () {
    setUp(baseSetUp);
    tearDown(dropCall);

    Widget app(Widget home, {List<GetPage<dynamic>>? pages}) => GetMaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          getPages: pages,
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, __) => home,
          ),
        );

    testWidgets('UI-01 end screen: reason + Call again / Cancel', (tester) async {
      Get.testMode = false;
      await tester.pumpWidget(app(const CallEndedScreen(
        info: CallEndInfo(
          outcome: CallEndOutcome.noAnswer,
          remoteUserId: peer,
          name: 'Peer',
          isVideo: false,
        ),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Peer'), findsOneWidget);
      expect(find.text(appL10n.call_endNoAnswer), findsOneWidget);
      expect(find.text(appL10n.call_callAgain), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('call_end_cancel')), findsOneWidget);
    });

    testWidgets('CT-06b End & accept: current call ends, new call opens',
        (tester) async {
      Get.testMode = false;
      SignallingService.instance.disconnect(); // navigation only
      await tester.pumpWidget(app(
        const Scaffold(body: Text('home')),
        pages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: Routes.callScreen,
            page: () => const Scaffold(body: Text('call page')),
            binding: StreamBinding(),
          ),
        ],
      ));
      Get.toNamed(Routes.callScreen, arguments: outgoing());
      await tester.pumpAndSettle();
      final CallingController first = Get.find<CallingController>();
      first.showWaitingCall({'callId': 900, 'callerId': 303, 'caller_name': 'Third'});
      expect(first.waitingCall.value, isNotNull);

      unawaited(first.endAndAcceptWaitingCall());
      await tester.pumpAndSettle();
      final CallingController second = Get.find<CallingController>();
      expect(identical(first, second), isFalse);
      expect(second.args['callerId'], third);
      expect(second.args['callType'], 'Incoming');
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
