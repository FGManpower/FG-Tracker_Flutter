# FG Tracker Language Module: Flutter (Frontend) Implementation Guide

> **Document version:** `L-1.1.1` (Part 1 and Part 2 done: whole app in 10 languages; one "last seen" format) · **Date:** 2026-11-12 · **Branch:** `multi-language`
> **Backend:** none. No backend changes; the language is stored only on the phone.
> **Scope:** language selection after OTP, side menu → Language, whole-app translation (10 languages), platform strings.
> **Owner:** Flutter team. **Readers:** Flutter developers, QA.

A new user picks the app language on the Language screen, which opens right before Registration. Anyone can change it any time from the side menu. The choice is saved on the phone and applied at once, without a restart. With nothing saved, the app is in **English**; it never follows the phone language. Three rules always hold:
1. **No backend changes.** No new headers, fields or APIs.
2. **API data is shown as it comes.** Names, group names, package names, server messages and server push text are never translated.
3. **Login and OTP are not translated.** They stay in English and their screens are not touched.

This is the only maintained language doc. It includes the audit summary (§4.6), the changed files (§10) and the manual test cases (§6.1).

### How to maintain this document
1. Any change to the language flow, the pref key, the supported languages, the ARB files or the Language UI → update this file in the same PR, bump the version (`L-1.1.1`, …) and add a line to the change log (§9).
2. Adding or removing a language → follow §5.2 and update §3.
3. A new open question → add it to §7 with an owner and status.
4. Names here are copied from the code. Never rename one in only one place.

---

## 0. Architecture overview

### 0.0 Module overview & flow
```
 ┌────────┐   ┌──────────────────┐   ┌────────────────┐
 │ Splash │──▶│ Login (English)  │──▶│ OTP (English)  │
 └────────┘   └──────────────────┘   └───────┬────────┘
                                             │ OTP verified
                          ┌──────────────────┴───────────────────┐
           isNewUser == true                          isNewUser != true (existing user)
                          ▼                                      ▼
 ┌──────────────────────────────────────────┐   original code, unchanged:
 │ LanguageController                        │   Get.offAllNamed(Routes.Home_Screen)
 │   .showBeforeRegistration(openRegistration)│   or Get.offAllNamed(Routes.permissionSetup)
 │ → Get.toNamed('/language-select')         │   NO Language screen
 │   (always, even if a language is saved)   │
 └────────────────────┬─────────────────────┘
                      ▼
 ┌──────────────────────────────────────────┐
 │ Language screen (Routes.languageSelect)   │
 │ saved language or English pre-selected    │
 └────────────────────┬─────────────────────┘
                      │ Continue → setLanguage(code)
                      │          → finishLanguageStep(route)
                      ▼
 Get.toNamed(Routes.Register, arguments: {"mobNo": …})   (original call)
 Language screen removed from the stack → Back on Registration goes to OTP

 Home → ☰ side menu → Language item (LanguageSettingsRow)
      → closes the drawer → showLanguageSheet() → LanguageSheet
      → pick → LanguageController.setLanguage(code)
      → Get.locale = …; Get.appUpdate()  → whole app redraws, same screen stays
```

### 0.0.1 Language operations
| Action | Where | Code (class.method) | Result |
|---|---|---|---|
| Pick before Registration (new user) | OTP → Language screen | `OtpController` → `LanguageController.showBeforeRegistration` → `LanguageScreen._continue` → `LanguageController.setLanguage` → `LanguageController.finishLanguageStep` | Saved to `app_language`, locale applied, the original `Get.toNamed(Routes.Register, …)` runs, Language screen removed from the stack. Shown every time Registration is about to open, always with English pre-selected |
| Existing user logs in | OTP | `OtpController` original code | Home / Permission setup as before. No Language screen. App in the saved language, or English |
| Change from the side menu | ☰ → Language item → sheet | `LanguageSettingsRow._open` (closes the drawer) → `showLanguageSheet` → `LanguageSheet._pick` → `LanguageController.setLanguage` | Saved and applied at once. Same screen stays. No restart, no logout |
| Nothing saved | Any screen | `LanguageController.appLocale` → `current.locale` | English (`Locale('en')`), whatever the phone language |
| Logout | ☰ → Logout | `LogoutUser.clearSessionAndSockets` (`logoutuser.dart`) | `prefs.clear()`, then `app_language` written back. Logging in again keeps the language |
| Background FORCE_LOGOUT | FCM background handler | `main.dart` background handler | Same as logout: `app_language` read before clear and written back |
| Clear user data | Any caller of `StorageServices.clearAllUserData` | `storage_services.dart` | `app_language` kept |
| Reinstall / clear data | OS | — | Pref gone → app in English. A new user sees the Language screen before Registration; an existing user stays English (change from ☰) |
| Phone language changed | OS settings | — | No effect. The saved language (or English) wins |
| App killed on the Language screen | — | `_pendingRegistration` lives in memory only | Nothing saved, registration not finished (`isRegistered` not `"true"`), so the next launch goes back to Login → OTP → Language screen → Registration. See §7, #4 |

### 0.1 State and storage
- **Pref key:** `PrefConst.appLanguage = "app_language"` (`pref_res.dart`). The same string is `LanguageController.prefKey`. Value: a code from §3 (`en`, `hi`, …).
- **`LanguageController`** (`lib/features/language/language_controller.dart`, GetX):
  - put in `main.dart` after `Global.init()`: `await Get.put(LanguageController(), permanent: true).load();`
  - `load()` reads `app_language` into `savedCode` (`RxnString`);
  - exposes `to`, `hasSavedLanguage`, `current` (`LanguageOption`; the saved one, else English = `kAppLanguages.first`), `appLocale` (`current.locale`, **never null**);
  - `setLanguage(code)` → saves the pref → `savedCode.value = code` → `Get.locale = option.locale; Get.appUpdate();` → `firebaseNotificationServices.refreshChannelNames()` (Android channel names in the new language).
  - `load()` also calls `initializeDateFormatting()` so month / day names exist for all 10 languages.
  - **Not `Get.updateLocale`:** that runs a reassemble, clears the image cache and failed in widget tests. `Get.appUpdate()` rebuilds only the root `GetMaterialApp`; the switch is still instant.
  - `showBeforeRegistration(openRegistration)` (stores the original Register call in `_pendingRegistration`, opens the Language screen), `finishLanguageStep(route)`, `routeName = '/language-select'`, `fallbackRoute = '/splash'` (used only if the Language screen is reached with no pending Registration step). `routeAfterOtp` was removed in L-1.0.3.
  - The phone language is not read anywhere (the old `deviceLocale` / `suggested` were removed in L-1.0.2).
