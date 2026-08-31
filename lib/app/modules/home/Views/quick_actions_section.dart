import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Messages/Views/call_screen.dart';
import 'package:fgtracker/app/modules/Messages/Views/video_call_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            reausabletext(
              "Quick Actions",
              fontsize: 16.sp,
              fontfamily: FontFamily.interBold,
            ),
          ],
        ),
        SizedBox(height: 15.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.0,
          children: [
            _QuickActionCard(
              "Calling",
              Icons.phone,
              onTap: () => Get.to(() => const CallScreen()),
            ),
            _QuickActionCard(
              "Walkie Talkie",
              Icons.settings_cell,
              onTap: () => Get.toNamed(Routes.WalkieGroupSelect),
            ),
            _QuickActionCard("Tracking", Icons.location_on, isComingSoon: true),
            _QuickActionCard(
              "Video Call",
              Icons.videocam,
              onTap: () => Get.to(() => const VideoCallScreen()),
            ),
            _QuickActionCard("Chatting", Icons.chat_bubble, isComingSoon: true),
            _QuickActionCard(
              "Group Chat",
              Icons.groups,
              onTap: () => Get.toNamed(Routes.GroupsList),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard(
    this.title,
    this.icon, {
    this.onTap,
    this.isComingSoon = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isComingSoon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F8FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF6B4DFF).withOpacity(0.05),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: const Color(0xFF6B4DFF), size: 32.sp),
                      SizedBox(height: 8.h),
                      reausabletext(
                        title,
                        fontsize: 12.sp,
                        fontfamily: FontFamily.interSemiBold,
                        color: Colors.black87,
                        align: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      if (!isComingSoon)
                        Container(
                          width: 12.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B4DFF),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        )
                      else
                        SizedBox(height: 14.h),
                    ],
                  ),
                ),
                if (isComingSoon) ...[
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.35)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      color: Colors.black.withOpacity(0.85),
                      alignment: Alignment.center,
                      child: Text(
                        "COMING SOON",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
