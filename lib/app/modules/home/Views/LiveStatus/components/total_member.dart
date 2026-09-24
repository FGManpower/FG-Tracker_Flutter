import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TotalMember extends StatefulWidget {
  const TotalMember({super.key});

  @override
  State<TotalMember> createState() => _TotalMemberState();
}

class _TotalMemberState extends State<TotalMember> {
  late final LivesStatusController controller;

  final ScrollController _scrollController = ScrollController();

  bool _isSearchCollapsed = false;
  bool _showSearchInAppBar = false;

  @override
  void initState() {
    super.initState();

    controller = LivesStatusController.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllMembers();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final double currentPosition = _scrollController.position.pixels;
    final double maxPosition = _scrollController.position.maxScrollExtent;

    if (currentPosition > 40 && !_isSearchCollapsed) {
      setState(() {
        _isSearchCollapsed = true;
      });
    } else if (currentPosition <= 40 && _isSearchCollapsed) {
      setState(() {
        _isSearchCollapsed = false;
        _showSearchInAppBar = false;
      });
    }

    if (currentPosition >= maxPosition - 250) {
      controller.loadMoreAllMembers();
    }
  }

  void _showSearchBarAgain() {
    setState(() {
      _showSearchInAppBar = true;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                      "Members",
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.interBold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(
                      () => Text(
                        "${controller.totalMembersCount.value} Total Members",
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isSearchCollapsed && !_showSearchInAppBar
                    ? InkWell(
                        key: const ValueKey('search'),
                        onTap: _showSearchBarAgain,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            size: 22.sp,
                            color: const Color(0xFF6B4DFF),
                          ),
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey('empty-search'),
                        width: 0,
                      ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: (!_isSearchCollapsed || _showSearchInAppBar)
                ? Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    child: _buildSearchBar(),
                  )
                : const SizedBox(
                    width: double.infinity,
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: _buildMetadataCards(),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildSectionHeader(),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Obx(() {
              if (controller.allResponseError.value.isNotEmpty &&
                  controller.allMemberList.isEmpty) {
                return LostinternetConnection(
                  retry: () async {
                    await controller.getAllMembers(refresh: true);
                  },
                  messgae: controller.allResponseError.value,
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF6B4DFF),
                onRefresh: () async {
                  await controller.getAllMembers(refresh: true);
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
                    24.h,
                  ),
                  children: [
                    _buildMemberList(),
                    Obx(() {
                      if (controller.allMemberLoadingMore.value) {
                        return const _BottomSkeletonLoader();
                      }

                      return SizedBox(height: 24.h);
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
        onChanged: (val) => controller.searchAllMembers(val),
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
                      controller.searchAllMembers('');
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

  Widget _buildMetadataCards() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _buildMetaCard(
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF6B4DFF),
              iconBgColor: const Color(0xFFEDE9FE),
              count: controller.totalMembersCount.value,
              countColor: const Color(0xFF6B4DFF),
              title: "Total Members",
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildMetaCard(
              icon: Icons.circle,
              iconColor: const Color(0xFF10B981),
              iconBgColor: const Color(0xFFD1FAE5),
              count: controller.activeMembersCount.value,
              countColor: const Color(0xFF10B981),
              title: "Active",
              isDot: true,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildMetaCard(
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFFF59E0B),
              iconBgColor: const Color(0xFFFEF3C7),
              count: controller.inactiveMembersCount.value,
              countColor: const Color(0xFFF59E0B),
              title: "Inactive",
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildMetaCard(
              icon: Icons.person_add_rounded,
              iconColor: const Color(0xFF3B82F6),
              iconBgColor: const Color(0xFFDBEAFE),
              count: controller.newMembersCount.value,
              countColor: const Color(0xFF3B82F6),
              title: "New This Month",
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetaCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required int count,
    required Color countColor,
    required String title,
    bool isDot = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12.h,
        horizontal: 6.w,
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isDot ? 12.sp : 16.sp,
              color: iconColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              fontFamily: FontFamily.interBold,
              color: countColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              fontFamily: FontFamily.interMedium,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "All Members",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.interBold,
            color: Colors.black87,
          ),
        ),
        Obx(() {
          final isAsc = controller.isAllMembersAscending.value;

          return InkWell(
            onTap: () => controller.sortAllMembers(),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 4.h,
              ),
              child: Row(
                children: [
                  Text(
                    "Sort: Name (${isAsc ? 'A-Z' : 'Z-A'})",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFF6B4DFF),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16.sp,
                    color: const Color(0xFF6B4DFF),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMemberList() {
    if (controller.allMemberLoading.value && controller.allMemberList.isEmpty) {
      return const _TotalMemberSkeletonList();
    }

    final list = controller.filteredAllMemberList;

    if (list.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 48.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 12.h),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? "No members match '${controller.searchQuery.value}'"
                  : "No members found",
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
          _buildMemberCard(list[index]),
          if (index < list.length - 1) SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget _buildMemberCard(GroupMemberData member) {
    final bool isOnline = member.effectiveIsOnline;

    final String statusText = isOnline ? "Active" : "Inactive";

    final Color statusColor =
        isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

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
          status: isOnline,
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
                  width: 50.r,
                  height: 50.r,
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
                    width: 13.r,
                    height: 13.r,
                    decoration: BoxDecoration(
                      color: statusColor,
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
                  Row(
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.interSemiBold,
                          color: statusColor,
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
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  member.formattedJoinedAt,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.interSemiBold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalMemberSkeletonList extends StatelessWidget {
  const _TotalMemberSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          for (int i = 0; i < 6; i++) ...[
            const _TotalMemberSkeletonTile(),
            if (i < 5) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _TotalMemberSkeletonTile extends StatelessWidget {
  const _TotalMemberSkeletonTile();

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
                  "Member Department",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Active",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Joined",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: FontFamily.interRegular,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "12 Sep 2026",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interSemiBold,
                ),
              ),
            ],
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
            const _TotalMemberSkeletonTile(),
            SizedBox(height: 10.h),
            const _TotalMemberSkeletonTile(),
          ],
        ),
      ),
    );
  }
}
