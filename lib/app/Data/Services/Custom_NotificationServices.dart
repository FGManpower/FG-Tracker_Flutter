import 'dart:convert';
import 'dart:developer';
import 'package:fgtracker/app/Data/Services/Walkie_NotificationSerives.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

import '../../Core/constant/pref_res.dart';
import '../../Core/util/decomPress.dart';
import '../../Core/values/global.dart';
import '../../Model/call_model.dart';
import '../../routes/app_pages.dart';
import 'CallStateTracker.dart';
import 'SignallingService.dart';

class CustomNotificationServices {
  static const String channelId = "incoming_call_channel";

  final socket = SignallingService.instance.socket;

  CallUtils() {
    setupSocketCallEvents();
  }

  static Future<void> showIncomingCall(Map<String, dynamic> callData) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      "Incoming Calls",
      channelDescription: "Incoming audio/video calls",
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      actions: [
        const AndroidNotificationAction(
          "CALL_DECLINE",
          "Decline",
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          "CALL_ACCEPT",
          "Accept",
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    await flutterLocalNotificationsPlugin.show(
      999,
      "${callData['callerName']} is calling",
      callData['isVideo'] == "true"
          ? "Incoming Video Call"
          : "Incoming Audio Call",
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode(callData),
    );
  }

  Future<void> declineCall(Map<String, dynamic> data) async {
    FlutterRingtonePlayer().stop();
    final call = IncomingCallModel.fromMap(data);
    final myId = Global.storageServices.get(PrefConst.userId).toString();
    socket?.emit("rejectCall", {
      "callId": call.callId,
      "remoteUserId": myId,
    });

    CallStateTracker.isIncomingCallScreenOpen = false;
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> navigateToCallScreen(Map<String, dynamic> data) async {
    try {
      FlutterRingtonePlayer().stop();
      final call = IncomingCallModel.fromMap(data);
      CallStateTracker.isIncomingCallScreenOpen = false;
      Map<String, dynamic>? offer =
          await decomPress().decompressSDPOffer(call.sdpOfferCompressed);
      Get.offNamed(
        Routes.callScreen,
        arguments: {
          "callerId": call.callerId,
          "remoteUserId":
              Global.storageServices.get(PrefConst.userId).toString(),
          "offer": offer,
          "is_video": call.isVideo,
          "callerName": call.callerName,
          "callId": call.callId,
          "callerProfile": call.callerProfileImage,
        },
      );
    } catch (e) {
      FlutterRingtonePlayer().stop();
      log("[CallKit] Navigation error: $e");
    }
  }

  Future<void> navigateToIncomingCallScreen(Map<String, dynamic> data) async {
    try {
      final call = IncomingCallModel.fromMap(data);

      if (CallStateTracker.isIncomingCallScreenOpen) {
        return;
      }

      // CallStateTracker.isIncomingCallScreenOpen = true;
      Get.toNamed(
        Routes.IncomingCallScreen,
        arguments: {"callDetail": call},
      );
    } catch (e) {
      FlutterRingtonePlayer().stop();
      log("[CallKit] Navigation error: $e");
    }
  }

  void setupSocketCallEvents() {
    socket?.on("callEnded", (data) async {
      print("==========CallEndedSocketEvents");
      FlutterRingtonePlayer().stop();
      CallStateTracker.isIncomingCallScreenOpen = false;
      await flutterLocalNotificationsPlugin.cancelAll();

      if (Get.isOverlaysOpen || Get.isDialogOpen == true) {
        print("==========CallEndedSocketEvents1");
        Get.back();
      } else if (Get.currentRoute == Routes.callScreen) {
        Get.back();
        print("==========CallEndedSocketEvents2");
      }
    });

    socket?.on("missedCall", (data) async {
      FlutterRingtonePlayer().stop();
      CallStateTracker.isIncomingCallScreenOpen = false;
      await flutterLocalNotificationsPlugin.cancelAll();

      if (Get.currentRoute == Routes.callScreen) {
        Get.back();
      }
    });
  }
}
