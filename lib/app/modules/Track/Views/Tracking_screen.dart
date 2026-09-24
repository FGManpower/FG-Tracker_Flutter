import 'package:fgtracker/app/modules/Track/Controller/TrackingController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';

class TrackingScreen extends StatelessWidget {
  TrackingScreen({super.key});

  final TrackController controller = Get.put(TrackController());
  final Rx<MapType> _mapType = MapType.normal.obs;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final RxDouble _sheetExtent = 0.42.obs;
  static bool _isHelpDialogOpen = false;
  static DateTime? _lastHelpTapTime;

  void _toggleSheet() {
    if (_sheetController.isAttached) {
      if (_sheetExtent.value < 0.30) {
        _sheetController.animateTo(
          0.42,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else if (_sheetExtent.value < 0.65) {
        _sheetController.animateTo(
          0.90,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _sheetController.animateTo(
          0.42,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_sheetController.isAttached && _sheetExtent.value > 0.45) {
          _sheetController.animateTo(
            0.42,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        } else {
          Get.back();
        }
      },
      child: Scaffold(
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

              final double extent = _sheetExtent.value;
              final double screenH = MediaQuery.of(context).size.height;
              final double progress =
                  ((extent - 0.12) / (0.52 - 0.12)).clamp(0.0, 1.0);
              final double mapOffsetY = -progress * (screenH * 0.18);

              return Transform.translate(
                offset: Offset(0, mapOffsetY),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 14.5,
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
                  onTap: (latLng) {
                    if (controller.isSearchDropdownOpen.value) {
                      controller.isSearchDropdownOpen.value = false;
                      FocusScope.of(context).unfocus();
                    }
                    if (_sheetController.isAttached &&
                        _sheetExtent.value > 0.45) {
                      _sheetController.animateTo(
                        0.42,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
              );
            }),
          ),

          Obx(() {
            final double extent = _sheetExtent.value;
            final double fade =
                (1.0 - ((extent - 0.55) / 0.12)).clamp(0.0, 1.0);
            if (fade <= 0.0) return const SizedBox.shrink();

            final double screenH = MediaQuery.of(context).size.height;
            final double topBarBottom =
                MediaQuery.of(context).padding.top + 120.h;
            final double collapsedSheetTop = screenH * (1 - 0.12);
            final double buttonsHeight = 210.h;

            final double availableBigMapHeight =
                collapsedSheetTop - topBarBottom;
            final double centerTop =
                topBarBottom + (availableBigMapHeight - buttonsHeight) / 2;

            final double topTop = topBarBottom + 6.h;

            final double progress =
                ((extent - 0.12) / (0.52 - 0.12)).clamp(0.0, 1.0);

            final double currentTop =
                centerTop + (topTop - centerTop) * progress;

            return Positioned(
              top: currentTop,
              right: 16.w,
              child: Opacity(
                opacity: fade,
                child: _buildRightActionButtons(context),
              ),
            );
          }),

          Obx(() {
            final double extent = _sheetExtent.value;
            final double fade =
                (1.0 - ((extent - 0.52) / 0.10)).clamp(0.0, 1.0);
            if (fade <= 0.0) return const SizedBox.shrink();

            final screenH = MediaQuery.of(context).size.height;
            final pillBottom = (extent * screenH) + 12.h;
            return Positioned(
              left: 16.w,
              bottom: pillBottom,
              child: Opacity(
                opacity: fade,
                child: _buildLiveMembersPill(),
              ),
            );
          }),

          // ── Group Mode Overlay on Map ──
          Obx(() {
            if (!controller.isGroupMode.value) return const SizedBox.shrink();
            final double extent = _sheetExtent.value;
            final double fade =
                (1.0 - ((extent - 0.52) / 0.10)).clamp(0.0, 1.0);
            if (fade <= 0.0) return const SizedBox.shrink();

            final String rawGroupImg = controller.selectedGroupProfile.value;
            final String? groupImg =
                rawGroupImg.isNotEmpty && rawGroupImg.toLowerCase() != 'null'
                    ? (rawGroupImg.startsWith("http")
                        ? rawGroupImg
                        : "${ConstRes.aImageBaseUrl}$rawGroupImg")
                    : null;

            return Positioned(
              bottom: (extent * MediaQuery.of(context).size.height) + 12.h,
              right: 16.w,
              child: Opacity(
                opacity: fade,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.fitAllMembers();
                        },
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF4338CA),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4338CA)
                                    .withValues(alpha: 0.35),
                                blurRadius: 10.r,
                                offset: Offset(0, 3.h),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(2.5.w),
                          child: ClipOval(
                            child: groupImg != null
                                ? Image.network(
                                    groupImg,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: const Color(0xFFEEF2FF),
                                      child: Icon(
                                        Icons.groups_rounded,
                                        color: const Color(0xFF4338CA),
                                        size: 22.sp,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: const Color(0xFFEEF2FF),
                                    child: Icon(
                                      Icons.groups_rounded,
                                      color: const Color(0xFF4338CA),
                                      size: 22.sp,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -2.h,
                        right: -2.w,
                        child: GestureDetector(
                          onTap: () {
                            controller.clearGroupMode();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: EdgeInsets.all(3.5.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 1.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 11.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _sheetExtent.value = notification.extent;
              return true;
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.42,
              minChildSize: 0.12,
              maxChildSize: 0.90,
              snap: true,
              snapSizes: const [0.12, 0.42, 0.90],
              snapAnimationDuration: const Duration(milliseconds: 280),
              builder: (context, scrollController) {
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18.r,
                        offset: Offset(0, -3.h),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final isGroupTab = controller.selectedTabIndex.value == 1;
                    return RefreshIndicator(
                      onRefresh: () async {
                        if (isGroupTab) {
                          await controller.fetchGroupData();
                        } else {
                          await controller.getUsersWithinRadius();
                        }
                      },
                      color: const Color(0xFF4338CA),
                      backgroundColor: Colors.white,
                      displacement: 20.h,
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
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
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // ── Top Section (App Bar & Search Bar) on top of Stack ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildTopSection(context),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopAppBar(context),
          Obx(() {
            final double extent = _sheetExtent.value;
            // Smoothly fade out search bar as sheet expands above mid (0.52 to 0.65)
            final double searchOpacity =
                (1.0 - ((extent - 0.52) / 0.13)).clamp(0.0, 1.0);
            if (searchOpacity <= 0.0) {
              return const SizedBox.shrink();
            }
            return Opacity(
              opacity: searchOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.h),
                  _buildTopSearchBar(context),
                  if (controller.isSearchDropdownOpen.value &&
                      controller.searchQuery.value.trim().isNotEmpty)
                    _buildSearchDropdown(context),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () {
            if (_sheetController.isAttached && _sheetExtent.value > 0.45) {
              _sheetController.animateTo(
                0.42,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              );
            } else {
              Get.back();
            }
          },
        ),
        _iconButton(
          icon: Icons.help_outline_rounded,
          onTap: () => _showTrackingHelpDialog(context),
        ),
      ],
    );
  }

  Widget _buildTopSearchBar(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (controller.searchController.text.trim().isNotEmpty) {
                controller.submitSearch(controller.searchController.text);
                FocusScope.of(context).unfocus();
              }
            },
            child: Icon(
              Icons.search_rounded,
              color: const Color(0xFF4338CA),
              size: 22.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (val) {
                controller.submitSearch(val);
                FocusScope.of(context).unfocus();
              },
              onChanged: (val) {
                controller.onSearch(val);
              },
              style: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFF1E1B4B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Search members or groups...",
                hintStyle: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.5.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    controller.searchController.clear();
                    controller.searchQuery.value = "";
                    controller.isSearchDropdownOpen.value = false;
                    controller.onSearch('');
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 18.sp,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown(BuildContext context) {
    final query = controller.searchQuery.value.trim().toLowerCase();
    final List<MemberModel> membersSource =
        controller.allFetchedMembers.isNotEmpty
            ? controller.allFetchedMembers.toList()
            : controller.radiusUsers.map((u) => u.toMemberModel()).toList();

    final matchingMembers = membersSource
        .where((m) =>
            m.name.toLowerCase().contains(query) ||
            m.team.toLowerCase().contains(query) ||
            m.location.toLowerCase().contains(query))
        .toList();

    final matchingGroups = controller.groupList
        .where((g) =>
            (g.groupName ?? "").toLowerCase().contains(query) ||
            (g.groupDesc ?? "").toLowerCase().contains(query) ||
            (g.groupCode ?? "").toLowerCase().contains(query))
        .toList();

    final bool hasNoResults = matchingMembers.isEmpty && matchingGroups.isEmpty;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      constraints: BoxConstraints(maxHeight: 280.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: hasNoResults
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 32.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "No members or groups matching\n'${controller.searchQuery.value}'",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                shrinkWrap: true,
                children: [
                  if (matchingMembers.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 4.h),
                      child: Text(
                        "MEMBERS (${matchingMembers.length})",
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6366F1),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    ...matchingMembers
                        .map((m) => _searchMemberItem(context, m)),
                  ],
                  if (matchingGroups.isNotEmpty) ...[
                    if (matchingMembers.isNotEmpty)
                      Divider(height: 12.h, color: const Color(0xFFF1F5F9)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 4.h),
                      child: Text(
                        "GROUPS (${matchingGroups.length})",
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6366F1),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    ...matchingGroups.map((g) => _searchGroupItem(context, g)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _searchMemberItem(BuildContext context, MemberModel m) {
    return InkWell(
      onTap: () {
        controller.searchController.text = m.name;
        controller.searchQuery.value = m.name;
        controller.isSearchDropdownOpen.value = false;
        FocusScope.of(context).unfocus();
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            0.12,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
        controller.zoomToMember(m);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: const Color(0xFFEEF2FF),
                  backgroundImage:
                      m.avatarUrl.isNotEmpty ? NetworkImage(m.avatarUrl) : null,
                  child: m.avatarUrl.isEmpty
                      ? Icon(Icons.person,
                          size: 20.sp, color: const Color(0xFF4338CA))
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: m.isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${m.team.isNotEmpty ? '${m.team} • ' : ''}${m.location.isNotEmpty ? m.location : m.distance}",
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
            Icon(
              Icons.my_location_rounded,
              size: 18.sp,
              color: const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchGroupItem(BuildContext context, GroupsResData g) {
    return InkWell(
      onTap: () {
        final String gIdStr = (g.id ?? 0).toString();
        controller.isSearchDropdownOpen.value = false;
        FocusScope.of(context).unfocus();
        controller.selectedTabIndex.value = 1;
        controller.searchController.text = g.groupName ?? "";
        controller.searchQuery.value = g.groupName ?? "";
        controller.expandedGroupId.value = gIdStr;
        controller.selectGroup(g);
        controller.fetchGroupLocationData(gIdStr);
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            0.52,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.groups_rounded,
                size: 20.sp,
                color: const Color(0xFF4338CA),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.groupName ?? "Unnamed Group",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${g.memberCount ?? 0} members • Code: ${g.groupCode ?? 'N/A'}",
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13.sp,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightActionButtons(BuildContext context) {
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
        Obx(
          () => _mapActionButton(
            icon: Icons.refresh_rounded,
            isLoading: controller.isLoading.value,
            onTap: () {
              if (controller.isGroupMode.value &&
                  controller.selectedGroupId.value.isNotEmpty) {
                controller.fetchGroupLocationData(
                    controller.selectedGroupId.value);
              } else {
                controller.getUsersWithinRadius();
              }
            },
          ),
        ),
        Obx(() {
          // Hide radius button when in group tab or group mode
          if (controller.isGroupMode.value ||
              controller.selectedTabIndex.value == 1) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: _buildRadiusButton(context),
          );
        }),
      ],
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                  ),
                )
              : Icon(
                  icon,
                  color: const Color(0xFF4338CA),
                  size: 20.sp,
                ),
        ),
      ),
    );
  }

  Widget _buildRadiusButton(BuildContext context) {
    // 4 preset options starting from 100m, followed by custom
    final List<Map<String, String>> presets = [
      {"label": "100 m", "value": "0.1"},
      {"label": "200 m", "value": "0.2"},
      {"label": "500 m", "value": "0.5"},
      {"label": "1 km", "value": "1"},
    ];

    return Obx(() {
      final String currentVal = controller.selectedRadius.value;
      final bool isCustom = !presets.any((p) => p["value"] == currentVal);

      return PopupMenuButton<String>(
        offset: Offset(-8.w, 48.h),
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        onSelected: (value) {
          if (value == "custom") {
            _showCustomRadiusDialog(context);
          } else {
            controller.updateRadius(value);
          }
        },
        itemBuilder: (ctx) => [
          ...presets.map(
            (p) {
              final bool isSelected = currentVal == p["value"];
              return PopupMenuItem<String>(
                value: p["value"],
                height: 38.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p["label"]!,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 13.sp,
                        color: isSelected
                            ? const Color(0xFF4338CA)
                            : AppColors.primaryText,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_rounded,
                        color: const Color(0xFF4338CA),
                        size: 16.sp,
                      ),
                  ],
                ),
              );
            },
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: "custom",
            height: 38.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 15.sp,
                      color: isCustom
                          ? const Color(0xFF4338CA)
                          : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isCustom
                          ? "Custom (${controller.currentFormattedRadius})"
                          : "Custom",
                      style: TextStyle(
                        fontWeight:
                            isCustom ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 13.sp,
                        color: isCustom
                            ? const Color(0xFF4338CA)
                            : AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                if (isCustom)
                  Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF4338CA),
                    size: 16.sp,
                  ),
              ],
            ),
          ),
        ],
        child: Container(
          width: 44.w,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                controller.currentFormattedRadius,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    });
  }

  void _showCustomRadiusDialog(BuildContext context) {
    final List<double> radiusOptions = [
      100.0,
      250.0,
      500.0,
      1000.0,
      2000.0,
      5000.0,
    ];

    String formatRadius(double meters) {
      if (meters >= 1000) {
        final km = meters / 1000.0;
        return km == km.toInt()
            ? '${km.toInt()} km'
            : '${km.toStringAsFixed(1)} km';
      }
      return '${meters.toInt()} m';
    }

    final double currentMeters =
        (double.tryParse(controller.selectedRadius.value) ?? 0.1) * 1000.0;
    int initialIndex = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < radiusOptions.length; i++) {
      final diff = (radiusOptions[i] - currentMeters).abs();
      if (diff < minDiff) {
        minDiff = diff;
        initialIndex = i;
      }
    }

    final RxInt selectedIndex = initialIndex.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4338CA).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: const Color(0xFF4338CA),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Set Tracking Radius",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                          Text(
                            "Slide to select area radius",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),

              // Safe Zone style slider with floating badge
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    Obx(() {
                      final int index = selectedIndex.value;
                      final double alignX = -1.0 + (index / 5.0) * 2.0;
                      final radius = radiusOptions[index];

                      return AnimatedAlign(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment(alignX, 0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4338CA),
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4338CA)
                                    .withValues(alpha: 0.3),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Text(
                            formatRadius(radius),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                    Obx(() {
                      final double sliderValue = selectedIndex.value.toDouble();

                      return SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF4338CA),
                          inactiveTrackColor: Colors.grey.shade200,
                          thumbColor: Colors.white,
                          overlayColor:
                              const Color(0xFF4338CA).withValues(alpha: 0.1),
                          trackHeight: 3.h,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 9.r,
                            elevation: 2,
                          ),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0,
                          max: 5,
                          divisions: 5,
                          onChanged: (val) {
                            selectedIndex.value = val.round();
                          },
                        ),
                      );
                    }),
                    SizedBox(height: 4.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: radiusOptions.asMap().entries.map((e) {
                          return Obx(() {
                            final isActive = e.key == selectedIndex.value;
                            return Column(
                              children: [
                                Container(
                                  width: 1,
                                  height: 5.h,
                                  color: isActive
                                      ? const Color(0xFF4338CA)
                                      : Colors.grey.shade400,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  formatRadius(e.value),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: isActive
                                        ? const Color(0xFF4338CA)
                                        : Colors.grey.shade600,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          });
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // Safe Zone style InnerCard (Selected Location & Radius)
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4338CA).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4338CA).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: const Color(0xFF4338CA),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selected Location",
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(
                            () => Text(
                              controller.currentLocationName.value.isNotEmpty
                                  ? controller.currentLocationName.value
                                  : "Current Location",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 30.h,
                      width: 1,
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                      color: Colors.grey.shade300,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Radius",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Obx(() {
                          final radius = radiusOptions[selectedIndex.value];
                          return Text(
                            formatRadius(radius),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4338CA),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final double selectedMeters =
                            radiusOptions[selectedIndex.value];
                        final double inKm = selectedMeters / 1000.0;
                        final String kmString =
                            inKm == inKm.toInt() ? "${inKm.toInt()}" : "$inKm";
                        controller.updateRadius(kmString);
                        Get.back();
                      },
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4338CA),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4338CA)
                                  .withValues(alpha: 0.25),
                              blurRadius: 8.r,
                              offset: Offset(0, 3.h),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Apply Radius",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildLiveMembersPill() {
    return GestureDetector(
      onTap: controller.fitAllMembers,
      child: Obx(() {
        final bool isGroup = controller.isGroupMode.value;
        final int count = isGroup
            ? controller.groupModeUsers.length
            : controller.liveMembers.length;
        final String groupName = controller.selectedGroupName.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isGroup
                  ? const Color(0xFF4338CA).withValues(alpha: 0.35)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: isGroup
                    ? const Color(0xFF4338CA).withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isGroup ? Icons.groups_rounded : Icons.person_rounded,
                size: 18.sp,
                color: const Color(0xFF4338CA),
              ),
              SizedBox(width: 6.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGroup
                        ? "$count Member${count == 1 ? '' : 's'}"
                        : "$count Members Live",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  if (isGroup && groupName.isNotEmpty)
                    Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4338CA),
                      ),
                    ),
                ],
              ),
              Container(
                height: 16.h,
                width: 1.w,
                color: const Color(0xFFE2E8F0),
                margin: EdgeInsets.symmetric(horizontal: 10.w),
              ),
              Icon(
                isGroup ? Icons.my_location_rounded : Icons.bar_chart_rounded,
                size: 18.sp,
                color: const Color(0xFF4338CA),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      alignment: Alignment.center,
      child: Container(
        width: 44.w,
        height: 4.5.h,
        decoration: BoxDecoration(
          color: const Color(0xFF94A3B8).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(3.r),
        ),
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
              onTap: () {
                controller.selectTab(0);
                if (_sheetController.isAttached && _sheetExtent.value < 0.30) {
                  _sheetController.animateTo(
                    0.52,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
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
              onTap: () {
                controller.selectTab(1);
                if (_sheetController.isAttached && _sheetExtent.value < 0.30) {
                  _sheetController.animateTo(
                    0.52,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
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
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // _buildSearchBox("Search by name or group..."),
          // SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Live Members",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4338CA).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Obx(
                      () => Text(
                        "${controller.liveMembers.length} Live",
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4338CA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                final bool loading = controller.isLoading.value;
                return GestureDetector(
                  onTap:
                      loading ? null : () => controller.getUsersWithinRadius(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF4338CA).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        loading
                            ? SizedBox(
                                width: 12.sp,
                                height: 12.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF4338CA),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                size: 14.sp,
                                color: const Color(0xFF4338CA),
                              ),
                        SizedBox(width: 4.w),
                        Text(
                          loading ? "Refreshing..." : "Refresh",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4338CA),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final query = controller.searchQuery.value.trim().toLowerCase();
            final List<MemberModel> sourceList =
                controller.allFetchedMembers.isNotEmpty
                    ? controller.allFetchedMembers.toList()
                    : controller.liveMembers.toList();
            final List<MemberModel> membersToDisplay = query.isEmpty
                ? sourceList
                : sourceList
                    .where((m) =>
                        m.name.toLowerCase().contains(query) ||
                        m.team.toLowerCase().contains(query) ||
                        m.location.toLowerCase().contains(query))
                    .toList();

            if (controller.isLoading.value) {
              return Skeletonizer(
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
              );
            } else if (membersToDisplay.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sensors_off_rounded,
                          color: const Color(0xFF94A3B8),
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        controller.searchQuery.value.trim().isNotEmpty
                            ? "No members match '${controller.searchQuery.value}'"
                            : "No active members found within ${controller.currentFormattedRadius}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (controller.responseError.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Text(
                            controller.responseError.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFEF4444),
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      SizedBox(height: 14.h),
                      GestureDetector(
                        onTap: () => controller.getUsersWithinRadius(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4338CA),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4338CA)
                                    .withValues(alpha: 0.2),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded,
                                  color: Colors.white, size: 16.sp),
                              SizedBox(width: 6.w),
                              Text(
                                "Refresh Live Data",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: membersToDisplay.map((m) => _memberCard(m)).toList(),
              );
            }
          }),
          SizedBox(height: 6.h),
          _buildBottomShareButton(),
          SizedBox(height: 24.h),
        ]),
      ),
    );
  }

  Widget _buildGroupSliverContent() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // _buildSearchBox("Search groups..."),
          // SizedBox(height: 12.h),
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
              Obx(() => Skeletonizer(
                    enabled: controller.isGroupLoading.value,
                    child: Text(
                      "${controller.filteredGroups.length} Groups",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4338CA),
                      ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final bool isGroupLoading = controller.isGroupLoading.value;
            if (isGroupLoading && controller.filteredGroups.isEmpty) {
              return Skeletonizer(
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
              );
            } else if (controller.filteredGroups.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Center(
                  child: Text(
                    controller.searchQuery.value.trim().isNotEmpty
                        ? "No groups match '${controller.searchQuery.value}'"
                        : (controller.groupError.isNotEmpty
                            ? controller.groupError.value
                            : "No groups found"),
                    style: TextStyle(
                      color: AppColors.primaryThreeElementText,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: controller.filteredGroups
                    .map((g) => _groupCard(g))
                    .toList(),
              );
            }
          }),
          SizedBox(height: 24.h),
        ]),
      ),
    );
  }

  // Widget _buildSearchBox(String hint) {
  //   return Container(
  //     height: 42.h,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF1F5F9),
  //       borderRadius: BorderRadius.circular(12.r),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //     ),
  //     alignment: Alignment.center,
  //     child: TextField(
  //       controller: controller.searchController,
  //       onChanged: (val) {
  //         controller.onSearch(val);
  //         controller.isSearchDropdownOpen.value = false;
  //       },
  //       textInputAction: TextInputAction.search,
  //       onSubmitted: (val) {
  //         controller.submitSearch(val);
  //         FocusManager.instance.primaryFocus?.unfocus();
  //       },
  //       style: TextStyle(
  //         fontSize: 13.sp,
  //         color: const Color(0xFF1E1B4B),
  //         fontWeight: FontWeight.w500,
  //       ),
  //       decoration: InputDecoration(
  //         isDense: true,
  //         prefixIcon: Icon(
  //           Icons.search_rounded,
  //           color: const Color(0xFF4338CA),
  //           size: 20.sp,
  //         ),
  //         prefixIconConstraints: BoxConstraints(minWidth: 38.w),
  //         suffixIcon: ValueListenableBuilder<TextEditingValue>(
  //           valueListenable: controller.searchController,
  //           builder: (context, value, child) {
  //             if (value.text.isNotEmpty) {
  //               return GestureDetector(
  //                 onTap: () {
  //                   controller.searchController.clear();
  //                   controller.searchQuery.value = "";
  //                   controller.isSearchDropdownOpen.value = false;
  //                   controller.onSearch('');
  //                   FocusManager.instance.primaryFocus?.unfocus();
  //                 },
  //                 child: Padding(
  //                   padding: EdgeInsets.symmetric(horizontal: 10.w),
  //                   child: Icon(
  //                     Icons.close_rounded,
  //                     color: const Color(0xFF94A3B8),
  //                     size: 18.sp,
  //                   ),
  //                 ),
  //               );
  //             }
  //             return const SizedBox.shrink();
  //           },
  //         ),
  //         suffixIconConstraints: BoxConstraints(minWidth: 36.w),
  //         hintText: hint,
  //         hintStyle: TextStyle(
  //           color: const Color(0xFF94A3B8),
  //           fontSize: 12.sp,
  //         ),
  //         border: InputBorder.none,
  //         contentPadding: EdgeInsets.symmetric(vertical: 10.h),
  //       ),
  //     ),
  //   );
  // }

  void _zoomToMemberFromList(MemberModel member) {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.11,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
    controller.zoomToMember(member);
  }

  Widget _memberCard(MemberModel member) {
    return GestureDetector(
      onTap: () => _zoomToMemberFromList(member),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2046).withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => controller.showMemberProfileFromMemberModel(member),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        width: 1.5.w,
                      ),
                    ),
                    child: ClipOval(
                      child: member.avatarUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: member.avatarUrl,
                              width: 44.w,
                              height: 44.w,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 44.w,
                                height: 44.w,
                                color: AppColors.primaryElementLight,
                                child: const Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4338CA),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
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
                        color: member.isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
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
                          (member.location.isNotEmpty &&
                                  member.location != "Location unavailable" &&
                                  member.location != "Location" &&
                                  member.location != "Locating...")
                              ? member.location
                              : (member.latitude != null &&
                                      member.longitude != null &&
                                      member.latitude != 0.0 &&
                                      member.longitude != 0.0
                                  ? "${member.latitude!.toStringAsFixed(4)}, ${member.longitude!.toStringAsFixed(4)}"
                                  : "Location unavailable"),
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
            Builder(
              builder: (context) {
                final int? batteryVal = member.battery;
                Color batteryColor;
                if (batteryVal == null) {
                  batteryColor = const Color(0xFF94A3B8);
                } else if (batteryVal > 50) {
                  batteryColor = const Color(0xFF10B981);
                } else if (batteryVal >= 20) {
                  batteryColor = const Color(0xFFF59E0B);
                } else {
                  batteryColor = const Color(0xFFEF4444);
                }

                return Column(
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
                          _getBatteryIcon(batteryVal ?? 100),
                          color: batteryColor,
                          size: 14.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          batteryVal != null ? "$batteryVal%" : "--%",
                          style: TextStyle(
                            color: batteryColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () => _zoomToMemberFromList(member),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                    color: Colors.black.withValues(alpha: 0.06),
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
    final String gIdStr = (group.id ?? 0).toString();
    final String? profileUrl =
        group.groupProfile != null && group.groupProfile!.isNotEmpty
            ? (group.groupProfile!.startsWith("http")
                ? group.groupProfile!
                : "${ConstRes.aImageBaseUrl}${group.groupProfile}")
            : null;

    return Obx(() {
      final bool isExpanded = controller.expandedGroupId.value == gIdStr;
      final List<LocationData> members =
          controller.groupMembersMap[gIdStr] ?? [];
      final bool isMembersLoading = controller.isGroupMembersLoading.value &&
          controller.expandedGroupId.value == gIdStr;

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFF4338CA).withValues(alpha: 0.35)
                : const Color(0xFFF1F5F9),
            width: isExpanded ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? const Color(0xFF4338CA).withValues(alpha: 0.08)
                  : const Color(0xFF1E2046).withValues(alpha: 0.02),
              blurRadius: isExpanded ? 12.r : 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Group Card Header (Tappable to toggle dropdown) ──
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final int gId = group.id is int
                    ? (group.id as int)
                    : (int.tryParse(group.id?.toString() ?? '0') ?? 0);

                if (isExpanded) {
                  controller.expandedGroupId.value = "";
                } else {
                  controller.expandedGroupId.value = gIdStr;
                  controller.selectGroup(group);
                  controller.fetchGroupLocationData(gIdStr);

                  // Keep sheet expanded so the dropdown members list is visible!
                  if (_sheetController.isAttached &&
                      _sheetExtent.value < 0.52) {
                    _sheetController.animateTo(
                      0.52,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    );
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.all(12.w),
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
                            (group.groupDesc != null &&
                                    group.groupDesc!.isNotEmpty)
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
                        // Member count badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryElementLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people,
                                  size: 11.sp,
                                  color: AppColors.primaryElement),
                              SizedBox(width: 3.w),
                              Text(
                                "${group.memberCount ?? members.length}",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryElement,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Commented out Memberscreen navigation & forward arrow as requested ──
                        // GestureDetector(
                        //   onTap: () {
                        //     Get.toNamed(
                        //       Routes.Memberscreen,
                        //       arguments: {
                        //         "groupId": group.id?.toString() ?? "",
                        //         "groupName": group.groupName ?? "",
                        //         "groupCode": group.groupCode ?? "",
                        //         "isCreator": group.isCreator?.toString() ?? "false",
                        //         "isActive": group.isActive?.toString() ?? "false",
                        //       },
                        //     )?.then((value) {
                        //       if (value == true) {
                        //         controller.fetchGroupData();
                        //       }
                        //     });
                        //   },
                        //   child: Container(
                        //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        //     decoration: BoxDecoration(
                        //       color: AppColors.primaryElementLight,
                        //       borderRadius: BorderRadius.circular(10.r),
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(Icons.people, size: 11.sp, color: AppColors.primaryElement),
                        //         SizedBox(width: 3.w),
                        //         Text("${group.memberCount ?? 0}"),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 4.h),
                        // Icon(
                        //   Icons.arrow_forward_ios_rounded,
                        //   size: 13.sp,
                        //   color: AppColors.primaryThreeElementText,
                        // ),
                        SizedBox(height: 4.h),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20.sp,
                            color: isExpanded
                                ? const Color(0xFF4338CA)
                                : AppColors.primaryThreeElementText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Group Members Dropdown List ──
            if (isExpanded)
              _buildGroupMembersDropdown(
                  group, members, isMembersLoading),
          ],
        ),
      );
    });
  }

  Widget _buildGroupMembersDropdown(
    GroupsResData group,
    List<LocationData> members,
    bool isLoading,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            color: const Color(0xFFE2E8F0),
            height: 1.h,
            thickness: 1,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 14.sp,
                    color: const Color(0xFF4338CA),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "Group Members",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                ],
              ),
              if (members.isNotEmpty)
                Text(
                  "${members.length} member${members.length == 1 ? '' : 's'}",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          if (isLoading && members.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                  ),
                ),
              ),
            )
          else if (members.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  "No members found in this group",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            Column(
              children: members
                  .map((m) => _buildGroupDropdownMemberItem(m, group))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupDropdownMemberItem(
    LocationData member,
    GroupsResData group,
  ) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
    final memberUserId = (member.userId ?? member.id ?? '').toString();
    final bool isMe =
        memberUserId.isNotEmpty && memberUserId == currentUserId;

    final bool isAdmin = member.isCreator == true ||
        member.isCreator == 1 ||
        member.isCreator == '1' ||
        member.role?.toString().toLowerCase() == 'admin';

    final bool isGhostMode = member.locationSharing == false ||
        member.locationSharing == 0 ||
        member.locationSharing == '0';

    final bool isOnline = !isGhostMode &&
        Tracking().isOnline(
          rawIsOnline: member.isOnline,
          lastSeen: member.lastSeen,
          thresholdMinutes: 5,
        );

    final String name = (member.name != null &&
            member.name.toString().trim().isNotEmpty &&
            member.name.toString().toLowerCase() != 'null')
        ? member.name.toString().trim()
        : 'Member';

    final String? rawImg = member.profileImage?.toString();
    final String? profileUrl = (rawImg != null &&
            rawImg.trim().isNotEmpty &&
            rawImg.toLowerCase() != 'null')
        ? (rawImg.startsWith('http://') || rawImg.startsWith('https://')
            ? rawImg
            : "${ConstRes.aImageBaseUrl}$rawImg")
        : null;

    String getLastSeenText() {
      if (isGhostMode) return "Ghost Mode Enabled";
      if (isOnline) return "Online";
      if (member.lastSeen == null ||
          member.lastSeen.toString().trim().isEmpty ||
          member.lastSeen.toString().toLowerCase() == 'null') {
        return "Offline";
      }

      final parsedDate = Tracking.parseDateTime(member.lastSeen);
      if (parsedDate == null) {
        final s = member.lastSeen.toString().trim();
        return s.toLowerCase() == 'offline' ? "Offline" : "Last seen: $s";
      }

      try {
        return "Last seen: ${Tracking().getTimeAgo(parsedDate)}";
      } catch (_) {
        return "Offline";
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.zoomToMember(member);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isGhostMode ? const Color(0xFFF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isGhostMode
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF4338CA).withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4.r,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with online status badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 19.r,
                  backgroundColor: const Color(0xFFEEF2FF),
                  backgroundImage:
                      profileUrl != null ? NetworkImage(profileUrl) : null,
                  child: profileUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: TextStyle(
                            color: const Color(0xFF4338CA),
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 9.5.w,
                    height: 9.5.w,
                    decoration: BoxDecoration(
                      color: isGhostMode
                          ? const Color(0xFF7E57C2)
                          : (isOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8)),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            // Name & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 5.w),
                        _memberBadge(
                          "You",
                          const Color(0xFFEEF2FF),
                          const Color(0xFF4338CA),
                        ),
                      ],
                      if (isAdmin) ...[
                        SizedBox(width: 5.w),
                        _memberBadge(
                          "Admin",
                          const Color(0xFFE7F8EC),
                          const Color(0xFF2BB673),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6.r,
                        color: isGhostMode
                            ? const Color(0xFF7E57C2)
                            : (isOnline
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8)),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          getLastSeenText(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: isGhostMode
                                ? const Color(0xFF7E57C2)
                                : (isOnline
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF64748B)),
                            fontWeight: isGhostMode || isOnline
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons (Chat, Call, Video Call) if not me
            if (!isMe) ...[
              _memberActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF4338CA),
                onTap: () {
                  if (Get.isRegistered<MessageController>()) {
                    Get.delete<MessageController>(force: true);
                  }
                  final MemberData memberData = MemberData(
                    id: int.tryParse(member.id?.toString() ?? ''),
                    userId: int.tryParse(memberUserId),
                    groupId: 0,
                    name: name,
                    profileImage: member.profileImage?.toString(),
                    lastSeen: member.lastSeen?.toString(),
                    isOnline: isOnline,
                    locationSharing: !isGhostMode,
                  );

                  Get.toNamed(
                    Routes.chatScreen,
                    arguments: {
                      "userData": memberData,
                      "groupName": name,
                      "isCreator": false,
                      "type": "chatScreen",
                      "chatType": "private",
                      "groupId": 0,
                    },
                  );
                },
              ),
              SizedBox(width: 6.w),
              _memberActionButton(
                icon: Icons.call_outlined,
                color: const Color(0xFF2BB673),
                onTap: () {
                  if (Get.isRegistered<CallingController>()) {
                    Get.delete<CallingController>(force: true);
                  }
                  Get.toNamed(
                    Routes.callScreen,
                    arguments: {
                      "callerId": currentUserId,
                      "remoteUserId": memberUserId,
                      "callerName": name,
                      "callerProfile":
                          member.profileImage?.toString() ?? "",
                      "offer": null,
                      "is_video": false,
                      "callType": "outGoing",
                    },
                  );
                },
              ),
              SizedBox(width: 6.w),
              _memberActionButton(
                icon: Icons.videocam_outlined,
                color: const Color(0xFFEF4444),
                onTap: () {
                  if (Get.isRegistered<CallingController>()) {
                    Get.delete<CallingController>(force: true);
                  }
                  Get.toNamed(
                    Routes.callScreen,
                    arguments: {
                      "callerId": currentUserId,
                      "remoteUserId": memberUserId,
                      "callerName": name,
                      "callerProfile":
                          member.profileImage?.toString() ?? "",
                      "offer": null,
                      "is_video": true,
                      "callType": "outGoing",
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _memberBadge(String label, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _memberActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 15.sp),
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
              color: Colors.black.withValues(alpha: 0.04),
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
    if (_isHelpDialogOpen) return;
    _isHelpDialogOpen = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tracking Help",
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 56.h, right: 16.w),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250.w,
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
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
        ).then((_) {
          _isHelpDialogOpen = false;
        });
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
    if (distance.isEmpty ||
        distance.toLowerCase().contains("nan") ||
        distance.trim() == "Nearby") {
      return "Nearby";
    }
    if (distance.contains("away")) return distance;
    if (distance.contains("km") || distance.contains(" m")) {
      return "$distance away";
    }
    final cleaned = distance.replaceAll(RegExp(r'[^\d.]'), '');
    final numVal = double.tryParse(cleaned);
    if (numVal != null) {
      return "${numVal.toStringAsFixed(1)} km away";
    }
    return distance;
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 75) return Icons.battery_6_bar_rounded;
    if (level >= 50) return Icons.battery_4_bar_rounded;
    if (level >= 20) return Icons.battery_2_bar_rounded;
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
