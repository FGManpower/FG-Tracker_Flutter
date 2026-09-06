import 'package:fgtracker/app/Core/constant/BottomSheet/bottom_actions_bar.dart';
import 'package:fgtracker/app/Core/values/colorPool.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/WalkieTalkieScreen.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../Group/controller/Group_Controller.dart';

class WalkieGroupSelectScreen extends StatefulWidget {
  const WalkieGroupSelectScreen({super.key});

  @override
  State<WalkieGroupSelectScreen> createState() =>
      _WalkieGroupSelectScreenState();
}

class _WalkieGroupSelectScreenState extends State<WalkieGroupSelectScreen> {
  final GroupController controller = Get.put(GroupController());
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  final RxBool isSearchVisible = false.obs;
  final RxMap<String, bool> activeToggles = <String, bool>{}.obs;

  List<GroupsResData> get _filteredGroups {
    final String query = _searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return controller.groupData;
    return controller.groupData.where((group) {
      final String name = (group.groupName ?? '').toLowerCase();
      final String code = (group.groupCode ?? '').toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getGroupData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => isSearchVisible.value
                ? _buildSearchBar()
                : const SizedBox.shrink()),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                if (controller.responseError.value.isNotEmpty) {
                  return LostinternetConnection(
                    retry: () {
                      controller.getGroupData();
                    },
                    messgae: controller.responseError.value.toString(),
                  );
                }
                if (controller.groupDataLoading.value) {
                  return _buildGroupList(isLoading: true);
                }
                final List<GroupsResData> groups = _filteredGroups;
                if (groups.isEmpty) {
                  return controller.groupData.isEmpty
                      ? DataEmpty_AssetsIcon(
                          assetspath: Assets.images.notFount.path)
                      : Center(
                          child: reausabletext(
                            "No groups found",
                            fontsize: 14.sp,
                            color: Colors.grey,
                          ),
                        );
                }
                return _buildGroupList(data: groups, isLoading: false);
              }),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70.h,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          _circleIcon(
            icon: Icons.arrow_back,
            color: const Color(0xFF6B4DFF),
            onTap: () => Get.back(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
      actions: [
        _circleIcon(
          icon: Icons.search,
          color: const Color(0xFF6B4DFF),
          onTap: () {
            isSearchVisible.toggle();
            if (!isSearchVisible.value) {
              _searchController.clear();
              _searchQuery.value = '';
            }
          },
        ),
        SizedBox(width: 8.w),
        _circleIcon(
          icon: Icons.add,
          color: const Color(0xFF6B4DFF),
          onTap: () {
            try {
              controller.groupName.clear();
              controller.groupDesc.clear();
            } catch (e) {
              debugPrint("Clear error: $e");
            }
            showCreateGroupSheet();
          },
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _circleIcon(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ]),
        child: Row(
          children: [
            Icon(Icons.search, size: 20.sp, color: const Color(0xFF6B4DFF)),
            SizedBox(width: 12.w),
            Expanded(
              child: Obx(() {
                return TextField(
                  controller: _searchController,
                  onChanged: (value) => _searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: "Search groups",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontFamily: FontFamily.interRegular,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    suffixIcon: _searchQuery.value.isEmpty
                        ? null
                        : GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _searchQuery.value = '';
                            },
                            child: Icon(
                              Icons.close,
                              size: 18.sp,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList({
    List<GroupsResData>? data,
    bool isLoading = false,
  }) {
    final List<GroupsResData>? items = isLoading ? null : data;
    final int itemCount = items?.length ?? 6;
    return Skeletonizer(
      enabled: items == null,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final List<GroupsResData>? list = items;
          if (list == null) return const _GroupCardSkeleton();
          return _apiGroupCard(list[index], index);
        },
      ),
    );
  }

  Widget _apiGroupCard(GroupsResData group, int index) {
    final colors = colorPool[index % colorPool.length];
    final String groupId = group.id?.toString() ?? "unknown";

    return InkWell(
      onTap: () {
        Get.to(
          () => const GroupWalkieScreen(),
          arguments: {
            'groupId': groupId,
            'groupName': group.groupName ?? "Unknown Group",
            'groupDesc': group.groupDesc ?? "",
            'groupCode': group.groupCode ?? "",
          },
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: colors['bg'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups,
                color: colors['icon'],
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    group.groupName ?? "No Name Group",
                    fontsize: 15.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt,
                        size: 13.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      reausabletext(
                        "${group.memberCount ?? 0} Members",
                        fontsize: 12.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              final bool isToggled = activeToggles[groupId] ?? false;
              return CupertinoSwitch(
                value: isToggled,
                activeColor: const Color(0xFF6B4DFF),
                onChanged: (bool value) {
                  activeToggles[groupId] = value;
                },
              );
            }),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cell_tower,
                size: 20.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCardSkeleton extends StatelessWidget {
  const _GroupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Group name placeholder",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Members placeholder",
                  style: TextStyle(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Container(width: 40.w, height: 24.h, color: Colors.grey.shade200),
          SizedBox(width: 8.w),
          Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey.shade200)),
        ],
      ),
    );
  }
}
