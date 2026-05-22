import 'dart:developer';
import 'dart:math' hide log;

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../Core/values/Dialog/DialogBox.dart';
import '../../../Core/values/colors.dart';
import '../../../Core/values/global.dart';
import '../../../Core/values/loading.dart';
import '../../../Data/Services/Tracking.dart';
import 'SocketServices.dart';
import 'LocationService.dart';
import '../Widget/Track_widget.dart';

class TrackingController extends GetxController {
  static TrackingController get instance => Get.put(TrackingController());

  final markers = <Marker>{}.obs;

  String? userId;

  Map<String, dynamic>? arguments = Get.arguments;

  final joinedGroupIds = <String>[].obs;

  final LocationService locationService = LocationService.instance;

  final SocketService socketService = SocketService.instance;

  GoogleMapController? mapController;

  final currentMapType = MapType.normal.obs;

  String darkMapStyle = "";

  bool isDarkMode = false;

  final groupWiseUserData = <String, List<LocationData>>{}.obs;

  final _markerPositions = <String, LatLng>{};

  final _activeAnimations = <String, bool>{};

  String? _alreadyListeningGroupId;

  Future<void> loadMapStyle() async {
    darkMapStyle = await rootBundle.loadString(
      'assets/map_theme/dark_map.json',
    );
  }

  Future<void> changeMapTheme(
    MapType type, {
    bool darkTheme = false,
  }) async {
    currentMapType.value = type;

    isDarkMode = darkTheme;

    if (mapController == null) return;

    if (darkTheme) {
      await mapController!.setMapStyle(
        darkMapStyle,
      );
    } else {
      await mapController!.setMapStyle(
        null,
      );
    }

    update();
  }

