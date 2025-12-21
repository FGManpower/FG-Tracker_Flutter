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

import '../../../Core/values/Context_Utility.dart';

class LocationService extends GetxService {
  static LocationService get instance => Get.put(LocationService());

  final Location _location = Location();
  LocationData? currentPosition;
  StreamSubscription<LocationData>? _positionStream;
  bool get isLocationEnabled => currentPosition != null;
  final SocketService socketService = SocketService.instance;


  Future<void> initLocationTracking({String? groupId}) async {
    final hasPermission = await LocationPermissions().handleLocationPermission();
    bool serviceEnabled = await _location.serviceEnabled();

    if (hasPermission) {
      log("ServiceEnable--------${serviceEnabled}");
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
        } catch (e) {
          log("GPS Enable Canceled or Failed: $e");
          return;
        }
      } else {

        try {
          // Loading().showloading();
          await _location.enableBackgroundMode(enable: true);


          _listenToLocationUpdates(
              Global.storageServices.get(PrefConst.userId).toString());
          // Loading().dismissloading();

        } catch (e) {
          // Loading().dismissloading();

        }
      }
    } else {
     log("Permission Denied");
    }
  }

  void _listenToLocationUpdates( String userId) {
    _positionStream?.cancel();
    _positionStream = _location.onLocationChanged.listen((location) {
      currentPosition = location;
      socketService.emitLocation( userId, currentPosition!.latitude,
          currentPosition!.longitude);
    });
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    super.onClose();
  }
}
