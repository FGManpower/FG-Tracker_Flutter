import 'package:fgtracker/app/modules/auth/Controller/RegisterController.dart';
import 'package:fgtracker/app/modules/auth/Views/registration_screen.dart';
import 'package:fgtracker/features/language/language_controller.dart';
import 'package:fgtracker/features/language/language_options.dart';
import 'package:fgtracker/features/language/language_screen.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Part 2, first case: pick हिन्दी on the Language screen → आगे बढ़ें → the real
/// Registration screen opens in Hindi straight away (labels, gender
/// options, Done, validation). What the user typed stays as typed.
void main() {
  const otp = '/OTPScreen';
  const register = '/register';

  Future<LanguageController> pumpFlow(WidgetTester tester) async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);

    final controller = Get.put(LanguageController(), permanent: true);
    await controller.load();

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        initialRoute: otp,
        locale: controller.appLocale,
        fallbackLocale: const Locale('en'),
        supportedLocales: kAppLanguages.map((o) => o.locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        getPages: [
          GetPage(name: otp, page: () => const Scaffold(body: Text('OTP'))),
          GetPage(
            name: LanguageController.routeName,
            page: () => const LanguageScreen(),
            popGesture: false,
          ),
          GetPage(
            name: register,
            page: () => const RegistrationScreen(),
            binding: BindingsBuilder(
                () => Get.lazyPut(() => RegistrationController())),
          ),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    // Same call OtpController makes for a new user.
    controller.showBeforeRegistration(
      () => Get.toNamed(register, arguments: {'mobNo': '1111111111'}),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('हिन्दी → आगे बढ़ें → Registration is in Hindi', (tester) async {
    final controller = await pumpFlow(tester);

    await tester.tap(find.byKey(const ValueKey('language-card-hi')));
    await tester.pumpAndSettle();
    expect(find.text('आगे बढ़ें'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('language-continue')));
    await tester.pumpAndSettle();

    expect(controller.savedCode.value, 'hi');
    expect(find.byType(RegistrationScreen), findsOneWidget);

    // Labels, hints, gender options, Done.
    for (final text in [
      'उपयोगकर्ता नाम',
      'संपर्क नंबर',
      'ईमेल पता',
      'लिंग चुनें',
      'पुरुष',
      'महिला',
      'अन्य',
      'पूर्ण',
      'उपयोगकर्ता नाम दर्ज करें',
      'ईमेल पता दर्ज करें',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    for (final english in [
      'User Name',
      'Contact Number',
      'Email Address',
      'Select Gender',
      'Male',
      'Female',
      'Other',
      'Done',
    ]) {
      expect(find.text(english), findsNothing, reason: english);
    }

    // The mobile number passed by OTP stays as it is.
    expect(find.text('1111111111'), findsOneWidget);

    // Typed text stays as typed; validation messages are Hindi.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), 'dalai@gma');
    await tester.tap(find.text('पूर्ण'));
    await tester.pumpAndSettle();

    expect(find.text('dalai@gma'), findsOneWidget);
    expect(find.text('कृपया एक मान्य ईमेल पता दर्ज करें।'), findsOneWidget);
    expect(find.text('उपयोगकर्ता नाम आवश्यक है'), findsOneWidget);
    expect(find.text('Please enter a valid email address.'), findsNothing);

    // Empty email → its own Hindi message.
    await tester.enterText(fields.at(2), '');
    await tester.tap(find.text('पूर्ण'));
    await tester.pumpAndSettle();
    expect(find.text('ईमेल पता खाली नहीं हो सकता'), findsOneWidget);
  });

  testWidgets('English stays English (no regression)', (tester) async {
    await pumpFlow(tester);
    await tester.tap(find.byKey(const ValueKey('language-card-en')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-continue')));
    await tester.pumpAndSettle();

    for (final text in [
      'User Name',
      'Contact Number',
      'Email Address',
      'Select Gender',
      'Male',
      'Female',
      'Other',
      'Done',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    await tester.enterText(find.byType(TextFormField).at(2), 'dalai@gma');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('User Name is required'), findsOneWidget);
  });

  test('every ARB locale has the Registration keys (no English leftovers)',
      () {
    final en = lookupAppLocalizations(const Locale('en'));
    for (final o in kAppLanguages.where((o) => o.hasCompiledL10n && o.code != 'en')) {
      final l = lookupAppLocalizations(o.locale);
      expect(l.registration_userNameLabel, isNot(en.registration_userNameLabel),
          reason: o.code);
      expect(l.validation_emailInvalid, isNot(en.validation_emailInvalid),
          reason: o.code);
      expect(l.validation_required('X'), contains('X'), reason: o.code);
    }
  });
}
