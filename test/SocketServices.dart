// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:fgtracker/app/Core/values/global.dart';
// import 'package:fgtracker/app/Core/values/loading.dart';
// import 'package:fgtracker/app/Data/Services/Tracking.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:location/location.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../../../Core/util/http/Constant.dart';
// import '../../../Core/values/Context_Utility.dart';
// import '../../../Core/values/Dialog/Common_dialog.dart';
// import '../../../Core/values/Dialog/DialogBox.dart';
// import '../Widget/Track_widget.dart';
// import 'package:permission_handler/permission_handler.dart' as ph;
//
// class TrackingService extends GetxService {
//   static TrackingService get instance => Get.find<TrackingService>();
//
//   final markers = <Marker>{}.obs;
//   final polylines = <Polyline>{}.obs;
//   final isLoading = false.obs;
//
//   GoogleMapController? _mapController;
//   LocationData? currentPosition; // Replaced Position with LocationData
//   StreamSubscription<LocationData>? _positionStream;
//   IO.Socket? _socket;
//
//   String? _groupId;
//   String? _userId;
//
//   IO.Socket get socket {
//     if (_socket == null) {
//       log("⚠️ Socket accessed before initialization");
//       throw Exception("Socket not initialized");
//     }
//     return _socket!;
//   }
//
//   bool get isSocketConnected => _socket?.connected == true;
//
//   set mapController(GoogleMapController controller) {
//     _mapController = controller;
//   }
//
//   Future<void> init() async {
//     _initSocket();
//     await _initLocationTracking();
//   }
//
//   void setActiveGroup(String groupId, String userId) {
//     _groupId = groupId;
//     _userId = userId;
//
//     if (isSocketConnected) {
//       _socket?.emit("join-group", {
//         "groupId": groupId,
//         "userId": userId,
//       });
//     }
//   }
//
//   void _initSocket() {
//     _socket = IO.io(socketUrl, {
//       "transports": ["websocket"],
//       "autoConnect": true,
//     });
//
//     _socket?.onConnect((_) {
//       log("✅ Socket connected");
//       if (_groupId != null && _userId != null) {
//         _socket?.emit("join-group", {
//           "groupId": _groupId,
//           "userId": _userId,
//         });
//       }
//     });
//
//     _socket?.on("group-location-update", (data) {
//       if (data is List) {
//         for (var item in data) {
//           if (item["userId"].toString() != _userId) {
//             _updateGroupMarker(item);
//           }
//         }
//       } else if (data is Map && data["userId"].toString() != _userId) {
//         _updateGroupMarker(data);
//       }
//     });
//
//     _socket?.on("user-left", (data) {
//       final String removedUserId = data["userId"];
//       markers.removeWhere((m) => m.markerId.value == removedUserId);
//       markers.refresh();
//     });
//
//     _socket?.on("group-deleted", (data) {
//       if (data != null && data["groupId"] != null) {
//         final String groupId = data["groupId"];
//
//         markers.removeWhere((m) => _groupId == groupId);
//         polylines.removeWhere((m) => _groupId==groupId,);
//         markers.refresh();
//         polylines.refresh();
//
//       }
//     });
//
//
//
//     _socket?.on("user-offline", (data) {
//       // final String userId = data["userId"];
//       // final double? lat = double.tryParse(data["lat"]?.toString() ?? '');
//       // final double? lng = double.tryParse(data["lng"]?.toString() ?? '');
//       // final String? lastSeen = data["lastSeen"];
//       // final String? name = data["name"];
//       // final String? profileImage = data["ProfileImage"];
//       // final bool isOnline = data["isOnline"] ?? false;
//       //
//       // if (lat != null && lng != null) {
//       //   _updateGroupMarker({
//       //     "userId": userId,
//       //     "lat": lat,
//       //     "lng": lng,
//       //     "lastSeen": lastSeen,
//       //     "name": name,
//       //     "ProfileImage": profileImage,
//       //     "isOnline": isOnline,
//       //   });
//       // }
//
//       markers.refresh();
//     });
//
//     // _socket?.on("user-offline", (data) {
//     //   final String removedUserId = data["userId"];
//     //   markers.removeWhere((m) => m.markerId.value == removedUserId);
//     //   markers.refresh();
//     // });
//
//     _socket?.onDisconnect((_) => log("❌ Socket disconnected"));
//     _socket?.onError((err) => log("❌ Socket error: $err"));
//   }
//
//   void _emitLocation(LocationData location) {
//     if (isSocketConnected && _groupId != null && _userId != null) {
//       _socket?.emit("send-location", {
//         "groupId": _groupId,
//         "userId": _userId,
//         "lat": location.latitude,
//         "lng": location.longitude,
//       });
//     }
//   }
//
//   void exitGroup(String groupId, {Function(bool)? onCompletion}) {
//     socket.emit('leave-group', {
//       'groupId': groupId,
//       'userId': Global.storageServices.get(PrefConst.userId),
//     });
//     _groupId = null;
//     onCompletion!(true);
//   }
//
//   void deleteGroup(String groupId, {Function(bool)? onCompletion}) {
//     socket.emit('delete-group', {
//       'groupId': groupId,
//     });
//     _groupId = null;
//     onCompletion!(true);
//   }
//
//   void _listenToLocationUpdates() {
//     _positionStream?.cancel();
//     _positionStream = Location().onLocationChanged.listen((location) {
//       currentPosition = location;
//       _updateMyMarker(location);
//       _emitLocation(location);
//     });
//   }
//
//   Future<void> _initLocationTracking() async {
//     final hasPermission = await handleLocationPermission();
//     if (!hasPermission) {
//       log("Permission not granted.");
//       return;
//     }
//
//     bool serviceEnabled = await Location().serviceEnabled();
//     if (!serviceEnabled) {
//       await Location().requestService();
//       return;
//     }
//     Location().enableBackgroundMode(enable: true);
//     try {
//       isLoading.value = true;
//       currentPosition = await Location().getLocation();
//       _listenToLocationUpdates();
//     } catch (e) {
//       log("Error getting initial location: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<bool> handleLocationPermission() async {
//     ph.PermissionStatus permission = await Permission.location.status;
//
//     if (permission.isDenied || permission.isPermanentlyDenied) {
//       Completer<bool> completer = Completer();
//
//       CommonDialog.ConfirmationDialog(
//         icon: Icons.location_on_outlined,
//         cancel: "Cancel",
//         confirm: "Settings",
//         onConfirm: () async {
//           Navigator.pop(ContextUtility.context!);
//           await openAppSettings();
//           completer.complete(false);
//         },
//         onCancel: () {
//           Navigator.pop(ContextUtility.context!);
//           completer.complete(false);
//         },
//         title: Platform.isIOS
//             ? "Allow Location Access"
//             : "Location Permission Required",
//         content: Platform.isIOS
//             ? "This app requires access to your location. Please enable it in settings."
//             : "Please allow location access from settings.",
//       );
//
//       return completer.future;
//     }
//
//     if (Platform.isAndroid) {
//       ph.PermissionStatus backgroundPermission =
//       await Permission.locationAlways.status;
//
//       if (backgroundPermission.isDenied ||
//           backgroundPermission.isPermanentlyDenied) {
//         Completer<bool> completer = Completer();
//         CommonDialog.ConfirmationDialog(
//           icon: Icons.location_on_outlined,
//           cancel: "Cancel",
//           confirm: "Settings",
//           onConfirm: () async {
//             Navigator.pop(ContextUtility.context!);
//             await openAppSettings();
//             completer.complete(false);
//           },
//           onCancel: () {
//             Navigator.pop(ContextUtility.context!);
//             completer.complete(false);
//           },
//           title: "Background Location Permission Required",
//           content: "Please allow background location access from settings.",
//         );
//         return completer.future;
//       }
//     }
//
//     return true;
//   }
//
//   void _updateMyMarker(LocationData location) {
//     // _mapController?.animateCamera(CameraUpdate.newLatLng(
//     //   LatLng(location.latitude!, location.longitude!),
//     // ));
//   }
//
//   void _updateGroupMarker(dynamic data) async {
//     log("-------------UserData----------${data}");
//     final profileImageUrl = ConstRes.aImageBaseUrl + (data["ProfileImage"] ?? "");
//     final bool isOnline = data["isOnline"] == false;
//
//     final icon = await getCustomIcon(profileImageUrl, isOnline);
//
//     final marker = Marker(
//       markerId: MarkerId(data["userId"].toString()),
//       position: LatLng(data["lat"], data["lng"]),
//       icon: icon,
//       onTap: () async {
//         Loading().showloading();
//         try {
//           final dest = LatLng(data["lat"], data["lng"]);
//           final origin = LatLng(currentPosition!.latitude!, currentPosition!.longitude!);
//           final route = await Tracking().getWalkingRoute(origin, dest);
//
//           if (route != null) {
//             Loading().dismissloading();
//             drawPolyline(Tracking().decodePolyline(route["polyline"]));
//             DialogBox().showRouteDetailsBottomSheet(route,
//                 destination: LatLng(data["lat"], data["lng"]),
//                 name: data["name"],
//                 imageUrl: profileImageUrl,
//                 status: isOnline,
//                 lastSeen:
//                 Tracking().getTimeAgo(DateTime.parse(data['lastSeen'])));
//
//             // _showDirectionSheet();
//           } else {
//             log("elseException---------:}");
//             Loading().dismissloading();
//           }
//         } catch (e) {
//           log("Exception---------:${e.toString()}");
//           Loading().dismissloading();
//         }
//       },
//     );
//
//     markers.removeWhere((m) => m.markerId.value == data["userId"].toString());
//     markers.add(marker);
//     markers.refresh();
//   }
//
//   void drawPolyline(List<LatLng> points) {
//     final polyline = Polyline(
//       polylineId: const PolylineId("route"),
//       color: Colors.deepPurpleAccent, // Professional, clean color
//       width: 6,
//       points: points,
//       startCap: Cap.roundCap,
//       endCap: Cap.roundCap,
//       jointType: JointType.round,
//       patterns: [
//         PatternItem.dash(20),
//         PatternItem.gap(10),
//       ],
//     );
//
//     polylines.clear(); // If you're only showing one route at a time
//     polylines.add(polyline);
//     polylines.refresh(); // If polylines is RxSet
//   }
//
//   @override
//   void onClose() {
//     _positionStream?.cancel();
//     _socket?.dispose();
//     super.onClose();
//   }
// }
//
//
//
//
//
// _socket?.on("user-offline", (data) {
//
// markers.refresh();
// });