import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import '../../../../gen/fonts.gen.dart';

class GroupCallMoreSheet {
  static Future<void> show({
    required RxBool isScreenSharing,
    required VoidCallback onShareScreen,
    required VoidCallback onSendMessage,
    VoidCallback? onAddParticipants,
  }) {
    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E262C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: Colors.white12, width: 0.8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Header Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                appL10n.call_more,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Action Items Box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A3942),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  // Screen Sharing
                  Obx(
                    () => _buildTile(
                      icon: isScreenSharing.value
                          ? Icons.stop_screen_share_rounded
                          : Icons.screen_share_rounded,
                      iconColor: isScreenSharing.value
                          ? const Color(0xFFFF5252)
                          : const Color(0xFF25D366),
                      title: isScreenSharing.value
                          ? appL10n.call_stopSharing
                          : appL10n.call_shareScreen,
                      subtitle: isScreenSharing.value
                          ? "Tap to stop presenting your screen"
                          : "Present your screen to all call members",
                      onTap: onShareScreen,
                    ),
                  ),

                  Divider(color: Colors.white10, height: 1.h),

                  // Add Participants
                  if (onAddParticipants != null) ...[
                    _buildTile(
                      icon: Icons.person_add_alt_1_rounded,
                      iconColor: const Color(0xFF25D366),
                      title: "Add participants",
                      subtitle: "Invite other group members to this call",
                      onTap: onAddParticipants,
                    ),
                    Divider(color: Colors.white10, height: 1.h),
                  ],

                  // In-Call Group Chat
                  _buildTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: Colors.white,
                    title: "Message group",
                    subtitle: "Open group chat without leaving the call",
                    onTap: onSendMessage,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Cancel Button
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(30.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3942),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  appL10n.common_cancel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: FontFamily.interMedium,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: FontFamily.interRegular,
          color: Colors.white60,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }
}
