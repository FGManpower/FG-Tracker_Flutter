import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_middleware.dart';
import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_models.dart';
import 'package:fgtracker/app/Data/Services/PermissionGate/permission_gate_service.dart';
import 'package:fgtracker/app/modules/PermissionGate/permission_gate_controller.dart';
import 'package:fgtracker/app/modules/PermissionGate/permission_gate_screen.dart';
import 'package:fgtracker/app/modules/home/Bindings/permission_setup_binding.dart';
import 'package:fgtracker/app/modules/home/Controller/PermissionSetupController.dart';
import 'package:fgtracker/app/modules/home/Views/permission_setup_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_permission_backend.dart';

const homeKey = Key('home-stub');
const chatKey = Key('chat-stub');
const loginKey = Key('login-stub');

class PermissionTestEnv {
  final FakePermissionBackend device = FakePermissionBackend();
  final FakeFlagsSource flags = FakeFlagsSource();
  bool loggedIn = true;
  bool callActive = false;
  int logouts = 0;

  late PermissionGateService gate;

  void setUp([PermissionFlags f = PermissionFlags.defaults]) {
    flags.flags = f;
    Get.testMode = true;
    gate = Get.put(
      PermissionGateService(
        backend: device,
        flagsSource: flags,
        isLoggedIn: () => loggedIn,
        isCallOrWalkieActive: () => callActive,
      ),
      permanent: true,
    );
  }

  void tearDown() {
    // Make sure no lifecycle observer survives into the next test.
    if (Get.isRegistered<PermissionSetupController>()) {
      Get.delete<PermissionSetupController>(force: true);
    }
    if (Get.isRegistered<PermissionGateController>()) {
      Get.delete<PermissionGateController>(force: true);
    }
    Get.delete<PermissionGateService>(force: true);
    Get.reset();
  }

  Future<void> pump(
    WidgetTester tester, {
    required String initialRoute,
    Size size = const Size(1080, 2400),
    double dpr = 2.75,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) => GetMaterialApp(
          initialRoute: initialRoute,
          getPages: PermissionGateMiddleware.guard([
            GetPage(
              name: Routes.permissionSetup,
              page: () => const PermissionSetupScreen(),
              binding: PermissionSetupBinding(),
            ),
            GetPage(
              name: Routes.permissionGate,
              page: () => const PermissionGateScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => PermissionGateController(
                      onLogout: () async {
                        logouts++;
                        Get.offAllNamed(Routes.Login);
                      },
                    ));
              }),
            ),
            GetPage(
              name: Routes.Home_Screen,
              page: () => const Scaffold(body: Text('HOME', key: homeKey)),
            ),
            GetPage(
              name: Routes.chatScreen,
              page: () => const Scaffold(body: Text('CHAT', key: chatKey)),
            ),
            GetPage(
              name: Routes.Login,
              page: () => const Scaffold(body: Text('LOGIN', key: loginKey)),
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> resume(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  }
}

/// Taps a dialog button (rationale "Continue" / "Not Now", settings dialog).
Future<void> tapDialog(WidgetTester tester, String label) async {
  final finder = find.descendant(
    of: find.byType(Dialog),
    matching: find.text(label),
  );
  expect(finder, findsOneWidget, reason: 'dialog button "$label"');
  await tester.tap(finder);
  // No pumpAndSettle: a follow-up dialog may open while the button spinner
  // animates, which never "settles".
  await pumpFrames(tester);
}

Future<void> pumpFrames(WidgetTester tester, [int frames = 8]) async {
  await tester.pump();
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Starts an action whose button shows a spinner while a dialog is open.
Future<void> tapAndOpenDialog(WidgetTester tester, Finder target) async {
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
