import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_models.dart';
import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_service.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support/fake_permission_backend.dart';

PermissionSnapshot snap({
  LocationLevel level = LocationLevel.always,
  bool locPermDenied = false,
  bool alwaysPermDenied = false,
  bool service = true,
  bool precise = true,
  bool notif = true,
  bool notifPermDenied = false,
}) =>
    PermissionSnapshot(
      locationLevel: level,
      locationPermanentlyDenied: locPermDenied,
      alwaysPermanentlyDenied: alwaysPermDenied,
      locationServiceOn: service,
      preciseLocation: precise,
      notificationGranted: notif,
      notificationPermanentlyDenied: notifPermDenied,
    );

PermissionGateStatus eval(PermissionSnapshot s,
        [PermissionFlags f = PermissionFlags.defaults]) =>
    PermissionGateResult.evaluate(s, f).status;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('evaluate() — every status combination', () {
    test('everything granted → allGranted', () {
      expect(eval(snap()), PermissionGateStatus.allGranted);
      expect(PermissionGateResult.evaluate(snap(), PermissionFlags.defaults)
          .allowsAccess, isTrue);
    });

    test('no location permission → locationMissing', () {
      expect(eval(snap(level: LocationLevel.none)),
          PermissionGateStatus.locationMissing);
    });

    test('"While using" only (incl. "Only this time") → locationMissing', () {
      final r = PermissionGateResult.evaluate(
          snap(level: LocationLevel.whileInUse), PermissionFlags.defaults);
      expect(r.status, PermissionGateStatus.locationMissing);
      expect(r.locationStep, LocationStep.grantAlways);
    });

    test('location permanently denied → permanentlyDenied', () {
      final r = PermissionGateResult.evaluate(
          snap(level: LocationLevel.none, locPermDenied: true),
          PermissionFlags.defaults);
      expect(r.status, PermissionGateStatus.permanentlyDenied);
      expect(r.locationStep, LocationStep.openSettings);
    });

    test('"Always" permanently denied → permanentlyDenied', () {
      expect(
          eval(snap(level: LocationLevel.whileInUse, alwaysPermDenied: true)),
          PermissionGateStatus.permanentlyDenied);
    });

    test('GPS off → locationServiceOff', () {
      final r = PermissionGateResult.evaluate(
          snap(service: false), PermissionFlags.defaults);
      expect(r.status, PermissionGateStatus.locationServiceOff);
      expect(r.locationStep, LocationStep.turnOnService);
    });

    test('Approximate only → locationMissing / grantPrecise', () {
      final r = PermissionGateResult.evaluate(
          snap(precise: false), PermissionFlags.defaults);
      expect(r.status, PermissionGateStatus.locationMissing);
      expect(r.locationStep, LocationStep.grantPrecise);
    });

    test('notification missing → notificationMissing', () {
      expect(eval(snap(notif: false)), PermissionGateStatus.notificationMissing);
    });

    test('notification permanently denied → permanentlyDenied', () {
      final r = PermissionGateResult.evaluate(
          snap(notif: false, notifPermDenied: true), PermissionFlags.defaults);
      expect(r.status, PermissionGateStatus.permanentlyDenied);
      expect(r.notificationStep, NotificationStep.openSettings);
    });

    test('location is reported before notification', () {
      expect(eval(snap(level: LocationLevel.none, notif: false)),
          PermissionGateStatus.locationMissing);
    });

    test('permission is checked before GPS', () {
      expect(eval(snap(level: LocationLevel.whileInUse, service: false)),
          PermissionGateStatus.locationMissing);
    });

    test('require_location=false → missing location does not block', () {
      const f = PermissionFlags(requireLocation: false);
      final r = PermissionGateResult.evaluate(
          snap(level: LocationLevel.none), f);
      expect(r.status, PermissionGateStatus.allGranted);
      expect(r.allowsAccess, isTrue);
      expect(r.locationOk, isFalse); // still shown as "Recommended"
    });

    test('require_location=false still blocks on notification', () {
      const f = PermissionFlags(requireLocation: false);
      expect(eval(snap(level: LocationLevel.none, notif: false), f),
          PermissionGateStatus.notificationMissing);
    });

    test('require_notification=false → missing notification does not block',
        () {
      const f = PermissionFlags(requireNotification: false);
      expect(eval(snap(notif: false), f), PermissionGateStatus.allGranted);
    });

    test('both flags false → never blocks', () {
      const f =
          PermissionFlags(requireLocation: false, requireNotification: false);
      expect(
          eval(snap(level: LocationLevel.none, notif: false, service: false),
              f),
          PermissionGateStatus.allGranted);
    });

    test('error result never allows access', () {
      final r = PermissionGateResult.error(PermissionFlags.defaults);
      expect(r.hasError, isTrue);
      expect(r.allowsAccess, isFalse);
    });
  });

  group('PermissionGateService', () {
    late FakePermissionBackend device;
    late FakeFlagsSource flags;
    bool loggedIn = true;
    bool callActive = false;
    int tokenRefreshes = 0;

    PermissionGateService make() => PermissionGateService(
          backend: device,
          flagsSource: flags,
          isLoggedIn: () => loggedIn,
          isCallOrWalkieActive: () => callActive,
          onNotificationGranted: () async => tokenRefreshes++,
          flagsTimeout: const Duration(milliseconds: 200),
        );

    setUp(() {
      device = FakePermissionBackend();
      flags = FakeFlagsSource();
      loggedIn = true;
      callActive = false;
      tokenRefreshes = 0;
    });

    tearDown(Get.reset);

    test('check() reflects the device and caches the result', () async {
      device.grantAll();
      final s = make();
      final r = await s.check();
      expect(r.allowsAccess, isTrue);
      expect(s.result.value, same(r));
    });

    test('plugin throws → error result (blocking + Retry), no crash',
        () async {
      device.throwOnSnapshot = true;
      final s = make();
      final r = await s.check();
      expect(r.hasError, isTrue);
      expect(r.allowsAccess, isFalse);
    });

    test('flags are loaded once and reused', () async {
      final s = make();
      await s.check();
      await s.check();
      expect(flags.loads, 1);
    });

    test('flags fail to load (offline) → defaults (both required)', () async {
      flags.fail = true;
      device.grantAll();
      device.notification = false;
      final s = make();
      final r = await s.check();
      expect(s.flags.requireLocation, isTrue);
      expect(s.flags.requireNotification, isTrue);
      expect(r.status, PermissionGateStatus.notificationMissing);
    });

    test('flags time out → defaults', () async {
      flags.delay = const Duration(seconds: 2);
      flags.flags = const PermissionFlags(requireNotification: false);
      final s = make();
      await s.check();
      expect(s.flags.requireNotification, isTrue);
    });

    test('remote flag false is honoured', () async {
      flags.flags = const PermissionFlags(requireNotification: false);
      device.grantAll();
      device.notification = false;
      final r = await make().check();
      expect(r.allowsAccess, isTrue);
    });

    test('token refresh runs when notification turns on (once)', () async {
      final s = make();
      await s.check();
      expect(tokenRefreshes, 0);
      device.notification = true;
      await s.check();
      await Future<void>.delayed(Duration.zero);
      expect(tokenRefreshes, 1);
      await s.check();
      await Future<void>.delayed(Duration.zero);
      expect(tokenRefreshes, 1);
    });

    group('shouldBlockRoute', () {
      test('blocks guarded routes while a required permission is missing',
          () async {
        final s = make();
        await s.check();
        expect(s.shouldBlockRoute(Routes.Home_Screen), isTrue);
        expect(s.shouldBlockRoute(Routes.chatScreen), isTrue);
        expect(s.shouldBlockRoute(Routes.TrackingScreen), isTrue);
      });

      test('never blocks exempt routes (auth, permission, call screens)',
          () async {
        final s = make();
        await s.check();
        for (final r in [
          Routes.Login,
          Routes.OTPScreen,
          Routes.permissionSetup,
          Routes.permissionGate,
          Routes.callScreen,
          Routes.groupWalkieScreen,
          Routes.groupIncomingCallScreen,
        ]) {
          expect(s.shouldBlockRoute(r), isFalse, reason: r);
        }
      });

      test('does not block logged-out users', () async {
        loggedIn = false;
        final s = make();
        await s.check();
        expect(s.shouldBlockRoute(Routes.Home_Screen), isFalse);
      });

      test('does not block during an active call / walkie', () async {
        callActive = true;
        final s = make();
        await s.check();
        expect(s.shouldBlockRoute(Routes.Home_Screen), isFalse);
      });

      test('does not block before the first check', () {
        expect(make().shouldBlockRoute(Routes.Home_Screen), isFalse);
      });

      test('does not block once everything is granted', () async {
        device.grantAll();
        final s = make();
        await s.check();
        expect(s.shouldBlockRoute(Routes.Home_Screen), isFalse);
      });
    });

    test('runExclusive marks the service busy', () async {
      final s = make();
      expect(s.isBusy, isFalse);
      await s.runExclusive(() async {
        expect(s.isBusy, isTrue);
      });
      expect(s.isBusy, isFalse);
    });
  });
}
