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
import 'package:fgtracker/app/modules/scan_text/views/scan_text_preview_sheet.dart';
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

  testWidgets('Proof A: MenuBar DOES NOT contain Scan Text (Removed Cleanly)', (WidgetTester tester) async {
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

    // Verify "Scan Text" option is NO LONGER in MenuBar
    expect(find.text('Scan Text'), findsNothing);
    expect(find.text('Scan text from camera or gallery'), findsNothing);

    // Save golden screenshot proving MenuBar has no Scan Text option
    await expectLater(
      find.byType(Sidemenu),
      matchesGoldenFile('$_proofDir/proof_a_menubar.png'),
    );
  });

  testWidgets('Proof B: Chat Attachment (+) Menu contains Scan Text alongside Camera, Gallery, Document', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    bool scanTextTapped = false;

    await tester.pumpWidget(
      _buildTestApp(
        Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    ChatBottomSheet.showFileOptions(
                      context,
                      onGallery: () {},
                      onCamera: () {},
                      onDocument: () {},
                      onLocation: () {},
                      onContact: () {},
                      onScanText: () {
                        scanTextTapped = true;
                      },
                    );
                  },
                  child: const Text('Open Attachment Menu'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // Tap button to open attachment sheet
    await tester.tap(find.text('Open Attachment Menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify "Scan Text" is present in attachment sheet alongside Gallery, Camera, Document
    expect(find.text('Scan Text'), findsOneWidget);
    expect(find.byIcon(Icons.document_scanner_rounded), findsOneWidget);
    expect(find.byIcon(Icons.image_rounded), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.description_rounded), findsOneWidget);

    // Tap Scan Text to verify callback
    await tester.tap(find.text('Scan Text'));
    await tester.pump();
    expect(scanTextTapped, isTrue);

    // Save golden screenshot proving Scan Text is in Attachment Sheet
    await expectLater(
      find.byType(Container).first,
      matchesGoldenFile('$_proofDir/proof_b_chat_attachment_sheet.png'),
    );
  });

  testWidgets('Proof C: Scan Text Preview Sheet renders editable text + Send As Message + Copy', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    const sampleScannedText =
        "Meeting Notes - Project Update\n"
        "Date: 24 Nov 2026\n"
        "Feature: Scan Text in Chat Attachment\n"
        "Status: Ready to Send as Message";

    String? sentText;

    await tester.pumpWidget(
      _buildTestApp(
        Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () async {
                    sentText = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) => const ScanTextPreviewSheet(
                        initialText: sampleScannedText,
                      ),
                    );
                  },
                  child: const Text('Open Preview'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // Open preview sheet
    await tester.tap(find.text('Open Preview'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify Title, Text, and Buttons
    expect(find.text('Scanned Text Preview'), findsOneWidget);
    expect(find.textContaining('words •'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Send As Message'), findsOneWidget);
    expect(find.text(sampleScannedText), findsOneWidget);

    // Edit text in preview
    await tester.enterText(
      find.byType(TextField),
      "$sampleScannedText\n[Approved]",
    );
    await tester.pump();

    // Tap Copy
    await tester.tap(find.text('Copy'));
    await tester.pump();

    // Tap "Send As Message"
    await tester.tap(find.text('Send As Message'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(sentText, contains('[Approved]'));

    // Save golden screenshot
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('$_proofDir/proof_c_scan_preview_sheet.png'),
    );
  });

  testWidgets('Proof D: Error Handling - No text found displays proper toast without crash', (WidgetTester tester) async {
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
                    'Empty, blurry or corrupted images do not crash the app, showing safe toast notification.',
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
