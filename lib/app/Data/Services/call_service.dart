import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/modules/call/Controller/contact_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The one entry point for outgoing 1:1 calls (chat, Calls tab, profile,
/// tracking map, dialogs). Doc 02 §5, Phase 2.
class CallService {
  /// Checks the live call and the permissions and returns the call-screen
  /// arguments, or `null` when the call must not start.
  ///
  /// Nothing is sent to the other user before this returns arguments: the
  /// call screen emits `makeCall` only after it opens (P-01).
  Future<Map<String, dynamic>?> prepareOutgoingCall({
    required String callerId,
    required String remoteUserId,
    required bool is_video,
    dynamic callerName,
    String? callerProfile,
  }) async {
    // Never replace a live call (e.g. minimized in the overlay); drop a
    // finished controller so the new call starts clean (BUG-CALL-01/21).
    if (!CallingController.prepareForNewCall()) return null;

    // P-01 … P-04: explain, ask, Settings, or voice instead of video.
    final CallPermResult perm =
        await CallPermissionFlow().beforeCall(video: is_video, incoming: false);
    if (!perm.proceed) return null;

    final String profile = callerProfile ?? MyAppTheme.ProfilenotFoundImg;
    return <String, dynamic>{
      "callerId": callerId,
      "remoteUserId": remoteUserId,
      "offer": null,
      "is_video": perm.video,
      "callerName": callerName,
      "profileImage": profile,
      "callerProfile": profile,
      "callType": "outGoing",
    };
  }

  Future<void> startOutGoingCall(
    BuildContext context, {
    required String callerId,
    required String remoteUserId,
    required bool is_video,
    dynamic callerName,
    String? callerProfile,
  }) async {
    final Map<String, dynamic>? arg = await prepareOutgoingCall(
      callerId: callerId,
      remoteUserId: remoteUserId,
      is_video: is_video,
      callerName: callerName,
      callerProfile: callerProfile,
    );
    if (arg == null) return;

    await Get.toNamed(
      Routes.callScreen,
      arguments: arg,
    );

    if (Get.isRegistered<ContactController>()) {
      ContactController.instance.silentRefresh(force: true);
    }
  }
}
