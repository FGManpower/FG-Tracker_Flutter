import 'package:fgtracker/app/Data/Services/PermissionGate/permission_backend.dart';
import 'package:fgtracker/app/Data/Services/PermissionGate/permission_flags.dart';
import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_models.dart';
import 'package:permission_handler/permission_handler.dart';

/// Scriptable device for permission tests.
class FakePermissionBackend implements PermissionBackend {
  LocationLevel level = LocationLevel.none;
  bool locationPermDenied = false;
  bool alwaysPermDenied = false;
  bool serviceOn = true;
  bool precise = true;
  bool notification = false;
  bool notificationPermDenied = false;

  @override
  bool isIOS = false;

  /// Throw from [snapshot] (plugin failure).
  bool throwOnSnapshot = false;

  // What the next system dialog answers.
  LocationLevel? onWhenInUse;
  LocationLevel? onAlways;
  bool? onPrecise;
  bool? onService;
  bool? onNotification;

  // Optional permissions.
  final Map<Permission, PermissionStatus> statuses = {};
  final Map<Permission, PermissionStatus> onRequest = {};

  final List<String> calls = [];
  int openAppSettingsCalls = 0;
  int openLocationSettingsCalls = 0;

  void grantAll() {
    level = LocationLevel.always;
    locationPermDenied = false;
    alwaysPermDenied = false;
    serviceOn = true;
    precise = true;
    notification = true;
    notificationPermDenied = false;
  }

  void grantRequiredOnly() => grantAll();

  @override
  Future<PermissionSnapshot> snapshot() async {
    if (throwOnSnapshot) throw Exception('plugin failure');
    return PermissionSnapshot(
      locationLevel: level,
      locationPermanentlyDenied: locationPermDenied,
      alwaysPermanentlyDenied: alwaysPermDenied,
      locationServiceOn: serviceOn,
      preciseLocation: level == LocationLevel.none ? false : precise,
      notificationGranted: notification,
      notificationPermanentlyDenied: notificationPermDenied,
    );
  }

  @override
  Future<void> requestLocationWhenInUse() async {
    calls.add('whenInUse');
    if (onWhenInUse != null) level = onWhenInUse!;
  }

  @override
  Future<void> requestLocationAlways() async {
    calls.add('always');
    if (onAlways != null) level = onAlways!;
  }

  @override
  Future<void> requestPreciseLocation() async {
    calls.add('precise');
    if (onPrecise != null) precise = onPrecise!;
  }

  @override
  Future<bool> requestLocationService() async {
    calls.add('service');
    if (onService != null) serviceOn = onService!;
    return serviceOn;
  }

  @override
  Future<void> requestNotification() async {
    calls.add('notification');
    if (onNotification != null) notification = onNotification!;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCalls++;
    return true;
  }

  @override
  Future<PermissionStatus> status(Permission permission) async =>
      statuses[permission] ?? PermissionStatus.denied;

  @override
  Future<PermissionStatus> request(Permission permission) async {
    calls.add('request:$permission');
    final next = onRequest[permission] ?? statuses[permission] ??
        PermissionStatus.denied;
    statuses[permission] = next;
    return next;
  }
}

class FakeFlagsSource implements PermissionFlagsSource {
  FakeFlagsSource([this.flags = PermissionFlags.defaults]);
  PermissionFlags flags;
  bool fail = false;
  Duration delay = Duration.zero;
  int loads = 0;

  @override
  Future<PermissionFlags> load() async {
    loads++;
    if (delay > Duration.zero) await Future.delayed(delay);
    if (fail) throw Exception('offline');
    return flags;
  }
}
