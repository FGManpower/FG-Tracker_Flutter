import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../global_widget/common_widget.dart';
import '../Controller/group_calling_controller.dart';

class GroupParticipantsSheet {
  static void show(GroupCallingController controller) {
    Get.bottomSheet(
      SizedBox(),
      // Container(
      //   height: Get.height * 0.7,
      //   decoration: BoxDecoration(
      //     color: const Color(0xFFF8F7FF),
      //     borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      //   ),
      //   padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Center(
      //         child: Container(
      //           width: 40.w,
      //           height: 4.h,
      //           decoration: BoxDecoration(
      //             color: Colors.grey.shade400,
      //             borderRadius: BorderRadius.circular(10.r),
      //           ),
      //         ),
      //       ),
      //       SizedBox(height: 20.h),
      //       Obx(() => reausabletext(
      //             "Not in this call (${controller.notInCallParticipants.length})",
      //             fontsize: 16,
      //             fontfamily: FontFamily.interSemiBold,
      //             color: const Color(0xFF1E1147),
      //           )),
      //       SizedBox(height: 10.h),
      //       Expanded(
      //         child: Obx(() {
      //           return ListView.separated(
      //             itemCount: controller.notInCallParticipants.length,
      //             separatorBuilder: (_, __) => SizedBox(height: 15.h),
      //             itemBuilder: (context, index) {
      //               final participant = controller.notInCallParticipants[index];
      //               return Row(
      //                 children: [
      //                   CircleAvatar(
      //                     radius: 25.r,
      //                     backgroundImage: NetworkImage(
      //                       participant.profileImage ??
      //                           "https://via.placeholder.com/150",
      //                     ),
      //                   ),
      //                   SizedBox(width: 15.w),
      //                   Expanded(
      //                     child: reausabletext(
      //                       participant.name,
      //                       fontsize: 15,
      //                       fontfamily: FontFamily.interMedium,
      //                       color: const Color(0xFF1E1147),
      //                     ),
      //                   ),
      //                   InkWell(
      //                     onTap: () =>
      //                         controller.notifyParticipant(participant),
      //                     child: Container(
      //                       padding: EdgeInsets.all(8.r),
      //                       decoration: BoxDecoration(
      //                         color: const Color(0xFFE9E5FE),
      //                         shape: BoxShape.circle,
      //                       ),
      //                       child: const Icon(Icons.notifications,
      //                           color: Color(0xFF6E5CA4), size: 20),
      //                     ),
      //                   ),
      //                 ],
      //               );
      //             },
      //           );
      //         }),
      //       ),
      //     ],
      //   ),
      // ),
      isScrollControlled: true,
    );
  }
}

class GroupCallMoreSheet {
  static void show({
    required VoidCallback onShareScreen,
    required VoidCallback onSendMessage,
  }) {
    Get.bottomSheet(
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
                  ListTile(
                    leading: const Icon(Icons.screen_share_outlined,
                        color: Color(0xFF6E5CA4)),
                    title: reausabletext("Share screen",
                        fontsize: 14, fontfamily: FontFamily.interMedium),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: onShareScreen,
                  ),
                  const Divider(height: 1, indent: 50),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF6E5CA4)),
                    title: reausabletext("Send message",
                        fontsize: 14, fontfamily: FontFamily.interMedium),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: onSendMessage,
                  ),
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
                child: reausabletext("Cancel",
                    fontsize: 14,
                    fontfamily: FontFamily.interSemiBold,
                    color: const Color(0xFF1E1147)),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
