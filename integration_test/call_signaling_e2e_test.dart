// E2E (signaling level): 1:1 calls against a REAL /callSignaling server.
//
// Drives the app's own SignallingService + CallingController on a device /
// emulator. Media is OFF (FakeCallPlatform.mediaEnabled = false), so the
// controller skips getUserMedia and the peer connection. The few signaling
// emits that normally come from the media path (`_setupPeer` in
// calling_controller.dart: makeCall, answerCall, acceptCallFromCallKit,
// IceCandidate, the missed-call timer start) are sent by this harness with
// the SAME payload shapes and a clearly marked FAKE SDP. Everything else
// (callCreated, callStatus, callRejected, callEnded, missedCall handling,
// endCall / missCall emits, controller release) is the app's real code.
//
// The other user is the Node bot in scripts/call_qa/ (see its README.md).
// This needs a STAGING server and two test accounts. Not run yet.
//
// Run (terminal 2, after starting the bot with MODE=suite in terminal 1):
//   flutter test integration_test/call_signaling_e2e_test.dart -d <device> \
//     --dart-define=SIGNALING_URL=https://<staging-host> \
//     --dart-define=APP_USER_ID=<test user A> \
//     --dart-define=PEER_USER_ID=<bot user B>
//
// Optional defines:
//   E2E_CASES=outgoing-answer,outgoing-reject   run only these cases (pair
//                                       with the matching bot MODE)
//   BOT_HOLD_SECONDS=5 BOT_DROP_SECONDS=5  must match the bot's HOLD_SECONDS
//                                       / DROP_SECONDS
//   APP_DROP_SECONDS=5                   app socket outage in "app-drop"
//   E2E_EXPECT_REJOIN=false              only warn (default: fail) when the
//                                       app does not emit rejoinCall after
//                                       a signaling reconnect
//
// Each case runs 3 times; one failed run fails the case (flaky = fail).
// No tokens or TURN credentials are needed or read here.
import 'dart:convert';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/call_session.dart'
    show CallSessionState;
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/modules/mediaStream/Bindings/call_binding.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' show Socket;

import '../test/call_qa/fakes/fake_call_permissions.dart';
import '../test/call_qa/fakes/fake_call_platform.dart';

// ------------------------------------------------------------------ config

const String kUrl = String.fromEnvironment('SIGNALING_URL');
const String kMe = String.fromEnvironment('APP_USER_ID');
const String kPeer = String.fromEnvironment('PEER_USER_ID');
const String kCases = String.fromEnvironment('E2E_CASES');
const int kBotHold = int.fromEnvironment('BOT_HOLD_SECONDS', defaultValue: 5);
const int kBotDrop = int.fromEnvironment('BOT_DROP_SECONDS', defaultValue: 5);
const int kAppDrop = int.fromEnvironment('APP_DROP_SECONDS', defaultValue: 5);
const bool kExpectRejoin =
    bool.fromEnvironment('E2E_EXPECT_REJOIN', defaultValue: true);

/// Every case runs this many times. One failed run = flaky = fail.
const int kRuns = 3;

/// Same order as MODE=suite in scripts/call_qa/call_bot.js.
const List<String> kAllCases = <String>[
  'outgoing-answer', // bot: answer
  'outgoing-reject', // bot: reject
  'outgoing-busy', // bot: busy
  'outgoing-timeout', // bot: timeout
  'outgoing-peer-ends', // bot: answer-then-end
  'peer-drop', // bot: answer-then-drop
  'app-drop', // bot: answer
  'incoming-accept', // bot: call-app:accept
  'incoming-decline', // bot: call-app:decline
];

bool _selected(String name) {
  if (kCases.trim().isEmpty) return true;
  return kCases.split(',').map((s) => s.trim()).contains(name);
}

// ------------------------------------------------------------------ fake media

/// FakeCallPlatform plus the newer CallPlatform hooks, so no tone, CallKit
/// outgoing report or PiP plugin runs on the test device.
class _E2ECallPlatform extends FakeCallPlatform {
  @override
  void playTone(String asset) => log.add('tone:$asset');

  @override
  Future<void> reportOutgoingToCallKit({
    required String uuid,
    required String name,
    required String handle,
    required bool isVideo,
  }) async =>
      log.add('callkitOutgoing');

  @override
  Future<void> syncCallKitMute(String id, bool muted) async {}

