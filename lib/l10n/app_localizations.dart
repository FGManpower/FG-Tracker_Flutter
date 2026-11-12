import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('pa'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @about_aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get about_aboutUs;

  /// No description provided for @about_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get about_address;

  /// No description provided for @about_appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'About FG Tracker'**
  String get about_appBarTitle;

  /// No description provided for @about_company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get about_company;

  /// No description provided for @about_contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get about_contactUs;

  /// No description provided for @about_developerEmail.
  ///
  /// In en, this message translates to:
  /// **'Developer Email'**
  String get about_developerEmail;

  /// No description provided for @about_downloadTitle.
  ///
  /// In en, this message translates to:
  /// **'📱 Download App'**
  String get about_downloadTitle;

  /// No description provided for @about_howItWorksIntro.
  ///
  /// In en, this message translates to:
  /// **'FG Tracker simplifies group travel coordination. Here\'s how:'**
  String get about_howItWorksIntro;

  /// No description provided for @about_howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'⚙️ How It Works'**
  String get about_howItWorksTitle;

  /// No description provided for @about_howStep1.
  ///
  /// In en, this message translates to:
  /// **'Create a Group'**
  String get about_howStep1;

  /// No description provided for @about_howStep2.
  ///
  /// In en, this message translates to:
  /// **'Share the group code or QR code with your companions'**
  String get about_howStep2;

  /// No description provided for @about_howStep3.
  ///
  /// In en, this message translates to:
  /// **'Each member joins using the shared code or QR'**
  String get about_howStep3;

  /// No description provided for @about_howStep4.
  ///
  /// In en, this message translates to:
  /// **'Track everyone’s live location on a shared map in real-time'**
  String get about_howStep4;

  /// No description provided for @about_howStep5.
  ///
  /// In en, this message translates to:
  /// **'Use the sharing feature to invite more people effortlessly'**
  String get about_howStep5;

  /// No description provided for @about_intro.
  ///
  /// In en, this message translates to:
  /// **'FG Tracker is your go-to companion for staying connected and secure while traveling in a group. Whether you\'re out on a family road trip, a picnic with friends, or just commuting with colleagues — FG Tracker makes sure no one gets left behind.'**
  String get about_intro;

  /// No description provided for @about_privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your safety and privacy matter. FG Tracker does not share your location with anyone outside your group. All data is encrypted and only shared with the people you authorize.'**
  String get about_privacyBody;

  /// No description provided for @about_privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get about_privacyPolicy;

  /// No description provided for @about_privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'🔐 Privacy & Security'**
  String get about_privacyTitle;

  /// No description provided for @about_supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support Email'**
  String get about_supportEmail;

  /// No description provided for @about_supportTitle.
  ///
  /// In en, this message translates to:
  /// **'📩 Support & Developer Info'**
  String get about_supportTitle;

  /// No description provided for @about_termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get about_termsConditions;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about_title;

  /// No description provided for @about_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get about_website;

  /// No description provided for @about_welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FG Tracker'**
  String get about_welcomeTitle;

  /// No description provided for @about_whyBuiltFor.
  ///
  /// In en, this message translates to:
  /// **'Built for families, friends, and small teams.'**
  String get about_whyBuiltFor;

  /// No description provided for @about_whyChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'🌟 Why Choose FG Tracker?'**
  String get about_whyChooseTitle;

  /// No description provided for @about_whyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy to use and lightweight app with privacy control.'**
  String get about_whyEasy;

  /// No description provided for @about_whyNoCalls.
  ///
  /// In en, this message translates to:
  /// **'No need to call or text—track live on the map.'**
  String get about_whyNoCalls;

  /// No description provided for @about_whyRealTime.
  ///
  /// In en, this message translates to:
  /// **'Real-time location sharing with all group members.'**
  String get about_whyRealTime;

  /// No description provided for @appUpdate_checkError.
  ///
  /// In en, this message translates to:
  /// **'Error checking for update: {error}'**
  String appUpdate_checkError(String error);

  /// No description provided for @appUpdate_exitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to Exit?'**
  String get appUpdate_exitConfirmTitle;

  /// No description provided for @appUpdate_noUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Update Available'**
  String get appUpdate_noUpdateAvailable;

  /// No description provided for @appUpdate_restartApp.
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get appUpdate_restartApp;

  /// No description provided for @appUpdate_updateApp.
  ///
  /// In en, this message translates to:
  /// **'Update App'**
  String get appUpdate_updateApp;

  /// No description provided for @appUpdate_updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get appUpdate_updateAvailable;

  /// No description provided for @appUpdate_updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A new update is available. Please update the app'**
  String get appUpdate_updateAvailableMessage;

  /// No description provided for @appUpdate_updateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Update unavailable'**
  String get appUpdate_updateUnavailable;

  /// No description provided for @appUpdate_updatingProgress.
  ///
  /// In en, this message translates to:
  /// **'Updating... {progress}%'**
  String appUpdate_updatingProgress(int progress);

  /// No description provided for @attendance_addOption.
  ///
  /// In en, this message translates to:
  /// **'Add Another Option'**
  String get attendance_addOption;

  /// No description provided for @attendance_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get attendance_admin;

  /// No description provided for @attendance_allowChange.
  ///
  /// In en, this message translates to:
  /// **'Allow changing response'**
  String get attendance_allowChange;

  /// No description provided for @attendance_allowChangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Members can change or remove their response'**
  String get attendance_allowChangeSubtitle;

  /// No description provided for @attendance_askCommunity.
  ///
  /// In en, this message translates to:
  /// **'Ask your community'**
  String get attendance_askCommunity;

  /// No description provided for @attendance_cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to mark attendance.'**
  String get attendance_cameraPermissionRequired;

  /// No description provided for @attendance_cameraStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the camera.'**
  String get attendance_cameraStartFailed;

  /// No description provided for @attendance_cameraStartFailedCode.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the camera ({code}).'**
  String attendance_cameraStartFailedCode(String code);

  /// No description provided for @attendance_cameraStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get attendance_cameraStarting;

  /// No description provided for @attendance_captureFailedBlink.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t capture. Blink again to retry'**
  String get attendance_captureFailedBlink;

  /// No description provided for @attendance_capturedAtVerified.
  ///
  /// In en, this message translates to:
  /// **'Captured at {time} • Verified'**
  String attendance_capturedAtVerified(String time);

  /// No description provided for @attendance_capturedCheck.
  ///
  /// In en, this message translates to:
  /// **'Captured ✓'**
  String get attendance_capturedCheck;

  /// No description provided for @attendance_changeResponse.
  ///
  /// In en, this message translates to:
  /// **'Change response'**
  String get attendance_changeResponse;

  /// No description provided for @attendance_chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder, e.g. Downloads'**
  String get attendance_chooseFolder;

  /// No description provided for @attendance_closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close attendance'**
  String get attendance_closeAction;

  /// No description provided for @attendance_closeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Members won\'t be able to respond after it is closed.'**
  String get attendance_closeConfirmBody;

  /// No description provided for @attendance_closeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Close attendance?'**
  String get attendance_closeConfirmTitle;

  /// No description provided for @attendance_closeEndOfDay.
  ///
  /// In en, this message translates to:
  /// **'Close at end of day'**
  String get attendance_closeEndOfDay;

  /// No description provided for @attendance_closeEndOfDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically closes at {time} today'**
  String attendance_closeEndOfDaySubtitle(String time);

  /// No description provided for @attendance_closeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to close attendance'**
  String get attendance_closeFailed;

  /// No description provided for @attendance_closeFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Unable to close'**
  String get attendance_closeFailedShort;

  /// No description provided for @attendance_closesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes {dateTime}'**
  String attendance_closesAt(String dateTime);

  /// No description provided for @attendance_createFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create attendance'**
  String get attendance_createFailed;

  /// No description provided for @attendance_createSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send an attendance poll to this group'**
  String get attendance_createSubtitle;

  /// No description provided for @attendance_createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Attendance'**
  String get attendance_createTitle;

  /// No description provided for @attendance_created.
  ///
  /// In en, this message translates to:
  /// **'Attendance Created'**
  String get attendance_created;

  /// No description provided for @attendance_dateEnded.
  ///
  /// In en, this message translates to:
  /// **'The selected date has already ended. Pick another date or turn off auto-close.'**
  String get attendance_dateEnded;

  /// No description provided for @attendance_dateToday.
  ///
  /// In en, this message translates to:
  /// **'Date (today)'**
  String get attendance_dateToday;

  /// No description provided for @attendance_dateTodaySemantics.
  ///
  /// In en, this message translates to:
  /// **'Attendance date, today'**
  String get attendance_dateTodaySemantics;

  /// No description provided for @attendance_deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete attendance'**
  String get attendance_deleteFailed;

  /// No description provided for @attendance_deletedText.
  ///
  /// In en, this message translates to:
  /// **'This attendance was deleted'**
  String get attendance_deletedText;

  /// No description provided for @attendance_downloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get attendance_downloadReport;

  /// No description provided for @attendance_everyoneResponded.
  ///
  /// In en, this message translates to:
  /// **'Everyone has responded'**
  String get attendance_everyoneResponded;

  /// No description provided for @attendance_faceDetectedBlink.
  ///
  /// In en, this message translates to:
  /// **'Face detected — now blink your eyes'**
  String get attendance_faceDetectedBlink;

  /// No description provided for @attendance_failed.
  ///
  /// In en, this message translates to:
  /// **'Attendance Failed'**
  String get attendance_failed;

  /// No description provided for @attendance_filterNotRespondedCount.
  ///
  /// In en, this message translates to:
  /// **'Not responded ({count})'**
  String attendance_filterNotRespondedCount(int count);

  /// No description provided for @attendance_filterResponded.
  ///
  /// In en, this message translates to:
  /// **'Responded ({count})'**
  String attendance_filterResponded(int count);

  /// No description provided for @attendance_fixErrors.
  ///
  /// In en, this message translates to:
  /// **'Please fix the highlighted errors before submitting'**
  String get attendance_fixErrors;

  /// No description provided for @attendance_holdStill.
  ///
  /// In en, this message translates to:
  /// **'Hold still…'**
  String get attendance_holdStill;

  /// No description provided for @attendance_howToTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'How to take your photo'**
  String get attendance_howToTakePhoto;

  /// No description provided for @attendance_invalidGroup.
  ///
  /// In en, this message translates to:
  /// **'Invalid group. Please reopen the chat.'**
  String get attendance_invalidGroup;

  /// No description provided for @attendance_keepFaceInCircle.
  ///
  /// In en, this message translates to:
  /// **'Keep your face inside the circle'**
  String get attendance_keepFaceInCircle;

  /// No description provided for @attendance_limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get attendance_limitReached;

  /// No description provided for @attendance_loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load attendance'**
  String get attendance_loadFailed;

  /// No description provided for @attendance_loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get attendance_loadMore;

  /// No description provided for @attendance_loadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load more'**
  String get attendance_loadMoreFailed;

  /// No description provided for @attendance_loadVotersFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load voters'**
  String get attendance_loadVotersFailed;

  /// No description provided for @attendance_lookAtCamera.
  ///
  /// In en, this message translates to:
  /// **'Look at the camera'**
  String get attendance_lookAtCamera;

  /// No description provided for @attendance_lookStraight.
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera'**
  String get attendance_lookStraight;

  /// No description provided for @attendance_markYourAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark your attendance'**
  String get attendance_markYourAttendance;

  /// No description provided for @attendance_markedAs.
  ///
  /// In en, this message translates to:
  /// **'Marked as {option}'**
  String attendance_markedAs(String option);

  /// No description provided for @attendance_markedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Attendance marked successfully'**
  String get attendance_markedSuccess;

  /// No description provided for @attendance_maxOptions.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {count} options only'**
  String attendance_maxOptions(int count);

  /// No description provided for @attendance_members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get attendance_members;

  /// No description provided for @attendance_membersWithCount.
  ///
  /// In en, this message translates to:
  /// **'Members ({count})'**
  String attendance_membersWithCount(int count);

  /// No description provided for @attendance_minOptions.
  ///
  /// In en, this message translates to:
  /// **'At least {count} options are required'**
  String attendance_minOptions(int count);

  /// No description provided for @attendance_moveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move a little closer'**
  String get attendance_moveCloser;

  /// No description provided for @attendance_multipleFaces.
  ///
  /// In en, this message translates to:
  /// **'Multiple faces detected — only you should be in frame'**
  String get attendance_multipleFaces;

  /// No description provided for @attendance_noCsvApp.
  ///
  /// In en, this message translates to:
  /// **'No app found to open CSV files. Use Save or Share instead.'**
  String get attendance_noCsvApp;

  /// No description provided for @attendance_noFace.
  ///
  /// In en, this message translates to:
  /// **'No face detected'**
  String get attendance_noFace;

  /// No description provided for @attendance_noFrontCamera.
  ///
  /// In en, this message translates to:
  /// **'No front camera found on this device.'**
  String get attendance_noFrontCamera;

  /// No description provided for @attendance_noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location available'**
  String get attendance_noLocation;

  /// No description provided for @attendance_noMembersMatch.
  ///
  /// In en, this message translates to:
  /// **'No members match your search'**
  String get attendance_noMembersMatch;

  /// No description provided for @attendance_noResponses.
  ///
  /// In en, this message translates to:
  /// **'No responses yet'**
  String get attendance_noResponses;

  /// No description provided for @attendance_notResponded.
  ///
  /// In en, this message translates to:
  /// **'Not responded'**
  String get attendance_notResponded;

  /// No description provided for @attendance_openEyes.
  ///
  /// In en, this message translates to:
  /// **'Open your eyes and look at the camera'**
  String get attendance_openEyes;

  /// No description provided for @attendance_openMapFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open map'**
  String get attendance_openMapFailed;

  /// No description provided for @attendance_openSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View in Excel, Sheets or another app'**
  String get attendance_openSubtitle;

  /// No description provided for @attendance_optionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter option label'**
  String get attendance_optionHint;

  /// No description provided for @attendance_optionLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'All options must have a label'**
  String get attendance_optionLabelRequired;

  /// No description provided for @attendance_optionNumber.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String attendance_optionNumber(int number);

  /// No description provided for @attendance_optionPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Option {number} • 📷 Photo required'**
  String attendance_optionPhotoRequired(int number);

  /// No description provided for @attendance_optionsUnique.
  ///
  /// In en, this message translates to:
  /// **'Options must be unique'**
  String get attendance_optionsUnique;

  /// No description provided for @attendance_photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo Captured'**
  String get attendance_photoCaptured;

  /// No description provided for @attendance_photoCapturedTapRetake.
  ///
  /// In en, this message translates to:
  /// **'Photo captured ✓ (Tap to retake)'**
  String get attendance_photoCapturedTapRetake;

  /// No description provided for @attendance_photoProof.
  ///
  /// In en, this message translates to:
  /// **'Photo Proof'**
  String get attendance_photoProof;

  /// No description provided for @attendance_photoProofOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Photo Proof'**
  String attendance_photoProofOf(String name);

  /// No description provided for @attendance_photoRequiredFor.
  ///
  /// In en, this message translates to:
  /// **'⚠ Photo required for {option}'**
  String attendance_photoRequiredFor(String option);

  /// No description provided for @attendance_photoRules.
  ///
  /// In en, this message translates to:
  /// **'Only the front camera is used. The photo is taken automatically when you blink, and uploads from the gallery aren\'t allowed.'**
  String get attendance_photoRules;

  /// No description provided for @attendance_photoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a live photo to verify your attendance'**
  String get attendance_photoSubtitle;

  /// No description provided for @attendance_photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Photo'**
  String get attendance_photoTitle;

  /// No description provided for @attendance_photoVerified.
  ///
  /// In en, this message translates to:
  /// **'Photo verified'**
  String get attendance_photoVerified;

  /// No description provided for @attendance_questionHint.
  ///
  /// In en, this message translates to:
  /// **'Will you be available today?'**
  String get attendance_questionHint;

  /// No description provided for @attendance_questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance Question'**
  String get attendance_questionLabel;

  /// No description provided for @attendance_questionRequired.
  ///
  /// In en, this message translates to:
  /// **'Attendance question is required'**
  String get attendance_questionRequired;

  /// No description provided for @attendance_questionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Question must be at least {count} characters long'**
  String attendance_questionTooShort(int count);

  /// No description provided for @attendance_removeFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Unable to remove'**
  String get attendance_removeFailedShort;

  /// No description provided for @attendance_removeResponseBody.
  ///
  /// In en, this message translates to:
  /// **'Your attendance for this poll will be cleared.'**
  String get attendance_removeResponseBody;

  /// No description provided for @attendance_removeResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove your response?'**
  String get attendance_removeResponseTitle;

  /// No description provided for @attendance_removeVoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to remove vote'**
  String get attendance_removeVoteFailed;

  /// No description provided for @attendance_reportEmpty.
  ///
  /// In en, this message translates to:
  /// **'The report is empty'**
  String get attendance_reportEmpty;

  /// No description provided for @attendance_reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Report Failed'**
  String get attendance_reportFailed;

  /// No description provided for @attendance_reportInvalid.
  ///
  /// In en, this message translates to:
  /// **'The server returned an invalid report. Please try again.'**
  String get attendance_reportInvalid;

  /// No description provided for @attendance_reportReady.
  ///
  /// In en, this message translates to:
  /// **'Report ready • {fileName}'**
  String attendance_reportReady(String fileName);

  /// No description provided for @attendance_reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report Saved'**
  String get attendance_reportSaved;

  /// No description provided for @attendance_reportSubject.
  ///
  /// In en, this message translates to:
  /// **'Attendance Report'**
  String get attendance_reportSubject;

  /// No description provided for @attendance_reportSubjectWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Report • {title}'**
  String attendance_reportSubjectWithTitle(String title);

  /// No description provided for @attendance_respondedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} responded'**
  String attendance_respondedCount(int count);

  /// No description provided for @attendance_retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get attendance_retakePhoto;

  /// No description provided for @attendance_saveInFiles.
  ///
  /// In en, this message translates to:
  /// **'Save in the Files app'**
  String get attendance_saveInFiles;

  /// No description provided for @attendance_saveReportDialog.
  ///
  /// In en, this message translates to:
  /// **'Save attendance report'**
  String get attendance_saveReportDialog;

  /// No description provided for @attendance_saveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to device'**
  String get attendance_saveToDevice;

  /// No description provided for @attendance_searchMember.
  ///
  /// In en, this message translates to:
  /// **'Search member'**
  String get attendance_searchMember;

  /// No description provided for @attendance_selectPhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option to require a live photo for it'**
  String get attendance_selectPhotoOption;

  /// No description provided for @attendance_selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Please select your status'**
  String get attendance_selectStatus;

  /// No description provided for @attendance_sentToAllMembers.
  ///
  /// In en, this message translates to:
  /// **'Sent to all members of this group'**
  String get attendance_sentToAllMembers;

  /// No description provided for @attendance_sentToGroup.
  ///
  /// In en, this message translates to:
  /// **'Attendance sent to the group'**
  String get attendance_sentToGroup;

  /// No description provided for @attendance_shareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send via WhatsApp, email…'**
  String get attendance_shareSubtitle;

  /// No description provided for @attendance_statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get attendance_statusCompleted;

  /// Attendance poll state: still accepting responses
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get attendance_statusOpen;

  /// No description provided for @attendance_stepBlink.
  ///
  /// In en, this message translates to:
  /// **'Blink your eyes to capture your photo'**
  String get attendance_stepBlink;

  /// No description provided for @attendance_stepEyeLevel.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone at eye level'**
  String get attendance_stepEyeLevel;

  /// No description provided for @attendance_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Attendance'**
  String get attendance_submit;

  /// No description provided for @attendance_submitted.
  ///
  /// In en, this message translates to:
  /// **'Attendance Submitted'**
  String get attendance_submitted;

  /// No description provided for @attendance_title.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance_title;

  /// No description provided for @attendance_update.
  ///
  /// In en, this message translates to:
  /// **'Update Attendance'**
  String get attendance_update;

  /// No description provided for @attendance_validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get attendance_validationError;

  /// Button: view location / photo
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get attendance_view;

  /// No description provided for @attendance_viewTitle.
  ///
  /// In en, this message translates to:
  /// **'View Attendance'**
  String get attendance_viewTitle;

  /// No description provided for @attendance_voteFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to record vote'**
  String get attendance_voteFailed;

  /// No description provided for @attendance_withinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String attendance_withinKm(String km);

  /// No description provided for @attendance_withinMeters.
  ///
  /// In en, this message translates to:
  /// **'Within {count} m'**
  String attendance_withinMeters(int count);

  /// Button: accept an incoming call
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get call_accept;

  /// No description provided for @call_allContacts.
  ///
  /// In en, this message translates to:
  /// **'All Contacts'**
  String get call_allContacts;

  /// No description provided for @call_allowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get call_allowAccess;

  /// Button: answer an incoming call
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get call_answer;

  /// No description provided for @call_audioOutput.
  ///
  /// In en, this message translates to:
  /// **'Audio Output'**
  String get call_audioOutput;

  /// Shown above the caller's name on an incoming call
  ///
  /// In en, this message translates to:
  /// **'Call From'**
  String get call_callFrom;

  /// No description provided for @call_callIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Call ID not found'**
  String get call_callIdNotFound;

  /// No description provided for @call_callInformation.
  ///
  /// In en, this message translates to:
  /// **'Call Information'**
  String get call_callInformation;

  /// No description provided for @call_callSummary.
  ///
  /// In en, this message translates to:
  /// **'Call Summary'**
  String get call_callSummary;

  /// Badge: the person who started the call
  ///
  /// In en, this message translates to:
  /// **'Caller'**
  String get call_caller;

  /// No description provided for @call_callerAndOthers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{name}} =1{{name} and 1 other} other{{name} and {count} others}}'**
  String call_callerAndOthers(String name, int count);

  /// No description provided for @call_callsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Couldn\'t delete 1 call. Try again.} other{Couldn\'t delete {count} calls. Try again.}}'**
  String call_callsDeleteFailed(int count);

  /// No description provided for @call_callsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 call deleted} other{{count} calls deleted}}'**
  String call_callsDeleted(int count);

  /// No description provided for @call_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get call_camera;

  /// No description provided for @call_cameraMicRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera or Mic permissions are required'**
  String get call_cameraMicRequired;

  /// No description provided for @call_cameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get call_cameraOff;

  /// No description provided for @call_cameraOn.
  ///
  /// In en, this message translates to:
  /// **'Camera on'**
  String get call_cameraOn;

  /// No description provided for @call_cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sorry, camera access is currently unavailable. Please try again later.'**
  String get call_cameraUnavailable;

  /// No description provided for @call_cannotReachCallServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to call server. Please check your network.'**
  String get call_cannotReachCallServer;

  /// Fallback title of a chat with no name
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get call_chatFallback;

  /// No description provided for @call_closeFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Close full screen'**
  String get call_closeFullScreen;

  /// No description provided for @call_communicationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Communication is not available with this user'**
  String get call_communicationUnavailable;

  /// No description provided for @call_connectingProgress.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get call_connectingProgress;

  /// No description provided for @call_connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get call_connectionTimeout;

  /// No description provided for @call_contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get call_contactInformation;

  /// No description provided for @call_contactsAccessBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Find and call your team members easily.'**
  String get call_contactsAccessBannerMessage;

  /// No description provided for @call_contactsAccessBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Let us access your contacts'**
  String get call_contactsAccessBannerTitle;

  /// No description provided for @call_contactsAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'We need access to your contacts to show who is on FG Tracker and to let you call them or send an invite.'**
  String get call_contactsAccessMessage;

  /// No description provided for @call_contactsAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow contacts access'**
  String get call_contactsAccessTitle;

  /// Button: decline a call
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get call_decline;

  /// No description provided for @call_deleteCallsMessage.
  ///
  /// In en, this message translates to:
  /// **'These calls will be removed from your call history.'**
  String get call_deleteCallsMessage;

  /// No description provided for @call_deleteCallsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 call?} other{Delete {count} calls?}}'**
  String call_deleteCallsTitle(int count);

  /// No description provided for @call_deleteHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this call history?'**
  String get call_deleteHistoryMessage;

  /// No description provided for @call_deleteHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Call History'**
  String get call_deleteHistoryTitle;

  /// No description provided for @call_deleteSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete this selected call history?} other{Are you sure you want to delete these {count} selected call history entries?}}'**
  String call_deleteSelectedMessage(int count);

  /// No description provided for @call_deleteSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Calls'**
  String get call_deleteSelectedTitle;

  /// No description provided for @call_deleteWithCount.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String call_deleteWithCount(int count);

  /// No description provided for @call_durHr.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String call_durHr(int hours);

  /// No description provided for @call_durHrMin.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String call_durHrMin(int hours, int minutes);

  /// No description provided for @call_durMin.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String call_durMin(int minutes);

  /// No description provided for @call_durMinSec.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String call_durMinSec(int minutes, int seconds);

  /// No description provided for @call_durSec.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String call_durSec(int seconds);

  /// No description provided for @call_durShortHr.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String call_durShortHr(int hours);

  /// Very short duration, e.g. 1h 5m
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String call_durShortHrMin(int hours, int minutes);

  /// No description provided for @call_durShortMin.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String call_durShortMin(int minutes);

  /// No description provided for @call_durShortMinSec.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String call_durShortMinSec(int minutes, int seconds);

  /// No description provided for @call_durShortSec.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String call_durShortSec(int seconds);

  /// No description provided for @call_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get call_duration;

  /// No description provided for @call_durationValue.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String call_durationValue(String duration);

  /// Audio output
  ///
  /// In en, this message translates to:
  /// **'Earpiece'**
  String get call_earpiece;

  /// No description provided for @call_endCall.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get call_endCall;

  /// Time the call ended
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get call_ended;

  /// No description provided for @call_enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter number'**
  String get call_enterNumber;

  /// No description provided for @call_enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get call_enterPhoneNumber;

  /// No description provided for @call_entryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete call entry'**
  String get call_entryDeleteFailed;

  /// No description provided for @call_entryDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete call entry: {error}'**
  String call_entryDeleteFailedError(String error);

  /// No description provided for @call_entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Call entry deleted'**
  String get call_entryDeleted;

  /// No description provided for @call_everyoneInCall.
  ///
  /// In en, this message translates to:
  /// **'Everyone is already in the call'**
  String get call_everyoneInCall;

  /// No description provided for @call_failedTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Failed'**
  String get call_failedTitle;

  /// Small badge / fallback name for a group
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get call_groupBadge;

  /// No description provided for @call_groupCallComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Group calling is coming soon'**
  String get call_groupCallComingSoon;

  /// No description provided for @call_groupCallInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to initialize group call'**
  String get call_groupCallInitFailed;

  /// No description provided for @call_groupCallStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start group call. Please try again.'**
  String get call_groupCallStartFailed;

  /// No description provided for @call_groupInformation.
  ///
  /// In en, this message translates to:
  /// **'Group Information'**
  String get call_groupInformation;

  /// No description provided for @call_groupWithId.
  ///
  /// In en, this message translates to:
  /// **'Group {id}'**
  String call_groupWithId(String id);

  /// Audio output: wired headphones (no device name)
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get call_headphones;

  /// callType is e.g. "Video Call"
  ///
  /// In en, this message translates to:
  /// **'Cancelled {callType}'**
  String call_historyCancelled(String callType);

  /// No description provided for @call_historyClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear call history'**
  String get call_historyClearFailed;

  /// No description provided for @call_historyClearFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear call history: {error}'**
  String call_historyClearFailedError(String error);

  /// No description provided for @call_historyCleared.
  ///
  /// In en, this message translates to:
  /// **'All call history cleared'**
  String get call_historyCleared;

  /// callType is e.g. "Video Call"
  ///
  /// In en, this message translates to:
  /// **'Incoming {callType}'**
  String call_historyIncoming(String callType);

  /// callType is e.g. "Video Call"
  ///
  /// In en, this message translates to:
  /// **'Missed {callType}'**
  String call_historyMissed(String callType);

  /// callType is e.g. "Video Call"
  ///
  /// In en, this message translates to:
  /// **'Outgoing {callType}'**
  String call_historyOutgoing(String callType);

  /// callType is e.g. "Video Call"
  ///
  /// In en, this message translates to:
  /// **'Rejected {callType}'**
  String call_historyRejected(String callType);

  /// No description provided for @call_inCall.
  ///
  /// In en, this message translates to:
  /// **'In call'**
  String get call_inCall;

  /// No description provided for @call_inCallWithGroup.
  ///
  /// In en, this message translates to:
  /// **'In call · {groupName}'**
  String call_inCallWithGroup(String groupName);

  /// No description provided for @call_inThisCall.
  ///
  /// In en, this message translates to:
  /// **'In this call ({count})'**
  String call_inThisCall(int count);

  /// No description provided for @call_incomingAudio.
  ///
  /// In en, this message translates to:
  /// **'Incoming audio call'**
  String get call_incomingAudio;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Incoming Call'**
  String get call_incomingCallChannelName;

  /// No description provided for @call_incomingGroupAudio.
  ///
  /// In en, this message translates to:
  /// **'Incoming group audio call'**
  String get call_incomingGroupAudio;

  /// No description provided for @call_incomingGroupVideo.
  ///
  /// In en, this message translates to:
  /// **'Incoming group video call'**
  String get call_incomingGroupVideo;

  /// No description provided for @call_incomingVideo.
  ///
  /// In en, this message translates to:
  /// **'Incoming video call'**
  String get call_incomingVideo;

  /// No description provided for @call_infoDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get call_infoDescription;

  /// No description provided for @call_infoEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get call_infoEmail;

  /// No description provided for @call_infoGroupCode.
  ///
  /// In en, this message translates to:
  /// **'Group Code'**
  String get call_infoGroupCode;

  /// No description provided for @call_infoGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get call_infoGroupName;

  /// No description provided for @call_infoMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get call_infoMobile;

  /// No description provided for @call_infoTotalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get call_infoTotalMembers;

  /// Button: invite a contact to the app
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get call_invite;

  /// No description provided for @call_inviteToApp.
  ///
  /// In en, this message translates to:
  /// **'Invite to FG Tracker'**
  String get call_inviteToApp;

  /// Button: join a group call
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get call_join;

  /// No description provided for @call_joinOnAnswer.
  ///
  /// In en, this message translates to:
  /// **'You will join as soon as you answer'**
  String get call_joinOnAnswer;

  /// No description provided for @call_kindAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio Call'**
  String get call_kindAudio;

  /// A call (noun) in call history
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call_kindCall;

  /// No description provided for @call_kindGroupAudio.
  ///
  /// In en, this message translates to:
  /// **'Group Audio Call'**
  String get call_kindGroupAudio;

  /// No description provided for @call_kindGroupCall.
  ///
  /// In en, this message translates to:
  /// **'Group Call'**
  String get call_kindGroupCall;

  /// kind is a call type name from the server
  ///
  /// In en, this message translates to:
  /// **'Group {kind} Call'**
  String call_kindGroupOther(String kind);

  /// No description provided for @call_kindGroupVideo.
  ///
  /// In en, this message translates to:
  /// **'Group Video Call'**
  String get call_kindGroupVideo;

  /// kind is a call type name from the server
  ///
  /// In en, this message translates to:
  /// **'{kind} Call'**
  String call_kindOther(String kind);

  /// No description provided for @call_kindVideo.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get call_kindVideo;

  /// No description provided for @call_loadDetailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load call detail'**
  String get call_loadDetailFailed;

  /// No description provided for @call_loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get call_loadMore;

  /// No description provided for @call_loadRecentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recent calls'**
  String get call_loadRecentFailed;

  /// No description provided for @call_loginToCall.
  ///
  /// In en, this message translates to:
  /// **'Please login to make a call'**
  String get call_loginToCall;

  /// No description provided for @call_membersInCall.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member in this call} other{{count} members in this call}}'**
  String call_membersInCall(int count);

  /// Button: open chat with the contact
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get call_message;

  /// No description provided for @call_micActive.
  ///
  /// In en, this message translates to:
  /// **'Microphone is active'**
  String get call_micActive;

  /// No description provided for @call_missedCall.
  ///
  /// In en, this message translates to:
  /// **'Missed Call'**
  String get call_missedCall;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Missed Call'**
  String get call_missedCallChannelName;

  /// Subtitle of the missed call system notification
  ///
  /// In en, this message translates to:
  /// **'Missed call'**
  String get call_missedCallNotification;

  /// Button: more options
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get call_more;

  /// Button: mute the microphone
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get call_mute;

  /// State: microphone is muted
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get call_muted;

  /// No description provided for @call_nameYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (You)'**
  String call_nameYou(String name);

  /// No description provided for @call_noActiveParticipants.
  ///
  /// In en, this message translates to:
  /// **'No active participants'**
  String get call_noActiveParticipants;

  /// No description provided for @call_noContactsMatch.
  ///
  /// In en, this message translates to:
  /// **'No contacts match your search'**
  String get call_noContactsMatch;

  /// No description provided for @call_noGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get call_noGroupsFound;

  /// No description provided for @call_noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get call_noGroupsYet;

  /// No description provided for @call_noNameGroup.
  ///
  /// In en, this message translates to:
  /// **'Unnamed group'**
  String get call_noNameGroup;

  /// No description provided for @call_noRecentCalls.
  ///
  /// In en, this message translates to:
  /// **'No recent calls'**
  String get call_noRecentCalls;

  /// No description provided for @call_noRecentMatch.
  ///
  /// In en, this message translates to:
  /// **'No recent calls match your search'**
  String get call_noRecentMatch;

  /// No description provided for @call_noRecentYet.
  ///
  /// In en, this message translates to:
  /// **'No recent calls yet'**
  String get call_noRecentYet;

  /// No description provided for @call_noRegisteredContacts.
  ///
  /// In en, this message translates to:
  /// **'No registered contacts found'**
  String get call_noRegisteredContacts;

  /// No description provided for @call_notInContacts.
  ///
  /// In en, this message translates to:
  /// **'This number is not in your contacts'**
  String get call_notInContacts;

  /// No description provided for @call_notInThisCall.
  ///
  /// In en, this message translates to:
  /// **'Not in this call ({count})'**
  String call_notInThisCall(int count);

  /// No description provided for @call_notReady.
  ///
  /// In en, this message translates to:
  /// **'Call not ready'**
  String get call_notReady;

  /// No description provided for @call_notificationPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'Needed to show incoming calls.'**
  String get call_notificationPermissionRationale;

  /// No description provided for @call_notificationPermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in Settings.'**
  String get call_notificationPermissionSettings;

  /// No description provided for @call_notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get call_notificationPermissionTitle;

  /// Button: notify a member to join the call
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get call_notify;

  /// No description provided for @call_notifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Notify failed'**
  String get call_notifyFailed;

  /// No description provided for @call_notifySent.
  ///
  /// In en, this message translates to:
  /// **'Notified successfully'**
  String get call_notifySent;

  /// No description provided for @call_ongoingChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Keeps the call and screen sharing alive'**
  String get call_ongoingChannelDescription;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Ongoing call'**
  String get call_ongoingChannelName;

  /// No description provided for @call_otherAlreadySharing.
  ///
  /// In en, this message translates to:
  /// **'The other person is already sharing the screen'**
  String get call_otherAlreadySharing;

  /// No description provided for @call_otherStartingVideo.
  ///
  /// In en, this message translates to:
  /// **'The other person is starting video'**
  String get call_otherStartingVideo;

  /// No description provided for @call_participant.
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get call_participant;

  /// No description provided for @call_participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get call_participants;

  /// No description provided for @call_personIsSharing.
  ///
  /// In en, this message translates to:
  /// **'{name} is sharing'**
  String call_personIsSharing(String name);

  /// No description provided for @call_personSharingScreen.
  ///
  /// In en, this message translates to:
  /// **'{name} is sharing the screen'**
  String call_personSharingScreen(String name);

  /// Audio output: the phone's earpiece
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get call_phone;

  /// No description provided for @call_pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get call_pleaseWait;

  /// No description provided for @call_recentCalls.
  ///
  /// In en, this message translates to:
  /// **'Recent Calls'**
  String get call_recentCalls;

  /// No description provided for @call_resetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get call_resetZoom;

  /// No description provided for @call_returnToCall.
  ///
  /// In en, this message translates to:
  /// **'Return to Call'**
  String get call_returnToCall;

  /// No description provided for @call_screenBeingShared.
  ///
  /// In en, this message translates to:
  /// **'Screen is being shared'**
  String get call_screenBeingShared;

  /// No description provided for @call_screenShareChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Active screen sharing session notification'**
  String get call_screenShareChannelDescription;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Screen Sharing Service'**
  String get call_screenShareChannelName;

  /// No description provided for @call_screenSharePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Screen sharing permission denied'**
  String get call_screenSharePermissionDenied;

  /// No description provided for @call_screenShareStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start screen sharing'**
  String get call_screenShareStartFailed;

  /// No description provided for @call_screenShareStopped.
  ///
  /// In en, this message translates to:
  /// **'Screen sharing stopped'**
  String get call_screenShareStopped;

  /// No description provided for @call_screenSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen sharing'**
  String get call_screenSharingTitle;

  /// No description provided for @call_screenVisibleToName.
  ///
  /// In en, this message translates to:
  /// **'Your screen is visible to {name}'**
  String call_screenVisibleToName(String name);

  /// No description provided for @call_screenVisibleToOther.
  ///
  /// In en, this message translates to:
  /// **'Your screen is visible to the other person'**
  String get call_screenVisibleToOther;

  /// No description provided for @call_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search contacts or groups'**
  String get call_searchHint;

  /// No description provided for @call_sectionLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get call_sectionLastWeek;

  /// Section of older calls
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get call_sectionOlder;

  /// No description provided for @call_sectionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get call_sectionThisWeek;

  /// No description provided for @call_selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get call_selectAll;

  /// No description provided for @call_selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String call_selectedCount(int count);

  /// No description provided for @call_selectedDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete selected calls'**
  String get call_selectedDeleteFailed;

  /// No description provided for @call_selectedDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete selected calls: {error}'**
  String call_selectedDeleteFailedError(String error);

  /// No description provided for @call_selectedDeleted.
  ///
  /// In en, this message translates to:
  /// **'Selected calls deleted'**
  String get call_selectedDeleted;

  /// No description provided for @call_selfCallWarning.
  ///
  /// In en, this message translates to:
  /// **'You cannot call your own number.'**
  String get call_selfCallWarning;

  /// No description provided for @call_sessionConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to the call session'**
  String get call_sessionConnectFailed;

  /// No description provided for @call_shareScreen.
  ///
  /// In en, this message translates to:
  /// **'Share screen'**
  String get call_shareScreen;

  /// Short button: share the screen
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get call_shareScreenShort;

  /// No description provided for @call_sharingInGroupTapReturn.
  ///
  /// In en, this message translates to:
  /// **'Sharing in {groupName} • Tap to return to call'**
  String call_sharingInGroupTapReturn(String groupName);

  /// No description provided for @call_sharingYourScreen.
  ///
  /// In en, this message translates to:
  /// **'Sharing your screen'**
  String get call_sharingYourScreen;

  /// Fallback name of an unknown caller in a group call
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get call_someone;

  /// Audio output: loudspeaker
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get call_speaker;

  /// Time the call started
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get call_started;

  /// No description provided for @call_startingScreenShare.
  ///
  /// In en, this message translates to:
  /// **'Starting screen share…'**
  String get call_startingScreenShare;

  /// Call status: the other person is busy
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get call_statusBusy;

  /// Call status; the UI adds "..." after it
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get call_statusCalling;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get call_statusCancelled;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get call_statusCompleted;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get call_statusConnected;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get call_statusConnecting;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get call_statusDeclined;

  /// Group call participant status
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get call_statusJoined;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get call_statusMissed;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get call_statusReconnecting;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Ringing'**
  String get call_statusRinging;

  /// Call status
  ///
  /// In en, this message translates to:
  /// **'Video connecting'**
  String get call_statusVideoConnecting;

  /// Button: stop screen sharing
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get call_stop;

  /// No description provided for @call_stopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get call_stopSharing;

  /// No description provided for @call_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Audio / Video Call'**
  String get call_subtitle;

  /// No description provided for @call_swipeUpToAnswer.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to answer'**
  String get call_swipeUpToAnswer;

  /// Button: switch to video call
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get call_switch;

  /// No description provided for @call_switchCameraFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to switch camera'**
  String get call_switchCameraFailed;

  /// No description provided for @call_switchToVideoToShare.
  ///
  /// In en, this message translates to:
  /// **'Switch to video call to share your screen'**
  String get call_switchToVideoToShare;

  /// No description provided for @call_tabContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get call_tabContacts;

  /// No description provided for @call_tabGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get call_tabGroups;

  /// Tab / section of recent calls
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get call_tabRecent;

  /// No description provided for @call_tapNotifyToInvite.
  ///
  /// In en, this message translates to:
  /// **'Tap notify to invite'**
  String get call_tapNotifyToInvite;

  /// "Start Broadcast" is the iOS system button text, keep it in English
  ///
  /// In en, this message translates to:
  /// **'Tap Start Broadcast if the system prompt appears'**
  String get call_tapStartBroadcastHint;

  /// Title of the Call screen (noun)
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call_title;

  /// value is a date or a time
  ///
  /// In en, this message translates to:
  /// **'Today, {value}'**
  String call_todayAt(String value);

  /// No description provided for @call_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get call_total;

  /// No description provided for @call_turnOnVideo.
  ///
  /// In en, this message translates to:
  /// **'Turn on your video'**
  String get call_turnOnVideo;

  /// No description provided for @call_unableToCallContact.
  ///
  /// In en, this message translates to:
  /// **'Unable to call this contact'**
  String get call_unableToCallContact;

  /// No description provided for @call_unableToMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Unable to make call'**
  String get call_unableToMakeCall;

  /// No description provided for @call_unableToOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Unable to open chat for this contact'**
  String get call_unableToOpenChat;

  /// No description provided for @call_unableToShareScreen.
  ///
  /// In en, this message translates to:
  /// **'Unable to share screen'**
  String get call_unableToShareScreen;

  /// No description provided for @call_unavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Call unavailable'**
  String get call_unavailableTitle;

  /// No description provided for @call_unexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from server'**
  String get call_unexpectedResponse;

  /// Fallback name of an unknown caller
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get call_unknown;

  /// No description provided for @call_unknownGroup.
  ///
  /// In en, this message translates to:
  /// **'Unknown Group'**
  String get call_unknownGroup;

  /// No description provided for @call_unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get call_unknownUser;

  /// Button: unmute the microphone
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get call_unmute;

  /// No description provided for @call_unselectAll.
  ///
  /// In en, this message translates to:
  /// **'Unselect all'**
  String get call_unselectAll;

  /// Fallback name when a contact has no name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get call_user;

  /// No description provided for @call_userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get call_userNotFound;

  /// No description provided for @call_userWithId.
  ///
  /// In en, this message translates to:
  /// **'User {id}'**
  String call_userWithId(String id);

  /// Button: switch to video
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get call_video;

  /// "Start Broadcast" is the iOS system button text, keep it in English
  ///
  /// In en, this message translates to:
  /// **'Waiting for Start Broadcast'**
  String get call_waitingForBroadcast;

  /// "Start Broadcast" is the iOS system button text, keep it in English
  ///
  /// In en, this message translates to:
  /// **'Tap “Start Broadcast” in the system dialog to share your screen. Sharing begins only after that.'**
  String get call_waitingForBroadcastMessage;

  /// No description provided for @call_waitingForMedia.
  ///
  /// In en, this message translates to:
  /// **'Waiting for media stream...'**
  String get call_waitingForMedia;

  /// Audio output: wired headset
  ///
  /// In en, this message translates to:
  /// **'Wired'**
  String get call_wired;

  /// No description provided for @call_yesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get call_yesDelete;

  /// value is a date or a time
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {value}'**
  String call_yesterdayAt(String value);

  /// No description provided for @call_youAreSharing.
  ///
  /// In en, this message translates to:
  /// **'You\'re sharing'**
  String get call_youAreSharing;

  /// No description provided for @call_youAreSharingScreen.
  ///
  /// In en, this message translates to:
  /// **'You are sharing your screen'**
  String get call_youAreSharingScreen;

  /// No description provided for @call_zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get call_zoomIn;

  /// No description provided for @call_zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get call_zoomOut;

  /// No description provided for @chatList_allChats.
  ///
  /// In en, this message translates to:
  /// **'All Chats'**
  String get chatList_allChats;

  /// No description provided for @chatList_allContacts.
  ///
  /// In en, this message translates to:
  /// **'All Contacts'**
  String get chatList_allContacts;

  /// No description provided for @chatList_allowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get chatList_allowAccess;

  /// No description provided for @chatList_allowContactsBody.
  ///
  /// In en, this message translates to:
  /// **'We need access to your contacts to show who is on FG Tracker and to let you start a chat or send an invite.'**
  String get chatList_allowContactsBody;

  /// No description provided for @chatList_allowContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow contacts access'**
  String get chatList_allowContactsTitle;

  /// No description provided for @chatList_archiveChat.
  ///
  /// In en, this message translates to:
  /// **'Archive Chat'**
  String get chatList_archiveChat;

  /// No description provided for @chatList_archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get chatList_archived;

  /// No description provided for @chatList_archivedChatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your hidden conversations'**
  String get chatList_archivedChatsSubtitle;

  /// No description provided for @chatList_archivedChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived Chats'**
  String get chatList_archivedChatsTitle;

  /// No description provided for @chatList_archivedCount.
  ///
  /// In en, this message translates to:
  /// **'Archived ({count})'**
  String chatList_archivedCount(int count);

  /// No description provided for @chatList_block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get chatList_block;

  /// No description provided for @chatList_blockFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to block user'**
  String get chatList_blockFailed;

  /// No description provided for @chatList_blockName.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String chatList_blockName(String name);

  /// No description provided for @chatList_blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get chatList_blockUser;

  /// No description provided for @chatList_blockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get chatList_blockUserConfirm;

  /// No description provided for @chatList_blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get chatList_blocked;

  /// No description provided for @chatList_chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared'**
  String get chatList_chatCleared;

  /// No description provided for @chatList_chooseContactToShare.
  ///
  /// In en, this message translates to:
  /// **'Choose a contact to share in your chat.'**
  String get chatList_chooseContactToShare;

  /// Confirm button: clear a chat
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chatList_clear;

  /// No description provided for @chatList_clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get chatList_clearChat;

  /// No description provided for @chatList_clearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all messages with this user?'**
  String get chatList_clearChatConfirm;

  /// No description provided for @chatList_clearChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to clear chat'**
  String get chatList_clearChatFailed;

  /// No description provided for @chatList_clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get chatList_clearSearch;

  /// No description provided for @chatList_contactAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact & Info'**
  String get chatList_contactAndInfo;

  /// No description provided for @chatList_contactPermissionNeededMsg.
  ///
  /// In en, this message translates to:
  /// **'Contact permission is needed to share a contact in chat.'**
  String get chatList_contactPermissionNeededMsg;

  /// No description provided for @chatList_contactsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 contact} other{{count} contacts}}'**
  String chatList_contactsCount(int count);

  /// No description provided for @chatList_contactsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load contacts: {error}'**
  String chatList_contactsLoadFailed(String error);

  /// No description provided for @chatList_contactsPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission needed'**
  String get chatList_contactsPermissionNeeded;

  /// No description provided for @chatList_contactsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your contacts will appear here when available.'**
  String get chatList_contactsWillAppear;

  /// Short elapsed days on a chat row
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String chatList_daysShort(int count);

  /// Chip next to a group deactivated by its admin
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get chatList_deactivated;

  /// No description provided for @chatList_defaultAbout.
  ///
  /// In en, this message translates to:
  /// **'Hey there! I am using FG Tracker'**
  String get chatList_defaultAbout;

  /// No description provided for @chatList_deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get chatList_deleteChat;

  /// No description provided for @chatList_deleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation from your chat list?'**
  String get chatList_deleteChatConfirm;

  /// No description provided for @chatList_forwardFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to forward message.'**
  String get chatList_forwardFailed;

  /// No description provided for @chatList_forwardListLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load forward list.'**
  String get chatList_forwardListLoadFailed;

  /// No description provided for @chatList_forwardTo.
  ///
  /// In en, this message translates to:
  /// **'Forward to...'**
  String get chatList_forwardTo;

  /// No description provided for @chatList_forwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get chatList_forwarded;

  /// No description provided for @chatList_groupChatFallback.
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get chatList_groupChatFallback;

  /// No description provided for @chatList_groupDeactivatedBanner.
  ///
  /// In en, this message translates to:
  /// **'This group has been deactivated by the Admin'**
  String get chatList_groupDeactivatedBanner;

  /// Fallback name of a group chat without a name
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get chatList_groupFallback;

  /// No description provided for @chatList_howToAllow.
  ///
  /// In en, this message translates to:
  /// **'How to allow'**
  String get chatList_howToAllow;

  /// No description provided for @chatList_howToAllowStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Allow Access\" to open Settings'**
  String get chatList_howToAllowStep1;

  /// No description provided for @chatList_howToAllowStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Permissions\"'**
  String get chatList_howToAllowStep2;

  /// No description provided for @chatList_howToAllowStep3.
  ///
  /// In en, this message translates to:
  /// **'Select \"Contacts\"'**
  String get chatList_howToAllowStep3;

  /// No description provided for @chatList_howToAllowStep4.
  ///
  /// In en, this message translates to:
  /// **'Choose \"Allow\", then come back to the app'**
  String get chatList_howToAllowStep4;

  /// Button: invite a contact to the app
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get chatList_invite;

  /// No description provided for @chatList_inviteChooseHow.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to send the invite'**
  String get chatList_inviteChooseHow;

  /// Invite text the user sends to a contact
  ///
  /// In en, this message translates to:
  /// **'Hey {name}! Join me on FG Tracker.\n\nDownload for Android: {playStoreLink}\n\nDownload for iOS: {appStoreLink}'**
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink);

  /// No description provided for @chatList_inviteMoreApps.
  ///
  /// In en, this message translates to:
  /// **'More apps'**
  String get chatList_inviteMoreApps;

  /// No description provided for @chatList_inviteName.
  ///
  /// In en, this message translates to:
  /// **'Invite {name}'**
  String chatList_inviteName(String name);

  /// Invite option: send by SMS app
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatList_inviteViaMessage;

  /// No description provided for @chatList_locationHidden.
  ///
  /// In en, this message translates to:
  /// **'Location Hidden'**
  String get chatList_locationHidden;

  /// No description provided for @chatList_manyTyping.
  ///
  /// In en, this message translates to:
  /// **'{name1}, {name2} +{count} are typing...'**
  String chatList_manyTyping(String name1, String name2, int count);

  /// No description provided for @chatList_markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get chatList_markAsRead;

  /// No description provided for @chatList_markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unread'**
  String get chatList_markAsUnread;

  /// No description provided for @chatList_mediaLinksDocs.
  ///
  /// In en, this message translates to:
  /// **'Media, links and docs'**
  String get chatList_mediaLinksDocs;

  /// Fallback name of a person without a name
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get chatList_memberFallback;

  /// No description provided for @chatList_messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get chatList_messageDeleted;

  /// No description provided for @chatList_messageForwarded.
  ///
  /// In en, this message translates to:
  /// **'Message forwarded'**
  String get chatList_messageForwarded;

  /// No description provided for @chatList_messageIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Message ID is missing.'**
  String get chatList_messageIdMissing;

  /// Short elapsed time on a chat row, e.g. 5 min
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String chatList_minutesShort(int count);

  /// No description provided for @chatList_mute1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get chatList_mute1Hour;

  /// No description provided for @chatList_mute8Hours.
  ///
  /// In en, this message translates to:
  /// **'8 hours'**
  String get chatList_mute8Hours;

  /// No description provided for @chatList_muteAlways.
  ///
  /// In en, this message translates to:
  /// **'Until I turn it back on'**
  String get chatList_muteAlways;

  /// No description provided for @chatList_muteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how long you want to pause notifications.'**
  String get chatList_muteSubtitle;

  /// No description provided for @chatList_muteTitle.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get chatList_muteTitle;

  /// No description provided for @chatList_muteUntilTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Until tomorrow'**
  String get chatList_muteUntilTomorrow;

  /// No description provided for @chatList_newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get chatList_newChat;

  /// No description provided for @chatList_newChatSectionContacts.
  ///
  /// In en, this message translates to:
  /// **'Start a New Chat (Contacts)'**
  String get chatList_newChatSectionContacts;

  /// No description provided for @chatList_newChatSectionInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite to Chat (Unregistered Contacts)'**
  String get chatList_newChatSectionInvite;

  /// No description provided for @chatList_noArchivedChats.
  ///
  /// In en, this message translates to:
  /// **'No Archived Chats'**
  String get chatList_noArchivedChats;

  /// No description provided for @chatList_noArchivedChatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Archived conversations will appear here.'**
  String get chatList_noArchivedChatsSubtitle;

  /// No description provided for @chatList_noChatsFound.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get chatList_noChatsFound;

  /// No description provided for @chatList_noChatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your private chats will appear here.'**
  String get chatList_noChatsSubtitle;

  /// No description provided for @chatList_noContactsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No contacts available'**
  String get chatList_noContactsAvailable;

  /// No description provided for @chatList_noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get chatList_noContactsFound;

  /// No description provided for @chatList_noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No groups available'**
  String get chatList_noGroupsAvailable;

  /// No description provided for @chatList_noGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get chatList_noGroupsFound;

  /// No description provided for @chatList_noMediaYet.
  ///
  /// In en, this message translates to:
  /// **'No media shared yet'**
  String get chatList_noMediaYet;

  /// No description provided for @chatList_noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatList_noMessagesYet;

  /// No description provided for @chatList_noPeopleOrGroups.
  ///
  /// In en, this message translates to:
  /// **'No people or groups found'**
  String get chatList_noPeopleOrGroups;

  /// No description provided for @chatList_noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String chatList_noResultsFor(String query);

  /// No description provided for @chatList_noResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No results for \'{query}\''**
  String chatList_noResultsForQuery(String query);

  /// No description provided for @chatList_noTrackerContacts.
  ///
  /// In en, this message translates to:
  /// **'No active tracker contacts found'**
  String get chatList_noTrackerContacts;

  /// No description provided for @chatList_offlineNotSaved.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. The change wasn\'t saved, please try again.'**
  String get chatList_offlineNotSaved;

  /// No description provided for @chatList_oneTyping.
  ///
  /// In en, this message translates to:
  /// **'{name} is typing...'**
  String chatList_oneTyping(String name);

  /// No description provided for @chatList_openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get chatList_openSettings;

  /// No description provided for @chatList_pinChat.
  ///
  /// In en, this message translates to:
  /// **'Pin Chat'**
  String get chatList_pinChat;

  /// No description provided for @chatList_pinnedChats.
  ///
  /// In en, this message translates to:
  /// **'Pinned Chats'**
  String get chatList_pinnedChats;

  /// No description provided for @chatList_pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get chatList_pleaseTryAgain;

  /// Profile quick action: voice call
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get chatList_profileCall;

  /// Profile quick action: open chat
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatList_profileMessage;

  /// No description provided for @chatList_profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile details not found'**
  String get chatList_profileNotFound;

  /// No description provided for @chatList_profileVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get chatList_profileVideoCall;

  /// No description provided for @chatList_quickCommSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with your team instantly'**
  String get chatList_quickCommSubtitle;

  /// No description provided for @chatList_quickCommTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Communication'**
  String get chatList_quickCommTitle;

  /// No description provided for @chatList_quickGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get chatList_quickGroups;

  /// No description provided for @chatList_quickGroupsSub.
  ///
  /// In en, this message translates to:
  /// **'Team Chats'**
  String get chatList_quickGroupsSub;

  /// No description provided for @chatList_quickSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Safe Zone'**
  String get chatList_quickSafeZone;

  /// No description provided for @chatList_quickSafeZoneSub.
  ///
  /// In en, this message translates to:
  /// **'Safety & Alerts'**
  String get chatList_quickSafeZoneSub;

  /// No description provided for @chatList_quickTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get chatList_quickTracking;

  /// No description provided for @chatList_quickTrackingSub.
  ///
  /// In en, this message translates to:
  /// **'Live Location'**
  String get chatList_quickTrackingSub;

  /// No description provided for @chatList_quickWalkie.
  ///
  /// In en, this message translates to:
  /// **'Walkie'**
  String get chatList_quickWalkie;

  /// No description provided for @chatList_quickWalkieSub.
  ///
  /// In en, this message translates to:
  /// **'Push to Talk'**
  String get chatList_quickWalkieSub;

  /// No description provided for @chatList_searchByNameOrNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by name or number...'**
  String get chatList_searchByNameOrNumber;

  /// No description provided for @chatList_searchGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups...'**
  String get chatList_searchGroupsHint;

  /// No description provided for @chatList_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search chats or messages...'**
  String get chatList_searchHint;

  /// No description provided for @chatList_searchHintShort.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get chatList_searchHintShort;

  /// No description provided for @chatList_searchNameOrNumber.
  ///
  /// In en, this message translates to:
  /// **'Search name or number'**
  String get chatList_searchNameOrNumber;

  /// No description provided for @chatList_searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get chatList_searchResults;

  /// No description provided for @chatList_sectionGroups.
  ///
  /// In en, this message translates to:
  /// **'GROUPS'**
  String get chatList_sectionGroups;

  /// No description provided for @chatList_sectionMyContacts.
  ///
  /// In en, this message translates to:
  /// **'MY CONTACTS'**
  String get chatList_sectionMyContacts;

  /// No description provided for @chatList_sectionOtherContacts.
  ///
  /// In en, this message translates to:
  /// **'OTHER CONTACTS'**
  String get chatList_sectionOtherContacts;

  /// No description provided for @chatList_sectionRecentChats.
  ///
  /// In en, this message translates to:
  /// **'RECENT CHATS'**
  String get chatList_sectionRecentChats;

  /// No description provided for @chatList_selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get chatList_selectDestination;

  /// No description provided for @chatList_selectDestinationMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one person or group.'**
  String get chatList_selectDestinationMsg;

  /// No description provided for @chatList_selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String chatList_selectedCount(int count);

  /// No description provided for @chatList_shareContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Contact'**
  String get chatList_shareContactTitle;

  /// No description provided for @chatList_shareMenuFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open share menu: {error}'**
  String chatList_shareMenuFailed(String error);

  /// No description provided for @chatList_smsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Messaging app could not be opened'**
  String get chatList_smsOpenFailed;

  /// No description provided for @chatList_someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get chatList_someone;

  /// No description provided for @chatList_startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get chatList_startConversation;

  /// No description provided for @chatList_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with your team'**
  String get chatList_subtitle;

  /// No description provided for @chatList_telegramOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Telegram could not be opened'**
  String get chatList_telegramOpenFailed;

  /// Chat list screen title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatList_title;

  /// No description provided for @chatList_tryAnotherNameOrNumber.
  ///
  /// In en, this message translates to:
  /// **'Try another name or phone number.'**
  String get chatList_tryAnotherNameOrNumber;

  /// No description provided for @chatList_tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or message.'**
  String get chatList_tryDifferentSearch;

  /// No description provided for @chatList_twoTyping.
  ///
  /// In en, this message translates to:
  /// **'{name1}, {name2} are typing...'**
  String chatList_twoTyping(String name1, String name2);

  /// No description provided for @chatList_typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get chatList_typing;

  /// No description provided for @chatList_unableToCallContact.
  ///
  /// In en, this message translates to:
  /// **'Unable to call this contact'**
  String get chatList_unableToCallContact;

  /// No description provided for @chatList_unableToLoadContacts.
  ///
  /// In en, this message translates to:
  /// **'Unable to load contacts'**
  String get chatList_unableToLoadContacts;

  /// No description provided for @chatList_unarchiveChat.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Chat'**
  String get chatList_unarchiveChat;

  /// No description provided for @chatList_unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get chatList_unblock;

  /// No description provided for @chatList_unblockFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to unblock user'**
  String get chatList_unblockFailed;

  /// No description provided for @chatList_unblockName.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}'**
  String chatList_unblockName(String name);

  /// No description provided for @chatList_unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get chatList_unblockUser;

  /// No description provided for @chatList_unblockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this user?'**
  String get chatList_unblockUserConfirm;

  /// No description provided for @chatList_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get chatList_unknown;

  /// No description provided for @chatList_unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get chatList_unknownUser;

  /// No description provided for @chatList_unnamedContact.
  ///
  /// In en, this message translates to:
  /// **'Unnamed contact'**
  String get chatList_unnamedContact;

  /// No description provided for @chatList_unpinChat.
  ///
  /// In en, this message translates to:
  /// **'Unpin Chat'**
  String get chatList_unpinChat;

  /// No description provided for @chatList_unreadMessages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String chatList_unreadMessages(int count);

  /// No description provided for @chatList_updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the chat. Please try again.'**
  String get chatList_updateFailed;

  /// Fallback name when a person has no name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get chatList_userFallback;

  /// No description provided for @chatList_userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get chatList_userNotFound;

  /// No description provided for @chatList_viewArchived.
  ///
  /// In en, this message translates to:
  /// **'View archived conversations'**
  String get chatList_viewArchived;

  /// No description provided for @chatList_whatsappOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp could not be opened'**
  String get chatList_whatsappOpenFailed;

  /// No description provided for @chatList_yourContacts.
  ///
  /// In en, this message translates to:
  /// **'Your contacts'**
  String get chatList_yourContacts;

  /// No description provided for @chat_addCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a caption...'**
  String get chat_addCaptionHint;

  /// No description provided for @chat_audioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This audio is no longer available'**
  String get chat_audioUnavailable;

  /// No description provided for @chat_blockFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to block user'**
  String get chat_blockFailed;

  /// Button: phone call a shared contact
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get chat_call;

  /// No description provided for @chat_cameraAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to take photos and videos in chat.'**
  String get chat_cameraAccessNeeded;

  /// Camera mode tab label
  ///
  /// In en, this message translates to:
  /// **'PHOTO'**
  String get chat_cameraModePhoto;

  /// Camera mode tab label
  ///
  /// In en, this message translates to:
  /// **'PORTRAIT'**
  String get chat_cameraModePortrait;

  /// Camera mode tab label
  ///
  /// In en, this message translates to:
  /// **'VIDEO'**
  String get chat_cameraModeVideo;

  /// No description provided for @chat_cameraStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the camera.'**
  String get chat_cameraStartFailed;

  /// No description provided for @chat_cantMessageUser.
  ///
  /// In en, this message translates to:
  /// **'You can\'t message this user'**
  String get chat_cantMessageUser;

  /// No description provided for @chat_chatActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your chat'**
  String get chat_chatActionsSubtitle;

  /// No description provided for @chat_chatActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Actions'**
  String get chat_chatActionsTitle;

  /// Button: clear (delete) chat messages
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chat_clear;

  /// No description provided for @chat_clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get chat_clearChat;

  /// No description provided for @chat_clearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all messages from this chat?'**
  String get chat_clearChatConfirm;

  /// No description provided for @chat_clearGroupChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear group chat'**
  String get chat_clearGroupChatFailed;

  /// No description provided for @chat_contactBlockedYou.
  ///
  /// In en, this message translates to:
  /// **'This contact has blocked you'**
  String get chat_contactBlockedYou;

  /// No description provided for @chat_contactUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Contact unavailable'**
  String get chat_contactUnavailable;

  /// No description provided for @chat_deleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for Everyone'**
  String get chat_deleteForEveryone;

  /// No description provided for @chat_deleteForEveryoneConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message for everyone?'**
  String get chat_deleteForEveryoneConfirm;

  /// No description provided for @chat_deleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for Me'**
  String get chat_deleteForMe;

  /// No description provided for @chat_deleteForMeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message for you?'**
  String get chat_deleteForMeConfirm;

  /// No description provided for @chat_deleteMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get chat_deleteMember;

  /// No description provided for @chat_deleteMemberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove a member from this group'**
  String get chat_deleteMemberSubtitle;

  /// No description provided for @chat_documentAvailable.
  ///
  /// In en, this message translates to:
  /// **'Document is available'**
  String get chat_documentAvailable;

  /// No description provided for @chat_documentDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The document couldn\'t be downloaded.'**
  String get chat_documentDownloadFailed;

  /// No description provided for @chat_documentOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the document. Please try again.'**
  String get chat_documentOpenFailed;

  /// No description provided for @chat_documentPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview is not available for this file type. Open the document using your installed application.'**
  String get chat_documentPreviewUnavailable;

  /// No description provided for @chat_documentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This document is no longer available'**
  String get chat_documentUnavailable;

  /// No description provided for @chat_downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get chat_downloadFailed;

  /// Small label next to the time of an edited message
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chat_edited;

  /// No description provided for @chat_emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Say hi 👋 to start the conversation'**
  String get chat_emptySubtitle;

  /// No description provided for @chat_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages here yet'**
  String get chat_emptyTitle;

  /// No description provided for @chat_fetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching location...'**
  String get chat_fetchingLocation;

  /// No description provided for @chat_finishVoiceRecordingFirst.
  ///
  /// In en, this message translates to:
  /// **'Finish or cancel the voice recording first'**
  String get chat_finishVoiceRecordingFirst;

  /// No description provided for @chat_forwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get chat_forwarded;

  /// No description provided for @chat_galleryCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String chat_galleryCounter(int current, int total);

  /// No description provided for @chat_groupActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your group settings'**
  String get chat_groupActionsSubtitle;

  /// No description provided for @chat_groupActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Actions'**
  String get chat_groupActionsTitle;

  /// No description provided for @chat_groupChatCleared.
  ///
  /// In en, this message translates to:
  /// **'Group chat cleared successfully'**
  String get chat_groupChatCleared;

  /// No description provided for @chat_groupDeactivated.
  ///
  /// In en, this message translates to:
  /// **'This group has been deactivated by the Admin'**
  String get chat_groupDeactivated;

  /// No description provided for @chat_imageFailed.
  ///
  /// In en, this message translates to:
  /// **'Image failed'**
  String get chat_imageFailed;

  /// No description provided for @chat_listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get chat_listen;

  /// No description provided for @chat_listenEnglish.
  ///
  /// In en, this message translates to:
  /// **'Listen (English)'**
  String get chat_listenEnglish;

  /// No description provided for @chat_listenHindi.
  ///
  /// In en, this message translates to:
  /// **'Listen (Hindi)'**
  String get chat_listenHindi;

  /// No description provided for @chat_loadFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get chat_loadFailedSubtitle;

  /// No description provided for @chat_loadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load messages'**
  String get chat_loadFailedTitle;

  /// No description provided for @chat_locationFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Please try again.'**
  String get chat_locationFetchFailed;

  /// No description provided for @chat_locationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to share your location.'**
  String get chat_locationPermissionNeeded;

  /// No description provided for @chat_locationPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Location permission is turned off for this app. Enable it in Settings to share your location.'**
  String get chat_locationPermissionOff;

  /// No description provided for @chat_locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to share your location.'**
  String get chat_locationServicesOff;

  /// No description provided for @chat_locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get chat_locationUnavailable;

  /// No description provided for @chat_mediaMissing.
  ///
  /// In en, this message translates to:
  /// **'Media is missing'**
  String get chat_mediaMissing;

  /// No description provided for @chat_mediaMissingToast.
  ///
  /// In en, this message translates to:
  /// **'Media is missing. This file is no longer available.'**
  String get chat_mediaMissingToast;

  /// No description provided for @chat_mediaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This media is no longer available'**
  String get chat_mediaUnavailable;

  /// No description provided for @chat_menuForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get chat_menuForward;

  /// No description provided for @chat_menuMessageInfo.
  ///
  /// In en, this message translates to:
  /// **'Message Info'**
  String get chat_menuMessageInfo;

  /// No description provided for @chat_menuPin.
  ///
  /// In en, this message translates to:
  /// **'Pin Message'**
  String get chat_menuPin;

  /// No description provided for @chat_menuReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chat_menuReply;

  /// No description provided for @chat_menuUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin Message'**
  String get chat_menuUnpin;

  /// No description provided for @chat_messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get chat_messageCopied;

  /// No description provided for @chat_messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get chat_messageDeleted;

  /// No description provided for @chat_messageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Message not available'**
  String get chat_messageNotAvailable;

  /// No description provided for @chat_messageNotSent.
  ///
  /// In en, this message translates to:
  /// **'Message not sent. Please try again.'**
  String get chat_messageNotSent;

  /// No description provided for @chat_noCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get chat_noCameraFound;

  /// No description provided for @chat_noLongerMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re no longer a member of this group'**
  String get chat_noLongerMember;

  /// No description provided for @chat_noMediaAvailable.
  ///
  /// In en, this message translates to:
  /// **'No media available'**
  String get chat_noMediaAvailable;

  /// No description provided for @chat_offlineNotSent.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Message not sent.'**
  String get chat_offlineNotSent;

  /// No description provided for @chat_openDocument.
  ///
  /// In en, this message translates to:
  /// **'Open Document'**
  String get chat_openDocument;

  /// No description provided for @chat_openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get chat_openInGoogleMaps;

  /// No description provided for @chat_openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get chat_openSettings;

  /// No description provided for @chat_peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String chat_peopleCount(int count);

  /// No description provided for @chat_photoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This photo is no longer available'**
  String get chat_photoUnavailable;

  /// No description provided for @chat_previewAttendancePoll.
  ///
  /// In en, this message translates to:
  /// **'Attendance poll'**
  String get chat_previewAttendancePoll;

  /// No description provided for @chat_previewAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get chat_previewAudio;

  /// No description provided for @chat_previewContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get chat_previewContact;

  /// No description provided for @chat_previewDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get chat_previewDocument;

  /// No description provided for @chat_previewLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get chat_previewLocation;

  /// Noun: a chat message (fallback preview text)
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chat_previewMessage;

  /// No description provided for @chat_previewNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get chat_previewNewMessage;

  /// No description provided for @chat_previewOwnDeleted.
  ///
  /// In en, this message translates to:
  /// **'You deleted this message'**
  String get chat_previewOwnDeleted;

  /// No description provided for @chat_previewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chat_previewPhoto;

  /// No description provided for @chat_previewPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Photo} other{{count} Photos}}'**
  String chat_previewPhotosCount(int count);

  /// No description provided for @chat_previewPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get chat_previewPoll;

  /// No description provided for @chat_previewSticker.
  ///
  /// In en, this message translates to:
  /// **'Sticker'**
  String get chat_previewSticker;

  /// No description provided for @chat_previewVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chat_previewVideo;

  /// No description provided for @chat_previewVideosCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Video} other{{count} Videos}}'**
  String chat_previewVideosCount(int count);

  /// No description provided for @chat_previewVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get chat_previewVoiceMessage;

  /// No description provided for @chat_previewVoiceMessageDuration.
  ///
  /// In en, this message translates to:
  /// **'Voice message ({duration})'**
  String chat_previewVoiceMessageDuration(String duration);

  /// No description provided for @chat_recordingFailed.
  ///
  /// In en, this message translates to:
  /// **'Recording failed'**
  String get chat_recordingFailed;

  /// No description provided for @chat_removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get chat_removeMember;

  /// No description provided for @chat_removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member from the group?'**
  String get chat_removeMemberConfirm;

  /// No description provided for @chat_replyHint.
  ///
  /// In en, this message translates to:
  /// **'Reply to message...'**
  String get chat_replyHint;

  /// No description provided for @chat_searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search Messages'**
  String get chat_searchMessages;

  /// No description provided for @chat_searchMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages...'**
  String get chat_searchMessagesHint;

  /// No description provided for @chat_searchMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find messages by keyword'**
  String get chat_searchMessagesSubtitle;

  /// No description provided for @chat_sendLocation.
  ///
  /// In en, this message translates to:
  /// **'Send Location'**
  String get chat_sendLocation;

  /// No description provided for @chat_shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get chat_shareLocation;

  /// No description provided for @chat_shareVideoFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to share video'**
  String get chat_shareVideoFailed;

  /// No description provided for @chat_sharedFromApp.
  ///
  /// In en, this message translates to:
  /// **'Shared from FG Tracker'**
  String get chat_sharedFromApp;

  /// No description provided for @chat_sharedLocation.
  ///
  /// In en, this message translates to:
  /// **'Shared Location'**
  String get chat_sharedLocation;

  /// No description provided for @chat_showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show Original'**
  String get chat_showOriginal;

  /// No description provided for @chat_someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get chat_someone;

  /// A status/story update
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get chat_statusLabel;

  /// No description provided for @chat_statusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This status update is no longer available'**
  String get chat_statusUnavailable;

  /// No description provided for @chat_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get chat_stop;

  /// No description provided for @chat_stopEnglish.
  ///
  /// In en, this message translates to:
  /// **'Stop (English)'**
  String get chat_stopEnglish;

  /// No description provided for @chat_stopHindi.
  ///
  /// In en, this message translates to:
  /// **'Stop (Hindi)'**
  String get chat_stopHindi;

  /// No description provided for @chat_takePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo'**
  String get chat_takePhotoFailed;

  /// No description provided for @chat_translatedToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Translated to English'**
  String get chat_translatedToEnglish;

  /// No description provided for @chat_translatedToHindi.
  ///
  /// In en, this message translates to:
  /// **'Translated to Hindi'**
  String get chat_translatedToHindi;

  /// No description provided for @chat_translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get chat_translating;

  /// No description provided for @chat_tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get chat_tryAgain;

  /// No description provided for @chat_typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chat_typeMessageHint;

  /// No description provided for @chat_typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get chat_typing;

  /// Keep the trailing "..."
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person is typing...} other{{count} people are typing...}}'**
  String chat_typingMany(int count);

  /// Keep the trailing "..."
  ///
  /// In en, this message translates to:
  /// **'{name} is typing...'**
  String chat_typingOne(String name);

  /// Keep the trailing "..."
  ///
  /// In en, this message translates to:
  /// **'{name1}, {name2} are typing...'**
  String chat_typingTwo(String name1, String name2);

  /// No description provided for @chat_unableToOpen.
  ///
  /// In en, this message translates to:
  /// **'Unable to Open'**
  String get chat_unableToOpen;

  /// No description provided for @chat_unableToOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Unable to open Google Maps'**
  String get chat_unableToOpenGoogleMaps;

  /// No description provided for @chat_unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get chat_unblock;

  /// No description provided for @chat_unblockContact.
  ///
  /// In en, this message translates to:
  /// **'Unblock Contact'**
  String get chat_unblockContact;

  /// No description provided for @chat_unblockContactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this contact?'**
  String get chat_unblockContactConfirm;

  /// No description provided for @chat_unblockFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to unblock user'**
  String get chat_unblockFailed;

  /// Fallback when a name is missing
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get chat_unknown;

  /// No description provided for @chat_unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get chat_unknownLocation;

  /// No description provided for @chat_unsupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'This message isn\'t supported in this version of the app'**
  String get chat_unsupportedMessage;

  /// No description provided for @chat_updateGroup.
  ///
  /// In en, this message translates to:
  /// **'Update Group'**
  String get chat_updateGroup;

  /// No description provided for @chat_updateGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change the current group detail'**
  String get chat_updateGroupSubtitle;

  /// No description provided for @chat_uploadFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload {path}'**
  String chat_uploadFileFailed(String path);

  /// No description provided for @chat_userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get chat_userBlocked;

  /// No description provided for @chat_userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked successfully'**
  String get chat_userUnblocked;

  /// No description provided for @chat_videoDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Video downloaded successfully'**
  String get chat_videoDownloaded;

  /// No description provided for @chat_videoThumbnailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate video thumbnail'**
  String get chat_videoThumbnailFailed;

  /// No description provided for @chat_videoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This video is no longer available'**
  String get chat_videoUnavailable;

  /// No description provided for @chat_videoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload video'**
  String get chat_videoUploadFailed;

  /// No description provided for @chat_voicePlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play voice message'**
  String get chat_voicePlayFailed;

  /// No description provided for @chat_voiceUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice message upload failed. Please try again.'**
  String get chat_voiceUploadFailed;

  /// No description provided for @chat_youBlockedContact.
  ///
  /// In en, this message translates to:
  /// **'You blocked this contact'**
  String get chat_youBlockedContact;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get common_allow;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get common_comingSoon;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get common_copied;

  /// No description provided for @common_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get common_copy;

  /// No description provided for @common_daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String common_daysAgo(int count);

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// Default button of the error dialog. Login / OTP always show English.
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get common_dismiss;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get common_exit;

  /// No description provided for @common_gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get common_gotIt;

  /// No description provided for @common_hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String common_hoursAgo(int count);

  /// No description provided for @common_justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get common_justNow;

  /// No description provided for @common_lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {time}'**
  String common_lastSeen(String time);

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get common_loading;

  /// No description provided for @common_membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String common_membersCount(int count);

  /// No description provided for @common_minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String common_minutesAgo(int count);

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_noData.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get common_noData;

  /// No description provided for @common_noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get common_noInternet;

  /// No description provided for @common_notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get common_notNow;

  /// No description provided for @common_offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get common_offline;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get common_online;

  /// No description provided for @common_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get common_open;

  /// No description provided for @common_permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get common_permissionDenied;

  /// No description provided for @common_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get common_remove;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get common_send;

  /// No description provided for @common_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get common_settings;

  /// No description provided for @common_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// No description provided for @common_somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get common_somethingWentWrong;

  /// No description provided for @common_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get common_submit;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String common_todayAt(String time);

  /// No description provided for @common_tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_tryAgain;

  /// No description provided for @common_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get common_viewAll;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get common_yesterday;

  /// No description provided for @common_you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get common_you;

  /// No description provided for @dialog_allowLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get dialog_allowLocationAccess;

  /// No description provided for @dialog_anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred!'**
  String get dialog_anErrorOccurred;

  /// No description provided for @dialog_important.
  ///
  /// In en, this message translates to:
  /// **'Important!'**
  String get dialog_important;

  /// No description provided for @dialog_locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get dialog_locationPermissionRequired;

  /// No description provided for @dialog_locationPurposeBody.
  ///
  /// In en, this message translates to:
  /// **'To improve service efficiency, our application requests permission to access your location for the purpose of saving it. This enables our laborers to navigate accurately to your designated work location.'**
  String get dialog_locationPurposeBody;

  /// No description provided for @dialog_locationSettingsAndroid.
  ///
  /// In en, this message translates to:
  /// **'Without location access, we won\'t be able to detect your current location. Please tap on \'Settings\', then \'Permissions\', and allow location access.'**
  String get dialog_locationSettingsAndroid;

  /// No description provided for @dialog_locationSettingsIos.
  ///
  /// In en, this message translates to:
  /// **'This app requires access to your location to provide location-based services. Please go to \'Settings\' and enable location permissions.'**
  String get dialog_locationSettingsIos;

  /// No description provided for @dialog_loggedInElsewhere.
  ///
  /// In en, this message translates to:
  /// **'You have been logged in from another device.'**
  String get dialog_loggedInElsewhere;

  /// No description provided for @dialog_loggedInElsewhereLogInAgain.
  ///
  /// In en, this message translates to:
  /// **'You have been logged in from another device. Please log in again.'**
  String get dialog_loggedInElsewhereLogInAgain;

  /// No description provided for @dialog_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get dialog_logoutConfirm;

  /// No description provided for @dialog_selectAllowAllTheTime.
  ///
  /// In en, this message translates to:
  /// **'In the next popup, please select\n\'Allow all the time\'.'**
  String get dialog_selectAllowAllTheTime;

  /// No description provided for @dialog_sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get dialog_sessionExpiredTitle;

  /// No description provided for @editProfile_fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get editProfile_fullNameLabel;

  /// No description provided for @editProfile_personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get editProfile_personalInfo;

  /// No description provided for @editProfile_phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editProfile_phoneLabel;

  /// No description provided for @editProfile_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfile_saveButton;

  /// No description provided for @editProfile_tapPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap on the photo to change'**
  String get editProfile_tapPhotoHint;

  /// No description provided for @editProfile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile_title;

  /// No description provided for @forceUpdate_currentInstalled.
  ///
  /// In en, this message translates to:
  /// **'CURRENT INSTALLED'**
  String get forceUpdate_currentInstalled;

  /// No description provided for @forceUpdate_defaultMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of FG Tracker is available. Please update to continue.'**
  String get forceUpdate_defaultMessage;

  /// No description provided for @forceUpdate_defaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get forceUpdate_defaultTitle;

  /// No description provided for @forceUpdate_fallbackMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of FG Tracker is available with critical improvements. Please update to continue using the application.'**
  String get forceUpdate_fallbackMessage;

  /// No description provided for @forceUpdate_footer.
  ///
  /// In en, this message translates to:
  /// **'Update is required to proceed with FG Tracker'**
  String get forceUpdate_footer;

  /// No description provided for @forceUpdate_requiredVersion.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED VERSION'**
  String get forceUpdate_requiredVersion;

  /// No description provided for @forceUpdate_updateOnStore.
  ///
  /// In en, this message translates to:
  /// **'Update on {storeName}'**
  String forceUpdate_updateOnStore(String storeName);

  /// No description provided for @groupDialog_audioCall.
  ///
  /// In en, this message translates to:
  /// **'Audio Call'**
  String get groupDialog_audioCall;

  /// No description provided for @groupDialog_audioCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start voice conversation'**
  String get groupDialog_audioCallSubtitle;

  /// Button: call this member
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get groupDialog_call;

  /// Button: open a chat with this member
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get groupDialog_chat;

  /// No description provided for @groupDialog_codeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Group code cannot be empty'**
  String get groupDialog_codeEmpty;

  /// No description provided for @groupDialog_codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Code'**
  String get groupDialog_codeLabel;

  /// No description provided for @groupDialog_createButton.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get groupDialog_createButton;

  /// No description provided for @groupDialog_createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get groupDialog_createTitle;

  /// No description provided for @groupDialog_descHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Group Description'**
  String get groupDialog_descHint;

  /// No description provided for @groupDialog_descLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Description (Optional)'**
  String get groupDialog_descLabel;

  /// No description provided for @groupDialog_distance.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance}'**
  String groupDialog_distance(String distance);

  /// No description provided for @groupDialog_enterCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Group Code Manually'**
  String get groupDialog_enterCodeManually;

  /// No description provided for @groupDialog_enterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Group Code'**
  String get groupDialog_enterCodeTitle;

  /// No description provided for @groupDialog_fillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below'**
  String get groupDialog_fillDetails;

  /// No description provided for @groupDialog_getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get groupDialog_getDirections;

  /// No description provided for @groupDialog_join.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get groupDialog_join;

  /// No description provided for @groupDialog_lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {time}'**
  String groupDialog_lastSeen(String time);

  /// No description provided for @groupDialog_locationHidden.
  ///
  /// In en, this message translates to:
  /// **'Location Hidden'**
  String get groupDialog_locationHidden;

  /// No description provided for @groupDialog_locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get groupDialog_locationUnavailable;

  /// Fallback name when a member has no name
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupDialog_member;

  /// No description provided for @groupDialog_memberInfo.
  ///
  /// In en, this message translates to:
  /// **'Member’s Info'**
  String get groupDialog_memberInfo;

  /// No description provided for @groupDialog_nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get groupDialog_nameHint;

  /// No description provided for @groupDialog_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupDialog_nameLabel;

  /// No description provided for @groupDialog_noQrInImage.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in the selected image.'**
  String get groupDialog_noQrInImage;

  /// No description provided for @groupDialog_noValidQr.
  ///
  /// In en, this message translates to:
  /// **'No valid QR code found.'**
  String get groupDialog_noValidQr;

  /// No description provided for @groupDialog_qrDecodeError.
  ///
  /// In en, this message translates to:
  /// **'Error decoding QR from gallery: {error}'**
  String groupDialog_qrDecodeError(String error);

  /// No description provided for @groupDialog_scanCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan from Camera'**
  String get groupDialog_scanCamera;

  /// No description provided for @groupDialog_selectCallType.
  ///
  /// In en, this message translates to:
  /// **'Select Call Type'**
  String get groupDialog_selectCallType;

  /// Button: save changes to a group
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get groupDialog_update;

  /// No description provided for @groupDialog_updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Group'**
  String get groupDialog_updateTitle;

  /// No description provided for @groupDialog_uploadGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get groupDialog_uploadGallery;

  /// No description provided for @groupDialog_videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get groupDialog_videoCall;

  /// No description provided for @groupDialog_videoCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start video conversation'**
  String get groupDialog_videoCallSubtitle;

  /// No description provided for @groupDialog_yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your current location'**
  String get groupDialog_yourLocation;

  /// Group status badge
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get groupInfo_active;

  /// No description provided for @groupInfo_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get groupInfo_admin;

  /// No description provided for @groupInfo_allGroups.
  ///
  /// In en, this message translates to:
  /// **'All Groups'**
  String get groupInfo_allGroups;

  /// No description provided for @groupInfo_allGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with your teams'**
  String get groupInfo_allGroupsSubtitle;

  /// No description provided for @groupInfo_areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get groupInfo_areYouSure;

  /// No description provided for @groupInfo_audioCall.
  ///
  /// In en, this message translates to:
  /// **'Audio Call'**
  String get groupInfo_audioCall;

  /// No description provided for @groupInfo_clearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all messages from this device?'**
  String get groupInfo_clearChatConfirm;

  /// No description provided for @groupInfo_createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get groupInfo_createdBy;

  /// No description provided for @groupInfo_detailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group details not found'**
  String get groupInfo_detailsNotFound;

  /// No description provided for @groupInfo_exitGroup.
  ///
  /// In en, this message translates to:
  /// **'Exit Group'**
  String get groupInfo_exitGroup;

  /// No description provided for @groupInfo_exitGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit \"{groupName}\"?'**
  String groupInfo_exitGroupConfirm(String groupName);

  /// No description provided for @groupInfo_exitGroupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to Exit this Group?'**
  String get groupInfo_exitGroupQuestion;

  /// Fallback group name
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupInfo_group;

  /// No description provided for @groupInfo_groupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Group Admin'**
  String get groupInfo_groupAdmin;

  /// No description provided for @groupInfo_groupCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start group call. Please try again.'**
  String get groupInfo_groupCallFailed;

  /// No description provided for @groupInfo_groupCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Group code copied!'**
  String get groupInfo_groupCodeCopied;

  /// No description provided for @groupInfo_groupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group Settings'**
  String get groupInfo_groupSettings;

  /// No description provided for @groupInfo_groupSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit group info, privacy, and more'**
  String get groupInfo_groupSettingsSubtitle;

  /// Group status badge
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get groupInfo_inactive;

  /// No description provided for @groupInfo_inviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite text copied'**
  String get groupInfo_inviteCopied;

  /// No description provided for @groupInfo_inviteText.
  ///
  /// In en, this message translates to:
  /// **'Join my group \"{groupName}\" on FG Tracker'**
  String groupInfo_inviteText(String groupName);

  /// No description provided for @groupInfo_inviteTextWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join my group \"{groupName}\" on FG Tracker. Code: {code}'**
  String groupInfo_inviteTextWithCode(String groupName, String code);

  /// No description provided for @groupInfo_inviteViaLink.
  ///
  /// In en, this message translates to:
  /// **'Invite via Link'**
  String get groupInfo_inviteViaLink;

  /// No description provided for @groupInfo_mediaLinksDocs.
  ///
  /// In en, this message translates to:
  /// **'Media, Links & Docs'**
  String get groupInfo_mediaLinksDocs;

  /// No description provided for @groupInfo_member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupInfo_member;

  /// No description provided for @groupInfo_members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupInfo_members;

  /// Verb: send a message to this member (menu item)
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get groupInfo_messageAction;

  /// No description provided for @groupInfo_nameYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (You)'**
  String groupInfo_nameYou(String name);

  /// No description provided for @groupInfo_noGroupFound.
  ///
  /// In en, this message translates to:
  /// **'No group found for \'{query}\''**
  String groupInfo_noGroupFound(String query);

  /// No description provided for @groupInfo_noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined or created any groups yet.\nStart exploring now!'**
  String get groupInfo_noGroupsYet;

  /// No description provided for @groupInfo_noMediaYet.
  ///
  /// In en, this message translates to:
  /// **'No media shared yet'**
  String get groupInfo_noMediaYet;

  /// No description provided for @groupInfo_removeFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get groupInfo_removeFromGroup;

  /// No description provided for @groupInfo_removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from the group?'**
  String groupInfo_removeMemberConfirm(String name);

  /// No description provided for @groupInfo_searchGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups...'**
  String get groupInfo_searchGroupsHint;

  /// No description provided for @groupInfo_showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get groupInfo_showLess;

  /// No description provided for @groupInfo_teamCode.
  ///
  /// In en, this message translates to:
  /// **'Team Code'**
  String get groupInfo_teamCode;

  /// No description provided for @groupInfo_totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Total'**
  String groupInfo_totalCount(int count);

  /// No description provided for @groupInfo_unknownGroup.
  ///
  /// In en, this message translates to:
  /// **'Unknown Group'**
  String get groupInfo_unknownGroup;

  /// No description provided for @groupInfo_unnamedGroup.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Group'**
  String get groupInfo_unnamedGroup;

  /// No description provided for @groupInfo_videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get groupInfo_videoCall;

  /// No description provided for @groupInfo_viewAllMembers.
  ///
  /// In en, this message translates to:
  /// **'View all members'**
  String get groupInfo_viewAllMembers;

  /// No description provided for @group_activatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group activated successfully'**
  String get group_activatedSuccess;

  /// No description provided for @group_addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get group_addMember;

  /// No description provided for @group_alignQr.
  ///
  /// In en, this message translates to:
  /// **'Align QR inside the frame'**
  String get group_alignQr;

  /// No description provided for @group_areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get group_areYouSure;

  /// No description provided for @group_chatWithMembers.
  ///
  /// In en, this message translates to:
  /// **'Chat with members in the group'**
  String get group_chatWithMembers;

  /// No description provided for @group_codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Group code copied!'**
  String get group_codeCopied;

  /// No description provided for @group_codeShareInfo.
  ///
  /// In en, this message translates to:
  /// **'Group code: {code} — share it so others can join'**
  String group_codeShareInfo(String code);

  /// No description provided for @group_copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get group_copyCode;

  /// Label: who created the group (value: You / Other)
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get group_created;

  /// No description provided for @group_createdJustNow.
  ///
  /// In en, this message translates to:
  /// **'Created just now'**
  String get group_createdJustNow;

  /// No description provided for @group_deactivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group deactivated successfully'**
  String get group_deactivatedSuccess;

  /// Fallback group name when the group has no name
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group_defaultName;

  /// No description provided for @group_deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Group Delete'**
  String get group_deleteGroup;

  /// No description provided for @group_deleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to Delete this Group?'**
  String get group_deleteGroupConfirm;

  /// No description provided for @group_deletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group deleted successfully'**
  String get group_deletedSuccess;

  /// No description provided for @group_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get group_download;

  /// No description provided for @group_downloadChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifies when QR code is downloaded'**
  String get group_downloadChannelDescription;

  /// No description provided for @group_downloadChannelName.
  ///
  /// In en, this message translates to:
  /// **'Download Notifications'**
  String get group_downloadChannelName;

  /// No description provided for @group_enableLocationToJoin.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services to join a group.'**
  String get group_enableLocationToJoin;

  /// No description provided for @group_exitGroup.
  ///
  /// In en, this message translates to:
  /// **'Exit Group'**
  String get group_exitGroup;

  /// No description provided for @group_exitGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to Exit this Group?'**
  String get group_exitGroupConfirm;

  /// No description provided for @group_exitGroupNamedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit \"{groupName}\"? You\'ll need a group code to rejoin.'**
  String group_exitGroupNamedConfirm(String groupName);

  /// No description provided for @group_exitedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group Exit successfully'**
  String get group_exitedSuccess;

  /// No description provided for @group_goToGroups.
  ///
  /// In en, this message translates to:
  /// **'Go to Groups →'**
  String get group_goToGroups;

  /// No description provided for @group_groupMessage.
  ///
  /// In en, this message translates to:
  /// **'Group Message'**
  String get group_groupMessage;

  /// No description provided for @group_invalidResponseFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get group_invalidResponseFormat;

  /// No description provided for @group_joinedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Joined just now'**
  String get group_joinedJustNow;

  /// Shown as the join date when it is unknown
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get group_joinedRecently;

  /// No description provided for @group_leftJustNow.
  ///
  /// In en, this message translates to:
  /// **'Left just now'**
  String get group_leftJustNow;

  /// No description provided for @group_locationNoLongerShared.
  ///
  /// In en, this message translates to:
  /// **'Your location is no longer shared with this group'**
  String get group_locationNoLongerShared;

  /// No description provided for @group_locationPermissionToJoin.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to join a group.'**
  String get group_locationPermissionToJoin;

  /// No description provided for @group_locationShared.
  ///
  /// In en, this message translates to:
  /// **'Your location is shared with this group'**
  String get group_locationShared;

  /// No description provided for @group_memberFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get group_memberFallbackName;

  /// No description provided for @group_membersMeta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member · {when}} other{{count} members · {when}}}'**
  String group_membersMeta(int count, String when);

  /// No description provided for @group_noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get group_noContactsFound;

  /// No description provided for @group_noGroupCode.
  ///
  /// In en, this message translates to:
  /// **'No Group Code Available'**
  String get group_noGroupCode;

  /// No description provided for @group_noNewMessages.
  ///
  /// In en, this message translates to:
  /// **'You won\'t get new messages from this group'**
  String get group_noNewMessages;

  /// No description provided for @group_noNumber.
  ///
  /// In en, this message translates to:
  /// **'No number'**
  String get group_noNumber;

  /// No description provided for @group_openGroup.
  ///
  /// In en, this message translates to:
  /// **'Open Group →'**
  String get group_openGroup;

  /// No description provided for @group_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get group_other;

  /// No description provided for @group_qrSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to open your QR code'**
  String get group_qrSavedBody;

  /// No description provided for @group_qrSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Code Saved'**
  String get group_qrSavedTitle;

  /// No description provided for @group_qrShareMessage.
  ///
  /// In en, this message translates to:
  /// **'📌 Group Code: {groupCode}\n\nJoin my group instantly using the QR code or the code above.\n\n📲 Download the app to stay connected:\n{appLink}'**
  String group_qrShareMessage(String groupCode, String appLink);

  /// No description provided for @group_scanToJoin.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code to join the group'**
  String get group_scanToJoin;

  /// No description provided for @group_searchMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Search member...'**
  String get group_searchMemberHint;

  /// No description provided for @group_shareCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'Share the group code so others can join'**
  String get group_shareCodeInfo;

  /// No description provided for @group_shareQr.
  ///
  /// In en, this message translates to:
  /// **'Share QR'**
  String get group_shareQr;

  /// No description provided for @group_shareQrToInvite.
  ///
  /// In en, this message translates to:
  /// **'Share QR code to invite members'**
  String get group_shareQrToInvite;

  /// No description provided for @group_sheetCreatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your group is ready. Share the code so members can join.'**
  String get group_sheetCreatedSubtitle;

  /// No description provided for @group_sheetCreatedSubtitleNamed.
  ///
  /// In en, this message translates to:
  /// **'{name}, your group is ready. Share the code so members can join.'**
  String group_sheetCreatedSubtitleNamed(String name);

  /// No description provided for @group_sheetCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Group created!'**
  String get group_sheetCreatedTitle;

  /// No description provided for @group_sheetJoinedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, you\'re now a member of this group.'**
  String get group_sheetJoinedSubtitle;

  /// No description provided for @group_sheetJoinedSubtitleNamed.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}, you\'re now a member of this group.'**
  String group_sheetJoinedSubtitleNamed(String name);

  /// No description provided for @group_sheetJoinedTitle.
  ///
  /// In en, this message translates to:
  /// **'Joined successfully!'**
  String get group_sheetJoinedTitle;

  /// No description provided for @group_sheetLeftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re no longer a member of this group.'**
  String get group_sheetLeftSubtitle;

  /// No description provided for @group_sheetLeftSubtitleNamed.
  ///
  /// In en, this message translates to:
  /// **'{name}, you\'re no longer a member of this group.'**
  String group_sheetLeftSubtitleNamed(String name);

  /// No description provided for @group_sheetLeftTitle.
  ///
  /// In en, this message translates to:
  /// **'You left the group'**
  String get group_sheetLeftTitle;

  /// No description provided for @group_showQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get group_showQrCode;

  /// No description provided for @group_startConversation.
  ///
  /// In en, this message translates to:
  /// **'Feel Free to start a conversation '**
  String get group_startConversation;

  /// No description provided for @group_statusUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update group status'**
  String get group_statusUpdateFailed;

  /// No description provided for @group_teamCode.
  ///
  /// In en, this message translates to:
  /// **'Team Code'**
  String get group_teamCode;

  /// No description provided for @group_teamCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Team Code: '**
  String get group_teamCodeLabel;

  /// No description provided for @group_track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get group_track;

  /// No description provided for @group_unnamedMember.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Member'**
  String get group_unnamedMember;

  /// No description provided for @group_unnamedTrip.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Trip'**
  String get group_unnamedTrip;

  /// No description provided for @group_updateGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update the group details?'**
  String get group_updateGroupConfirm;

  /// No description provided for @group_updateGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Group'**
  String get group_updateGroupTitle;

  /// No description provided for @group_youAreAdmin.
  ///
  /// In en, this message translates to:
  /// **'You are the admin of this group'**
  String get group_youAreAdmin;

  /// No description provided for @home_actionAllContacts.
  ///
  /// In en, this message translates to:
  /// **'All contacts'**
  String get home_actionAllContacts;

  /// No description provided for @home_actionAudioVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Audio/Video Call'**
  String get home_actionAudioVideoCall;

  /// No description provided for @home_actionChatting.
  ///
  /// In en, this message translates to:
  /// **'Chatting'**
  String get home_actionChatting;

  /// No description provided for @home_actionSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Safe Zone'**
  String get home_actionSafeZone;

  /// No description provided for @home_actionTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get home_actionTracking;

  /// No description provided for @home_actionWalkieTalkie.
  ///
  /// In en, this message translates to:
  /// **'Walkie Talkie'**
  String get home_actionWalkieTalkie;

  /// No description provided for @home_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get home_active;

  /// No description provided for @home_activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get home_activeSessions;

  /// No description provided for @home_activeSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Active Session} other{{count} Active Sessions}}'**
  String home_activeSessionsCount(int count);

  /// No description provided for @home_allMembers.
  ///
  /// In en, this message translates to:
  /// **'All Members'**
  String get home_allMembers;

  /// No description provided for @home_createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get home_createGroup;

  /// No description provided for @home_createGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create new group'**
  String get home_createGroupSubtitle;

  /// No description provided for @home_goodToSeeYou.
  ///
  /// In en, this message translates to:
  /// **'It’s good to see you again 👋'**
  String get home_goodToSeeYou;

  /// No description provided for @home_groupsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Group} other{{count} Groups}}'**
  String home_groupsCount(int count);

  /// No description provided for @home_helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String home_helloName(String name);

  /// No description provided for @home_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get home_inactive;

  /// No description provided for @home_joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get home_joinGroup;

  /// No description provided for @home_joinGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join existing group'**
  String get home_joinGroupSubtitle;

  /// No description provided for @home_lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String home_lastSeen(String time);

  /// No description provided for @home_newThisMonth.
  ///
  /// In en, this message translates to:
  /// **'New This Month'**
  String get home_newThisMonth;

  /// No description provided for @home_noActivePrivateSessions.
  ///
  /// In en, this message translates to:
  /// **'No active private sessions'**
  String get home_noActivePrivateSessions;

  /// No description provided for @home_noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No groups available'**
  String get home_noGroupsAvailable;

  /// No description provided for @home_noGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get home_noGroupsFound;

  /// No description provided for @home_noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get home_noMembersFound;

  /// No description provided for @home_noMembersMatch.
  ///
  /// In en, this message translates to:
  /// **'No members match \'{query}\''**
  String home_noMembersMatch(String query);

  /// No description provided for @home_noMembersOnline.
  ///
  /// In en, this message translates to:
  /// **'No members currently online'**
  String get home_noMembersOnline;

  /// No description provided for @home_noNameGroup.
  ///
  /// In en, this message translates to:
  /// **'No Name Group'**
  String get home_noNameGroup;

  /// No description provided for @home_noRecentlyActiveMembers.
  ///
  /// In en, this message translates to:
  /// **'No recently active members'**
  String get home_noRecentlyActiveMembers;

  /// No description provided for @home_onlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online Now'**
  String get home_onlineNow;

  /// No description provided for @home_peopleOnline.
  ///
  /// In en, this message translates to:
  /// **'People Online'**
  String get home_peopleOnline;

  /// No description provided for @home_peopleOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These members are active in the app right now and available to connect.'**
  String get home_peopleOnlineSubtitle;

  /// No description provided for @home_privateMode.
  ///
  /// In en, this message translates to:
  /// **'Private Mode'**
  String get home_privateMode;

  /// No description provided for @home_privateModeIsOn.
  ///
  /// In en, this message translates to:
  /// **'Private Mode is ON'**
  String get home_privateModeIsOn;

  /// No description provided for @home_privateModeOffHint.
  ///
  /// In en, this message translates to:
  /// **'When Private Mode is OFF, others can see your location.'**
  String get home_privateModeOffHint;

  /// No description provided for @home_privateModeOnHint.
  ///
  /// In en, this message translates to:
  /// **'When Private Mode is ON, others can\'t see your location.'**
  String get home_privateModeOnHint;

  /// No description provided for @home_quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need, one tap away.'**
  String get home_quickActionsSubtitle;

  /// No description provided for @home_quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get home_quickActionsTitle;

  /// No description provided for @home_recentlyOnline.
  ///
  /// In en, this message translates to:
  /// **'Recently Online'**
  String get home_recentlyOnline;

  /// No description provided for @home_searchGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups...'**
  String get home_searchGroupsHint;

  /// No description provided for @home_searchMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Search members...'**
  String get home_searchMembersHint;

  /// No description provided for @home_showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get home_showLess;

  /// No description provided for @home_sortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Sort: Name (A-Z)'**
  String get home_sortNameAsc;

  /// No description provided for @home_sortNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Sort: Name (Z-A)'**
  String get home_sortNameDesc;

  /// No description provided for @home_startedAt.
  ///
  /// In en, this message translates to:
  /// **'Started at {time}'**
  String home_startedAt(String time);

  /// No description provided for @home_statGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get home_statGroups;

  /// No description provided for @home_statMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get home_statMembers;

  /// No description provided for @home_statNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get home_statNow;

  /// No description provided for @home_statTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get home_statTotal;

  /// No description provided for @home_totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get home_totalMembers;

  /// No description provided for @home_totalMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Total Member} other{{count} Total Members}}'**
  String home_totalMembersCount(int count);

  /// No description provided for @home_unableToFetchGroups.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch groups'**
  String get home_unableToFetchGroups;

  /// No description provided for @home_unknownMember.
  ///
  /// In en, this message translates to:
  /// **'Unknown Member'**
  String get home_unknownMember;

  /// No description provided for @home_upgradeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced features for your team'**
  String get home_upgradeSubtitle;

  /// No description provided for @home_upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get home_upgradeToPremium;

  /// No description provided for @home_viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get home_viewPlans;

  /// No description provided for @home_walkieExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get home_walkieExpired;

  /// No description provided for @home_walkieOneHourFree.
  ///
  /// In en, this message translates to:
  /// **'1 hr free'**
  String get home_walkieOneHourFree;

  /// No description provided for @home_walkieRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get home_walkieRenew;

  /// No description provided for @home_walkieSubscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get home_walkieSubscribed;

  /// No description provided for @home_youAreInvisible.
  ///
  /// In en, this message translates to:
  /// **'You\'re Invisible'**
  String get home_youAreInvisible;

  /// No description provided for @home_youAreVisible.
  ///
  /// In en, this message translates to:
  /// **'You\'re Visible'**
  String get home_youAreVisible;

  /// Shown when a request fails because of a network problem or timeout
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again!'**
  String get http_networkError;

  /// No description provided for @http_sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get http_sessionExpired;

  /// No description provided for @http_unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get http_unexpectedError;

  /// No description provided for @imagePicker_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imagePicker_camera;

  /// No description provided for @imagePicker_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get imagePicker_cancel;

  /// No description provided for @imagePicker_cropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get imagePicker_cropTitle;

  /// No description provided for @imagePicker_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get imagePicker_gallery;

  /// No description provided for @imagePicker_title.
  ///
  /// In en, this message translates to:
  /// **'Choose an Option'**
  String get imagePicker_title;

  /// No description provided for @intro_realTimeTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View live locations of friends, \n family, or team members on \n the map instantly.'**
  String get intro_realTimeTrackingSubtitle;

  /// No description provided for @intro_realTimeTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Tracking'**
  String get intro_realTimeTrackingTitle;

  /// No description provided for @intro_secureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your live location with \n selected contacts safely and \n privately.'**
  String get intro_secureSubtitle;

  /// No description provided for @intro_secureTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure & Easy'**
  String get intro_secureTitle;

  /// No description provided for @intro_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get intro_skip;

  /// No description provided for @intro_walkieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No signal. No problem. Stay \n connected anywhere.'**
  String get intro_walkieSubtitle;

  /// No description provided for @intro_walkieTitle.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie \n feature'**
  String get intro_walkieTitle;

  /// No description provided for @media_cannotOpen.
  ///
  /// In en, this message translates to:
  /// **'Cannot open'**
  String get media_cannotOpen;

  /// No description provided for @media_documentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Document not found'**
  String get media_documentNotFound;

  /// No description provided for @media_invalidLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid link'**
  String get media_invalidLink;

  /// No description provided for @media_noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get media_noDocuments;

  /// No description provided for @media_noLinks.
  ///
  /// In en, this message translates to:
  /// **'No links found'**
  String get media_noLinks;

  /// No description provided for @media_noMedia.
  ///
  /// In en, this message translates to:
  /// **'No media found'**
  String get media_noMedia;

  /// No description provided for @media_tabDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get media_tabDocs;

  /// No description provided for @media_tabDocsCount.
  ///
  /// In en, this message translates to:
  /// **'Docs ({count})'**
  String media_tabDocsCount(int count);

  /// No description provided for @media_tabLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get media_tabLinks;

  /// No description provided for @media_tabLinksCount.
  ///
  /// In en, this message translates to:
  /// **'Links ({count})'**
  String media_tabLinksCount(int count);

  /// No description provided for @media_tabMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media_tabMedia;

  /// No description provided for @media_tabMediaCount.
  ///
  /// In en, this message translates to:
  /// **'Media ({count})'**
  String media_tabMediaCount(int count);

  /// No description provided for @media_title.
  ///
  /// In en, this message translates to:
  /// **'Media, links, and docs'**
  String get media_title;

  /// No description provided for @media_videoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Video not found'**
  String get media_videoNotFound;

  /// No description provided for @menu_contactUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Know more about us'**
  String get menu_contactUsSubtitle;

  /// No description provided for @menu_editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get menu_editProfile;

  /// No description provided for @menu_editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get menu_editProfileSubtitle;

  /// No description provided for @menu_followUsOn.
  ///
  /// In en, this message translates to:
  /// **'Follow us on'**
  String get menu_followUsOn;

  /// No description provided for @menu_logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get menu_logOut;

  /// No description provided for @menu_logOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to logout?'**
  String get menu_logOutConfirmMessage;

  /// No description provided for @menu_logOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out from the app'**
  String get menu_logOutSubtitle;

  /// No description provided for @menu_profileImageUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile image'**
  String get menu_profileImageUpdateFailed;

  /// No description provided for @menu_profileImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully'**
  String get menu_profileImageUpdated;

  /// Notification action button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get notif_accept;

  /// No description provided for @notif_channelHighImportanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Default channel for high importance notifications'**
  String get notif_channelHighImportanceDesc;

  /// Android notification channel name (shown in system settings)
  ///
  /// In en, this message translates to:
  /// **'High Importance Notifications'**
  String get notif_channelHighImportanceName;

  /// No description provided for @notif_channelWalkieAudioDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintains live voice communication and background mic capture'**
  String get notif_channelWalkieAudioDesc;

  /// No description provided for @notif_channelWalkieAudioName.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie Live Audio'**
  String get notif_channelWalkieAudioName;

  /// No description provided for @notif_channelWalkieCallsDesc.
  ///
  /// In en, this message translates to:
  /// **'Incoming Walkie-Talkie calls'**
  String get notif_channelWalkieCallsDesc;

  /// No description provided for @notif_channelWalkieCallsName.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie Calls'**
  String get notif_channelWalkieCallsName;

  /// No description provided for @notif_channelWalkieDesc.
  ///
  /// In en, this message translates to:
  /// **'Group walkie calls and speaking updates'**
  String get notif_channelWalkieDesc;

  /// No description provided for @notif_channelWalkieLiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for active Walkie-Talkie channels'**
  String get notif_channelWalkieLiveDesc;

  /// No description provided for @notif_channelWalkieLiveName.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie Live Channels'**
  String get notif_channelWalkieLiveName;

  /// Notification channel name
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie'**
  String get notif_channelWalkieName;

  /// No description provided for @notif_connectedIn.
  ///
  /// In en, this message translates to:
  /// **'Connected in {group} • Live Audio Stream'**
  String notif_connectedIn(String group);

  /// No description provided for @notif_goToWalkie.
  ///
  /// In en, this message translates to:
  /// **'Go to Walkie Screen'**
  String get notif_goToWalkie;

  /// No description provided for @notif_incomingWalkieTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Walkie-Talkie'**
  String get notif_incomingWalkieTitle;

  /// No description provided for @notif_isTalking.
  ///
  /// In en, this message translates to:
  /// **'{name} is talking'**
  String notif_isTalking(String name);

  /// Notification button: leave the walkie group
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get notif_leave;

  /// No description provided for @notif_openWalkie.
  ///
  /// In en, this message translates to:
  /// **'Open Walkie'**
  String get notif_openWalkie;

  /// Notification action button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get notif_reject;

  /// No description provided for @notif_stoppedTalking.
  ///
  /// In en, this message translates to:
  /// **'{name} stopped talking'**
  String notif_stoppedTalking(String name);

  /// No description provided for @notif_walkieActiveConversation.
  ///
  /// In en, this message translates to:
  /// **'Active walkie-talkie conversation'**
  String get notif_walkieActiveConversation;

  /// No description provided for @notif_walkieActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie Active'**
  String get notif_walkieActiveTitle;

  /// No description provided for @notif_wantsToTalk.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to talk'**
  String notif_wantsToTalk(String name);

  /// No description provided for @notifications_clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications'**
  String get notifications_clearAll;

  /// No description provided for @notifications_clearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared successfully'**
  String get notifications_clearedSuccess;

  /// No description provided for @notifications_emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no new alerts at the moment.'**
  String get notifications_emptySubtitle;

  /// No description provided for @notifications_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Notifications Yet'**
  String get notifications_emptyTitle;

  /// No description provided for @notifications_filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifications_filterAll;

  /// No description provided for @notifications_filterCalls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get notifications_filterCalls;

  /// No description provided for @notifications_filterChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get notifications_filterChats;

  /// No description provided for @notifications_filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notifications_filterUnread;

  /// No description provided for @notifications_loadingDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading notification details'**
  String get notifications_loadingDetails;

  /// No description provided for @notifications_recentCalls.
  ///
  /// In en, this message translates to:
  /// **'Recent Calls'**
  String get notifications_recentCalls;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @otpCharges_chargedNotice.
  ///
  /// In en, this message translates to:
  /// **'From now on, each login OTP to your number is charged. Resending the OTP is free (up to 3 attempts).'**
  String get otpCharges_chargedNotice;

  /// No description provided for @otpCharges_chargesApplyTo.
  ///
  /// In en, this message translates to:
  /// **'Charges apply to'**
  String get otpCharges_chargesApplyTo;

  /// No description provided for @otpCharges_eachOtpCosts.
  ///
  /// In en, this message translates to:
  /// **'Each OTP costs'**
  String get otpCharges_eachOtpCosts;

  /// No description provided for @otpCharges_eachOtpCostsSpoken.
  ///
  /// In en, this message translates to:
  /// **'Each OTP costs {amount}'**
  String otpCharges_eachOtpCostsSpoken(String amount);

  /// No description provided for @otpCharges_eachOtpCostsSpokenGst.
  ///
  /// In en, this message translates to:
  /// **'Each OTP costs {amount}, including {percent} percent GST'**
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent);

  /// No description provided for @otpCharges_firstLoginFree.
  ///
  /// In en, this message translates to:
  /// **'Your first login was free.'**
  String get otpCharges_firstLoginFree;

  /// No description provided for @otpCharges_freeBody.
  ///
  /// In en, this message translates to:
  /// **'Login OTPs sent to this number are not charged.'**
  String get otpCharges_freeBody;

  /// No description provided for @otpCharges_freeTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP is free for your number'**
  String get otpCharges_freeTitle;

  /// No description provided for @otpCharges_gstTitle.
  ///
  /// In en, this message translates to:
  /// **'GST ({percent}%)'**
  String otpCharges_gstTitle(String percent);

  /// No description provided for @otpCharges_includingGst.
  ///
  /// In en, this message translates to:
  /// **'Including {percent}% GST'**
  String otpCharges_includingGst(String percent);

  /// No description provided for @otpCharges_includingTax.
  ///
  /// In en, this message translates to:
  /// **'Including {percent}% Tax'**
  String otpCharges_includingTax(String percent);

  /// No description provided for @otpCharges_noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get otpCharges_noInternet;

  /// No description provided for @otpCharges_otpCharge.
  ///
  /// In en, this message translates to:
  /// **'OTP charge'**
  String get otpCharges_otpCharge;

  /// No description provided for @otpCharges_pay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String otpCharges_pay(String amount);

  /// No description provided for @otpCharges_paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled. You cancelled the payment. No money was deducted.'**
  String get otpCharges_paymentCancelled;

  /// No description provided for @otpCharges_paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. If money was deducted it will be refunded in 5–7 working days.'**
  String get otpCharges_paymentFailed;

  /// No description provided for @otpCharges_paymentPausedButton.
  ///
  /// In en, this message translates to:
  /// **'Payment Paused ({amount})'**
  String otpCharges_paymentPausedButton(String amount);

  /// No description provided for @otpCharges_paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received. Your OTP may take a moment to arrive.'**
  String get otpCharges_paymentReceived;

  /// No description provided for @otpCharges_paymentStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the payment. Please try again.'**
  String get otpCharges_paymentStartFailed;

  /// No description provided for @otpCharges_paymentsPaused.
  ///
  /// In en, this message translates to:
  /// **'OTP payments are temporarily paused by administrator. Tap below for details.'**
  String get otpCharges_paymentsPaused;

  /// No description provided for @otpCharges_paymentsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'OTP payments are temporarily unavailable. Please try again later.'**
  String get otpCharges_paymentsUnavailable;

  /// No description provided for @otpCharges_sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please start again.'**
  String get otpCharges_sessionExpired;

  /// No description provided for @otpCharges_title.
  ///
  /// In en, this message translates to:
  /// **'OTP Charges'**
  String get otpCharges_title;

  /// No description provided for @otpCharges_totalPerOtp.
  ///
  /// In en, this message translates to:
  /// **'Total per OTP'**
  String get otpCharges_totalPerOtp;

  /// No description provided for @otpCharges_tryAgainMoment.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again in a moment.'**
  String get otpCharges_tryAgainMoment;

  /// No description provided for @otpCharges_unknownBody.
  ///
  /// In en, this message translates to:
  /// **'Login OTPs to Indian numbers are free. For other countries, the exact price is shown before you pay at login.'**
  String get otpCharges_unknownBody;

  /// No description provided for @otpCharges_unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP charges depend on your country'**
  String get otpCharges_unknownTitle;

  /// No description provided for @otpCharges_updateApp.
  ///
  /// In en, this message translates to:
  /// **'Payment couldn\'t start. Please update the app and try again.'**
  String get otpCharges_updateApp;

  /// No description provided for @otpCharges_vatTitle.
  ///
  /// In en, this message translates to:
  /// **'VAT / Tax ({percent}%)'**
  String otpCharges_vatTitle(String percent);

  /// No description provided for @otpCharges_verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment verification failed. If money was deducted it will be refunded in 5–7 working days.'**
  String get otpCharges_verificationFailed;

  /// No description provided for @otpCharges_yourNumber.
  ///
  /// In en, this message translates to:
  /// **'Your number'**
  String get otpCharges_yourNumber;

  /// No description provided for @package_noPackages.
  ///
  /// In en, this message translates to:
  /// **'No packages are available right now.'**
  String get package_noPackages;

  /// title = package/module name from the server
  ///
  /// In en, this message translates to:
  /// **'{title} plans are coming soon'**
  String package_plansComingSoon(String title);

  /// No description provided for @package_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a module to see its plans'**
  String get package_subtitle;

  /// No description provided for @package_title.
  ///
  /// In en, this message translates to:
  /// **'Packages & Pricing'**
  String get package_title;

  /// No description provided for @package_viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get package_viewPlans;

  /// No description provided for @perm_alwaysLocationBody.
  ///
  /// In en, this message translates to:
  /// **'To track your group in real time and in background, please set Location access to \'Allow all the time\' in App Settings.'**
  String get perm_alwaysLocationBody;

  /// No description provided for @perm_alwaysLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable \'Always\' Location Permission'**
  String get perm_alwaysLocationTitle;

  /// No description provided for @perm_chooseAllowAllTime.
  ///
  /// In en, this message translates to:
  /// **'Please choose \'Allow all the time\' in the upcoming popup.'**
  String get perm_chooseAllowAllTime;

  /// No description provided for @perm_collectsLocationBody.
  ///
  /// In en, this message translates to:
  /// **'This app collects location data to ensure smooth job progress and provide efficient tracking, even when the app is closed or not in use.'**
  String get perm_collectsLocationBody;

  /// No description provided for @perm_enableDeviceGpsBody.
  ///
  /// In en, this message translates to:
  /// **'Please enable your device\'s GPS (Google Location).'**
  String get perm_enableDeviceGpsBody;

  /// No description provided for @perm_enableGpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get perm_enableGpsTitle;

  /// No description provided for @perm_exitBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the app?'**
  String get perm_exitBody;

  /// No description provided for @perm_exitTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get perm_exitTitle;

  /// No description provided for @perm_gpsRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'GPS is required to track your group in real time.'**
  String get perm_gpsRequiredBody;

  /// No description provided for @perm_locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get perm_locationTitle;

  /// No description provided for @perm_trackingPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'FG Partner app needs your permission to track location while you are logged in.'**
  String get perm_trackingPermissionBody;

  /// No description provided for @permission_allowAllTheTime.
  ///
  /// In en, this message translates to:
  /// **'Allow All The Time'**
  String get permission_allowAllTheTime;

  /// No description provided for @permission_allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get permission_allowLocation;

  /// No description provided for @permission_allowLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Please allow Location first.'**
  String get permission_allowLocationFirst;

  /// No description provided for @permission_allowNamed.
  ///
  /// In en, this message translates to:
  /// **'Allow {permission}'**
  String permission_allowNamed(String permission);

  /// No description provided for @permission_allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get permission_allowNotifications;

  /// No description provided for @permission_appPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the permissions required.'**
  String get permission_appPermissionsSubtitle;

  /// No description provided for @permission_appPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get permission_appPermissionsTitle;

  /// No description provided for @permission_badgeGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permission_badgeGranted;

  /// No description provided for @permission_badgeOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get permission_badgeOptional;

  /// No description provided for @permission_badgeRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get permission_badgeRecommended;

  /// No description provided for @permission_badgeRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get permission_badgeRequired;

  /// No description provided for @permission_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permission_camera;

  /// No description provided for @permission_cameraDescription.
  ///
  /// In en, this message translates to:
  /// **'Used by the app features that capture photos or videos.'**
  String get permission_cameraDescription;

  /// No description provided for @permission_cameraSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed to capture photos and videos. Please enable it from app settings.'**
  String get permission_cameraSettingsMessage;

  /// No description provided for @permission_cameraWhy.
  ///
  /// In en, this message translates to:
  /// **'Allows you to capture photos and videos for supported profile, chat and other app features.'**
  String get permission_cameraWhy;

  /// No description provided for @permission_contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get permission_contacts;

  /// No description provided for @permission_contactsDescription.
  ///
  /// In en, this message translates to:
  /// **'Used to discover or select contacts for contact-related app features.'**
  String get permission_contactsDescription;

  /// No description provided for @permission_contactsSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is needed to find and select contacts. Please enable it from app settings.'**
  String get permission_contactsSettingsMessage;

  /// No description provided for @permission_contactsWhy.
  ///
  /// In en, this message translates to:
  /// **'Helps you find and select contacts when using supported contact-related features.'**
  String get permission_contactsWhy;

  /// No description provided for @permission_gateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not check your permissions. Please try again.'**
  String get permission_gateCheckFailed;

  /// No description provided for @permission_gateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FG Tracker needs these permissions to receive calls and alerts and to run attendance, live tracking and safe zone.'**
  String get permission_gateSubtitle;

  /// No description provided for @permission_gateTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions Required'**
  String get permission_gateTitle;

  /// No description provided for @permission_genericSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'This permission is needed. Please enable it from app settings.'**
  String get permission_genericSettingsMessage;

  /// No description provided for @permission_iosLocationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location Services are turned off. Open Settings → Privacy & Security → Location Services and turn it on, then come back.'**
  String get permission_iosLocationServicesOff;

  /// No description provided for @permission_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permission_location;

  /// No description provided for @permission_locationAndNotificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location and Notification permissions are required to continue.'**
  String get permission_locationAndNotificationRequired;

  /// No description provided for @permission_locationAndNotificationsRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Location and Notifications are required to continue.'**
  String get permission_locationAndNotificationsRequiredHint;

  /// No description provided for @permission_locationDescription.
  ///
  /// In en, this message translates to:
  /// **'Needed for attendance, live tracking and safe zone — including when the app is in the background.'**
  String get permission_locationDescription;

  /// No description provided for @permission_locationRequiredToContinue.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to continue.'**
  String get permission_locationRequiredToContinue;

  /// No description provided for @permission_locationStatusApproximate.
  ///
  /// In en, this message translates to:
  /// **'Only approximate location is allowed. Precise is required.'**
  String get permission_locationStatusApproximate;

  /// No description provided for @permission_locationStatusBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked. Enable it from Settings.'**
  String get permission_locationStatusBlocked;

  /// No description provided for @permission_locationStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Allowed all the time · Precise · GPS on'**
  String get permission_locationStatusDone;

  /// No description provided for @permission_locationStatusGpsOff.
  ///
  /// In en, this message translates to:
  /// **'Device location (GPS) is turned off.'**
  String get permission_locationStatusGpsOff;

  /// No description provided for @permission_locationStatusNeedAlways.
  ///
  /// In en, this message translates to:
  /// **'\"Allow all the time\" is required.'**
  String get permission_locationStatusNeedAlways;

  /// No description provided for @permission_locationStatusNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Location permission not allowed yet.'**
  String get permission_locationStatusNotAllowed;

  /// No description provided for @permission_locationWhyExtra.
  ///
  /// In en, this message translates to:
  /// **'Please choose \"Allow all the time\" and keep Precise location on.'**
  String get permission_locationWhyExtra;

  /// No description provided for @permission_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get permission_logout;

  /// No description provided for @permission_microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone / Audio'**
  String get permission_microphone;

  /// No description provided for @permission_microphoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Used by voice, walkie-talkie, and calling features where applicable.'**
  String get permission_microphoneDescription;

  /// No description provided for @permission_microphoneSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed for voice, walkie-talkie and calls. Please enable it from app settings.'**
  String get permission_microphoneSettingsMessage;

  /// No description provided for @permission_microphoneWhy.
  ///
  /// In en, this message translates to:
  /// **'Allows voice communication, walkie-talkie transmission and calls when you use these features.'**
  String get permission_microphoneWhy;

  /// No description provided for @permission_notGrantedNamed.
  ///
  /// In en, this message translates to:
  /// **'{permission} permission was not granted. Please try again.'**
  String permission_notGrantedNamed(String permission);

  /// No description provided for @permission_notificationRequiredToContinue.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to continue.'**
  String get permission_notificationRequiredToContinue;

  /// No description provided for @permission_notificationSettingsText.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for FG Tracker. Open Settings → Notifications and allow them.'**
  String get permission_notificationSettingsText;

  /// No description provided for @permission_notificationStatusBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Enable them from Settings.'**
  String get permission_notificationStatusBlocked;

  /// No description provided for @permission_notificationStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permission_notificationStatusDone;

  /// No description provided for @permission_notificationStatusNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notification permission not allowed yet.'**
  String get permission_notificationStatusNotAllowed;

  /// No description provided for @permission_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permission_notifications;

  /// No description provided for @permission_notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Needed to receive incoming calls, chat messages and attendance / safe-zone alerts.'**
  String get permission_notificationsDescription;

  /// No description provided for @permission_notificationsWhyExtra.
  ///
  /// In en, this message translates to:
  /// **'Incoming calls cannot ring without this permission.'**
  String get permission_notificationsWhyExtra;

  /// No description provided for @permission_openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permission_openSettings;

  /// No description provided for @permission_preciseLocation.
  ///
  /// In en, this message translates to:
  /// **'Precise Location'**
  String get permission_preciseLocation;

  /// No description provided for @permission_pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get permission_pushNotifications;

  /// No description provided for @permission_reasonLocation.
  ///
  /// In en, this message translates to:
  /// **'Location is needed for attendance, live tracking and safe zone alerts.'**
  String get permission_reasonLocation;

  /// Quoted option is the Android system option 'Allow all the time'; translate it as the phone shows it in that language
  ///
  /// In en, this message translates to:
  /// **'Choose \"Allow all the time\" so live tracking and safe zone keep working when the app is in the background.'**
  String get permission_reasonLocationAlways;

  /// No description provided for @permission_reasonNotification.
  ///
  /// In en, this message translates to:
  /// **'Notifications are needed to receive incoming calls, chat messages, attendance and safe-zone alerts.'**
  String get permission_reasonNotification;

  /// No description provided for @permission_reasonPrecise.
  ///
  /// In en, this message translates to:
  /// **'Precise location is needed for accurate attendance, live tracking and safe zone alerts.'**
  String get permission_reasonPrecise;

  /// No description provided for @permission_required.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permission_required;

  /// No description provided for @permission_selectAllowAllTheTime.
  ///
  /// In en, this message translates to:
  /// **'Please select \"Allow all the time\" to continue.'**
  String get permission_selectAllowAllTheTime;

  /// No description provided for @permission_settingsAndroidAlways.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Permissions → Location and choose \"Allow all the time\".'**
  String get permission_settingsAndroidAlways;

  /// No description provided for @permission_settingsAndroidBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked for FG Tracker. Open Settings → Permissions → Location and choose \"Allow all the time\".'**
  String get permission_settingsAndroidBlocked;

  /// No description provided for @permission_settingsAndroidPrecise.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Permissions → Location and turn on \"Use precise location\".'**
  String get permission_settingsAndroidPrecise;

  /// No description provided for @permission_settingsIosAlways.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Location and choose \"Always\".'**
  String get permission_settingsIosAlways;

  /// No description provided for @permission_settingsIosBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location access is turned off for FG Tracker. Open Settings → Location and choose \"Always\".'**
  String get permission_settingsIosBlocked;

  /// No description provided for @permission_settingsIosPrecise.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Location and turn on \"Precise Location\".'**
  String get permission_settingsIosPrecise;

  /// No description provided for @permission_skipAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Skip & Continue'**
  String get permission_skipAndContinue;

  /// No description provided for @permission_turnOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn On Location'**
  String get permission_turnOnLocation;

  /// No description provided for @permission_turnOnPreciseLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn On Precise Location'**
  String get permission_turnOnPreciseLocation;

  /// No description provided for @permission_unableToRequest.
  ///
  /// In en, this message translates to:
  /// **'Unable to request permission.'**
  String get permission_unableToRequest;

  /// No description provided for @permission_whyWeNeedThis.
  ///
  /// In en, this message translates to:
  /// **'Why we need this?'**
  String get permission_whyWeNeedThis;

  /// Hint in the (read-only) mobile number field.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Number'**
  String get registration_contactNumberHint;

  /// No description provided for @registration_contactNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get registration_contactNumberLabel;

  /// Submit button on the Registration screen.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get registration_doneButton;

  /// No description provided for @registration_emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Email Address'**
  String get registration_emailHint;

  /// No description provided for @registration_emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get registration_emailLabel;

  /// No description provided for @registration_genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get registration_genderFemale;

  /// No description provided for @registration_genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get registration_genderLabel;

  /// No description provided for @registration_genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get registration_genderMale;

  /// No description provided for @registration_genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get registration_genderOther;

  /// No description provided for @registration_selectGenderError.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get registration_selectGenderError;

  /// No description provided for @registration_userNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter User Name'**
  String get registration_userNameHint;

  /// No description provided for @registration_userNameLabel.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get registration_userNameLabel;

  /// No description provided for @repo_allCallsCleared.
  ///
  /// In en, this message translates to:
  /// **'All call history cleared successfully'**
  String get repo_allCallsCleared;

  /// No description provided for @repo_callDeleted.
  ///
  /// In en, this message translates to:
  /// **'Call history deleted successfully'**
  String get repo_callDeleted;

  /// No description provided for @repo_invalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response format'**
  String get repo_invalidResponse;

  /// No description provided for @repo_loadLocationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load group locations'**
  String get repo_loadLocationsFailed;

  /// No description provided for @repo_pkgConflict.
  ///
  /// In en, this message translates to:
  /// **'This plan is already active or a payment is in progress.'**
  String get repo_pkgConflict;

  /// No description provided for @repo_pkgNotFound.
  ///
  /// In en, this message translates to:
  /// **'Plans are not available right now. Please try again later.'**
  String get repo_pkgNotFound;

  /// No description provided for @repo_pkgOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get repo_pkgOffline;

  /// No description provided for @repo_pkgSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get repo_pkgSessionExpired;

  /// No description provided for @repo_pkgTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long to respond. Please try again.'**
  String get repo_pkgTimeout;

  /// No description provided for @repo_selectedCallsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Selected calls deleted successfully'**
  String get repo_selectedCallsDeleted;

  /// No description provided for @repo_unnamedGroup.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Group'**
  String get repo_unnamedGroup;

  /// No description provided for @safeRoute_activeDetails.
  ///
  /// In en, this message translates to:
  /// **'Total Distance: {distance}  •  Allowed Deviation: {deviation}'**
  String safeRoute_activeDetails(String distance, String deviation);

  /// No description provided for @safeRoute_activeTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Safe Route'**
  String get safeRoute_activeTitle;

  /// No description provided for @safeRoute_alertSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage safe route alerts, deviation limits and notification preferences.'**
  String get safeRoute_alertSettingsDesc;

  /// No description provided for @safeRoute_alertSheetDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time alerts when team members deviate from the safe route'**
  String get safeRoute_alertSheetDesc;

  /// No description provided for @safeRoute_alertTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Route Alert'**
  String get safeRoute_alertTitle;

  /// No description provided for @safeRoute_appBarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a safe route for your team member.'**
  String get safeRoute_appBarSubtitle;

  /// No description provided for @safeRoute_destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get safeRoute_destination;

  /// No description provided for @safeRoute_deviated.
  ///
  /// In en, this message translates to:
  /// **'Deviated from safe route'**
  String get safeRoute_deviated;

  /// No description provided for @safeRoute_deviationAlertNote.
  ///
  /// In en, this message translates to:
  /// **'Alert will be triggered if the member deviates more than {distance} from the safe route.'**
  String safeRoute_deviationAlertNote(String distance);

  /// No description provided for @safeRoute_deviationAt.
  ///
  /// In en, this message translates to:
  /// **'{place} (Deviation: {distance})'**
  String safeRoute_deviationAt(String place, String distance);

  /// No description provided for @safeRoute_deviationLimit.
  ///
  /// In en, this message translates to:
  /// **'Deviation Limit'**
  String get safeRoute_deviationLimit;

  /// No description provided for @safeRoute_deviationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set how much deviation is allowed from the selected route.'**
  String get safeRoute_deviationSubtitle;

  /// No description provided for @safeRoute_distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get safeRoute_distance;

  /// No description provided for @safeRoute_distanceEta.
  ///
  /// In en, this message translates to:
  /// **'{distance} km • {minutes} min'**
  String safeRoute_distanceEta(String distance, int minutes);

  /// No description provided for @safeRoute_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Safe Route'**
  String get safeRoute_edit;

  /// No description provided for @safeRoute_end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get safeRoute_end;

  /// No description provided for @safeRoute_estTime.
  ///
  /// In en, this message translates to:
  /// **'Est. Time: {minutes} min'**
  String safeRoute_estTime(int minutes);

  /// No description provided for @safeRoute_featureDesc.
  ///
  /// In en, this message translates to:
  /// **'Set predefined routes for your team members. Get alerts if someone deviates from the safe route.'**
  String get safeRoute_featureDesc;

  /// No description provided for @safeRoute_groupWithCount.
  ///
  /// In en, this message translates to:
  /// **'{group} ({count, plural, =1{1 Member} other{{count} Members}})'**
  String safeRoute_groupWithCount(String group, int count);

  /// No description provided for @safeRoute_helpDeviationBody.
  ///
  /// In en, this message translates to:
  /// **'Set the allowed distance a member can move away from the selected route. You’ll get an alert if they exceed this limit.'**
  String get safeRoute_helpDeviationBody;

  /// No description provided for @safeRoute_helpDeviationTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Deviation Limit?'**
  String get safeRoute_helpDeviationTitle;

  /// No description provided for @safeRoute_helpHowBody.
  ///
  /// In en, this message translates to:
  /// **'Select the member, choose start and destination locations, pick the best route and set a deviation limit.'**
  String get safeRoute_helpHowBody;

  /// No description provided for @safeRoute_helpHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Create Safe Route?'**
  String get safeRoute_helpHowTitle;

  /// No description provided for @safeRoute_helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Route Help'**
  String get safeRoute_helpTitle;

  /// No description provided for @safeRoute_helpWhatBody.
  ///
  /// In en, this message translates to:
  /// **'Set a start and destination location to create a safe travel route for your team member.'**
  String get safeRoute_helpWhatBody;

  /// No description provided for @safeRoute_helpWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Safe Route?'**
  String get safeRoute_helpWhatTitle;

  /// No description provided for @safeRoute_memberDeviated.
  ///
  /// In en, this message translates to:
  /// **'{name} has deviated from Safe Route'**
  String safeRoute_memberDeviated(String name);

  /// No description provided for @safeRoute_recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get safeRoute_recommended;

  /// No description provided for @safeRoute_recommendedRoute.
  ///
  /// In en, this message translates to:
  /// **'{name} (Recommended)'**
  String safeRoute_recommendedRoute(String name);

  /// No description provided for @safeRoute_routeFor.
  ///
  /// In en, this message translates to:
  /// **'Route ({name})'**
  String safeRoute_routeFor(String name);

  /// No description provided for @safeRoute_saveActivate.
  ///
  /// In en, this message translates to:
  /// **'Save & Activate Safe Route'**
  String get safeRoute_saveActivate;

  /// No description provided for @safeRoute_saveActivateGroup.
  ///
  /// In en, this message translates to:
  /// **'Save & Activate Safe Route for Group'**
  String get safeRoute_saveActivateGroup;

  /// No description provided for @safeRoute_selectedRoute.
  ///
  /// In en, this message translates to:
  /// **'Selected Route'**
  String get safeRoute_selectedRoute;

  /// No description provided for @safeRoute_setRoutesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage safe routes for all group members.'**
  String get safeRoute_setRoutesSubtitle;

  /// No description provided for @safeRoute_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get safeRoute_start;

  /// No description provided for @safeRoute_startLocation.
  ///
  /// In en, this message translates to:
  /// **'Start Location'**
  String get safeRoute_startLocation;

  /// No description provided for @safeRoute_stepDeviation.
  ///
  /// In en, this message translates to:
  /// **'{step}. Set Deviation Limit'**
  String safeRoute_stepDeviation(int step);

  /// No description provided for @safeRoute_stepPreviewApply.
  ///
  /// In en, this message translates to:
  /// **'{step}. Preview & Apply'**
  String safeRoute_stepPreviewApply(int step);

  /// No description provided for @safeRoute_stepPreviewRoute.
  ///
  /// In en, this message translates to:
  /// **'{step}. Preview Route'**
  String safeRoute_stepPreviewRoute(int step);

  /// No description provided for @safeRoute_stepSelectRoute.
  ///
  /// In en, this message translates to:
  /// **'{step}. Select Route'**
  String safeRoute_stepSelectRoute(int step);

  /// No description provided for @safeRoute_stepSetRoutesForMembers.
  ///
  /// In en, this message translates to:
  /// **'{step}. Set Routes for Members'**
  String safeRoute_stepSetRoutesForMembers(int step);

  /// No description provided for @safeRoute_stepStartDest.
  ///
  /// In en, this message translates to:
  /// **'{step}. Set Start & Destination'**
  String safeRoute_stepStartDest(int step);

  /// No description provided for @safeRoute_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Route protection'**
  String get safeRoute_subtitle;

  /// No description provided for @safeRoute_title.
  ///
  /// In en, this message translates to:
  /// **'Safe Route'**
  String get safeRoute_title;

  /// No description provided for @safeZone_activeDetails.
  ///
  /// In en, this message translates to:
  /// **'Radius: {radius}  •  Center: {center}'**
  String safeZone_activeDetails(String radius, String center);

  /// No description provided for @safeZone_activePreview.
  ///
  /// In en, this message translates to:
  /// **'Active (Preview)'**
  String get safeZone_activePreview;

  /// No description provided for @safeZone_activeTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Safe Zone'**
  String get safeZone_activeTitle;

  /// No description provided for @safeZone_alertSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage safe zone, alert distance and notification preferences'**
  String get safeZone_alertSettingsDesc;

  /// No description provided for @safeZone_alertSheetDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time alerts when team members leave the safe zone'**
  String get safeZone_alertSheetDesc;

  /// No description provided for @safeZone_alertTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Zone Alert'**
  String get safeZone_alertTitle;

  /// No description provided for @safeZone_allMonitored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member will be monitored\nwithin this safe zone.} other{All {count} members will be monitored\nwithin this safe zone.}}'**
  String safeZone_allMonitored(int count);

  /// No description provided for @safeZone_appBarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define a safe area. Get alerts if someone\nsteps outside the safe zone.'**
  String get safeZone_appBarSubtitle;

  /// No description provided for @safeZone_appliedToGroup.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This safe zone will be applied to the 1 member in the selected group.} other{This safe zone will be applied to all {count} members in the selected group.}}'**
  String safeZone_appliedToGroup(int count);

  /// No description provided for @safeZone_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Safe Zone'**
  String get safeZone_edit;

  /// No description provided for @safeZone_exited.
  ///
  /// In en, this message translates to:
  /// **'Exited safe zone'**
  String get safeZone_exited;

  /// No description provided for @safeZone_featureDesc.
  ///
  /// In en, this message translates to:
  /// **'Define a safe geographic area for your team. Get instant alerts if someone steps outside the safe zone.'**
  String get safeZone_featureDesc;

  /// No description provided for @safeZone_helpHowBody.
  ///
  /// In en, this message translates to:
  /// **'Select a member, choose a location on the map and set the radius.'**
  String get safeZone_helpHowBody;

  /// No description provided for @safeZone_helpHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Create Safe Zone?'**
  String get safeZone_helpHowTitle;

  /// No description provided for @safeZone_helpRadiusBody.
  ///
  /// In en, this message translates to:
  /// **'Set the area radius (500 m, 1 km, 2 km or 5 km) according to your need.'**
  String get safeZone_helpRadiusBody;

  /// No description provided for @safeZone_helpRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Safe Zone Radius?'**
  String get safeZone_helpRadiusTitle;

  /// No description provided for @safeZone_helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Zone Help'**
  String get safeZone_helpTitle;

  /// No description provided for @safeZone_helpWhatBody.
  ///
  /// In en, this message translates to:
  /// **'Set a specific area on the map and get alerts if the member steps outside the safe zone.'**
  String get safeZone_helpWhatBody;

  /// No description provided for @safeZone_helpWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Safe Zone?'**
  String get safeZone_helpWhatTitle;

  /// No description provided for @safeZone_memberLeft.
  ///
  /// In en, this message translates to:
  /// **'{name} has left the Safe Zone'**
  String safeZone_memberLeft(String name);

  /// No description provided for @safeZone_membersMonitored.
  ///
  /// In en, this message translates to:
  /// **'Members will be monitored within this safe zone.'**
  String get safeZone_membersMonitored;

  /// No description provided for @safeZone_nearOutsideZone.
  ///
  /// In en, this message translates to:
  /// **'Near {place} (Outside {zone})'**
  String safeZone_nearOutsideZone(String place, String zone);

  /// No description provided for @safeZone_outsideZone.
  ///
  /// In en, this message translates to:
  /// **'{place} (Outside {zone})'**
  String safeZone_outsideZone(String place, String zone);

  /// No description provided for @safeZone_saveActivate.
  ///
  /// In en, this message translates to:
  /// **'Save & Activate Safe Zone'**
  String get safeZone_saveActivate;

  /// No description provided for @safeZone_saveActivateGroup.
  ///
  /// In en, this message translates to:
  /// **'Save & Activate Safe Zone for Group'**
  String get safeZone_saveActivateGroup;

  /// No description provided for @safeZone_searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search Location...'**
  String get safeZone_searchLocation;

  /// No description provided for @safeZone_statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get safeZone_statusLabel;

  /// No description provided for @safeZone_stepPreview.
  ///
  /// In en, this message translates to:
  /// **'{step}. Preview Safe Zone'**
  String safeZone_stepPreview(int step);

  /// No description provided for @safeZone_stepRadius.
  ///
  /// In en, this message translates to:
  /// **'{step}. Set Safe Zone Radius'**
  String safeZone_stepRadius(int step);

  /// No description provided for @safeZone_stepSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'{step}. Select Location on Map'**
  String safeZone_stepSelectLocation(int step);

  /// No description provided for @safeZone_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Area protection'**
  String get safeZone_subtitle;

  /// No description provided for @safeZone_title.
  ///
  /// In en, this message translates to:
  /// **'Safe Zone'**
  String get safeZone_title;

  /// No description provided for @safeZone_totalMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Total 1 Member} other{Total {count} Members}}'**
  String safeZone_totalMembers(int count);

  /// Status chip (adjective)
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get safety_active;

  /// No description provided for @safety_alertSettings.
  ///
  /// In en, this message translates to:
  /// **'Alert Settings'**
  String get safety_alertSettings;

  /// No description provided for @safety_alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get safety_alerts;

  /// No description provided for @safety_alertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Require immediate attention'**
  String get safety_alertsDesc;

  /// No description provided for @safety_bannerBody.
  ///
  /// In en, this message translates to:
  /// **'Monitor and protect your team with smart safety features.'**
  String get safety_bannerBody;

  /// No description provided for @safety_bannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Safety, Our Priority'**
  String get safety_bannerTitle;

  /// No description provided for @safety_chooseFeature.
  ///
  /// In en, this message translates to:
  /// **'Choose a Safety Feature'**
  String get safety_chooseFeature;

  /// No description provided for @safety_comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Smart safety features to protect your team are on the way.'**
  String get safety_comingSoonBody;

  /// No description provided for @safety_contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get safety_contactSupport;

  /// No description provided for @safety_editAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can edit or deactivate anytime later.'**
  String get safety_editAnytime;

  /// No description provided for @safety_mapCityPark.
  ///
  /// In en, this message translates to:
  /// **'City Park'**
  String get safety_mapCityPark;

  /// No description provided for @safety_mapMainRoad.
  ///
  /// In en, this message translates to:
  /// **'Main Road'**
  String get safety_mapMainRoad;

  /// No description provided for @safety_mapMarketLane.
  ///
  /// In en, this message translates to:
  /// **'Market Lane'**
  String get safety_mapMarketLane;

  /// No description provided for @safety_mapRiver.
  ///
  /// In en, this message translates to:
  /// **'River'**
  String get safety_mapRiver;

  /// No description provided for @safety_mapStationRoad.
  ///
  /// In en, this message translates to:
  /// **'Station Road'**
  String get safety_mapStationRoad;

  /// No description provided for @safety_needHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Contact support team for any safety related assistance.'**
  String get safety_needHelpBody;

  /// No description provided for @safety_quickOverview.
  ///
  /// In en, this message translates to:
  /// **'Quick Overview'**
  String get safety_quickOverview;

  /// No description provided for @safety_recentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent Alerts'**
  String get safety_recentAlerts;

  /// No description provided for @safety_recenter.
  ///
  /// In en, this message translates to:
  /// **'Re-center'**
  String get safety_recenter;

  /// No description provided for @safety_safeNow.
  ///
  /// In en, this message translates to:
  /// **'Safe Now'**
  String get safety_safeNow;

  /// No description provided for @safety_safeNowDesc.
  ///
  /// In en, this message translates to:
  /// **'Members are within safe zone/route'**
  String get safety_safeNowDesc;

  /// No description provided for @safety_stepSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'{step}. Select Group'**
  String safety_stepSelectGroup(int step);

  /// No description provided for @safety_stepSelectMember.
  ///
  /// In en, this message translates to:
  /// **'{step}. Select Member'**
  String safety_stepSelectMember(int step);

  /// No description provided for @safety_tabIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get safety_tabIndividual;

  /// No description provided for @safety_tagline.
  ///
  /// In en, this message translates to:
  /// **'Stay protected. Stay connected.'**
  String get safety_tagline;

  /// No description provided for @safety_title.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety_title;

  /// No description provided for @safety_viewAllMembers.
  ///
  /// In en, this message translates to:
  /// **'View All Members'**
  String get safety_viewAllMembers;

  /// No description provided for @sheet_addGroupMember.
  ///
  /// In en, this message translates to:
  /// **'Add Group Member'**
  String get sheet_addGroupMember;

  /// Badge next to a group admin's name
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get sheet_admin;

  /// No description provided for @sheet_attachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share files and media with your team'**
  String get sheet_attachSubtitle;

  /// No description provided for @sheet_attachUpload.
  ///
  /// In en, this message translates to:
  /// **'Attach / Upload'**
  String get sheet_attachUpload;

  /// No description provided for @sheet_attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get sheet_attendance;

  /// No description provided for @sheet_callOptions.
  ///
  /// In en, this message translates to:
  /// **'Call Options'**
  String get sheet_callOptions;

  /// No description provided for @sheet_cantRemoveSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t remove yourself from the group.'**
  String get sheet_cantRemoveSelf;

  /// No description provided for @sheet_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get sheet_contact;

  /// No description provided for @sheet_contactsNotOnApp.
  ///
  /// In en, this message translates to:
  /// **'Your contacts are not using FG Tracker yet.'**
  String get sheet_contactsNotOnApp;

  /// No description provided for @sheet_document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get sheet_document;

  /// No description provided for @sheet_groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get sheet_groupMembers;

  /// No description provided for @sheet_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sheet_location;

  /// No description provided for @sheet_memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed successfully'**
  String get sheet_memberRemoved;

  /// No description provided for @sheet_noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get sheet_noMembers;

  /// No description provided for @sheet_noRegisteredContacts.
  ///
  /// In en, this message translates to:
  /// **'No Registered Contacts'**
  String get sheet_noRegisteredContacts;

  /// No description provided for @sheet_noUserFound.
  ///
  /// In en, this message translates to:
  /// **'No User Found'**
  String get sheet_noUserFound;

  /// No description provided for @sheet_normalAudioCall.
  ///
  /// In en, this message translates to:
  /// **'Normal Audio Call'**
  String get sheet_normalAudioCall;

  /// No description provided for @sheet_normalAudioCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard clear voice quality'**
  String get sheet_normalAudioCallSubtitle;

  /// No description provided for @sheet_registeredContacts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Registered Contact} other{{count} Registered Contacts}}'**
  String sheet_registeredContacts(int count);

  /// No description provided for @sheet_removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from the group?'**
  String sheet_removeMemberConfirm(String name);

  /// No description provided for @sheet_removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get sheet_removeMemberTitle;

  /// No description provided for @sheet_searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get sheet_searchContacts;

  /// No description provided for @sheet_walkieCall.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie Call'**
  String get sheet_walkieCall;

  /// No description provided for @sheet_walkieCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Push-to-talk communication'**
  String get sheet_walkieCallSubtitle;

  /// No description provided for @sos_addDetailsMandatory.
  ///
  /// In en, this message translates to:
  /// **'Add Details (Mandatory)'**
  String get sos_addDetailsMandatory;

  /// No description provided for @sos_addDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Add Details (Optional)'**
  String get sos_addDetailsOptional;

  /// No description provided for @sos_addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get sos_addFamilyMember;

  /// No description provided for @sos_addFamilyMemberRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 family member to send SOS alert'**
  String get sos_addFamilyMemberRequired;

  /// No description provided for @sos_addPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Attach a photo to help others understand better.'**
  String get sos_addPhotoHint;

  /// No description provided for @sos_addPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Add Photo (Optional)'**
  String get sos_addPhotoOptional;

  /// No description provided for @sos_alertSent.
  ///
  /// In en, this message translates to:
  /// **'SOS Alert Sent!'**
  String get sos_alertSent;

  /// No description provided for @sos_alertSentToNearby.
  ///
  /// In en, this message translates to:
  /// **'Your alert has been sent to nearby people.'**
  String get sos_alertSentToNearby;

  /// No description provided for @sos_alertWillBeSent.
  ///
  /// In en, this message translates to:
  /// **'Alert will be sent to nearby people'**
  String get sos_alertWillBeSent;

  /// No description provided for @sos_alertWillBeSentFamily.
  ///
  /// In en, this message translates to:
  /// **'Your alert will be sent to nearby people and your family.'**
  String get sos_alertWillBeSentFamily;

  /// No description provided for @sos_availableUsers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Available User} other{{count} Available Users}}'**
  String sos_availableUsers(int count);

  /// No description provided for @sos_detailsHint.
  ///
  /// In en, this message translates to:
  /// **'Type any additional details...'**
  String get sos_detailsHint;

  /// No description provided for @sos_detailsMandatoryForOther.
  ///
  /// In en, this message translates to:
  /// **'Add Details is mandatory when \'Other\' reason is selected'**
  String get sos_detailsMandatoryForOther;

  /// No description provided for @sos_howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get sos_howItWorks;

  /// No description provided for @sos_howItWorksIntro.
  ///
  /// In en, this message translates to:
  /// **'SOS Alert helps you notify nearby people and your family in emergency situations.'**
  String get sos_howItWorksIntro;

  /// No description provided for @sos_howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How SOS Alert Works?'**
  String get sos_howItWorksTitle;

  /// No description provided for @sos_liveTrackingStarted.
  ///
  /// In en, this message translates to:
  /// **'Live tracking started'**
  String get sos_liveTrackingStarted;

  /// No description provided for @sos_locationSharedWithFamily.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your location is being shared with 1 family member} other{Your location is being shared with {count} family members}}'**
  String sos_locationSharedWithFamily(int count);

  /// No description provided for @sos_membersSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member selected} other{{count} members selected}}'**
  String sos_membersSelected(int count);

  /// No description provided for @sos_needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get sos_needHelp;

  /// No description provided for @sos_needHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Send an SOS alert to nearby people.\nThey will be notified and can assist you.'**
  String get sos_needHelpBody;

  /// No description provided for @sos_noMatchFound.
  ///
  /// In en, this message translates to:
  /// **'No Match Found'**
  String get sos_noMatchFound;

  /// No description provided for @sos_noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No Users Found'**
  String get sos_noUsersFound;

  /// No description provided for @sos_notifyFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify Your Family (1 to 5 required)'**
  String get sos_notifyFamilyTitle;

  /// No description provided for @sos_notifyUpdates.
  ///
  /// In en, this message translates to:
  /// **'We will notify you of any updates'**
  String get sos_notifyUpdates;

  /// No description provided for @sos_okGotIt.
  ///
  /// In en, this message translates to:
  /// **'OK, Got It'**
  String get sos_okGotIt;

  /// No description provided for @sos_peopleWithinRadius.
  ///
  /// In en, this message translates to:
  /// **'People within 2 km radius'**
  String get sos_peopleWithinRadius;

  /// No description provided for @sos_privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important. Your location is shared only during an active SOS alert.'**
  String get sos_privacyNote;

  /// No description provided for @sos_reasonAccident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get sos_reasonAccident;

  /// No description provided for @sos_reasonMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get sos_reasonMedical;

  /// No description provided for @sos_reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sos_reasonOther;

  /// No description provided for @sos_reasonSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get sos_reasonSafety;

  /// No description provided for @sos_reasonThreat.
  ///
  /// In en, this message translates to:
  /// **'Threat'**
  String get sos_reasonThreat;

  /// No description provided for @sos_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get sos_required;

  /// No description provided for @sos_searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get sos_searchUsers;

  /// No description provided for @sos_selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select Reason'**
  String get sos_selectReason;

  /// No description provided for @sos_sendSosAlert.
  ///
  /// In en, this message translates to:
  /// **'Send SOS Alert'**
  String get sos_sendSosAlert;

  /// No description provided for @sos_stayCalm.
  ///
  /// In en, this message translates to:
  /// **'Stay calm, help is on the way'**
  String get sos_stayCalm;

  /// No description provided for @sos_step1Body.
  ///
  /// In en, this message translates to:
  /// **'Tap on the SOS button and send alert to people nearby.'**
  String get sos_step1Body;

  /// No description provided for @sos_step1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Send SOS Alert'**
  String get sos_step1Title;

  /// No description provided for @sos_step2Body.
  ///
  /// In en, this message translates to:
  /// **'People nearby will receive your alert with your location.'**
  String get sos_step2Body;

  /// No description provided for @sos_step2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Notify Nearby People'**
  String get sos_step2Title;

  /// No description provided for @sos_step3Body.
  ///
  /// In en, this message translates to:
  /// **'Nearby people can view your alert and reach out to help you.'**
  String get sos_step3Body;

  /// No description provided for @sos_step3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Get Help Faster'**
  String get sos_step3Title;

  /// No description provided for @sos_step4Body.
  ///
  /// In en, this message translates to:
  /// **'Your family members will be instantly notified about your SOS.'**
  String get sos_step4Body;

  /// No description provided for @sos_step4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Family Gets Notified'**
  String get sos_step4Title;

  /// No description provided for @sos_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Send alert to nearby people'**
  String get sos_subtitle;

  /// No description provided for @sos_title.
  ///
  /// In en, this message translates to:
  /// **'SOS Alert'**
  String get sos_title;

  /// No description provided for @sos_willBeNotified.
  ///
  /// In en, this message translates to:
  /// **'will be notified'**
  String get sos_willBeNotified;

  /// Number of my active statuses
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String status_activeCount(int count);

  /// No description provided for @status_addToMyStatus.
  ///
  /// In en, this message translates to:
  /// **'Add to My Status'**
  String get status_addToMyStatus;

  /// No description provided for @status_allContacts.
  ///
  /// In en, this message translates to:
  /// **'All Contacts'**
  String get status_allContacts;

  /// No description provided for @status_cameraAccessFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to access camera'**
  String get status_cameraAccessFailed;

  /// No description provided for @status_captionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a caption...'**
  String get status_captionHint;

  /// No description provided for @status_changeMedia.
  ///
  /// In en, this message translates to:
  /// **'Change Media'**
  String get status_changeMedia;

  /// e.g. Today, 3:45 PM
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String status_dayAtTime(String day, String time);

  /// No description provided for @status_deleted.
  ///
  /// In en, this message translates to:
  /// **'Status deleted'**
  String get status_deleted;

  /// No description provided for @status_deletedByOwner.
  ///
  /// In en, this message translates to:
  /// **'This status was deleted by the owner'**
  String get status_deletedByOwner;

  /// No description provided for @status_exceptContacts.
  ///
  /// In en, this message translates to:
  /// **'Except Contacts'**
  String get status_exceptContacts;

  /// No description provided for @status_exceptSelected.
  ///
  /// In en, this message translates to:
  /// **'Except Selected'**
  String get status_exceptSelected;

  /// Switch front/back camera
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get status_flip;

  /// No description provided for @status_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get status_gallery;

  /// No description provided for @status_modePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get status_modePhoto;

  /// Text status mode
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get status_modeText;

  /// No description provided for @status_modeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get status_modeVideo;

  /// No description provided for @status_myStatus.
  ///
  /// In en, this message translates to:
  /// **'My Status'**
  String get status_myStatus;

  /// Status not seen yet
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get status_new;

  /// No description provided for @status_noCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera available'**
  String get status_noCamera;

  /// No description provided for @status_noLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This status is no longer available'**
  String get status_noLongerAvailable;

  /// No description provided for @status_noViewsYet.
  ///
  /// In en, this message translates to:
  /// **'No views yet'**
  String get status_noViewsYet;

  /// No description provided for @status_onlyShareWith.
  ///
  /// In en, this message translates to:
  /// **'Only Share With'**
  String get status_onlyShareWith;

  /// No description provided for @status_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get status_pause;

  /// No description provided for @status_pinchZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom photo'**
  String get status_pinchZoomHint;

  /// No description provided for @status_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get status_play;

  /// No description provided for @status_postStatus.
  ///
  /// In en, this message translates to:
  /// **'Post Status'**
  String get status_postStatus;

  /// No description provided for @status_previewStatus.
  ///
  /// In en, this message translates to:
  /// **'Preview Status'**
  String get status_previewStatus;

  /// No description provided for @status_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get status_privacy;

  /// No description provided for @status_privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Status Privacy'**
  String get status_privacyTitle;

  /// No description provided for @status_publishFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to publish status'**
  String get status_publishFailed;

  /// No description provided for @status_replyHint.
  ///
  /// In en, this message translates to:
  /// **'Reply to status...'**
  String get status_replyHint;

  /// No description provided for @status_retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get status_retake;

  /// No description provided for @status_selectPhotoFirst.
  ///
  /// In en, this message translates to:
  /// **'Please capture or select a photo first'**
  String get status_selectPhotoFirst;

  /// No description provided for @status_selectVideoFirst.
  ///
  /// In en, this message translates to:
  /// **'Please capture or select a video first'**
  String get status_selectVideoFirst;

  /// No description provided for @status_shareUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'Share updates with your team'**
  String get status_shareUpdatesHint;

  /// No description provided for @status_tapVideoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap video to play / pause'**
  String get status_tapVideoHint;

  /// No description provided for @status_textRequired.
  ///
  /// In en, this message translates to:
  /// **'Text content is required for text status'**
  String get status_textRequired;

  /// Status / stories feature
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status_title;

  /// No description provided for @status_typeHint.
  ///
  /// In en, this message translates to:
  /// **'Type a status...'**
  String get status_typeHint;

  /// No description provided for @status_uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get status_uploadFailed;

  /// No description provided for @status_viewMyStatus.
  ///
  /// In en, this message translates to:
  /// **'View My Status'**
  String get status_viewMyStatus;

  /// Status already seen
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get status_viewed;

  /// No description provided for @status_viewedBy.
  ///
  /// In en, this message translates to:
  /// **'Viewed by {count}'**
  String status_viewedBy(int count);

  /// No description provided for @status_viewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 View} other{{count} Views}}'**
  String status_viewsCount(int count);

  /// No description provided for @status_whoCanSee.
  ///
  /// In en, this message translates to:
  /// **'Who can see?'**
  String get status_whoCanSee;

  /// No description provided for @track_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get track_admin;

  /// No description provided for @track_applyRadius.
  ///
  /// In en, this message translates to:
  /// **'Apply Radius'**
  String get track_applyRadius;

  /// No description provided for @track_checkNetworkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again.'**
  String get track_checkNetworkConnection;

  /// No description provided for @track_checkNetworkMembers.
  ///
  /// In en, this message translates to:
  /// **'Please check your network and try again to view nearby members.'**
  String get track_checkNetworkMembers;

  /// No description provided for @track_currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get track_currentLocation;

  /// Custom radius option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get track_custom;

  /// No description provided for @track_customWithValue.
  ///
  /// In en, this message translates to:
  /// **'Custom ({radius})'**
  String track_customWithValue(String radius);

  /// distance like '1.2 km' or '350 m'
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String track_distanceAway(String distance);

  /// Button: turn GPS on
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get track_enable;

  /// No description provided for @track_enableGpsBody.
  ///
  /// In en, this message translates to:
  /// **'To track your group in real time, please turn on your GPS.'**
  String get track_enableGpsBody;

  /// No description provided for @track_enableGpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get track_enableGpsTitle;

  /// No description provided for @track_errorFailedLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Failed to load groups'**
  String get track_errorFailedLoadGroups;

  /// No description provided for @track_errorLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Unable to load groups. Please try again.'**
  String get track_errorLoadGroups;

  /// No description provided for @track_errorLoadMembers.
  ///
  /// In en, this message translates to:
  /// **'Unable to load nearby members. Please try again.'**
  String get track_errorLoadMembers;

  /// No description provided for @track_errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get track_errorNoInternet;

  /// No description provided for @track_errorServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server. Please try again.'**
  String get track_errorServer;

  /// No description provided for @track_groupCode.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String track_groupCode(String code);

  /// No description provided for @track_groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get track_groupMembers;

  /// No description provided for @track_groupMembersAndCode.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member • Code: {code}} other{{count} members • Code: {code}}}'**
  String track_groupMembersAndCode(int count, String code);

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get track_groupTab;

  /// No description provided for @track_groupsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Group} other{{count} Groups}}'**
  String track_groupsCount(int count);

  /// No description provided for @track_groupsHeader.
  ///
  /// In en, this message translates to:
  /// **'GROUPS ({count})'**
  String track_groupsHeader(int count);

  /// No description provided for @track_helpGroupBody.
  ///
  /// In en, this message translates to:
  /// **'Create a group to track multiple members.'**
  String get track_helpGroupBody;

  /// No description provided for @track_helpGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Add Group?'**
  String get track_helpGroupTitle;

  /// No description provided for @track_helpLiveBody.
  ///
  /// In en, this message translates to:
  /// **'Track team\'s real-time location on the map.'**
  String get track_helpLiveBody;

  /// No description provided for @track_helpLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Live Tracking?'**
  String get track_helpLiveTitle;

  /// No description provided for @track_helpRadiusBody.
  ///
  /// In en, this message translates to:
  /// **'Set the area to find nearby members on the map.'**
  String get track_helpRadiusBody;

  /// No description provided for @track_helpRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Tracking Radius?'**
  String get track_helpRadiusTitle;

  /// No description provided for @track_helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking Help'**
  String get track_helpTitle;

  /// No description provided for @track_lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {time}'**
  String track_lastSeen(String time);

  /// No description provided for @track_liveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Live'**
  String track_liveCount(int count);

  /// No description provided for @track_liveMembers.
  ///
  /// In en, this message translates to:
  /// **'Live Members'**
  String get track_liveMembers;

  /// No description provided for @track_liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get track_liveTracking;

  /// No description provided for @track_locating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get track_locating;

  /// No description provided for @track_locationHidden.
  ///
  /// In en, this message translates to:
  /// **'Location Hidden'**
  String get track_locationHidden;

  /// No description provided for @track_locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get track_locationUnavailable;

  /// No description provided for @track_mapOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Internet connection is required to load live map data and real-time member locations.'**
  String get track_mapOfflineBody;

  /// No description provided for @track_mapUnavailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Map Unavailable Offline'**
  String get track_mapUnavailableOffline;

  /// Fallback when a member has no name
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get track_member;

  /// No description provided for @track_memberPausedSharing.
  ///
  /// In en, this message translates to:
  /// **'{name} has paused location sharing. Live location is not available.'**
  String track_memberPausedSharing(String name);

  /// No description provided for @track_membersHeader.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS ({count})'**
  String track_membersHeader(int count);

  /// No description provided for @track_membersLive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Member Live} other{{count} Members Live}}'**
  String track_membersLive(int count);

  /// No description provided for @track_menuMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get track_menuMembers;

  /// No description provided for @track_menuRefreshMap.
  ///
  /// In en, this message translates to:
  /// **'Refresh Map'**
  String get track_menuRefreshMap;

  /// No description provided for @track_menuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get track_menuTheme;

  /// No description provided for @track_nearbyYou.
  ///
  /// In en, this message translates to:
  /// **'Nearby you'**
  String get track_nearbyYou;

  /// No description provided for @track_noActiveMembers.
  ///
  /// In en, this message translates to:
  /// **'No Active Members'**
  String get track_noActiveMembers;

  /// No description provided for @track_noActiveMembersWithin.
  ///
  /// In en, this message translates to:
  /// **'No active members found within {radius}'**
  String track_noActiveMembersWithin(String radius);

  /// No description provided for @track_noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get track_noDescription;

  /// No description provided for @track_noGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'No Groups Found'**
  String get track_noGroupsFound;

  /// No description provided for @track_noGroupsMatch.
  ///
  /// In en, this message translates to:
  /// **'No Groups Match'**
  String get track_noGroupsMatch;

  /// No description provided for @track_noGroupsMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'No groups match \'{query}\''**
  String track_noGroupsMatchQuery(String query);

  /// No description provided for @track_noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined or created any groups yet.'**
  String get track_noGroupsYet;

  /// No description provided for @track_noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get track_noInternetTitle;

  /// No description provided for @track_noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No Members Found'**
  String get track_noMembersFound;

  /// No description provided for @track_noMembersFoundPlain.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get track_noMembersFoundPlain;

  /// No description provided for @track_noMembersInGroup.
  ///
  /// In en, this message translates to:
  /// **'No members found in this group'**
  String get track_noMembersInGroup;

  /// No description provided for @track_noMembersMatch.
  ///
  /// In en, this message translates to:
  /// **'No members match \'{query}\''**
  String track_noMembersMatch(String query);

  /// No description provided for @track_noSearchMatches.
  ///
  /// In en, this message translates to:
  /// **'No members or groups matching\n\'{query}\''**
  String track_noSearchMatches(String query);

  /// No description provided for @track_noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No members or groups found for \'{query}\''**
  String track_noSearchResults(String query);

  /// Shown when a group has no code
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get track_notAvailable;

  /// No description provided for @track_offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Map & tracking are offline.'**
  String get track_offlineBanner;

  /// No description provided for @track_private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get track_private;

  /// No description provided for @track_radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get track_radius;

  /// No description provided for @track_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get track_refresh;

  /// No description provided for @track_refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get track_refreshing;

  /// No description provided for @track_retryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get track_retryConnection;

  /// No description provided for @track_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search members or groups...'**
  String get track_searchHint;

  /// No description provided for @track_searchMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Search Members...'**
  String get track_searchMembersHint;

  /// No description provided for @track_selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get track_selectedLocation;

  /// No description provided for @track_setRadiusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Slide to select area radius'**
  String get track_setRadiusSubtitle;

  /// No description provided for @track_setRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Tracking Radius'**
  String get track_setRadiusTitle;

  /// No description provided for @track_unableToLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Groups'**
  String get track_unableToLoadGroups;

  /// No description provided for @track_unableToLoadMembers.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Members'**
  String get track_unableToLoadMembers;

  /// No description provided for @track_unnamedGroup.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Group'**
  String get track_unnamedGroup;

  /// No description provided for @track_unnamedMember.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Member'**
  String get track_unnamedMember;

  /// No description provided for @track_yourGroups.
  ///
  /// In en, this message translates to:
  /// **'Your Groups'**
  String get track_yourGroups;

  /// No description provided for @track_yourLocationPaused.
  ///
  /// In en, this message translates to:
  /// **'Your live location sharing is paused and private.'**
  String get track_yourLocationPaused;

  /// No description provided for @util_previewContact.
  ///
  /// In en, this message translates to:
  /// **'👤 Contact'**
  String get util_previewContact;

  /// No description provided for @util_previewDocument.
  ///
  /// In en, this message translates to:
  /// **'📄 Document'**
  String get util_previewDocument;

  /// No description provided for @util_previewLocation.
  ///
  /// In en, this message translates to:
  /// **'📍 Location'**
  String get util_previewLocation;

  /// No description provided for @util_previewPhoto.
  ///
  /// In en, this message translates to:
  /// **'📷 Photo'**
  String get util_previewPhoto;

  /// No description provided for @util_previewVideo.
  ///
  /// In en, this message translates to:
  /// **'🎥 Video'**
  String get util_previewVideo;

  /// No description provided for @util_previewVoice.
  ///
  /// In en, this message translates to:
  /// **'🎤 Voice message'**
  String get util_previewVoice;

  /// No description provided for @util_spokenEur.
  ///
  /// In en, this message translates to:
  /// **'{amount} euros'**
  String util_spokenEur(String amount);

  /// No description provided for @util_spokenGbp.
  ///
  /// In en, this message translates to:
  /// **'{amount} pounds'**
  String util_spokenGbp(String amount);

  /// Screen-reader text for an amount in rupees
  ///
  /// In en, this message translates to:
  /// **'{rupees, plural, =1{1 rupee} other{{rupees} rupees}}'**
  String util_spokenRupees(int rupees);

  /// Screen-reader text for an amount in rupees and paise
  ///
  /// In en, this message translates to:
  /// **'{rupees} rupees {paise} paise'**
  String util_spokenRupeesPaise(int rupees, int paise);

  /// No description provided for @util_spokenUsd.
  ///
  /// In en, this message translates to:
  /// **'{amount} US dollars'**
  String util_spokenUsd(String amount);

  /// No description provided for @util_unableToCallContact.
  ///
  /// In en, this message translates to:
  /// **'Unable to call this contact'**
  String get util_unableToCallContact;

  /// No description provided for @util_unableToStartGroupCall.
  ///
  /// In en, this message translates to:
  /// **'Unable to start group call'**
  String get util_unableToStartGroupCall;

  /// No description provided for @validation_emailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email address cannot be empty'**
  String get validation_emailEmpty;

  /// No description provided for @validation_emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get validation_emailInvalid;

  /// Form error under a required field. {field} is the already-translated field label.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validation_required(String field);

  /// No description provided for @voice_appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get voice_appLanguage;

  /// No description provided for @voice_audioChip.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get voice_audioChip;

  /// No description provided for @voice_captionReady.
  ///
  /// In en, this message translates to:
  /// **'Caption ready'**
  String get voice_captionReady;

  /// No description provided for @voice_chooseSpeechLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Speech Language'**
  String get voice_chooseSpeechLanguage;

  /// No description provided for @voice_couldntPlay.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play voice message'**
  String get voice_couldntPlay;

  /// No description provided for @voice_didntCatch.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t catch that. Tap the mic and speak a little louder.'**
  String get voice_didntCatch;

  /// No description provided for @voice_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get voice_language;

  /// No description provided for @voice_listenBack.
  ///
  /// In en, this message translates to:
  /// **'Listen back'**
  String get voice_listenBack;

  /// No description provided for @voice_listenBeforeSending.
  ///
  /// In en, this message translates to:
  /// **'Listen before sending your voice message.'**
  String get voice_listenBeforeSending;

  /// No description provided for @voice_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voice_listening;

  /// No description provided for @voice_micPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed to use voice.'**
  String get voice_micPermissionNeeded;

  /// No description provided for @voice_micUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone unavailable. Please check settings.'**
  String get voice_micUnavailable;

  /// No description provided for @voice_noTextCaptured.
  ///
  /// In en, this message translates to:
  /// **'No text captured — try re-recording.'**
  String get voice_noTextCaptured;

  /// No description provided for @voice_openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get voice_openSettings;

  /// No description provided for @voice_permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get voice_permissionRequired;

  /// No description provided for @voice_reRecord.
  ///
  /// In en, this message translates to:
  /// **'Re-record'**
  String get voice_reRecord;

  /// No description provided for @voice_readyToSend.
  ///
  /// In en, this message translates to:
  /// **'Ready to send'**
  String get voice_readyToSend;

  /// No description provided for @voice_recordVoice.
  ///
  /// In en, this message translates to:
  /// **'Record Voice'**
  String get voice_recordVoice;

  /// No description provided for @voice_recordVoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record and send as an audio message'**
  String get voice_recordVoiceSubtitle;

  /// No description provided for @voice_recordingYourVoice.
  ///
  /// In en, this message translates to:
  /// **'Recording your voice…'**
  String get voice_recordingYourVoice;

  /// No description provided for @voice_replyReady.
  ///
  /// In en, this message translates to:
  /// **'Reply ready'**
  String get voice_replyReady;

  /// No description provided for @voice_reviewTextHint.
  ///
  /// In en, this message translates to:
  /// **'Listen to your voice above, or edit the text in the message box before sending.'**
  String get voice_reviewTextHint;

  /// No description provided for @voice_sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get voice_sendMessage;

  /// No description provided for @voice_sendVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Send voice message'**
  String get voice_sendVoiceMessage;

  /// No description provided for @voice_speakNowCaption.
  ///
  /// In en, this message translates to:
  /// **'Speak now – we are typing your caption'**
  String get voice_speakNowCaption;

  /// No description provided for @voice_speakNowMessage.
  ///
  /// In en, this message translates to:
  /// **'Speak now – your words appear in the message box'**
  String get voice_speakNowMessage;

  /// No description provided for @voice_speakNowReply.
  ///
  /// In en, this message translates to:
  /// **'Speak now – we are typing your reply'**
  String get voice_speakNowReply;

  /// No description provided for @voice_speakPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Speak… your text will appear here'**
  String get voice_speakPlaceholder;

  /// No description provided for @voice_speechPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition permission is needed to convert voice to text.'**
  String get voice_speechPermissionNeeded;

  /// No description provided for @voice_tapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get voice_tapToStop;

  /// No description provided for @voice_textReady.
  ///
  /// In en, this message translates to:
  /// **'Text ready'**
  String get voice_textReady;

  /// No description provided for @voice_tooMuchNoise.
  ///
  /// In en, this message translates to:
  /// **'Too much noise – hold the phone closer and speak clearly'**
  String get voice_tooMuchNoise;

  /// Label under the AUDIO chip: the kind of message (noun)
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get voice_type;

  /// No description provided for @voice_voiceToText.
  ///
  /// In en, this message translates to:
  /// **'Voice to Text'**
  String get voice_voiceToText;

  /// No description provided for @voice_voiceToTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak and type into the message box'**
  String get voice_voiceToTextSubtitle;

  /// No description provided for @voice_willSendAudioMessage.
  ///
  /// In en, this message translates to:
  /// **'Your voice will be sent as an audio message'**
  String get voice_willSendAudioMessage;

  /// No description provided for @voice_willSendAudioReply.
  ///
  /// In en, this message translates to:
  /// **'Your voice will be sent as an audio reply'**
  String get voice_willSendAudioReply;

  /// No description provided for @voice_willSendWithFile.
  ///
  /// In en, this message translates to:
  /// **'Your voice will be sent with the file as audio'**
  String get voice_willSendWithFile;

  /// No description provided for @voice_yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get voice_yourMessage;

  /// No description provided for @voice_yourVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Your voice message'**
  String get voice_yourVoiceMessage;

  /// No description provided for @walkiePlan_availableIndividualPlans.
  ///
  /// In en, this message translates to:
  /// **'Individual Plans'**
  String get walkiePlan_availableIndividualPlans;

  /// No description provided for @walkiePlan_availablePerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get walkiePlan_availablePerMonth;

  /// No description provided for @walkiePlan_availablePerSeat.
  ///
  /// In en, this message translates to:
  /// **'/ seat'**
  String get walkiePlan_availablePerSeat;

  /// No description provided for @walkiePlan_availableSingleMember.
  ///
  /// In en, this message translates to:
  /// **'Single Member (Personal Access)'**
  String get walkiePlan_availableSingleMember;

  /// No description provided for @walkiePlan_availableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a plan to start or upgrade your subscription'**
  String get walkiePlan_availableSubtitle;

  /// No description provided for @walkiePlan_availableTeamPlans.
  ///
  /// In en, this message translates to:
  /// **'Team Plans'**
  String get walkiePlan_availableTeamPlans;

  /// No description provided for @walkiePlan_availableTeamSeats.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} Seats  •  Group Collaboration'**
  String walkiePlan_availableTeamSeats(int min, int max);

  /// No description provided for @walkiePlan_availableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Plans'**
  String get walkiePlan_availableTitle;

  /// No description provided for @walkiePlan_bottomBarAfterTrial.
  ///
  /// In en, this message translates to:
  /// **'After your free trial'**
  String get walkiePlan_bottomBarAfterTrial;

  /// No description provided for @walkiePlan_bottomBarChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get walkiePlan_bottomBarChoosePlan;

  /// No description provided for @walkiePlan_bottomBarContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with Walkie Talkie'**
  String get walkiePlan_bottomBarContinue;

  /// No description provided for @walkiePlan_bottomBarPricePer.
  ///
  /// In en, this message translates to:
  /// **'{price} / {period}'**
  String walkiePlan_bottomBarPricePer(String price, String period);

  /// No description provided for @walkiePlan_bottomBarPurchaseFor.
  ///
  /// In en, this message translates to:
  /// **'Purchase for {price}'**
  String walkiePlan_bottomBarPurchaseFor(String price);

  /// Status badge of a subscription / trial
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get walkiePlan_cardActive;

  /// No description provided for @walkiePlan_cardActiveSince.
  ///
  /// In en, this message translates to:
  /// **'Active since {date}'**
  String walkiePlan_cardActiveSince(String date);

  /// Seat count label: seats assigned
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get walkiePlan_cardAssigned;

  /// No description provided for @walkiePlan_cardAssignedBy.
  ///
  /// In en, this message translates to:
  /// **'Assigned by {name}'**
  String walkiePlan_cardAssignedBy(String name);

  /// No description provided for @walkiePlan_cardAssignedToYou.
  ///
  /// In en, this message translates to:
  /// **'Assigned to You'**
  String get walkiePlan_cardAssignedToYou;

  /// Seat count label: seats still free
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get walkiePlan_cardAvailable;

  /// No description provided for @walkiePlan_cardManageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get walkiePlan_cardManageMembers;

  /// No description provided for @walkiePlan_cardNoActiveIndividual.
  ///
  /// In en, this message translates to:
  /// **'No active Individual subscription'**
  String get walkiePlan_cardNoActiveIndividual;

  /// No description provided for @walkiePlan_cardNoActiveTeam.
  ///
  /// In en, this message translates to:
  /// **'No active Team plan or assigned seat'**
  String get walkiePlan_cardNoActiveTeam;

  /// No description provided for @walkiePlan_cardOneSeatSelf.
  ///
  /// In en, this message translates to:
  /// **'1 Seat (Self)'**
  String get walkiePlan_cardOneSeatSelf;

  /// No description provided for @walkiePlan_cardPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get walkiePlan_cardPersonal;

  /// Seat count label: seats purchased
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get walkiePlan_cardPurchased;

  /// No description provided for @walkiePlan_cardPurchasedByYou.
  ///
  /// In en, this message translates to:
  /// **'Purchased by You'**
  String get walkiePlan_cardPurchasedByYou;

  /// No description provided for @walkiePlan_cardPurchasedOn.
  ///
  /// In en, this message translates to:
  /// **'Purchased On'**
  String get walkiePlan_cardPurchasedOn;

  /// No description provided for @walkiePlan_cardSeatsMembers.
  ///
  /// In en, this message translates to:
  /// **'Seats / Members'**
  String get walkiePlan_cardSeatsMembers;

  /// No description provided for @walkiePlan_cardSubscribedByYou.
  ///
  /// In en, this message translates to:
  /// **'Subscribed by You'**
  String get walkiePlan_cardSubscribedByYou;

  /// No description provided for @walkiePlan_cardTeamAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Team Administrator'**
  String get walkiePlan_cardTeamAdministrator;

  /// No description provided for @walkiePlan_cardValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get walkiePlan_cardValidUntil;

  /// No description provided for @walkiePlan_cardView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get walkiePlan_cardView;

  /// No description provided for @walkiePlan_cardViewPlan.
  ///
  /// In en, this message translates to:
  /// **'View Plan'**
  String get walkiePlan_cardViewPlan;

  /// No description provided for @walkiePlan_couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'{value} Discount'**
  String walkiePlan_couponDiscount(String value);

  /// No description provided for @walkiePlan_couponExpired.
  ///
  /// In en, this message translates to:
  /// **'Coupon has expired'**
  String get walkiePlan_couponExpired;

  /// Coupon badge, amount like ₹150
  ///
  /// In en, this message translates to:
  /// **'Flat {amount} OFF'**
  String walkiePlan_couponFlatOff(String amount);

  /// No description provided for @walkiePlan_couponMinOrderNotMet.
  ///
  /// In en, this message translates to:
  /// **'Minimum order amount not met'**
  String get walkiePlan_couponMinOrderNotMet;

  /// No description provided for @walkiePlan_couponNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Not eligible for current plan'**
  String get walkiePlan_couponNotEligible;

  /// No description provided for @walkiePlan_couponNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Coupon offer is not active yet'**
  String get walkiePlan_couponNotStarted;

  /// No description provided for @walkiePlan_couponPercentOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String walkiePlan_couponPercentOff(int percent);

  /// No description provided for @walkiePlan_couponPlanNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not applicable on this plan'**
  String get walkiePlan_couponPlanNotApplicable;

  /// No description provided for @walkiePlan_couponValidTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till {date}'**
  String walkiePlan_couponValidTill(String date);

  /// No description provided for @walkiePlan_ctrlContinueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get walkiePlan_ctrlContinueToPayment;

  /// Button; plan is the plan name (may come from the server)
  ///
  /// In en, this message translates to:
  /// **'Continue with {plan}'**
  String walkiePlan_ctrlContinueWith(String plan);

  /// No description provided for @walkiePlan_ctrlCouponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied successfully!'**
  String get walkiePlan_ctrlCouponApplied;

  /// No description provided for @walkiePlan_ctrlCouponAppliedSave.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied! You save {amount}'**
  String walkiePlan_ctrlCouponAppliedSave(String amount);

  /// No description provided for @walkiePlan_ctrlCouponFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply coupon'**
  String get walkiePlan_ctrlCouponFailed;

  /// No description provided for @walkiePlan_ctrlCouponRemoved.
  ///
  /// In en, this message translates to:
  /// **'Coupon removed'**
  String get walkiePlan_ctrlCouponRemoved;

  /// No description provided for @walkiePlan_ctrlGatewayError.
  ///
  /// In en, this message translates to:
  /// **'Cashfree error ({code})'**
  String walkiePlan_ctrlGatewayError(String code);

  /// No description provided for @walkiePlan_ctrlGatewayInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment initiation failed.'**
  String get walkiePlan_ctrlGatewayInitFailed;

  /// No description provided for @walkiePlan_ctrlGatewaySessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create payment session: {error}'**
  String walkiePlan_ctrlGatewaySessionFailed(String error);

  /// No description provided for @walkiePlan_ctrlGatewayUnableToProcess.
  ///
  /// In en, this message translates to:
  /// **'Unable to process payment: {error}'**
  String walkiePlan_ctrlGatewayUnableToProcess(String error);

  /// No description provided for @walkiePlan_ctrlLoadingPlans.
  ///
  /// In en, this message translates to:
  /// **'Loading plans...'**
  String get walkiePlan_ctrlLoadingPlans;

  /// No description provided for @walkiePlan_ctrlUnableToLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plans. Please try again.'**
  String get walkiePlan_ctrlUnableToLoadPlans;

  /// No description provided for @walkiePlan_detailsAllBanks.
  ///
  /// In en, this message translates to:
  /// **'All Indian Banks supported'**
  String get walkiePlan_detailsAllBanks;

  /// Button state: coupon has been applied
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get walkiePlan_detailsApplied;

  /// Button: apply the coupon code
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get walkiePlan_detailsApply;

  /// Small upper-case button on a coupon row
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get walkiePlan_detailsApplyCaps;

  /// No description provided for @walkiePlan_detailsAvailableCoupons.
  ///
  /// In en, this message translates to:
  /// **'Available Coupons'**
  String get walkiePlan_detailsAvailableCoupons;

  /// No description provided for @walkiePlan_detailsCard.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get walkiePlan_detailsCard;

  /// No description provided for @walkiePlan_detailsChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get walkiePlan_detailsChooseTitle;

  /// No description provided for @walkiePlan_detailsCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String walkiePlan_detailsCodeLabel(String code);

  /// No description provided for @walkiePlan_detailsCouponsOffers.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get walkiePlan_detailsCouponsOffers;

  /// No description provided for @walkiePlan_detailsEnterCouponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get walkiePlan_detailsEnterCouponHint;

  /// No description provided for @walkiePlan_detailsEnterValidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid coupon code'**
  String get walkiePlan_detailsEnterValidCoupon;

  /// No description provided for @walkiePlan_detailsFeatGroupComm.
  ///
  /// In en, this message translates to:
  /// **'Group Communication'**
  String get walkiePlan_detailsFeatGroupComm;

  /// No description provided for @walkiePlan_detailsFeatHqVoice.
  ///
  /// In en, this message translates to:
  /// **'High Quality Voice'**
  String get walkiePlan_detailsFeatHqVoice;

  /// No description provided for @walkiePlan_detailsFeatPrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get walkiePlan_detailsFeatPrioritySupport;

  /// No description provided for @walkiePlan_detailsFeatUnlimitedRange.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Range'**
  String get walkiePlan_detailsFeatUnlimitedRange;

  /// No description provided for @walkiePlan_detailsFeatUnlimitedWalkie.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Walkie Talkie'**
  String get walkiePlan_detailsFeatUnlimitedWalkie;

  /// No description provided for @walkiePlan_detailsHavePromoCode.
  ///
  /// In en, this message translates to:
  /// **'Have a Promo Code?'**
  String get walkiePlan_detailsHavePromoCode;

  /// No description provided for @walkiePlan_detailsIndividualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue using Walkie Talkie with a plan that fits your team'**
  String get walkiePlan_detailsIndividualSubtitle;

  /// Small upper-case badge: coupon is not eligible
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get walkiePlan_detailsLockedCaps;

  /// No description provided for @walkiePlan_detailsMaxMembersReached.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Maximum limit of 1 member reached} other{Maximum limit of {count} members reached}}'**
  String walkiePlan_detailsMaxMembersReached(int count);

  /// Word under the member count in the stepper when the count is not 1
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get walkiePlan_detailsMemberPlural;

  /// Word under the member count in the stepper when the count is 1
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get walkiePlan_detailsMemberSingular;

  /// No description provided for @walkiePlan_detailsMembersTimesRate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Member × {rate}} other{{count} Members × {rate}}}'**
  String walkiePlan_detailsMembersTimesRate(int count, String rate);

  /// No description provided for @walkiePlan_detailsMinTeamSize.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Minimum team size is 1 member} other{Minimum team size is {count} members}}'**
  String walkiePlan_detailsMinTeamSize(int count);

  /// No description provided for @walkiePlan_detailsMoreMembersBody.
  ///
  /// In en, this message translates to:
  /// **'Add or remove members anytime.'**
  String get walkiePlan_detailsMoreMembersBody;

  /// No description provided for @walkiePlan_detailsMoreMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'More Members?'**
  String get walkiePlan_detailsMoreMembersTitle;

  /// No description provided for @walkiePlan_detailsMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get walkiePlan_detailsMostPopular;

  /// No description provided for @walkiePlan_detailsNetBanking.
  ///
  /// In en, this message translates to:
  /// **'Net Banking'**
  String get walkiePlan_detailsNetBanking;

  /// No description provided for @walkiePlan_detailsNoCouponsBody.
  ///
  /// In en, this message translates to:
  /// **'There are no active coupons for this plan right now.'**
  String get walkiePlan_detailsNoCouponsBody;

  /// No description provided for @walkiePlan_detailsNoCouponsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Coupons Available'**
  String get walkiePlan_detailsNoCouponsTitle;

  /// No description provided for @walkiePlan_detailsNoIndividualPlans.
  ///
  /// In en, this message translates to:
  /// **'No individual walkie-talkie plans are currently available. Please check back later or retry.'**
  String get walkiePlan_detailsNoIndividualPlans;

  /// No description provided for @walkiePlan_detailsNoPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'No Plans Available'**
  String get walkiePlan_detailsNoPlansTitle;

  /// No description provided for @walkiePlan_detailsNoTeamPlans.
  ///
  /// In en, this message translates to:
  /// **'No team walkie-talkie plans are currently available. Please check back later or retry.'**
  String get walkiePlan_detailsNoTeamPlans;

  /// No description provided for @walkiePlan_detailsOriginalTotal.
  ///
  /// In en, this message translates to:
  /// **'{amount} total'**
  String walkiePlan_detailsOriginalTotal(String amount);

  /// No description provided for @walkiePlan_detailsPayActivate.
  ///
  /// In en, this message translates to:
  /// **'Pay & Activate Plan'**
  String get walkiePlan_detailsPayActivate;

  /// Suffix after a price, e.g. ₹500 / person
  ///
  /// In en, this message translates to:
  /// **'/ person'**
  String get walkiePlan_detailsPerPerson;

  /// Second line of the feature chip 'For Teams / of All Sizes'
  ///
  /// In en, this message translates to:
  /// **'of All Sizes'**
  String get walkiePlan_detailsPillAllSizes;

  /// No description provided for @walkiePlan_detailsPillCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get walkiePlan_detailsPillCommunication;

  /// First line of a feature chip 'For Teams / of All Sizes'; translations may reorder the two lines
  ///
  /// In en, this message translates to:
  /// **'For Teams'**
  String get walkiePlan_detailsPillForTeams;

  /// First line of the feature chip 'Instant / Communication'
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get walkiePlan_detailsPillInstant;

  /// First line of the feature chip 'Priority / Support'
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get walkiePlan_detailsPillPriority;

  /// First line of the feature chip 'Reliable & / Secure'
  ///
  /// In en, this message translates to:
  /// **'Reliable &'**
  String get walkiePlan_detailsPillReliable;

  /// No description provided for @walkiePlan_detailsPillSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get walkiePlan_detailsPillSecure;

  /// No description provided for @walkiePlan_detailsPillSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get walkiePlan_detailsPillSupport;

  /// First line of a feature chip; second line is 'Walkie Talkie'
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get walkiePlan_detailsPillUnlimited;

  /// No description provided for @walkiePlan_detailsPillWalkieTalkie.
  ///
  /// In en, this message translates to:
  /// **'Walkie Talkie'**
  String get walkiePlan_detailsPillWalkieTalkie;

  /// No description provided for @walkiePlan_detailsPlanActivated.
  ///
  /// In en, this message translates to:
  /// **'Plan Activated Successfully!'**
  String get walkiePlan_detailsPlanActivated;

  /// No description provided for @walkiePlan_detailsPlanActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Your Walkie Talkie plan is now active. Enjoy uninterrupted instant voice communication.'**
  String get walkiePlan_detailsPlanActiveBody;

  /// No description provided for @walkiePlan_detailsPlanSummary.
  ///
  /// In en, this message translates to:
  /// **'Plan Summary'**
  String get walkiePlan_detailsPlanSummary;

  /// No description provided for @walkiePlan_detailsPromoApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo ({code}) applied'**
  String walkiePlan_detailsPromoApplied(String code);

  /// Small upper-case button: remove the applied coupon
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get walkiePlan_detailsRemoveCaps;

  /// No description provided for @walkiePlan_detailsSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get walkiePlan_detailsSelectPaymentMethod;

  /// Placeholder text shown while coupons load (shimmer)
  ///
  /// In en, this message translates to:
  /// **'Valid on all plans • Expires soon'**
  String get walkiePlan_detailsSkeletonCouponNote;

  /// No description provided for @walkiePlan_detailsStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how many team members you want to add'**
  String get walkiePlan_detailsStep1Subtitle;

  /// No description provided for @walkiePlan_detailsStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Select Number of Members'**
  String get walkiePlan_detailsStep1Title;

  /// No description provided for @walkiePlan_detailsStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan duration that works for you'**
  String get walkiePlan_detailsStep2Subtitle;

  /// No description provided for @walkiePlan_detailsStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Select Plan Duration'**
  String get walkiePlan_detailsStep2Title;

  /// No description provided for @walkiePlan_detailsSubtitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Instant walkie talkie voice access'**
  String get walkiePlan_detailsSubtitleDefault;

  /// No description provided for @walkiePlan_detailsSubtitleGrowingTeams.
  ///
  /// In en, this message translates to:
  /// **'Great value for growing teams'**
  String get walkiePlan_detailsSubtitleGrowingTeams;

  /// No description provided for @walkiePlan_detailsSubtitleLongTerm.
  ///
  /// In en, this message translates to:
  /// **'Best for long-term use'**
  String get walkiePlan_detailsSubtitleLongTerm;

  /// No description provided for @walkiePlan_detailsSubtitleShortTerm.
  ///
  /// In en, this message translates to:
  /// **'Perfect for short-term use'**
  String get walkiePlan_detailsSubtitleShortTerm;

  /// No description provided for @walkiePlan_detailsTabIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get walkiePlan_detailsTabIndividual;

  /// No description provided for @walkiePlan_detailsTabMultipleMembers.
  ///
  /// In en, this message translates to:
  /// **'For Multiple Members'**
  String get walkiePlan_detailsTabMultipleMembers;

  /// No description provided for @walkiePlan_detailsTabPerPerson.
  ///
  /// In en, this message translates to:
  /// **'Per Person'**
  String get walkiePlan_detailsTabPerPerson;

  /// No description provided for @walkiePlan_detailsTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add team members and get everyone connected with Walkie Talkie'**
  String get walkiePlan_detailsTeamSubtitle;

  /// No description provided for @walkiePlan_detailsUpiQr.
  ///
  /// In en, this message translates to:
  /// **'UPI / QR Code'**
  String get walkiePlan_detailsUpiQr;

  /// No description provided for @walkiePlan_detailsYouSaveWithCoupon.
  ///
  /// In en, this message translates to:
  /// **'You save {amount} with this coupon!'**
  String walkiePlan_detailsYouSaveWithCoupon(String amount);

  /// No description provided for @walkiePlan_durationFallback.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get walkiePlan_durationFallback;

  /// Plan duration label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get walkiePlan_durationMonthly;

  /// No description provided for @walkiePlan_durationMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Month} other{{count} Months}}'**
  String walkiePlan_durationMonths(int count);

  /// Plan duration label (3 months)
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get walkiePlan_durationQuarterly;

  /// Plan duration label (12 months)
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get walkiePlan_durationYearly;

  /// No description provided for @walkiePlan_individualPlan.
  ///
  /// In en, this message translates to:
  /// **'Individual Plan'**
  String get walkiePlan_individualPlan;

  /// Plan name built from the billing interval sent by the server
  ///
  /// In en, this message translates to:
  /// **'{interval} Plan'**
  String walkiePlan_intervalPlan(String interval);

  /// No description provided for @walkiePlan_monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get walkiePlan_monthlyPlan;

  /// No description provided for @walkiePlan_noInternetCheckNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get walkiePlan_noInternetCheckNetwork;

  /// No description provided for @walkiePlan_order100Secure.
  ///
  /// In en, this message translates to:
  /// **'100% Secure'**
  String get walkiePlan_order100Secure;

  /// No description provided for @walkiePlan_order3ds2Secure.
  ///
  /// In en, this message translates to:
  /// **'3DS2 Secure'**
  String get walkiePlan_order3ds2Secure;

  /// Followed by the 'Terms & Conditions' link; keep the trailing space
  ///
  /// In en, this message translates to:
  /// **'By proceeding, you agree to our '**
  String get walkiePlan_orderAgreePrefix;

  /// No description provided for @walkiePlan_orderAmountAfterDiscount.
  ///
  /// In en, this message translates to:
  /// **'Amount After Discount'**
  String get walkiePlan_orderAmountAfterDiscount;

  /// No description provided for @walkiePlan_orderCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get walkiePlan_orderCards;

  /// No description provided for @walkiePlan_orderChangeMethod.
  ///
  /// In en, this message translates to:
  /// **'Change Method'**
  String get walkiePlan_orderChangeMethod;

  /// No description provided for @walkiePlan_orderCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Could not start the payment. Please try again.'**
  String get walkiePlan_orderCouldNotStart;

  /// No description provided for @walkiePlan_orderCouponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied successfully!'**
  String get walkiePlan_orderCouponApplied;

  /// No description provided for @walkiePlan_orderCouponAppliedSaved.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied! You saved {amount}'**
  String walkiePlan_orderCouponAppliedSaved(String amount);

  /// No description provided for @walkiePlan_orderCouponRemoved.
  ///
  /// In en, this message translates to:
  /// **'Coupon removed successfully'**
  String get walkiePlan_orderCouponRemoved;

  /// No description provided for @walkiePlan_orderCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create payment order. Please try again.'**
  String get walkiePlan_orderCreateFailed;

  /// No description provided for @walkiePlan_orderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get walkiePlan_orderDiscount;

  /// No description provided for @walkiePlan_orderDiscountWithCode.
  ///
  /// In en, this message translates to:
  /// **'Discount ({code})'**
  String walkiePlan_orderDiscountWithCode(String code);

  /// No description provided for @walkiePlan_orderDomesticHint.
  ///
  /// In en, this message translates to:
  /// **'Choose from GPay, PhonePe, Cards, NetBanking or Wallets on next step.'**
  String get walkiePlan_orderDomesticHint;

  /// No description provided for @walkiePlan_orderEncryptedPayment.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Payment'**
  String get walkiePlan_orderEncryptedPayment;

  /// No description provided for @walkiePlan_orderEnterValidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid coupon code'**
  String get walkiePlan_orderEnterValidCoupon;

  /// No description provided for @walkiePlan_orderForMultipleMembers.
  ///
  /// In en, this message translates to:
  /// **'For Multiple Members'**
  String get walkiePlan_orderForMultipleMembers;

  /// No description provided for @walkiePlan_orderForSingleMember.
  ///
  /// In en, this message translates to:
  /// **'For Single Member'**
  String get walkiePlan_orderForSingleMember;

  /// No description provided for @walkiePlan_orderGstTitle.
  ///
  /// In en, this message translates to:
  /// **'GST ({percent}%)'**
  String walkiePlan_orderGstTitle(String percent);

  /// No description provided for @walkiePlan_orderIntlHint.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with International Credit/Debit Cards (Visa, Mastercard, Amex).'**
  String get walkiePlan_orderIntlHint;

  /// No description provided for @walkiePlan_orderIntlHintPaypal.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with International Credit/Debit Cards (Visa, Mastercard, Amex) or PayPal.'**
  String get walkiePlan_orderIntlHintPaypal;

  /// No description provided for @walkiePlan_orderInvalidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired coupon code'**
  String get walkiePlan_orderInvalidCoupon;

  /// No description provided for @walkiePlan_orderMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Member} other{{count} Members}}'**
  String walkiePlan_orderMemberCount(int count);

  /// No description provided for @walkiePlan_orderMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get walkiePlan_orderMembersLabel;

  /// Members multiplied by price per member, e.g. 5 Members × ₹500
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Member × {rate}} other{{count} Members × {rate}}}'**
  String walkiePlan_orderMembersTimesRate(int count, String rate);

  /// No description provided for @walkiePlan_orderNetBanking.
  ///
  /// In en, this message translates to:
  /// **'NetBanking'**
  String get walkiePlan_orderNetBanking;

  /// No description provided for @walkiePlan_orderOnlineViaRazorpay.
  ///
  /// In en, this message translates to:
  /// **'Online Payment via Razorpay'**
  String get walkiePlan_orderOnlineViaRazorpay;

  /// No description provided for @walkiePlan_orderOpeningCheckout.
  ///
  /// In en, this message translates to:
  /// **'Opening Razorpay Payment Checkout...'**
  String get walkiePlan_orderOpeningCheckout;

  /// No description provided for @walkiePlan_orderPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get walkiePlan_orderPaymentDetails;

  /// No description provided for @walkiePlan_orderPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get walkiePlan_orderPaymentMethod;

  /// No description provided for @walkiePlan_orderPricePerMember.
  ///
  /// In en, this message translates to:
  /// **'Price per member'**
  String get walkiePlan_orderPricePerMember;

  /// No description provided for @walkiePlan_orderProceedToPay.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Pay • {amount}'**
  String walkiePlan_orderProceedToPay(String amount);

  /// No description provided for @walkiePlan_orderProcessingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get walkiePlan_orderProcessingPayment;

  /// No description provided for @walkiePlan_orderRetryPay.
  ///
  /// In en, this message translates to:
  /// **'Retry Pay'**
  String get walkiePlan_orderRetryPay;

  /// No description provided for @walkiePlan_orderSecureBadge.
  ///
  /// In en, this message translates to:
  /// **'SECURE'**
  String get walkiePlan_orderSecureBadge;

  /// No description provided for @walkiePlan_orderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your plan details & proceed to pay'**
  String get walkiePlan_orderSubtitle;

  /// No description provided for @walkiePlan_orderSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get walkiePlan_orderSubtotal;

  /// No description provided for @walkiePlan_orderTaxExport.
  ///
  /// In en, this message translates to:
  /// **'Tax (0% Export)'**
  String get walkiePlan_orderTaxExport;

  /// No description provided for @walkiePlan_orderTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get walkiePlan_orderTermsConditions;

  /// No description provided for @walkiePlan_orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get walkiePlan_orderTitle;

  /// No description provided for @walkiePlan_orderTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get walkiePlan_orderTotalAmount;

  /// No description provided for @walkiePlan_orderTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get walkiePlan_orderTotalPayable;

  /// No description provided for @walkiePlan_orderUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load order summary.'**
  String get walkiePlan_orderUnableToLoad;

  /// No description provided for @walkiePlan_orderUpiQr.
  ///
  /// In en, this message translates to:
  /// **'UPI / QR'**
  String get walkiePlan_orderUpiQr;

  /// No description provided for @walkiePlan_orderVatTitle.
  ///
  /// In en, this message translates to:
  /// **'VAT / Tax ({percent}%)'**
  String walkiePlan_orderVatTitle(String percent);

  /// No description provided for @walkiePlan_orderWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walkiePlan_orderWallets;

  /// No description provided for @walkiePlan_orderYouSaved.
  ///
  /// In en, this message translates to:
  /// **'You saved {amount} on this order!'**
  String walkiePlan_orderYouSaved(String amount);

  /// No description provided for @walkiePlan_payAnnualPlan.
  ///
  /// In en, this message translates to:
  /// **'Annual Plan'**
  String get walkiePlan_payAnnualPlan;

  /// No description provided for @walkiePlan_payBadgeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get walkiePlan_payBadgeCompleted;

  /// No description provided for @walkiePlan_payBadgeInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get walkiePlan_payBadgeInProgress;

  /// No description provided for @walkiePlan_payBadgePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get walkiePlan_payBadgePending;

  /// No description provided for @walkiePlan_payCancelledByUser.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled by user. No amount has been charged to your account.'**
  String get walkiePlan_payCancelledByUser;

  /// No description provided for @walkiePlan_payCouldNotBeProcessed.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be processed'**
  String get walkiePlan_payCouldNotBeProcessed;

  /// No description provided for @walkiePlan_payFailedContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get walkiePlan_payFailedContactSupport;

  /// No description provided for @walkiePlan_payFailedOn.
  ///
  /// In en, this message translates to:
  /// **'Payment failed on {time}'**
  String walkiePlan_payFailedOn(String time);

  /// No description provided for @walkiePlan_payFailedSubtitleLong.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete your payment.\nPlease try again or use a different payment method.'**
  String get walkiePlan_payFailedSubtitleLong;

  /// No description provided for @walkiePlan_payFailedSubtitleShort.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete your payment'**
  String get walkiePlan_payFailedSubtitleShort;

  /// No description provided for @walkiePlan_payFailedSupportHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help with your payment? Our team is available 24/7 to assist you.'**
  String get walkiePlan_payFailedSupportHelp;

  /// No description provided for @walkiePlan_payFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get walkiePlan_payFailedTitle;

  /// No description provided for @walkiePlan_payIndividualFeatures.
  ///
  /// In en, this message translates to:
  /// **'Real-time monitoring • Instant alerts'**
  String get walkiePlan_payIndividualFeatures;

  /// No description provided for @walkiePlan_payInitiatedOn.
  ///
  /// In en, this message translates to:
  /// **'Payment initiated on {time}'**
  String walkiePlan_payInitiatedOn(String time);

  /// Shown after a price: ₹500 / month
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get walkiePlan_payIntervalMonth;

  /// Shown after a price: ₹500 / plan
  ///
  /// In en, this message translates to:
  /// **'plan'**
  String get walkiePlan_payIntervalPlan;

  /// Shown after a price: ₹1200 / quarter
  ///
  /// In en, this message translates to:
  /// **'quarter'**
  String get walkiePlan_payIntervalQuarter;

  /// Shown after a price: ₹4000 / year
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get walkiePlan_payIntervalYear;

  /// No description provided for @walkiePlan_payMethodCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card ({network})'**
  String walkiePlan_payMethodCreditCard(String network);

  /// No description provided for @walkiePlan_payMethodDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit Card ({network})'**
  String walkiePlan_payMethodDebitCard(String network);

  /// No description provided for @walkiePlan_payMethodInternational.
  ///
  /// In en, this message translates to:
  /// **'International Card / PayPal'**
  String get walkiePlan_payMethodInternational;

  /// No description provided for @walkiePlan_payMethodNetBanking.
  ///
  /// In en, this message translates to:
  /// **'NetBanking ({bank})'**
  String walkiePlan_payMethodNetBanking(String bank);

  /// No description provided for @walkiePlan_payMethodRazorpay.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Payment'**
  String get walkiePlan_payMethodRazorpay;

  /// No description provided for @walkiePlan_payMethodRazorpayCheckout.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Checkout'**
  String get walkiePlan_payMethodRazorpayCheckout;

  /// No description provided for @walkiePlan_payMethodRazorpayUpiCard.
  ///
  /// In en, this message translates to:
  /// **'Razorpay (UPI / Card)'**
  String get walkiePlan_payMethodRazorpayUpiCard;

  /// No description provided for @walkiePlan_payMethodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI Payment'**
  String get walkiePlan_payMethodUpi;

  /// No description provided for @walkiePlan_payMethodWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet ({wallet})'**
  String walkiePlan_payMethodWallet(String wallet);

  /// No description provided for @walkiePlan_payNetworkIssue.
  ///
  /// In en, this message translates to:
  /// **'Network connection issue during payment. Please check your internet and try again.'**
  String get walkiePlan_payNetworkIssue;

  /// No description provided for @walkiePlan_payNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your payment was not completed. No amount has been charged to your account.'**
  String get walkiePlan_payNotCompleted;

  /// No description provided for @walkiePlan_payOtpCharge.
  ///
  /// In en, this message translates to:
  /// **'OTP charge'**
  String get walkiePlan_payOtpCharge;

  /// No description provided for @walkiePlan_payOtpChargeDetails.
  ///
  /// In en, this message translates to:
  /// **'OTP Charge Details'**
  String get walkiePlan_payOtpChargeDetails;

  /// No description provided for @walkiePlan_payOtpChargedPerLogin.
  ///
  /// In en, this message translates to:
  /// **'Charged per login. Resending the OTP is free'**
  String get walkiePlan_payOtpChargedPerLogin;

  /// No description provided for @walkiePlan_payOtpCharges.
  ///
  /// In en, this message translates to:
  /// **'OTP charges'**
  String get walkiePlan_payOtpCharges;

  /// No description provided for @walkiePlan_payPendingDoNotClose.
  ///
  /// In en, this message translates to:
  /// **'Please do not close the app. We will notify you once the payment is confirmed and your plan is activated.'**
  String get walkiePlan_payPendingDoNotClose;

  /// No description provided for @walkiePlan_payPendingStillInProgress.
  ///
  /// In en, this message translates to:
  /// **'Payment still in progress. We\'ll update once confirmed.'**
  String get walkiePlan_payPendingStillInProgress;

  /// No description provided for @walkiePlan_payPendingStillProcessing.
  ///
  /// In en, this message translates to:
  /// **'Payment status is still processing. Please wait.'**
  String get walkiePlan_payPendingStillProcessing;

  /// No description provided for @walkiePlan_payPendingSubtitleLong.
  ///
  /// In en, this message translates to:
  /// **'Your payment is being processed by the payment provider.\nThis may take a few minutes.'**
  String get walkiePlan_payPendingSubtitleLong;

  /// No description provided for @walkiePlan_payPendingSubtitleShort.
  ///
  /// In en, this message translates to:
  /// **'Your payment is being processed'**
  String get walkiePlan_payPendingSubtitleShort;

  /// No description provided for @walkiePlan_payPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get walkiePlan_payPendingTitle;

  /// No description provided for @walkiePlan_payPlanDetails.
  ///
  /// In en, this message translates to:
  /// **'Plan Details'**
  String get walkiePlan_payPlanDetails;

  /// No description provided for @walkiePlan_payRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get walkiePlan_payRefreshStatus;

  /// No description provided for @walkiePlan_payStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get walkiePlan_payStatusTitle;

  /// No description provided for @walkiePlan_payStepActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate Plan'**
  String get walkiePlan_payStepActivate;

  /// No description provided for @walkiePlan_payStepActivateSub.
  ///
  /// In en, this message translates to:
  /// **'Your plan will be activated automatically'**
  String get walkiePlan_payStepActivateSub;

  /// No description provided for @walkiePlan_payStepInitiated.
  ///
  /// In en, this message translates to:
  /// **'Payment Initiated'**
  String get walkiePlan_payStepInitiated;

  /// No description provided for @walkiePlan_payStepProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment'**
  String get walkiePlan_payStepProcessing;

  /// No description provided for @walkiePlan_payStepProcessingSub.
  ///
  /// In en, this message translates to:
  /// **'Your payment is being confirmed'**
  String get walkiePlan_payStepProcessingSub;

  /// No description provided for @walkiePlan_payTeamFeatures.
  ///
  /// In en, this message translates to:
  /// **'Multi-member access • Instant alerts'**
  String get walkiePlan_payTeamFeatures;

  /// No description provided for @walkiePlan_payTotalPerOtp.
  ///
  /// In en, this message translates to:
  /// **'Total per OTP'**
  String get walkiePlan_payTotalPerOtp;

  /// No description provided for @walkiePlan_payTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get walkiePlan_payTryAgain;

  /// No description provided for @walkiePlan_payViewPlanDetails.
  ///
  /// In en, this message translates to:
  /// **'View Plan Details'**
  String get walkiePlan_payViewPlanDetails;

  /// No description provided for @walkiePlan_perMember.
  ///
  /// In en, this message translates to:
  /// **'per member'**
  String get walkiePlan_perMember;

  /// Fallback name of a subscription plan
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get walkiePlan_planFallback;

  /// No description provided for @walkiePlan_quarterlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Plan'**
  String get walkiePlan_quarterlyPlan;

  /// No description provided for @walkiePlan_razorpayCompleteInWindow.
  ///
  /// In en, this message translates to:
  /// **'Please complete the transaction in the Razorpay payment window.'**
  String get walkiePlan_razorpayCompleteInWindow;

  /// No description provided for @walkiePlan_razorpayCompletePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get walkiePlan_razorpayCompletePayment;

  /// No description provided for @walkiePlan_razorpayConfirmingWithBank.
  ///
  /// In en, this message translates to:
  /// **'Payment was initiated. We are confirming with the bank.'**
  String get walkiePlan_razorpayConfirmingWithBank;

  /// No description provided for @walkiePlan_razorpayConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Razorpay...'**
  String get walkiePlan_razorpayConnecting;

  /// No description provided for @walkiePlan_razorpayCouldNotProcess.
  ///
  /// In en, this message translates to:
  /// **'The payment could not be processed. Please try again.'**
  String get walkiePlan_razorpayCouldNotProcess;

  /// No description provided for @walkiePlan_razorpayFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get walkiePlan_razorpayFailedTryAgain;

  /// No description provided for @walkiePlan_razorpayOneMonthActive.
  ///
  /// In en, this message translates to:
  /// **'1 Month Active'**
  String get walkiePlan_razorpayOneMonthActive;

  /// No description provided for @walkiePlan_razorpayPayAmountVia.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} via Razorpay'**
  String walkiePlan_razorpayPayAmountVia(String amount);

  /// No description provided for @walkiePlan_razorpayPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment Cancelled'**
  String get walkiePlan_razorpayPaymentCancelled;

  /// No description provided for @walkiePlan_razorpayPaymentIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Payment ID copied to clipboard!'**
  String get walkiePlan_razorpayPaymentIdCopied;

  /// No description provided for @walkiePlan_razorpayPciCompliant.
  ///
  /// In en, this message translates to:
  /// **'100% Safe & PCI-DSS Compliant'**
  String get walkiePlan_razorpayPciCompliant;

  /// No description provided for @walkiePlan_razorpayPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Payment is pending confirmation.'**
  String get walkiePlan_razorpayPendingConfirmation;

  /// No description provided for @walkiePlan_razorpayProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing with Razorpay...'**
  String get walkiePlan_razorpayProcessing;

  /// No description provided for @walkiePlan_razorpayReceiptAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String walkiePlan_razorpayReceiptAmount(String amount);

  /// No description provided for @walkiePlan_razorpayReceiptCopied.
  ///
  /// In en, this message translates to:
  /// **'Receipt details copied to clipboard!'**
  String get walkiePlan_razorpayReceiptCopied;

  /// No description provided for @walkiePlan_razorpayReceiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String walkiePlan_razorpayReceiptDate(String date);

  /// No description provided for @walkiePlan_razorpayReceiptMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode: {mode}'**
  String walkiePlan_razorpayReceiptMode(String mode);

  /// No description provided for @walkiePlan_razorpayReceiptOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID: {id}'**
  String walkiePlan_razorpayReceiptOrderId(String id);

  /// No description provided for @walkiePlan_razorpayReceiptPaymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID: {id}'**
  String walkiePlan_razorpayReceiptPaymentId(String id);

  /// No description provided for @walkiePlan_razorpayReceiptPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan: {plan}'**
  String walkiePlan_razorpayReceiptPlan(String plan);

  /// No description provided for @walkiePlan_razorpayReceiptStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Status: Completed'**
  String get walkiePlan_razorpayReceiptStatusCompleted;

  /// No description provided for @walkiePlan_razorpayReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'FG Tracker Payment Receipt'**
  String get walkiePlan_razorpayReceiptTitle;

  /// No description provided for @walkiePlan_razorpayRetryPayment.
  ///
  /// In en, this message translates to:
  /// **'Retry Payment'**
  String get walkiePlan_razorpayRetryPayment;

  /// No description provided for @walkiePlan_razorpaySecureCheckout.
  ///
  /// In en, this message translates to:
  /// **'Secure Checkout powered by Razorpay'**
  String get walkiePlan_razorpaySecureCheckout;

  /// No description provided for @walkiePlan_razorpaySslEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Transactions are encrypted with end-to-end 256-bit SSL security.'**
  String get walkiePlan_razorpaySslEncrypted;

  /// No description provided for @walkiePlan_razorpaySupportedModes.
  ///
  /// In en, this message translates to:
  /// **'Supported Payment Modes'**
  String get walkiePlan_razorpaySupportedModes;

  /// No description provided for @walkiePlan_razorpayTotalPayableAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Payable Amount'**
  String get walkiePlan_razorpayTotalPayableAmount;

  /// No description provided for @walkiePlan_razorpayUnableToLaunch.
  ///
  /// In en, this message translates to:
  /// **'Unable to launch payment gateway: {error}'**
  String walkiePlan_razorpayUnableToLaunch(String error);

  /// No description provided for @walkiePlan_razorpayVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment verification failed.'**
  String get walkiePlan_razorpayVerifyFailed;

  /// No description provided for @walkiePlan_seatAssignedSeat.
  ///
  /// In en, this message translates to:
  /// **'Assigned Seat'**
  String get walkiePlan_seatAssignedSeat;

  /// No description provided for @walkiePlan_seatAssignment.
  ///
  /// In en, this message translates to:
  /// **'Seat Assignment'**
  String get walkiePlan_seatAssignment;

  /// No description provided for @walkiePlan_seatTeamAccess.
  ///
  /// In en, this message translates to:
  /// **'Team Access'**
  String get walkiePlan_seatTeamAccess;

  /// No description provided for @walkiePlan_seatTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Team Member'**
  String get walkiePlan_seatTeamMember;

  /// No description provided for @walkiePlan_secureEncryptedPayment.
  ///
  /// In en, this message translates to:
  /// **'Secure & Encrypted Payment'**
  String get walkiePlan_secureEncryptedPayment;

  /// No description provided for @walkiePlan_successAccessActivated.
  ///
  /// In en, this message translates to:
  /// **'Access Activated'**
  String get walkiePlan_successAccessActivated;

  /// No description provided for @walkiePlan_successAccessActivatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your personal Walkie-Talkie access is active now.'**
  String get walkiePlan_successAccessActivatedDesc;

  /// No description provided for @walkiePlan_successAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get walkiePlan_successAmountPaid;

  /// No description provided for @walkiePlan_successAssignLaterNote.
  ///
  /// In en, this message translates to:
  /// **'You can assign Walkie access later from Team Settings anytime.'**
  String get walkiePlan_successAssignLaterNote;

  /// No description provided for @walkiePlan_successAssignMembers.
  ///
  /// In en, this message translates to:
  /// **'Assign Members'**
  String get walkiePlan_successAssignMembers;

  /// No description provided for @walkiePlan_successAssignWalkieAccess.
  ///
  /// In en, this message translates to:
  /// **'Assign Walkie Access'**
  String get walkiePlan_successAssignWalkieAccess;

  /// No description provided for @walkiePlan_successChooseMembersDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which members can use Walkie Talkie.'**
  String get walkiePlan_successChooseMembersDesc;

  /// No description provided for @walkiePlan_successContinueHome.
  ///
  /// In en, this message translates to:
  /// **'Continue to Home'**
  String get walkiePlan_successContinueHome;

  /// No description provided for @walkiePlan_successDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get walkiePlan_successDateTime;

  /// No description provided for @walkiePlan_successDefaultPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Razorpay (UPI / Card)'**
  String get walkiePlan_successDefaultPaymentMethod;

  /// No description provided for @walkiePlan_successIndividualActive.
  ///
  /// In en, this message translates to:
  /// **'Your Individual Plan is now active'**
  String get walkiePlan_successIndividualActive;

  /// No description provided for @walkiePlan_successIndividualActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your individual plan is active. Head to home and start talking.'**
  String get walkiePlan_successIndividualActiveDesc;

  /// No description provided for @walkiePlan_successIndividualLinkedNote.
  ///
  /// In en, this message translates to:
  /// **'Your individual subscription is active and linked directly to your account.'**
  String get walkiePlan_successIndividualLinkedNote;

  /// No description provided for @walkiePlan_successManageAccessNote.
  ///
  /// In en, this message translates to:
  /// **'You can manage or change Walkie access anytime from Team Settings.'**
  String get walkiePlan_successManageAccessNote;

  /// No description provided for @walkiePlan_successMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get walkiePlan_successMaybeLater;

  /// No description provided for @walkiePlan_successNoAccessUntilAssigned.
  ///
  /// In en, this message translates to:
  /// **'Your plan is active. Team members will not have Walkie access until you assign them.'**
  String get walkiePlan_successNoAccessUntilAssigned;

  /// No description provided for @walkiePlan_successNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now?'**
  String get walkiePlan_successNotNow;

  /// Badge on the receipt
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get walkiePlan_successPaid;

  /// No description provided for @walkiePlan_successPaymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get walkiePlan_successPaymentId;

  /// No description provided for @walkiePlan_successPaymentIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Payment ID copied to clipboard!'**
  String get walkiePlan_successPaymentIdCopied;

  /// No description provided for @walkiePlan_successPaymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get walkiePlan_successPaymentMode;

  /// No description provided for @walkiePlan_successPaymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get walkiePlan_successPaymentReceipt;

  /// No description provided for @walkiePlan_successPushToTalkDesc.
  ///
  /// In en, this message translates to:
  /// **'Push to talk and connect instantly with your team.'**
  String get walkiePlan_successPushToTalkDesc;

  /// No description provided for @walkiePlan_successRazorpayVerified.
  ///
  /// In en, this message translates to:
  /// **'Razorpay Verified'**
  String get walkiePlan_successRazorpayVerified;

  /// No description provided for @walkiePlan_successReceiptAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String walkiePlan_successReceiptAmount(String amount);

  /// No description provided for @walkiePlan_successReceiptCopied.
  ///
  /// In en, this message translates to:
  /// **'Receipt details copied to clipboard!'**
  String get walkiePlan_successReceiptCopied;

  /// No description provided for @walkiePlan_successReceiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String walkiePlan_successReceiptDate(String date);

  /// No description provided for @walkiePlan_successReceiptHeader.
  ///
  /// In en, this message translates to:
  /// **'FG Tracker Payment Receipt'**
  String get walkiePlan_successReceiptHeader;

  /// No description provided for @walkiePlan_successReceiptOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID: {id}'**
  String walkiePlan_successReceiptOrderId(String id);

  /// No description provided for @walkiePlan_successReceiptPaymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID: {id}'**
  String walkiePlan_successReceiptPaymentId(String id);

  /// No description provided for @walkiePlan_successReceiptPaymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode: {mode}'**
  String walkiePlan_successReceiptPaymentMode(String mode);

  /// No description provided for @walkiePlan_successReceiptPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan: {plan}'**
  String walkiePlan_successReceiptPlan(String plan);

  /// No description provided for @walkiePlan_successReceiptStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Status: Completed'**
  String get walkiePlan_successReceiptStatusCompleted;

  /// No description provided for @walkiePlan_successSelectChannel.
  ///
  /// In en, this message translates to:
  /// **'Select Channel'**
  String get walkiePlan_successSelectChannel;

  /// No description provided for @walkiePlan_successSelectChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Join any group or channel to connect with members.'**
  String get walkiePlan_successSelectChannelDesc;

  /// No description provided for @walkiePlan_successSelectMembersDesc.
  ///
  /// In en, this message translates to:
  /// **'Select team members who will use Walkie Talkie.'**
  String get walkiePlan_successSelectMembersDesc;

  /// No description provided for @walkiePlan_successSetUpTeam.
  ///
  /// In en, this message translates to:
  /// **'Set Up Team'**
  String get walkiePlan_successSetUpTeam;

  /// No description provided for @walkiePlan_successSetUpTeamDesc.
  ///
  /// In en, this message translates to:
  /// **'Invite members, manage roles and permissions.'**
  String get walkiePlan_successSetUpTeamDesc;

  /// No description provided for @walkiePlan_successShareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get walkiePlan_successShareReceipt;

  /// No description provided for @walkiePlan_successStartCommunicating.
  ///
  /// In en, this message translates to:
  /// **'Start Communicating'**
  String get walkiePlan_successStartCommunicating;

  /// No description provided for @walkiePlan_successStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get walkiePlan_successStatus;

  /// No description provided for @walkiePlan_successSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get walkiePlan_successSuccessful;

  /// No description provided for @walkiePlan_successTeamActive.
  ///
  /// In en, this message translates to:
  /// **'Your Team Plan is now active'**
  String get walkiePlan_successTeamActive;

  /// No description provided for @walkiePlan_successTeamReady.
  ///
  /// In en, this message translates to:
  /// **'Your team is ready to go!'**
  String get walkiePlan_successTeamReady;

  /// No description provided for @walkiePlan_successTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful!'**
  String get walkiePlan_successTitle;

  /// No description provided for @walkiePlan_successValidTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till {date}'**
  String walkiePlan_successValidTill(String date);

  /// No description provided for @walkiePlan_successVisitHome.
  ///
  /// In en, this message translates to:
  /// **'Visit Home Screen'**
  String get walkiePlan_successVisitHome;

  /// No description provided for @walkiePlan_successWhatsNext.
  ///
  /// In en, this message translates to:
  /// **'What\'s Next?'**
  String get walkiePlan_successWhatsNext;

  /// No description provided for @walkiePlan_teamPlan.
  ///
  /// In en, this message translates to:
  /// **'Team Plan'**
  String get walkiePlan_teamPlan;

  /// No description provided for @walkiePlan_teamPlanWithDuration.
  ///
  /// In en, this message translates to:
  /// **'Team Plan ({duration})'**
  String walkiePlan_teamPlanWithDuration(String duration);

  /// No description provided for @walkiePlan_trial7DaysPeriod.
  ///
  /// In en, this message translates to:
  /// **'7 Days Trial Period'**
  String get walkiePlan_trial7DaysPeriod;

  /// No description provided for @walkiePlan_trialActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'TRIAL ACTIVE'**
  String get walkiePlan_trialActiveLabel;

  /// No description provided for @walkiePlan_trialActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'Active Subscription'**
  String get walkiePlan_trialActiveSubscription;

  /// No description provided for @walkiePlan_trialActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get walkiePlan_trialActiveSubscriptions;

  /// No description provided for @walkiePlan_trialAvailableToStart.
  ///
  /// In en, this message translates to:
  /// **'Available to start'**
  String get walkiePlan_trialAvailableToStart;

  /// No description provided for @walkiePlan_trialCheckConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get walkiePlan_trialCheckConnectionRetry;

  /// No description provided for @walkiePlan_trialChoosePlanBelow.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan below to start using Walkie Talkie.'**
  String get walkiePlan_trialChoosePlanBelow;

  /// No description provided for @walkiePlan_trialChooseSubscription.
  ///
  /// In en, this message translates to:
  /// **'Choose a subscription to continue using Walkie Talkie.'**
  String get walkiePlan_trialChooseSubscription;

  /// No description provided for @walkiePlan_trialCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trial Completed'**
  String get walkiePlan_trialCompleted;

  /// No description provided for @walkiePlan_trialDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String walkiePlan_trialDaysLeft(int count);

  /// No description provided for @walkiePlan_trialDurationFree.
  ///
  /// In en, this message translates to:
  /// **'{duration} Free'**
  String walkiePlan_trialDurationFree(String duration);

  /// No description provided for @walkiePlan_trialEndedOn.
  ///
  /// In en, this message translates to:
  /// **'Ended on {date}'**
  String walkiePlan_trialEndedOn(String date);

  /// No description provided for @walkiePlan_trialEnjoyAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all Walkie Talkie features free for {duration}.\nNo payment required.'**
  String walkiePlan_trialEnjoyAllFeatures(String duration);

  /// No description provided for @walkiePlan_trialEnjoyDuringActive.
  ///
  /// In en, this message translates to:
  /// **'Enjoy Walkie Talkie during your active trial period.'**
  String get walkiePlan_trialEnjoyDuringActive;

  /// No description provided for @walkiePlan_trialErrAccessMissing.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie access information is missing.'**
  String get walkiePlan_trialErrAccessMissing;

  /// No description provided for @walkiePlan_trialErrFetchDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch Walkie-Talkie details.'**
  String get walkiePlan_trialErrFetchDetails;

  /// No description provided for @walkiePlan_trialErrInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response received from the server.'**
  String get walkiePlan_trialErrInvalidResponse;

  /// No description provided for @walkiePlan_trialErrNoInternetRetry.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get walkiePlan_trialErrNoInternetRetry;

  /// No description provided for @walkiePlan_trialErrOverviewMissing.
  ///
  /// In en, this message translates to:
  /// **'Walkie-Talkie overview data is missing.'**
  String get walkiePlan_trialErrOverviewMissing;

  /// No description provided for @walkiePlan_trialErrTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get walkiePlan_trialErrTimeout;

  /// No description provided for @walkiePlan_trialErrUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load Walkie-Talkie details. Please check your connection.'**
  String get walkiePlan_trialErrUnableToLoad;

  /// No description provided for @walkiePlan_trialExpired.
  ///
  /// In en, this message translates to:
  /// **'Trial Expired'**
  String get walkiePlan_trialExpired;

  /// No description provided for @walkiePlan_trialExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'TRIAL EXPIRED'**
  String get walkiePlan_trialExpiredLabel;

  /// No description provided for @walkiePlan_trialExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get walkiePlan_trialExpiringSoon;

  /// No description provided for @walkiePlan_trialFeatClearAudio.
  ///
  /// In en, this message translates to:
  /// **'Clear Audio'**
  String get walkiePlan_trialFeatClearAudio;

  /// No description provided for @walkiePlan_trialFeatClearAudioDesc.
  ///
  /// In en, this message translates to:
  /// **'High quality voice'**
  String get walkiePlan_trialFeatClearAudioDesc;

  /// No description provided for @walkiePlan_trialFeatGroupComm.
  ///
  /// In en, this message translates to:
  /// **'Group Communication'**
  String get walkiePlan_trialFeatGroupComm;

  /// No description provided for @walkiePlan_trialFeatGroupCommDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with your team'**
  String get walkiePlan_trialFeatGroupCommDesc;

  /// No description provided for @walkiePlan_trialFeatPtt.
  ///
  /// In en, this message translates to:
  /// **'Push-to-talk'**
  String get walkiePlan_trialFeatPtt;

  /// No description provided for @walkiePlan_trialFeatPttDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant voice communication'**
  String get walkiePlan_trialFeatPttDesc;

  /// No description provided for @walkiePlan_trialFeatUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Usage'**
  String get walkiePlan_trialFeatUnlimited;

  /// No description provided for @walkiePlan_trialFeatUnlimitedDesc.
  ///
  /// In en, this message translates to:
  /// **'Use without any limits'**
  String get walkiePlan_trialFeatUnlimitedDesc;

  /// No description provided for @walkiePlan_trialFreeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Available'**
  String get walkiePlan_trialFreeAvailable;

  /// Badge/label in capitals in English
  ///
  /// In en, this message translates to:
  /// **'FREE TRIAL'**
  String get walkiePlan_trialFreeTrialLabel;

  /// No description provided for @walkiePlan_trialFreeTrialRunning.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Running'**
  String get walkiePlan_trialFreeTrialRunning;

  /// No description provided for @walkiePlan_trialFullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full access to all features'**
  String get walkiePlan_trialFullAccess;

  /// No description provided for @walkiePlan_trialFullyConsumed.
  ///
  /// In en, this message translates to:
  /// **'Your free trial has been completely consumed.'**
  String get walkiePlan_trialFullyConsumed;

  /// No description provided for @walkiePlan_trialHasEnded.
  ///
  /// In en, this message translates to:
  /// **'Your Trial Has Ended'**
  String get walkiePlan_trialHasEnded;

  /// No description provided for @walkiePlan_trialHeaderInstant.
  ///
  /// In en, this message translates to:
  /// **'Instantly communicate with your group'**
  String get walkiePlan_trialHeaderInstant;

  /// No description provided for @walkiePlan_trialHeaderPlanStatus.
  ///
  /// In en, this message translates to:
  /// **'Your plan & subscription status'**
  String get walkiePlan_trialHeaderPlanStatus;

  /// No description provided for @walkiePlan_trialHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Hour} other{{count} Hours}}'**
  String walkiePlan_trialHours(int count);

  /// No description provided for @walkiePlan_trialHoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour left} other{{count} hours left}}'**
  String walkiePlan_trialHoursLeft(int count);

  /// No description provided for @walkiePlan_trialHr.
  ///
  /// In en, this message translates to:
  /// **'{count} hr'**
  String walkiePlan_trialHr(int count);

  /// No description provided for @walkiePlan_trialHrMin.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String walkiePlan_trialHrMin(int hours, int minutes);

  /// No description provided for @walkiePlan_trialIsActive.
  ///
  /// In en, this message translates to:
  /// **'Your Trial Is Active'**
  String get walkiePlan_trialIsActive;

  /// No description provided for @walkiePlan_trialMin.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String walkiePlan_trialMin(int count);

  /// No description provided for @walkiePlan_trialMinSec.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String walkiePlan_trialMinSec(int minutes, int seconds);

  /// No description provided for @walkiePlan_trialMinsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min left} other{{count} mins left}}'**
  String walkiePlan_trialMinsLeft(int count);

  /// No description provided for @walkiePlan_trialMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Minute} other{{count} Minutes}}'**
  String walkiePlan_trialMinutes(int count);

  /// No description provided for @walkiePlan_trialNoActivePlan.
  ///
  /// In en, this message translates to:
  /// **'No Active Plan'**
  String get walkiePlan_trialNoActivePlan;

  /// No description provided for @walkiePlan_trialNoCardRequired.
  ///
  /// In en, this message translates to:
  /// **'Use anytime within 7 days  •  No credit card required'**
  String get walkiePlan_trialNoCardRequired;

  /// No description provided for @walkiePlan_trialNoInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get walkiePlan_trialNoInternetTitle;

  /// No description provided for @walkiePlan_trialNoPaymentNow.
  ///
  /// In en, this message translates to:
  /// **'No payment needed now. After your trial, you can choose to continue with a paid plan ({price}/person) if you like.'**
  String walkiePlan_trialNoPaymentNow(String price);

  /// Billing period after a price, e.g. ₹999 / month
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get walkiePlan_trialPeriodMonth;

  /// No description provided for @walkiePlan_trialRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying...'**
  String get walkiePlan_trialRetrying;

  /// No description provided for @walkiePlan_trialSec.
  ///
  /// In en, this message translates to:
  /// **'{count} sec'**
  String walkiePlan_trialSec(int count);

  /// No description provided for @walkiePlan_trialStartFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start {duration} Free Trial'**
  String walkiePlan_trialStartFreeTrial(String duration);

  /// No description provided for @walkiePlan_trialStartYourFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Your Free Trial'**
  String get walkiePlan_trialStartYourFreeTrial;

  /// No description provided for @walkiePlan_trialStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get walkiePlan_trialStatusCompleted;

  /// Status chip
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get walkiePlan_trialStatusExpired;

  /// No description provided for @walkiePlan_trialSubscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Subscription Active'**
  String get walkiePlan_trialSubscriptionActive;

  /// No description provided for @walkiePlan_trialSubscriptionEndedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your Walkie Talkie subscription has ended. Renew a plan to keep talking with your team.'**
  String get walkiePlan_trialSubscriptionEndedMsg;

  /// No description provided for @walkiePlan_trialSubscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription Expired'**
  String get walkiePlan_trialSubscriptionExpired;

  /// No description provided for @walkiePlan_trialTalkFree.
  ///
  /// In en, this message translates to:
  /// **'Talk free with your group.'**
  String get walkiePlan_trialTalkFree;

  /// No description provided for @walkiePlan_trialTalkFreeTill.
  ///
  /// In en, this message translates to:
  /// **'Talk free with your group till {date}.'**
  String walkiePlan_trialTalkFreeTill(String date);

  /// No description provided for @walkiePlan_trialTeamAccessMsg.
  ///
  /// In en, this message translates to:
  /// **'You have Walkie Talkie access through your team plan.'**
  String get walkiePlan_trialTeamAccessMsg;

  /// No description provided for @walkiePlan_trialTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String walkiePlan_trialTimeLeft(String time);

  /// No description provided for @walkiePlan_trialTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Trial Time Remaining'**
  String get walkiePlan_trialTimeRemaining;

  /// No description provided for @walkiePlan_trialTimeUsedUp.
  ///
  /// In en, this message translates to:
  /// **'Trial time used up'**
  String get walkiePlan_trialTimeUsedUp;

  /// No description provided for @walkiePlan_trialTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get walkiePlan_trialTryAgain;

  /// No description provided for @walkiePlan_trialUnableToLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Walkie Talkie'**
  String get walkiePlan_trialUnableToLoadTitle;

  /// No description provided for @walkiePlan_trialUsage.
  ///
  /// In en, this message translates to:
  /// **'Trial Usage'**
  String get walkiePlan_trialUsage;

  /// No description provided for @walkiePlan_trialUseAnytime7Days.
  ///
  /// In en, this message translates to:
  /// **'Use trial anytime in 7 days'**
  String get walkiePlan_trialUseAnytime7Days;

  /// No description provided for @walkiePlan_trialUseWithin7Days.
  ///
  /// In en, this message translates to:
  /// **'Use your {duration} trial anytime within 7 days.'**
  String walkiePlan_trialUseWithin7Days(String duration);

  /// No description provided for @walkiePlan_trialUsed.
  ///
  /// In en, this message translates to:
  /// **'Trial Used'**
  String get walkiePlan_trialUsed;

  /// No description provided for @walkiePlan_trialValidityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Trial Validity Period'**
  String get walkiePlan_trialValidityPeriod;

  /// No description provided for @walkiePlan_trialWalkieTalkieTitle.
  ///
  /// In en, this message translates to:
  /// **'Walkie Talkie'**
  String get walkiePlan_trialWalkieTalkieTitle;

  /// No description provided for @walkiePlan_trialWhatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'What you can do during the trial'**
  String get walkiePlan_trialWhatYouCanDo;

  /// No description provided for @walkiePlan_unableToConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server. Please try again.'**
  String get walkiePlan_unableToConnect;

  /// No description provided for @walkiePlan_yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get walkiePlan_yearlyPlan;

  /// No description provided for @walkie_aMember.
  ///
  /// In en, this message translates to:
  /// **'A member'**
  String get walkie_aMember;

  /// No description provided for @walkie_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get walkie_accept;

  /// No description provided for @walkie_activeAccess.
  ///
  /// In en, this message translates to:
  /// **'Active Access'**
  String get walkie_activeAccess;

  /// Status badge: active / online
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get walkie_activeBadge;

  /// No description provided for @walkie_activeInWalkie.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Active in Walkie} other{{count} Active in Walkie}}'**
  String walkie_activeInWalkie(int count);

  /// No description provided for @walkie_activeMember.
  ///
  /// In en, this message translates to:
  /// **'Active Member'**
  String get walkie_activeMember;

  /// No description provided for @walkie_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get walkie_admin;

  /// No description provided for @walkie_adminMuted.
  ///
  /// In en, this message translates to:
  /// **'Admin • Muted'**
  String get walkie_adminMuted;

  /// No description provided for @walkie_adminOnlyAction.
  ///
  /// In en, this message translates to:
  /// **'Admin Only Action'**
  String get walkie_adminOnlyAction;

  /// No description provided for @walkie_adminOnlyActionMessage.
  ///
  /// In en, this message translates to:
  /// **'Only group admin can send notification alerts to members.'**
  String get walkie_adminOnlyActionMessage;

  /// No description provided for @walkie_alertSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification sent to {name}. Retry available in 10s.'**
  String walkie_alertSentMessage(String name);

  /// No description provided for @walkie_alertSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert Sent'**
  String get walkie_alertSentTitle;

  /// No description provided for @walkie_assignMembersToCommunicate.
  ///
  /// In en, this message translates to:
  /// **'Assign members to communicate in this group'**
  String get walkie_assignMembersToCommunicate;

  /// No description provided for @walkie_assignedByYou.
  ///
  /// In en, this message translates to:
  /// **'Assigned by You'**
  String get walkie_assignedByYou;

  /// No description provided for @walkie_assignedCount.
  ///
  /// In en, this message translates to:
  /// **'Assigned ({count})'**
  String walkie_assignedCount(int count);

  /// No description provided for @walkie_assignedSeats.
  ///
  /// In en, this message translates to:
  /// **'Assigned Seats'**
  String get walkie_assignedSeats;

  /// No description provided for @walkie_audioBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get walkie_audioBluetooth;

  /// No description provided for @walkie_audioHeadset.
  ///
  /// In en, this message translates to:
  /// **'Headset'**
  String get walkie_audioHeadset;

  /// No description provided for @walkie_audioOutput.
  ///
  /// In en, this message translates to:
  /// **'Audio Output'**
  String get walkie_audioOutput;

  /// Audio output: the phone earpiece
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get walkie_audioPhone;

  /// Audio output: loudspeaker
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get walkie_audioSpeaker;

  /// No description provided for @walkie_audioWiredHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Wired Headphones'**
  String get walkie_audioWiredHeadphones;

  /// No description provided for @walkie_autoUnlockIn.
  ///
  /// In en, this message translates to:
  /// **'Auto-unlock in {seconds}s'**
  String walkie_autoUnlockIn(int seconds);

  /// No description provided for @walkie_availableMembers.
  ///
  /// In en, this message translates to:
  /// **'Available Members'**
  String get walkie_availableMembers;

  /// No description provided for @walkie_canAssignUpTo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You can assign up to 1 member in this group} other{You can assign up to {count} members in this group}}'**
  String walkie_canAssignUpTo(int count);

  /// No description provided for @walkie_cannotRemoveOtherAdminSeat.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove seat assigned by another admin'**
  String get walkie_cannotRemoveOtherAdminSeat;

  /// No description provided for @walkie_cannotSpeak.
  ///
  /// In en, this message translates to:
  /// **'Cannot speak on this channel'**
  String get walkie_cannotSpeak;

  /// No description provided for @walkie_channelBusy.
  ///
  /// In en, this message translates to:
  /// **'Channel is busy'**
  String get walkie_channelBusy;

  /// No description provided for @walkie_channelLocked.
  ///
  /// In en, this message translates to:
  /// **'Channel locked'**
  String get walkie_channelLocked;

  /// No description provided for @walkie_channelSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Channel speaking...'**
  String get walkie_channelSpeaking;

  /// No description provided for @walkie_channelSwitchErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not set {group} as active speaking channel.'**
  String walkie_channelSwitchErrorMessage(String group);

  /// No description provided for @walkie_channelSwitchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Channel Switch Error'**
  String get walkie_channelSwitchErrorTitle;

  /// No description provided for @walkie_channelUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Channel unlocked'**
  String get walkie_channelUnlocked;

  /// No description provided for @walkie_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get walkie_chat;

  /// No description provided for @walkie_checkNetworkTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again.'**
  String get walkie_checkNetworkTryAgain;

  /// No description provided for @walkie_chooseAPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get walkie_chooseAPlan;

  /// No description provided for @walkie_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get walkie_connected;

  /// No description provided for @walkie_connectedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Connected to channel • Waiting for others to join'**
  String get walkie_connectedWaiting;

  /// No description provided for @walkie_connectingChannel.
  ///
  /// In en, this message translates to:
  /// **'Connecting to channel...'**
  String get walkie_connectingChannel;

  /// No description provided for @walkie_consumingTrial.
  ///
  /// In en, this message translates to:
  /// **'Consuming trial...'**
  String get walkie_consumingTrial;

  /// No description provided for @walkie_continueListenOnly.
  ///
  /// In en, this message translates to:
  /// **'Continue in Listen-Only Mode'**
  String get walkie_continueListenOnly;

  /// No description provided for @walkie_currentlyAssigned.
  ///
  /// In en, this message translates to:
  /// **'Currently Assigned ({count})'**
  String walkie_currentlyAssigned(int count);

  /// No description provided for @walkie_defaultGroupName.
  ///
  /// In en, this message translates to:
  /// **'Walkie Group'**
  String get walkie_defaultGroupName;

  /// No description provided for @walkie_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get walkie_description;

  /// No description provided for @walkie_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get walkie_disconnected;

  /// No description provided for @walkie_editAssignedMembers.
  ///
  /// In en, this message translates to:
  /// **'Edit Assigned Members'**
  String get walkie_editAssignedMembers;

  /// Button: turn on (microphone permission)
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get walkie_enable;

  /// No description provided for @walkie_errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String walkie_errorWithDetails(String details);

  /// No description provided for @walkie_exitWalkie.
  ///
  /// In en, this message translates to:
  /// **'Exit Walkie'**
  String get walkie_exitWalkie;

  /// No description provided for @walkie_exitWalkieMessage.
  ///
  /// In en, this message translates to:
  /// **'You will disconnect from this walkie channel. You will still remain a member of the group.'**
  String get walkie_exitWalkieMessage;

  /// No description provided for @walkie_exitWalkieTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Walkie?'**
  String get walkie_exitWalkieTitle;

  /// No description provided for @walkie_fairConnection.
  ///
  /// In en, this message translates to:
  /// **'Fair Connection'**
  String get walkie_fairConnection;

  /// No description provided for @walkie_fairConnectionMs.
  ///
  /// In en, this message translates to:
  /// **'Fair Connection ({ms}ms)'**
  String walkie_fairConnectionMs(int ms);

  /// No description provided for @walkie_featureAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Use on All Devices'**
  String get walkie_featureAllDevices;

  /// No description provided for @walkie_featureEasyCoordination.
  ///
  /// In en, this message translates to:
  /// **'Easy group\ncoordination'**
  String get walkie_featureEasyCoordination;

  /// No description provided for @walkie_featureHoldToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get walkie_featureHoldToTalk;

  /// No description provided for @walkie_featurePtt.
  ///
  /// In en, this message translates to:
  /// **'Push-to-talk\ncommunication'**
  String get walkie_featurePtt;

  /// No description provided for @walkie_featureQuickGroup.
  ///
  /// In en, this message translates to:
  /// **'Quick group\ncommunication'**
  String get walkie_featureQuickGroup;

  /// No description provided for @walkie_featureRealtime.
  ///
  /// In en, this message translates to:
  /// **'Real-time Connectivity'**
  String get walkie_featureRealtime;

  /// No description provided for @walkie_featureSafeReliable.
  ///
  /// In en, this message translates to:
  /// **'Safe & Reliable'**
  String get walkie_featureSafeReliable;

  /// No description provided for @walkie_featureStayConnected.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected Always'**
  String get walkie_featureStayConnected;

  /// No description provided for @walkie_featureTeamCommunication.
  ///
  /// In en, this message translates to:
  /// **'Team Communication'**
  String get walkie_featureTeamCommunication;

  /// No description provided for @walkie_featureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get walkie_featureUnlimited;

  /// No description provided for @walkie_fieldTeam.
  ///
  /// In en, this message translates to:
  /// **'Field Team'**
  String get walkie_fieldTeam;

  /// No description provided for @walkie_freeTrialEnded.
  ///
  /// In en, this message translates to:
  /// **'Free trial ended'**
  String get walkie_freeTrialEnded;

  /// No description provided for @walkie_freeTrialEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your 1 hour free trial for Walkie Talkie has ended.\nUpgrade now to continue using group communication\nwith your team.'**
  String get walkie_freeTrialEndedMessage;

  /// No description provided for @walkie_freeTrialEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Ended'**
  String get walkie_freeTrialEndedTitle;

  /// No description provided for @walkie_genericError.
  ///
  /// In en, this message translates to:
  /// **'Walkie Talkie Error'**
  String get walkie_genericError;

  /// No description provided for @walkie_getPlan.
  ///
  /// In en, this message translates to:
  /// **'Get Plan'**
  String get walkie_getPlan;

  /// No description provided for @walkie_goodConnectionMs.
  ///
  /// In en, this message translates to:
  /// **'Good Connection ({ms}ms)'**
  String walkie_goodConnectionMs(int ms);

  /// No description provided for @walkie_groupCode.
  ///
  /// In en, this message translates to:
  /// **'Group Code: {code}'**
  String walkie_groupCode(String code);

  /// No description provided for @walkie_groupCommunication.
  ///
  /// In en, this message translates to:
  /// **'Group Communication'**
  String get walkie_groupCommunication;

  /// No description provided for @walkie_groupFallback.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get walkie_groupFallback;

  /// No description provided for @walkie_groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get walkie_groupMembers;

  /// No description provided for @walkie_heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use push-to-talk voice communication with your group\nwithout making a phone call.'**
  String get walkie_heroSubtitle;

  /// No description provided for @walkie_heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected, Talk Instantly'**
  String get walkie_heroTitle;

  /// No description provided for @walkie_holdToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to Talk'**
  String get walkie_holdToTalk;

  /// No description provided for @walkie_holdToTalkSlideLock.
  ///
  /// In en, this message translates to:
  /// **'Hold to Talk, Slide Up to Lock'**
  String get walkie_holdToTalkSlideLock;

  /// No description provided for @walkie_inWalkieChannel.
  ///
  /// In en, this message translates to:
  /// **'In Walkie Channel'**
  String get walkie_inWalkieChannel;

  /// No description provided for @walkie_individualActiveUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Individual Plan active (Self access only) • Upgrade to Team Plan to assign members.'**
  String get walkie_individualActiveUpgrade;

  /// No description provided for @walkie_individualLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Individual Plan allows 1 member seat only. To assign multiple members and connect your entire team, please upgrade to a Team Plan.'**
  String get walkie_individualLimitMessage;

  /// No description provided for @walkie_individualPlan.
  ///
  /// In en, this message translates to:
  /// **'Individual Plan'**
  String get walkie_individualPlan;

  /// No description provided for @walkie_individualSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/1 (Individual)'**
  String walkie_individualSelectedCount(int count);

  /// No description provided for @walkie_individualSelfOnlyUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Individual Plan (Self Access Only) • Upgrade to Team to assign members'**
  String get walkie_individualSelfOnlyUpgrade;

  /// No description provided for @walkie_individualSubscribedSelf.
  ///
  /// In en, this message translates to:
  /// **'Individual Plan • Subscribed by Self'**
  String get walkie_individualSubscribedSelf;

  /// Button that opens group info
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get walkie_info;

  /// No description provided for @walkie_isSpeaking.
  ///
  /// In en, this message translates to:
  /// **'{name} is speaking...'**
  String walkie_isSpeaking(String name);

  /// No description provided for @walkie_isTalking.
  ///
  /// In en, this message translates to:
  /// **'{name} is talking...'**
  String walkie_isTalking(String name);

  /// No description provided for @walkie_joinedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Joined} other{{count} Joined}}'**
  String walkie_joinedCount(int count);

  /// No description provided for @walkie_lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String walkie_lastSeen(String time);

  /// No description provided for @walkie_listenOnly.
  ///
  /// In en, this message translates to:
  /// **'Listen Only'**
  String get walkie_listenOnly;

  /// No description provided for @walkie_listenOnlyTapPlan.
  ///
  /// In en, this message translates to:
  /// **'Listen Only — Tap to View Plan'**
  String get walkie_listenOnlyTapPlan;

  /// No description provided for @walkie_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get walkie_listening;

  /// No description provided for @walkie_listeningOnly.
  ///
  /// In en, this message translates to:
  /// **'Listening Only'**
  String get walkie_listeningOnly;

  /// Badge on a live walkie call; keep very short
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get walkie_live;

  /// No description provided for @walkie_lockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Lock timeout — Mic released'**
  String get walkie_lockTimeout;

  /// No description provided for @walkie_lockedTapMic.
  ///
  /// In en, this message translates to:
  /// **'Locked — Tap mic to stop'**
  String get walkie_lockedTapMic;

  /// No description provided for @walkie_maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get walkie_maybeLater;

  /// No description provided for @walkie_member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get walkie_member;

  /// No description provided for @walkie_membersInChannel.
  ///
  /// In en, this message translates to:
  /// **'Members In Channel'**
  String get walkie_membersInChannel;

  /// Shown after a separately styled number, e.g. "3 Members Online"
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Member Online} other{Members Online}}'**
  String walkie_membersOnlineLabel(int count);

  /// No description provided for @walkie_membersUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update assigned members'**
  String get walkie_membersUpdateFailed;

  /// No description provided for @walkie_membersUpdated.
  ///
  /// In en, this message translates to:
  /// **'Assigned members updated successfully'**
  String get walkie_membersUpdated;

  /// No description provided for @walkie_micAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone access required to talk.'**
  String get walkie_micAccessRequired;

  /// No description provided for @walkie_micDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is disabled in device settings. To speak in this group, please allow microphone access in Settings.\n\nYou can still listen to other members.'**
  String get walkie_micDisabledMessage;

  /// No description provided for @walkie_micPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required'**
  String get walkie_micPermissionRequired;

  /// No description provided for @walkie_micPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission'**
  String get walkie_micPermissionTitle;

  /// No description provided for @walkie_micRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to talk in this Walkie-Talkie group.\n\nYou can still listen to others without enabling microphone.'**
  String get walkie_micRequiredMessage;

  /// No description provided for @walkie_muteMe.
  ///
  /// In en, this message translates to:
  /// **'Mute Me'**
  String get walkie_muteMe;

  /// No description provided for @walkie_muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get walkie_muted;

  /// No description provided for @walkie_mutedInWalkie.
  ///
  /// In en, this message translates to:
  /// **'Muted • In Walkie'**
  String get walkie_mutedInWalkie;

  /// No description provided for @walkie_mutedListeningOnly.
  ///
  /// In en, this message translates to:
  /// **'You are muted — Listening only'**
  String get walkie_mutedListeningOnly;

  /// No description provided for @walkie_nameSpeaking.
  ///
  /// In en, this message translates to:
  /// **'{name} speaking...'**
  String walkie_nameSpeaking(String name);

  /// No description provided for @walkie_noActivePlan.
  ///
  /// In en, this message translates to:
  /// **'No Active Plan'**
  String get walkie_noActivePlan;

  /// No description provided for @walkie_noAvailableMembers.
  ///
  /// In en, this message translates to:
  /// **'No available members'**
  String get walkie_noAvailableMembers;

  /// No description provided for @walkie_noBluetoothDevice.
  ///
  /// In en, this message translates to:
  /// **'No Bluetooth audio device connected. Please pair your Bluetooth headset in settings.'**
  String get walkie_noBluetoothDevice;

  /// No description provided for @walkie_noGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get walkie_noGroupsFound;

  /// No description provided for @walkie_noMembersAssigned.
  ///
  /// In en, this message translates to:
  /// **'No members currently assigned'**
  String get walkie_noMembersAssigned;

  /// No description provided for @walkie_noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get walkie_noMembersFound;

  /// No description provided for @walkie_noMembersFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Members Found'**
  String get walkie_noMembersFoundTitle;

  /// No description provided for @walkie_noMembersMatch.
  ///
  /// In en, this message translates to:
  /// **'No Members Match'**
  String get walkie_noMembersMatch;

  /// No description provided for @walkie_noMembersMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'No members match \'{query}\''**
  String walkie_noMembersMatchQuery(String query);

  /// No description provided for @walkie_noMembersToAssign.
  ///
  /// In en, this message translates to:
  /// **'No group members available to assign.'**
  String get walkie_noMembersToAssign;

  /// No description provided for @walkie_noNameGroup.
  ///
  /// In en, this message translates to:
  /// **'No Name Group'**
  String get walkie_noNameGroup;

  /// No description provided for @walkie_noPlanSubscribeAssign.
  ///
  /// In en, this message translates to:
  /// **'No active plan • Subscribe to assign members'**
  String get walkie_noPlanSubscribeAssign;

  /// No description provided for @walkie_noSeatMessage.
  ///
  /// In en, this message translates to:
  /// **'You have an active Team Plan, but all active voice seats are currently assigned to other team members.\n\nYou can listen to group conversations in real-time, but to speak, you must assign a seat to yourself or upgrade your plan.'**
  String get walkie_noSeatMessage;

  /// No description provided for @walkie_noSeatTitle.
  ///
  /// In en, this message translates to:
  /// **'No Voice Seat Assigned'**
  String get walkie_noSeatTitle;

  /// No description provided for @walkie_noSeatsRefreshing.
  ///
  /// In en, this message translates to:
  /// **'No team seats available. Refreshing member list...'**
  String get walkie_noSeatsRefreshing;

  /// No description provided for @walkie_noSubscriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have an active Walkie Talkie subscription. Subscribe to a plan to assign members and start instant voice communication.'**
  String get walkie_noSubscriptionMessage;

  /// No description provided for @walkie_noTeamSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active team subscription found'**
  String get walkie_noTeamSubscription;

  /// No description provided for @walkie_noValidMembers.
  ///
  /// In en, this message translates to:
  /// **'No valid members selected to assign'**
  String get walkie_noValidMembers;

  /// No description provided for @walkie_noVoiceSeatListenOnly.
  ///
  /// In en, this message translates to:
  /// **'No voice seat assigned — You are in Listen-Only mode'**
  String get walkie_noVoiceSeatListenOnly;

  /// No description provided for @walkie_noWiredDevice.
  ///
  /// In en, this message translates to:
  /// **'No wired earphones or headset connected. Please plug them into your device.'**
  String get walkie_noWiredDevice;

  /// No description provided for @walkie_notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get walkie_notConnected;

  /// Notification action: leave the walkie channel
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get walkie_notifLeave;

  /// No description provided for @walkie_notifOpenWalkie.
  ///
  /// In en, this message translates to:
  /// **'Open Walkie'**
  String get walkie_notifOpenWalkie;

  /// No description provided for @walkie_notifStoppedTalking.
  ///
  /// In en, this message translates to:
  /// **'{name} stopped talking'**
  String walkie_notifStoppedTalking(String name);

  /// No description provided for @walkie_notifTalking.
  ///
  /// In en, this message translates to:
  /// **'{name} is talking'**
  String walkie_notifTalking(String name);

  /// No description provided for @walkie_notificationSettingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update notification setting for {group}. Please try again.'**
  String walkie_notificationSettingFailed(String group);

  /// No description provided for @walkie_notificationSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Setting'**
  String get walkie_notificationSettingTitle;

  /// No description provided for @walkie_onlyAdminCanAlert.
  ///
  /// In en, this message translates to:
  /// **'Only Group Admin can send alert'**
  String get walkie_onlyAdminCanAlert;

  /// No description provided for @walkie_openWalkieTalkie.
  ///
  /// In en, this message translates to:
  /// **'Open Walkie Talkie'**
  String get walkie_openWalkieTalkie;

  /// No description provided for @walkie_otherTeam.
  ///
  /// In en, this message translates to:
  /// **'Other Team'**
  String get walkie_otherTeam;

  /// No description provided for @walkie_othersWontHear.
  ///
  /// In en, this message translates to:
  /// **'Others won\'t hear you'**
  String get walkie_othersWontHear;

  /// No description provided for @walkie_planRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Walkie Talkie Plan Required'**
  String get walkie_planRequiredTitle;

  /// No description provided for @walkie_planRequiredToTalk.
  ///
  /// In en, this message translates to:
  /// **'Plan Required to Talk'**
  String get walkie_planRequiredToTalk;

  /// No description provided for @walkie_planStartsOnFirstAssign.
  ///
  /// In en, this message translates to:
  /// **'Plan starts when the first member is assigned.'**
  String get walkie_planStartsOnFirstAssign;

  /// No description provided for @walkie_poorConnection.
  ///
  /// In en, this message translates to:
  /// **'Poor network connection — Audio may lag'**
  String get walkie_poorConnection;

  /// No description provided for @walkie_preparingAudio.
  ///
  /// In en, this message translates to:
  /// **'Preparing audio...'**
  String get walkie_preparingAudio;

  /// No description provided for @walkie_purchaseTeamPlanToAssign.
  ///
  /// In en, this message translates to:
  /// **'Purchase a Team Plan to assign Walkie-Talkie access to members.'**
  String get walkie_purchaseTeamPlanToAssign;

  /// No description provided for @walkie_purchaseUpgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Purchase / Upgrade Plan'**
  String get walkie_purchaseUpgradePlan;

  /// No description provided for @walkie_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get walkie_ready;

  /// No description provided for @walkie_reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get walkie_reconnecting;

  /// No description provided for @walkie_reconnectingServer.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting to walkie server...'**
  String get walkie_reconnectingServer;

  /// No description provided for @walkie_releaseToStop.
  ///
  /// In en, this message translates to:
  /// **'Release to Stop'**
  String get walkie_releaseToStop;

  /// No description provided for @walkie_removeAll.
  ///
  /// In en, this message translates to:
  /// **'Remove All'**
  String get walkie_removeAll;

  /// No description provided for @walkie_searchGroups.
  ///
  /// In en, this message translates to:
  /// **'Search groups'**
  String get walkie_searchGroups;

  /// No description provided for @walkie_searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members...'**
  String get walkie_searchMembers;

  /// No description provided for @walkie_seatsFraction.
  ///
  /// In en, this message translates to:
  /// **'{assigned}/{total} seats'**
  String walkie_seatsFraction(int assigned, int total);

  /// No description provided for @walkie_seatsSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} Total Seats • {assigned} Assigned • {available} Available'**
  String walkie_seatsSummary(int total, int assigned, int available);

  /// No description provided for @walkie_seatsUsed.
  ///
  /// In en, this message translates to:
  /// **'{assigned} / {total} Seats Used'**
  String walkie_seatsUsed(String assigned, String total);

  /// No description provided for @walkie_secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String walkie_secondsShort(int seconds);

  /// No description provided for @walkie_selectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one member to assign'**
  String get walkie_selectAtLeastOne;

  /// No description provided for @walkie_selectGroupFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a group first'**
  String get walkie_selectGroupFirst;

  /// No description provided for @walkie_selectGroupToConnect.
  ///
  /// In en, this message translates to:
  /// **'Select a group to connect'**
  String get walkie_selectGroupToConnect;

  /// No description provided for @walkie_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get walkie_selected;

  /// No description provided for @walkie_selfAccess.
  ///
  /// In en, this message translates to:
  /// **'Self Access'**
  String get walkie_selfAccess;

  /// No description provided for @walkie_selfPlan.
  ///
  /// In en, this message translates to:
  /// **'Self Plan'**
  String get walkie_selfPlan;

  /// No description provided for @walkie_slideUpToLock.
  ///
  /// In en, this message translates to:
  /// **'Slide up to lock'**
  String get walkie_slideUpToLock;

  /// No description provided for @walkie_someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get walkie_someone;

  /// No description provided for @walkie_someoneSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Someone is speaking...'**
  String get walkie_someoneSpeaking;

  /// No description provided for @walkie_speaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking...'**
  String get walkie_speaking;

  /// No description provided for @walkie_startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start {duration} Free Trial'**
  String walkie_startFreeTrial(String duration);

  /// No description provided for @walkie_strongConnection.
  ///
  /// In en, this message translates to:
  /// **'Strong Connection'**
  String get walkie_strongConnection;

  /// No description provided for @walkie_strongConnectionMs.
  ///
  /// In en, this message translates to:
  /// **'Strong Connection ({ms}ms)'**
  String walkie_strongConnectionMs(int ms);

  /// No description provided for @walkie_subscribeToStartTalk.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to start voice talk & assign members'**
  String get walkie_subscribeToStartTalk;

  /// No description provided for @walkie_subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get walkie_subscribed;

  /// No description provided for @walkie_talking.
  ///
  /// In en, this message translates to:
  /// **'Talking...'**
  String get walkie_talking;

  /// No description provided for @walkie_tapToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap to Unlock'**
  String get walkie_tapToUnlock;

  /// No description provided for @walkie_teamAssignedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Team Plan • Assigned Elsewhere'**
  String get walkie_teamAssignedElsewhere;

  /// No description provided for @walkie_teamPlan.
  ///
  /// In en, this message translates to:
  /// **'Team Plan'**
  String get walkie_teamPlan;

  /// No description provided for @walkie_teamPlanRequired.
  ///
  /// In en, this message translates to:
  /// **'Team Plan Required'**
  String get walkie_teamPlanRequired;

  /// No description provided for @walkie_teamPlanRequiredToAssign.
  ///
  /// In en, this message translates to:
  /// **'Team Plan required to assign members'**
  String get walkie_teamPlanRequiredToAssign;

  /// No description provided for @walkie_teamPlanStatus.
  ///
  /// In en, this message translates to:
  /// **'Team Plan Status'**
  String get walkie_teamPlanStatus;

  /// No description provided for @walkie_teamSeatMember.
  ///
  /// In en, this message translates to:
  /// **'Team Seat Member'**
  String get walkie_teamSeatMember;

  /// No description provided for @walkie_title.
  ///
  /// In en, this message translates to:
  /// **'Walkie Talkie'**
  String get walkie_title;

  /// No description provided for @walkie_totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 total} other{{count} total}}'**
  String walkie_totalCount(int count);

  /// No description provided for @walkie_trialActive1hr.
  ///
  /// In en, this message translates to:
  /// **'1 hr trial active'**
  String get walkie_trialActive1hr;

  /// No description provided for @walkie_trialEndedSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Free trial ended — Please subscribe to continue'**
  String get walkie_trialEndedSubscribe;

  /// No description provided for @walkie_unableToConnectReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to channel — Reconnecting...'**
  String get walkie_unableToConnectReconnecting;

  /// No description provided for @walkie_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get walkie_unavailable;

  /// No description provided for @walkie_updateMembers.
  ///
  /// In en, this message translates to:
  /// **'Update Members ({assigned}/{total})'**
  String walkie_updateMembers(int assigned, int total);

  /// No description provided for @walkie_updatingMembers.
  ///
  /// In en, this message translates to:
  /// **'Updating Members...'**
  String get walkie_updatingMembers;

  /// No description provided for @walkie_upgradeAddSeats.
  ///
  /// In en, this message translates to:
  /// **'Upgrade & Add Seats'**
  String get walkie_upgradeAddSeats;

  /// No description provided for @walkie_upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get walkie_upgradeNow;

  /// No description provided for @walkie_upgradeTeamAssign.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Team Plan (Assign Members)'**
  String get walkie_upgradeTeamAssign;

  /// No description provided for @walkie_upgradeToTeamPlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Team Plan'**
  String get walkie_upgradeToTeamPlan;

  /// No description provided for @walkie_userCancelled.
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled'**
  String walkie_userCancelled(String name);

  /// No description provided for @walkie_userJoined.
  ///
  /// In en, this message translates to:
  /// **'{name} joined'**
  String walkie_userJoined(String name);

  /// No description provided for @walkie_userLeft.
  ///
  /// In en, this message translates to:
  /// **'{name} left'**
  String walkie_userLeft(String name);

  /// No description provided for @walkie_validTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till {date}'**
  String walkie_validTill(String date);

  /// No description provided for @walkie_viewPlan.
  ///
  /// In en, this message translates to:
  /// **'View Plan'**
  String get walkie_viewPlan;

  /// No description provided for @walkie_voiceNotPermitted.
  ///
  /// In en, this message translates to:
  /// **'Voice transmission not permitted'**
  String get walkie_voiceNotPermitted;

  /// No description provided for @walkie_weakSignal.
  ///
  /// In en, this message translates to:
  /// **'Weak Signal'**
  String get walkie_weakSignal;

  /// No description provided for @walkie_weakSignalMs.
  ///
  /// In en, this message translates to:
  /// **'Weak Signal ({ms}ms)'**
  String walkie_weakSignalMs(int ms);

  /// No description provided for @walkie_youAreConnected.
  ///
  /// In en, this message translates to:
  /// **'You are Connected'**
  String get walkie_youAreConnected;

  /// No description provided for @walkie_yourVoiceAccess.
  ///
  /// In en, this message translates to:
  /// **'Your Voice Access'**
  String get walkie_yourVoiceAccess;

  /// No description provided for @widget_inviteDownloadLinks.
  ///
  /// In en, this message translates to:
  /// **'Download for Android: {playStoreLink}\n\nDownload for iOS: {appStoreLink}'**
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink);

  /// Location sharing status chip
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get widget_live;

  /// No description provided for @widget_lostConnection.
  ///
  /// In en, this message translates to:
  /// **'Lost Connection'**
  String get widget_lostConnection;

  /// No description provided for @widget_manageGroups.
  ///
  /// In en, this message translates to:
  /// **'Manage your groups easily'**
  String get widget_manageGroups;

  /// No description provided for @widget_noInternetBody.
  ///
  /// In en, this message translates to:
  /// **'Whoops... no internet connection found. check you connection'**
  String get widget_noInternetBody;

  /// No description provided for @widget_notSeenYet.
  ///
  /// In en, this message translates to:
  /// **'Not seen yet'**
  String get widget_notSeenYet;

  /// No description provided for @widget_pinnedMessage.
  ///
  /// In en, this message translates to:
  /// **'Pinned Message'**
  String get widget_pinnedMessage;

  /// Location sharing status chip (private mode)
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get widget_private;

  /// No description provided for @widget_refreshPage.
  ///
  /// In en, this message translates to:
  /// **'Refresh the page'**
  String get widget_refreshPage;

  /// No description provided for @widget_seen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get widget_seen;

  /// No description provided for @widget_seenCount.
  ///
  /// In en, this message translates to:
  /// **'({count})'**
  String widget_seenCount(int count);

  /// No description provided for @widget_seenCountOfTotal.
  ///
  /// In en, this message translates to:
  /// **'({count} of {total})'**
  String widget_seenCountOfTotal(int count, int total);

  /// No description provided for @widget_somethingWentWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get widget_somethingWentWrongTitle;

  /// No description provided for @widget_userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get widget_userFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'en',
        'gu',
        'hi',
        'kn',
        'ml',
        'mr',
        'pa',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
