import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Controller/Track_controller.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TrackingScreen extends StatelessWidget {
  TrackingScreen({super.key});

  final TrackController controller = Get.put(TrackController());

  final Color primaryColor = const Color(0xFF4338CA);
  final Color primaryLight = const Color(0xFFEEF2FF);
  final Color bgColor = const Color(0xFFF7F8FE);
  final Color cardColor = Colors.white;
  final Color textDark = const Color(0xFF1E2046);
  final Color textGrey = const Color(0xFF6B7280);
  final Color textLight = const Color(0xFF9CA3AF);
  final Color borderColor = const Color(0xFFECEFF8);
  final Color greenStatus = const Color(0xFF22C55E);
  final Color greenLight = const Color(0xFFECFDF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
                    color: textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Live location tracking",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w400,
                    color: textGrey,
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

  // --- TRACKING HELP POPUP DIALOG ---
  void _showTrackingHelpDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tracking Help",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 220),
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
                  // Active Help Button matching position
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
                        color: textDark,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Help Card
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 285.w,
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.16),
                            blurRadius: 24.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: "Tracking Help" + Close Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tracking Help",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(ctx).pop(),
                                child: Padding(
                                  padding: EdgeInsets.all(2.r),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: primaryColor,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          // Item 1: What is Live Tracking?
                          _helpItem(
                            icon: Icons.location_on_rounded,
                            title: "What is Live Tracking?",
                            subtitle:
                                "Track team's real-time location on the map.",
                          ),
                          SizedBox(height: 14.h),
                          // Item 2: How to Add Group?
                          _helpItem(
                            icon: Icons.groups_rounded,
                            title: "How to Add Group?",
                            subtitle:
                                "Create a group to track multiple members.",
                          ),
                          SizedBox(height: 14.h),
                          // Item 3: What is Tracking Radius?
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
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 18.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w400,
                  color: textGrey,
                  height: 1.25,
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
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2046).withOpacity(0.04),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(icon, color: textDark, size: 20.sp),
      ),
    );
  }

  // --- CUSTOM TABS: Live Tracking | Group ---
  Widget _buildCustomTabs() {
    return Obx(() {
      final isLive = controller.selectedTabIndex.value == 0;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 48.h,
        decoration: BoxDecoration(
          color: cardColor,
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
                    color: isLive ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        size: 17.sp,
                        color: isLive ? Colors.white : textDark,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Live Tracking",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isLive ? Colors.white : textDark,
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
                    color: !isLive ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 19.sp,
                        color: !isLive ? Colors.white : textDark,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Group",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: !isLive ? Colors.white : textDark,
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
                color: cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                style: TextStyle(fontSize: 13.sp, color: textDark),
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: primaryColor,
                    size: 20.sp,
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 38.w),
                  hintText: "Search by name or group...",
                  hintStyle: TextStyle(color: textLight, fontSize: 12.sp),
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
                                  ? primaryColor
                                  : textDark,
                            ),
                          ),
                          if (controller.selectedRadius.value == r)
                            Icon(Icons.check_rounded,
                                color: primaryColor, size: 16.sp),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed_rounded,
                        color: primaryColor, size: 14.sp),
                    SizedBox(width: 5.w),
                    Text(
                      "Radius: ${controller.selectedRadius.value} km",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5.sp,
                        color: textDark,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18.sp,
                      color: textDark,
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
                          size: 16.sp, color: primaryColor),
                      SizedBox(width: 5.w),
                      Obx(
                        () => Text(
                          "${controller.liveNowCount.value} Members Live",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(Icons.chevron_right_rounded,
                          size: 17.sp, color: primaryColor),
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
                                size: 18.sp, color: textDark),
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
                                size: 18.sp, color: textDark),
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
                          size: 16.sp, color: textDark),
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

  // --- STATS CARDS: Live Now | Tracking Radius ---
  Widget _buildStatsCard() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        children: [
          // Card 1: Live Now
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E2046).withOpacity(0.02),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: greenStatus,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            "Live Now",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: greenLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          color: const Color(0xFF10B981),
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Obx(
                    () => Text(
                      "${controller.liveNowCount.value}",
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Members currently live",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Card 2: Tracking Radius
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E2046).withOpacity(0.02),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.gps_fixed_rounded,
                              size: 13.sp, color: primaryColor),
                          SizedBox(width: 4.w),
                          Text(
                            "Tracking Radius",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: primaryColor,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Obx(
                    () => Text(
                      "${controller.selectedRadius.value} km",
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Current search radius",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: textLight,
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
                  color: textDark,
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
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.sp,
                      color: primaryColor,
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
                          color: textLight, size: 36.sp),
                      SizedBox(height: 8.h),
                      Text(
                        controller.searchController.text.trim().isNotEmpty
                            ? "No members match '${controller.searchController.text}'"
                            : "No members found within ${controller.selectedRadius.value} km",
                        style: TextStyle(color: textGrey, fontSize: 13.sp),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () => controller.getUsersWithinRadius(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: primaryLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "Tap to Refresh",
                            style: TextStyle(
                              color: primaryColor,
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
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
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
                    color: greenStatus,
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
                    color: textDark,
                  ),
                ),
                if (member.team.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    member.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: primaryColor, size: 12.sp),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        member.location.isNotEmpty
                            ? member.location
                            : "Location unavailable",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textGrey,
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
                member.distance.contains('away')
                    ? member.distance
                    : (member.distance.contains('km') ||
                            member.distance.contains('m')
                        ? "${member.distance} away"
                        : "${member.distance} km away"),
                style: TextStyle(
                  color: const Color(0xFF4B5563),
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (member.battery != null && member.battery! > 0) ...[
                SizedBox(height: 3.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.battery_5_bar_rounded,
                        color: primaryColor, size: 13.sp),
                    SizedBox(width: 2.w),
                    Text(
                      "${member.battery}%",
                      style: TextStyle(
                        color: const Color(0xFF4B5563),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
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
                    color: primaryColor, size: 15.sp),
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

  Widget _placeholderAvatar([String? name]) {
    final String initial = (name != null && name.trim().isNotEmpty)
        ? name.trim()[0].toUpperCase()
        : "";
    return Container(
      width: 42.w,
      height: 42.w,
      color: primaryLight,
      alignment: Alignment.center,
      child: initial.isNotEmpty
          ? Text(
              initial,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            )
          : Icon(Icons.person, color: primaryColor, size: 22.sp),
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
              color: primaryColor,
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
                    color: textDark,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Share your live location with your team",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textGrey,
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
                color: primaryColor, size: 19.sp),
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
              color: cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearch,
              style: TextStyle(fontSize: 13.sp, color: textDark),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search_rounded,
                    color: primaryColor, size: 20.sp),
                prefixIconConstraints: BoxConstraints(minWidth: 38.w),
                hintText: "Search groups...",
                hintStyle: TextStyle(color: textLight, fontSize: 12.sp),
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
                  color: textDark,
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
                      color: primaryColor,
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
              color: primaryColor,
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
                      style: TextStyle(color: textLight, fontSize: 13.sp),
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

    final isSelected = controller.selectedGroupId.value == group.id?.toString();

    return GestureDetector(
      onTap: () {
        controller.selectGroup(group);
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
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 1.5.w : 1.w,
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
                color: primaryLight,
                shape: BoxShape.circle,
                image: profileUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profileUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileUrl == null
                  ? Icon(Icons.groups_rounded, color: primaryColor, size: 21.sp)
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
                            color: textDark,
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
                            color: primaryLight,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
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
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 11.sp, color: primaryColor),
                      SizedBox(width: 3.w),
                      Text(
                        "${group.memberCount ?? 0}",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.sp,
                  color: textLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
