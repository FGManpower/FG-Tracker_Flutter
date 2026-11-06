import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_models.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support/permission_test_app.dart';

/// Blocking "Permissions Required" screen + global gate (route guard,
/// app resume) for existing / returning users.
void main() {
  late PermissionTestEnv env;

  setUp(() {
    env = PermissionTestEnv()..setUp();
  });
  tearDown(() => env.tearDown());

  Future<void> openGate(WidgetTester tester) async {
    await env.gate.check();
    await env.pump(tester, initialRoute: Routes.permissionGate);
  }

  group('Blocking screen', () {
    testWidgets('shows both required permissions with Required badges',
        (tester) async {
      await openGate(tester);
      expect(find.text('Permissions Required'), findsOneWidget);
      expect(find.text('Required'), findsNWidgets(2));
      expect(find.text('Allow Location'), findsOneWidget);
      expect(find.text('Allow Notifications'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('back button cannot leave the screen (PopScope)',
        (tester) async {
      await openGate(tester);
      final scope = tester.widget<PopScope>(find.byType(PopScope).first);
      expect(scope.canPop, isFalse);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Permissions Required'), findsOneWidget);
    });

    testWidgets('notification tap / deep link to a module is redirected',
        (tester) async {
      await openGate(tester);
      Get.toNamed(Routes.chatScreen);
      await tester.pumpAndSettle();
      expect(find.byKey(chatKey), findsNothing);
      expect(find.text('Permissions Required'), findsOneWidget);
    });

    testWidgets('permanently denied → "Open Settings" button', (tester) async {
      env.device.locationPermDenied = true;
      await openGate(tester);
      final openSettings = find.widgetWithText(OutlinedButton, 'Open Settings');
      expect(openSettings, findsOneWidget);
      await tester.tap(openSettings);
      await tester.pumpAndSettle();
      expect(env.device.openAppSettingsCalls, 1);
    });

    testWidgets('enable in Settings → come back → unlocks by itself',
        (tester) async {
      env.device.locationPermDenied = true;
      env.device.notificationPermDenied = true;
      await openGate(tester);

      env.device.grantAll();
      await env.resume(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('GPS off → turn on → unlocks', (tester) async {
      env.device.grantAll();
      env.device.serviceOn = false;
      env.device.onService = true;
      await openGate(tester);
      expect(find.text('Device location (GPS) is turned off.'), findsOneWidget);
      await tester.tap(find.text('Turn On Location'));
      await pumpFrames(tester);
      await tester.pumpAndSettle();
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('grant both from the blocking screen → Home', (tester) async {
      env.device.level = LocationLevel.whileInUse;
      env.device.onAlways = LocationLevel.always;
      env.device.onNotification = true;
      await openGate(tester);

      await tapAndOpenDialog(tester, find.text('Allow All The Time'));
      await tapDialog(tester, 'Continue');
      expect(find.text('Granted'), findsOneWidget);

      await tapAndOpenDialog(tester, find.text('Allow Notifications'));
      await tapDialog(tester, 'Continue');
      await tester.pumpAndSettle();
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('plugin error → Retry → recovers', (tester) async {
      env.device.throwOnSnapshot = true;
      await openGate(tester);
      expect(find.text('Retry'), findsOneWidget);

      env.device
        ..throwOnSnapshot = false
        ..grantAll();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('Logout is always available', (tester) async {
      env.device.locationPermDenied = true;
      await openGate(tester);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(env.logouts, 1);
      expect(find.byKey(loginKey), findsOneWidget);
    });

    testWidgets('remote flag false → only location blocks', (tester) async {
      env.tearDown();
      env = PermissionTestEnv()
        ..setUp(const PermissionFlags(requireNotification: false));
      env.device.level = LocationLevel.none;
      await openGate(tester);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);

      env.device.grantAll();
      env.device.notification = false;
      await env.resume(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('small screen renders without overflow', (tester) async {
      env.device.locationPermDenied = true;
      await env.gate.check();
      await env.pump(tester,
          initialRoute: Routes.permissionGate,
          size: const Size(640, 1136),
          dpr: 2.0);
      expect(tester.takeException(), isNull);
      expect(find.text('Logout'), findsOneWidget);
    });
  });

  group('Global gate (existing users)', () {
    testWidgets('granted user reaches Home normally', (tester) async {
      env.device.grantAll();
      await env.gate.check();
      await env.pump(tester, initialRoute: Routes.Home_Screen);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('missing permission → Home route is redirected', (tester) async {
      env.device.grantAll();
      env.device.notification = false;
      await env.gate.check();
      await env.pump(tester, initialRoute: Routes.Home_Screen);
      expect(find.byKey(homeKey), findsNothing);
      expect(find.text('Permissions Required'), findsOneWidget);
    });

    testWidgets('revoked in Settings while using the app → blocked on resume',
        (tester) async {
      env.device.grantAll();
      await env.gate.check();
      await env.pump(tester, initialRoute: Routes.Home_Screen);
      expect(find.byKey(homeKey), findsOneWidget);

      env.device.level = LocationLevel.whileInUse;
      await env.resume(tester);
      expect(find.text('Permissions Required'), findsOneWidget);
      expect(find.text('Allow All The Time'), findsOneWidget);
    });

    testWidgets('revoked during an active call → not interrupted',
        (tester) async {
      env.device.grantAll();
      await env.gate.check();
      await env.pump(tester, initialRoute: Routes.Home_Screen);

      env.callActive = true;
      env.device.notification = false;
      await env.resume(tester);
      expect(find.byKey(homeKey), findsOneWidget);
    });

    testWidgets('logged-out user is never gated', (tester) async {
      env.loggedIn = false;
      await env.gate.check();
      await env.pump(tester, initialRoute: Routes.chatScreen);
      expect(find.byKey(chatKey), findsOneWidget);
    });
  });
}
