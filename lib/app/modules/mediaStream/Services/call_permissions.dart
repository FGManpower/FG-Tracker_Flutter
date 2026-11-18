import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mic / camera state as the call flow needs it.
/// - [granted]: usable now.
/// - [canAsk]: the system dialog can still be shown.
/// - [blocked]: only Settings can change it (permanently denied, restricted,
///   or iOS after one "Don't Allow").
enum CallPermStatus { granted, canAsk, blocked }

/// What the call flow must do next (doc 02 §5, P-01 … P-12).
enum CallPermStep {
  /// Everything needed is granted: start / join the call.
  start,

  /// Incoming video call without camera: join as voice, camera off,
  /// still show the other side's video (P-06).
  startCameraOff,

  /// Ask for the microphone (outgoing: explain first; incoming: at accept).
  askMic,

  /// Microphone blocked: only Settings can help (P-03, P-05).
  micSettings,

  /// Ask for the camera with the system dialog.
  askCamera,

  /// Outgoing video, camera not available: voice instead or Settings (P-04).
  voiceOrSettings,

  /// Incoming call: microphone refused at accept. End cleanly (P-05).
  fail,
}

/// Pure decision table. No plugins, no UI, same on Android and iOS.
class CallPermissionPolicy {
  const CallPermissionPolicy._();

  static CallPermStep decide({
    required CallPermStatus mic,
    required CallPermStatus camera,
    required bool video,
    required bool incoming,
    bool micAsked = false,
    bool cameraAsked = false,
  }) {
    if (mic == CallPermStatus.blocked) return CallPermStep.micSettings;
    if (mic == CallPermStatus.canAsk) {
      // Incoming: the caller is waiting; one system dialog, then give up.
      if (incoming && micAsked) return CallPermStep.fail;
      return CallPermStep.askMic;
    }

    // Microphone granted.
    if (!video || camera == CallPermStatus.granted) return CallPermStep.start;
    if (camera == CallPermStatus.canAsk && !cameraAsked) {
      return CallPermStep.askCamera;
    }
    return incoming ? CallPermStep.startCameraOff : CallPermStep.voiceOrSettings;
  }

  /// Turning the camera on during a call (P-07). The call always continues.
  static CallPermStep decideCameraMidCall({
    required CallPermStatus camera,
    bool cameraAsked = false,
  }) {
    if (camera == CallPermStatus.granted) return CallPermStep.start;
    if (camera == CallPermStatus.canAsk && !cameraAsked) {
      return CallPermStep.askCamera;
    }
    return CallPermStep.voiceOrSettings;
  }
}

/// Sheets the flow can show. Strings live in the ARB files.
enum CallPermSheet {
  /// P-01 / P-02: why the mic is needed, [Allow] / [Not now].
  micExplain,

  /// P-03 / P-05: mic blocked, [Open Settings] / [Cancel].
  micBlocked,

  /// P-04: outgoing video, camera blocked:
  /// [Start voice call instead] / [Open Settings] / [Cancel].
  cameraBlocked,

  /// P-07: camera blocked during a call, [Open Settings] / [Not now].
  cameraMidCall,

  /// P-10: first visit to Calls, mic never asked, [Allow] / [Not now].
  answerReady,
}

enum CallPermChoice { allow, openSettings, voiceInstead, cancel }

/// Device side of permissions. Replaced by a fake in tests.
class CallPermissionBackend {
  static CallPermissionBackend instance = CallPermissionBackend();

  static CallPermStatus map(PermissionStatus s) {
    if (s.isGranted || s.isLimited || s.isProvisional) {
      return CallPermStatus.granted;
    }
    if (s.isPermanentlyDenied || s.isRestricted) return CallPermStatus.blocked;
    return CallPermStatus.canAsk;
  }

  Future<CallPermStatus> status(Permission p) async {
    try {
      return map(await p.status);
    } catch (e) {
      if (kDebugMode) log('[CALL] permission status error $p: $e');
      return CallPermStatus.canAsk;
    }
  }

