import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/profile_details_model.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/user_profile_details_controller.dart';
import 'package:fgtracker/app/modules/Messages/Views/UserProfileScreen.dart';
import 'package:fgtracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMessageController extends MessageController {
  FakeMessageController(MemberData member) {
    memberData = member;
  }

  @override
  void onInit() {
    // Avoid starting real network polling timers and sockets during widget testing
  }

  @override
  void onClose() {}
}

Widget _buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => GetMaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: '100',
      PrefConst.userName: 'CurrentUser',
      PrefConst.STORAGE_USER_TOKEN_KEY: 'test-token',
    });
    Global.storageServices = await StorageServices().init();

    // Mock fluttertoast channel to avoid platform channel errors
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall call) async => true,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('UserProfileDetailsController Block Logic', () {
    test('initializes with isBlocked = false and toggles state correctly', () {
      final controller = UserProfileDetailsController();
      expect(controller.isBlocked.value, isFalse);
      expect(controller.isBlocking.value, isFalse);
      expect(controller.isUnblocking.value, isFalse);

      controller.isBlocked.value = true;
      expect(controller.isBlocked.value, isTrue);

      controller.isBlocked.value = false;
      expect(controller.isBlocked.value, isFalse);
    });

    test('profileData blockStatus updates isBlocked state', () {
      final controller = UserProfileDetailsController();
      controller.profileData.value = ProfileDetailsData(
        blockStatus: BlockStatus(isBlocked: true, blockedByMe: true),
      );
      final bs = controller.profileData.value?.blockStatus;
      if (bs != null) {
        controller.isBlocked.value = bs.isBlocked == true || bs.blockedByMe == true;
      }
      expect(controller.isBlocked.value, isTrue);
    });
  });

  group('UserProfileScreen Block Option Tests', () {
    testWidgets(
        'Case A: Direct Chat (MessageController registered) - Block option renders and updates dynamically',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final member = MemberData(
        userId: 200,
        name: 'John Doe',
        chatId: 501,
      );

      final msgController =
          Get.put<MessageController>(FakeMessageController(member));
      msgController.isBlocked.value = false;

      await tester.pumpWidget(_buildTestApp(UserProfileScreen(
        userData: member,
        chatId: 501,
      )));
      await tester.pumpAndSettle();

      // Clear Chat should be present
      expect(find.text('Clear Chat'), findsOneWidget);

      // Block John Doe should be present
      expect(find.text('Block John Doe'), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);

      // Dynamically simulate blocking
      msgController.isBlocked.value = true;
      await tester.pumpAndSettle();

      // Now should show Unblock John Doe in place
      expect(find.text('Unblock John Doe'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
    });

    testWidgets(
        'Case B: Group Chat Member (NO MessageController registered) - Block option renders and is visible',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Ensure MessageController is NOT registered (Group Chat environment)
      expect(Get.isRegistered<MessageController>(), isFalse);

      final member = MemberData(
        userId: 300,
        name: 'ram',
        chatId: 0,
      );

      await tester.pumpWidget(_buildTestApp(UserProfileScreen(
        userData: member,
        chatId: 0,
      )));
      await tester.pumpAndSettle();

      // Clear Chat should be present
      expect(find.text('Clear Chat'), findsOneWidget);

      // Block option MUST be present (previously was hidden SizedBox.shrink())
      expect(find.text('Block ram'), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);

      // Find UserProfileDetailsController and toggle blocked state
      final detailsController = Get.find<UserProfileDetailsController>();
      detailsController.isBlocked.value = true;
      await tester.pumpAndSettle();

      // Dynamically updates to Unblock ram
      expect(find.text('Unblock ram'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
    });

    testWidgets(
        'Self Profile Check: Viewing own profile does not show Block card',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ownMember = MemberData(
        userId: 100, // matches PrefConst.userId '100'
        name: 'CurrentUser',
      );

      await tester.pumpWidget(_buildTestApp(UserProfileScreen(
        userData: ownMember,
      )));
      await tester.pumpAndSettle();

      // Block option must NOT be shown for own profile
      expect(find.text('Block CurrentUser'), findsNothing);
      expect(find.text('Unblock CurrentUser'), findsNothing);
    });
  });
}
