// import 'dart:developer';
//
// import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
// import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
// import 'package:fgtracker/app/Model/GroupRes.dart';
// import 'package:fgtracker/app/Model/LocationDataRes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import '../../../Core/values/Dialog/DialogBox.dart';
// import '../../../Core/util/http/Constant.dart';
// import '../../../Core/values/global.dart';
// import '../../../Core/values/loading.dart';
// import '../../../Data/Services/Tracking.dart';
// import 'SocketServices.dart';
// import 'LocationService.dart';
// import '../Widget/Track_widget.dart';
//
// class TrackingController extends GetxController {
//   static TrackingController get instance => Get.put(TrackingController());
//
//   final markers = <Marker>{}.obs;
//   final polylines = <Polyline>{}.obs;
//
//   String? userId;
//
//   final joinedGroupIds = <String>[].obs;
//
//   final LocationService locationService = LocationService.instance;
//   final SocketService socketService = SocketService.instance;
//   GoogleMapController? mapController;
//
//   final groupWiseUserData = <String, List<LocationData>>{}.obs;
//   String? _alreadyListeningGroupId;
//
//   Future<void> initSocketConnection() async {
//     userId = Global.storageServices.get(Constant.userId).toString();
//     await socketService.init(socketUrl);
//   }
//
//   void initializeLocation() {
//     locationService.initLocationTracking();
//   }
//
//   void inItAllGroups({List<GroupData>? groups}) {
//     initSocketConnection();
//     for (var group in groups!) {
//       if (group.isActive == true) {
//         joinedGroupIds.add(group.id.toString());
//         socketService.joinGroup(groupId: group.id.toString(), userId: userId!);
//       }
//     }
//
//     socketService.onUserLeft((userId) => removeUserMarker(userId));
//     socketService.onGroupDeleted((groupId) => deleteGroupMarker(groupId));
//     socketService.onUserOffline((userId) => updateOfflineMarker(userId));
//     initializeLocation();
//   }
//
//   void initGroupTracking(String groupId) {
//     groupWiseUserData[groupId] = [];
//
//     _initSocketTracking(groupId);
//     _loadInitialMarkers(groupId);
//   }
//
//   Future<void> getGroupLocationData(BuildContext context, int groupId) async {
//     try {
//       Loading().showloading(context: context);
//       var result = await TrackRepo.getUserLocationData(groupId);
//       if (result.status == true) {
//         Loading().dismissloading(context: context);
//         for (var data in result.locations!) {
//           updateGroupMarker(data);
//         }
//       } else {
//         Loading().dismissloading(context: context);
//         CommonDialog.errorMessage(result.message);
//       }
//     } catch (e) {
//       Loading().dismissloading(context: context);
//       CommonDialog.errorMessage(e.toString());
//     }
//   }
//
//   void deleteGroupMarker(String groupId) {
//     groupWiseUserData.remove(groupId);
//
//     markers.removeWhere((marker) {
//       return groupWiseUserData[groupId]?.any(
//               (user) => user.userId.toString() == marker.markerId.value) ??
//           false;
//     });
//
//     polylines.removeWhere((p) => p.polylineId.value == groupId);
//     joinedGroupIds.remove(groupId);
//     markers.refresh();
//     polylines.refresh();
//   }
//
//   void updateOfflineMarker(String userId) {
//     log("📴 User went offline: $userId");
//   }
//
//   void exitGroup({required String groupId, Function(bool)? onCompletion}) {
//     if (userId != null) {
//       socketService.leaveGroup(groupId: groupId, userId: userId!);
//       joinedGroupIds.remove(groupId);
//       onCompletion?.call(true);
//     }
//   }
//
//   void deleteGroup({required String groupId, Function(bool)? onCompletion}) {
//     socketService.deleteGroup(groupId: groupId);
//     joinedGroupIds.remove(groupId);
//     onCompletion?.call(true);
//   }
//
//   void drawPolyline(List<LatLng> points) {
//     final polyline = Polyline(
//       polylineId: PolylineId("route"),
//       color: Colors.deepPurpleAccent,
//       width: 6,
//       points: points,
//       startCap: Cap.roundCap,
//       endCap: Cap.roundCap,
//       jointType: JointType.round,
//       patterns: [PatternItem.dash(20), PatternItem.gap(10)],
//     );
//     polylines.clear();
//     polylines.add(polyline);
//     polylines.refresh();
//   }
//
//   Future<void> clearSearchZoomOut() async {
//     if (mapController != null) {
//       await mapController!.animateCamera(CameraUpdate.zoomTo(11.0));
//     }
//   }
//
//   Future<void> searchUserAndZoom(String groupId, String userName) async {
//     final users = groupWiseUserData[groupId] ?? [];
//     final user = users.firstWhereOrNull((u) =>
//         u.name.toString().toLowerCase().contains(userName.toLowerCase()));
//
//     if (user != null) {
//       final matchedMarker = markers.firstWhere(
//         (m) => m.markerId.value == user.userId.toString(),
//       );
//
//       if (matchedMarker != null && mapController != null) {
//         await mapController!.animateCamera(
//           CameraUpdate.newLatLngZoom(matchedMarker.position, 18.5),
//         );
//       } else {
//         Get.snackbar("User Not Found", "Marker not available on map",
//             backgroundColor: Colors.redAccent, colorText: Colors.white);
//       }
//     } else {
//       Get.snackbar("User Not Found", "No user with name '$userName' found.",
//           backgroundColor: Colors.redAccent, colorText: Colors.white);
//     }
//   }
//
//   Future<void> searchAndFocusUser(String groupId, String name) async {
//     final users = groupWiseUserData[groupId] ?? [];
//     final user = users
//         .firstWhereOrNull((u) => u.name.toLowerCase() == name.toLowerCase());
//
//     if (user != null && mapController != null) {
//       await mapController!.animateCamera(
//         CameraUpdate.newLatLngZoom(
//             LatLng(user.latitude!, user.longitude!), 22.5),
//       );
//     } else {
//       Get.snackbar("User Not Found", "No user with name '$name' found.",
//           backgroundColor: Colors.redAccent, colorText: Colors.white);
//     }
//   }
//
//   void removeUserMarker(String userId) {
//     markers.removeWhere((m) => m.markerId.value == userId);
//     markers.refresh();
//   }
//
//   void showMarkersForGroup(String groupId) {
//     markers.clear();
//     final users = groupWiseUserData[groupId] ?? [];
//     for (var user in users) {
//       updateGroupMarker(user);
//     }
//   }
//
//   void _initSocketTracking(String groupId) {
//     if (_alreadyListeningGroupId == groupId) return;
//     _alreadyListeningGroupId = groupId;
//
//     socketService.onGroupLocationUpdateOff();
//     socketService.onGroupLocationUpdate((data) {
//       if (data["groupId"].toString() == groupId) {
//         final location = LocationData.fromJson(data);
//         updateGroupMarker(location);
//       }
//     });
//   }
//
//   void _loadInitialMarkers(String groupId) {
//     markers.clear();
//     final users = groupWiseUserData[groupId] ?? [];
//     for (var user in users) {
//       updateGroupMarker(user);
//     }
//   }
//
//   Future<void> updateGroupMarker(LocationData data) async {
//     final groupId = data.groupId.toString();
//     final profileImageUrl = data.profileImage?.toString() ?? '';
//     final bool isOnline = data.isOnline == true || data.isOnline == 1;
//
//     final groupList = groupWiseUserData[groupId] ?? [];
//     groupList.removeWhere((u) => u.userId.toString() == data.userId.toString());
//     groupList.add(data);
//     groupWiseUserData[groupId] = groupList;
//
//     try {
//       if (profileImageUrl.isNotEmpty) {
//         await precacheImage(
//           NetworkImage(Constant.ImagebaseUrl + profileImageUrl),
//           Get.context!,
//         );
//       }
//     } catch (e) {
//       log("❌ Failed to preload image: $e");
//     }
//
//     final icon = await getCustomIcon(profileImageUrl, isOnline);
//
//     final marker = Marker(
//       markerId: MarkerId(data.userId.toString()),
//       position: LatLng(data.latitude!, data.longitude!),
//       icon: icon,
//       onTap: () async {
//         Loading().showloading();
//         try {
//           final dest = LatLng(
//             double.tryParse(data.latitude.toString()) ?? 0.0,
//             double.tryParse(data.longitude.toString()) ?? 0.0,
//           );
//
//           if (locationService.currentPosition == null) {
//             Loading().dismissloading();
//             return;
//           }
//
//           final origin = LatLng(
//             locationService.currentPosition!.latitude!,
//             locationService.currentPosition!.longitude!,
//           );
//
//           final route = await Tracking().getWalkingRoute(origin, dest);
//           final vehicleRoute =
//               await Tracking().getWalkingRoute(origin, dest, mode: "driving");
//
//           if (route != null || vehicleRoute != null) {
//             Loading().dismissloading();
//             drawPolyline(Tracking().decodePolyline(route?["polyline"]));
//             DialogBox().showRouteDetailsBottomSheet(
//               route!,
//               vehicleRoute!,
//               destination: dest,
//               name: data.name,
//               imageUrl: profileImageUrl,
//               lastSeen: Tracking().getTimeAgo(DateTime.parse(data.lastSeen!)),
//             );
//           } else {
//             Loading().dismissloading();
//           }
//         } catch (e) {
//           log("Exception on tap: ${e.toString()}");
//           Loading().dismissloading();
//         }
//       },
//     );
//
//     markers.removeWhere((m) => m.markerId.value == data.userId.toString());
//     markers.add(marker);
//     markers.refresh();
//   }
//
//   void clearMapMarkers() {
//     polylines.clear();
//     markers.clear();
//     update();
//   }
// }
import 'dart:developer';
import 'dart:math' hide log;

