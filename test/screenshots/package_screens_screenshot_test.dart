// Renders the Package screens to PNG for docs/packages/02_backend_requirements.md
//
// Skipped in the normal test run. To regenerate:
//   flutter test test/screenshots/package_screens_screenshot_test.dart \
//     --dart-define=SCREENSHOTS=true --update-goldens
//
// The JSON below is test input in the documented API shape — it is NOT used
// by the app (the app has no sample / fallback data).
import 'dart:async';
import 'dart:io';

import 'package:fgtracker/app/Data/Repositories/package_api_error.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/modules/PackagePricing/Controller/package_list_controller.dart';
import 'package:fgtracker/app/modules/PackagePricing/Views/package_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const _enabled = bool.fromEnvironment('SCREENSHOTS');
const _out = '../../docs/packages/screenshots';

Future<void> _loadFonts() async {
  const inter = {
    'InterRegular': 'Inter-Regular.ttf',
    'InterMedium': 'Inter-Medium.ttf',
    'InterSemiBold': 'Inter-SemiBold.ttf',
    'InterBold': 'Inter-Bold.ttf',
    'InterExtraBold': 'Inter-ExtraBold.ttf',
  };
  for (final e in inter.entries) {
    final bytes = File('assets/fonts/${e.value}').readAsBytesSync();
    await (FontLoader(e.key)..addFont(Future.value(ByteData.sublistView(bytes))))
        .load();
  }
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final icons = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(
              ByteData.sublistView(icons.readAsBytesSync()))))
        .load();
  }
}

Widget _app(Widget home) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'InterRegular'),
        home: home,
      ),
    );

void _surface(WidgetTester tester, double height) {
  tester.view.physicalSize = Size(375 * 2, height * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

final _packagesJson = {
  'status': true,
  'data': {
    'packages': [
      {
        'id': 1,
        'moduleKey': 'attendance',
        'title': 'Attendance',
        'tagline': 'Daily check-in, check-out and reports for your team',
        'badge': 'Popular',
        'isAvailable': true,
        'highlights': ['Check-in / out', 'Reports'],
        'sortOrder': 1,
      },
      {
        'id': 2,
        'moduleKey': 'walkie_talkie',
        'title': 'Walkie-Talkie',
        'tagline': 'Push-to-talk voice for your group',
        'isAvailable': true,
        'highlights': ['Push to talk', 'Team channels'],
        'sortOrder': 2,
      },
      {
        'id': 3,
        'moduleKey': 'safe_zone_route',
        'title': 'Safe Zone + Safe Route',
        'tagline': 'Geo-fence alerts and route deviation alerts',
        'isAvailable': true,
        'highlights': ['Geo-fence', 'Route alerts'],
        'sortOrder': 3,
      },
      {
        'id': 4,
        'moduleKey': 'live_tracking',
        'title': 'Live Tracking',
        'tagline': 'See your team on the map in real time',
        'isAvailable': true,
        'highlights': ['Live map', 'Location history'],
        'sortOrder': 4,
      },
    ],
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);
  tearDown(Get.reset);

  Future<void> shotList(WidgetTester tester, String name,
      Future<PackageListResponse> Function() loader,
      {bool settle = true}) async {
    _surface(tester, 812);
    Get.put(PackageListController(loader: loader));
    await tester.pumpWidget(_app(const PackageListView()));
    settle ? await tester.pumpAndSettle() : await tester.pump();
    await expectLater(
        find.byType(PackageListView), matchesGoldenFile('$_out/$name.png'));
  }

  testWidgets('01 package list', (t) async {
    await shotList(t, '01_package_list',
        () async => PackageListResponse.fromJson(_packagesJson));
  }, skip: !_enabled);

  testWidgets('02 package list loading', (t) async {
    final pending = Completer<PackageListResponse>();
    await shotList(t, '02_package_list_loading', () => pending.future,
        settle: false);
    pending.complete(const PackageListResponse());
    await t.pumpAndSettle();
  }, skip: !_enabled);

  testWidgets('03 package list empty', (t) async {
    await shotList(t, '03_package_list_empty',
        () async => PackageListResponse.fromJson(
            {'status': true, 'data': {'packages': []}}));
  }, skip: !_enabled);

  testWidgets('04 package list error', (t) async {
    await shotList(t, '04_package_list_error',
        () async => throw const PackageApiException(PackageErrorKind.notFound));
  }, skip: !_enabled);
}
