import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieGroupSelectScreen extends StatelessWidget {
  const WalkieGroupSelectScreen({super.key});

  static final List<Map<String, dynamic>> _groups = [
    {
      'name': 'Construction Group',
      'members': 12,
      'online': true,
      'color': const Color(0xFFE8DEFF),
      'iconColor': const Color(0xFF6B4DFF),
    },
    {
      'name': 'Logistics Group',
      'members': 8,
      'online': true,
      'color': const Color(0xFFD1FAE5),
      'iconColor': const Color(0xFF10B981),
    },
    {
      'name': 'Security Group',
      'members': 10,
      'online': true,
      'color': const Color(0xFFE0E7FF),
      'iconColor': const Color(0xFF6366F1),
    },
    {
      'name': 'Maintenance Group',
      'members': 7,
      'online': false,
      'color': const Color(0xFFFFEDD5),
      'iconColor': const Color(0xFFF59E0B),
    },
    {
      'name': 'General Group',
      'members': 15,
      'online': true,
      'color': const Color(0xFFCFFAFE),
      'iconColor': const Color(0xFF06B6D4),
    },
    {
      'name': 'Event Group',
      'members': 6,
      'online': true,
      'color': const Color(0xFFFCE7F3),
      'iconColor': const Color(0xFFEC4899),
    },
    {
      'name': 'Housekeeping Group',
      'members': 9,
      'online': true,
      'color': const Color(0xFFEDE9FE),
      'iconColor': const Color(0xFF8B5CF6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            SizedBox(height: 8.h),
            _buildSearchBar(),
            SizedBox(height: 12.h),
            _buildTabs(),
            SizedBox(height: 12.h),
            Expanded(child: _buildGroupList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 16.sp, color: Colors.black87),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  "Walkie Talkie",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                reausabletext(
                  "Select a group to connect",
                  fontsize: 11.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          _circleIcon(Icons.search),
          SizedBox(width: 8.w),
          _circleIcon(Icons.add),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, size: 18.sp, color: const Color(0xFF6B4DFF)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.sp, color: Colors.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search groups",
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey,
                          fontFamily: FontFamily.interRegular,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            height: 44.h,
            width: 44.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child:
                Icon(Icons.tune, size: 18.sp, color: const Color(0xFF6B4DFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _tabChip("All Groups", Icons.groups, isSelected: true),
          SizedBox(width: 10.w),
          _tabChip("Recent", Icons.access_time, isSelected: false),
        ],
      ),
    );
  }

  Widget _tabChip(String title, IconData icon, {required bool isSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6B4DFF) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border:
            isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isSelected ? Colors.white : Colors.grey,
          ),
          SizedBox(width: 6.w),
          reausabletext(
            title,
            fontsize: 12.sp,
            color: isSelected ? Colors.white : Colors.grey,
            fontfamily: FontFamily.interSemiBold,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      itemCount: _groups.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final g = _groups[index];
        return _groupCard(g);
      },
    );
  }

  Widget _groupCard(Map<String, dynamic> g) {
    final bool online = g['online'] as bool;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: g['color'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups,
              color: g['iconColor'] as Color,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  g['name'] as String,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black87,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined,
                        size: 12.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    reausabletext(
                      "${g['members']} Members",
                      fontsize: 11.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    reausabletext(
                      online ? "Online" : "Offline",
                      fontsize: 11.sp,
                      color: online ? const Color(0xFF10B981) : Colors.grey,
                      fontfamily: FontFamily.interSemiBold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.mic_external_off,
              size: 18.sp,
              color: const Color(0xFF6B4DFF),
            ),
          ),
        ],
      ),
    );
  }
}
