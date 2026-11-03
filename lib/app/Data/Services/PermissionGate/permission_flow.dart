import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'permission_gate_models.dart';
import 'permission_gate_service.dart';

/// User-facing reasons (one line each, shown before every system dialog).
class PermissionReasons {
  static const String location =
      'Location is needed for attendance, live tracking and safe zone alerts.';
  static const String locationAlways =
      'Choose "Allow all the time" so live tracking and safe zone keep working '
      'when the app is in the background.';
  static const String precise =
      'Precise location is needed for accurate attendance, live tracking and '
      'safe zone alerts.';
  static const String notification =
      'Notifications are needed to receive incoming calls, chat messages, '
      'attendance and safe-zone alerts.';
}

/// Drives the compulsory-permission requests step by step. One tap = one
/// step = at most one system dialog, always preceded by a one-line reason.
/// Shared by the onboarding screen and the blocking screen.
class PermissionFlow {
  PermissionFlow(this.gate);

  final PermissionGateService gate;

  // Repeated "nothing happened" answers → send the user to Settings instead
  // of looping (e.g. Android ≤12 notifications, OEM quirks).
  final Map<String, int> _attempts = {};

  static const Color _brand = Color(0xFF6C5DD3);
  static const Color _navy = Color(0xFF11145A);
  static const Color _grey = Color(0xFF686B9D);

  // ----------------------------------------------------------------- location

  /// Label for the location action button for the current state.
  static String locationActionLabel(LocationStep step) {
    switch (step) {
      case LocationStep.done:
        return 'Continue';
      case LocationStep.grantPermission:
        return 'Allow Location';
      case LocationStep.grantAlways:
        return 'Allow All The Time';
      case LocationStep.turnOnService:
        return 'Turn On Location';
      case LocationStep.grantPrecise:
        return 'Turn On Precise Location';
      case LocationStep.openSettings:
        return 'Open Settings';
    }
  }

  static String locationStatusText(LocationStep step) {
    switch (step) {
      case LocationStep.done:
        return 'Allowed all the time · Precise · GPS on';
      case LocationStep.grantPermission:
        return 'Location permission not allowed yet.';
      case LocationStep.grantAlways:
        return '"Allow all the time" is required.';
      case LocationStep.turnOnService:
        return 'Device location (GPS) is turned off.';
      case LocationStep.grantPrecise:
        return 'Only approximate location is allowed. Precise is required.';
      case LocationStep.openSettings:
        return 'Location is blocked. Enable it from Settings.';
    }
  }

  Future<PermissionGateResult> fixLocation() {
    return gate.runExclusive(() async {
      var r = await gate.check();
      final step = r.locationStep;
      final backend = gate.backend;

      switch (step) {
        case LocationStep.done:
          return r;

        case LocationStep.grantPermission:
          if (!await _rationale(Icons.location_on_rounded, 'Allow Location',
              PermissionReasons.location)) {
            return r;
          }
          await backend.requestLocationWhenInUse();
          r = await gate.check();
          if (r.locationStep == LocationStep.openSettings) {
            await _settingsDialog(Icons.location_on_rounded,
                _locationSettingsText(LocationStep.grantPermission));
          } else if (r.locationStep == LocationStep.grantPermission) {
            await _noProgress('location', Icons.location_on_rounded,
                'Location permission is required to continue.',
                _locationSettingsText(LocationStep.grantPermission));
          }
          break;

        case LocationStep.grantAlways:
          if (!await _rationale(Icons.my_location_rounded,
              'Allow All The Time', PermissionReasons.locationAlways)) {
            return r;
          }
          await backend.requestLocationAlways();
          r = await gate.check();
          if (r.locationStep == LocationStep.grantAlways ||
              r.locationStep == LocationStep.openSettings) {
            if (backend.isIOS || r.locationStep == LocationStep.openSettings) {
              // iOS offers the "Always" upgrade only once; afterwards only
              // Settings can do it.
              await _settingsDialog(Icons.my_location_rounded,
                  _locationSettingsText(LocationStep.grantAlways));
            } else {
              await _noProgress(
                  'always',
                  Icons.my_location_rounded,
                  'Please select "Allow all the time" to continue.',
                  _locationSettingsText(LocationStep.grantAlways));
            }
          }
          break;

        case LocationStep.turnOnService:
          if (backend.isIOS) {
            await _settingsDialog(
              Icons.gps_fixed_rounded,
              'Location Services are turned off. Open Settings → Privacy & '
              'Security → Location Services and turn it on, then come back.',
            );
          } else {
            final on = await backend.requestLocationService();
            if (!on) await backend.openLocationSettings();
          }
          r = await gate.check();
          break;

        case LocationStep.grantPrecise:
          if (!await _rationale(Icons.gps_fixed_rounded, 'Precise Location',
              PermissionReasons.precise)) {
            return r;
          }
          await backend.requestPreciseLocation();
          r = await gate.check();
          if (r.locationStep == LocationStep.grantPrecise) {
            await _settingsDialog(Icons.gps_fixed_rounded,
                _locationSettingsText(LocationStep.grantPrecise));
          }
          break;

        case LocationStep.openSettings:
          await _settingsDialog(Icons.location_on_rounded,
              _locationSettingsText(LocationStep.grantPermission));
          break;
      }
      return r;
    });
  }

