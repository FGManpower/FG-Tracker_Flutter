import 'dart:convert';
import 'package:fgtracker/app/Data/Services/Walkie_NotificationSerives.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


import '../constant/notification_holder.dart';
import '../../Data/Services/Custom_NotificationServices.dart';

class GlobalNotificationHandler with WidgetsBindingObserver {
  static final GlobalNotificationHandler instance =
  GlobalNotificationHandler._internal();

  GlobalNotificationHandler._internal();

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      handlePendingNotification();
    }
  }

  Future<void> handlePendingNotification() async {
    NotificationResponse? response;

    final details =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details?.notificationResponse != null) {
      response = details!.notificationResponse;
    }

    response ??= NotificationHolder.pendingResponse;

    if (response == null || response.payload == null) return;

    final Map<String, dynamic> callData =
    jsonDecode(response.payload!);

    FlutterRingtonePlayer().stop();

    if (response.actionId == "CALL_ACCEPT") {
      await CustomNotificationServices().navigateToCallScreen(callData);
    } else if (response.actionId == "CALL_DECLINE") {
      CustomNotificationServices().declineCall(callData);
    }

    NotificationHolder.clear();
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
