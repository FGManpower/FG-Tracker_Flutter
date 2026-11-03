import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import 'permission_gate_models.dart';

/// The only place that talks to permission plugins. Everything above it
/// (gate service, screens) works on [PermissionSnapshot]s, so tests can swap
/// in a fake backend.
abstract class PermissionBackend {
  /// Reads the current device state. May throw if a plugin fails.
  Future<PermissionSnapshot> snapshot();

  /// Asks for "While using the app" (first location dialog).
  Future<void> requestLocationWhenInUse();

  /// Asks for "Allow all the time". Android 10: dialog, Android 11+: opens the
  /// app's location settings page. iOS: only works once, before the user has
  /// answered the upgrade prompt — afterwards the caller must send the user
  /// to Settings.
  Future<void> requestLocationAlways();

  /// Android 12+: re-asks so the user can switch Approximate → Precise.
  /// iOS 14+: requests temporary full accuracy for this session.
  Future<void> requestPreciseLocation();

  /// Android: in-app "turn on location" dialog. Returns false when it could
  /// not be turned on from inside the app.
  Future<bool> requestLocationService();

  Future<void> requestNotification();

  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();

  /// Optional permissions (camera, microphone, contacts…).
  Future<PermissionStatus> status(Permission permission);
  Future<PermissionStatus> request(Permission permission);

  bool get isIOS;
}

class PluginPermissionBackend implements PermissionBackend {
  final loc.Location _location = loc.Location();

  /// Purpose key in Info.plist → NSLocationTemporaryUsageDescriptionDictionary.
  static const String preciseLocationPurposeKey = 'PreciseLocation';

  @override
  bool get isIOS => GetPlatform.isIOS;

  @override
  Future<PermissionSnapshot> snapshot() async {
    LocationLevel level;
    bool locationPermDenied = false;
    bool alwaysPermDenied = false;

    if (isIOS) {
      final p = await Geolocator.checkPermission();
      switch (p) {
        case LocationPermission.always:
          level = LocationLevel.always;
          break;
        case LocationPermission.whileInUse:
          level = LocationLevel.whileInUse;
          break;
        case LocationPermission.deniedForever:
          level = LocationLevel.none;
          locationPermDenied = true;
          break;
        default:
          level = LocationLevel.none;
      }
    } else {
      final whenInUse = await Permission.locationWhenInUse.status;
      final always = await Permission.locationAlways.status;
      if (whenInUse.isGranted && always.isGranted) {
        level = LocationLevel.always;
      } else if (whenInUse.isGranted) {
        level = LocationLevel.whileInUse;
        alwaysPermDenied = always.isPermanentlyDenied || always.isRestricted;
      } else {
        level = LocationLevel.none;
        locationPermDenied =
            whenInUse.isPermanentlyDenied || whenInUse.isRestricted;
      }
    }

    final serviceOn = await Geolocator.isLocationServiceEnabled();

    bool precise = false;
    if (level != LocationLevel.none) {
      try {
        precise = await Geolocator.getLocationAccuracy() ==
            LocationAccuracyStatus.precise;
      } catch (e) {
        // Accuracy API unavailable (old OS / plugin issue): don't lock the
        // user out because of it.
        log('[PermissionGate] accuracy check failed: $e');
        precise = true;
      }
    }

    final notif = await Permission.notification.status;
    // iOS provisional authorization intentionally does NOT count.
    final notifGranted = notif.isGranted;
    final notifPermDenied = notif.isPermanentlyDenied || notif.isRestricted;

    return PermissionSnapshot(
      locationLevel: level,
      locationPermanentlyDenied: locationPermDenied,
      alwaysPermanentlyDenied: alwaysPermDenied,
      locationServiceOn: serviceOn,
      preciseLocation: precise,
      notificationGranted: notifGranted,
      notificationPermanentlyDenied: notifPermDenied,
    );
  }

  @override
  Future<void> requestLocationWhenInUse() async {
    if (isIOS) {
      // geolocator asks for Always when the Always key exists in Info.plist
      // (iOS shows "While using" first and offers the upgrade later).
      await Geolocator.requestPermission();
    } else {
      await Permission.locationWhenInUse.request();
    }
  }

  @override
  Future<void> requestLocationAlways() async {
    if (isIOS) {
      // Returns immediately if iOS already decided — caller then shows the
      // "Open Settings → Location → Always" dialog.
      await Geolocator.requestPermission();
    } else {
      await Permission.locationAlways.request();
    }
  }

  @override
  Future<void> requestPreciseLocation() async {
    if (isIOS) {
      await Geolocator.requestTemporaryFullAccuracy(
        purposeKey: preciseLocationPurposeKey,
      );
    } else {
      // Requesting FINE again shows the Android 12+ "Precise" upgrade dialog.
      await Permission.locationWhenInUse.request();
    }
  }

  @override
  Future<bool> requestLocationService() async {
    if (isIOS) return false; // iOS has no in-app dialog for this.
    try {
      if (await _location.serviceEnabled()) return true;
      return await _location.requestService();
    } catch (e) {
      log('[PermissionGate] requestService failed: $e');
      return false;
    }
  }

  @override
  Future<void> requestNotification() async {
    await Permission.notification.request();
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => isIOS
      ? Geolocator.openAppSettings()
      : Geolocator.openLocationSettings();

  @override
  Future<PermissionStatus> status(Permission permission) => permission.status;

  @override
  Future<PermissionStatus> request(Permission permission) =>
      permission.request();
}
