import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/LiveStatus_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OnlineMember extends StatefulWidget {
  const OnlineMember({super.key});

  @override
  State<OnlineMember> createState() => _OnlineMemberState();
}

class _OnlineMemberState extends State<OnlineMember> {
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
    if (!_scrollController.hasClients) {
      return;
    }

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
                  onTap: () {
                    Get.back();
                  },
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
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.group_rounded,
                        color: const Color(0xFF6B4DFF),
                        size: 22.sp,
                      ),
                      Positioned(
                        right: 2.w,
                        bottom: 2.w,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                        () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontFamily: FontFamily.interBold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${controller.onlineMembersCount} Members Online',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontFamily: FontFamily.interRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Obx(() {
          if (controller.memberLoading.value) {
            return SkeletonMember();
          }
          if (controller.responseError.value.isNotEmpty) {
            return LostinternetConnection(
              retry: controller.getGroupMember,
              messgae: controller.responseError.value,
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: OnlineMemberUi(),
          );
        }));
  }

  Widget OnlineMemberUi() {
    return Skeletonizer(
      enabled: controller.memberLoading.value,
      child: Column(
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
                suffixIcon: Obx(
                      () {
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
                  },
                ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Online Now",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      fontFamily: FontFamily.interBold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "12",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B4DFF),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B4DFF),
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
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Obx(
                  () => _buildMemberList(),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
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
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.group_rounded,
                        color: const Color(0xFF6B4DFF),
                        size: 22.sp,
                      ),
                      Positioned(
                        right: 2.w,
                        bottom: 2.w,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
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
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "People Online",
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "These members are active in the app right now and available to connect.",
                        style: TextStyle(
                          fontSize: 10.5.sp,
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
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    if (controller.filteredMembers.isEmpty) {
      return emptyView();
    }

    final List<UserMemberData> members = List<UserMemberData>.from(
      controller.filteredMembers,
    );

    final bool showLoadingMore = controller.memberLoadingMore.value;

    return RefreshIndicator(
      color: const Color(0xFF6756E8),
      onRefresh: controller.refreshMembers,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: members.length + (showLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= members.length) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: 15.h,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6756E8),
                ),
              ),
            );
          }

          return memberCard(members[index]);
        },
      ),
    );
  }

  Widget emptyView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 55.sp,
              color: const Color(0xFFAAAED0),
            ),
            SizedBox(height: 12.h),
            reausabletext(
              controller.searchQuery.value.isEmpty
                  ? 'No online members found'
                  : 'No members found',
              fontsize: 15.sp,
              fontfamily: FontFamily.interSemiBold,
              color: const Color(0xFF68729C),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }
}