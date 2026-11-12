import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';
export 'formatters.dart';

const Locale _english = Locale('en');

/// SharedPreferences key of the app language. Same value as
/// PrefConst.appLanguage / LanguageController.prefKey.
const String _appLanguagePrefKey = 'app_language';

AppLocalizations _lookup(String? code) {
  if (code != null &&
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code)) {
    return lookupAppLocalizations(Locale(code));
  }
  return lookupAppLocalizations(_english);
}

/// English texts. Used where the app must stay English (Login / OTP).
AppLocalizations get englishL10n => lookupAppLocalizations(_english);

extension AppL10nContext on BuildContext {
  /// Translations for widgets: `context.l10n.registration_doneButton`.
  /// Rebuilds the widget when the app language changes. Falls back to
  /// English if the tree has no supported locale.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ?? englishL10n;
}

/// Translations where there is no BuildContext (controllers, validators,
/// models, toasts). Follows the app language (Get.locale: the saved
/// language, or English) and falls back to English for a missing or
/// unsupported locale.
AppLocalizations get appL10n => _lookup(Get.locale?.languageCode);

/// True while Login or OTP is the current screen. Those screens stay English.
bool get isOnLoginOrOtp {
  final route = Get.currentRoute;
  return route == Routes.Login || route == Routes.OTPScreen;
}

/// For shared widgets that can also appear on Login / OTP (CommonDialog,
/// toasts, loaders): English there, the app language everywhere else.
AppLocalizations get sharedL10n => isOnLoginOrOtp ? englishL10n : appL10n;

/// For code that runs without GetX state (background isolate: FCM
/// background handler, notification actions). Reads the saved language from
/// SharedPreferences; English if nothing is saved.
Future<AppLocalizations> loadAppL10nFromPrefs() async {
  String? code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    code = prefs.getString(_appLanguagePrefKey);
  } catch (_) {}
  try {
    await initializeDateFormatting();
  } catch (_) {}
  return _lookup(code);
}
