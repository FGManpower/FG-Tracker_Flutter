import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';

@pragma('vm:entry-point')
void startWalkieTaskHandler() {
  FlutterForegroundTask.setTaskHandler(WalkieTaskHandler());
}

class WalkieTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('[WalkieTaskHandler] Walkie-Talkie Foreground Service Started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    log('[WalkieTaskHandler] Walkie-Talkie Foreground Service Stopped');
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'btn_open_walkie') {
      FlutterForegroundTask.sendDataToMain('open_walkie');
      FlutterForegroundTask.launchApp(Routes.groupWalkieScreen);
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.sendDataToMain('open_walkie');
    FlutterForegroundTask.launchApp(Routes.groupWalkieScreen);
  }
}

class WalkieForegroundService {
  static void init() {
    if (GetPlatform.isAndroid) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'walkie_talkie_live_channel',
          channelName: 'Walkie-Talkie Live Audio',
          channelDescription: 'Maintains live voice communication and background mic capture',
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

      FlutterForegroundTask.addTaskDataCallback((data) {
        if (data == 'open_walkie') {
          if (Get.currentRoute != Routes.groupWalkieScreen) {
            final groupId = GroupWalkieService.instance.currentGroupId;
            if (groupId != null && groupId.isNotEmpty) {
              Get.toNamed(
                Routes.groupWalkieScreen,
                arguments: {
                  "groupId": groupId,
                  "groupName": "Walkie-Talkie",
                  "autoOpened": true,
                },
              );
            }
          }
        }
      });
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
          serviceId: 501,
          notificationTitle: 'Walkie-Talkie Active',
          notificationText: 'Connected in $groupName • Live Audio Stream',
          notificationIcon: const NotificationIcon(
            metaDataName: 'com.fg.fgtracker',
          ),
          notificationButtons: [
            const NotificationButton(
              id: 'btn_open_walkie',
              text: 'Open Walkie',
              textColor: Color(0xFF6E5CA4),
            ),
          ],
          callback: startWalkieTaskHandler,
        );
        log('Walkie Foreground Service Start Result: $result');
      } else {
        await updateNotification(
          text: 'Connected in $groupName • Live Audio Stream',
        );
      }

      return true;
    } catch (e) {
      log('Walkie Foreground Service Start Error: $e');
      return false;
    }
  }

  static Future<void> updateNotification({required String text}) async {
    if (!GetPlatform.isAndroid) return;
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(
          notificationText: text,
        );
      }
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (!GetPlatform.isAndroid) return;
    try {
      final isRunning = await FlutterForegroundTask.isRunningService;
      if (isRunning) {
        await FlutterForegroundTask.stopService();
        log('Walkie Foreground Service Stopped');
      }
    } catch (e) {
      log('Walkie Foreground Service Stop Error: $e');
    }
  }
}
