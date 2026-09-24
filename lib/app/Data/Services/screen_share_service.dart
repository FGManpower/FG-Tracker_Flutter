import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/routes/app_pages.dart';


@pragma('vm:entry-point')
void startScreenShareTaskHandler() {
  FlutterForegroundTask.setTaskHandler(ScreenShareTaskHandler());
}

class ScreenShareTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('[ScreenShareTaskHandler] Background Task Started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    log('[ScreenShareTaskHandler] Background Task Destroyed (isTimeout: $isTimeout)');
  }

  @override
  void onNotificationButtonPressed(String id) {
    log('[ScreenShareTaskHandler] Notification Button Pressed: $id');

    if (id == 'btn_stop_sharing') {
      _stopSharingFromNotification();
    } else if (id == 'btn_open_call') {
      FlutterForegroundTask.launchApp();
      _redirectToCallingScreen();
    }
  }

  @override
  void onNotificationPressed() {
    log('[ScreenShareTaskHandler] Notification Tapped');
    FlutterForegroundTask.launchApp();
    _redirectToCallingScreen();
  }

  void _redirectToCallingScreen() {
    if (Get.currentRoute != Routes.groupCallingScreen) {
      log('Navigating to Group Calling Screen');
      Get.toNamed(Routes.groupCallingScreen);
    }
  }

  void _stopSharingFromNotification() {
    try {
      _redirectToCallingScreen();
    } catch (e) {
      log('Error stopping from notification: $e');
    }
  }
}

class ScreenShareForegroundService {
  static void init() {
    if (GetPlatform.isAndroid) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'screen_share_channel_v2',
          channelName: 'Screen Sharing Service',
          channelDescription: 'Active screen sharing session notification',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          enableVibration: false,
          playSound: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
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
  }

  static Future<bool> start({required String groupName}) async {
    if (!GetPlatform.isAndroid) return true;

    try {
      final notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }

      final isRunning = await FlutterForegroundTask.isRunningService;
      if (!isRunning) {
        final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
          serviceId: 256,
          notificationTitle: 'Sharing your screen',
          notificationText: 'Sharing in $groupName • Tap to return to call',
          notificationIcon: const NotificationIcon(
            metaDataName: 'com.fg.fgtracker',
          ),
          notificationButtons: [
            const NotificationButton(
              id: 'btn_open_call',
              text: 'Return to Call',
              textColor: Color(0xFF6E5CA4),
            ),
            const NotificationButton(
              id: 'btn_stop_sharing',
              text: 'Stop Sharing',
              textColor: Color(0xFFFF3B30),
            ),
          ],
          callback: startScreenShareTaskHandler,
        );
        log('Foreground Service Start Result: $result');
      }

      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      log('Foreground Service Start Error: $e');
      return false;
    }
  }

  static Future<void> updateNotification({required String text}) async {
    if (!GetPlatform.isAndroid) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationText: text,
      );
    }
  }

  static Future<void> stop() async {
    if (!GetPlatform.isAndroid) return;

    try {
      final isRunning = await FlutterForegroundTask.isRunningService;
      if (isRunning) {
        await FlutterForegroundTask.stopService();
        log('Foreground Service Stopped');
      }
    } catch (e) {
      log('Foreground Service Stop Error: $e');
    }
  }
}