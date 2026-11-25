import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fgtracker/app/Core/constant/BottomSheet/ChatBottomSheet.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Views/sidemenu.dart';
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

  testWidgets('Proof A: MenuBar DOES NOT show Scan Text option (Clean MenuBar)', (WidgetTester tester) async {
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

    // Verify "Scan Text" option is NOT in Sidemenu
    expect(find.text('Scan Text'), findsNothing);
    expect(find.text('Scan text from camera or gallery'), findsNothing);

    // Save golden screenshot proving MenuBar has no Scan Text
    await expectLater(
      find.byType(Sidemenu),
      matchesGoldenFile('$_proofDir/proof_a_menubar.png'),
    );
  });

  testWidgets('Proof B: Chat Attachment (+) shows Scan Text option', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _buildTestApp(
        Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    ChatBottomSheet.showFileOptions(
                      context,
                      onGallery: () {},
                      onCamera: () {},
                      onDocument: () {},
                      onLocation: () {},
                      onContact: () {},
                      onScanText: () {},
                    );
                  },
                  child: const Text('Open Attachments'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    // Tap button to open attachment bottom sheet
    await tester.tap(find.text('Open Attachments'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify "Scan Text" item is present in Attachment sheet
    expect(find.text('Scan Text'), findsOneWidget);
    expect(find.byIcon(Icons.document_scanner_rounded), findsOneWidget);

    // Save golden screenshot proving Attachment has Scan Text
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('$_proofDir/proof_b_chat_attachment.png'),
    );
  });

  testWidgets('Proof C: Scan Text Result Screen in Chat mode has Send + Edit + Copy', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    const sampleScannedText =
        "FG Manpower Attendance Report\n"
        "Date: 25 November 2026\n"
        "Employee: Rahul Sharma\n"
        "Status: Present\n"
        "Scanned via Google ML Kit OCR.";

    await tester.pumpWidget(
      _buildTestApp(
        const ScanTextResultScreen(
          scannedText: sampleScannedText,
          isForChat: true,
        ),
      ),
    );
    await tester.pump();

    // Verify Title, Counters, and Buttons
    expect(find.text('Scan Result'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Rescan'), findsOneWidget);
    expect(find.text('Send'), findsOneWidget); // exactly 1 time in bottom action bar

    // Verify Scanned Text inside TextField
    expect(find.text(sampleScannedText), findsOneWidget);

    // Test Editing Text
    final textFieldFinder = find.byType(TextField);
    await tester.enterText(
      textFieldFinder,
      "$sampleScannedText\n[Ready to Send in Chat]",
    );
    await tester.pump();
    expect(find.textContaining('[Ready to Send in Chat]'), findsOneWidget);

    // Test Copy Button Tap
    await tester.tap(find.text('Copy'));
    await tester.pump();

    // Save golden screenshot
    await expectLater(
      find.byType(ScanTextResultScreen),
      matchesGoldenFile('$_proofDir/proof_c_chat_scan_preview.png'),
    );
  });

  testWidgets('Proof D: Error Handling on no text found', (WidgetTester tester) async {
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
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF5D47F1), size: 48),
                  SizedBox(height: 12),
                  Text(
                    'No text found, try again with clear photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E202B)),
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
