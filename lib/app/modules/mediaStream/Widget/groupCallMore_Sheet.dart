import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/utility.dart';
import '../../../global_widget/common_widget.dart';
import '../../../Model/group_call_participant.dart';

class GroupCallMoreSheet {
  static Future<void> show({
    required RxBool isScreenSharing,
    required VoidCallback onShareScreen,
    required VoidCallback onSendMessage,
  }) {
    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                children: [
                  Obx(() => ListTile(
                        leading: Icon(
                          isScreenSharing.value
                              ? Icons.stop_screen_share_outlined
                              : Icons.screen_share_outlined,
                          color: isScreenSharing.value
                              ? Colors.red
                              : const Color(0xFF6E5CA4),
                        ),
                        title: Text(
                          isScreenSharing.value
                              ? "Stop sharing"
                              : "Share screen",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: FontFamily.interMedium,
                            color: isScreenSharing.value
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        trailing:
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: onShareScreen,
                      )),
                ],
              ),
            ),
            SizedBox(height: 15.h),
            InkWell(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: const Color(0xFF1E1147),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