  @override
  Future<void> setAutoPip(bool enabled) async {}
}

const String _fakeMark = 'FG-CALL-QA FAKE SDP - signaling test only, NO media';

Map<String, dynamic> _fakeSdp(String type) => <String, dynamic>{
      'sdp': <String>[
        'v=0',
        'o=fg-call-qa 0 0 IN IP4 192.0.2.1',
        's=$_fakeMark ($type)',
        't=0 0',
        'a=x-fg-call-qa:fake',
        'm=audio 9 UDP/TLS/RTP/SAVPF 111',
        'c=IN IP4 192.0.2.1',
        'a=inactive',
        '',
      ].join('\r\n'),
      'type': type,
    };

/// TEST-NET-1 (RFC 5737), never routable.
const Map<String, dynamic> _fakeIce = <String, dynamic>{
  'id': '0',
  'label': 0,
  'candidate': 'candidate:fgcallqa 1 udp 1 192.0.2.1 9 typ host',
};

// ------------------------------------------------------------------ logging

final RegExp _secretKey =
    RegExp(r'token|auth|password|secret|credential|cookie', caseSensitive: false);
final RegExp _sdpKey = RegExp(
  r'^(sdp|sdpOffer|sdpAnswer|offer|answer|sdpOfferCompressed)$',
  caseSensitive: false,
);

/// Never prints secrets or full SDP / ICE: lengths only.
dynamic _sanitize(dynamic v, [String key = '']) {
  if (v == null) return null;
  if (_secretKey.hasMatch(key)) return '<redacted>';
  if (v is String) {
    if (_sdpKey.hasMatch(key) || v.startsWith('v=0')) {
      return '<sdp len=${v.length}>';
    }
    if (key == 'candidate') return '<candidate len=${v.length}>';
    if (v.length > 160) return '<string len=${v.length}>';
    return v;
  }
  if (v is List) return v.map((e) => _sanitize(e, key)).toList();
  if (v is Map) {
    return <String, dynamic>{
      for (final MapEntry<dynamic, dynamic> e in v.entries)
        e.key.toString(): _sanitize(e.value, e.key.toString()),
    };
  }
  return v;
}

void _log(String msg) {
  final String t = DateTime.now().toIso8601String().substring(11, 23);
  // ignore: avoid_print
  print('[E2E $t] $msg');
}

String _s(dynamic v) => v == null ? '' : v.toString();

// ------------------------------------------------------------------ recorder

class _Rec {
  _Rec(this.event, this.data, {required this.outgoing}) : at = DateTime.now();
  final DateTime at;
  final String event;
  final dynamic data;
  final bool outgoing;
}

/// Records every event the app's signaling socket receives and sends.
class _SignalLog {
  final List<_Rec> items = <_Rec>[];
  Socket? _socket;
  int newCallCursor = 0;

  dynamic _in(String event, dynamic data) {
    items.add(_Rec(event, data, outgoing: false));
    _log('<- $event ${jsonEncode(_sanitize(data))}');
    return null;
  }

  dynamic _out(String event, dynamic data) {
    items.add(_Rec(event, data, outgoing: true));
    _log('-> $event ${jsonEncode(_sanitize(data))}');
    return null;
  }

  void attach(Socket s) {
    _socket = s;
    s.onAny(_in);
    s.onAnyOutgoing(_out);
  }

  void detach() {
    _socket?.offAny(_in);
    _socket?.offAnyOutgoing(_out);
    _socket = null;
  }

  int mark() => items.length;

  Iterable<_Rec> since(int from, {String? event, bool? outgoing}) =>
      items.skip(from).where((r) =>
          (event == null || r.event == event) &&
          (outgoing == null || r.outgoing == outgoing));