  void showMapThemeBottomSheet(BuildContext context) {
    final themes = [
      {
        'label': 'Light',
        'icon': Icons.light_mode_rounded,
        'onTap': () => changeMapTheme(MapType.normal),
        'selected': true,
      },
      {
        'label': 'Dark',
        'icon': Icons.dark_mode_rounded,
        'onTap': () => changeMapTheme(MapType.normal, darkTheme: true),
      },
      {
        'label': 'Satellite',
        'icon': Icons.satellite_alt_rounded,
        'onTap': () => changeMapTheme(MapType.satellite),
      },
      {
        'label': 'Terrain',
        'icon': Icons.terrain_rounded,
        'onTap': () => changeMapTheme(MapType.terrain),
      },
      {
        'label': 'Hybrid',
        'icon': Icons.map_rounded,
        'onTap': () => changeMapTheme(MapType.hybrid),
      },
    ];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Map Theme',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: themes.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final theme = themes[index];

                final bool isSelected = theme['selected'] == true;

                return GestureDetector(
                  onTap: () {
                    (theme['onTap'] as VoidCallback)();
                    Get.back();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 15.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xffF3EEFF)
                          : const Color(0xffF7F7F7),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryDarkblue
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primaryDarkblue
                                : Colors.white,
                          ),
                          child: Icon(
                            theme['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.black87,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 18.w),
                        Expanded(
                          child: Text(
                            theme['label'] as String,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryDarkblue,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> initSocketConnection() async {
    userId = Global.storageServices.get(PrefConst.userId).toString();

    await socketService.init(
      ConstRes.socketUrl,
    );
  }

  void initializeLocation() {
    locationService.initLocationTracking();
  }

  void inItAllGroups({
    List<GroupsResData>? groups,
  }) {
    initSocketConnection();

    for (var group in groups!) {
      if (group.isActive == true) {
        joinedGroupIds.add(
          group.id.toString(),
        );

        socketService.joinGroup(
          groupId: group.id.toString(),
          userId: userId!,
        );
      }
    }

    socketService.onUserLeft(
      (userId) => removeUserMarker(userId),
    );

    socketService.onGroupDeleted(
      (groupId) => deleteGroupMarker(groupId),
    );

    socketService.onUserOffline(
      (userId) => updateOfflineMarker(userId),
    );

    initializeLocation();
  }

  void initGroupTracking(String groupId) {
    if (!groupWiseUserData.containsKey(groupId)) {
      groupWiseUserData[groupId] = [];
    }

    _initSocketTracking(groupId);

    _loadInitialMarkers(groupId);
  }

  Future<void> getGroupLocationData(
    BuildContext context,
    int groupId,
  ) async {
    try {
      Loading().showloading(
        context: context,
      );

      var result = await TrackRepo.getUserLocationData(
        groupId,
      );

      if (result.status == true) {
        Loading().dismissloading(
          context: context,
        );

        for (var data in result.locations!) {
          updateGroupMarker(data);
        }
      } else {
        Loading().dismissloading(
          context: context,
        );

        CommonDialog.errorMessage(
          result.message,
        );
      }
    } catch (e) {
      Loading().dismissloading(
        context: context,
      );

      CommonDialog.errorMessage(
        e.toString(),
      );
    }
  }

  void deleteGroupMarker(String groupId) {
    groupWiseUserData.remove(groupId);

    markers.removeWhere(
      (marker) {
        return groupWiseUserData[groupId]?.any(
              (user) => user.userId.toString() == marker.markerId.value,
            ) ??
            false;
      },
    );

    joinedGroupIds.remove(groupId);

    markers.refresh();
  }

  void updateOfflineMarker(String userId) {
    log("📴 User went offline: $userId");
  }

  void exitGroup({
    required String groupId,
    Function(bool)? onCompletion,
  }) {
    if (userId != null) {
      socketService.leaveGroup(
        groupId: groupId,
        userId: userId!,
      );

      joinedGroupIds.remove(groupId);

      onCompletion?.call(true);
    }
  }

  void deleteGroup({
    required String groupId,
    Function(bool)? onCompletion,
  }) {
    socketService.deleteGroup(
      groupId: groupId,
    );

    joinedGroupIds.remove(groupId);

    onCompletion?.call(true);
  }

  Future<void> clearSearchZoomOut() async {
    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.zoomTo(11.0),
      );
    }
  }

  Future<void> searchUserAndZoom(
    String groupId,
    String userId,
  ) async {
    int retries = 0;

    while (markers.isEmpty && retries < 30) {
      await Future.delayed(
        const Duration(
          milliseconds: 100,
        ),
      );

      retries++;
    }

    final matchedMarker = markers.toList().firstWhereOrNull(
          (m) => m.markerId.value == userId,
        );

    if (matchedMarker != null && mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          matchedMarker.position,
          18.5,
        ),
      );
    } else {
      Get.snackbar(
        "User Not Found",
        "No user with id '$userId' found.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // Future<void> searchAndFocusUser(String groupId, String name) async {
  //   final users = groupWiseUserData[groupId] ?? [];
  //   final user = users
  //       .firstWhereOrNull((u) => u.name.toLowerCase() == name.toLowerCase());
  //
  //   if (user != null && mapController != null) {
  //     await mapController!.animateCamera(
  //       CameraUpdate.newLatLngZoom(
  //           LatLng(user.latitude!, user.longitude!), 22.5),
  //     );
  //   } else {
  //     Get.snackbar("User Not Found", "No user with name '$name' found.",
  //         backgroundColor: Colors.redAccent, colorText: Colors.white);
  //   }
  // }
  void removeUserMarker(String userId) {
    markers.removeWhere(
      (m) => m.markerId.value == userId,
    );

    _markerPositions.remove(userId);

    _activeAnimations[userId] = false;

    markers.refresh();
  }

  void showMarkersForGroup(String groupId) {
    markers.clear();

    final users = groupWiseUserData[groupId] ?? [];

    for (var user in users) {
      updateGroupMarker(user);
    }
  }

  void _initSocketTracking(String groupId) {
    if (_alreadyListeningGroupId == groupId) return;

    _alreadyListeningGroupId = groupId;

    socketService.onGroupLocationUpdateOff();

    socketService.onGroupLocationUpdate(
      (data) {
        if (data["groupId"].toString() == groupId) {
          final location = LocationData.fromJson(
            data,
          );

          updateGroupMarker(location);
        }
      },
    );
  }

  void _loadInitialMarkers(String groupId) {
    markers.clear();

    final users = groupWiseUserData[groupId] ?? [];

    for (var user in users) {
      updateGroupMarker(user);
    }
  }

  Future<void> _animateMarkerTo({
    required String markerId,
    required LatLng from,
    required LatLng to,
    required Marker Function(
      LatLng position,
    ) markerBuilder,
    int steps = 40,
    Duration duration = const Duration(
      milliseconds: 900,
    ),
  }) async {
    _activeAnimations[markerId] = false;

    await Future.delayed(
      const Duration(milliseconds: 16),
    );

    _activeAnimations[markerId] = true;

    final stepDuration = Duration(
      microseconds: duration.inMicroseconds ~/ steps,
    );

    for (int i = 1; i <= steps; i++) {
      if (_activeAnimations[markerId] != true) return;

      final t = i / steps;

      final easedT = t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

      final interpolated = LatLng(
        from.latitude + (to.latitude - from.latitude) * easedT,
        from.longitude + (to.longitude - from.longitude) * easedT,
      );

      markers.removeWhere(
        (m) => m.markerId.value == markerId,
      );

      markers.add(
        markerBuilder(interpolated),
      );

      markers.refresh();

      await Future.delayed(
        stepDuration,
      );
    }

    _markerPositions[markerId] = to;

    _activeAnimations[markerId] = false;
  }

  Future<void> updateGroupMarker(LocationData data) async {
    final groupId = data.groupId.toString();

    final profileImageUrl = data.profileImage?.toString() ?? '';

    bool isOnline = (data.isOnline == true) ||
        (data.lastSeen != null &&
            Tracking()
                    .getTimeAgo(
                      DateTime.parse(
                        data.lastSeen!,
                      ),
                    )
                    .toLowerCase() ==
                "just now");

    final groupList = groupWiseUserData[groupId] ?? [];

    groupList.removeWhere(
      (u) => u.userId.toString() == data.userId.toString(),
    );

    groupList.add(data);

    groupWiseUserData[groupId] = groupList;

    try {
      if (profileImageUrl.isNotEmpty) {
        await precacheImage(
          NetworkImage(
            ConstRes.aImageBaseUrl + profileImageUrl,
          ),
          Get.context!,
        );
      }
    } catch (e) {
      log(
        "❌ Failed to preload image: $e",
      );
    }

    final icon = await getCustomIcon(
      profileImageUrl,
      isOnline,
    );

    final newPosition = LatLng(
      data.latitude!,
      data.longitude!,
    );

    final oldPosition = _markerPositions[data.userId.toString()] ?? newPosition;

    Marker markerBuilder(LatLng position) => Marker(
          markerId: MarkerId(
            data.userId.toString(),
          ),
          position: position,
          icon: icon,
          onTap: () async {
            final dest = LatLng(
              data.latitude!,
              data.longitude!,
            );

            double distanceKm = 0.0;

            if (locationService.currentPosition != null) {
              final origin = LatLng(
                locationService.currentPosition!.latitude!,
                locationService.currentPosition!.longitude!,
              );

              distanceKm = _calculateDistance(
                origin.latitude,
                origin.longitude,
                dest.latitude,
                dest.longitude,
              );
            }

            DialogBox().showRouteDetailsBottomSheet(
              destination: dest,
              distance: distanceKm,
              name: data.name,
              imageUrl: profileImageUrl,
              lastSeen: Tracking().getTimeAgo(
                DateTime.parse(
                  data.lastSeen!,
                ),
              ),
              userId: int.tryParse(
                data.userId.toString(),
              ),
              groupId: int.tryParse(
                data.groupId.toString(),
              ),
              id: int.tryParse(
                data.id.toString(),
              ),
              status: data.isOnline,
            );
          },
        );

    if (oldPosition == newPosition) {
      markers.removeWhere(
        (m) => m.markerId.value == data.userId.toString(),
      );

      markers.add(
        markerBuilder(newPosition),
      );

      markers.refresh();

      _markerPositions[data.userId.toString()] = newPosition;
    } else {
      _animateMarkerTo(
        markerId: data.userId.toString(),
        from: oldPosition,
        to: newPosition,
        markerBuilder: markerBuilder,
      );
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371;

    final dLat = (lat2 - lat1) * (pi / 180);

    final dLon = (lon2 - lon1) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R *
        2 *
        atan2(
          sqrt(a),
          sqrt(1 - a),
        );
  }

  void clearMapMarkers() {
    markers.clear();

    update();
  }
}
