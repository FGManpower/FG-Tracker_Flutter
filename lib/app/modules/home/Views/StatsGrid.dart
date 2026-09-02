import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final GroupCountDetail detail = controller.groupCount.value;
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.groups,
              iconColor: const Color(0xFF6B4DFF),
              title: "Groups",
              value: detail.totalGroups.toString(),
              subtitle: "Total",
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              icon: Icons.person,
              iconColor: const Color(0xFF10B981),
              title: "Online",
              value: detail.activeMembers.toString(),
              subtitle: "Now",
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              icon: Icons.people_alt,
              iconColor: const Color(0xFF3B82F6),
              title: "Members",
              value: detail.totalMembers.toString(),
              subtitle: "Total",
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              icon: Icons.supervised_user_circle,
              iconColor: const Color(0xFFF59E0B),
              title: "Ghost Mode",
              value: detail.locationDisabledMembers.toString(),
              subtitle: "Active",
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 13.h,
            horizontal: 6.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(height: 6.h),
              reausabletext(
                title,
                fontsize: 10.5.sp,
                color: Colors.black87,
                fontfamily: FontFamily.interSemiBold,
                align: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              reausabletext(
                value,
                fontsize: 15.sp,
                color: Colors.black,
                fontfamily: FontFamily.interBold,
                align: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              reausabletext(
                subtitle,
                fontsize: 9.5.sp,
                color: Colors.grey,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