  /// First matching received event at index >= [from], or null on timeout.
  Future<_Rec?> wait(
    String event, {
    required int from,
    required Duration timeout,
    bool Function(dynamic data)? where,
  }) async {
    final DateTime end = DateTime.now().add(timeout);
    while (true) {
      for (final _Rec r in since(from, event: event, outgoing: false)) {
        if (where == null || where(r.data)) return r;
      }
      if (DateTime.now().isAfter(end)) return null;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}

// ------------------------------------------------------------------ helpers

Future<void> _sleep(Duration d) => Future<void>.delayed(d);

Future<bool> _until(bool Function() ok, Duration timeout) async {
  final DateTime end = DateTime.now().add(timeout);
  while (!ok()) {
    if (DateTime.now().isAfter(end)) return ok();
    await _sleep(const Duration(milliseconds: 50));
  }
  return true;
}

/// Fails when [ok] becomes false at any point during [d].
Future<void> _staysTrue(bool Function() ok, Duration d, String reason) async {
  final DateTime end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    expect(ok(), isTrue, reason: reason);
    await _sleep(const Duration(milliseconds: 100));
  }
  expect(ok(), isTrue, reason: reason);
}

Socket _socket() {
  final Socket? s = SignallingService.instance.socket;
  if (s == null) throw StateError('SignallingService has no socket');
  return s;
}

/// Stand-in for an emit the controller's media path would make.
void _emit(String event, Map<String, dynamic> data) =>
    _socket().emit(event, data);

/// Opens a call screen the way the route does: arguments + StreamBinding.
CallingController _openCall(Map<String, dynamic> args) {
  Get.routing.args = args;
  StreamBinding().dependencies();
  return Get.find<CallingController>();
}

Map<String, dynamic> _outgoingArgs() => <String, dynamic>{
      'callerId': kMe,
      'remoteUserId': kPeer,
      'offer': null,
      'is_video': false,
      'callerName': 'Call QA bot',
      'callType': 'outGoing',
    };

/// Event belongs to this call (or carries no id).
bool Function(dynamic) _sameCall(dynamic callId, String? sessionId) {
  return (dynamic d) {
    if (d is! Map) return true;
    final List<String> ids = <dynamic>[d['callId'], d['sessionId'], d['session_id']]
        .map(_s)
        .where((s) => s.isNotEmpty && s != 'null')
        .toList();
    if (ids.isEmpty) return true;
    return ids.contains(_s(callId)) ||
        (sessionId != null && sessionId.isNotEmpty && ids.contains(sessionId));
  };
}

bool _released(CallingController c) => !c.isCallLive;

// ------------------------------------------------------------------ test

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final String? skip = kUrl.isEmpty
      ? 'SIGNALING_URL is not defined. This E2E needs a staging '
          '/callSignaling server, two test accounts and the bot in '
          'scripts/call_qa/. Pass --dart-define=SIGNALING_URL=... '
          '--dart-define=APP_USER_ID=... --dart-define=PEER_USER_ID=... '
          '(see scripts/call_qa/README.md).'
      : null;
  if (skip != null) _log('SKIPPED: $skip');

  late _SignalLog sig;

