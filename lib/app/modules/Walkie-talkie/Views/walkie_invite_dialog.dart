import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Data/Services/Walkie-Talkie-Service.dart';
import '../../../routes/app_pages.dart';

class WalkieInviteDialog {
  static bool _isShowing = false;

  static void show({
    required String groupId,
    required String groupName,
    required String speakerName,
    required String speakerImage,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      _InviteDialogWidget(
        groupId: groupId,
        groupName: groupName,
        speakerName: speakerName,
        speakerImage: speakerImage,
      ),
      barrierDismissible: false,
    ).then((_) {
      _isShowing = false;
    });

    // Auto dismiss after 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (_isShowing && Get.isDialogOpen == true) {
        Get.back();
        _isShowing = false;
      }
    });
  }
}

class _InviteDialogWidget extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String speakerName;
  final String speakerImage;

  const _InviteDialogWidget({
    required this.groupId,
    required this.groupName,
    required this.speakerName,
    required this.speakerImage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF161A30),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFF6B4EFF).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulse icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EFF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_voice_rounded,
                color: const Color(0xFF6B4EFF),
                size: 40.sp,
              ),
            ),
            SizedBox(height: 16.h),

            // Speaker Avatar
            CircleAvatar(
              radius: 32.r,
              backgroundColor: const Color(0xFF6B4EFF).withOpacity(0.2),
              backgroundImage: speakerImage.isNotEmpty
                  ? NetworkImage(ConstRes.aImageBaseUrl + speakerImage)
                  : null,
              child: speakerImage.isEmpty
                  ? Text(
                _getInitials(speakerName),
                style: TextStyle(
                  color: const Color(0xFF6B4EFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              )
                  : null,
            ),
            SizedBox(height: 12.h),

            Text(
              speakerName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),

            Text(
              "is talking on Walkie-Talkie",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 8.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EFF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                groupName,
                style: TextStyle(
                  color: const Color(0xFF8C73FF),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Dismiss",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Get.back(); // close dialog

                      // If somehow in another session, leave first
                      if (GroupWalkieService.instance.currentGroupId != null) {
                        await GroupWalkieService.instance.leaveGroup();
                      }

                      Get.toNamed(Routes.groupWalkieScreen, arguments: {
                        "groupId": groupId,
                        "groupName": groupName,
                        "speakerName": speakerName,
                        "autoOpened": true,
                      });
                    },
                    icon: Icon(Icons.mic_rounded, size: 18.sp),
                    label: Text(
                      "Join Walkie",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4EFF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}