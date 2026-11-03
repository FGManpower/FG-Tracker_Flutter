/// Models + pure evaluation logic for the compulsory-permission gate.
///
/// Kept free of plugin / Flutter imports so every status combination can be
/// unit-tested without a device.
library;

/// How much location access the app currently has.
enum LocationLevel { none, whileInUse, always }

/// Single result the whole app reacts to.
enum PermissionGateStatus {
  /// Nothing blocks the app (every *required* permission is fine).
  allGranted,

  /// Location permission is missing / not "Always" / not Precise.
  locationMissing,

  /// Location permission is fine but the device Location Service (GPS) is off.
  locationServiceOff,

  /// Push notification permission is missing (and can still be requested).
  notificationMissing,

  /// A required permission can only be fixed from system Settings.
  permanentlyDenied,
}

/// The next concrete thing the user has to do to fix location.
enum LocationStep {
  done,
  grantPermission, // no location permission yet
  grantAlways, // has "While using" → needs "Allow all the time"
  turnOnService, // GPS / Location Service is off
  grantPrecise, // only Approximate location
  openSettings, // permanently denied → only Settings can fix it
}

enum NotificationStep { done, grantPermission, openSettings }

/// Raw device state, read by the [PermissionBackend].
class PermissionSnapshot {
  final LocationLevel locationLevel;

  /// The system dialog can no longer be shown for location
  /// (Android "Don't ask again", iOS denied).
  final bool locationPermanentlyDenied;

  /// "Allow all the time" can only be granted from Settings now.
  final bool alwaysPermanentlyDenied;

  final bool locationServiceOn;
  final bool preciseLocation;

  final bool notificationGranted;
  final bool notificationPermanentlyDenied;

  const PermissionSnapshot({
    required this.locationLevel,
    required this.locationServiceOn,
    required this.preciseLocation,
    required this.notificationGranted,
    this.locationPermanentlyDenied = false,
    this.alwaysPermanentlyDenied = false,
    this.notificationPermanentlyDenied = false,
  });

  bool get locationOk =>
      locationLevel == LocationLevel.always &&
      locationServiceOn &&
      preciseLocation;

  LocationStep get locationStep {
    switch (locationLevel) {
      case LocationLevel.none:
        return locationPermanentlyDenied
            ? LocationStep.openSettings
            : LocationStep.grantPermission;
      case LocationLevel.whileInUse:
        return alwaysPermanentlyDenied
            ? LocationStep.openSettings
            : LocationStep.grantAlways;
      case LocationLevel.always:
        if (!locationServiceOn) return LocationStep.turnOnService;
        if (!preciseLocation) return LocationStep.grantPrecise;
        return LocationStep.done;
    }
  }

  NotificationStep get notificationStep {
    if (notificationGranted) return NotificationStep.done;
    return notificationPermanentlyDenied
        ? NotificationStep.openSettings
        : NotificationStep.grantPermission;
  }

  @override
  String toString() => 'PermissionSnapshot(location: $locationLevel, '
      'locPermDenied: $locationPermanentlyDenied, '
      'alwaysPermDenied: $alwaysPermanentlyDenied, '
      'service: $locationServiceOn, precise: $preciseLocation, '
      'notification: $notificationGranted, '
      'notifPermDenied: $notificationPermanentlyDenied)';
}

/// Which permissions block the app. Comes from Firebase Remote Config,
/// default = both required.
class PermissionFlags {
  final bool requireLocation;
  final bool requireNotification;

  const PermissionFlags({
    this.requireLocation = true,
    this.requireNotification = true,
  });

  static const PermissionFlags defaults = PermissionFlags();

  @override
  String toString() =>
      'PermissionFlags(location: $requireLocation, notification: $requireNotification)';
}

class PermissionGateResult {
  final PermissionGateStatus status;
  final PermissionSnapshot? snapshot;
  final PermissionFlags flags;

  /// A permission plugin threw → blocked with a Retry button.
  final bool hasError;

  const PermissionGateResult({
    required this.status,
    required this.flags,
    this.snapshot,
    this.hasError = false,
  });

  factory PermissionGateResult.error(PermissionFlags flags) =>
      PermissionGateResult(
        status: PermissionGateStatus.locationMissing,
        flags: flags,
        hasError: true,
      );

  /// True → user may use the app.
  bool get allowsAccess =>
      !hasError && status == PermissionGateStatus.allGranted;

  bool get locationOk => snapshot?.locationOk ?? false;
  bool get notificationOk => snapshot?.notificationGranted ?? false;

  LocationStep get locationStep =>
      snapshot?.locationStep ?? LocationStep.grantPermission;
  NotificationStep get notificationStep =>
      snapshot?.notificationStep ?? NotificationStep.grantPermission;

  /// Pure evaluation: snapshot + flags → status. Location is checked first,
  /// then notification (same order the user is asked in).
  static PermissionGateResult evaluate(
    PermissionSnapshot s,
    PermissionFlags flags,
  ) {
    PermissionGateStatus status = PermissionGateStatus.allGranted;

    if (flags.requireLocation && !s.locationOk) {
      switch (s.locationStep) {
        case LocationStep.openSettings:
          status = PermissionGateStatus.permanentlyDenied;
          break;
        case LocationStep.turnOnService:
          status = PermissionGateStatus.locationServiceOff;
          break;
        default:
          status = PermissionGateStatus.locationMissing;
      }
    } else if (flags.requireNotification && !s.notificationGranted) {
      status = s.notificationPermanentlyDenied
          ? PermissionGateStatus.permanentlyDenied
          : PermissionGateStatus.notificationMissing;
    }

    return PermissionGateResult(status: status, flags: flags, snapshot: s);
  }

  @override
  String toString() =>
      'PermissionGateResult($status, error: $hasError, $flags, $snapshot)';
}