- **`GetMaterialApp`** (`main.dart`):
  - `locale: LanguageController.to.appLocale` (saved language or `Locale('en')`; never null, because null makes Flutter follow the phone);
  - `fallbackLocale: const Locale('en')`;
  - `supportedLocales`: the 10 from `kAppLanguages`, plus `Locale('en','US')`, `Locale('hi','IN')`, `Locale('ur','PK')` kept from before (§7, #6). They no longer change anything because `locale` is always set;
  - `localizationsDelegates`: `AppLocalizations.delegate`, `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`.
- **Accessors** (`lib/l10n/l10n.dart`): `context.l10n` reads `AppLocalizations` from the tree (widgets); `appL10n` uses `Get.locale` (controllers, models, toasts); `sharedL10n` is English while Login / OTP is the current route, else `appL10n` (shared dialogs, toasts, http errors); `loadAppL10nFromPrefs()` reads `app_language` from prefs (background isolate: FCM handler, CallKit, walkie notifications). All fall back to English.
- **Places that clear prefs and keep `app_language`:**
  - `StorageServices.clearAllUserData` (`storage_services.dart`);
  - `LogoutUser.clearSessionAndSockets` (`logoutuser.dart`);
  - the FORCE_LOGOUT background handler in `main.dart`.
  No other `prefs.clear()` was found in `lib/`.
- **Text scale pin:** `main.dart` wraps the app in `MediaQuery(... textScaler: const TextScaler.linear(1.0))`. The phone font size has no effect in the app, so the Language screen's 1-column rule (text scale ≥ 1.3) never triggers on a device. It is covered by tests only. Kept by user decision (§7, #5).
- **Side effect of the English default:** `voice_input_controller.dart` and `voice_input/widgets/language_list.dart` read `Get.locale ?? Get.deviceLocale`. With nothing saved, `Get.locale` is now `en`, so voice input also starts in English instead of the phone language.

### 0.2 Key files
| Area | Files |
|---|---|
| Language config (codes, names, picker strings, aliases) | `lib/features/language/language_options.dart` (`LanguageOption`, `kAppLanguages`, `kAppLanguageCodes`, `languageForCode`, `languageFor`) |
| Controller | `lib/features/language/language_controller.dart` (`LanguageController`) |
| Language screen | `lib/features/language/language_screen.dart` (`LanguageScreen`), `lib/features/language/widgets/language_card.dart` (`LanguageCard`) |
| Side menu item + sheet | `lib/features/language/language_settings.dart` (`LanguageSettingsRow`, `showLanguageSheet`, `LanguageSheet`); used in `lib/app/modules/home/Views/sidemenu.dart` |
| Colours | `lib/features/language/language_theme.dart` (`LanguageColors`, `kLanguageAnim`) |
| gen-l10n config | `l10n.yaml`, `pubspec.yaml` (`flutter: generate: true`) |
| ARB files | `lib/l10n/app_en.arb` (template) + `app_hi`, `app_mr`, `app_gu`, `app_kn`, `app_bn`, `app_ml`, `app_ta`, `app_te`, `app_pa` `.arb` |
| Generated | `lib/l10n/app_localizations.dart` + `app_localizations_<code>.dart` (from `flutter gen-l10n` / `flutter pub get`; never edit by hand) |
| Accessors | `lib/l10n/l10n.dart` (`context.l10n`, `appL10n`, `sharedL10n`, `englishL10n`, `loadAppL10nFromPrefs`) |
| App setup | `lib/main.dart` |
| Routes | `lib/app/routes/app_routes.dart` (`Routes.languageSelect`), `lib/app/routes/app_pages.dart` |
| Permission gate | `lib/app/Data/Services/PermissionGate/permission_gate_service.dart` (`Routes.languageSelect` in `exemptRoutes`) |
| OTP hook (frozen, approved) | `lib/app/modules/auth/Controller/OtpController.dart` |
| Logout (frozen, approved) | `lib/app/Core/values/logoutuser.dart` |
| Storage | `lib/app/Core/values/storage_services.dart`, `lib/app/Core/constant/pref_res.dart` |
| iOS strings | `ios/Runner/Info.plist` (`CFBundleLocalizations`), `ios/Runner/<code>.lproj/InfoPlist.strings` × 10, registered in `ios/Runner.xcodeproj/project.pbxproj` |
| Android strings | None needed: `app_name` is the brand; notification channel names are created in Dart and translated (`firebaseNotificationServices.refreshChannelNames()`) |
| String fragments (source of the ARB files) | `tool/l10n/fragments/*.json` (one per area) → `dart run tool/l10n/merge_arb.dart` writes `lib/l10n/app_<code>.arb` and runs gen-l10n |
| Formatting | `lib/l10n/formatters.dart` (`appDateFormat`, `appTime`, `appDayLabel`, `appRelativeTime`, `appNumber`, `appCurrency`) |
| Overflow-safe label | `lib/app/global_widget/auto_fit_text.dart` (`AutoFitText`) |
| String audit tool | `tool/l10n/audit_strings.dart` (writes `build/l10n_audit/`, not committed) |
| Tests | `test/language_selection_test.dart`, `test/registration_l10n_test.dart`, `test/l10n_completeness_test.dart`, `test/auto_fit_text_test.dart`, `test/screenshots/language_screens_screenshot_test.dart` |

### 0.3 Global rules (apply everywhere)
- **No backend changes.** No new headers, fields or APIs.
- **API data shown exactly as it comes:** names, group names, package names, server messages / errors (`result.message`), server push text.
- **Login and OTP** screens are untouched and stay in English. The audit tool excludes `login_Page.dart`, `Otp_Screen.dart`, `OtpController.dart`, `login_controller.dart`.
- **English by default.** No saved language → English. The phone language is never used.
- **No hardcoded user-facing text** outside Login / OTP. Key names are `screen_element` (e.g. `registration_userNameLabel`). Use ICU placeholders and plurals, never string joining (e.g. `validation_required`: `"{field} is required"`).
- **Missing key → English**, never the key name. **Digits stay 0–9** (§4.5).
- **The saved language wins** over the phone language.
- **UI text is never used as a logic value.** Compare stable values (e.g. gender `"male"` / `"female"` / `"others"`), translate only what is shown. The 24 places found by the audit keep an English id for the logic and translate only the label (§4.2).
- **Frozen modules (AGENTS.md) edited with user approval:**
  - `OtpController.dart`: import `language_controller.dart`; **only** the new-user `Get.toNamed(Routes.Register, arguments: {"mobNo": arguments?['mobNo']})` is wrapped in `LanguageController.to.showBeforeRegistration(() => …)`. Same route, same arguments, same method. The existing-user `Get.offAllNamed(Routes.Home_Screen)` / `Get.offAllNamed(Routes.permissionSetup)` is the original code (identical to HEAD). Approved by the user on 2026-11-11 (§7, #3).
  - `logoutuser.dart` (`clearSessionAndSockets`): reads `PrefConst.appLanguage` before `prefs.clear()` and writes it back after.
  - No other frozen file is touched.

---

## 1. Language screen (after OTP)

### 1.1 When it opens
- **Same condition as Registration:** `result.data?.isNewUser == true` in `OtpController`. Inside the existing post-frame callback it calls `LanguageController.to.showBeforeRegistration(() => Get.toNamed(Routes.Register, arguments: {"mobNo": arguments?['mobNo']}))`.
- `showBeforeRegistration` **always** opens the Language screen (`Get.toNamed('/language-select')`), also when a language is already saved on the phone. **English is always pre-selected** (user rule); the user then picks any language. Continue runs the original Register call.
- **Existing users** (`isNewUser != true`) never see it: OTP → Home / Permission setup exactly as in the original code.
- **Other `Routes.Register` calls** (side menu avatar, side menu Edit Profile, Home widget avatar) open Edit Profile (`"type": "Update"`), not Registration, and never show the Language screen. Splash never opens Registration.
- **Route:** `GetPage(name: Routes.languageSelect, page: () => const LanguageScreen(), popGesture: false, transition: Transition.rightToLeft, transitionDuration: 500 ms)`.
- The permission gate never blocks it (`exemptRoutes`).

### 1.2 Layout and design tokens
- `LanguageColors.primary = #5D47F1` (app brand purple), `letterTile = #EDE9FE`. Tints are `#5D47F1` over white: `page #F7F6FE` (5 %), `selectedCard #F2F0FE` (8 %), `pageGlow #E8E5FD` (14 %), `cardBorder #E5E2FD` (16 %). Text `#1C1730` / `#6B6480`. Light theme only.
- Gradient page, `SafeArea`, content max 480 wide and centred.
- Header: 50×50 icon tile, title 25, subtitle 14. Search field 50 high, radius 16, clear button.
- Grid: 2 columns, card height 70 (`mainAxisExtent`), gap 10, side padding 20; 1 column when text scale ≥ 1.3. Card: 42 letter tile, 24 check badge at the top-right corner.
- Bottom bar with a fade above it; Continue button 56 high, radius 18.
- Sizes are plain logical pixels (the Language feature does not use ScreenUtil).

### 1.3 Pre-selection, live preview, search
- **Pre-selection:** always English (`kAppLanguages.first`), even if a language is saved on the phone (user rule, L-1.1.0).
- **Order:** always the fixed order of `kAppLanguages`, English first. The phone language is never moved to the top.
- **Live preview:** tapping a card switches the title, subtitle, search hint, "no results" text and button label to that language (`AnimatedSwitcher`, 180 ms `kLanguageAnim`). The picker strings live in `LanguageOption` (`title`, `subtitle`, `searchHint`, `continueLabel`, `noResults`), not in the ARB files, because they must show before a language is applied.
- **Subtitle** says the language can be changed from the **menu** (e.g. en "You can change it anytime from the menu", mr "तुम्ही ती कधीही मेनूमधून बदलू शकता"); all 10 in `kAppLanguages`.
- **Search** (`LanguageOption.matches`): English name, native name, code, and `aliases` (`hindi`, `gujrati`, `kanada`, `bangla`, `panjabi`). The keyboard closes on scroll.

### 1.4 Continue and Back
- `_continue`: ignored while `_saving`; shows a loader in the button; `await setLanguage(code)`; then `finishLanguageStep(route)`.
- `finishLanguageStep` runs the stored Register call, then removes the Language route, so Back on Registration goes to OTP as before.
- The locale is applied **before** `next()` runs, so the next screen opens in the chosen language with no restart (tested for Registration in `test/registration_l10n_test.dart`).
- **Back is blocked:** `PopScope(canPop: false)` + `popGesture: false`. No back arrow.

### 1.5 States
| State | What shows | Test key |
|---|---|---|
| Default | 10 cards in fixed order, English selected | `language-grid`, `language-card-<code>` |
| Selected | Filled card, border, check badge; texts previewed | `language-title`, `language-subtitle` |
| Search, no match | Centred "No language found" in the previewed language | `language-no-match`, `language-search-clear` |
| Saving | Spinner in the button, taps ignored | `language-continue-loader` |

---

## 2. Side menu → Language
- **Item:** `LanguageSettingsRow` in `sidemenu.dart` (`_buildMenuItems`), right after Edit Profile. The side menu is the app's settings; there is no separate Settings screen, so this one shared widget is both the "menu item" and the "Settings row".
- **Look** (same as the other side menu items): 44×44 `#EDE9FE` tile with `Icons.translate_rounded` in `#5D47F1`; the word "Language" in the current language (`languageLabel`, e.g. भाषा), bold 15; the current `nativeName` on the right in purple (max 120 wide, e.g. मराठी); chevron `#7E69F7`. Keys `settings-language-row`, `settings-language-current`.
- **Tap:** `_open` closes the drawer (`ScaffoldState.closeDrawer`) and opens the sheet from the Scaffold's context. Outside a drawer it just opens the sheet.
- **Sheet:** `showLanguageSheet()` → `LanguageSheet` (`showModalBottomSheet`, `isScrollControlled`, `useSafeArea`): top radius 30, handle, title / subtitle in the current language, 62-high radio cards, max height 88 % of the screen, max width 520. The current language is ticked. Key `language-sheet`.
- **Apply:** a tap saves, closes the sheet, then `setLanguage(code)`. The whole app redraws in place. No restart, no logout; the same screen stays.

---

## 3. Supported languages

| # | Code | English name | Native name | Tile letter | Region / Category |
|---|---|---|---|---|---|
| 1 | `en` | English | English | Aa | International / Global |
| 2 | `hi` | Hindi | हिन्दी | हि | India (National / North / Central) |
| 3 | `mr` | Marathi | मराठी | म | India (Maharashtra) |
| 4 | `gu` | Gujarati | ગુજરાતી | ગુ | India (Gujarat) |
| 5 | `kn` | Kannada | ಕನ್ನಡ | ಕ | India (Karnataka) |
| 6 | `bn` | Bengali | বাংলা | বা | India (West Bengal) |
| 7 | `ml` | Malayalam | മലയാളം | മ | India (Kerala) |
| 8 | `ta` | Tamil | தமிழ் | த | India (Tamil Nadu) |
| 9 | `te` | Telugu | తెలుగు | తె | India (Andhra Pradesh / Telangana) |
| 10 | `pa` | Punjabi | ਪੰਜਾਬੀ | ਪੰ | India (Punjab) |
| 11 | `or` | Odia | ଓଡ଼ିଆ | ଓ | India (Odisha) |
| 12 | `es` | Spanish | Español | Es | Global (Europe / Americas) |
| 13 | `fr` | French | Français | Fr | Global (Europe / Africa) |
| 14 | `de` | German | Deutsch | De | Global (Europe) |
| 15 | `ar` | Arabic | العربية | عر | Global (UAE / Dubai / Middle East) |
| 16 | `pt` | Portuguese | Português | Pt | Global (Brazil / Portugal) |
| 17 | `ja` | Japanese | 日本語 | 日 | Global (East Asia) |
| 18 | `zh` | Chinese | 中文 | 中 | Global (East Asia) |

- Picker strings per language: `kAppLanguages` in `language_options.dart`.
- Material and Cupertino (`flutter_localizations`) support all 10.
- The list follows the product prompt. Tamil, Telugu and Punjabi are assumed; final confirmation is open (§7, #1).

---

## 4. Translation coverage

### 4.1 Coverage table
Keys = ARB keys owned by the area (prefixes in brackets). ✅ = every user-facing text in the area is a key, translated in that language. Total: **2,134 keys × 10 languages** (21,340 strings); `test/l10n_completeness_test.dart` checks all of them.

| Module | Keys | en | hi | mr | gu | kn | bn | ml | ta | te | pa | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Language screen + side menu sheet | picker strings in `language_options.dart` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Registration, Edit Profile, validators, photo picker | 26 (`registration_`, `editProfile_`, `validation_`, `imagePicker_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 1. Permissions (setup, gate) | 70 (`permission_`) + 11 (`perm_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 2. Home, side menu, About, Intro, live status | 61 `home_`, 9 `menu_`, 29 `about_`, 7 `intro_`, 14 `widget_` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3. Chat list, archived, new chat, forward, user profile | 149 (`chatList_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3. Private / group chat, bubbles, long-press menu, Group Info, media | 139 `chat_`, 41 `groupInfo_`, 14 `media_` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3. Status | 45 (`status_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 4–5. Attendance + Poll (create, vote, view, close, chat cards) | 122 (`attendance_`; poll previews in `chat_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 6. Walkie-Talkie (screen, group select, invites, notifications) | 207 (`walkie_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 6. Walkie plans, order summary, payment, purchase success, trial | 395 (`walkiePlan_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 7. Tracking, Safe Zone, Safe Route, Safety dashboard, SOS | 78 `track_`, 33 `safeZone_`, 44 `safeRoute_`, 27 `safety_`, 49 `sos_` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 8. Packages, OTP charges | 5 `package_`, 31 `otpCharges_` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 9. Groups (list, create, join, QR, members, success sheets) | 68 `group_`, 34 `groupDialog_` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 10. Notifications screen, calls (incoming, calling, group, CallKit), force / app update | 11 `notifications_`, 226 `call_`, 7 `forceUpdate_`, 9 `appUpdate_` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 11. Common: dialogs, toasts, sheets, http errors, local notifications, date / time labels | 48 `common_`, 12 `dialog_`, 24 `sheet_`, 3 `http_`, 22 `notif_`, 13 `util_`, 11 `repo_` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Voice input | 40 (`voice_`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

Three keys are the same as English on purpose: `otpCharges_gstTitle`, `walkiePlan_orderGstTitle` ("GST") and `walkiePlan_orderUpiQr` ("UPI / QR") — standard terms kept in English in Indian apps. They are listed with reasons in the completeness test.

### 4.2 Not translated, on purpose
- **Login and OTP:** `login_Page.dart`, `Otp_Screen.dart`, `login_controller.dart`, `OtpController.dart`, `AppText.dart` (used only by Login / OTP now), `Auth_widget.dart` / `privacy_terms_bottom_sheet.dart` texts shown there. Shared dialogs, toasts and http errors use `sharedL10n`, so they are English while Login / OTP is open. The "Session expired …" force-logout messages are shown on Login, so they stay English.
- **Frozen files (AGENTS.md), still English:** `GroupTrackController.dart` (group-map error dialogs and snackbars, map-theme sheet "Light / Dark / Satellite / Terrain / Hybrid", "Map Theme", member list "Members / Unknown / Private / Online / Offline / Location Hidden"), `LiveStatus_controller.dart` ("Failed to load … members"), `logoutuser.dart` (session-expired text). Translating them needs approval to edit those files (§7, #12).
- **API data shown as-is:** names (users, groups, speakers, callers), group codes, plan / package names, descriptions, features and prices, coupon codes, server `message` / error text (`result.message`, ack `message`, `e.toString()` of server errors), server push title / body, message content and captions, poll / attendance titles and options typed by users, addresses from geocoding, zone / route names.
- **What the user types** stays as typed.
- **Logic ids** (the English text stays the internal value; only the label is translated through a display helper): "This message was deleted", "Location unavailable" / "Current Location" / "Locating...", call types and statuses ("Incoming", "Missed", "Calling", "Connected", …), plan titles / durations ("Team Plan (Monthly)", "Monthly"), "Bluetooth" / "Headset", "User" / "Someone" / "Member" fallbacks sent in socket payloads, camera modes (PORTRAIT / PHOTO / VIDEO), mute options, popup-menu values.
- **Sent to servers / gateways:** Razorpay / Cashfree checkout name, description and notes ("FG MANPOWER LLP", "Walkie-Talkie Subscription", "International OTP Verification Fee"), the attendance poll defaults "Present" / "Absent" / "Will you be available today?" and title "Attendance • 12 Nov" (§7, #13).
- **Brands, codes, units:** FG Tracker, WhatsApp, Telegram, Google Play / App Store, PayPal, UPI app names, GST, OTP, GPS, SOS, km / m, support e-mail and phone, company address.
- **Shimmer placeholders** (drawn as grey skeleton blocks, never readable): "Loading member name", "Group Name Placeholder", dummy dates and so on.

### 4.3 Notifications written by the app
- Local notifications (`NotificationServices.dart`, walkie notification services, foreground service) use `appL10n` in the foreground and `await loadAppL10nFromPrefs()` in background isolates.
- Android notification **channel names / descriptions** are translated; after a language change `LanguageController.setLanguage` calls `firebaseNotificationServices.refreshChannelNames()`, which re-creates the existing channels (same ids) with the new names.
- **CallKit** (`callkit_service.dart`): Accept / Decline, "Missed call", the notification-permission texts and the "Unknown" / "Group call" fallbacks come from `loadAppL10nFromPrefs()`, so they follow the app language even when the app is closed.
- **Native walkie notification** (`packages/walkie_custom_notification`): `WalkieCustomNotification.show()` takes optional `textSpeaking`, `textJoined`, `labelLive`, `labelAccept`, `labelCancel`, `defaultGroupName`; the Kotlin side uses them when passed and keeps the old English otherwise. Dart calls it through `showLocalizedWalkieCustomNotification(...)`.
- iOS notification action buttons (Darwin categories) are registered at plugin start, so they change language on the next app start.
- Server push title / body: as sent.

### 4.4 Platform strings
- **iOS:** `ios/Runner/<code>.lproj/InfoPlist.strings` for all 10 languages (11 `NS*UsageDescription` texts + precise-location text), `CFBundleLocalizations` in `Info.plist`, and the `InfoPlist.strings` variant group registered in `project.pbxproj` (`knownRegions` + Resources build phase). Not built on this Windows machine — check the first iOS build (§7, #11).
- **Android:** `app_name` stays "FG Tracker" (brand); no other user-facing strings in `res/values/strings.xml`, so no `values-<code>` folders.
- **OS permission pop-ups and the app name follow the phone language,** not the app language. That is how iOS and Android work; our own explanation texts before the pop-up are translated.

### 4.5 Dates, times, numbers, currency
- `lib/l10n/formatters.dart`: `appDateFormat(pattern)` (month / day names in the app language), `appTime`, `appDayLabel` (Today / Yesterday / date), `appRelativeTime` (Just now / 5 min ago / 2 hours ago / Yesterday / 3 days ago / date), `appNumber` (12,34,567), `appCurrency` (₹1,499).
- **Digits always 0–9** (`useNativeDigits = false`), even for Marathi / Bengali; money uses Indian grouping (`en_IN`). Tested for all 10 languages.
- `LanguageController.load()` calls `initializeDateFormatting()`; if date data is missing, `appDateFormat` falls back to English instead of crashing.
- Formats used for parsing or sent to the API were not changed.

### 4.5.1 "Last seen": one format everywhere (L-1.1.1, 2026-11-12)
**Rule** (same as Walkie-Talkie → Group Info → Group Members), from `lib/app/Core/util/last_seen_formatter.dart`:

| When (phone-local calendar day) | Shown |
|---|---|
| Today | `Last seen: Today, 12:40 AM` |
| Any earlier day this year (yesterday too) | `Last seen: 09 Nov, 11:15 PM` |
| An earlier year | `Last seen: 09 Nov 2025, 11:15 PM` |

- `formatLastSeen(context, serverTime, {now})` in widgets; `formatLastSeenWith(appL10n, serverTime, {now})` where there is no `BuildContext` (controllers). Both return **null** for no time, so each screen keeps its own fallback.
- Server strings are parsed with the existing `Tracking.parseDateTime(raw)` (ISO with / without `Z`, epoch seconds / ms), then shown in **phone-local time**. A time slightly in the future counts as now.
- `Last seen:` and `Today` are ARB keys **`common_lastSeen`** / **`common_todayAt`** (`{time}`, all 10 languages, in `tool/l10n/fragments/common.json`). Month and AM/PM come from intl in the app language; 12-hour clock, 2-digit hour / day, **AM/PM in capitals**, **digits 0–9**.
- **Not changed:** "Online", "Active", "In Walkie Channel", "Speaking…", "Muted", "typing…", and each screen's text when there is no last-seen value (Offline / empty). No model, API, socket, layout or style change: only the expression that builds the text.
- The older module keys (`groupDialog_lastSeen`, `track_lastSeen`, `home_lastSeen`, `walkie_lastSeen`) are still used for the fallbacks (unparseable server text).

**Audit (every place that shows last seen):**

| # | Screen | File | Old | New |
|---|---|---|---|---|
| 1 | Private chat → app bar (under the name) | `Messages/Controller/MessageController.dart` (`peerLastSeen`, set when history loads) | `5 min ago` / `Yesterday` / `3 days ago` (no label) | rule above |
| 2 | Private chat → user profile header | `Messages/Views/UserProfileScreen.dart` (`_buildProfileHeader`) | `5 min ago` (or the server's text) | rule above |
| 3 | Group chat → Group Info → member list | `Messages/Views/Group/ChatGroupProfile_Screen.dart` (`_statusText`) | `5 min ago` (no label) | rule above |
| 4 | Member profile dialog (tap a member from Home, chat, groups, tracking, ghost list) | `Core/values/Dialog/DialogBox.dart` | `Last seen: 5 min ago` | rule above |
| 5 | Group members bottom sheet | `Core/values/BottomSheets/BottomSheetUi.dart` (`getLastSeenText`) | `Last seen: 5 min ago` | rule above |
| 6 | Walkie-Talkie → Group Info → Group Members (reference) | `Walkie-talkie/widgets/group_info_bottom_sheet.dart` | `Last seen 5 min ago`; parsed with `DateTime.tryParse` (UTC without `Z` not converted) | rule above; now parsed with `Tracking.parseDateTime` |
| 7 | Live Tracking → member card | `Track/Views/Tracking_screen.dart` (`getLastSeenText`) | `Last seen: 5 min ago` | rule above |
| 8 | Tracking → Search members | `Track/Views/Search_Members.dart` | `5 min ago` (no label) | rule above |
| 9 | Home → Online members | `home/Views/LiveStatus/components/online_member.dart` | `Last seen 5 min ago` | rule above |
| 10 | Home → Total members | `home/Views/LiveStatus/components/total_member.dart` | `5 min ago` (no label) | rule above |
| 11 | Groups → Member screen (both member lists, right column) | `Group/Views/MemberScreen.dart` | `12:40 AM` (time only, no date, no label) | rule above |
| 12 | Group map → member list subtitle | `Track/Controller/GroupTrackController.dart` (~line 1133, hard-coded English "Online" / time-ago / "Offline") | — | **Not changed: frozen file** (AGENTS.md). Needs approval (§7, #18) |

Checked, **no last-seen text**: chat list rows, group chat app bar, Attendance, Safe Zone / Safe Route, side menu (online dot only), own profile, Notifications, calls.

**Live updates:** every screen above rebuilds its text from the member data it already has, so socket updates that change that data still refresh it exactly as before. The private-chat app bar sets `peerLastSeen` when the history loads (unchanged; there is no socket handler for it today).

### 4.6 Long translations and overflow
- Some translations are 2–3× longer than English (257 short labels, used in 395 places). Every place was checked; about 140 that could overflow (buttons, chips, tabs, badges, labels next to icons, stat cards, call controls, popup items) were fixed, the rest wrap already.
- Fix: **`AutoFitText`** (`lib/app/global_widget/auto_fit_text.dart`) — same font size when the text fits, shrinks only that label when it doesn't (`FittedBox(scaleDown)`); `maxLines: 2` wraps and ends with "…". It is safe in popup menus and dialogs (no `LayoutBuilder`). Inside a `Row` it needs `Flexible` / `Expanded`; badges in rows got a `maxWidth`.
- The shared `reausablebutton` label is now `Flexible(AutoFitText)`, so every caller is covered. No font size, colour, padding or translation was changed.

### 4.7 Audit summary
Run `dart run tool/l10n/audit_strings.dart` (writes `build/l10n_audit/`, not committed). It parses every Dart file reachable from `lib/main.dart` and lists every string by where it is used. Before Part 2: 382 reachable files, about 2,670 user-facing texts, 60 screens, 57 dialogs, 46 bottom sheets, 121 toast sites, 13 local-notification sites, 59 API sinks. After Part 2 every remaining literal was reviewed; what is left is in §4.2 (Login / OTP, frozen files, API data, logic ids, payloads, brands, placeholders).

---

## 5. How-to

### 5.1 Add or change a string
1. Add the key to the fragment of its area in `tool/l10n/fragments/` (e.g. `walkie_core.json`), with all 10 languages:
   `"walkie_holdToTalk": { "en": "Hold to talk", "hi": "…", …, "pa": "…" }`. Placeholders / plurals: `"en": "{count, plural, =1{1 member} other{{count} members}}"` plus `"placeholders": {"count": {"type": "int"}}`.
   (`walkie_plans.json` and `track_misc.json` are generated from scratch sources by their builders; for a quick change editing the fragment is fine.)
2. Run `dart run tool/l10n/merge_arb.dart`. It fails on a duplicate key, a missing or empty language or a missing placeholder, writes the 10 ARB files and runs `flutter gen-l10n`. Never edit `lib/l10n/app_*.arb` or the generated files by hand.
3. Use it: `context.l10n.key` in widgets; `appL10n.key` in controllers / models / toasts; `sharedL10n.key` in widgets that also show on Login / OTP; `await loadAppL10nFromPrefs()` in background isolates.
4. If the text is also compared (`==`, `contains`, `switch`), keep the English id for the logic and translate only the label.
5. Short label in a button / chip / row? Use `AutoFitText` (inside `Flexible` in a `Row`).
6. Run `flutter test test/l10n_completeness_test.dart`.

### 5.2 Add or remove a language
1. `kAppLanguages` in `language_options.dart` (code, names, tile letter, picker strings incl. the "menu" subtitle, aliases).
2. Add the language to every fragment (`codes` in `tool/l10n/merge_arb.dart` and in `test/l10n_completeness_test.dart`), then run the merge.
3. `supportedLocales` follows `kAppLanguages`; check that `flutter_localizations` supports the code.
4. iOS: add the code to `CFBundleLocalizations`, add `<code>.lproj/InfoPlist.strings` and register it in `project.pbxproj` (`knownRegions` + the `InfoPlist.strings` variant group).
5. Tests: the order / count in `test/language_selection_test.dart` (Config group) and the locale loop in `test/registration_l10n_test.dart`.
6. This doc: §3, §4.1, change log.

---

## 6. Testing
- **`test/l10n_completeness_test.dart`** (16 tests): the 10 ARB files exist; every key is in all 10 files and not empty; nothing left in English except the 3 allowed keys; placeholders match English; keys resolve in all 10 locales; dates / times keep digits 0–9 in all 10 languages; money uses Indian grouping.
- **`test/language_selection_test.dart`** (23 tests): Language screen (10 cards in fixed order, **English always pre-selected**, nothing saved → app English even with the phone in Hindi, live preview, search, screen reader label, text scale 1.3 → 1 column, small phone, tablet, Back blocked); Continue (loader, one navigation, Registration with the same arguments, Back → OTP); routing after OTP (new user → Language screen; **new user with a saved language → Language screen with English pre-selected**; existing user → Home with no Language screen); side menu item (closes the drawer, opens the sheet, a pick applies instantly); config.
- **`test/registration_l10n_test.dart`** (3 tests): मराठी → पुढे जा → the real Registration screen in Marathi (labels, hints, gender, Done, validation); typed text unchanged; English unchanged; every locale has its own texts.
- **`test/last_seen_formatter_test.dart`** (12 tests, fixed "now"): today, yesterday shows the date, older date, last year, null, future time = now, UTC → local, UTC → IST (runs when the machine is on IST), Hindi texts / month / no Devanagari digits, all 10 languages.
- **`test/auto_fit_text_test.dart`** (5 tests): fitting text keeps its size; long text shrinks without overflow; `Row` + `Flexible`; safe in a popup menu and an AlertDialog; `maxLines: 2`.
- **`test/screenshots/language_screens_screenshot_test.dart`:** renders the Language screen and the side menu sheet to `build/language_screenshots/*.png` (not committed). Run with `flutter test test/screenshots --update-goldens --dart-define=SCREENSHOTS=true`; skipped otherwise.
- **Full suite:** the tests that already failed before this work (31 at the start of Part 1) are not caused by the language changes; see §7, #14.
- **Device QA:** Android ⏳, iOS ⏳ (iOS cannot be built on the Windows machine used here).

### 6.1 Manual test cases (Android + iOS)

**Reset to a fresh install:** Android: Settings → Apps → FG Tracker → Storage → Clear storage (or `adb uninstall <package>`). iOS: long-press → Remove App. Then install / `flutter run`.
**Phone language:** Android: Settings → System → Languages → add हिन्दी, drag to top. iOS: Settings → General → Language & Region → Add Language → हिन्दी.
**Large font:** the app pins text scale to 1.0, so font size has no effect (§7, #5).
**Accounts:** a new number (opens Registration) and a registered number (opens Home / Permission setup).

| ID | Area | Steps | Expected | Android | iOS |
|---|---|---|---|---|---|
| L-01 | New user | Fresh install → Login → **new** number → OTP | Language screen opens right after OTP (before Registration). Login and OTP in English | | |
| L-02 | English default | Phone in हिन्दी → fresh install → new number → OTP | **English selected**; order English, हिन्दी, मराठी, … | | |
| L-03 | English default | Phone in हिन्दी, existing user who never chose → open app | Whole app in English; ☰ Language item shows English | | |
| L-04 | Layout | Pixel 7 / iPhone 15 | All 10 cards visible, Continue at the bottom, nothing under notch / gesture bar | | |
| L-05 | Live preview | Tap each card | Title, subtitle, search hint, button switch with a short fade; one card selected | | |
| L-06 | Search | `bangla` / `मराठी` / `ta` / `xyz` | বাংলা / मराठी / தமிழ் / "No language found" (× clears) | | |
| L-07 | Continue | Select मराठी → tap पुढे जा twice quickly | Spinner; one navigation | | |
| L-08 | Registration | L-07 with a new number | Registration **in Marathi** with the number filled; `dalai@gma` + पूर्ण → "कृपया वैध ईमेल पत्ता टाका." | | |
| L-09 | Existing user | Registered number → OTP | **No Language screen**; Home or Permission setup as before | | |
| L-10 | New user, saved language | Choose हिन्दी → Logout → **new** number → OTP | Language screen with **English pre-selected** | | |
| L-11 | Back | Back / edge swipe on the Language screen | Nothing happens | | |
| L-12 | Side menu | Home → ☰ → Language | Drawer closes, sheet opens, current language ticked | | |
| L-13 | Apply instantly | In the sheet pick मराठी | Home redraws in Marathi at once; no restart, no logout | | |
| L-14 | Every screen in मराठी | With मराठी, open: Home, ☰, chat list, archived, private chat (long-press menu), group chat + Group Info, Status, Attendance (create / vote / view / close), Poll card, Walkie-Talkie (group select, screen, plans, order summary), Tracking, Safe Zone, Safe Route, Safety, SOS, Packages, OTP charges, Groups (create / join / QR / members / success sheets), Notifications, calls (incoming, calling, group), Permission setup, voice input | All app texts in Marathi; names, messages, prices and server texts as before; no English left except §4.2 | | |
| L-15 | All 10 languages | Repeat L-14 quickly (Home, chat, walkie, tracking) in each language | Same; no boxes / clipped letters | | |
| L-16 | Overflow | In ta, ml, kn, mr: Home stat cards + quick actions, call controls (1:1 and group), walkie header pills + Talk button, plan / order screens, attendance card buttons, chat list quick cards, popup menus | No yellow-black overflow stripes; long labels shrink slightly, other text unchanged | | |
| L-17 | Dates / numbers | Chat times, "Yesterday", "5 min ago", call history, plan "Valid till", prices | Words in the language, **digits 0–9**, ₹ with Indian grouping | | |
| L-18 | Local notifications | Choose தமிழ் → walkie talk / missed call / app-written alerts with the app in background and killed | Texts in Tamil; channel names in Android settings in Tamil | | |
| L-19 | Login / OTP stay English | Choose हिन्दी → Logout → Login, enter a wrong OTP | Login, OTP and their error dialogs in English | | |
| L-20 | Logout / force logout / kill | Choose ગુજરાતી → Logout → log in; log in on another device; swipe the app away → open | Language kept every time | | |
| L-21 | Phone language changed | Choose मराठी → phone to English → open app | App stays मराठी | | |
| L-22 | Reinstall | Uninstall → install → log in | App in English | | |
| L-23 | API data | In हिन्दी open Home, chat list, packages | Names, group names, package names, server messages unchanged | | |
| L-24 | iOS permissions | iOS in हिन्दी, app in मराठी → trigger location / camera permission | The OS pop-up text is in **Hindi** (phone language, by design); our explanation screen is in Marathi | | |
| L-25 | Screen reader | TalkBack / VoiceOver on Language cards and ☰ item | "Hindi, हिन्दी, selected"; "Language, English" | | |

**Last seen (§4.5.1).** Setup: two phones; user B goes offline (close the app or turn off data). For "earlier day / year", use a member who was last online before today / last year, or set phone A's date forward a day. Phone A in IST.

| ID | Screen | Steps | Expected | Android | iOS |
|---|---|---|---|---|---|
| LS-01 | Walkie-Talkie → Group Info → Group Members | B offline since earlier today | `Last seen: Today, 12:40 AM` style (reference format) | | |
| LS-02 | Private chat with B | Open the chat | App bar under the name: `Last seen: Today, hh:mm AM/PM` | | |
| LS-03 | Private chat → B's profile | Tap the name | Header shows the same text | | |
| LS-04 | Group chat → Group Info → members | Open | B's row: same format | | |
| LS-05 | Member profile dialog | Tap B on Home / group / tracking | Same format in the dialog | | |
| LS-06 | Group members bottom sheet | Home → group → members | Same format | | |
| LS-07 | Live Tracking + Search members | Open map, then search B | Member card and search row: same format | | |
| LS-08 | Home → Online / Total members | Open both lists | Same format (Online / Active rows unchanged) | | |
| LS-09 | Groups → Member screen | Open a group's members | Right column shows the full text, no overflow on a 360 px phone | | |
| LS-10 | Earlier day / yesterday | B last online yesterday 11:15 PM | `Last seen: 10 Nov, 11:15 PM` (a date, **not** "Yesterday") | | |
| LS-11 | Earlier year | B last online last year | `Last seen: 09 Nov 2025, 11:15 PM` | | |
| LS-12 | Unchanged states | B online / typing / in walkie channel / speaking | "Online", "typing…", "In Walkie Channel", "Speaking…" exactly as before | | |
| LS-13 | No value | A member with no last-seen data | Same as before on each screen (Offline / empty) | | |
| LS-14 | Live update | Keep a list open while B goes offline | Text changes to `Last seen: Today, …` as before (no reopen needed where it updated before) | | |
| LS-15 | Language | Switch to हिन्दी, then to தமிழ் | `आखिरी बार देखा गया: आज, 12:40 AM`; month names in the language; digits 0–9; AM/PM in capitals | | |

---

## 7. Open items

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Final list of 10 languages (Tamil, Telugu, Punjabi assumed from the prompt) | Product | **Open** |
| 2 | Native-speaker review of every language (2,134 keys; short labels and tone) | Product | **Open** |
| 3 | When the Language screen shows: only for new users, right before Registration, every time, **English pre-selected** (user decisions 2026-11-11) | User | **Closed** |
| 4 | App killed on the Language screen → Login again → OTP → Language screen → Registration | — | **Closed** |
| 5 | `TextScaler.linear(1.0)` pin in `main.dart` (large fonts never apply) | Product / Flutter | **Kept** by user decision |
| 6 | `Locale('ur','PK')`, `Locale('en','US')`, `Locale('hi','IN')` still in `supportedLocales`; no effect now, can be removed | Flutter | **Open** |
| 7 | Shared dialogs / `AppText` with Login / OTP | Flutter | **Closed**: shared widgets use `sharedL10n` (English on Login / OTP) |
| 8 | Groups passing "Group Name" to the validator | Flutter | **Closed** (translated title) |
| 9 | 24 English UI texts used as logic values | Flutter | **Closed**: English ids kept for logic, labels translated (§4.2) |
| 10 | Voice input starts in English when no language is saved (reads `Get.locale ?? Get.deviceLocale`) | Product | **Open** (confirm) |
| 11 | Device QA Android + iOS, incl. the first iOS build with the new `.lproj` files in `project.pbxproj` | QA | **Open** |
| 12 | Frozen `GroupTrackController.dart` / `LiveStatus_controller.dart` texts stay English (§4.2). Translate them? Needs approval to edit frozen files | User | **Open** |
| 13 | Attendance defaults "Present" / "Absent" / "Will you be available today?" and the "Attendance • date" title are sent to the server as poll content and drive the present / absent colours; kept English | Product | **Open** (decide) |
| 14 | Tests that already failed before Part 1 (31 at the start) | Flutter | **Open** (not language-related) |
| 15 | OTP Charges screen (opened from the login flow) follows the app language; should it stay English like Login / OTP? | Product | **Open** (confirm) |
| 16 | Map "YOU" marker and recent-call labels keep the old language until the screen / app reloads after a language change | Flutter | **Open** (minor) |
| 17 | Status list 'User' fallback is translated when loaded, so an open list keeps the old language until it reloads | Flutter | **Open** (minor) |
| 18 | Last seen on the group map member list (`GroupTrackController.dart`, frozen) still shows English time-ago (§4.5.1, #12) | User | **Open** — approve a one-expression change in the frozen file? |
| 19 | Last-seen device QA LS-01…LS-15, incl. the longer text in the Member screen's right column on a small phone | QA | **Open** |

### 7.1 Detailed questions
**#12 Frozen files.** `GroupTrackController.dart` holds the group map's error dialogs, map-theme sheet and member-list labels. Translating them is a text-only change but touches a frozen file. Approve?

**#13 Attendance defaults.** Translating the pre-filled options would change what other members see (the creator's language) and break the present / absent colour match. Options: keep English; or translate only for display (needs colour matching by a stable id from the server).

---

## 8. Temporary diagnostics (remove after device QA)
None.

---

## 9. Change log
| Version | Date | Change |
|---|---|---|
| L-1.1.1 | 2026-11-12 | **One "last seen" format everywhere** (§4.5.1): new `last_seen_formatter.dart` (`formatLastSeen` / `formatLastSeenWith`), keys `common_lastSeen` + `common_todayAt` × 10; 11 places switched (only the text expression), the frozen group-map list left for approval (#18). Tests: `last_seen_formatter_test.dart` (12). Manual cases LS-01…LS-15. |
| L-1.1.0 | 2026-11-11 | **Part 2 done: whole app in 10 languages.** 2,134 keys × 10 (fragments in `tool/l10n/fragments/`, merged by `tool/l10n/merge_arb.dart`). All modules translated (§4.1): Permissions, Home / side menu / About / Intro, chat list / chat / group chat / Group Info / Status, Attendance + Poll, Walkie-Talkie + plans / payment, Tracking / Safe Zone / Safe Route / Safety / SOS, Packages / OTP charges, Groups, Notifications, calls + CallKit, force / app update, common dialogs / toasts / sheets / http errors / local notifications / voice input. New: `sharedL10n` (English on Login / OTP), `loadAppL10nFromPrefs` (background isolates), `formatters.dart` (dates in the language, digits 0–9, ₹ Indian grouping), translated Android channel names + `refreshChannelNames()` on language change, native walkie notification texts from Dart, iOS `InfoPlist.strings` × 10 + `CFBundleLocalizations`. Logic values keep English ids. **Overflow:** `AutoFitText` + about 140 layout fixes for long translations. **Language screen always pre-selects English.** Tests: `l10n_completeness_test.dart`, `auto_fit_text_test.dart`. Branch `multi-language`. |
| L-1.0.3 | 2026-11-11 | Language screen only before Registration (user-approved change to frozen `OtpController.dart`); existing users go OTP → Home / Permissions as in the original code. `routeAfterOtp` replaced by `showBeforeRegistration`. |
| L-1.0.2 | 2026-11-11 | English by default (`appLocale` never null; phone language not read); side menu item restyled and closes the drawer; "menu" subtitle; `docs/language/` folded into this guide. |
| L-1.0.1 | 2026-11-11 | Part 2 started: gen-l10n setup; Registration + Edit Profile, validators, photo picker (26 keys). |
| L-1.0.0 | 2026-11-11 | Part 1: Language screen after OTP, `app_language` kept on logout / clear / FORCE_LOGOUT, side menu Language row + sheet, colours `#5D47F1` / `#EDE9FE`, 21 widget tests. |

---

## 10. Changed files (all parts)

| Area | Files |
|---|---|
| Language feature (new) | `lib/features/language/*` (options, controller, screen, card, side menu item + sheet, colours) |
| l10n setup (new) | `l10n.yaml`, `pubspec.yaml` (`generate: true`, no package changes), `lib/l10n/*.arb` × 10 + generated `app_localizations*.dart`, `lib/l10n/l10n.dart`, `lib/l10n/formatters.dart`, `tool/l10n/fragments/*.json` × 10, `tool/l10n/merge_arb.dart`, `tool/l10n/audit_strings.dart` |
| Frozen, edited with approval | `OtpController.dart` (import + `showBeforeRegistration` around the new-user Register call only), `logoutuser.dart` (keeps `app_language`) |
| App setup / storage / routes | `lib/main.dart`, `pref_res.dart`, `storage_services.dart`, `app_routes.dart`, `app_pages.dart`, `permission_gate_service.dart` |
| Translated screens and logic (text only) | Every module under `lib/app/modules/` except Login / OTP and frozen files: Attendance, call, ForceUpdate, AppUpdate, Group, home, IntroScreen, Messages, mediaStream, Notification, OtpCharges, PackagePricing, PermissionGate, Safe_Zone, sos, status, Track, Walkie-talkie (+ `Walkie-talkie/Utils/walkie_plan_l10n.dart`, new), auth (Registration / Edit Profile / shared widgets); `lib/app/Core/**` (dialogs, sheets, utils, validators, http errors), `lib/app/Data/**` (notification services, CallKit, sockets, repositories), `lib/app/Model/**` (display fallbacks, dates), `lib/app/widgets/**`, `lib/app/global_widget/**` (incl. new `auto_fit_text.dart`), `lib/features/safety/**`, `lib/features/voice_input/**` |
| Native | `packages/walkie_custom_notification` (Dart `show()` args, Kotlin `WalkieNotificationTexts`, layout id for LIVE), `ios/Runner/Info.plist`, `ios/Runner/<code>.lproj/InfoPlist.strings` × 10, `ios/Runner.xcodeproj/project.pbxproj` |
| Tests (new) | `test/language_selection_test.dart`, `test/registration_l10n_test.dart`, `test/l10n_completeness_test.dart`, `test/auto_fit_text_test.dart`, `test/screenshots/language_screens_screenshot_test.dart` |
| Last seen (L-1.1.1) | New `lib/app/Core/util/last_seen_formatter.dart`, `test/last_seen_formatter_test.dart`; `tool/l10n/fragments/common.json` (+2 keys) → ARB × 10 + generated; text expression only in `MessageController.dart`, `UserProfileScreen.dart`, `ChatGroupProfile_Screen.dart`, `DialogBox.dart`, `BottomSheetUi.dart`, `group_info_bottom_sheet.dart`, `Tracking_screen.dart`, `Search_Members.dart`, `online_member.dart`, `total_member.dart`, `MemberScreen.dart` |
| Docs | `docs/06_LANGUAGE_MODULE_FRONTEND.md` (this guide), `docs/README.md` |
