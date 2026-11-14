import 'package:fgtracker/features/language/fallback_localizations_delegate.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('Number, Date and Plural safety on unsupported & RTL fallback locales', (tester) async {
    await initializeDateFormatting();
    // Test bho (unsupported by GlobalMaterialLocalizations)
    const bhoLocale = Locale('bho');
    const fallbackMat = FallbackMaterialLocalizationsDelegate();
    const fallbackCup = FallbackCupertinoLocalizationsDelegate();
    expect(fallbackCup.isSupported(bhoLocale), isTrue);
    const rtlDelegate = RtlWidgetsLocalizationsDelegate();

    expect(fallbackMat.isSupported(bhoLocale), isTrue);
    final bhoMat = await fallbackMat.load(bhoLocale);
    expect(bhoMat, isNotNull);

    // Test sd (RTL fallback)
    const sdLocale = Locale('sd');
    expect(rtlDelegate.isSupported(sdLocale), isTrue);
    final sdWidgets = await rtlDelegate.load(sdLocale);
    expect(sdWidgets.textDirection, TextDirection.rtl);

    // Test formatters with fallback
    final now = DateTime(2026, 11, 14, 14, 30);
    expect(() => appDateFormat('d MMM yyyy').format(now), returnsNormally);
    expect(() => appTime(now), returnsNormally);
    expect(() => appNumber(1499), returnsNormally);
    expect(() => appCurrency(1499), returnsNormally);

    // Test build widget with both delegates using a compiled RTL locale (ar)
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          RtlWidgetsLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackMaterialLocalizationsDelegate(),
          FallbackCupertinoLocalizationsDelegate(),
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final dir = Directionality.of(context);
            expect(dir, TextDirection.rtl);
            return const Scaffold(body: Text('OK'));
          },
        ),
      ),
    );
    expect(find.text('OK'), findsOneWidget);
  });
}
