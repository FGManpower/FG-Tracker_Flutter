import 'package:fgtracker/app/Core/values/responsive.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import '../../Group/controller/Group_Controller.dart';

class WalkieGroupSelectScreen extends StatefulWidget {
  const WalkieGroupSelectScreen({super.key});

  @override
  State<WalkieGroupSelectScreen> createState() =>
      _WalkieGroupSelectScreenState();
}

class _WalkieGroupSelectScreenState extends State<WalkieGroupSelectScreen> {
  int _selectedTab = 0;

  final GroupController _groupController = Get.put(GroupController());

  final List<Map<String, Color>> _colorPool = [
    {'bg': const Color(0xFFE8DEFF), 'icon': const Color(0xFF6B4DFF)},
    {'bg': const Color(0xFFD1FAE5), 'icon': const Color(0xFF10B981)},
    {'bg': const Color(0xFFE0E7FF), 'icon': const Color(0xFF6366F1)},
    {'bg': const Color(0xFFFFEDD5), 'icon': const Color(0xFFF59E0B)},
    {'bg': const Color(0xFFCFFAFE), 'icon': const Color(0xFF06B6D4)},
    {'bg': const Color(0xFFFCE7F3), 'icon': const Color(0xFFEC4899)},
    {'bg': const Color(0xFFEDE9FE), 'icon': const Color(0xFF8B5CF6)},
  ];

  static final List<Map<String, dynamic>> _recentGroups = [
    {
      'name': 'Logistics Group',
      'members': 8,
      'color': const Color(0xFFD1FAE5),
      'iconColor': const Color(0xFF10B981),
      'muted': true,
    },
    {
      'name': 'Security Group',
      'members': 10,
      'color': const Color(0xFFE0E7FF),
      'iconColor': const Color(0xFF6366F1),
      'muted': false,
    },
    {
      'name': 'Construction Group',
      'members': 12,
      'color': const Color(0xFFE8DEFF),
      'iconColor': const Color(0xFF6B4DFF),
      'muted': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupController.getGroupData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            MediaQueryHelper.gapH(8, context),
            _buildSearchBar(),
            MediaQueryHelper.gapH(12, context),
            Expanded(child: _buildGroupList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: MediaQueryHelper.paddingSymmetric(
          horizontal: 16, vertical: 8, context: context),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: MediaQueryHelper.paddingAll(8, context),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 16.sp, color: Colors.black87),
            ),
          ),
          MediaQueryHelper.gapW(12, context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  "Walkie Talkie",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                reausabletext(
                  "Select a group to connect",
                  fontsize: 11.sp,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          MediaQueryHelper.gapW(8, context),
          _circleIcon(Icons.add),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: MediaQueryHelper.paddingAll(8, context),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, size: 18.sp, color: const Color(0xFF6B4DFF)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding:
          MediaQueryHelper.paddingSymmetric(horizontal: 16, context: context),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.h,
              padding: MediaQueryHelper.paddingSymmetric(
                  horizontal: 14, context: context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.sp, color: Colors.grey),
                  MediaQueryHelper.gapW(8, context),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search groups",
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey,
                          fontFamily: FontFamily.interRegular,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MediaQueryHelper.gapW(10, context),
          Container(
            height: 44.h,
            width: 44.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child:
                Icon(Icons.tune, size: 18.sp, color: const Color(0xFF6B4DFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding:
          MediaQueryHelper.paddingSymmetric(horizontal: 16, context: context),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0
                        ? const Color(0xFF6B4DFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: _selectedTab == 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6B4DFF).withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups,
                        size: 16.sp,
                        color: _selectedTab == 0 ? Colors.white : Colors.grey,
                      ),
                      MediaQueryHelper.gapW(6, context),
                      reausabletext(
                        "All Groups",
                        fontsize: 13.sp,
                        color: _selectedTab == 0 ? Colors.white : Colors.grey,
                        fontfamily: FontFamily.interSemiBold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1
                        ? const Color(0xFF6B4DFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: _selectedTab == 1
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6B4DFF).withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: _selectedTab == 1 ? Colors.white : Colors.grey,
                      ),
                      MediaQueryHelper.gapW(6, context),
                      reausabletext(
                        "Recent",
                        fontsize: 13.sp,
                        color: _selectedTab == 1 ? Colors.white : Colors.grey,
                        fontfamily: FontFamily.interSemiBold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    return Obx(() {
      if (_selectedTab == 0) {
        if (_groupController.groupDataLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B4DFF)),
            ),
          );
        }

        final List<GroupsResData> allApiGroups = [];
        allApiGroups.addAll(_groupController.newlyCreatedGroups);
        allApiGroups.addAll(_groupController.createdGroups);

        if (allApiGroups.isEmpty) {
          return Center(
            child: reausabletext(
              "No groups found",
              fontsize: 14.sp,
              color: Colors.grey,
            ),
          );
        }

        return ListView.separated(
          padding: MediaQueryHelper.paddingSymmetric(
              horizontal: 16, vertical: 4, context: context),
          itemCount: allApiGroups.length,
          separatorBuilder: (_, __) => MediaQueryHelper.gapH(10, context),
          itemBuilder: (context, index) {
            return _apiGroupCard(allApiGroups[index], index);
          },
        );
      } else {
        final groups = _recentGroups;
        if (groups.isEmpty) {
          return Center(
            child: reausabletext(
              "No recent groups found",
              fontsize: 14.sp,
              color: Colors.grey,
            ),
          );
        }
        return ListView.separated(
          padding: MediaQueryHelper.paddingSymmetric(
              horizontal: 16, vertical: 4, context: context),
          itemCount: groups.length,
          separatorBuilder: (_, __) => MediaQueryHelper.gapH(10, context),
          itemBuilder: (context, index) {
            return _dummyGroupCard(groups[index]);
          },
        );
      }
    });
  }

