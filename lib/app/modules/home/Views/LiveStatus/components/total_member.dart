import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TotalMember extends StatefulWidget {
  const TotalMember({super.key});

  @override
  State<TotalMember> createState() => _TotalMemberState();
}

class _TotalMemberState extends State<TotalMember> {
  late final LivesStatusController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LivesStatusController>()
        ? Get.find<LivesStatusController>()
        : Get.put(LivesStatusController());

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double currentPosition = _scrollController.position.pixels;
    final double maxPosition = _scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 250) {
      controller.loadMoreMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: const Color(0xFFF7F8FC),
          titleSpacing: 16.w,
          title: Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_rounded,
                  color: const Color(0xFF6B4DFF),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Members',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '20 Total Members',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontFamily: FontFamily.interRegular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.memberLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: _buildTotalMemberContent(),
            ),
          );
        }
        if (controller.responseError.value.isNotEmpty) {
          return LostinternetConnection(
            retry: controller.getGroupMember,
            messgae: controller.responseError.value,
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: _buildTotalMemberContent(),
        );
      }),
    );
  }

  Widget _buildTotalMemberContent() {
    return Column(
      children: [
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
          ),
          child: TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search members...',
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                color: Colors.grey.shade400,
                fontFamily: FontFamily.interRegular,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20.sp,
                color: Colors.grey.shade400,
              ),
              suffixIcon: Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: controller.clearSearch,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: Colors.grey.shade400,
                  ),
                );
              }),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 16.w,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            _buildStatCard("20", "Total Members", Icons.group_rounded, const Color(0xFF6B4DFF), const Color(0xFFEDE9FE)),
            SizedBox(width: 8.w),
            _buildStatCard("14", "Active", Icons.fiber_manual_record_rounded, const Color(0xFF10B981), const Color(0xFFE8FDF2)),
            SizedBox(width: 8.w),
            _buildStatCard("4", "Inactive", Icons.access_time_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
            SizedBox(width: 8.w),
            _buildStatCard("2", "New This Month", Icons.person_add_rounded, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "All Members",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontFamily: FontFamily.interBold,
              ),
            ),
            Row(
              children: [
                Text(
                  "Sort: Name (A-Z)",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B4DFF),
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Expanded(
          child: _buildStaticMemberList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String count, String label, IconData icon, Color iconColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              count,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontFamily: FontFamily.interBold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                color: Colors.grey.shade600,
                fontFamily: FontFamily.interRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticMemberList() {
    final List<Map<String, String>> staticMembers = [
      {"name": "Samad", "team": "FG Manpower Development", "status": "Active", "joined": "12 Jan 2024"},
      {"name": "Priya Sharma", "team": "Event Management Team", "status": "Active", "joined": "08 Feb 2024"},
      {"name": "Imran Khan", "team": "Construction Team", "status": "Active", "joined": "15 Jan 2024"},
      {"name": "Neha Verma", "team": "Site Operations Team", "status": "Inactive", "joined": "22 Mar 2024"},
      {"name": "Rohit Verma", "team": "HR Department", "status": "Active", "joined": "05 Jan 2024"},
      {"name": "Pooja Mehta", "team": "Accounts Team", "status": "Inactive", "joined": "18 Feb 2024"},
      {"name": "Ariun Patel", "team": "Electrical Team", "status": "Active", "joined": "11 Apr 2024"},
      {"name": "Anjali Gupta", "team": "Administration Team", "status": "Active", "joined": "02 Feb 2024"},
      {"name": "Suresh Yadav", "team": "Construction Team", "status": "Inactive", "joined": "25 Mar 2024"},
    ];

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: staticMembers.length,
      itemBuilder: (context, index) {
        final member = staticMembers[index];
        final bool isActive = member["status"] == "Active";

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: const Color(0xFFEDE9FE),
                    child: Text(
                      member["name"]![0],
                      style: TextStyle(
                        color: const Color(0xFF6B4DFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member["name"]!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      member["team"]!,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        fontFamily: FontFamily.interRegular,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          member["status"]!,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Joined",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade400,
                      fontFamily: FontFamily.interRegular,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    member["joined"]!,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}