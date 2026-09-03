import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/call_contacts_tab.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/call_groups_tab.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/call_recent_calls_tab.dart';
import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
      backgroundColor: const Color(0xFFF5F4FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            SizedBox(height: 10.h),
            _buildSearchBar(),
            SizedBox(height: 12.h),
            _buildTabBar(),
            SizedBox(height: 12.h),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CallRecentCallsTab(),
                  CallContactsTab(),
                  CallGroupsTab(),
                ],

              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const _QuickCallActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Get.back(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: reausabletext(
              "Audio / Video Call",
              fontsize: 14.sp,
              fontfamily: FontFamily.interBold,
              color: Colors.black87,
            ),
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
            color: const Color(0xFF6B4DFF).withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18.sp, color: const Color(0xFF6B4DFF)),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interRegular,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Search contacts or groups",
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
        height: 45.h,
        // padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          onTap: controller.switchTab,
          indicator: BoxDecoration(
            color: const Color(0xFF4818F0),
            borderRadius: BorderRadius.circular(15.r),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 0.w),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6B4DFF),
          labelStyle: TextStyle(
            fontSize: 9.sp,
            fontFamily: FontFamily.interSemiBold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 9.sp,
            fontFamily: FontFamily.interSemiBold,
          ),
          tabs: [
            callTab(
              icon: Icons.history_rounded,
              title: "Recent",
            ),
            callTab(
              icon: Icons.person_rounded,
              title: "Contacts",
            ),
            callTab(
              icon: Icons.groups_rounded,
              title: "Groups",
            ),
          ],
        ),
      ),
    );
  }
}

Widget callTab({
  required String title,
  required IconData icon,
}) {
  return Tab(
    // height: 45.h,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        reausableIcon(icon: icon, size: 15),
        SizedBox(
          width: 5.4,
        ),
        reausabletext(
          title,
          fontsize: 13,
          fontfamily: FontFamily.interBold,
        ),
      ],
    ),
  );
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: Colors.black87),
      ),
    );
  }
}

class _QuickCallActionButton extends StatelessWidget {
  const _QuickCallActionButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58.w,
      height: 58.w,
      decoration: BoxDecoration(
        color: const Color(0xFF4818F0),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4818F0).withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.apps_rounded, size: 26.sp, color: Colors.white),
    );
  }
}
