import 'package:fgtracker/app/Data/Services/GroupCountService.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Views/LiveStatus/components/online_member.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'components/ghost_member.dart';
import 'components/total_member.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final GroupCountDetail detail = GroupCountService.instance.groupCount.value;

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              imagePath: "assets/icons/stat_groups.png",
              iconColor: const Color(0xFF6B4DFF),
              title: "Groups",
              value: detail.totalGroups.toString(),
              subtitle: "Total",
              onTap: () {
                Get.toNamed(Routes.GroupsList);
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              imagePath: "assets/icons/stat_live_beacon.png",
              iconColor: const Color(0xFF10B981),
              title: "Online",
              value: detail.activeMembers.toString(),
              subtitle: "Now",
              onTap: () {
                Get.to(() => OnlineMember());
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              imagePath: "assets/icons/stat_online.png",
              iconColor: const Color(0xFF3B82F6),
              title: "Members",
              value: detail.totalMembers.toString(),
              subtitle: "Total",
              onTap: () {
                Get.to(() => const TotalMember());
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              imagePath: "assets/icons/stat_private_mode.png",
              iconColor: const Color(0xFF6366F1),
              title: "Private Mode",
              value: detail.locationDisabledMembers.toString(),
              subtitle: "Members",
              onTap: () {
                Get.to(() => GhostMember());
              },
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    this.icon,
    this.imagePath,
    this.iconColor = const Color(0xFF6B4DFF),
    required this.title,
    required this.value,
    required this.subtitle,
    this.hasOnlineIndicator = false,
    this.onTap,
  });

  final IconData? icon;
  final String? imagePath;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool hasOnlineIndicator;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 4.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B1F70).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE9ECF4),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  if (imagePath != null)
                    SizedBox(
                      width: 44.w,
                      height: 44.w,
                      child: Center(
                        child: Image.asset(
                          imagePath!,
                          width: 44.w,
                          height: 44.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon ?? Icons.circle,
                        color: iconColor,
                        size: 22.sp,
                      ),
                    ),
                  if (hasOnlineIndicator && imagePath == null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 5.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.interSemiBold,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222741),
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.interBold,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10153D),
                  height: 1.1,
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.interRegular,
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E95A3),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}