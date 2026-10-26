import 'dart:developer';

import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/modules/call/Controller/contact_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallService {
  Future<void> startOutGoingCall(
      BuildContext context, {
        required String callerId,
        required String remoteUserId,
        required bool is_video,
        dynamic callerName,
        String? callerProfile,
      }) async {
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

    // Call se wapas aate hi contacts silently refresh (search filter same rahega)
    if (Get.isRegistered<ContactController>()) {
      ContactController.instance.silentRefresh(force: true);
    }
  }
}