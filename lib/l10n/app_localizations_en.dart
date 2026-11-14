// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about_aboutUs => 'About Us';

  @override
  String get about_address => 'Address';

  @override
  String get about_appBarTitle => 'About FG Tracker';

  @override
  String get about_company => 'Company';

  @override
  String get about_contactUs => 'Contact Us';

  @override
  String get about_developerEmail => 'Developer Email';

  @override
  String get about_downloadTitle => '📱 Download App';

  @override
  String get about_howItWorksIntro =>
      'FG Tracker simplifies group travel coordination. Here\'s how:';

  @override
  String get about_howItWorksTitle => '⚙️ How It Works';

  @override
  String get about_howStep1 => 'Create a Group';

  @override
  String get about_howStep2 =>
      'Share the group code or QR code with your companions';

  @override
  String get about_howStep3 => 'Each member joins using the shared code or QR';

  @override
  String get about_howStep4 =>
      'Track everyone’s live location on a shared map in real-time';

  @override
  String get about_howStep5 =>
      'Use the sharing feature to invite more people effortlessly';

  @override
  String get about_intro =>
      'FG Tracker is your go-to companion for staying connected and secure while traveling in a group. Whether you\'re out on a family road trip, a picnic with friends, or just commuting with colleagues — FG Tracker makes sure no one gets left behind.';

  @override
  String get about_privacyBody =>
      'Your safety and privacy matter. FG Tracker does not share your location with anyone outside your group. All data is encrypted and only shared with the people you authorize.';

  @override
  String get about_privacyPolicy => 'Privacy Policy';

  @override
  String get about_privacyTitle => '🔐 Privacy & Security';

  @override
  String get about_supportEmail => 'Support Email';

  @override
  String get about_supportTitle => '📩 Support & Developer Info';

  @override
  String get about_termsConditions => 'Terms & Conditions';

  @override
  String get about_title => 'About';

  @override
  String get about_website => 'Website';

  @override
  String get about_welcomeTitle => 'Welcome to FG Tracker';

  @override
  String get about_whyBuiltFor =>
      'Built for families, friends, and small teams.';

  @override
  String get about_whyChooseTitle => '🌟 Why Choose FG Tracker?';

  @override
  String get about_whyEasy =>
      'Easy to use and lightweight app with privacy control.';

  @override
  String get about_whyNoCalls =>
      'No need to call or text—track live on the map.';

  @override
  String get about_whyRealTime =>
      'Real-time location sharing with all group members.';

  @override
  String appUpdate_checkError(String error) {
    return 'Error checking for update: $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => 'Do you want to Exit?';

  @override
  String get appUpdate_noUpdateAvailable => 'No Update Available';

  @override
  String get appUpdate_restartApp => 'Restart App';

  @override
  String get appUpdate_updateApp => 'Update App';

  @override
  String get appUpdate_updateAvailable => 'Update Available';

  @override
  String get appUpdate_updateAvailableMessage =>
      'A new update is available. Please update the app';

  @override
  String get appUpdate_updateUnavailable => 'Update unavailable';

  @override
  String appUpdate_updatingProgress(int progress) {
    return 'Updating... $progress%';
  }

  @override
  String get attendance_addOption => 'Add Another Option';

  @override
  String get attendance_admin => 'Admin';

  @override
  String get attendance_allowChange => 'Allow changing response';

  @override
  String get attendance_allowChangeSubtitle =>
      'Members can change or remove their response';

  @override
  String get attendance_askCommunity => 'Ask your community';

  @override
  String get attendance_cameraPermissionRequired =>
      'Camera permission is required to mark attendance.';

  @override
  String get attendance_cameraStartFailed => 'Couldn\'t start the camera.';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'Couldn\'t start the camera ($code).';
  }

  @override
  String get attendance_cameraStarting => 'Starting camera…';

  @override
  String get attendance_captureFailedBlink =>
      'Couldn\'t capture. Blink again to retry';

  @override
  String attendance_capturedAtVerified(String time) {
    return 'Captured at $time • Verified';
  }

  @override
  String get attendance_capturedCheck => 'Captured ✓';

  @override
  String get attendance_changeResponse => 'Change response';

  @override
  String get attendance_chooseFolder => 'Choose a folder, e.g. Downloads';

  @override
  String get attendance_closeAction => 'Close attendance';

  @override
  String get attendance_closeConfirmBody =>
      'Members won\'t be able to respond after it is closed.';

  @override
  String get attendance_closeConfirmTitle => 'Close attendance?';

  @override
  String get attendance_closeEndOfDay => 'Close at end of day';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return 'Automatically closes at $time today';
  }

  @override
  String get attendance_closeFailed => 'Unable to close attendance';

  @override
  String get attendance_closeFailedShort => 'Unable to close';

  @override
  String attendance_closesAt(String dateTime) {
    return 'Closes $dateTime';
  }

  @override
  String get attendance_createFailed => 'Unable to create attendance';

  @override
  String get attendance_createSubtitle =>
      'Send an attendance poll to this group';

  @override
  String get attendance_createTitle => 'Create Attendance';

  @override
  String get attendance_created => 'Attendance Created';

  @override
  String get attendance_dateEnded =>
      'The selected date has already ended. Pick another date or turn off auto-close.';

  @override
  String get attendance_dateToday => 'Date (today)';

  @override
  String get attendance_dateTodaySemantics => 'Attendance date, today';

  @override
  String get attendance_deleteFailed => 'Unable to delete attendance';

  @override
  String get attendance_deletedText => 'This attendance was deleted';

  @override
  String get attendance_downloadReport => 'Download Report';

  @override
  String get attendance_everyoneResponded => 'Everyone has responded';

  @override
  String get attendance_faceDetectedBlink =>
      'Face detected — now blink your eyes';

  @override
  String get attendance_failed => 'Attendance Failed';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return 'Not responded ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return 'Responded ($count)';
  }

  @override
  String get attendance_fixErrors =>
      'Please fix the highlighted errors before submitting';

  @override
  String get attendance_holdStill => 'Hold still…';

  @override
  String get attendance_howToTakePhoto => 'How to take your photo';

  @override
  String get attendance_invalidGroup =>
      'Invalid group. Please reopen the chat.';

  @override
  String get attendance_keepFaceInCircle => 'Keep your face inside the circle';

  @override
  String get attendance_limitReached => 'Limit Reached';

  @override
  String get attendance_loadFailed => 'Couldn\'t load attendance';

  @override
  String get attendance_loadMore => 'Load more';

  @override
  String get attendance_loadMoreFailed => 'Unable to load more';

  @override
  String get attendance_loadVotersFailed => 'Unable to load voters';

  @override
  String get attendance_lookAtCamera => 'Look at the camera';

  @override
  String get attendance_lookStraight => 'Look straight at the camera';

  @override
  String get attendance_markYourAttendance => 'Mark your attendance';

  @override
  String attendance_markedAs(String option) {
    return 'Marked as $option';
  }

  @override
  String get attendance_markedSuccess => 'Attendance marked successfully';

  @override
  String attendance_maxOptions(int count) {
    return 'You can add up to $count options only';
  }

  @override
  String get attendance_members => 'Members';

  @override
  String attendance_membersWithCount(int count) {
    return 'Members ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return 'At least $count options are required';
  }

  @override
  String get attendance_moveCloser => 'Move a little closer';

  @override
  String get attendance_multipleFaces =>
      'Multiple faces detected — only you should be in frame';

  @override
  String get attendance_noCsvApp =>
      'No app found to open CSV files. Use Save or Share instead.';

  @override
  String get attendance_noFace => 'No face detected';

  @override
  String get attendance_noFrontCamera =>
      'No front camera found on this device.';

  @override
  String get attendance_noLocation => 'No location available';

  @override
  String get attendance_noMembersMatch => 'No members match your search';

  @override
  String get attendance_noResponses => 'No responses yet';

  @override
  String get attendance_notResponded => 'Not responded';

  @override
  String get attendance_openEyes => 'Open your eyes and look at the camera';

  @override
  String get attendance_openMapFailed => 'Unable to open map';

  @override
  String get attendance_openSubtitle => 'View in Excel, Sheets or another app';

  @override
  String get attendance_optionHint => 'Enter option label';

  @override
  String get attendance_optionLabelRequired => 'All options must have a label';

  @override
  String attendance_optionNumber(int number) {
    return 'Option $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return 'Option $number • 📷 Photo required';
  }

  @override
  String get attendance_optionsUnique => 'Options must be unique';

  @override
  String get attendance_photoCaptured => 'Photo Captured';

  @override
  String get attendance_photoCapturedTapRetake =>
      'Photo captured ✓ (Tap to retake)';

  @override
  String get attendance_photoProof => 'Photo Proof';

  @override
  String attendance_photoProofOf(String name) {
    return '$name\'s Photo Proof';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ Photo required for $option';
  }

  @override
  String get attendance_photoRules =>
      'Only the front camera is used. The photo is taken automatically when you blink, and uploads from the gallery aren\'t allowed.';

  @override
  String get attendance_photoSubtitle =>
      'Take a live photo to verify your attendance';

  @override
  String get attendance_photoTitle => 'Attendance Photo';

  @override
  String get attendance_photoVerified => 'Photo verified';

  @override
  String get attendance_questionHint => 'Will you be available today?';

  @override
  String get attendance_questionLabel => 'Attendance Question';

  @override
  String get attendance_questionRequired => 'Attendance question is required';

  @override
  String attendance_questionTooShort(int count) {
    return 'Question must be at least $count characters long';
  }

  @override
  String get attendance_removeFailedShort => 'Unable to remove';

  @override
  String get attendance_removeResponseBody =>
      'Your attendance for this poll will be cleared.';

  @override
  String get attendance_removeResponseTitle => 'Remove your response?';

  @override
  String get attendance_removeVoteFailed => 'Unable to remove vote';

  @override
  String get attendance_reportEmpty => 'The report is empty';

  @override
  String get attendance_reportFailed => 'Report Failed';

  @override
  String get attendance_reportInvalid =>
      'The server returned an invalid report. Please try again.';

  @override
  String attendance_reportReady(String fileName) {
    return 'Report ready • $fileName';
  }

  @override
  String get attendance_reportSaved => 'Report Saved';

  @override
  String get attendance_reportSubject => 'Attendance Report';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return 'Attendance Report • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count responded';
  }

  @override
  String get attendance_retakePhoto => 'Retake Photo';

  @override
  String get attendance_saveInFiles => 'Save in the Files app';

  @override
  String get attendance_saveReportDialog => 'Save attendance report';

  @override
  String get attendance_saveToDevice => 'Save to device';

  @override
  String get attendance_searchMember => 'Search member';

  @override
  String get attendance_selectPhotoOption =>
      'Select an option to require a live photo for it';

  @override
  String get attendance_selectStatus => 'Please select your status';

  @override
  String get attendance_sentToAllMembers => 'Sent to all members of this group';

  @override
  String get attendance_sentToGroup => 'Attendance sent to the group';

  @override
  String get attendance_shareSubtitle => 'Send via WhatsApp, email…';

  @override
  String get attendance_statusCompleted => 'Completed';

  @override
  String get attendance_statusOpen => 'Open';

  @override
  String get attendance_stepBlink => 'Blink your eyes to capture your photo';

  @override
  String get attendance_stepEyeLevel => 'Hold your phone at eye level';

  @override
  String get attendance_submit => 'Submit Attendance';

  @override
  String get attendance_submitted => 'Attendance Submitted';

  @override
  String get attendance_title => 'Attendance';

  @override
  String get attendance_update => 'Update Attendance';

  @override
  String get attendance_validationError => 'Validation Error';

  @override
  String get attendance_view => 'View';

  @override
  String get attendance_viewTitle => 'View Attendance';

  @override
  String get attendance_voteFailed => 'Unable to record vote';

  @override
  String attendance_withinKm(String km) {
    return 'Within $km km';
  }

  @override
  String attendance_withinMeters(int count) {
    return 'Within $count m';
  }

  @override
  String get call_accept => 'Accept';

  @override
  String get call_allContacts => 'All Contacts';

  @override
  String get call_allowAccess => 'Allow Access';

  @override
  String get call_answer => 'Answer';

  @override
  String get call_audioOutput => 'Audio Output';

  @override
  String get call_callFrom => 'Call From';

  @override
  String get call_callIdNotFound => 'Call ID not found';

  @override
  String get call_callInformation => 'Call Information';

  @override
  String get call_callSummary => 'Call Summary';

  @override
  String get call_caller => 'Caller';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name and $count others',
      one: '$name and 1 other',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Couldn\'t delete $count calls. Try again.',
      one: 'Couldn\'t delete 1 call. Try again.',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count calls deleted',
      one: '1 call deleted',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'Camera';

  @override
  String get call_cameraMicRequired => 'Camera or Mic permissions are required';

  @override
  String get call_cameraOff => 'Camera off';

  @override
  String get call_cameraOn => 'Camera on';

  @override
  String get call_cameraUnavailable =>
      'Sorry, camera access is currently unavailable. Please try again later.';

  @override
  String get call_cannotReachCallServer =>
      'Unable to connect to call server. Please check your network.';

  @override
  String get call_chatFallback => 'Chat';

  @override
  String get call_closeFullScreen => 'Close full screen';

  @override
  String get call_communicationUnavailable =>
      'Communication is not available with this user';

  @override
  String get call_connectingProgress => 'Connecting…';

  @override
  String get call_connectionTimeout => 'Connection timed out';

  @override
  String get call_contactInformation => 'Contact Information';

  @override
  String get call_contactsAccessBannerMessage =>
      'Find and call your team members easily.';

  @override
  String get call_contactsAccessBannerTitle => 'Let us access your contacts';

  @override
  String get call_contactsAccessMessage =>
      'We need access to your contacts to show who is on FG Tracker and to let you call them or send an invite.';

  @override
  String get call_contactsAccessTitle => 'Allow contacts access';

  @override
  String get call_decline => 'Decline';

  @override
  String get call_deleteCallsMessage =>
      'These calls will be removed from your call history.';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count calls?',
      one: 'Delete 1 call?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage =>
      'Are you sure you want to delete this call history?';

  @override
  String get call_deleteHistoryTitle => 'Delete Call History';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Are you sure you want to delete these $count selected call history entries?',
      one: 'Are you sure you want to delete this selected call history?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => 'Delete Selected Calls';

  @override
  String call_deleteWithCount(int count) {
    return 'Delete ($count)';
  }

  @override
  String call_durHr(int hours) {
    return '$hours hr';
  }

  @override
  String call_durHrMin(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String call_durMin(int minutes) {
    return '$minutes min';
  }

  @override
  String call_durMinSec(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String call_durSec(int seconds) {
    return '$seconds sec';
  }

  @override
  String call_durShortHr(int hours) {
    return '${hours}h';
  }

  @override
  String call_durShortHrMin(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String call_durShortMin(int minutes) {
    return '${minutes}m';
  }

  @override
  String call_durShortMinSec(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String call_durShortSec(int seconds) {
    return '${seconds}s';
  }

  @override
  String get call_duration => 'Duration';

  @override
  String call_durationValue(String duration) {
    return 'Duration: $duration';
  }

  @override
  String get call_earpiece => 'Earpiece';

  @override
  String get call_endCall => 'End call';

  @override
  String get call_ended => 'Ended';

  @override
  String get call_enterNumber => 'Enter number';

  @override
  String get call_enterPhoneNumber => 'Please enter a phone number';

  @override
  String get call_entryDeleteFailed => 'Failed to delete call entry';

  @override
  String call_entryDeleteFailedError(String error) {
    return 'Failed to delete call entry: $error';
  }

  @override
  String get call_entryDeleted => 'Call entry deleted';

  @override
  String get call_everyoneInCall => 'Everyone is already in the call';

  @override
  String get call_failedTitle => 'Call Failed';

  @override
  String get call_groupBadge => 'Group';

  @override
  String get call_groupCallComingSoon => 'Group calling is coming soon';

  @override
  String get call_groupCallInitFailed => 'Unable to initialize group call';

  @override
  String get call_groupCallStartFailed =>
      'Could not start group call. Please try again.';

  @override
  String get call_groupInformation => 'Group Information';

  @override
  String call_groupWithId(String id) {
    return 'Group $id';
  }

  @override
  String get call_headphones => 'Headphones';

  @override
  String call_historyCancelled(String callType) {
    return 'Cancelled $callType';
  }

  @override
  String get call_historyClearFailed => 'Failed to clear call history';

  @override
  String call_historyClearFailedError(String error) {
    return 'Failed to clear call history: $error';
  }

  @override
  String get call_historyCleared => 'All call history cleared';

  @override
  String call_historyIncoming(String callType) {
    return 'Incoming $callType';
  }

  @override
  String call_historyMissed(String callType) {
    return 'Missed $callType';
  }

  @override
  String call_historyOutgoing(String callType) {
    return 'Outgoing $callType';
  }

  @override
  String call_historyRejected(String callType) {
    return 'Rejected $callType';
  }

  @override
  String get call_inCall => 'In call';

  @override
  String call_inCallWithGroup(String groupName) {
    return 'In call · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return 'In this call ($count)';
  }

  @override
  String get call_incomingAudio => 'Incoming audio call';

  @override
  String get call_incomingCallChannelName => 'Incoming Call';

  @override
  String get call_incomingGroupAudio => 'Incoming group audio call';

  @override
  String get call_incomingGroupVideo => 'Incoming group video call';

  @override
  String get call_incomingVideo => 'Incoming video call';

  @override
  String get call_infoDescription => 'Description';

  @override
  String get call_infoEmail => 'Email';

  @override
  String get call_infoGroupCode => 'Group Code';

  @override
  String get call_infoGroupName => 'Group Name';

  @override
  String get call_infoMobile => 'Mobile';

  @override
  String get call_infoTotalMembers => 'Total Members';

  @override
  String get call_invite => 'Invite';

  @override
  String get call_inviteToApp => 'Invite to FG Tracker';

  @override
  String get call_join => 'Join';

  @override
  String get call_joinOnAnswer => 'You will join as soon as you answer';

  @override
  String get call_kindAudio => 'Audio Call';

  @override
  String get call_kindCall => 'Call';

  @override
  String get call_kindGroupAudio => 'Group Audio Call';

  @override
  String get call_kindGroupCall => 'Group Call';

  @override
  String call_kindGroupOther(String kind) {
    return 'Group $kind Call';
  }

  @override
  String get call_kindGroupVideo => 'Group Video Call';

  @override
  String call_kindOther(String kind) {
    return '$kind Call';
  }

  @override
  String get call_kindVideo => 'Video Call';

  @override
  String get call_loadDetailFailed => 'Failed to load call detail';

  @override
  String get call_loadMore => 'Load more';

  @override
  String get call_loadRecentFailed => 'Failed to load recent calls';

  @override
  String get call_loginToCall => 'Please login to make a call';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members in this call',
      one: '1 member in this call',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'Message';

  @override
  String get call_micActive => 'Microphone is active';

  @override
  String get call_missedCall => 'Missed Call';

  @override
  String get call_missedCallChannelName => 'Missed Call';

  @override
  String get call_missedCallNotification => 'Missed call';

  @override
  String get call_more => 'More';

  @override
  String get call_mute => 'Mute';

  @override
  String get call_muted => 'Muted';

  @override
  String call_nameYou(String name) {
    return '$name (You)';
  }

  @override
  String get call_noActiveParticipants => 'No active participants';

  @override
  String get call_noContactsMatch => 'No contacts match your search';

  @override
  String get call_noGroupsFound => 'No groups found';

  @override
  String get call_noGroupsYet => 'No groups yet';

  @override
  String get call_noNameGroup => 'Unnamed group';

  @override
  String get call_noRecentCalls => 'No recent calls';

  @override
  String get call_noRecentMatch => 'No recent calls match your search';

  @override
  String get call_noRecentYet => 'No recent calls yet';

  @override
  String get call_noRegisteredContacts => 'No registered contacts found';

  @override
  String get call_notInContacts => 'This number is not in your contacts';

  @override
  String call_notInThisCall(int count) {
    return 'Not in this call ($count)';
  }

  @override
  String get call_notReady => 'Call not ready';

  @override
  String get call_notificationPermissionRationale =>
      'Needed to show incoming calls.';

  @override
  String get call_notificationPermissionSettings =>
      'Enable notifications in Settings.';

  @override
  String get call_notificationPermissionTitle => 'Notification permission';

  @override
  String get call_notify => 'Notify';

  @override
  String get call_notifyFailed => 'Notify failed';

  @override
  String get call_notifySent => 'Notified successfully';

  @override
  String get call_ongoingChannelDescription =>
      'Keeps the call and screen sharing alive';

  @override
  String get call_ongoingChannelName => 'Ongoing call';

  @override
  String get call_otherAlreadySharing =>
      'The other person is already sharing the screen';

  @override
  String get call_otherStartingVideo => 'The other person is starting video';

  @override
  String get call_participant => 'Participant';

  @override
  String get call_participants => 'Participants';

  @override
  String call_personIsSharing(String name) {
    return '$name is sharing';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name is sharing the screen';
  }

  @override
  String get call_phone => 'Phone';

  @override
  String get call_pleaseWait => 'Please wait';

  @override
  String get call_recentCalls => 'Recent Calls';

  @override
  String get call_resetZoom => 'Reset zoom';

  @override
  String get call_returnToCall => 'Return to Call';

  @override
  String get call_screenBeingShared => 'Screen is being shared';

  @override
  String get call_screenShareChannelDescription =>
      'Active screen sharing session notification';

  @override
  String get call_screenShareChannelName => 'Screen Sharing Service';

  @override
  String get call_screenSharePermissionDenied =>
      'Screen sharing permission denied';

  @override
  String get call_screenShareStartFailed => 'Could not start screen sharing';

  @override
  String get call_screenShareStopped => 'Screen sharing stopped';

  @override
  String get call_screenSharingTitle => 'Screen sharing';

  @override
  String call_screenVisibleToName(String name) {
    return 'Your screen is visible to $name';
  }

  @override
  String get call_screenVisibleToOther =>
      'Your screen is visible to the other person';

  @override
  String get call_searchHint => 'Search contacts or groups';

  @override
  String get call_sectionLastWeek => 'Last Week';

  @override
  String get call_sectionOlder => 'Older';

  @override
  String get call_sectionThisWeek => 'This Week';

  @override
  String get call_selectAll => 'Select all';

  @override
  String call_selectedCount(int count) {
    return '$count Selected';
  }

  @override
  String get call_selectedDeleteFailed => 'Failed to delete selected calls';

  @override
  String call_selectedDeleteFailedError(String error) {
    return 'Failed to delete selected calls: $error';
  }

  @override
  String get call_selectedDeleted => 'Selected calls deleted';

  @override
  String get call_selfCallWarning => 'You cannot call your own number.';

  @override
  String get call_sessionConnectFailed =>
      'Failed to connect to the call session';

  @override
  String get call_shareScreen => 'Share screen';

  @override
  String get call_shareScreenShort => 'Share';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return 'Sharing in $groupName • Tap to return to call';
  }

  @override
  String get call_sharingYourScreen => 'Sharing your screen';

  @override
  String get call_someone => 'Someone';

  @override
  String get call_speaker => 'Speaker';

  @override
  String get call_started => 'Started';

  @override
  String get call_startingScreenShare => 'Starting screen share…';

  @override
  String get call_statusBusy => 'Busy';

  @override
  String get call_statusCalling => 'Calling';

  @override
  String get call_statusCancelled => 'Cancelled';

  @override
  String get call_statusCompleted => 'Completed';

  @override
  String get call_statusConnected => 'Connected';

  @override
  String get call_statusConnecting => 'Connecting';

  @override
  String get call_statusDeclined => 'Declined';

  @override
  String get call_statusJoined => 'Joined';

  @override
  String get call_statusMissed => 'Missed';

  @override
  String get call_statusReconnecting => 'Reconnecting';

  @override
  String get call_statusRinging => 'Ringing';

  @override
  String get call_statusVideoConnecting => 'Video connecting';

  @override
  String get call_stop => 'Stop';

  @override
  String get call_stopSharing => 'Stop sharing';

  @override
  String get call_subtitle => 'Audio / Video Call';

  @override
  String get call_swipeUpToAnswer => 'Swipe up to answer';

  @override
  String get call_switch => 'Switch';

  @override
  String get call_switchCameraFailed => 'Unable to switch camera';

  @override
  String get call_switchToVideoToShare =>
      'Switch to video call to share your screen';

  @override
  String get call_tabContacts => 'Contacts';

  @override
  String get call_tabGroups => 'Groups';

  @override
  String get call_tabRecent => 'Recent';

  @override
  String get call_tapNotifyToInvite => 'Tap notify to invite';

  @override
  String get call_tapStartBroadcastHint =>
      'Tap Start Broadcast if the system prompt appears';

  @override
  String get call_title => 'Call';

  @override
  String call_todayAt(String value) {
    return 'Today, $value';
  }

  @override
  String get call_total => 'Total';

  @override
  String get call_turnOnVideo => 'Turn on your video';

  @override
  String get call_unableToCallContact => 'Unable to call this contact';

  @override
  String get call_unableToMakeCall => 'Unable to make call';

  @override
  String get call_unableToOpenChat => 'Unable to open chat for this contact';

  @override
  String get call_unableToShareScreen => 'Unable to share screen';

  @override
  String get call_unavailableTitle => 'Call unavailable';

  @override
  String get call_unexpectedResponse => 'Unexpected response from server';

  @override
  String get call_unknown => 'Unknown';

  @override
  String get call_unknownGroup => 'Unknown Group';

  @override
  String get call_unknownUser => 'Unknown User';

  @override
  String get call_unmute => 'Unmute';

  @override
  String get call_unselectAll => 'Unselect all';

  @override
  String get call_user => 'User';

  @override
  String get call_userNotFound => 'User not found';

  @override
  String call_userWithId(String id) {
    return 'User $id';
  }

  @override
  String get call_video => 'Video';

  @override
  String get call_waitingForBroadcast => 'Waiting for Start Broadcast';

  @override
  String get call_waitingForBroadcastMessage =>
      'Tap “Start Broadcast” in the system dialog to share your screen. Sharing begins only after that.';

  @override
  String get call_waitingForMedia => 'Waiting for media stream...';

  @override
  String get call_wired => 'Wired';

  @override
  String get call_yesDelete => 'Yes, Delete';

  @override
  String call_yesterdayAt(String value) {
    return 'Yesterday, $value';
  }

  @override
  String get call_youAreSharing => 'You\'re sharing';

  @override
  String get call_youAreSharingScreen => 'You are sharing your screen';

  @override
  String get call_zoomIn => 'Zoom in';

  @override
  String get call_zoomOut => 'Zoom out';

  @override
  String get chatList_allChats => 'All Chats';

  @override
  String get chatList_allContacts => 'All Contacts';

  @override
  String get chatList_allowAccess => 'Allow Access';

  @override
  String get chatList_allowContactsBody =>
      'We need access to your contacts to show who is on FG Tracker and to let you start a chat or send an invite.';

  @override
  String get chatList_allowContactsTitle => 'Allow contacts access';

  @override
  String get chatList_archiveChat => 'Archive Chat';

  @override
  String get chatList_archived => 'Archived';

  @override
  String get chatList_archivedChatsSubtitle => 'Your hidden conversations';

  @override
  String get chatList_archivedChatsTitle => 'Archived Chats';

  @override
  String chatList_archivedCount(int count) {
    return 'Archived ($count)';
  }

  @override
  String get chatList_block => 'Block';

  @override
  String get chatList_blockFailed => 'Unable to block user';

  @override
  String chatList_blockName(String name) {
    return 'Block $name';
  }

  @override
  String get chatList_blockUser => 'Block User';

  @override
  String get chatList_blockUserConfirm =>
      'Are you sure you want to block this user?';

  @override
  String get chatList_blocked => 'Blocked';

  @override
  String get chatList_chatCleared => 'Chat cleared';

  @override
  String get chatList_chooseContactToShare =>
      'Choose a contact to share in your chat.';

  @override
  String get chatList_clear => 'Clear';

  @override
  String get chatList_clearChat => 'Clear Chat';

  @override
  String get chatList_clearChatConfirm => 'Delete all messages with this user?';

  @override
  String get chatList_clearChatFailed => 'Unable to clear chat';

  @override
  String get chatList_clearSearch => 'Clear search';

  @override
  String get chatList_contactAndInfo => 'Contact & Info';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'Contact permission is needed to share a contact in chat.';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts',
      one: '1 contact',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return 'Failed to load contacts: $error';
  }

  @override
  String get chatList_contactsPermissionNeeded => 'Contacts permission needed';

  @override
  String get chatList_contactsWillAppear =>
      'Your contacts will appear here when available.';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => 'Deactivated';

  @override
  String get chatList_defaultAbout => 'Hey there! I am using FG Tracker';

  @override
  String get chatList_deleteChat => 'Delete Chat';

  @override
  String get chatList_deleteChatConfirm =>
      'Delete this conversation from your chat list?';

  @override
  String get chatList_forwardFailed => 'Unable to forward message.';

  @override
  String get chatList_forwardListLoadFailed => 'Unable to load forward list.';

  @override
  String get chatList_forwardTo => 'Forward to...';

  @override
  String get chatList_forwarded => 'Forwarded';

  @override
  String get chatList_groupChatFallback => 'Group Chat';

  @override
  String get chatList_groupDeactivatedBanner =>
      'This group has been deactivated by the Admin';

  @override
  String get chatList_groupFallback => 'Group';

  @override
  String get chatList_howToAllow => 'How to allow';

  @override
  String get chatList_howToAllowStep1 =>
      'Tap \"Allow Access\" to open Settings';

  @override
  String get chatList_howToAllowStep2 => 'Tap \"Permissions\"';

  @override
  String get chatList_howToAllowStep3 => 'Select \"Contacts\"';

  @override
  String get chatList_howToAllowStep4 =>
      'Choose \"Allow\", then come back to the app';

  @override
  String get chatList_invite => 'Invite';

  @override
  String get chatList_inviteChooseHow =>
      'Choose how you want to send the invite';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return 'Hey $name! Join me on FG Tracker.\n\nDownload for Android: $playStoreLink\n\nDownload for iOS: $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'More apps';

  @override
  String chatList_inviteName(String name) {
    return 'Invite $name';
  }

  @override
  String get chatList_inviteViaMessage => 'Message';

  @override
  String get chatList_locationHidden => 'Location Hidden';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1, $name2 +$count are typing...';
  }

  @override
  String get chatList_markAsRead => 'Mark as Read';

  @override
  String get chatList_markAsUnread => 'Mark as Unread';

  @override
  String get chatList_mediaLinksDocs => 'Media, links and docs';

  @override
  String get chatList_memberFallback => 'Member';

  @override
  String get chatList_messageDeleted => 'This message was deleted';

  @override
  String get chatList_messageForwarded => 'Message forwarded';

  @override
  String get chatList_messageIdMissing => 'Message ID is missing.';

  @override
  String chatList_minutesShort(int count) {
    return '$count min';
  }

  @override
  String get chatList_mute1Hour => '1 hour';

  @override
  String get chatList_mute8Hours => '8 hours';

  @override
  String get chatList_muteAlways => 'Until I turn it back on';

  @override
  String get chatList_muteSubtitle =>
      'Choose how long you want to pause notifications.';

  @override
  String get chatList_muteTitle => 'Mute notifications';

  @override
  String get chatList_muteUntilTomorrow => 'Until tomorrow';

  @override
  String get chatList_newChat => 'New Chat';

  @override
  String get chatList_newChatSectionContacts => 'Start a New Chat (Contacts)';

  @override
  String get chatList_newChatSectionInvite =>
      'Invite to Chat (Unregistered Contacts)';

  @override
  String get chatList_noArchivedChats => 'No Archived Chats';

  @override
  String get chatList_noArchivedChatsSubtitle =>
      'Archived conversations will appear here.';

  @override
  String get chatList_noChatsFound => 'No chats found';

  @override
  String get chatList_noChatsSubtitle => 'Your private chats will appear here.';

  @override
  String get chatList_noContactsAvailable => 'No contacts available';

  @override
  String get chatList_noContactsFound => 'No contacts found';

  @override
  String get chatList_noGroupsAvailable => 'No groups available';

  @override
  String get chatList_noGroupsFound => 'No groups found';

  @override
  String get chatList_noMediaYet => 'No media shared yet';

  @override
  String get chatList_noMessagesYet => 'No messages yet';

  @override
  String get chatList_noPeopleOrGroups => 'No people or groups found';

  @override
  String chatList_noResultsFor(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return 'No results for \'$query\'';
  }

  @override
  String get chatList_noTrackerContacts => 'No active tracker contacts found';

  @override
  String get chatList_offlineNotSaved =>
      'You\'re offline. The change wasn\'t saved, please try again.';

  @override
  String chatList_oneTyping(String name) {
    return '$name is typing...';
  }

  @override
  String get chatList_openSettings => 'Open Settings';

  @override
  String get chatList_pinChat => 'Pin Chat';

  @override
  String get chatList_pinnedChats => 'Pinned Chats';

  @override
  String get chatList_pleaseTryAgain => 'Please try again.';

  @override
  String get chatList_profileCall => 'Call';

  @override
  String get chatList_profileMessage => 'Message';

  @override
  String get chatList_profileNotFound => 'Profile details not found';

  @override
  String get chatList_profileVideoCall => 'Video Call';

  @override
  String get chatList_quickCommSubtitle => 'Connect with your team instantly';

  @override
  String get chatList_quickCommTitle => 'Quick Communication';

  @override
  String get chatList_quickGroups => 'Groups';

  @override
  String get chatList_quickGroupsSub => 'Team Chats';

  @override
  String get chatList_quickSafeZone => 'Safe Zone';

  @override
  String get chatList_quickSafeZoneSub => 'Safety & Alerts';

  @override
  String get chatList_quickTracking => 'Tracking';

  @override
  String get chatList_quickTrackingSub => 'Live Location';

  @override
  String get chatList_quickWalkie => 'Walkie';

  @override
  String get chatList_quickWalkieSub => 'Push to Talk';

  @override
  String get chatList_searchByNameOrNumber => 'Search by name or number...';

  @override
  String get chatList_searchGroupsHint => 'Search groups...';

  @override
  String get chatList_searchHint => 'Search chats or messages...';

  @override
  String get chatList_searchHintShort => 'Search...';

  @override
  String get chatList_searchNameOrNumber => 'Search name or number';

  @override
  String get chatList_searchResults => 'Search Results';

  @override
  String get chatList_sectionGroups => 'GROUPS';

  @override
  String get chatList_sectionMyContacts => 'MY CONTACTS';

  @override
  String get chatList_sectionOtherContacts => 'OTHER CONTACTS';

  @override
  String get chatList_sectionRecentChats => 'RECENT CHATS';

  @override
  String get chatList_selectDestination => 'Select Destination';

  @override
  String get chatList_selectDestinationMsg =>
      'Please select at least one person or group.';

  @override
  String chatList_selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get chatList_shareContactTitle => 'Share Contact';

  @override
  String chatList_shareMenuFailed(String error) {
    return 'Could not open share menu: $error';
  }

  @override
  String get chatList_smsOpenFailed => 'Messaging app could not be opened';

  @override
  String get chatList_someone => 'Someone';

  @override
  String get chatList_startConversation => 'Start a conversation';

  @override
  String get chatList_subtitle => 'Stay connected with your team';

  @override
  String get chatList_telegramOpenFailed => 'Telegram could not be opened';

  @override
  String get chatList_title => 'Chat';

  @override
  String get chatList_tryAnotherNameOrNumber =>
      'Try another name or phone number.';

  @override
  String get chatList_tryDifferentSearch =>
      'Try searching with a different name or message.';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1, $name2 are typing...';
  }

  @override
  String get chatList_typing => 'typing...';

  @override
  String get chatList_unableToCallContact => 'Unable to call this contact';

  @override
  String get chatList_unableToLoadContacts => 'Unable to load contacts';

  @override
  String get chatList_unarchiveChat => 'Unarchive Chat';

  @override
  String get chatList_unblock => 'Unblock';

  @override
  String get chatList_unblockFailed => 'Unable to unblock user';

  @override
  String chatList_unblockName(String name) {
    return 'Unblock $name';
  }

  @override
  String get chatList_unblockUser => 'Unblock User';

  @override
  String get chatList_unblockUserConfirm =>
      'Are you sure you want to unblock this user?';

  @override
  String get chatList_unknown => 'Unknown';

  @override
  String get chatList_unknownUser => 'Unknown User';

  @override
  String get chatList_unnamedContact => 'Unnamed contact';

  @override
  String get chatList_unpinChat => 'Unpin Chat';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed =>
      'Couldn\'t update the chat. Please try again.';

  @override
  String get chatList_userFallback => 'User';

  @override
  String get chatList_userNotFound => 'User not found';

  @override
  String get chatList_viewArchived => 'View archived conversations';

  @override
  String get chatList_whatsappOpenFailed => 'WhatsApp could not be opened';

  @override
  String get chatList_yourContacts => 'Your contacts';

  @override
  String get chat_addCaptionHint => 'Add a caption...';

  @override
  String get chat_audioUnavailable => 'This audio is no longer available';

  @override
  String get chat_blockFailed => 'Unable to block user';

  @override
  String get chat_call => 'Call';

  @override
  String get chat_cameraAccessNeeded =>
      'Camera access is needed to take photos and videos in chat.';

  @override
  String get chat_cameraModePhoto => 'PHOTO';

  @override
  String get chat_cameraModePortrait => 'PORTRAIT';

  @override
  String get chat_cameraModeVideo => 'VIDEO';

  @override
  String get chat_cameraStartFailed => 'Couldn\'t start the camera.';

  @override
  String get chat_cantMessageUser => 'You can\'t message this user';

  @override
  String get chat_chatActionsSubtitle => 'Manage your chat';

  @override
  String get chat_chatActionsTitle => 'Chat Actions';

  @override
  String get chat_clear => 'Clear';

  @override
  String get chat_clearChat => 'Clear Chat';

  @override
  String get chat_clearChatConfirm => 'Clear all messages from this chat?';

  @override
  String get chat_clearGroupChatFailed => 'Failed to clear group chat';

  @override
  String get chat_contactBlockedYou => 'This contact has blocked you';

  @override
  String get chat_contactUnavailable => 'Contact unavailable';

  @override
  String get chat_deleteForEveryone => 'Delete for Everyone';

  @override
  String get chat_deleteForEveryoneConfirm =>
      'Are you sure you want to delete this message for everyone?';

  @override
  String get chat_deleteForMe => 'Delete for Me';

  @override
  String get chat_deleteForMeConfirm =>
      'Are you sure you want to delete this message for you?';

  @override
  String get chat_deleteMember => 'Delete Member';

  @override
  String get chat_deleteMemberSubtitle => 'Remove a member from this group';

  @override
  String get chat_documentAvailable => 'Document is available';

  @override
  String get chat_documentDownloadFailed =>
      'The document couldn\'t be downloaded.';

  @override
  String get chat_documentOpenFailed =>
      'Couldn\'t open the document. Please try again.';

  @override
  String get chat_documentPreviewUnavailable =>
      'Preview is not available for this file type. Open the document using your installed application.';

  @override
  String get chat_documentUnavailable => 'This document is no longer available';

  @override
  String get chat_downloadFailed => 'Download failed';

  @override
  String get chat_edited => 'edited';

  @override
  String get chat_emptySubtitle => 'Say hi 👋 to start the conversation';

  @override
  String get chat_emptyTitle => 'No messages here yet';

  @override
  String get chat_fetchingLocation => 'Fetching location...';

  @override
  String get chat_finishVoiceRecordingFirst =>
      'Finish or cancel the voice recording first';

  @override
  String get chat_forwarded => 'Forwarded';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current of $total';
  }

  @override
  String get chat_groupActionsSubtitle => 'Manage your group settings';

  @override
  String get chat_groupActionsTitle => 'Group Actions';

  @override
  String get chat_groupChatCleared => 'Group chat cleared successfully';

  @override
  String get chat_groupDeactivated =>
      'This group has been deactivated by the Admin';

  @override
  String get chat_imageFailed => 'Image failed';

  @override
  String get chat_listen => 'Listen';

  @override
  String get chat_listenEnglish => 'Listen (English)';

  @override
  String get chat_listenHindi => 'Listen (Hindi)';

  @override
  String get chat_loadFailedSubtitle => 'Check your connection and try again.';

  @override
  String get chat_loadFailedTitle => 'Couldn\'t load messages';

  @override
  String get chat_locationFetchFailed =>
      'Couldn\'t get your location. Please try again.';

  @override
  String get chat_locationPermissionNeeded =>
      'Location permission is needed to share your location.';

  @override
  String get chat_locationPermissionOff =>
      'Location permission is turned off for this app. Enable it in Settings to share your location.';

  @override
  String get chat_locationServicesOff =>
      'Turn on location services to share your location.';

  @override
  String get chat_locationUnavailable => 'Location unavailable';

  @override
  String get chat_mediaMissing => 'Media is missing';

  @override
  String get chat_mediaMissingToast =>
      'Media is missing. This file is no longer available.';

  @override
  String get chat_mediaUnavailable => 'This media is no longer available';

  @override
  String get chat_menuForward => 'Forward';

  @override
  String get chat_menuMessageInfo => 'Message Info';

  @override
  String get chat_menuPin => 'Pin Message';

  @override
  String get chat_menuReply => 'Reply';

  @override
  String get chat_menuUnpin => 'Unpin Message';

  @override
  String get chat_messageCopied => 'Message copied';

  @override
  String get chat_messageDeleted => 'This message was deleted';

  @override
  String get chat_messageNotAvailable => 'Message not available';

  @override
  String get chat_messageNotSent => 'Message not sent. Please try again.';

  @override
  String get chat_noCameraFound => 'No camera found on this device.';

  @override
  String get chat_noLongerMember => 'You\'re no longer a member of this group';

  @override
  String get chat_noMediaAvailable => 'No media available';

  @override
  String get chat_offlineNotSent => 'You\'re offline. Message not sent.';

  @override
  String get chat_openDocument => 'Open Document';

  @override
  String get chat_openInGoogleMaps => 'Open in Google Maps';

  @override
  String get chat_openSettings => 'Open Settings';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'This photo is no longer available';

  @override
  String get chat_previewAttendancePoll => 'Attendance poll';

  @override
  String get chat_previewAudio => 'Audio';

  @override
  String get chat_previewContact => 'Contact';

  @override
  String get chat_previewDocument => 'Document';

  @override
  String get chat_previewLocation => 'Location';

  @override
  String get chat_previewMessage => 'Message';

  @override
  String get chat_previewNewMessage => 'New message';

  @override
  String get chat_previewOwnDeleted => 'You deleted this message';

  @override
  String get chat_previewPhoto => 'Photo';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Photos',
      one: '1 Photo',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => 'Poll';

  @override
  String get chat_previewSticker => 'Sticker';

  @override
  String get chat_previewVideo => 'Video';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Videos',
      one: '1 Video',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => 'Voice message';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return 'Voice message ($duration)';
  }

  @override
  String get chat_recordingFailed => 'Recording failed';

  @override
  String get chat_removeMember => 'Remove Member';

  @override
  String get chat_removeMemberConfirm =>
      'Are you sure you want to remove this member from the group?';

  @override
  String get chat_replyHint => 'Reply to message...';

  @override
  String get chat_searchMessages => 'Search Messages';

  @override
  String get chat_searchMessagesHint => 'Search messages...';

  @override
  String get chat_searchMessagesSubtitle => 'Find messages by keyword';

  @override
  String get chat_sendLocation => 'Send Location';

  @override
  String get chat_shareLocation => 'Share Location';

  @override
  String get chat_shareVideoFailed => 'Unable to share video';

  @override
  String get chat_sharedFromApp => 'Shared from FG Tracker';

  @override
  String get chat_sharedLocation => 'Shared Location';

  @override
  String get chat_showOriginal => 'Show Original';

  @override
  String get chat_someone => 'Someone';

  @override
  String get chat_statusLabel => 'Status';

  @override
  String get chat_statusUnavailable =>
      'This status update is no longer available';

  @override
  String get chat_stop => 'Stop';

  @override
  String get chat_stopEnglish => 'Stop (English)';

  @override
  String get chat_stopHindi => 'Stop (Hindi)';

  @override
  String get chat_takePhotoFailed => 'Failed to take photo';

  @override
  String get chat_translatedToEnglish => 'Translated to English';

  @override
  String get chat_translatedToHindi => 'Translated to Hindi';

  @override
  String get chat_translating => 'Translating...';

  @override
  String get chat_tryAgain => 'Try again';

  @override
  String get chat_typeMessageHint => 'Type a message...';

  @override
  String get chat_typing => 'typing...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people are typing...',
      one: '1 person is typing...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name is typing...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1, $name2 are typing...';
  }

  @override
  String get chat_unableToOpen => 'Unable to Open';

  @override
  String get chat_unableToOpenGoogleMaps => 'Unable to open Google Maps';

  @override
  String get chat_unblock => 'Unblock';

  @override
  String get chat_unblockContact => 'Unblock Contact';

  @override
  String get chat_unblockContactConfirm =>
      'Are you sure you want to unblock this contact?';

  @override
  String get chat_unblockFailed => 'Unable to unblock user';

  @override
  String get chat_unknown => 'Unknown';

  @override
  String get chat_unknownLocation => 'Unknown Location';

  @override
  String get chat_unsupportedMessage =>
      'This message isn\'t supported in this version of the app';

  @override
  String get chat_updateGroup => 'Update Group';

  @override
  String get chat_updateGroupSubtitle => 'Change the current group detail';

  @override
  String chat_uploadFileFailed(String path) {
    return 'Failed to upload $path';
  }

  @override
  String get chat_userBlocked => 'User blocked successfully';

  @override
  String get chat_userUnblocked => 'User unblocked successfully';

  @override
  String get chat_videoDownloaded => 'Video downloaded successfully';

  @override
  String get chat_videoThumbnailFailed => 'Failed to generate video thumbnail';

  @override
  String get chat_videoUnavailable => 'This video is no longer available';

  @override
  String get chat_videoUploadFailed => 'Failed to upload video';

  @override
  String get chat_voicePlayFailed => 'Couldn\'t play voice message';

  @override
  String get chat_voiceUploadFailed =>
      'Voice message upload failed. Please try again.';

  @override
  String get chat_youBlockedContact => 'You blocked this contact';

  @override
  String get common_add => 'Add';

  @override
  String get common_allow => 'Allow';

  @override
  String get common_back => 'Back';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_close => 'Close';

  @override
  String get common_comingSoon => 'Coming soon';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_copied => 'Copied';

  @override
  String get common_copy => 'Copy';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => 'Delete';

  @override
  String get common_dismiss => 'DISMISS';

  @override
  String get common_done => 'Done';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_error => 'Error';

  @override
  String get common_exit => 'Exit';

  @override
  String get common_gotIt => 'Got it';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'Just now';

  @override
  String common_lastSeen(String time) {
    return 'Last seen: $time';
  }

  @override
  String get common_loading => 'Loading…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String get common_next => 'Next';

  @override
  String get common_no => 'No';

  @override
  String get common_noData => 'No data found';

  @override
  String get common_noInternet => 'No internet connection';

  @override
  String get common_notNow => 'Not now';

  @override
  String get common_offline => 'Offline';

  @override
  String get common_ok => 'OK';

  @override
  String get common_online => 'Online';

  @override
  String get common_open => 'Open';

  @override
  String get common_permissionDenied => 'Permission denied';

  @override
  String get common_remove => 'Remove';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_save => 'Save';

  @override
  String get common_search => 'Search';

  @override
  String get common_send => 'Send';

  @override
  String get common_settings => 'Settings';

  @override
  String get common_share => 'Share';

  @override
  String get common_somethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get common_submit => 'Submit';

  @override
  String get common_success => 'Success';

  @override
  String get common_today => 'Today';

  @override
  String common_todayAt(String time) {
    return 'Today, $time';
  }

  @override
  String get common_tryAgain => 'Try again';

  @override
  String get common_viewAll => 'View all';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_yesterday => 'Yesterday';

  @override
  String get common_you => 'You';

  @override
  String get dialog_allowLocationAccess => 'Allow Location Access';

  @override
  String get dialog_anErrorOccurred => 'An error occurred!';

  @override
  String get dialog_important => 'Important!';

  @override
  String get dialog_locationPermissionRequired =>
      'Location Permission Required';

  @override
  String get dialog_locationPurposeBody =>
      'To improve service efficiency, our application requests permission to access your location for the purpose of saving it. This enables our laborers to navigate accurately to your designated work location.';

  @override
  String get dialog_locationSettingsAndroid =>
      'Without location access, we won\'t be able to detect your current location. Please tap on \'Settings\', then \'Permissions\', and allow location access.';

  @override
  String get dialog_locationSettingsIos =>
      'This app requires access to your location to provide location-based services. Please go to \'Settings\' and enable location permissions.';

  @override
  String get dialog_loggedInElsewhere =>
      'You have been logged in from another device.';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      'You have been logged in from another device. Please log in again.';

  @override
  String get dialog_logoutConfirm => 'Do you want to log out?';

  @override
  String get dialog_selectAllowAllTheTime =>
      'In the next popup, please select\n\'Allow all the time\'.';

  @override
  String get dialog_sessionExpiredTitle => 'Session Expired';

  @override
  String get editProfile_fullNameLabel => 'Full Name';

  @override
  String get editProfile_personalInfo => 'Personal Information';

  @override
  String get editProfile_phoneLabel => 'Phone Number';

  @override
  String get editProfile_saveButton => 'Save Changes';

  @override
  String get editProfile_tapPhotoHint => 'Tap on the photo to change';

  @override
  String get editProfile_title => 'Edit Profile';

  @override
  String get forceUpdate_currentInstalled => 'CURRENT INSTALLED';

  @override
  String get forceUpdate_defaultMessage =>
      'A new version of FG Tracker is available. Please update to continue.';

  @override
  String get forceUpdate_defaultTitle => 'Update Required';

  @override
  String get forceUpdate_fallbackMessage =>
      'A new version of FG Tracker is available with critical improvements. Please update to continue using the application.';

  @override
  String get forceUpdate_footer =>
      'Update is required to proceed with FG Tracker';

  @override
  String get forceUpdate_requiredVersion => 'REQUIRED VERSION';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return 'Update on $storeName';
  }

  @override
  String get groupDialog_audioCall => 'Audio Call';

  @override
  String get groupDialog_audioCallSubtitle => 'Start voice conversation';

  @override
  String get groupDialog_call => 'Call';

  @override
  String get groupDialog_chat => 'Chat';

  @override
  String get groupDialog_codeEmpty => 'Group code cannot be empty';

  @override
  String get groupDialog_codeLabel => 'Group Code';

  @override
  String get groupDialog_createButton => 'Create Group';

  @override
  String get groupDialog_createTitle => 'Create New Group';

  @override
  String get groupDialog_descHint => 'Enter Group Description';

  @override
  String get groupDialog_descLabel => 'Group Description (Optional)';

  @override
  String groupDialog_distance(String distance) {
    return 'Distance: $distance';
  }

  @override
  String get groupDialog_enterCodeManually => 'Enter Group Code Manually';

  @override
  String get groupDialog_enterCodeTitle => 'Enter Group Code';

  @override
  String get groupDialog_fillDetails => 'Fill in the details below';

  @override
  String get groupDialog_getDirections => 'Get Directions';

  @override
  String get groupDialog_join => 'Join Group';

  @override
  String groupDialog_lastSeen(String time) {
    return 'Last seen: $time';
  }

  @override
  String get groupDialog_locationHidden => 'Location Hidden';

  @override
  String get groupDialog_locationUnavailable => 'Location unavailable';

  @override
  String get groupDialog_member => 'Member';

  @override
  String get groupDialog_memberInfo => 'Member’s Info';

  @override
  String get groupDialog_nameHint => 'Enter group name';

  @override
  String get groupDialog_nameLabel => 'Group Name';

  @override
  String get groupDialog_noQrInImage =>
      'No QR code found in the selected image.';

  @override
  String get groupDialog_noValidQr => 'No valid QR code found.';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'Error decoding QR from gallery: $error';
  }

  @override
  String get groupDialog_scanCamera => 'Scan from Camera';

  @override
  String get groupDialog_selectCallType => 'Select Call Type';

  @override
  String get groupDialog_update => 'Update';

  @override
  String get groupDialog_updateTitle => 'Update Group';

  @override
  String get groupDialog_uploadGallery => 'Upload from Gallery';

  @override
  String get groupDialog_videoCall => 'Video Call';

  @override
  String get groupDialog_videoCallSubtitle => 'Start video conversation';

  @override
  String get groupDialog_yourLocation => 'Your current location';

  @override
  String get groupInfo_active => 'Active';

  @override
  String get groupInfo_admin => 'Admin';

  @override
  String get groupInfo_allGroups => 'All Groups';

  @override
  String get groupInfo_allGroupsSubtitle => 'Stay connected with your teams';

  @override
  String get groupInfo_areYouSure => 'Are you sure?';

  @override
  String get groupInfo_audioCall => 'Audio Call';

  @override
  String get groupInfo_clearChatConfirm =>
      'Delete all messages from this device?';

  @override
  String get groupInfo_createdBy => 'Created By';

  @override
  String get groupInfo_detailsNotFound => 'Group details not found';

  @override
  String get groupInfo_exitGroup => 'Exit Group';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return 'Are you sure you want to exit \"$groupName\"?';
  }

  @override
  String get groupInfo_exitGroupQuestion => 'Do you want to Exit this Group?';

  @override
  String get groupInfo_group => 'Group';

  @override
  String get groupInfo_groupAdmin => 'Group Admin';

  @override
  String get groupInfo_groupCallFailed =>
      'Could not start group call. Please try again.';

  @override
  String get groupInfo_groupCodeCopied => 'Group code copied!';

  @override
  String get groupInfo_groupSettings => 'Group Settings';

  @override
  String get groupInfo_groupSettingsSubtitle =>
      'Edit group info, privacy, and more';

  @override
  String get groupInfo_inactive => 'Inactive';

  @override
  String get groupInfo_inviteCopied => 'Invite text copied';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'Join my group \"$groupName\" on FG Tracker';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'Join my group \"$groupName\" on FG Tracker. Code: $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'Invite via Link';

  @override
  String get groupInfo_mediaLinksDocs => 'Media, Links & Docs';

  @override
  String get groupInfo_member => 'Member';

  @override
  String get groupInfo_members => 'Members';

  @override
  String get groupInfo_messageAction => 'Message';

  @override
  String groupInfo_nameYou(String name) {
    return '$name (You)';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return 'No group found for \'$query\'';
  }

  @override
  String get groupInfo_noGroupsYet =>
      'You haven\'t joined or created any groups yet.\nStart exploring now!';

  @override
  String get groupInfo_noMediaYet => 'No media shared yet';

  @override
  String get groupInfo_removeFromGroup => 'Remove from group';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return 'Are you sure you want to remove $name from the group?';
  }

  @override
  String get groupInfo_searchGroupsHint => 'Search groups...';

  @override
  String get groupInfo_showLess => 'Show less';

  @override
  String get groupInfo_teamCode => 'Team Code';

  @override
  String groupInfo_totalCount(int count) {
    return '$count Total';
  }

  @override
  String get groupInfo_unknownGroup => 'Unknown Group';

  @override
  String get groupInfo_unnamedGroup => 'Unnamed Group';

  @override
  String get groupInfo_videoCall => 'Video Call';

  @override
  String get groupInfo_viewAllMembers => 'View all members';

  @override
  String get group_activatedSuccess => 'Group activated successfully';

  @override
  String get group_addMember => 'Add Member';

  @override
  String get group_alignQr => 'Align QR inside the frame';

  @override
  String get group_areYouSure => 'Are you sure?';

  @override
  String get group_chatWithMembers => 'Chat with members in the group';

  @override
  String get group_codeCopied => 'Group code copied!';

  @override
  String group_codeShareInfo(String code) {
    return 'Group code: $code — share it so others can join';
  }

  @override
  String get group_copyCode => 'Copy code';

  @override
  String get group_created => 'Created';

  @override
  String get group_createdJustNow => 'Created just now';

  @override
  String get group_deactivatedSuccess => 'Group deactivated successfully';

  @override
  String get group_defaultName => 'Group';

  @override
  String get group_deleteGroup => 'Group Delete';

  @override
  String get group_deleteGroupConfirm => 'Do you want to Delete this Group?';

  @override
  String get group_deletedSuccess => 'Group deleted successfully';

  @override
  String get group_download => 'Download';

  @override
  String get group_downloadChannelDescription =>
      'Notifies when QR code is downloaded';

  @override
  String get group_downloadChannelName => 'Download Notifications';

  @override
  String get group_enableLocationToJoin =>
      'Please enable location services to join a group.';

  @override
  String get group_exitGroup => 'Exit Group';

  @override
  String get group_exitGroupConfirm => 'Do you want to Exit this Group?';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return 'Are you sure you want to exit \"$groupName\"? You\'ll need a group code to rejoin.';
  }

  @override
  String get group_exitedSuccess => 'Group Exit successfully';

  @override
  String get group_goToGroups => 'Go to Groups →';

  @override
  String get group_groupMessage => 'Group Message';

  @override
  String get group_invalidResponseFormat => 'Invalid format';

  @override
  String get group_joinedJustNow => 'Joined just now';

  @override
  String get group_joinedRecently => 'Recent';

  @override
  String get group_leftJustNow => 'Left just now';

  @override
  String get group_locationNoLongerShared =>
      'Your location is no longer shared with this group';

  @override
  String get group_locationPermissionToJoin =>
      'Location permission is required to join a group.';

  @override
  String get group_locationShared => 'Your location is shared with this group';

  @override
  String get group_memberFallbackName => 'Member';

  @override
  String group_membersMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members · $when',
      one: '1 member · $when',
    );
    return '$_temp0';
  }

  @override
  String get group_noContactsFound => 'No contacts found';

  @override
  String get group_noGroupCode => 'No Group Code Available';

  @override
  String get group_noNewMessages =>
      'You won\'t get new messages from this group';

  @override
  String get group_noNumber => 'No number';

  @override
  String get group_openGroup => 'Open Group →';

  @override
  String get group_other => 'Other';

  @override
  String get group_qrSavedBody => 'Tap to open your QR code';

  @override
  String get group_qrSavedTitle => 'QR Code Saved';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 Group Code: $groupCode\n\nJoin my group instantly using the QR code or the code above.\n\n📲 Download the app to stay connected:\n$appLink';
  }

  @override
  String get group_scanToJoin => 'Scan this QR code to join the group';

  @override
  String get group_searchMemberHint => 'Search member...';

  @override
  String get group_shareCodeInfo => 'Share the group code so others can join';

  @override
  String get group_shareQr => 'Share QR';

  @override
  String get group_shareQrToInvite => 'Share QR code to invite members';

  @override
  String get group_sheetCreatedSubtitle =>
      'Your group is ready. Share the code so members can join.';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name, your group is ready. Share the code so members can join.';
  }

  @override
  String get group_sheetCreatedTitle => 'Group created!';

  @override
  String get group_sheetJoinedSubtitle =>
      'Welcome, you\'re now a member of this group.';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return 'Welcome $name, you\'re now a member of this group.';
  }

  @override
  String get group_sheetJoinedTitle => 'Joined successfully!';

  @override
  String get group_sheetLeftSubtitle =>
      'You\'re no longer a member of this group.';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name, you\'re no longer a member of this group.';
  }

  @override
  String get group_sheetLeftTitle => 'You left the group';

  @override
  String get group_showQrCode => 'Show QR Code';

  @override
  String get group_startConversation => 'Feel Free to start a conversation';

  @override
  String get group_statusUpdateFailed => 'Failed to update group status';

  @override
  String get group_teamCode => 'Team Code';

  @override
  String get group_teamCodeLabel => 'Team Code: ';

  @override
  String get group_track => 'Track';

  @override
  String get group_unnamedMember => 'Unnamed Member';

  @override
  String get group_unnamedTrip => 'Unnamed Trip';

  @override
  String get group_updateGroupConfirm =>
      'Are you sure you want to update the group details?';

  @override
  String get group_updateGroupTitle => 'Update Group';

  @override
  String get group_youAreAdmin => 'You are the admin of this group';

  @override
  String get home_actionAllContacts => 'All contacts';

  @override
  String get home_actionAudioVideoCall => 'Audio/Video Call';

  @override
  String get home_actionChatting => 'Chatting';

  @override
  String get home_actionSafeZone => 'Safe Zone';

  @override
  String get home_actionTracking => 'Tracking';

  @override
  String get home_actionWalkieTalkie => 'Walkie Talkie';

  @override
  String get home_active => 'Active';

  @override
  String get home_activeSessions => 'Active Sessions';

  @override
  String home_activeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Active Sessions',
      one: '1 Active Session',
    );
    return '$_temp0';
  }

  @override
  String get home_allMembers => 'All Members';

  @override
  String get home_createGroup => 'Create Group';

  @override
  String get home_createGroupSubtitle => 'Create new group';

  @override
  String get home_goodToSeeYou => 'It’s good to see you again 👋';

  @override
  String home_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Groups',
      one: '1 Group',
    );
    return '$_temp0';
  }

  @override
  String home_helloName(String name) {
    return 'Hello $name';
  }

  @override
  String get home_inactive => 'Inactive';

  @override
  String get home_joinGroup => 'Join Group';

  @override
  String get home_joinGroupSubtitle => 'Join existing group';

  @override
  String home_lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String get home_newThisMonth => 'New This Month';

  @override
  String get home_noActivePrivateSessions => 'No active private sessions';

  @override
  String get home_noGroupsAvailable => 'No groups available';

  @override
  String get home_noGroupsFound => 'No groups found';

  @override
  String get home_noMembersFound => 'No members found';

  @override
  String home_noMembersMatch(String query) {
    return 'No members match \'$query\'';
  }

  @override
  String get home_noMembersOnline => 'No members currently online';

  @override
  String get home_noNameGroup => 'No Name Group';

  @override
  String get home_noRecentlyActiveMembers => 'No recently active members';

  @override
  String get home_onlineNow => 'Online Now';

  @override
  String get home_peopleOnline => 'People Online';

  @override
  String get home_peopleOnlineSubtitle =>
      'These members are active in the app right now and available to connect.';

  @override
  String get home_privateMode => 'Private Mode';

  @override
  String get home_privateModeIsOn => 'Private Mode is ON';

  @override
  String get home_privateModeOffHint =>
      'When Private Mode is OFF, others can see your location.';

  @override
  String get home_privateModeOnHint =>
      'When Private Mode is ON, others can\'t see your location.';

  @override
  String get home_quickActionsSubtitle => 'Everything you need, one tap away.';

  @override
  String get home_quickActionsTitle => 'Quick Actions';

  @override
  String get home_recentlyOnline => 'Recently Online';

  @override
  String get home_searchGroupsHint => 'Search groups...';

  @override
  String get home_searchMembersHint => 'Search members...';

  @override
  String get home_showLess => 'Show Less';

  @override
  String get home_sortNameAsc => 'Sort: Name (A-Z)';

  @override
  String get home_sortNameDesc => 'Sort: Name (Z-A)';

  @override
  String home_startedAt(String time) {
    return 'Started at $time';
  }

  @override
  String get home_statGroups => 'Groups';

  @override
  String get home_statMembers => 'Members';

  @override
  String get home_statNow => 'Now';

  @override
  String get home_statTotal => 'Total';

  @override
  String get home_totalMembers => 'Total Members';

  @override
  String home_totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Total Members',
      one: '1 Total Member',
    );
    return '$_temp0';
  }

  @override
  String get home_unableToFetchGroups => 'Unable to fetch groups';

  @override
  String get home_unknownMember => 'Unknown Member';

  @override
  String get home_upgradeSubtitle => 'Unlock advanced features for your team';

  @override
  String get home_upgradeToPremium => 'Upgrade to Premium';

  @override
  String get home_viewPlans => 'View Plans';

  @override
  String get home_walkieExpired => 'Expired';

  @override
  String get home_walkieOneHourFree => '1 hr free';

  @override
  String get home_walkieRenew => 'Renew';

  @override
  String get home_walkieSubscribed => 'Subscribed';

  @override
  String get home_youAreInvisible => 'You\'re Invisible';

  @override
  String get home_youAreVisible => 'You\'re Visible';

  @override
  String get http_networkError => 'An error occurred. Please try again!';

  @override
  String get http_sessionExpired => 'Session expired. Please log in again.';

  @override
  String get http_unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get imagePicker_camera => 'Camera';

  @override
  String get imagePicker_cancel => 'Cancel';

  @override
  String get imagePicker_cropTitle => 'Crop Image';

  @override
  String get imagePicker_gallery => 'Gallery';

  @override
  String get imagePicker_title => 'Choose an Option';

  @override
  String get intro_realTimeTrackingSubtitle =>
      'View live locations of friends, family, or team members on the map instantly.';

  @override
  String get intro_realTimeTrackingTitle => 'Real-Time Tracking';

  @override
  String get intro_secureSubtitle =>
      'Share your live location with\nselected contacts safely and\nprivately.';

  @override
  String get intro_secureTitle => 'Secure & Easy';

  @override
  String get intro_skip => 'Skip';

  @override
  String get intro_walkieSubtitle =>
      'No signal. No problem. Stay\nconnected anywhere.';

  @override
  String get intro_walkieTitle => 'Walkie-Talkie\nfeature';

  @override
  String login_dataSecure(String percent) {
    return 'Your data is $percent secure';
  }

  @override
  String get login_enterMobileNumber => 'Enter Mobile Number';

  @override
  String get media_cannotOpen => 'Cannot open';

  @override
  String get media_documentNotFound => 'Document not found';

  @override
  String get media_invalidLink => 'Invalid link';

  @override
  String get media_noDocuments => 'No documents found';

  @override
  String get media_noLinks => 'No links found';

  @override
  String get media_noMedia => 'No media found';

  @override
  String get media_tabDocs => 'Docs';

  @override
  String media_tabDocsCount(int count) {
    return 'Docs ($count)';
  }

  @override
  String get media_tabLinks => 'Links';

  @override
  String media_tabLinksCount(int count) {
    return 'Links ($count)';
  }

  @override
  String get media_tabMedia => 'Media';

  @override
  String media_tabMediaCount(int count) {
    return 'Media ($count)';
  }

  @override
  String get media_title => 'Media, links, and docs';

  @override
  String get media_videoNotFound => 'Video not found';

  @override
  String get menu_contactUsSubtitle => 'Know more about us';

  @override
  String get menu_editProfile => 'Edit Profile';

  @override
  String get menu_editProfileSubtitle => 'Update your information';

  @override
  String get menu_followUsOn => 'Follow us on';

  @override
  String get menu_logOut => 'Log Out';

  @override
  String get menu_logOutConfirmMessage => 'Do you really want to logout?';

  @override
  String get menu_logOutSubtitle => 'Sign out from the app';

  @override
  String get menu_profileImageUpdateFailed => 'Failed to update profile image';

  @override
  String get menu_profileImageUpdated => 'Profile image updated successfully';

  @override
  String get notif_accept => 'Accept';

  @override
  String get notif_channelHighImportanceDesc =>
      'Default channel for high importance notifications';

  @override
  String get notif_channelHighImportanceName => 'High Importance Notifications';

  @override
  String get notif_channelWalkieAudioDesc =>
      'Maintains live voice communication and background mic capture';

  @override
  String get notif_channelWalkieAudioName => 'Walkie-Talkie Live Audio';

  @override
  String get notif_channelWalkieCallsDesc => 'Incoming Walkie-Talkie calls';

  @override
  String get notif_channelWalkieCallsName => 'Walkie-Talkie Calls';

  @override
  String get notif_channelWalkieDesc =>
      'Group walkie calls and speaking updates';

  @override
  String get notif_channelWalkieLiveDesc =>
      'Notifications for active Walkie-Talkie channels';

  @override
  String get notif_channelWalkieLiveName => 'Walkie-Talkie Live Channels';

  @override
  String get notif_channelWalkieName => 'Walkie-Talkie';

  @override
  String notif_connectedIn(String group) {
    return 'Connected in $group • Live Audio Stream';
  }

  @override
  String get notif_goToWalkie => 'Go to Walkie Screen';

  @override
  String get notif_incomingWalkieTitle => 'Incoming Walkie-Talkie';

  @override
  String notif_isTalking(String name) {
    return '$name is talking';
  }

  @override
  String get notif_leave => 'Leave';

  @override
  String get notif_openWalkie => 'Open Walkie';

  @override
  String get notif_reject => 'Reject';

  @override
  String notif_stoppedTalking(String name) {
    return '$name stopped talking';
  }

  @override
  String get notif_walkieActiveConversation =>
      'Active walkie-talkie conversation';

  @override
  String get notif_walkieActiveTitle => 'Walkie-Talkie Active';

  @override
  String notif_wantsToTalk(String name) {
    return '$name wants to talk';
  }

  @override
  String get notifications_clearAll => 'Clear all notifications';

  @override
  String get notifications_clearedSuccess =>
      'All notifications cleared successfully';

  @override
  String get notifications_emptySubtitle =>
      'You have no new alerts at the moment.';

  @override
  String get notifications_emptyTitle => 'No Notifications Yet';

  @override
  String get notifications_filterAll => 'All';

  @override
  String get notifications_filterCalls => 'Calls';

  @override
  String get notifications_filterChats => 'Chats';

  @override
  String get notifications_filterUnread => 'Unread';

  @override
  String get notifications_loadingDetails => 'Loading notification details';

  @override
  String get notifications_recentCalls => 'Recent Calls';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get otpCharges_chargedNotice =>
      'From now on, each login OTP to your number is charged. Resending the OTP is free (up to 3 attempts).';

  @override
  String get otpCharges_chargesApplyTo => 'Charges apply to';

  @override
  String get otpCharges_eachOtpCosts => 'Each OTP costs';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'Each OTP costs $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'Each OTP costs $amount, including $percent percent GST';
  }

  @override
  String get otpCharges_firstLoginFree => 'Your first login was free.';

  @override
  String get otpCharges_freeBody =>
      'Login OTPs sent to this number are not charged.';

  @override
  String get otpCharges_freeTitle => 'OTP is free for your number';

  @override
  String otpCharges_gstTitle(String percent) {
    return 'GST ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return 'Including $percent% GST';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return 'Including $percent% Tax';
  }

  @override
  String get otpCharges_noInternet =>
      'No internet connection. Check your network and try again.';

  @override
  String get otpCharges_otpCharge => 'OTP charge';

  @override
  String otpCharges_pay(String amount) {
    return 'Pay $amount';
  }

  @override
  String get otpCharges_paymentCancelled =>
      'Payment cancelled. You cancelled the payment. No money was deducted.';

  @override
  String get otpCharges_paymentFailed =>
      'Payment failed. If money was deducted it will be refunded in 5–7 working days.';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return 'Payment Paused ($amount)';
  }

  @override
  String get otpCharges_paymentReceived =>
      'Payment received. Your OTP may take a moment to arrive.';

  @override
  String get otpCharges_paymentStartFailed =>
      'Could not start the payment. Please try again.';

  @override
  String get otpCharges_paymentsPaused =>
      'OTP payments are temporarily paused by administrator. Tap below for details.';

  @override
  String get otpCharges_paymentsUnavailable =>
      'OTP payments are temporarily unavailable. Please try again later.';

  @override
  String get otpCharges_sessionExpired =>
      'Session expired. Please start again.';

  @override
  String get otpCharges_title => 'OTP Charges';

  @override
  String get otpCharges_totalPerOtp => 'Total per OTP';

  @override
  String get otpCharges_tryAgainMoment =>
      'Something went wrong. Please try again in a moment.';

  @override
  String get otpCharges_unknownBody =>
      'Login OTPs to Indian numbers are free. For other countries, the exact price is shown before you pay at login.';

  @override
  String get otpCharges_unknownTitle => 'OTP charges depend on your country';

  @override
  String get otpCharges_updateApp =>
      'Payment couldn\'t start. Please update the app and try again.';

  @override
  String otpCharges_vatTitle(String percent) {
    return 'VAT / Tax ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      'Payment verification failed. If money was deducted it will be refunded in 5–7 working days.';

  @override
  String get otpCharges_yourNumber => 'Your number';

  @override
  String get package_noPackages => 'No packages are available right now.';

  @override
  String package_plansComingSoon(String title) {
    return '$title plans are coming soon';
  }

  @override
  String get package_subtitle => 'Pick a module to see its plans';

  @override
  String get package_title => 'Packages & Pricing';

  @override
  String get package_viewPlans => 'View plans';

  @override
  String get perm_alwaysLocationBody =>
      'To track your group in real time and in background, please set Location access to \'Allow all the time\' in App Settings.';

  @override
  String get perm_alwaysLocationTitle =>
      'Enable \'Always\' Location Permission';

  @override
  String get perm_chooseAllowAllTime =>
      'Please choose \'Allow all the time\' in the upcoming popup.';

  @override
  String get perm_collectsLocationBody =>
      'This app collects location data to ensure smooth job progress and provide efficient tracking, even when the app is closed or not in use.';

  @override
  String get perm_enableDeviceGpsBody =>
      'Please enable your device\'s GPS (Google Location).';

  @override
  String get perm_enableGpsTitle => 'Enable GPS';

  @override
  String get perm_exitBody => 'Do you want to exit the app?';

  @override
  String get perm_exitTitle => 'Are you sure?';

  @override
  String get perm_gpsRequiredBody =>
      'GPS is required to track your group in real time.';

  @override
  String get perm_locationTitle => 'Location Permission';

  @override
  String get perm_trackingPermissionBody =>
      'FG Partner app needs your permission to track location while you are logged in.';

  @override
  String get permission_allowAllTheTime => 'Allow All The Time';

  @override
  String get permission_allowLocation => 'Allow Location';

  @override
  String get permission_allowLocationFirst => 'Please allow Location first.';

  @override
  String permission_allowNamed(String permission) {
    return 'Allow $permission';
  }

  @override
  String get permission_allowNotifications => 'Allow Notifications';

  @override
  String get permission_appPermissionsSubtitle =>
      'Review the permissions required.';

  @override
  String get permission_appPermissionsTitle => 'App Permissions';

  @override
  String get permission_badgeGranted => 'Granted';

  @override
  String get permission_badgeOptional => 'Optional';

  @override
  String get permission_badgeRecommended => 'Recommended';

  @override
  String get permission_badgeRequired => 'Required';

  @override
  String get permission_camera => 'Camera';

  @override
  String get permission_cameraDescription =>
      'Used by the app features that capture photos or videos.';

  @override
  String get permission_cameraSettingsMessage =>
      'Camera permission is needed to capture photos and videos. Please enable it from app settings.';

  @override
  String get permission_cameraWhy =>
      'Allows you to capture photos and videos for supported profile, chat and other app features.';

  @override
  String get permission_contacts => 'Contacts';

  @override
  String get permission_contactsDescription =>
      'Used to discover or select contacts for contact-related app features.';

  @override
  String get permission_contactsSettingsMessage =>
      'Contacts permission is needed to find and select contacts. Please enable it from app settings.';

  @override
  String get permission_contactsWhy =>
      'Helps you find and select contacts when using supported contact-related features.';

  @override
  String get permission_gateCheckFailed =>
      'We could not check your permissions. Please try again.';

  @override
  String get permission_gateSubtitle =>
      'FG Tracker needs these permissions to receive calls and alerts and to run attendance, live tracking and safe zone.';

  @override
  String get permission_gateTitle => 'Permissions Required';

  @override
  String get permission_genericSettingsMessage =>
      'This permission is needed. Please enable it from app settings.';

  @override
  String get permission_iosLocationServicesOff =>
      'Location Services are turned off. Open Settings → Privacy & Security → Location Services and turn it on, then come back.';

  @override
  String get permission_location => 'Location';

  @override
  String get permission_locationAndNotificationRequired =>
      'Location and Notification permissions are required to continue.';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      'Location and Notifications are required to continue.';

  @override
  String get permission_locationDescription =>
      'Needed for attendance, live tracking and safe zone — including when the app is in the background.';

  @override
  String get permission_locationRequiredToContinue =>
      'Location permission is required to continue.';

  @override
  String get permission_locationStatusApproximate =>
      'Only approximate location is allowed. Precise is required.';

  @override
  String get permission_locationStatusBlocked =>
      'Location is blocked. Enable it from Settings.';

  @override
  String get permission_locationStatusDone =>
      'Allowed all the time · Precise · GPS on';

  @override
  String get permission_locationStatusGpsOff =>
      'Device location (GPS) is turned off.';

  @override
  String get permission_locationStatusNeedAlways =>
      '\"Allow all the time\" is required.';

  @override
  String get permission_locationStatusNotAllowed =>
      'Location permission not allowed yet.';

  @override
  String get permission_locationWhyExtra =>
      'Please choose \"Allow all the time\" and keep Precise location on.';

  @override
  String get permission_logout => 'Logout';

  @override
  String get permission_microphone => 'Microphone / Audio';

  @override
  String get permission_microphoneDescription =>
      'Used by voice, walkie-talkie, and calling features where applicable.';

  @override
  String get permission_microphoneSettingsMessage =>
      'Microphone permission is needed for voice, walkie-talkie and calls. Please enable it from app settings.';

  @override
  String get permission_microphoneWhy =>
      'Allows voice communication, walkie-talkie transmission and calls when you use these features.';

  @override
  String permission_notGrantedNamed(String permission) {
    return '$permission permission was not granted. Please try again.';
  }

  @override
  String get permission_notificationRequiredToContinue =>
      'Notification permission is required to continue.';

  @override
  String get permission_notificationSettingsText =>
      'Notifications are turned off for FG Tracker. Open Settings → Notifications and allow them.';

  @override
  String get permission_notificationStatusBlocked =>
      'Notifications are blocked. Enable them from Settings.';

  @override
  String get permission_notificationStatusDone => 'Allowed';

  @override
  String get permission_notificationStatusNotAllowed =>
      'Notification permission not allowed yet.';

  @override
  String get permission_notifications => 'Notifications';

  @override
  String get permission_notificationsDescription =>
      'Needed to receive incoming calls, chat messages and attendance / safe-zone alerts.';

  @override
  String get permission_notificationsWhyExtra =>
      'Incoming calls cannot ring without this permission.';

  @override
  String get permission_openSettings => 'Open Settings';

  @override
  String get permission_preciseLocation => 'Precise Location';

  @override
  String get permission_pushNotifications => 'Push Notifications';

  @override
  String get permission_reasonLocation =>
      'Location is needed for attendance, live tracking and safe zone alerts.';

  @override
  String get permission_reasonLocationAlways =>
      'Choose \"Allow all the time\" so live tracking and safe zone keep working when the app is in the background.';

  @override
  String get permission_reasonNotification =>
      'Notifications are needed to receive incoming calls, chat messages, attendance and safe-zone alerts.';

  @override
  String get permission_reasonPrecise =>
      'Precise location is needed for accurate attendance, live tracking and safe zone alerts.';

  @override
  String get permission_required => 'Permission Required';

  @override
  String get permission_selectAllowAllTheTime =>
      'Please select \"Allow all the time\" to continue.';

  @override
  String get permission_settingsAndroidAlways =>
      'Open Settings → Permissions → Location and choose \"Allow all the time\".';

  @override
  String get permission_settingsAndroidBlocked =>
      'Location access is blocked for FG Tracker. Open Settings → Permissions → Location and choose \"Allow all the time\".';

  @override
  String get permission_settingsAndroidPrecise =>
      'Open Settings → Permissions → Location and turn on \"Use precise location\".';

  @override
  String get permission_settingsIosAlways =>
      'Open Settings → Location and choose \"Always\".';

  @override
  String get permission_settingsIosBlocked =>
      'Location access is turned off for FG Tracker. Open Settings → Location and choose \"Always\".';

  @override
  String get permission_settingsIosPrecise =>
      'Open Settings → Location and turn on \"Precise Location\".';

  @override
  String get permission_skipAndContinue => 'Skip & Continue';

  @override
  String get permission_turnOnLocation => 'Turn On Location';

  @override
  String get permission_turnOnPreciseLocation => 'Turn On Precise Location';

  @override
  String get permission_unableToRequest => 'Unable to request permission.';

  @override
  String get permission_whyWeNeedThis => 'Why we need this?';

  @override
  String get registration_contactNumberHint => 'Enter Contact Number';

  @override
  String get registration_contactNumberLabel => 'Contact Number';

  @override
  String get registration_doneButton => 'Done';

  @override
  String get registration_emailHint => 'Enter Email Address';

  @override
  String get registration_emailLabel => 'Email Address';

  @override
  String get registration_genderFemale => 'Female';

  @override
  String get registration_genderLabel => 'Select Gender';

  @override
  String get registration_genderMale => 'Male';

  @override
  String get registration_genderOther => 'Other';

  @override
  String get registration_selectGenderError => 'Please select your gender';

  @override
  String get registration_userNameHint => 'Enter User Name';

  @override
  String get registration_userNameLabel => 'User Name';

  @override
  String get repo_allCallsCleared => 'All call history cleared successfully';

  @override
  String get repo_callDeleted => 'Call history deleted successfully';

  @override
  String get repo_invalidResponse => 'Invalid response format';

  @override
  String get repo_loadLocationsFailed => 'Failed to load group locations';

  @override
  String get repo_pkgConflict =>
      'This plan is already active or a payment is in progress.';

  @override
  String get repo_pkgNotFound =>
      'Plans are not available right now. Please try again later.';

  @override
  String get repo_pkgOffline =>
      'No internet connection. Check your network and try again.';

  @override
  String get repo_pkgSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get repo_pkgTimeout =>
      'The server is taking too long to respond. Please try again.';

  @override
  String get repo_selectedCallsDeleted => 'Selected calls deleted successfully';

  @override
  String get repo_unnamedGroup => 'Unnamed Group';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return 'Total Distance: $distance  •  Allowed Deviation: $deviation';
  }

  @override
  String get safeRoute_activeTitle => 'Active Safe Route';

  @override
  String get safeRoute_alertSettingsDesc =>
      'Manage safe route alerts, deviation limits and notification preferences.';

  @override
  String get safeRoute_alertSheetDesc =>
      'Real-time alerts when team members deviate from the safe route';

  @override
  String get safeRoute_alertTitle => 'Safe Route Alert';

  @override
  String get safeRoute_appBarSubtitle =>
      'Set a safe route for your team member.';

  @override
  String get safeRoute_destination => 'Destination';

  @override
  String get safeRoute_deviated => 'Deviated from safe route';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'Alert will be triggered if the member deviates more than $distance from the safe route.';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (Deviation: $distance)';
  }

  @override
  String get safeRoute_deviationLimit => 'Deviation Limit';

  @override
  String get safeRoute_deviationSubtitle =>
      'Set how much deviation is allowed from the selected route.';

  @override
  String get safeRoute_distance => 'Distance';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance km • $minutes min';
  }

  @override
  String get safeRoute_edit => 'Edit Safe Route';

  @override
  String get safeRoute_end => 'End';

  @override
  String safeRoute_estTime(int minutes) {
    return 'Est. Time: $minutes min';
  }

  @override
  String get safeRoute_featureDesc =>
      'Set predefined routes for your team members. Get alerts if someone deviates from the safe route.';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Members',
      one: '1 Member',
    );
    return '$group ($_temp0)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'Set the allowed distance a member can move away from the selected route. You’ll get an alert if they exceed this limit.';

  @override
  String get safeRoute_helpDeviationTitle => 'What is Deviation Limit?';

  @override
  String get safeRoute_helpHowBody =>
      'Select the member, choose start and destination locations, pick the best route and set a deviation limit.';

  @override
  String get safeRoute_helpHowTitle => 'How to Create Safe Route?';

  @override
  String get safeRoute_helpTitle => 'Safe Route Help';

  @override
  String get safeRoute_helpWhatBody =>
      'Set a start and destination location to create a safe travel route for your team member.';

  @override
  String get safeRoute_helpWhatTitle => 'What is Safe Route?';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$name has deviated from Safe Route';
  }

  @override
  String get safeRoute_recommended => 'Recommended';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (Recommended)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'Route ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'Save & Activate Safe Route';

  @override
  String get safeRoute_saveActivateGroup =>
      'Save & Activate Safe Route for Group';

  @override
  String get safeRoute_selectedRoute => 'Selected Route';

  @override
  String get safeRoute_setRoutesSubtitle =>
      'Create and manage safe routes for all group members.';

  @override
  String get safeRoute_start => 'Start';

  @override
  String get safeRoute_startLocation => 'Start Location';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. Set Deviation Limit';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. Preview & Apply';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. Preview Route';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. Select Route';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. Set Routes for Members';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. Set Start & Destination';
  }

  @override
  String get safeRoute_subtitle => 'Route protection';

  @override
  String get safeRoute_title => 'Safe Route';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return 'Radius: $radius  •  Center: $center';
  }

  @override
  String get safeZone_activePreview => 'Active (Preview)';

  @override
  String get safeZone_activeTitle => 'Active Safe Zone';

  @override
  String get safeZone_alertSettingsDesc =>
      'Manage safe zone, alert distance and notification preferences';

  @override
  String get safeZone_alertSheetDesc =>
      'Real-time alerts when team members leave the safe zone';

  @override
  String get safeZone_alertTitle => 'Safe Zone Alert';

  @override
  String safeZone_allMonitored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count members will be monitored\nwithin this safe zone.',
      one: '1 member will be monitored\nwithin this safe zone.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_appBarSubtitle =>
      'Define a safe area. Get alerts if someone\nsteps outside the safe zone.';

  @override
  String safeZone_appliedToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This safe zone will be applied to all $count members in the selected group.',
      one:
          'This safe zone will be applied to the 1 member in the selected group.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_edit => 'Edit Safe Zone';

  @override
  String get safeZone_exited => 'Exited safe zone';

  @override
  String get safeZone_featureDesc =>
      'Define a safe geographic area for your team. Get instant alerts if someone steps outside the safe zone.';

  @override
  String get safeZone_helpHowBody =>
      'Select a member, choose a location on the map and set the radius.';

  @override
  String get safeZone_helpHowTitle => 'How to Create Safe Zone?';

  @override
  String get safeZone_helpRadiusBody =>
      'Set the area radius (500 m, 1 km, 2 km or 5 km) according to your need.';

  @override
  String get safeZone_helpRadiusTitle => 'What is Safe Zone Radius?';

  @override
  String get safeZone_helpTitle => 'Safe Zone Help';

  @override
  String get safeZone_helpWhatBody =>
      'Set a specific area on the map and get alerts if the member steps outside the safe zone.';

  @override
  String get safeZone_helpWhatTitle => 'What is Safe Zone?';

  @override
  String safeZone_memberLeft(String name) {
    return '$name has left the Safe Zone';
  }

  @override
  String get safeZone_membersMonitored =>
      'Members will be monitored within this safe zone.';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return 'Near $place (Outside $zone)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place (Outside $zone)';
  }

  @override
  String get safeZone_saveActivate => 'Save & Activate Safe Zone';

  @override
  String get safeZone_saveActivateGroup =>
      'Save & Activate Safe Zone for Group';

  @override
  String get safeZone_searchLocation => 'Search Location...';

  @override
  String get safeZone_statusLabel => 'Status:';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. Preview Safe Zone';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. Set Safe Zone Radius';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. Select Location on Map';
  }

  @override
  String get safeZone_subtitle => 'Area protection';

  @override
  String get safeZone_title => 'Safe Zone';

  @override
  String safeZone_totalMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Total $count Members',
      one: 'Total 1 Member',
    );
    return '$_temp0';
  }

  @override
  String get safety_active => 'Active';

  @override
  String get safety_alertSettings => 'Alert Settings';

  @override
  String get safety_alerts => 'Alerts';

  @override
  String get safety_alertsDesc => 'Require immediate attention';

  @override
  String get safety_bannerBody =>
      'Monitor and protect your team with smart safety features.';

  @override
  String get safety_bannerTitle => 'Your Safety, Our Priority';

  @override
  String get safety_chooseFeature => 'Choose a Safety Feature';

  @override
  String get safety_comingSoonBody =>
      'Smart safety features to protect your team are on the way.';

  @override
  String get safety_contactSupport => 'Contact Support';

  @override
  String get safety_editAnytime => 'You can edit or deactivate anytime later.';

  @override
  String get safety_mapCityPark => 'City Park';

  @override
  String get safety_mapMainRoad => 'Main Road';

  @override
  String get safety_mapMarketLane => 'Market Lane';

  @override
  String get safety_mapRiver => 'River';

  @override
  String get safety_mapStationRoad => 'Station Road';

  @override
  String get safety_needHelpBody =>
      'Contact support team for any safety related assistance.';

  @override
  String get safety_quickOverview => 'Quick Overview';

  @override
  String get safety_recentAlerts => 'Recent Alerts';

  @override
  String get safety_recenter => 'Re-center';

  @override
  String get safety_safeNow => 'Safe Now';

  @override
  String get safety_safeNowDesc => 'Members are within safe zone/route';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. Select Group';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. Select Member';
  }

  @override
  String get safety_tabIndividual => 'Individual';

  @override
  String get safety_tagline => 'Stay protected. Stay connected.';

  @override
  String get safety_title => 'Safety';

  @override
  String get safety_viewAllMembers => 'View All Members';

  @override
  String get sheet_addGroupMember => 'Add Group Member';

  @override
  String get sheet_admin => 'Admin';

  @override
  String get sheet_attachSubtitle => 'Share files and media with your team';

  @override
  String get sheet_attachUpload => 'Attach / Upload';

  @override
  String get sheet_attendance => 'Attendance';

  @override
  String get sheet_callOptions => 'Call Options';

  @override
  String get sheet_cantRemoveSelf =>
      'You can\'t remove yourself from the group.';

  @override
  String get sheet_contact => 'Contact';

  @override
  String get sheet_contactsNotOnApp =>
      'Your contacts are not using FG Tracker yet.';

  @override
  String get sheet_document => 'Document';

  @override
  String get sheet_groupMembers => 'Group Members';

  @override
  String get sheet_location => 'Location';

  @override
  String get sheet_memberRemoved => 'Member removed successfully';

  @override
  String get sheet_noMembers => 'No members found';

  @override
  String get sheet_noRegisteredContacts => 'No Registered Contacts';

  @override
  String get sheet_noUserFound => 'No User Found';

  @override
  String get sheet_normalAudioCall => 'Normal Audio Call';

  @override
  String get sheet_normalAudioCallSubtitle => 'Standard clear voice quality';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Registered Contacts',
      one: '1 Registered Contact',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return 'Are you sure you want to remove $name from the group?';
  }

  @override
  String get sheet_removeMemberTitle => 'Remove Member';

  @override
  String get sheet_searchContacts => 'Search contacts';

  @override
  String get sheet_walkieCall => 'Walkie-Talkie Call';

  @override
  String get sheet_walkieCallSubtitle => 'Push-to-talk communication';

  @override
  String get sos_addDetailsMandatory => 'Add Details (Mandatory)';

  @override
  String get sos_addDetailsOptional => 'Add Details (Optional)';

  @override
  String get sos_addFamilyMember => 'Add Family Member';

  @override
  String get sos_addFamilyMemberRequired =>
      'Add at least 1 family member to send SOS alert';

  @override
  String get sos_addPhotoHint =>
      'Attach a photo to help others understand better.';

  @override
  String get sos_addPhotoOptional => 'Add Photo (Optional)';

  @override
  String get sos_alertSent => 'SOS Alert Sent!';

  @override
  String get sos_alertSentToNearby =>
      'Your alert has been sent to nearby people.';

  @override
  String get sos_alertWillBeSent => 'Alert will be sent to nearby people';

  @override
  String get sos_alertWillBeSentFamily =>
      'Your alert will be sent to nearby people and your family.';

  @override
  String sos_availableUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Available Users',
      one: '1 Available User',
    );
    return '$_temp0';
  }

  @override
  String get sos_detailsHint => 'Type any additional details...';

  @override
  String get sos_detailsMandatoryForOther =>
      'Add Details is mandatory when \'Other\' reason is selected';

  @override
  String get sos_howItWorks => 'How it works';

  @override
  String get sos_howItWorksIntro =>
      'SOS Alert helps you notify nearby people and your family in emergency situations.';

  @override
  String get sos_howItWorksTitle => 'How SOS Alert Works?';

  @override
  String get sos_liveTrackingStarted => 'Live tracking started';

  @override
  String sos_locationSharedWithFamily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your location is being shared with $count family members',
      one: 'Your location is being shared with 1 family member',
    );
    return '$_temp0';
  }

  @override
  String sos_membersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members selected',
      one: '1 member selected',
    );
    return '$_temp0';
  }

  @override
  String get sos_needHelp => 'Need Help?';

  @override
  String get sos_needHelpBody =>
      'Send an SOS alert to nearby people.\nThey will be notified and can assist you.';

  @override
  String get sos_noMatchFound => 'No Match Found';

  @override
  String get sos_noUsersFound => 'No Users Found';

  @override
  String get sos_notifyFamilyTitle => 'Notify Your Family (1 to 5 required)';

  @override
  String get sos_notifyUpdates => 'We will notify you of any updates';

  @override
  String get sos_okGotIt => 'OK, Got It';

  @override
  String get sos_peopleWithinRadius => 'People within 2 km radius';

  @override
  String get sos_privacyNote =>
      'Your privacy is important. Your location is shared only during an active SOS alert.';

  @override
  String get sos_reasonAccident => 'Accident';

  @override
  String get sos_reasonMedical => 'Medical';

  @override
  String get sos_reasonOther => 'Other';

  @override
  String get sos_reasonSafety => 'Safety';

  @override
  String get sos_reasonThreat => 'Threat';

  @override
  String get sos_required => 'Required';

  @override
  String get sos_searchUsers => 'Search users';

  @override
  String get sos_selectReason => 'Select Reason';

  @override
  String get sos_sendSosAlert => 'Send SOS Alert';

  @override
  String get sos_stayCalm => 'Stay calm, help is on the way';

  @override
  String get sos_step1Body =>
      'Tap on the SOS button and send alert to people nearby.';

  @override
  String get sos_step1Title => '1. Send SOS Alert';

  @override
  String get sos_step2Body =>
      'People nearby will receive your alert with your location.';

  @override
  String get sos_step2Title => '2. Notify Nearby People';

  @override
  String get sos_step3Body =>
      'Nearby people can view your alert and reach out to help you.';

  @override
  String get sos_step3Title => '3. Get Help Faster';

  @override
  String get sos_step4Body =>
      'Your family members will be instantly notified about your SOS.';

  @override
  String get sos_step4Title => '4. Family Gets Notified';

  @override
  String get sos_subtitle => 'Send alert to nearby people';

  @override
  String get sos_title => 'SOS Alert';

  @override
  String get sos_willBeNotified => 'will be notified';

  @override
  String status_activeCount(int count) {
    return '$count active';
  }

  @override
  String get status_addToMyStatus => 'Add to My Status';

  @override
  String get status_allContacts => 'All Contacts';

  @override
  String get status_cameraAccessFailed => 'Unable to access camera';

  @override
  String get status_captionHint => 'Add a caption...';

  @override
  String get status_changeMedia => 'Change Media';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get status_deleted => 'Status deleted';

  @override
  String get status_deletedByOwner => 'This status was deleted by the owner';

  @override
  String get status_exceptContacts => 'Except Contacts';

  @override
  String get status_exceptSelected => 'Except Selected';

  @override
  String get status_flip => 'Flip';

  @override
  String get status_gallery => 'Gallery';

  @override
  String get status_modePhoto => 'Photo';

  @override
  String get status_modeText => 'Text';

  @override
  String get status_modeVideo => 'Video';

  @override
  String get status_myStatus => 'My Status';

  @override
  String get status_new => 'New';

  @override
  String get status_noCamera => 'No camera available';

  @override
  String get status_noLongerAvailable => 'This status is no longer available';

  @override
  String get status_noViewsYet => 'No views yet';

  @override
  String get status_onlyShareWith => 'Only Share With';

  @override
  String get status_pause => 'Pause';

  @override
  String get status_pinchZoomHint => 'Pinch to zoom photo';

  @override
  String get status_play => 'Play';

  @override
  String get status_postStatus => 'Post Status';

  @override
  String get status_previewStatus => 'Preview Status';

  @override
  String get status_privacy => 'Privacy';

  @override
  String get status_privacyTitle => 'Status Privacy';

  @override
  String get status_publishFailed => 'Unable to publish status';

  @override
  String get status_replyHint => 'Reply to status...';

  @override
  String get status_retake => 'Retake';

  @override
  String get status_selectPhotoFirst =>
      'Please capture or select a photo first';

  @override
  String get status_selectVideoFirst =>
      'Please capture or select a video first';

  @override
  String get status_shareUpdatesHint => 'Share updates with your team';

  @override
  String get status_tapVideoHint => 'Tap video to play / pause';

  @override
  String get status_textRequired => 'Text content is required for text status';

  @override
  String get status_title => 'Status';

  @override
  String get status_typeHint => 'Type a status...';

  @override
  String get status_uploadFailed => 'Upload Failed';

  @override
  String get status_viewMyStatus => 'View My Status';

  @override
  String get status_viewed => 'Viewed';

  @override
  String status_viewedBy(int count) {
    return 'Viewed by $count';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Views',
      one: '1 View',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => 'Who can see?';

  @override
  String get track_admin => 'Admin';

  @override
  String get track_applyRadius => 'Apply Radius';

  @override
  String get track_checkNetworkConnection =>
      'Please check your network connection and try again.';

  @override
  String get track_checkNetworkMembers =>
      'Please check your network and try again to view nearby members.';

  @override
  String get track_currentLocation => 'Current Location';

  @override
  String get track_custom => 'Custom';

  @override
  String track_customWithValue(String radius) {
    return 'Custom ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return '$distance away';
  }

  @override
  String get track_enable => 'Enable';

  @override
  String get track_enableGpsBody =>
      'To track your group in real time, please turn on your GPS.';

  @override
  String get track_enableGpsTitle => 'Enable GPS';

  @override
  String get track_errorFailedLoadGroups => 'Failed to load groups';

  @override
  String get track_errorLoadGroups =>
      'Unable to load groups. Please try again.';

  @override
  String get track_errorLoadMembers =>
      'Unable to load nearby members. Please try again.';

  @override
  String get track_errorNoInternet =>
      'No internet connection. Please check your network.';

  @override
  String get track_errorServer =>
      'Unable to connect to server. Please try again.';

  @override
  String track_groupCode(String code) {
    return 'Code: $code';
  }

  @override
  String get track_groupMembers => 'Group Members';

  @override
  String track_groupMembersAndCode(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members • Code: $code',
      one: '1 member • Code: $code',
    );
    return '$_temp0';
  }

  @override
  String get track_groupTab => 'Group';

  @override
  String track_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Groups',
      one: '1 Group',
    );
    return '$_temp0';
  }

  @override
  String track_groupsHeader(int count) {
    return 'GROUPS ($count)';
  }

  @override
  String get track_helpGroupBody => 'Create a group to track multiple members.';

  @override
  String get track_helpGroupTitle => 'How to Add Group?';

  @override
  String get track_helpLiveBody =>
      'Track team\'s real-time location on the map.';

  @override
  String get track_helpLiveTitle => 'What is Live Tracking?';

  @override
  String get track_helpRadiusBody =>
      'Set the area to find nearby members on the map.';

  @override
  String get track_helpRadiusTitle => 'What is Tracking Radius?';

  @override
  String get track_helpTitle => 'Tracking Help';

  @override
  String track_lastSeen(String time) {
    return 'Last seen: $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count Live';
  }

  @override
  String get track_liveMembers => 'Live Members';

  @override
  String get track_liveTracking => 'Live Tracking';

  @override
  String get track_locating => 'Locating...';

  @override
  String get track_locationHidden => 'Location Hidden';

  @override
  String get track_locationUnavailable => 'Location unavailable';

  @override
  String get track_mapOfflineBody =>
      'Internet connection is required to load live map data and real-time member locations.';

  @override
  String get track_mapUnavailableOffline => 'Map Unavailable Offline';

  @override
  String get track_member => 'Member';

  @override
  String track_memberPausedSharing(String name) {
    return '$name has paused location sharing. Live location is not available.';
  }

  @override
  String track_membersHeader(int count) {
    return 'MEMBERS ($count)';
  }

  @override
  String track_membersLive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Members Live',
      one: '1 Member Live',
    );
    return '$_temp0';
  }

  @override
  String get track_menuMembers => 'Members';

  @override
  String get track_menuRefreshMap => 'Refresh Map';

  @override
  String get track_menuTheme => 'Theme';

  @override
  String get track_nearbyYou => 'Nearby you';

  @override
  String get track_noActiveMembers => 'No Active Members';

  @override
  String track_noActiveMembersWithin(String radius) {
    return 'No active members found within $radius';
  }

  @override
  String get track_noDescription => 'No description';

  @override
  String get track_noGroupsFound => 'No Groups Found';

  @override
  String get track_noGroupsMatch => 'No Groups Match';

  @override
  String track_noGroupsMatchQuery(String query) {
    return 'No groups match \'$query\'';
  }

  @override
  String get track_noGroupsYet =>
      'You haven\'t joined or created any groups yet.';

  @override
  String get track_noInternetTitle => 'No Internet Connection';

  @override
  String get track_noMembersFound => 'No Members Found';

  @override
  String get track_noMembersFoundPlain => 'No members found';

  @override
  String get track_noMembersInGroup => 'No members found in this group';

  @override
  String track_noMembersMatch(String query) {
    return 'No members match \'$query\'';
  }

  @override
  String track_noSearchMatches(String query) {
    return 'No members or groups matching';
  }

  @override
  String track_noSearchResults(String query) {
    return 'No members or groups found for \'$query\'';
  }

  @override
  String get track_notAvailable => 'N/A';

  @override
  String get track_offlineBanner =>
      'No internet connection. Map & tracking are offline.';

  @override
  String get track_private => 'Private';

  @override
  String get track_radius => 'Radius';

  @override
  String get track_refresh => 'Refresh';

  @override
  String get track_refreshing => 'Refreshing...';

  @override
  String get track_retryConnection => 'Retry Connection';

  @override
  String get track_searchHint => 'Search members or groups...';

  @override
  String get track_searchMembersHint => 'Search Members...';

  @override
  String get track_selectedLocation => 'Selected Location';

  @override
  String get track_setRadiusSubtitle => 'Slide to select area radius';

  @override
  String get track_setRadiusTitle => 'Set Tracking Radius';

  @override
  String get track_unableToLoadGroups => 'Unable to Load Groups';

  @override
  String get track_unableToLoadMembers => 'Unable to Load Members';

  @override
  String get track_unnamedGroup => 'Unnamed Group';

  @override
  String get track_unnamedMember => 'Unnamed Member';

  @override
  String get track_yourGroups => 'Your Groups';

  @override
  String get track_yourLocationPaused =>
      'Your live location sharing is paused and private.';

  @override
  String get util_previewContact => '👤 Contact';

  @override
  String get util_previewDocument => '📄 Document';

  @override
  String get util_previewLocation => '📍 Location';

  @override
  String get util_previewPhoto => '📷 Photo';

  @override
  String get util_previewVideo => '🎥 Video';

  @override
  String get util_previewVoice => '🎤 Voice message';

  @override
  String util_spokenEur(String amount) {
    return '$amount euros';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amount pounds';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupees rupees',
      one: '1 rupee',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees rupees $paise paise';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount US dollars';
  }

  @override
  String get util_unableToCallContact => 'Unable to call this contact';

  @override
  String get util_unableToStartGroupCall => 'Unable to start group call';

  @override
  String get validation_emailEmpty => 'Email address cannot be empty';

  @override
  String get validation_emailInvalid => 'Please enter a valid email address.';

  @override
  String validation_required(String field) {
    return '$field is required';
  }

  @override
  String get voice_appLanguage => 'App language';

  @override
  String get voice_audioChip => 'AUDIO';

  @override
  String get voice_captionReady => 'Caption ready';

  @override
  String get voice_chooseSpeechLanguage => 'Choose Speech Language';

  @override
  String get voice_couldntPlay => 'Couldn\'t play voice message';

  @override
  String get voice_didntCatch =>
      'Didn\'t catch that. Tap the mic and speak a little louder.';

  @override
  String get voice_language => 'Language';

  @override
  String get voice_listenBack => 'Listen back';

  @override
  String get voice_listenBeforeSending =>
      'Listen before sending your voice message.';

  @override
  String get voice_listening => 'Listening…';

  @override
  String get voice_micPermissionNeeded =>
      'Microphone permission is needed to use voice.';

  @override
  String get voice_micUnavailable =>
      'Microphone unavailable. Please check settings.';

  @override
  String get voice_noTextCaptured => 'No text captured — try re-recording.';

  @override
  String get voice_openSettings => 'Open settings';

  @override
  String get voice_permissionRequired => 'Permission Required';

  @override
  String get voice_reRecord => 'Re-record';

  @override
  String get voice_readyToSend => 'Ready to send';

  @override
  String get voice_recordVoice => 'Record Voice';

  @override
  String get voice_recordVoiceSubtitle => 'Record and send as an audio message';

  @override
  String get voice_recordingYourVoice => 'Recording your voice…';

  @override
  String get voice_replyReady => 'Reply ready';

  @override
  String get voice_reviewTextHint =>
      'Listen to your voice above, or edit the text in the message box before sending.';

  @override
  String get voice_sendMessage => 'Send message';

  @override
  String get voice_sendVoiceMessage => 'Send voice message';

  @override
  String get voice_speakNowCaption => 'Speak now – we are typing your caption';

  @override
  String get voice_speakNowMessage =>
      'Speak now – your words appear in the message box';

  @override
  String get voice_speakNowReply => 'Speak now – we are typing your reply';

  @override
  String get voice_speakPlaceholder => 'Speak… your text will appear here';

  @override
  String get voice_speechPermissionNeeded =>
      'Speech recognition permission is needed to convert voice to text.';

  @override
  String get voice_tapToStop => 'Tap to stop';

  @override
  String get voice_textReady => 'Text ready';

  @override
  String get voice_tooMuchNoise =>
      'Too much noise – hold the phone closer and speak clearly';

  @override
  String get voice_type => 'Type';

  @override
  String get voice_voiceToText => 'Voice to Text';

  @override
  String get voice_voiceToTextSubtitle => 'Speak and type into the message box';

  @override
  String get voice_willSendAudioMessage =>
      'Your voice will be sent as an audio message';

  @override
  String get voice_willSendAudioReply =>
      'Your voice will be sent as an audio reply';

  @override
  String get voice_willSendWithFile =>
      'Your voice will be sent with the file as audio';

  @override
  String get voice_yourMessage => 'Your message';

  @override
  String get voice_yourVoiceMessage => 'Your voice message';

  @override
  String get walkiePlan_availableIndividualPlans => 'Individual Plans';

  @override
  String get walkiePlan_availablePerMonth => '/ month';

  @override
  String get walkiePlan_availablePerSeat => '/ seat';

  @override
  String get walkiePlan_availableSingleMember =>
      'Single Member (Personal Access)';

  @override
  String get walkiePlan_availableSubtitle =>
      'Select a plan to start or upgrade your subscription';

  @override
  String get walkiePlan_availableTeamPlans => 'Team Plans';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min-$max Seats  •  Group Collaboration';
  }

  @override
  String get walkiePlan_availableTitle => 'Available Plans';

  @override
  String get walkiePlan_bottomBarAfterTrial => 'After your free trial';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'Choose a Plan';

  @override
  String get walkiePlan_bottomBarContinue => 'Continue with Walkie Talkie';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return 'Purchase for $price';
  }

  @override
  String get walkiePlan_cardActive => 'Active';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return 'Active since $date';
  }

  @override
  String get walkiePlan_cardAssigned => 'Assigned';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return 'Assigned by $name';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'Assigned to You';

  @override
  String get walkiePlan_cardAvailable => 'Available';

  @override
  String get walkiePlan_cardManageMembers => 'Manage Members';

  @override
  String get walkiePlan_cardNoActiveIndividual =>
      'No active Individual subscription';

  @override
  String get walkiePlan_cardNoActiveTeam =>
      'No active Team plan or assigned seat';

  @override
  String get walkiePlan_cardOneSeatSelf => '1 Seat (Self)';

  @override
  String get walkiePlan_cardPersonal => 'Personal';

  @override
  String get walkiePlan_cardPurchased => 'Purchased';

  @override
  String get walkiePlan_cardPurchasedByYou => 'Purchased by You';

  @override
  String get walkiePlan_cardPurchasedOn => 'Purchased On';

  @override
  String get walkiePlan_cardSeatsMembers => 'Seats / Members';

  @override
  String get walkiePlan_cardSubscribedByYou => 'Subscribed by You';

  @override
  String get walkiePlan_cardTeamAdministrator => 'Team Administrator';

  @override
  String get walkiePlan_cardValidUntil => 'Valid Until';

  @override
  String get walkiePlan_cardView => 'View';

  @override
  String get walkiePlan_cardViewPlan => 'View Plan';

  @override
  String walkiePlan_couponDiscount(String value) {
    return '$value Discount';
  }

  @override
  String get walkiePlan_couponExpired => 'Coupon has expired';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return 'Flat $amount OFF';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet => 'Minimum order amount not met';

  @override
  String get walkiePlan_couponNotEligible => 'Not eligible for current plan';

  @override
  String get walkiePlan_couponNotStarted => 'Coupon offer is not active yet';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent% OFF';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable =>
      'Not applicable on this plan';

  @override
  String walkiePlan_couponValidTill(String date) {
    return 'Valid till $date';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'Continue to Payment';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return 'Continue with $plan';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => 'Coupon applied successfully!';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return 'Coupon applied! You save $amount';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => 'Failed to apply coupon';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'Coupon removed';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'Cashfree error ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed => 'Payment initiation failed.';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return 'Failed to create payment session: $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return 'Unable to process payment: $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'Loading plans...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans =>
      'Unable to load plans. Please try again.';

  @override
  String get walkiePlan_detailsAllBanks => 'All Indian Banks supported';

  @override
  String get walkiePlan_detailsApplied => 'Applied';

  @override
  String get walkiePlan_detailsApply => 'Apply';

  @override
  String get walkiePlan_detailsApplyCaps => 'APPLY';

  @override
  String get walkiePlan_detailsAvailableCoupons => 'Available Coupons';

  @override
  String get walkiePlan_detailsCard => 'Credit / Debit Card';

  @override
  String get walkiePlan_detailsChooseTitle => 'Choose a Plan';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'Code: $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'Coupons & Offers';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'Enter coupon code';

  @override
  String get walkiePlan_detailsEnterValidCoupon =>
      'Please enter a valid coupon code';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'Group Communication';

  @override
  String get walkiePlan_detailsFeatHqVoice => 'High Quality Voice';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => 'Priority Support';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => 'Unlimited Range';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => 'Unlimited Walkie Talkie';

  @override
  String get walkiePlan_detailsHavePromoCode => 'Have a Promo Code?';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'Continue using Walkie Talkie with a plan that fits your team';

  @override
  String get walkiePlan_detailsLockedCaps => 'LOCKED';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Maximum limit of $count members reached',
      one: 'Maximum limit of 1 member reached',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMemberPlural => 'Members';

  @override
  String get walkiePlan_detailsMemberSingular => 'Member';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Members × $rate',
      one: '1 Member × $rate',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minimum team size is $count members',
      one: 'Minimum team size is 1 member',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody =>
      'Add or remove members anytime.';

  @override
  String get walkiePlan_detailsMoreMembersTitle => 'More Members?';

  @override
  String get walkiePlan_detailsMostPopular => 'Most Popular';

  @override
  String get walkiePlan_detailsNetBanking => 'Net Banking';

  @override
  String get walkiePlan_detailsNoCouponsBody =>
      'There are no active coupons for this plan right now.';

  @override
  String get walkiePlan_detailsNoCouponsTitle => 'No Coupons Available';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      'No individual walkie-talkie plans are currently available. Please check back later or retry.';

  @override
  String get walkiePlan_detailsNoPlansTitle => 'No Plans Available';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      'No team walkie-talkie plans are currently available. Please check back later or retry.';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '$amount total';
  }

  @override
  String get walkiePlan_detailsPayActivate => 'Pay & Activate Plan';

  @override
  String get walkiePlan_detailsPerPerson => '/ person';

  @override
  String get walkiePlan_detailsPillAllSizes => 'of All Sizes';

  @override
  String get walkiePlan_detailsPillCommunication => 'Communication';

  @override
  String get walkiePlan_detailsPillForTeams => 'For Teams';

  @override
  String get walkiePlan_detailsPillInstant => 'Instant';

  @override
  String get walkiePlan_detailsPillPriority => 'Priority';

  @override
  String get walkiePlan_detailsPillReliable => 'Reliable &';

  @override
  String get walkiePlan_detailsPillSecure => 'Secure';

  @override
  String get walkiePlan_detailsPillSupport => 'Support';

  @override
  String get walkiePlan_detailsPillUnlimited => 'Unlimited';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'Walkie Talkie';

  @override
  String get walkiePlan_detailsPlanActivated => 'Plan Activated Successfully!';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'Your Walkie Talkie plan is now active. Enjoy uninterrupted instant voice communication.';

  @override
  String get walkiePlan_detailsPlanSummary => 'Plan Summary';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'Promo ($code) applied';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => 'REMOVE';

  @override
  String get walkiePlan_detailsSelectPaymentMethod => 'Select Payment Method';

  @override
  String get walkiePlan_detailsSkeletonCouponNote =>
      'Valid on all plans • Expires soon';

  @override
  String get walkiePlan_detailsStep1Subtitle =>
      'Choose how many team members you want to add';

  @override
  String get walkiePlan_detailsStep1Title => 'Select Number of Members';

  @override
  String get walkiePlan_detailsStep2Subtitle =>
      'Choose the plan duration that works for you';

  @override
  String get walkiePlan_detailsStep2Title => 'Select Plan Duration';

  @override
  String get walkiePlan_detailsSubtitleDefault =>
      'Instant walkie talkie voice access';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams =>
      'Great value for growing teams';

  @override
  String get walkiePlan_detailsSubtitleLongTerm => 'Best for long-term use';

  @override
  String get walkiePlan_detailsSubtitleShortTerm =>
      'Perfect for short-term use';

  @override
  String get walkiePlan_detailsTabIndividual => 'Individual';

  @override
  String get walkiePlan_detailsTabMultipleMembers => 'For Multiple Members';

  @override
  String get walkiePlan_detailsTabPerPerson => 'Per Person';

  @override
  String get walkiePlan_detailsTeamSubtitle =>
      'Add team members and get everyone connected with Walkie Talkie';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / QR Code';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return 'You save $amount with this coupon!';
  }

  @override
  String get walkiePlan_durationFallback => 'Duration';

  @override
  String get walkiePlan_durationMonthly => 'Monthly';

  @override
  String walkiePlan_durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Months',
      one: '1 Month',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_durationQuarterly => 'Quarterly';

  @override
  String get walkiePlan_durationYearly => 'Yearly';

  @override
  String get walkiePlan_individualPlan => 'Individual Plan';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return '$interval Plan';
  }

  @override
  String get walkiePlan_monthlyPlan => 'Monthly Plan';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'No internet connection. Please check your network.';

  @override
  String get walkiePlan_order100Secure => '100% Secure';

  @override
  String get walkiePlan_order3ds2Secure => '3DS2 Secure';

  @override
  String get walkiePlan_orderAgreePrefix => 'By proceeding, you agree to our ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => 'Amount After Discount';

  @override
  String get walkiePlan_orderCards => 'Cards';

  @override
  String get walkiePlan_orderChangeMethod => 'Change Method';

  @override
  String get walkiePlan_orderCouldNotStart =>
      'Could not start the payment. Please try again.';

  @override
  String get walkiePlan_orderCouponApplied => 'Coupon applied successfully!';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return 'Coupon applied! You saved $amount';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'Coupon removed successfully';

  @override
  String get walkiePlan_orderCreateFailed =>
      'Failed to create payment order. Please try again.';

  @override
  String get walkiePlan_orderDiscount => 'Discount';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return 'Discount ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint =>
      'Choose from GPay, PhonePe, Cards, NetBanking or Wallets on next step.';

  @override
  String get walkiePlan_orderEncryptedPayment => 'Encrypted Payment';

  @override
  String get walkiePlan_orderEnterValidCoupon =>
      'Please enter a valid coupon code';

  @override
  String get walkiePlan_orderForMultipleMembers => 'For Multiple Members';

  @override
  String get walkiePlan_orderForSingleMember => 'For Single Member';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return 'GST ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      'Pay securely with International Credit/Debit Cards (Visa, Mastercard, Amex).';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      'Pay securely with International Credit/Debit Cards (Visa, Mastercard, Amex) or PayPal.';

  @override
  String get walkiePlan_orderInvalidCoupon => 'Invalid or expired coupon code';

  @override
  String walkiePlan_orderMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Members',
      one: '1 Member',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'Members';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Members × $rate',
      one: '1 Member × $rate',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderNetBanking => 'NetBanking';

  @override
  String get walkiePlan_orderOnlineViaRazorpay => 'Online Payment via Razorpay';

  @override
  String get walkiePlan_orderOpeningCheckout =>
      'Opening Razorpay Payment Checkout...';

  @override
  String get walkiePlan_orderPaymentDetails => 'Payment Details';

  @override
  String get walkiePlan_orderPaymentMethod => 'Payment Method';

  @override
  String get walkiePlan_orderPricePerMember => 'Price per member';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return 'Proceed to Pay • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => 'Processing Payment...';

  @override
  String get walkiePlan_orderRetryPay => 'Retry Pay';

  @override
  String get walkiePlan_orderSecureBadge => 'SECURE';

  @override
  String get walkiePlan_orderSubtitle =>
      'Review your plan details & proceed to pay';

  @override
  String get walkiePlan_orderSubtotal => 'Subtotal';

  @override
  String get walkiePlan_orderTaxExport => 'Tax (0% Export)';

  @override
  String get walkiePlan_orderTermsConditions => 'Terms & Conditions';

  @override
  String get walkiePlan_orderTitle => 'Order Summary';

  @override
  String get walkiePlan_orderTotalAmount => 'Total Amount';

  @override
  String get walkiePlan_orderTotalPayable => 'Total Payable';

  @override
  String get walkiePlan_orderUnableToLoad => 'Unable to load order summary.';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return 'VAT / Tax ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => 'Wallets';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return 'You saved $amount on this order!';
  }

  @override
  String get walkiePlan_payAnnualPlan => 'Annual Plan';

  @override
  String get walkiePlan_payBadgeCompleted => 'Completed';

  @override
  String get walkiePlan_payBadgeInProgress => 'In Progress';

  @override
  String get walkiePlan_payBadgePending => 'Pending';

  @override
  String get walkiePlan_payCancelledByUser =>
      'Payment was cancelled by user. No amount has been charged to your account.';

  @override
  String get walkiePlan_payCouldNotBeProcessed =>
      'Payment could not be processed';

  @override
  String get walkiePlan_payFailedContactSupport => 'Contact Support';

  @override
  String walkiePlan_payFailedOn(String time) {
    return 'Payment failed on $time';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'We couldn\'t complete your payment.\nPlease try again or use a different payment method.';

  @override
  String get walkiePlan_payFailedSubtitleShort =>
      'We couldn\'t complete your payment';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      'Need help with your payment? Our team is available 24/7 to assist you.';

  @override
  String get walkiePlan_payFailedTitle => 'Payment Failed';

  @override
  String get walkiePlan_payIndividualFeatures =>
      'Real-time monitoring • Instant alerts';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return 'Payment initiated on $time';
  }

  @override
  String get walkiePlan_payIntervalMonth => 'month';

  @override
  String get walkiePlan_payIntervalPlan => 'plan';

  @override
  String get walkiePlan_payIntervalQuarter => 'quarter';

  @override
  String get walkiePlan_payIntervalYear => 'year';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'Credit Card ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'Debit Card ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational => 'International Card / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'NetBanking ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'Razorpay Payment';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'Razorpay Checkout';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / Card)';

  @override
  String get walkiePlan_payMethodUpi => 'UPI Payment';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'Wallet ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue =>
      'Network connection issue during payment. Please check your internet and try again.';

  @override
  String get walkiePlan_payNotCompleted =>
      'Your payment was not completed. No amount has been charged to your account.';

  @override
  String get walkiePlan_payOtpCharge => 'OTP charge';

  @override
  String get walkiePlan_payOtpChargeDetails => 'OTP Charge Details';

  @override
  String get walkiePlan_payOtpChargedPerLogin =>
      'Charged per login. Resending the OTP is free';

  @override
  String get walkiePlan_payOtpCharges => 'OTP charges';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'Please do not close the app. We will notify you once the payment is confirmed and your plan is activated.';

  @override
  String get walkiePlan_payPendingStillInProgress =>
      'Payment still in progress. We\'ll update once confirmed.';

  @override
  String get walkiePlan_payPendingStillProcessing =>
      'Payment status is still processing. Please wait.';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      'Your payment is being processed by the payment provider.\nThis may take a few minutes.';

  @override
  String get walkiePlan_payPendingSubtitleShort =>
      'Your payment is being processed';

  @override
  String get walkiePlan_payPendingTitle => 'Payment Pending';

  @override
  String get walkiePlan_payPlanDetails => 'Plan Details';

  @override
  String get walkiePlan_payRefreshStatus => 'Refresh Status';

  @override
  String get walkiePlan_payStatusTitle => 'Payment Status';

  @override
  String get walkiePlan_payStepActivate => 'Activate Plan';

  @override
  String get walkiePlan_payStepActivateSub =>
      'Your plan will be activated automatically';

  @override
  String get walkiePlan_payStepInitiated => 'Payment Initiated';

  @override
  String get walkiePlan_payStepProcessing => 'Processing Payment';

  @override
  String get walkiePlan_payStepProcessingSub =>
      'Your payment is being confirmed';

  @override
  String get walkiePlan_payTeamFeatures =>
      'Multi-member access • Instant alerts';

  @override
  String get walkiePlan_payTotalPerOtp => 'Total per OTP';

  @override
  String get walkiePlan_payTryAgain => 'Try Again';

  @override
  String get walkiePlan_payViewPlanDetails => 'View Plan Details';

  @override
  String get walkiePlan_perMember => 'per member';

  @override
  String get walkiePlan_planFallback => 'Plan';

  @override
  String get walkiePlan_quarterlyPlan => 'Quarterly Plan';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'Please complete the transaction in the Razorpay payment window.';

  @override
  String get walkiePlan_razorpayCompletePayment => 'Complete Payment';

  @override
  String get walkiePlan_razorpayConfirmingWithBank =>
      'Payment was initiated. We are confirming with the bank.';

  @override
  String get walkiePlan_razorpayConnecting => 'Connecting to Razorpay...';

  @override
  String get walkiePlan_razorpayCouldNotProcess =>
      'The payment could not be processed. Please try again.';

  @override
  String get walkiePlan_razorpayFailedTryAgain =>
      'Payment failed. Please try again.';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1 Month Active';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return 'Pay $amount via Razorpay';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => 'Payment Cancelled';

  @override
  String get walkiePlan_razorpayPaymentIdCopied =>
      'Payment ID copied to clipboard!';

  @override
  String get walkiePlan_razorpayPciCompliant => '100% Safe & PCI-DSS Compliant';

  @override
  String get walkiePlan_razorpayPendingConfirmation =>
      'Payment is pending confirmation.';

  @override
  String get walkiePlan_razorpayProcessing => 'Processing with Razorpay...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return 'Amount: $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied =>
      'Receipt details copied to clipboard!';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return 'Date: $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return 'Payment Mode: $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return 'Order ID: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return 'Payment ID: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'Plan: $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => 'Status: Completed';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'FG Tracker Payment Receipt';

  @override
  String get walkiePlan_razorpayRetryPayment => 'Retry Payment';

  @override
  String get walkiePlan_razorpaySecureCheckout =>
      'Secure Checkout powered by Razorpay';

  @override
  String get walkiePlan_razorpaySslEncrypted =>
      'Transactions are encrypted with end-to-end 256-bit SSL security.';

  @override
  String get walkiePlan_razorpaySupportedModes => 'Supported Payment Modes';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => 'Total Payable Amount';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return 'Unable to launch payment gateway: $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed => 'Payment verification failed.';

  @override
  String get walkiePlan_seatAssignedSeat => 'Assigned Seat';

  @override
  String get walkiePlan_seatAssignment => 'Seat Assignment';

  @override
  String get walkiePlan_seatTeamAccess => 'Team Access';

  @override
  String get walkiePlan_seatTeamMember => 'Team Member';

  @override
  String get walkiePlan_secureEncryptedPayment => 'Secure & Encrypted Payment';

  @override
  String get walkiePlan_successAccessActivated => 'Access Activated';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      'Your personal Walkie-Talkie access is active now.';

  @override
  String get walkiePlan_successAmountPaid => 'Amount Paid';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'You can assign Walkie access later from Team Settings anytime.';

  @override
  String get walkiePlan_successAssignMembers => 'Assign Members';

  @override
  String get walkiePlan_successAssignWalkieAccess => 'Assign Walkie Access';

  @override
  String get walkiePlan_successChooseMembersDesc =>
      'Choose which members can use Walkie Talkie.';

  @override
  String get walkiePlan_successContinueHome => 'Continue to Home';

  @override
  String get walkiePlan_successDateTime => 'Date & Time';

  @override
  String get walkiePlan_successDefaultPaymentMethod => 'Razorpay (UPI / Card)';

  @override
  String get walkiePlan_successIndividualActive =>
      'Your Individual Plan is now active';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      'Your individual plan is active. Head to home and start talking.';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      'Your individual subscription is active and linked directly to your account.';

  @override
  String get walkiePlan_successManageAccessNote =>
      'You can manage or change Walkie access anytime from Team Settings.';

  @override
  String get walkiePlan_successMaybeLater => 'Maybe Later';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'Your plan is active. Team members will not have Walkie access until you assign them.';

  @override
  String get walkiePlan_successNotNow => 'Not Now?';

  @override
  String get walkiePlan_successPaid => 'PAID';

  @override
  String get walkiePlan_successPaymentId => 'Payment ID';

  @override
  String get walkiePlan_successPaymentIdCopied =>
      'Payment ID copied to clipboard!';

  @override
  String get walkiePlan_successPaymentMode => 'Payment Mode';

  @override
  String get walkiePlan_successPaymentReceipt => 'Payment Receipt';

  @override
  String get walkiePlan_successPushToTalkDesc =>
      'Push to talk and connect instantly with your team.';

  @override
  String get walkiePlan_successRazorpayVerified => 'Razorpay Verified';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return 'Amount: $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied =>
      'Receipt details copied to clipboard!';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return 'Date: $date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'FG Tracker Payment Receipt';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return 'Order ID: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return 'Payment ID: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return 'Payment Mode: $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'Plan: $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => 'Status: Completed';

  @override
  String get walkiePlan_successSelectChannel => 'Select Channel';

  @override
  String get walkiePlan_successSelectChannelDesc =>
      'Join any group or channel to connect with members.';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'Select team members who will use Walkie Talkie.';

  @override
  String get walkiePlan_successSetUpTeam => 'Set Up Team';

  @override
  String get walkiePlan_successSetUpTeamDesc =>
      'Invite members, manage roles and permissions.';

  @override
  String get walkiePlan_successShareReceipt => 'Share Receipt';

  @override
  String get walkiePlan_successStartCommunicating => 'Start Communicating';

  @override
  String get walkiePlan_successStatus => 'Status';

  @override
  String get walkiePlan_successSuccessful => 'Successful';

  @override
  String get walkiePlan_successTeamActive => 'Your Team Plan is now active';

  @override
  String get walkiePlan_successTeamReady => 'Your team is ready to go!';

  @override
  String get walkiePlan_successTitle => 'Purchase Successful!';

  @override
  String walkiePlan_successValidTill(String date) {
    return 'Valid till $date';
  }

  @override
  String get walkiePlan_successVisitHome => 'Visit Home Screen';

  @override
  String get walkiePlan_successWhatsNext => 'What\'s Next?';

  @override
  String get walkiePlan_teamPlan => 'Team Plan';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'Team Plan ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => '7 Days Trial Period';

  @override
  String get walkiePlan_trialActiveLabel => 'TRIAL ACTIVE';

  @override
  String get walkiePlan_trialActiveSubscription => 'Active Subscription';

  @override
  String get walkiePlan_trialActiveSubscriptions => 'Active Subscriptions';

  @override
  String get walkiePlan_trialAvailableToStart => 'Available to start';

  @override
  String get walkiePlan_trialCheckConnectionRetry =>
      'Please check your internet connection and try again.';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'Choose a plan below to start using Walkie Talkie.';

  @override
  String get walkiePlan_trialChooseSubscription =>
      'Choose a subscription to continue using Walkie Talkie.';

  @override
  String get walkiePlan_trialCompleted => 'Trial Completed';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration Free';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return 'Ended on $date';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return 'Enjoy all Walkie Talkie features free for $duration.\nNo payment required.';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      'Enjoy Walkie Talkie during your active trial period.';

  @override
  String get walkiePlan_trialErrAccessMissing =>
      'Walkie-Talkie access information is missing.';

  @override
  String get walkiePlan_trialErrFetchDetails =>
      'Unable to fetch Walkie-Talkie details.';

  @override
  String get walkiePlan_trialErrInvalidResponse =>
      'Invalid response received from the server.';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'No internet connection. Please check your network and try again.';

  @override
  String get walkiePlan_trialErrOverviewMissing =>
      'Walkie-Talkie overview data is missing.';

  @override
  String get walkiePlan_trialErrTimeout =>
      'The request timed out. Please try again.';

  @override
  String get walkiePlan_trialErrUnableToLoad =>
      'Unable to load Walkie-Talkie details. Please check your connection.';

  @override
  String get walkiePlan_trialExpired => 'Trial Expired';

  @override
  String get walkiePlan_trialExpiredLabel => 'TRIAL EXPIRED';

  @override
  String get walkiePlan_trialExpiringSoon => 'Expiring soon';

  @override
  String get walkiePlan_trialFeatClearAudio => 'Clear Audio';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'High quality voice';

  @override
  String get walkiePlan_trialFeatGroupComm => 'Group Communication';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => 'Connect with your team';

  @override
  String get walkiePlan_trialFeatPtt => 'Push-to-talk';

  @override
  String get walkiePlan_trialFeatPttDesc => 'Instant voice communication';

  @override
  String get walkiePlan_trialFeatUnlimited => 'Unlimited Usage';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => 'Use without any limits';

  @override
  String get walkiePlan_trialFreeAvailable => 'Free Trial Available';

  @override
  String get walkiePlan_trialFreeTrialLabel => 'FREE TRIAL';

  @override
  String get walkiePlan_trialFreeTrialRunning => 'Free Trial Running';

  @override
  String get walkiePlan_trialFullAccess => 'Full access to all features';

  @override
  String get walkiePlan_trialFullyConsumed =>
      'Your free trial has been completely consumed.';

  @override
  String get walkiePlan_trialHasEnded => 'Your Trial Has Ended';

  @override
  String get walkiePlan_trialHeaderInstant =>
      'Instantly communicate with your group';

  @override
  String get walkiePlan_trialHeaderPlanStatus =>
      'Your plan & subscription status';

  @override
  String walkiePlan_trialHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hours',
      one: '1 Hour',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours left',
      one: '1 hour left',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHr(int count) {
    return '$count hr';
  }

  @override
  String walkiePlan_trialHrMin(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String get walkiePlan_trialIsActive => 'Your Trial Is Active';

  @override
  String walkiePlan_trialMin(int count) {
    return '$count min';
  }

  @override
  String walkiePlan_trialMinSec(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String walkiePlan_trialMinsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mins left',
      one: '1 min left',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minutes',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_trialNoActivePlan => 'No Active Plan';

  @override
  String get walkiePlan_trialNoCardRequired =>
      'Use anytime within 7 days  •  No credit card required';

  @override
  String get walkiePlan_trialNoInternetTitle => 'No Internet Connection';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return 'No payment needed now. After your trial, you can choose to continue with a paid plan ($price/person) if you like.';
  }

  @override
  String get walkiePlan_trialPeriodMonth => 'month';

  @override
  String get walkiePlan_trialRetrying => 'Retrying...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count sec';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return 'Start $duration Free Trial';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial => 'Start Your Free Trial';

  @override
  String get walkiePlan_trialStatusCompleted => 'Completed';

  @override
  String get walkiePlan_trialStatusExpired => 'Expired';

  @override
  String get walkiePlan_trialSubscriptionActive => 'Subscription Active';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'Your Walkie Talkie subscription has ended. Renew a plan to keep talking with your team.';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'Subscription Expired';

  @override
  String get walkiePlan_trialTalkFree => 'Talk free with your group.';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return 'Talk free with your group till $date.';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg =>
      'You have Walkie Talkie access through your team plan.';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return '$time left';
  }

  @override
  String get walkiePlan_trialTimeRemaining => 'Trial Time Remaining';

  @override
  String get walkiePlan_trialTimeUsedUp => 'Trial time used up';

  @override
  String get walkiePlan_trialTryAgain => 'Try Again';

  @override
  String get walkiePlan_trialUnableToLoadTitle =>
      'Unable to Load Walkie Talkie';

  @override
  String get walkiePlan_trialUsage => 'Trial Usage';

  @override
  String get walkiePlan_trialUseAnytime7Days => 'Use trial anytime in 7 days';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return 'Use your $duration trial anytime within 7 days.';
  }

  @override
  String get walkiePlan_trialUsed => 'Trial Used';

  @override
  String get walkiePlan_trialValidityPeriod => 'Trial Validity Period';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'Walkie Talkie';

  @override
  String get walkiePlan_trialWhatYouCanDo => 'What you can do during the trial';

  @override
  String get walkiePlan_unableToConnect =>
      'Unable to connect to server. Please try again.';

  @override
  String get walkiePlan_yearlyPlan => 'Yearly Plan';

  @override
  String get walkie_aMember => 'A member';

  @override
  String get walkie_accept => 'Accept';

  @override
  String get walkie_activeAccess => 'Active Access';

  @override
  String get walkie_activeBadge => 'Active';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Active in Walkie',
      one: '1 Active in Walkie',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'Active Member';

  @override
  String get walkie_admin => 'Admin';

  @override
  String get walkie_adminMuted => 'Admin • Muted';

  @override
  String get walkie_adminOnlyAction => 'Admin Only Action';

  @override
  String get walkie_adminOnlyActionMessage =>
      'Only group admin can send notification alerts to members.';

  @override
  String walkie_alertSentMessage(String name) {
    return 'Notification sent to $name. Retry available in 10s.';
  }

  @override
  String get walkie_alertSentTitle => 'Alert Sent';

  @override
  String get walkie_assignMembersToCommunicate =>
      'Assign members to communicate in this group';

  @override
  String get walkie_assignedByYou => 'Assigned by You';

  @override
  String walkie_assignedCount(int count) {
    return 'Assigned ($count)';
  }

  @override
  String get walkie_assignedSeats => 'Assigned Seats';

  @override
  String get walkie_audioBluetooth => 'Bluetooth';

  @override
  String get walkie_audioHeadset => 'Headset';

  @override
  String get walkie_audioOutput => 'Audio Output';

  @override
  String get walkie_audioPhone => 'Phone';

  @override
  String get walkie_audioSpeaker => 'Speaker';

  @override
  String get walkie_audioWiredHeadphones => 'Wired Headphones';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return 'Auto-unlock in ${seconds}s';
  }

  @override
  String get walkie_availableMembers => 'Available Members';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You can assign up to $count members in this group',
      one: 'You can assign up to 1 member in this group',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat =>
      'Cannot remove seat assigned by another admin';

  @override
  String get walkie_cannotSpeak => 'Cannot speak on this channel';

  @override
  String get walkie_channelBusy => 'Channel is busy';

  @override
  String get walkie_channelLocked => 'Channel locked';

  @override
  String get walkie_channelSpeaking => 'Channel speaking...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return 'Could not set $group as active speaking channel.';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'Channel Switch Error';

  @override
  String get walkie_channelUnlocked => 'Channel unlocked';

  @override
  String get walkie_chat => 'Chat';

  @override
  String get walkie_checkNetworkTryAgain =>
      'Please check your network connection and try again.';

  @override
  String get walkie_chooseAPlan => 'Choose a Plan';

  @override
  String get walkie_connected => 'Connected';

  @override
  String get walkie_connectedWaiting =>
      'Connected to channel • Waiting for others to join';

  @override
  String get walkie_connectingChannel => 'Connecting to channel...';

  @override
  String get walkie_consumingTrial => 'Consuming trial...';

  @override
  String get walkie_continueListenOnly => 'Continue in Listen-Only Mode';

  @override
  String walkie_currentlyAssigned(int count) {
    return 'Currently Assigned ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'Walkie Group';

  @override
  String get walkie_description => 'Description';

  @override
  String get walkie_disconnected => 'Disconnected';

  @override
  String get walkie_editAssignedMembers => 'Edit Assigned Members';

  @override
  String get walkie_enable => 'Enable';

  @override
  String walkie_errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get walkie_exitWalkie => 'Exit Walkie';

  @override
  String get walkie_exitWalkieMessage =>
      'You will disconnect from this walkie channel. You will still remain a member of the group.';

  @override
  String get walkie_exitWalkieTitle => 'Exit Walkie?';

  @override
  String get walkie_fairConnection => 'Fair Connection';

  @override
  String walkie_fairConnectionMs(int ms) {
    return 'Fair Connection (${ms}ms)';
  }

  @override
  String get walkie_featureAllDevices => 'Use on All Devices';

  @override
  String get walkie_featureEasyCoordination => 'Easy group\ncoordination';

  @override
  String get walkie_featureHoldToTalk => 'Hold to talk';

  @override
  String get walkie_featurePtt => 'Push-to-talk\ncommunication';

  @override
  String get walkie_featureQuickGroup => 'Quick group\ncommunication';

  @override
  String get walkie_featureRealtime => 'Real-time Connectivity';

  @override
  String get walkie_featureSafeReliable => 'Safe & Reliable';

  @override
  String get walkie_featureStayConnected => 'Stay Connected Always';

  @override
  String get walkie_featureTeamCommunication => 'Team Communication';

  @override
  String get walkie_featureUnlimited => 'Unlimited';

  @override
  String get walkie_fieldTeam => 'Field Team';

  @override
  String get walkie_freeTrialEnded => 'Free trial ended';

  @override
  String get walkie_freeTrialEndedMessage =>
      'Your 1 hour free trial for Walkie Talkie has ended.\nUpgrade now to continue using group communication\nwith your team.';

  @override
  String get walkie_freeTrialEndedTitle => 'Free Trial Ended';

  @override
  String get walkie_genericError => 'Walkie Talkie Error';

  @override
  String get walkie_getPlan => 'Get Plan';

  @override
  String walkie_goodConnectionMs(int ms) {
    return 'Good Connection (${ms}ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'Group Code: $code';
  }

  @override
  String get walkie_groupCommunication => 'Group Communication';

  @override
  String get walkie_groupFallback => 'Group';

  @override
  String get walkie_groupMembers => 'Group Members';

  @override
  String get walkie_heroSubtitle =>
      'Use push-to-talk voice communication with your group\nwithout making a phone call.';

  @override
  String get walkie_heroTitle => 'Stay Connected, Talk Instantly';

  @override
  String get walkie_holdToTalk => 'Hold to Talk';

  @override
  String get walkie_holdToTalkSlideLock => 'Hold to Talk, Slide Up to Lock';

  @override
  String get walkie_inWalkieChannel => 'In Walkie Channel';

  @override
  String get walkie_individualActiveUpgrade =>
      'Individual Plan active (Self access only) • Upgrade to Team Plan to assign members.';

  @override
  String get walkie_individualLimitMessage =>
      'Your Individual Plan allows 1 member seat only. To assign multiple members and connect your entire team, please upgrade to a Team Plan.';

  @override
  String get walkie_individualPlan => 'Individual Plan';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (Individual)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      'Individual Plan (Self Access Only) • Upgrade to Team to assign members';

  @override
  String get walkie_individualSubscribedSelf =>
      'Individual Plan • Subscribed by Self';

  @override
  String get walkie_info => 'Info';

  @override
  String walkie_isSpeaking(String name) {
    return '$name is speaking...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name is talking...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Joined',
      one: '1 Joined',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String get walkie_listenOnly => 'Listen Only';

  @override
  String get walkie_listenOnlyTapPlan => 'Listen Only — Tap to View Plan';

  @override
  String get walkie_listening => 'Listening';

  @override
  String get walkie_listeningOnly => 'Listening Only';

  @override
  String get walkie_live => 'LIVE';

  @override
  String get walkie_lockTimeout => 'Lock timeout — Mic released';

  @override
  String get walkie_lockedTapMic => 'Locked — Tap mic to stop';

  @override
  String get walkie_maybeLater => 'Maybe Later';

  @override
  String get walkie_member => 'Member';

  @override
  String get walkie_membersInChannel => 'Members In Channel';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Members Online',
      one: 'Member Online',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed => 'Failed to update assigned members';

  @override
  String get walkie_membersUpdated => 'Assigned members updated successfully';

  @override
  String get walkie_micAccessRequired => 'Microphone access required to talk.';

  @override
  String get walkie_micDisabledMessage =>
      'Microphone access is disabled in device settings. To speak in this group, please allow microphone access in Settings.\n\nYou can still listen to other members.';

  @override
  String get walkie_micPermissionRequired => 'Microphone permission required';

  @override
  String get walkie_micPermissionTitle => 'Microphone Permission';

  @override
  String get walkie_micRequiredMessage =>
      'Microphone permission is required to talk in this Walkie-Talkie group.\n\nYou can still listen to others without enabling microphone.';

  @override
  String get walkie_muteMe => 'Mute Me';

  @override
  String get walkie_muted => 'Muted';

  @override
  String get walkie_mutedInWalkie => 'Muted • In Walkie';

  @override
  String get walkie_mutedListeningOnly => 'You are muted — Listening only';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name speaking...';
  }

  @override
  String get walkie_noActivePlan => 'No Active Plan';

  @override
  String get walkie_noAvailableMembers => 'No available members';

  @override
  String get walkie_noBluetoothDevice =>
      'No Bluetooth audio device connected. Please pair your Bluetooth headset in settings.';

  @override
  String get walkie_noGroupsFound => 'No groups found';

  @override
  String get walkie_noMembersAssigned => 'No members currently assigned';

  @override
  String get walkie_noMembersFound => 'No members found';

  @override
  String get walkie_noMembersFoundTitle => 'No Members Found';

  @override
  String get walkie_noMembersMatch => 'No Members Match';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return 'No members match \'$query\'';
  }

  @override
  String get walkie_noMembersToAssign =>
      'No group members available to assign.';

  @override
  String get walkie_noNameGroup => 'No Name Group';

  @override
  String get walkie_noPlanSubscribeAssign =>
      'No active plan • Subscribe to assign members';

  @override
  String get walkie_noSeatMessage =>
      'You have an active Team Plan, but all active voice seats are currently assigned to other team members.\n\nYou can listen to group conversations in real-time, but to speak, you must assign a seat to yourself or upgrade your plan.';

  @override
  String get walkie_noSeatTitle => 'No Voice Seat Assigned';

  @override
  String get walkie_noSeatsRefreshing =>
      'No team seats available. Refreshing member list...';

  @override
  String get walkie_noSubscriptionMessage =>
      'You do not have an active Walkie Talkie subscription. Subscribe to a plan to assign members and start instant voice communication.';

  @override
  String get walkie_noTeamSubscription => 'No active team subscription found';

  @override
  String get walkie_noValidMembers => 'No valid members selected to assign';

  @override
  String get walkie_noVoiceSeatListenOnly =>
      'No voice seat assigned — You are in Listen-Only mode';

  @override
  String get walkie_noWiredDevice =>
      'No wired earphones or headset connected. Please plug them into your device.';

  @override
  String get walkie_notConnected => 'Not connected';

  @override
  String get walkie_notifLeave => 'Leave';

  @override
  String get walkie_notifOpenWalkie => 'Open Walkie';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name stopped talking';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name is talking';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return 'Could not update notification setting for $group. Please try again.';
  }

  @override
  String get walkie_notificationSettingTitle => 'Notification Setting';

  @override
  String get walkie_onlyAdminCanAlert => 'Only Group Admin can send alert';

  @override
  String get walkie_openWalkieTalkie => 'Open Walkie Talkie';

  @override
  String get walkie_otherTeam => 'Other Team';

  @override
  String get walkie_othersWontHear => 'Others won\'t hear you';

  @override
  String get walkie_planRequiredTitle => 'Walkie Talkie Plan Required';

  @override
  String get walkie_planRequiredToTalk => 'Plan Required to Talk';

  @override
  String get walkie_planStartsOnFirstAssign =>
      'Plan starts when the first member is assigned.';

  @override
  String get walkie_poorConnection => 'Poor network connection — Audio may lag';

  @override
  String get walkie_preparingAudio => 'Preparing audio...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'Purchase a Team Plan to assign Walkie-Talkie access to members.';

  @override
  String get walkie_purchaseUpgradePlan => 'Purchase / Upgrade Plan';

  @override
  String get walkie_ready => 'Ready';

  @override
  String get walkie_reconnecting => 'Reconnecting...';

  @override
  String get walkie_reconnectingServer => 'Reconnecting to walkie server...';

  @override
  String get walkie_releaseToStop => 'Release to Stop';

  @override
  String get walkie_removeAll => 'Remove All';

  @override
  String get walkie_searchGroups => 'Search groups';

  @override
  String get walkie_searchMembers => 'Search members...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total seats';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '$total Total Seats • $assigned Assigned • $available Available';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '$assigned / $total Seats Used';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get walkie_selectAtLeastOne =>
      'Please select at least one member to assign';

  @override
  String get walkie_selectGroupFirst => 'Please select a group first';

  @override
  String get walkie_selectGroupToConnect => 'Select a group to connect';

  @override
  String get walkie_selected => 'Selected';

  @override
  String get walkie_selfAccess => 'Self Access';

  @override
  String get walkie_selfPlan => 'Self Plan';

  @override
  String get walkie_slideUpToLock => 'Slide up to lock';

  @override
  String get walkie_someone => 'Someone';

  @override
  String get walkie_someoneSpeaking => 'Someone is speaking...';

  @override
  String get walkie_speaking => 'Speaking...';

  @override
  String walkie_startFreeTrial(String duration) {
    return 'Start $duration Free Trial';
  }

  @override
  String get walkie_strongConnection => 'Strong Connection';

  @override
  String walkie_strongConnectionMs(int ms) {
    return 'Strong Connection (${ms}ms)';
  }

  @override
  String get walkie_subscribeToStartTalk =>
      'Subscribe to start voice talk & assign members';

  @override
  String get walkie_subscribed => 'Subscribed';

  @override
  String get walkie_talking => 'Talking...';

  @override
  String get walkie_tapToUnlock => 'Tap to Unlock';

  @override
  String get walkie_teamAssignedElsewhere => 'Team Plan • Assigned Elsewhere';

  @override
  String get walkie_teamPlan => 'Team Plan';

  @override
  String get walkie_teamPlanRequired => 'Team Plan Required';

  @override
  String get walkie_teamPlanRequiredToAssign =>
      'Team Plan required to assign members';

  @override
  String get walkie_teamPlanStatus => 'Team Plan Status';

  @override
  String get walkie_teamSeatMember => 'Team Seat Member';

  @override
  String get walkie_title => 'Walkie Talkie';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count total',
      one: '1 total',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => '1 hr trial active';

  @override
  String get walkie_trialEndedSubscribe =>
      'Free trial ended — Please subscribe to continue';

  @override
  String get walkie_unableToConnectReconnecting =>
      'Unable to connect to channel — Reconnecting...';

  @override
  String get walkie_unavailable => 'Unavailable';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'Update Members ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'Updating Members...';

  @override
  String get walkie_upgradeAddSeats => 'Upgrade & Add Seats';

  @override
  String get walkie_upgradeNow => 'Upgrade Now';

  @override
  String get walkie_upgradeTeamAssign =>
      'Upgrade to Team Plan (Assign Members)';

  @override
  String get walkie_upgradeToTeamPlan => 'Upgrade to Team Plan';

  @override
  String walkie_userCancelled(String name) {
    return '$name cancelled';
  }

  @override
  String walkie_userJoined(String name) {
    return '$name joined';
  }

  @override
  String walkie_userLeft(String name) {
    return '$name left';
  }

  @override
  String walkie_validTill(String date) {
    return 'Valid till $date';
  }

  @override
  String get walkie_viewPlan => 'View Plan';

  @override
  String get walkie_voiceNotPermitted => 'Voice transmission not permitted';

  @override
  String get walkie_weakSignal => 'Weak Signal';

  @override
  String walkie_weakSignalMs(int ms) {
    return 'Weak Signal (${ms}ms)';
  }

  @override
  String get walkie_youAreConnected => 'You are Connected';

  @override
  String get walkie_yourVoiceAccess => 'Your Voice Access';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Download for Android: $playStoreLink\n\nDownload for iOS: $appStoreLink';
  }

  @override
  String get widget_live => 'Live';

  @override
  String get widget_lostConnection => 'Lost Connection';

  @override
  String get widget_manageGroups => 'Manage your groups easily';

  @override
  String get widget_noInternetBody =>
      'Whoops... no internet connection found. check you connection';

  @override
  String get widget_notSeenYet => 'Not seen yet';

  @override
  String get widget_pinnedMessage => 'Pinned Message';

  @override
  String get widget_private => 'Private';

  @override
  String get widget_refreshPage => 'Refresh the page';

  @override
  String get widget_seen => 'Seen';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count of $total)';
  }

  @override
  String get widget_somethingWentWrongTitle => 'Something went wrong';

  @override
  String get widget_userFallback => 'User';
}
