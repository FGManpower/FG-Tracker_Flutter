import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// System picture-in-picture for 1:1 video calls (BUG-CALL-16), Android
/// only. Native side: `MainActivity.java` (channel `com.fgtracker/pip`).
///
/// While "auto PiP" is on, leaving the app (Home / Recents) puts the call in
/// a floating window (Android 8+; Android 12+ uses setAutoEnterEnabled).
/// It is on only for a connected video call whose screen is open (not
/// minimized to the in-app bubble, not screen sharing).
///
/// iOS: video PiP with the camera needs Apple's multitasking-camera
/// entitlement and an AVPictureInPictureController video-call view; not
/// done (see doc 02 §7).
class CallPip {
  CallPip._();

  static const MethodChannel _channel = MethodChannel('com.fgtracker/pip');

  /// True while the activity is in the PiP window (hide the controls).
  static final RxBool inPip = false.obs;

  static bool _bound = false;
  static bool _auto = false;

  static bool shouldAutoPip({
    required bool video,
    required bool connected,
    required bool minimized,
    required bool screenSharing,
  }) =>
      video && connected && !minimized && !screenSharing;

  static void _bind() {
    if (_bound) return;
    _bound = true;
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onPipChanged') inPip.value = call.arguments == true;
      return null;
    });
  }

  static Future<void> setAuto(bool enabled) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (enabled == _auto) return;
    _auto = enabled;
    _bind();
    try {
      await _channel.invokeMethod<void>('setAutoPip', <String, dynamic>{
        'enabled': enabled,
        'width': 9,
        'height': 16,
      });
    } catch (_) {
      // Older app build without the native side: no PiP, nothing else.
    }
    if (!enabled) inPip.value = false;
  }
}
