import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class WalkieNotificationManager {
  WalkieNotificationManager._();
  static final WalkieNotificationManager instance =
  WalkieNotificationManager._();

  static const int notificationId = 5001;
  static const String channelId = 'walkie_talkie_channel';
  static const String channelName = 'Walkie-Talkie Voice Activity';
  static const String channelDesc =
      'Live voice activity notifications for Walkie-Talkie';

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  final RxBool isWalkieJoined = false.obs;
  final RxBool isWalkieScreenActive = false.obs;
  final RxBool isSomeoneTalking = false.obs;
  final RxBool isNotificationVisible = false.obs;

  String? _activeGroupId;
  String? _activeGroupName;
  String? _activeSpeakerId;
  String? _activeSpeakerName;

  Timer? _durationTimer;
  int _talkSeconds = 0;
  bool _initialized = false;

  void _log(String msg) {
    log('🔔 [WALKIE_NOTIF] $msg');
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _log('Initializing WalkieNotificationManager...');

    // Request Android 13+ & iOS Notification Permissions
    await _requestPermissions();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: walkieNotificationTapBackground,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.high,
          playSound: false,
          enableVibration: false,
          showBadge: true,
        ),
      );
    }

    _log('WalkieNotificationManager initialization complete.');
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        _log('Android Notification status: $status');
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          _log('Requested Android Notification permission: $result');
        }
      } else if (Platform.isIOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _log('iOS Notification permission granted: $granted');
      }
    } catch (e) {
      _log('Error requesting notification permission: $e');
    }
  }

  void setWalkieJoined(bool value, {String? groupId, String? groupName}) {
    _log('setWalkieJoined: $value | groupId: $groupId | groupName: $groupName');
    isWalkieJoined.value = value;
    if (value) {
      _activeGroupId = groupId ?? _activeGroupId;
      _activeGroupName = groupName ?? _activeGroupName;
    } else {
      _activeGroupId = null;
      _activeGroupName = null;
      hideNotification();
      stopTalkingUi();
    }
  }

  void setWalkieScreenActive(bool value) {
    _log('setWalkieScreenActive: $value');
    isWalkieScreenActive.value = value;
    if (value) {
      hideNotification();
    }
  }

  Future<void> onSomeoneStartedTalking({
    required String speakerId,
    required String speakerName,
    required String groupId,
    required String groupName,
  }) async {
    final selfId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

    _log('onSomeoneStartedTalking => speakerId: "$speakerId", selfId: "$selfId", speakerName: "$speakerName", group: "$groupName"');

    // Rule: Don't show notification for yourself
    if (speakerId.isNotEmpty && (speakerId == selfId || speakerId == GroupWalkieService.instance.selfUserId)) {
      _log('Skipped notification: Speaker is self.');
      return;
    }

    _activeSpeakerId = speakerId;
    _activeSpeakerName = speakerName.isEmpty ? 'Someone' : speakerName;
    _activeGroupId = groupId.isEmpty ? _activeGroupId : groupId;
    _activeGroupName = groupName.isEmpty ? _activeGroupName : groupName;
    isSomeoneTalking.value = true;
    _talkSeconds = 0;

    // Rule: Foreground + Walkie Screen -> Audio only, NO notification
    if (isWalkieScreenActive.value) {
      _log('Skipped notification: User is currently on Walkie Screen.');
      hideNotification();
      return;
    }

    _log('Displaying live talking notification for $_activeSpeakerName in $_activeGroupName...');
    await _showOrUpdateTalkingNotification();
    _startDurationTimer();
  }

  Future<void> onSomeoneStoppedTalking({
    String? speakerId,
    String? speakerName,
  }) async {
    _log('onSomeoneStoppedTalking => speakerId: $speakerId');
    isSomeoneTalking.value = false;
    _stopDurationTimer();

    if (isWalkieScreenActive.value) {
      hideNotification();
      return;
    }

    if (isNotificationVisible.value) {
      final name = speakerName ?? _activeSpeakerName ?? 'Someone';
      await _showStoppedNotification(name);
      await Future.delayed(const Duration(seconds: 2));
      if (!isSomeoneTalking.value) {
        await hideNotification();
      }
    }

    _activeSpeakerId = null;
    _activeSpeakerName = null;
    _talkSeconds = 0;
  }

  void stopTalkingUi() {
    isSomeoneTalking.value = false;
    _stopDurationTimer();
    _talkSeconds = 0;
    _activeSpeakerId = null;
    _activeSpeakerName = null;
  }

  Future<void> _showOrUpdateTalkingNotification() async {
    final title = '$_activeSpeakerName is talking';
    final body = (_activeGroupName != null && _activeGroupName!.isNotEmpty)
        ? _activeGroupName!
        : 'Walkie-Talkie';
    final timerText = _formatDuration(_talkSeconds);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'open_walkie',
          'Open Walkie',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'leave_walkie',
          'Leave',
          cancelNotification: true,
          showsUserInterface: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    try {
      await _plugin.show(
        notificationId,
        title,
        '$body  •  $timerText',
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: _buildPayload(action: 'open'),
      );
      isNotificationVisible.value = true;
      _log('Notification posted successfully.');
    } catch (e) {
      _log('Error posting notification: $e');
    }
  }

  Future<void> _showStoppedNotification(String speakerName) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: false,
      autoCancel: true,
      onlyAlertOnce: true,
      showWhen: false,
    );

    try {
      await _plugin.show(
        notificationId,
        '$speakerName stopped talking',
        _activeGroupName ?? 'Walkie Group',
        const NotificationDetails(android: androidDetails),
        payload: _buildPayload(action: 'open'),
      );
    } catch (_) {}
  }

  Future<void> hideNotification() async {
    try {
      await _plugin.cancel(notificationId);
    } catch (_) {}
    isNotificationVisible.value = false;
    _stopDurationTimer();
  }

  void _startDurationTimer() {
    _stopDurationTimer();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!isSomeoneTalking.value) {
        _stopDurationTimer();
        return;
      }
      if (isWalkieScreenActive.value) {
        hideNotification();
        return;
      }
      _talkSeconds++;
      await _showOrUpdateTalkingNotification();
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _buildPayload({required String action}) {
    return [
      action,
      _activeGroupId ?? '',
      _activeGroupName ?? '',
      _activeSpeakerName ?? '',
    ].join('|');
  }

  void onNotificationTap(NotificationResponse response) {
    _log('Notification tapped! Action: ${response.actionId} | Payload: ${response.payload}');
    final actionId = response.actionId;
    final payload = response.payload ?? '';
    final parts = payload.split('|');
    final action = actionId ?? (parts.isNotEmpty ? parts[0] : 'open');
    final groupId = parts.length > 1 ? parts[1] : (_activeGroupId ?? '');
    final groupName = parts.length > 2 ? parts[2] : (_activeGroupName ?? '');

    if (action == 'leave_walkie' || action == 'leave') {
      _handleLeave(groupId);
      return;
    }

    _handleOpenWalkie(groupId: groupId, groupName: groupName);
  }

  Future<void> _handleOpenWalkie({
    required String groupId,
    required String groupName,
  }) async {
    await hideNotification();

    if (isWalkieScreenActive.value &&
        WalkieLaunchTracker.fromWalkieCall &&
        GroupWalkieService.instance.currentGroupId == groupId) {
      return;
    }

    if (groupId.isEmpty) return;

    final args = <String, dynamic>{
      'groupId': groupId,
      'groupName': groupName.isEmpty ? 'Walkie Group' : groupName,
      'fromNotification': true,
    };

    if (Get.currentRoute == Routes.groupWalkieScreen ||
        WalkieLaunchTracker.fromWalkieCall) {
      Get.offNamed(Routes.groupWalkieScreen, arguments: args);
    } else {
      Get.toNamed(Routes.groupWalkieScreen, arguments: args);
    }
  }

  Future<void> _handleLeave(String groupId) async {
    await hideNotification();
    isWalkieJoined.value = false;
    isSomeoneTalking.value = false;
    stopTalkingUi();

    try {
      await GroupWalkieService.instance.leaveGroup();
    } catch (_) {}

    if (Get.isRegistered<GroupWalkieController>()) {
      try {
        Get.find<GroupWalkieController>().reset();
      } catch (_) {}
    }

    if (isWalkieScreenActive.value) {
      isWalkieScreenActive.value = false;
      if (Get.currentRoute == Routes.groupWalkieScreen) {
        Get.back();
      }
    }
  }
}

@pragma('vm:entry-point')
void walkieNotificationTapBackground(NotificationResponse response) {
  // Required background entry point
}