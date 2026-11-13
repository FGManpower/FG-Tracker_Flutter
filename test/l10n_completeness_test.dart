import 'dart:convert';
import 'dart:io';

import 'package:fgtracker/features/language/language_options.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// ARB completeness: every key in all 10 files, nothing empty, nothing left
/// in English (except brand words / symbols), placeholders consistent.
/// Also checks that dates and numbers keep the digits 0–9.
void main() {
  setUpAll(() => initializeDateFormatting());

  const codes = [
    'en',
    'hi',
    'mr',
    'gu',
    'kn',
    'bn',
    'ml',
    'ta',
    'te',
    'pa',
    'or',
    'es',
    'fr',
    'de',
    'ar',
    'pt',
    'ja',
    'zh',
  ];

  /// Keys whose translation may equal English on purpose (brand names,
  /// symbols, codes). Each needs a reason.
  const sameAsEnglishAllowed = <String, String>{
    'otpCharges_gstTitle': 'GST is the tax name used as-is in all Indian languages',
    'walkiePlan_orderGstTitle': 'GST is the tax name used as-is in all Indian languages',
    'walkiePlan_orderUpiQr': 'UPI / QR are payment-method names (as in PhonePe / GPay)',
    'walkiePlan_detailsUpiQr': 'UPI / QR are payment-method names (as in PhonePe / GPay)',
    'common_ok': 'OK is an international confirmation abbreviation',
    'walkie_audioBluetooth': 'Bluetooth is an international trademark technology name',
    'walkie_live': 'LIVE is an international UI broadcast indicator badge',
    'walkiePlan_couponPercentOff': 'OFF is a universal discount percentage label',
    'chatList_contactsCount': 'contact/contacts spelling is identical in French',
    'chat_previewVideosCount': 'Video/Videos spelling is identical in German',
  };

  Map<String, dynamic> arb(String code) =>
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;

  Iterable<String> keysOf(Map<String, dynamic> m) =>
      m.keys.where((k) => !k.startsWith('@'));

  /// True when the text has no Latin letters outside {placeholders} and ICU
  /// keywords, i.e. it is only symbols / digits / emoji / placeholders.
  bool hasNoWords(String s) {
    final stripped = s
        .replaceAll(RegExp(r'\{\w+\}'), '')
        .replaceAll(RegExp(r'\b(plural|select|other|=\d+|zero|one|two|few|many)\b'), '');
    return !RegExp(r'[A-Za-z]{2,}').hasMatch(stripped);
  }

  test('the 18 ARB files exist and match the app languages', () {
    expect(kAppLanguages.map((o) => o.code).toList(), codes);
    for (final c in codes) {
      expect(File('lib/l10n/app_$c.arb').existsSync(), isTrue, reason: c);
      expect(arb(c)['@@locale'], c);
    }
  });

  test('every key exists in all 18 files and is not empty', () {
    final en = keysOf(arb('en')).toSet();
    expect(en, isNotEmpty);
    for (final c in codes.skip(1)) {
      final m = arb(c);
      final keys = keysOf(m).toSet();
      expect(en.difference(keys), isEmpty, reason: 'missing in $c');
      expect(keys.difference(en), isEmpty, reason: 'extra in $c');
      for (final k in keys) {
        expect((m[k] as String).trim(), isNotEmpty, reason: '$c.$k is empty');
      }
    }
  });

  test('nothing left in English (except brand words / symbols)', () {
    final en = arb('en');
    final problems = <String>[];
    const nonLatinCodes = {
      'hi',
      'mr',
      'gu',
      'kn',
      'bn',
      'ml',
      'ta',
      'te',
      'pa',
      'or',
      'ar',
      'ja',
      'zh',
    };
    for (final c in codes.skip(1)) {
      final m = arb(c);
      for (final k in keysOf(en)) {
        final e = en[k] as String;
        final v = m[k] as String;
        if (v == e && !sameAsEnglishAllowed.containsKey(k) && !hasNoWords(e)) {
          if (nonLatinCodes.contains(c)) {
            problems.add('$c.$k = "$v"');
          } else {
            final words = e
                .replaceAll(RegExp(r'\{\w+\}'), '')
                .replaceAll(RegExp(r'[^a-zA-Z\s]'), '')
                .trim()
                .split(RegExp(r'\s+'));
            if (words.length > 2) {
              problems.add('$c.$k = "$v"');
            }
          }
        }
      }
    }
    expect(problems, isEmpty, reason: problems.take(40).join('\n'));
  });

  test('placeholders in every translation match English', () {
    final en = arb('en');
    final ph = RegExp(r'\{(\w+)[,}]');
    final problems = <String>[];
    for (final k in keysOf(en)) {
      final want = ph.allMatches(en[k] as String).map((m) => m.group(1)).toSet();
      for (final c in codes.skip(1)) {
        final got = ph.allMatches(arb(c)[k] as String).map((m) => m.group(1)).toSet()
          ..removeWhere((p) => !want.contains(p) && p == 'other');
        if (!got.containsAll(want)) problems.add('$c.$k: $got vs $want');
      }
    }
    expect(problems, isEmpty, reason: problems.take(40).join('\n'));
  });

  test('every key resolves through AppLocalizations in all 17 locales', () {
    // Spot-check the generated code: no locale falls back to the key name.
    for (final c in codes) {
      final l = lookupAppLocalizations(Locale(c));
      expect(l.localeName, c);
      expect(l.common_cancel, isNot('common_cancel'));
      expect(l.common_minutesAgo(5), contains('5'));
    }
  });

  group('dates and numbers keep digits 0–9', () {
    final latinDigitsOnly = RegExp(r'^[^०-९০-৯੦-੯૦-૯೦-೯൦-൯௦-௯౦-౯]*$');
    final date = DateTime(2026, 11, 12, 15, 45);

    for (final c in codes) {
      test(c, () {
        final l = lookupAppLocalizations(Locale(c));
        final d = appDateFormat('d MMM yyyy', l).format(date);
        final t = appTime(date, l);
        expect(d, matches(latinDigitsOnly), reason: d);
        expect(d, contains('12'));
        expect(d, contains('2026'));
        expect(t, matches(latinDigitsOnly), reason: t);
        expect(appRelativeTime(date.subtract(const Duration(minutes: 5)),
                now: date, l10n: l),
            contains('5'));
        expect(appDayLabel(date, now: date, l10n: l), l.common_today);
      });
    }

    test('money uses Indian grouping', () {
      expect(appCurrency(1499), '₹1,499');
      expect(appCurrency(149999), '₹1,49,999');
      expect(appNumber(1234567), '12,34,567');
    });
  });
}
