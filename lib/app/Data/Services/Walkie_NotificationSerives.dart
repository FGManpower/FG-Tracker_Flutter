import 'package:fgtracker/l10n/l10n.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class WalkieNotificationServices {

  Future<void> showWalkieNotification(Map<String, dynamic> callData) async {
    const String channelId = "walkie_call_channel";
    // Can run without GetX state: read the language from prefs.
    final l10n = await loadAppL10nFromPrefs();

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      l10n.notif_channelWalkieCallsName,
      description: l10n.notif_channelWalkieCallsDesc,
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      channelId,
      l10n.notif_channelWalkieCallsName,
      channelDescription: l10n.notif_channelWalkieCallsDesc,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      sound: const RawResourceAndroidNotificationSound("recieve_notification"),
      enableVibration: true,
      actions: [
        AndroidNotificationAction(
          "WALKIE_ACCEPT",
          l10n.notif_accept,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          "WALKIE_REJECT",
          l10n.notif_reject,
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
      l10n.notif_incomingWalkieTitle,
      l10n.notif_wantsToTalk("${callData['callerName']}"),
      notificationDetails,
      payload: jsonEncode(callData), // 🔴 REQUIRED
    );
  }

  /// ✅ ACCEPT
  void acceptWalkieCall(Map<String, dynamic> callData) {
    final offer = jsonDecode(
      utf8.decode(base64Decode(callData['sdpOfferCompressed'])),
    );
    //Accept after Without App Open recieve the voice of call user
  }

  /// ❌ REJECT
  void rejectWalkieCall(Map<String, dynamic> callData) {

  }
}
