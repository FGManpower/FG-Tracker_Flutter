import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/ghost_member_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/LiveStatus_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GhostMember extends StatefulWidget {
  const GhostMember({super.key});

  @override
  State<GhostMember> createState() => _GhostMemberState();
}

class _GhostMemberState extends State<GhostMember> {
  late final LivesStatusController controller;
  late final TrackingController trackingController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<LivesStatusController>()
        ? Get.find<LivesStatusController>()
        : Get.put(LivesStatusController());

    trackingController = Get.isRegistered<TrackingController>()
        ? Get.find<TrackingController>()
        : Get.put(TrackingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.privateMemberData.isEmpty) {
        controller.getPrivateMembers();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double currentPosition = _scrollController.position.pixels;
    final double maxPosition = _scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 250) {
      controller.loadMorePrivateMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(68.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: const Color(0xFFF8F9FE),
          titleSpacing: 16.w,
          title: Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
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
              SizedBox(width: 12.w),
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF818CF8),
                      Color(0xFF6366F1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(() {
                  final int count = controller.privateMemberData.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Private Mode',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '$count Active Sessions',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                          fontFamily: FontFamily.interRegular,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.privateMemberLoading.value &&
            controller.privateMemberData.isEmpty) {
          return SkeletonMember();
        }
        if (controller.privateResponseError.value.isNotEmpty &&
            controller.privateMemberData.isEmpty) {
          return LostinternetConnection(
            retry: controller.getPrivateMembers,
            messgae: controller.privateResponseError.value,
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF6366F1),
          onRefresh: controller.refreshPrivateMembers,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: _buildGhostMemberContent(),
          ),
        );
      }),
    );
  }

  Widget _buildGhostMemberContent() {
    final List<GhostMemberData> members = controller.privateMemberData;
    final int sessionCount = members.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInvisibleToggleCard(),
        SizedBox(height: 18.h),
        _buildSectionHeader(sessionCount),
        SizedBox(height: 10.h),
        if (members.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFF1F3F9)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 36.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(height: 8.h),
                Text(
                  "No active private sessions",
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
              ],
            ),
          )
        else
          _buildSessionsGroupCard(members),
        SizedBox(height: 20.h),
        _buildBottomPrivacyBanner(),
        if (controller.privateMemberLoadingMore.value) ...[
          SizedBox(height: 16.h),
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6366F1),
            ),
          ),
        ],
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildInvisibleToggleCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFECEEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: const Color(0xFF6B4DFF),
              size: 22.sp,
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
                    color: const Color(0xFF111827),
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "When Private Mode is ON, others can't see your online status or last seen.",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
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
              value: !trackingController.isLocationSharing.value,
              activeColor: const Color(0xFF6366F1),
              onChanged: (val) async {
                await trackingController.toggleLocationSharing(!val);
                controller.refreshPrivateMembers();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        Text(
          "Active Sessions",
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            fontFamily: FontFamily.interBold,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B4DFF),
              fontFamily: FontFamily.interBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsGroupCard(List<GhostMemberData> members) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF1F3F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.8,
          color: const Color(0xFFF3F4F6),
          indent: 68.w,
        ),
        itemBuilder: (context, index) {
          final member = members[index];
          return _buildSessionTile(member);
        },
      ),
    );
  }

  Widget _buildSessionTile(GhostMemberData member) {
    final String name =
        member.name?.trim().isNotEmpty == true ? member.name!.trim() : 'Member';

    final hasProfileImage = member.profileImage != null &&
        member.profileImage!.trim().isNotEmpty &&
        member.profileImage!.toLowerCase() != 'null';

    final String? imageUrl = hasProfileImage
        ? (member.profileImage!.startsWith('http')
            ? member.profileImage!
            : "${ConstRes.aImageBaseUrl}${member.profileImage}")
        : null;

    final String timeText = _formatStartedTime(member.startedAt);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: const Color(0xFFEEF2F6),
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl) : null,
                onBackgroundImageError: imageUrl != null ? (_, __) {} : null,
                child: !hasProfileImage
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6366F1),
                          fontFamily: FontFamily.interBold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -1.w,
                bottom: -1.h,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 8.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Private Mode is ON",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6366F1),
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF9CA3AF),
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

  String _formatStartedTime(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw == 'null') {
      return 'Started recently';
    }

    final trimmed = raw.trim();
    if (trimmed.toLowerCase().startsWith('started at')) {
      return trimmed;
    }

    final dt = DateTime.tryParse(trimmed);
    if (dt != null) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return 'Started at $hour:$minute $period';
    }

    return 'Started at $trimmed';
  }

  Widget _buildBottomPrivacyBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE8E5FA)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.verified_user_rounded,
                color: const Color(0xFF6B4DFF),
                size: 20.sp,
              ),
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
                    color: const Color(0xFF1E1B4B),
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Private Mode only hides your activity. You can still send messages and use the app normally.",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: FontFamily.interRegular,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
