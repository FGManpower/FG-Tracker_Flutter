import 'dart:convert';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/BottomSheet/bottom_actions_bar.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class _FakeGroupController extends GroupController {
  @override
  // ignore: must_call_super
  void onInit() {
    // Skip Hive cache warm-up in widget tests.
  }
}

// Valid 1x1 transparent PNG bytes for FileImage tests.
final List<int> _kTinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File tempPngFile;

  setUpAll(() {
    tempPngFile = File(
      '${Directory.systemTemp.path}/create_group_test_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    tempPngFile.writeAsBytesSync(_kTinyPng);
  });

  tearDownAll(() {
    if (tempPngFile.existsSync()) {
      tempPngFile.deleteSync();
    }
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> openSheet(
    WidgetTester tester, {
    required Size logicalSize,
    FakeViewPadding viewPadding = FakeViewPadding.zero,
  }) async {
    Get.reset();
    Get.put<GroupController>(_FakeGroupController(), permanent: true);

    const double dpr = 3.0;
    tester.view.devicePixelRatio = dpr;
    tester.view.physicalSize = logicalSize * dpr;
    tester.view.viewPadding = viewPadding;
    tester.view.padding = viewPadding;
    tester.view.viewInsets = FakeViewPadding.zero;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) => GetMaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
              child: ElevatedButton(
                onPressed: showCreateGroupSheet,
                child: const Text('Create Group Trigger'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Group Trigger'));
    await tester.pumpAndSettle();
  }

  ScrollableState bodyScrollable(WidgetTester tester) {
    final scrollView = tester.widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(CreateGroupSheet),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    final scrollableFinder = find.descendant(
      of: find.byWidget(scrollView),
      matching: find.byType(Scrollable),
    );
    return tester.state<ScrollableState>(scrollableFinder.first);
  }

  testWidgets('iOS (375x812): larger group image & fits in 1 view without scrolling',
      (tester) async {
    await openSheet(
      tester,
      logicalSize: const Size(375, 812),
      viewPadding: const FakeViewPadding(top: 47 * 3, bottom: 34 * 3),
    );

    expect(find.text('Create New Group'), findsOneWidget);
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.text('Group Description (Optional)'), findsOneWidget);
    expect(find.text('0/200'), findsOneWidget);
    expect(find.text('Create Group'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);

    // Bigger & clearly visible Group Image (>= 90px diameter).
    final imagePickerRect =
        tester.getRect(find.byKey(const ValueKey('create_group_image_picker')));
    expect(imagePickerRect.width, greaterThanOrEqualTo(90));
    expect(imagePickerRect.height, greaterThanOrEqualTo(90));

    // Zero scrolling needed when keyboard is closed.
    expect(bodyScrollable(tester).position.maxScrollExtent, 0.0);

    final sheetRect = tester.getRect(find.byType(CreateGroupSheet));
    final titleRect = tester.getRect(find.text('Create New Group'));
    final buttonRect = tester.getRect(find.text('Create Group'));

    expect(titleRect.top, greaterThanOrEqualTo(0));
    expect(buttonRect.bottom, lessThanOrEqualTo(812 - 34));
    expect(sheetRect.height, greaterThan(350));
    expect(sheetRect.height, lessThan(600));
  });

  testWidgets('Android compact (360x640): fits in 1 view without scrolling',
      (tester) async {
    await openSheet(
      tester,
      logicalSize: const Size(360, 640),
      viewPadding: const FakeViewPadding(top: 24 * 3),
    );

    expect(bodyScrollable(tester).position.maxScrollExtent, 0.0);

    final titleRect = tester.getRect(find.text('Create New Group'));
    final buttonRect = tester.getRect(find.text('Create Group'));
    expect(titleRect.top, greaterThanOrEqualTo(24));
    expect(buttonRect.bottom, lessThanOrEqualTo(640));
  });

  testWidgets(
      'Keyboard open & close (iOS 375x812): header fixed at top, field & Create button stay visible above keyboard',
      (tester) async {
    await openSheet(
      tester,
      logicalSize: const Size(375, 812),
      viewPadding: const FakeViewPadding(top: 47 * 3, bottom: 34 * 3),
    );

    final initialSheetRect = tester.getRect(find.byType(CreateGroupSheet));

    // Tap Group Name field and open keyboard (300px tall).
    await tester.tap(find.byType(TextFormField).first);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    tester.view.padding = const FakeViewPadding(top: 47 * 3);
    await tester.pumpAndSettle();

    final double visibleBottom = 812 - 300;
    final titleRect = tester.getRect(find.text('Create New Group'));
    final nameFieldRect = tester.getRect(find.byType(TextFormField).first);
    final buttonRect = tester.getRect(find.text('Create Group'));
    final sheetRectWithKb = tester.getRect(find.byType(CreateGroupSheet));

    // Top header fixed & visible below status bar.
    expect(titleRect.top, greaterThanOrEqualTo(47));
    // Sheet lifts above keyboard and isn't clipped off-screen.
    expect(sheetRectWithKb.top, greaterThanOrEqualTo(47));
    expect(sheetRectWithKb.bottom, lessThanOrEqualTo(visibleBottom + 0.5));
    // Active TextField & Create button both visible above keyboard.
    expect(nameFieldRect.bottom, lessThanOrEqualTo(buttonRect.top));
    expect(buttonRect.bottom, lessThanOrEqualTo(visibleBottom));

    // Close keyboard -> sheet returns to original position without scrolling.
    tester.view.viewInsets = FakeViewPadding.zero;
    tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
    await tester.pumpAndSettle();

    final restoredRect = tester.getRect(find.byType(CreateGroupSheet));
    expect(restoredRect.bottom, closeTo(initialSheetRect.bottom, 1.0));
  });

  testWidgets(
      'Keyboard open on compact Android (360x640): description field & Create button stay visible above keyboard',
      (tester) async {
    await openSheet(
      tester,
      logicalSize: const Size(360, 640),
      viewPadding: const FakeViewPadding(top: 24 * 3),
    );

    // Focus Group Description field and open 260px keyboard.
    await tester.tap(find.byType(TextFormField).last);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260 * 3);
    await tester.pumpAndSettle();

    final double visibleBottom = 640 - 260;
    final titleRect = tester.getRect(find.text('Create New Group'));
    final descFieldRect = tester.getRect(find.byType(TextFormField).last);
    final buttonRect = tester.getRect(find.text('Create Group'));

    expect(titleRect.top, greaterThanOrEqualTo(24));
    expect(descFieldRect.bottom, lessThanOrEqualTo(visibleBottom));
    expect(buttonRect.bottom, lessThanOrEqualTo(visibleBottom));

    // Typing updates description counter & validation works.
    await tester.enterText(find.byType(TextFormField).last, 'Project team');
    await tester.pump();
    expect(find.text('12/200'), findsOneWidget);

    await tester.tap(find.text('Create Group'));
    await tester.pumpAndSettle();
    // Group Name is empty -> validation error shown without throwing overflow.
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Closing sheet via X without creating clears Name, Description & Image; reopen shows empty sheet',
      (tester) async {
    await openSheet(
      tester,
      logicalSize: const Size(375, 812),
      viewPadding: const FakeViewPadding(top: 47 * 3, bottom: 34 * 3),
    );

    final controller = Get.find<GroupController>();
    await tester.enterText(find.byType(TextFormField).first, 'Unsaved Group');
    await tester.enterText(find.byType(TextFormField).last, 'Draft desc');
    controller.selectedGroupImage.value = XFile(tempPngFile.path);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(controller.groupName.text, 'Unsaved Group');
    expect(controller.groupDesc.text, 'Draft desc');
    expect(controller.selectedGroupImage.value, isNotNull);

    // Close via header X button (without tapping Create Group).
    final closeIcon = find.descendant(
      of: find.byType(CreateGroupSheet),
      matching: find.byIcon(Icons.close),
    );
    // Two close icons now (image remove badge + header X); header X is first.
    await tester.tap(closeIcon.first);
    await tester.pumpAndSettle();

    expect(find.byType(CreateGroupSheet), findsNothing);
    expect(controller.groupName.text, isEmpty);
    expect(controller.groupDesc.text, isEmpty);
    expect(controller.selectedGroupImage.value, isNull);

    // Reopen -> completely clean empty sheet.
    await tester.tap(find.text('Create Group Trigger'));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved Group'), findsNothing);
    expect(find.text('Draft desc'), findsNothing);
    expect(find.text('0/200'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
  });

  testWidgets(
      'Dismissing sheet via outside barrier tap clears Name, Description & Image',
      (tester) async {
    await openSheet(
      tester,
      logicalSize: const Size(375, 812),
      viewPadding: const FakeViewPadding(top: 47 * 3, bottom: 34 * 3),
    );

    final controller = Get.find<GroupController>();
    await tester.enterText(find.byType(TextFormField).first, 'Barrier Draft');
    controller.selectedGroupImage.value = XFile(tempPngFile.path);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Tap dimmed barrier area above the bottom sheet.
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();

    expect(find.byType(CreateGroupSheet), findsNothing);
    expect(controller.groupName.text, isEmpty);
    expect(controller.groupDesc.text, isEmpty);
    expect(controller.selectedGroupImage.value, isNull);
  });
}