  String _locationSettingsText(LocationStep step) {
    final ios = gate.backend.isIOS;
    switch (step) {
      case LocationStep.grantAlways:
        return ios
            ? 'Open Settings → Location and choose "Always". '
                '${PermissionReasons.locationAlways}'
            : 'Open Settings → Permissions → Location and choose '
                '"Allow all the time".';
      case LocationStep.grantPrecise:
        return ios
            ? 'Open Settings → Location and turn on "Precise Location".'
            : 'Open Settings → Permissions → Location and turn on '
                '"Use precise location".';
      default:
        return ios
            ? 'Location access is turned off for FG Tracker. Open Settings → '
                'Location and choose "Always".'
            : 'Location access is blocked for FG Tracker. Open Settings → '
                'Permissions → Location and choose "Allow all the time".';
    }
  }

  // ------------------------------------------------------------ notification

  static String notificationActionLabel(NotificationStep step) {
    switch (step) {
      case NotificationStep.done:
        return 'Continue';
      case NotificationStep.grantPermission:
        return 'Allow Notifications';
      case NotificationStep.openSettings:
        return 'Open Settings';
    }
  }

  static String notificationStatusText(NotificationStep step) {
    switch (step) {
      case NotificationStep.done:
        return 'Allowed';
      case NotificationStep.grantPermission:
        return 'Notification permission not allowed yet.';
      case NotificationStep.openSettings:
        return 'Notifications are blocked. Enable them from Settings.';
    }
  }

  static const String _notificationSettingsText =
      'Notifications are turned off for FG Tracker. Open Settings → '
      'Notifications and allow them. ${PermissionReasons.notification}';

  Future<PermissionGateResult> fixNotification() {
    return gate.runExclusive(() async {
      var r = await gate.check();
      switch (r.notificationStep) {
        case NotificationStep.done:
          return r;
        case NotificationStep.openSettings:
          await _settingsDialog(
              Icons.notifications_rounded, _notificationSettingsText);
          return r;
        case NotificationStep.grantPermission:
          if (!await _rationale(Icons.notifications_rounded,
              'Allow Notifications', PermissionReasons.notification)) {
            return r;
          }
          await gate.backend.requestNotification();
          r = await gate.check();
          if (r.notificationStep == NotificationStep.openSettings) {
            await _settingsDialog(
                Icons.notifications_rounded, _notificationSettingsText);
          } else if (r.notificationStep == NotificationStep.grantPermission) {
            await _noProgress(
                'notification',
                Icons.notifications_rounded,
                'Notification permission is required to continue.',
                _notificationSettingsText);
          }
          return r;
      }
    });
  }

  /// Opens app settings directly (blocking screen "Open Settings" button).
  Future<void> openSettings() => gate.backend.openAppSettings();

  // ------------------------------------------------------------------ dialogs

  Future<void> _noProgress(
    String key,
    IconData icon,
    String message,
    String settingsText,
  ) async {
    final n = (_attempts[key] ?? 0) + 1;
    _attempts[key] = n;
    if (n >= 2) {
      _attempts[key] = 0;
      await _settingsDialog(icon, settingsText);
    } else {
      showMessage(message);
    }
  }

  Future<bool> _rationale(IconData icon, String title, String reason) async {
    final ok = await _dialog(
      icon: icon,
      title: title,
      message: reason,
      primary: 'Continue',
      secondary: 'Not Now',
    );
    return ok == true;
  }

  Future<void> _settingsDialog(IconData icon, String message) async {
    final ok = await _dialog(
      icon: icon,
      title: 'Permission Required',
      message: message,
      primary: 'Open Settings',
      secondary: 'Cancel',
    );
    if (ok == true) await gate.backend.openAppSettings();
  }

  static void showMessage(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool?> _dialog({
    required IconData icon,
    required String title,
    required String message,
    required String primary,
    required String secondary,
  }) async {
    final context = Get.context;
    if (context == null) return null;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brand.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: _brand, size: 30.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5.sp, height: 1.45, color: _grey),
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brand,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          side: BorderSide(
                            color: _brand.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            secondary,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            primary,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w700),
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
    );
  }
}