  Future<void> setUpApp() async {
    expect(kMe.isNotEmpty && kPeer.isNotEmpty, isTrue,
        reason: 'APP_USER_ID and PEER_USER_ID must be defined');
    expect(kMe != kPeer, isTrue, reason: 'APP_USER_ID == PEER_USER_ID');

    Get.reset();
    Get.testMode = true; // navigation without a navigator is a no-op
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(375, 812)),
      designSize: const Size(375, 812),
      splitScreenMode: false,
      minTextAdapt: false,
    );
    // In-memory prefs: the device's real app data is never touched.
    SharedPreferences.setMockInitialValues(<String, Object>{
      PrefConst.userId: kMe,
    });
    Global.storageServices = await StorageServices().init();
    CallSessionState.reset();

    CallPlatform.instance = _E2ECallPlatform();
    CallPermissionBackend.instance = FakeCallPermissionBackend.allGranted();

    SignallingService.instance.init(websocketUrl: kUrl, selfCallerID: kMe);
    sig = _SignalLog()..attach(_socket());
    final bool up = await _until(
      () => SignallingService.instance.socket?.connected == true,
      const Duration(seconds: 20),
    );
    expect(up, isTrue, reason: 'cannot connect to $kUrl/callSignaling');
    _log('connected to /callSignaling as $kMe, peer bot $kPeer');
  }

  Future<void> tearDownApp() async {
    if (Get.isRegistered<CallingController>()) {
      final CallingController c = Get.find<CallingController>();
      if (c.isCallLive) await c.endCall(type: 'e2e-teardown');
    }
    if (Get.isRegistered<CallingController>()) {
      Get.find<CallingController>().isMinimized.value = false;
      Get.delete<CallingController>(force: true);
    }
    await _sleep(const Duration(milliseconds: 500));
    sig.detach();
    SignallingService.instance.disconnect();
    CallPlatform.instance = CallPlatform();
    CallPermissionBackend.instance = CallPermissionBackend();
  }

  /// Leaves no live controller behind after a failed run.
  Future<void> cleanupRun() async {
    if (Get.isRegistered<CallingController>()) {
      final CallingController c = Get.find<CallingController>();
      if (c.isCallLive) await c.endCall(type: 'e2e-cleanup');
    }
    CallSessionState.reset();
  }

  // ---------------------------------------------------------------- outgoing

  /// App calls the bot. Returns the controller once callCreated was applied.
  Future<(CallingController, int)> placeCall({bool startTimer = false}) async {
    final int from = sig.mark();
    CallingController.lastEndInfo = null;
    final CallingController c = _openCall(_outgoingArgs());
    // Let onInit / the permission check run (media is off).
    await _sleep(const Duration(milliseconds: 500));
    expect(c.isCallLive, isTrue,
        reason: 'controller ended before makeCall (permission flow?)');

    // calling_controller.dart `_setupPeer`, outgoing branch.
    _emit('makeCall', <String, dynamic>{
      'remoteUserId': kPeer,
      'sdpOffer': _fakeSdp('offer'),
      'is_video': false,
      'callerId': Global.storageServices.get(PrefConst.userId),
    });
    if (startTimer) c.startMissedCallTimer();

    final _Rec? created = await sig.wait('callCreated',
        from: from, timeout: const Duration(seconds: 15));
    expect(created, isNotNull, reason: 'no callCreated within 15 s');
    final dynamic id = (created!.data as Map)['callId'];
    expect(_s(id), isNotEmpty, reason: 'callCreated without callId');
    final bool applied = await _until(
        () => _s(c.callId) == _s(id), const Duration(seconds: 5));
    expect(applied, isTrue,
        reason: 'controller did not take callId from callCreated');
    return (c, from);
  }

  Future<_Rec> waitAnswered(CallingController c, int from) async {
    final _Rec? r = await sig.wait('callAnswered',
        from: from,
        timeout: const Duration(seconds: 30),
        where: _sameCall(c.callId, CallSessionState.sessionId));
    expect(r, isNotNull, reason: 'no callAnswered within 30 s');
    expect(c.isCallLive, isTrue, reason: 'call ended before callAnswered');
    // calling_controller.dart callAnswered handler: flush ICE to the callee.
    _emit('IceCandidate',
        <String, dynamic>{'remoteUserId': kPeer, 'iceCandidate': _fakeIce});
    return r!;
  }

  Future<void> expectReleased(CallingController c, Duration within,
      String what) async {
    final bool ok = await _until(() => _released(c), within);
    expect(ok, isTrue, reason: '$what: controller still live after $within');
    expect(Get.isRegistered<CallingController>(), isFalse,
        reason: '$what: finished controller was not released (BUG-CALL-01)');
  }

  void expectNoOwnEndCall(int from, String what) {
    expect(sig.since(from, event: 'endCall', outgoing: true), isEmpty,
        reason: '$what: app echoed endCall after the remote side ended');
  }

  void expectOwnEndCall(int from, CallingController c, String what) {
    final List<_Rec> sent =
        sig.since(from, event: 'endCall', outgoing: true).toList();
    expect(sent, hasLength(1), reason: '$what: endCall sent ${sent.length}x');
    final Map<dynamic, dynamic> p = sent.single.data as Map;
    expect(_s(p['remoteUserId']), kPeer,
        reason: '$what: endCall.remoteUserId');
    expect(_s(p['callId']), isNotEmpty, reason: '$what: endCall.callId');
  }

  Future<void> outgoingAnswer() async {
    final (CallingController c, int from) = await placeCall();
    await waitAnswered(c, from);
    final _Rec? ice = await sig.wait('IceCandidate',
        from: from, timeout: const Duration(seconds: 10));
    expect(ice, isNotNull, reason: 'IceCandidate from the bot not relayed');
    await _sleep(const Duration(seconds: 2));
    final int beforeEnd = sig.mark();
    await c.endCall();
    await expectReleased(c, const Duration(seconds: 5), 'own hang-up');
    await _sleep(const Duration(milliseconds: 500));
    expectOwnEndCall(beforeEnd, c, 'own hang-up');
  }

  Future<void> outgoingDeclined(String what) async {
    final (CallingController c, int from) = await placeCall();
    await expectReleased(c, const Duration(seconds: 30), what);
    final bool viaRejected =
        sig.since(from, event: 'callRejected', outgoing: false).isNotEmpty;
    final List<String> statuses = sig
        .since(from, event: 'callStatus', outgoing: false)
        .map((r) => _s((r.data as Map)['status'] ?? (r.data as Map)['callingStatus']))
        .toList();
    _log('$what: callRejected=$viaRejected callStatus=$statuses');
    expect(sig.since(from, event: 'callAnswered', outgoing: false), isEmpty,
        reason: '$what: unexpected callAnswered');
    expectNoOwnEndCall(from, what);
    if (what == 'busy' &&
        !statuses.any((s) => s.toLowerCase() == 'busy')) {
      _log('NOTE busy: server did not relay callStatus "busy" '
          '(the call ended through callRejected only)');
    }
    // End screen outcome (call_entry.dart rejectOutcome): the server must
    // keep `reason` on callRejected for "busy" to reach the caller.
    expect(CallingController.lastEndInfo?.outcome,
        what == 'busy' ? CallEndOutcome.busy : CallEndOutcome.declined,
        reason: '$what: end screen outcome');
  }

  Future<void> outgoingTimeout() async {
    final (CallingController c, int from) =
        await placeCall(startTimer: true);
    await expectReleased(c, kCallRingTimeout + const Duration(seconds: 20),
        'ring timeout');
    await _sleep(const Duration(milliseconds: 500));
    expect(sig.since(from, event: 'callAnswered', outgoing: false), isEmpty,
        reason: 'timeout: unexpected callAnswered');
    final bool serverMissed =
        sig.since(from, event: 'missedCall', outgoing: false).isNotEmpty;
    if (!serverMissed) {
      final List<_Rec> miss =
          sig.since(from, event: 'missCall', outgoing: true).toList();
      expect(miss, hasLength(1), reason: 'timeout: missCall not sent once');
      expect(_s((miss.single.data as Map)['remoteUserId']), kPeer,
          reason: 'timeout: missCall.remoteUserId');
      expectOwnEndCall(from, c, 'timeout');
      expect(CallingController.lastEndInfo?.outcome, CallEndOutcome.noAnswer,
          reason: 'timeout: end screen outcome');
    }
  }

  Future<void> outgoingPeerEnds() async {
    final (CallingController c, int from) = await placeCall();
    await waitAnswered(c, from);
    await expectReleased(
        c, const Duration(seconds: kBotHold + 30), 'bot hang-up');
    expect(
      sig.since(from, outgoing: false).any((r) =>
          r.event == 'callEnded' || r.event == 'endCall'),
      isTrue,
      reason: 'bot hang-up: no callEnded received',
    );
    expectNoOwnEndCall(from, 'bot hang-up');
  }

  Future<void> peerDrop() async {
    final (CallingController c, int from) = await placeCall();
    await waitAnswered(c, from);
    // Bot: hold, drop for kBotDrop s, reconnect + rejoinCall, hold, end.
    await _staysTrue(
      () => c.isCallLive,
      const Duration(seconds: kBotHold + kBotDrop + 3),
      'call ended while the bot\'s socket was down / reconnecting',
    );
    await expectReleased(
        c, const Duration(seconds: kBotHold + 40), 'bot hang-up after drop');
    expect(
      sig.since(from, outgoing: false).any((r) =>
          r.event == 'callEnded' || r.event == 'endCall'),
      isTrue,
      reason: 'peer drop: no callEnded after the bot hung up',
    );
    expectNoOwnEndCall(from, 'peer drop');
  }

  Future<void> appDrop() async {
    final (CallingController c, int from) = await placeCall();
    await waitAnswered(c, from);
    await _sleep(const Duration(seconds: 2));

    final Socket s = _socket();
    final int dropMark = sig.mark();
    _log('dropping the app signaling transport for ~$kAppDrop s');
    s.io.reconnectionDelay = kAppDrop * 1000;
    s.io.reconnectionDelayMax = kAppDrop * 1000;
    s.io.randomizationFactor = 0;
    try {
      // Looks like a network loss to the server ("transport close"); the
      // client reconnects on its own.
      s.io.engine?.close();
      expect(await _until(() => !s.connected, const Duration(seconds: 5)),
          isTrue,
          reason: 'socket did not go down');
      await _staysTrue(() => c.isCallLive || s.connected,
          const Duration(seconds: 1), 'call ended right after the drop');
      expect(
          await _until(
              () => s.connected, const Duration(seconds: kAppDrop + 30)),
          isTrue,
          reason: 'app socket did not reconnect');
    } finally {
      s.io.reconnectionDelay = 1000;
      s.io.reconnectionDelayMax = 5000;
      s.io.randomizationFactor = 0.5;
    }
    expect(identical(SignallingService.instance.socket, s), isTrue,
        reason: 'reconnect replaced the socket object');
    expect(c.isCallLive, isTrue,
        reason: 'call did not survive the app socket drop');

    await _sleep(const Duration(seconds: 3));
    final bool rejoined =
        sig.since(dropMark, event: 'rejoinCall', outgoing: true).isNotEmpty;
    if (kExpectRejoin) {
      expect(rejoined, isTrue,
          reason: 'app did not emit rejoinCall after reconnect');
    } else if (!rejoined) {
      _log('WARN app did not emit rejoinCall after reconnect '
          '(E2E_EXPECT_REJOIN=false: warning only)');
    }
    expect(
      sig.since(dropMark, outgoing: false).any((r) =>
          r.event == 'callEnded' || r.event == 'missedCall'),
      isFalse,
      reason: 'server ended the call during the app socket drop',
    );
    expect(c.isCallLive, isTrue, reason: 'call ended after reconnect');

    final int beforeEnd = sig.mark();
    await c.endCall();
    await expectReleased(c, const Duration(seconds: 5), 'hang-up after drop');
    await _sleep(const Duration(milliseconds: 500));
    expectOwnEndCall(beforeEnd, c, 'hang-up after drop');
  }

  // ---------------------------------------------------------------- incoming

  Future<(Map<dynamic, dynamic>, int)> waitIncoming() async {
    final DateTime end = DateTime.now().add(const Duration(seconds: 180));
    while (DateTime.now().isBefore(end)) {
      final List<_Rec> all = sig.items;
      for (int i = sig.newCallCursor; i < all.length; i++) {
        final _Rec r = all[i];
        if (r.outgoing || r.event != 'newCall' || r.data is! Map) continue;
        sig.newCallCursor = i + 1;
        final Map<dynamic, dynamic> d = r.data as Map;
        final String caller = _s(d['callerId'] ?? d['remoteUserId']);
        if (caller != kPeer) {
          _log('ignoring newCall from $caller (not PEER_USER_ID)');
          continue;
        }
        // CallingController._onNewCall / NotificationServices: Ringing.
        _emit('CallingStatus', <String, dynamic>{
          'callId': _s(d['callId']),
          'remoteUserId': int.tryParse(caller) ?? 0,
          'callingStatus': 'Ringing',
        });
        return (d, i);
      }
      sig.newCallCursor = all.length;
      await _sleep(const Duration(milliseconds: 50));
    }
    fail('no newCall from the bot within 180 s');
  }

  String sessionOf(Map<dynamic, dynamic> d) {
    dynamic callData = d['callData'];
    if (callData is String) {
      try {
        callData = jsonDecode(callData);
      } catch (_) {
        callData = null; // compressed / other format
      }
    }
    final dynamic v = d['sessionId'] ??
        d['session_id'] ??
        (callData is Map ? (callData['sessionId'] ?? callData['session_id']) : null);
    final String s = _s(v);
    return s == 'null' ? '' : s;
  }

  Future<void> incomingAccept() async {
    final (Map<dynamic, dynamic> d, int from) = await waitIncoming();
    final String sid = sessionOf(d);
    final dynamic offer = d['sdpOffer'] ?? d['offer'];
    try {
      // CallKit accept (foreground path in doc 02 §5.1).
      final CallingController c = _openCall(incomingCallArgs(
        callerId: kPeer,
        callId: d['callId'],
        sessionId: sid.isEmpty ? null : sid,
        isVideo: false,
        callerName: d['callerName'],
        profileImage: null,
        offer: offer,
        fromCallKit: true,
      ));
      await _sleep(const Duration(milliseconds: 500));
      expect(c.isCallLive, isTrue, reason: 'incoming controller ended early');

      // calling_controller.dart `_setupPeer`, incoming branches.
      if (offer == null) {
        final int acceptMark = sig.mark();
        _emit('acceptCallFromCallKit', <String, dynamic>{
          'callerId': c.callerId,
          'sessionId': CallSessionState.sessionId ?? (sid.isEmpty ? null : sid),
          'callId': c.callId,
          'receiverId': Global.storageServices.get(PrefConst.userId),
        });
        final _Rec? o = await sig.wait('sdpOfferFromCaller',
            from: acceptMark, timeout: const Duration(seconds: 30));
        expect(o, isNotNull,
            reason: 'no sdpOfferFromCaller after acceptCallFromCallKit');
        final Map<dynamic, dynamic> od = o!.data as Map;
        expect(od['sdpOffer'] ?? od['offer'], isNotNull,
            reason: 'sdpOfferFromCaller without an offer');
        c.callId = od['callId'] ?? c.callId;
      }
      _emit('IceCandidate',
          <String, dynamic>{'remoteUserId': c.callerId, 'iceCandidate': _fakeIce});
      _emit('answerCall', <String, dynamic>{
        'callId': c.callId,
        'callerId': c.callerId,
        'sdpAnswer': _fakeSdp('answer'),
      });

      // Bot: holds kBotHold s after callAnswered, then endCall.
      await _staysTrue(() => c.isCallLive,
          const Duration(seconds: kBotHold - 1 > 0 ? kBotHold - 1 : 0),
          'incoming call ended before the bot hung up');
      await expectReleased(
          c, const Duration(seconds: 40), 'bot hang-up (incoming)');
      expect(
        sig.since(from, outgoing: false).any((r) =>
            r.event == 'callEnded' || r.event == 'endCall'),
        isTrue,
        reason: 'incoming: no callEnded after the bot hung up',
      );
      expectNoOwnEndCall(from, 'incoming accept');
    } finally {
      await CallKitService.dismissAll(); // system UI shown by CallKitService
    }
  }

  Future<void> incomingDecline() async {
    final (Map<dynamic, dynamic> d, int from) = await waitIncoming();
    try {
      await _sleep(const Duration(seconds: 1));
      // IncomingCallController.rejectCall / CallKit decline payload.
      _emit('rejectCall', rejectCallPayload(callId: d['callId'], callerId: kPeer));
      await _sleep(const Duration(seconds: 3));
      expect(sig.since(from, event: 'rejectCall', outgoing: true), hasLength(1),
          reason: 'rejectCall not sent');
      expect(
        sig.since(from, event: 'sdpOfferFromCaller', outgoing: false),
        isEmpty,
        reason: 'server sent an offer for a declined call',
      );
    } finally {
      await CallKitService.dismissAll();
    }
  }

  // ---------------------------------------------------------------- cases

  final Map<String, Future<void> Function()> cases =
      <String, Future<void> Function()>{
    'outgoing-answer': outgoingAnswer,
    'outgoing-reject': () => outgoingDeclined('reject'),
    'outgoing-busy': () => outgoingDeclined('busy'),
    'outgoing-timeout': outgoingTimeout,
    'outgoing-peer-ends': outgoingPeerEnds,
    'peer-drop': peerDrop,
    'app-drop': appDrop,
    'incoming-accept': incomingAccept,
    'incoming-decline': incomingDecline,
  };

  group('1:1 call signaling E2E (staging, bot = scripts/call_qa)', () {
    for (final String name in kAllCases) {
      testWidgets(
        '$name x$kRuns',
        (WidgetTester t) async {
          await setUpApp();
          final List<String> failures = <String>[];
          try {
            for (int run = 1; run <= kRuns; run++) {
              _log('==== $name run $run/$kRuns ====');
              try {
                await cases[name]!();
                _log('PASS $name run $run/$kRuns');
              } catch (e) {
                failures.add('run $run: $e');
                _log('FAIL $name run $run/$kRuns: $e');
                await cleanupRun();
              }
              await _sleep(const Duration(seconds: 3));
            }
          } finally {
            await tearDownApp();
          }
          if (failures.isNotEmpty) {
            fail('$name: ${failures.length}/$kRuns run(s) failed '
                '(one failure = flaky = fail)\n${failures.join('\n')}');
          }
        },
        skip: !_selected(name),
        timeout: const Timeout(Duration(minutes: 10)),
      );
    }
  }, skip: skip);
}
