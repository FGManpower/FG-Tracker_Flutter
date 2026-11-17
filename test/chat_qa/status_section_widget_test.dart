// QA widget tests for lib/app/modules/status/views/status_section.dart
// ("My Status" popup + contact rings). Network is avoided with a fake feed
// controller and a status socket service that never connects.
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:fgtracker/app/modules/status/views/status_section.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeFeed extends StatusFeedController {
  @override
  Future<void> refreshAll() async {}
  @override
  Future<void> fetchMyStatuses() async {}
}

StatusItemModel st(int id, {bool viewed = false}) =>
    StatusItemModel.fromJson({'id': id, 'type': 'text', 'isViewed': viewed});

ContactStatusGroupModel grp(int id, String name, {required bool allViewed}) =>
    ContactStatusGroupModel(
      user: StatusCreatorUser(id: id, name: name),
      isAllViewed: allViewed,
      latestTimestamp: DateTime(2026, 11, 16),
      statuses: [st(id * 10, viewed: allViewed)],
    );

Widget app() => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SafeArea(child: StatusSection())),
      ),
    );

void main() {
  late FakeFeed feed;

  setUp(() {
    // T-04 (Run 2): start every test from a clean GetX state with a fixed
    // language, so nothing left by an earlier test (permanent services,
    // locale, popup route) changes what this one finds.
    Get.reset();
    Get.testMode = true;
    Get.locale = const Locale('en');
    Get.put(StatusSocketService(), permanent: true);
    feed = Get.put<StatusFeedController>(FakeFeed(), permanent: true)
        as FakeFeed;
  });

  tearDown(Get.reset);

  Future<void> phone(WidgetTester tester) async {
    // Real phone size (375x812 dp) so ScreenUtil scale = 1.
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> openPopup(WidgetTester tester) async {
    await tester.tap(find.text('My Status'));
    await tester.pumpAndSettle();
  }

  testWidgets('no own status: popup offers only "Add to My Status"',
      (tester) async {
    await phone(tester);
    await tester.pumpWidget(app());
    await openPopup(tester);
    expect(find.text('Add to My Status'), findsOneWidget);
    expect(find.text('View My Status'), findsNothing);
  });

  testWidgets('with own statuses: shows count and "View My Status"',
      (tester) async {
    feed.myStatuses.assignAll([st(1), st(2)]);
    await phone(tester);
    await tester.pumpWidget(app());
    expect(find.text('2 active'), findsOneWidget);
    await openPopup(tester);
    expect(find.text('View My Status'), findsOneWidget);
    expect(find.text('Add to My Status'), findsOneWidget);
  });

  testWidgets('tap outside dismisses the popup and the screen stays usable',
      (tester) async {
    await phone(tester);
    await tester.pumpWidget(app());
    await openPopup(tester);
    await tester.tapAt(const Offset(20, 700));
    await tester.pumpAndSettle();
    expect(find.text('Add to My Status'), findsNothing);
    await openPopup(tester); // touch still works: popup opens again
    expect(find.text('Add to My Status'), findsOneWidget);
  });

  testWidgets('system back dismisses the popup', (tester) async {
    await phone(tester);
    await tester.pumpWidget(app());
    await openPopup(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Add to My Status'), findsNothing);
  });

  testWidgets('contacts show New / Viewed with the matching ring',
      (tester) async {
    feed.contactGroups.assignAll([
      grp(1, 'Asha', allViewed: false),
      grp(2, 'Ravi', allViewed: true),
    ]);
    await phone(tester);
    await tester.pumpWidget(app());
    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Viewed'), findsOneWidget);
  });

  testWidgets('live delete removes the contact ring', (tester) async {
    feed.contactGroups.assignAll([grp(1, 'Asha', allViewed: false)]);
    await phone(tester);
    await tester.pumpWidget(app());
    expect(find.text('Asha'), findsOneWidget);
    feed.onStatusDeletedReceived(10, 1);
    await tester.pumpAndSettle();
    expect(find.text('Asha'), findsNothing);
  });
}