  Widget _apiGroupCard(GroupsResData group, int index) {
    final colors = _colorPool[index % _colorPool.length];

    return InkWell(
      onTap: () {
        Get.to(
          () => const GroupWalkieScreen(),
          arguments: {
            'groupId': group.id?.toString() ?? "",
            'groupName': group.groupName ?? "Unknown Group",
            'groupDesc': group.groupDesc ?? "",
            'groupCode': group.groupCode ?? "",
          },
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: MediaQueryHelper.paddingSymmetric(
            horizontal: 12, vertical: 12, context: context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: colors['bg'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups,
                color: colors['icon'],
                size: 22.sp,
              ),
            ),
            MediaQueryHelper.gapW(12, context),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    group.groupName ?? "No Name Group",
                    fontsize: 14.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: Colors.black87,
                  ),
                  MediaQueryHelper.gapH(4, context),
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined,
                          size: 12.sp, color: Colors.grey),
                      MediaQueryHelper.gapW(4, context),
                      reausabletext(
                        "${group.memberCount ?? 0} Members",
                        fontsize: 11.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: MediaQueryHelper.paddingAll(8, context),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.cell_tower,
                size: 18.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dummyGroupCard(Map<String, dynamic> g) {
    final bool muted = g['muted'] as bool? ?? false;

    return Container(
      padding: MediaQueryHelper.paddingSymmetric(
          horizontal: 12, vertical: 12, context: context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: g['color'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups,
              color: g['iconColor'] as Color,
              size: 22.sp,
            ),
          ),
          MediaQueryHelper.gapW(12, context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  g['name'] as String,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interSemiBold,
                  color: Colors.black87,
                ),
                MediaQueryHelper.gapH(4, context),
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined,
                        size: 12.sp, color: Colors.grey),
                    MediaQueryHelper.gapW(4, context),
                    reausabletext(
                      "${g['members']} Members",
                      fontsize: 11.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (muted) ...[
            Icon(
              Icons.mic_off_rounded,
              size: 16.sp,
              color: const Color(0xFF6B4DFF).withOpacity(0.5),
            ),
            MediaQueryHelper.gapW(6, context),
          ],
          Container(
            padding: MediaQueryHelper.paddingAll(8, context),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.cell_tower,
              size: 18.sp,
              color: const Color(0xFF6B4DFF),
            ),
          ),
        ],
      ),
    );
  }
}
