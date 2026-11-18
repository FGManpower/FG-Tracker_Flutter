import 'dart:developer';

import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

/// Notification button id and the message the task isolate sends to the app.
const String kCallHangUpButtonId = 'btn_call_hang_up';
const String kCallHangUpData = 'call_hang_up';

@pragma('vm:entry-point')
void startCallTaskHandler() {
  FlutterForegroundTask.setTaskHandler(CallTaskHandler());
}

/// Runs in the foreground-service isolate. It only forwards the Hang up
/// button to the app; the call itself lives in the main isolate.
class CallTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {
    if (id == kCallHangUpButtonId) {
      FlutterForegroundTask.sendDataToMain(kCallHangUpData);
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

/// Android foreground-service types for a 1:1 call (BUG-CALL-15).
///
/// `phoneCall` is not used: on Android 14 it needs an active self-managed
/// Telecom call or the default dialer, which outgoing app calls are not.
/// `camera` is only allowed when the camera permission is already granted,
/// otherwise Android 14 throws a SecurityException at start.
List<ForegroundServiceTypes> callForegroundServiceTypes({
  required bool video,
  required bool cameraGranted,
}) {
  return <ForegroundServiceTypes>[
    ForegroundServiceTypes.microphone,
    if (video && cameraGranted) ForegroundServiceTypes.camera,
  ];
}

/// The ongoing-call foreground service (Android only).
///
/// Started when the call screen opens (app still visible), not when ICE
/// connects. Only stopped by the call if the call started it, so a running
/// walkie-talkie or screen-share service is never killed by a call ending.
class CallForegroundService {
  CallForegroundService._();

  static bool _owned = false;

  /// Called when the user taps Hang up in the ongoing-call notification.
  static VoidCallback? onHangUp;

  static bool get isOwnedByCall => _owned;

  static void _onTaskData(Object data) {
    if (data == kCallHangUpData) {
      if (kDebugMode) log('[CALL] hang up from notification');
      onHangUp?.call();
    }
  }

  static Future<void> start({required bool video}) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      // Same check the old call code used. Calling init() again would
      // overwrite the walkie-talkie channel options.
      // ignore: invalid_use_of_visible_for_testing_member
      if (!FlutterForegroundTask.isInitialized) {
        FlutterForegroundTask.init(
          androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'fgtracker_call_service',
            channelName: appL10n.call_ongoingChannelName,
            channelDescription: appL10n.call_ongoingChannelDescription,
            channelImportance: NotificationChannelImportance.LOW,
            priority: NotificationPriority.LOW,
          ),
          iosNotificationOptions: const IOSNotificationOptions(
            showNotification: false,
            playSound: false,
          ),
          foregroundTaskOptions: ForegroundTaskOptions(
            eventAction: ForegroundTaskEventAction.nothing(),
            autoRunOnBoot: false,
            allowWakeLock: true,
            allowWifiLock: true,
          ),
        );
      }

      // Needed so the Hang up button reaches this isolate.
      FlutterForegroundTask.initCommunicationPort();
      FlutterForegroundTask.addTaskDataCallback(_onTaskData);

      if (await FlutterForegroundTask.isRunningService) {
        // Walkie-talkie or screen share already runs the service; it keeps
        // the process alive. Do not take it over and do not stop it later.
        if (kDebugMode) log('[CALL] FGS already running (not owned by call)');
        return;
      }

      final bool cameraGranted = video && await Permission.camera.isGranted;
      final List<ForegroundServiceTypes> types = callForegroundServiceTypes(
        video: video,
        cameraGranted: cameraGranted,
      );

      ServiceRequestResult result = await _startWith(video, types);
      if (result is ServiceRequestFailure && types.length > 1) {
        if (kDebugMode) {
          log('[CALL] FGS with camera failed, retry microphone only');
        }
        result = await _startWith(
          video,
          const <ForegroundServiceTypes>[ForegroundServiceTypes.microphone],
        );
      }
      _owned = result is ServiceRequestSuccess;
      if (kDebugMode) log('[CALL] FGS start types=$types result=$result');
    } catch (e) {
      if (kDebugMode) log('[CALL] FGS start error: $e');
    }
  }

  static Future<ServiceRequestResult> _startWith(
    bool video,
    List<ForegroundServiceTypes> types,
  ) {
    return FlutterForegroundTask.startService(
      serviceId: 9910,
      serviceTypes: types,
      notificationTitle: video ? appL10n.call_kindVideo : appL10n.call_kindAudio,
      notificationText: appL10n.call_inCall,
      notificationButtons: <NotificationButton>[
        NotificationButton(
          id: kCallHangUpButtonId,
          text: appL10n.call_endCall,
          textColor: const Color(0xFFFF3B30),
        ),
      ],
      callback: startCallTaskHandler,
    );
  }

  /// Screen share replaces the service with its own (mediaProjection).
  static void yieldToScreenShare() => _owned = false;

  static Future<void> stop() async {
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    if (!_owned) return;
    _owned = false;
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      if (kDebugMode) log('[CALL] FGS stop error: $e');
    }
  }
}
