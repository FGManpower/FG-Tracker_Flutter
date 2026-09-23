import 'package:fgtracker/app/modules/mediaStream/Views/call_contacts_tab.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/call_groups_tab.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Widget/call_dial_pad.dart';
import 'call_recent_calls_tab.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final CallController controller = CallController.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.switchTab(_tabController.index);
        if (_tabController.index != 0 && controller.isDialPadOpen.value) {
          controller.isDialPadOpen.value = false;
        }
      }
    });
    controller.loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                SizedBox(height: 8.h),
                _buildSearchBar(),
                SizedBox(height: 12.h),
                _buildTabBar(),
                SizedBox(height: 8.h),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const CallRecentCallsTab(),
                      const CallContactsTab(),
                      CallGroupsTab(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Obx(() {
                if (controller.selectedTab.value != 0) {
                  return const SizedBox.shrink();
                }
                return const CallDialPad();
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedTab.value != 0 ||
            controller.isDialPadOpen.value) {
          return const SizedBox.shrink();
        }
        return const _QuickCallActionButton();
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: const Color(0xFF4818F0),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Call",
                style: TextStyle(
                  fontSize: 19.sp,
                  fontFamily: FontFamily.interBold,
                  color: const Color(0xFF1E1B4B),
                  height: 1.15,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Audio / Video Call",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontFamily: FontFamily.interRegular,
                  color: const Color(0xFF6B4DFF),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: const Color(0xFF6B4DFF).withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 20.sp,
              color: const Color(0xFF6B4DFF),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                onTap: () {
                  if (controller.isDialPadOpen.value) {
                    controller.isDialPadOpen.value = false;
                  }
                },
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interRegular,
                  color: const Color(0xFF1E1B4B),
                ),
                decoration: InputDecoration(
                  hintText: "Search contacts or groups",
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                    fontFamily: FontFamily.interRegular,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: controller.clearSearch,
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: Colors.grey,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          onTap: (index) {
            controller.switchTab(index);
            if (index != 0 && controller.isDialPadOpen.value) {
              controller.isDialPadOpen.value = false;
            }
          },
          indicator: BoxDecoration(
            color: const Color(0xFF4818F0),
            borderRadius: BorderRadius.circular(13.r),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF4818F0),
          labelStyle: TextStyle(
            fontSize: 12.sp,
            fontFamily: FontFamily.interSemiBold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.sp,
            fontFamily: FontFamily.interSemiBold,
          ),
          tabs: [
            _buildTab(
              icon: Icons.access_time_rounded,
              title: "Recent",
            ),
            _buildTab(
              icon: Icons.person_outline_rounded,
              title: "Contacts",
            ),
            _buildTab(
              icon: Icons.groups_outlined,
              title: "Groups",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required IconData icon}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 6.w),
          Text(title),
        ],
      ),
    );
  }
}

class _QuickCallActionButton extends StatelessWidget {
  const _QuickCallActionButton();

  @override
  Widget build(BuildContext context) {
    final callController = CallController.instance;
    return GestureDetector(
      onTap: callController.toggleDialPad,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: const Color(0xFF4818F0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4818F0).withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.apps_rounded,
          size: 26.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
