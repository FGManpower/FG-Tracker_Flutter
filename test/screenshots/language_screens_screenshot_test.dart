// Renders the language UI to PNG in build/language_screenshots/ (not committed).
//
// Skipped in the normal test run. To regenerate (Windows — uses the system
// Segoe UI + Nirmala UI fonts so every Indian script renders):
//   flutter test test/screenshots/language_screens_screenshot_test.dart \
//     --dart-define=SCREENSHOTS=true --update-goldens
//
// These are harness renders of the real widgets (LanguageScreen,
// LanguageSettingsRow, LanguageSheet), not device captures.
import 'dart:io';

import 'package:fgtracker/features/language/language_controller.dart';
import 'package:fgtracker/features/language/language_options.dart';
import 'package:fgtracker/features/language/language_screen.dart';
import 'package:fgtracker/features/language/language_settings.dart';
import 'package:fgtracker/features/language/language_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _enabled = bool.fromEnvironment('SCREENSHOTS');
const _out = '../../build/language_screenshots';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final p in paths) {
      final f = File(p);
      if (f.existsSync()) {
        loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
      }
    }
    await loader.load();
  }

  await load('SegoeUI', [
    'C:/Windows/Fonts/segoeui.ttf',
    'C:/Windows/Fonts/segoeuib.ttf',
  ]);
  await load('NirmalaUI', ['C:/Windows/Fonts/Nirmala.ttc']);

  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ]);
}

void main() {
  setUpAll(() async {
    if (_enabled) await _loadFonts();
  });

  late LanguageController controller;

  Future<void> pump(WidgetTester tester, Widget home,
      {Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Get.testMode = true;
    controller = Get.put(LanguageController(), permanent: true);
    await controller.load();
    await tester.pumpWidget(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SegoeUI',
        fontFamilyFallback: const ['NirmalaUI'],
      ),
      locale: controller.appLocale,
      supportedLocales: kAppLanguages.map((o) => o.locale),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ));
    await tester.pumpAndSettle();
  }

  tearDown(Get.reset);

  // flutter_test paints shadows as solid blocks by default; render the real
  // blurred shadows for the capture so the PNG matches a device, then restore
  // the flag before the test ends (the binding asserts it is unchanged).
  Future<void> shot(WidgetTester tester, String name) async {
    debugDisableShadows = false;
    try {
      tester.binding.renderViews.first.markNeedsPaint();
      for (final e in find.byType(Container).evaluate()) {
        e.renderObject?.markNeedsPaint();
      }
      await tester.pump();
      await expectLater(
          find.byType(MaterialApp), matchesGoldenFile('$_out/$name'));
    } finally {
      debugDisableShadows = true;
      await tester.pump();
    }
  }

  testWidgets('1 — English selected', (tester) async {
    await pump(tester, const LanguageScreen());
    await shot(tester, '01_language_en.png');
  }, skip: !_enabled);

  testWidgets('2 — मराठी selected (live preview)', (tester) async {
    await pump(tester, const LanguageScreen());
    await tester.tap(find.byKey(const ValueKey('language-card-mr')));
    await tester.pumpAndSettle();
    await shot(tester, '02_language_mr.png');
  }, skip: !_enabled);

  testWidgets('3 — search with no match', (tester) async {
    await pump(tester, const LanguageScreen());
    await tester.enterText(find.byKey(const Key('language-search')), 'xyz');
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await shot(tester, '03_language_no_match.png');
  }, skip: !_enabled);

  testWidgets('3b — search "bangla"', (tester) async {
    await pump(tester, const LanguageScreen());
    await tester.enterText(find.byKey(const Key('language-search')), 'bangla');
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await shot(tester, '03b_language_search_bangla.png');
  }, skip: !_enabled);

  testWidgets('4 — Settings row + sheet', (tester) async {
    await pump(tester, const _SettingsHarness(),
        prefs: {LanguageController.prefKey: 'en'});
    await shot(tester, '04_settings_row.png');
    await tester.tap(find.byKey(const Key('settings-language-row')));
    await tester.pumpAndSettle();
    await shot(tester, '05_settings_sheet.png');
  }, skip: !_enabled);

  testWidgets('5 — Settings after picking हिन्दी', (tester) async {
    await pump(tester, const _SettingsHarness(),
        prefs: {LanguageController.prefKey: 'en'});
    await tester.tap(find.byKey(const Key('settings-language-row')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-card-hi')));
    await tester.pumpAndSettle();
    await shot(tester, '06_settings_row_hi.png');
  }, skip: !_enabled);

  testWidgets('6 — large text (1.3) → one column', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(tester, const LanguageScreen());
    await shot(tester, '07_language_text_scale_1_3.png');
  }, skip: !_enabled);
}

/// Stand-in for the side menu: shows LanguageSettingsRow in a list like the
/// app's drawer. (The real Sidemenu needs the API-backed HomeController.)
class _SettingsHarness extends StatelessWidget {
  const _SettingsHarness();

  @override
  Widget build(BuildContext context) {
    Widget stub(IconData icon, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LanguageColors.letterTile,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: LanguageColors.primary, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LanguageColors.text)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: LanguageColors.primary),
          ]),
        );
    return Scaffold(
      backgroundColor: LanguageColors.page,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Side menu',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: LanguageColors.text)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: LanguageColors.cardBorder),
                ),
                child: Column(children: [
                  stub(Icons.person_rounded, 'Edit Profile'),
                  const Divider(color: Color(0xFFF0ECFC), height: 1),
                  const LanguageSettingsRow(),
                  const Divider(color: Color(0xFFF0ECFC), height: 1),
                  stub(Icons.support_agent_rounded, 'Contact Us'),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
