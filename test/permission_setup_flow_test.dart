import 'package:fgtracker/app/Data/Services/PermissionGate/permission_flow.dart';
import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_models.dart';
import 'package:fgtracker/app/modules/home/Controller/PermissionSetupController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'support/permission_test_app.dart';

/// "New customer" permission screen (shown after login / registration).
void main() {
  late PermissionTestEnv env;

  setUp(() {
    env = PermissionTestEnv()..setUp();
  });
  tearDown(() => env.tearDown());

  PermissionSetupController ctrl() => Get.find<PermissionSetupController>();
  final primary = find.byKey(const Key('permission-primary-button'));
  final continueBtn = find.byKey(const Key('permission-continue-button'));

  bool continueEnabled(WidgetTester tester) {
    final w = tester.widget<ButtonStyleButton>(continueBtn);
    return w.onPressed != null;
  }

  Future<void> open(WidgetTester tester) =>
      env.pump(tester, initialRoute: Routes.permissionSetup);

  /// Grants location through the UI: When-in-use → Always.
  Future<void> grantLocationViaUi(WidgetTester tester) async {
    env.device.onWhenInUse = LocationLevel.whileInUse;
    env.device.onAlways = LocationLevel.always;
    await tapAndOpenDialog(tester, find.text('Allow Location'));
    await tapDialog(tester, 'Continue');
    await tapAndOpenDialog(tester, find.text('Allow All The Time'));
    await tapDialog(tester, 'Continue');
  }

  group('Entry', () {
    testWidgets('all permissions granted → straight to Home', (tester) async {
      env.device.grantAll();
      env.device.statuses[Permission.camera] = PermissionStatus.granted;
      await open(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('only the 2 required granted → straight to Home',
        (tester) async {
      env.device.grantRequiredOnly();
      await open(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('nothing granted → screen, nothing auto-requested',
        (tester) async {
      await open(tester);
      expect(find.text('App Permissions'), findsOneWidget);
      expect(env.device.calls, isEmpty, reason: 'no auto request on open');
      expect(ctrl().selectedIndex.value, 0);
    });

    testWidgets('"While using" only → stays (Always is compulsory)',
        (tester) async {
      env.device.grantAll();
      env.device.level = LocationLevel.whileInUse;
      await open(tester);
      expect(find.byKey(homeKey), findsNothing);
      expect(find.text('Allow All The Time'), findsOneWidget);
    });

    testWidgets('notification missing → stays', (tester) async {
      env.device.grantAll();
      env.device.notification = false;
      await open(tester);
      expect(find.byKey(homeKey), findsNothing);
      expect(ctrl().selectedIndex.value, 1);
    });
  });

  group('Badges & Continue button', () {
    testWidgets('Required on Location + Notifications, Optional on the rest',
        (tester) async {
      await open(tester);
      expect(find.text('Required'), findsNWidgets(2));
      final c = ctrl();
      expect([for (var i = 0; i < c.items.length; i++) c.isRequired(i)],
          [true, true, false, false, false]);
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(find.text('Optional'), findsWidgets);
      expect(find.text('Contacts'), findsOneWidget);
    });

    testWidgets('Continue disabled until both required are granted',
        (tester) async {
      await open(tester);
      expect(continueEnabled(tester), isFalse);
      expect(find.text('Location and Notifications are required to continue.'),
          findsOneWidget);

      await grantLocationViaUi(tester);
      expect(continueEnabled(tester), isFalse, reason: 'location only');

      env.device.onNotification = true;
      await tapAndOpenDialog(tester, primary);
      await tapDialog(tester, 'Continue');
      expect(continueEnabled(tester), isTrue);
      expect(find.text('Skip & Continue'), findsOneWidget);

      await tester.tap(continueBtn);
      await tester.pumpAndSettle();
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('remote flag false → "Recommended" badge, does not block',
        (tester) async {
      env.tearDown();
      env = PermissionTestEnv()
        ..setUp(const PermissionFlags(requireNotification: false));
      env.device.grantAll();
      env.device.notification = false;
      // Required ones satisfied → app opens directly.
      await open(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('remote flag false shows Recommended while location missing',
        (tester) async {
      env.tearDown();
      env = PermissionTestEnv()
        ..setUp(const PermissionFlags(requireNotification: false));
      await open(tester);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
    });
  });

  group('Location flow (one step per tap, reason first)', () {
    testWidgets('reason dialog appears before the system dialog; Not Now '
        'requests nothing', (tester) async {
      await open(tester);
      await tapAndOpenDialog(tester, find.text('Allow Location'));
      expect(find.text(PermissionReasons.location), findsOneWidget);
      await tapDialog(tester, 'Not Now');
      expect(env.device.calls, isEmpty);
    });

    testWidgets('When-in-use → Always → moves to Notifications',
        (tester) async {
      await open(tester);
      await grantLocationViaUi(tester);
      expect(env.device.calls, ['whenInUse', 'always']);
      expect(ctrl().grantedItems.contains(0), isTrue);
      expect(ctrl().selectedIndex.value, 1);
      expect(find.text('Allow Notifications'), findsOneWidget);
    });

    testWidgets('notification is not requested before location',
        (tester) async {
      await open(tester);
      ctrl().selectCard(1);
      await tester.pumpAndSettle();
      await tester.tap(primary);
      await tester.pumpAndSettle();
      expect(env.device.calls, isEmpty);
      expect(find.text('Please allow Location first.'), findsOneWidget);
      expect(ctrl().selectedIndex.value, 0);
    });

    testWidgets('"Always" refused twice → Settings dialog (no loop)',
        (tester) async {
      env.device.level = LocationLevel.whileInUse;
      await open(tester);
      // 1st refusal → message
      await tapAndOpenDialog(tester, find.text('Allow All The Time'));
      await tapDialog(tester, 'Continue');
      expect(find.text('Please select "Allow all the time" to continue.'),
          findsOneWidget);
      // 2nd refusal → Settings dialog
      await tapAndOpenDialog(tester, find.text('Allow All The Time'));
      await tapDialog(tester, 'Continue');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Permission Required'), findsOneWidget);
      await tapDialog(tester, 'Open Settings');
      expect(env.device.openAppSettingsCalls, 1);
    });

    testWidgets('iOS "While using" → Always goes to Settings directly',
        (tester) async {
      env.device.isIOS = true;
      env.device.level = LocationLevel.whileInUse;
      await open(tester);
      await tapAndOpenDialog(tester, find.text('Allow All The Time'));
      await tapDialog(tester, 'Continue');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Permission Required'), findsOneWidget);
      expect(find.textContaining('choose "Always"'), findsOneWidget);
    });

    testWidgets('permanently denied → Settings → granted → back = unlocked',
        (tester) async {
      env.device.locationPermDenied = true;
      await open(tester);
      expect(find.text('Open Settings'), findsOneWidget);
      await tapAndOpenDialog(tester, primary);
      await tapDialog(tester, 'Open Settings');
      expect(env.device.openAppSettingsCalls, 1);

      // User enables Location + Notifications in Settings and comes back:
      // Continue unlocks by itself (optional ones still offered).
      env.device.grantAll();
      await env.resume(tester);
      expect(ctrl().grantedItems.containsAll([0, 1]), isTrue);
      expect(continueEnabled(tester), isTrue);
      expect(ctrl().selectedIndex.value, 2);
    });

    testWidgets('everything enabled in Settings → back = Home',
        (tester) async {
      env.device.locationPermDenied = true;
      await open(tester);
      env.device.grantAll();
      for (final p in [
        Permission.camera,
        Permission.microphone,
        Permission.contacts
      ]) {
        env.device.statuses[p] = PermissionStatus.granted;
      }
      await env.resume(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('GPS off → Turn On Location uses the in-app GPS prompt',
        (tester) async {
      env.device.grantAll();
      env.device.serviceOn = false;
      env.device.notification = false;
      env.device.onService = true;
      await open(tester);
      expect(find.text('Turn On Location'), findsOneWidget);
      await tester.tap(find.text('Turn On Location'));
      await tester.pumpAndSettle();
      expect(env.device.calls, contains('service'));
      expect(ctrl().grantedItems.contains(0), isTrue);
    });

    testWidgets('GPS prompt refused → opens location settings',
        (tester) async {
      env.device.grantAll();
      env.device.serviceOn = false;
      env.device.onService = false;
      await open(tester);
      await tester.tap(find.text('Turn On Location'));
      await tester.pumpAndSettle();
      expect(env.device.openLocationSettingsCalls, 1);
    });

    testWidgets('Approximate → asks for Precise', (tester) async {
      env.device.grantAll();
      env.device.precise = false;
      env.device.onPrecise = true;
      await open(tester);
      await tapAndOpenDialog(tester, find.text('Turn On Precise Location'));
      expect(find.text(PermissionReasons.precise), findsOneWidget);
      await tapDialog(tester, 'Continue');
      expect(env.device.calls, ['precise']);
      expect(find.byKey(homeKey), findsNothing); // optional ones remain
      expect(ctrl().grantedItems.contains(0), isTrue);
    });

    testWidgets('Precise refused → Settings dialog', (tester) async {
      env.device.grantAll();
      env.device.precise = false;
      env.device.onPrecise = false;
      await open(tester);
      await tapAndOpenDialog(tester, find.text('Turn On Precise Location'));
      await tapDialog(tester, 'Continue');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('precise location'), findsWidgets);
      expect(find.text('Open Settings'), findsWidgets);
    });
  });

  group('Notification flow', () {
    setUp(() {
      env.device
        ..level = LocationLevel.always
        ..serviceOn = true
        ..precise = true;
    });

    testWidgets('reason mentions calls; granting enables Continue',
        (tester) async {
      env.device.onNotification = true;
      await open(tester);
      await tapAndOpenDialog(tester, find.text('Allow Notifications'));
      expect(find.text(PermissionReasons.notification), findsOneWidget);
      expect(find.textContaining('incoming calls'), findsWidgets);
      await tapDialog(tester, 'Continue');
      expect(env.device.calls, ['notification']);
      expect(continueEnabled(tester), isTrue);
    });

    testWidgets('no dialog shown (Android ≤12 / OEM) twice → Settings',
        (tester) async {
      await open(tester);
      await tapAndOpenDialog(tester, find.text('Allow Notifications'));
      await tapDialog(tester, 'Continue');
      expect(find.text('Notification permission is required to continue.'),
          findsOneWidget);
      await tapAndOpenDialog(tester, find.text('Allow Notifications'));
      await tapDialog(tester, 'Continue');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Permission Required'), findsOneWidget);
    });

    testWidgets('permanently denied → Open Settings', (tester) async {
      env.device.notificationPermDenied = true;
      await open(tester);
      await tapAndOpenDialog(tester, primary);
      await tapDialog(tester, 'Open Settings');
      expect(env.device.openAppSettingsCalls, 1);
    });
  });

  group('Optional permissions (unchanged behaviour)', () {
    setUp(() => env.device.grantAll());

    testWidgets('camera can be granted, then Continue', (tester) async {
      env.device.statuses[Permission.contacts] = PermissionStatus.denied;
      env.device.onRequest[Permission.camera] = PermissionStatus.granted;
      // Required are granted → entry goes Home; reopen manually.
      await open(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('every optional denied → app still usable', (tester) async {
      env.device.statuses[Permission.camera] =
          PermissionStatus.permanentlyDenied;
      env.device.statuses[Permission.microphone] = PermissionStatus.denied;
      env.device.statuses[Permission.contacts] = PermissionStatus.denied;
      await open(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('optional request flow still works on the screen',
        (tester) async {
      env.device.notification = false;
      env.device.onNotification = true;
      env.device.onRequest[Permission.camera] = PermissionStatus.granted;
      await open(tester);
      await tapAndOpenDialog(tester, find.text('Allow Notifications'));
      await tapDialog(tester, 'Continue');
      expect(find.text('Allow Camera'), findsOneWidget);
      await tester.tap(find.text('Allow Camera'));
      await tester.pumpAndSettle();
      expect(ctrl().grantedItems.contains(2), isTrue);
      expect(find.text('Allow Microphone / Audio'), findsOneWidget);
    });
  });

  group('Layout', () {
    testWidgets('small screen (iPhone SE size) renders without overflow',
        (tester) async {
      await env.pump(tester,
          initialRoute: Routes.permissionSetup,
          size: const Size(640, 1136),
          dpr: 2.0);
      expect(tester.takeException(), isNull);
      expect(find.text('App Permissions'), findsOneWidget);
    });
  });
}
