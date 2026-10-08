// import 'dart:convert';
// import 'dart:math';
// import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
// import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
// import 'package:fgtracker/app/Core/util/CallKit/callkit_service.dart';
// import 'package:fgtracker/app/Core/values/Context_Utility.dart';
// import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
// import 'package:fgtracker/app/Model/MemberDataRes.dart';
// import 'package:fgtracker/app/Model/call_model.dart';
// import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
// import 'package:fgtracker/app/modules/Walkie-talkie/Services/walkie_notification_manager.dart';
// import 'package:fgtracker/app/routes/app_pages.dart';
// import 'package:fgtracker/main.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'dart:io';
// import 'CallStateTracker.dart';
// import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
// import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_invite_dialog.dart';
//
// class firebaseNotificationServices {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final notificationCtr = Get.put(NotificationController());
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static String fcmToken = "";
//   static RemoteMessage? pendingInitialMessage;
//
//   void inItLocalNotification(
//       BuildContext context, RemoteMessage message) async {
//     var androidinitializeSetting =
//         const AndroidInitializationSettings("@mipmap/ic_launcher");
//     var iosinitializeSetting = const DarwinInitializationSettings();
//     var initializationSetting = InitializationSettings(
//       android: androidinitializeSetting,
//       iOS: iosinitializeSetting,
//     );
//     await flutterLocalNotificationsPlugin.initialize(initializationSetting,
//         onDidReceiveNotificationResponse: (payload) {
//       if (payload.payload != null && payload.payload!.isNotEmpty) {
//         try {
//           final data = jsonDecode(payload.payload!);
//           handleMessage(
//             context,
//             RemoteMessage(data: Map<String, dynamic>.from(data)),
//             type: "recienvedmessage",
//           );
//           return;
//         } catch (_) {}
//       }
//       handleMessage(context, message, type: "recienvedmessage");
//     });
//   }
//
//   Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       Random.secure().nextInt(10000).toString(),
//       "High Importance Notification",
//       importance: Importance.max,
//       sound:
//           const RawResourceAndroidNotificationSound('recieve_notification.mp3'),
//     );
//
//     AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//             channel.id.toString(), channel.name.toString(),
//             channelDescription: "you Channel Description",
//             importance: Importance.high,
//             priority: Priority.high,
//             ticker: "ticker",
//             sound: const RawResourceAndroidNotificationSound(
//                 'recieve_notification'),
//             enableVibration: true);
//
//     const DarwinNotificationDetails darwinNotificationDetails =
//         DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//             sound: "recieve_notification.mp3");
//
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: darwinNotificationDetails,
//     );
//
//     final screenName = (message.data['screen_name'] ??
//             message.data['screenName'] ??
//             message.data['screen'])
//         ?.toString();
//     if (screenName == "group_walkie" ||
//         screenName == "groupWalkie" ||
//         screenName == "walkie") {
//       // Top banner dialog (WalkieInviteDialog) is already shown in-app; skip duplicate status bar notification
//       return;
//     }
//
//     var title = message.notification?.title ?? message.data['title']?.toString();
//     var body = message.notification?.body ?? message.data['body']?.toString();
//
//     if ((title == null || title.trim().isEmpty) && (body == null || body.trim().isEmpty)) {
//       debugPrint("⏭️ Skipping local notification: message has no title/body");
//       return;
//     }
//
//     Future.delayed(Duration.zero, () {
//       flutterLocalNotificationsPlugin.show(
//         0,
//         title,
//         body,
//         notificationDetails,
//         payload: jsonEncode(message.data),
//       );
//     });
//   }
//
//   Future<String> getDiviceToken() async {
//     String? token = await messaging.getToken();
//     return token ?? '';
//   }
//
//   Future<void> setupInteractMessage(BuildContext context) async {
//     RemoteMessage? initialMessage = pendingInitialMessage ??
//         await FirebaseMessaging.instance.getInitialMessage();
//     pendingInitialMessage = null;
//
//     if (initialMessage != null) {
//       handleMessage(context, initialMessage, type: "recienvedmessage");
//     }
//
//     FirebaseMessaging.onMessageOpenedApp.listen((event) async {
//       handleMessage(context, event, type: "recienvedmessage");
//     });
//   }
//
//   askPermission() async {
//     await Firebase.initializeApp();
//
//     if (Platform.isAndroid) {
//       NotificationSettings setting = await messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true,
//       );
//       if (setting.authorizationStatus == AuthorizationStatus.authorized) {
//         // debugPrint("user granted permission");
//       } else {
//         // debugPrint("user denied permission");
//         // openAppSettings();
//       }
//     } else if (Platform.isIOS) {
//       await FlutterLocalNotificationsPlugin()
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//     }
//   }
//
//   Future<void> initialized() async {
//     getDeviceTokenToSendNotification();
//
//     const androidinitializeSetting =
//         AndroidInitializationSettings("@mipmap/ic_launcher");
//     const iosinitializeSetting = DarwinInitializationSettings();
//     const initializationSetting = InitializationSettings(
//       android: androidinitializeSetting,
//       iOS: iosinitializeSetting,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSetting,
//       onDidReceiveNotificationResponse: (payload) {
//         if (payload.payload != null && payload.payload!.isNotEmpty) {
//           try {
//             final data = jsonDecode(payload.payload!);
//             final ctx = ContextUtility.navigatorkey.currentState?.context ??
//                 Get.context;
//             if (ctx != null) {
//               handleMessage(
//                 ctx,
//                 RemoteMessage(data: Map<String, dynamic>.from(data)),
//                 type: "recienvedmessage",
//               );
//             }
//             return;
//           } catch (e) {
//             debugPrint("Notification payload parse error: $e");
//           }
//         }
//       },
//     );
//
//     final launchDetails =
//         await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
//     if (launchDetails?.didNotificationLaunchApp ?? false) {
//       final payload = launchDetails?.notificationResponse?.payload;
//       if (payload != null && payload.isNotEmpty) {
//         try {
//           final data = jsonDecode(payload);
//           pendingInitialMessage =
//               RemoteMessage(data: Map<String, dynamic>.from(data));
//         } catch (_) {}
//       }
//     }
//
//     final initMsg = await FirebaseMessaging.instance.getInitialMessage();
//     if (initMsg != null) {
//       pendingInitialMessage = initMsg;
//     }
//
//     FirebaseMessaging.onMessage.listen((message) async {
//       final context =
//           ContextUtility.navigatorkey.currentState?.overlay?.context;
//
//       if (context == null) {
//         debugPrint("Context not ready, skipping UI actions");
//         return;
//       }
//
//       if (Platform.isAndroid) {
//         inItLocalNotification(context, message);
//         showNotification(message);
//         handleMessage(context, message);
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((event) async {
//       final ctx = ContextUtility.navigatorkey.currentState?.context ?? Get.context;
//       if (ctx != null) {
//         handleMessage(ctx, event, type: "recienvedmessage");
//       } else {
//         Future.delayed(const Duration(milliseconds: 300), () {
//           final retryCtx = ContextUtility.navigatorkey.currentState?.context ?? Get.context;
//           if (retryCtx != null) {
//             handleMessage(retryCtx, event, type: "recienvedmessage");
//           }
//         });
//       }
//     });
//
//     FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//         alert: true, badge: true, sound: true);
//   }
//
//   static Future<String> getDeviceTokenToSendNotification() async {
//     fcmToken = (await FirebaseMessaging.instance.getToken()).toString();
//     return fcmToken;
//   }
//
//   // Future<void> handleMessage(BuildContext context, RemoteMessage message,
//   //     {String? type}) async {
//   //   print("Notification-MessageData:${message.data}");
//   //   final screenName = (message.data['screen_name'] ??
//   //           message.data['screenName'] ??
//   //           message.data['screen'])
//   //       ?.toString();
//   //
//   //   if (type == "recienvedmessage") {
//   //     if (screenName == "MemberPage") {
//   //       Get.toNamed(Routes.Memberscreen, arguments: {
//   //         "groupId": message.data['groupId'],
//   //         "groupName": message.data['groupName'],
//   //         "isCreator": message.data['isCreator'],
//   //         "isActive": message.data['isActive'],
//   //       });
//   //     } else if (screenName == "chatScreen") {
//   //       MemberData? memberData;
//   //       try {
//   //         memberData =
//   //             MemberData.fromJson(jsonDecode(message.data['memberData']));
//   //       } catch (e) {
//   //         debugPrint("Invalid memberData format: $e");
//   //       }
//   //       if (memberData != null) {
//   //         memberData.groupId = 0;
//   //
//   //         Get.toNamed(
//   //           Routes.chatScreen,
//   //           arguments: {
//   //             "userData": memberData,
//   //             "groupName": "",
//   //             "type": "chatScreen",
//   //           },
//   //         );
//   //
//   //         await notificationCtr.markAsRead(
//   //           int.parse(message.data["notificationId"].toString()),
//   //         );
//   //       }
//   //     } else if (screenName == "groupChatScreen") {
//   //       Get.toNamed(
//   //         Routes.groupChatScreen,
//   //         arguments: {
//   //           "groupId": int.parse(message.data["groupId"].toString()).toString(),
//   //           "groupName": message.data["groupName"],
//   //           "groupImage": "",
//   //         },
//   //       );
//   //       await notificationCtr.markAsRead(
//   //         int.parse(message.data["notificationId"].toString()),
//   //       );
//   //     } else if (screenName == 'incomingCall') {
//   //       if (CallStateTracker.isIncomingCallScreenOpen) return;
//   //
//   //       final callMap = jsonDecode(message.data['callData']);
//   //       final call = IncomingCallModel.fromMap(callMap);
//   //
//   //       CallStateTracker.isIncomingCallScreenOpen = true;
//   //
//   //       Get.toNamed(
//   //         Routes.IncomingCallScreen,
//   //         arguments: {"callDetail": call},
//   //       );
//   //     } else if (screenName == "missedCall") {
//   //       Get.toNamed(Routes.notificationScreen);
//   //     } else if (screenName == "group_walkie" ||
//   //         screenName == "groupWalkie" ||
//   //         screenName == "walkie") {
//   //       final groupId = (message.data['groupId'] ??
//   //               message.data['group_id'] ??
//   //               message.data['id'])
//   //           ?.toString() ??
//   //           '';
//   //       final groupName = (message.data['groupName'] ??
//   //               message.data['group_name'] ??
//   //               message.data['title'])
//   //           ?.toString() ??
//   //           'Walkie-Talkie';
//   //       final speakerName = (message.data['speakerName'] ??
//   //               message.data['speaker_name'] ??
//   //               message.data['callerName'] ??
//   //               message.data['name'])
//   //           ?.toString() ??
//   //           'Someone';
//   //       final speakerImage = (message.data['speakerImage'] ??
//   //               message.data['speaker_image'] ??
//   //               message.data['speakerProfile'] ??
//   //               message.data['callerProfileImage'])
//   //           ?.toString() ??
//   //           '';
//   //
//   //       if (groupId.isNotEmpty) {
//   //         if (GroupWalkieService.instance.currentGroupId != null &&
//   //             GroupWalkieService.instance.currentGroupId != groupId) {
//   //           await GroupWalkieService.instance.leaveGroup();
//   //         }
//   //
//   //         Future.delayed(const Duration(milliseconds: 300), () {
//   //           Get.toNamed(
//   //             Routes.groupWalkieScreen,
//   //             arguments: {
//   //               "groupId": groupId,
//   //               "groupName": groupName,
//   //               "speakerName": speakerName,
//   //               "speakerImage": speakerImage,
//   //               "autoOpened": true,
//   //             },
//   //           );
//   //         });
//   //       }
//   //     }
//   //   } else {
//   //     if (screenName == "group_walkie" ||
//   //         screenName == "groupWalkie" ||
//   //         screenName == "walkie") {
//   //       final groupId = (message.data['groupId'] ??
//   //               message.data['group_id'] ??
//   //               message.data['id'])
//   //           ?.toString() ??
//   //           '';
//   //       final groupName = (message.data['groupName'] ??
//   //               message.data['group_name'] ??
//   //               message.data['title'])
//   //           ?.toString() ??
//   //           'Walkie-Talkie';
//   //       final speakerName = (message.data['speakerName'] ??
//   //               message.data['speaker_name'] ??
//   //               message.data['callerName'] ??
//   //               message.data['name'])
//   //           ?.toString() ??
//   //           'Someone';
//   //       final speakerImage = (message.data['speakerImage'] ??
//   //               message.data['speaker_image'] ??
//   //               message.data['speakerProfile'] ??
//   //               message.data['callerProfileImage'])
//   //           ?.toString() ??
//   //           '';
//   //
//   //       if (groupId.isNotEmpty &&
//   //           GroupWalkieService.instance.currentGroupId != groupId &&
//   //           Get.currentRoute != Routes.groupWalkieScreen) {
//   //         WalkieInviteDialog.show(
//   //           groupId: groupId,
//   //           groupName: groupName,
//   //           speakerName: speakerName,
//   //           speakerImage: speakerImage,
//   //         );
//   //       }
//   //     }
//   //
//   //       if (message.data['screen_name'] == "incomingCall") {
//   //         final callData = jsonDecode(message.data['callData']);
//   //
//   //         final originalCallId = callData['callId'].toString();
//   //         socket?.emit("CallingStatus", {
//   //           "callId": originalCallId,
//   //           "remoteUserId": int.tryParse(callData['callerId'].toString()) ?? 0,
//   //           "callingStatus": "Ringing",
//   //         });
//   //         if (Platform.isAndroid) {
//   //           final Map<String, String> userInfo = callData.map<String, String>(
//   //               (key, value) => MapEntry(key.toString(), value.toString()));
//   //           await ConnectycubeFlutterCallKit.showCallNotification(
//   //             CallEvent(
//   //               sessionId: callIdToUuid(callData['callId'].toString()),
//   //               callerName: callData['callerName'],
//   //               callType: callData['isVideo'] == true ? 1 : 0,
//   //               opponentsIds: {int.parse(callData['callerId'])},
//   //               callerId: int.parse(callData['callerId']),
//   //               userInfo: userInfo,
//   //             ),
//   //           );
//   //           CallSessionState.sessionId = callData['callId'].toString();
//   //         }
//   //       }
//   //
//   //
//   //       if (message.data['screen_name'] == "incomingGroupCall") {
//   //         final callData = jsonDecode(message.data['callData']);
//   //         final originalCallId = callData['callId'].toString();
//   //         socket?.emit("CallingStatus", {
//   //           "callId": originalCallId,
//   //           "remoteUserId": int.tryParse(callData['callerId'].toString()) ?? 0,
//   //           "callingStatus": "Ringing",
//   //         });
//   //         if (Platform.isAndroid) {
//   //           final Map<String, String> userInfo = callData.map<String, String>(
//   //               (key, value) => MapEntry(key.toString(), value.toString()));
//   //           await ConnectycubeFlutterCallKit.showCallNotification(
//   //             CallEvent(
//   //               sessionId: callIdToUuid(callData['callId'].toString()),
//   //               callerName: callData['groupName'],
//   //               callType: callData['isVideo'] == true ? 1 : 0,
//   //               opponentsIds: {int.parse(callData['callerId'])},
//   //               callerId: int.parse(callData['callerId']),
//   //               userInfo: userInfo,
//   //             ),
//   //           );
//   //           CallSessionState.sessionId = callData['callId'].toString();
//   //         }
//   //       }
//   //
//   //
//   //     if (message.data['screen_name'] == "missedCall") {
//   //       final callData = jsonDecode(message.data['callData']);
//   //       final sessionId = callData['session_id'].toString();
//   //       callEnded(sessionId, type: "Notification-services");
//   //     } else if (message.data['screen_name'] == "missedGroupCall") {
//   //       final sessionId = message.data['session_id'].toString();
//   //       callEnded(sessionId, type: "Notification-services");
//   //       CallStateTracker.isIncomingCallScreenOpen = false;
//   //       flutterLocalNotificationsPlugin.cancelAll();
//   //     }
//   //
//   //   }
//   // }
//
//   Future<void> handleMessage(
//       BuildContext context,
//       RemoteMessage message, {
//         String? type,
//       }) async {
//     debugPrint("Notification-MessageData: ${message.data}");
//
//     final screenName = (message.data['screen_name'] ??
//         message.data['screenName'] ??
//         message.data['screen'])
//         ?.toString();
//
//     // ───────────────────────────────────────────────────────────────────────────
//     // BRANCH 1: Notification Tapped by User (Tapped Call-Style Notif / System Bar)
//     // ───────────────────────────────────────────────────────────────────────────
//     if (type == "recienvedmessage") {
//       if (screenName == "MemberPage") {
//         Get.toNamed(Routes.Memberscreen, arguments: {
//           "groupId": message.data['groupId'],
//           "groupName": message.data['groupName'],
//           "isCreator": message.data['isCreator'],
//           "isActive": message.data['isActive'],
//         });
//       } else if (screenName == "chatScreen") {
//         MemberData? memberData;
//         try {
//           memberData =
//               MemberData.fromJson(jsonDecode(message.data['memberData']));
//         } catch (e) {
//           debugPrint("Invalid memberData format: $e");
//         }
//         if (memberData != null) {
//           memberData.groupId = 0;
//
//           Get.toNamed(
//             Routes.chatScreen,
//             arguments: {
//               "userData": memberData,
//               "groupName": "",
//               "type": "chatScreen",
//             },
//           );
//
//           if (message.data["notificationId"] != null) {
//             await notificationCtr.markAsRead(
//               int.parse(message.data["notificationId"].toString()),
//             );
//           }
//         }
//       } else if (screenName == "groupChatScreen") {
//         Get.toNamed(
//           Routes.groupChatScreen,
//           arguments: {
//             "groupId": int.parse(message.data["groupId"].toString()).toString(),
//             "groupName": message.data["groupName"],
//             "groupImage": "",
//           },
//         );
//         if (message.data["notificationId"] != null) {
//           await notificationCtr.markAsRead(
//             int.parse(message.data["notificationId"].toString()),
//           );
//         }
//       } else if (screenName == 'incomingCall') {
//         if (CallStateTracker.isIncomingCallScreenOpen) return;
//
//         final callMap = jsonDecode(message.data['callData']);
//         final call = IncomingCallModel.fromMap(callMap);
//
//         CallStateTracker.isIncomingCallScreenOpen = true;
//
//         Get.toNamed(
//           Routes.IncomingCallScreen,
//           arguments: {"callDetail": call},
//         );
//       } else if (screenName == "missedCall") {
//         Get.toNamed(Routes.notificationScreen);
//       } else if (_isWalkieScreen(screenName)) {
//         // 🎤 WALKIE-TALKIE TAP -> Open Walkie Screen directly
//         final groupId = _extractWalkieGroupId(message.data);
//         final groupName = _extractWalkieGroupName(message.data);
//         final speakerName = _extractWalkieSpeakerName(message.data);
//         final speakerImage = _extractWalkieSpeakerImage(message.data);
//
//         if (groupId.isNotEmpty) {
//           // Dismiss notification bar
//           await WalkieNotificationManager.instance.hideNotification();
//
//           if (GroupWalkieService.instance.currentGroupId != null &&
//               GroupWalkieService.instance.currentGroupId != groupId) {
//             await GroupWalkieService.instance.leaveGroup();
//           }
//
//           WalkieNotificationManager.instance.setWalkieJoined(
//             true,
//             groupId: groupId,
//             groupName: groupName,
//           );
//
//           Future.delayed(const Duration(milliseconds: 200), () {
//             Get.toNamed(
//               Routes.groupWalkieScreen,
//               arguments: {
//                 "groupId": groupId,
//                 "groupName": groupName,
//                 "speakerName": speakerName,
//                 "speakerImage": speakerImage,
//                 "autoOpened": true,
//                 "fromNotification": true,
//               },
//             );
//           });
//         }
//       }
//     }
//     // ───────────────────────────────────────────────────────────────────────────
//     // BRANCH 2: Push Received in Foreground / Background (Untapped)
//     // ───────────────────────────────────────────────────────────────────────────
//     else {
//       if (_isWalkieScreen(screenName)) {
//         final groupId = _extractWalkieGroupId(message.data);
//         final groupName = _extractWalkieGroupName(message.data);
//         final speakerName = _extractWalkieSpeakerName(message.data);
//         final speakerId = (message.data['speakerId'] ??
//             message.data['speaker_id'] ??
//             message.data['callerId'] ??
//             message.data['userId'] ??
//             message.data['fromUserId'])
//             ?.toString() ??
//             '';
//
//         final bool isOnWalkieScreen =
//             Get.currentRoute == Routes.groupWalkieScreen ||
//                 WalkieNotificationManager.instance.isWalkieScreenActive.value;
//
//         // ───────────────────────────────────────────────────────────────────────
//         // SPECIFICATION RULES (Matches SS Requirement Table):
//         // 1. If user is ON Walkie Screen -> NO Notification, audio plays live.
//         // 2. If user is on ANOTHER screen / Background -> Show 1 Call-Style
//         //    Notification with live duration timer & "Open Walkie" / "Leave" buttons.
//         // ───────────────────────────────────────────────────────────────────────
//         if (!isOnWalkieScreen && groupId.isNotEmpty) {
//           WalkieNotificationManager.instance.onSomeoneStartedTalking(
//             speakerId: speakerId,
//             speakerName: speakerName,
//             groupId: groupId,
//             groupName: groupName,
//           );
//         }
//       }
//
//       if (message.data['screen_name'] == "incomingCall") {
//         final callData = jsonDecode(message.data['callData']);
//         final originalCallId = callData['callId'].toString();
//
//         socket?.emit("CallingStatus", {
//           "callId": originalCallId,
//           "remoteUserId": int.tryParse(callData['callerId'].toString()) ?? 0,
//           "callingStatus": "Ringing",
//         });
//
//         if (Platform.isAndroid) {
//           final Map<String, String> userInfo = callData.map<String, String>(
//                   (key, value) => MapEntry(key.toString(), value.toString()));
//
//           await ConnectycubeFlutterCallKit.showCallNotification(
//             CallEvent(
//               sessionId: callIdToUuid(callData['callId'].toString()),
//               callerName: callData['callerName'],
//               callType: callData['isVideo'] == true ? 1 : 0,
//               opponentsIds: {int.parse(callData['callerId'])},
//               callerId: int.parse(callData['callerId']),
//               userInfo: userInfo,
//             ),
//           );
//           CallSessionState.sessionId = callData['callId'].toString();
//         }
//       }
//
//       if (message.data['screen_name'] == "incomingGroupCall") {
//         final callData = jsonDecode(message.data['callData']);
//         final originalCallId = callData['callId'].toString();
//
//         socket?.emit("CallingStatus", {
//           "callId": originalCallId,
//           "remoteUserId": int.tryParse(callData['callerId'].toString()) ?? 0,
//           "callingStatus": "Ringing",
//         });
//
//         if (Platform.isAndroid) {
//           final Map<String, String> userInfo = callData.map<String, String>(
//                   (key, value) => MapEntry(key.toString(), value.toString()));
//
//           await ConnectycubeFlutterCallKit.showCallNotification(
//             CallEvent(
//               sessionId: callIdToUuid(callData['callId'].toString()),
//               callerName: callData['groupName'],
//               callType: callData['isVideo'] == true ? 1 : 0,
//               opponentsIds: {int.parse(callData['callerId'])},
//               callerId: int.parse(callData['callerId']),
//               userInfo: userInfo,
//             ),
//           );
//           CallSessionState.sessionId = callData['callId'].toString();
//         }
//       }
//
//       if (message.data['screen_name'] == "missedCall") {
//         final callData = jsonDecode(message.data['callData']);
//         final sessionId = callData['session_id'].toString();
//         callEnded(sessionId, type: "Notification-services");
//       } else if (message.data['screen_name'] == "missedGroupCall") {
//         final sessionId = message.data['session_id'].toString();
//         callEnded(sessionId, type: "Notification-services");
//         CallStateTracker.isIncomingCallScreenOpen = false;
//         flutterLocalNotificationsPlugin.cancelAll();
//       }
//     }
//   }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Walkie-Talkie Field Helper Functions
// // ─────────────────────────────────────────────────────────────────────────────
//
//   bool _isWalkieScreen(String? screenName) {
//     return screenName == "group_walkie" ||
//         screenName == "groupWalkie" ||
//         screenName == "walkie";
//   }
//
//   String _extractWalkieGroupId(Map<String, dynamic> data) {
//     return (data['groupId'] ?? data['group_id'] ?? data['id'])?.toString() ?? '';
//   }
//
//   String _extractWalkieGroupName(Map<String, dynamic> data) {
//     return (data['groupName'] ?? data['group_name'] ?? data['title'])
//         ?.toString() ??
//         'Walkie-Talkie';
//   }
//
//   String _extractWalkieSpeakerName(Map<String, dynamic> data) {
//     return (data['speakerName'] ??
//         data['speaker_name'] ??
//         data['callerName'] ??
//         data['name'])
//         ?.toString() ??
//         'Someone';
//   }
//
//   String _extractWalkieSpeakerImage(Map<String, dynamic> data) {
//     return (data['speakerImage'] ??
//         data['speaker_image'] ??
//         data['speakerProfile'] ??
//         data['callerProfileImage'])
//         ?.toString() ??
//         '';
//   }
// }


















import 'dart:convert';
import 'dart:math';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/util/CallKit/callkit_service.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/call_model.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'CallStateTracker.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_invite_dialog.dart';

class firebaseNotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final notificationCtr = Get.put(NotificationController());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static String fcmToken = "";
  static RemoteMessage? pendingInitialMessage;

  void inItLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidinitializeSetting =
    const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosinitializeSetting = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      android: androidinitializeSetting,
      iOS: iosinitializeSetting,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          if (payload.payload != null && payload.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(payload.payload!);
              handleMessage(
                context,
                RemoteMessage(data: Map<String, dynamic>.from(data)),
                type: "recienvedmessage",
              );
              return;
            } catch (_) {}
          }
          handleMessage(context, message, type: "recienvedmessage");
        });
  }

  Future<void> showNotification(RemoteMessage message) async {
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

    final screenName = (message.data['screen_name'] ??
        message.data['screenName'] ??
        message.data['screen'])
        ?.toString();
    if (screenName == "group_walkie" ||
        screenName == "groupWalkie" ||
        screenName == "walkie") {
      // Top banner dialog (WalkieInviteDialog) is already shown in-app; skip duplicate status bar notification
      return;
    }

    var title = message.notification?.title ?? message.data['title']?.toString();
    var body = message.notification?.body ?? message.data['body']?.toString();

    if ((title == null || title.trim().isEmpty) && (body == null || body.trim().isEmpty)) {
      debugPrint("⏭️ Skipping local notification: message has no title/body");
      return;
    }

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
      handleMessage(context, initialMessage, type: "recienvedmessage");
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      handleMessage(context, event, type: "recienvedmessage");
    });
  }

  askPermission() async {
    await Firebase.initializeApp();

    if (Platform.isAndroid) {
      NotificationSettings setting = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
      if (setting.authorizationStatus == AuthorizationStatus.authorized) {
        // debugPrint("user granted permission");
      } else {
        // debugPrint("user denied permission");
        // openAppSettings();
      }
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
    const iosinitializeSetting = DarwinInitializationSettings();
    const initializationSetting = InitializationSettings(
      android: androidinitializeSetting,
      iOS: iosinitializeSetting,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload) {
        if (payload.payload != null && payload.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(payload.payload!);
            final ctx = ContextUtility.navigatorkey.currentState?.context ??
                Get.context;
            if (ctx != null) {
              handleMessage(
                ctx,
                RemoteMessage(data: Map<String, dynamic>.from(data)),
                type: "recienvedmessage",
              );
            }
            return;
          } catch (e) {
            debugPrint("Notification payload parse error: $e");
          }
        }
      },
    );

    final launchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          final data = jsonDecode(payload);
          pendingInitialMessage =
              RemoteMessage(data: Map<String, dynamic>.from(data));
        } catch (_) {}
      }
    }

    final initMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initMsg != null) {
      pendingInitialMessage = initMsg;
    }

    FirebaseMessaging.onMessage.listen((message) async {
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
      final ctx = ContextUtility.navigatorkey.currentState?.context ?? Get.context;
      if (ctx != null) {
        handleMessage(ctx, event, type: "recienvedmessage");
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          final retryCtx = ContextUtility.navigatorkey.currentState?.context ?? Get.context;
          if (retryCtx != null) {
            handleMessage(retryCtx, event, type: "recienvedmessage");
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
    final screenName = (message.data['screen_name'] ??
        message.data['screenName'] ??
        message.data['screen'])
        ?.toString();

    if (type == "recienvedmessage") {
      if (screenName == "MemberPage") {
        Get.toNamed(Routes.Memberscreen, arguments: {
          "groupId": message.data['groupId'],
          "groupName": message.data['groupName'],
          "isCreator": message.data['isCreator'],
          "isActive": message.data['isActive'],
        });
      } else if (screenName == "chatScreen") {
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
      } else if (screenName == "groupChatScreen") {
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
      } else if (screenName == 'incomingCall') {
        if (CallStateTracker.isIncomingCallScreenOpen) return;

        final callMap = jsonDecode(message.data['callData']);
        final call = IncomingCallModel.fromMap(callMap);

        CallStateTracker.isIncomingCallScreenOpen = true;

        Get.toNamed(
          Routes.IncomingCallScreen,
          arguments: {"callDetail": call},
        );
      } else if (screenName == "missedCall") {
        Get.toNamed(Routes.notificationScreen);
      } else if (screenName == "group_walkie" ||
          screenName == "groupWalkie" ||
          screenName == "walkie") {
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
          if (GroupWalkieService.instance.currentGroupId != null &&
              GroupWalkieService.instance.currentGroupId != groupId) {
            await GroupWalkieService.instance.leaveGroup();
          }

          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toNamed(
              Routes.groupWalkieScreen,
              arguments: {
                "groupId": groupId,
                "groupName": groupName,
                "speakerName": speakerName,
                "speakerImage": speakerImage,
                "autoOpened": true,
              },
            );
          });
        }
      }
    } else {
      if (screenName == "group_walkie" ||
          screenName == "groupWalkie" ||
          screenName == "walkie") {
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

        if (groupId.isNotEmpty &&
            GroupWalkieService.instance.currentGroupId != groupId &&
            Get.currentRoute != Routes.groupWalkieScreen) {
          WalkieInviteDialog.show(
            groupId: groupId,
            groupName: groupName,
            speakerName: speakerName,
            speakerImage: speakerImage,
          );
        }
      }

      if (message.data['screen_name'] == "incomingCall") {
        final callData = jsonDecode(message.data['callData']);

        final originalCallId = callData['callId'].toString();
        socket?.emit("CallingStatus", {
          "callId": originalCallId,
          "remoteUserId": int.tryParse(callData['callerId'].toString()) ?? 0,
          "callingStatus": "Ringing",
        });
        if (Platform.isAndroid) {
          final Map<String, String> userInfo = callData.map<String, String>(
                  (key, value) => MapEntry(key.toString(), value.toString()));
          await ConnectycubeFlutterCallKit.showCallNotification(
            CallEvent(
              sessionId: callIdToUuid(callData['callId'].toString()),
              callerName: callData['callerName'],
              callType: callData['isVideo'] == true ? 1 : 0,
              opponentsIds: {int.parse(callData['callerId'])},
              callerId: int.parse(callData['callerId']),
              userInfo: userInfo,
            ),
          );
          CallSessionState.sessionId = callData['callId'].toString();
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
        if (Platform.isAndroid) {
          final Map<String, String> userInfo = callData.map<String, String>(
                  (key, value) => MapEntry(key.toString(), value.toString()));
          await ConnectycubeFlutterCallKit.showCallNotification(
            CallEvent(
              sessionId: callIdToUuid(callData['callId'].toString()),
              callerName: callData['groupName'],
              callType: callData['isVideo'] == true ? 1 : 0,
              opponentsIds: {int.parse(callData['callerId'])},
              callerId: int.parse(callData['callerId']),
              userInfo: userInfo,
            ),
          );
          CallSessionState.sessionId = callData['callId'].toString();
        }
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
      // else if (message.data['screen_name'] == "groupCallEnded") {
      //   final c = Get.find<GroupCallingController>();
      //   try {
      //     if (PictureInPicture.isActive) {
      //       PictureInPicture.stopPiP();
      //     }
      //   } catch (_) {}
      //   await c.endCall();
      // }

    }
  }
}
