import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

/// One "last seen" format for the whole app (same as Walkie-Talkie →
/// Group Info → Group Members):
///
///   today         → "Last seen: Today, 12:40 AM"
///   earlier day   → "Last seen: 09 Nov, 11:15 PM"       (yesterday too)
///   earlier year  → "Last seen: 09 Nov 2025, 11:15 PM"
///
/// - [serverTime] is converted to the phone's local time; "today" is the
///   phone's local calendar day.
/// - A time slightly in the future counts as now.
/// - "Last seen:" and "Today" come from the ARB files (`common_lastSeen`,
///   `common_todayAt`); month and AM/PM follow the app language; digits are
///   always 0–9; AM/PM in capitals.
/// - Returns null when there is no time, so each screen keeps its own
///   fallback ("Offline", empty, …).
///
/// Parse server strings with `Tracking.parseDateTime(raw)` first: it handles
/// ISO with / without "Z" and epoch seconds / milliseconds.
String? formatLastSeen(BuildContext context, DateTime? serverTime,
        {DateTime? now}) =>
    formatLastSeenWith(context.l10n, serverTime, now: now);

/// Same as [formatLastSeen] for code without a BuildContext (controllers,
/// models): pass `appL10n`.
String? formatLastSeenWith(AppLocalizations l10n, DateTime? serverTime,
    {DateTime? now}) {
  if (serverTime == null) return null;
  final current = (now ?? DateTime.now()).toLocal();
  var local = serverTime.toLocal();
  if (local.isAfter(current)) local = current;
  return l10n.common_lastSeen(_dayAndTime(l10n, local, current));
}

/// "Today, 12:40 AM" / "09 Nov, 11:15 PM" / "09 Nov 2025, 11:15 PM".
String _dayAndTime(AppLocalizations l10n, DateTime local, DateTime now) {
  final time = '${appDateFormat('hh:mm', l10n).format(local)} '
      '${appDateFormat('a', l10n).format(local).toUpperCase()}';
  final sameDay = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  if (sameDay) return l10n.common_todayAt(time);
  final pattern = local.year == now.year ? 'dd MMM' : 'dd MMM yyyy';
  return '${appDateFormat(pattern, l10n).format(local)}, $time';
}
