import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkieAwesomeNotificationService {
  WalkieAwesomeNotificationService._();
  static final instance = WalkieAwesomeNotificationService._();

  static const int walkieNotificationId = 5001;
  static const String channelKey = 'group_walkie_channel';

  /// Tracks whether the user is currently on the Walkie screen.
  /// When true, notifications are NOT shown and any active notification is dismissed.
  static bool isWalkieScreenActive = false;
  static Map<String, dynamic>? pendingWalkiePayload;

  Timer? _sessionTimer;
  int _elapsedSeconds = 0;
  String? _activeGroupId;
  String? _activeGroupName;
  String? _currentSpeakerName;
  String? _currentSpeakerImage;
  bool _isSpeaking = false;

  bool get isInActiveSession => _activeGroupId != null;
  String? get activeGroupId => _activeGroupId;
  String? get activeGroupName => _activeGroupName;
  String? get currentSpeakerName => _currentSpeakerName;

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: 'Walkie Talkie',
          channelDescription: 'Group Walkie Call and Speaking Updates',
          defaultColor: const Color(0xFF5A35FF),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: false,
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

    try {
      final initialAction =
          await AwesomeNotifications().getInitialNotificationAction();
      if (initialAction != null) {
        await onActionReceivedMethod(initialAction);
      }
    } catch (_) {}
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final payload = action.payload ?? {};
    final groupId = payload['groupId'] ?? '';
    final groupName = payload['groupName'] ?? 'Group';
    final speakerName = payload['speakerName'] ?? '';
    final speakerImage = payload['speakerImage'] ?? '';

    if (action.buttonKeyPressed == 'WALKIE_LEAVE') {
      await instance.dismissWalkieNotification();
      if (groupId.isNotEmpty &&
          GroupWalkieService.instance.currentGroupId == groupId) {
        await GroupWalkieService.instance.leaveGroup();
      }
      if (isWalkieScreenActive && Get.currentRoute == Routes.groupWalkieScreen) {
        Get.back();
      }
    } else {
      // Tapped 'WALKIE_OPEN' or tapped anywhere on the notification card
      await instance.dismissWalkieNotification();
      if (groupId.isNotEmpty) {
        WalkieLaunchTracker.fromWalkieCall = true;
        pendingWalkiePayload = {
          "groupId": groupId,
          "groupName": groupName,
          "speakerName": speakerName,
          "speakerImage": speakerImage,
        };

        // If coming from another group, switch to the new group
        if (GroupWalkieService.instance.currentGroupId != null &&
            GroupWalkieService.instance.currentGroupId != groupId) {
          await GroupWalkieService.instance.leaveGroup();
        }

        // Join the walkie session
        await GroupWalkieService.instance.joinGroup(groupId);

        navigateToWalkieScreen({
          "groupId": groupId,
          "groupName": groupName,
          "speakerName": speakerName,
          "speakerImage": speakerImage,
        });
      }
    }
  }

  static void navigateToWalkieScreen(Map<String, dynamic> arguments) {
    void doNavigate() {
      if (Get.currentRoute == Routes.groupWalkieScreen) {
        Get.offNamed(
          Routes.groupWalkieScreen,
          arguments: arguments,
        );
      } else {
        Get.toNamed(
          Routes.groupWalkieScreen,
          arguments: arguments,
        );
      }
    }

    if (Get.context != null) {
      doNavigate();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        doNavigate();
      });
    }
  }

  /// Shows or updates the Call-style smart notification.
  /// Does NOT show notification if the user is currently on the Walkie screen for this group.
  Future<void> showTalkingNotification({
    required String groupId,
    required String groupName,
    required String speakerName,
    String? speakerImage,
    bool isSpeaking = true,
  }) async {
    // If the user is currently active on the Walkie screen for this group, DO NOT show notification!
    if (isWalkieScreenActive &&
        GroupWalkieService.instance.currentGroupId == groupId) {
      await dismissWalkieNotification();
      return;
    }

    final isNewSpeakerOrGroup = _activeGroupId != groupId ||
        _currentSpeakerName != speakerName ||
        !_isSpeaking;

    _activeGroupId = groupId;
    _activeGroupName = groupName.isNotEmpty ? groupName : 'FG Manpower Group';
    _currentSpeakerName = speakerName.isNotEmpty ? speakerName : 'Someone';
    _currentSpeakerImage = speakerImage;
    _isSpeaking = isSpeaking;

    if (isSpeaking) {
      if (isNewSpeakerOrGroup) {
        _elapsedSeconds = 0;
      }
      _sessionTimer?.cancel();
      await _renderNotification();

      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (isWalkieScreenActive &&
            GroupWalkieService.instance.currentGroupId == _activeGroupId) {
          await dismissWalkieNotification();
          return;
        }
        _elapsedSeconds++;
        await _renderNotification();
      });
    } else {
      _sessionTimer?.cancel();
      _sessionTimer = null;
      await _renderNotification();
    }
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  Future<void> _renderNotification() async {
    if (_activeGroupId == null) return;
    if (isWalkieScreenActive &&
        GroupWalkieService.instance.currentGroupId == _activeGroupId) {
      await dismissWalkieNotification();
      return;
    }

    final timerStr = _formatTimer(_elapsedSeconds);
    final speaker = _currentSpeakerName ?? 'Someone';
    final group = _activeGroupName ?? 'FG Manpower Group';

    final titleText = _isSpeaking
        ? "$speaker is talking"
        : "$speaker stopped talking";

    final bodyText = "$group\n🎙 $timerStr";

    final hasValidImage = _currentSpeakerImage != null &&
        _currentSpeakerImage!.isNotEmpty &&
        _currentSpeakerImage!.startsWith('http');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: walkieNotificationId,
        channelKey: channelKey,
        title: titleText,
        body: bodyText,
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Call,
        actionType: ActionType.Default,
        autoDismissible: true,
        wakeUpScreen: true,
        largeIcon: hasValidImage
            ? _currentSpeakerImage
            : 'asset://assets/icons/walkie-talkie.png',
        color: const Color(0xFF5A35FF),
        locked: false,
        payload: {
          'groupId': _activeGroupId ?? '',
          'groupName': _activeGroupName ?? '',
          'speakerName': _currentSpeakerName ?? '',
          'speakerImage': _currentSpeakerImage ?? '',
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'WALKIE_OPEN',
          label: 'Go to Walkie Screen',
          actionType: ActionType.Default,
          color: const Color(0xFF5A35FF),
        ),
        NotificationActionButton(
          key: 'WALKIE_LEAVE',
          label: 'Leave',
          actionType: ActionType.DismissAction,
          isDangerousOption: true,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  /// Backward-compatible startActiveSession method
  Future<void> startActiveSession({
    required String groupId,
    required String groupName,
    String? speakerName,
  }) async {
    _activeGroupId = groupId;
    _activeGroupName = groupName.isNotEmpty ? groupName : 'FG Manpower Group';

    // If user is already on the walkie screen, don't show notifications
    if (isWalkieScreenActive) {
      await dismissWalkieNotification();
      return;
    }

    await showTalkingNotification(
      groupId: groupId,
      groupName: groupName,
      speakerName: speakerName ?? 'Active Session',
      isSpeaking: true,
    );
  }

  Future<void> exitActiveSession() async {
    await dismissWalkieNotification();
    _activeGroupId = null;
    _activeGroupName = null;
    _currentSpeakerName = null;
    _currentSpeakerImage = null;
    _isSpeaking = false;
    await GroupWalkieService.instance.leaveGroup();
  }

  Future<void> dismissWalkieNotification() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _elapsedSeconds = 0;
    await AwesomeNotifications().cancel(walkieNotificationId);
  }

  Future<void> dismissIncomingNotification() async {
    await dismissWalkieNotification();
  }

  Future<void> dismissAll() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _elapsedSeconds = 0;
    _activeGroupId = null;
    _activeGroupName = null;
    _currentSpeakerName = null;
    _currentSpeakerImage = null;
    _isSpeaking = false;
    await AwesomeNotifications().cancel(walkieNotificationId);
    // Also cancel legacy notification IDs if any exist
    await AwesomeNotifications().cancel(7001);
    await AwesomeNotifications().cancel(7002);
  }
}
