import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkieAwesomeNotificationService {
  WalkieAwesomeNotificationService._();
  static final instance = WalkieAwesomeNotificationService._();

  static const int incomingNotificationId = 7001;
  static const int activeNotificationId = 7002;
  static const String channelKey = 'group_walkie_channel';

  Timer? _sessionTimer;
  int _elapsedSeconds = 0;
  String? _activeGroupId;
  String? _activeGroupName;

  bool get isInActiveSession => _activeGroupId != null;
  String? get activeGroupId => _activeGroupId;
  String? get activeGroupName => _activeGroupName;

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: 'Group Walkie',
          channelDescription: 'Group Walkie Call and Session Notifications',
          defaultColor: const Color(0xFF5A35FF),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true,
          locked: false,
        ),
      ],
      debug: false,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final payload = action.payload ?? {};
    final groupId = payload['groupId'] ?? '';
    final groupName = payload['groupName'] ?? 'Group';
    final speakerName = payload['speakerName'] ?? '';
    final speakerImage = payload['speakerImage'] ?? '';

    if (action.buttonKeyPressed == 'WALKIE_JOIN') {
      await instance.dismissIncomingNotification();
      if (groupId.isNotEmpty) {
        await instance.startActiveSession(groupId: groupId, groupName: groupName);
        if (Get.currentRoute != Routes.groupWalkieScreen) {
          Get.to(
            () => const GroupWalkieScreen(),
            routeName: Routes.groupWalkieScreen,
            arguments: {
              "groupId": groupId,
              "groupName": groupName,
              "speakerName": speakerName,
              "speakerImage": speakerImage,
            },
          );
        }
      }
    } else if (action.buttonKeyPressed == 'WALKIE_REJECT') {
      await instance.dismissIncomingNotification();
    } else if (action.buttonKeyPressed == 'WALKIE_EXIT') {
      await instance.exitActiveSession();
      if (Get.currentRoute == Routes.groupWalkieScreen) {
        Get.back();
      }
    } else {
      if (groupId.isNotEmpty && Get.currentRoute != Routes.groupWalkieScreen) {
        Get.to(
          () => const GroupWalkieScreen(),
          routeName: Routes.groupWalkieScreen,
          arguments: {
            "groupId": groupId,
            "groupName": groupName,
            "speakerName": speakerName,
            "speakerImage": speakerImage,
          },
        );
      }
    }
  }

  Future<void> showIncomingCallNotification({
    required String groupId,
    required String groupName,
    String? speakerName,
    String? speakerImage,
  }) async {
    if (_activeGroupId == groupId) return;

    final hasValidSpeakerImage = speakerImage != null &&
        speakerImage.isNotEmpty &&
        speakerImage.startsWith('http');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: incomingNotificationId,
        channelKey: channelKey,
        title: 'Group-Walkie',
        body: groupName.isNotEmpty ? groupName : 'FG-Manpower',
        summary: 'Incoming Walkie',
        category: NotificationCategory.Call,
        largeIcon: hasValidSpeakerImage
            ? speakerImage
            : 'asset://assets/icons/walkie-talkie.png',
        color: const Color(0xFF5A35FF),
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        payload: {
          'groupId': groupId,
          'groupName': groupName,
          'speakerName': speakerName ?? '',
          'speakerImage': speakerImage ?? '',
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'WALKIE_JOIN',
          label: 'Join',
          actionType: ActionType.Default,
          color: Color(0xFF22C55E),
        ),
        NotificationActionButton(
          key: 'WALKIE_REJECT',
          label: 'Reject',
          actionType: ActionType.DismissAction,
          isDangerousOption: true,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Future<void> startActiveSession({
    required String groupId,
    required String groupName,
  }) async {
    _activeGroupId = groupId;
    _activeGroupName = groupName.isNotEmpty ? groupName : 'FG-Manpower';
    _elapsedSeconds = 0;

    await GroupWalkieService.instance.joinGroup(groupId);

    _sessionTimer?.cancel();
    await _updateActiveNotification();

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _elapsedSeconds++;
      await _updateActiveNotification();
    });
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${s.toString().padLeft(2, '0')}:000";
  }

  Future<void> _updateActiveNotification() async {
    if (_activeGroupId == null) return;

    final timerLabel = _formatTimer(_elapsedSeconds);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: activeNotificationId,
        channelKey: channelKey,
        title: 'Group-Walkie',
        body: _activeGroupName ?? 'FG-Manpower',
        summary: 'Live Session',
        category: NotificationCategory.Call,
        largeIcon: 'asset://assets/icons/walkie-talkie.png',
        color: const Color(0xFF5A35FF),
        autoDismissible: false,
        locked: true,
        payload: {
          'groupId': _activeGroupId ?? '',
          'groupName': _activeGroupName ?? '',
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'WALKIE_TIMER',
          label: '⏱️ $timerLabel',
          actionType: ActionType.KeepOnTop,
          color: const Color(0xFF5A35FF),
        ),
        NotificationActionButton(
          key: 'WALKIE_EXIT',
          label: 'Exit',
          actionType: ActionType.Default,
          isDangerousOption: true,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Future<void> exitActiveSession() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _elapsedSeconds = 0;
    _activeGroupId = null;
    _activeGroupName = null;

    await AwesomeNotifications().cancel(activeNotificationId);
    await GroupWalkieService.instance.leaveGroup();
  }

  Future<void> dismissIncomingNotification() async {
    await AwesomeNotifications().cancel(incomingNotificationId);
  }

  Future<void> dismissAll() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _elapsedSeconds = 0;
    _activeGroupId = null;
    _activeGroupName = null;
    await AwesomeNotifications().cancel(incomingNotificationId);
    await AwesomeNotifications().cancel(activeNotificationId);
  }
}
