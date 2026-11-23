import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

class GroupCallService {
  static final GroupCallService instance = GroupCallService._internal();
  GroupCallService._internal();

  /// Master switch for STARTING outgoing group calls from the UI.
  /// Enabled for WhatsApp-grade group calling.
  static const bool isGroupCallEnabled = true;

  /// Shared "Coming soon" feedback for all group call buttons.
  static void showComingSoon() {
    Utils().fluttertoast(appL10n.call_groupCallComingSoon);
  }

  void startGroupCall(
      BuildContext context, {
        required String groupId,
        required String groupName,
        required bool isVideo,
        String? groupProfile,
        int? memberCount,
      }) {
    if (!isGroupCallEnabled) {
      showComingSoon();
      return;
    }

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
