import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/online_member_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/LiveStatus_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OnlineMember extends StatefulWidget {
  const OnlineMember({super.key});

  @override
  State<OnlineMember> createState() => _OnlineMemberState();
}

class _OnlineMemberState extends State<OnlineMember> {
  late final LivesStatusController controller;
  final ScrollController _scrollController = ScrollController();
  bool _showAllOnline = false;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<LivesStatusController>()
        ? Get.find<LivesStatusController>()
        : Get.put(LivesStatusController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.memberFilter.value != 'online' ||
          controller.memberData.isEmpty) {
        controller.changeFilter('online');
      }
    });

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
                onTap: () {
                  Get.back();
                },
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    Positioned(
                      right: 3.w,
                      top: 3.w,
                      child: Container(
                        width: 9.w,
                        height: 9.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.8,
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
                  () {
                    final int count = controller.memberData.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                            fontFamily: FontFamily.interBold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '$count Members Online',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF6B7280),
                            fontFamily: FontFamily.interRegular,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.memberLoading.value && controller.memberData.isEmpty) {
          return SkeletonMember();
        }
        if (controller.responseError.value.isNotEmpty &&
            controller.memberData.isEmpty) {
          return LostinternetConnection(
            retry: controller.getGroupMember,
            messgae: controller.responseError.value,
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF6366F1),
          onRefresh: controller.refreshMembers,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: OnlineMemberUi(),
          ),
        );
      }),
    );
  }

  Widget OnlineMemberUi() {
    final List<OnlineMemberData> members = controller.filtermember;

    if (members.isEmpty) {
      return Column(
        children: [
          _buildSearchField(),
          SizedBox(height: 40.h),
          emptyView(),
        ],
      );
    }

    final List<OnlineMemberData> onlineList = [];
    final List<OnlineMemberData> recentList = [];

    for (final m in members) {
      final String rawLastSeen = m.lastSeen?.trim().toLowerCase() ?? '';
      final bool isOnline = m.online ||
          m.isOnline == 1 ||
          rawLastSeen == 'online' ||
          rawLastSeen == 'active' ||
          rawLastSeen == 'now';

      if (isOnline) {
        onlineList.add(m);
      } else {
        recentList.add(m);
      }
    }

    if (onlineList.isEmpty &&
        recentList.isNotEmpty &&
        controller.memberFilter.value == 'online') {
      final bool hasExplicitOffline = recentList.any((m) {
        final ls = m.lastSeen?.toLowerCase() ?? '';
        return m.isOnline == 0 ||
            ls.contains('ago') ||
            ls.contains('min') ||
            ls.contains('hr');
      });
      if (!hasExplicitOffline) {
        onlineList.addAll(recentList);
        recentList.clear();
      }
    }

    final List<OnlineMemberData> displayedOnline =
        (_showAllOnline || controller.searchQuery.value.trim().isNotEmpty)
            ? onlineList
            : onlineList.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(),
        SizedBox(height: 16.h),
        if (onlineList.isNotEmpty) ...[
          _buildSectionHeader(
            title: "Online Now",
            count: onlineList.length,
            trailing: onlineList.length > 5 &&
                    controller.searchQuery.value.trim().isEmpty
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _showAllOnline = !_showAllOnline;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllOnline ? "Show Less" : "View All",
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          _showAllOnline
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.chevron_right_rounded,
                          size: 18.sp,
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          SizedBox(height: 10.h),
          _buildGroupCard(
            members: displayedOnline,
            isOnlineSection: true,
          ),
          SizedBox(height: 20.h),
        ],
        if (recentList.isNotEmpty) ...[
          _buildSectionHeader(
            title: "Recently Online",
            count: recentList.length,
          ),
          SizedBox(height: 10.h),
          _buildGroupCard(
            members: recentList,
            isOnlineSection: false,
          ),
          SizedBox(height: 20.h),
        ],
        _buildBottomInfoBanner(),
        if (controller.memberLoadingMore.value) ...[
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

  Widget _buildSearchField() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFECEEF5)),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search members...',
          hintStyle: TextStyle(
            fontSize: 13.5.sp,
            color: const Color(0xFF9CA3AF),
            fontFamily: FontFamily.interRegular,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: const Color(0xFF9CA3AF),
          ),
          suffixIcon: Obx(
            () {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: controller.clearSearch,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
              );
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 13.h,
            horizontal: 16.w,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
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
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildGroupCard({
    required List<OnlineMemberData> members,
    required bool isOnlineSection,
  }) {
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
          return _buildMemberTile(
            member: member,
            isOnline: isOnlineSection,
          );
        },
      ),
    );
  }

  Widget _buildMemberTile({
    required OnlineMemberData member,
    required bool isOnline,
  }) {
    final String name = member.name?.trim().isNotEmpty == true
        ? member.name!.trim()
        : 'Member';

    final String department = member.department?.trim().isNotEmpty == true
        ? member.department!.trim()
        : (member.mobileNo?.trim().isNotEmpty == true
            ? member.mobileNo!.trim()
            : '');

    String statusText;
    if (isOnline) {
      statusText = 'Online';
    } else {
      final rawLastSeen = member.lastSeen?.trim();
      if (rawLastSeen != null &&
          rawLastSeen.isNotEmpty &&
          rawLastSeen.toLowerCase() != 'null') {
        if (rawLastSeen.toLowerCase().contains('ago') ||
            rawLastSeen.toLowerCase().contains('online')) {
          statusText = rawLastSeen.toLowerCase().startsWith('last seen')
              ? rawLastSeen
              : 'Last seen $rawLastSeen';
        } else {
          statusText = 'Last seen $rawLastSeen';
        }
      } else {
        statusText = 'Offline';
      }
    }

    final hasProfileImage = member.profileImage != null &&
        member.profileImage!.trim().isNotEmpty &&
        member.profileImage!.toLowerCase() != 'null';

    final String? imageUrl = hasProfileImage
        ? (member.profileImage!.startsWith('http')
            ? member.profileImage!
            : "${ConstRes.aImageBaseUrl}${member.profileImage}")
        : null;

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
                  width: 11.w,
                  height: 11.w,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFFA5B4FC),
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
                if (department.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    department,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6366F1),
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ],
                SizedBox(height: 2.h),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF9CA3AF),
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

  Widget _buildBottomInfoBanner() {
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
                    width: 9.w,
                    height: 9.w,
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
                    color: const Color(0xFF1E1B4B),
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "These members are active in the app right now and available to connect.",
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

  Widget emptyView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 55.sp,
              color: const Color(0xFFAAAED0),
            ),
            SizedBox(height: 12.h),
            reausabletext(
              controller.searchQuery.value.isEmpty
                  ? 'No online members found'
                  : 'No members found matching "${controller.searchQuery.value}"',
              fontsize: 14.5.sp,
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