import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';

import 'package:fgtracker/app/Data/Services/LocationPermission.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

import 'package:geocoding/geocoding.dart' hide Location;
import 'package:fgtracker/app/modules/Track/Controller/Track_controller.dart';
import '../../../Core/values/Context_Utility.dart';
import 'TrackController.dart';

class LocationService extends GetxService {
  static LocationService get instance => Get.put(LocationService());

  final Location _location = Location();
  LocationData? currentPosition;
  StreamSubscription<LocationData>? _positionStream;
  bool get isLocationEnabled => currentPosition != null;
  final SocketService socketService = SocketService.instance;


  Future<void> initLocationTracking() async {
    final hasPermission = await LocationPermissions().handleLocationPermission();
    bool serviceEnabled = await _location.serviceEnabled();

    if (hasPermission) {
      log("ServiceEnable--------$serviceEnabled");
      if (serviceEnabled==false) {
        Completer<void> completer = Completer<void>();

        CommonDialog.ConfirmationDialog(
          icon: Icons.gps_off,
          cancel: "Cancel",
          confirm: "Enable",
          onConfirm: () async {
            Navigator.pop(ContextUtility.context!);
            bool requested = await _location.requestService();
            if (requested) {
              completer.complete();

            } else {
              completer.completeError("GPS not enabled");
            }
          },
          onCancel: () {
            Navigator.pop(ContextUtility.context!);
            completer.completeError("User cancelled GPS enable dialog");
          },
          title: "Enable GPS",
          content: "To track your group in real time, please turn on your GPS.",
        );

        try {
          await completer.future;
          await _location.enableBackgroundMode(enable: true);
          Future.delayed(Duration(seconds: 2),() {
            _listenToLocationUpdates(
              Global.storageServices
                  .get(PrefConst.userId)
                  .toString(),
            );
          },);



        } catch (e) {
          log("GPS Enable Canceled or Failed: $e");
          return;
        }
      } else {

        try {
          // Loading().showloading();
          await _location.enableBackgroundMode(enable: true);
          _listenToLocationUpdates(Global.storageServices.get(PrefConst.userId).toString());
          // Loading().dismissloading();
        } catch (e) {
          // Loading().dismissloading();
        }
      }
    } else {
     log("Permission Denied");
    }
  }




  void _listenToLocationUpdates(String userId) {
    _positionStream?.cancel();
    _positionStream = _location.onLocationChanged.listen((location) async {
      currentPosition = location;

      if (!TrackingController.instance.isLocationSharing.value) {
        log("Ghost Mode Enabled - Location not shared");
        return;
      }

      final lat = currentPosition?.latitude;
      final lng = currentPosition?.longitude;

      if (lat == null || lng == null) return;

      String? address;
      String? area;
      String? city;

      // 1. Pull from TrackController if already resolved
      if (Get.isRegistered<TrackController>()) {
        final trackCtrl = Get.find<TrackController>();
        if (trackCtrl.currentLocationName.value != "Locating..." &&
            trackCtrl.currentLocationName.value != "Current Location") {
          address = trackCtrl.currentLocationName.value;
        }
        if (trackCtrl.currentArea.value.isNotEmpty) {
          area = trackCtrl.currentArea.value;
        }
        if (trackCtrl.currentCity.value.isNotEmpty) {
          city = trackCtrl.currentCity.value;
        }
      }

      if (area == null || area.isEmpty) {
        try {
          final placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            area = (p.subLocality?.trim().isNotEmpty == true
                ? p.subLocality!.trim()
                : (p.thoroughfare?.trim().isNotEmpty == true
                    ? p.thoroughfare!.trim()
                    : p.subAdministrativeArea?.trim())) ?? '';
            city = (p.locality?.trim().isNotEmpty == true
                ? p.locality!.trim()
                : p.administrativeArea?.trim()) ?? '';
            if (address == null || address.isEmpty) {
              address = area.isNotEmpty && city.isNotEmpty
                  ? '$area, $city'
                  : (area.isNotEmpty ? area : city);
            }
          }
        } catch (_) {}
      }

      socketService.emitLocation(
        userId,
        lat,
        lng,
        address: address,
        area: area,
        city: city,
      );
    });
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    super.onClose();
  }
}
