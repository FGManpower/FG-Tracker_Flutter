import 'dart:async';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

import 'permission_gate_models.dart';

/// Where the "is this permission compulsory?" switches come from.
abstract class PermissionFlagsSource {
  /// Must never throw; falls back to [PermissionFlags.defaults].
  Future<PermissionFlags> load();
}

/// Firebase Remote Config switches (Firebase Console → Remote Config):
///
/// | key                            | type    | default |
/// |--------------------------------|---------|---------|
/// | `require_location_android`     | boolean | true    |
/// | `require_location_ios`         | boolean | true    |
/// | `require_notification_android` | boolean | true    |
/// | `require_notification_ios`     | boolean | true    |
///
/// false → the permission is still requested but no longer blocks the app.
/// Offline / fetch failure → last fetched values, or the defaults (true).
class RemoteConfigPermissionFlagsSource implements PermissionFlagsSource {
  static const String requireLocationAndroid = 'require_location_android';
  static const String requireLocationIos = 'require_location_ios';
  static const String requireNotificationAndroid =
      'require_notification_android';
  static const String requireNotificationIos = 'require_notification_ios';

  static const Duration fetchTimeout = Duration(seconds: 5);
  static const Duration minimumFetchInterval = Duration(hours: 1);

  @override
  Future<PermissionFlags> load() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setDefaults(const {
        requireLocationAndroid: true,
        requireLocationIos: true,
        requireNotificationAndroid: true,
        requireNotificationIos: true,
      });
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: fetchTimeout,
        minimumFetchInterval: minimumFetchInterval,
      ));

      try {
        await rc
            .fetchAndActivate()
            .timeout(fetchTimeout + const Duration(seconds: 1));
      } catch (e) {
        // Offline / throttled: keep last activated values or defaults.
        log('[PermissionGate] remote config fetch failed: $e');
      }

      final ios = GetPlatform.isIOS;
      final flags = PermissionFlags(
        requireLocation:
            rc.getBool(ios ? requireLocationIos : requireLocationAndroid),
        requireNotification: rc
            .getBool(ios ? requireNotificationIos : requireNotificationAndroid),
      );
      log('[PermissionGate] flags: $flags');
      return flags;
    } catch (e) {
      log('[PermissionGate] remote config unavailable, using defaults: $e');
      return PermissionFlags.defaults;
    }
  }
}
