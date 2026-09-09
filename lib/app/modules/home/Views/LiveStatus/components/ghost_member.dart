import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/LiveStatus_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GhostMember extends StatefulWidget {
  const GhostMember({super.key});

  @override
  State<GhostMember> createState() => _GhostMemberState();
}

class _GhostMemberState extends State<GhostMember> {
  late final LivesStatusController controller;
  final ScrollController _scrollController = ScrollController();
  final RxBool isPrivateModeOn = true.obs;

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
                  Icons.admin_panel_settings_rounded,
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
                      'Private Mode',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '3 Active Sessions',
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
          child: _buildGhostMemberContent(),
        );
      }),
    );
  }

  Widget _buildGhostMemberContent() {
    return Skeletonizer(
      enabled: controller.memberLoading.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invisible Banner Toggle Card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: const Color(0xFF6B4DFF),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You're Invisible",
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "When Private Mode is ON, others can't see your online status or last seen.",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                          fontFamily: FontFamily.interRegular,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(
                      () => Switch.adaptive(
                    value: isPrivateModeOn.value,
                    activeColor: const Color(0xFF6B4DFF),
                    onChanged: (val) {
                      isPrivateModeOn.value = val;
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          // Active Sessions Header
          Row(
            children: [
              Text(
                "Active Sessions",
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
                  "3",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B4DFF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Member List
          Expanded(
            child: Obx(() => _buildMemberList()),
          ),
          SizedBox(height: 10.h),

          // Bottom Security Footer Card
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
                  width: 38.w,
                  height: 38.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: const Color(0xFF6B4DFF),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your privacy is our priority",
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Private Mode only hides your activity. You can still send messages and use the app normally.",
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: Colors.grey.shade600,
                          fontFamily: FontFamily.interRegular,
                          height: 1.3,
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
              padding: EdgeInsets.symmetric(vertical: 15.h),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6756E8),
                ),
              ),
            );
          }

          return _ghostMemberCard(members[index]);
        },
      ),
    );
  }

  Widget _ghostMemberCard(UserMemberData member) {
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
                backgroundImage: member.profileImage != null && member.profileImage!.isNotEmpty
                    ? NetworkImage(member.profileImage!)
                    : null,
                child: member.profileImage == null || member.profileImage!.isEmpty
                    ? Text(
                  (member.name != null && member.name!.isNotEmpty)
                      ? member.name![0].toUpperCase()
                      : "U",
                  style: TextStyle(
                    color: const Color(0xFF6B4DFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4DFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 9.sp,
                      color: Colors.white,
                    ),
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
                  member.name ?? "User Name",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Private Mode is ON",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Started at 10:24 AM",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.grey.shade500,
                        fontFamily: FontFamily.interRegular,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
              Icons.admin_panel_settings_outlined,
              size: 55.sp,
              color: const Color(0xFFAAAED0),
            ),
            SizedBox(height: 12.h),
            reausabletext(
              'No active private sessions',
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