import 'dart:developer';

import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallService {
  startOutGoingCall(
    BuildContext context, {
    required String callerId,
    required String remoteUserId,
    required bool is_video,
    dynamic callerName,
    String? callerProfile,
    String? destinationPhone,
  }) {
    if (!CallValidation.validateCall(
      destinationPhone: destinationPhone,
      destinationUserId: remoteUserId,
    )) {
      return;
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
    log("=========OutGoingCallArgumentDetail:${arg}");
    Get.toNamed(
      Routes.callScreen,
      arguments:arg
    );
  }
}
