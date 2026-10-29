import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/call_model.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'CallStateTracker.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_invite_dialog.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Services/walkie_notification_manager.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:walkie_custom_notification/walkie_custom_notification.dart';

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  final action = (notificationResponse.actionId ?? '').toUpperCase();
  if (action == firebaseNotificationServices.walkieCancelActionId ||
      action == firebaseNotificationServices.walkieDeclineActionId ||
      action.contains('CANCEL') ||
      action.contains('DECLINE') ||
      action.contains('REJECT')) {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.cancel(notificationResponse.id ?? 502);
    await plugin.cancel(502);
    try {
      if (notificationResponse.payload != null &&
          notificationResponse.payload!.isNotEmpty) {
        final data = jsonDecode(notificationResponse.payload!);
        final groupId = (data['groupId'] ?? data['group_id'] ?? '')?.toString();
        if (groupId != null && groupId.isNotEmpty) {
          GroupWalkieService.instance.socket?.emit('decline_walkie_invite', {
            'groupId': groupId,
          });
          GroupWalkieService.instance.socket?.emit('walkie_invite_declined', {
            'groupId': groupId,
          });
        }
      }
    } catch (_) {}
  }
}

class firebaseNotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final notificationCtr = Get.put(NotificationController());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static String fcmToken = "";
  static RemoteMessage? pendingInitialMessage;

  static const String walkieAcceptActionId = 'WALKIE_ACCEPT';
  static const String walkieDeclineActionId = 'WALKIE_DECLINE';
  static const String walkieCancelActionId = 'WALKIE_CANCEL';
  static const String walkieCategoryIdentifier = 'walkie_invite_category';

  static final Map<String, int> _recentWalkieEvents = <String, int>{};
  static bool isDuplicateWalkieEvent(String eventKey,
      {int debounceSeconds = 3}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _recentWalkieEvents.removeWhere((_, time) => now - time > 15000);
    if (_recentWalkieEvents.containsKey(eventKey)) {
      final prevTime = _recentWalkieEvents[eventKey]!;
      if (now - prevTime < (debounceSeconds * 1000)) {
        return true;
      }
    }
    _recentWalkieEvents[eventKey] = now;
    return false;
  }

  static DarwinInitializationSettings createDarwinSettings() {
    final darwinNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'WALKIE_INVITE',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            walkieAcceptActionId,
            'Accept',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            walkieCancelActionId,
            'Cancel',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
      DarwinNotificationCategory(
        walkieCategoryIdentifier,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            walkieAcceptActionId,
            'Accept',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            walkieCancelActionId,
            'Cancel',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
    ];

    return DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: darwinNotificationCategories,
    );
  }

  static void onNotificationResponse(NotificationResponse payload) async {
    final action = (payload.actionId ?? '').toUpperCase();
    if (action == walkieCancelActionId ||
        action == walkieDeclineActionId ||
        action.contains('CANCEL') ||
        action.contains('DECLINE') ||
        action.contains('REJECT')) {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancel(payload.id ?? 502);
      await plugin.cancel(502);
      try {
        if (payload.payload != null && payload.payload!.isNotEmpty) {
          final data = jsonDecode(payload.payload!);
          final groupId =
              (data['groupId'] ?? data['group_id'] ?? '')?.toString();
          if (groupId != null && groupId.isNotEmpty) {
            final myId = GroupWalkieService.instance.selfUserId ??
                Global.storageServices.get(PrefConst.userId)?.toString() ??
                '';
            final myName =
                Global.storageServices.get(PrefConst.userName)?.toString() ??
                    'A member';
            GroupWalkieService.instance.socket?.emit('decline_walkie_invite', {
              'groupId': groupId,
              'userId': myId,
              'userName': myName,
              'name': myName,
            });
            GroupWalkieService.instance.socket?.emit('walkie_invite_declined', {
              'groupId': groupId,
              'userId': myId,
              'userName': myName,
              'name': myName,
            });
          }
        }
      } catch (_) {}
      return;
    }

    if (payload.payload != null && payload.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(payload.payload!);
        final isWalkie = (data['screen_name'] == 'group_walkie' ||
            data['screenName'] == 'group_walkie' ||
            data['screen_name'] == 'groupWalkie' ||
            data['groupId'] != null ||
            data['group_id'] != null);

        if (isWalkie) {
          final plugin = FlutterLocalNotificationsPlugin();
          await plugin.cancel(payload.id ?? 502);
          await plugin.cancel(502);

          final groupId =
              (data['groupId'] ?? data['group_id'] ?? '')?.toString() ?? '';
          final groupName =
              (data['groupName'] ?? data['group_name'] ?? 'Walkie-Talkie')
                      ?.toString() ??
                  'Walkie-Talkie';
          final speakerName =
              (data['speakerName'] ?? data['speaker_name'] ?? 'Someone')
                      ?.toString() ??
                  'Someone';
          final speakerImage =
              (data['speakerImage'] ?? data['speaker_image'] ?? '')
                      ?.toString() ??
                  '';

          if (groupId.isNotEmpty) {
            WalkieLaunchTracker.fromWalkieCall = true;
            log("🔔 [onNotificationResponse] Walkie notification tapped -> navigating directly to walkie screen: groupId=$groupId");
            Future.delayed(const Duration(milliseconds: 300), () {
              navigateToWalkieScreen(
                groupId: groupId,
                groupName: groupName,
                speakerName: speakerName,
                speakerImage: speakerImage,
              );
            });
            return;
          }
        }

        final ctx =
            ContextUtility.navigatorkey.currentState?.context ?? Get.context;
        if (ctx != null) {
          firebaseNotificationServices().handleMessage(
            ctx,
            RemoteMessage(data: Map<String, dynamic>.from(data)),
            type: "frombackground",
          );
        }
        return;
      } catch (e) {
        debugPrint("Notification payload parse error: $e");
      }
    }
  }

  void inItLocalNotification(
      BuildContext context, RemoteMessage message) async {
    const androidinitializeSetting =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    final iosinitializeSetting = createDarwinSettings();
    final initializationSetting = InitializationSettings(
      android: androidinitializeSetting,
      iOS: iosinitializeSetting,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static Future<void> navigateToWalkieScreen({
    required String groupId,
    required String groupName,
    required String speakerName,
    String? speakerImage,
  }) async {
    if (groupId.isEmpty) return;
    WalkieLaunchTracker.fromWalkieCall = true;

    final args = {
      "groupId": groupId,
      "groupName": groupName,
      "speakerName": speakerName,
      "speakerImage": speakerImage ?? '',
      "autoOpened": true,
    };

    if (Get.currentRoute == Routes.groupWalkieScreen ||
        WalkieNotificationManager.instance.isWalkieScreenActive.value) {
      if (Get.isRegistered<GroupWalkieController>()) {
        final wc = Get.find<GroupWalkieController>();
        if (wc.onSwitchGroupRequested != null) {
          wc.onSwitchGroupRequested!(args);
          return;
        }
      }
      if (GroupWalkieService.instance.currentGroupId != null &&
          GroupWalkieService.instance.currentGroupId != groupId) {
        await GroupWalkieService.instance.leaveGroup();
        Get.offNamed(Routes.groupWalkieScreen, arguments: args);
      } else {
        await GroupWalkieService.instance.joinGroup(groupId);
      }
    } else {
      if (GroupWalkieService.instance.currentGroupId != null &&
          GroupWalkieService.instance.currentGroupId != groupId) {
        await GroupWalkieService.instance.leaveGroup();
      }
      Get.toNamed(
        Routes.groupWalkieScreen,
        arguments: args,
      );
    }
  }

  static Future<void> showWalkieNotification({
    required String groupId,
    required String groupName,
    required String speakerName,
    String? speakerImage,
    int? joinedCount,
    Map<String, dynamic>? extraData,
  }) async {
    log("🔔 [showWalkieNotification] Started: group=$groupName, speaker=$speakerName, joined=$joinedCount");
    try {
      WidgetsFlutterBinding.ensureInitialized();
    } catch (_) {}

    final eventKey =
        extraData?['eventId']?.toString() ?? "${groupId}_$speakerName";
    if (isDuplicateWalkieEvent(eventKey)) {
      log("🔔 [showWalkieNotification] Skipping duplicate walkie event: $eventKey");
      return;
    }

    bool isForeground = false;
    try {
      isForeground =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    } catch (_) {
      isForeground = false;
    }

    if (isForeground) {
      log("🔔 [showWalkieNotification] App is in foreground, displaying WalkieInviteDialog");
      WalkieInviteDialog.show(
        groupId: groupId,
        groupName: groupName,
        speakerName: speakerName,
        speakerImage: speakerImage ?? '',
        joinedCount: joinedCount,
      );
      return;
    }

    log("🔔 [showWalkieNotification] App is background/terminated, displaying notification");

    // Android: Use Native Custom RemoteViews Notification
    if (Platform.isAndroid) {
      log("🔔 [showWalkieNotification] Android: Calling native WalkieCustomNotification.show");
      try {
        final success = await WalkieCustomNotification.show(
          groupId: groupId,
          groupName: groupName,
          speakerName: speakerName,
          speakerImage: speakerImage,
          joinedCount: joinedCount,
        );
        log("✅ [showWalkieNotification] WalkieCustomNotification.show result: $success");
      } catch (e, st) {
        log("❌ [showWalkieNotification] Error calling WalkieCustomNotification.show: $e\n$st");
      }
      return;
    }

    // iOS: Use Native UserNotifications with Action Buttons (Accept / Cancel) and Content Extension
    if (Platform.isIOS) {
      log("🔔 [showWalkieNotification] iOS: Displaying native notification with Accept/Cancel actions");
      try {
        final title = (groupName.trim().isNotEmpty)
            ? groupName.trim()
            : "Walkie-Talkie Active";
        final joinedText = (joinedCount != null && joinedCount > 0)
            ? " • $joinedCount Joined"
            : "";
        final body = (speakerName.trim().isNotEmpty)
            ? "$speakerName is speaking...$joinedText"
            : "Active walkie-talkie conversation$joinedText";

        final localNotifications = FlutterLocalNotificationsPlugin();
        final iosinitializeSetting = createDarwinSettings();
        final initializationSetting = InitializationSettings(
          iOS: iosinitializeSetting,
        );
        try {
          await localNotifications.initialize(
            initializationSetting,
            onDidReceiveNotificationResponse: onNotificationResponse,
            onDidReceiveBackgroundNotificationResponse:
                notificationTapBackground,
          );
        } catch (_) {}

        final DarwinNotificationDetails darwinNotificationDetails =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'walkie-talkie-ringtone.caf',
          categoryIdentifier: 'WALKIE_INVITE',
          threadIdentifier: 'walkie_$groupId',
        );

        final NotificationDetails notificationDetails = NotificationDetails(
          iOS: darwinNotificationDetails,
        );

        final payloadMap = <String, dynamic>{
          'screen_name': 'group_walkie',
          'groupId': groupId,
          'groupName': groupName,
          'speakerName': speakerName,
          'speakerImage': speakerImage ?? '',
          'joinedMemberCount': joinedCount?.toString() ?? '0',
          if (extraData != null) ...extraData,
        };

        final int notificationId = 5000 + (groupId.hashCode.abs() % 1000);
        log("🔔 [showWalkieNotification] Invoking localNotifications.show($notificationId) on iOS (group: $groupId)...");
        try {
          await localNotifications.cancel(notificationId);
          await localNotifications.cancel(502);
        } catch (_) {}
        await localNotifications.show(
          notificationId,
          title,
          body,
          notificationDetails,
          payload: jsonEncode(payloadMap),
        );
        log("✅ [showWalkieNotification] iOS notification shown successfully!");
      } catch (e, st) {
        log("❌ [showWalkieNotification] iOS error showing notification: $e\n$st");
      }
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    final screenName = (message.data['screen_name'] ??
            message.data['screenName'] ??
            message.data['screen'])
        ?.toString();
    if (screenName == "group_walkie" ||
        screenName == "groupWalkie" ||
        screenName == "walkie") {
      final isForeground =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
      if (isForeground) {
        return;
      }
      final rawJoined = message.data['joinedMemberCount'] ??
          message.data['joinedCount'] ??
          message.data['activeMemberCount'] ??
          message.data['totalJoinedMembers'] ??
          message.data['membersJoined'];
      final int? joinedCount =
          rawJoined != null ? int.tryParse(rawJoined.toString()) : null;
      final speakerId = message.data['speakerId']?.toString();
      final myId = GroupWalkieService.instance.selfUserId ??
          Global.storageServices.get(PrefConst.userId)?.toString();
      if (speakerId != null && myId != null && speakerId == myId) {
        return;
      }
      await showWalkieNotification(
        groupId: (message.data['groupId'] ??
                message.data['group_id'] ??
                message.data['id'] ??
                '')
            .toString(),
        groupName: (message.data['groupName'] ??
                message.data['group_name'] ??
                message.data['title'] ??
                'Walkie-Talkie')
            .toString(),
        speakerName: (message.data['speakerName'] ??
                message.data['speaker_name'] ??
                message.data['name'] ??
                'Someone')
            .toString(),
        speakerImage: (message.data['speakerImage'] ??
                message.data['speaker_image'] ??
                '')
            .toString(),
        joinedCount: joinedCount,
        extraData: Map<String, dynamic>.from(message.data),
      );
      return;
    }

    var title =
        message.notification?.title ?? message.data['title']?.toString();
    var body = message.notification?.body ?? message.data['body']?.toString();
    if (message.data['screen_name'] == "incomingGroupCall") {
      return;
    }
    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      debugPrint("⏭️ Skipping local notification: message has no title/body");
      return;
    }

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(10000).toString(),
      "High Importance Notification",
      importance: Importance.max,
      sound:
          const RawResourceAndroidNotificationSound('recieve_notification.mp3'),
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: "you Channel Description",
            importance: Importance.high,
            priority: Priority.high,
            ticker: "ticker",
            sound: const RawResourceAndroidNotificationSound(
                'recieve_notification'),
            enableVibration: true);

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: "recieve_notification.mp3");

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    });
  }

  Future<String> getDiviceToken() async {
    String? token = await messaging.getToken();
    return token ?? '';
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage = pendingInitialMessage ??
        await FirebaseMessaging.instance.getInitialMessage();
    pendingInitialMessage = null;

    if (initialMessage != null) {
      handleMessage(context, initialMessage, type: "frombackground");
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      handleMessage(context, event, type: "frombackground");
    });
  }

  askPermission() async {
    await Firebase.initializeApp();

    if (Platform.isAndroid) {
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> initialized() async {
    getDeviceTokenToSendNotification();

    const androidinitializeSetting =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    final iosinitializeSetting = createDarwinSettings();
    final initializationSetting = InitializationSettings(
      android: androidinitializeSetting,
      iOS: iosinitializeSetting,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    const AndroidNotificationChannel walkieChannel = AndroidNotificationChannel(
      'walkie_talkie_live_channel_v3',
      'Walkie-Talkie Live Channels',
      description: 'Notifications for active Walkie-Talkie channels',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('recieve_notification'),
    );

    const AndroidNotificationChannel highImportanceChannel =
        AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Default channel for high importance notifications',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('recieve_notification'),
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(walkieChannel);
    await androidPlugin?.createNotificationChannel(highImportanceChannel);

    final launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;
      final action = (response?.actionId ?? '').toUpperCase();
      if (response != null &&
          (action == walkieCancelActionId ||
              action == walkieDeclineActionId ||
              action.contains('CANCEL') ||
              action.contains('DECLINE') ||
              action.contains('REJECT'))) {
        // User cancelled from terminated state; skip opening
      } else if (response?.payload != null && response!.payload!.isNotEmpty) {
        try {
          final data = jsonDecode(response.payload!);
          final isWalkie = (data['screen_name'] == 'group_walkie' ||
              data['screenName'] == 'group_walkie' ||
              data['screen_name'] == 'groupWalkie' ||
              data['groupId'] != null ||
              data['group_id'] != null);

          if (isWalkie) {
            final groupId =
                (data['groupId'] ?? data['group_id'] ?? '')?.toString() ?? '';
            final groupName =
                (data['groupName'] ?? data['group_name'] ?? 'Walkie-Talkie')
                        ?.toString() ??
                    'Walkie-Talkie';
            final speakerName =
                (data['speakerName'] ?? data['speaker_name'] ?? 'Someone')
                        ?.toString() ??
                    'Someone';
            final speakerImage =
                (data['speakerImage'] ?? data['speaker_image'] ?? '')
                        ?.toString() ??
                    '';

            if (groupId.isNotEmpty) {
              WalkieLaunchTracker.fromWalkieCall = true;
              log("🔔 [initNotificationServices] App launched from Walkie notification -> scheduling navigation");
              Future.delayed(const Duration(milliseconds: 800), () {
                navigateToWalkieScreen(
                  groupId: groupId,
                  groupName: groupName,
                  speakerName: speakerName,
                  speakerImage: speakerImage,
                );
              });
            }
          } else {
            pendingInitialMessage =
                RemoteMessage(data: Map<String, dynamic>.from(data));
          }
        } catch (_) {}
      }
    }

    final initMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initMsg != null) {
      pendingInitialMessage = initMsg;
    }

    if (Platform.isAndroid) {
      WalkieCustomNotification.initialize();
      WalkieCustomNotification.setActionListener((data) {
        log("🔔 [WalkieCustomNotification] Action received: $data");
        final action = data['action']?.toString();
        final groupId = data['groupId']?.toString() ?? '';
        final groupName = data['groupName']?.toString() ?? 'Walkie-Talkie';
        final speakerName = data['speakerName']?.toString() ?? 'Someone';

        if (action == 'accept' && groupId.isNotEmpty) {
          navigateToWalkieScreen(
            groupId: groupId,
            groupName: groupName,
            speakerName: speakerName,
          );
        }
      });

      WalkieCustomNotification.getInitialAction().then((data) {
        if (data != null) {
          log("🔔 [WalkieCustomNotification] Initial action: $data");
          final action = data['action']?.toString();
          final groupId = data['groupId']?.toString() ?? '';
          final groupName = data['groupName']?.toString() ?? 'Walkie-Talkie';
          final speakerName = data['speakerName']?.toString() ?? 'Someone';

          if (action == 'accept' && groupId.isNotEmpty) {
            WalkieLaunchTracker.fromWalkieCall = true;
            Future.delayed(const Duration(milliseconds: 600), () {
              navigateToWalkieScreen(
                groupId: groupId,
                groupName: groupName,
                speakerName: speakerName,
              );
            });
          }
        }
      });
    }

    FirebaseMessaging.onMessage.listen((message) async {
      final data = message.data;
      if (data['type'] == 'FORCE_LOGOUT' ||
          data['screen_name'] == 'force_logout') {
        LogoutUser().handleForceLogout(
          message: message.notification?.body ??
              "Session expired. You logged in on another device.",
        );
        return;
      }

      final context =
          ContextUtility.navigatorkey.currentState?.overlay?.context;

      if (context == null) {
        debugPrint("Context not ready, skipping UI actions");
        return;
      }

      if (Platform.isAndroid) {
        inItLocalNotification(context, message);
        showNotification(message);
        handleMessage(context, message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      final ctx =
          ContextUtility.navigatorkey.currentState?.context ?? Get.context;
      if (ctx != null) {
        handleMessage(ctx, event, type: "frombackground");
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          final retryCtx =
              ContextUtility.navigatorkey.currentState?.context ?? Get.context;
          if (retryCtx != null) {
            handleMessage(retryCtx, event, type: "frombackground");
          }
        });
      }
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
  }

  static Future<String> getDeviceTokenToSendNotification() async {
    fcmToken = (await FirebaseMessaging.instance.getToken()).toString();
    return fcmToken;
  }

  Future<void> handleMessage(BuildContext context, RemoteMessage message,
      {String? type}) async {
    print("Notification-MessageData:${message.data}");
    final data = message.data;
    if (data['type'] == 'FORCE_LOGOUT' ||
        data['screen_name'] == 'force_logout') {
      LogoutUser().handleForceLogout(
        message: message.notification?.body ??
            "Session expired. You logged in on another device.",
      );
      return;
    }
    if (type == "frombackground" || type == "recienvedmessage") {
      if (message.data['screen_name'] == "MemberPage") {
        Get.toNamed(Routes.Memberscreen, arguments: {
          "groupId": message.data['groupId'],
          "groupName": message.data['groupName'],
          "isCreator": message.data['isCreator'],
          "isActive": message.data['isActive'],
        });
      } else if (message.data["screen_name"] == "chatScreen") {
        MemberData? memberData;
        try {
          memberData =
              MemberData.fromJson(jsonDecode(message.data['memberData']));
        } catch (e) {
          debugPrint("Invalid memberData format: $e");
        }
        if (memberData != null) {
          memberData.groupId = 0;

          Get.toNamed(
            Routes.chatScreen,
            arguments: {
              "userData": memberData,
              "groupName": "",
              "type": "chatScreen",
            },
          );

          await notificationCtr.markAsRead(
            int.parse(message.data["notificationId"].toString()),
          );
        }
      } else if (message.data["screen_name"] == "groupChatScreen") {
        Get.toNamed(
          Routes.groupChatScreen,
          arguments: {
            "groupId": int.parse(message.data["groupId"].toString()).toString(),
            "groupName": message.data["groupName"],
            "groupImage": "",
          },
        );
        await notificationCtr.markAsRead(
          int.parse(message.data["notificationId"].toString()),
        );
      } else if (message.data['screen_name'] == 'incomingCall') {
        if (CallStateTracker.isIncomingCallScreenOpen) return;

        final callMap = jsonDecode(message.data['callData']);
        final call = IncomingCallModel.fromMap(callMap);

        CallStateTracker.isIncomingCallScreenOpen = true;

        Get.toNamed(
          Routes.IncomingCallScreen,
          arguments: {"callDetail": call},
        );
      }
      // else if (message.data['screen_name'] == 'groupCallNotify') {
      // FlutterRingtonePlayer().stop();
      // if (CallStateTracker.isIncomingCallScreenOpen) return;
      //
      // final data = jsonDecode(message.data['callData']);
      //
      // print("=========againCalledgroupIncommingScreen");
      // CallStateTracker.isIncomingCallScreenOpen = true;
      // Get.toNamed(
      //   Routes.groupIncomingCallScreen,
      //   arguments: {
      //     "callId": data['callId']?.toString(),
      //     "groupId": data['groupId']?.toString() ?? "",
      //     "groupName": (data['groupName'] ?? "Group Call").toString(),
      //     "callerName": data['callerName'],
      //     "groupProfile": data['callerProfileImage'],
      //     "callerProfileImage": data['callerProfileImage'],
      //     "activeMemberCount": 1,
      //     "totalMemberCount": data['totalGroupMember'] ?? 0,
      //     "isVideo": data['isVideo'] == true,
      //     "callType": "incoming",
      //   },
      // );
      // flutterLocalNotificationsPlugin.cancelAll();
      // }

      else if (message.data['screen_name'] == "missedCall") {
        Get.toNamed(Routes.notificationScreen);
      } else if (message.data['screen_name'] == "group_walkie" ||
          message.data['screenName'] == "group_walkie" ||
          message.data['screen_name'] == "groupWalkie" ||
          message.data['screen'] == "group_walkie" ||
          message.data['screen'] == "walkie") {
        final groupId = (message.data['groupId'] ??
                    message.data['group_id'] ??
                    message.data['id'])
                ?.toString() ??
            '';
        final groupName = (message.data['groupName'] ??
                    message.data['group_name'] ??
                    message.data['title'])
                ?.toString() ??
            'Walkie-Talkie';
        final speakerName = (message.data['speakerName'] ??
                    message.data['speaker_name'] ??
                    message.data['callerName'] ??
                    message.data['name'])
                ?.toString() ??
            'Someone';
        final speakerImage = (message.data['speakerImage'] ??
                    message.data['speaker_image'] ??
                    message.data['speakerProfile'] ??
                    message.data['callerProfileImage'])
                ?.toString() ??
            '';

        if (groupId.isNotEmpty) {
          if (type == "frombackground") {
            log("🔔 [handleMessage] Walkie notification opened from background -> navigating to walkie screen directly");
            WalkieLaunchTracker.fromWalkieCall = true;
            Future.delayed(const Duration(milliseconds: 300), () {
              navigateToWalkieScreen(
                groupId: groupId,
                groupName: groupName,
                speakerName: speakerName,
                speakerImage: speakerImage,
              );
            });
            return;
          }

          if (GroupWalkieService.instance.currentGroupId != null &&
              GroupWalkieService.instance.currentGroupId != groupId) {
            await GroupWalkieService.instance.leaveGroup();
          }

          final rawJoinedCount = message.data['joinedMemberCount'] ??
              message.data['joinedCount'] ??
              message.data['activeMemberCount'] ??
              message.data['totalJoinedMembers'] ??
              message.data['membersJoined'];
          final int? joinedCount = rawJoinedCount != null
              ? int.tryParse(rawJoinedCount.toString())
              : null;

          Future.delayed(const Duration(milliseconds: 300), () {
            WalkieInviteDialog.show(
              groupId: groupId,
              groupName: groupName,
              speakerName: speakerName,
              speakerImage: speakerImage,
              joinedCount: joinedCount,
            );
          });
        }
      }
    } else {
      print("===========groupcallingscreenworkig....");
      if (message.data['screen_name'] == "group_walkie" ||
          message.data['screenName'] == "group_walkie" ||
          message.data['screen_name'] == "groupWalkie" ||
          message.data['screen'] == "group_walkie" ||
          message.data['screen'] == "walkie") {
        final groupId = (message.data['groupId'] ??
                    message.data['group_id'] ??
                    message.data['id'])
                ?.toString() ??
            '';
        final groupName = (message.data['groupName'] ??
                    message.data['group_name'] ??
                    message.data['title'])
                ?.toString() ??
            'Walkie-Talkie';
        final speakerName = (message.data['speakerName'] ??
                    message.data['speaker_name'] ??
                    message.data['callerName'] ??
                    message.data['name'])
                ?.toString() ??
            'Someone';
        final speakerImage = (message.data['speakerImage'] ??
                    message.data['speaker_image'] ??
                    message.data['speakerProfile'] ??
                    message.data['callerProfileImage'])
                ?.toString() ??
            '';

        final rawJoinedCount = message.data['joinedMemberCount'] ??
            message.data['joinedCount'] ??
            message.data['activeMemberCount'] ??
            message.data['totalJoinedMembers'] ??
            message.data['membersJoined'];
        final int? joinedCount = rawJoinedCount != null
            ? int.tryParse(rawJoinedCount.toString())
            : null;

        final speakerId = message.data['speakerId']?.toString();
        final myId = GroupWalkieService.instance.selfUserId ??
            Global.storageServices.get(PrefConst.userId)?.toString();
        if (speakerId != null && myId != null && speakerId == myId) {
          return;
        }

        final isForeground =
            WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
        if (!isForeground) {
          return;
        }

        if (groupId.isNotEmpty &&
            GroupWalkieService.instance.currentGroupId != groupId &&
            Get.currentRoute != Routes.groupWalkieScreen) {
          WalkieInviteDialog.show(
            groupId: groupId,
            groupName: groupName,
            speakerName: speakerName,
            speakerImage: speakerImage,
            title: message.notification?.title ??
                message.data['title']?.toString(),
            subtitle:
                message.notification?.body ?? message.data['body']?.toString(),
            location: message.data['location']?.toString() ??
                message.data['area']?.toString(),
            joinedCount: joinedCount,
          );
        }
      }

      if (message.data['screen_name'] == 'incomingCall') {
        try {
          final callData = CallKitService.decodeCallData(
            message.data['callData'],
          );

          final callId = callData['callId'].toString();
          final remoteUserId =
              int.tryParse(callData['callerId'].toString()) ?? 0;

          if (socket != null && socket!.connected) {
            socket?.emit('CallingStatus', {
              'callId': callId,
              'remoteUserId': remoteUserId,
              'callingStatus': 'Ringing',
            });
          } else {
            await CallRepo.updateCallingStatus(
              callId: callId,
              callingStatus: 'Ringing',
              remoteUserId: remoteUserId,
            );
          }
        } catch (e) {
          log('Ringing status error: $e');
        }
      }

      if (message.data['screen_name'] == "incomingGroupCall") {
        final callData = jsonDecode(message.data['callData']);
        final originalCallId = callData['callId'].toString();
        socket?.emit("CallingStatus", {
          "callId": originalCallId,
          "remoteUserId": int.tryParse(callData['callerId'].toString()) ?? 0,
          "callingStatus": "Ringing",
        });
      }

      if (message.data['screen_name'] == "missedCall") {
        final callData = jsonDecode(message.data['callData']);
        final sessionId = callData['session_id'].toString();
        callEnded(sessionId, type: "Notification-services");
      } else if (message.data['screen_name'] == "missedGroupCall") {
        final sessionId = message.data['session_id'].toString();
        callEnded(sessionId, type: "Notification-services");
        CallStateTracker.isIncomingCallScreenOpen = false;
        flutterLocalNotificationsPlugin.cancelAll();
      }
    }
  }
}