  Future<CallPermStatus> request(Permission p) async {
    try {
      return map(await p.request());
    } catch (e) {
      if (kDebugMode) log('[CALL] permission request error $p: $e');
      return CallPermStatus.canAsk;
    }
  }

  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (_) {}
  }

  /// Completes when the app comes back to the foreground (user returns from
  /// Settings, P-12), or after [timeout].
  Future<void> waitForResume({
    Duration timeout = const Duration(minutes: 2),
  }) {
    final Completer<void> done = Completer<void>();
    late final AppLifecycleListener listener;
    listener = AppLifecycleListener(
      onResume: () {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future
        .timeout(timeout, onTimeout: () {})
        .whenComplete(listener.dispose);
  }

  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Android 14+: may the incoming-call screen show over the lock screen?
  Future<bool> canUseFullScreenIntent() async {
    if (!isAndroid) return true;
    try {
      return await FlutterCallkitIncoming.canUseFullScreenIntent() != false;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestFullScreenIntent() async {
    if (!isAndroid) return;
    try {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    } catch (_) {}
  }

  static const String _micPrimerKey = 'call_mic_primer_shown_v1';

  Future<bool> micPrimerShown() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      return p.getBool(_micPrimerKey) ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<void> markMicPrimerShown() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setBool(_micPrimerKey, true);
    } catch (_) {}
  }
}

/// Shows a permission sheet and returns the user's choice.
/// Replaced in tests; the app uses `call_permission_sheet.dart`.
abstract class CallPermissionUi {
  static CallPermissionUi? instance;
  Future<CallPermChoice> show(CallPermSheet sheet);
}

/// Result of a permission run before a call starts / is joined.
class CallPermResult {
  const CallPermResult._(this.proceed, this.video, this.cameraBlocked);

  const CallPermResult.go({required bool video})
      : this._(true, video, false);
  const CallPermResult.cameraOff() : this._(true, false, true);
  const CallPermResult.stop() : this._(false, false, false);

  /// Start / join the call.
  final bool proceed;

  /// Use the camera (false: voice, or video call with own camera off).
  final bool video;

  /// The camera is off because of the permission ("Camera off · Allow").
  final bool cameraBlocked;

  @override
  String toString() =>
      'CallPermResult(proceed=$proceed video=$video cameraBlocked=$cameraBlocked)';
}

/// Runs the permission steps for every call entry point:
/// outgoing (CallService), accept (in-app / CallKit, on the call screen),
/// camera on mid-call, the "Camera off · Allow" chip and the route sheet.
class CallPermissionFlow {
  CallPermissionFlow({CallPermissionBackend? backend, CallPermissionUi? ui})
      : _b = backend ?? CallPermissionBackend.instance,
        _ui = ui ?? CallPermissionUi.instance;

  final CallPermissionBackend _b;
  final CallPermissionUi? _ui;

  static const int _maxSteps = 8;

  Future<CallPermChoice> _show(CallPermSheet s) async {
    final CallPermissionUi? ui = _ui;
    if (ui == null) return CallPermChoice.cancel;
    return ui.show(s);
  }

  /// Before an outgoing call ([incoming] false: nothing is sent to the other
  /// user until this returns `proceed`) or when joining an incoming call.
  Future<CallPermResult> beforeCall({
    required bool video,
    required bool incoming,
    Duration settingsWait = const Duration(minutes: 2),
  }) async {
    bool micAsked = false;
    bool cameraAsked = false;

    for (int i = 0; i < _maxSteps; i++) {
      final CallPermStatus mic = await _b.status(Permission.microphone);
      final CallPermStatus cam = video
          ? await _b.status(Permission.camera)
          : CallPermStatus.granted;
      final CallPermStep step = CallPermissionPolicy.decide(
        mic: mic,
        camera: cam,
        video: video,
        incoming: incoming,
        micAsked: micAsked,
        cameraAsked: cameraAsked,
      );
      if (kDebugMode) {
        log('[CALL] permission step=$step mic=$mic cam=$cam '
            'video=$video incoming=$incoming');
      }

      switch (step) {
        case CallPermStep.start:
          return CallPermResult.go(video: video);
        case CallPermStep.startCameraOff:
          return const CallPermResult.cameraOff();
        case CallPermStep.fail:
          return const CallPermResult.stop();
        case CallPermStep.askMic:
          // Outgoing: explain first (P-01 / P-02). Incoming: the user just
          // tapped Accept, ask right away on the call screen (P-05).
          if (!incoming &&
              await _show(CallPermSheet.micExplain) != CallPermChoice.allow) {
            return const CallPermResult.stop();
          }
          micAsked = true;
          await _b.request(Permission.microphone);
          break;
        case CallPermStep.micSettings:
          if (await _show(CallPermSheet.micBlocked) !=
              CallPermChoice.openSettings) {
            return const CallPermResult.stop();
          }
          await _b.openSettings();
          await _b.waitForResume(timeout: settingsWait);
          micAsked = true;
          // Loop: re-check after the user is back (P-12).
          break;
        case CallPermStep.askCamera:
          cameraAsked = true;
          await _b.request(Permission.camera);
          break;
        case CallPermStep.voiceOrSettings:
          final CallPermChoice c = await _show(CallPermSheet.cameraBlocked);
          if (c == CallPermChoice.voiceInstead) {
            return const CallPermResult.go(video: false);
          }
          if (c != CallPermChoice.openSettings) {
            return const CallPermResult.stop();
          }
          await _b.openSettings();
          await _b.waitForResume(timeout: settingsWait);
          cameraAsked = true;
          break;
      }
    }
    return const CallPermResult.stop();
  }

  /// Camera on during a call (P-07) or the "Camera off · Allow" chip (P-06).
  /// Returns true when the camera may be used. The call continues either way.
  Future<bool> cameraDuringCall({
    Duration settingsWait = const Duration(minutes: 2),
  }) async {
    bool asked = false;
    for (int i = 0; i < _maxSteps; i++) {
      final CallPermStatus cam = await _b.status(Permission.camera);
      switch (CallPermissionPolicy.decideCameraMidCall(
        camera: cam,
        cameraAsked: asked,
      )) {
        case CallPermStep.start:
          return true;
        case CallPermStep.askCamera:
          asked = true;
          await _b.request(Permission.camera);
          break;
        default:
          if (await _show(CallPermSheet.cameraMidCall) !=
              CallPermChoice.openSettings) {
            return false;
          }
          await _b.openSettings();
          await _b.waitForResume(timeout: settingsWait);
          asked = true;
      }
    }
    return false;
  }

  /// P-09: can incoming calls ring? Notifications, and on Android 14 the
  /// full-screen incoming-call screen. Never blocks calling.
  Future<bool> incomingCallsCanRing() async {
    final CallPermStatus n = await _b.status(Permission.notification);
    return n == CallPermStatus.granted && await _b.canUseFullScreenIntent();
  }

  /// "Allow" on the P-09 banner. Returns whether calls can ring now.
  Future<bool> fixIncomingRinging() async {
    final CallPermStatus n = await _b.status(Permission.notification);
    if (n == CallPermStatus.canAsk) {
      await _b.request(Permission.notification);
    } else if (n == CallPermStatus.blocked) {
      await _b.openSettings();
      await _b.waitForResume();
    }
    if (await _b.status(Permission.notification) == CallPermStatus.granted &&
        !await _b.canUseFullScreenIntent()) {
      await _b.requestFullScreenIntent();
      await _b.waitForResume(timeout: const Duration(seconds: 30));
    }
    return incomingCallsCanRing();
  }

  /// P-10: ask for the mic once, early (first visit to Calls), so a call
  /// answered from the iPhone lock screen does not wait for a dialog.
  /// Only when it was never asked; never again after the first time.
  Future<void> primeMicOnce() async {
    if (await _b.micPrimerShown()) return;
    if (await _b.status(Permission.microphone) != CallPermStatus.canAsk) {
      return;
    }
    await _b.markMicPrimerShown();
    if (await _show(CallPermSheet.answerReady) == CallPermChoice.allow) {
      await _b.request(Permission.microphone);
    }
  }

  /// Android 12+: Bluetooth audio needs BLUETOOTH_CONNECT (P-08). Asked only
  /// when the route sheet opens and a Bluetooth device is present. Returns
  /// whether Bluetooth routes may be shown. Never blocks the call.
  Future<bool> bluetoothForRoutes({required bool devicePresent}) async {
    if (!_b.isAndroid || !devicePresent) return true;
    CallPermStatus s = await _b.status(Permission.bluetoothConnect);
    if (s == CallPermStatus.canAsk) {
      s = await _b.request(Permission.bluetoothConnect);
    }
    return s == CallPermStatus.granted;
  }
}
