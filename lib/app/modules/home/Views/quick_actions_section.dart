import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Track/Views/Tracking_screen.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/call_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Messages/Views/chatlist_screen.dart';


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
              "Audio/Video Call",
              Icons.call,
              onTap: () => Get.to(() => CallScreen()),
            ),
            _QuickActionCard(
              "Walkie Talkie",
              Icons.settings_cell,
              onTap: () => Get.toNamed(Routes.WalkieGroupSelect),
            ),
            _QuickActionCard(
              "Tracking",
              Icons.location_on,
              isComingSoon: false,
              onTap: () => Get.to(() => TrackingScreen()),
            ),
            _QuickActionCard(
              "Chatting",
              Icons.message_outlined,
              onTap: () => Get.to(() => const ChatListScreen()),
            ),
            _QuickActionCard(
              "Group Chat",
              Icons.groups,
              onTap: () => Get.toNamed(Routes.GroupsList),
            ),
            _QuickActionCard(
              "Safe Zone",
              Icons.verified_user_rounded,
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
              color: const Color(0xFF6B4DFF).withValues(alpha: 0.05),
            ),
          ),
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
      ),
    );
  }
}