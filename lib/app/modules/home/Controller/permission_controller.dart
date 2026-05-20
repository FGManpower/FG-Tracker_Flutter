import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  final Location _location = Location();

  /// 0 = Ask Permission
  /// 1 = Enable GPS
  /// 2 = Done
  RxInt step = 0.obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    int initialStep = await getStartingStep();
    step.value = initialStep;
  }

  Future<int> getStartingStep() async {
    final locationWhenInUse =
    await Permission.locationWhenInUse.status;

    final locationAlways =
    await Permission.locationAlways.status;

    bool isLocationGranted =
        locationWhenInUse.isGranted &&
            locationAlways.isGranted;

    if (Platform.isIOS) {
      LocationPermission permission =
      await Geolocator.checkPermission();

      isLocationGranted =
          permission == LocationPermission.always;
    }

    if (!isLocationGranted) return 0;

    final gpsEnabled = await _location.serviceEnabled();

    if (!gpsEnabled) return 1;

    return 2;
  }

  Future<void> requestStepWisePermission() async {
    int currentStep = step.value;

    /// STEP 0 -> LOCATION PERMISSION
    if (currentStep == 0) {
      if (Platform.isAndroid) {
        final whenInUse =
        await Permission.locationWhenInUse.request();

        if (whenInUse.isGranted) {
          final always =
          await Permission.locationAlways.request();

          if (always.isGranted) {
            step.value = 1;
          } else if (always.isPermanentlyDenied) {
            await openAppSettings();
          }
        } else if (whenInUse.isPermanentlyDenied) {
          await openAppSettings();
        }
      } else {
        LocationPermission permission =
        await Geolocator.requestPermission();

        if (permission == LocationPermission.always) {
          step.value = 1;
        } else if (permission ==
            LocationPermission.whileInUse ||
            permission ==
                LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }
      }
    }

    /// STEP 1 -> ENABLE GPS
    else if (currentStep == 1) {
      final gpsEnabled = await _location.serviceEnabled();

      if (!gpsEnabled) {
        bool requested =
        await _location.requestService();

        if (requested) {
          step.value = 2;
        }
      } else {
        step.value = 2;
      }
    }
  }
}