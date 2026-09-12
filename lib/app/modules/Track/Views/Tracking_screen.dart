import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Controller/Track_controller.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TrackingScreen extends StatelessWidget {
  TrackingScreen({super.key});

  final TrackController controller = Get.put(TrackController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySecondaryBackground,
      body: Stack(
        children: [
          // Subtle decorative lavender-blue glow at top right matching reference design
          Positioned(
            top: -70.h,
            right: -70.w,
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE0E7FF).withOpacity(0.55),
                    const Color(0xFFEDE9FE).withOpacity(0.25),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildCustomTabs(),
                Obx(() {
                  if (controller.selectedTabIndex.value == 1) {
                    return Expanded(child: _buildGroupTabContent());
                  }
                  return Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildSearchAndRadius(),
                          _buildMapSection(),
                          _buildStatsCard(),
                          _buildLiveMembersList(),
                          _buildBottomShareButton(),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- APPBAR / HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Row(
        children: [
          // Back button
          _iconButton(
            icon: Icons.arrow_back,
            onTap: () => Get.back(),
          ),
          SizedBox(width: 12.w),
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tracking",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Live location tracking",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primarySecondaryElementText,
                  ),
                ),
              ],
            ),
          ),
          // Help / Info button on right
          _iconButton(
            icon: Icons.help_outline_rounded,
            onTap: () {
              _showTrackingHelpDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTrackingHelpDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tracking Help",
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 10.h, right: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.primaryText,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 245.w,
                      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20.r,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tracking Help",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E1B4B),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(ctx).pop(),
                                child: Padding(
                                  padding: EdgeInsets.all(2.r),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: const Color(0xFF4338CA),
                                    size: 17.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _helpItem(
                            icon: Icons.location_on_rounded,
                            title: "What is Live Tracking?",
                            subtitle:
                                "Track team's real-time location on the map.",
                          ),
                          SizedBox(height: 11.h),
                          _helpItem(
                            icon: Icons.groups_rounded,
                            title: "How to Add Group?",
                            subtitle:
                                "Create a group to track multiple members.",
                          ),
                          SizedBox(height: 11.h),
                          _helpItem(
                            icon: Icons.gps_fixed_rounded,
                            title: "What is Tracking Radius?",
                            subtitle:
                                "Set the area to find nearby members on the map.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            ),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }

  Widget _helpItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4F46E5),
            size: 16.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.textbordercolor),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2046).withOpacity(0.04),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 20.sp),
      ),
    );
  }

  // --- CUSTOM TABS: Live Tracking | Group ---
