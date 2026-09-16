import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/online_member_model.dart';
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
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LivesStatusController>()
        ? Get.find<LivesStatusController>()
        : Get.put(LivesStatusController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.allMemberData.isEmpty) {
        controller.getAllMembers();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double currentPosition = _scrollController.position.pixels;
    final double maxPosition = _scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 250) {
      controller.loadMoreAllMembers();
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
                    Obx(() {
                      final count = controller.totalMembersCount.value > 0
                          ? controller.totalMembersCount.value
                          : controller.allMemberData.length;
                      return Text(
                        '$count Total Members',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontFamily: FontFamily.interRegular,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.allMemberLoading.value && controller.allMemberData.isEmpty) {
          return Skeletonizer(
            enabled: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: _buildSkeletonContent(),
            ),
          );
        }
        if (controller.allResponseError.value.isNotEmpty && controller.allMemberData.isEmpty) {
          return LostinternetConnection(
            retry: controller.getAllMembers,
            messgae: controller.allResponseError.value,
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF6B4DFF),
          onRefresh: controller.refreshAllMembers,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: _buildTotalMemberContent(),
          ),
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
            onChanged: controller.onAllSearchChanged,
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
                  onPressed: controller.clearAllSearch,
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
        Obx(() {
          final total = controller.totalMembersCount.value > 0
              ? controller.totalMembersCount.value
              : controller.allMemberData.length;
          final active = controller.activeMembersCount.value;
          final inactive = controller.inactiveMembersCount.value > 0
              ? controller.inactiveMembersCount.value
              : (total - active > 0 ? total - active : 0);
          final newMembers = controller.newMembersCount.value;

          return Row(
            children: [
              _buildStatCard(
                "$total",
                "Total Members",
                Icons.group_rounded,
                const Color(0xFF6B4DFF),
                const Color(0xFFEDE9FE),
              ),
              SizedBox(width: 8.w),
              _buildStatCard(
                "$active",
                "Active",
                Icons.fiber_manual_record_rounded,
                const Color(0xFF10B981),
                const Color(0xFFE8FDF2),
              ),
              SizedBox(width: 8.w),
              _buildStatCard(
                "$inactive",
                "Inactive",
                Icons.access_time_rounded,
                const Color(0xFFF59E0B),
                const Color(0xFFFEF3C7),
              ),
              SizedBox(width: 8.w),
              _buildStatCard(
                "$newMembers",
                "New This Month",
                Icons.person_add_rounded,
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
              ),
            ],
          );
        }),
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
            InkWell(
              onTap: () {
                setState(() {
                  _isAscending = !_isAscending;
                });
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Row(
                  children: [
                    Text(
                      _isAscending ? "Sort: Name (A-Z)" : "Sort: Name (Z-A)",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B4DFF),
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      _isAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 15.sp,
                      color: const Color(0xFF6B4DFF),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Expanded(
          child: _buildMemberList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String count, String label, IconData icon, Color iconColor, Color bgColor) {
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

  Widget _buildMemberList() {
    return Obx(() {
      final List<OnlineMemberData> list =
          List<OnlineMemberData>.from(controller.filteredAllMembers);

      if (list.isEmpty) {
        final query = controller.searchQuery.value.trim();
        return Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_search_rounded,
                    color: const Color(0xFF6B4DFF),
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  query.isNotEmpty
                      ? "No members match '$query'"
                      : "No members available",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  query.isNotEmpty
                      ? "Try searching with a different name or number"
                      : "Members in your groups will appear here",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
                if (query.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  TextButton.icon(
                    onPressed: controller.clearAllSearch,
                    icon: Icon(Icons.clear_all_rounded, size: 18.sp),
                    label: const Text("Clear Search"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B4DFF),
                      textStyle: TextStyle(
                        fontFamily: FontFamily.interBold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      list.sort((a, b) {
        final nameA = (a.name ?? '').toLowerCase();
        final nameB = (b.name ?? '').toLowerCase();
        return _isAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
      });

      final hasMore = controller.hasMoreAllMembers.value;
      final itemCount = list.length + (hasMore ? 1 : 0);

      return ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == list.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B4DFF)),
                ),
              ),
            );
          }

          final member = list[index];
          final bool isActive = member.isOnline == 1 || member.online;
          final String name = member.name?.trim().isNotEmpty == true
              ? member.name!.trim()
              : 'Member';
          final String team = member.department?.trim().isNotEmpty == true
              ? member.department!.trim()
              : (member.mobileNo?.trim().isNotEmpty == true
                  ? member.mobileNo!.trim()
                  : 'FG Manpower');

          final hasImage = member.profileImage != null &&
              member.profileImage!.trim().isNotEmpty &&
              member.profileImage!.toLowerCase() != 'null';

          final String? imageUrl = hasImage
              ? (member.profileImage!.startsWith('http')
                  ? member.profileImage!
                  : "${ConstRes.aImageBaseUrl}${member.profileImage}")
              : null;

          final String joinedDate = _formatJoinedOrLastSeen(member.lastSeen);

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
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: const Color(0xFFEDE9FE),
                      backgroundImage:
                          imageUrl != null ? NetworkImage(imageUrl) : null,
                      onBackgroundImageError:
                          imageUrl != null ? (_, __) {} : null,
                      child: imageUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'M',
                              style: TextStyle(
                                color: const Color(0xFF6B4DFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                fontFamily: FontFamily.interBold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
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
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        team,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF94A3B8),
                              fontFamily: FontFamily.interMedium,
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
                      isActive ? "Status" : "Last seen",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade400,
                        fontFamily: FontFamily.interRegular,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      joinedDate,
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
    });
  }

  Widget _buildSkeletonContent() {
    return Column(
      children: [
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 70.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (_, __) => Container(
              margin: EdgeInsets.only(bottom: 10.h),
              height: 70.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatJoinedOrLastSeen(String? raw) {
    if (raw == null ||
        raw.trim().isEmpty ||
        raw.trim().toLowerCase() == 'null') {
      return '--';
    }
    final trimmed = raw.trim();
    if (trimmed.toLowerCase() == 'online') {
      return 'Online';
    }
    if (trimmed.toLowerCase().contains('ago')) {
      return trimmed;
    }
    try {
      final dt = DateTime.tryParse(trimmed);
      if (dt != null) {
        final local = dt.toLocal();
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${local.day} ${months[local.month - 1]} ${local.year}';
      }
    } catch (_) {}
    return trimmed;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}