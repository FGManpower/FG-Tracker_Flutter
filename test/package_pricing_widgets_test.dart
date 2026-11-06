import 'dart:async';

import 'package:fgtracker/app/Data/Repositories/package_api_error.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:fgtracker/app/modules/PackagePricing/Controller/package_list_controller.dart';
import 'package:fgtracker/app/modules/PackagePricing/Views/package_list_view.dart';
import 'package:fgtracker/app/modules/PackagePricing/widgets/package_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Phone-sized surface (375×812) so ScreenUtil and layout agree
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _app(Widget home, {double textScale = 1.0}) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
      ),
    );

PackageListResponse _list(List<Map<String, dynamic>> items) =>
    PackageListResponse.fromJson({
      'status': true,
      'data': {'packages': items},
    });

void main() {
  tearDown(Get.reset);

  group('Package list screen', () {
    testWidgets('shows the loader while the API is pending', (tester) async {
      _phone(tester);
      final pending = Completer<PackageListResponse>();
      Get.put(PackageListController(loader: () => pending.future));

      await tester.pumpWidget(_app(const PackageListView()));
      await tester.pump();
      expect(find.byWidgetPredicate((w) => w is Skeletonizer), findsWidgets);
      // Skeleton bones use the placeholder card, not real data
      expect(find.text('Package name here'), findsWidgets);

      pending.complete(_list(const []));
      await tester.pumpAndSettle();
    });

    testWidgets('lists packages from the API in sortOrder', (tester) async {
      _phone(tester);
      Get.put(PackageListController(
        loader: () async => _list([
          {'moduleKey': 'attendance', 'title': 'Attendance', 'sortOrder': 2},
          {'moduleKey': 'walkie_talkie', 'title': 'Walkie-Talkie',
            'sortOrder': 1},
          {'moduleKey': '', 'title': 'Broken row is skipped'},
        ]),
      ));

      await tester.pumpWidget(_app(const PackageListView()));
      await tester.pumpAndSettle();

      expect(find.byType(PackageCard), findsNWidgets(2));
      final titles = tester
          .widgetList<PackageCard>(find.byType(PackageCard))
          .map((c) => c.item.title)
          .toList();
      expect(titles, ['Walkie-Talkie', 'Attendance']);
      expect(find.text('View plans'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      expect(find.textContaining('Starts at'), findsNothing);
    });

    testWidgets('empty list shows the empty state', (tester) async {
      _phone(tester);
      Get.put(PackageListController(loader: () async => _list(const [])));

      await tester.pumpWidget(_app(const PackageListView()));
      await tester.pumpAndSettle();

      expect(find.text('No packages are available right now.'),
          findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    for (final kind in [
      PackageErrorKind.notFound,
      PackageErrorKind.unauthorized,
      PackageErrorKind.server,
      PackageErrorKind.timeout,
      PackageErrorKind.offline,
      PackageErrorKind.malformed,
    ]) {
      testWidgets('${kind.name}: friendly error + Retry', (tester) async {
      _phone(tester);
        var calls = 0;
        final error = PackageApiException(kind,
            debugMessage: "Can't find /api/packages on the server!");
        Get.put(PackageListController(loader: () async {
          calls++;
          throw error;
        }));

        await tester.pumpWidget(_app(const PackageListView()));
        await tester.pumpAndSettle();

        expect(find.text(error.userMessage), findsOneWidget);
        expect(find.textContaining("Can't find"), findsNothing);
        expect(find.text('Try again'), findsOneWidget);
        if (kind == PackageErrorKind.offline) {
          expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
        }

        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(calls, 2);
      });
    }

    testWidgets('Retry after an error shows the list', (tester) async {
      _phone(tester);
      var fail = true;
      Get.put(PackageListController(loader: () async {
        if (fail) {
          fail = false;
          throw const PackageApiException(PackageErrorKind.offline);
        }
        return _list([
          {'moduleKey': 'walkie_talkie', 'title': 'Walkie-Talkie'},
        ]);
      }));

      await tester.pumpWidget(_app(const PackageListView()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(PackageCard), findsOneWidget);
    });

    testWidgets('long names and large font do not overflow', (tester) async {
      _phone(tester);
      Get.put(PackageListController(
        loader: () async => _list([
          {
            'moduleKey': 'safe_zone_route',
            'title': 'Safe Zone + Safe Route with a very very long name ' * 3,
            'tagline': 'A long tagline that keeps going ' * 6,
            'badge': 'Most popular choice',
            'highlights': ['Geo-fence alerts for everyone', 'Route deviation',
              'History'],
          },
        ]),
      ));

      await tester.pumpWidget(
          _app(const PackageListView(), textScale: 1.6));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('4 modules: Walkie-Talkie open, other 3 Coming soon',
        (tester) async {
      _phone(tester);
      Get.put(PackageListController(
        loader: () async => _list([
          for (final (i, key, title) in [
            (1, 'attendance', 'Attendance'),
            (2, 'walkie_talkie', 'Walkie-Talkie'),
            (3, 'safe_zone_route', 'Safe Zone + Safe Route'),
            (4, 'live_tracking', 'Live Tracking'),
          ])
            {
              'moduleKey': key,
              'title': title,
              'isAvailable': true,
              'sortOrder': i,
            },
        ]),
      ));

      await tester.pumpWidget(_app(const PackageListView()));
      await tester.pumpAndSettle();

      expect(find.byType(PackageCard), findsNWidgets(4));
      final cards =
          tester.widgetList<PackageCard>(find.byType(PackageCard)).toList();
      final open = cards.where((c) => c.item.isAvailable).map((c) => c.item);
      expect(open.map((i) => i.moduleKey), ['walkie_talkie']);
      expect(find.text('View plans'), findsOneWidget);
      expect(find.text('Coming soon'), findsNWidgets(3));
    });

    testWidgets('small screen (320) does not overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      Get.put(PackageListController(
        loader: () async => _list([
          {'moduleKey': 'walkie_talkie', 'title': 'Walkie-Talkie',
            'tagline': 'Push-to-talk voice for your group', 'badge': 'New',
            'highlights': ['Push to talk', 'Team channels']},
          {'moduleKey': 'safe_zone_route', 'title': 'Safe Zone + Safe Route',
            'tagline': 'Geo-fence alerts and route deviation alerts',
            'highlights': ['Geo-fence', 'Route alerts']},
        ]),
      ));

      await tester.pumpWidget(_app(const PackageListView(), textScale: 1.3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
