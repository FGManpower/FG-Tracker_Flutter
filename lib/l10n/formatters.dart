import 'package:intl/intl.dart';

import 'l10n.dart';

/// Date, time and number formatting in the app language.
///
/// Rules: month / day names follow the app language; digits are ALWAYS 0–9
/// (never Devanagari / Bengali digits); money uses Indian grouping (₹1,499).

/// Locale name for intl (e.g. "mr"), from the app language.
String get appIntlLocale => appL10n.localeName;

/// `DateFormat(pattern)` in the app language with digits 0–9.
/// Example: `appDateFormat('d MMM yyyy').format(date)` → "12 नोव्हें 2026".
DateFormat appDateFormat(String pattern, [AppLocalizations? l10n]) {
  DateFormat f;
  try {
    f = DateFormat(pattern, (l10n ?? appL10n).localeName);
  } catch (_) {
    // Date data for this locale not initialised yet → English.
    f = DateFormat(pattern, 'en');
  }
  f.useNativeDigits = false;
  return f;
}

/// Time of day, e.g. "3:45 PM" in the app language, digits 0–9.
String appTime(DateTime t, [AppLocalizations? l10n]) =>
    appDateFormat('h:mm a', l10n).format(t);

/// "Today" / "Yesterday" / a date ("12 Nov 2026") for day separators.
String appDayLabel(DateTime t, {DateTime? now, AppLocalizations? l10n}) {
  final l = l10n ?? appL10n;
  final n = now ?? DateTime.now();
  final d = DateTime(t.year, t.month, t.day);
  final today = DateTime(n.year, n.month, n.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return l.common_today;
  if (diff == 1) return l.common_yesterday;
  return appDateFormat('d MMM yyyy', l).format(t);
}

/// "Just now" / "5 min ago" / "2 hours ago" / "Yesterday" / "3 days ago" /
/// a date (older than 7 days).
String appRelativeTime(DateTime t, {DateTime? now, AppLocalizations? l10n}) {
  final l = l10n ?? appL10n;
  final n = now ?? DateTime.now();
  final diff = n.difference(t);
  if (diff.inMinutes < 1) return l.common_justNow;
  if (diff.inMinutes < 60) return l.common_minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l.common_hoursAgo(diff.inHours);
  final days = DateTime(n.year, n.month, n.day)
      .difference(DateTime(t.year, t.month, t.day))
      .inDays;
  if (days <= 1) return l.common_yesterday;
  if (days < 7) return l.common_daysAgo(days);
  return appDateFormat('d MMM yyyy', l).format(t);
}

/// Number with Indian grouping and digits 0–9: 1499 → "1,499".
String appNumber(num value) => NumberFormat.decimalPattern('en_IN').format(value);

/// Money with Indian grouping and digits 0–9: 1499 → "₹1,499".
/// [decimals] defaults to 0 for whole amounts, 2 otherwise.
String appCurrency(num value, {String symbol = '₹', int? decimals}) {
  final digits = decimals ?? (value == value.roundToDouble() ? 0 : 2);
  return NumberFormat.currency(
          locale: 'en_IN', symbol: symbol, decimalDigits: digits)
      .format(value);
}
