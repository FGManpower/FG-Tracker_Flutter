import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallService {
  startCall(
    BuildContext context, {
    required String callerId,
    required String remoteUserId,
    required bool is_video,
    dynamic offer,
    dynamic callerName,
  }) {
    Get.toNamed(
      Routes.callScreen,
      arguments: {
        "callerId": callerId,
        "remoteUserId": remoteUserId,
        "offer": offer,
        "is_video": is_video,
        "callerName": callerName,
        "callType": "outGoing",
      },
    );
  }
}
