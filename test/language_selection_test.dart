import 'package:fgtracker/features/language/language_controller.dart';
import 'package:fgtracker/features/language/language_options.dart';
import 'package:fgtracker/features/language/language_screen.dart';
import 'package:fgtracker/features/language/language_settings.dart';
import 'package:fgtracker/features/language/widgets/language_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language screen, side menu sheet and OTP routing.
///
/// The OTP / Register / Home pages are stubs. OtpController wraps only the
/// new-user Register call in LanguageController.showBeforeRegistration;
/// existing users navigate exactly as before (no Language screen).
void main() {
  late int registerPushes;
  late LanguageController controller;

  const otp = '/OTPScreen';
  const register = '/register';
  const home = '/Home_Screen';

  /// Mirrors OtpController: new user → Language screen → toNamed(Register,
  /// {"mobNo"}).
  void otpNewUser() => controller.showBeforeRegistration(() {
        registerPushes++;
        Get.toNamed(register, arguments: {'mobNo': '9876543210'});
      });

  /// Mirrors OtpController: existing user → offAllNamed(Home), the original
  /// call with no Language screen.
  void otpExistingUser() => Get.offAllNamed(home);

  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    Locale device = const Locale('en'),
    double textScale = 1.0,
    Size size = const Size(390, 844),
    Widget? homeBody,
    Widget? homeDrawer,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    // The phone language. The app must ignore it (English by default).
    tester.platformDispatcher.localeTestValue = device;
    tester.platformDispatcher.localesTestValue = [device];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    controller = Get.put(LanguageController(), permanent: true);
    await controller.load();

    await tester.pumpWidget(GetMaterialApp(
      initialRoute: otp,
      locale: controller.appLocale,
      fallbackLocale: const Locale('en'),
      supportedLocales: kAppLanguages.map((o) => o.locale),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      getPages: [
        GetPage(
          name: otp,
          page: () => const Scaffold(body: Text('OTP')),
        ),
        GetPage(
          name: LanguageController.routeName,
          page: () => const LanguageScreen(),
          popGesture: false,
        ),
        GetPage(
          name: register,
          page: () => Scaffold(
            body: Text('REGISTER ${(Get.arguments as Map)['mobNo']}'),
          ),
        ),
        GetPage(
          name: home,
          page: () => Scaffold(
            drawer: homeDrawer,
            body: homeBody ?? const Text('HOME'),
          ),
        ),
      ],
    ));
    await tester.pumpAndSettle();
  }

  Future<void> openLanguageScreen(WidgetTester tester,
      {Locale device = const Locale('en'),
      double textScale = 1.0,
      Size size = const Size(390, 844)}) async {
    await pumpApp(tester, device: device, textScale: textScale, size: size);
    otpNewUser();
    await tester.pumpAndSettle();
    expect(find.byType(LanguageScreen), findsOneWidget);
  }

  List<LanguageCard> cards(WidgetTester tester) =>
      tester.widgetList<LanguageCard>(find.byType(LanguageCard)).toList();

  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  setUp(() {
    Get.testMode = true;
    registerPushes = 0;
  });

  tearDown(Get.reset);

  group('Language screen', () {
    testWidgets('shows language cards, exactly one selected',
        (tester) async {
      await openLanguageScreen(tester);

      expect(cards(tester).where((c) => c.selected), hasLength(1));
      expect(cards(tester).first.option.code, 'en');
      expect(cards(tester).first.selected, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone in Hindi → English pre-selected, fixed order',
        (tester) async {
      await openLanguageScreen(tester, device: const Locale('hi', 'IN'));
      expect(cards(tester).first.option.code, 'en');
      expect(cards(tester).singleWhere((c) => c.selected).option.code, 'en');
      expect(find.text('Choose your language'), findsOneWidget);
    });

    testWidgets('nothing saved → app is English even with the phone in Hindi',
        (tester) async {
      await pumpApp(tester, device: const Locale('hi', 'IN'));
      expect(controller.appLocale, const Locale('en'));
      final ctx = tester.element(find.text('OTP'));
      expect(Localizations.localeOf(ctx).languageCode, 'en');
      expect(MaterialLocalizations.of(ctx).okButtonLabel, 'OK');
    });

    testWidgets('unsupported phone language falls back to English',
        (tester) async {
      await openLanguageScreen(tester, device: const Locale('ru', 'RU'));
      expect(cards(tester).first.option.code, 'en');
      expect(find.text('Choose your language'), findsOneWidget);
    });

    testWidgets('tapping a card previews title/subtitle/hint/button live',
        (tester) async {
      await openLanguageScreen(tester);

      final hiCard = find.byKey(const ValueKey('language-card-hi'));
      await tester.tap(hiCard);
      await tester.pumpAndSettle();

      expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
      expect(
          find.text('आप इसे कभी भी मेनू से बदल सकते हैं'),
          findsOneWidget);
      expect(find.text('भाषा खोजें'), findsOneWidget);
      expect(find.text('आगे बढ़ें'), findsOneWidget);
      expect(find.text('Choose your language'), findsNothing);

      final selected = cards(tester).where((c) => c.selected).toList();
      expect(selected.single.option.code, 'hi');

      // Nothing is saved until Continue.
      expect((await prefs()).getString(LanguageController.prefKey), isNull);
    });

    testWidgets('search: alias, native script, code, no match, clear',
        (tester) async {
      await openLanguageScreen(tester);
      final search = find.byKey(const Key('language-search'));

      Future<List<String>> results(String q) async {
        await tester.enterText(search, q);
        await tester.pumpAndSettle();
        return cards(tester).map((c) => c.option.code).toList();
      }

      expect(await results('bangla'), ['bn']);
      expect(await results('gujrati'), ['gu']);
      expect(await results('kanada'), ['kn']);
      expect(await results('panjabi'), ['pa']);
      expect(await results('oriya'), ['or']);
      expect(await results('odisa'), ['or']);
      expect(await results('मराठी'), ['mr']);
      expect(await results('tamil'), ['ta']);
      expect(await results('TELUGU'), ['te']);
      expect(await results('espanol'), ['es']);
      expect(await results('french'), ['fr']);
      expect(await results('deutsch'), ['de']);
      expect(await results('arabic'), ['ar']);
      expect(await results('portugues'), ['pt']);
      expect(await results('日本語'), ['ja']);
      expect((await results('中文')).contains('zh'), isTrue);

      expect(await results('xyz'), isEmpty);
      expect(find.text('No language found'), findsOneWidget);

      // No-match text follows the previewed language.
      await tester.enterText(search, '');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('language-card-hi')));
      await tester.enterText(search, 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('कोई भाषा नहीं मिली'), findsOneWidget);

      await tester.tap(find.byKey(const Key('language-search-clear')));
      await tester.pumpAndSettle();
      expect(cards(tester), isNotEmpty);
      expect(find.byKey(const Key('language-search-clear')), findsNothing);
    });

    testWidgets('screen reader label reads "Hindi, हिन्दी" + selected',
        (tester) async {
      final handle = tester.ensureSemantics();
      await openLanguageScreen(tester);
      await tester.tap(find.byKey(const ValueKey('language-card-hi')));
      await tester.pumpAndSettle();
      final node = tester.getSemantics(find.bySemanticsLabel('Hindi, हिन्दी'));
      expect(
        node,
        matchesSemantics(
          label: 'Hindi, हिन्दी',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('text scale 1.3 → one column, no overflow', (tester) async {
      await openLanguageScreen(tester, textScale: 1.3);
      final grid =
          tester.widget<GridView>(find.byKey(const Key('language-grid')));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('default text scale → two columns', (tester) async {
      await openLanguageScreen(tester);
      final grid =
          tester.widget<GridView>(find.byKey(const Key('language-grid')));
      expect(
          (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
              .crossAxisCount,
          2);
    });

    testWidgets('small phone: grid scrolls, Continue stays visible',
        (tester) async {
      await openLanguageScreen(tester, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
      final button = find.byKey(const Key('language-continue'));
      expect(tester.getRect(button).bottom, lessThanOrEqualTo(568));
      await tester.dragUntilVisible(
        find.byKey(const ValueKey('language-card-zh')),
        find.byKey(const Key('language-grid')),
        const Offset(0, -200),
      );
      expect(tester.getRect(button).bottom, lessThanOrEqualTo(568));
    });

    testWidgets('tablet: content is max 480 wide and centred', (tester) async {
      await openLanguageScreen(tester, size: const Size(1024, 1366));
      final r = tester.getRect(find.byKey(const Key('language-continue')));
      expect(r.width, lessThanOrEqualTo(480));
      expect((r.center.dx - 512).abs(), lessThan(1));
    });

    testWidgets('back does nothing (never skips, never returns to OTP)',
        (tester) async {
      await openLanguageScreen(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LanguageScreen), findsOneWidget);
      expect(find.text('OTP'), findsNothing);
    });
  });

  group('Continue', () {
    testWidgets(
        'shows loader, ignores double tap, saves, opens Registration with '
        'the same arguments, Back goes to OTP as today', (tester) async {
      await openLanguageScreen(tester);
      await tester.tap(find.byKey(const ValueKey('language-card-hi')));
      await tester.pumpAndSettle();

      final button = find.byKey(const Key('language-continue'));
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(registerPushes, 1);
      expect(find.text('REGISTER 9876543210'), findsOneWidget);
      expect((await prefs()).getString(LanguageController.prefKey), 'hi');
      expect(controller.savedCode.value, 'hi');
      expect(Get.locale, const Locale('hi'));

      // Language screen was removed from the stack: Back → OTP (unchanged).
      Get.back();
      await tester.pumpAndSettle();
      expect(find.text('OTP'), findsOneWidget);
      expect(find.byType(LanguageScreen), findsNothing);
    });

    testWidgets('existing user, nothing saved: OTP → Home, no Language screen',
        (tester) async {
      await pumpApp(tester);
      otpExistingUser();
      await tester.pumpAndSettle();

      expect(find.byType(LanguageScreen), findsNothing);
      expect(find.text('HOME'), findsOneWidget);
      expect(Navigator.of(tester.element(find.text('HOME'))).canPop(), isFalse);
      expect(controller.hasPendingRegistration, isFalse);
      // Nothing saved → the app stays English.
      expect((await prefs()).getString(LanguageController.prefKey), isNull);
      expect(Localizations.localeOf(tester.element(find.text('HOME'))),
          const Locale('en'));
      expect(tester.takeException(), isNull);
    });
  });

  group('Routing after OTP', () {
    testWidgets('new user, nothing saved → Language screen first',
        (tester) async {
      await pumpApp(tester);
      otpNewUser();
      await tester.pumpAndSettle();
      expect(find.byType(LanguageScreen), findsOneWidget);
      expect(registerPushes, 0);
    });

    testWidgets(
        'new user, language already saved → Language screen still shows '
        '(English pre-selected, never the saved one), then Registration', (tester) async {
      await pumpApp(tester, prefs: {LanguageController.prefKey: 'es'});
      expect(controller.hasSavedLanguage, isTrue);
      otpNewUser();
      await tester.pumpAndSettle();
      expect(find.byType(LanguageScreen), findsOneWidget);
      expect(registerPushes, 0);
      expect(cards(tester).singleWhere((c) => c.selected).option.code, 'en');

      await tester.tap(find.byKey(const Key('language-continue')));
      await tester.pumpAndSettle();
      expect(find.text('REGISTER 9876543210'), findsOneWidget);
      expect(registerPushes, 1);
    });

    testWidgets('saved language → existing user goes straight Home',
        (tester) async {
      await pumpApp(tester, prefs: {LanguageController.prefKey: 'hi'});
      otpExistingUser();
      await tester.pumpAndSettle();
      expect(find.byType(LanguageScreen), findsNothing);
      expect(find.text('HOME'), findsOneWidget);
    });

    test('an unknown saved code is ignored (treated as not chosen)', () async {
      SharedPreferences.setMockInitialValues(
          {LanguageController.prefKey: 'xx'});
      final c = await LanguageController().load();
      expect(c.hasSavedLanguage, isFalse);
      expect(c.current.code, 'en');
    });
  });

  group('Settings → Language', () {
    testWidgets(
        'side menu item closes the drawer, opens the sheet, applies a pick '
        'instantly', (tester) async {
      await pumpApp(
        tester,
        homeDrawer: const Drawer(child: SafeArea(child: LanguageSettingsRow())),
      );
      Get.offAllNamed(home);
      await tester.pumpAndSettle();

      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.translate_rounded), findsOneWidget);
      expect(
          tester
              .widget<Text>(find.byKey(const Key('settings-language-current')))
              .data,
          'English');

      await tester.tap(find.byKey(const Key('settings-language-row')));
      await tester.pumpAndSettle();
      expect(scaffold.isDrawerOpen, isFalse);
      expect(find.byKey(const Key('language-sheet')), findsOneWidget);
      expect(cards(tester).singleWhere((c) => c.selected).option.code, 'en');

      await tester.tap(find.byKey(const ValueKey('language-card-hi')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('language-sheet')), findsNothing);
      expect((await prefs()).getString(LanguageController.prefKey), 'hi');
      expect(Get.locale, const Locale('hi'));
      expect(Localizations.localeOf(tester.element(find.text('HOME'))),
          const Locale('hi'));

      scaffold.openDrawer();
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Text>(find.byKey(const Key('settings-language-current')))
              .data,
          'हिन्दी');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'row shows current language; sheet ticks it and applies a new '
        'pick instantly on the same screen', (tester) async {
      await pumpApp(
        tester,
        prefs: {LanguageController.prefKey: 'en'},
        homeBody: const SafeArea(child: LanguageSettingsRow()),
      );
      Get.offAllNamed(home);
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(
          find.byKey(const Key('settings-language-current')), findsOneWidget);
      expect(
          tester
              .widget<Text>(find.byKey(const Key('settings-language-current')))
              .data,
          'English');

      await tester.tap(find.byKey(const Key('settings-language-row')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('language-sheet')), findsOneWidget);
      expect(find.text('Choose your language'), findsOneWidget);

      expect(find.byKey(const Key('language-sheet-close')), findsOneWidget);
      expect(find.byKey(const Key('language-sheet-search')), findsOneWidget);

      final sheetCards = cards(tester);
      // Lazy list (it scrolls when taller than the screen)
      final list = tester.widget<ListView>(find.descendant(
          of: find.byKey(const Key('language-sheet')),
          matching: find.byType(ListView)));
      expect(list.semanticChildCount, kWorkingLanguages.length);
      expect(sheetCards.where((c) => c.selected).single.option.code, 'en');
      expect(sheetCards.every((c) => c.marker == LanguageCardMarker.radio),
          isTrue);

      await tester.tap(find.byKey(const ValueKey('language-card-hi')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('language-sheet')), findsNothing);
      expect((await prefs()).getString(LanguageController.prefKey), 'hi');
      expect(Get.locale, const Locale('hi'));
      expect(find.text('भाषा'), findsOneWidget);
      expect(
          tester
              .widget<Text>(find.byKey(const Key('settings-language-current')))
              .data,
          'हिन्दी');
      // Same screen stays.
      expect(find.byKey(const Key('settings-language-row')), findsOneWidget);

      // Re-opening ticks the new language and shows its strings.
      await tester.tap(find.byKey(const Key('settings-language-row')));
      await tester.pumpAndSettle();
      expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
      expect(cards(tester).where((c) => c.selected).single.option.code, 'hi');
    });

    testWidgets('sheet scrolls on a short screen without overflow',
        (tester) async {
      await pumpApp(
        tester,
        size: const Size(320, 480),
        prefs: {LanguageController.prefKey: 'en'},
        homeBody: const LanguageSettingsRow(),
      );
      Get.offAllNamed(home);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings-language-row')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.dragUntilVisible(
        find.byKey(const ValueKey('language-card-zh')),
        find.byType(ListView),
        const Offset(0, -100),
        maxIteration: 100,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('language-card-zh')), findsOneWidget);
    });
  });

  group('Config', () {
    test('all languages in the agreed order, unique codes', () {
      expect(kAppLanguageCodes.first, 'en');
      expect(kAppLanguageCodes.toSet(), hasLength(kAppLanguages.length));
    });

    test('every picker string is filled and non-English outside en', () {
      final en = kAppLanguages.first;
      for (final o in kAppLanguages) {
        for (final s in [
          o.title,
          o.subtitle,
          o.searchHint,
          o.continueLabel,
          o.noResults,
          o.languageLabel,
          o.glyph,
          o.nativeName,
        ]) {
          expect(s.trim(), isNotEmpty, reason: o.code);
        }
        if (o.code == 'en') continue;
        expect(o.title, isNot(en.title), reason: o.code);
        expect(o.subtitle, isNot(en.subtitle), reason: o.code);
        expect(o.searchHint, isNot(en.searchHint), reason: o.code);
        expect(o.continueLabel, isNot(en.continueLabel), reason: o.code);
        expect(o.noResults, isNot(en.noResults), reason: o.code);
        expect(o.languageLabel, isNot(en.languageLabel), reason: o.code);
      }
    });
  });
}
