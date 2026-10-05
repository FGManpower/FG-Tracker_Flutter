import 'dart:async';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Global call-style walkie notification manager.
/// One fixed notification ID, live timer, no spam.
class WalkieNotificationManager {
  WalkieNotificationManager._();
  static final WalkieNotificationManager instance =
  WalkieNotificationManager._();

  static const int notificationId = 5001;
  static const String channelId = 'walkie_talkie_channel';
  static const String channelName = 'Walkie-Talkie';
  static const String channelDesc =
      'Live walkie-talkie voice activity notifications';

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // ── Frontend state flags (from your screenshot) ──────────────────────────
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

  // ── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

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
      await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
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
  }


  void handleLaunchPayload(NotificationResponse? response) {
    if (response != null) onNotificationTap(response);
  }

  // ── Public state setters (call from screen / service) ────────────────────
  void setWalkieJoined(bool value, {String? groupId, String? groupName}) {
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
    isWalkieScreenActive.value = value;
    // Rule 1 & 4: on walkie screen → never show notification
    if (value) {
      hideNotification();
    }
  }

  // ── Core: someone started talking ────────────────────────────────────────
  Future<void> onSomeoneStartedTalking({
    required String speakerId,
    required String speakerName,
    required String groupId,
    required String groupName,
  }) async {
    final selfId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

    // Sender side: never notify yourself
    if (speakerId.isNotEmpty && speakerId == selfId) return;

    _activeSpeakerId = speakerId;
    _activeSpeakerName = speakerName.isEmpty ? 'Someone' : speakerName;
    _activeGroupId = groupId;
    _activeGroupName = groupName.isEmpty ? 'Walkie Group' : groupName;
    isSomeoneTalking.value = true;
    _talkSeconds = 0;

    // State 1: Foreground + Walkie Screen → audio only, NO notification
    if (isWalkieScreenActive.value) {
      hideNotification();
      return;
    }

    // States 2, 3, 4: show / update ONE notification with live timer
    await _showOrUpdateTalkingNotification();
    _startDurationTimer();
  }

  // ── Core: talking stopped ────────────────────────────────────────────────
  Future<void> onSomeoneStoppedTalking({
    String? speakerId,
    String? speakerName,
  }) async {
    isSomeoneTalking.value = false;
    _stopDurationTimer();

    if (isWalkieScreenActive.value) {
      hideNotification();
      return;
    }

    // Brief "stopped talking" state, then clear
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

  // ── Notification builders ────────────────────────────────────────────────
  Future<void> _showOrUpdateTalkingNotification() async {
    final title = '$_activeSpeakerName is talking';
    final body = _activeGroupName ?? 'Walkie Group';
    final timerText = _formatDuration(_talkSeconds);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true, // critical: no sound/vibrate on every update
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

    await _plugin.show(
      notificationId,
      title,
      '$body  •  $timerText',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: _buildPayload(action: 'open'),
    );

    isNotificationVisible.value = true;
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

    await _plugin.show(
      notificationId,
      '$speakerName stopped talking',
      _activeGroupName ?? 'Walkie Group',
      const NotificationDetails(android: androidDetails),
      payload: _buildPayload(action: 'open'),
    );
  }

  Future<void> hideNotification() async {
    try {
      await _plugin.cancel(notificationId);
    } catch (_) {}
    isNotificationVisible.value = false;
    _stopDurationTimer();
  }

  // ── Live duration timer (updates SAME notification ID) ───────────────────
  void _startDurationTimer() {
    _stopDurationTimer();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!isSomeoneTalking.value) {
        _stopDurationTimer();
        return;
      }
      // Never update notification while user is on walkie screen
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

  // ── Tap / action handlers ────────────────────────────────────────────────
  void onNotificationTap(NotificationResponse response) {
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

    // Default / open_walkie
    _handleOpenWalkie(groupId: groupId, groupName: groupName);
  }

  Future<void> _handleOpenWalkie({
    required String groupId,
    required String groupName,
  }) async {
    await hideNotification();

    // Already on walkie screen for same group
    if (isWalkieScreenActive.value &&
        WalkieLaunchTracker.fromWalkieCall &&
        GroupWalkieService.instance.currentGroupId == groupId) {
      return;
    }

    // Navigate to walkie screen
    if (groupId.isEmpty) return;

    final args = <String, dynamic>{
      'groupId': groupId,
      'groupName': groupName.isEmpty ? 'Walkie Group' : groupName,
      'fromNotification': true,
    };

    // If walkie screen already in stack, just bring it / replace
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

    // If user is currently on walkie screen, pop it
    if (isWalkieScreenActive.value) {
      isWalkieScreenActive.value = false;
      if (Get.currentRoute == Routes.groupWalkieScreen) {
        Get.back();
      }
    }
  }

  // ── App lifecycle helpers ────────────────────────────────────────────────
  /// Call from WidgetsBindingObserver when app resumes / pauses
  void onAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // If user opened app from killed/background and walkie screen not open,
      // keep notification if someone still talking
      if (isWalkieScreenActive.value) {
        hideNotification();
      }
    }
  }

  void disposeManager() {
    _stopDurationTimer();
    hideNotification();
  }
}

/// Top-level background tap callback (required by plugin)
@pragma('vm:entry-point')
void walkieNotificationTapBackground(NotificationResponse response) {
  // Plugin will re-deliver via onDidReceiveNotificationResponse when app opens
}