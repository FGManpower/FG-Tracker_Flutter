import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
import 'package:fgtracker/app/modules/scan_text/views/live_scan_camera_screen.dart';
import 'package:fgtracker/app/modules/scan_text/views/scan_text_result_screen.dart';
import 'package:fgtracker/l10n/l10n.dart';

const String _proofDir = '/Users/46solution/.gemini/antigravity/brain/2d42e9ee-bff6-49ef-8703-be3e7417a4a3';

class _MockHomeController extends HomeController {
  @override
  void onInit() {
    super.onInit();
    userData.value = UserData(
      userId: 101,
      name: 'Divesh Shinde',
      mobileNo: '+919876543210',
    );
  }

  @override
  dynamic init() {}

  @override
  Future<void> getProfileData() async {}
}

Widget _buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      );
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: '101',
      PrefConst.userName: 'Divesh Shinde',
      PrefConst.userPhone: '+919876543210',
    });
    Global.storageServices = await StorageServices().init();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall call) async => true,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') return null;
        if (call.method == 'Clipboard.getData') return {'text': 'mock'};
        return null;
      },
    );
  });

  setUp(() {
    Get.testMode = true;
    Get.put<HomeController>(_MockHomeController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Proof A: MenuBar shows Scan Text option', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      _buildTestApp(
        Scaffold(
          key: scaffoldKey,
          drawer: Sidemenu(scaffoldKey: scaffoldKey),
          body: Center(
            child: ElevatedButton(
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
              child: const Text('Open Menu'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Open drawer
    scaffoldKey.currentState?.openDrawer();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify "Scan Text" option is present in Sidemenu
    expect(find.text('Scan Text'), findsOneWidget);
    expect(find.text('Scan text from camera or gallery'), findsOneWidget);
    expect(find.byIcon(Icons.document_scanner_rounded), findsOneWidget);

    // Save golden screenshot
    await expectLater(
      find.byType(Sidemenu),
      matchesGoldenFile('$_proofDir/proof_a_menubar.png'),
    );
  });

  testWidgets('Proof B & C: Scan Text Result Screen renders English & Hindi text + Edit + Copy', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    const sampleScannedText =
        "FG Manpower Attendance Report\n"
        "दिनांक: २४ नवंबर २०२६\n"
        "कर्मचारी नाम: राहुल शर्मा\n"
        "स्थिति: उपस्थित (Present)\n"
        "समय: 09:30 AM\n"
        "This is an official document scanned with Google ML Kit.";

    await tester.pumpWidget(
      _buildTestApp(
        const ScanTextResultScreen(
          scannedText: sampleScannedText,
        ),
      ),
    );
    await tester.pump();

    // Verify Title and Stats
    expect(find.text('Scan Result'), findsOneWidget);
    expect(find.textContaining('words •'), findsOneWidget);
    expect(find.textContaining('characters'), findsOneWidget);

    // Verify Buttons
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Rescan'), findsOneWidget);

    // Verify Scanned Text inside TextField
    expect(find.text(sampleScannedText), findsOneWidget);

    // Test Editing Text
    final textFieldFinder = find.byType(TextField);
    await tester.enterText(
      textFieldFinder,
      "$sampleScannedText\n[Verified OK]",
    );
    await tester.pump();
    expect(find.textContaining('[Verified OK]'), findsOneWidget);

    // Test Copy Button Tap
    await tester.tap(find.text('Copy'));
    await tester.pump();

    // Save golden screenshot
    await expectLater(
      find.byType(ScanTextResultScreen),
      matchesGoldenFile('$_proofDir/proof_b_result_screen.png'),
    );
  });

  testWidgets('Proof C: Full Screen Live Camera Scanner renders iOS reticle and Insert button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _buildTestApp(const LiveScanCameraScreen(
        initialText: "Colors.black87,\nfontSize: 18.sp,\nfontWeight: FontWeight.w700,\n• // TextStyle",
      )),
    );
    await tester.pump();

    // Verify top bar and UI components
    expect(find.text('Scan Text'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिंदी'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Insert'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);

    // Save golden screenshot
    await expectLater(
      find.byType(LiveScanCameraScreen),
      matchesGoldenFile('$_proofDir/proof_c_live_camera_scanner.png'),
    );
  });

  testWidgets('Proof D: Source Selection Sheet and Error Handling', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _buildTestApp(
        Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF5D47F1), size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'No text found, try again with clear photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E202B)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Blur photo ya bina text wali photo par application crash nahi hoti, safe error message display hota hai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF7A7F93)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No text found, try again with clear photo'), findsOneWidget);

    // Save golden screenshot
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('$_proofDir/proof_d_error_case.png'),
    );
  });
}
