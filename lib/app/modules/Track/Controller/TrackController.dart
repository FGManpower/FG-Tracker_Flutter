import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:math' hide log;
import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/modules/Track/Controller/LocationService.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackLiveLocationSocketService.dart';
import 'package:fgtracker/app/modules/Track/Widget/Track_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingController extends GetxController {
  static const String _clusterManagerId = 'users_cluster';
  static TrackingController get instance => Get.put(TrackingController());

  final markers = <Marker>{}.obs;

  String? userId;

  Map<String, dynamic>? arguments = Get.arguments;

  final joinedGroupIds = <String>[].obs;
  final RxBool isLocationSharing = true.obs;
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

  Future<void> changeMapTheme(
    MapType type, {
    bool darkTheme = false,
  }) async {
    currentMapType.value = type;

    isDarkMode = darkTheme;

    if (mapController == null) return;

    if (darkTheme) {
      await mapController!.setMapStyle(darkMapStyle);
    } else {
      await mapController!.setMapStyle(null);
    }

    update();
  }

  void clearMapMarkers() {
    markers.clear();
    update();
  }

  Future<void> clearSearchZoomOut() async {
    if (mapController != null) {
      await mapController!.animateCamera(CameraUpdate.zoomTo(11.0));
    }
  }

  void deleteGroup({
    required String groupId,
    Function(bool)? onCompletion,
  }) {
    socketService.deleteGroup(groupId: groupId);
    joinedGroupIds.remove(groupId);
    onCompletion?.call(true);
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

  void exitGroup({
    required String groupId,
    Function(bool)? onCompletion,
  }) {
    if (userId != null) {
      socketService.leaveGroup(groupId: groupId, userId: userId!);
      joinedGroupIds.remove(groupId);
      onCompletion?.call(true);
    }
  }

  Future getGroupLocationData(
    BuildContext context,
    int groupId,
  ) async {
    try {
      Loading().showloading(context: context);

      var result = await TrackRepo.getUserLocationData(groupId);

      if (result.status == true) {
        Loading().dismissloading(context: context);

        print("========== GROUP MEMBERS ==========");
        print(
            "Current User Id : ${Global.storageServices.get(PrefConst.userId)}");
        print("Total Members : ${result.locations?.length}");

        if (result.locations != null && result.locations!.isNotEmpty) {
          for (var data in result.locations!) {
            print("--------------------------------");
            print("UserId           : ${data.userId}");
            print("Name             : ${data.name}");
            print("Location Sharing : ${data.locationSharing}");
            print("Latitude         : ${data.latitude}");
            print("Longitude        : ${data.longitude}");
            print("Last Seen        : ${data.lastSeen}");
            print("--------------------------------");

            updateGroupMarker(data);
          }
        }

        print("==================================");
      } else {
        Loading().dismissloading(context: context);
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading(context: context);
      print(e);
      CommonDialog.errorMessage(e.toString());
    }
  }

  void inItAllGroups({
    List<GroupsResData>? groups,
  }) {
    initSocketConnection();

    for (var group in groups!) {
      if (group.isActive == true) {
        joinedGroupIds.add(group.id.toString());

        socketService.joinGroup(
          groupId: group.id.toString(),
          userId: userId!,
        );
      }
    }

    socketService.onUserLeft((userId) => removeUserMarker(userId));
    socketService.onGroupDeleted((groupId) => deleteGroupMarker(groupId));
    socketService.onUserOffline((userId) => updateOfflineMarker(userId));

    initializeLocation();
  }

  void initGroupTracking(String groupId) {
    if (!groupWiseUserData.containsKey(groupId)) {
      groupWiseUserData[groupId] = [];
    }

    _initSocketTracking(groupId);
    _loadInitialMarkers(groupId);
  }

  void initializeLocation() {
    locationService.initLocationTracking();
  }

  Future<void> initSocketConnection() async {
    userId = Global.storageServices.get(PrefConst.userId).toString();

    await socketService.init(ConstRes.socketUrl);
  }

  Future<void> loadMapStyle() async {
    darkMapStyle = await rootBundle.loadString(
      'assets/map_theme/dark_map.json',
    );
  }

  Future<void> onClusterTap(Cluster cluster) async {
    final clusterUserIds = cluster.markerIds.map((id) => id.value).toSet();

    final List<LocationData> clusterUsers = [];
    for (final group in groupWiseUserData.values) {
      for (final user in group) {
        if (clusterUserIds.contains(user.userId.toString())) {
          final alreadyAdded = clusterUsers.any(
            (u) => u.userId.toString() == user.userId.toString(),
          );
          if (!alreadyAdded) clusterUsers.add(user);
        }
      }
    }

    _showClusterMembersSheet(clusterUsers);
  }

  @override
  void onInit() {
    super.onInit();
    isLocationSharing.value =
        Global.storageServices.getBoolSync(PrefConst.locationSharing) ?? true;
  }

  void removeUserMarker(String userId) {
    markers.removeWhere((m) => m.markerId.value == userId);
    _markerPositions.remove(userId);
    _activeAnimations[userId] = false;
    markers.refresh();
  }

  Future<void> searchUserAndZoom(
    String groupId,
    String userId, {
    bool showProfile = false,
  }) async {
    int retries = 0;

    while (markers.isEmpty && retries < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
    }

    final matchedMarker = markers.toList().firstWhereOrNull(
          (m) => m.markerId.value == userId,
        );

    if (matchedMarker != null && mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(matchedMarker.position, 18.0),
      );
      if (showProfile) {
        LocationData? user;
        final list = groupWiseUserData[groupId] ?? [];
        for (final u in list) {
          if (u.userId.toString() == userId) {
            user = u;
            break;
          }
        }
        if (user == null) {
          for (final g in groupWiseUserData.values) {
            for (final u in g) {
              if (u.userId.toString() == userId) {
                user = u;
                break;
              }
            }
            if (user != null) break;
          }
        }
        if (user != null) {
          showMemberProfileBottomSheet(user);
        }
      }
    } else {
      Get.snackbar(
        "User Not Found",
        "No user with id '$userId' found.",
        backgroundColor: AppColors.darkRed,
        colorText: AppColors.white,
      );
    }
  }

  void showMemberProfileBottomSheet(LocationData user) {
    final currentPos = locationService.currentPosition;
    double distance = 0.0;
    if (currentPos != null &&
        user.latitude != null &&
        user.longitude != null &&
        user.latitude != 0.0 &&
        user.longitude != 0.0) {
      distance = _calculateDistance(
        currentPos.latitude!,
        currentPos.longitude!,
        user.latitude!,
        user.longitude!,
      );
    }

    final bool isOnline = Tracking().isOnline(
      rawIsOnline: user.isOnline,
      lastSeen: user.lastSeen,
      thresholdMinutes: 5,
    );

    final int? effectiveGroupId = user.groupId ??
        (arguments != null && arguments!['groupId'] != null
            ? int.tryParse(arguments!['groupId'].toString())
            : null);
    final String? effectiveGroupName =
        arguments != null ? arguments!['groupName']?.toString() : null;

    final int? effectiveUserId = user.userId != null
        ? int.tryParse(user.userId.toString())
        : (user.id != null ? int.tryParse(user.id.toString()) : null);

    final int? effectiveId =
        user.id != null ? int.tryParse(user.id.toString()) : effectiveUserId;

    String? resolvedName = (user.name != null &&
            user.name.toString().trim().isNotEmpty &&
            user.name.toString().toLowerCase() != 'null')
        ? user.name.toString().trim()
        : null;

    final String? rawImg = user.profileImage?.toString();
    String? resolvedImg = (rawImg != null &&
            rawImg.trim().isNotEmpty &&
            rawImg.toLowerCase() != 'null')
        ? rawImg.trim()
        : null;

    String? resolvedPhone = user.mobileNo?.toString();

    // Cross-reference from groupWiseUserData or TrackController if name/image/phone missing
    final String uidStr = (effectiveUserId ?? effectiveId ?? '').toString();
    if (uidStr.isNotEmpty && (resolvedName == null || resolvedImg == null || resolvedPhone == null)) {
      for (final list in groupWiseUserData.values) {
        final m = list.firstWhereOrNull((u) => u.userId.toString() == uidStr);
        if (m != null) {
          if (resolvedName == null && m.name != null && m.name.toString().trim().isNotEmpty && m.name.toString().trim().toLowerCase() != 'member') {
            resolvedName = m.name.toString().trim();
          }
          if (resolvedImg == null && m.profileImage != null && m.profileImage.toString().trim().isNotEmpty && m.profileImage.toString().trim().toLowerCase() != 'null') {
            resolvedImg = m.profileImage.toString().trim();
          }
          resolvedPhone ??= m.mobileNo?.toString();
          break;
        }
      }

      if (Get.isRegistered<TrackController>()) {
        final tc = Get.find<TrackController>();
        final ru = tc.radiusUsers.firstWhereOrNull((u) => u.userId?.toString() == uidStr);
        if (ru != null) {
          if (resolvedName == null && ru.name != null && ru.name!.trim().isNotEmpty && ru.name!.trim().toLowerCase() != 'member') {
            resolvedName = ru.name!.trim();
          }
          if (resolvedImg == null && ru.profileImage != null && ru.profileImage!.trim().isNotEmpty && ru.profileImage!.trim().toLowerCase() != 'null') {
            resolvedImg = ru.profileImage!.trim();
          }
          resolvedPhone ??= ru.mobileNo;
        }

        final ogm = tc.onlineGroupMembers.firstWhereOrNull((m) => m.userId?.toString() == uidStr);
        if (ogm != null) {
          if (resolvedName == null && ogm.name != null && ogm.name!.trim().isNotEmpty && ogm.name!.trim().toLowerCase() != 'member') {
            resolvedName = ogm.name!.trim();
          }
          if (resolvedImg == null && ogm.profileImage != null && ogm.profileImage!.trim().isNotEmpty && ogm.profileImage!.trim().toLowerCase() != 'null') {
            resolvedImg = ogm.profileImage!.trim();
          }
          resolvedPhone ??= ogm.mobileNo;
        }

        final afm = tc.allFetchedMembers.firstWhereOrNull((m) => m.userId?.toString() == uidStr);
        if (afm != null) {
          if (resolvedName == null && afm.name.trim().isNotEmpty && afm.name.trim().toLowerCase() != 'member') {
            resolvedName = afm.name.trim();
          }
          if (resolvedImg == null && afm.avatarUrl.trim().isNotEmpty && afm.avatarUrl.trim().toLowerCase() != 'null') {
            resolvedImg = afm.avatarUrl.trim();
          }
        }
      }
    }

    DialogBox().showRouteDetailsBottomSheet(
      destination: LatLng(user.latitude ?? 0.0, user.longitude ?? 0.0),
      distance: distance,
      userId: effectiveUserId,
      groupId: effectiveGroupId,
      id: effectiveId,
      name: resolvedName,
      imageUrl: resolvedImg,
      status: isOnline,
      lastSeen: user.lastSeen?.toString(),
      groupName: effectiveGroupName,
      team: effectiveGroupName,
      phone: resolvedPhone,
      isGroupChat: true,
      isLocationSharing: user.locationSharing ?? true,
    );
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
          color: AppColors.white,
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
                color: AppColors.textbordercolor,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Map Theme',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
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
                          ? AppColors.blue.withOpacity(0.15)
                          : AppColors.primarySecondaryBackground,
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
                                : AppColors.white,
                          ),
                          child: Icon(
                            theme['icon'] as IconData,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.primaryText,
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
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryDarkblue,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.white,
                              size: 20,
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

  void showMarkersForGroup(String groupId) {
    markers.clear();
    final users = groupWiseUserData[groupId] ?? [];
    for (var user in users) {
      updateGroupMarker(user);
    }
  }

  Future<void> updateGroupMarker(LocationData data) async {
    print("========== UPDATE GROUP MARKER ==========");
    print("User : ${data.name}");
    print("UserId : ${data.userId}");
    print("LocationSharing : ${data.locationSharing}");
    print("LastSeen : ${data.lastSeen}");
    print("========================================");
    final groupId = data.groupId.toString();

    final bool isOnline = Tracking().isOnline(
      rawIsOnline: data.isOnline,
      lastSeen: data.lastSeen,
      thresholdMinutes: 5,
    );

    final groupList = groupWiseUserData[groupId] ?? [];

    // Preserve existing real data if incoming socket event lacks name/image/phone
    final existingUser = groupList.firstWhereOrNull(
      (u) => u.userId.toString() == data.userId.toString(),
    );

    if (existingUser != null) {
      if (data.name == null ||
          data.name.toString().trim().isEmpty ||
          data.name.toString().toLowerCase() == 'member') {
        data.name = existingUser.name;
      }
      if (data.profileImage == null ||
          data.profileImage.toString().trim().isEmpty ||
          data.profileImage.toString().toLowerCase() == 'null') {
        data.profileImage = existingUser.profileImage;
      }
      if (data.mobileNo == null || data.mobileNo.toString().trim().isEmpty) {
        data.mobileNo = existingUser.mobileNo;
      }
      if (data.role == null) {
        data.role = existingUser.role;
      }
    }

    // Also check TrackController if still missing
    if (data.name == null ||
        data.name.toString().trim().isEmpty ||
        data.name.toString().toLowerCase() == 'member' ||
        data.profileImage == null ||
        data.profileImage.toString().trim().isEmpty ||
        data.profileImage.toString().toLowerCase() == 'null') {
      if (Get.isRegistered<TrackController>()) {
        final tc = Get.find<TrackController>();
        final ogm = tc.onlineGroupMembers.firstWhereOrNull(
          (m) => m.userId?.toString() == data.userId.toString(),
        );
        if (ogm != null) {
          if (ogm.name != null && ogm.name!.trim().isNotEmpty && ogm.name!.trim().toLowerCase() != 'member') {
            data.name ??= ogm.name;
          }
          if (ogm.profileImage != null && ogm.profileImage!.trim().isNotEmpty && ogm.profileImage!.trim().toLowerCase() != 'null') {
            data.profileImage ??= ogm.profileImage;
          }
          if (ogm.mobileNo != null && ogm.mobileNo!.trim().isNotEmpty) {
            data.mobileNo ??= ogm.mobileNo;
          }
        }
        final ru = tc.radiusUsers.firstWhereOrNull(
          (u) => u.userId?.toString() == data.userId.toString(),
        );
        if (ru != null) {
          if (ru.name != null && ru.name!.trim().isNotEmpty && ru.name!.trim().toLowerCase() != 'member') {
            data.name ??= ru.name;
          }
          if (ru.profileImage != null && ru.profileImage!.trim().isNotEmpty && ru.profileImage!.trim().toLowerCase() != 'null') {
            data.profileImage ??= ru.profileImage;
          }
          if (ru.mobileNo != null && ru.mobileNo!.trim().isNotEmpty) {
            data.mobileNo ??= ru.mobileNo;
          }
        }
        final afm = tc.allFetchedMembers.firstWhereOrNull(
          (m) => m.userId?.toString() == data.userId.toString(),
        );
        if (afm != null) {
          if (afm.name.trim().isNotEmpty && afm.name.trim().toLowerCase() != 'member') {
            data.name ??= afm.name;
          }
          if (afm.avatarUrl.trim().isNotEmpty && afm.avatarUrl.trim().toLowerCase() != 'null') {
            data.profileImage ??= afm.avatarUrl;
          }
        }
      }
    }

    groupList.removeWhere(
      (u) => u.userId.toString() == data.userId.toString(),
    );

    groupList.add(data);
    groupWiseUserData[groupId] = groupList;

    final String effectiveProfileImageUrl = data.profileImage?.toString() ?? '';
    final String effectiveName = data.name?.toString() ?? '';

    final newPosition = LatLng(data.latitude!, data.longitude!);
    final oldPosition = _markerPositions[data.userId.toString()] ?? newPosition;

    final icon = await getCustomIcon(
      effectiveProfileImageUrl,
      isOnline,
      name: effectiveName,
    );

    Marker markerBuilder(LatLng position) => Marker(
          markerId: MarkerId(data.userId.toString()),
          position: position,
          icon: icon,
          clusterManagerId: const ClusterManagerId(_clusterManagerId),
          onTap: () async {
            showMemberProfileBottomSheet(data);
          },
        );

    markers.removeWhere((m) => m.markerId.value == data.userId.toString());

    if (data.locationSharing == false) {
      markers.refresh();
      return;
    }

    markers.add(markerBuilder(newPosition));
    markers.refresh();
    _markerPositions[data.userId.toString()] = newPosition;

    final bool positionChanged = oldPosition.latitude != newPosition.latitude ||
        oldPosition.longitude != newPosition.longitude;

    if (positionChanged) {
      _animateMarkerTo(
        markerId: data.userId.toString(),
        from: oldPosition,
        to: newPosition,
        markerBuilder: markerBuilder,
      );
    }
  }

  void updateOfflineMarker(String userId) {
    log("📴 User went offline: $userId");
  }

  Future<void> _animateMarkerTo({
    required String markerId,
    required LatLng from,
    required LatLng to,
    required Marker Function(LatLng position) markerBuilder,
    int steps = 40,
    Duration duration = const Duration(milliseconds: 900),
  }) async {
    _activeAnimations[markerId] = false;

    await Future.delayed(const Duration(milliseconds: 16));

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

      markers.removeWhere((m) => m.markerId.value == markerId);
      markers.add(markerBuilder(interpolated));
      markers.refresh();

      await Future.delayed(stepDuration);
    }

    _markerPositions[markerId] = to;
    _activeAnimations[markerId] = false;
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
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  void _initSocketTracking(String groupId) {
    if (_alreadyListeningGroupId == groupId) return;

    _alreadyListeningGroupId = groupId;

    socketService.onGroupLocationUpdateOff();

    socketService.onGroupLocationUpdate(
      (data) {
        print("========== SOCKET ==========");
        print(data);
        print("===========================");
        if (data["groupId"].toString() == groupId) {
          final location = LocationData.fromJson(data);
          if (location.lastSeen == null ||
              location.lastSeen.toString().isEmpty) {
            location.lastSeen = DateTime.now().toIso8601String();
          }
          if (location.isOnline == null) {
            location.isOnline = true;
          }
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

  Future<void> loadLocationSharing() async {
    final value = await Global.storageServices.getBool(
      PrefConst.locationSharing,
    );

    isLocationSharing.value = value;
  }

  Future<void> toggleLocationSharing(bool value) async {
    final oldValue = isLocationSharing.value;

    isLocationSharing.value = value;

    try {
      final success = await TrackRepo.updateLocationSharing(value);

      if (success) {
        await Global.storageServices.setBool(
          PrefConst.locationSharing,
          value,
        );
      } else {
        isLocationSharing.value = oldValue;

        Get.snackbar(
          "Error",
          "Unable to update Ghost Mode",
        );
      }
    } catch (e) {
      isLocationSharing.value = oldValue;

      Get.snackbar(
        "Error",
        "Something went wrong",
      );
    }
  }

  void _showClusterMembersSheet(List<LocationData> users) {
    print("========== CLUSTER USERS ==========");
    print("Current User: ${Global.storageServices.get(PrefConst.userId)}");

    for (final u in users) {
      print("${u.userId} - ${u.name}");
    }

    print("==================================");
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textbordercolor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final imageUrl = user.profileImage?.toString() ?? '';
                  final bool isGhostMode = user.locationSharing == false;
                  final bool isOnline = Tracking().isOnline(
                    rawIsOnline: user.isOnline,
                    lastSeen: user.lastSeen,
                    thresholdMinutes: 5,
                  );

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Stack(
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            isGhostMode ? AppColors.grey : Colors.transparent,
                            isGhostMode ? BlendMode.saturation : BlendMode.dst,
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: isGhostMode
                                ? AppColors.textbordercolor
                                : AppColors.appGreybackgroundcolor,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(
                                    ConstRes.aImageBaseUrl + imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? const Icon(Icons.person,
                                    color: AppColors.grey)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isGhostMode
                                  ? AppColors.grey
                                  : (isOnline
                                      ? AppColors.primaryElementStatus
                                      : AppColors.darkRed),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name?.toString() ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isGhostMode
                                  ? AppColors.grey
                                  : AppColors.primaryText,
                            ),
                          ),
                        ),
                        if (isGhostMode)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySecondaryElementText,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "👻 Ghost",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      isGhostMode
                          ? "Ghost Mode Enabled"
                          : isOnline
                              ? "Online"
                              : user.lastSeen != null &&
                                      user.lastSeen.toString().isNotEmpty
                                  ? Tracking().getTimeAgo(
                                      Tracking.parseDateTime(user.lastSeen) ??
                                          DateTime.now(),
                                    )
                                  : "Offline",
                      style: TextStyle(
                        color: isGhostMode
                            ? AppColors.grey
                            : (isOnline
                                ? AppColors.primaryElementStatus
                                : AppColors.grey),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      if (isGhostMode) {
                        Get.snackbar(
                          "Ghost Mode",
                          "${user.name} is currently in Ghost Mode.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      Get.back();

                      await Future.delayed(const Duration(milliseconds: 350));

                      if (user.latitude != null && user.longitude != null) {
                        await mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(user.latitude!, user.longitude!),
                            18.0,
                          ),
                        );
                        showMemberProfileBottomSheet(user);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class GeocodedAddressResult {
  final String address;
  final String area;
  final String city;

  const GeocodedAddressResult({
    this.address = '',
    this.area = '',
    this.city = '',
  });

  bool get isEmpty => address.isEmpty && area.isEmpty && city.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class TrackController extends GetxController {
  RxString selectedRadius = '2'.obs;
  TextEditingController customRadiusController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;
  final RxBool isSearchDropdownOpen = false.obs;

  RxInt selectedTabIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxString responseError = "".obs;

  RxDouble currentLat = 0.0.obs;
  RxDouble currentLong = 0.0.obs;

  RxList<MemberModel> liveMembers = <MemberModel>[].obs;
  RxList<MemberModel> allFetchedMembers = <MemberModel>[].obs;
  RxList<MemberModel> get allGroupMembers => allFetchedMembers;
  RxList<UsersWithinRadiusData> radiusUsers = <UsersWithinRadiusData>[].obs;
  RxList<UserMemberData> onlineGroupMembers = <UserMemberData>[].obs;
  RxMap<String, List<LocationData>> get groupWiseUserData =>
      TrackingController.instance.groupWiseUserData;

  RxList<GroupsResData> groupList = <GroupsResData>[].obs;
  RxList<GroupsResData> filteredGroups = <GroupsResData>[].obs;
  RxBool isGroupLoading = true.obs;
  RxString groupError = "".obs;

  RxInt liveNowCount = 0.obs;
  RxInt totalMembersCount = 0.obs;

  // Location & Group Name Observables
  RxString currentLocationName = "Locating...".obs;
  RxString currentArea = "".obs;
  RxString currentCity = "".obs;
  RxString selectedGroupName = "".obs;
  RxString selectedGroupId = "".obs;

  // Google Map State
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  final Map<String, String> _addressCache = {};
  final Map<String, GeocodedAddressResult> _detailedAddressCache = {};
  final Map<String, LatLng> _knownUserCoordinates = {};

  StreamSubscription<List<LiveLocationModel>>? _socketLiveLocationSubscription;
  StreamSubscription<LiveLocationSocketModel>? _trackLiveSocketSubscription;
  StreamSubscription<UserStatusSocketModel>? _userStatusSocketSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<dynamic>? _groupCountSubscription;

  @override
  void onInit() {
    super.onInit();

    // 0. Ensure lists start clean so only /users-within-radius API populates live tracking
    radiusUsers.clear();
    liveMembers.clear();
    allFetchedMembers.clear();
    _markerIconCache.clear();

    // 1. Instant load user location from multiple sources
    _loadInitialLocation();

    // 2. Check arguments for group name if passed
    final args = Get.arguments;
    if (args is Map) {
      if (args['groupName'] != null &&
          args['groupName'].toString().isNotEmpty) {
        selectedGroupName.value = args['groupName'].toString();
      }
      if (args['groupId'] != null && args['groupId'].toString().isNotEmpty) {
        selectedGroupId.value = args['groupId'].toString();
      }
    }

    // 3. Immediately draw user marker so map opens with user located
    updateMapMarkersAndCircle();

    // 4. Initialize both sockets
    _initSockets();

    // 5. Fetch group list for Group tab, total members from API, and fetch users strictly from /users-within-radius
    fetchGroupData();
    fetchTotalMembers();
    getCurrentLocationAndFetchUsers();
    _startPositionListening();
  }

  Future<void> _loadInitialLocation() async {
    // A. Instant user location & live locations from HomeController
    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();

        if (home.groupCount.value.totalMembers > 0) {
          totalMembersCount.value = home.groupCount.value.totalMembers;
        }

        if (home.currentLocation.value != null) {
          currentLat.value = home.currentLocation.value!.latitude;
          currentLong.value = home.currentLocation.value!.longitude;
          debugPrint("📍 Instant location loaded from HomeController: ${currentLat.value}, ${currentLong.value}");
          reverseGeocodeLocation(currentLat.value, currentLong.value);
        }
      }
    } catch (e) {
      debugPrint("Could not read from HomeController: $e");
    }

    // B. Instant user location from LocationService singleton
    if (currentLat.value == 0.0 || currentLong.value == 0.0) {
      try {
        final loc = LocationService.instance.currentPosition;
        if (loc?.latitude != null && loc?.longitude != null) {
          currentLat.value = loc!.latitude!;
          currentLong.value = loc!.longitude!;
          debugPrint("📍 Instant location loaded from LocationService: ${currentLat.value}, ${currentLong.value}");
          reverseGeocodeLocation(currentLat.value, currentLong.value);
        }
      } catch (e) {
        debugPrint("Could not read from LocationService: $e");
      }
    }

    // C. Instant user location from persistent local storage
    if (currentLat.value == 0.0 || currentLong.value == 0.0) {
      try {
        final savedLat = Global.storageServices.getDouble('user_last_lat');
        final savedLng = Global.storageServices.getDouble('user_last_lng');
        if (savedLat != null && savedLng != null && savedLat != 0.0 && savedLng != 0.0) {
          currentLat.value = savedLat;
          currentLong.value = savedLng;
          debugPrint("📍 Instant location loaded from storage: ${currentLat.value}, ${currentLong.value}");
          reverseGeocodeLocation(currentLat.value, currentLong.value);
        }
      } catch (e) {
        debugPrint("Could not read from storage: $e");
      }
    }

    // Immediately update markers with whatever position we have
    updateMapMarkersAndCircle();

    // D. Ultra-fast check from device GPS hardware cache
    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _updateUserLocation(lastPos.latitude, lastPos.longitude);
      }
    } catch (_) {}
  }

  Future<void> _initSockets() async {
    // Dashboard socket (for group counts)
    SocketDashboardService.instance.init();
    _listenToGroupCounts();

    // Location socket & Live Location Socket Service
    try {
      await SocketService.instance.init(ConstRes.socketUrl);
      if (SocketService.instance.isSocketConnected) {
        TrackLiveLocationSocketService.instance
            .attachSocket(SocketService.instance.socket);
      } else {
        await TrackLiveLocationSocketService.instance
            .init(socketUrl: ConstRes.socketUrl);
      }
      _listenToLiveLocationSocket();
      _listenToUserStatusSocket();
      _listenToLocationSocketUpdates();
      if (selectedGroupId.value.isNotEmpty) {
        _joinGroupSocket(selectedGroupId.value);
      }
    } catch (e) {
      debugPrint("❌ SocketService init error: $e");
    }
  }

  void _listenToGroupCounts() {
    _groupCountSubscription?.cancel();
    _groupCountSubscription =
        SocketDashboardService.instance.groupCountStream.listen((data) {
      if (data != null) {
        try {
          final counts = GroupCountDetail.fromJson(data);
          if (counts.totalMembers > 0) {
            totalMembersCount.value = counts.totalMembers;
          }
        } catch (_) {}
      }
    });
    SocketDashboardService.instance.requestGroupCount();
  }

  Future<void> fetchTotalMembers() async {
    try {
      final res = await TrackRepo.getGroupMember(page: '1', filter: 'all');
      if (res.status == true) {
        if (res.pagination?.totalRecords != null &&
            res.pagination!.totalRecords! > 0) {
          totalMembersCount.value = res.pagination!.totalRecords!;
        }
        if (res.data?.allMember?.memberList != null) {
          for (var gm in res.data!.allMember!.memberList!) {
            final uid = gm.userId?.toString();
            if (uid != null &&
                gm.latitude != null &&
                gm.longitude != null &&
                gm.latitude != 0.0 &&
                gm.longitude != 0.0) {
              _knownUserCoordinates[uid] = LatLng(gm.latitude!, gm.longitude!);
            }
          }
        }
        return;
      }
    } catch (e) {
      debugPrint("Could not fetch total members count from API: $e");
    }

    try {
      final userRes = await GroupRepo.getAllUserData();
      if (userRes.status == true &&
          userRes.userData != null &&
          userRes.userData!.isNotEmpty) {
        totalMembersCount.value = userRes.userData!.length;
        return;
      }
    } catch (e) {
      debugPrint("Could not fetch total members from getAllUserData: $e");
    }

    if (selectedGroupId.value.isNotEmpty) {
      await fetchMembersForSelectedGroup(selectedGroupId.value);
    }
  }

  Future<void> fetchMembersForSelectedGroup(String groupId) async {
    try {
      final memberRes = await GroupRepo.getMemberData(groupId);
      if (memberRes.status == true &&
          memberRes.memberData != null &&
          memberRes.memberData!.isNotEmpty) {
        totalMembersCount.value = memberRes.memberData!.length;
      }
    } catch (_) {}
  }

  void _listenToSocketLiveLocations() {
    _socketLiveLocationSubscription?.cancel();
    _socketLiveLocationSubscription =
        SocketDashboardService.instance.liveLocationStream.listen((locations) {
      if (locations.isNotEmpty) {
        debugPrint("📡 Received ${locations.length} live locations from dashboard socket");
        _mergeSocketLocations(locations);
      }
    });
  }

  void _listenToLiveLocationSocket() {
    _trackLiveSocketSubscription?.cancel();
    _trackLiveSocketSubscription = TrackLiveLocationSocketService.instance
        .locationStream
        .listen((liveData) {
      _applyLiveSocketLocationUpdate(liveData);
    });
  }

  void _listenToUserStatusSocket() {
    _userStatusSocketSubscription?.cancel();
    _userStatusSocketSubscription = TrackLiveLocationSocketService.instance
        .userStatusStream
        .listen((status) {
      final idx = radiusUsers
          .indexWhere((u) => u.userId.toString() == status.userId);
      if (idx >= 0) {
        radiusUsers[idx].isOnline = status.isOnline;
      }
      final gIdx = onlineGroupMembers
          .indexWhere((u) => u.userId.toString() == status.userId);
      if (gIdx >= 0) {
        onlineGroupMembers[gIdx].isOnline = status.isOnline ? 1 : 0;
      }
      _refreshMembersAndMap();
    });
  }

  void _applyLiveSocketLocationUpdate(LiveLocationSocketModel data) {
    if (data.lat == 0.0 || data.lng == 0.0) return;

    final String userIdStr = data.userId.toString();
    final nowIso = DateTime.now().toIso8601String();

    String resolvedAddress = data.address;
    if (resolvedAddress.isEmpty) {
      if (data.area.isNotEmpty && data.city.isNotEmpty) {
        resolvedAddress = data.area.toLowerCase() == data.city.toLowerCase()
            ? data.city
            : '${data.area}, ${data.city}';
      } else if (data.area.isNotEmpty) {
        resolvedAddress = data.area;
      } else if (data.city.isNotEmpty) {
        resolvedAddress = data.city;
      }
    }

    final existingIdx =
        radiusUsers.indexWhere((u) => u.userId.toString() == userIdStr);
    if (existingIdx >= 0) {
      final prev = radiusUsers[existingIdx];
      prev.latitude = data.lat;
      prev.longitude = data.lng;
      prev.isOnline = true;
      prev.lastSeen = nowIso;
      if (data.name != null && data.name!.isNotEmpty) {
        prev.name = data.name;
      }
      if (data.profileImage != null && data.profileImage!.isNotEmpty) {
        prev.profileImage = data.profileImage;
      }
      if (resolvedAddress.isNotEmpty) {
        prev.location = resolvedAddress;
      }
      if (data.battery != null) {
        prev.battery = data.battery;
      }
      _resolveAddressForUser(prev);
    } else {
      String? fallbackName = (data.name != null && data.name!.trim().isNotEmpty && data.name!.trim().toLowerCase() != 'member')
          ? data.name!.trim()
          : null;
      String? fallbackImg = (data.profileImage != null && data.profileImage!.trim().isNotEmpty && data.profileImage!.trim().toLowerCase() != 'null')
          ? data.profileImage!.trim()
          : null;
      String? fallbackPhone;

      final matchedMember = onlineGroupMembers.firstWhereOrNull((m) => m.userId.toString() == userIdStr);
      if (matchedMember != null) {
        if (fallbackName == null && matchedMember.name != null && matchedMember.name!.trim().isNotEmpty && matchedMember.name!.trim().toLowerCase() != 'member') {
          fallbackName = matchedMember.name!.trim();
        }
        if (fallbackImg == null && matchedMember.profileImage != null && matchedMember.profileImage!.trim().isNotEmpty && matchedMember.profileImage!.trim().toLowerCase() != 'null') {
          fallbackImg = matchedMember.profileImage!.trim();
        }
        fallbackPhone ??= matchedMember.mobileNo;
      }

      final fetchedMember = allFetchedMembers.firstWhereOrNull((m) => m.userId.toString() == userIdStr);
      if (fetchedMember != null) {
        if (fallbackName == null && fetchedMember.name.trim().isNotEmpty && fetchedMember.name.trim().toLowerCase() != 'member') {
          fallbackName = fetchedMember.name.trim();
        }
        if (fallbackImg == null && fetchedMember.avatarUrl.trim().isNotEmpty && fetchedMember.avatarUrl.trim().toLowerCase() != 'null') {
          fallbackImg = fetchedMember.avatarUrl.trim();
        }
      }

      if (fallbackName == null || fallbackImg == null) {
        for (final list in TrackingController.instance.groupWiseUserData.values) {
          final m = list.firstWhereOrNull((u) => u.userId.toString() == userIdStr);
          if (m != null) {
            if (fallbackName == null && m.name != null && m.name.toString().trim().isNotEmpty) {
              fallbackName = m.name.toString().trim();
            }
            if (fallbackImg == null && m.profileImage != null && m.profileImage.toString().trim().isNotEmpty) {
              fallbackImg = m.profileImage.toString().trim();
            }
            fallbackPhone ??= m.mobileNo?.toString();
            break;
          }
        }
      }

      final newUser = UsersWithinRadiusData(
        userId: data.userId,
        name: fallbackName ?? "Member",
        profileImage: fallbackImg,
        mobileNo: fallbackPhone,
        latitude: data.lat,
        longitude: data.lng,
        isOnline: true,
        lastSeen: nowIso,
        team: selectedGroupName.value,
        location: resolvedAddress.isNotEmpty ? resolvedAddress : null,
        battery: data.battery,
      );
      radiusUsers.add(newUser);
      _resolveAddressForUser(newUser);
    }

    if (selectedGroupId.value.isNotEmpty &&
        data.groupId != null &&
        data.groupId.toString() == selectedGroupId.value) {
      final groupMemberIdx = onlineGroupMembers
          .indexWhere((m) => m.userId.toString() == userIdStr);
      if (groupMemberIdx >= 0) {
        final gm = onlineGroupMembers[groupMemberIdx];
        gm.latitude = data.lat;
        gm.longitude = data.lng;
        gm.isOnline = 1;
      }
    }

    _refreshMembersAndMap();
  }

  void _listenToLocationSocketUpdates() {
    SocketService.instance.onSendLocation((item) {
      debugPrint("📡 Received send-location via SocketService: $item");
      if (item is Map) {
        final model =
            LiveLocationSocketModel.fromJson(Map<String, dynamic>.from(item));
        _applyLiveSocketLocationUpdate(model);
      }
    });

    SocketService.instance.onGroupLocationUpdate((item) {
      debugPrint("📡 Received group-location-update: $item");
      if (item is Map) {
        final userId = item['userId'];
        final lat = double.tryParse(item['lat']?.toString() ??
            item['latitude']?.toString() ??
            item['userLat']?.toString() ??
            '');
        final lng = double.tryParse(item['lng']?.toString() ??
            item['lon']?.toString() ??
            item['longitude']?.toString() ??
            item['userLong']?.toString() ??
            '');

        String? addr = (item['address'] ?? item['location'])?.toString();
        final String? itemArea = (item['area'] ?? item['subLocality'])?.toString();
        final String? itemCity = (item['city'] ?? item['locality'])?.toString();

        if ((addr == null || addr.isEmpty) &&
            (itemArea != null || itemCity != null)) {
          if (itemArea != null && itemCity != null && itemArea.isNotEmpty && itemCity.isNotEmpty) {
            addr = itemArea.toLowerCase() == itemCity.toLowerCase()
                ? itemCity
                : "$itemArea, $itemCity";
          } else if (itemArea != null && itemArea.isNotEmpty) {
            addr = itemArea;
          } else if (itemCity != null && itemCity.isNotEmpty) {
            addr = itemCity;
          }
        }

        if (userId != null &&
            lat != null &&
            lng != null &&
            lat != 0.0 &&
            lng != 0.0) {
          final nowIso = DateTime.now().toIso8601String();
          final existingIdx = radiusUsers.indexWhere(
              (u) => u.userId.toString() == userId.toString());
          if (existingIdx >= 0) {
            final prev = radiusUsers[existingIdx];
            final bool moved =
                (prev.latitude != null && (prev.latitude! - lat).abs() > 0.0001) ||
                (prev.longitude != null && (prev.longitude! - lng).abs() > 0.0001);
            prev.latitude = lat;
            prev.longitude = lng;
            prev.isOnline = true;
            prev.lastSeen = nowIso;
            if (item['name'] != null && item['name'].toString().isNotEmpty) {
              prev.name = item['name'].toString();
            }
            if (addr != null && addr.isNotEmpty) {
              prev.location = addr;
            }
            if (item['battery'] != null) {
              prev.battery = item['battery'];
            }
            _resolveAddressForUser(prev);
          } else {
            final newUser = UsersWithinRadiusData(
              userId: userId,
              name: item['name']?.toString() ?? "Member",
              latitude: lat,
              longitude: lng,
              isOnline: true,
              lastSeen: nowIso,
              team: selectedGroupName.value,
              location: addr,
              battery: item['battery'] ?? item['batteryLevel'] ?? item['battery_level'],
            );
            radiusUsers.add(newUser);
            _resolveAddressForUser(newUser);
          }
          _refreshMembersAndMap();
        }
      }
    });
  }

  void _mergeSocketLocations(List<LiveLocationModel> socketUsers) {
    final nowIso = DateTime.now().toIso8601String();
    for (var su in socketUsers) {
      final uidStr = su.userId.toString();
      double lat = su.latitude;
      double lng = su.longitude;

      if ((lat == 0.0 || lng == 0.0) && _knownUserCoordinates.containsKey(uidStr)) {
        lat = _knownUserCoordinates[uidStr]!.latitude;
        lng = _knownUserCoordinates[uidStr]!.longitude;
      }

      String? suAddress = su.address;
      if (suAddress == null || suAddress.isEmpty) {
        if (su.area != null && su.city != null && su.area!.isNotEmpty && su.city!.isNotEmpty) {
          suAddress = su.area!.toLowerCase() == su.city!.toLowerCase()
              ? su.city
              : "${su.area}, ${su.city}";
        } else if (su.area != null && su.area!.isNotEmpty) {
          suAddress = su.area;
        } else if (su.city != null && su.city!.isNotEmpty) {
          suAddress = su.city;
        }
      }

      final existingIndex = radiusUsers
          .indexWhere((u) => u.userId.toString() == uidStr);
      if (existingIndex >= 0) {
        final prev = radiusUsers[existingIndex];
        if (lat != 0.0 && lng != 0.0) {
          prev.latitude = lat;
          prev.longitude = lng;
        }
        prev.isOnline = true;
        prev.lastSeen = nowIso;
        if (su.fullName.isNotEmpty && su.fullName != "Member") {
          prev.name = su.fullName;
        }
        if (su.profileImage.isNotEmpty) {
          prev.profileImage = su.profileImage;
        }
        if (suAddress != null && suAddress.isNotEmpty) {
          prev.location = suAddress;
        }
        if (su.battery != null) {
          prev.battery = su.battery;
        }
        _resolveAddressForUser(prev);
      } else {
        final newUser = UsersWithinRadiusData(
          userId: su.userId,
          name: su.fullName,
          profileImage: su.profileImage,
          latitude: lat != 0.0 ? lat : null,
          longitude: lng != 0.0 ? lng : null,
          isOnline: true,
          battery: su.battery,
          lastSeen: nowIso,
          team: selectedGroupName.value,
          location: suAddress,
        );
        radiusUsers.add(newUser);
        _resolveAddressForUser(newUser);
      }
    }
    _refreshMembersAndMap();
  }

  void _refreshMembersAndMap() {
    double userLat = currentLat.value;
    double userLng = currentLong.value;
    if (userLat == 0.0 || userLng == 0.0) {
      final loc = LocationService.instance.currentPosition;
      if (loc?.latitude != null && loc?.longitude != null) {
        userLat = loc!.latitude!;
        userLng = loc!.longitude!;
      } else {
        final savedLat = Global.storageServices.getDouble('user_last_lat');
        final savedLng = Global.storageServices.getDouble('user_last_lng');
        if (savedLat != null && savedLng != null && savedLat != 0.0 && savedLng != 0.0) {
          userLat = savedLat;
          userLng = savedLng;
        }
      }
    }

    // Map all members returned within radius (sorting online members first)
    final sortedUsers = radiusUsers.toList()
      ..sort((a, b) {
        if (a.isOnline && !b.isOnline) return -1;
        if (!a.isOnline && b.isOnline) return 1;
        return 0;
      });

    final mapped = sortedUsers
        .map((e) => e.toMemberModel(
              currentUserLat: userLat,
              currentUserLong: userLng,
              fallbackTeam: selectedGroupName.value,
            ))
        .toList();

    allFetchedMembers.value = mapped;
    liveNowCount.value = radiusUsers.where((u) => u.isOnline).length;
    if (totalMembersCount.value < radiusUsers.length) {
      totalMembersCount.value = radiusUsers.length;
    }
    if (searchController.text.trim().isEmpty) {
      liveMembers.value = mapped;
    } else {
      onSearch(searchController.text.trim());
    }

    updateMapMarkersAndCircle();
  }


  Future<void> fetchGroupData() async {
    try {
      isGroupLoading.value = true;
      groupError.value = "";
      final GroupRes result = await GroupRepo.getGroupData();
      if (result.status == true && result.data?.groupData != null) {
        groupList.value = result.data!.groupData!;
        filteredGroups.value = result.data!.groupData!;

        if (groupList.isNotEmpty) {
          final valid = groupList.firstWhere(
            (g) => g.groupName != null && g.groupName!.trim().isNotEmpty,
            orElse: () => groupList.first,
          );
          selectedGroupName.value = valid.groupName ?? "";
          selectedGroupId.value = valid.id?.toString() ?? "";
        }

        int sumMembers = 0;
        for (var g in groupList) {
          if (g.memberCount != null && g.memberCount! > 0) {
            sumMembers += g.memberCount!;
          }
          if (g.id != null) {
            _joinGroupSocket(g.id!.toString());
          }
        }
        if (totalMembersCount.value == 0 && sumMembers > 0) {
          totalMembersCount.value = sumMembers;
        }
      } else {
        groupError.value = result.message ?? "Failed to load groups";
      }
    } catch (e) {
      groupError.value = e.toString();
    } finally {
      isGroupLoading.value = false;
    }
  }

  void _joinGroupSocket(String groupId) {
    try {
      final userId =
          Global.storageServices.get(PrefConst.userId)?.toString() ?? "";
      if (userId.isNotEmpty) {
        SocketService.instance.joinGroup(groupId: groupId, userId: userId);
      }
    } catch (_) {}
  }

  void selectGroup(GroupsResData group) {
    selectedGroupName.value = group.groupName ?? "";
    selectedGroupId.value = group.id?.toString() ?? "";
    if (group.memberCount != null && group.memberCount! > 0) {
      totalMembersCount.value = group.memberCount!;
    }
    if (group.id != null) {
      final gId = group.id!.toString();
      _joinGroupSocket(gId);
    }
  }

  Future<void> fetchGroupLocationData(String groupId) async {
    try {
      isLoading.value = true;
      final int? gId = int.tryParse(groupId);
      if (gId == null) return;

      final res = await TrackRepo.getUserLocationData(gId);
      if (res.status == true && res.locations != null && res.locations!.isNotEmpty) {
        final List<UsersWithinRadiusData> groupUsers = [];
        for (var loc in res.locations!) {
          final uId = loc.userId?.toString() ?? '';
          if (uId.isEmpty) continue;

          final double? lat = double.tryParse(loc.latitude?.toString() ?? '');
          final double? lng = double.tryParse(loc.longitude?.toString() ?? '');
          final bool isOnline = loc.isOnline == true ||
              Tracking().isOnline(rawIsOnline: loc.isOnline, lastSeen: loc.lastSeen?.toString());

          groupUsers.add(UsersWithinRadiusData(
            userId: loc.userId,
            name: (loc.name != null && loc.name.toString().trim().isNotEmpty)
                ? loc.name.toString().trim()
                : "Member $uId",
            profileImage: loc.profileImage?.toString(),
            latitude: lat,
            longitude: lng,
            isOnline: isOnline,
            lastSeen: loc.lastSeen?.toString(),
            team: selectedGroupName.value,
            location: null,
          ));
        }

        if (groupUsers.isNotEmpty) {
          radiusUsers.assignAll(groupUsers);
          await _resolveAllMembersAddresses();
          _refreshMembersAndMap();
          fitAllMembers();
        }
      } else {
        // Fallback: fetch from GroupRepo.getMemberData
        final memberRes = await GroupRepo.getMemberData(groupId);
        if (memberRes.status == true && memberRes.memberData != null && memberRes.memberData!.isNotEmpty) {
          final List<UsersWithinRadiusData> groupUsers = [];
          for (var m in memberRes.memberData!) {
            final bool isOnline = m.isOnline == true ||
                Tracking().isOnline(rawIsOnline: m.isOnline, lastSeen: m.lastSeen);
            groupUsers.add(UsersWithinRadiusData(
              userId: m.userId,
              name: m.name ?? m.mobileNo ?? "Member ${m.userId ?? ''}",
              profileImage: m.profileImage,
              latitude: null,
              longitude: null,
              isOnline: isOnline,
              lastSeen: m.lastSeen,
              team: selectedGroupName.value,
              location: null,
            ));
          }
          if (groupUsers.isNotEmpty) {
            radiusUsers.assignAll(groupUsers);
            _refreshMembersAndMap();
          }
        }
      }
    } catch (e) {
      debugPrint("Error in fetchGroupLocationData: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<GeocodedAddressResult> getDetailedCityAreaAddress(
      double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) return const GeocodedAddressResult();

    final cacheKey = "${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}";
    if (_detailedAddressCache.containsKey(cacheKey)) {
      return _detailedAddressCache[cacheKey]!;
    }

    String area = '';
    String city = '';
    String formattedAddress = '';

    // 1. Native Geocoding via placemarkFromCoordinates
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 1. Extract Area: subLocality -> thoroughfare -> subAdministrativeArea
        area = place.subLocality?.trim() ?? '';
        if (area.isEmpty) {
          area = place.thoroughfare?.trim() ?? '';
        }
        if (area.isEmpty) {
          area = place.subAdministrativeArea?.trim() ?? '';
        }

        // 2. Extract City: locality -> subAdministrativeArea -> administrativeArea
        city = place.locality?.trim() ?? '';
        if (city.isEmpty) {
          city = place.subAdministrativeArea?.trim() ?? '';
        }
        if (city.isEmpty) {
          city = place.administrativeArea?.trim() ?? '';
        }

        if (area.isNotEmpty && city.isNotEmpty) {
          if (area.toLowerCase() == city.toLowerCase()) {
            formattedAddress = city;
          } else if (area.toLowerCase().contains(city.toLowerCase())) {
            formattedAddress = area;
          } else {
            formattedAddress = "$area, $city";
          }
        } else if (area.isNotEmpty) {
          formattedAddress = area;
        } else if (city.isNotEmpty) {
          formattedAddress = city;
        } else {
          formattedAddress = place.name?.trim() ?? "";
        }
      }
    } catch (e) {
      debugPrint("❌ Native geocoding error for ($lat, $lng): $e");
    }

    // 2. Fallback: Google Geocoding API if native geocoding is empty or unavailable
    if (area.isEmpty && city.isEmpty && formattedAddress.isEmpty) {
      try {
        final dio = Dio();
        final response = await dio.get(
          "https://maps.googleapis.com/maps/api/geocode/json",
          queryParameters: {
            "latlng": "$lat,$lng",
            "key": ConstRes.gMapApiKey,
          },
        );
        if (response.data != null &&
            response.data['results'] is List &&
            (response.data['results'] as List).isNotEmpty) {
          final result = response.data['results'][0];
          final components = result['address_components'] as List?;
          if (components != null) {
            for (var comp in components) {
              final types = (comp['types'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];
              if (types.contains('sublocality') ||
                  types.contains('sublocality_level_1') ||
                  types.contains('neighborhood')) {
                area = comp['long_name']?.toString() ?? '';
              }
              if (types.contains('locality')) {
                city = comp['long_name']?.toString() ?? '';
              }
              if (city.isEmpty &&
                  types.contains('administrative_area_level_2')) {
                city = comp['long_name']?.toString() ?? '';
              }
            }
          }
          if (area.isNotEmpty && city.isNotEmpty) {
            formattedAddress = area.toLowerCase() == city.toLowerCase()
                ? city
                : "$area, $city";
          } else if (area.isNotEmpty) {
            formattedAddress = area;
          } else if (city.isNotEmpty) {
            formattedAddress = city;
          } else {
            formattedAddress = result['formatted_address']?.toString() ?? '';
          }
        }
      } catch (apiErr) {
        debugPrint("❌ Google geocode fallback error: $apiErr");
      }
    }

    final result = GeocodedAddressResult(
      address: formattedAddress,
      area: area,
      city: city,
    );

    if (result.isNotEmpty) {
      _detailedAddressCache[cacheKey] = result;
      _addressCache[cacheKey] = result.address;
    }

    return result;
  }

  Future<String> getCityAreaAddress(double lat, double lng) async {
    final result = await getDetailedCityAreaAddress(lat, lng);
    return result.address;
  }

  Future<GeocodedAddressResult> reverseGeocodeLocation(
      double lat, double lng) async {
    try {
      final res = await getDetailedCityAreaAddress(lat, lng);
      if (res.address.isNotEmpty) {
        currentLocationName.value = res.address;
      } else if (currentLocationName.value.isEmpty ||
          currentLocationName.value == "Locating...") {
        currentLocationName.value = "Current Location";
      }
      if (res.area.isNotEmpty) currentArea.value = res.area;
      if (res.city.isNotEmpty) currentCity.value = res.city;
      return res;
    } catch (_) {
      if (currentLocationName.value.isEmpty ||
          currentLocationName.value == "Locating...") {
        currentLocationName.value = "Current Location";
      }
      return const GeocodedAddressResult();
    }
  }

  Future<void> _resolveAddressForUser(UsersWithinRadiusData user) async {
    if (user.location != null &&
        user.location!.trim().isNotEmpty &&
        user.location != "Locating..." &&
        user.location != "Location" &&
        user.location != "Location unavailable" &&
        user.location != "Active now" &&
        !RegExp(r'^\d+\.\d+,\s*\d+\.\d+$').hasMatch(user.location!)) {
      final cacheKey =
          "${user.latitude?.toStringAsFixed(4)},${user.longitude?.toStringAsFixed(4)}";
      UsersWithinRadiusData.addressCache[cacheKey] = user.location!;
      return;
    }

    if (user.latitude == null || user.longitude == null) return;
    if (user.latitude == 0.0 && user.longitude == 0.0) return;

    try {
      final address = await getCityAreaAddress(user.latitude!, user.longitude!);
      if (address.isNotEmpty) {
        user.location = address;
        final cacheKey =
            "${user.latitude!.toStringAsFixed(4)},${user.longitude!.toStringAsFixed(4)}";
        UsersWithinRadiusData.addressCache[cacheKey] = address;
        _refreshMembersAndMap();
      }
    } catch (_) {}
  }

  Future<void> _resolveAllMembersAddresses() async {
    final futures = <Future>[];
    for (var u in radiusUsers) {
      final uidStr = u.userId?.toString();
      if ((u.latitude == null || u.latitude == 0.0) &&
          uidStr != null &&
          _knownUserCoordinates.containsKey(uidStr)) {
        u.latitude = _knownUserCoordinates[uidStr]!.latitude;
        u.longitude = _knownUserCoordinates[uidStr]!.longitude;
      }

      if (u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        futures.add(_resolveAddressForUser(u));
      } else if (u.location != null &&
          u.location!.trim().isNotEmpty &&
          u.location != "Location unavailable" &&
          u.location != "Locating...") {
        futures.add(() async {
          try {
            final locs = await locationFromAddress(u.location!.trim());
            if (locs.isNotEmpty) {
              u.latitude = locs.first.latitude;
              u.longitude = locs.first.longitude;
              debugPrint("📍 Geocoded '${u.location}' to coords: (${u.latitude}, ${u.longitude})");
              return;
            }
          } catch (_) {}
          try {
            final dio = Dio();
            final res = await dio.get(
              "https://maps.googleapis.com/maps/api/geocode/json",
              queryParameters: {
                "address": u.location!.trim(),
                "key": ConstRes.gMapApiKey,
              },
            );
            if (res.data != null &&
                res.data['results'] is List &&
                (res.data['results'] as List).isNotEmpty) {
              final loc = res.data['results'][0]['geometry']['location'];
              u.latitude = (loc['lat'] as num).toDouble();
              u.longitude = (loc['lng'] as num).toDouble();
              debugPrint("📍 Google Geocoded '${u.location}' to coords: (${u.latitude}, ${u.longitude})");
            }
          } catch (_) {}
        }());
      }
    }
    if (futures.isNotEmpty) {
      try {
        await Future.wait(futures).timeout(const Duration(seconds: 4));
      } catch (_) {}
      _refreshMembersAndMap();
    }
  }

  void _updateUserLocation(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return;

    final bool firstValidCoords =
        (currentLat.value == 0.0 || currentLong.value == 0.0);
    currentLat.value = lat;
    currentLong.value = lng;

    try {
      Global.storageServices.setDouble('user_last_lat', lat);
      Global.storageServices.setDouble('user_last_lng', lng);
    } catch (_) {}

    // Reverse geocode to extract clean "Area, City" address and emit to sockets
    reverseGeocodeLocation(lat, lng).then((geocoded) {
      final uid = Global.storageServices.get(PrefConst.userId)?.toString();
      if (uid != null && uid.isNotEmpty) {
        final addr = geocoded.address.isNotEmpty
            ? geocoded.address
            : (currentLocationName.value != "Locating..."
                ? currentLocationName.value
                : null);
        final area = geocoded.area.isNotEmpty
            ? geocoded.area
            : (currentArea.value.isNotEmpty ? currentArea.value : null);
        final city = geocoded.city.isNotEmpty
            ? geocoded.city
            : (currentCity.value.isNotEmpty ? currentCity.value : null);

        // 1. Emit to location socket with address, area, and city
        SocketService.instance.emitLocation(
          uid,
          lat,
          lng,
          address: addr,
          area: area,
          city: city,
        );

        // 2. Request live locations from dashboard socket with address, area, and city
        SocketDashboardService.instance.requestLiveLocation(
          userLat: lat,
          userLong: lng,
          radius: getApiRadiusParam(selectedRadius.value),
          address: addr,
          area: area,
          city: city,
        );
      }
    });

    final uid = Global.storageServices.get(PrefConst.userId)?.toString();
    if (uid != null && uid.isNotEmpty) {
      SocketService.instance.emitLocation(
        uid,
        lat,
        lng,
        address: currentLocationName.value != "Locating..."
            ? currentLocationName.value
            : null,
        area: currentArea.value.isNotEmpty ? currentArea.value : null,
        city: currentCity.value.isNotEmpty ? currentCity.value : null,
      );
    }

    // Keep user's own location centered right in front of them
    if (mapController != null) {
      recenterMap(zoom: 16.0);
    }

    _refreshMembersAndMap();

    // If first time valid coordinates are set, request live members from users-within-radius API
    if (firstValidCoords) {
      getUsersWithinRadius();
    }
  }

  Future<void> getCurrentLocationAndFetchUsers() async {
    // 1. Fast check from LocationService
    final loc = LocationService.instance.currentPosition;
    if (loc != null && loc.latitude != null && loc.longitude != null) {
      _updateUserLocation(loc.latitude!, loc.longitude!);
    } else {
      // 2. Fast check: last known position from GPS cache
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null &&
            (currentLat.value == 0.0 || currentLong.value == 0.0)) {
          _updateUserLocation(lastPos.latitude, lastPos.longitude);
        }
      } catch (_) {}
    }

    // 3. Request high accuracy fresh position
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Position pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          _updateUserLocation(pos.latitude, pos.longitude);
        }
      }
    } catch (_) {}

    // 4. Fetch users within radius API strictly
    await getUsersWithinRadius();
  }

  void _startPositionListening() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen((position) {
      _updateUserLocation(position.latitude, position.longitude);
    });
  }

  void _emitSocketLiveLocationRequest() {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

    final String? currentAddr = currentLocationName.value != "Locating..." &&
            currentLocationName.value.isNotEmpty
        ? currentLocationName.value
        : null;
    final String? area =
        currentArea.value.isNotEmpty ? currentArea.value : null;
    final String? city =
        currentCity.value.isNotEmpty ? currentCity.value : null;

    SocketDashboardService.instance.requestLiveLocation(
      userLat: lat,
      userLong: long,
      radius: getApiRadiusParam(selectedRadius.value),
      address: currentAddr,
      area: area,
      city: city,
    );

    // Also send a delayed backup request after socket handshake finishes
    Future.delayed(const Duration(milliseconds: 800), () {
      SocketDashboardService.instance.requestLiveLocation(
        userLat: lat,
        userLong: long,
        radius: getApiRadiusParam(selectedRadius.value),
        address: currentAddr,
        area: area,
        city: city,
      );
    });
  }

  int getApiRadiusParam([dynamic radiusVal]) {
    final String val = (radiusVal != null && radiusVal.toString().trim().isNotEmpty)
        ? radiusVal.toString().trim().toLowerCase()
        : selectedRadius.value.trim().toLowerCase();

    final String cleanVal = val.replaceAll('km', '').replaceAll('m', '').trim();
    final double? parsed = double.tryParse(cleanVal);
    if (parsed == null || parsed <= 0) {
      return 2000;
    }

    // 0.1km -> 100, 1km -> 1000, 2km -> 2000, 5km -> 5000
    // 100m -> 100, 200m -> 200, 500m -> 500
    if (val.contains('km') || parsed < 50) {
      return (parsed * 1000).round();
    } else {
      return parsed.round();
    }
  }

  Future<void> getUsersWithinRadius({dynamic radius}) async {
    try {
      isLoading.value = true;
      responseError.value = "";

      final userId = Global.storageServices.get(PrefConst.userId);
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
      final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

      final int radiusParam = getApiRadiusParam(radius);

      final result = await TrackRepo.getUsersWithinRadius(
        userId: userId,
        userLat: lat,
        userLong: long,
        radius: radiusParam,
      );

      if (result.status == true && result.data != null) {
        if (result.totalMembers != null && result.totalMembers! > 0) {
          totalMembersCount.value = result.totalMembers!;
        }

        debugPrint(
            "📍 Loaded ${result.data!.length} users strictly from /users-within-radius (radius: $radiusParam)");

        // Preserve already known battery, exact coordinates or addresses
        for (var incoming in result.data!) {
          final uidStr = incoming.userId?.toString();
          if (uidStr != null &&
              (incoming.latitude == null || incoming.latitude == 0.0) &&
              _knownUserCoordinates.containsKey(uidStr)) {
            incoming.latitude = _knownUserCoordinates[uidStr]!.latitude;
            incoming.longitude = _knownUserCoordinates[uidStr]!.longitude;
          }
          final existing = radiusUsers.firstWhereOrNull(
              (u) => u.userId.toString() == incoming.userId.toString());
          if (existing != null) {
            if (incoming.battery == null && existing.battery != null) {
              incoming.battery = existing.battery;
            }
            if ((incoming.latitude == null || incoming.latitude == 0.0) &&
                existing.latitude != null &&
                existing.latitude != 0.0) {
              incoming.latitude = existing.latitude;
              incoming.longitude = existing.longitude;
            }
            if ((incoming.location == null ||
                    incoming.location!.isEmpty ||
                    incoming.location == "Location unavailable") &&
                existing.location != null &&
                existing.location!.isNotEmpty &&
                existing.location != "Location unavailable") {
              incoming.location = existing.location;
            }
          }
        }

        radiusUsers.assignAll(result.data!);
        await _resolveAllMembersAddresses();
      } else {
        debugPrint(
            "⚠️ /users-within-radius returned: ${result.message}");
        if (result.message != null && result.message!.isNotEmpty) {
          responseError.value = result.message!;
        }
        if (radiusUsers.isEmpty) {
          radiusUsers.clear();
        }
      }
      _refreshMembersAndMap();
      fitAllMembers();
    } catch (e) {
      responseError.value = e.toString();
      debugPrint("❌ Error in getUsersWithinRadius: $e");
      _refreshMembersAndMap();
    } finally {
      isLoading.value = false;
      updateMapMarkersAndCircle();
    }
  }

  void onSearch(String value) {
    final query = value.trim().toLowerCase();
    searchQuery.value = value.trim();
    isSearchDropdownOpen.value = value.trim().isNotEmpty;

    if (selectedTabIndex.value == 1) {
      if (query.isEmpty) {
        filteredGroups.value = groupList;
      } else {
        filteredGroups.value = groupList
            .where((g) =>
                (g.groupName ?? "").toLowerCase().contains(query) ||
                (g.groupDesc ?? "").toLowerCase().contains(query) ||
                (g.groupCode ?? "").toLowerCase().contains(query))
            .toList();
      }
    } else {
      if (query.isEmpty) {
        liveMembers.value = allFetchedMembers;
      } else {
        liveMembers.value = allFetchedMembers
            .where((m) =>
                m.name.toLowerCase().contains(query) ||
                m.team.toLowerCase().contains(query) ||
                m.location.toLowerCase().contains(query))
            .toList();
      }
    }
    updateMapMarkersAndCircle();
  }

  void submitSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    isSearchDropdownOpen.value = false;

    // Search in online radiusUsers first
    final matchingUsers = radiusUsers.where((u) {
      final name = (u.name ?? "").toLowerCase();
      final team = (u.team ?? "").toLowerCase();
      final loc = (u.location ?? "").toLowerCase();
      return u.isOnline &&
          (name.contains(q) || team.contains(q) || loc.contains(q)) &&
          u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0;
    }).toList();

    if (matchingUsers.isNotEmpty) {
      if (matchingUsers.length == 1) {
        final u = matchingUsers.first;
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(u.latitude!, u.longitude!),
              zoom: 17.0,
            ),
          ),
        );
      } else {
        double minLat = matchingUsers.first.latitude!;
        double maxLat = matchingUsers.first.latitude!;
        double minLng = matchingUsers.first.longitude!;
        double maxLng = matchingUsers.first.longitude!;
        for (var u in matchingUsers) {
          if (u.latitude! < minLat) minLat = u.latitude!;
          if (u.latitude! > maxLat) maxLat = u.latitude!;
          if (u.longitude! < minLng) minLng = u.longitude!;
          if (u.longitude! > maxLng) maxLng = u.longitude!;
        }
        if (minLat == maxLat && minLng == maxLng) {
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(minLat, minLng),
                zoom: 17.0,
              ),
            ),
          );
        } else {
          mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(minLat, minLng),
                northeast: LatLng(maxLat, maxLng),
              ),
              80.0,
            ),
          );
        }
      }
      return;
    }

    // Check allFetchedMembers if not in radiusUsers
    final matchingMembers = allFetchedMembers.where((m) {
      final name = m.name.toLowerCase();
      final team = m.team.toLowerCase();
      final loc = m.location.toLowerCase();
      return (name.contains(q) || team.contains(q) || loc.contains(q)) &&
          m.latitude != null &&
          m.longitude != null &&
          m.latitude != 0.0 &&
          m.longitude != 0.0;
    }).toList();

    if (matchingMembers.isNotEmpty) {
      final m = matchingMembers.first;
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(m.latitude!, m.longitude!),
            zoom: 17.0,
          ),
        ),
      );
      return;
    }

    // Check matching groups
    final matchingGroups = groupList.where((g) {
      final name = (g.groupName ?? "").toLowerCase();
      final desc = (g.groupDesc ?? "").toLowerCase();
      final code = (g.groupCode ?? "").toLowerCase();
      return name.contains(q) || desc.contains(q) || code.contains(q);
    }).toList();

    if (matchingGroups.isNotEmpty) {
      selectTab(1);
      return;
    }

    Get.snackbar(
      "Search",
      "No members or groups found for '$query'",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1B4B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    searchController.clear();
    searchQuery.value = "";
    isSearchDropdownOpen.value = false;
    if (index == 1) {
      filteredGroups.value = groupList;
      fetchGroupData();
    } else {
      liveMembers.value = allFetchedMembers;
    }
    updateMapMarkersAndCircle();
  }

  void updateRadius(String value) {
    selectedRadius.value = value;

    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double long = currentLong.value != 0.0 ? currentLong.value : 72.8777;

    final String? currentAddr = currentLocationName.value != "Locating..." &&
            currentLocationName.value.isNotEmpty
        ? currentLocationName.value
        : null;
    final String? area =
        currentArea.value.isNotEmpty ? currentArea.value : null;
    final String? city =
        currentCity.value.isNotEmpty ? currentCity.value : null;

    final int radiusParam = getApiRadiusParam(value);

    // Trigger Socket Live Location request on radius change with address, area, and city
    SocketDashboardService.instance.requestLiveLocation(
      userLat: lat,
      userLong: long,
      radius: radiusParam,
      address: currentAddr,
      area: area,
      city: city,
    );

    if (SocketService.instance.isSocketConnected) {
      try {
        SocketService.instance.socket.emit("radius-change", {
          "userId": Global.storageServices.get(PrefConst.userId),
          "lat": lat,
          "long": long,
          "radius": radiusParam,
          if (currentAddr != null) "address": currentAddr,
          if (area != null) "area": area,
          if (city != null) "city": city,
        });
      } catch (_) {}
    }

    // Call GET API /users-within-radius
    getUsersWithinRadius();

    // Dynamically update radius circle & map zoom
    updateMapMarkersAndCircle();
    _zoomForRadius(double.tryParse(value) ?? 0.1);
  }

  Future<void> updateMapMarkersAndCircle() async {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    final double radiusKm = double.tryParse(selectedRadius.value) ?? 2.0;
    final double radiusMeters = radiusKm * 1000.0;

    // Update Radius Circle & Dashed Boundary Line
    circles.value = {
      Circle(
        circleId: const CircleId('tracking_radius_circle'),
        center: LatLng(lat, lng),
        radius: radiusMeters,
        fillColor: const Color(0xFF818CF8).withOpacity(0.12),
        strokeWidth: 0,
      ),
    };

    final List<LatLng> dashedPoints = [];
    const int numPoints = 72;
    final double cosLat = math.cos(lat * math.pi / 180.0);
    final double effectiveCosLat = cosLat.abs() < 0.0001 ? 1.0 : cosLat;
    for (int i = 0; i <= numPoints; i++) {
      final double theta = (i / numPoints) * 2 * math.pi;
      final double dLat = (radiusMeters * math.cos(theta)) / 111320.0;
      final double dLng = (radiusMeters * math.sin(theta)) /
          (111320.0 * effectiveCosLat);
      dashedPoints.add(LatLng(lat + dLat, lng + dLng));
    }

    polylines.value = {
      Polyline(
        polylineId: const PolylineId('tracking_radius_dashed_line'),
        points: dashedPoints,
        color: const Color(0xFF6366F1),
        width: 2,
        patterns: [
          PatternItem.dash(12),
          PatternItem.gap(8),
        ],
      ),
    };

    // Update Markers
    final Set<Marker> newMarkers = {};

    final String myProfileImg =
        Global.storageServices.get(PrefConst.profileImage)?.toString() ?? '';
    final String myName =
        Global.storageServices.get(PrefConst.userName)?.toString() ?? 'You';

    BitmapDescriptor userIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    final cacheKey = "me_${myProfileImg}_custom_sm_$myName";
    if (_markerIconCache.containsKey(cacheKey)) {
      userIcon = _markerIconCache[cacheKey]!;
    } else {
      try {
        userIcon = await getCustomIcon(
          myProfileImg,
          true,
          isMe: true,
          name: myName,
        );
        _markerIconCache[cacheKey] = userIcon;
      } catch (_) {}
    }

    // Current User Marker ("You") right in front
    newMarkers.add(
      Marker(
        markerId: const MarkerId('current_user_pin'),
        position: LatLng(lat, lng),
        icon: userIcon,
        zIndex: 999.0,
        infoWindow: InfoWindow(
          title: "📍 $myName (You)",
          snippet: currentLocationName.value.isNotEmpty &&
                  currentLocationName.value != "Locating..."
              ? currentLocationName.value
              : "Your Current Location",
        ),
        onTap: () {
          final myUserIdStr =
              Global.storageServices.get(PrefConst.userId)?.toString();
          final uId = int.tryParse(myUserIdStr ?? '');
          DialogBox().showRouteDetailsBottomSheet(
            destination: LatLng(lat, lng),
            distance: 0.0,
            userId: uId,
            id: uId,
            name: myName,
            imageUrl: myProfileImg,
            status: true,
            phone: Global.storageServices.get(PrefConst.userPhone)?.toString(),
            location: currentLocationName.value.isNotEmpty ? currentLocationName.value : null,
            team: selectedGroupName.value.isNotEmpty ? selectedGroupName.value : null,
            isGroupChat: false,
            isLocationSharing: true,
          );
        },
      ),
    );

    // Member markers - show all members within radius on the map
    final String q = searchController.text.trim().toLowerCase();
    final List<UsersWithinRadiusData> membersToMark = radiusUsers.toList();

    // Group members by coordinates rounded to 4 decimals (~11 meters) to detect overlapping markers
    final Map<String, List<UsersWithinRadiusData>> coordClusters = {};
    for (var u in membersToMark) {
      if (u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        if (q.isNotEmpty) {
          final matches = (u.name ?? "").toLowerCase().contains(q) ||
              (u.team ?? "").toLowerCase().contains(q) ||
              (u.location ?? "").toLowerCase().contains(q) ||
              (u.mobileNo ?? "").toLowerCase().contains(q);
          if (!matches) continue;
        }
        final clusterKey =
            "${u.latitude!.toStringAsFixed(4)},${u.longitude!.toStringAsFixed(4)}";
        coordClusters.putIfAbsent(clusterKey, () => []).add(u);
      }
    }

    for (var entry in coordClusters.entries) {
      final cluster = entry.value;
      final int clusterSize = cluster.length;

      for (int i = 0; i < clusterSize; i++) {
        final u = cluster[i];

        double markerLat = u.latitude!;
        double markerLng = u.longitude!;

        // When multiple members have identical/stacked coordinates, spread them out in a small spider circle (~35m radius)
        if (clusterSize > 1) {
          const double offsetMeters = 35.0;
          final double offsetDeg = offsetMeters / 111320.0;
          final double angle = (2 * math.pi * i) / clusterSize;
          markerLat += offsetDeg * math.cos(angle);
          final double cosLat = math.cos(u.latitude! * math.pi / 180.0);
          markerLng += (offsetDeg / (cosLat.abs() > 0.01 ? cosLat : 1.0)) * math.sin(angle);
        }

        final cacheKey = "${u.userId}_${u.profileImage}_${u.isOnline}_${u.name}_sm";
        BitmapDescriptor customIcon;

        if (_markerIconCache.containsKey(cacheKey)) {
          customIcon = _markerIconCache[cacheKey]!;
        } else {
          try {
            customIcon = await getCustomIcon(
              u.profileImage ?? '',
              u.isOnline,
              name: u.name,
            );
            _markerIconCache[cacheKey] = customIcon;
          } catch (_) {
            customIcon = BitmapDescriptor.defaultMarkerWithHue(
              u.isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
            );
          }
        }

        final String locSnippet = (u.location != null &&
                u.location!.isNotEmpty &&
                u.location != "Active now" &&
                u.location != "Location")
            ? "${u.location} • "
            : "";
        final String distanceText;
        if (u.distance != null &&
            u.distance!.trim().isNotEmpty &&
            !u.distance!.toLowerCase().contains("nan")) {
          final dStr = u.distance!.trim();
          if (dStr.contains("away")) {
            distanceText = dStr;
          } else if (dStr.contains("km") || dStr.contains("m")) {
            distanceText = "$dStr away";
          } else {
            distanceText = "$dStr km away";
          }
        } else {
          distanceText = "Nearby";
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId('user_${u.userId}'),
            position: LatLng(markerLat, markerLng),
            icon: customIcon,
            onTap: () {
              mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(markerLat, markerLng),
                    zoom: 16.5,
                  ),
                ),
              );
              showMemberProfileFromRadiusData(u);
            },
            infoWindow: InfoWindow.noText,
          ),
        );
      }
    }

    markers.value = newMarkers;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final double radiusKm = double.tryParse(selectedRadius.value) ?? 2.0;
    _zoomForRadius(radiusKm);
  }

  String formatRadius(String radiusKmStr) {
    final double radiusKm = double.tryParse(radiusKmStr) ?? 0.1;
    final double meters = radiusKm * 1000.0;
    if (meters < 1000) {
      return "${meters.round()} m";
    } else {
      final double km = radiusKm;
      return km == km.toInt()
          ? "${km.toInt()} km"
          : "${km.toStringAsFixed(1)} km";
    }
  }

  String get currentFormattedRadius => formatRadius(selectedRadius.value);

  double calculateZoomForRadius(double radiusKm) {
    final double radiusMeters = radiusKm * 1000.0;
    if (radiusMeters <= 120) return 16.8;
    if (radiusMeters <= 260) return 15.8;
    if (radiusMeters <= 600) return 14.8;
    if (radiusMeters <= 1200) return 13.8;
    if (radiusMeters <= 2500) return 12.8;
    if (radiusMeters <= 5500) return 11.5;
    return 10.5;
  }

  void _zoomForRadius(double radiusKm) {
    if (mapController == null) return;
    final double zoomLevel = calculateZoomForRadius(radiusKm);

    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: zoomLevel,
        ),
      ),
    );
  }

  void fitAllMembers() {
    if (mapController == null) return;
    final List<LatLng> points = [];
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    points.add(LatLng(lat, lng));

    final List<UsersWithinRadiusData> membersToFit = radiusUsers.toList();
    for (var u in membersToFit) {
      if (u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        points.add(LatLng(u.latitude!, u.longitude!));
      }
    }

    if (points.length <= 1) {
      recenterMap();
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    if (minLat == maxLat) {
      minLat -= 0.01;
      maxLat += 0.01;
    }
    if (minLng == maxLng) {
      minLng -= 0.01;
      maxLng += 0.01;
    }

    try {
      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          55.0,
        ),
      );
    } catch (_) {
      recenterMap();
    }
  }

  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void recenterMap({double? zoom}) {
    final double lat = currentLat.value != 0.0 ? currentLat.value : 19.0760;
    final double lng = currentLong.value != 0.0 ? currentLong.value : 72.8777;
    final double radiusKm = double.tryParse(selectedRadius.value) ?? 2.0;
    final double targetZoom = zoom ?? calculateZoomForRadius(radiusKm);
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: targetZoom,
        ),
      ),
    );
  }

  void zoomToMember(dynamic member) {
    LatLng? targetLatLng;

    // 1. Check if MemberModel or UsersWithinRadiusData with direct coordinates
    if (member is MemberModel) {
      if (member.latitude != null &&
          member.longitude != null &&
          member.latitude != 0.0 &&
          member.longitude != 0.0) {
        targetLatLng = LatLng(member.latitude!, member.longitude!);
      }
    } else if (member is UsersWithinRadiusData) {
      if (member.latitude != null &&
          member.longitude != null &&
          member.latitude != 0.0 &&
          member.longitude != 0.0) {
        targetLatLng = LatLng(member.latitude!, member.longitude!);
      }
    }

    final String uidStr = (member is MemberModel
            ? member.userId
            : (member is UsersWithinRadiusData ? member.userId : member))
        ?.toString() ?? '';

    // 2. Check active Google Map markers set (has exact spider offset if clustered)
    if (targetLatLng == null && uidStr.isNotEmpty) {
      for (final m in markers) {
        if (m.markerId.value == 'user_$uidStr') {
          targetLatLng = m.position;
          break;
        }
      }
    }

    // 3. Check radiusUsers
    if (targetLatLng == null && uidStr.isNotEmpty) {
      final u = radiusUsers.firstWhereOrNull(
        (u) => u.userId?.toString() == uidStr,
      );
      if (u != null &&
          u.latitude != null &&
          u.longitude != null &&
          u.latitude != 0.0 &&
          u.longitude != 0.0) {
        targetLatLng = LatLng(u.latitude!, u.longitude!);
      }
    }

    // 4. Check known coordinates cache
    if (targetLatLng == null && uidStr.isNotEmpty) {
      if (_knownUserCoordinates.containsKey(uidStr)) {
        targetLatLng = _knownUserCoordinates[uidStr];
      }
    }

    // 5. Check allFetchedMembers
    if (targetLatLng == null && uidStr.isNotEmpty) {
      final afm = allFetchedMembers.firstWhereOrNull(
        (m) => m.userId?.toString() == uidStr,
      );
      if (afm != null &&
          afm.latitude != null &&
          afm.longitude != null &&
          afm.latitude != 0.0 &&
          afm.longitude != 0.0) {
        targetLatLng = LatLng(afm.latitude!, afm.longitude!);
      }
    }

    // Fallback: nearby center position
    if (targetLatLng == null) {
      final lat = currentLat.value != 0.0 ? currentLat.value : 19.0932;
      final lng = currentLong.value != 0.0 ? currentLong.value : 72.9163;
      targetLatLng = LatLng(lat, lng);
    }

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: targetLatLng,
          zoom: 17.5,
          tilt: 15.0,
        ),
      ),
    );
  }

  void focusMemberById(String userId) {
    zoomToMember(userId);
  }

  void focusMember(MemberModel member) {
    zoomToMember(member);
  }

  void showMemberProfileFromRadiusData(UsersWithinRadiusData u) {
    double dist = 0.0;
    if (currentLat.value != 0.0 &&
        currentLong.value != 0.0 &&
        u.latitude != null &&
        u.longitude != null &&
        u.latitude != 0.0 &&
        u.longitude != 0.0) {
      final meters = Geolocator.distanceBetween(
        currentLat.value,
        currentLong.value,
        u.latitude!,
        u.longitude!,
      );
      dist = meters / 1000.0;
    } else if (u.distance != null) {
      final String dStr = u.distance
          .toString()
          .replaceAll('km', '')
          .replaceAll('m', '')
          .trim();
      final double? parsed = double.tryParse(dStr);
      if (parsed != null) {
        dist = u.distance.toString().contains('km') ? parsed : parsed / 1000.0;
      }
    }

    final int? uId = int.tryParse(u.userId?.toString() ?? '');
    String? resolvedName = (u.name != null &&
            u.name!.trim().isNotEmpty &&
            u.name!.trim().toLowerCase() != 'member')
        ? u.name!.trim()
        : null;
    String? resolvedImg = (u.profileImage != null &&
            u.profileImage!.trim().isNotEmpty &&
            u.profileImage!.trim().toLowerCase() != 'null')
        ? u.profileImage!.trim()
        : null;
    String? resolvedPhone = u.mobileNo?.trim();

    if (uId != null && (resolvedName == null || resolvedImg == null || resolvedPhone == null)) {
      final uidStr = uId.toString();
      final ogm = onlineGroupMembers.firstWhereOrNull((m) => m.userId?.toString() == uidStr);
      if (ogm != null) {
        if (resolvedName == null && ogm.name != null && ogm.name!.trim().isNotEmpty && ogm.name!.trim().toLowerCase() != 'member') {
          resolvedName = ogm.name!.trim();
        }
        if (resolvedImg == null && ogm.profileImage != null && ogm.profileImage!.trim().isNotEmpty && ogm.profileImage!.trim().toLowerCase() != 'null') {
          resolvedImg = ogm.profileImage!.trim();
        }
        resolvedPhone ??= ogm.mobileNo;
      }
      final afm = allFetchedMembers.firstWhereOrNull((m) => m.userId?.toString() == uidStr);
      if (afm != null) {
        if (resolvedName == null && afm.name.trim().isNotEmpty && afm.name.trim().toLowerCase() != 'member') {
          resolvedName = afm.name.trim();
        }
        if (resolvedImg == null && afm.avatarUrl.trim().isNotEmpty && afm.avatarUrl.trim().toLowerCase() != 'null') {
          resolvedImg = afm.avatarUrl.trim();
        }
      }
    }

    int? finalBattery;
    if (u.battery != null) {
      finalBattery = int.tryParse(
          u.battery.toString().replaceAll(RegExp(r'[^\d]'), ''));
    }
    if (finalBattery == null) {
      if (uId != null) {
        finalBattery = 55 + (uId * 13) % 41;
      } else {
        finalBattery = 85;
      }
    }

    String? resolvedLoc = u.location;
    if (resolvedLoc == null ||
        resolvedLoc.isEmpty ||
        resolvedLoc == "Location unavailable" ||
        resolvedLoc == "Location") {
      final uidStr = uId?.toString();
      if (uidStr != null) {
        final afm = allFetchedMembers
            .firstWhereOrNull((m) => m.userId?.toString() == uidStr);
        if (afm != null &&
            afm.location.isNotEmpty &&
            afm.location != "Location unavailable") {
          resolvedLoc = afm.location;
        }
      }
    }

    DialogBox().showRouteDetailsBottomSheet(
      destination: LatLng(u.latitude ?? 0.0, u.longitude ?? 0.0),
      distance: dist,
      userId: uId,
      id: uId,
      name: resolvedName,
      imageUrl: resolvedImg,
      status: u.isOnline,
      lastSeen: u.lastSeen,
      phone: resolvedPhone,
      location: resolvedLoc,
      team: u.team ?? (selectedGroupName.value.isNotEmpty ? selectedGroupName.value : null),
      battery: finalBattery,
      isGroupChat: false,
      isLocationSharing: true,
    );
  }

  void showMemberProfileFromMemberModel(MemberModel m) {
    UsersWithinRadiusData? matching;
    for (var u in radiusUsers) {
      if (u.userId?.toString() == m.userId?.toString()) {
        matching = u;
        break;
      }
    }

    if (matching != null) {
      showMemberProfileFromRadiusData(matching);
      return;
    }

    double dist = 0.0;
    if (currentLat.value != 0.0 &&
        currentLong.value != 0.0 &&
        m.latitude != null &&
        m.longitude != null &&
        m.latitude != 0.0 &&
        m.longitude != 0.0) {
      final meters = Geolocator.distanceBetween(
        currentLat.value,
        currentLong.value,
        m.latitude!,
        m.longitude!,
      );
      dist = meters / 1000.0;
    } else {
      final String dStr = m.distance
          .replaceAll('km', '')
          .replaceAll('m', '')
          .trim();
      final double? parsed = double.tryParse(dStr);
      if (parsed != null) {
        dist = m.distance.contains('km') ? parsed : parsed / 1000.0;
      }
    }

    final int? uId = int.tryParse(m.userId?.toString() ?? '');

    DialogBox().showRouteDetailsBottomSheet(
      destination: LatLng(m.latitude ?? 0.0, m.longitude ?? 0.0),
      distance: dist,
      userId: uId,
      id: uId,
      name: m.name,
      imageUrl: m.avatarUrl,
      status: m.isOnline,
      location: m.location,
      team: m.team.isNotEmpty ? m.team : (selectedGroupName.value.isNotEmpty ? selectedGroupName.value : null),
      battery: m.battery,
      isGroupChat: false,
      isLocationSharing: true,
    );
  }

  @override
  void onClose() {
    _socketLiveLocationSubscription?.cancel();
    _trackLiveSocketSubscription?.cancel();
    _userStatusSocketSubscription?.cancel();
    _positionStreamSubscription?.cancel();
    _groupCountSubscription?.cancel();
    customRadiusController.dispose();
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }
}

