import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class WalkieNotificationServices {

  Future<void> showWalkieNotification(Map<String, dynamic> callData) async {
    const String channelId = "walkie_call_channel";

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      "Walkie Talkie Calls",
      description: "Incoming Walkie Talkie Calls",
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      channelId,
      "Walkie Talkie Calls",
      channelDescription: "Incoming Walkie Talkie Calls",
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      sound: const RawResourceAndroidNotificationSound("recieve_notification"),
      enableVibration: true,
      actions: const [
        AndroidNotificationAction(
          "WALKIE_ACCEPT",
          "Accept",
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          "WALKIE_REJECT",
          "Reject",
          cancelNotification: true,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      1001,
      "Incoming Walkie-Talkie",
      "${callData['callerName']} wants to talk",
      notificationDetails,
      payload: jsonEncode(callData), // 🔴 REQUIRED
    );
  }

  /// ✅ ACCEPT
  void acceptWalkieCall(Map<String, dynamic> callData) {
    print("AcceptCall=========>");
    final offer = jsonDecode(
      utf8.decode(base64Decode(callData['sdpOfferCompressed'])),
    );
    //Accept after Without App Open recieve the voice of call user
  }

  /// ❌ REJECT
  void rejectWalkieCall(Map<String, dynamic> callData) {
    print("RejectCall=========>");

  }
}
