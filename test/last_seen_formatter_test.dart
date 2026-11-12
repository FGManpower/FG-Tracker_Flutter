import 'package:fgtracker/app/Core/util/last_seen_formatter.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  final en = lookupAppLocalizations(const Locale('en'));
  final hi = lookupAppLocalizations(const Locale('hi'));

  // Fixed "now": 11 Nov 2026, 3:00 PM phone-local time.
  final now = DateTime(2026, 11, 11, 15, 0);

  String? f(DateTime? t, [AppLocalizations? l]) =>
      formatLastSeenWith(l ?? en, t, now: now);

  group('English (must match the Walkie-Talkie Group Members format)', () {
    test('today → "Today, hh:mm a"', () {
      expect(f(DateTime(2026, 11, 11, 0, 40)), 'Last seen: Today, 12:40 AM');
      expect(f(DateTime(2026, 11, 11, 14, 5)), 'Last seen: Today, 02:05 PM');
    });

    test('yesterday shows the date, not "Yesterday"', () {
      expect(f(DateTime(2026, 11, 10, 23, 15)), 'Last seen: 10 Nov, 11:15 PM');
    });

    test('older date this year → "dd MMM, hh:mm a"', () {
      expect(f(DateTime(2026, 11, 9, 23, 15)), 'Last seen: 09 Nov, 11:15 PM');
      expect(f(DateTime(2026, 1, 3, 9, 5)), 'Last seen: 03 Jan, 09:05 AM');
    });

    test('last year → "dd MMM yyyy, hh:mm a"', () {
      expect(f(DateTime(2025, 11, 9, 23, 15)),
          'Last seen: 09 Nov 2025, 11:15 PM');
    });

    test('null → null (each screen keeps its own fallback)', () {
      expect(f(null), isNull);
    });

    test('a time slightly in the future counts as now', () {
      expect(f(DateTime(2026, 11, 11, 15, 2)), 'Last seen: Today, 03:00 PM');
    });

    test('UTC server time is shown in phone-local time', () {
      final utc = DateTime.utc(2026, 11, 10, 20, 0);
      final local = utc.toLocal();
      final expected = local.day == now.day && local.month == now.month
          ? 'Last seen: Today, ${DateFormat('hh:mm a', 'en').format(local)}'
          : 'Last seen: ${DateFormat('dd MMM, hh:mm a', 'en').format(local)}';
      expect(f(utc), expected);
    });

    test('UTC → IST: 19:10 UTC on 10 Nov is 12:40 AM on 11 Nov in India',
        () {
      expect(f(DateTime.utc(2026, 11, 10, 19, 10)),
          'Last seen: Today, 12:40 AM');
    },
        skip: DateTime(2026, 11, 11).timeZoneOffset !=
                const Duration(hours: 5, minutes: 30)
            ? 'Runs only when the test machine is set to IST (UTC+05:30)'
            : false);
  });

  group('Hindi', () {
    test('"Last seen" and "Today" from the ARB, digits 0–9, AM/PM capitals',
        () {
      expect(f(DateTime(2026, 11, 11, 0, 40), hi),
          'आखिरी बार देखा गया: आज, 12:40 AM');
    });

    test('month name follows the app language', () {
      final month = DateFormat('MMM', 'hi').format(DateTime(2026, 11, 9));
      expect(f(DateTime(2026, 11, 9, 23, 15), hi),
          'आखिरी बार देखा गया: 09 $month, 11:15 PM');
      expect(f(DateTime(2025, 11, 9, 23, 15), hi),
          'आखिरी बार देखा गया: 09 $month 2025, 11:15 PM');
    });

    test('no Devanagari digits', () {
      final out = f(DateTime(2025, 11, 9, 23, 15), hi)!;
      expect(RegExp('[०-९]').hasMatch(out), isFalse, reason: out);
    });
  });

  test('all 10 languages produce a label with digits 0–9', () {
    for (final code in ['en', 'hi', 'mr', 'gu', 'kn', 'bn', 'ml', 'ta', 'te', 'pa']) {
      final l = lookupAppLocalizations(Locale(code));
      final out = f(DateTime(2025, 11, 9, 23, 15), l)!;
      expect(out, contains('09'), reason: '$code: $out');
      expect(out, contains('2025'), reason: '$code: $out');
      expect(out, contains('11:15'), reason: '$code: $out');
      expect(out.contains('{'), isFalse, reason: '$code: $out');
    }
  });
}
