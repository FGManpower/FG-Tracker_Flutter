// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get about_aboutUs => 'हमारे बारे में';

  @override
  String get about_address => 'पता';

  @override
  String get about_appBarTitle => 'FG ट्रैकर के बारे में';

  @override
  String get about_company => 'कंपनी';

  @override
  String get about_contactUs => 'संपर्क करें';

  @override
  String get about_developerEmail => 'डेवलपर ईमेल';

  @override
  String get about_downloadTitle => '📱 ऐप डाउनलोड करें';

  @override
  String get about_howItWorksIntro =>
      'FG ट्रैकर समूह यात्रा समन्वय को सरल बनाता है। ऐसे:';

  @override
  String get about_howItWorksTitle => '⚙️ यह कैसे काम करता है';

  @override
  String get about_howStep1 => 'एक समूह बनाएं';

  @override
  String get about_howStep2 =>
      'अपने साथियों के साथ समूह कोड या QR कोड साझा करें';

  @override
  String get about_howStep3 =>
      'प्रत्येक सदस्य साझा किए गए कोड या QR से जुड़ता है';

  @override
  String get about_howStep4 =>
      'साझा मानचित्र पर वास्तविक समय में सभी का लाइव स्थान ट्रैक करें';

  @override
  String get about_howStep5 =>
      'अधिक लोगों को आसानी से आमंत्रित करने के लिए शेयर सुविधा का उपयोग करें';

  @override
  String get about_intro =>
      'FG ट्रैकर समूह में यात्रा करते समय जुड़े रहने और सुरक्षित रहने के लिए आपका आदर्श साथी है। चाहे पारिवारिक यात्रा हो, दोस्तों के साथ पिकनिक हो या सहकर्मियों के साथ सफर — FG ट्रैकर सुनिश्चित करता है कि कोई पीछे न छूटे।';

  @override
  String get about_privacyBody =>
      'आपकी सुरक्षा और गोपनीयता महत्वपूर्ण है। FG ट्रैकर आपके समूह से बाहर किसी के साथ आपका स्थान साझा नहीं करता है। सभी डेटा एन्क्रिप्टेड है और केवल आपके अधिकृत लोगों के साथ साझा किया जाता है।';

  @override
  String get about_privacyPolicy => 'गोपनीयता नीति';

  @override
  String get about_privacyTitle => '🔐 गोपनीयता और सुरक्षा';

  @override
  String get about_supportEmail => 'सहायता ईमेल';

  @override
  String get about_supportTitle => '📩 सहायता और डेवलपर जानकारी';

  @override
  String get about_termsConditions => 'नियम और शर्तें';

  @override
  String get about_title => 'परिचय';

  @override
  String get about_website => 'वेबसाइट';

  @override
  String get about_welcomeTitle => 'FG ट्रैकर में आपका स्वागत है';

  @override
  String get about_whyBuiltFor =>
      'परिवारों, दोस्तों और छोटी टीमों के लिए निर्मित।';

  @override
  String get about_whyChooseTitle => '🌟 FG ट्रैकर क्यों चुनें?';

  @override
  String get about_whyEasy =>
      'गोपनीयता नियंत्रण के साथ उपयोग में आसान और हल्का ऐप।';

  @override
  String get about_whyNoCalls =>
      'कॉल या मैसेज करने की जरूरत नहीं—मानचित्र पर लाइव ट्रैक करें।';

  @override
  String get about_whyRealTime =>
      'सभी समूह सदस्यों के साथ रीयल-टाइम स्थान साझाकरण।';

  @override
  String appUpdate_checkError(String error) {
    return 'अपडेट जांचने में त्रुटि: $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => 'क्या आप बाहर निकलना चाहते हैं?';

  @override
  String get appUpdate_noUpdateAvailable => 'कोई अपडेट उपलब्ध नहीं है';

  @override
  String get appUpdate_restartApp => 'ऐप पुनरारंभ करें';

  @override
  String get appUpdate_updateApp => 'ऐप अपडेट करें';

  @override
  String get appUpdate_updateAvailable => 'अपडेट उपलब्ध है';

  @override
  String get appUpdate_updateAvailableMessage =>
      'एक नया अपडेट उपलब्ध है। कृपया ऐप अपडेट करें';

  @override
  String get appUpdate_updateUnavailable => 'अपडेट अनुपलब्ध है';

  @override
  String appUpdate_updatingProgress(int progress) {
    return 'अपडेट हो रहा है... $progress%';
  }

  @override
  String get attendance_addOption => 'एक और विकल्प जोड़ें';

  @override
  String get attendance_admin => 'एडमिन';

  @override
  String get attendance_allowChange => 'जवाब बदलने दें';

  @override
  String get attendance_allowChangeSubtitle =>
      'सदस्य अपना जवाब बदल या हटा सकते हैं';

  @override
  String get attendance_askCommunity => 'अपने ग्रुप से पूछें';

  @override
  String get attendance_cameraPermissionRequired =>
      'हाज़िरी लगाने के लिए कैमरे की अनुमति ज़रूरी है।';

  @override
  String get attendance_cameraStartFailed => 'कैमरा शुरू नहीं हो सका।';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'कैमरा शुरू नहीं हो सका ($code)।';
  }

  @override
  String get attendance_cameraStarting => 'कैमरा शुरू हो रहा है…';

  @override
  String get attendance_captureFailedBlink =>
      'फ़ोटो नहीं ली जा सकी। फिर से पलक झपकाएँ';

  @override
  String attendance_capturedAtVerified(String time) {
    return '$time पर ली गई • सत्यापित';
  }

  @override
  String get attendance_capturedCheck => 'फ़ोटो ली गई ✓';

  @override
  String get attendance_changeResponse => 'जवाब बदलें';

  @override
  String get attendance_chooseFolder => 'कोई फ़ोल्डर चुनें, जैसे Downloads';

  @override
  String get attendance_closeAction => 'हाज़िरी बंद करें';

  @override
  String get attendance_closeConfirmBody =>
      'बंद होने के बाद सदस्य जवाब नहीं दे पाएँगे।';

  @override
  String get attendance_closeConfirmTitle => 'हाज़िरी बंद करें?';

  @override
  String get attendance_closeEndOfDay => 'दिन खत्म होने पर बंद करें';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return 'आज $time बजे अपने आप बंद हो जाएगा';
  }

  @override
  String get attendance_closeFailed => 'हाज़िरी बंद नहीं हो सकी';

  @override
  String get attendance_closeFailedShort => 'बंद नहीं हो सका';

  @override
  String attendance_closesAt(String dateTime) {
    return '$dateTime को बंद होगा';
  }

  @override
  String get attendance_createFailed => 'हाज़िरी नहीं बन सकी';

  @override
  String get attendance_createSubtitle => 'इस ग्रुप में हाज़िरी पोल भेजें';

  @override
  String get attendance_createTitle => 'हाज़िरी बनाएँ';

  @override
  String get attendance_created => 'हाज़िरी बनाई गई';

  @override
  String get attendance_dateEnded =>
      'चुनी गई तारीख बीत चुकी है। कोई दूसरी तारीख चुनें या ऑटो-क्लोज़ बंद करें।';

  @override
  String get attendance_dateToday => 'तारीख (आज)';

  @override
  String get attendance_dateTodaySemantics => 'हाज़िरी की तारीख, आज';

  @override
  String get attendance_deleteFailed => 'हाज़िरी डिलीट नहीं हो सकी';

  @override
  String get attendance_deletedText => 'यह हाज़िरी डिलीट कर दी गई';

  @override
  String get attendance_downloadReport => 'रिपोर्ट डाउनलोड करें';

  @override
  String get attendance_everyoneResponded => 'सभी ने जवाब दे दिया है';

  @override
  String get attendance_faceDetectedBlink => 'चेहरा मिल गया — अब पलकें झपकाएँ';

  @override
  String get attendance_failed => 'हाज़िरी नहीं हो सकी';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return 'जवाब नहीं दिया ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return 'जवाब दिया ($count)';
  }

  @override
  String get attendance_fixErrors =>
      'सबमिट करने से पहले दिखाई गई गलतियाँ ठीक करें';

  @override
  String get attendance_holdStill => 'हिलें नहीं…';

  @override
  String get attendance_howToTakePhoto => 'फ़ोटो कैसे लें';

  @override
  String get attendance_invalidGroup =>
      'ग्रुप सही नहीं है। कृपया चैट फिर से खोलें।';

  @override
  String get attendance_keepFaceInCircle => 'अपना चेहरा गोले के अंदर रखें';

  @override
  String get attendance_limitReached => 'सीमा पूरी हो गई';

  @override
  String get attendance_loadFailed => 'हाज़िरी लोड नहीं हो सकी';

  @override
  String get attendance_loadMore => 'और लोड करें';

  @override
  String get attendance_loadMoreFailed => 'और लोड नहीं हो सका';

  @override
  String get attendance_loadVotersFailed =>
      'जवाब देने वालों की लिस्ट लोड नहीं हो सकी';

  @override
  String get attendance_lookAtCamera => 'कैमरे की ओर देखें';

  @override
  String get attendance_lookStraight => 'कैमरे में सीधे देखें';

  @override
  String get attendance_markYourAttendance => 'अपनी हाज़िरी लगाएँ';

  @override
  String attendance_markedAs(String option) {
    return '$option के रूप में दर्ज';
  }

  @override
  String get attendance_markedSuccess => 'हाज़िरी सफलतापूर्वक लग गई';

  @override
  String attendance_maxOptions(int count) {
    return 'आप सिर्फ़ $count विकल्प तक जोड़ सकते हैं';
  }

  @override
  String get attendance_members => 'सदस्य';

  @override
  String attendance_membersWithCount(int count) {
    return 'सदस्य ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return 'कम से कम $count विकल्प ज़रूरी हैं';
  }

  @override
  String get attendance_moveCloser => 'थोड़ा पास आएँ';

  @override
  String get attendance_multipleFaces =>
      'कई चेहरे दिखे — फ़्रेम में सिर्फ़ आप होने चाहिए';

  @override
  String get attendance_noCsvApp =>
      'CSV फ़ाइल खोलने के लिए कोई ऐप नहीं मिला। इसकी जगह सेव या शेयर करें।';

  @override
  String get attendance_noFace => 'कोई चेहरा नहीं मिला';

  @override
  String get attendance_noFrontCamera => 'इस डिवाइस में फ्रंट कैमरा नहीं मिला।';

  @override
  String get attendance_noLocation => 'कोई लोकेशन उपलब्ध नहीं';

  @override
  String get attendance_noMembersMatch => 'खोज से कोई सदस्य मेल नहीं खाता';

  @override
  String get attendance_noResponses => 'अभी तक कोई जवाब नहीं';

  @override
  String get attendance_notResponded => 'जवाब नहीं दिया';

  @override
  String get attendance_openEyes => 'आँखें खोलें और कैमरे की ओर देखें';

  @override
  String get attendance_openMapFailed => 'मैप नहीं खुल सका';

  @override
  String get attendance_openSubtitle =>
      'Excel, Sheets या किसी दूसरे ऐप में देखें';

  @override
  String get attendance_optionHint => 'विकल्प का नाम लिखें';

  @override
  String get attendance_optionLabelRequired => 'हर विकल्प का नाम होना चाहिए';

  @override
  String attendance_optionNumber(int number) {
    return 'विकल्प $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return 'विकल्प $number • 📷 फ़ोटो ज़रूरी';
  }

  @override
  String get attendance_optionsUnique => 'विकल्प अलग-अलग होने चाहिए';

  @override
  String get attendance_photoCaptured => 'फ़ोटो ले ली गई';

  @override
  String get attendance_photoCapturedTapRetake =>
      'फ़ोटो ली गई ✓ (फिर से लेने के लिए टैप करें)';

  @override
  String get attendance_photoProof => 'फ़ोटो प्रमाण';

  @override
  String attendance_photoProofOf(String name) {
    return '$name का फ़ोटो प्रमाण';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ $option के लिए फ़ोटो ज़रूरी है';
  }

  @override
  String get attendance_photoRules =>
      'सिर्फ़ फ्रंट कैमरा इस्तेमाल होता है। पलक झपकाते ही फ़ोटो अपने आप ली जाती है, और गैलरी से अपलोड की अनुमति नहीं है।';

  @override
  String get attendance_photoSubtitle =>
      'अपनी हाज़िरी की पुष्टि के लिए लाइव फ़ोटो लें';

  @override
  String get attendance_photoTitle => 'हाज़िरी फ़ोटो';

  @override
  String get attendance_photoVerified => 'फ़ोटो सत्यापित';

  @override
  String get attendance_questionHint => 'क्या आप आज उपलब्ध रहेंगे?';

  @override
  String get attendance_questionLabel => 'हाज़िरी का सवाल';

  @override
  String get attendance_questionRequired => 'हाज़िरी का सवाल ज़रूरी है';

  @override
  String attendance_questionTooShort(int count) {
    return 'सवाल कम से कम $count अक्षरों का होना चाहिए';
  }

  @override
  String get attendance_removeFailedShort => 'हटाया नहीं जा सका';

  @override
  String get attendance_removeResponseBody =>
      'इस पोल के लिए आपकी हाज़िरी हटा दी जाएगी।';

  @override
  String get attendance_removeResponseTitle => 'अपना जवाब हटाएँ?';

  @override
  String get attendance_removeVoteFailed => 'जवाब हटाया नहीं जा सका';

  @override
  String get attendance_reportEmpty => 'रिपोर्ट खाली है';

  @override
  String get attendance_reportFailed => 'रिपोर्ट नहीं बन सकी';

  @override
  String get attendance_reportInvalid =>
      'सर्वर से गलत रिपोर्ट मिली। कृपया फिर से कोशिश करें।';

  @override
  String attendance_reportReady(String fileName) {
    return 'रिपोर्ट तैयार • $fileName';
  }

  @override
  String get attendance_reportSaved => 'रिपोर्ट सेव हो गई';

  @override
  String get attendance_reportSubject => 'हाज़िरी रिपोर्ट';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return 'हाज़िरी रिपोर्ट • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count ने जवाब दिया';
  }

  @override
  String get attendance_retakePhoto => 'फ़ोटो फिर से लें';

  @override
  String get attendance_saveInFiles => 'Files ऐप में सेव करें';

  @override
  String get attendance_saveReportDialog => 'हाज़िरी रिपोर्ट सेव करें';

  @override
  String get attendance_saveToDevice => 'डिवाइस में सेव करें';

  @override
  String get attendance_searchMember => 'सदस्य खोजें';

  @override
  String get attendance_selectPhotoOption =>
      'जिस विकल्प के लिए लाइव फ़ोटो ज़रूरी हो, उसे चुनें';

  @override
  String get attendance_selectStatus => 'कृपया अपना स्टेटस चुनें';

  @override
  String get attendance_sentToAllMembers =>
      'इस ग्रुप के सभी सदस्यों को भेजा जाएगा';

  @override
  String get attendance_sentToGroup => 'हाज़िरी ग्रुप में भेज दी गई';

  @override
  String get attendance_shareSubtitle => 'WhatsApp, ईमेल से भेजें…';

  @override
  String get attendance_statusCompleted => 'पूरा हुआ';

  @override
  String get attendance_statusOpen => 'खुला';

  @override
  String get attendance_stepBlink => 'फ़ोटो लेने के लिए पलकें झपकाएँ';

  @override
  String get attendance_stepEyeLevel => 'फ़ोन को आँखों की सीध में रखें';

  @override
  String get attendance_submit => 'हाज़िरी सबमिट करें';

  @override
  String get attendance_submitted => 'हाज़िरी दर्ज हो गई';

  @override
  String get attendance_title => 'हाज़िरी';

  @override
  String get attendance_update => 'हाज़िरी अपडेट करें';

  @override
  String get attendance_validationError => 'जानकारी में गलती';

  @override
  String get attendance_view => 'देखें';

  @override
  String get attendance_viewTitle => 'हाज़िरी देखें';

  @override
  String get attendance_voteFailed => 'जवाब दर्ज नहीं हो सका';

  @override
  String attendance_withinKm(String km) {
    return '$km कि.मी. के अंदर';
  }

  @override
  String attendance_withinMeters(int count) {
    return '$count मी. के अंदर';
  }

  @override
  String get call_accept => 'स्वीकार';

  @override
  String get call_allContacts => 'सभी संपर्क';

  @override
  String get call_allowAccess => 'अनुमति दें';

  @override
  String get call_answer => 'जवाब दें';

  @override
  String get call_audioOutput => 'ऑडियो आउटपुट';

  @override
  String get call_callFrom => 'कॉल आ रही है';

  @override
  String get call_callIdNotFound => 'कॉल ID नहीं मिली';

  @override
  String get call_callInformation => 'कॉल की जानकारी';

  @override
  String get call_callSummary => 'कॉल सारांश';

  @override
  String get call_caller => 'कॉलर';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name और $count अन्य',
      one: '$name और 1 अन्य',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कॉल हटाई नहीं जा सकीं। फिर से कोशिश करें।',
      one: '1 कॉल हटाई नहीं जा सकी। फिर से कोशिश करें।',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कॉल हटाई गईं',
      one: '1 कॉल हटाई गई',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'कैमरा';

  @override
  String get call_cameraMicRequired => 'कैमरा या माइक की अनुमति ज़रूरी है';

  @override
  String get call_cameraOff => 'कैमरा बंद';

  @override
  String get call_cameraOn => 'कैमरा चालू';

  @override
  String get call_cameraUnavailable =>
      'माफ़ करें, अभी कैमरा उपलब्ध नहीं है। कृपया बाद में फिर कोशिश करें।';

  @override
  String get call_cannotReachCallServer =>
      'कॉल सर्वर से कनेक्ट नहीं हो सका। कृपया अपना नेटवर्क जांचें।';

  @override
  String get call_chatFallback => 'चैट';

  @override
  String get call_closeFullScreen => 'फ़ुल स्क्रीन बंद करें';

  @override
  String get call_communicationUnavailable =>
      'इस यूज़र से संपर्क उपलब्ध नहीं है';

  @override
  String get call_connectingProgress => 'कनेक्ट हो रहा है…';

  @override
  String get call_connectionTimeout => 'कनेक्शन का समय खत्म हो गया';

  @override
  String get call_contactInformation => 'संपर्क की जानकारी';

  @override
  String get call_contactsAccessBannerMessage =>
      'अपनी टीम के लोगों को आसानी से ढूंढें और कॉल करें।';

  @override
  String get call_contactsAccessBannerTitle => 'हमें अपने संपर्क देखने दें';

  @override
  String get call_contactsAccessMessage =>
      'FG Tracker पर कौन है यह दिखाने और आपको उन्हें कॉल करने या इनवाइट भेजने देने के लिए हमें आपके संपर्कों की अनुमति चाहिए।';

  @override
  String get call_contactsAccessTitle => 'संपर्कों की अनुमति दें';

  @override
  String get call_decline => 'अस्वीकार';

  @override
  String get call_deleteCallsMessage =>
      'ये कॉल आपकी कॉल हिस्ट्री से हटा दी जाएंगी।';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कॉल हटाएं?',
      one: '1 कॉल हटाएं?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage =>
      'क्या आप वाकई यह कॉल हिस्ट्री हटाना चाहते हैं?';

  @override
  String get call_deleteHistoryTitle => 'कॉल हिस्ट्री हटाएं';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'क्या आप वाकई चुनी गई ये $count कॉल हिस्ट्री एंट्री हटाना चाहते हैं?',
      one: 'क्या आप वाकई चुनी गई यह कॉल हिस्ट्री हटाना चाहते हैं?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => 'चुनी गई कॉल हटाएं';

  @override
  String call_deleteWithCount(int count) {
    return 'हटाएं ($count)';
  }

  @override
  String call_durHr(int hours) {
    return '$hours घं';
  }

  @override
  String call_durHrMin(int hours, int minutes) {
    return '$hours घं $minutes मि';
  }

  @override
  String call_durMin(int minutes) {
    return '$minutes मि';
  }

  @override
  String call_durMinSec(int minutes, int seconds) {
    return '$minutes मि $seconds से';
  }

  @override
  String call_durSec(int seconds) {
    return '$seconds से';
  }

  @override
  String call_durShortHr(int hours) {
    return '$hoursघं';
  }

  @override
  String call_durShortHrMin(int hours, int minutes) {
    return '$hoursघं $minutesमि';
  }

  @override
  String call_durShortMin(int minutes) {
    return '$minutesमि';
  }

  @override
  String call_durShortMinSec(int minutes, int seconds) {
    return '$minutesमि $secondsसे';
  }

  @override
  String call_durShortSec(int seconds) {
    return '$secondsसे';
  }

  @override
  String get call_duration => 'अवधि';

  @override
  String call_durationValue(String duration) {
    return 'अवधि: $duration';
  }

  @override
  String get call_earpiece => 'ईयरपीस';

  @override
  String get call_endCall => 'कॉल खत्म करें';

  @override
  String get call_ended => 'खत्म हुई';

  @override
  String get call_enterNumber => 'नंबर डालें';

  @override
  String get call_enterPhoneNumber => 'कृपया फ़ोन नंबर डालें';

  @override
  String get call_entryDeleteFailed => 'कॉल एंट्री हटाई नहीं जा सकी';

  @override
  String call_entryDeleteFailedError(String error) {
    return 'कॉल एंट्री हटाई नहीं जा सकी: $error';
  }

  @override
  String get call_entryDeleted => 'कॉल एंट्री हटा दी गई';

  @override
  String get call_everyoneInCall => 'सभी पहले से कॉल में हैं';

  @override
  String get call_failedTitle => 'कॉल विफल';

  @override
  String get call_groupBadge => 'ग्रुप';

  @override
  String get call_groupCallComingSoon => 'ग्रुप कॉलिंग जल्द आ रही है';

  @override
  String get call_groupCallInitFailed => 'ग्रुप कॉल शुरू नहीं हो सकी';

  @override
  String get call_groupCallStartFailed =>
      'ग्रुप कॉल शुरू नहीं हो सकी। कृपया फिर से कोशिश करें।';

  @override
  String get call_groupInformation => 'ग्रुप की जानकारी';

  @override
  String call_groupWithId(String id) {
    return 'ग्रुप $id';
  }

  @override
  String get call_headphones => 'हेडफ़ोन';

  @override
  String call_historyCancelled(String callType) {
    return 'रद्द $callType';
  }

  @override
  String get call_historyClearFailed => 'कॉल हिस्ट्री साफ़ नहीं हो सकी';

  @override
  String call_historyClearFailedError(String error) {
    return 'कॉल हिस्ट्री साफ़ नहीं हो सकी: $error';
  }

  @override
  String get call_historyCleared => 'पूरी कॉल हिस्ट्री साफ़ कर दी गई';

  @override
  String call_historyIncoming(String callType) {
    return 'इनकमिंग $callType';
  }

  @override
  String call_historyMissed(String callType) {
    return 'मिस्ड $callType';
  }

  @override
  String call_historyOutgoing(String callType) {
    return 'आउटगोइंग $callType';
  }

  @override
  String call_historyRejected(String callType) {
    return 'अस्वीकृत $callType';
  }

  @override
  String get call_inCall => 'कॉल में';

  @override
  String call_inCallWithGroup(String groupName) {
    return 'कॉल में · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return 'इस कॉल में ($count)';
  }

  @override
  String get call_incomingAudio => 'इनकमिंग ऑडियो कॉल';

  @override
  String get call_incomingCallChannelName => 'इनकमिंग कॉल';

  @override
  String get call_incomingGroupAudio => 'इनकमिंग ग्रुप ऑडियो कॉल';

  @override
  String get call_incomingGroupVideo => 'इनकमिंग ग्रुप वीडियो कॉल';

  @override
  String get call_incomingVideo => 'इनकमिंग वीडियो कॉल';

  @override
  String get call_infoDescription => 'विवरण';

  @override
  String get call_infoEmail => 'ईमेल';

  @override
  String get call_infoGroupCode => 'ग्रुप कोड';

  @override
  String get call_infoGroupName => 'ग्रुप का नाम';

  @override
  String get call_infoMobile => 'मोबाइल';

  @override
  String get call_infoTotalMembers => 'कुल सदस्य';

  @override
  String get call_invite => 'इनवाइट';

  @override
  String get call_inviteToApp => 'FG Tracker पर इनवाइट करें';

  @override
  String get call_join => 'जुड़ें';

  @override
  String get call_joinOnAnswer => 'जवाब देते ही आप जुड़ जाएंगे';

  @override
  String get call_kindAudio => 'ऑडियो कॉल';

  @override
  String get call_kindCall => 'कॉल';

  @override
  String get call_kindGroupAudio => 'ग्रुप ऑडियो कॉल';

  @override
  String get call_kindGroupCall => 'ग्रुप कॉल';

  @override
  String call_kindGroupOther(String kind) {
    return 'ग्रुप $kind कॉल';
  }

  @override
  String get call_kindGroupVideo => 'ग्रुप वीडियो कॉल';

  @override
  String call_kindOther(String kind) {
    return '$kind कॉल';
  }

  @override
  String get call_kindVideo => 'वीडियो कॉल';

  @override
  String get call_loadDetailFailed => 'कॉल की जानकारी लोड नहीं हो सकी';

  @override
  String get call_loadMore => 'और देखें';

  @override
  String get call_loadRecentFailed => 'हाल की कॉल लोड नहीं हो सकीं';

  @override
  String get call_loginToCall => 'कॉल करने के लिए कृपया लॉग इन करें';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस कॉल में $count सदस्य',
      one: 'इस कॉल में 1 सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'मैसेज';

  @override
  String get call_micActive => 'माइक्रोफ़ोन चालू है';

  @override
  String get call_missedCall => 'मिस्ड कॉल';

  @override
  String get call_missedCallChannelName => 'मिस्ड कॉल';

  @override
  String get call_missedCallNotification => 'मिस्ड कॉल';

  @override
  String get call_more => 'और';

  @override
  String get call_mute => 'म्यूट';

  @override
  String get call_muted => 'म्यूट है';

  @override
  String call_nameYou(String name) {
    return '$name (आप)';
  }

  @override
  String get call_noActiveParticipants => 'कोई सक्रिय प्रतिभागी नहीं';

  @override
  String get call_noContactsMatch => 'आपकी खोज से कोई संपर्क मेल नहीं खाता';

  @override
  String get call_noGroupsFound => 'कोई ग्रुप नहीं मिला';

  @override
  String get call_noGroupsYet => 'अभी कोई ग्रुप नहीं';

  @override
  String get call_noNameGroup => 'बिना नाम का ग्रुप';

  @override
  String get call_noRecentCalls => 'कोई हालिया कॉल नहीं';

  @override
  String get call_noRecentMatch => 'आपकी खोज से कोई हालिया कॉल मेल नहीं खाती';

  @override
  String get call_noRecentYet => 'अभी कोई हालिया कॉल नहीं';

  @override
  String get call_noRegisteredContacts => 'कोई रजिस्टर्ड संपर्क नहीं मिला';

  @override
  String get call_notInContacts => 'यह नंबर आपके संपर्कों में नहीं है';

  @override
  String call_notInThisCall(int count) {
    return 'इस कॉल में नहीं ($count)';
  }

  @override
  String get call_notReady => 'कॉल अभी तैयार नहीं है';

  @override
  String get call_notificationPermissionRationale =>
      'आने वाली कॉल दिखाने के लिए ज़रूरी है।';

  @override
  String get call_notificationPermissionSettings =>
      'सेटिंग्स में सूचनाएं चालू करें।';

  @override
  String get call_notificationPermissionTitle => 'सूचना की अनुमति';

  @override
  String get call_notify => 'नोटिफ़ाई';

  @override
  String get call_notifyFailed => 'सूचना नहीं भेजी जा सकी';

  @override
  String get call_notifySent => 'सूचना भेज दी गई';

  @override
  String get call_ongoingChannelDescription =>
      'कॉल और स्क्रीन शेयरिंग को चालू रखता है';

  @override
  String get call_ongoingChannelName => 'चालू कॉल';

  @override
  String get call_otherAlreadySharing =>
      'सामने वाला व्यक्ति पहले से स्क्रीन शेयर कर रहा है';

  @override
  String get call_otherStartingVideo =>
      'सामने वाला व्यक्ति वीडियो शुरू कर रहा है';

  @override
  String get call_participant => 'प्रतिभागी';

  @override
  String get call_participants => 'प्रतिभागी';

  @override
  String call_personIsSharing(String name) {
    return '$name शेयर कर रहे हैं';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name स्क्रीन शेयर कर रहे हैं';
  }

  @override
  String get call_phone => 'फ़ोन';

  @override
  String get call_pleaseWait => 'कृपया प्रतीक्षा करें';

  @override
  String get call_recentCalls => 'हाल की कॉल';

  @override
  String get call_resetZoom => 'ज़ूम रीसेट करें';

  @override
  String get call_returnToCall => 'कॉल पर लौटें';

  @override
  String get call_screenBeingShared => 'स्क्रीन शेयर की जा रही है';

  @override
  String get call_screenShareChannelDescription =>
      'चालू स्क्रीन शेयरिंग की सूचना';

  @override
  String get call_screenShareChannelName => 'स्क्रीन शेयरिंग सेवा';

  @override
  String get call_screenSharePermissionDenied =>
      'स्क्रीन शेयरिंग की अनुमति नहीं मिली';

  @override
  String get call_screenShareStartFailed => 'स्क्रीन शेयरिंग शुरू नहीं हो सकी';

  @override
  String get call_screenShareStopped => 'स्क्रीन शेयरिंग बंद हो गई';

  @override
  String get call_screenSharingTitle => 'स्क्रीन शेयरिंग';

  @override
  String call_screenVisibleToName(String name) {
    return 'आपकी स्क्रीन $name को दिख रही है';
  }

  @override
  String get call_screenVisibleToOther =>
      'आपकी स्क्रीन सामने वाले को दिख रही है';

  @override
  String get call_searchHint => 'संपर्क या ग्रुप खोजें';

  @override
  String get call_sectionLastWeek => 'पिछले हफ़्ते';

  @override
  String get call_sectionOlder => 'पुराने';

  @override
  String get call_sectionThisWeek => 'इस हफ़्ते';

  @override
  String get call_selectAll => 'सभी चुनें';

  @override
  String call_selectedCount(int count) {
    return '$count चुने गए';
  }

  @override
  String get call_selectedDeleteFailed => 'चुनी गई कॉल हटाई नहीं जा सकीं';

  @override
  String call_selectedDeleteFailedError(String error) {
    return 'चुनी गई कॉल हटाई नहीं जा सकीं: $error';
  }

  @override
  String get call_selectedDeleted => 'चुनी गई कॉल हटा दी गईं';

  @override
  String get call_selfCallWarning => 'आप अपने ही नंबर पर कॉल नहीं कर सकते।';

  @override
  String get call_sessionConnectFailed => 'कॉल से कनेक्ट नहीं हो सका';

  @override
  String get call_shareScreen => 'स्क्रीन शेयर करें';

  @override
  String get call_shareScreenShort => 'शेयर';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return '$groupName में शेयर हो रहा है • कॉल पर लौटने के लिए टैप करें';
  }

  @override
  String get call_sharingYourScreen => 'आपकी स्क्रीन शेयर हो रही है';

  @override
  String get call_someone => 'कोई';

  @override
  String get call_speaker => 'स्पीकर';

  @override
  String get call_started => 'शुरू हुई';

  @override
  String get call_startingScreenShare => 'स्क्रीन शेयर शुरू हो रही है…';

  @override
  String get call_statusBusy => 'व्यस्त';

  @override
  String get call_statusCalling => 'कॉल हो रही है';

  @override
  String get call_statusCancelled => 'रद्द की गई';

  @override
  String get call_statusCompleted => 'पूरी हुई';

  @override
  String get call_statusConnected => 'कनेक्ट हो गया';

  @override
  String get call_statusConnecting => 'कनेक्ट हो रहा है';

  @override
  String get call_statusDeclined => 'अस्वीकार की गई';

  @override
  String get call_statusJoined => 'जुड़े';

  @override
  String get call_statusMissed => 'मिस्ड';

  @override
  String get call_statusReconnecting => 'फिर से कनेक्ट हो रहा है';

  @override
  String get call_statusRinging => 'घंटी बज रही है';

  @override
  String get call_statusVideoConnecting => 'वीडियो कनेक्ट हो रहा है';

  @override
  String get call_stop => 'रोकें';

  @override
  String get call_stopSharing => 'शेयर करना बंद करें';

  @override
  String get call_subtitle => 'ऑडियो / वीडियो कॉल';

  @override
  String get call_swipeUpToAnswer => 'जवाब देने के लिए ऊपर स्वाइप करें';

  @override
  String get call_switch => 'बदलें';

  @override
  String get call_switchCameraFailed => 'कैमरा नहीं बदल सका';

  @override
  String get call_switchToVideoToShare =>
      'अपनी स्क्रीन शेयर करने के लिए वीडियो कॉल पर जाएं';

  @override
  String get call_tabContacts => 'संपर्क';

  @override
  String get call_tabGroups => 'ग्रुप';

  @override
  String get call_tabRecent => 'हाल के';

  @override
  String get call_tapNotifyToInvite => 'बुलाने के लिए नोटिफ़ाई पर टैप करें';

  @override
  String get call_tapStartBroadcastHint =>
      'सिस्टम प्रॉम्प्ट दिखे तो Start Broadcast पर टैप करें';

  @override
  String get call_title => 'कॉल';

  @override
  String call_todayAt(String value) {
    return 'आज, $value';
  }

  @override
  String get call_total => 'कुल';

  @override
  String get call_turnOnVideo => 'अपना वीडियो चालू करें';

  @override
  String get call_unableToCallContact => 'इस संपर्क को कॉल नहीं किया जा सकता';

  @override
  String get call_unableToMakeCall => 'कॉल नहीं हो सकी';

  @override
  String get call_unableToOpenChat => 'इस संपर्क की चैट नहीं खुल सकी';

  @override
  String get call_unableToShareScreen => 'स्क्रीन शेयर नहीं हो सकी';

  @override
  String get call_unavailableTitle => 'कॉल उपलब्ध नहीं';

  @override
  String get call_unexpectedResponse => 'सर्वर से अनपेक्षित जवाब मिला';

  @override
  String get call_unknown => 'अज्ञात';

  @override
  String get call_unknownGroup => 'अज्ञात ग्रुप';

  @override
  String get call_unknownUser => 'अज्ञात यूज़र';

  @override
  String get call_unmute => 'अनम्यूट';

  @override
  String get call_unselectAll => 'सभी का चयन हटाएं';

  @override
  String get call_user => 'यूज़र';

  @override
  String get call_userNotFound => 'यूज़र नहीं मिला';

  @override
  String call_userWithId(String id) {
    return 'यूज़र $id';
  }

  @override
  String get call_video => 'वीडियो';

  @override
  String get call_waitingForBroadcast => 'Start Broadcast का इंतज़ार';

  @override
  String get call_waitingForBroadcastMessage =>
      'अपनी स्क्रीन शेयर करने के लिए सिस्टम डायलॉग में “Start Broadcast” पर टैप करें। शेयरिंग उसके बाद ही शुरू होगी।';

  @override
  String get call_waitingForMedia => 'मीडिया स्ट्रीम का इंतज़ार...';

  @override
  String get call_wired => 'वायर्ड';

  @override
  String get call_yesDelete => 'हाँ, हटाएं';

  @override
  String call_yesterdayAt(String value) {
    return 'कल, $value';
  }

  @override
  String get call_youAreSharing => 'आप शेयर कर रहे हैं';

  @override
  String get call_youAreSharingScreen => 'आप अपनी स्क्रीन शेयर कर रहे हैं';

  @override
  String get call_zoomIn => 'ज़ूम इन';

  @override
  String get call_zoomOut => 'ज़ूम आउट';

  @override
  String get chatList_allChats => 'सभी चैट';

  @override
  String get chatList_allContacts => 'सभी संपर्क';

  @override
  String get chatList_allowAccess => 'अनुमति दें';

  @override
  String get chatList_allowContactsBody =>
      'FG Tracker पर कौन है यह दिखाने और आपको चैट शुरू करने या आमंत्रण भेजने देने के लिए हमें आपके संपर्कों की अनुमति चाहिए।';

  @override
  String get chatList_allowContactsTitle => 'संपर्कों की अनुमति दें';

  @override
  String get chatList_archiveChat => 'चैट आर्काइव करें';

  @override
  String get chatList_archived => 'आर्काइव';

  @override
  String get chatList_archivedChatsSubtitle => 'आपकी छिपी हुई बातचीत';

  @override
  String get chatList_archivedChatsTitle => 'आर्काइव चैट';

  @override
  String chatList_archivedCount(int count) {
    return 'आर्काइव ($count)';
  }

  @override
  String get chatList_block => 'ब्लॉक करें';

  @override
  String get chatList_blockFailed => 'यूज़र को ब्लॉक नहीं कर सके';

  @override
  String chatList_blockName(String name) {
    return '$name को ब्लॉक करें';
  }

  @override
  String get chatList_blockUser => 'यूज़र को ब्लॉक करें';

  @override
  String get chatList_blockUserConfirm =>
      'क्या आप वाकई इस यूज़र को ब्लॉक करना चाहते हैं?';

  @override
  String get chatList_blocked => 'ब्लॉक किया';

  @override
  String get chatList_chatCleared => 'चैट साफ़ हो गई';

  @override
  String get chatList_chooseContactToShare =>
      'चैट में शेयर करने के लिए एक संपर्क चुनें।';

  @override
  String get chatList_clear => 'साफ़ करें';

  @override
  String get chatList_clearChat => 'चैट साफ़ करें';

  @override
  String get chatList_clearChatConfirm =>
      'इस यूज़र के साथ सभी मैसेज डिलीट करें?';

  @override
  String get chatList_clearChatFailed => 'चैट साफ़ नहीं हो सकी';

  @override
  String get chatList_clearSearch => 'खोज साफ़ करें';

  @override
  String get chatList_contactAndInfo => 'संपर्क और जानकारी';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'चैट में संपर्क शेयर करने के लिए संपर्क की अनुमति ज़रूरी है।';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संपर्क',
      one: '1 संपर्क',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return 'संपर्क लोड नहीं हो सके: $error';
  }

  @override
  String get chatList_contactsPermissionNeeded => 'संपर्क की अनुमति ज़रूरी है';

  @override
  String get chatList_contactsWillAppear =>
      'उपलब्ध होने पर आपके संपर्क यहाँ दिखेंगे।';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => 'निष्क्रिय';

  @override
  String get chatList_defaultAbout =>
      'नमस्ते! मैं FG Tracker इस्तेमाल कर रहा/रही हूँ';

  @override
  String get chatList_deleteChat => 'चैट डिलीट करें';

  @override
  String get chatList_deleteChatConfirm =>
      'इस बातचीत को अपनी चैट लिस्ट से डिलीट करें?';

  @override
  String get chatList_forwardFailed => 'मैसेज फ़ॉरवर्ड नहीं हो सका।';

  @override
  String get chatList_forwardListLoadFailed =>
      'फ़ॉरवर्ड लिस्ट लोड नहीं हो सकी।';

  @override
  String get chatList_forwardTo => 'इसे फ़ॉरवर्ड करें...';

  @override
  String get chatList_forwarded => 'फ़ॉरवर्ड किया गया';

  @override
  String get chatList_groupChatFallback => 'ग्रुप चैट';

  @override
  String get chatList_groupDeactivatedBanner =>
      'इस ग्रुप को एडमिन ने निष्क्रिय कर दिया है';

  @override
  String get chatList_groupFallback => 'ग्रुप';

  @override
  String get chatList_howToAllow => 'अनुमति कैसे दें';

  @override
  String get chatList_howToAllowStep1 =>
      'सेटिंग्स खोलने के लिए \"अनुमति दें\" पर टैप करें';

  @override
  String get chatList_howToAllowStep2 =>
      '\"अनुमतियाँ\" (Permissions) पर टैप करें';

  @override
  String get chatList_howToAllowStep3 => '\"संपर्क\" (Contacts) चुनें';

  @override
  String get chatList_howToAllowStep4 =>
      '\"अनुमति दें\" (Allow) चुनें, फिर ऐप पर वापस आएँ';

  @override
  String get chatList_invite => 'आमंत्रित करें';

  @override
  String get chatList_inviteChooseHow => 'चुनें कि आमंत्रण कैसे भेजना है';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return 'नमस्ते $name! FG Tracker पर मेरे साथ जुड़ें।\n\nAndroid के लिए डाउनलोड करें: $playStoreLink\n\niOS के लिए डाउनलोड करें: $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'और ऐप';

  @override
  String chatList_inviteName(String name) {
    return '$name को आमंत्रित करें';
  }

  @override
  String get chatList_inviteViaMessage => 'मैसेज';

  @override
  String get chatList_locationHidden => 'लोकेशन छिपी है';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1, $name2 +$count टाइप कर रहे हैं...';
  }

  @override
  String get chatList_markAsRead => 'पढ़ा हुआ मार्क करें';

  @override
  String get chatList_markAsUnread => 'बिना पढ़ा मार्क करें';

  @override
  String get chatList_mediaLinksDocs => 'मीडिया, लिंक और डॉक्स';

  @override
  String get chatList_memberFallback => 'सदस्य';

  @override
  String get chatList_messageDeleted => 'यह मैसेज डिलीट कर दिया गया';

  @override
  String get chatList_messageForwarded => 'मैसेज फ़ॉरवर्ड हो गया';

  @override
  String get chatList_messageIdMissing => 'मैसेज ID नहीं मिली।';

  @override
  String chatList_minutesShort(int count) {
    return '$count मिनट';
  }

  @override
  String get chatList_mute1Hour => '1 घंटा';

  @override
  String get chatList_mute8Hours => '8 घंटे';

  @override
  String get chatList_muteAlways => 'जब तक मैं वापस चालू न करूँ';

  @override
  String get chatList_muteSubtitle =>
      'चुनें कि नोटिफ़िकेशन कितनी देर के लिए रोकने हैं।';

  @override
  String get chatList_muteTitle => 'नोटिफ़िकेशन म्यूट करें';

  @override
  String get chatList_muteUntilTomorrow => 'कल तक';

  @override
  String get chatList_newChat => 'नई चैट';

  @override
  String get chatList_newChatSectionContacts => 'नई चैट शुरू करें (संपर्क)';

  @override
  String get chatList_newChatSectionInvite =>
      'चैट के लिए आमंत्रित करें (अपंजीकृत संपर्क)';

  @override
  String get chatList_noArchivedChats => 'कोई आर्काइव चैट नहीं';

  @override
  String get chatList_noArchivedChatsSubtitle =>
      'आर्काइव की गई बातचीत यहाँ दिखेंगी।';

  @override
  String get chatList_noChatsFound => 'कोई चैट नहीं मिली';

  @override
  String get chatList_noChatsSubtitle => 'आपकी प्राइवेट चैट यहाँ दिखेंगी।';

  @override
  String get chatList_noContactsAvailable => 'कोई संपर्क उपलब्ध नहीं';

  @override
  String get chatList_noContactsFound => 'कोई संपर्क नहीं मिला';

  @override
  String get chatList_noGroupsAvailable => 'कोई ग्रुप उपलब्ध नहीं';

  @override
  String get chatList_noGroupsFound => 'कोई ग्रुप नहीं मिला';

  @override
  String get chatList_noMediaYet => 'अभी तक कोई मीडिया शेयर नहीं हुआ';

  @override
  String get chatList_noMessagesYet => 'अभी कोई मैसेज नहीं';

  @override
  String get chatList_noPeopleOrGroups => 'कोई व्यक्ति या ग्रुप नहीं मिला';

  @override
  String chatList_noResultsFor(String query) {
    return '\"$query\" के लिए कोई परिणाम नहीं मिला';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return '\'$query\' के लिए कोई परिणाम नहीं';
  }

  @override
  String get chatList_noTrackerContacts => 'कोई सक्रिय ट्रैकर संपर्क नहीं मिला';

  @override
  String get chatList_offlineNotSaved =>
      'आप ऑफ़लाइन हैं। बदलाव सेव नहीं हुआ, कृपया फिर से कोशिश करें।';

  @override
  String chatList_oneTyping(String name) {
    return '$name टाइप कर रहे हैं...';
  }

  @override
  String get chatList_openSettings => 'सेटिंग्स खोलें';

  @override
  String get chatList_pinChat => 'चैट पिन करें';

  @override
  String get chatList_pinnedChats => 'पिन की गई चैट';

  @override
  String get chatList_pleaseTryAgain => 'कृपया फिर से कोशिश करें।';

  @override
  String get chatList_profileCall => 'कॉल';

  @override
  String get chatList_profileMessage => 'मैसेज';

  @override
  String get chatList_profileNotFound => 'प्रोफ़ाइल की जानकारी नहीं मिली';

  @override
  String get chatList_profileVideoCall => 'वीडियो कॉल';

  @override
  String get chatList_quickCommSubtitle => 'अपनी टीम से तुरंत जुड़ें';

  @override
  String get chatList_quickCommTitle => 'त्वरित संपर्क';

  @override
  String get chatList_quickGroups => 'ग्रुप';

  @override
  String get chatList_quickGroupsSub => 'टीम चैट';

  @override
  String get chatList_quickSafeZone => 'सेफ ज़ोन';

  @override
  String get chatList_quickSafeZoneSub => 'सुरक्षा और अलर्ट';

  @override
  String get chatList_quickTracking => 'ट्रैकिंग';

  @override
  String get chatList_quickTrackingSub => 'लाइव लोकेशन';

  @override
  String get chatList_quickWalkie => 'वॉकी';

  @override
  String get chatList_quickWalkieSub => 'दबाकर बोलें';

  @override
  String get chatList_searchByNameOrNumber => 'नाम या नंबर से खोजें...';

  @override
  String get chatList_searchGroupsHint => 'ग्रुप खोजें...';

  @override
  String get chatList_searchHint => 'चैट या मैसेज खोजें...';

  @override
  String get chatList_searchHintShort => 'खोजें...';

  @override
  String get chatList_searchNameOrNumber => 'नाम या नंबर खोजें';

  @override
  String get chatList_searchResults => 'खोज परिणाम';

  @override
  String get chatList_sectionGroups => 'ग्रुप';

  @override
  String get chatList_sectionMyContacts => 'मेरे संपर्क';

  @override
  String get chatList_sectionOtherContacts => 'अन्य संपर्क';

  @override
  String get chatList_sectionRecentChats => 'हाल की चैट';

  @override
  String get chatList_selectDestination => 'किसे भेजना है चुनें';

  @override
  String get chatList_selectDestinationMsg =>
      'कृपया कम से कम एक व्यक्ति या ग्रुप चुनें।';

  @override
  String chatList_selectedCount(int count) {
    return '$count चुने गए';
  }

  @override
  String get chatList_shareContactTitle => 'संपर्क शेयर करें';

  @override
  String chatList_shareMenuFailed(String error) {
    return 'शेयर मेनू नहीं खुल सका: $error';
  }

  @override
  String get chatList_smsOpenFailed => 'मैसेजिंग ऐप नहीं खुल सका';

  @override
  String get chatList_someone => 'कोई';

  @override
  String get chatList_startConversation => 'बातचीत शुरू करें';

  @override
  String get chatList_subtitle => 'अपनी टीम से जुड़े रहें';

  @override
  String get chatList_telegramOpenFailed => 'Telegram नहीं खुल सका';

  @override
  String get chatList_title => 'चैट';

  @override
  String get chatList_tryAnotherNameOrNumber =>
      'कोई दूसरा नाम या फ़ोन नंबर आज़माएँ।';

  @override
  String get chatList_tryDifferentSearch => 'किसी दूसरे नाम या मैसेज से खोजें।';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1, $name2 टाइप कर रहे हैं...';
  }

  @override
  String get chatList_typing => 'टाइप कर रहे हैं...';

  @override
  String get chatList_unableToCallContact => 'इस संपर्क को कॉल नहीं कर सकते';

  @override
  String get chatList_unableToLoadContacts => 'संपर्क लोड नहीं हो सके';

  @override
  String get chatList_unarchiveChat => 'चैट अनआर्काइव करें';

  @override
  String get chatList_unblock => 'अनब्लॉक करें';

  @override
  String get chatList_unblockFailed => 'यूज़र को अनब्लॉक नहीं कर सके';

  @override
  String chatList_unblockName(String name) {
    return '$name को अनब्लॉक करें';
  }

  @override
  String get chatList_unblockUser => 'यूज़र को अनब्लॉक करें';

  @override
  String get chatList_unblockUserConfirm =>
      'क्या आप वाकई इस यूज़र को अनब्लॉक करना चाहते हैं?';

  @override
  String get chatList_unknown => 'अज्ञात';

  @override
  String get chatList_unknownUser => 'अज्ञात यूज़र';

  @override
  String get chatList_unnamedContact => 'बिना नाम का संपर्क';

  @override
  String get chatList_unpinChat => 'चैट अनपिन करें';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अनपढ़े मैसेज',
      one: '1 अनपढ़ा मैसेज',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed =>
      'चैट अपडेट नहीं हो सकी। कृपया फिर से कोशिश करें।';

  @override
  String get chatList_userFallback => 'यूज़र';

  @override
  String get chatList_userNotFound => 'यूज़र नहीं मिला';

  @override
  String get chatList_viewArchived => 'आर्काइव की गई बातचीत देखें';

  @override
  String get chatList_whatsappOpenFailed => 'WhatsApp नहीं खुल सका';

  @override
  String get chatList_yourContacts => 'आपके संपर्क';

  @override
  String get chat_addCaptionHint => 'कैप्शन जोड़ें...';

  @override
  String get chat_audioUnavailable => 'यह ऑडियो अब उपलब्ध नहीं है';

  @override
  String get chat_blockFailed => 'यूज़र को ब्लॉक नहीं कर सके';

  @override
  String get chat_call => 'कॉल करें';

  @override
  String get chat_cameraAccessNeeded =>
      'चैट में फ़ोटो और वीडियो लेने के लिए कैमरा एक्सेस ज़रूरी है।';

  @override
  String get chat_cameraModePhoto => 'फ़ोटो';

  @override
  String get chat_cameraModePortrait => 'पोर्ट्रेट';

  @override
  String get chat_cameraModeVideo => 'वीडियो';

  @override
  String get chat_cameraStartFailed => 'कैमरा शुरू नहीं हो सका।';

  @override
  String get chat_cantMessageUser => 'आप इस यूज़र को मैसेज नहीं कर सकते';

  @override
  String get chat_chatActionsSubtitle => 'अपनी चैट मैनेज करें';

  @override
  String get chat_chatActionsTitle => 'चैट एक्शन';

  @override
  String get chat_clear => 'साफ़ करें';

  @override
  String get chat_clearChat => 'चैट साफ़ करें';

  @override
  String get chat_clearChatConfirm => 'इस चैट के सभी मैसेज साफ़ करें?';

  @override
  String get chat_clearGroupChatFailed => 'ग्रुप चैट साफ़ नहीं हो सकी';

  @override
  String get chat_contactBlockedYou => 'इस कॉन्टैक्ट ने आपको ब्लॉक किया है';

  @override
  String get chat_contactUnavailable => 'कॉन्टैक्ट उपलब्ध नहीं';

  @override
  String get chat_deleteForEveryone => 'सभी के लिए डिलीट करें';

  @override
  String get chat_deleteForEveryoneConfirm =>
      'क्या आप यह मैसेज सभी के लिए डिलीट करना चाहते हैं?';

  @override
  String get chat_deleteForMe => 'मेरे लिए डिलीट करें';

  @override
  String get chat_deleteForMeConfirm =>
      'क्या आप यह मैसेज अपने लिए डिलीट करना चाहते हैं?';

  @override
  String get chat_deleteMember => 'सदस्य हटाएं';

  @override
  String get chat_deleteMemberSubtitle => 'इस ग्रुप से किसी सदस्य को हटाएं';

  @override
  String get chat_documentAvailable => 'डॉक्यूमेंट उपलब्ध है';

  @override
  String get chat_documentDownloadFailed => 'डॉक्यूमेंट डाउनलोड नहीं हो सका।';

  @override
  String get chat_documentOpenFailed =>
      'डॉक्यूमेंट नहीं खुल सका। कृपया फिर से कोशिश करें।';

  @override
  String get chat_documentPreviewUnavailable =>
      'इस फ़ाइल टाइप के लिए प्रीव्यू उपलब्ध नहीं है। अपने फ़ोन के ऐप से डॉक्यूमेंट खोलें।';

  @override
  String get chat_documentUnavailable => 'यह डॉक्यूमेंट अब उपलब्ध नहीं है';

  @override
  String get chat_downloadFailed => 'डाउनलोड नहीं हो सका';

  @override
  String get chat_edited => 'एडिट किया गया';

  @override
  String get chat_emptySubtitle => 'बातचीत शुरू करने के लिए hi 👋 कहें';

  @override
  String get chat_emptyTitle => 'यहाँ अभी कोई मैसेज नहीं है';

  @override
  String get chat_fetchingLocation => 'लोकेशन ढूँढी जा रही है...';

  @override
  String get chat_finishVoiceRecordingFirst =>
      'पहले वॉइस रिकॉर्डिंग पूरी या रद्द करें';

  @override
  String get chat_forwarded => 'फ़ॉरवर्ड किया गया';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$total में से $current';
  }

  @override
  String get chat_groupActionsSubtitle => 'अपनी ग्रुप सेटिंग्स मैनेज करें';

  @override
  String get chat_groupActionsTitle => 'ग्रुप एक्शन';

  @override
  String get chat_groupChatCleared => 'ग्रुप चैट साफ़ हो गई';

  @override
  String get chat_groupDeactivated => 'एडमिन ने इस ग्रुप को बंद कर दिया है';

  @override
  String get chat_imageFailed => 'इमेज लोड नहीं हुई';

  @override
  String get chat_listen => 'सुनें';

  @override
  String get chat_listenEnglish => 'सुनें (अंग्रेज़ी)';

  @override
  String get chat_listenHindi => 'सुनें (हिंदी)';

  @override
  String get chat_loadFailedSubtitle =>
      'अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get chat_loadFailedTitle => 'मैसेज लोड नहीं हो सके';

  @override
  String get chat_locationFetchFailed =>
      'आपकी लोकेशन नहीं मिल सकी। कृपया फिर से कोशिश करें।';

  @override
  String get chat_locationPermissionNeeded =>
      'लोकेशन शेयर करने के लिए लोकेशन परमिशन ज़रूरी है।';

  @override
  String get chat_locationPermissionOff =>
      'इस ऐप के लिए लोकेशन परमिशन बंद है। लोकेशन शेयर करने के लिए इसे सेटिंग्स में चालू करें।';

  @override
  String get chat_locationServicesOff =>
      'अपनी लोकेशन शेयर करने के लिए लोकेशन सर्विस चालू करें।';

  @override
  String get chat_locationUnavailable => 'लोकेशन उपलब्ध नहीं';

  @override
  String get chat_mediaMissing => 'मीडिया मौजूद नहीं है';

  @override
  String get chat_mediaMissingToast =>
      'मीडिया मौजूद नहीं है। यह फ़ाइल अब उपलब्ध नहीं है।';

  @override
  String get chat_mediaUnavailable => 'यह मीडिया अब उपलब्ध नहीं है';

  @override
  String get chat_menuForward => 'फ़ॉरवर्ड करें';

  @override
  String get chat_menuMessageInfo => 'मैसेज जानकारी';

  @override
  String get chat_menuPin => 'मैसेज पिन करें';

  @override
  String get chat_menuReply => 'जवाब दें';

  @override
  String get chat_menuUnpin => 'मैसेज अनपिन करें';

  @override
  String get chat_messageCopied => 'मैसेज कॉपी हो गया';

  @override
  String get chat_messageDeleted => 'यह मैसेज डिलीट कर दिया गया';

  @override
  String get chat_messageNotAvailable => 'मैसेज उपलब्ध नहीं है';

  @override
  String get chat_messageNotSent =>
      'मैसेज नहीं भेजा गया। कृपया फिर से कोशिश करें।';

  @override
  String get chat_noCameraFound => 'इस डिवाइस पर कोई कैमरा नहीं मिला।';

  @override
  String get chat_noLongerMember => 'आप अब इस ग्रुप के सदस्य नहीं हैं';

  @override
  String get chat_noMediaAvailable => 'कोई मीडिया उपलब्ध नहीं';

  @override
  String get chat_offlineNotSent => 'आप ऑफ़लाइन हैं। मैसेज नहीं भेजा गया।';

  @override
  String get chat_openDocument => 'डॉक्यूमेंट खोलें';

  @override
  String get chat_openInGoogleMaps => 'Google Maps में खोलें';

  @override
  String get chat_openSettings => 'सेटिंग्स खोलें';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लोग',
      one: '1 व्यक्ति',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'यह फ़ोटो अब उपलब्ध नहीं है';

  @override
  String get chat_previewAttendancePoll => 'अटेंडेंस पोल';

  @override
  String get chat_previewAudio => 'ऑडियो';

  @override
  String get chat_previewContact => 'कॉन्टैक्ट';

  @override
  String get chat_previewDocument => 'डॉक्यूमेंट';

  @override
  String get chat_previewLocation => 'लोकेशन';

  @override
  String get chat_previewMessage => 'मैसेज';

  @override
  String get chat_previewNewMessage => 'नया मैसेज';

  @override
  String get chat_previewOwnDeleted => 'आपने यह मैसेज डिलीट किया';

  @override
  String get chat_previewPhoto => 'फ़ोटो';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो',
      one: '1 फ़ोटो',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => 'पोल';

  @override
  String get chat_previewSticker => 'स्टिकर';

  @override
  String get chat_previewVideo => 'वीडियो';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वीडियो',
      one: '1 वीडियो',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => 'वॉइस मैसेज';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return 'वॉइस मैसेज ($duration)';
  }

  @override
  String get chat_recordingFailed => 'रिकॉर्डिंग नहीं हो सकी';

  @override
  String get chat_removeMember => 'सदस्य हटाएं';

  @override
  String get chat_removeMemberConfirm =>
      'क्या आप इस सदस्य को ग्रुप से हटाना चाहते हैं?';

  @override
  String get chat_replyHint => 'मैसेज का जवाब दें...';

  @override
  String get chat_searchMessages => 'मैसेज खोजें';

  @override
  String get chat_searchMessagesHint => 'मैसेज खोजें...';

  @override
  String get chat_searchMessagesSubtitle => 'कीवर्ड से मैसेज ढूँढें';

  @override
  String get chat_sendLocation => 'लोकेशन भेजें';

  @override
  String get chat_shareLocation => 'लोकेशन शेयर करें';

  @override
  String get chat_shareVideoFailed => 'वीडियो शेयर नहीं हो सका';

  @override
  String get chat_sharedFromApp => 'FG Tracker से शेयर किया गया';

  @override
  String get chat_sharedLocation => 'शेयर की गई लोकेशन';

  @override
  String get chat_showOriginal => 'मूल दिखाएं';

  @override
  String get chat_someone => 'कोई';

  @override
  String get chat_statusLabel => 'स्टेटस';

  @override
  String get chat_statusUnavailable => 'यह स्टेटस अब उपलब्ध नहीं है';

  @override
  String get chat_stop => 'रोकें';

  @override
  String get chat_stopEnglish => 'रोकें (अंग्रेज़ी)';

  @override
  String get chat_stopHindi => 'रोकें (हिंदी)';

  @override
  String get chat_takePhotoFailed => 'फ़ोटो नहीं ली जा सकी';

  @override
  String get chat_translatedToEnglish => 'अंग्रेज़ी में अनुवादित';

  @override
  String get chat_translatedToHindi => 'हिंदी में अनुवादित';

  @override
  String get chat_translating => 'अनुवाद हो रहा है...';

  @override
  String get chat_tryAgain => 'फिर से कोशिश करें';

  @override
  String get chat_typeMessageHint => 'मैसेज लिखें...';

  @override
  String get chat_typing => 'टाइप कर रहे हैं...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लोग टाइप कर रहे हैं...',
      one: '1 व्यक्ति टाइप कर रहा है...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name टाइप कर रहे हैं...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1, $name2 टाइप कर रहे हैं...';
  }

  @override
  String get chat_unableToOpen => 'खुल नहीं सका';

  @override
  String get chat_unableToOpenGoogleMaps => 'Google Maps नहीं खुल सका';

  @override
  String get chat_unblock => 'अनब्लॉक करें';

  @override
  String get chat_unblockContact => 'कॉन्टैक्ट अनब्लॉक करें';

  @override
  String get chat_unblockContactConfirm =>
      'क्या आप इस कॉन्टैक्ट को अनब्लॉक करना चाहते हैं?';

  @override
  String get chat_unblockFailed => 'यूज़र को अनब्लॉक नहीं कर सके';

  @override
  String get chat_unknown => 'अज्ञात';

  @override
  String get chat_unknownLocation => 'अज्ञात लोकेशन';

  @override
  String get chat_unsupportedMessage =>
      'यह मैसेज ऐप के इस वर्ज़न में सपोर्ट नहीं है';

  @override
  String get chat_updateGroup => 'ग्रुप अपडेट करें';

  @override
  String get chat_updateGroupSubtitle => 'ग्रुप की जानकारी बदलें';

  @override
  String chat_uploadFileFailed(String path) {
    return '$path अपलोड नहीं हो सका';
  }

  @override
  String get chat_userBlocked => 'यूज़र ब्लॉक हो गया';

  @override
  String get chat_userUnblocked => 'यूज़र अनब्लॉक हो गया';

  @override
  String get chat_videoDownloaded => 'वीडियो डाउनलोड हो गया';

  @override
  String get chat_videoThumbnailFailed => 'वीडियो थंबनेल नहीं बन सका';

  @override
  String get chat_videoUnavailable => 'यह वीडियो अब उपलब्ध नहीं है';

  @override
  String get chat_videoUploadFailed => 'वीडियो अपलोड नहीं हो सका';

  @override
  String get chat_voicePlayFailed => 'वॉइस मैसेज नहीं चल सका';

  @override
  String get chat_voiceUploadFailed =>
      'वॉइस मैसेज अपलोड नहीं हुआ। कृपया फिर से कोशिश करें।';

  @override
  String get chat_youBlockedContact => 'आपने इस कॉन्टैक्ट को ब्लॉक किया है';

  @override
  String get common_add => 'जोड़ें';

  @override
  String get common_allow => 'अनुमति दें';

  @override
  String get common_back => 'वापस';

  @override
  String get common_cancel => 'रद्द करें';

  @override
  String get common_close => 'बंद करें';

  @override
  String get common_comingSoon => 'जल्द आ रहा है';

  @override
  String get common_confirm => 'पुष्टि करें';

  @override
  String get common_continue => 'जारी रखें';

  @override
  String get common_copied => 'कॉपी हो गया';

  @override
  String get common_copy => 'कॉपी करें';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: '1 दिन पहले',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => 'हटाएं';

  @override
  String get common_dismiss => 'ठीक है';

  @override
  String get common_done => 'हो गया';

  @override
  String get common_edit => 'संपादित करें';

  @override
  String get common_error => 'त्रुटि';

  @override
  String get common_exit => 'बाहर निकलें';

  @override
  String get common_gotIt => 'समझ गया';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे पहले',
      one: '1 घंटा पहले',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'अभी-अभी';

  @override
  String common_lastSeen(String time) {
    return 'आखिरी बार देखा गया: $time';
  }

  @override
  String get common_loading => 'लोड हो रहा है…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '1 सदस्य',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट पहले',
      one: '1 मिनट पहले',
    );
    return '$_temp0';
  }

  @override
  String get common_next => 'आगे';

  @override
  String get common_no => 'नहीं';

  @override
  String get common_noData => 'कोई डेटा नहीं मिला';

  @override
  String get common_noInternet => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get common_notNow => 'अभी नहीं';

  @override
  String get common_offline => 'ऑफ़लाइन';

  @override
  String get common_ok => 'ठीक है';

  @override
  String get common_online => 'ऑनलाइन';

  @override
  String get common_open => 'खोलें';

  @override
  String get common_permissionDenied => 'अनुमति नहीं मिली';

  @override
  String get common_remove => 'हटाएं';

  @override
  String get common_retry => 'फिर से कोशिश करें';

  @override
  String get common_save => 'सहेजें';

  @override
  String get common_search => 'खोजें';

  @override
  String get common_send => 'भेजें';

  @override
  String get common_settings => 'सेटिंग्स';

  @override
  String get common_share => 'शेयर करें';

  @override
  String get common_somethingWentWrong =>
      'कुछ गलत हो गया। कृपया फिर से कोशिश करें।';

  @override
  String get common_submit => 'सबमिट करें';

  @override
  String get common_success => 'सफल';

  @override
  String get common_today => 'आज';

  @override
  String common_todayAt(String time) {
    return 'आज, $time';
  }

  @override
  String get common_tryAgain => 'फिर से कोशिश करें';

  @override
  String get common_viewAll => 'सभी देखें';

  @override
  String get common_yes => 'हाँ';

  @override
  String get common_yesterday => 'कल';

  @override
  String get common_you => 'आप';

  @override
  String get dialog_allowLocationAccess => 'लोकेशन एक्सेस की अनुमति दें';

  @override
  String get dialog_anErrorOccurred => 'एक त्रुटि हुई!';

  @override
  String get dialog_important => 'ज़रूरी!';

  @override
  String get dialog_locationPermissionRequired => 'लोकेशन अनुमति ज़रूरी है';

  @override
  String get dialog_locationPurposeBody =>
      'सेवा को बेहतर बनाने के लिए हमारा ऐप आपकी लोकेशन सेव करने हेतु उसे एक्सेस करने की अनुमति माँगता है। इससे हमारे कर्मचारी आपकी तय कार्य-स्थल तक सही तरह पहुँच पाते हैं।';

  @override
  String get dialog_locationSettingsAndroid =>
      'लोकेशन एक्सेस के बिना हम आपकी मौजूदा लोकेशन का पता नहीं लगा पाएँगे। कृपया \'सेटिंग्स\' पर टैप करें, फिर \'अनुमतियाँ\' में जाकर लोकेशन एक्सेस की अनुमति दें।';

  @override
  String get dialog_locationSettingsIos =>
      'लोकेशन-आधारित सेवाएँ देने के लिए इस ऐप को आपकी लोकेशन की ज़रूरत है। कृपया \'सेटिंग्स\' में जाकर लोकेशन अनुमति चालू करें।';

  @override
  String get dialog_loggedInElsewhere =>
      'आपने किसी दूसरे डिवाइस से लॉग इन किया है।';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      'आपने किसी दूसरे डिवाइस से लॉग इन किया है। कृपया दोबारा लॉग इन करें।';

  @override
  String get dialog_logoutConfirm => 'क्या आप लॉग आउट करना चाहते हैं?';

  @override
  String get dialog_selectAllowAllTheTime =>
      'अगले पॉपअप में कृपया\n\'हर समय अनुमति दें\' चुनें।';

  @override
  String get dialog_sessionExpiredTitle => 'सेशन खत्म हो गया';

  @override
  String get editProfile_fullNameLabel => 'पूरा नाम';

  @override
  String get editProfile_personalInfo => 'व्यक्तिगत जानकारी';

  @override
  String get editProfile_phoneLabel => 'फ़ोन नंबर';

  @override
  String get editProfile_saveButton => 'बदलाव सहेजें';

  @override
  String get editProfile_tapPhotoHint => 'बदलने के लिए फ़ोटो पर टैप करें';

  @override
  String get editProfile_title => 'प्रोफ़ाइल संपादित करें';

  @override
  String get forceUpdate_currentInstalled => 'वर्तमान में स्थापित';

  @override
  String get forceUpdate_defaultMessage =>
      'FG ट्रैकर का नया संस्करण उपलब्ध है। जारी रखने के लिए कृपया अपडेट करें।';

  @override
  String get forceUpdate_defaultTitle => 'अपडेट आवश्यक है';

  @override
  String get forceUpdate_fallbackMessage =>
      'महत्वपूर्ण सुधारों के साथ FG ट्रैकर का नया संस्करण उपलब्ध है। ऐप का उपयोग जारी रखने के लिए कृपया अपडेट करें।';

  @override
  String get forceUpdate_footer =>
      'FG ट्रैकर के साथ आगे बढ़ने के लिए अपडेट आवश्यक है';

  @override
  String get forceUpdate_requiredVersion => 'आवश्यक संस्करण';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return '$storeName पर अपडेट करें';
  }

  @override
  String get groupDialog_audioCall => 'ऑडियो कॉल';

  @override
  String get groupDialog_audioCallSubtitle => 'आवाज़ से बातचीत शुरू करें';

  @override
  String get groupDialog_call => 'कॉल';

  @override
  String get groupDialog_chat => 'चैट';

  @override
  String get groupDialog_codeEmpty => 'ग्रुप कोड खाली नहीं हो सकता';

  @override
  String get groupDialog_codeLabel => 'ग्रुप कोड';

  @override
  String get groupDialog_createButton => 'ग्रुप बनाएँ';

  @override
  String get groupDialog_createTitle => 'नया ग्रुप बनाएँ';

  @override
  String get groupDialog_descHint => 'ग्रुप विवरण डालें';

  @override
  String get groupDialog_descLabel => 'ग्रुप विवरण (वैकल्पिक)';

  @override
  String groupDialog_distance(String distance) {
    return 'दूरी: $distance';
  }

  @override
  String get groupDialog_enterCodeManually => 'ग्रुप कोड खुद डालें';

  @override
  String get groupDialog_enterCodeTitle => 'ग्रुप कोड डालें';

  @override
  String get groupDialog_fillDetails => 'नीचे विवरण भरें';

  @override
  String get groupDialog_getDirections => 'रास्ता देखें';

  @override
  String get groupDialog_join => 'ग्रुप से जुड़ें';

  @override
  String groupDialog_lastSeen(String time) {
    return 'आखिरी बार देखा गया: $time';
  }

  @override
  String get groupDialog_locationHidden => 'लोकेशन छिपी है';

  @override
  String get groupDialog_locationUnavailable => 'लोकेशन उपलब्ध नहीं';

  @override
  String get groupDialog_member => 'सदस्य';

  @override
  String get groupDialog_memberInfo => 'सदस्य की जानकारी';

  @override
  String get groupDialog_nameHint => 'ग्रुप का नाम डालें';

  @override
  String get groupDialog_nameLabel => 'ग्रुप का नाम';

  @override
  String get groupDialog_noQrInImage =>
      'चुनी गई इमेज में कोई QR कोड नहीं मिला।';

  @override
  String get groupDialog_noValidQr => 'कोई मान्य QR कोड नहीं मिला।';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'गैलरी से QR पढ़ने में त्रुटि: $error';
  }

  @override
  String get groupDialog_scanCamera => 'कैमरा से स्कैन करें';

  @override
  String get groupDialog_selectCallType => 'कॉल का प्रकार चुनें';

  @override
  String get groupDialog_update => 'अपडेट करें';

  @override
  String get groupDialog_updateTitle => 'ग्रुप अपडेट करें';

  @override
  String get groupDialog_uploadGallery => 'गैलरी से अपलोड करें';

  @override
  String get groupDialog_videoCall => 'वीडियो कॉल';

  @override
  String get groupDialog_videoCallSubtitle => 'वीडियो बातचीत शुरू करें';

  @override
  String get groupDialog_yourLocation => 'आपकी मौजूदा लोकेशन';

  @override
  String get groupInfo_active => 'सक्रिय';

  @override
  String get groupInfo_admin => 'एडमिन';

  @override
  String get groupInfo_allGroups => 'सभी ग्रुप';

  @override
  String get groupInfo_allGroupsSubtitle => 'अपनी टीमों से जुड़े रहें';

  @override
  String get groupInfo_areYouSure => 'क्या आप पक्का हैं?';

  @override
  String get groupInfo_audioCall => 'ऑडियो कॉल';

  @override
  String get groupInfo_clearChatConfirm => 'इस डिवाइस से सभी मैसेज डिलीट करें?';

  @override
  String get groupInfo_createdBy => 'बनाने वाले';

  @override
  String get groupInfo_detailsNotFound => 'ग्रुप की जानकारी नहीं मिली';

  @override
  String get groupInfo_exitGroup => 'ग्रुप छोड़ें';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return 'क्या आप \"$groupName\" छोड़ना चाहते हैं?';
  }

  @override
  String get groupInfo_exitGroupQuestion =>
      'क्या आप यह ग्रुप छोड़ना चाहते हैं?';

  @override
  String get groupInfo_group => 'ग्रुप';

  @override
  String get groupInfo_groupAdmin => 'ग्रुप एडमिन';

  @override
  String get groupInfo_groupCallFailed =>
      'ग्रुप कॉल शुरू नहीं हो सकी। कृपया फिर से कोशिश करें।';

  @override
  String get groupInfo_groupCodeCopied => 'ग्रुप कोड कॉपी हो गया!';

  @override
  String get groupInfo_groupSettings => 'ग्रुप सेटिंग्स';

  @override
  String get groupInfo_groupSettingsSubtitle =>
      'ग्रुप जानकारी, प्राइवेसी और बहुत कुछ एडिट करें';

  @override
  String get groupInfo_inactive => 'निष्क्रिय';

  @override
  String get groupInfo_inviteCopied => 'आमंत्रण टेक्स्ट कॉपी हो गया';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'FG Tracker पर मेरे ग्रुप \"$groupName\" से जुड़ें';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'FG Tracker पर मेरे ग्रुप \"$groupName\" से जुड़ें। कोड: $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'लिंक से आमंत्रित करें';

  @override
  String get groupInfo_mediaLinksDocs => 'मीडिया, लिंक और डॉक्स';

  @override
  String get groupInfo_member => 'सदस्य';

  @override
  String get groupInfo_members => 'सदस्य';

  @override
  String get groupInfo_messageAction => 'मैसेज करें';

  @override
  String groupInfo_nameYou(String name) {
    return '$name (आप)';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return '\'$query\' के लिए कोई ग्रुप नहीं मिला';
  }

  @override
  String get groupInfo_noGroupsYet =>
      'आपने अभी तक कोई ग्रुप जॉइन या नहीं बनाया है।\nअभी शुरू करें!';

  @override
  String get groupInfo_noMediaYet => 'अभी तक कोई मीडिया शेयर नहीं हुआ';

  @override
  String get groupInfo_removeFromGroup => 'ग्रुप से हटाएं';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return 'क्या आप $name को ग्रुप से हटाना चाहते हैं?';
  }

  @override
  String get groupInfo_searchGroupsHint => 'ग्रुप खोजें...';

  @override
  String get groupInfo_showLess => 'कम दिखाएं';

  @override
  String get groupInfo_teamCode => 'टीम कोड';

  @override
  String groupInfo_totalCount(int count) {
    return 'कुल $count';
  }

  @override
  String get groupInfo_unknownGroup => 'अज्ञात ग्रुप';

  @override
  String get groupInfo_unnamedGroup => 'बिना नाम का ग्रुप';

  @override
  String get groupInfo_videoCall => 'वीडियो कॉल';

  @override
  String get groupInfo_viewAllMembers => 'सभी सदस्य देखें';

  @override
  String get group_activatedSuccess => 'समूह सफलतापूर्वक सक्रिय किया गया';

  @override
  String get group_addMember => 'सदस्य जोड़ें';

  @override
  String get group_alignQr => 'फ़्रेम के अंदर QR कोड संरेखित करें';

  @override
  String get group_areYouSure => 'क्या आप सुनिश्चित हैं?';

  @override
  String get group_chatWithMembers => 'समूह के सदस्यों के साथ चैट करें';

  @override
  String get group_codeCopied => 'समूह कोड कॉपी हो गया!';

  @override
  String group_codeShareInfo(String code) {
    return 'समूह कोड: $code — इसे साझा करें ताकि अन्य शामिल हो सकें';
  }

  @override
  String get group_copyCode => 'कोड कॉपी करें';

  @override
  String get group_created => 'बनाया गया';

  @override
  String get group_createdJustNow => 'अभी-अभी बनाया गया';

  @override
  String get group_deactivatedSuccess => 'समूह सफलतापूर्वक निष्क्रिय किया गया';

  @override
  String get group_defaultName => 'समूह';

  @override
  String get group_deleteGroup => 'समूह हटाएं';

  @override
  String get group_deleteGroupConfirm => 'क्या आप इस समूह को हटाना चाहते हैं?';

  @override
  String get group_deletedSuccess => 'समूह सफलतापूर्वक हटा दिया गया';

  @override
  String get group_download => 'डाउनलोड करें';

  @override
  String get group_downloadChannelDescription =>
      'QR कोड डाउनलोड होने पर सूचित करता है';

  @override
  String get group_downloadChannelName => 'डाउनलोड सूचनाएं';

  @override
  String get group_enableLocationToJoin =>
      'समूह में शामिल होने के लिए कृपया स्थान सेवाएँ सक्षम करें।';

  @override
  String get group_exitGroup => 'समूह छोड़ें';

  @override
  String get group_exitGroupConfirm =>
      'क्या आप इस समूह से बाहर निकलना चाहते हैं?';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return 'क्या आप वाकई \"$groupName\" छोड़ना चाहते हैं? दोबारा जुड़ने के लिए आपको समूह कोड की आवश्यकता होगी।';
  }

  @override
  String get group_exitedSuccess => 'समूह से सफलतापूर्वक बाहर निकल गए';

  @override
  String get group_goToGroups => 'समूहों पर जाएं →';

  @override
  String get group_groupMessage => 'समूह संदेश';

  @override
  String get group_invalidResponseFormat => 'अमान्य प्रारूप';

  @override
  String get group_joinedJustNow => 'अभी-अभी जुड़े';

  @override
  String get group_joinedRecently => 'हालिया';

  @override
  String get group_leftJustNow => 'अभी-अभी छोड़ दिया';

  @override
  String get group_locationNoLongerShared =>
      'आपका स्थान अब इस समूह के साथ साझा नहीं किया जाता है';

  @override
  String get group_locationPermissionToJoin =>
      'समूह में शामिल होने के लिए स्थान की अनुमति आवश्यक है।';

  @override
  String get group_locationShared =>
      'आपका स्थान इस समूह के साथ साझा किया जा रहा है';

  @override
  String get group_memberFallbackName => 'सदस्य';

  @override
  String group_membersMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य · $when',
      one: '1 सदस्य · $when',
    );
    return '$_temp0';
  }

  @override
  String get group_noContactsFound => 'कोई संपर्क नहीं मिला';

  @override
  String get group_noGroupCode => 'कोई समूह कोड उपलब्ध नहीं है';

  @override
  String get group_noNewMessages => 'आपको इस समूह से नए संदेश नहीं मिलेंगे';

  @override
  String get group_noNumber => 'कोई नंबर नहीं';

  @override
  String get group_openGroup => 'समूह खोलें →';

  @override
  String get group_other => 'अन्य';

  @override
  String get group_qrSavedBody => 'अपना QR कोड खोलने के लिए टैप करें';

  @override
  String get group_qrSavedTitle => 'QR कोड सहेजा गया';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 समूह कोड: $groupCode\n\nQR कोड या ऊपर दिए गए कोड का उपयोग करके तुरंत मेरे समूह में शामिल हों।\n\n📲 जुड़े रहने के लिए ऐप डाउनलोड करें:\n$appLink';
  }

  @override
  String get group_scanToJoin =>
      'समूह में शामिल होने के लिए इस QR कोड को स्कैन करें';

  @override
  String get group_searchMemberHint => 'सदस्य खोजें...';

  @override
  String get group_shareCodeInfo =>
      'समूह कोड साझा करें ताकि अन्य शामिल हो सकें';

  @override
  String get group_shareQr => 'QR साझा करें';

  @override
  String get group_shareQrToInvite =>
      'सदस्यों को आमंत्रित करने के लिए QR कोड साझा करें';

  @override
  String get group_sheetCreatedSubtitle =>
      'आपका समूह तैयार है। कोड साझा करें ताकि सदस्य शामिल हो सकें।';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name, आपका समूह तैयार है। कोड साझा करें ताकि सदस्य शामिल हो सकें।';
  }

  @override
  String get group_sheetCreatedTitle => 'समूह बन गया!';

  @override
  String get group_sheetJoinedSubtitle =>
      'स्वागत है, अब आप इस समूह के सदस्य हैं।';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return 'स्वागत है $name, अब आप इस समूह के सदस्य हैं।';
  }

  @override
  String get group_sheetJoinedTitle => 'सफलतापूर्वक शामिल हुए!';

  @override
  String get group_sheetLeftSubtitle => 'अब आप इस समूह के सदस्य नहीं हैं।';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name, अब आप इस समूह के सदस्य नहीं हैं।';
  }

  @override
  String get group_sheetLeftTitle => 'आपने समूह छोड़ दिया';

  @override
  String get group_showQrCode => 'QR कोड दिखाएं';

  @override
  String get group_startConversation => 'बातचीत शुरू करने में संकोच न करें';

  @override
  String get group_statusUpdateFailed => 'समूह स्थिति अपडेट करने में विफल';

  @override
  String get group_teamCode => 'टीम कोड';

  @override
  String get group_teamCodeLabel => 'टीम कोड: ';

  @override
  String get group_track => 'ट्रैक';

  @override
  String get group_unnamedMember => 'अनाम सदस्य';

  @override
  String get group_unnamedTrip => 'अनाम यात्रा';

  @override
  String get group_updateGroupConfirm =>
      'क्या आप वाकई समूह विवरण अपडेट करना चाहते हैं?';

  @override
  String get group_updateGroupTitle => 'समूह अपडेट करें';

  @override
  String get group_youAreAdmin => 'आप इस समूह के व्यवस्थापक (एडमिन) हैं';

  @override
  String get home_actionAllContacts => 'सभी संपर्क';

  @override
  String get home_actionAudioVideoCall => 'ऑडियो/वीडियो कॉल';

  @override
  String get home_actionChatting => 'चैटिंग';

  @override
  String get home_actionSafeZone => 'सुरक्षित क्षेत्र (सेफ ज़ोन)';

  @override
  String get home_actionTracking => 'ट्रैकिंग';

  @override
  String get home_actionWalkieTalkie => 'वॉकी टॉकी';

  @override
  String get home_active => 'सक्रिय';

  @override
  String get home_activeSessions => 'सक्रिय सत्र';

  @override
  String home_activeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सक्रिय सत्र',
      one: '1 सक्रिय सत्र',
    );
    return '$_temp0';
  }

  @override
  String get home_allMembers => 'सभी सदस्य';

  @override
  String get home_createGroup => 'समूह बनाएं';

  @override
  String get home_createGroupSubtitle => 'नया समूह बनाएं';

  @override
  String get home_goodToSeeYou => 'आपको फिर से देखकर अच्छा लगा 👋';

  @override
  String home_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समूह',
      one: '1 समूह',
    );
    return '$_temp0';
  }

  @override
  String home_helloName(String name) {
    return 'नमस्ते $name';
  }

  @override
  String get home_inactive => 'निष्क्रिय';

  @override
  String get home_joinGroup => 'समूह में शामिल हों';

  @override
  String get home_joinGroupSubtitle => 'मौजूदा समूह से जुड़ें';

  @override
  String home_lastSeen(String time) {
    return 'अंतिम बार देखा गया $time';
  }

  @override
  String get home_newThisMonth => 'इस महीने नए';

  @override
  String get home_noActivePrivateSessions => 'कोई सक्रिय निजी सत्र नहीं';

  @override
  String get home_noGroupsAvailable => 'कोई समूह उपलब्ध नहीं है';

  @override
  String get home_noGroupsFound => 'कोई समूह नहीं मिला';

  @override
  String get home_noMembersFound => 'कोई सदस्य नहीं मिला';

  @override
  String home_noMembersMatch(String query) {
    return 'कोई भी सदस्य \'$query\' से मेल नहीं खाता';
  }

  @override
  String get home_noMembersOnline => 'वर्तमान में कोई सदस्य ऑनलाइन नहीं है';

  @override
  String get home_noNameGroup => 'बिना नाम का समूह';

  @override
  String get home_noRecentlyActiveMembers => 'हाल ही में कोई सक्रिय सदस्य नहीं';

  @override
  String get home_onlineNow => 'अभी ऑनलाइन';

  @override
  String get home_peopleOnline => 'ऑनलाइन लोग';

  @override
  String get home_peopleOnlineSubtitle =>
      'ये सदस्य अभी ऐप में सक्रिय हैं और जुड़ने के लिए उपलब्ध हैं।';

  @override
  String get home_privateMode => 'निजी मोड (प्राइवेट)';

  @override
  String get home_privateModeIsOn => 'निजी मोड चालू है';

  @override
  String get home_privateModeOffHint =>
      'जब निजी मोड बंद होता है, तो अन्य आपका स्थान देख सकते हैं।';

  @override
  String get home_privateModeOnHint =>
      'जब निजी मोड चालू होता है, तो अन्य आपका स्थान नहीं देख सकते।';

  @override
  String get home_quickActionsSubtitle =>
      'सब कुछ आपकी पहुंच में, सिर्फ एक टैप दूर।';

  @override
  String get home_quickActionsTitle => 'त्वरित कार्रवाइयां';

  @override
  String get home_recentlyOnline => 'हाल ही में ऑनलाइन';

  @override
  String get home_searchGroupsHint => 'समूह खोजें...';

  @override
  String get home_searchMembersHint => 'सदस्यों को खोजें...';

  @override
  String get home_showLess => 'कम दिखाएं';

  @override
  String get home_sortNameAsc => 'क्रमबद्ध: नाम (A-Z)';

  @override
  String get home_sortNameDesc => 'क्रमबद्ध: नाम (Z-A)';

  @override
  String home_startedAt(String time) {
    return '$time पर शुरू हुआ';
  }

  @override
  String get home_statGroups => 'समूह';

  @override
  String get home_statMembers => 'सदस्य';

  @override
  String get home_statNow => 'अभी';

  @override
  String get home_statTotal => 'कुल';

  @override
  String get home_totalMembers => 'कुल सदस्य';

  @override
  String home_totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कुल सदस्य',
      one: '1 कुल सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get home_unableToFetchGroups => 'समूह प्राप्त करने में असमर्थ';

  @override
  String get home_unknownMember => 'अज्ञात सदस्य';

  @override
  String get home_upgradeSubtitle =>
      'अपनी टीम के लिए उन्नत सुविधाएं अनलॉक करें';

  @override
  String get home_upgradeToPremium => 'प्रीमियम में अपग्रेड करें';

  @override
  String get home_viewPlans => 'योजनाएं देखें';

  @override
  String get home_walkieExpired => 'समाप्त';

  @override
  String get home_walkieOneHourFree => '1 घंटा मुफ़्त';

  @override
  String get home_walkieRenew => 'नवीनीकरण करें';

  @override
  String get home_walkieSubscribed => 'सक्रिय सदस्यता';

  @override
  String get home_youAreInvisible => 'आप अदृश्य हैं';

  @override
  String get home_youAreVisible => 'आप दिखाई दे रहे हैं';

  @override
  String get http_networkError => 'कोई त्रुटि हुई। कृपया दोबारा कोशिश करें!';

  @override
  String get http_sessionExpired =>
      'सेशन खत्म हो गया। कृपया दोबारा लॉग इन करें।';

  @override
  String get http_unexpectedError =>
      'एक अनपेक्षित त्रुटि हुई। कृपया दोबारा कोशिश करें।';

  @override
  String get imagePicker_camera => 'कैमरा';

  @override
  String get imagePicker_cancel => 'रद्द करें';

  @override
  String get imagePicker_cropTitle => 'इमेज क्रॉप करें';

  @override
  String get imagePicker_gallery => 'गैलरी';

  @override
  String get imagePicker_title => 'एक विकल्प चुनें';

  @override
  String get intro_realTimeTrackingSubtitle =>
      'मानचित्र पर तुरंत मित्रों, परिवार या टीम के सदस्यों के लाइव स्थान देखें।';

  @override
  String get intro_realTimeTrackingTitle => 'वास्तविक समय ट्रैकिंग';

  @override
  String get intro_secureSubtitle =>
      'चयनित संपर्कों के साथ अपना लाइव स्थान\nसुरक्षित और निजी तौर पर साझा करें।';

  @override
  String get intro_secureTitle => 'सुरक्षित और आसान';

  @override
  String get intro_skip => 'छोड़ें';

  @override
  String get intro_walkieSubtitle =>
      'कोई सिग्नल नहीं। कोई समस्या नहीं। कहीं भी\nजुड़े रहें।';

  @override
  String get intro_walkieTitle => 'वॉकी-टॉकी\nसुविधा';

  @override
  String login_dataSecure(String percent) {
    return 'आपका डेटा $percent सुरक्षित है';
  }

  @override
  String get login_enterMobileNumber => 'मोबाइल नंबर दर्ज करें';

  @override
  String get media_cannotOpen => 'खोल नहीं सकते';

  @override
  String get media_documentNotFound => 'डॉक्यूमेंट नहीं मिला';

  @override
  String get media_invalidLink => 'अमान्य लिंक';

  @override
  String get media_noDocuments => 'कोई डॉक्यूमेंट नहीं मिला';

  @override
  String get media_noLinks => 'कोई लिंक नहीं मिला';

  @override
  String get media_noMedia => 'कोई मीडिया नहीं मिला';

  @override
  String get media_tabDocs => 'डॉक्स';

  @override
  String media_tabDocsCount(int count) {
    return 'डॉक्स ($count)';
  }

  @override
  String get media_tabLinks => 'लिंक';

  @override
  String media_tabLinksCount(int count) {
    return 'लिंक ($count)';
  }

  @override
  String get media_tabMedia => 'मीडिया';

  @override
  String media_tabMediaCount(int count) {
    return 'मीडिया ($count)';
  }

  @override
  String get media_title => 'मीडिया, लिंक और डॉक्स';

  @override
  String get media_videoNotFound => 'वीडियो नहीं मिला';

  @override
  String get menu_contactUsSubtitle => 'हमारे बारे में अधिक जानें';

  @override
  String get menu_editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get menu_editProfileSubtitle => 'अपनी जानकारी अपडेट करें';

  @override
  String get menu_followUsOn => 'हमें फ़ॉलो करें';

  @override
  String get menu_logOut => 'लॉग आउट';

  @override
  String get menu_logOutConfirmMessage =>
      'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get menu_logOutSubtitle => 'ऐप से साइन आउट करें';

  @override
  String get menu_profileImageUpdateFailed =>
      'प्रोफ़ाइल फ़ोटो अपडेट करने में विफल';

  @override
  String get menu_profileImageUpdated =>
      'प्रोफ़ाइल फ़ोटो सफलतापूर्वक अपडेट की गई';

  @override
  String get notif_accept => 'स्वीकारें';

  @override
  String get notif_channelHighImportanceDesc =>
      'ज़रूरी सूचनाओं के लिए डिफ़ॉल्ट चैनल';

  @override
  String get notif_channelHighImportanceName => 'ज़रूरी सूचनाएँ';

  @override
  String get notif_channelWalkieAudioDesc =>
      'लाइव आवाज़ संचार और बैकग्राउंड में माइक चालू रखता है';

  @override
  String get notif_channelWalkieAudioName => 'वॉकी-टॉकी लाइव ऑडियो';

  @override
  String get notif_channelWalkieCallsDesc => 'आने वाली वॉकी-टॉकी कॉल';

  @override
  String get notif_channelWalkieCallsName => 'वॉकी-टॉकी कॉल';

  @override
  String get notif_channelWalkieDesc => 'ग्रुप वॉकी कॉल और बोलने की अपडेट';

  @override
  String get notif_channelWalkieLiveDesc => 'चालू वॉकी-टॉकी चैनलों की सूचनाएँ';

  @override
  String get notif_channelWalkieLiveName => 'वॉकी-टॉकी लाइव चैनल';

  @override
  String get notif_channelWalkieName => 'वॉकी-टॉकी';

  @override
  String notif_connectedIn(String group) {
    return '$group में जुड़े हैं • लाइव ऑडियो';
  }

  @override
  String get notif_goToWalkie => 'वॉकी स्क्रीन पर जाएँ';

  @override
  String get notif_incomingWalkieTitle => 'वॉकी-टॉकी कॉल आ रही है';

  @override
  String notif_isTalking(String name) {
    return '$name बोल रहे हैं';
  }

  @override
  String get notif_leave => 'छोड़ें';

  @override
  String get notif_openWalkie => 'वॉकी खोलें';

  @override
  String get notif_reject => 'अस्वीकारें';

  @override
  String notif_stoppedTalking(String name) {
    return '$name ने बोलना बंद किया';
  }

  @override
  String get notif_walkieActiveConversation => 'वॉकी-टॉकी पर बातचीत चल रही है';

  @override
  String get notif_walkieActiveTitle => 'वॉकी-टॉकी चालू है';

  @override
  String notif_wantsToTalk(String name) {
    return '$name बात करना चाहते हैं';
  }

  @override
  String get notifications_clearAll => 'सभी सूचनाएं हटाएं';

  @override
  String get notifications_clearedSuccess =>
      'सभी सूचनाएं सफलतापूर्वक हटा दी गईं';

  @override
  String get notifications_emptySubtitle =>
      'इस समय आपके पास कोई नया अलर्ट नहीं है।';

  @override
  String get notifications_emptyTitle => 'अभी कोई सूचना नहीं है';

  @override
  String get notifications_filterAll => 'सभी';

  @override
  String get notifications_filterCalls => 'कॉल';

  @override
  String get notifications_filterChats => 'चैट';

  @override
  String get notifications_filterUnread => 'अपठित';

  @override
  String get notifications_loadingDetails => 'सूचना विवरण लोड हो रहा है';

  @override
  String get notifications_recentCalls => 'हाल की कॉल';

  @override
  String get notifications_title => 'सूचनाएं';

  @override
  String get otpCharges_chargedNotice =>
      'अब से, आपके नंबर पर प्रत्येक लॉगिन OTP चार्ज किया जाएगा। OTP दोबारा भेजना मुफ़्त है (अधिकतम 3 प्रयास)।';

  @override
  String get otpCharges_chargesApplyTo => 'शुल्क इस पर लागू होते हैं';

  @override
  String get otpCharges_eachOtpCosts => 'प्रत्येक OTP की लागत';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'प्रत्येक OTP की लागत $amount है';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'प्रत्येक OTP की लागत $amount है, जिसमें $percent प्रतिशत जीएसटी शामिल है';
  }

  @override
  String get otpCharges_firstLoginFree => 'आपका पहला लॉगिन मुफ़्त था।';

  @override
  String get otpCharges_freeBody =>
      'इस नंबर पर भेजे गए लॉगिन OTP पर कोई शुल्क नहीं लिया जाता है।';

  @override
  String get otpCharges_freeTitle => 'आपके नंबर के लिए OTP मुफ़्त है';

  @override
  String otpCharges_gstTitle(String percent) {
    return 'जीएसटी ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return '$percent% जीएसटी शामिल';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return '$percent% कर शामिल';
  }

  @override
  String get otpCharges_noInternet =>
      'कोई इंटरनेट कनेक्शन नहीं है। अपना नेटवर्क जांचें और पुनः प्रयास करें।';

  @override
  String get otpCharges_otpCharge => 'OTP शुल्क';

  @override
  String otpCharges_pay(String amount) {
    return '$amount भुगतान करें';
  }

  @override
  String get otpCharges_paymentCancelled =>
      'भुगतान रद्द किया गया। आपने भुगतान रद्द कर दिया। कोई पैसा नहीं काटा गया।';

  @override
  String get otpCharges_paymentFailed =>
      'भुगतान विफल रहा। यदि पैसे कट गए हैं तो 5-7 कार्य दिवसों में वापस कर दिए जाएंगे।';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return 'भुगतान रुका हुआ ($amount)';
  }

  @override
  String get otpCharges_paymentReceived =>
      'भुगतान प्राप्त हुआ। आपका OTP आने में कुछ समय लग सकता है।';

  @override
  String get otpCharges_paymentStartFailed =>
      'भुगतान शुरू नहीं किया जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get otpCharges_paymentsPaused =>
      'प्रशासक द्वारा OTP भुगतान अस्थायी रूप से रोक दिए गए हैं। विवरण के लिए नीचे टैप करें।';

  @override
  String get otpCharges_paymentsUnavailable =>
      'OTP भुगतान अस्थायी रूप से अनुपलब्ध हैं। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get otpCharges_sessionExpired =>
      'सत्र समाप्त हो गया। कृपया फिर से शुरू करें।';

  @override
  String get otpCharges_title => 'OTP शुल्क';

  @override
  String get otpCharges_totalPerOtp => 'प्रति OTP कुल';

  @override
  String get otpCharges_tryAgainMoment =>
      'कुछ गलत हो गया। कृपया कुछ पलों में पुनः प्रयास करें।';

  @override
  String get otpCharges_unknownBody =>
      'भारतीय नंबरों पर लॉगिन OTP मुफ़्त हैं। अन्य देशों के लिए, लॉगिन पर भुगतान करने से पहले सटीक मूल्य दिखाया जाता है।';

  @override
  String get otpCharges_unknownTitle => 'OTP शुल्क आपके देश पर निर्भर करता है';

  @override
  String get otpCharges_updateApp =>
      'भुगतान शुरू नहीं हो सका। कृपया ऐप अपडेट करें और पुनः प्रयास करें।';

  @override
  String otpCharges_vatTitle(String percent) {
    return 'वैट / कर ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      'भुगतान सत्यापन विफल रहा। यदि पैसे कट गए हैं तो 5-7 कार्य दिवसों में वापस कर दिए जाएंगे।';

  @override
  String get otpCharges_yourNumber => 'आपका नंबर';

  @override
  String get package_noPackages => 'अभी कोई पैकेज उपलब्ध नहीं है।';

  @override
  String package_plansComingSoon(String title) {
    return '$title योजनाएं जल्द आ रही हैं';
  }

  @override
  String get package_subtitle => 'योजनाएं देखने के लिए कोई मॉड्यूल चुनें';

  @override
  String get package_title => 'पैकेज और मूल्य निर्धारण';

  @override
  String get package_viewPlans => 'योजनाएं देखें';

  @override
  String get perm_alwaysLocationBody =>
      'अपने ग्रुप को रियल टाइम और बैकग्राउंड में ट्रैक करने के लिए, कृपया ऐप सेटिंग्स में लोकेशन एक्सेस को \'हर समय अनुमति दें\' पर सेट करें।';

  @override
  String get perm_alwaysLocationTitle => '\'हमेशा\' लोकेशन अनुमति चालू करें';

  @override
  String get perm_chooseAllowAllTime =>
      'कृपया अगले पॉपअप में \'हर समय अनुमति दें\' चुनें।';

  @override
  String get perm_collectsLocationBody =>
      'काम सुचारू रूप से चलाने और बेहतर ट्रैकिंग के लिए यह ऐप लोकेशन डेटा इकट्ठा करता है, तब भी जब ऐप बंद हो या इस्तेमाल में न हो।';

  @override
  String get perm_enableDeviceGpsBody =>
      'कृपया अपने डिवाइस का GPS (Google Location) चालू करें।';

  @override
  String get perm_enableGpsTitle => 'GPS चालू करें';

  @override
  String get perm_exitBody => 'क्या आप ऐप से बाहर निकलना चाहते हैं?';

  @override
  String get perm_exitTitle => 'क्या आप निश्चित हैं?';

  @override
  String get perm_gpsRequiredBody =>
      'अपने ग्रुप को रियल टाइम में ट्रैक करने के लिए GPS ज़रूरी है।';

  @override
  String get perm_locationTitle => 'लोकेशन अनुमति';

  @override
  String get perm_trackingPermissionBody =>
      'लॉग इन रहने के दौरान लोकेशन ट्रैक करने के लिए FG Partner ऐप को आपकी अनुमति चाहिए।';

  @override
  String get permission_allowAllTheTime => 'हमेशा अनुमति दें';

  @override
  String get permission_allowLocation => 'स्थान की अनुमति दें';

  @override
  String get permission_allowLocationFirst => 'कृपया पहले स्थान की अनुमति दें।';

  @override
  String permission_allowNamed(String permission) {
    return '$permission की अनुमति दें';
  }

  @override
  String get permission_allowNotifications => 'सूचनाओं की अनुमति दें';

  @override
  String get permission_appPermissionsSubtitle =>
      'आवश्यक अनुमतियों की समीक्षा करें।';

  @override
  String get permission_appPermissionsTitle => 'ऐप अनुमतियाँ';

  @override
  String get permission_badgeGranted => 'अनुमत';

  @override
  String get permission_badgeOptional => 'वैकल्पिक';

  @override
  String get permission_badgeRecommended => 'अनुशंसित';

  @override
  String get permission_badgeRequired => 'आवश्यक';

  @override
  String get permission_camera => 'कैमरा';

  @override
  String get permission_cameraDescription =>
      'फ़ोटो या वीडियो कैप्चर करने वाली ऐप सुविधाओं द्वारा उपयोग किया जाता है।';

  @override
  String get permission_cameraSettingsMessage =>
      'फ़ोटो और वीडियो लेने के लिए कैमरा अनुमति आवश्यक है। कृपया इसे ऐप सेटिंग्स से सक्षम करें।';

  @override
  String get permission_cameraWhy =>
      'समर्थित प्रोफ़ाइल, चैट और अन्य ऐप सुविधाओं के लिए फ़ोटो और वीडियो लेने की अनुमति देता है।';

  @override
  String get permission_contacts => 'संपर्क';

  @override
  String get permission_contactsDescription =>
      'संपर्क संबंधी सुविधाओं के लिए संपर्कों को खोजने या चुनने के लिए उपयोग किया जाता है।';

  @override
  String get permission_contactsSettingsMessage =>
      'संपर्कों को खोजने और चुनने के लिए संपर्क अनुमति की आवश्यकता है। कृपया इसे ऐप सेटिंग्स से सक्षम करें।';

  @override
  String get permission_contactsWhy =>
      'समर्थित संपर्क सुविधाओं का उपयोग करते समय संपर्कों को ढूंढने और चुनने में मदद करता है।';

  @override
  String get permission_gateCheckFailed =>
      'हम आपकी अनुमतियों की जांच नहीं कर सके। कृपया पुनः प्रयास करें।';

  @override
  String get permission_gateSubtitle =>
      'FG ट्रैकर को कॉल और अलर्ट प्राप्त करने और उपस्थिति, लाइव ट्रैकिंग और सुरक्षित क्षेत्र चलाने के लिए इन अनुमतियों की आवश्यकता है।';

  @override
  String get permission_gateTitle => 'अनुमतियाँ आवश्यक हैं';

  @override
  String get permission_genericSettingsMessage =>
      'यह अनुमति आवश्यक है। कृपया इसे ऐप सेटिंग्स से सक्षम करें।';

  @override
  String get permission_iosLocationServicesOff =>
      'स्थान सेवाएं बंद हैं। सेटिंग्स → गोपनीयता और सुरक्षा → स्थान सेवाएं खोलें और इसे चालू करें, फिर वापस आएं।';

  @override
  String get permission_location => 'स्थान';

  @override
  String get permission_locationAndNotificationRequired =>
      'जारी रखने के लिए स्थान और सूचना अनुमतियाँ आवश्यक हैं।';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      'जारी रखने के लिए स्थान और सूचनाएं आवश्यक हैं।';

  @override
  String get permission_locationDescription =>
      'उपस्थिति, लाइव ट्रैकिंग और सुरक्षित क्षेत्र के लिए आवश्यक — जिसमें बैकग्राउंड में होना भी शामिल है।';

  @override
  String get permission_locationRequiredToContinue =>
      'जारी रखने के लिए स्थान की अनुमति आवश्यक है।';

  @override
  String get permission_locationStatusApproximate =>
      'केवल अनुमानित स्थान की अनुमति है। सटीक आवश्यक है।';

  @override
  String get permission_locationStatusBlocked =>
      'स्थान अवरुद्ध है। इसे सेटिंग्स से सक्षम करें।';

  @override
  String get permission_locationStatusDone =>
      'हमेशा अनुमत · सटीक · जीपीएस चालू';

  @override
  String get permission_locationStatusGpsOff => 'डिवाइस स्थान (GPS) बंद है।';

  @override
  String get permission_locationStatusNeedAlways =>
      '\"हमेशा अनुमति दें\" आवश्यक है।';

  @override
  String get permission_locationStatusNotAllowed =>
      'स्थान की अनुमति अभी नहीं दी गई है।';

  @override
  String get permission_locationWhyExtra =>
      'कृपया \"हमेशा अनुमति दें\" चुनें और सटीक स्थान चालू रखें।';

  @override
  String get permission_logout => 'लॉग आउट';

  @override
  String get permission_microphone => 'माइक्रोफ़ोन / ऑडियो';

  @override
  String get permission_microphoneDescription =>
      'आवाज़, वॉकी-टॉकी और कॉलिंग सुविधाओं द्वारा उपयोग किया जाता है।';

  @override
  String get permission_microphoneSettingsMessage =>
      'आवाज़, वॉकी-टॉकी और कॉल के लिए माइक्रोफ़ोन की अनुमति आवश्यक है। कृपया इसे ऐप सेटिंग्स से सक्षम करें।';

  @override
  String get permission_microphoneWhy =>
      'वॉइस संचार, वॉकी-टॉकी ट्रांसमिशन और कॉल करने की अनुमति देता है।';

  @override
  String permission_notGrantedNamed(String permission) {
    return '$permission की अनुमति नहीं दी गई थी। कृपया पुनः प्रयास करें।';
  }

  @override
  String get permission_notificationRequiredToContinue =>
      'जारी रखने के लिए सूचना की अनुमति आवश्यक है।';

  @override
  String get permission_notificationSettingsText =>
      'FG ट्रैकर के लिए सूचनाएं बंद हैं। सेटिंग्स → सूचनाएं खोलें और अनुमति दें।';

  @override
  String get permission_notificationStatusBlocked =>
      'सूचनाएं अवरुद्ध हैं। उन्हें सेटिंग्स से सक्षम करें।';

  @override
  String get permission_notificationStatusDone => 'अनुमत';

  @override
  String get permission_notificationStatusNotAllowed =>
      'सूचना की अनुमति अभी नहीं दी गई है।';

  @override
  String get permission_notifications => 'सूचनाएं';

  @override
  String get permission_notificationsDescription =>
      'इनकमिंग कॉल, चैट संदेश और उपस्थिति/सुरक्षित क्षेत्र अलर्ट प्राप्त करने के लिए आवश्यक।';

  @override
  String get permission_notificationsWhyExtra =>
      'इस अनुमति के बिना इनकमिंग कॉल की घंटी नहीं बज सकती।';

  @override
  String get permission_openSettings => 'सेटिंग्स खोलें';

  @override
  String get permission_preciseLocation => 'सटीक स्थान';

  @override
  String get permission_pushNotifications => 'पुश सूचनाएं';

  @override
  String get permission_reasonLocation =>
      'उपस्थिति, लाइव ट्रैकिंग और सुरक्षित क्षेत्र अलर्ट के लिए स्थान आवश्यक है।';

  @override
  String get permission_reasonLocationAlways =>
      '\"हमेशा अनुमति दें\" चुनें ताकि ऐप बैकग्राउंड में होने पर भी लाइव ट्रैकिंग और सेफ ज़ोन काम करते रहें।';

  @override
  String get permission_reasonNotification =>
      'इनकमिंग कॉल, चैट संदेश, उपस्थिति और सुरक्षित क्षेत्र अलर्ट प्राप्त करने के लिए सूचनाएं आवश्यक हैं।';

  @override
  String get permission_reasonPrecise =>
      'सटीक उपस्थिति, लाइव ट्रैकिंग और सुरक्षित क्षेत्र अलर्ट के लिए सटीक स्थान आवश्यक है।';

  @override
  String get permission_required => 'अनुमति आवश्यक है';

  @override
  String get permission_selectAllowAllTheTime =>
      'जारी रखने के लिए कृपया \"हमेशा अनुमति दें\" चुनें।';

  @override
  String get permission_settingsAndroidAlways =>
      'सेटिंग्स → अनुमतियाँ → स्थान खोलें और \"हमेशा अनुमति दें\" चुनें।';

  @override
  String get permission_settingsAndroidBlocked =>
      'FG ट्रैकर के लिए स्थान पहुंच अवरुद्ध है। सेटिंग्स → अनुमतियाँ → स्थान खोलें और \"हमेशा अनुमति दें\" चुनें।';

  @override
  String get permission_settingsAndroidPrecise =>
      'सेटिंग्स → अनुमतियाँ → स्थान खोलें और \"सटीक स्थान का उपयोग करें\" चालू करें।';

  @override
  String get permission_settingsIosAlways =>
      'सेटिंग्स → स्थान खोलें और \"हमेशा\" चुनें।';

  @override
  String get permission_settingsIosBlocked =>
      'FG ट्रैकर के लिए स्थान पहुंच बंद है। सेटिंग्स → स्थान खोलें और \"हमेशा\" चुनें।';

  @override
  String get permission_settingsIosPrecise =>
      'सेटिंग्स → स्थान खोलें और \"सटीक स्थान\" चालू करें।';

  @override
  String get permission_skipAndContinue => 'छोड़ें और जारी रखें';

  @override
  String get permission_turnOnLocation => 'स्थान (GPS) चालू करें';

  @override
  String get permission_turnOnPreciseLocation => 'सटीक स्थान चालू करें';

  @override
  String get permission_unableToRequest => 'अनुमति का अनुरोध करने में असमर्थ।';

  @override
  String get permission_whyWeNeedThis => 'हमें इसकी आवश्यकता क्यों है?';

  @override
  String get registration_contactNumberHint => 'संपर्क नंबर दर्ज करें';

  @override
  String get registration_contactNumberLabel => 'संपर्क नंबर';

  @override
  String get registration_doneButton => 'पूर्ण';

  @override
  String get registration_emailHint => 'ईमेल पता दर्ज करें';

  @override
  String get registration_emailLabel => 'ईमेल पता';

  @override
  String get registration_genderFemale => 'महिला';

  @override
  String get registration_genderLabel => 'लिंग चुनें';

  @override
  String get registration_genderMale => 'पुरुष';

  @override
  String get registration_genderOther => 'अन्य';

  @override
  String get registration_selectGenderError => 'कृपया अपना लिंग चुनें';

  @override
  String get registration_userNameHint => 'उपयोगकर्ता नाम दर्ज करें';

  @override
  String get registration_userNameLabel => 'उपयोगकर्ता नाम';

  @override
  String get repo_allCallsCleared => 'पूरी कॉल हिस्ट्री साफ़ हो गई';

  @override
  String get repo_callDeleted => 'कॉल हिस्ट्री डिलीट हो गई';

  @override
  String get repo_invalidResponse => 'जवाब का फ़ॉर्मेट गलत है';

  @override
  String get repo_loadLocationsFailed => 'ग्रुप लोकेशन लोड नहीं हो सकीं';

  @override
  String get repo_pkgConflict =>
      'यह प्लान पहले से चालू है या पेमेंट प्रोसेस में है।';

  @override
  String get repo_pkgNotFound =>
      'प्लान अभी उपलब्ध नहीं हैं। कृपया बाद में कोशिश करें।';

  @override
  String get repo_pkgOffline =>
      'इंटरनेट कनेक्शन नहीं है। अपना नेटवर्क जाँचें और दोबारा कोशिश करें।';

  @override
  String get repo_pkgSessionExpired =>
      'आपका सेशन खत्म हो गया है। कृपया दोबारा लॉग इन करें।';

  @override
  String get repo_pkgTimeout =>
      'सर्वर जवाब देने में बहुत समय ले रहा है। कृपया दोबारा कोशिश करें।';

  @override
  String get repo_selectedCallsDeleted => 'चुनी गई कॉल डिलीट हो गईं';

  @override
  String get repo_unnamedGroup => 'बिना नाम का ग्रुप';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return 'कुल दूरी: $distance  •  अनुमत विचलन: $deviation';
  }

  @override
  String get safeRoute_activeTitle => 'सक्रिय सुरक्षित मार्ग';

  @override
  String get safeRoute_alertSettingsDesc =>
      'सुरक्षित मार्ग अलर्ट, विचलन सीमाएं और अधिसूचना प्राथमिकताएं प्रबंधित करें।';

  @override
  String get safeRoute_alertSheetDesc =>
      'जब टीम के सदस्य सुरक्षित मार्ग से भटकते हैं तो रीयल-टाइम अलर्ट';

  @override
  String get safeRoute_alertTitle => 'सुरक्षित मार्ग अलर्ट';

  @override
  String get safeRoute_appBarSubtitle =>
      'अपनी टीम के सदस्य के लिए एक सुरक्षित मार्ग निर्धारित करें।';

  @override
  String get safeRoute_destination => 'गंतव्य';

  @override
  String get safeRoute_deviated => 'सुरक्षित मार्ग से भटक गए';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'यदि सदस्य सुरक्षित मार्ग से $distance से अधिक भटकता है तो अलर्ट चालू हो जाएगा।';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (विचलन: $distance)';
  }

  @override
  String get safeRoute_deviationLimit => 'विचलन सीमा';

  @override
  String get safeRoute_deviationSubtitle =>
      'निर्धारित करें कि चयनित मार्ग से कितने विचलन की अनुमति है।';

  @override
  String get safeRoute_distance => 'दूरी';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance किमी • $minutes मिनट';
  }

  @override
  String get safeRoute_edit => 'सुरक्षित मार्ग संपादित करें';

  @override
  String get safeRoute_end => 'समाप्त';

  @override
  String safeRoute_estTime(int minutes) {
    return 'अनुमानित समय: $minutes मिनट';
  }

  @override
  String get safeRoute_featureDesc =>
      'अपनी टीम के सदस्यों के लिए पूर्व-निर्धारित मार्ग निर्धारित करें। यदि कोई सुरक्षित मार्ग से भटकता है तो अलर्ट प्राप्त करें।';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '1 सदस्य',
    );
    return '$group ($_temp0)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'निर्धारित दूरी सेट करें जिससे सदस्य चयनित मार्ग से दूर जा सकता है। सीमा पार होने पर आपको अलर्ट मिलेगा।';

  @override
  String get safeRoute_helpDeviationTitle => 'विचलन सीमा क्या है?';

  @override
  String get safeRoute_helpHowBody =>
      'सदस्य चुनें, प्रारंभ और गंतव्य स्थान चुनें, सर्वश्रेष्ठ मार्ग चुनें और विचलन सीमा निर्धारित करें।';

  @override
  String get safeRoute_helpHowTitle => 'सुरक्षित मार्ग कैसे बनाएं?';

  @override
  String get safeRoute_helpTitle => 'सुरक्षित मार्ग सहायता';

  @override
  String get safeRoute_helpWhatBody =>
      'अपनी टीम के सदस्य के लिए एक सुरक्षित यात्रा मार्ग बनाने के लिए एक प्रारंभ और गंतव्य स्थान निर्धारित करें।';

  @override
  String get safeRoute_helpWhatTitle => 'सुरक्षित मार्ग क्या है?';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$name सुरक्षित मार्ग से भटक गए हैं';
  }

  @override
  String get safeRoute_recommended => 'अनुशंसित';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (अनुशंसित)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'मार्ग ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'सुरक्षित मार्ग सहेजें और सक्रिय करें';

  @override
  String get safeRoute_saveActivateGroup =>
      'समूह के लिए सुरक्षित मार्ग सहेजें और सक्रिय करें';

  @override
  String get safeRoute_selectedRoute => 'चयनित मार्ग';

  @override
  String get safeRoute_setRoutesSubtitle =>
      'सभी समूह सदस्यों के लिए सुरक्षित मार्ग बनाएं और प्रबंधित करें।';

  @override
  String get safeRoute_start => 'शुरू';

  @override
  String get safeRoute_startLocation => 'प्रस्थान स्थान';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. विचलन सीमा निर्धारित करें';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. पूर्वावलोकन करें और लागू करें';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. मार्ग का पूर्वावलोकन करें';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. मार्ग चुनें';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. सदस्यों के लिए मार्ग निर्धारित करें';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. प्रस्थान और गंतव्य निर्धारित करें';
  }

  @override
  String get safeRoute_subtitle => 'मार्ग सुरक्षा';

  @override
  String get safeRoute_title => 'सुरक्षित मार्ग (सेफ रूट)';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return 'दायरा: $radius  •  केंद्र: $center';
  }

  @override
  String get safeZone_activePreview => 'सक्रिय (पूर्वावलोकन)';

  @override
  String get safeZone_activeTitle => 'सक्रिय सुरक्षित क्षेत्र';

  @override
  String get safeZone_alertSettingsDesc =>
      'सुरक्षित क्षेत्र, अलर्ट दूरी और अधिसूचना प्राथमिकताएं प्रबंधित करें';

  @override
  String get safeZone_alertSheetDesc =>
      'जब टीम के सदस्य सुरक्षित क्षेत्र छोड़ते हैं तो रीयल-टाइम अलर्ट';

  @override
  String get safeZone_alertTitle => 'सुरक्षित क्षेत्र अलर्ट';

  @override
  String safeZone_allMonitored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'इस सुरक्षित क्षेत्र के भीतर सभी $count सदस्यों की\nनिगरानी की जाएगी।',
      one: 'इस सुरक्षित क्षेत्र के भीतर 1 सदस्य की\nनिगरानी की जाएगी।',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_appBarSubtitle =>
      'एक सुरक्षित क्षेत्र परिभाषित करें। यदि कोई सुरक्षित\nक्षेत्र से बाहर निकलता है तो अलर्ट प्राप्त करें।';

  @override
  String safeZone_appliedToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'यह सुरक्षित क्षेत्र चयनित समूह के सभी $count सदस्यों पर लागू होगा।',
      one: 'यह सुरक्षित क्षेत्र चयनित समूह के 1 सदस्य पर लागू होगा।',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_edit => 'सुरक्षित क्षेत्र संपादित करें';

  @override
  String get safeZone_exited => 'सुरक्षित क्षेत्र से बाहर निकल गए';

  @override
  String get safeZone_featureDesc =>
      'अपनी टीम के लिए एक सुरक्षित भौगोलिक क्षेत्र परिभाषित करें। यदि कोई सुरक्षित क्षेत्र से बाहर कदम रखता है तो तुरंत अलर्ट प्राप्त करें।';

  @override
  String get safeZone_helpHowBody =>
      'एक सदस्य चुनें, मानचित्र पर एक स्थान चुनें और दायरा निर्धारित करें।';

  @override
  String get safeZone_helpHowTitle => 'सुरक्षित क्षेत्र कैसे बनाएं?';

  @override
  String get safeZone_helpRadiusBody =>
      'अपनी आवश्यकता के अनुसार क्षेत्र का दायरा (500 मी, 1 किमी, 2 किमी या 5 किमी) निर्धारित करें।';

  @override
  String get safeZone_helpRadiusTitle => 'सुरक्षित क्षेत्र का दायरा क्या है?';

  @override
  String get safeZone_helpTitle => 'सुरक्षित क्षेत्र सहायता';

  @override
  String get safeZone_helpWhatBody =>
      'मानचित्र पर एक विशिष्ट क्षेत्र निर्धारित करें और यदि सदस्य सुरक्षित क्षेत्र से बाहर निकलता है तो अलर्ट प्राप्त करें।';

  @override
  String get safeZone_helpWhatTitle => 'सुरक्षित क्षेत्र क्या है?';

  @override
  String safeZone_memberLeft(String name) {
    return '$name सुरक्षित क्षेत्र से बाहर चले गए हैं';
  }

  @override
  String get safeZone_membersMonitored =>
      'इस सुरक्षित क्षेत्र के भीतर सदस्यों की निगरानी की जाएगी।';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return '$place के पास ($zone के बाहर)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place ($zone के बाहर)';
  }

  @override
  String get safeZone_saveActivate => 'सुरक्षित क्षेत्र सहेजें और सक्रिय करें';

  @override
  String get safeZone_saveActivateGroup =>
      'समूह के लिए सुरक्षित क्षेत्र सहेजें और सक्रिय करें';

  @override
  String get safeZone_searchLocation => 'स्थान खोजें...';

  @override
  String get safeZone_statusLabel => 'स्थिति:';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. सुरक्षित क्षेत्र का पूर्वावलोकन करें';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. सुरक्षित क्षेत्र का दायरा निर्धारित करें';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. मानचित्र पर स्थान चुनें';
  }

  @override
  String get safeZone_subtitle => 'क्षेत्र सुरक्षा';

  @override
  String get safeZone_title => 'सुरक्षित क्षेत्र (सेफ ज़ोन)';

  @override
  String safeZone_totalMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कुल $count सदस्य',
      one: 'कुल 1 सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get safety_active => 'सक्रिय';

  @override
  String get safety_alertSettings => 'अलर्ट सेटिंग्स';

  @override
  String get safety_alerts => 'अलर्ट';

  @override
  String get safety_alertsDesc => 'तत्काल ध्यान देने की आवश्यकता है';

  @override
  String get safety_bannerBody =>
      'स्मार्ट सुरक्षा सुविधाओं के साथ अपनी टीम की निगरानी और सुरक्षा करें।';

  @override
  String get safety_bannerTitle => 'आपकी सुरक्षा, हमारी प्राथमिकता';

  @override
  String get safety_chooseFeature => 'एक सुरक्षा सुविधा चुनें';

  @override
  String get safety_comingSoonBody =>
      'आपकी टीम की सुरक्षा के लिए स्मार्ट सुरक्षा सुविधाएं जल्द आ रही हैं।';

  @override
  String get safety_contactSupport => 'सहायता से संपर्क करें';

  @override
  String get safety_editAnytime =>
      'आप बाद में कभी भी संपादित या निष्क्रिय कर सकते हैं।';

  @override
  String get safety_mapCityPark => 'सिटी पार्क';

  @override
  String get safety_mapMainRoad => 'मुख्य मार्ग';

  @override
  String get safety_mapMarketLane => 'मार्केट लेन';

  @override
  String get safety_mapRiver => 'नदी';

  @override
  String get safety_mapStationRoad => 'स्टेशन रोड';

  @override
  String get safety_needHelpBody =>
      'सुरक्षा संबंधी किसी भी सहायता के लिए सहायता टीम से संपर्क करें।';

  @override
  String get safety_quickOverview => 'त्वरित समीक्षा';

  @override
  String get safety_recentAlerts => 'हाल के अलर्ट';

  @override
  String get safety_recenter => 'पुनः केंद्रित करें';

  @override
  String get safety_safeNow => 'अभी सुरक्षित';

  @override
  String get safety_safeNowDesc => 'सदस्य सुरक्षित क्षेत्र/मार्ग के भीतर हैं';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. समूह चुनें';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. सदस्य चुनें';
  }

  @override
  String get safety_tabIndividual => 'व्यक्तिगत';

  @override
  String get safety_tagline => 'सुरक्षित रहें। जुड़े रहें।';

  @override
  String get safety_title => 'सुरक्षा (सेफ्टी)';

  @override
  String get safety_viewAllMembers => 'सभी सदस्य देखें';

  @override
  String get sheet_addGroupMember => 'ग्रुप सदस्य जोड़ें';

  @override
  String get sheet_admin => 'एडमिन';

  @override
  String get sheet_attachSubtitle =>
      'अपनी टीम के साथ फ़ाइलें और मीडिया शेयर करें';

  @override
  String get sheet_attachUpload => 'अटैच / अपलोड';

  @override
  String get sheet_attendance => 'हाज़िरी';

  @override
  String get sheet_callOptions => 'कॉल विकल्प';

  @override
  String get sheet_cantRemoveSelf => 'आप खुद को ग्रुप से नहीं हटा सकते।';

  @override
  String get sheet_contact => 'संपर्क';

  @override
  String get sheet_contactsNotOnApp =>
      'आपके संपर्क अभी FG Tracker का इस्तेमाल नहीं कर रहे हैं।';

  @override
  String get sheet_document => 'डॉक्यूमेंट';

  @override
  String get sheet_groupMembers => 'ग्रुप सदस्य';

  @override
  String get sheet_location => 'लोकेशन';

  @override
  String get sheet_memberRemoved => 'सदस्य हटा दिया गया';

  @override
  String get sheet_noMembers => 'कोई सदस्य नहीं मिला';

  @override
  String get sheet_noRegisteredContacts => 'कोई रजिस्टर्ड संपर्क नहीं';

  @override
  String get sheet_noUserFound => 'कोई उपयोगकर्ता नहीं मिला';

  @override
  String get sheet_normalAudioCall => 'सामान्य ऑडियो कॉल';

  @override
  String get sheet_normalAudioCallSubtitle => 'साफ़ और सामान्य आवाज़ गुणवत्ता';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रजिस्टर्ड संपर्क',
      one: '1 रजिस्टर्ड संपर्क',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return 'क्या आप वाकई $name को ग्रुप से हटाना चाहते हैं?';
  }

  @override
  String get sheet_removeMemberTitle => 'सदस्य हटाएँ';

  @override
  String get sheet_searchContacts => 'संपर्क खोजें';

  @override
  String get sheet_walkieCall => 'वॉकी-टॉकी कॉल';

  @override
  String get sheet_walkieCallSubtitle => 'दबाकर बात करें (PTT)';

  @override
  String get sos_addDetailsMandatory => 'विवरण जोड़ें (अनिवार्य)';

  @override
  String get sos_addDetailsOptional => 'विवरण जोड़ें (वैकल्पिक)';

  @override
  String get sos_addFamilyMember => 'परिवार का सदस्य जोड़ें';

  @override
  String get sos_addFamilyMemberRequired =>
      'SOS अलर्ट भेजने के लिए कम से कम 1 परिवार का सदस्य जोड़ें';

  @override
  String get sos_addPhotoHint =>
      'दूसरों को स्थिति बेहतर ढंग से समझने में मदद के लिए फ़ोटो संलग्न करें।';

  @override
  String get sos_addPhotoOptional => 'फ़ोटो जोड़ें (वैकल्पिक)';

  @override
  String get sos_alertSent => 'SOS अलर्ट भेजा गया!';

  @override
  String get sos_alertSentToNearby =>
      'आपका अलर्ट आस-पास के लोगों को भेज दिया गया है।';

  @override
  String get sos_alertWillBeSent => 'अलर्ट आस-पास के लोगों को भेजा जाएगा';

  @override
  String get sos_alertWillBeSentFamily =>
      'आपका अलर्ट आस-पास के लोगों और आपके परिवार को भेजा जाएगा।';

  @override
  String sos_availableUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count उपलब्ध उपयोगकर्ता',
      one: '1 उपलब्ध उपयोगकर्ता',
    );
    return '$_temp0';
  }

  @override
  String get sos_detailsHint => 'कोई अतिरिक्त विवरण लिखें...';

  @override
  String get sos_detailsMandatoryForOther =>
      'जब \'अन्य\' कारण चुना जाता है तो विवरण जोड़ना अनिवार्य है';

  @override
  String get sos_howItWorks => 'यह कैसे काम करता है';

  @override
  String get sos_howItWorksIntro =>
      'SOS अलर्ट आपातकालीन स्थितियों में आस-पास के लोगों और आपके परिवार को सूचित करने में मदद करता है।';

  @override
  String get sos_howItWorksTitle => 'SOS अलर्ट कैसे काम करता है?';

  @override
  String get sos_liveTrackingStarted => 'लाइव ट्रैकिंग शुरू हो गई';

  @override
  String sos_locationSharedWithFamily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपका स्थान परिवार के $count सदस्यों के साथ साझा किया जा रहा है',
      one: 'आपका स्थान परिवार के 1 सदस्य के साथ साझा किया जा रहा है',
    );
    return '$_temp0';
  }

  @override
  String sos_membersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य चुने गए',
      one: '1 सदस्य चुना गया',
    );
    return '$_temp0';
  }

  @override
  String get sos_needHelp => 'मदद चाहिए?';

  @override
  String get sos_needHelpBody =>
      'आस-पास के लोगों को SOS अलर्ट भेजें।\nउन्हें सूचित किया जाएगा और वे आपकी सहायता कर सकते हैं।';

  @override
  String get sos_noMatchFound => 'कोई मिलान नहीं मिला';

  @override
  String get sos_noUsersFound => 'कोई उपयोगकर्ता नहीं मिला';

  @override
  String get sos_notifyFamilyTitle =>
      'अपने परिवार को सूचित करें (1 से 5 आवश्यक)';

  @override
  String get sos_notifyUpdates =>
      'हम आपको किसी भी अपडेट के बारे में सूचित करेंगे';

  @override
  String get sos_okGotIt => 'ठीक है, समझ गया';

  @override
  String get sos_peopleWithinRadius => '2 किमी के दायरे में लोग';

  @override
  String get sos_privacyNote =>
      'आपकी गोपनीयता महत्वपूर्ण है। आपका स्थान केवल सक्रिय SOS अलर्ट के दौरान साझा किया जाता है।';

  @override
  String get sos_reasonAccident => 'दुर्घटना';

  @override
  String get sos_reasonMedical => 'चिकित्सा आपातकाल';

  @override
  String get sos_reasonOther => 'अन्य';

  @override
  String get sos_reasonSafety => 'सुरक्षा खतरा';

  @override
  String get sos_reasonThreat => 'धमकी / ख़तरा';

  @override
  String get sos_required => 'आवश्यक';

  @override
  String get sos_searchUsers => 'उपयोगकर्ता खोजें';

  @override
  String get sos_selectReason => 'कारण चुनें';

  @override
  String get sos_sendSosAlert => 'SOS अलर्ट भेजें';

  @override
  String get sos_stayCalm => 'शांत रहें, मदद रास्ते में है';

  @override
  String get sos_step1Body =>
      'SOS बटन पर टैप करें और आस-पास के लोगों को अलर्ट भेजें।';

  @override
  String get sos_step1Title => '1. SOS अलर्ट भेजें';

  @override
  String get sos_step2Body =>
      'आस-पास के लोगों को आपके स्थान के साथ आपका अलर्ट प्राप्त होगा।';

  @override
  String get sos_step2Title => '2. आस-पास के लोगों को सूचित करें';

  @override
  String get sos_step3Body =>
      'आस-पास के लोग आपका अलर्ट देख सकते हैं और आपकी मदद के लिए पहुंच सकते हैं।';

  @override
  String get sos_step3Title => '3. तेजी से मदद पाएं';

  @override
  String get sos_step4Body =>
      'आपके परिवार के सदस्यों को आपके SOS के बारे में तुरंत सूचित किया जाएगा।';

  @override
  String get sos_step4Title => '4. परिवार को सूचित किया जाता है';

  @override
  String get sos_subtitle => 'आस-पास के लोगों को अलर्ट भेजें';

  @override
  String get sos_title => 'SOS अलर्ट';

  @override
  String get sos_willBeNotified => 'को सूचित किया जाएगा';

  @override
  String status_activeCount(int count) {
    return '$count सक्रिय';
  }

  @override
  String get status_addToMyStatus => 'मेरे स्टेटस में जोड़ें';

  @override
  String get status_allContacts => 'सभी संपर्क';

  @override
  String get status_cameraAccessFailed => 'कैमरा एक्सेस नहीं हो सका';

  @override
  String get status_captionHint => 'कैप्शन जोड़ें...';

  @override
  String get status_changeMedia => 'मीडिया बदलें';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get status_deleted => 'स्टेटस डिलीट हो गया';

  @override
  String get status_deletedByOwner => 'यह स्टेटस इसके मालिक ने डिलीट कर दिया';

  @override
  String get status_exceptContacts => 'इन संपर्कों को छोड़कर';

  @override
  String get status_exceptSelected => 'चुने हुए को छोड़कर';

  @override
  String get status_flip => 'कैमरा बदलें';

  @override
  String get status_gallery => 'गैलरी';

  @override
  String get status_modePhoto => 'फ़ोटो';

  @override
  String get status_modeText => 'टेक्स्ट';

  @override
  String get status_modeVideo => 'वीडियो';

  @override
  String get status_myStatus => 'मेरा स्टेटस';

  @override
  String get status_new => 'नया';

  @override
  String get status_noCamera => 'कोई कैमरा उपलब्ध नहीं';

  @override
  String get status_noLongerAvailable => 'यह स्टेटस अब उपलब्ध नहीं है';

  @override
  String get status_noViewsYet => 'अभी तक किसी ने नहीं देखा';

  @override
  String get status_onlyShareWith => 'सिर्फ़ इनके साथ शेयर करें';

  @override
  String get status_pause => 'रोकें';

  @override
  String get status_pinchZoomHint => 'फ़ोटो ज़ूम करने के लिए पिंच करें';

  @override
  String get status_play => 'चलाएँ';

  @override
  String get status_postStatus => 'स्टेटस पोस्ट करें';

  @override
  String get status_previewStatus => 'स्टेटस प्रीव्यू';

  @override
  String get status_privacy => 'प्राइवेसी';

  @override
  String get status_privacyTitle => 'स्टेटस प्राइवेसी';

  @override
  String get status_publishFailed => 'स्टेटस पोस्ट नहीं हो सका';

  @override
  String get status_replyHint => 'स्टेटस का जवाब दें...';

  @override
  String get status_retake => 'फिर से लें';

  @override
  String get status_selectPhotoFirst => 'कृपया पहले फ़ोटो लें या चुनें';

  @override
  String get status_selectVideoFirst =>
      'कृपया पहले वीडियो रिकॉर्ड करें या चुनें';

  @override
  String get status_shareUpdatesHint => 'अपनी टीम के साथ अपडेट शेयर करें';

  @override
  String get status_tapVideoHint => 'चलाने / रोकने के लिए वीडियो पर टैप करें';

  @override
  String get status_textRequired =>
      'टेक्स्ट स्टेटस के लिए टेक्स्ट लिखना ज़रूरी है';

  @override
  String get status_title => 'स्टेटस';

  @override
  String get status_typeHint => 'स्टेटस लिखें...';

  @override
  String get status_uploadFailed => 'अपलोड नहीं हुआ';

  @override
  String get status_viewMyStatus => 'मेरा स्टेटस देखें';

  @override
  String get status_viewed => 'देखा गया';

  @override
  String status_viewedBy(int count) {
    return '$count ने देखा';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count व्यू',
      one: '1 व्यू',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => 'कौन देख सकता है?';

  @override
  String get track_admin => 'व्यवस्थापक (एडमिन)';

  @override
  String get track_applyRadius => 'दायरा लागू करें';

  @override
  String get track_checkNetworkConnection =>
      'कृपया अपना नेटवर्क कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get track_checkNetworkMembers =>
      'आस-पास के सदस्यों को देखने के लिए कृपया अपना नेटवर्क जांचें और पुनः प्रयास करें।';

  @override
  String get track_currentLocation => 'वर्तमान स्थान';

  @override
  String get track_custom => 'कस्टम';

  @override
  String track_customWithValue(String radius) {
    return 'कस्टम ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return '$distance दूर';
  }

  @override
  String get track_enable => 'सक्षम करें';

  @override
  String get track_enableGpsBody =>
      'अपने समूह को वास्तविक समय में ट्रैक करने के लिए, कृपया अपना जीपीएस चालू करें।';

  @override
  String get track_enableGpsTitle => 'जीपीएस सक्षम करें';

  @override
  String get track_errorFailedLoadGroups => 'समूह लोड करने में विफल';

  @override
  String get track_errorLoadGroups =>
      'समूह लोड करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get track_errorLoadMembers =>
      'आस-पास के सदस्यों को लोड करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get track_errorNoInternet =>
      'कोई इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें।';

  @override
  String get track_errorServer =>
      'सर्वर से कनेक्ट करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String track_groupCode(String code) {
    return 'कोड: $code';
  }

  @override
  String get track_groupMembers => 'समूह सदस्य';

  @override
  String track_groupMembersAndCode(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य • कोड: $code',
      one: '1 सदस्य • कोड: $code',
    );
    return '$_temp0';
  }

  @override
  String get track_groupTab => 'समूह';

  @override
  String track_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समूह',
      one: '1 समूह',
    );
    return '$_temp0';
  }

  @override
  String track_groupsHeader(int count) {
    return 'समूह ($count)';
  }

  @override
  String get track_helpGroupBody =>
      'एकाधिक सदस्यों को ट्रैक करने के लिए एक समूह बनाएं।';

  @override
  String get track_helpGroupTitle => 'समूह कैसे जोड़ें?';

  @override
  String get track_helpLiveBody =>
      'मानचित्र पर टीम के वास्तविक समय के स्थान को ट्रैक करें।';

  @override
  String get track_helpLiveTitle => 'लाइव ट्रैकिंग क्या है?';

  @override
  String get track_helpRadiusBody =>
      'मानचित्र पर आस-पास के सदस्यों को खोजने के लिए क्षेत्र सेट करें।';

  @override
  String get track_helpRadiusTitle => 'ट्रैकिंग दायरा क्या है?';

  @override
  String get track_helpTitle => 'ट्रैकिंग सहायता';

  @override
  String track_lastSeen(String time) {
    return 'अंतिम बार देखा गया: $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count लाइव';
  }

  @override
  String get track_liveMembers => 'लाइव सदस्य';

  @override
  String get track_liveTracking => 'लाइव ट्रैकिंग';

  @override
  String get track_locating => 'स्थान खोज रहे हैं...';

  @override
  String get track_locationHidden => 'स्थान छिपा हुआ है';

  @override
  String get track_locationUnavailable => 'स्थान अनुपलब्ध है';

  @override
  String get track_mapOfflineBody =>
      'लाइव मानचित्र डेटा और रीयल-टाइम सदस्य स्थान लोड करने के लिए इंटरनेट कनेक्शन आवश्यक है।';

  @override
  String get track_mapUnavailableOffline => 'मानचित्र ऑफ़लाइन अनुपलब्ध है';

  @override
  String get track_member => 'सदस्य';

  @override
  String track_memberPausedSharing(String name) {
    return '$name ने स्थान साझाकरण रोक दिया है। लाइव स्थान उपलब्ध नहीं है।';
  }

  @override
  String track_membersHeader(int count) {
    return 'सदस्य ($count)';
  }

  @override
  String track_membersLive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य लाइव',
      one: '1 सदस्य लाइव',
    );
    return '$_temp0';
  }

  @override
  String get track_menuMembers => 'सदस्य';

  @override
  String get track_menuRefreshMap => 'मानचित्र रिफ्रेश करें';

  @override
  String get track_menuTheme => 'थीम';

  @override
  String get track_nearbyYou => 'आपके आस-पास';

  @override
  String get track_noActiveMembers => 'कोई सक्रिय सदस्य नहीं';

  @override
  String track_noActiveMembersWithin(String radius) {
    return '$radius के भीतर कोई सक्रिय सदस्य नहीं मिला';
  }

  @override
  String get track_noDescription => 'कोई विवरण नहीं';

  @override
  String get track_noGroupsFound => 'कोई समूह नहीं मिला';

  @override
  String get track_noGroupsMatch => 'कोई समूह मेल नहीं खाता';

  @override
  String track_noGroupsMatchQuery(String query) {
    return 'कोई भी समूह \'$query\' से मेल नहीं खाता';
  }

  @override
  String get track_noGroupsYet =>
      'आप अभी तक किसी भी समूह में शामिल नहीं हुए हैं या कोई समूह नहीं बनाया है।';

  @override
  String get track_noInternetTitle => 'कोई इंटरनेट कनेक्शन नहीं';

  @override
  String get track_noMembersFound => 'कोई सदस्य नहीं मिला';

  @override
  String get track_noMembersFoundPlain => 'कोई सदस्य नहीं मिला';

  @override
  String get track_noMembersInGroup => 'इस समूह में कोई सदस्य नहीं मिला';

  @override
  String track_noMembersMatch(String query) {
    return 'कोई भी सदस्य \'$query\' से मेल नहीं खाता';
  }

  @override
  String track_noSearchMatches(String query) {
    return 'कोई मेल खाते सदस्य या समूह नहीं';
  }

  @override
  String track_noSearchResults(String query) {
    return '\'$query\' के लिए कोई सदस्य या समूह नहीं मिला';
  }

  @override
  String get track_notAvailable => 'लागू नहीं';

  @override
  String get track_offlineBanner =>
      'कोई इंटरनेट कनेक्शन नहीं है। मानचित्र और ट्रैकिंग ऑफ़लाइन हैं।';

  @override
  String get track_private => 'निजी';

  @override
  String get track_radius => 'दायरा (रेडियस)';

  @override
  String get track_refresh => 'रिफ्रेश करें';

  @override
  String get track_refreshing => 'ताज़ा किया जा रहा है...';

  @override
  String get track_retryConnection => 'कनेक्शन पुनः प्रयास करें';

  @override
  String get track_searchHint => 'सदस्य या समूह खोजें...';

  @override
  String get track_searchMembersHint => 'सदस्य खोजें...';

  @override
  String get track_selectedLocation => 'चयनित स्थान';

  @override
  String get track_setRadiusSubtitle =>
      'क्षेत्र का दायरा चुनने के लिए स्लाइड करें';

  @override
  String get track_setRadiusTitle => 'ट्रैकिंग दायरा सेट करें';

  @override
  String get track_unableToLoadGroups => 'समूह लोड करने में असमर्थ';

  @override
  String get track_unableToLoadMembers => 'सदस्यों को लोड करने में असमर्थ';

  @override
  String get track_unnamedGroup => 'बिना नाम का समूह';

  @override
  String get track_unnamedMember => 'अनाम सदस्य';

  @override
  String get track_yourGroups => 'आपके समूह';

  @override
  String get track_yourLocationPaused =>
      'आपका लाइव स्थान साझाकरण रुका हुआ और निजी है।';

  @override
  String get util_previewContact => '👤 संपर्क';

  @override
  String get util_previewDocument => '📄 डॉक्यूमेंट';

  @override
  String get util_previewLocation => '📍 लोकेशन';

  @override
  String get util_previewPhoto => '📷 फ़ोटो';

  @override
  String get util_previewVideo => '🎥 वीडियो';

  @override
  String get util_previewVoice => '🎤 वॉइस मैसेज';

  @override
  String util_spokenEur(String amount) {
    return '$amount यूरो';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amount पाउंड';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupees रुपये',
      one: '1 रुपया',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees रुपये $paise पैसे';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount अमेरिकी डॉलर';
  }

  @override
  String get util_unableToCallContact => 'इस संपर्क को कॉल नहीं किया जा सका';

  @override
  String get util_unableToStartGroupCall => 'ग्रुप कॉल शुरू नहीं हो सकी';

  @override
  String get validation_emailEmpty => 'ईमेल पता खाली नहीं हो सकता';

  @override
  String get validation_emailInvalid => 'कृपया एक मान्य ईमेल पता दर्ज करें।';

  @override
  String validation_required(String field) {
    return '$field आवश्यक है';
  }

  @override
  String get voice_appLanguage => 'ऐप की भाषा';

  @override
  String get voice_audioChip => 'ऑडियो';

  @override
  String get voice_captionReady => 'कैप्शन तैयार है';

  @override
  String get voice_chooseSpeechLanguage => 'भाषण की भाषा चुनें';

  @override
  String get voice_couldntPlay => 'वॉइस संदेश चलाया नहीं जा सका';

  @override
  String get voice_didntCatch =>
      'समझ नहीं आया। माइक पर टैप करें और थोड़ा ज़ोर से बोलें।';

  @override
  String get voice_language => 'भाषा';

  @override
  String get voice_listenBack => 'फिर से सुनें';

  @override
  String get voice_listenBeforeSending =>
      'अपना वॉइस संदेश भेजने से पहले सुनें।';

  @override
  String get voice_listening => 'सुन रहे हैं…';

  @override
  String get voice_micPermissionNeeded =>
      'वॉइस का उपयोग करने के लिए माइक्रोफ़ोन अनुमति आवश्यक है।';

  @override
  String get voice_micUnavailable =>
      'माइक्रोफ़ोन अनुपलब्ध है। कृपया सेटिंग्स जांचें।';

  @override
  String get voice_noTextCaptured =>
      'कोई टेक्स्ट कैप्चर नहीं हुआ — पुनः रिकॉर्ड करने का प्रयास करें।';

  @override
  String get voice_openSettings => 'सेटिंग्स खोलें';

  @override
  String get voice_permissionRequired => 'अनुमति आवश्यक है';

  @override
  String get voice_reRecord => 'फिर से रिकॉर्ड करें';

  @override
  String get voice_readyToSend => 'भेजने के लिए तैयार';

  @override
  String get voice_recordVoice => 'आवाज़ रिकॉर्ड करें';

  @override
  String get voice_recordVoiceSubtitle =>
      'रिकॉर्ड करें और ऑडियो संदेश के रूप में भेजें';

  @override
  String get voice_recordingYourVoice => 'आपकी आवाज़ रिकॉर्ड की जा रही है…';

  @override
  String get voice_replyReady => 'उत्तर तैयार है';

  @override
  String get voice_reviewTextHint =>
      'ऊपर अपनी आवाज़ सुनें, या भेजने से पहले संदेश बॉक्स में टेक्स्ट संपादित करें।';

  @override
  String get voice_sendMessage => 'संदेश भेजें';

  @override
  String get voice_sendVoiceMessage => 'वॉइस संदेश भेजें';

  @override
  String get voice_speakNowCaption =>
      'अब बोलें – हम आपका कैप्शन टाइप कर रहे हैं';

  @override
  String get voice_speakNowMessage =>
      'अब बोलें – आपके शब्द संदेश बॉक्स में दिखाई देंगे';

  @override
  String get voice_speakNowReply => 'अब बोलें – हम आपका उत्तर टाइप कर रहे हैं';

  @override
  String get voice_speakPlaceholder => 'बोलें… आपका टेक्स्ट यहां दिखाई देगा';

  @override
  String get voice_speechPermissionNeeded =>
      'आवाज़ को टेक्स्ट में बदलने के लिए वाक् पहचान अनुमति आवश्यक है।';

  @override
  String get voice_tapToStop => 'रोकने के लिए टैप करें';

  @override
  String get voice_textReady => 'टेक्स्ट तैयार है';

  @override
  String get voice_tooMuchNoise =>
      'बहुत अधिक शोर है – फ़ोन को पास रखें और स्पष्ट बोलें';

  @override
  String get voice_type => 'प्रकार';

  @override
  String get voice_voiceToText => 'आवाज़ से टेक्स्ट';

  @override
  String get voice_voiceToTextSubtitle =>
      'बोलें और संदेश बॉक्स में टाइप करवाएं';

  @override
  String get voice_willSendAudioMessage =>
      'आपकी आवाज़ ऑडियो संदेश के रूप में भेजी जाएगी';

  @override
  String get voice_willSendAudioReply =>
      'आपकी आवाज़ ऑडियो उत्तर के रूप में भेजी जाएगी';

  @override
  String get voice_willSendWithFile =>
      'आपकी आवाज़ फ़ाइल के साथ ऑडियो के रूप में भेजी जाएगी';

  @override
  String get voice_yourMessage => 'आपका संदेश';

  @override
  String get voice_yourVoiceMessage => 'आपका वॉइस संदेश';

  @override
  String get walkiePlan_availableIndividualPlans => 'व्यक्तिगत योजनाएं';

  @override
  String get walkiePlan_availablePerMonth => '/ महीना';

  @override
  String get walkiePlan_availablePerSeat => '/ सीट';

  @override
  String get walkiePlan_availableSingleMember => 'एकल सदस्य (व्यक्तिगत पहुंच)';

  @override
  String get walkiePlan_availableSubtitle =>
      'अपनी सदस्यता शुरू करने या अपग्रेड करने के लिए योजना चुनें';

  @override
  String get walkiePlan_availableTeamPlans => 'टीम योजनाएं';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min-$max सीटें  •  समूह सहयोग';
  }

  @override
  String get walkiePlan_availableTitle => 'उपलब्ध योजनाएं';

  @override
  String get walkiePlan_bottomBarAfterTrial => 'आपके मुफ़्त परीक्षण के बाद';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'एक योजना चुनें';

  @override
  String get walkiePlan_bottomBarContinue => 'वॉकी टॉकी के साथ जारी रखें';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return '$price में खरीदें';
  }

  @override
  String get walkiePlan_cardActive => 'सक्रिय';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return '$date से सक्रिय';
  }

  @override
  String get walkiePlan_cardAssigned => 'असाइन किया गया';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return '$name द्वारा सौंपा गया';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'आपको सौंपा गया';

  @override
  String get walkiePlan_cardAvailable => 'उपलब्ध';

  @override
  String get walkiePlan_cardManageMembers => 'सदस्यों को प्रबंधित करें';

  @override
  String get walkiePlan_cardNoActiveIndividual =>
      'कोई सक्रिय व्यक्तिगत सदस्यता नहीं है';

  @override
  String get walkiePlan_cardNoActiveTeam =>
      'कोई सक्रिय टीम योजना या सौंपी गई सीट नहीं है';

  @override
  String get walkiePlan_cardOneSeatSelf => '1 सीट (स्वयं)';

  @override
  String get walkiePlan_cardPersonal => 'व्यक्तिगत';

  @override
  String get walkiePlan_cardPurchased => 'खरीदा गया';

  @override
  String get walkiePlan_cardPurchasedByYou => 'आपके द्वारा खरीदा गया';

  @override
  String get walkiePlan_cardPurchasedOn => 'खरीद की तारीख';

  @override
  String get walkiePlan_cardSeatsMembers => 'सीटें / सदस्य';

  @override
  String get walkiePlan_cardSubscribedByYou =>
      'आपके द्वारा सब्सक्राइब किया गया';

  @override
  String get walkiePlan_cardTeamAdministrator => 'टीम व्यवस्थापक';

  @override
  String get walkiePlan_cardValidUntil => 'वैधता तिथि';

  @override
  String get walkiePlan_cardView => 'देखें';

  @override
  String get walkiePlan_cardViewPlan => 'योजना देखें';

  @override
  String walkiePlan_couponDiscount(String value) {
    return '$value छूट';
  }

  @override
  String get walkiePlan_couponExpired => 'कूपन समाप्त हो गया है';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return 'सीधे $amount की छूट';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet =>
      'न्यूनतम ऑर्डर राशि पूरी नहीं हुई';

  @override
  String get walkiePlan_couponNotEligible =>
      'वर्तमान योजना के लिए पात्र नहीं है';

  @override
  String get walkiePlan_couponNotStarted => 'कूपन ऑफ़र अभी सक्रिय नहीं है';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent% की छूट';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable => 'इस योजना पर लागू नहीं है';

  @override
  String walkiePlan_couponValidTill(String date) {
    return '$date तक मान्य';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'भुगतान के लिए आगे बढ़ें';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return '$plan के साथ जारी रखें';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => 'कूपन सफलतापूर्वक लागू हुआ!';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return 'कूपन लागू हुआ! आप $amount बचाते हैं';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => 'कूपन लागू करने में विफल';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'कूपन हटा दिया गया';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'कैशफ़्री त्रुटि ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed => 'भुगतान आरंभ विफल रहा।';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return 'भुगतान सत्र बनाने में विफल: $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return 'भुगतान संसाधित करने में असमर्थ: $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'योजनाएं लोड हो रही हैं...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans =>
      'योजनाएं लोड करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get walkiePlan_detailsAllBanks => 'सभी भारतीय बैंक समर्थित हैं';

  @override
  String get walkiePlan_detailsApplied => 'लागू किया गया';

  @override
  String get walkiePlan_detailsApply => 'लागू करें';

  @override
  String get walkiePlan_detailsApplyCaps => 'लागू करें';

  @override
  String get walkiePlan_detailsAvailableCoupons => 'उपलब्ध कूपन';

  @override
  String get walkiePlan_detailsCard => 'क्रेडिट / डेबिट कार्ड';

  @override
  String get walkiePlan_detailsChooseTitle => 'एक योजना चुनें';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'कोड: $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'कूपन और ऑफ़र';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'कूपन कोड दर्ज करें';

  @override
  String get walkiePlan_detailsEnterValidCoupon =>
      'कृपया एक वैध कूपन कोड दर्ज करें';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'समूह संचार';

  @override
  String get walkiePlan_detailsFeatHqVoice => 'उच्च गुणवत्ता वाली आवाज़';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => 'प्राथमिकता सहायता';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => 'असीमित रेंज';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => 'असीमित वॉकी टॉकी';

  @override
  String get walkiePlan_detailsHavePromoCode =>
      'क्या आपके पास कोई प्रोमो कोड है?';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'अपनी टीम के अनुकूल योजना के साथ वॉकी टॉकी का उपयोग जारी रखें';

  @override
  String get walkiePlan_detailsLockedCaps => 'लॉक्ड';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'अधिकतम $count सदस्यों की सीमा समाप्त हो गई',
      one: 'अधिकतम 1 सदस्य की सीमा समाप्त हो गई',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMemberPlural => 'सदस्य';

  @override
  String get walkiePlan_detailsMemberSingular => 'सदस्य';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य × $rate',
      one: '1 सदस्य × $rate',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'न्यूनतम टीम आकार $count सदस्य है',
      one: 'न्यूनतम टीम आकार 1 सदस्य है',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody =>
      'किसी भी समय सदस्यों को जोड़ें या निकालें।';

  @override
  String get walkiePlan_detailsMoreMembersTitle => 'अधिक सदस्य?';

  @override
  String get walkiePlan_detailsMostPopular => 'सबसे लोकप्रिय';

  @override
  String get walkiePlan_detailsNetBanking => 'नेट बैंकिंग';

  @override
  String get walkiePlan_detailsNoCouponsBody =>
      'इस समय इस योजना के लिए कोई सक्रिय कूपन नहीं हैं।';

  @override
  String get walkiePlan_detailsNoCouponsTitle => 'कोई कूपन उपलब्ध नहीं है';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      'वर्तमान में कोई व्यक्तिगत वॉकी-टॉकी योजनाएं उपलब्ध नहीं हैं। कृपया बाद में जांचें या पुनः प्रयास करें।';

  @override
  String get walkiePlan_detailsNoPlansTitle => 'कोई योजना उपलब्ध नहीं है';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      'वर्तमान में कोई टीम वॉकी-टॉकी योजनाएं उपलब्ध नहीं हैं। कृपया बाद में जांचें या पुनः प्रयास करें।';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '$amount कुल';
  }

  @override
  String get walkiePlan_detailsPayActivate =>
      'भुगतान करें और योजना सक्रिय करें';

  @override
  String get walkiePlan_detailsPerPerson => '/ व्यक्ति';

  @override
  String get walkiePlan_detailsPillAllSizes => 'सभी आकारों के';

  @override
  String get walkiePlan_detailsPillCommunication => 'संचार';

  @override
  String get walkiePlan_detailsPillForTeams => 'टीमों के लिए';

  @override
  String get walkiePlan_detailsPillInstant => 'त्वरित';

  @override
  String get walkiePlan_detailsPillPriority => 'प्राथमिकता';

  @override
  String get walkiePlan_detailsPillReliable => 'विश्वसनीय और';

  @override
  String get walkiePlan_detailsPillSecure => 'सुरक्षित';

  @override
  String get walkiePlan_detailsPillSupport => 'सहायता';

  @override
  String get walkiePlan_detailsPillUnlimited => 'असीमित';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'वॉकी टॉकी';

  @override
  String get walkiePlan_detailsPlanActivated =>
      'योजना सफलतापूर्वक सक्रिय की गई!';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'आपकी वॉकी टॉकी योजना अब सक्रिय है। निर्बाध त्वरित वॉइस संचार का आनंद लें।';

  @override
  String get walkiePlan_detailsPlanSummary => 'योजना सारांश';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'प्रोमो ($code) लागू हुआ';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => 'हटाएं';

  @override
  String get walkiePlan_detailsSelectPaymentMethod => 'भुगतान विधि चुनें';

  @override
  String get walkiePlan_detailsSkeletonCouponNote =>
      'सभी योजनाओं पर मान्य • जल्द समाप्त हो रहा है';

  @override
  String get walkiePlan_detailsStep1Subtitle =>
      'चुनें कि आप कितने टीम सदस्यों को जोड़ना चाहते हैं';

  @override
  String get walkiePlan_detailsStep1Title => 'सदस्यों की संख्या चुनें';

  @override
  String get walkiePlan_detailsStep2Subtitle =>
      'वह योजना अवधि चुनें जो आपके लिए उपयुक्त हो';

  @override
  String get walkiePlan_detailsStep2Title => 'योजना की अवधि चुनें';

  @override
  String get walkiePlan_detailsSubtitleDefault => 'त्वरित वॉकी टॉकी वॉइस पहुंच';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams =>
      'बढ़ती टीमों के लिए बेहतरीन मूल्य';

  @override
  String get walkiePlan_detailsSubtitleLongTerm =>
      'दीर्घकालिक उपयोग के लिए सर्वश्रेष्ठ';

  @override
  String get walkiePlan_detailsSubtitleShortTerm =>
      'अल्पकालिक उपयोग के लिए बिल्कुल सही';

  @override
  String get walkiePlan_detailsTabIndividual => 'व्यक्तिगत';

  @override
  String get walkiePlan_detailsTabMultipleMembers => 'एकाधिक सदस्यों के लिए';

  @override
  String get walkiePlan_detailsTabPerPerson => 'प्रति व्यक्ति';

  @override
  String get walkiePlan_detailsTeamSubtitle =>
      'टीम के सदस्यों को जोड़ें और सभी को वॉकी टॉकी से जोड़ें';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / QR कोड';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return 'आप इस कूपन से $amount बचाते हैं!';
  }

  @override
  String get walkiePlan_durationFallback => 'अवधि';

  @override
  String get walkiePlan_durationMonthly => 'मासिक';

  @override
  String walkiePlan_durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महीने',
      one: '1 महीना',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_durationQuarterly => 'त्रैमासिक';

  @override
  String get walkiePlan_durationYearly => 'वार्षिक';

  @override
  String get walkiePlan_individualPlan => 'व्यक्तिगत योजना';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return '$interval योजना';
  }

  @override
  String get walkiePlan_monthlyPlan => 'मासिक योजना';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'कोई इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें।';

  @override
  String get walkiePlan_order100Secure => '100% सुरक्षित';

  @override
  String get walkiePlan_order3ds2Secure => '3DS2 सुरक्षित';

  @override
  String get walkiePlan_orderAgreePrefix =>
      'आगे बढ़कर, आप हमारी सहमति देते हैं ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => 'छूट के बाद राशि';

  @override
  String get walkiePlan_orderCards => 'कार्ड';

  @override
  String get walkiePlan_orderChangeMethod => 'विधि बदलें';

  @override
  String get walkiePlan_orderCouldNotStart =>
      'भुगतान शुरू नहीं किया जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get walkiePlan_orderCouponApplied => 'कूपन सफलतापूर्वक लागू हुआ!';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return 'कूपन लागू हुआ! आपने $amount बचाए';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'कूपन सफलतापूर्वक हटा दिया गया';

  @override
  String get walkiePlan_orderCreateFailed =>
      'भुगतान आदेश बनाने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get walkiePlan_orderDiscount => 'छूट';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return 'छूट ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint =>
      'अगले चरण पर GPay, PhonePe, कार्ड, नेटबैंकिंग या वॉलेट में से चुनें।';

  @override
  String get walkiePlan_orderEncryptedPayment => 'एन्क्रिप्टेड भुगतान';

  @override
  String get walkiePlan_orderEnterValidCoupon =>
      'कृपया एक वैध कूपन कोड दर्ज करें';

  @override
  String get walkiePlan_orderForMultipleMembers => 'एकाधिक सदस्यों के लिए';

  @override
  String get walkiePlan_orderForSingleMember => 'एकल सदस्य के लिए';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return 'जीएसटी ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      'अंतर्राष्ट्रीय क्रेडिट/डेबिट कार्ड (Visa, Mastercard, Amex) से सुरक्षित भुगतान करें।';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      'अंतर्राष्ट्रीय क्रेडिट/डेबिट कार्ड (Visa, Mastercard, Amex) या PayPal से सुरक्षित भुगतान करें।';

  @override
  String get walkiePlan_orderInvalidCoupon => 'अमान्य या समाप्त कूपन कोड';

  @override
  String walkiePlan_orderMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '1 सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'सदस्य';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य × $rate',
      one: '1 सदस्य × $rate',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderNetBanking => 'नेटबैंकिंग';

  @override
  String get walkiePlan_orderOnlineViaRazorpay =>
      'रेज़रपे के माध्यम से ऑनलाइन भुगतान';

  @override
  String get walkiePlan_orderOpeningCheckout =>
      'रेज़रपे भुगतान चेकआउट खोला जा रहा है...';

  @override
  String get walkiePlan_orderPaymentDetails => 'भुगतान विवरण';

  @override
  String get walkiePlan_orderPaymentMethod => 'भुगतान विधि';

  @override
  String get walkiePlan_orderPricePerMember => 'प्रति सदस्य मूल्य';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return 'भुगतान के लिए आगे बढ़ें • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => 'भुगतान संसाधित हो रहा है...';

  @override
  String get walkiePlan_orderRetryPay => 'पुनः भुगतान करें';

  @override
  String get walkiePlan_orderSecureBadge => 'सुरक्षित';

  @override
  String get walkiePlan_orderSubtitle =>
      'अपनी योजना के विवरण की समीक्षा करें और भुगतान के लिए आगे बढ़ें';

  @override
  String get walkiePlan_orderSubtotal => 'उप-योग (सबटोटल)';

  @override
  String get walkiePlan_orderTaxExport => 'कर (0% निर्यात)';

  @override
  String get walkiePlan_orderTermsConditions => 'नियम और शर्तें';

  @override
  String get walkiePlan_orderTitle => 'ऑर्डर सारांश';

  @override
  String get walkiePlan_orderTotalAmount => 'कुल राशि';

  @override
  String get walkiePlan_orderTotalPayable => 'कुल देय';

  @override
  String get walkiePlan_orderUnableToLoad =>
      'ऑर्डर सारांश लोड करने में असमर्थ।';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return 'वैट / कर ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => 'वॉलेट';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return 'आपने इस ऑर्डर पर $amount बचाए!';
  }

  @override
  String get walkiePlan_payAnnualPlan => 'वार्षिक योजना';

  @override
  String get walkiePlan_payBadgeCompleted => 'पूर्ण';

  @override
  String get walkiePlan_payBadgeInProgress => 'प्रगति पर है';

  @override
  String get walkiePlan_payBadgePending => 'लंबित';

  @override
  String get walkiePlan_payCancelledByUser =>
      'उपयोगकर्ता द्वारा भुगतान रद्द कर दिया गया था। आपके खाते से कोई राशि नहीं काटी गई है।';

  @override
  String get walkiePlan_payCouldNotBeProcessed =>
      'भुगतान संसाधित नहीं किया जा सका';

  @override
  String get walkiePlan_payFailedContactSupport => 'सहायता से संपर्क करें';

  @override
  String walkiePlan_payFailedOn(String time) {
    return '$time पर भुगतान विफल रहा';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'हम आपका भुगतान पूरा नहीं कर सके।\nकृपया पुनः प्रयास करें या भिन्न भुगतान विधि का उपयोग करें।';

  @override
  String get walkiePlan_payFailedSubtitleShort =>
      'हम आपका भुगतान पूरा नहीं कर सके';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      'भुगतान में मदद चाहिए? हमारी टीम आपकी सहायता के लिए 24/7 उपलब्ध है।';

  @override
  String get walkiePlan_payFailedTitle => 'भुगतान विफल रहा';

  @override
  String get walkiePlan_payIndividualFeatures =>
      'रीयल-टाइम निगरानी • त्वरित अलर्ट';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return '$time पर भुगतान शुरू किया गया';
  }

  @override
  String get walkiePlan_payIntervalMonth => 'महीना';

  @override
  String get walkiePlan_payIntervalPlan => 'योजना';

  @override
  String get walkiePlan_payIntervalQuarter => 'तिमाही';

  @override
  String get walkiePlan_payIntervalYear => 'वर्ष';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'क्रेडिट कार्ड ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'डेबिट कार्ड ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational =>
      'अंतर्राष्ट्रीय कार्ड / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'नेटबैंकिंग ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'रेज़रपे भुगतान';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'रेज़रपे चेकआउट';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'रेज़रपे (UPI / कार्ड)';

  @override
  String get walkiePlan_payMethodUpi => 'UPI भुगतान';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'वॉलेट ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue =>
      'भुगतान के दौरान नेटवर्क कनेक्शन समस्या। कृपया अपना इंटरनेट जांचें और पुनः प्रयास करें।';

  @override
  String get walkiePlan_payNotCompleted =>
      'आपका भुगतान पूरा नहीं हुआ था। आपके खाते से कोई राशि नहीं काटी गई है।';

  @override
  String get walkiePlan_payOtpCharge => 'OTP शुल्क';

  @override
  String get walkiePlan_payOtpChargeDetails => 'OTP शुल्क विवरण';

  @override
  String get walkiePlan_payOtpChargedPerLogin =>
      'प्रति लॉगिन शुल्क। OTP दोबारा भेजना मुफ़्त है';

  @override
  String get walkiePlan_payOtpCharges => 'OTP शुल्क';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'कृपया ऐप बंद न करें। भुगतान की पुष्टि होने और योजना सक्रिय होने पर हम आपको सूचित करेंगे।';

  @override
  String get walkiePlan_payPendingStillInProgress =>
      'भुगतान अभी भी प्रगति पर है। पुष्टि होने पर हम अपडेट करेंगे।';

  @override
  String get walkiePlan_payPendingStillProcessing =>
      'भुगतान स्थिति अभी भी प्रसंस्करण में है। कृपया प्रतीक्षा करें।';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      'आपका भुगतान प्रदाता द्वारा संसाधित किया जा रहा है।\nइसमें कुछ मिनट लग सकते हैं।';

  @override
  String get walkiePlan_payPendingSubtitleShort =>
      'आपका भुगतान संसाधित किया जा रहा है';

  @override
  String get walkiePlan_payPendingTitle => 'भुगतान लंबित है';

  @override
  String get walkiePlan_payPlanDetails => 'योजना विवरण';

  @override
  String get walkiePlan_payRefreshStatus => 'स्थिति रिफ्रेश करें';

  @override
  String get walkiePlan_payStatusTitle => 'भुगतान स्थिति';

  @override
  String get walkiePlan_payStepActivate => 'योजना सक्रिय करें';

  @override
  String get walkiePlan_payStepActivateSub =>
      'आपकी योजना अपने आप सक्रिय हो जाएगी';

  @override
  String get walkiePlan_payStepInitiated => 'भुगतान शुरू हुआ';

  @override
  String get walkiePlan_payStepProcessing => 'भुगतान प्रसंस्करण';

  @override
  String get walkiePlan_payStepProcessingSub =>
      'आपके भुगतान की पुष्टि की जा रही है';

  @override
  String get walkiePlan_payTeamFeatures => 'बहु-सदस्य पहुंच • त्वरित अलर्ट';

  @override
  String get walkiePlan_payTotalPerOtp => 'प्रति OTP कुल';

  @override
  String get walkiePlan_payTryAgain => 'पुनः प्रयास करें';

  @override
  String get walkiePlan_payViewPlanDetails => 'योजना विवरण देखें';

  @override
  String get walkiePlan_perMember => 'प्रति सदस्य';

  @override
  String get walkiePlan_planFallback => 'योजना';

  @override
  String get walkiePlan_quarterlyPlan => 'त्रैमासिक योजना';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'कृपया रेज़रपे भुगतान विंडो में लेन-देन पूरा करें।';

  @override
  String get walkiePlan_razorpayCompletePayment => 'भुगतान पूरा करें';

  @override
  String get walkiePlan_razorpayConfirmingWithBank =>
      'भुगतान शुरू किया गया था। हम बैंक से पुष्टि कर रहे हैं।';

  @override
  String get walkiePlan_razorpayConnecting => 'रेज़रपे से कनेक्ट हो रहा है...';

  @override
  String get walkiePlan_razorpayCouldNotProcess =>
      'भुगतान संसाधित नहीं किया जा सका। कृपया पुनः प्रयास करें।';

  @override
  String get walkiePlan_razorpayFailedTryAgain =>
      'भुगतान विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1 महीना सक्रिय';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return 'रेज़रपे के माध्यम से $amount का भुगतान करें';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => 'भुगतान रद्द किया गया';

  @override
  String get walkiePlan_razorpayPaymentIdCopied =>
      'भुगतान आईडी क्लिपबोर्ड पर कॉपी हो गई!';

  @override
  String get walkiePlan_razorpayPciCompliant =>
      '100% सुरक्षित और PCI-DSS अनुरूप';

  @override
  String get walkiePlan_razorpayPendingConfirmation =>
      'भुगतान की पुष्टि लंबित है।';

  @override
  String get walkiePlan_razorpayProcessing =>
      'रेज़रपे के साथ प्रसंस्करण हो रहा है...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return 'राशि: $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied =>
      'रसीद विवरण क्लिपबोर्ड पर कॉपी हो गया!';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return 'दिनांक: $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return 'भुगतान मोड: $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return 'ऑर्डर आईडी: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return 'भुगतान आईडी: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'योजना: $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => 'स्थिति: पूर्ण';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'FG ट्रैकर भुगतान रसीद';

  @override
  String get walkiePlan_razorpayRetryPayment => 'पुनः भुगतान करें';

  @override
  String get walkiePlan_razorpaySecureCheckout =>
      'रेज़रपे द्वारा संचालित सुरक्षित चेकआउट';

  @override
  String get walkiePlan_razorpaySslEncrypted =>
      'लेन-देन एंड-टू-एंड 256-बिट एसएसएल सुरक्षा के साथ एन्क्रिप्टेड हैं।';

  @override
  String get walkiePlan_razorpaySupportedModes => 'समर्थित भुगतान मोड';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => 'कुल देय राशि';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return 'भुगतान गेटवे लॉन्च करने में असमर्थ: $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed => 'भुगतान सत्यापन विफल रहा।';

  @override
  String get walkiePlan_seatAssignedSeat => 'सौंपी गई सीट';

  @override
  String get walkiePlan_seatAssignment => 'सीट असाइनमेंट';

  @override
  String get walkiePlan_seatTeamAccess => 'टीम पहुंच';

  @override
  String get walkiePlan_seatTeamMember => 'टीम के सदस्य';

  @override
  String get walkiePlan_secureEncryptedPayment =>
      'सुरक्षित और एन्क्रिप्टेड भुगतान';

  @override
  String get walkiePlan_successAccessActivated => 'पहुंच सक्रिय हो गई';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      'आपकी व्यक्तिगत वॉकी-टॉकी पहुंच अब सक्रिय है।';

  @override
  String get walkiePlan_successAmountPaid => 'भुगतान की गई राशि';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'आप टीम सेटिंग्स से कभी भी बाद में वॉकी एक्सेस असाइन कर सकते हैं।';

  @override
  String get walkiePlan_successAssignMembers => 'सदस्य असाइन करें';

  @override
  String get walkiePlan_successAssignWalkieAccess => 'वॉकी एक्सेस असाइन करें';

  @override
  String get walkiePlan_successChooseMembersDesc =>
      'चुनें कि कौन से सदस्य वॉकी टॉकी का उपयोग कर सकते हैं।';

  @override
  String get walkiePlan_successContinueHome => 'होम पर जारी रखें';

  @override
  String get walkiePlan_successDateTime => 'दिनांक और समय';

  @override
  String get walkiePlan_successDefaultPaymentMethod => 'रेज़रपे (UPI / कार्ड)';

  @override
  String get walkiePlan_successIndividualActive =>
      'आपकी व्यक्तिगत योजना अब सक्रिय है';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      'आपकी व्यक्तिगत योजना सक्रिय है। होम पर जाएं और बात करना शुरू करें।';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      'आपकी व्यक्तिगत सदस्यता सक्रिय है और सीधे आपके खाते से जुड़ी है।';

  @override
  String get walkiePlan_successManageAccessNote =>
      'आप टीम सेटिंग्स से कभी भी वॉकी एक्सेस प्रबंधित या बदल सकते हैं।';

  @override
  String get walkiePlan_successMaybeLater => 'शायद बाद में';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'आपकी योजना सक्रिय है। जब तक आप असाइन नहीं करेंगे तब तक टीम के सदस्यों के पास वॉकी का उपयोग नहीं होगा।';

  @override
  String get walkiePlan_successNotNow => 'अभी नहीं?';

  @override
  String get walkiePlan_successPaid => 'भुगतान किया गया';

  @override
  String get walkiePlan_successPaymentId => 'भुगतान आईडी';

  @override
  String get walkiePlan_successPaymentIdCopied =>
      'भुगतान आईडी क्लिपबोर्ड पर कॉपी हो गई!';

  @override
  String get walkiePlan_successPaymentMode => 'भुगतान मोड';

  @override
  String get walkiePlan_successPaymentReceipt => 'भुगतान रसीद';

  @override
  String get walkiePlan_successPushToTalkDesc =>
      'पुश टू टॉक करें और अपनी टीम से तुरंत जुड़ें।';

  @override
  String get walkiePlan_successRazorpayVerified => 'रेज़रपे सत्यापित';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return 'राशि: $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied =>
      'रसीद विवरण क्लिपबोर्ड पर कॉपी हो गया!';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return 'दिनांक: $date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'FG ट्रैकर भुगतान रसीद';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return 'ऑर्डर आईडी: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return 'भुगतान आईडी: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return 'भुगतान मोड: $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'योजना: $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => 'स्थिति: पूर्ण';

  @override
  String get walkiePlan_successSelectChannel => 'चैनल चुनें';

  @override
  String get walkiePlan_successSelectChannelDesc =>
      'सदस्यों से जुड़ने के लिए किसी भी समूह या चैनल में शामिल हों।';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'उन टीम सदस्यों का चयन करें जो वॉकी टॉकी का उपयोग करेंगे।';

  @override
  String get walkiePlan_successSetUpTeam => 'टीम सेट अप करें';

  @override
  String get walkiePlan_successSetUpTeamDesc =>
      'सदस्यों को आमंत्रित करें, भूमिकाएं और अनुमतियां प्रबंधित करें।';

  @override
  String get walkiePlan_successShareReceipt => 'रसीद साझा करें';

  @override
  String get walkiePlan_successStartCommunicating => 'संवाद शुरू करें';

  @override
  String get walkiePlan_successStatus => 'स्थिति';

  @override
  String get walkiePlan_successSuccessful => 'सफल';

  @override
  String get walkiePlan_successTeamActive => 'आपकी टीम योजना अब सक्रिय है';

  @override
  String get walkiePlan_successTeamReady => 'आपकी टीम पूरी तरह तैयार है!';

  @override
  String get walkiePlan_successTitle => 'खरीद सफल!';

  @override
  String walkiePlan_successValidTill(String date) {
    return '$date तक मान्य';
  }

  @override
  String get walkiePlan_successVisitHome => 'होम स्क्रीन पर जाएं';

  @override
  String get walkiePlan_successWhatsNext => 'आगे क्या है?';

  @override
  String get walkiePlan_teamPlan => 'टीम योजना';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'टीम योजना ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => '7 दिन की परीक्षण अवधि';

  @override
  String get walkiePlan_trialActiveLabel => 'परीक्षण सक्रिय है';

  @override
  String get walkiePlan_trialActiveSubscription => 'सक्रिय सदस्यता';

  @override
  String get walkiePlan_trialActiveSubscriptions => 'सक्रिय सदस्यताएँ';

  @override
  String get walkiePlan_trialAvailableToStart => 'शुरू करने के लिए उपलब्ध';

  @override
  String get walkiePlan_trialCheckConnectionRetry =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'वॉकी टॉकी का उपयोग शुरू करने के लिए नीचे दी गई योजना चुनें।';

  @override
  String get walkiePlan_trialChooseSubscription =>
      'वॉकी टॉकी का उपयोग जारी रखने के लिए एक सदस्यता चुनें।';

  @override
  String get walkiePlan_trialCompleted => 'परीक्षण पूर्ण';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन शेष',
      one: '1 दिन शेष',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration मुफ़्त';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return '$date को समाप्त हुआ';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return '$duration के लिए वॉकी टॉकी की सभी सुविधाओं का मुफ़्त आनंद लें।\nकिसी भुगतान की आवश्यकता नहीं है।';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      'अपनी सक्रिय परीक्षण अवधि के दौरान वॉकी टॉकी का आनंद लें।';

  @override
  String get walkiePlan_trialErrAccessMissing =>
      'वॉकी-टॉकी पहुंच जानकारी गायब है।';

  @override
  String get walkiePlan_trialErrFetchDetails =>
      'वॉकी-टॉकी विवरण प्राप्त करने में असमर्थ।';

  @override
  String get walkiePlan_trialErrInvalidResponse =>
      'सर्वर से अमान्य प्रतिक्रिया प्राप्त हुई।';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'कोई इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें और पुनः प्रयास करें।';

  @override
  String get walkiePlan_trialErrOverviewMissing =>
      'वॉकी-टॉकी अवलोकन डेटा गायब है।';

  @override
  String get walkiePlan_trialErrTimeout =>
      'अनुरोध का समय समाप्त हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get walkiePlan_trialErrUnableToLoad =>
      'वॉकी-टॉकी विवरण लोड करने में असमर्थ। कृपया अपना कनेक्शन जांचें।';

  @override
  String get walkiePlan_trialExpired => 'परीक्षण समाप्त';

  @override
  String get walkiePlan_trialExpiredLabel => 'परीक्षण समाप्त हो गया';

  @override
  String get walkiePlan_trialExpiringSoon => 'जल्द समाप्त हो रहा है';

  @override
  String get walkiePlan_trialFeatClearAudio => 'स्पष्ट ऑडियो';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'उच्च गुणवत्ता वाली आवाज़';

  @override
  String get walkiePlan_trialFeatGroupComm => 'समूह संचार';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => 'अपनी टीम से जुड़ें';

  @override
  String get walkiePlan_trialFeatPtt => 'पुश-टू-टॉक (दबाकर बोलें)';

  @override
  String get walkiePlan_trialFeatPttDesc => 'त्वरित वॉइस संचार';

  @override
  String get walkiePlan_trialFeatUnlimited => 'असीमित उपयोग';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc =>
      'बिना किसी सीमा के उपयोग करें';

  @override
  String get walkiePlan_trialFreeAvailable => 'मुफ़्त परीक्षण उपलब्ध है';

  @override
  String get walkiePlan_trialFreeTrialLabel => 'मुफ़्त परीक्षण';

  @override
  String get walkiePlan_trialFreeTrialRunning => 'मुफ़्त परीक्षण चल रहा है';

  @override
  String get walkiePlan_trialFullAccess => 'सभी सुविधाओं तक पूर्ण पहुंच';

  @override
  String get walkiePlan_trialFullyConsumed =>
      'आपका मुफ़्त परीक्षण पूरी तरह से समाप्त हो गया है।';

  @override
  String get walkiePlan_trialHasEnded => 'आपका परीक्षण समाप्त हो गया है';

  @override
  String get walkiePlan_trialHeaderInstant =>
      'अपने समूह के साथ तुरंत संवाद करें';

  @override
  String get walkiePlan_trialHeaderPlanStatus =>
      'आपकी योजना और सदस्यता की स्थिति';

  @override
  String walkiePlan_trialHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे',
      one: '1 घंटा',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे शेष',
      one: '1 घंटा शेष',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHr(int count) {
    return '$count घंटा';
  }

  @override
  String walkiePlan_trialHrMin(int hours, int minutes) {
    return '$hours घंटा $minutes मिनट';
  }

  @override
  String get walkiePlan_trialIsActive => 'आपका परीक्षण सक्रिय है';

  @override
  String walkiePlan_trialMin(int count) {
    return '$count मिनट';
  }

  @override
  String walkiePlan_trialMinSec(int minutes, int seconds) {
    return '$minutes मिनट $seconds सेकंड';
  }

  @override
  String walkiePlan_trialMinsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट शेष',
      one: '1 मिनट शेष',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट',
      one: '1 मिनट',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_trialNoActivePlan => 'कोई सक्रिय योजना नहीं';

  @override
  String get walkiePlan_trialNoCardRequired =>
      '7 दिनों के भीतर कभी भी उपयोग करें  •  क्रेडिट कार्ड की आवश्यकता नहीं है';

  @override
  String get walkiePlan_trialNoInternetTitle => 'कोई इंटरनेट कनेक्शन नहीं';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return 'अभी किसी भुगतान की आवश्यकता नहीं है। परीक्षण के बाद, आप चाहें तो सशुल्क योजना ($price/व्यक्ति) के साथ जारी रख सकते हैं।';
  }

  @override
  String get walkiePlan_trialPeriodMonth => 'महीना';

  @override
  String get walkiePlan_trialRetrying => 'पुनः प्रयास किया जा रहा है...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count सेकंड';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return '$duration मुफ़्त परीक्षण शुरू करें';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial =>
      'अपना मुफ़्त परीक्षण शुरू करें';

  @override
  String get walkiePlan_trialStatusCompleted => 'पूर्ण';

  @override
  String get walkiePlan_trialStatusExpired => 'समाप्त';

  @override
  String get walkiePlan_trialSubscriptionActive => 'सदस्यता सक्रिय है';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'आपकी वॉकी टॉकी सदस्यता समाप्त हो गई है। अपनी टीम से बात करते रहने के लिए नवीनीकरण करें।';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'सदस्यता समाप्त हो गई';

  @override
  String get walkiePlan_trialTalkFree => 'अपने समूह के साथ मुफ़्त बात करें।';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return '$date तक अपने समूह के साथ मुफ़्त बात करें।';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg =>
      'आपके पास अपनी टीम योजना के माध्यम से वॉकी टॉकी पहुंच है।';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return '$time शेष';
  }

  @override
  String get walkiePlan_trialTimeRemaining => 'शेष परीक्षण समय';

  @override
  String get walkiePlan_trialTimeUsedUp => 'परीक्षण का समय समाप्त हो गया';

  @override
  String get walkiePlan_trialTryAgain => 'पुनः प्रयास करें';

  @override
  String get walkiePlan_trialUnableToLoadTitle =>
      'वॉकी टॉकी लोड करने में असमर्थ';

  @override
  String get walkiePlan_trialUsage => 'परीक्षण उपयोग';

  @override
  String get walkiePlan_trialUseAnytime7Days =>
      '7 दिनों में कभी भी परीक्षण का उपयोग करें';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return '7 दिनों के भीतर कभी भी अपने $duration परीक्षण का उपयोग करें।';
  }

  @override
  String get walkiePlan_trialUsed => 'परीक्षण का उपयोग किया गया';

  @override
  String get walkiePlan_trialValidityPeriod => 'परीक्षण वैधता अवधि';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'वॉकी टॉकी';

  @override
  String get walkiePlan_trialWhatYouCanDo =>
      'परीक्षण के दौरान आप क्या कर सकते हैं';

  @override
  String get walkiePlan_unableToConnect =>
      'सर्वर से कनेक्ट करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get walkiePlan_yearlyPlan => 'वार्षिक योजना';

  @override
  String get walkie_aMember => 'एक सदस्य';

  @override
  String get walkie_accept => 'स्वीकारें';

  @override
  String get walkie_activeAccess => 'सक्रिय एक्सेस';

  @override
  String get walkie_activeBadge => 'सक्रिय';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'वॉकी में $count सक्रिय',
      one: 'वॉकी में 1 सक्रिय',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'सक्रिय सदस्य';

  @override
  String get walkie_admin => 'एडमिन';

  @override
  String get walkie_adminMuted => 'एडमिन • म्यूट';

  @override
  String get walkie_adminOnlyAction => 'केवल एडमिन के लिए';

  @override
  String get walkie_adminOnlyActionMessage =>
      'केवल ग्रुप एडमिन सदस्यों को नोटिफिकेशन अलर्ट भेज सकते हैं।';

  @override
  String walkie_alertSentMessage(String name) {
    return '$name को नोटिफिकेशन भेजा गया। 10 सेकंड में फिर से भेज सकते हैं।';
  }

  @override
  String get walkie_alertSentTitle => 'अलर्ट भेजा गया';

  @override
  String get walkie_assignMembersToCommunicate =>
      'इस ग्रुप में बात करने के लिए सदस्य असाइन करें';

  @override
  String get walkie_assignedByYou => 'आपके द्वारा असाइन';

  @override
  String walkie_assignedCount(int count) {
    return 'असाइन ($count)';
  }

  @override
  String get walkie_assignedSeats => 'असाइन की गई सीटें';

  @override
  String get walkie_audioBluetooth => 'ब्लूटूथ';

  @override
  String get walkie_audioHeadset => 'हेडसेट';

  @override
  String get walkie_audioOutput => 'ऑडियो आउटपुट';

  @override
  String get walkie_audioPhone => 'फ़ोन';

  @override
  String get walkie_audioSpeaker => 'स्पीकर';

  @override
  String get walkie_audioWiredHeadphones => 'वायर्ड हेडफ़ोन';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return '$seconds से. में ऑटो-अनलॉक';
  }

  @override
  String get walkie_availableMembers => 'उपलब्ध सदस्य';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आप इस ग्रुप में $count सदस्यों तक असाइन कर सकते हैं',
      one: 'आप इस ग्रुप में 1 सदस्य तक असाइन कर सकते हैं',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat =>
      'दूसरे एडमिन द्वारा असाइन की गई सीट हटाई नहीं जा सकती';

  @override
  String get walkie_cannotSpeak => 'इस चैनल पर नहीं बोल सकते';

  @override
  String get walkie_channelBusy => 'चैनल व्यस्त है';

  @override
  String get walkie_channelLocked => 'चैनल लॉक है';

  @override
  String get walkie_channelSpeaking => 'चैनल पर बात चल रही है...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return '$group को सक्रिय बोलने वाला चैनल नहीं बनाया जा सका।';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'चैनल बदलने में त्रुटि';

  @override
  String get walkie_channelUnlocked => 'चैनल अनलॉक हुआ';

  @override
  String get walkie_chat => 'चैट';

  @override
  String get walkie_checkNetworkTryAgain =>
      'कृपया अपना नेटवर्क कनेक्शन जांचें और फिर से कोशिश करें।';

  @override
  String get walkie_chooseAPlan => 'प्लान चुनें';

  @override
  String get walkie_connected => 'कनेक्टेड';

  @override
  String get walkie_connectedWaiting =>
      'चैनल से जुड़े • दूसरों के जुड़ने का इंतज़ार';

  @override
  String get walkie_connectingChannel => 'चैनल से जुड़ रहे हैं...';

  @override
  String get walkie_consumingTrial => 'ट्रायल चल रहा है...';

  @override
  String get walkie_continueListenOnly => 'केवल-सुनें मोड में जारी रखें';

  @override
  String walkie_currentlyAssigned(int count) {
    return 'अभी असाइन ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'वॉकी ग्रुप';

  @override
  String get walkie_description => 'विवरण';

  @override
  String get walkie_disconnected => 'डिस्कनेक्ट हो गया';

  @override
  String get walkie_editAssignedMembers => 'असाइन किए गए सदस्य बदलें';

  @override
  String get walkie_enable => 'चालू करें';

  @override
  String walkie_errorWithDetails(String details) {
    return 'त्रुटि: $details';
  }

  @override
  String get walkie_exitWalkie => 'वॉकी से बाहर निकलें';

  @override
  String get walkie_exitWalkieMessage =>
      'आप इस वॉकी चैनल से डिस्कनेक्ट हो जाएंगे। आप ग्रुप के सदस्य बने रहेंगे।';

  @override
  String get walkie_exitWalkieTitle => 'वॉकी से बाहर निकलें?';

  @override
  String get walkie_fairConnection => 'ठीक-ठाक कनेक्शन';

  @override
  String walkie_fairConnectionMs(int ms) {
    return 'ठीक-ठाक कनेक्शन (${ms}ms)';
  }

  @override
  String get walkie_featureAllDevices => 'सभी डिवाइस पर उपयोग करें';

  @override
  String get walkie_featureEasyCoordination => 'आसान ग्रुप\nतालमेल';

  @override
  String get walkie_featureHoldToTalk => 'बोलने के लिए दबाकर रखें';

  @override
  String get walkie_featurePtt => 'पुश-टू-टॉक\nकम्युनिकेशन';

  @override
  String get walkie_featureQuickGroup => 'तेज़ ग्रुप\nकम्युनिकेशन';

  @override
  String get walkie_featureRealtime => 'रियल-टाइम कनेक्टिविटी';

  @override
  String get walkie_featureSafeReliable => 'सुरक्षित और भरोसेमंद';

  @override
  String get walkie_featureStayConnected => 'हमेशा जुड़े रहें';

  @override
  String get walkie_featureTeamCommunication => 'टीम कम्युनिकेशन';

  @override
  String get walkie_featureUnlimited => 'अनलिमिटेड';

  @override
  String get walkie_fieldTeam => 'फील्ड टीम';

  @override
  String get walkie_freeTrialEnded => 'फ्री ट्रायल खत्म';

  @override
  String get walkie_freeTrialEndedMessage =>
      'वॉकी-टॉकी का आपका 1 घंटे का फ्री ट्रायल खत्म हो गया है।\nअपनी टीम के साथ ग्रुप कम्युनिकेशन जारी रखने के लिए\nअभी अपग्रेड करें।';

  @override
  String get walkie_freeTrialEndedTitle => 'फ्री ट्रायल खत्म हो गया';

  @override
  String get walkie_genericError => 'वॉकी-टॉकी त्रुटि';

  @override
  String get walkie_getPlan => 'प्लान लें';

  @override
  String walkie_goodConnectionMs(int ms) {
    return 'अच्छा कनेक्शन (${ms}ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'ग्रुप कोड: $code';
  }

  @override
  String get walkie_groupCommunication => 'ग्रुप कम्युनिकेशन';

  @override
  String get walkie_groupFallback => 'ग्रुप';

  @override
  String get walkie_groupMembers => 'ग्रुप सदस्य';

  @override
  String get walkie_heroSubtitle =>
      'फ़ोन कॉल किए बिना अपने ग्रुप के साथ\nपुश-टू-टॉक वॉइस कम्युनिकेशन का उपयोग करें।';

  @override
  String get walkie_heroTitle => 'जुड़े रहें, तुरंत बात करें';

  @override
  String get walkie_holdToTalk => 'बोलने के लिए दबाएं';

  @override
  String get walkie_holdToTalkSlideLock =>
      'बोलने के लिए दबाएं, लॉक के लिए ऊपर स्लाइड करें';

  @override
  String get walkie_inWalkieChannel => 'वॉकी चैनल में';

  @override
  String get walkie_individualActiveUpgrade =>
      'व्यक्तिगत प्लान सक्रिय (केवल खुद के लिए) • सदस्य असाइन करने के लिए टीम प्लान में अपग्रेड करें।';

  @override
  String get walkie_individualLimitMessage =>
      'आपके व्यक्तिगत प्लान में केवल 1 सदस्य सीट है। कई सदस्य असाइन करने और पूरी टीम को जोड़ने के लिए टीम प्लान में अपग्रेड करें।';

  @override
  String get walkie_individualPlan => 'व्यक्तिगत प्लान';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (व्यक्तिगत)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      'व्यक्तिगत प्लान (केवल खुद के लिए) • सदस्य असाइन करने के लिए टीम में अपग्रेड करें';

  @override
  String get walkie_individualSubscribedSelf =>
      'व्यक्तिगत प्लान • खुद सब्सक्राइब किया';

  @override
  String get walkie_info => 'जानकारी';

  @override
  String walkie_isSpeaking(String name) {
    return '$name बोल रहे हैं...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name बोल रहे हैं...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जुड़े',
      one: '1 जुड़ा',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return 'अंतिम बार देखा गया $time';
  }

  @override
  String get walkie_listenOnly => 'केवल सुनें';

  @override
  String get walkie_listenOnlyTapPlan =>
      'केवल सुनें — प्लान देखने के लिए टैप करें';

  @override
  String get walkie_listening => 'सुन रहे हैं';

  @override
  String get walkie_listeningOnly => 'केवल सुन रहे हैं';

  @override
  String get walkie_live => 'लाइव';

  @override
  String get walkie_lockTimeout => 'लॉक समय समाप्त — माइक छोड़ा गया';

  @override
  String get walkie_lockedTapMic => 'लॉक है — रोकने के लिए माइक टैप करें';

  @override
  String get walkie_maybeLater => 'बाद में';

  @override
  String get walkie_member => 'सदस्य';

  @override
  String get walkie_membersInChannel => 'चैनल में सदस्य';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सदस्य ऑनलाइन',
      one: 'सदस्य ऑनलाइन',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed =>
      'असाइन किए गए सदस्य अपडेट नहीं हो सके';

  @override
  String get walkie_membersUpdated =>
      'असाइन किए गए सदस्य सफलतापूर्वक अपडेट हुए';

  @override
  String get walkie_micAccessRequired =>
      'बोलने के लिए माइक्रोफ़ोन एक्सेस ज़रूरी है।';

  @override
  String get walkie_micDisabledMessage =>
      'डिवाइस सेटिंग्स में माइक्रोफ़ोन एक्सेस बंद है। इस ग्रुप में बोलने के लिए सेटिंग्स में माइक्रोफ़ोन एक्सेस की अनुमति दें।\n\nआप अब भी दूसरे सदस्यों को सुन सकते हैं।';

  @override
  String get walkie_micPermissionRequired => 'माइक्रोफ़ोन अनुमति ज़रूरी है';

  @override
  String get walkie_micPermissionTitle => 'माइक्रोफ़ोन अनुमति';

  @override
  String get walkie_micRequiredMessage =>
      'इस वॉकी-टॉकी ग्रुप में बोलने के लिए माइक्रोफ़ोन अनुमति ज़रूरी है।\n\nमाइक्रोफ़ोन चालू किए बिना भी आप दूसरों को सुन सकते हैं।';

  @override
  String get walkie_muteMe => 'मुझे म्यूट करें';

  @override
  String get walkie_muted => 'म्यूट';

  @override
  String get walkie_mutedInWalkie => 'म्यूट • वॉकी में';

  @override
  String get walkie_mutedListeningOnly => 'आप म्यूट हैं — केवल सुन सकते हैं';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name बोल रहे हैं...';
  }

  @override
  String get walkie_noActivePlan => 'कोई सक्रिय प्लान नहीं';

  @override
  String get walkie_noAvailableMembers => 'कोई उपलब्ध सदस्य नहीं';

  @override
  String get walkie_noBluetoothDevice =>
      'कोई ब्लूटूथ ऑडियो डिवाइस कनेक्ट नहीं है। कृपया सेटिंग्स में अपना ब्लूटूथ हेडसेट पेयर करें।';

  @override
  String get walkie_noGroupsFound => 'कोई ग्रुप नहीं मिला';

  @override
  String get walkie_noMembersAssigned => 'अभी कोई सदस्य असाइन नहीं है';

  @override
  String get walkie_noMembersFound => 'कोई सदस्य नहीं मिला';

  @override
  String get walkie_noMembersFoundTitle => 'कोई सदस्य नहीं मिला';

  @override
  String get walkie_noMembersMatch => 'कोई सदस्य मेल नहीं खाता';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return '\'$query\' से कोई सदस्य मेल नहीं खाता';
  }

  @override
  String get walkie_noMembersToAssign =>
      'असाइन करने के लिए कोई ग्रुप सदस्य उपलब्ध नहीं है।';

  @override
  String get walkie_noNameGroup => 'बिना नाम का ग्रुप';

  @override
  String get walkie_noPlanSubscribeAssign =>
      'कोई सक्रिय प्लान नहीं • सदस्य असाइन करने के लिए सब्सक्राइब करें';

  @override
  String get walkie_noSeatMessage =>
      'आपके पास सक्रिय टीम प्लान है, लेकिन सभी वॉइस सीटें अभी दूसरे टीम सदस्यों को असाइन हैं।\n\nआप ग्रुप की बातचीत लाइव सुन सकते हैं, लेकिन बोलने के लिए खुद को सीट असाइन करें या अपना प्लान अपग्रेड करें।';

  @override
  String get walkie_noSeatTitle => 'कोई वॉइस सीट असाइन नहीं';

  @override
  String get walkie_noSeatsRefreshing =>
      'कोई टीम सीट उपलब्ध नहीं। सदस्य सूची रिफ्रेश हो रही है...';

  @override
  String get walkie_noSubscriptionMessage =>
      'आपके पास कोई सक्रिय वॉकी-टॉकी सब्सक्रिप्शन नहीं है। सदस्य असाइन करने और तुरंत वॉइस कम्युनिकेशन शुरू करने के लिए कोई प्लान लें।';

  @override
  String get walkie_noTeamSubscription =>
      'कोई सक्रिय टीम सब्सक्रिप्शन नहीं मिला';

  @override
  String get walkie_noValidMembers =>
      'असाइन करने के लिए कोई मान्य सदस्य नहीं चुना गया';

  @override
  String get walkie_noVoiceSeatListenOnly =>
      'कोई वॉइस सीट असाइन नहीं — आप केवल-सुनें मोड में हैं';

  @override
  String get walkie_noWiredDevice =>
      'कोई वायर्ड ईयरफ़ोन या हेडसेट कनेक्ट नहीं है। कृपया उन्हें अपने डिवाइस में लगाएं।';

  @override
  String get walkie_notConnected => 'कनेक्टेड नहीं';

  @override
  String get walkie_notifLeave => 'छोड़ें';

  @override
  String get walkie_notifOpenWalkie => 'वॉकी खोलें';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name ने बोलना बंद किया';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name बोल रहे हैं';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return '$group के लिए नोटिफिकेशन सेटिंग अपडेट नहीं हो सकी। कृपया फिर से कोशिश करें।';
  }

  @override
  String get walkie_notificationSettingTitle => 'नोटिफिकेशन सेटिंग';

  @override
  String get walkie_onlyAdminCanAlert => 'केवल ग्रुप एडमिन अलर्ट भेज सकते हैं';

  @override
  String get walkie_openWalkieTalkie => 'वॉकी-टॉकी खोलें';

  @override
  String get walkie_otherTeam => 'दूसरी टीम';

  @override
  String get walkie_othersWontHear => 'दूसरे आपको नहीं सुन पाएंगे';

  @override
  String get walkie_planRequiredTitle => 'वॉकी-टॉकी प्लान ज़रूरी है';

  @override
  String get walkie_planRequiredToTalk => 'बात करने के लिए प्लान ज़रूरी';

  @override
  String get walkie_planStartsOnFirstAssign =>
      'पहला सदस्य असाइन होते ही प्लान शुरू होगा।';

  @override
  String get walkie_poorConnection =>
      'कमज़ोर नेटवर्क — ऑडियो में देरी हो सकती है';

  @override
  String get walkie_preparingAudio => 'ऑडियो तैयार हो रहा है...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'सदस्यों को वॉकी-टॉकी एक्सेस देने के लिए टीम प्लान खरीदें।';

  @override
  String get walkie_purchaseUpgradePlan => 'प्लान खरीदें / अपग्रेड करें';

  @override
  String get walkie_ready => 'तैयार';

  @override
  String get walkie_reconnecting => 'दोबारा जुड़ रहे हैं...';

  @override
  String get walkie_reconnectingServer =>
      'वॉकी सर्वर से दोबारा जुड़ रहे हैं...';

  @override
  String get walkie_releaseToStop => 'रोकने के लिए छोड़ें';

  @override
  String get walkie_removeAll => 'सभी हटाएं';

  @override
  String get walkie_searchGroups => 'ग्रुप खोजें';

  @override
  String get walkie_searchMembers => 'सदस्य खोजें...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total सीटें';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return 'कुल $total सीटें • $assigned असाइन • $available उपलब्ध';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '$assigned / $total सीटें उपयोग में';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds से.';
  }

  @override
  String get walkie_selectAtLeastOne =>
      'कृपया असाइन करने के लिए कम से कम एक सदस्य चुनें';

  @override
  String get walkie_selectGroupFirst => 'कृपया पहले एक ग्रुप चुनें';

  @override
  String get walkie_selectGroupToConnect => 'जुड़ने के लिए ग्रुप चुनें';

  @override
  String get walkie_selected => 'चुने गए';

  @override
  String get walkie_selfAccess => 'स्वयं एक्सेस';

  @override
  String get walkie_selfPlan => 'स्वयं प्लान';

  @override
  String get walkie_slideUpToLock => 'लॉक करने के लिए ऊपर स्लाइड करें';

  @override
  String get walkie_someone => 'कोई';

  @override
  String get walkie_someoneSpeaking => 'कोई बोल रहा है...';

  @override
  String get walkie_speaking => 'बोल रहे हैं...';

  @override
  String walkie_startFreeTrial(String duration) {
    return '$duration का फ्री ट्रायल शुरू करें';
  }

  @override
  String get walkie_strongConnection => 'मज़बूत कनेक्शन';

  @override
  String walkie_strongConnectionMs(int ms) {
    return 'मज़बूत कनेक्शन (${ms}ms)';
  }

  @override
  String get walkie_subscribeToStartTalk =>
      'वॉइस बातचीत शुरू करने और सदस्य असाइन करने के लिए सब्सक्राइब करें';

  @override
  String get walkie_subscribed => 'सब्सक्राइब्ड';

  @override
  String get walkie_talking => 'बोल रहे हैं...';

  @override
  String get walkie_tapToUnlock => 'अनलॉक के लिए टैप करें';

  @override
  String get walkie_teamAssignedElsewhere => 'टीम प्लान • कहीं और असाइन';

  @override
  String get walkie_teamPlan => 'टीम प्लान';

  @override
  String get walkie_teamPlanRequired => 'टीम प्लान ज़रूरी है';

  @override
  String get walkie_teamPlanRequiredToAssign =>
      'सदस्य असाइन करने के लिए टीम प्लान ज़रूरी है';

  @override
  String get walkie_teamPlanStatus => 'टीम प्लान स्थिति';

  @override
  String get walkie_teamSeatMember => 'टीम सीट सदस्य';

  @override
  String get walkie_title => 'वॉकी-टॉकी';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कुल $count',
      one: 'कुल 1',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => '1 घंटे का ट्रायल सक्रिय';

  @override
  String get walkie_trialEndedSubscribe =>
      'फ्री ट्रायल खत्म — जारी रखने के लिए सब्सक्राइब करें';

  @override
  String get walkie_unableToConnectReconnecting =>
      'चैनल से नहीं जुड़ पाए — दोबारा जुड़ रहे हैं...';

  @override
  String get walkie_unavailable => 'उपलब्ध नहीं';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'सदस्य अपडेट करें ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'सदस्य अपडेट हो रहे हैं...';

  @override
  String get walkie_upgradeAddSeats => 'अपग्रेड करें और सीटें जोड़ें';

  @override
  String get walkie_upgradeNow => 'अभी अपग्रेड करें';

  @override
  String get walkie_upgradeTeamAssign =>
      'टीम प्लान में अपग्रेड करें (सदस्य असाइन करें)';

  @override
  String get walkie_upgradeToTeamPlan => 'टीम प्लान में अपग्रेड करें';

  @override
  String walkie_userCancelled(String name) {
    return '$name ने रद्द किया';
  }

  @override
  String walkie_userJoined(String name) {
    return '$name जुड़े';
  }

  @override
  String walkie_userLeft(String name) {
    return '$name चले गए';
  }

  @override
  String walkie_validTill(String date) {
    return '$date तक मान्य';
  }

  @override
  String get walkie_viewPlan => 'प्लान देखें';

  @override
  String get walkie_voiceNotPermitted => 'आवाज़ भेजने की अनुमति नहीं है';

  @override
  String get walkie_weakSignal => 'कमज़ोर सिग्नल';

  @override
  String walkie_weakSignalMs(int ms) {
    return 'कमज़ोर सिग्नल (${ms}ms)';
  }

  @override
  String get walkie_youAreConnected => 'आप कनेक्टेड हैं';

  @override
  String get walkie_yourVoiceAccess => 'आपकी वॉइस एक्सेस';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Android के लिए डाउनलोड करें: $playStoreLink\n\niOS के लिए डाउनलोड करें: $appStoreLink';
  }

  @override
  String get widget_live => 'लाइव';

  @override
  String get widget_lostConnection => 'कनेक्शन टूट गया';

  @override
  String get widget_manageGroups => 'अपने समूहों को आसानी से प्रबंधित करें';

  @override
  String get widget_noInternetBody =>
      'उफ़... कोई इंटरनेट कनेक्शन नहीं मिला। कृपया अपना कनेक्शन जांचें';

  @override
  String get widget_notSeenYet => 'अभी तक नहीं देखा';

  @override
  String get widget_pinnedMessage => 'पिन किया गया संदेश';

  @override
  String get widget_private => 'निजी';

  @override
  String get widget_refreshPage => 'पेज रिफ्रेश करें';

  @override
  String get widget_seen => 'देखा गया';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count में से $total)';
  }

  @override
  String get widget_somethingWentWrongTitle => 'कुछ गलत हो गया';

  @override
  String get widget_userFallback => 'उपयोगकर्ता';
}
