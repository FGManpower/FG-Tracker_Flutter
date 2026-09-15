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
  final Rx<MapType> _mapType = MapType.normal.obs;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final RxDouble _sheetExtent = 0.175.obs;

  void _toggleSheet() {
    if (_sheetController.isAttached) {
      if (_sheetExtent.value < 0.3) {
        _sheetController.animateTo(
          0.88,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _sheetController.animateTo(
          0.175,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
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
                polylines: controller.polylines.value,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                buildingsEnabled: true,
                mapType: _mapType.value,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                onMapCreated: controller.onMapCreated,
              );
            }),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildTopSearchBar(),
            ),
          ),

          Positioned(
            top: 104.h,
            right: 16.w,
            child: _buildRightActionButtons(),
          ),

          Obx(() {
            final screenH = MediaQuery.of(context).size.height;
            final pillBottom = (_sheetExtent.value * screenH) + 12.h;
            if (_sheetExtent.value > 0.70) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: 16.w,
              bottom: pillBottom,
              child: _buildLiveMembersPill(),
            );
          }),

          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _sheetExtent.value = notification.extent;
              return true;
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.175,
              minChildSize: 0.175,
              maxChildSize: 0.88,
              snap: true,
              snapSizes: const [0.175, 0.88],
              builder: (context, scrollController) {
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18.r,
                        offset: Offset(0, -3.h),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final isGroupTab = controller.selectedTabIndex.value == 1;
                    return CustomScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _toggleSheet,
                                behavior: HitTestBehavior.opaque,
                                child: _buildDragHandle(),
                              ),
                              _buildSheetHeader(context),
                              _buildCustomTabs(),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                        if (isGroupTab)
                          _buildGroupSliverContent()
                        else
                          _buildLiveTrackingSliverContent(),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GestureDetector(
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
        child: Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: const Color(0xFF4338CA),
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Search location...",
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _mapActionButton(
          icon: Icons.layers_rounded,
          onTap: () {
            if (_mapType.value == MapType.normal) {
              _mapType.value = MapType.satellite;
            } else if (_mapType.value == MapType.satellite) {
              _mapType.value = MapType.terrain;
            } else {
              _mapType.value = MapType.normal;
            }
          },
        ),
        SizedBox(height: 10.h),
        _mapActionButton(
          icon: Icons.my_location_rounded,
          onTap: () => controller.recenterMap(zoom: 16.0),
        ),
        SizedBox(height: 10.h),
        _mapActionButton(
          icon: Icons.refresh_rounded,
          onTap: () => controller.getUsersWithinRadius(),
        ),
        SizedBox(height: 10.h),
        _buildRadiusButton(),
      ],
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: const Color(0xFF4338CA),
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusButton() {
    return PopupMenuButton<String>(
      offset: Offset(-8.w, 48.h),
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
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
                          ? FontWeight.w800
                          : FontWeight.w500,
                      fontSize: 13.sp,
                      color: controller.selectedRadius.value == r
                          ? const Color(0xFF4338CA)
                          : AppColors.primaryText,
                    ),
                  ),
                  if (controller.selectedRadius.value == r)
                    Icon(
                      Icons.check_rounded,
                      color: const Color(0xFF4338CA),
                      size: 16.sp,
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        width: 44.w,
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.track_changes_rounded,
              color: const Color(0xFF4338CA),
              size: 18.sp,
            ),
            SizedBox(height: 1.h),
            Text(
              "Radius",
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4338CA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMembersPill() {
    return GestureDetector(
      onTap: controller.fitAllMembers,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_rounded,
              size: 18.sp,
              color: const Color(0xFF4338CA),
            ),
            SizedBox(width: 6.w),
            Obx(
              () {
                final count = controller.liveNowCount.value > 0
                    ? controller.liveNowCount.value
                    : (controller.liveMembers.isNotEmpty
                        ? controller.liveMembers.length
                        : 0);
                return Text(
                  "$count Members Live",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B4B),
                  ),
                );
              },
            ),
            Container(
              height: 16.h,
              width: 1.w,
              color: const Color(0xFFE2E8F0),
              margin: EdgeInsets.symmetric(horizontal: 10.w),
            ),
            Icon(
              Icons.bar_chart_rounded,
              size: 18.sp,
              color: const Color(0xFF4338CA),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
        width: 44.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: const Color(0xFF94A3B8).withOpacity(0.4),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tracking",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B4B),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "Live location tracking",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          _iconButton(
            icon: Icons.help_outline_rounded,
            onTap: () => _showTrackingHelpDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabs() {
    final isLive = controller.selectedTabIndex.value == 0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(3.r),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectTab(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isLive ? const Color(0xFF4338CA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sensors_rounded,
                      size: 18.sp,
                      color: isLive ? Colors.white : const Color(0xFF4338CA),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Live Tracking",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isLive ? Colors.white : const Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectTab(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !isLive ? const Color(0xFF4338CA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: 19.sp,
                      color: !isLive ? Colors.white : const Color(0xFF4338CA),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Group",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: !isLive ? Colors.white : const Color(0xFF4338CA),
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
  }

  Widget _buildLiveTrackingSliverContent() {
    final query = controller.searchController.text.trim().toLowerCase();
    final List<MemberModel> membersToDisplay = query.isEmpty
        ? controller.liveMembers.toList()
        : controller.liveMembers
            .where((m) =>
                m.name.toLowerCase().contains(query) ||
                m.team.toLowerCase().contains(query) ||
                m.location.toLowerCase().contains(query))
            .toList();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildSearchBox("Search by name or group..."),
          SizedBox(height: 12.h),
          Text(
            "Live Members",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          SizedBox(height: 8.h),
          if (controller.isLoading.value && controller.liveMembers.isEmpty)
            Skeletonizer(
              enabled: true,
              child: Column(
                children: List.generate(
                  3,
                  (index) => _memberCard(
                    MemberModel(
                      userId: index,
                      name: "Member Name Placeholder",
                      team: "Operations Team",
                      location: "Area Name, City",
                      distance: "1.2 km away",
                      battery: 85,
                      avatarUrl: "",
                    ),
                  ),
                ),
              ),
            )
          else if (membersToDisplay.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off_rounded,
                      color: AppColors.primaryThreeElementText,
                      size: 36.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      controller.searchController.text.trim().isNotEmpty
                          ? "No members match '${controller.searchController.text}'"
                          : "No members found within ${controller.selectedRadius.value} km",
                      style: TextStyle(
                        color: AppColors.primarySecondaryElementText,
                        fontSize: 13.sp,
                      ),
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
            )
          else
            ...membersToDisplay.map((m) => _memberCard(m)),
          SizedBox(height: 6.h),
          _buildBottomShareButton(),
          SizedBox(height: 24.h),
        ]),
      ),
    );
  }

  Widget _buildGroupSliverContent() {
    final bool isGroupLoading = controller.isGroupLoading.value;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildSearchBox("Search groups..."),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Groups",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              Skeletonizer(
                enabled: isGroupLoading,
                child: Text(
                  "${controller.filteredGroups.length} Groups",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4338CA),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (isGroupLoading && controller.filteredGroups.isEmpty)
            Skeletonizer(
              enabled: true,
              child: Column(
                children: List.generate(
                  4,
                  (index) => _groupCard(
                    GroupsResData(
                      id: index,
                      groupName: "Loading Group Name",
                      groupDesc: "Group description placeholder",
                      groupCode: "FG-00$index",
                    ),
                  ),
                ),
              ),
            )
          else if (controller.filteredGroups.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Center(
                child: Text(
                  controller.groupError.isNotEmpty
                      ? controller.groupError.value
                      : "No groups found",
                  style: TextStyle(
                    color: AppColors.primaryThreeElementText,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            )
          else
            ...controller.filteredGroups.map((g) => _groupCard(g)),
          SizedBox(height: 24.h),
        ]),
      ),
    );
  }

  Widget _buildSearchBox(String hint) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFF1E1B4B),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF4338CA),
            size: 20.sp,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 38.w),
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 12.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
    );
  }

  Widget _memberCard(MemberModel member) {
    return GestureDetector(
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
          if (_sheetController.isAttached) {
            _sheetController.animateTo(
              0.175,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        }
      },
      child: Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2046).withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    width: 1.5.w,
                  ),
                ),
                child: ClipOval(
                  child: member.avatarUrl.isNotEmpty
                      ? Image.network(
                          member.avatarUrl,
                          width: 44.w,
                          height: 44.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholderAvatar(member.name),
                        )
                      : _placeholderAvatar(member.name),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 11.w,
                  height: 11.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
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
                    fontSize: 14.sp,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: const Color(0xFF4338CA),
                      size: 13.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        member.location.isNotEmpty
                            ? member.location
                            : "Location unavailable",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDistance(member.distance),
                style: TextStyle(
                  color: const Color(0xFF4338CA),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getBatteryIcon(member.battery ?? 80),
                    color: const Color(0xFF4338CA),
                    size: 14.sp,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    "${member.battery ?? 80}%",
                    style: TextStyle(
                      color: const Color(0xFF4338CA),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 10.w),
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
                if (_sheetController.isAttached) {
                  _sheetController.animateTo(
                    0.175,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              }
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: -0.4,
                child: Icon(
                  Icons.near_me_rounded,
                  color: const Color(0xFF4338CA),
                  size: 17.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBottomShareButton() {
    return GestureDetector(
      onTap: () => controller.selectTab(1),
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 8.h, 0, 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: Color(0xFF4338CA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Share Live Location",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1B4B),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Share your live location with your team",
                    style: TextStyle(
                      color: const Color(0xFF6366F1),
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
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFF4338CA),
                size: 20.sp,
              ),
            ),
          ],
        ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
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
                            color: const Color(0xFF1E1B4B),
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
                      color: const Color(0xFF64748B),
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

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E1B4B), size: 20.sp),
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

  Widget _placeholderAvatar([String? name]) {
    final String initial = (name != null && name.trim().isNotEmpty)
        ? name.trim()[0].toUpperCase()
        : "";
    return Container(
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
}
