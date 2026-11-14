import 'dart:async';

import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_options.dart';

/// Single source of truth for the app language.
///
/// The chosen code is saved ONLY on the phone (SharedPreferences key
/// [prefKey]). It survives logout (logoutuser.dart / storage_services.dart /
/// the FORCE_LOGOUT handler keep it) and is lost on uninstall / clear data.
class LanguageController extends GetxController {
  static LanguageController get to => Get.find<LanguageController>();

  /// Must stay equal to PrefConst.appLanguage.
  static const String prefKey = 'app_language';

  /// Route of the Language screen (registered in app_pages.dart).
  static const String routeName = '/language-select';

  /// Where to go if the Language screen is reached without a pending
  /// Registration step (e.g. after a hot restart). Equals Routes.Splash, which
  /// re-decides the flow from saved state.
  static const String fallbackRoute = '/splash';

  /// The saved code, or null when the user has not chosen a language yet.
  final RxnString savedCode = RxnString();

  VoidCallback? _pendingRegistration;

  bool get hasSavedLanguage => savedCode.value != null;

  /// The language currently applied to the app (English if none saved or hidden).
  LanguageOption get current {
    final opt = languageForCode(savedCode.value);
    if (opt != null && opt.hasCompiledL10n) return opt;
    return kWorkingLanguages.first;
  }

  /// Locale for GetMaterialApp: the saved language, or English. Never null,
  /// because a null locale makes Flutter follow the phone language.
  Locale get appLocale => current.locale;

  /// Reads the saved code. Call once before runApp.
  Future<LanguageController> load() async {
    // Month / day names for every app language (used by appDateFormat).
    try {
      await initializeDateFormatting();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(prefKey);
      final opt = languageForCode(code);
      savedCode.value = (opt != null && opt.hasCompiledL10n) ? opt.code : null;
    } catch (_) {
      savedCode.value = null;
    }
    return this;
  }

  /// Saves [code] on the phone and applies it to the whole app instantly.
  Future<void> setLanguage(String code) async {
    final option = languageForCode(code);
    if (option == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, option.code);
    savedCode.value = option.code;
    // Rebuild only the root GetMaterialApp with the new locale. Unlike
    // Get.updateLocale (a hot-reload style reassemble that also clears the
    // image cache), this keeps every open screen and image as it is; widgets
    // that read Localizations rebuild on their own.
    Get.locale = option.locale;
    if (!Get.testMode) {
      try {
        Get.updateLocale(option.locale);
      } catch (_) {}
    }
    Get.appUpdate();
    // Android shows notification channel names in system settings; re-create
    // the existing channels (same ids) with names in the new language.
    unawaited(firebaseNotificationServices.refreshChannelNames());
  }

  // ------------------------------------------------------- registration

  /// Called by OtpController for a new user (isNewUser == true), exactly
  /// where it used to open Registration directly.
  ///
  /// [openRegistration] is the ORIGINAL call, unchanged:
  /// `Get.toNamed(Routes.Register, arguments: {"mobNo": …})`. The Language
  /// screen is ALWAYS shown first (also when a language is already saved; it
  /// is then pre-selected) and [openRegistration] runs on Continue.
  /// Existing users never come here: they go OTP → Home / Permissions as
  /// before.
  void showBeforeRegistration(VoidCallback openRegistration) {
    _pendingRegistration = openRegistration;
    Get.toNamed(routeName);
  }

  /// Called by the Language screen after the choice is saved. Opens
  /// Registration, then removes the Language screen from the stack so the
  /// result is identical to today's flow (OTP → Registration; Back on
  /// Registration returns to OTP) and Back never returns to it.
  void finishLanguageStep(Route<dynamic>? languageRoute) {
    final next = _pendingRegistration;
    _pendingRegistration = null;
    if (next == null) {
      Get.offAllNamed(fallbackRoute);
      return;
    }
    next();
    if (languageRoute != null && languageRoute.isActive) {
      try {
        languageRoute.navigator?.removeRoute(languageRoute);
      } catch (_) {}
    }
  }

  @visibleForTesting
  bool get hasPendingRegistration => _pendingRegistration != null;
}
