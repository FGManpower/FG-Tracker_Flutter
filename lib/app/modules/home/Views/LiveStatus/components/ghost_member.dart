import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GhostMember extends StatefulWidget {
  const GhostMember({super.key});

  @override
  State<GhostMember> createState() => _GhostMemberState();
}

class _GhostMemberState extends State<GhostMember> {
  late final LivesStatusController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    controller = LivesStatusController.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPrivateMembers();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
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
                      "Private Mode",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.interBold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(
                      () => Text(
                        "${controller.privateMemberList.length} Active Sessions",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interRegular,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: _buildInvisibleTopCard(),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildSectionHeader(),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Obx(() {
              if (controller.privateResponseError.value.isNotEmpty &&
                  controller.privateMemberList.isEmpty) {
                return LostinternetConnection(
                  retry: () async {
                    await controller.getPrivateMembers(refresh: true);
                  },
                  messgae: controller.privateResponseError.value,
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF6B4DFF),
                onRefresh: () async {
                  await controller.getPrivateMembers(refresh: true);
                },
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    0,
                    16.w,
                    12.h,
                  ),
                  children: [
                    _buildPrivateMemberList(),
                    Obx(() {
                      if (controller.privateLoadingMore.value) {
                        return const _BottomSkeletonLoader();
                      }

                      return SizedBox(height: 12.h);
                    }),
                  ],
                ),
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
              child: _buildBottomPriorityCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvisibleTopCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF6B4DFF).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: Color(0xFF9D86FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: Colors.white,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "When Private Mode is ON, others can't see your online status or last seen.",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Obx(() {
            return CupertinoSwitch(
              value: controller.isMyPrivateModeOn.value,
              activeTrackColor: const Color(0xFF6B4DFF),
              onChanged: (val) {
                controller.togglePrivateMode(val);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          "Active Sessions",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.interBold,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 8.w),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              "${controller.privateMemberList.length}",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.interBold,
                color: const Color(0xFF6B4DFF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateMemberList() {
    if (controller.privateLoading.value &&
        controller.privateMemberList.isEmpty) {
      return const _PrivateMemberSkeletonList();
    }

    final list = controller.filteredPrivateMemberList;

    if (list.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 48.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 12.h),
            Text(
              "No active private sessions",
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interMedium,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < list.length; index++) ...[
          _buildPrivateMemberCard(list[index]),
          if (index < list.length - 1) SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget _buildPrivateMemberCard(GroupMemberData member) {
    return InkWell(
      onTap: () {
        DialogBox().showRouteDetailsBottomSheet(
          destination: LatLng(
            member.location?.latitude ?? 0.0,
            member.location?.longitude ?? 0.0,
          ),
          distance: 0,
          userId: member.userId,
          id: member.userId,
          name: member.displayName,
          imageUrl: member.profileImage,
          status: false,
          lastSeen: member.lastSeen,
          isGroupChat: false,
          isLocationSharing: false,
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6B4DFF).withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: member.resolvedImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: member.resolvedImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.person,
                              size: 26.sp,
                              color: const Color(0xFF6B4DFF),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 26.sp,
                            color: const Color(0xFF6B4DFF),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4DFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5.r,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 9.sp,
                      color: Colors.white,
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
                    member.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.interBold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Private Mode is ON",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interRegular,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        "Started at ${member.formattedStartedAt}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interRegular,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPriorityCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFF6B4DFF).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
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
                  "Your privacy is our priority",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.interBold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Private Mode only hides your activity. You can still send messages and use the app normally.",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: Colors.grey.shade700,
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
}

class _PrivateMemberSkeletonList extends StatelessWidget {
  const _PrivateMemberSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          for (int i = 0; i < 5; i++) ...[
            const _PrivateMemberSkeletonTile(),
            if (i < 4) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _PrivateMemberSkeletonTile extends StatelessWidget {
  const _PrivateMemberSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: Colors.grey.shade200,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Loading member name",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Private Mode is ON",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Started at 12 Sep 2026",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSkeletonLoader extends StatelessWidget {
  const _BottomSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Column(
          children: [
            const _PrivateMemberSkeletonTile(),
            SizedBox(height: 10.h),
            const _PrivateMemberSkeletonTile(),
          ],
        ),
      ),
    );
  }
}