// --- CUSTOM TABS: Live Tracking | Group ---
  Widget _buildCustomTabs() {
    return Obx(() {
      final isLive = controller.selectedTabIndex.value == 0;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2046).withOpacity(0.03),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(4.r),
        child: Row(
          children: [
            // Live Tracking Tab
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color:
                        isLive ? AppColors.primaryElement : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        size: 17.sp,
                        color: isLive ? Colors.white : AppColors.primarySecondaryElementText,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Live Tracking",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              isLive ? Colors.white : AppColors.primarySecondaryElementText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Group Tab
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: !isLive
                        ? AppColors.primaryElement
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 19.sp,
                        color: !isLive ? Colors.white : AppColors.primarySecondaryElementText,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Group",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              !isLive ? Colors.white : AppColors.primarySecondaryElementText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- SEARCH BAR & RADIUS DROPDOWN ---
  Widget _buildSearchAndRadius() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
      child: Row(
        children: [
          // Search box
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.textbordercolor),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                style:
                    TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryElement,
                    size: 20.sp,
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 38.w),
                  hintText: "Search by name or group...",
                  hintStyle: TextStyle(
                      color: AppColors.primaryThreeElementText, fontSize: 12.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Radius Dropdown Button
          Obx(() {
            return PopupMenuButton<String>(
              offset: Offset(0, 46.h),
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: (value) => controller.updateRadius(value),
              itemBuilder: (context) => ["2", "4", "6", "8"]
                  .map(
                    (r) => PopupMenuItem<String>(
                      value: r,
                      height: 38.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$r km",
                            style: TextStyle(
                              fontWeight: controller.selectedRadius.value == r
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13.sp,
                              color: controller.selectedRadius.value == r
                                  ? AppColors.primaryElement
                                  : AppColors.primaryText,
                            ),
                          ),
                          if (controller.selectedRadius.value == r)
                            Icon(Icons.check_rounded,
                                color: AppColors.primaryElement,
                                size: 16.sp),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.textbordercolor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed_rounded,
                        color: AppColors.primaryElement, size: 14.sp),
                    SizedBox(width: 5.w),
                    Text(
                      "Radius: ${controller.selectedRadius.value} km",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18.sp,
                      color: AppColors.primaryText,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- MAP SECTION ---
  Widget _buildMapSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 260.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2046).withOpacity(0.06),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          children: [
            // Live Interactive Google Map
            Obx(() {
              final lat = controller.currentLat.value != 0.0
                  ? controller.currentLat.value
                  : 19.0760;
              final lng = controller.currentLong.value != 0.0
                  ? controller.currentLong.value
                  : 72.8777;

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 16.0,
                ),
                markers: controller.markers.value,
                circles: controller.circles.value,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: false,
                buildingsEnabled: true,
                mapType: MapType.normal,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                onMapCreated: controller.onMapCreated,
              );
            }),

            // Bottom-left badge: "8 Members Live >"
            Positioned(
              left: 12.w,
              bottom: 12.h,
              child: GestureDetector(
                onTap: controller.fitAllMembers,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups_rounded,
                          size: 16.sp, color: AppColors.primaryElement),
                      SizedBox(width: 5.w),
                      Obx(
                        () => Text(
                          "${controller.liveNowCount.value} Members Live",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(Icons.chevron_right_rounded,
                          size: 17.sp, color: AppColors.primaryElement),
                    ],
                  ),
                ),
              ),
            ),

            // Map Control Buttons (Zoom in, Zoom out, My Location)
            Positioned(
              right: 12.w,
              bottom: 12.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32.h,
                          width: 34.w,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.add_rounded,
                                size: 18.sp, color: AppColors.primaryText),
                            onPressed: controller.zoomIn,
                          ),
                        ),
                        Divider(
                          height: 1.h,
                          thickness: 1.h,
                          color: const Color(0xFFF1F2F6),
                        ),
                        SizedBox(
                          height: 32.h,
                          width: 34.w,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.remove_rounded,
                                size: 18.sp, color: AppColors.primaryText),
                            onPressed: controller.zoomOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // My Location Button
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: "My Location",
                      icon: Icon(Icons.gps_fixed_rounded,
                          size: 16.sp, color: AppColors.primaryText),
                      onPressed: () => controller.recenterMap(zoom: 16.0),
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

  // --- STATS CARDS: Total Members | Live Now | Tracking Radius ---
  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textbordercolor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2046).withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Column 1: Total Members
          Expanded(
            child: InkWell(
              onTap: controller.fitAllMembers,
              borderRadius: BorderRadius.circular(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 16.sp,
                        color: const Color(0xFF4F46E5),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          "Total Members",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Obx(
                    () => Text(
                      "${controller.totalMembersCount.value}",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider 1
          Container(
            height: 36.h,
            width: 1.w,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            color: const Color(0xFFE2E8F0),
          ),

          // Column 2: Live Now
          Expanded(
            child: InkWell(
              onTap: controller.fitAllMembers,
              borderRadius: BorderRadius.circular(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          "Live Now",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Obx(
                    () => Text(
                      "${controller.liveNowCount.value}",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider 2
          Container(
            height: 36.h,
            width: 1.w,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            color: const Color(0xFFE2E8F0),
          ),

          // Column 3: Tracking Radius
          Expanded(
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              tooltip: "Select radius",
              offset: Offset(0, 48.h),
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: (value) => controller.updateRadius(value),
              itemBuilder: (context) => ["2", "4", "6", "8"]
                  .map(
                    (r) => PopupMenuItem<String>(
                      value: r,
                      height: 38.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$r km",
                            style: TextStyle(
                              fontWeight: controller.selectedRadius.value == r
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13.sp,
                              color: controller.selectedRadius.value == r
                                  ? AppColors.primaryElement
                                  : AppColors.primaryText,
                            ),
                          ),
                          if (controller.selectedRadius.value == r)
                            Icon(Icons.check_rounded,
                                color: AppColors.primaryElement,
                                size: 16.sp),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.track_changes_rounded,
                        size: 15.sp,
                        color: const Color(0xFF6366F1),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          "Tracking Radius",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Obx(
                    () => Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          controller.selectedRadius.value,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            height: 1.1,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "km",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LIVE MEMBERS SECTION ---
  Widget _buildLiveMembersList() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
      child: Column(
        children: [
          // Section Header: "Live Members" | "View All ->"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Live Members",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final List<LocationData> membersList = controller.radiusUsers
                      .map((u) => LocationData(
                            userId: u.userId,
                            name: u.name,
                            profileImage: u.profileImage,
                            latitude: u.latitude,
                            longitude: u.longitude,
                            isOnline: u.isOnline,
                            lastSeen: DateTime.now().toIso8601String(),
                          ))
                      .toList();

                  Get.toNamed(
                    Routes.SearchMembers,
                    arguments: {
                      "GroupMembers": membersList,
                    },
                  )?.then((selectedUserId) {
                    if (selectedUserId != null &&
                        selectedUserId.toString().isNotEmpty) {
                      controller.focusMemberById(selectedUserId.toString());
                    }
                  });
                },
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryElement,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.sp,
                      color: AppColors.primaryElement,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final bool isLoading = controller.isLoading.value;

            if (isLoading && controller.liveMembers.isEmpty) {
              return Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _memberCard(
                      MemberModel(
                        userId: index,
                        name: "Member Name Placeholder",
                        team: "Operations Team",
                        location: "Area Name, City",
                        distance: "1.2 km away",
                        battery: 85,
                        avatarUrl: "",
                      ),
                    );
                  },
                ),
              );
            }

            final String query =
                controller.searchController.text.trim().toLowerCase();
            final List<MemberModel> membersToDisplay = query.isEmpty
                ? controller.liveMembers.toList()
                : controller.liveMembers
                    .where((m) =>
                        m.name.toLowerCase().contains(query) ||
                        m.team.toLowerCase().contains(query) ||
                        m.location.toLowerCase().contains(query))
                    .toList();

            if (membersToDisplay.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_off_rounded,
                          color: AppColors.primaryThreeElementText, size: 36.sp),
                      SizedBox(height: 8.h),
                      Text(
                        controller.searchController.text.trim().isNotEmpty
                            ? "No members match '${controller.searchController.text}'"
                            : "No members found within ${controller.selectedRadius.value} km",
                        style: TextStyle(
                            color: AppColors.primarySecondaryElementText, fontSize: 13.sp),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () => controller.getUsersWithinRadius(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryElementLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "Tap to Refresh",
                            style: TextStyle(
                              color: AppColors.primaryElement,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Skeletonizer(
              enabled: isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: membersToDisplay.length,
                itemBuilder: (context, index) {
                  return _memberCard(membersToDisplay[index]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- MEMBER CARD ---
  Widget _memberCard(MemberModel member) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textbordercolor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2046).withOpacity(0.02),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with green online dot
          Stack(
            children: [
              ClipOval(
                child: member.avatarUrl.isNotEmpty
                    ? Image.network(
                        member.avatarUrl,
                        width: 42.w,
                        height: 42.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholderAvatar(member.name),
                      )
                    : _placeholderAvatar(member.name),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryElementStatus,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          // User Details (Name, Team, Location)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                if (member.team.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    member.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primarySecondaryElementText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: AppColors.primaryElement, size: 12.sp),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        member.location.isNotEmpty
                            ? member.location
                            : "Location unavailable",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primarySecondaryElementText,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          // Distance & Battery
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDistance(member.distance),
                style: TextStyle(
                  color: const Color(0xFF4B5563),
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getBatteryIcon(member.battery ?? 85),
                    color: _getBatteryColor(member.battery ?? 85),
                    size: 13.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "${member.battery ?? 85}%",
                    style: TextStyle(
                      color: const Color(0xFF4B5563),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 6.w),
          // Focus/Fly on Map action button
          GestureDetector(
            onTap: () {
              if (member.latitude != null &&
                  member.longitude != null &&
                  member.latitude != 0.0 &&
                  member.longitude != 0.0) {
                controller.mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(member.latitude!, member.longitude!),
                      zoom: 17.0,
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: -0.4,
                child: Icon(Icons.near_me_rounded,
                    color: AppColors.primaryElement, size: 15.sp),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          // Options Menu
          Icon(
            Icons.more_vert_rounded,
            color: const Color(0xFF9CA3AF),
            size: 18.sp,
          ),
        ],
      ),
    );
  }

  String _formatDistance(String distance) {
    if (distance.isEmpty) return "Nearby";
    if (distance.contains("away")) return distance;
    final cleaned = distance.replaceAll(RegExp(r'[^\d.]'), '');
    final numVal = double.tryParse(cleaned);
    if (numVal != null) {
      return "${numVal.toStringAsFixed(1)} km away";
    }
    return "$distance km away";
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 75) return Icons.battery_6_bar_rounded;
    if (level >= 50) return Icons.battery_4_bar_rounded;
    if (level >= 30) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  Color _getBatteryColor(int level) {
    if (level <= 20) return const Color(0xFFEF4444);
    if (level <= 40) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Widget _placeholderAvatar([String? name]) {
    final String initial = (name != null && name.trim().isNotEmpty)
        ? name.trim()[0].toUpperCase()
        : "";
    return Container(
      width: 42.w,
      height: 42.w,
      color: AppColors.primaryElementLight,
      alignment: Alignment.center,
      child: initial.isNotEmpty
          ? Text(
              initial,
              style: TextStyle(
                color: AppColors.primaryElement,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            )
          : Icon(Icons.person, color: AppColors.primaryElement, size: 22.sp),
    );
  }

  // --- BOTTOM BANNER: Share Live Location ---
  Widget _buildBottomShareButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 20.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2FE),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFDEE5FC)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.primaryElement,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.groups_rounded, color: Colors.white, size: 21.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share Live Location",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Share your live location with your team",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primarySecondaryElementText,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E2046).withOpacity(0.08),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(Icons.arrow_forward_rounded,
                color: AppColors.primaryElement, size: 19.sp),
          ),
        ],
      ),
    );
  }

  // --- GROUP TAB CONTENT ---
  Widget _buildGroupTabContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.textbordercolor),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearch,
              style: TextStyle(fontSize: 13.sp, color: AppColors.primaryText),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.primaryElement, size: 20.sp),
                prefixIconConstraints: BoxConstraints(minWidth: 38.w),
                hintText: "Search groups...",
                hintStyle:
                    TextStyle(color: AppColors.primaryThreeElementText, fontSize: 12.sp),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Groups",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              Obx(
                () => Skeletonizer(
                  enabled: controller.isGroupLoading.value,
                  child: Text(
                    "${controller.filteredGroups.length} Groups",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryElement,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.fetchGroupData();
              },
              color: AppColors.primaryElement,
              child: Obx(() {
                final bool isGroupLoading = controller.isGroupLoading.value;

                if (isGroupLoading && controller.filteredGroups.isEmpty) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 24.h),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _groupCard(
                          GroupsResData(
                            id: index,
                            groupName: "Loading Group Name",
                            groupDesc: "Group description placeholder",
                            groupCode: "FG-00$index",
                          ),
                        );
                      },
                    ),
                  );
                }
                if (controller.filteredGroups.isEmpty) {
                  return Center(
                    child: Text(
                      controller.groupError.isNotEmpty
                          ? controller.groupError.value
                          : "No groups found",
                      style: TextStyle(
                          color: AppColors.primaryThreeElementText, fontSize: 13.sp),
                    ),
                  );
                }
                return Skeletonizer(
                  enabled: isGroupLoading,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 24.h),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: controller.filteredGroups.length,
                    itemBuilder: (context, index) {
                      return _groupCard(controller.filteredGroups[index]);
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard(GroupsResData group) {
    final String? profileUrl =
        group.groupProfile != null && group.groupProfile!.isNotEmpty
            ? (group.groupProfile!.startsWith("http")
                ? group.groupProfile!
                : "${ConstRes.aImageBaseUrl}${group.groupProfile}")
            : null;

    return GestureDetector(
      onTap: () {
        controller.selectGroup(group);
        final int gId = group.id is int
            ? (group.id as int)
            : (int.tryParse(group.id?.toString() ?? '0') ?? 0);
        Get.toNamed(
          Routes.LocationTracking,
          arguments: {
            "groupId": gId,
            "groupName": group.groupName ?? "Group",
          },
        )?.then((value) {
          if (value == true) {
            controller.fetchGroupData();
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.textbordercolor,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2046).withOpacity(0.02),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.primaryElementLight,
                shape: BoxShape.circle,
                image: profileUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profileUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileUrl == null
                  ? Icon(Icons.groups_rounded,
                      color: AppColors.primaryElement, size: 21.sp)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.groupName ?? "Unnamed Group",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      if (group.isCreator == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryElementLight,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryElement,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    (group.groupDesc != null && group.groupDesc!.isNotEmpty)
                        ? group.groupDesc!
                        : (group.groupCode != null
                            ? "Code: ${group.groupCode}"
                            : "No description"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.primarySecondaryElementText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      Routes.Memberscreen,
                      arguments: {
                        "groupId": group.id?.toString() ?? "",
                        "groupName": group.groupName ?? "",
                        "groupCode": group.groupCode ?? "",
                        "isCreator": group.isCreator?.toString() ?? "false",
                        "isActive": group.isActive?.toString() ?? "false",
                      },
                    )?.then((value) {
                      if (value == true) {
                        controller.fetchGroupData();
                      }
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryElementLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people,
                            size: 11.sp, color: AppColors.primaryElement),
                        SizedBox(width: 3.w),
                        Text(
                          "${group.memberCount ?? 0}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryElement,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.sp,
                  color: AppColors.primaryThreeElementText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw a stylish dashed circular border matching the tracking radius visual
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;
  final double gapRatio;

  const DashedCirclePainter({
    this.color = const Color(0xFFA5B4FC),
    this.strokeWidth = 1.3,
    this.dashes = 20,
    this.gapRatio = 0.45,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double sweep = (2 * math.pi) / dashes;
    final double dashSweep = sweep * (1 - gapRatio);

    for (int i = 0; i < dashes; i++) {
      final double startAngle = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashes != dashes ||
      oldDelegate.gapRatio != gapRatio;
}
