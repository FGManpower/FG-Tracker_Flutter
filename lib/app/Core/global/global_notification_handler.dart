import 'dart:convert';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Custom_NotificationServices.dart';
import 'package:fgtracker/app/Data/Services/SignallingService.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Data/Services/CallStateTracker.dart';
import '../../Data/Services/Walkie_NotificationSerives.dart';

class GlobalNotificationHandler with WidgetsBindingObserver {
  static final GlobalNotificationHandler instance =
      GlobalNotificationHandler._internal();

  GlobalNotificationHandler._internal();

  AppLifecycleState? _lastState;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only react when coming FROM background
    // print("_lastState==$_lastState");

    if (_lastState == AppLifecycleState.paused) {
      handlePendingNotification();
    }

    _lastState = state;
  }
}

Future<void> handlePendingNotification() async {
  FlutterRingtonePlayer().stop();
  NotificationResponse? response;
  final pref = await SharedPreferences.getInstance();
  print("====NotificationStatus==${await pref.getString("notificationConsumed").toString()}");
  if (pref.getString("notificationConsumed").toString()=="true") return;


  final details =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (details?.notificationResponse != null) {
    response = details!.notificationResponse;
  }

  response ??= NotificationHolder.pendingResponse;

  if (response == null || response.payload == null) return;

  // 🔒 MARK AS CONSUMED IMMEDIATELY
  // AppLaunchState.notificationConsumed = true;

  await pref.setString("notificationConsumed", "true");

  final Map<String, dynamic> callData = jsonDecode(response.payload!);

  FlutterRingtonePlayer().stop();


  if (response.actionId == "CALL_ACCEPT") {
    await _ensureSocketReady();

    // wait for navigation stack
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("=======GoingFromBackgroundState");
      CustomNotificationServices().navigateToCallScreen(callData);
    });
  } else if (response.actionId == "CALL_DECLINE") {
    CustomNotificationServices().declineCall(callData);
  }

  NotificationHolder.clear();
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> _ensureSocketReady() async {
  final userId = Global.storageServices.get(PrefConst.userId)?.toString();

  if (userId == null || userId.isEmpty) {
    debugPrint("❌ userId missing, cannot init socket");
    return;
  }

  if (SignallingService.instance.socket == null ||
      SignallingService.instance.socket!.disconnected) {
    debugPrint("🔌 Reconnecting socket (terminated state)");

    SignallingService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfCallerID: userId,
    );

    // VERY IMPORTANT delay
    await Future.delayed(const Duration(milliseconds: 900));
  }

  debugPrint("✅ socket ready");
}

Future<void> handleTerminatedCallIfAny() async {
  final pref = await SharedPreferences.getInstance();
  print("====TerminatedNotificationStatus==${await pref.getString("notificationConsumed").toString()}");
  if (pref.getString("notificationConsumed").toString()=="true") return;


  FlutterRingtonePlayer().stop();
  NotificationResponse? response;

  final details =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (details?.notificationResponse != null) {
    response = details!.notificationResponse;
  }

  response ??= NotificationHolder.pendingResponse;

  if (response == null || response.payload == null) return;

  // 🔒 MARK AS CONSUMED IMMEDIATELY
  await pref.setString("notificationConsumed", "true");

  // AppLaunchState.notificationConsumed = true;

  final callData = jsonDecode(response.payload!);
  final userId = Global.storageServices.get(PrefConst.userId)?.toString();

  if (SignallingService.instance.socket == null ||
      SignallingService.instance.socket!.disconnected) {
    SignallingService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfCallerID: userId!,
    );
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  if (response.actionId == "CALL_ACCEPT") {
    await _ensureSocketReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("=======GoingFromTerminatedState");
      CustomNotificationServices().navigateToCallScreen(callData);
    });
  } else if (response.actionId == "CALL_DECLINE") {
    CustomNotificationServices().declineCall(callData);
  } else if (response.actionId == null) {
    CustomNotificationServices().navigateToIncomingCallScreen(callData);
  }

//====Clear===>
  await CallCleanupManager.onCallScreenOpened();
}

class CallCleanupManager {
  static bool callActive = false;

  static Future<void> onCallScreenOpened() async {
    if (callActive) return;
    callActive = true;

    FlutterRingtonePlayer().stop();
    await flutterLocalNotificationsPlugin.cancelAll();

    NotificationHolder.clear();
    await Global.storageServices.remove("TERMINATED_CALL_ACCEPT");

    CallStateTracker.isIncomingCallScreenOpen = false;
  }

  static void onCallEnded() {
    callActive = false;
  }
}
