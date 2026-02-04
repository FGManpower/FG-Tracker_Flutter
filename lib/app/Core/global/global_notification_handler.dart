import 'dart:convert';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/CallEvents_NotificationServices.dart';
import 'package:fgtracker/app/Data/Services/SignallingService.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Data/Services/Walkie_NotificationSerives.dart';

const String _consumeKey = "notificationConsumed";

class GlobalNotificationHandler with WidgetsBindingObserver {
  static final GlobalNotificationHandler instance =
      GlobalNotificationHandler._internal();

  GlobalNotificationHandler._internal();

  AppLifecycleState? _lastState;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_lastState == AppLifecycleState.paused) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      bool isConsumed = prefs.getBool(_consumeKey) ?? true;

      if (!isConsumed) {
        log("Found unconsumed notification. Processing now.$isConsumed");
        await prefs.setBool("notificationConsumed", true);
        await handlePendingNotification();
      }
    }

    _lastState = state;
  }
}

Future<void> handlePendingNotification() async {
  FlutterRingtonePlayer().stop();
  NotificationResponse? response;
  final details =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (details?.notificationResponse != null) {
    response = details!.notificationResponse;
  }

  response ??= NotificationHolder.pendingResponse;

  if (response == null || response.payload == null) return;

  final Map<String, dynamic> callData = jsonDecode(response.payload!);

  FlutterRingtonePlayer().stop();

  if (response.actionId == "CALL_ACCEPT") {
    await _ensureSocketReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("=======GoingFromBackgroundState");
      CustomNotificationServices().navigateToCallScreen(callData);
    });
  } else if (response.actionId == "CALL_DECLINE") {
    CustomNotificationServices().declineCall(callData);
  } else if (response.actionId == null) {
    CustomNotificationServices().navigateToIncomingCallScreen(callData);
  }

  NotificationHolder.clear();
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> _ensureSocketReady() async {
  final userId = Global.storageServices.get(PrefConst.userId)?.toString();

  if (userId == null || userId.isEmpty) {
    log("userId missing, cannot init socket");
    return;
  }

  if (SignallingService.instance.socket == null ||
      SignallingService.instance.socket!.disconnected) {
    log("Reconnecting socket (terminated state)");

    SignallingService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfCallerID: userId,
    );
    await Future.delayed(const Duration(milliseconds: 900));
  }

  log("socket ready");
}

Future<void> handleTerminatedCallIfAny() async {
  FlutterRingtonePlayer().stop();
  final prefs = await SharedPreferences.getInstance();

  await prefs.reload();


  bool isConsumed = prefs.getBool(_consumeKey) ?? true;
  debugPrint("======isConsume-${isConsumed}");
  if (isConsumed) return;
  await prefs.setBool("notificationConsumed", true);
  NotificationResponse? response;

  final details =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (details?.notificationResponse != null) {
    response = details!.notificationResponse;
  }
  debugPrint("======response-${response}");
  response ??= NotificationHolder.pendingResponse;

  if (response == null || response.payload == null) return;
  debugPrint("======responsePayload-${response.payload}");
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
  debugPrint("======response.actionId-${response.actionId}");
  if (response.actionId == "CALL_ACCEPT") {
    await _ensureSocketReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("=======GoingFromTerminatedState");
      CustomNotificationServices().navigateToCallScreen(callData);
    });
  } else if (response.actionId == "CALL_DECLINE") {
    CustomNotificationServices().declineCall(callData);
  } else if (response.actionId == null) {
    debugPrint("======response.actionIdNull-${response.actionId}");
    CustomNotificationServices().navigateToIncomingCallScreen(callData);
  }
  debugPrint("======response.actionIdReturn-${response.actionId}");
  NotificationHolder.clear();
}
