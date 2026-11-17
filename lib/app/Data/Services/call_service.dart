import 'dart:developer';

import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/call/Controller/contact_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CallService {
  Future<void> startOutGoingCall(
      BuildContext context, {
        required String callerId,
        required String remoteUserId,
        required bool is_video,
        dynamic callerName,
        String? callerProfile,
      }) async {
    // 1. Check & request Microphone permission
    final micStatus = await Permission.microphone.request();
    if (micStatus.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    if (!micStatus.isGranted) {
      Utils().fluttertoast("Microphone permission is required for calling");
      return;
    }

    // 2. Check & request Camera permission for video calls
    if (is_video) {
      final camStatus = await Permission.camera.request();
      if (camStatus.isPermanentlyDenied) {
        await openAppSettings();
        return;
      }
      if (!camStatus.isGranted) {
        Utils().fluttertoast("Camera permission is required for video calling");
        return;
      }
    }

    dynamic arg = {
      "callerId": callerId,
      "remoteUserId": remoteUserId,
      "offer": null,
      "is_video": is_video,
      "callerName": callerName,
      "profileImage": callerProfile ?? MyAppTheme.ProfilenotFoundImg,
      "callType": "outGoing",
    };

    await Get.toNamed(
      Routes.callScreen,
      arguments: arg,
    );

    if (Get.isRegistered<ContactController>()) {
      ContactController.instance.silentRefresh(force: true);
    }
  }
}