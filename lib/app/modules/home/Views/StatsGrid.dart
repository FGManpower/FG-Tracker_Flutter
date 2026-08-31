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
    this.onTap,
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
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              SizedBox(height: 8.h),
              reausabletext(
                title,
                fontsize: 11.sp,
                color: Colors.black87,
                fontfamily: FontFamily.interSemiBold,
                align: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              reausabletext(
                value,
                fontsize: 18.sp,
                color: Colors.black,
                fontfamily: FontFamily.interBold,
                align: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              reausabletext(
                subtitle,
                fontsize: 10.sp,
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
