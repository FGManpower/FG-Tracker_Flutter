import 'package:fgtracker/app/Core/theme/appTheme.dart';
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
  }) {
    Get.toNamed(
      Routes.callScreen,
      arguments: {
        "callerId": callerId,
        "remoteUserId": remoteUserId,
        "offer": null,
        "is_video": is_video,
        "callerName": callerName,
        "callerProfile": callerProfile ?? MyAppTheme.ProfilenotFoundImg,
        "callType": "outGoing",
      },
    );
  }
}