import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../Core/values/Dialog/DialogBox.dart';
import '../../../Core/util/http/Constant.dart';
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

  final joinedGroupIds = <String>[].obs;
  final LocationService locationService = LocationService.instance;
  final SocketService socketService = SocketService.instance;
  GoogleMapController? mapController;

  final groupWiseUserData = <String, List<LocationData>>{}.obs;
  String? _alreadyListeningGroupId;

  Future<void> initSocketConnection() async {
    userId = Global.storageServices.get(Constant.userId).toString();
    await socketService.init(socketUrl);
  }

  void initializeLocation() {
    locationService.initLocationTracking();
  }

  void inItAllGroups({List<GroupData>? groups}) {
    initSocketConnection();
    for (var group in groups!) {
      if (group.isActive == true) {
        joinedGroupIds.add(group.id.toString());
        socketService.joinGroup(groupId: group.id.toString(), userId: userId!);
      }
    }

    socketService.onUserLeft((userId) => removeUserMarker(userId));
    socketService.onGroupDeleted((groupId) => deleteGroupMarker(groupId));
    socketService.onUserOffline((userId) => updateOfflineMarker(userId));
    initializeLocation();
  }

  void initGroupTracking(String groupId) {
    groupWiseUserData[groupId] = [];
    _initSocketTracking(groupId);
    _loadInitialMarkers(groupId);
  }

  Future<void> getGroupLocationData(BuildContext context, int groupId) async {
    try {
      Loading().showloading(context: context);
      var result = await TrackRepo.getUserLocationData(groupId);
      if (result.status == true) {
        Loading().dismissloading(context: context);
        for (var data in result.locations!) {
          updateGroupMarker(data);
        }
      } else {
        Loading().dismissloading(context: context);
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading(context: context);
      CommonDialog.errorMessage(e.toString());
    }
  }

  void deleteGroupMarker(String groupId) {
    groupWiseUserData.remove(groupId);
    markers.removeWhere((marker) {
      return groupWiseUserData[groupId]?.any(
              (user) => user.userId.toString() == marker.markerId.value) ??
          false;
    });
    joinedGroupIds.remove(groupId);
    markers.refresh();
  }

  void updateOfflineMarker(String userId) {
    log("📴 User went offline: $userId");
  }

  void exitGroup({required String groupId, Function(bool)? onCompletion}) {
    if (userId != null) {
      socketService.leaveGroup(groupId: groupId, userId: userId!);
      joinedGroupIds.remove(groupId);
      onCompletion?.call(true);
    }
  }

  void deleteGroup({required String groupId, Function(bool)? onCompletion}) {
    socketService.deleteGroup(groupId: groupId);
    joinedGroupIds.remove(groupId);
    onCompletion?.call(true);
  }

  Future<void> clearSearchZoomOut() async {
    if (mapController != null) {
      await mapController!.animateCamera(CameraUpdate.zoomTo(11.0));
    }
  }

  Future<void> searchUserAndZoom(String groupId, String userName) async {
    final users = groupWiseUserData[groupId] ?? [];
    final user = users.firstWhereOrNull((u) =>
        u.name.toString().toLowerCase().contains(userName.toLowerCase()));

    if (user != null) {
      final matchedMarker = markers.firstWhere(
        (m) => m.markerId.value == user.userId.toString(),
      );

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(matchedMarker.position, 18.5),
        );
      }
    } else {
      Get.snackbar("User Not Found", "No user with name '$userName' found.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> searchAndFocusUser(String groupId, String name) async {
    final users = groupWiseUserData[groupId] ?? [];
    final user = users
        .firstWhereOrNull((u) => u.name.toLowerCase() == name.toLowerCase());

    if (user != null && mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(user.latitude!, user.longitude!), 22.5),
      );
    } else {
      Get.snackbar("User Not Found", "No user with name '$name' found.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void removeUserMarker(String userId) {
    markers.removeWhere((m) => m.markerId.value == userId);
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
    socketService.onGroupLocationUpdate((data) {
      if (data["groupId"].toString() == groupId) {
        final location = LocationData.fromJson(data);
        updateGroupMarker(location);
      }
    });
  }

  void _loadInitialMarkers(String groupId) {
    markers.clear();
    final users = groupWiseUserData[groupId] ?? [];
    for (var user in users) {
      updateGroupMarker(user);
    }
  }

  Future<void> updateGroupMarker(LocationData data) async {
    final groupId = data.groupId.toString();
    final profileImageUrl = data.profileImage?.toString() ?? '';
    final bool isOnline = data.isOnline == true || data.isOnline == 1;

    final groupList = groupWiseUserData[groupId] ?? [];
    groupList.removeWhere((u) => u.userId.toString() == data.userId.toString());
    groupList.add(data);
    groupWiseUserData[groupId] = groupList;

    try {
      if (profileImageUrl.isNotEmpty) {
        await precacheImage(
          NetworkImage(Constant.ImagebaseUrl + profileImageUrl),
          Get.context!,
        );
      }
    } catch (e) {
      log("❌ Failed to preload image: $e");
    }

    final icon = await getCustomIcon(profileImageUrl, isOnline);

    final marker = Marker(
      markerId: MarkerId(data.userId.toString()),
      position: LatLng(data.latitude!, data.longitude!),
      icon: icon,
      onTap: () async {
        if (locationService.currentPosition == null) return;

        final dest = LatLng(data.latitude!, data.longitude!);
        final origin = LatLng(
          locationService.currentPosition!.latitude!,
          locationService.currentPosition!.longitude!,
        );

        final distanceKm = _calculateDistance(
          origin.latitude,
          origin.longitude,
          dest.latitude,
          dest.longitude,
        );

        DialogBox().showRouteDetailsBottomSheet(
          destination: dest,
          distance: distanceKm,
          name: data.name,
          imageUrl: profileImageUrl,
          lastSeen: Tracking().getTimeAgo(DateTime.parse(data.lastSeen!)),
        );
        // showSimpleDistanceSheet(
        //    // name: data.name,
        //    // imageUrl: profileImageUrl,
        //    // distanceKm: distanceKm,
        //    // lastSeen: Tracking().getTimeAgo(DateTime.parse(data.lastSeen!)),
        //   context:  Get.context!,
        //   name: data.name,
        //   profileImage: profileImageUrl,
        //   distanceKm: 2.4,
        //   estimatedTime: Tracking().getTimeAgo(DateTime.parse(data.lastSeen!)),
        //    onGetDirections: () async {
        //      Loading().showloading();
        //      try {
        //        final route =
        //        await Tracking().getWalkingRoute(origin, dest, mode: "driving");
        //        Loading().dismissloading();
        //
        //        if (route != null) {
        //          DialogBox().showRouteDetailsBottomSheet(
        //            route,
        //            {},
        //            distance: dest,
        //            name: data.name,
        //            imageUrl: profileImageUrl,
        //            lastSeen:
        //            Tracking().getTimeAgo(DateTime.parse(data.lastSeen!)),
        //          );
        //        }
        //      } catch (e) {
        //        Loading().dismissloading();
        //        log("❌ Directions failed: $e");
        //      }
        //    },
        //  );
      },
    );

    markers.removeWhere((m) => m.markerId.value == data.userId.toString());
    markers.add(marker);
    markers.refresh();
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
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

  void clearMapMarkers() {
    markers.clear();
    update();
  }
}
