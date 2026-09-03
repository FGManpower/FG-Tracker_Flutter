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
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65.h),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: const Color(0xFFF9F9FF),
            titleSpacing: 18.w,
            title: Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(13.r),
                  child: Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 27.sp,
                      color: const Color(0xFF10184D),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6756E8),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                      Positioned(
                        right: 1.w,
                        bottom: 0,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF08C887),
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
                SizedBox(width: 14.w),
                Expanded(
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        reausabletext(
                          'Online',
                          fontsize: 16.sp,
                          fontfamily: FontFamily.interBold,
                          color: const Color(0xFF0E174F),
                        ),
                        SizedBox(height: 2.h),
                        reausabletext(
                          '${controller.onlineMembersCount} Members Online',
                          fontsize: 12.sp,
                          fontfamily: FontFamily.interRegular,
                          color: const Color(0xFF626DA7),
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
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: OnlineMemberUi(),
          );
        }));
  }

  Widget OnlineMemberUi() {
    return Skeletonizer(
      enabled: controller.memberLoading.value,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF737BAA),
                  fontFamily: FontFamily.interRegular,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 28.sp,
                  color: const Color(0xFF6D78B4),
                ),
                suffixIcon: Obx(
                  () {
                    if (controller.searchQuery.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return IconButton(
                      onPressed: controller.clearSearch,
                      icon: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: const Color(0xFF6D78B4),
                      ),
                    );
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14.h,
                  horizontal: 0.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: const Color(0xFFE3E5F7),
                    width: 1.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: const Color(0xFFE3E5F7),
                    width: 1.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: const Color(0xFF6756E8),
                    width: 1.2.w,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Obx(
              () => _buildMemberList(),
            ),
          ),
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
