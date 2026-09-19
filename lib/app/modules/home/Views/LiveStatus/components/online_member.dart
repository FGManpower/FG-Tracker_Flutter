import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../global_widget/common_widget.dart';

class OnlineMember extends StatefulWidget {
  const OnlineMember({super.key});

  @override
  State<OnlineMember> createState() => _OnlineMemberState();
}

class _OnlineMemberState extends State<OnlineMember> {
  late final LivesStatusController controller;

  final ScrollController _scrollController = ScrollController();

  bool _showAllOnlineNow = false;

  final RxBool _isSearchCollapsed = false.obs;
  final RxBool _showSearchInAppBar = false.obs;

  @override
  void initState() {
    super.initState();

    controller = LivesStatusController.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getOnlineMembers();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final double currentPosition = _scrollController.position.pixels;
    final double maxPosition = _scrollController.position.maxScrollExtent;

    if (currentPosition > 40 && !_isSearchCollapsed.value) {
      _isSearchCollapsed.value = true;
    } else if (currentPosition <= 40 && _isSearchCollapsed.value) {
      _isSearchCollapsed.value = false;
      _showSearchInAppBar.value = false;
    }
    if (currentPosition >= maxPosition - 200) {
      controller.loadMoreOnlineMembers();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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
                child: Icon(
                  Icons.person_pin_circle_rounded,
                  color: Colors.white,
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
                      "Online",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.interBold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(() {
                      final total = controller.onlineNowList.length +
                          controller.recentlyOnlineList.length;

                      return Text(
                        "$total Members Online",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interRegular,
                          color: Colors.grey.shade600,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() {
                if (!_isSearchCollapsed.value) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () {
                    _showSearchInAppBar.value = true;

                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 4.w),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: const Color(0xFF6B4DFF),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.onlineLoading.value &&
            controller.onlineNowList.isEmpty &&
            controller.recentlyOnlineList.isEmpty) {
          return const _OnlineMemberSkeleton();
        }

        if (controller.onlineResponseError.value.isNotEmpty &&
            controller.onlineNowList.isEmpty &&
            controller.recentlyOnlineList.isEmpty) {
          return LostinternetConnection(
            retry: () async {
              await controller.getOnlineMembers(
                refresh: true,
              );
            },
            messgae: controller.onlineResponseError.value,
          );
        }

        return Column(
          children: [
            Obx(
              () => AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: (_isSearchCollapsed.value && !_showSearchInAppBar.value)
                    ? const SizedBox(
                        width: double.infinity,
                      )
                    : _buildSearchBar(),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF6366F1),
                onRefresh: () async {
                  await controller.getOnlineMembers(
                    refresh: true,
                  );
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    8.h,
                    16.w,
                    20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOnlineNowSection(),
                      SizedBox(height: 20.h),
                      _buildRecentlyOnlineSection(),
                      SizedBox(height: 20.h),
                      Obx(() {
                        if (controller.onlineLoadingMore.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  8.h,
                  16.w,
                  10.h,
                ),
                child: _buildBottomInfoCard(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (val) => controller.searchOnlineMembers(val),
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: FontFamily.interMedium,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: "Search members...",
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: FontFamily.interRegular,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 22.sp,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchOnlineMembers('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineNowSection() {
    return Obx(() {
      final list = controller.filteredOnlineNowList;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Online Now",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "${list.length}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
              const Spacer(),
              if (list.length > 4)
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAllOnlineNow = !_showAllOnlineNow;
                    });
                  },
                  borderRadius: BorderRadius.circular(6.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      children: [
                        Text(
                          _showAllOnlineNow ? "Show Less" : "View All",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.interSemiBold,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16.sp,
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (list.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 16.h,
              ),
              alignment: Alignment.center,
              child: Text(
                "No members currently online",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interRegular,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  _showAllOnlineNow || list.length <= 5 ? list.length : 5,
              separatorBuilder: (_, __) => SizedBox(
                height: 8.h,
              ),
              itemBuilder: (_, index) {
                final member = list[index];

                return _buildMemberCard(
                  member,
                  isOnlineNow: true,
                );
              },
            ),
        ],
      );
    });
  }

  Widget _buildRecentlyOnlineSection() {
    return Obx(() {
      final list = controller.filteredRecentlyOnlineList;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Recently Online",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "${list.length}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (list.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 16.h,
              ),
              alignment: Alignment.center,
              child: Text(
                "No recently active members",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interRegular,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => SizedBox(
                height: 8.h,
              ),
              itemBuilder: (_, index) {
                final member = list[index];

                return _buildMemberCard(
                  member,
                  isOnlineNow: false,
                );
              },
            ),
        ],
      );
    });
  }

  Widget _buildMemberCard(
    GroupMemberData member, {
    required bool isOnlineNow,
  }) {
    final Color dotColor =
        isOnlineNow ? const Color(0xFF10B981) : const Color(0xFFA5B4FC);

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
          status: isOnlineNow,
          lastSeen: member.lastSeen,
          isGroupChat: false,
          isLocationSharing: member.isLocationSharing ?? true,
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
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.15),
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
                              size: 24.sp,
                              color: const Color(0xFF6366F1),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 24.sp,
                            color: const Color(0xFF6366F1),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.r,
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
                    member.displayDepartment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interRegular,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    isOnlineNow
                        ? "Online"
                        : "Last seen ${member.formattedLastSeen}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.interMedium,
                      color: isOnlineNow
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_rounded,
                  color: const Color(0xFF6366F1),
                  size: 22.sp,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 10.r,
                  height: 10.r,
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
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "People Online",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.interBold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "These members are active in the app right now and available to connect.",
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

class _OnlineMemberSkeleton extends StatelessWidget {
  const _OnlineMemberSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            4.h,
            16.w,
            8.h,
          ),
          child: Skeletonizer(
            enabled: true,
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Search members...",
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Skeletonizer(
            enabled: true,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                20.h,
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 6.h,
                    bottom: 10.h,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Online Now",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: FontFamily.interBold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 28.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < 5; i++) ...[
                  const _OnlineMemberSkeletonTile(),
                  if (i < 4) SizedBox(height: 8.h),
                ],
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(
                      "Recently Online",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 28.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                for (int i = 0; i < 4; i++) ...[
                  const _OnlineMemberSkeletonTile(),
                  if (i < 3) SizedBox(height: 8.h),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              8.h,
              16.w,
              10.h,
            ),
            child: Skeletonizer(
              enabled: true,
              child: _buildSkeletonBottomCard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonBottomCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.grey.shade300,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "People Online",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "These members are active in the app right now and available to connect.",
                  maxLines: 2,
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

class _OnlineMemberSkeletonTile extends StatelessWidget {
  const _OnlineMemberSkeletonTile();

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
            radius: 24.r,
            backgroundColor: Colors.grey.shade300,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Loading member name",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Loading department",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Online",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interMedium,
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
