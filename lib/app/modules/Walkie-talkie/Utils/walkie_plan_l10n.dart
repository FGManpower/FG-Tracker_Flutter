import 'package:fgtracker/l10n/l10n.dart';

/// Display text for plan duration / plan title values.
///
/// The plan flow keeps English values ("Monthly", "Team Plan (Monthly)",
/// "Individual Plan") as stable ids: they are compared in code and sent in
/// the Razorpay notes. Translate them only where they are shown. Anything
/// that is not one of the app's own values (plan names from the server) is
/// returned unchanged.
String walkieDurationText(String? raw, [AppLocalizations? l10n]) {
  final t = l10n ?? appL10n;
  final value = (raw ?? '').trim();
  switch (value.toLowerCase()) {
    case 'monthly':
      return t.walkiePlan_durationMonthly;
    case 'quarterly':
      return t.walkiePlan_durationQuarterly;
    case 'yearly':
    case 'annual':
      return t.walkiePlan_durationYearly;
    case 'duration':
      return t.walkiePlan_durationFallback;
  }
  final months = RegExp(r'^(\d+)\s+months?$', caseSensitive: false)
      .firstMatch(value);
  if (months != null) {
    return t.walkiePlan_durationMonths(int.parse(months.group(1)!));
  }
  return value;
}

/// See [walkieDurationText]. Only the app's own fallback titles are
/// translated; server plan names are shown as they come.
String walkiePlanTitleText(String? raw, [AppLocalizations? l10n]) {
  final t = l10n ?? appL10n;
  final value = (raw ?? '').trim();
  switch (value) {
    case 'Team Plan':
      return t.walkiePlan_teamPlan;
    case 'Individual Plan':
      return t.walkiePlan_individualPlan;
    case 'Plan':
      return t.walkiePlan_planFallback;
  }
  final team = RegExp(r'^Team Plan \((.+)\)$').firstMatch(value);
  if (team != null) {
    return t.walkiePlan_teamPlanWithDuration(
        walkieDurationText(team.group(1), t));
  }
  return value;
}
