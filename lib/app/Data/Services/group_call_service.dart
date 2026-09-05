import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupCallService {
  static final GroupCallService instance = GroupCallService._internal();
  GroupCallService._internal();

  void startGroupCall(
      BuildContext context, {
        required String groupId,
        required String groupName,
        required bool isVideo,
        String? groupProfile,
        int? memberCount,
      }) {
    // TODO: Emit backend group call creation socket event here.

    Get.toNamed(
      Routes.groupCallingScreen,
      arguments: {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfile": groupProfile,
        "isVideo": isVideo,
        "memberCount": memberCount ?? 0,
        "callType": "outgoing",
      },
    );
  }
}