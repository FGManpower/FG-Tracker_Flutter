import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

class GroupCallService {
  static final GroupCallService instance = GroupCallService._internal();
  GroupCallService._internal();

  /// Master switch for STARTING outgoing group calls from the UI.
  /// Set to false to disable group calling and show "Coming Soon".
  static const bool isGroupCallEnabled = false;

  /// Shared "Coming soon" feedback for all group call buttons.
  static void showComingSoon() {
    Utils().fluttertoast(appL10n.call_groupCallComingSoon);
  }

  Future<void> startGroupCall(
      BuildContext context, {
        required String groupId,
        required String groupName,
        required bool isVideo,
        String? groupProfile,
        int? memberCount,
      }) async {
    if (!isGroupCallEnabled) {
      showComingSoon();
      return;
    }

    final CallPermResult perm =
        await CallPermissionFlow().beforeCall(video: isVideo, incoming: false);
    if (!perm.proceed) return;

    Get.toNamed(
      Routes.groupCallingScreen,
      arguments: {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfile": groupProfile,
        "isVideo": perm.video,
        "memberCount": memberCount ?? 0,
        "callType": "outgoing",
      },
    );
  }
}
