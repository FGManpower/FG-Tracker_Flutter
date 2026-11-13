// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get about_aboutUs => 'من نحن';

  @override
  String get about_address => 'العنوان';

  @override
  String get about_appBarTitle => 'حول FG Tracker';

  @override
  String get about_company => 'الشركة';

  @override
  String get about_contactUs => 'اتصل بنا';

  @override
  String get about_developerEmail => 'البريد الإلكتروني للمطور';

  @override
  String get about_downloadTitle => '📱 تحميل التطبيق';

  @override
  String get about_howItWorksIntro =>
      'يسهل FG Tracker تنسيق الرحلات الجماعية. إليك الطريقة:';

  @override
  String get about_howItWorksTitle => '⚙️ كيف يعمل التطبيق';

  @override
  String get about_howStep1 => 'أنشئ مجموعة';

  @override
  String get about_howStep2 =>
      'شارك رمز المجموعة أو رمز الاستجابة السريعة (QR) مع رفقائك';

  @override
  String get about_howStep3 => 'ينضم كل عضو باستخدام الرمز المشترك أو رمز QR';

  @override
  String get about_howStep4 =>
      'تتبع موقع الجميع المباشر على خريطة مشتركة في الوقت الفعلي';

  @override
  String get about_howStep5 =>
      'استخدم ميزة المشاركة لدعوة المزيد من الأشخاص بسهولة';

  @override
  String get about_intro =>
      'يُعد FG Tracker رفيقك الموثوق للبقاء على اتصال وأمان أثناء التنقل في مجموعة. سواء كنت في رحلة عائلية أو نزهة مع الأصدقاء أو في طريقك مع الزملاء، يضمن FG Tracker عدم تخلف أي شخص.';

  @override
  String get about_privacyBody =>
      'سلامتك وخصوصيتك هي أولويتنا. لا يشارك FG Tracker موقعك مع أي شخص خارج مجموعتك. جميع البيانات مشفرة وتتم مشاركتها فقط مع الأشخاص المصرح لهم.';

  @override
  String get about_privacyPolicy => 'سياسة الخصوصية';

  @override
  String get about_privacyTitle => '🔐 الخصوصية والأمان';

  @override
  String get about_supportEmail => 'البريد الإلكتروني للدعم';

  @override
  String get about_supportTitle => '📩 الدعم ومعلومات المطور';

  @override
  String get about_termsConditions => 'الشروط والأحكام';

  @override
  String get about_title => 'حول';

  @override
  String get about_website => 'الموقع الإلكتروني';

  @override
  String get about_welcomeTitle => 'مرحبًا بك في FG Tracker';

  @override
  String get about_whyBuiltFor =>
      'مصمم خصيصًا للعائلات والأصدقاء وفرق العمل الصغيرة.';

  @override
  String get about_whyChooseTitle => '🌟 لماذا تختار FG Tracker؟';

  @override
  String get about_whyEasy =>
      'تطبيق خفيف وسهل الاستخدام مع تحكم كامل بالخصوصية.';

  @override
  String get about_whyNoCalls =>
      'لا داعي للاتصال أو المراسلة، تتبع مباشرة عبر الخريطة.';

  @override
  String get about_whyRealTime =>
      'مشاركة الموقع المباشر في الوقت الفعلي مع جميع أفراد المجموعة.';

  @override
  String appUpdate_checkError(String error) {
    return 'خطأ أثناء التحقق من التحديث: $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => 'هل تريد الخروج؟';

  @override
  String get appUpdate_noUpdateAvailable => 'لا توجد تحديثات متاحة';

  @override
  String get appUpdate_restartApp => 'إعادة تشغيل التطبيق';

  @override
  String get appUpdate_updateApp => 'تحديث التطبيق';

  @override
  String get appUpdate_updateAvailable => 'تحديث متاح';

  @override
  String get appUpdate_updateAvailableMessage =>
      'يتوفر تحديث جديد. يرجى تحديث التطبيق';

  @override
  String get appUpdate_updateUnavailable => 'التحديث غير متوفر حالياً';

  @override
  String appUpdate_updatingProgress(int progress) {
    return 'جاري التحديث... $progress٪';
  }

  @override
  String get attendance_addOption => 'إضافة خيار آخر';

  @override
  String get attendance_admin => 'مشرف';

  @override
  String get attendance_allowChange => 'السماح بتغيير الإجابة';

  @override
  String get attendance_allowChangeSubtitle =>
      'يمكن للأعضاء تغيير أو إزالة إجاباتهم';

  @override
  String get attendance_askCommunity => 'اسأل مجتمعك';

  @override
  String get attendance_cameraPermissionRequired =>
      'مطلوب إذن الكاميرا لتسجيل الحضور.';

  @override
  String get attendance_cameraStartFailed => 'تعذر بدء الكاميرا.';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'تعذر بدء الكاميرا ($code).';
  }

  @override
  String get attendance_cameraStarting => 'بدء تشغيل الكاميرا…';

  @override
  String get attendance_captureFailedBlink =>
      'تعذر الالتقاط. ارمش مرة أخرى للمحاولة';

  @override
  String attendance_capturedAtVerified(String time) {
    return 'تم الالتقاط في $time • تم التحقق';
  }

  @override
  String get attendance_capturedCheck => 'تم الالتقاط ✓';

  @override
  String get attendance_changeResponse => 'تغيير الإجابة';

  @override
  String get attendance_chooseFolder => 'اختر مجلداً، مثل التنزيلات';

  @override
  String get attendance_closeAction => 'إغلاق الحضور';

  @override
  String get attendance_closeConfirmBody =>
      'لن يتمكن الأعضاء من الإجابة بعد إغلاقها.';

  @override
  String get attendance_closeConfirmTitle => 'إغلاق استطلاع الحضور؟';

  @override
  String get attendance_closeEndOfDay => 'الإغلاق في نهاية اليوم';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return 'يغلق تلقائياً في الساعة $time اليوم';
  }

  @override
  String get attendance_closeFailed => 'تعذر إغلاق استطلاع الحضور';

  @override
  String get attendance_closeFailedShort => 'تعذر الإغلاق';

  @override
  String attendance_closesAt(String dateTime) {
    return 'يغلق في $dateTime';
  }

  @override
  String get attendance_createFailed => 'تعذر إنشاء استطلاع الحضور';

  @override
  String get attendance_createSubtitle => 'إرسال استطلاع حضور إلى هذه المجموعة';

  @override
  String get attendance_createTitle => 'إنشاء استطلاع الحضور';

  @override
  String get attendance_created => 'تم إنشاء استطلاع الحضور';

  @override
  String get attendance_dateEnded =>
      'انتهى التاريخ المحدد بالفعل. اختر تاريخاً آخر.';

  @override
  String get attendance_dateToday => 'التاريخ (اليوم)';

  @override
  String get attendance_dateTodaySemantics => 'تاريخ الحضور، اليوم';

  @override
  String get attendance_deleteFailed => 'تعذر حذف استطلاع الحضور';

  @override
  String get attendance_deletedText => 'تم حذف استطلاع الحضور هذا';

  @override
  String get attendance_downloadReport => 'تنزيل التقرير';

  @override
  String get attendance_everyoneResponded => 'أجاب الجميع';

  @override
  String get attendance_faceDetectedBlink =>
      'تم اكتشاف الوجه — ارمش بعينيك الآن';

  @override
  String get attendance_failed => 'فشل تسجيل الحضور';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return 'لم يتم الرد ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return 'تم الرد ($count)';
  }

  @override
  String get attendance_fixErrors => 'يرجى تصحيح الأخطاء المحددة قبل الإرسال';

  @override
  String get attendance_holdStill => 'اثبت في مكانك…';

  @override
  String get attendance_howToTakePhoto => 'كيفية التقاط صورتك';

  @override
  String get attendance_invalidGroup =>
      'مجموعة غير صالحة. يرجى إعادة فتح الدردشة.';

  @override
  String get attendance_keepFaceInCircle => 'أبقِ وجهك داخل الدائرة';

  @override
  String get attendance_limitReached => 'تم الوصول إلى الحد الأقصى';

  @override
  String get attendance_loadFailed => 'تعذر تحميل استطلاع الحضور';

  @override
  String get attendance_loadMore => 'تحميل المزيد';

  @override
  String get attendance_loadMoreFailed => 'تعذر تحميل المزيد';

  @override
  String get attendance_loadVotersFailed => 'تعذر تحميل قائمة المصوتين';

  @override
  String get attendance_lookAtCamera => 'انظر إلى الكاميرا';

  @override
  String get attendance_lookStraight => 'انظر مباشرة إلى الكاميرا';

  @override
  String get attendance_markYourAttendance => 'سجل حضورك';

  @override
  String attendance_markedAs(String option) {
    return 'تم التحديد كـ $option';
  }

  @override
  String get attendance_markedSuccess => 'تم تسجيل الحضور بنجاح';

  @override
  String attendance_maxOptions(int count) {
    return 'يمكنك إضافة ما يصل إلى $count خيارات فقط';
  }

  @override
  String get attendance_members => 'الأعضاء';

  @override
  String attendance_membersWithCount(int count) {
    return 'الأعضاء ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return 'مطلوب $count خيارات على الأقل';
  }

  @override
  String get attendance_moveCloser => 'اقترب قليلاً';

  @override
  String get attendance_multipleFaces =>
      'تم اكتشاف عدة وجوه — يجب أن تكون وحدك في الإطار';

  @override
  String get attendance_noCsvApp =>
      'لم يتم العثور على تطبيق لفتح ملفات CSV. استخدم الحفظ أو المشاركة بدلاً من ذلك.';

  @override
  String get attendance_noFace => 'لم يتم اكتشاف أي وجه';

  @override
  String get attendance_noFrontCamera =>
      'لم يتم العثور على كاميرا أمامية في هذا الجهاز.';

  @override
  String get attendance_noLocation => 'لا يوجد موقع متاح';

  @override
  String get attendance_noMembersMatch => 'لا يوجد أعضاء مطابقون لبحثك';

  @override
  String get attendance_noResponses => 'لا توجد إجابات بعد';

  @override
  String get attendance_notResponded => 'لم يتم الرد';

  @override
  String get attendance_openEyes => 'افتح عينيك وانظر إلى الكاميرا';

  @override
  String get attendance_openMapFailed => 'تعذر فتح الخريطة';

  @override
  String get attendance_openSubtitle => 'عرض في Excel أو الجداول أو تطبيق آخر';

  @override
  String get attendance_optionHint => 'أدخل تسمية الخيار';

  @override
  String get attendance_optionLabelRequired =>
      'يجب أن تحتوي جميع الخيارات على تسمية';

  @override
  String attendance_optionNumber(int number) {
    return 'الخيار $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return 'الخيار $number • 📷 صورة مطلوبة';
  }

  @override
  String get attendance_optionsUnique => 'يجب أن تكون الخيارات فريدة';

  @override
  String get attendance_photoCaptured => 'تم التقاط الصورة';

  @override
  String get attendance_photoCapturedTapRetake =>
      'تم التقاط الصورة ✓ (اضغط لإعادة الالتقاط)';

  @override
  String get attendance_photoProof => 'إثبات الصورة';

  @override
  String attendance_photoProofOf(String name) {
    return 'إثبات صورة $name';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ صورة مطلوبة لـ $option';
  }

  @override
  String get attendance_photoRules =>
      'تُستخدم الكاميرا الأمامية فقط. يتم التقاط الصورة تلقائياً عندما ترمش، ولا يُسمح بالتحميل من المعرض.';

  @override
  String get attendance_photoSubtitle => 'التقط صورة مباشرة لتأكيد حضورك';

  @override
  String get attendance_photoTitle => 'صورة الحضور';

  @override
  String get attendance_photoVerified => 'تم تأكيد الصورة';

  @override
  String get attendance_questionHint => 'هل ستكون متاحاً اليوم؟';

  @override
  String get attendance_questionLabel => 'سؤال الحضور';

  @override
  String get attendance_questionRequired => 'سؤال الحضور مطلوب';

  @override
  String attendance_questionTooShort(int count) {
    return 'يجب أن يتكون السؤال من $count أحرف على الأقل';
  }

  @override
  String get attendance_removeFailedShort => 'تعذر الإزالة';

  @override
  String get attendance_removeResponseBody =>
      'سيتم مسح حضورك في هذا الاستطلاع.';

  @override
  String get attendance_removeResponseTitle => 'إزالة إجابتك؟';

  @override
  String get attendance_removeVoteFailed => 'تعذر إزالة التصويت';

  @override
  String get attendance_reportEmpty => 'التقرير فارغ';

  @override
  String get attendance_reportFailed => 'فشل إنشاء التقرير';

  @override
  String get attendance_reportInvalid =>
      'أرجع الخادم تقريراً غير صالح. يرجى المحاولة مرة أخرى.';

  @override
  String attendance_reportReady(String fileName) {
    return 'التقرير جاهز • $fileName';
  }

  @override
  String get attendance_reportSaved => 'تم حفظ التتقرير';

  @override
  String get attendance_reportSubject => 'تقرير الحضور';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return 'تقرير الحضور • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return 'أجاب $count';
  }

  @override
  String get attendance_retakePhoto => 'إعادة التقاط الصورة';

  @override
  String get attendance_saveInFiles => 'حفظ في تطبيق الملفات';

  @override
  String get attendance_saveReportDialog => 'حفظ تقرير الحضور';

  @override
  String get attendance_saveToDevice => 'حفظ على الجهاز';

  @override
  String get attendance_searchMember => 'بحث عن عضو';

  @override
  String get attendance_selectPhotoOption => 'حدد خياراً يتطلب صورة مباشرة';

  @override
  String get attendance_selectStatus => 'يرجى تحديد حالتك';

  @override
  String get attendance_sentToAllMembers => 'أُرسل إلى جميع أعضاء هذه المجموعة';

  @override
  String get attendance_sentToGroup => 'تم إرسال الحضور إلى المجموعة';

  @override
  String get attendance_shareSubtitle => 'إرسال عبر واتساب أو البريد...';

  @override
  String get attendance_statusCompleted => 'مكتمل';

  @override
  String get attendance_statusOpen => 'مفتوح';

  @override
  String get attendance_stepBlink => 'ارمش بعينيك لالتقاط صورتك';

  @override
  String get attendance_stepEyeLevel => 'امسك هاتفك على مستوى عينيك';

  @override
  String get attendance_submit => 'إرسال الحضور';

  @override
  String get attendance_submitted => 'تم إرسال الحضور';

  @override
  String get attendance_title => 'الحضور';

  @override
  String get attendance_update => 'تحديث الحضور';

  @override
  String get attendance_validationError => 'خطأ في التحقق';

  @override
  String get attendance_view => 'عرض';

  @override
  String get attendance_viewTitle => 'عرض الحضور';

  @override
  String get attendance_voteFailed => 'تعذر تسجيل التصويت';

  @override
  String attendance_withinKm(String km) {
    return 'ضمن $km كم';
  }

  @override
  String attendance_withinMeters(int count) {
    return 'ضمن $count م';
  }

  @override
  String get call_accept => 'قبول';

  @override
  String get call_allContacts => 'جميع جهات الاتصال';

  @override
  String get call_allowAccess => 'السماح بالوصول';

  @override
  String get call_answer => 'رد';

  @override
  String get call_audioOutput => 'مخرج الصوت';

  @override
  String get call_callFrom => 'مكالمة من';

  @override
  String get call_callIdNotFound => 'معرف المكالمة غير موجود';

  @override
  String get call_callInformation => 'معلومات المكالمة';

  @override
  String get call_callSummary => 'ملخص المكالمة';

  @override
  String get call_caller => 'المتصل';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name و $count آخرين',
      one: '$name وآخر',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذر حذف $count مكالمات. حاول مجدداً.',
      one: 'تعذر حذف مكالمة واحدة. حاول مجدداً.',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حذف $count مكالمات',
      one: 'تم حذف مكالمة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'الكاميرا';

  @override
  String get call_cameraMicRequired => 'أذونات الكاميرا أو الميكروفون مطلوبة';

  @override
  String get call_cameraOff => 'الكاميرا مغلقة';

  @override
  String get call_cameraOn => 'الكاميرا مفتوحة';

  @override
  String get call_cameraUnavailable =>
      'الوصول إلى الكاميرا غير متاح حالياً. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get call_cannotReachCallServer =>
      'تعذر الاتصال بخادم المكالمات. يرجى التحقق من شبكتك.';

  @override
  String get call_chatFallback => 'دردشة';

  @override
  String get call_closeFullScreen => 'إغلاق ملء الشاشة';

  @override
  String get call_communicationUnavailable =>
      'الاتصال غير متاح مع هذا المستخدم';

  @override
  String get call_connectingProgress => 'جارٍ الاتصال…';

  @override
  String get call_connectionTimeout => 'انتهت مهلة الاتصال';

  @override
  String get call_contactInformation => 'معلومات الاتصال';

  @override
  String get call_contactsAccessBannerMessage =>
      'اعثر على أعضاء فريقك واتصل بهم بسهولة.';

  @override
  String get call_contactsAccessBannerTitle =>
      'اسمح لنا بالوصول إلى جهات اتصالك';

  @override
  String get call_contactsAccessMessage =>
      'نحتاج إلى الوصول إلى جهات اتصالك لمعرفة من يستخدم FG Tracker والسماح لك بالاتصال بهم أو إرسال دعوة.';

  @override
  String get call_contactsAccessTitle => 'السماح بالوصول إلى جهات الاتصال';

  @override
  String get call_decline => 'رفض';

  @override
  String get call_deleteCallsMessage =>
      'ستتم إزالة هذه المكالمات من سجل مكالماتك.';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حذف $count مكالمات؟',
      one: 'حذف مكالمة واحدة؟',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage =>
      'هل أنت متأكد من حذف هذا السجل للمكالمات؟';

  @override
  String get call_deleteHistoryTitle => 'حذف سجل المكالمات';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'هل أنت متأكد من حذف هذه السجلات الـ $count المحددة للمكالمات؟',
      one: 'هل أنت متأكد من حذف سجل المكالمة المحدد هذا؟',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => 'حذف المكالمات المحددة';

  @override
  String call_deleteWithCount(int count) {
    return 'حذف ($count)';
  }

  @override
  String call_durHr(int hours) {
    return '$hours س';
  }

  @override
  String call_durHrMin(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String call_durMin(int minutes) {
    return '$minutes د';
  }

  @override
  String call_durMinSec(int minutes, int seconds) {
    return '$minutes د $seconds ث';
  }

  @override
  String call_durSec(int seconds) {
    return '$seconds ث';
  }

  @override
  String call_durShortHr(int hours) {
    return '$hoursس';
  }

  @override
  String call_durShortHrMin(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String call_durShortMin(int minutes) {
    return '$minutesد';
  }

  @override
  String call_durShortMinSec(int minutes, int seconds) {
    return '$minutesد $secondsث';
  }

  @override
  String call_durShortSec(int seconds) {
    return '$secondsث';
  }

  @override
  String get call_duration => 'المدة';

  @override
  String call_durationValue(String duration) {
    return 'المدة: $duration';
  }

  @override
  String get call_earpiece => 'سماعة الأذن';

  @override
  String get call_endCall => 'إنهاء المكالمة';

  @override
  String get call_ended => 'انتهت';

  @override
  String get call_enterNumber => 'أدخل الرقم';

  @override
  String get call_enterPhoneNumber => 'يرجى إدخال رقم هاتف';

  @override
  String get call_entryDeleteFailed => 'فشل حذف سجل المكالمة';

  @override
  String call_entryDeleteFailedError(String error) {
    return 'فشل حذف سجل المكالمة: $error';
  }

  @override
  String get call_entryDeleted => 'تم حذف سجل المكالمة';

  @override
  String get call_everyoneInCall => 'الجميع في المكالمة بالفعل';

  @override
  String get call_failedTitle => 'فشلت المكالمة';

  @override
  String get call_groupBadge => 'مجموعة';

  @override
  String get call_groupCallComingSoon => 'المكالمات الجماعية قريباً';

  @override
  String get call_groupCallInitFailed => 'تعذر تهيئة المكالمة الجماعية';

  @override
  String get call_groupCallStartFailed =>
      'تعذر بدء المكالمة الجماعية. يرجى المحاولة مرة أخرى.';

  @override
  String get call_groupInformation => 'معلومات المجموعة';

  @override
  String call_groupWithId(String id) {
    return 'مجموعة $id';
  }

  @override
  String get call_headphones => 'سماعات الرأس';

  @override
  String call_historyCancelled(String callType) {
    return '$callType ملغاة';
  }

  @override
  String get call_historyClearFailed => 'فشل مسح سجل المكالمات';

  @override
  String call_historyClearFailedError(String error) {
    return 'فشل مسح سجل المكالمات: $error';
  }

  @override
  String get call_historyCleared => 'تم مسح كامل سجل المكالمات';

  @override
  String call_historyIncoming(String callType) {
    return '$callType واردة';
  }

  @override
  String call_historyMissed(String callType) {
    return '$callType فائتة';
  }

  @override
  String call_historyOutgoing(String callType) {
    return '$callType صادرة';
  }

  @override
  String call_historyRejected(String callType) {
    return '$callType مرفوضة';
  }

  @override
  String get call_inCall => 'في مكالمة';

  @override
  String call_inCallWithGroup(String groupName) {
    return 'في مكالمة · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return 'في هذه المكالمة ($count)';
  }

  @override
  String get call_incomingAudio => 'مكالمة صوتية واردة';

  @override
  String get call_incomingCallChannelName => 'مكالمة واردة';

  @override
  String get call_incomingGroupAudio => 'مكالمة صوتية جماعية واردة';

  @override
  String get call_incomingGroupVideo => 'مكالمة فيديو جماعية واردة';

  @override
  String get call_incomingVideo => 'مكالمة فيديو واردة';

  @override
  String get call_infoDescription => 'الوصف';

  @override
  String get call_infoEmail => 'البريد';

  @override
  String get call_infoGroupCode => 'رمز المجموعة';

  @override
  String get call_infoGroupName => 'اسم المجموعة';

  @override
  String get call_infoMobile => 'الجوال';

  @override
  String get call_infoTotalMembers => 'إجمالي الأعضاء';

  @override
  String get call_invite => 'دعوة';

  @override
  String get call_inviteToApp => 'دعوة إلى FG Tracker';

  @override
  String get call_join => 'انضمام';

  @override
  String get call_joinOnAnswer => 'ستنضم بمجرد الرد';

  @override
  String get call_kindAudio => 'مكالمة صوتية';

  @override
  String get call_kindCall => 'مكالمة';

  @override
  String get call_kindGroupAudio => 'مكالمة صوتية جماعية';

  @override
  String get call_kindGroupCall => 'مكالمة جماعية';

  @override
  String call_kindGroupOther(String kind) {
    return 'مكالمة جماعية $kind';
  }

  @override
  String get call_kindGroupVideo => 'مكالمة فيديو جماعية';

  @override
  String call_kindOther(String kind) {
    return 'مكالمة $kind';
  }

  @override
  String get call_kindVideo => 'مكالمة فيديو';

  @override
  String get call_loadDetailFailed => 'فشل تحميل تفاصيل المكالمة';

  @override
  String get call_loadMore => 'تحميل المزيد';

  @override
  String get call_loadRecentFailed => 'فشل تحميل المكالمات الأخيرة';

  @override
  String get call_loginToCall => 'يرجى تسجيل الدخول لإجراء مكالمة';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعضاء في هذه المكالمة',
      one: 'عضو واحد في هذه المكالمة',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'رسالة';

  @override
  String get call_micActive => 'الميكروفون نشط';

  @override
  String get call_missedCall => 'مكالمة فائتة';

  @override
  String get call_missedCallChannelName => 'مكالمة فائتة';

  @override
  String get call_missedCallNotification => 'مكالمة فائتة';

  @override
  String get call_more => 'المزيد';

  @override
  String get call_mute => 'كتم';

  @override
  String get call_muted => 'مكتوم';

  @override
  String call_nameYou(String name) {
    return '$name (أنت)';
  }

  @override
  String get call_noActiveParticipants => 'لا يوجد مشاركون نشطون';

  @override
  String get call_noContactsMatch => 'لا توجد جهات اتصال مطابقة لبحثك';

  @override
  String get call_noGroupsFound => 'لم يتم العثور على مجموعات';

  @override
  String get call_noGroupsYet => 'لا توجد مجموعات بعد';

  @override
  String get call_noNameGroup => 'مجموعة بدون اسم';

  @override
  String get call_noRecentCalls => 'لا توجد مكالمات حديثة';

  @override
  String get call_noRecentMatch => 'لا توجد مكالمات حديثة مطابقة لبحثك';

  @override
  String get call_noRecentYet => 'لا توجد مكالمات حديثة بعد';

  @override
  String get call_noRegisteredContacts => 'لم يتم العثور على جهات اتصال مسجلة';

  @override
  String get call_notInContacts => 'هذا الرقم ليس في جهات اتصالك';

  @override
  String call_notInThisCall(int count) {
    return 'ليسوا في هذه المكالمة ($count)';
  }

  @override
  String get call_notReady => 'المكالمة غير جاهزة';

  @override
  String get call_notificationPermissionRationale =>
      'مطلوب لإظهار المكالمات الواردة.';

  @override
  String get call_notificationPermissionSettings =>
      'تفعيل الإشعارات في الإعدادات.';

  @override
  String get call_notificationPermissionTitle => 'إذن الإشعارات';

  @override
  String get call_notify => 'إشعار';

  @override
  String get call_notifyFailed => 'فشل الإشعار';

  @override
  String get call_notifySent => 'تم الإشعار بنجاح';

  @override
  String get call_ongoingChannelDescription =>
      'يحافظ على استمرار المكالمة ومشاركة الشاشة';

  @override
  String get call_ongoingChannelName => 'مكالمة جارية';

  @override
  String get call_otherAlreadySharing => 'الطرف الآخر يشارك شاشته بالفعل';

  @override
  String get call_otherStartingVideo => 'الطرف الآخر يقوم بتشغيل الفيديو';

  @override
  String get call_participant => 'مشارك';

  @override
  String get call_participants => 'المشاركون';

  @override
  String call_personIsSharing(String name) {
    return '$name يشارك الآن';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name يشارك الشاشة';
  }

  @override
  String get call_phone => 'الهاتف';

  @override
  String get call_pleaseWait => 'يرجى الانتظار';

  @override
  String get call_recentCalls => 'المكالمات الأخيرة';

  @override
  String get call_resetZoom => 'إعادة ضبط التكبير';

  @override
  String get call_returnToCall => 'العودة إلى المكالمة';

  @override
  String get call_screenBeingShared => 'تتم مشاركة الشاشة';

  @override
  String get call_screenShareChannelDescription =>
      'إشعار جلسة مشاركة الشاشة النشطة';

  @override
  String get call_screenShareChannelName => 'خدمة مشاركة الشاشة';

  @override
  String get call_screenSharePermissionDenied => 'تم رفض إذن مشاركة الشاشة';

  @override
  String get call_screenShareStartFailed => 'تعذر بدء مشاركة الشاشة';

  @override
  String get call_screenShareStopped => 'تم إيقاف مشاركة الشاشة';

  @override
  String get call_screenSharingTitle => 'مشاركة الشاشة';

  @override
  String call_screenVisibleToName(String name) {
    return 'شاشتك مرئية لـ $name';
  }

  @override
  String get call_screenVisibleToOther => 'شاشتك مرئية للطرف الآخر';

  @override
  String get call_searchHint => 'البحث في جهات الاتصال أو المجموعات';

  @override
  String get call_sectionLastWeek => 'الأسبوع الماضي';

  @override
  String get call_sectionOlder => 'أقدم';

  @override
  String get call_sectionThisWeek => 'هذا الأسبوع';

  @override
  String get call_selectAll => 'تحديد الكل';

  @override
  String call_selectedCount(int count) {
    return '$count محدد';
  }

  @override
  String get call_selectedDeleteFailed => 'فشل حذف المكالمات المحددة';

  @override
  String call_selectedDeleteFailedError(String error) {
    return 'فشل حذف المكالمات المحددة: $error';
  }

  @override
  String get call_selectedDeleted => 'تم حذف المكالمات المحددة';

  @override
  String get call_selfCallWarning => 'لا يمكنك الاتصال برقمك الخاص.';

  @override
  String get call_sessionConnectFailed => 'فشل الاتصال بجلسة المكالمة';

  @override
  String get call_shareScreen => 'مشاركة الشاشة';

  @override
  String get call_shareScreenShort => 'مشاركة';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return 'مشاركة في $groupName • اضغط للعودة للمكالمة';
  }

  @override
  String get call_sharingYourScreen => 'مشاركة شاشتك';

  @override
  String get call_someone => 'شخص ما';

  @override
  String get call_speaker => 'مكبر الصوت';

  @override
  String get call_started => 'بدأت';

  @override
  String get call_startingScreenShare => 'بدء مشاركة الشاشة…';

  @override
  String get call_statusBusy => 'مشغول';

  @override
  String get call_statusCalling => 'جارٍ الاتصال';

  @override
  String get call_statusCancelled => 'ملغاة';

  @override
  String get call_statusCompleted => 'مكتملة';

  @override
  String get call_statusConnected => 'تم الاتصال';

  @override
  String get call_statusConnecting => 'جارٍ الربط';

  @override
  String get call_statusDeclined => 'تم الرفض';

  @override
  String get call_statusJoined => 'انضم';

  @override
  String get call_statusMissed => 'فائتة';

  @override
  String get call_statusReconnecting => 'جارٍ إعادة الاتصال';

  @override
  String get call_statusRinging => 'رنين';

  @override
  String get call_statusVideoConnecting => 'جارٍ ربط الفيديو';

  @override
  String get call_stop => 'إيقاف';

  @override
  String get call_stopSharing => 'إيقاف المشاركة';

  @override
  String get call_subtitle => 'مكالمة صوتية / فيديو';

  @override
  String get call_swipeUpToAnswer => 'اسحب للأعلى للرد';

  @override
  String get call_switch => 'تبديل';

  @override
  String get call_switchCameraFailed => 'تعذر تبديل الكاميرا';

  @override
  String get call_switchToVideoToShare =>
      'التبديل إلى مكالمة فيديو لمشاركة الشاشة';

  @override
  String get call_tabContacts => 'جهات الاتصال';

  @override
  String get call_tabGroups => 'المجموعات';

  @override
  String get call_tabRecent => 'الأخيرة';

  @override
  String get call_tapNotifyToInvite => 'اضغط على إشعار للدعوة';

  @override
  String get call_tapStartBroadcastHint =>
      'اضغط على بدء البث إذا ظهرت رسالة النظام';

  @override
  String get call_title => 'مكالمة';

  @override
  String call_todayAt(String value) {
    return 'اليوم، $value';
  }

  @override
  String get call_total => 'الإجمالي';

  @override
  String get call_turnOnVideo => 'تشغيل الفيديو';

  @override
  String get call_unableToCallContact => 'تعذر الاتصال بجهة الاتصال هذه';

  @override
  String get call_unableToMakeCall => 'تعذر إجراء المكالمة';

  @override
  String get call_unableToOpenChat => 'تعذر فتح الدردشة لجهة الاتصال هذه';

  @override
  String get call_unableToShareScreen => 'تعذر مشاركة الشاشة';

  @override
  String get call_unavailableTitle => 'المكالمة غير متاحة';

  @override
  String get call_unexpectedResponse => 'استجابة غير متوقعة من الخادم';

  @override
  String get call_unknown => 'غير معروف';

  @override
  String get call_unknownGroup => 'مجموعة غير معروفة';

  @override
  String get call_unknownUser => 'مستخدم غير معروف';

  @override
  String get call_unmute => 'إلغاء الكتم';

  @override
  String get call_unselectAll => 'إلغاء تحديد الكل';

  @override
  String get call_user => 'مستخدم';

  @override
  String get call_userNotFound => 'المستخدم غير موجود';

  @override
  String call_userWithId(String id) {
    return 'مستخدم $id';
  }

  @override
  String get call_video => 'فيديو';

  @override
  String get call_waitingForBroadcast => 'في انتظار بدء البث';

  @override
  String get call_waitingForBroadcastMessage =>
      'اضغط على \"بدء البث\" في نافذة النظام لمشاركة شاشتك.';

  @override
  String get call_waitingForMedia => 'في انتظار تدفق الوسائط...';

  @override
  String get call_wired => 'سلكي';

  @override
  String get call_yesDelete => 'نعم، حذف';

  @override
  String call_yesterdayAt(String value) {
    return 'أمس، $value';
  }

  @override
  String get call_youAreSharing => 'أنت تشارك الآن';

  @override
  String get call_youAreSharingScreen => 'أنت تشارك شاشتك الآن';

  @override
  String get call_zoomIn => 'تكبير';

  @override
  String get call_zoomOut => 'تصغير';

  @override
  String get chatList_allChats => 'جميع المحادثات';

  @override
  String get chatList_allContacts => 'جميع جهات الاتصال';

  @override
  String get chatList_allowAccess => 'السماح بالوصول';

  @override
  String get chatList_allowContactsBody =>
      'نحتاج إلى الوصول إلى جهات اتصالك لمعرفة من يستخدم FG Tracker والسماح لك ببدء محادثة أو إرسال دعوة.';

  @override
  String get chatList_allowContactsTitle => 'السماح بالوصول إلى جهات الاتصال';

  @override
  String get chatList_archiveChat => 'أرشفة المحادثة';

  @override
  String get chatList_archived => 'مؤرشف';

  @override
  String get chatList_archivedChatsSubtitle => 'محادثاتك المخفية';

  @override
  String get chatList_archivedChatsTitle => 'المحادثات المؤرشفة';

  @override
  String chatList_archivedCount(int count) {
    return 'المؤرشفة ($count)';
  }

  @override
  String get chatList_block => 'حظر';

  @override
  String get chatList_blockFailed => 'تعذر حظر المستخدم';

  @override
  String chatList_blockName(String name) {
    return 'حظر $name';
  }

  @override
  String get chatList_blockUser => 'حظر المستخدم';

  @override
  String get chatList_blockUserConfirm => 'هل أنت متأكد من حظر هذا المستخدم؟';

  @override
  String get chatList_blocked => 'محظور';

  @override
  String get chatList_chatCleared => 'تم مسح الدردشة';

  @override
  String get chatList_chooseContactToShare =>
      'اختر جهة اتصال لمشاركتها في محادثتك.';

  @override
  String get chatList_clear => 'مسح';

  @override
  String get chatList_clearChat => 'مسح الدردشة';

  @override
  String get chatList_clearChatConfirm =>
      'هل تريد حذف جميع الرسائل مع هذا المستخدم؟';

  @override
  String get chatList_clearChatFailed => 'تعذر مسح الدردشة';

  @override
  String get chatList_clearSearch => 'مسح البحث';

  @override
  String get chatList_contactAndInfo => 'جهة الاتصال والمعلومات';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'مطلوب إذن جهات الاتصال لمشاركة جهة اتصال في الدردشة.';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهات اتصال',
      one: 'جهة اتصال واحدة',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return 'فشل تحميل جهات الاتصال: $error';
  }

  @override
  String get chatList_contactsPermissionNeeded => 'مطلوب إذن جهات الاتصال';

  @override
  String get chatList_contactsWillAppear =>
      'ستظهر جهات اتصالك هنا عندما تكون متاحة.';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => 'معطل';

  @override
  String get chatList_defaultAbout => 'مرحباً! أنا أستخدم FG Tracker';

  @override
  String get chatList_deleteChat => 'حذف المحادثة';

  @override
  String get chatList_deleteChatConfirm =>
      'هل تريد حذف هذه المحادثة من قائمة الدردشات؟';

  @override
  String get chatList_forwardFailed => 'تعذر إعادة توجيه الرسالة.';

  @override
  String get chatList_forwardListLoadFailed =>
      'تعذر تحميل قائمة إعادة التوجيه.';

  @override
  String get chatList_forwardTo => 'إعادة توجيه إلى...';

  @override
  String get chatList_forwarded => 'محولة';

  @override
  String get chatList_groupChatFallback => 'محادثة المجموعة';

  @override
  String get chatList_groupDeactivatedBanner =>
      'تم إلغاء تفعيل هذه المجموعة من قبل المشرف';

  @override
  String get chatList_groupFallback => 'المجموعة';

  @override
  String get chatList_howToAllow => 'كيفية السماح';

  @override
  String get chatList_howToAllowStep1 =>
      'اضغط على \"السماح بالوصول\" لفتح الإعدادات';

  @override
  String get chatList_howToAllowStep2 => 'اضغط على \"الأذونات\"';

  @override
  String get chatList_howToAllowStep3 => 'حدد \"جهات الاتصال\"';

  @override
  String get chatList_howToAllowStep4 => 'اختر \"سماح\"، ثم ارجع إلى التطبيق';

  @override
  String get chatList_invite => 'دعوة';

  @override
  String get chatList_inviteChooseHow =>
      'اختر الطريقة التي تريد إرسال الدعوة بها';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return 'مرحباً $name! انضم إليّ على FG Tracker.\n\nتنزيل لأندرويد: $playStoreLink\n\nتنزيل لـ iOS: $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'المزيد من التطبيقات';

  @override
  String chatList_inviteName(String name) {
    return 'دعوة $name';
  }

  @override
  String get chatList_inviteViaMessage => 'رسالة';

  @override
  String get chatList_locationHidden => 'الموقع مخفي';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1 و $name2 و+$count يكتبون...';
  }

  @override
  String get chatList_markAsRead => 'تحديد كمقروء';

  @override
  String get chatList_markAsUnread => 'تحديد كغير مقروء';

  @override
  String get chatList_mediaLinksDocs => 'الوسائط والروابط والمستندات';

  @override
  String get chatList_memberFallback => 'عضو';

  @override
  String get chatList_messageDeleted => 'تم حذف هذه الرسالة';

  @override
  String get chatList_messageForwarded => 'تمت إعادة توجيه الرسالة';

  @override
  String get chatList_messageIdMissing => 'معرف الرسالة مفقود.';

  @override
  String chatList_minutesShort(int count) {
    return '$count د';
  }

  @override
  String get chatList_mute1Hour => 'ساعة واحدة';

  @override
  String get chatList_mute8Hours => '8 ساعات';

  @override
  String get chatList_muteAlways => 'حتى أقوم بإعادة تشغيله';

  @override
  String get chatList_muteSubtitle =>
      'اختر المدة التي تريد إيقاف الإشعارات خلالها.';

  @override
  String get chatList_muteTitle => 'كتم الإشعارات';

  @override
  String get chatList_muteUntilTomorrow => 'حتى الغد';

  @override
  String get chatList_newChat => 'محادثة جديدة';

  @override
  String get chatList_newChatSectionContacts =>
      'بدء محادثة جديدة (جهات الاتصال)';

  @override
  String get chatList_newChatSectionInvite =>
      'دعوة للدردشة (جهات اتصال غير مسجلة)';

  @override
  String get chatList_noArchivedChats => 'لا توجد محادثات مؤرشفة';

  @override
  String get chatList_noArchivedChatsSubtitle =>
      'ستظهر المحادثات المؤرشفة هنا.';

  @override
  String get chatList_noChatsFound => 'لم يتم العثور على محادثات';

  @override
  String get chatList_noChatsSubtitle => 'ستظهر محادثاتك الخاصة هنا.';

  @override
  String get chatList_noContactsAvailable => 'لا توجد جهات اتصال متاحة';

  @override
  String get chatList_noContactsFound => 'لم يتم العثور على جهات اتصال';

  @override
  String get chatList_noGroupsAvailable => 'لا توجد مجموعات متاحة';

  @override
  String get chatList_noGroupsFound => 'لم يتم العثور على مجموعات';

  @override
  String get chatList_noMediaYet => 'لم تتم مشاركة أي وسائط بعد';

  @override
  String get chatList_noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get chatList_noPeopleOrGroups => 'لم يتم العثور على أشخاص أو مجموعات';

  @override
  String chatList_noResultsFor(String query) {
    return 'لم يتم العثور على نتائج لـ \"$query\"';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return 'لا توجد نتائج لـ \'$query\'';
  }

  @override
  String get chatList_noTrackerContacts =>
      'لم يتم العثور على جهات اتصال نشطة في التتبع';

  @override
  String get chatList_offlineNotSaved =>
      'أنت غير متصل. لم يتم حفظ التغيير، يرجى المحاولة مرة أخرى.';

  @override
  String chatList_oneTyping(String name) {
    return '$name يكتب الآن...';
  }

  @override
  String get chatList_openSettings => 'فتح الإعدادات';

  @override
  String get chatList_pinChat => 'تثبيت المحادثة';

  @override
  String get chatList_pinnedChats => 'المحادثات المثبتة';

  @override
  String get chatList_pleaseTryAgain => 'يرجى المحاولة مرة أخرى.';

  @override
  String get chatList_profileCall => 'اتصال';

  @override
  String get chatList_profileMessage => 'رسالة';

  @override
  String get chatList_profileNotFound =>
      'لم يتم العثور على تفاصيل الملف الشخصي';

  @override
  String get chatList_profileVideoCall => 'مكالمة فيديو';

  @override
  String get chatList_quickCommSubtitle => 'تواصل مع فريقك فوراً';

  @override
  String get chatList_quickCommTitle => 'تواصل سريع';

  @override
  String get chatList_quickGroups => 'المجموعات';

  @override
  String get chatList_quickGroupsSub => 'محادثات الفريق';

  @override
  String get chatList_quickSafeZone => 'المنطقة الآمنة';

  @override
  String get chatList_quickSafeZoneSub => 'الأمان والتنبيهات';

  @override
  String get chatList_quickTracking => 'التتبع';

  @override
  String get chatList_quickTrackingSub => 'الموقع المباشر';

  @override
  String get chatList_quickWalkie => 'لاسلكي';

  @override
  String get chatList_quickWalkieSub => 'اضغط للتحدث';

  @override
  String get chatList_searchByNameOrNumber => 'بحث بالاسم أو الرقم...';

  @override
  String get chatList_searchGroupsHint => 'بحث في المجموعات...';

  @override
  String get chatList_searchHint => 'بحث في المحادثات أو الرسائل...';

  @override
  String get chatList_searchHintShort => 'بحث...';

  @override
  String get chatList_searchNameOrNumber => 'بحث بالاسم أو الرقم';

  @override
  String get chatList_searchResults => 'نتائج البحث';

  @override
  String get chatList_sectionGroups => 'المجموعات';

  @override
  String get chatList_sectionMyContacts => 'جهات اتصالي';

  @override
  String get chatList_sectionOtherContacts => 'جهات اتصال أخرى';

  @override
  String get chatList_sectionRecentChats => 'المحادثات الأخيرة';

  @override
  String get chatList_selectDestination => 'تحديد الوجهة';

  @override
  String get chatList_selectDestinationMsg =>
      'يرجى تحديد شخص واحد أو مجموعة واحدة على الأقل.';

  @override
  String chatList_selectedCount(int count) {
    return '$count محدد';
  }

  @override
  String get chatList_shareContactTitle => 'مشاركة جهة اتصال';

  @override
  String chatList_shareMenuFailed(String error) {
    return 'تعذر فتح قائمة المشاركة: $error';
  }

  @override
  String get chatList_smsOpenFailed => 'تعذر فتح تطبيق الرسائل';

  @override
  String get chatList_someone => 'شخص ما';

  @override
  String get chatList_startConversation => 'بدء محادثة';

  @override
  String get chatList_subtitle => 'ابقَ على اتصال مع فريقك';

  @override
  String get chatList_telegramOpenFailed => 'تعذر فتح تيليجرام';

  @override
  String get chatList_title => 'الدردشة';

  @override
  String get chatList_tryAnotherNameOrNumber => 'جرب اسماً أو رقم هاتف آخر.';

  @override
  String get chatList_tryDifferentSearch => 'جرب البحث باسم أو رسالة أخرى.';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1 و $name2 يكتبان...';
  }

  @override
  String get chatList_typing => 'يكتب...';

  @override
  String get chatList_unableToCallContact => 'تعذر الاتصال بجهة الاتصال هذه';

  @override
  String get chatList_unableToLoadContacts => 'تعذر تحميل جهات الاتصال';

  @override
  String get chatList_unarchiveChat => 'إلغاء أرشفة المحادثة';

  @override
  String get chatList_unblock => 'إلغاء الحظر';

  @override
  String get chatList_unblockFailed => 'تعذر إلغاء حظر المستخدم';

  @override
  String chatList_unblockName(String name) {
    return 'إلغاء حظر $name';
  }

  @override
  String get chatList_unblockUser => 'إلغاء حظر المستخدم';

  @override
  String get chatList_unblockUserConfirm =>
      'هل أنت متأكد من إلغاء حظر هذا المستخدم؟';

  @override
  String get chatList_unknown => 'غير معروف';

  @override
  String get chatList_unknownUser => 'مستخدم غير معروف';

  @override
  String get chatList_unnamedContact => 'جهة اتصال بدون اسم';

  @override
  String get chatList_unpinChat => 'إلغاء تثبيت المحادثة';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسائل غير مقروءة',
      one: 'رسالة واحدة غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed =>
      'تعذر تحديث الدردشة. يرجى المحاولة مرة أخرى.';

  @override
  String get chatList_userFallback => 'مستخدم';

  @override
  String get chatList_userNotFound => 'المستخدم غير موجود';

  @override
  String get chatList_viewArchived => 'عرض المحادثات المؤرشفة';

  @override
  String get chatList_whatsappOpenFailed => 'تعذر فتح واتساب';

  @override
  String get chatList_yourContacts => 'جهات اتصالك';

  @override
  String get chat_addCaptionHint => 'إضافة تسمية توضيحية...';

  @override
  String get chat_audioUnavailable => 'هذا المقطع الصوتي لم يعد متاحاً';

  @override
  String get chat_blockFailed => 'تعذر حظر المستخدم';

  @override
  String get chat_call => 'اتصال';

  @override
  String get chat_cameraAccessNeeded =>
      'مطلوب إذن الكاميرا لالتقاط الصور ومقاطع الفيديو في الدردشة.';

  @override
  String get chat_cameraModePhoto => 'صورة';

  @override
  String get chat_cameraModePortrait => 'بورتريه';

  @override
  String get chat_cameraModeVideo => 'فيديو';

  @override
  String get chat_cameraStartFailed => 'تعذر بدء الكاميرا.';

  @override
  String get chat_cantMessageUser => 'لا يمكنك مراسلة هذا المستخدم';

  @override
  String get chat_chatActionsSubtitle => 'إدارة محادثتك';

  @override
  String get chat_chatActionsTitle => 'إجراءات الدردشة';

  @override
  String get chat_clear => 'مسح';

  @override
  String get chat_clearChat => 'مسح الدردشة';

  @override
  String get chat_clearChatConfirm =>
      'هل تريد مسح جميع الرسائل من هذه المحادثة؟';

  @override
  String get chat_clearGroupChatFailed => 'فشل مسح محادثة المجموعة';

  @override
  String get chat_contactBlockedYou => 'قامت جهة الاتصال هذه بحظرك';

  @override
  String get chat_contactUnavailable => 'جهة الاتصال غير متاحة';

  @override
  String get chat_deleteForEveryone => 'الحذف لدى الجميع';

  @override
  String get chat_deleteForEveryoneConfirm =>
      'هل أنت متأكد من حذف هذه الرسالة لدى الجميع؟';

  @override
  String get chat_deleteForMe => 'الحذف لدي';

  @override
  String get chat_deleteForMeConfirm => 'هل أنت متأكد من حذف هذه الرسالة لديك؟';

  @override
  String get chat_deleteMember => 'حذف العضو';

  @override
  String get chat_deleteMemberSubtitle => 'إزالة عضو من هذه المجموعة';

  @override
  String get chat_documentAvailable => 'المستند متاح';

  @override
  String get chat_documentDownloadFailed => 'تعذر تنزيل المستند.';

  @override
  String get chat_documentOpenFailed =>
      'تعذر فتح المستند. يرجى المحاولة مرة أخرى.';

  @override
  String get chat_documentPreviewUnavailable =>
      'المعاينة غير متاحة لهذا النوع من الملفات. افتح المستند باستخدام التطبيق المثبت.';

  @override
  String get chat_documentUnavailable => 'هذا المستند لم يعد متاحاً';

  @override
  String get chat_downloadFailed => 'فشل التنزيل';

  @override
  String get chat_edited => 'تم تعديلها';

  @override
  String get chat_emptySubtitle => 'قل مرحباً 👋 لبدء المحادثة';

  @override
  String get chat_emptyTitle => 'لا توجد رسائل هنا بعد';

  @override
  String get chat_fetchingLocation => 'جارٍ جلب الموقع...';

  @override
  String get chat_finishVoiceRecordingFirst =>
      'قم بإنهاء أو إلغاء التسجيل الصوتي أولاً';

  @override
  String get chat_forwarded => 'محولة';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current من $total';
  }

  @override
  String get chat_groupActionsSubtitle => 'إدارة إعدادات مجموعتك';

  @override
  String get chat_groupActionsTitle => 'إجراءات المجموعة';

  @override
  String get chat_groupChatCleared => 'تم مسح محادثة المجموعة بنجاح';

  @override
  String get chat_groupDeactivated =>
      'تم إلغاء تفعيل هذه المجموعة من قبل المشرف';

  @override
  String get chat_imageFailed => 'فشلت الصورة';

  @override
  String get chat_listen => 'استماع';

  @override
  String get chat_listenEnglish => 'استماع (الإنجليزية)';

  @override
  String get chat_listenHindi => 'استماع (الهندية)';

  @override
  String get chat_loadFailedSubtitle => 'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get chat_loadFailedTitle => 'تعذر تحميل الرسائل';

  @override
  String get chat_locationFetchFailed =>
      'تعذر الحصول على موقعك. يرجى المحاولة مرة أخرى.';

  @override
  String get chat_locationPermissionNeeded => 'مطلوب إذن الموقع لمشاركة موقعك.';

  @override
  String get chat_locationPermissionOff =>
      'إذن الموقع مغلق لهذا التطبيق. يرجى تفعيله في الإعدادات لمشاركة موقعك.';

  @override
  String get chat_locationServicesOff =>
      'قم بتشغيل خدمات الموقع لمشاركة موقعك.';

  @override
  String get chat_locationUnavailable => 'الموقع غير متاح';

  @override
  String get chat_mediaMissing => 'الوسائط مفقودة';

  @override
  String get chat_mediaMissingToast =>
      'الوسائط مفقودة. هذا الملف لم يعد متاحاً.';

  @override
  String get chat_mediaUnavailable => 'هذه الوسائط لم تعد متاحة';

  @override
  String get chat_menuForward => 'إعادة توجيه';

  @override
  String get chat_menuMessageInfo => 'معلومات الرسالة';

  @override
  String get chat_menuPin => 'تثبيت الرسالة';

  @override
  String get chat_menuReply => 'رد';

  @override
  String get chat_menuUnpin => 'إلغاء تثبيت الرسالة';

  @override
  String get chat_messageCopied => 'تم نسخ الرسالة';

  @override
  String get chat_messageDeleted => 'تم حذف هذه الرسالة';

  @override
  String get chat_messageNotAvailable => 'الرسالة غير متاحة';

  @override
  String get chat_messageNotSent =>
      'لم يتم إرسال الرسالة. يرجى المحاولة مرة أخرى.';

  @override
  String get chat_noCameraFound => 'لم يتم العثور على كاميرا في هذا الجهاز.';

  @override
  String get chat_noLongerMember => 'لم تعد عضواً في هذه المجموعة';

  @override
  String get chat_noMediaAvailable => 'لا توجد وسائط متاحة';

  @override
  String get chat_offlineNotSent => 'أنت غير متصل. لم يتم إرسال الرسالة.';

  @override
  String get chat_openDocument => 'فتح المستند';

  @override
  String get chat_openInGoogleMaps => 'فتح في خرائط Google';

  @override
  String get chat_openSettings => 'فتح الإعدادات';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص',
      one: 'شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'هذه الصورة لم تعد متاحة';

  @override
  String get chat_previewAttendancePoll => 'استطلاع الحضور';

  @override
  String get chat_previewAudio => 'صوت';

  @override
  String get chat_previewContact => 'جهة اتصال';

  @override
  String get chat_previewDocument => 'مستند';

  @override
  String get chat_previewLocation => 'الموقع';

  @override
  String get chat_previewMessage => 'رسالة';

  @override
  String get chat_previewNewMessage => 'رسالة جديدة';

  @override
  String get chat_previewOwnDeleted => 'لقد حذفت هذه الرسالة';

  @override
  String get chat_previewPhoto => 'صورة';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صور',
      one: 'صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => 'استطلاع';

  @override
  String get chat_previewSticker => 'ملصق';

  @override
  String get chat_previewVideo => 'فيديو';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقاطع فيديو',
      one: 'فيديو واحد',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => 'رسالة صوتية';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return 'رسالة صوتية ($duration)';
  }

  @override
  String get chat_recordingFailed => 'فشل التسجيل';

  @override
  String get chat_removeMember => 'إزالة العضو';

  @override
  String get chat_removeMemberConfirm =>
      'هل أنت متأكد من إزالة هذا العضو من المجموعة؟';

  @override
  String get chat_replyHint => 'الرد على الرسالة...';

  @override
  String get chat_searchMessages => 'بحث في الرسائل';

  @override
  String get chat_searchMessagesHint => 'بحث في الرسائل...';

  @override
  String get chat_searchMessagesSubtitle =>
      'البحث عن الرسائل بالكلمات المفتاحية';

  @override
  String get chat_sendLocation => 'إرسال الموقع';

  @override
  String get chat_shareLocation => 'مشاركة الموقع';

  @override
  String get chat_shareVideoFailed => 'تعذر مشاركة الفيديو';

  @override
  String get chat_sharedFromApp => 'تمت المشاركة من FG Tracker';

  @override
  String get chat_sharedLocation => 'موقع تمت مشاركته';

  @override
  String get chat_showOriginal => 'عرض الأصل';

  @override
  String get chat_someone => 'شخص ما';

  @override
  String get chat_statusLabel => 'الحالة';

  @override
  String get chat_statusUnavailable => 'تحديث الحالة هذا لم يعد متاحاً';

  @override
  String get chat_stop => 'إيقاف';

  @override
  String get chat_stopEnglish => 'إيقاف (الإنجليزية)';

  @override
  String get chat_stopHindi => 'إيقاف (الهندية)';

  @override
  String get chat_takePhotoFailed => 'فشل التقاط الصورة';

  @override
  String get chat_translatedToEnglish => 'مترجم إلى الإنجليزية';

  @override
  String get chat_translatedToHindi => 'مترجم إلى الهندية';

  @override
  String get chat_translating => 'جارٍ الترجمة...';

  @override
  String get chat_tryAgain => 'إعادة المحاولة';

  @override
  String get chat_typeMessageHint => 'اكتب رسالة...';

  @override
  String get chat_typing => 'يكتب...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص يكتبون...',
      one: 'شخص واحد يكتب...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name يكتب الآن...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1 و $name2 يكتبان الآن...';
  }

  @override
  String get chat_unableToOpen => 'تعذر الفتح';

  @override
  String get chat_unableToOpenGoogleMaps => 'تعذر فتح خرائط Google';

  @override
  String get chat_unblock => 'إلغاء الحظر';

  @override
  String get chat_unblockContact => 'إلغاء حظر جهة الاتصال';

  @override
  String get chat_unblockContactConfirm =>
      'هل أنت متأكد من إلغاء حظر جهة الاتصال هذه؟';

  @override
  String get chat_unblockFailed => 'تعذر إلغاء حظر المستخدم';

  @override
  String get chat_unknown => 'غير معروف';

  @override
  String get chat_unknownLocation => 'موقع غير معروف';

  @override
  String get chat_unsupportedMessage =>
      'هذه الرسالة غير مدعومة في هذا الإصدار من التطبيق';

  @override
  String get chat_updateGroup => 'تحديث المجموعة';

  @override
  String get chat_updateGroupSubtitle => 'تغيير تفاصيل المجموعة الحالية';

  @override
  String chat_uploadFileFailed(String path) {
    return 'فشل تحميل $path';
  }

  @override
  String get chat_userBlocked => 'تم حظر المستخدم بنجاح';

  @override
  String get chat_userUnblocked => 'تم إلغاء حظر المستخدم بنجاح';

  @override
  String get chat_videoDownloaded => 'تم تنزيل الفيديو بنجاح';

  @override
  String get chat_videoThumbnailFailed => 'فشل إنشاء الصورة المصغرة للفيديو';

  @override
  String get chat_videoUnavailable => 'هذا الفيديو لم يعد متاحاً';

  @override
  String get chat_videoUploadFailed => 'فشل تحميل الفيديو';

  @override
  String get chat_voicePlayFailed => 'تعذر تشغيل الرسالة الصوتية';

  @override
  String get chat_voiceUploadFailed =>
      'فشل تحميل الرسالة الصوتية. يرجى المحاولة مرة أخرى.';

  @override
  String get chat_youBlockedContact => 'لقد حظرت جهة الاتصال هذه';

  @override
  String get common_add => 'إضافة';

  @override
  String get common_allow => 'السماح';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_comingSoon => 'قريباً';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_continue => 'متابعة';

  @override
  String get common_copied => 'تم النسخ';

  @override
  String get common_copy => 'نسخ';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      one: 'منذ يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => 'حذف';

  @override
  String get common_dismiss => 'تجاهل';

  @override
  String get common_done => 'تم';

  @override
  String get common_edit => 'تعديل';

  @override
  String get common_error => 'خطأ';

  @override
  String get common_exit => 'خروج';

  @override
  String get common_gotIt => 'فهمت';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      one: 'منذ ساعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'الآن';

  @override
  String common_lastSeen(String time) {
    return 'آخر ظهور: $time';
  }

  @override
  String get common_loading => 'جارٍ التحميل…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعضاء',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      one: 'منذ دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get common_next => 'التالي';

  @override
  String get common_no => 'لا';

  @override
  String get common_noData => 'لم يتم العثور على بيانات';

  @override
  String get common_noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get common_notNow => 'ليس الآن';

  @override
  String get common_offline => 'غير متصل';

  @override
  String get common_ok => 'موافق';

  @override
  String get common_online => 'متصل';

  @override
  String get common_open => 'فتح';

  @override
  String get common_permissionDenied => 'تم رفض الإذن';

  @override
  String get common_remove => 'إزالة';

  @override
  String get common_retry => 'إعادة المحاولة';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_search => 'بحث';

  @override
  String get common_send => 'إرسال';

  @override
  String get common_settings => 'الإعدادات';

  @override
  String get common_share => 'مشاركة';

  @override
  String get common_somethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get common_submit => 'إرسال';

  @override
  String get common_success => 'نجاح';

  @override
  String get common_today => 'اليوم';

  @override
  String common_todayAt(String time) {
    return 'اليوم، $time';
  }

  @override
  String get common_tryAgain => 'حاول مرة أخرى';

  @override
  String get common_viewAll => 'عرض الكل';

  @override
  String get common_yes => 'نعم';

  @override
  String get common_yesterday => 'أمس';

  @override
  String get common_you => 'أنت';

  @override
  String get dialog_allowLocationAccess => 'السماح بالوصول إلى الموقع';

  @override
  String get dialog_anErrorOccurred => 'حدث خطأ!';

  @override
  String get dialog_important => 'هام!';

  @override
  String get dialog_locationPermissionRequired => 'إذن الموقع مطلوب';

  @override
  String get dialog_locationPurposeBody =>
      'لتحسين كفاءة الخدمة، يطلب تطبيقنا إذناً للوصول إلى موقعك لحفظه. يتيح ذلك للأعضاء الانتقال بدقة إلى موقع العمل المحدد لك.';

  @override
  String get dialog_locationSettingsAndroid =>
      'بدون الوصول إلى الموقع، لن نتمكن من تحديد موقعك الحالي. يرجى الضغط على \"الإعدادات\"، ثم \"الأذونات\"، والسماح بالوصول إلى الموقع.';

  @override
  String get dialog_locationSettingsIos =>
      'يتطلب هذا التطبيق الوصول إلى موقعك لتقديم الخدمات القائمة على الموقع. يرجى الانتقال إلى \"الإعدادات\" وتفعيل أذونات الموقع.';

  @override
  String get dialog_loggedInElsewhere => 'تم تسجيل الدخول من جهاز آخر.';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      'تم تسجيل الدخول من جهاز آخر. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get dialog_logoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get dialog_selectAllowAllTheTime =>
      'في النافذة المنبثقة التالية، يرجى تحديد\n\'السماح طوال الوقت\'.';

  @override
  String get dialog_sessionExpiredTitle => 'انتهت الجلسة';

  @override
  String get editProfile_fullNameLabel => 'الاسم الكامل';

  @override
  String get editProfile_personalInfo => 'المعلومات الشخصية';

  @override
  String get editProfile_phoneLabel => 'رقم الهاتف';

  @override
  String get editProfile_saveButton => 'حفظ التغييرات';

  @override
  String get editProfile_tapPhotoHint => 'اضغط على الصورة للتغيير';

  @override
  String get editProfile_title => 'تعديل الملف الشخصي';

  @override
  String get forceUpdate_currentInstalled => 'الإصدار المثبت حالياً';

  @override
  String get forceUpdate_defaultMessage =>
      'يتوفر إصدار جديد من FG Tracker. يرجى التحديث للمتابعة.';

  @override
  String get forceUpdate_defaultTitle => 'التحديث مطلوب';

  @override
  String get forceUpdate_fallbackMessage =>
      'يتوفر إصدار جديد من FG Tracker يحتوي على تحسينات مهمة. يرجى التحديث لمتابعة استخدام التطبيق.';

  @override
  String get forceUpdate_footer => 'التحديث إلزامي لمتابعة استخدام FG Tracker';

  @override
  String get forceUpdate_requiredVersion => 'الإصدار المطلوب';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return 'تحديث على $storeName';
  }

  @override
  String get groupDialog_audioCall => 'مكالمة صوتية';

  @override
  String get groupDialog_audioCallSubtitle => 'بدء محادثة صوتية';

  @override
  String get groupDialog_call => 'اتصال';

  @override
  String get groupDialog_chat => 'دردشة';

  @override
  String get groupDialog_codeEmpty => 'لا يمكن أن يكون رمز المجموعة فارغاً';

  @override
  String get groupDialog_codeLabel => 'رمز المجموعة';

  @override
  String get groupDialog_createButton => 'إنشاء مجموعة';

  @override
  String get groupDialog_createTitle => 'إنشاء مجموعة جديدة';

  @override
  String get groupDialog_descHint => 'أدخل وصف المجموعة';

  @override
  String get groupDialog_descLabel => 'وصف المجموعة (اختياري)';

  @override
  String groupDialog_distance(String distance) {
    return 'المسافة: $distance';
  }

  @override
  String get groupDialog_enterCodeManually => 'إدخال رمز المجموعة يدوياً';

  @override
  String get groupDialog_enterCodeTitle => 'أدخل رمز المجموعة';

  @override
  String get groupDialog_fillDetails => 'املأ التفاصيل أدناه';

  @override
  String get groupDialog_getDirections => 'الحصول على الاتجاهات';

  @override
  String get groupDialog_join => 'الانضمام إلى المجموعة';

  @override
  String groupDialog_lastSeen(String time) {
    return 'آخر ظهور: $time';
  }

  @override
  String get groupDialog_locationHidden => 'الموقع مخفي';

  @override
  String get groupDialog_locationUnavailable => 'الموقع غير متاح';

  @override
  String get groupDialog_member => 'عضو';

  @override
  String get groupDialog_memberInfo => 'معلومات العضو';

  @override
  String get groupDialog_nameHint => 'أدخل اسم المجموعة';

  @override
  String get groupDialog_nameLabel => 'اسم المجموعة';

  @override
  String get groupDialog_noQrInImage =>
      'لم يتم العثور على رمز QR في الصورة المحددة.';

  @override
  String get groupDialog_noValidQr => 'لم يتم العثور على رمز QR صالح.';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'خطأ في فك شفرة QR من المعرض: $error';
  }

  @override
  String get groupDialog_scanCamera => 'المسح بالكاميرا';

  @override
  String get groupDialog_selectCallType => 'تحديد نوع المكالمة';

  @override
  String get groupDialog_update => 'تحديث';

  @override
  String get groupDialog_updateTitle => 'تحديث المجموعة';

  @override
  String get groupDialog_uploadGallery => 'تحميل من المعرض';

  @override
  String get groupDialog_videoCall => 'مكالمة فيديو';

  @override
  String get groupDialog_videoCallSubtitle => 'بدء محادثة فيديو';

  @override
  String get groupDialog_yourLocation => 'موقعك الحالي';

  @override
  String get groupInfo_active => 'نشط';

  @override
  String get groupInfo_admin => 'مشرف';

  @override
  String get groupInfo_allGroups => 'جميع المجموعات';

  @override
  String get groupInfo_allGroupsSubtitle => 'ابقَ على اتصال مع فرقك';

  @override
  String get groupInfo_areYouSure => 'هل أنت متأكد؟';

  @override
  String get groupInfo_audioCall => 'مكالمة صوتية';

  @override
  String get groupInfo_clearChatConfirm => 'حذف جميع الرسائل من هذا الجهاز؟';

  @override
  String get groupInfo_createdBy => 'تم الإنشاء بواسطة';

  @override
  String get groupInfo_detailsNotFound => 'لم يتم العثور على تفاصيل المجموعة';

  @override
  String get groupInfo_exitGroup => 'الخروج من المجموعة';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return 'هل أنت متأكد من الخروج من \"$groupName\"؟';
  }

  @override
  String get groupInfo_exitGroupQuestion => 'هل تريد الخروج من هذه المجموعة؟';

  @override
  String get groupInfo_group => 'المجموعة';

  @override
  String get groupInfo_groupAdmin => 'مشرف المجموعة';

  @override
  String get groupInfo_groupCallFailed =>
      'تعذر بدء المكالمة الجماعية. يرجى المحاولة مرة أخرى.';

  @override
  String get groupInfo_groupCodeCopied => 'تم نسخ رمز المجموعة!';

  @override
  String get groupInfo_groupSettings => 'إعدادات المجموعة';

  @override
  String get groupInfo_groupSettingsSubtitle =>
      'تعديل معلومات المجموعة والخصوصية والمزيد';

  @override
  String get groupInfo_inactive => 'غير نشط';

  @override
  String get groupInfo_inviteCopied => 'تم نسخ نص الدعوة';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'انضم إلى مجموعتي \"$groupName\" على FG Tracker';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'انضم إلى مجموعتي \"$groupName\" على FG Tracker. الرمز: $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'دعوة عبر الرابط';

  @override
  String get groupInfo_mediaLinksDocs => 'الوسائط والروابط والمستندات';

  @override
  String get groupInfo_member => 'عضو';

  @override
  String get groupInfo_members => 'الأعضاء';

  @override
  String get groupInfo_messageAction => 'رسالة';

  @override
  String groupInfo_nameYou(String name) {
    return '$name (أنت)';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return 'لم يتم العثور على مجموعة مطابقة لـ \'$query\'';
  }

  @override
  String get groupInfo_noGroupsYet =>
      'لم تنضم أو تنشئ أي مجموعات بعد.\nابدأ الاستكشاف الآن!';

  @override
  String get groupInfo_noMediaYet => 'لم تتم مشاركة أي وسائط بعد';

  @override
  String get groupInfo_removeFromGroup => 'إزالة من المجموعة';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return 'هل أنت متأكد من إزالة $name من المجموعة؟';
  }

  @override
  String get groupInfo_searchGroupsHint => 'بحث في المجموعات...';

  @override
  String get groupInfo_showLess => 'عرض أقل';

  @override
  String get groupInfo_teamCode => 'رمز الفريق';

  @override
  String groupInfo_totalCount(int count) {
    return '$count إجمالي';
  }

  @override
  String get groupInfo_unknownGroup => 'مجموعة غير معروفة';

  @override
  String get groupInfo_unnamedGroup => 'مجموعة بدون اسم';

  @override
  String get groupInfo_videoCall => 'مكالمة فيديو';

  @override
  String get groupInfo_viewAllMembers => 'عرض جميع الأعضاء';

  @override
  String get group_activatedSuccess => 'تم تنشيط المجموعة بنجاح';

  @override
  String get group_addMember => 'إضافة عضو';

  @override
  String get group_alignQr => 'وجّه رمز QR داخل الإطار';

  @override
  String get group_areYouSure => 'هل أنت متأكد؟';

  @override
  String get group_chatWithMembers => 'الدردشة مع أعضاء المجموعة';

  @override
  String get group_codeCopied => 'تم نسخ رمز المجموعة!';

  @override
  String group_codeShareInfo(String code) {
    return 'رمز المجموعة: $code — شاركه لينضم الآخرون';
  }

  @override
  String get group_copyCode => 'نسخ الرمز';

  @override
  String get group_created => 'تم الإنشاء';

  @override
  String get group_createdJustNow => 'تم الإنشاء الآن';

  @override
  String get group_deactivatedSuccess => 'تم إلغاء تنشيط المجموعة بنجاح';

  @override
  String get group_defaultName => 'المجموعة';

  @override
  String get group_deleteGroup => 'حذف المجموعة';

  @override
  String get group_deleteGroupConfirm => 'هل تريد حذف هذه المجموعة؟';

  @override
  String get group_deletedSuccess => 'تم حذف المجموعة بنجاح';

  @override
  String get group_download => 'تنزيل';

  @override
  String get group_downloadChannelDescription =>
      'إشعار عند اكتمال تنزيل رمز QR';

  @override
  String get group_downloadChannelName => 'إشعارات التنزيل';

  @override
  String get group_enableLocationToJoin =>
      'يرجى تفعيل خدمات الموقع للانضمام إلى المجموعة.';

  @override
  String get group_exitGroup => 'الخروج من المجموعة';

  @override
  String get group_exitGroupConfirm => 'هل تريد الخروج من هذه المجموعة؟';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return 'هل أنت متأكد من الخروج من \"$groupName\"؟ ستحتاج إلى رمز المجموعة للانضمام مجددًا.';
  }

  @override
  String get group_exitedSuccess => 'تم الخروج من المجموعة بنجاح';

  @override
  String get group_goToGroups => 'الانتقال إلى المجموعات ←';

  @override
  String get group_groupMessage => 'رسالة المجموعة';

  @override
  String get group_invalidResponseFormat => 'تنسيق غير صالح';

  @override
  String get group_joinedJustNow => 'انضم الآن';

  @override
  String get group_joinedRecently => 'مؤخراً';

  @override
  String get group_leftJustNow => 'غادر الآن';

  @override
  String get group_locationNoLongerShared =>
      'لم يعد موقعك الجغرافي مشتركًا مع هذه المجموعة';

  @override
  String get group_locationPermissionToJoin =>
      'إذن الموقع الجغرافي مطلوب للانضمام إلى مجموعة.';

  @override
  String get group_locationShared =>
      'موقعك الجغرافي قيد المشاركة مع هذه المجموعة';

  @override
  String get group_memberFallbackName => 'عضو';

  @override
  String group_membersMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو · $when',
      many: '$count عضوًا · $when',
      few: '$count أعضاء · $when',
      two: 'عضوان · $when',
      one: 'عضو واحد · $when',
    );
    return '$_temp0';
  }

  @override
  String get group_noContactsFound => 'لم يتم العثور على جهات اتصال';

  @override
  String get group_noGroupCode => 'لا يوجد رمز مجموعة متاح';

  @override
  String get group_noNewMessages => 'لن تتلقى رسائل جديدة من هذه المجموعة';

  @override
  String get group_noNumber => 'لا يوجد رقم';

  @override
  String get group_openGroup => 'فتح المجموعة ←';

  @override
  String get group_other => 'أخرى';

  @override
  String get group_qrSavedBody => 'اضغط لفتح رمز QR الخاص بك';

  @override
  String get group_qrSavedTitle => 'تم حفظ رمز QR';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 رمز المجموعة: $groupCode\n\nانضم إلى مجموعتي فورًا باستخدام رمز QR أو الرمز أعلاه.\n\n📲 قم بتنزيل التطبيق للبقاء على اتصال:\n$appLink';
  }

  @override
  String get group_scanToJoin => 'امسح رمز QR ضوئيًا للانضمام إلى المجموعة';

  @override
  String get group_searchMemberHint => 'البحث عن عضو...';

  @override
  String get group_shareCodeInfo => 'شارك رمز المجموعة لكي ينضم الآخرون';

  @override
  String get group_shareQr => 'مشاركة رمز QR';

  @override
  String get group_shareQrToInvite => 'شارك رمز QR لدعوة الأعضاء';

  @override
  String get group_sheetCreatedSubtitle =>
      'مجموعتك جاهزة. شارك الرمز لينضم الأعضاء.';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name، مجموعتك جاهزة. شارك الرمز لينضم بقية الأعضاء.';
  }

  @override
  String get group_sheetCreatedTitle => 'تم إنشاء المجموعة!';

  @override
  String get group_sheetJoinedSubtitle =>
      'أهلاً بك، لقد أصبحت الآن عضواً في هذه المجموعة.';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return 'أهلاً بك $name، لقد أصبحت الآن عضواً في هذه المجموعة.';
  }

  @override
  String get group_sheetJoinedTitle => 'تم الانضمام بنجاح!';

  @override
  String get group_sheetLeftSubtitle =>
      'لم تعد عضوًا في هذه المجموعة بعد الآن.';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name، لم تعد عضوًا في هذه المجموعة.';
  }

  @override
  String get group_sheetLeftTitle => 'لقد غادرت المجموعة';

  @override
  String get group_showQrCode => 'عرض رمز QR';

  @override
  String get group_startConversation => 'لا تتردد في بدء محادثة';

  @override
  String get group_statusUpdateFailed => 'فشل تحديث حالة المجموعة';

  @override
  String get group_teamCode => 'رمز الفريق';

  @override
  String get group_teamCodeLabel => 'رمز الفريق: ';

  @override
  String get group_track => 'تتبع';

  @override
  String get group_unnamedMember => 'عضو بدون اسم';

  @override
  String get group_unnamedTrip => 'رحلة بدون اسم';

  @override
  String get group_updateGroupConfirm =>
      'هل أنت متأكد من رغبتك في تحديث تفاصيل المجموعة؟';

  @override
  String get group_updateGroupTitle => 'تحديث المجموعة';

  @override
  String get group_youAreAdmin => 'أنت مسؤول (مشرف) هذه المجموعة';

  @override
  String get home_actionAllContacts => 'جميع جهات الاتصال';

  @override
  String get home_actionAudioVideoCall => 'مكالمة صوت / فيديو';

  @override
  String get home_actionChatting => 'الدردشة';

  @override
  String get home_actionSafeZone => 'المنطقة الآمنة';

  @override
  String get home_actionTracking => 'التتبع';

  @override
  String get home_actionWalkieTalkie => 'اللاسلكي (Walkie Talkie)';

  @override
  String get home_active => 'نشط';

  @override
  String get home_activeSessions => 'الجلسات النشطة';

  @override
  String home_activeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جلسة نشطة',
      many: '$count جلسة نشطة',
      few: '$count جلسات نشطة',
      two: 'جلستان نشطتان',
      one: 'جلسة نشطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get home_allMembers => 'جميع الأعضاء';

  @override
  String get home_createGroup => 'إنشاء مجموعة';

  @override
  String get home_createGroupSubtitle => 'إنشاء مجموعة جديدة';

  @override
  String get home_goodToSeeYou => 'سعداء برؤيتك مرة أخرى 👋';

  @override
  String home_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String home_helloName(String name) {
    return 'مرحباً $name';
  }

  @override
  String get home_inactive => 'غير نشط';

  @override
  String get home_joinGroup => 'الانضمام إلى مجموعة';

  @override
  String get home_joinGroupSubtitle => 'الانضمام لمجموعة حالية';

  @override
  String home_lastSeen(String time) {
    return 'آخر ظهور $time';
  }

  @override
  String get home_newThisMonth => 'جديد هذا الشهر';

  @override
  String get home_noActivePrivateSessions => 'لا توجد جلسات خاصة نشطة';

  @override
  String get home_noGroupsAvailable => 'لا توجد مجموعات متاحة';

  @override
  String get home_noGroupsFound => 'لم يتم العثور على مجموعات';

  @override
  String get home_noMembersFound => 'لم يتم العثور على أعضاء';

  @override
  String home_noMembersMatch(String query) {
    return 'لا يوجد أعضاء يطابقون \'$query\'';
  }

  @override
  String get home_noMembersOnline => 'لا يوجد أعضاء متصلون حالياً';

  @override
  String get home_noNameGroup => 'مجموعة بدون اسم';

  @override
  String get home_noRecentlyActiveMembers => 'لا يوجد أعضاء نشطون مؤخرًا';

  @override
  String get home_onlineNow => 'متصل الآن';

  @override
  String get home_peopleOnline => 'الأشخاص المتصلون';

  @override
  String get home_peopleOnlineSubtitle =>
      'هؤلاء الأعضاء نشطون في التطبيق حالياً ومتاحون للتواصل.';

  @override
  String get home_privateMode => 'الوضع الخاص (المخفي)';

  @override
  String get home_privateModeIsOn => 'الوضع الخاص مفعّل';

  @override
  String get home_privateModeOffHint =>
      'عند إيقاف الوضع الخاص، يمكن للآخرين رؤية موقعك.';

  @override
  String get home_privateModeOnHint =>
      'عند تفعيل الوضع الخاص، لا يمكن للآخرين رؤية موقعك.';

  @override
  String get home_quickActionsSubtitle => 'كل ما تحتاجه بلمسة واحدة.';

  @override
  String get home_quickActionsTitle => 'إجراءات سريعة';

  @override
  String get home_recentlyOnline => 'متصل مؤخرًا';

  @override
  String get home_searchGroupsHint => 'البحث في المجموعات...';

  @override
  String get home_searchMembersHint => 'البحث عن أعضاء...';

  @override
  String get home_showLess => 'عرض أقل';

  @override
  String get home_sortNameAsc => 'ترتيب: الاسم (أ-ي)';

  @override
  String get home_sortNameDesc => 'ترتيب: الاسم (ي-أ)';

  @override
  String home_startedAt(String time) {
    return 'بدأ في $time';
  }

  @override
  String get home_statGroups => 'المجموعات';

  @override
  String get home_statMembers => 'الأعضاء';

  @override
  String get home_statNow => 'الآن';

  @override
  String get home_statTotal => 'الإجمالي';

  @override
  String get home_totalMembers => 'إجمالي الأعضاء';

  @override
  String home_totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو إجمالي',
      many: '$count عضوًا إجمالياً',
      few: '$count أعضاء إجمالاً',
      two: 'عضوان',
      one: 'عضو إجمالي واحد',
    );
    return '$_temp0';
  }

  @override
  String get home_unableToFetchGroups => 'تعذر جلب المجموعات';

  @override
  String get home_unknownMember => 'عضو غير معروف';

  @override
  String get home_upgradeSubtitle => 'افتح ميزات متقدمة لفريقك';

  @override
  String get home_upgradeToPremium => 'الترقية إلى بريميوم';

  @override
  String get home_viewPlans => 'عرض الخطط';

  @override
  String get home_walkieExpired => 'منتهي الصلاحية';

  @override
  String get home_walkieOneHourFree => 'ساعة مجانية';

  @override
  String get home_walkieRenew => 'تجديد';

  @override
  String get home_walkieSubscribed => 'مشترك';

  @override
  String get home_youAreInvisible => 'أنت غير مرئي الآن';

  @override
  String get home_youAreVisible => 'أنت مرئي الآن';

  @override
  String get http_networkError => 'حدث خطأ. يرجى المحاولة مرة أخرى!';

  @override
  String get http_sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get http_unexpectedError =>
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get imagePicker_camera => 'الكاميرا';

  @override
  String get imagePicker_cancel => 'إلغاء';

  @override
  String get imagePicker_cropTitle => 'قص الصورة';

  @override
  String get imagePicker_gallery => 'المعرض';

  @override
  String get imagePicker_title => 'اختر خياراً';

  @override
  String get intro_realTimeTrackingSubtitle =>
      'شاهد المواقع المباشرة للأصدقاء أو العائلة أو أعضاء الفريق على الخريطة فورًا.';

  @override
  String get intro_realTimeTrackingTitle => 'التتبع في الوقت الفعلي';

  @override
  String get intro_secureSubtitle =>
      'شارك موقعك المباشر مع جهات الاتصال\nالمحددة بأمان وخصوصية تامة.';

  @override
  String get intro_secureTitle => 'آمن وسهل';

  @override
  String get intro_skip => 'تخطي';

  @override
  String get intro_walkieSubtitle =>
      'لا توجد شبكة؟ لا مشكلة. ابقَ\nعلى اتصال في أي مكان.';

  @override
  String get intro_walkieTitle => 'ميزة\nاللاسلكي (Walkie-Talkie)';

  @override
  String get media_cannotOpen => 'تعذر الفتح';

  @override
  String get media_documentNotFound => 'لم يتم العثور على المستند';

  @override
  String get media_invalidLink => 'رابط غير صالح';

  @override
  String get media_noDocuments => 'لم يتم العثور على مستندات';

  @override
  String get media_noLinks => 'لم يتم العثور على روابط';

  @override
  String get media_noMedia => 'لم يتم العثور على وسائط';

  @override
  String get media_tabDocs => 'المستندات';

  @override
  String media_tabDocsCount(int count) {
    return 'المستندات ($count)';
  }

  @override
  String get media_tabLinks => 'الروابط';

  @override
  String media_tabLinksCount(int count) {
    return 'الروابط ($count)';
  }

  @override
  String get media_tabMedia => 'الوسائط';

  @override
  String media_tabMediaCount(int count) {
    return 'الوسائط ($count)';
  }

  @override
  String get media_title => 'الوسائط والروابط والمستندات';

  @override
  String get media_videoNotFound => 'لم يتم العثور على الفيديو';

  @override
  String get menu_contactUsSubtitle => 'تعرف أكثر عنا';

  @override
  String get menu_editProfile => 'تعديل الملف الشخصي';

  @override
  String get menu_editProfileSubtitle => 'تحديث معلوماتك';

  @override
  String get menu_followUsOn => 'تابعنا على';

  @override
  String get menu_logOut => 'تسجيل الخروج';

  @override
  String get menu_logOutConfirmMessage => 'هل تريد حقًا تسجيل الخروج؟';

  @override
  String get menu_logOutSubtitle => 'تسجيل الخروج من التطبيق';

  @override
  String get menu_profileImageUpdateFailed => 'فشل تحديث صورة الملف الشخصي';

  @override
  String get menu_profileImageUpdated => 'تم تحديث صورة الملف الشخصي بنجاح';

  @override
  String get notif_accept => 'قبول';

  @override
  String get notif_channelHighImportanceDesc =>
      'القناة الافتراضية للإشعارات عالية الأهمية';

  @override
  String get notif_channelHighImportanceName => 'إشعارات عالية الأهمية';

  @override
  String get notif_channelWalkieAudioDesc =>
      'يحافظ على الاتصال الصوتي المباشر والتقاط الميكروفون في الخلفية';

  @override
  String get notif_channelWalkieAudioName => 'صوت اللاسلكي المباشر';

  @override
  String get notif_channelWalkieCallsDesc => 'مكالمات اللاسلكي الواردة';

  @override
  String get notif_channelWalkieCallsName => 'مكالمات اللاسلكي';

  @override
  String get notif_channelWalkieDesc =>
      'مكالمات اللاسلكي الجماعية وتحديثات التحدث';

  @override
  String get notif_channelWalkieLiveDesc => 'إشعارات قنوات اللاسلكي النشطة';

  @override
  String get notif_channelWalkieLiveName => 'قنوات اللاسلكي المباشرة';

  @override
  String get notif_channelWalkieName => 'لاسلكي';

  @override
  String notif_connectedIn(String group) {
    return 'متصل في $group • بث صوتي مباشر';
  }

  @override
  String get notif_goToWalkie => 'الانتقال إلى شاشة اللاسلكي';

  @override
  String get notif_incomingWalkieTitle => 'مكالمة لاسلكية واردة';

  @override
  String notif_isTalking(String name) {
    return '$name يتحدث الآن';
  }

  @override
  String get notif_leave => 'مغادرة';

  @override
  String get notif_openWalkie => 'فتح اللاسلكي';

  @override
  String get notif_reject => 'رفض';

  @override
  String notif_stoppedTalking(String name) {
    return '$name توقف عن التحدث';
  }

  @override
  String get notif_walkieActiveConversation => 'محادثة لاسلكية نشطة';

  @override
  String get notif_walkieActiveTitle => 'اللاسلكي نشط';

  @override
  String notif_wantsToTalk(String name) {
    return '$name يريد التحدث';
  }

  @override
  String get notifications_clearAll => 'مسح جميع الإشعارات';

  @override
  String get notifications_clearedSuccess => 'تم مسح جميع الإشعارات بنجاح';

  @override
  String get notifications_emptySubtitle =>
      'ليس لديك أي تنبيهات جديدة في الوقت الحالي.';

  @override
  String get notifications_emptyTitle => 'لا توجد إشعارات حتى الآن';

  @override
  String get notifications_filterAll => 'الكل';

  @override
  String get notifications_filterCalls => 'المكالمات';

  @override
  String get notifications_filterChats => 'الدردشات';

  @override
  String get notifications_filterUnread => 'غير مقروءة';

  @override
  String get notifications_loadingDetails => 'جاري تحميل تفاصيل الإشعار';

  @override
  String get notifications_recentCalls => 'المكالمات الأخيرة';

  @override
  String get notifications_title => 'الإشعارات';

  @override
  String get otpCharges_chargedNotice =>
      'من الآن فصاعدًا، يتم فرض رسوم على رموز التحقق لرقمك. إعادة إرسال الرمز مجانية (حتى 3 محاولات).';

  @override
  String get otpCharges_chargesApplyTo => 'تطبق الرسوم على';

  @override
  String get otpCharges_eachOtpCosts => 'تكلفة كل رمز تحقق';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'تكلفة كل رمز تحقق $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'تكلفة كل رمز $amount، بما في ذلك $percent٪ ضريبة القيمة المضافة';
  }

  @override
  String get otpCharges_firstLoginFree => 'كان تسجيل الدخول الأول مجانياً.';

  @override
  String get otpCharges_freeBody =>
      'لا توجد رسوم على رموز التحقق المرسلة لهذا الرقم.';

  @override
  String get otpCharges_freeTitle => 'رمز التحقق (OTP) مجاني لرقمك';

  @override
  String otpCharges_gstTitle(String percent) {
    return 'ضريبة القيمة المضافة ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return 'شامل $percent٪ ضريبة القيمة المضافة (GST/VAT)';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return 'شامل $percent٪ ضريبة';
  }

  @override
  String get otpCharges_noInternet =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مجدداً.';

  @override
  String get otpCharges_otpCharge => 'رسوم رمز التحقق';

  @override
  String otpCharges_pay(String amount) {
    return 'دفع $amount';
  }

  @override
  String get otpCharges_paymentCancelled =>
      'تم إلغاء الدفع. قمت بإلغاء العملية ولم يتم خصم أي مبالغ.';

  @override
  String get otpCharges_paymentFailed =>
      'فشلت عملية الدفع. إذا تم خصم أي مبلغ، فسيتم استرداده خلال 5-7 أيام عمل.';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return 'الدفع معلق مؤقتاً ($amount)';
  }

  @override
  String get otpCharges_paymentReceived =>
      'تم استلام الدفعة. قد يستغرق وصول رمز التحقق لحظات قليلة.';

  @override
  String get otpCharges_paymentStartFailed =>
      'تعذر بدء عملية الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get otpCharges_paymentsPaused =>
      'تم إيقاف مدفوعات OTP مؤقتًا بواسطة المسؤول. اضغط أدناه للتفاصيل.';

  @override
  String get otpCharges_paymentsUnavailable =>
      'مدفوعات OTP غير متوفرة حالياً. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get otpCharges_sessionExpired => 'انتهت الجلسة. يرجى البدء من جديد.';

  @override
  String get otpCharges_title => 'رسوم رمز التحقق (OTP)';

  @override
  String get otpCharges_totalPerOtp => 'الإجمالي لكل رمز';

  @override
  String get otpCharges_tryAgainMoment =>
      'حدث خطأ ما. يرجى المحاولة مرة أخرى بعد لحظات.';

  @override
  String get otpCharges_unknownBody =>
      'رموز الدخول للأرقام الهندية مجانية. بالنسبة للدول الأخرى، يظهر السعر الدقيق قبل الدفع عند تسجيل الدخول.';

  @override
  String get otpCharges_unknownTitle => 'تعتمد رسوم رمز التحقق على بلدك';

  @override
  String get otpCharges_updateApp =>
      'تعذر بدء الدفع. يرجى تحديث التطبيق ثم المحاولة مجددًا.';

  @override
  String otpCharges_vatTitle(String percent) {
    return 'ضريبة القيمة المضافة ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      'فشل التحقق من الدفع. إذا تم خصم المبلغ، فسيتم استرداده خلال 5-7 أيام عمل.';

  @override
  String get otpCharges_yourNumber => 'رقم هاتفك';

  @override
  String get package_noPackages => 'لا توجد باقات متاحة حالياً.';

  @override
  String package_plansComingSoon(String title) {
    return 'خطط $title قادمة قريباً';
  }

  @override
  String get package_subtitle => 'اختر ميزة أو خدمة لمعرفة الباقات المتوفرة';

  @override
  String get package_title => 'الباقات والأسعار';

  @override
  String get package_viewPlans => 'عرض الخطط';

  @override
  String get perm_alwaysLocationBody =>
      'لتتبع مجموعتك في الوقت الفعلي وفي الخلفية، يرجى ضبط الوصول إلى الموقع على \'السماح طوال الوقت\' في إعدادات التطبيق.';

  @override
  String get perm_alwaysLocationTitle => 'تفعيل إذن الموقع \'دائماً\'';

  @override
  String get perm_chooseAllowAllTime =>
      'يرجى اختيار \'السماح طوال الوقت\' في النافذة المنبثقة التالية.';

  @override
  String get perm_collectsLocationBody =>
      'يجمع هذا التطبيق بيانات الموقع لضمان سير العمل بكفاءة وتوفير تتبع فعال، حتى عند إغلاق التطبيق أو عدم استخدامه.';

  @override
  String get perm_enableDeviceGpsBody =>
      'يرجى تفعيل نظام GPS في جهازك (موقع Google).';

  @override
  String get perm_enableGpsTitle => 'تفعيل نظام تحديد المواقع (GPS)';

  @override
  String get perm_exitBody => 'هل تريد الخروج من التطبيق؟';

  @override
  String get perm_exitTitle => 'هل أنت متأكد؟';

  @override
  String get perm_gpsRequiredBody =>
      'يلزم تفعيل نظام GPS لتتبع مجموعتك في الوقت الفعلي.';

  @override
  String get perm_locationTitle => 'إذن الموقع';

  @override
  String get perm_trackingPermissionBody =>
      'يحتاج تطبيق FG Partner إلى إذنك لتتبع الموقع أثناء تسجيل دخولك.';

  @override
  String get permission_allowAllTheTime => 'السماح طوال الوقت';

  @override
  String get permission_allowLocation => 'السماح بالموقع';

  @override
  String get permission_allowLocationFirst =>
      'يرجى السماح بإذن الموقع الجغرافي أولاً.';

  @override
  String permission_allowNamed(String permission) {
    return 'السماح بإذن $permission';
  }

  @override
  String get permission_allowNotifications => 'السماح بالإشعارات';

  @override
  String get permission_appPermissionsSubtitle =>
      'مراجعة الأذونات المطلوبة لتشغيل الميزات.';

  @override
  String get permission_appPermissionsTitle => 'أذونات التطبيق';

  @override
  String get permission_badgeGranted => 'ممنوح';

  @override
  String get permission_badgeOptional => 'اختياري';

  @override
  String get permission_badgeRecommended => 'موصى به';

  @override
  String get permission_badgeRequired => 'إلزامي';

  @override
  String get permission_camera => 'الكاميرا';

  @override
  String get permission_cameraDescription =>
      'تستخدمها ميزات التطبيق لالتقاط الصور ومقاطع الفيديو.';

  @override
  String get permission_cameraSettingsMessage =>
      'إذن الكاميرا مطلوب لالتقاط الصور ومقاطع الفيديو. يرجى تفعيله من إعدادات التطبيق.';

  @override
  String get permission_cameraWhy =>
      'يتيح لك التقاط الصور ومقاطع الفيديو للملف الشخصي والدردشة والميزات الأخرى.';

  @override
  String get permission_contacts => 'جهات الاتصال';

  @override
  String get permission_contactsDescription =>
      'يُستخدم لاكتشاف جهات الاتصال أو تحديدها لميزات التطبيق.';

  @override
  String get permission_contactsSettingsMessage =>
      'إذن جهات الاتصال مطلوب للبحث عن جهات الاتصال واختيارها. يرجى تفعيله من الإعدادات.';

  @override
  String get permission_contactsWhy =>
      'يساعدك في العثور على جهات الاتصال واختيارها بسهولة داخل التطبيق.';

  @override
  String get permission_gateCheckFailed =>
      'تعذر التحقق من أذوناتك. يرجى المحاولة مرة أخرى.';

  @override
  String get permission_gateSubtitle =>
      'يحتاج FG Tracker إلى هذه الأذونات لتلقي المكالمات والتنبيهات وتشغيل ميزات الحضور والتتبع المباشر والمنطقة الآمنة.';

  @override
  String get permission_gateTitle => 'الأذونات المطلوبة';

  @override
  String get permission_genericSettingsMessage =>
      'هذا الإذن مطلوب. يرجى تفعيله من إعدادات التطبيق.';

  @override
  String get permission_iosLocationServicesOff =>
      'خدمات الموقع مغلقة. افتح الإعدادات ← الخصوصية والأمان ← خدمات الموقع وقم بتشغيلها.';

  @override
  String get permission_location => 'الموقع الجغرافي';

  @override
  String get permission_locationAndNotificationRequired =>
      'أذونات الموقع والإشعارات مطلوبة لمتابعة الاستخدام.';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      'الموقع الجغرافي والإشعارات مطلوبة للمتابعة.';

  @override
  String get permission_locationDescription =>
      'مطلوب لتسجيل الحضور والتتبع المباشر والمنطقة الآمنة، حتى عند تشغيل التطبيق في الخلفية.';

  @override
  String get permission_locationRequiredToContinue =>
      'إذن الموقع مطلوب للمتابعة.';

  @override
  String get permission_locationStatusApproximate =>
      'تم السماح بالموقع التقريبي فقط. الموقع الدقيق مطلوب.';

  @override
  String get permission_locationStatusBlocked =>
      'تم حظر إذن الموقع. يرجى تفعيله من الإعدادات.';

  @override
  String get permission_locationStatusDone =>
      'مسموح دائمًا · دقيق · GPS قيد التشغيل';

  @override
  String get permission_locationStatusGpsOff =>
      'خدمة تحديد الموقع (GPS) مغلقة على الجهاز.';

  @override
  String get permission_locationStatusNeedAlways =>
      'خيار \"السماح طوال الوقت\" مطلوب.';

  @override
  String get permission_locationStatusNotAllowed =>
      'إذن الموقع الجغرافي غير ممنوح بعد.';

  @override
  String get permission_locationWhyExtra =>
      'يرجى اختيار \"السماح طوال الوقت\" وإبقاء الموقع الدقيق قيد التشغيل.';

  @override
  String get permission_logout => 'تسجيل الخروج';

  @override
  String get permission_microphone => 'الميكروفون / الصوت';

  @override
  String get permission_microphoneDescription =>
      'يُستخدم للمكالمات الصوتية ورسائل الصوت وميزة اللاسلكي.';

  @override
  String get permission_microphoneSettingsMessage =>
      'إذن الميكروفون مطلوب للصوت وميزة اللاسلكي والمكالمات. يرجى تفعيله من الإعدادات.';

  @override
  String get permission_microphoneWhy =>
      'يتيح التواصل الصوتي وإرسال اللاسلكي والمكالمات عند استخدام هذه الميزات.';

  @override
  String permission_notGrantedNamed(String permission) {
    return 'لم يتم منح إذن $permission. يرجى المحاولة مرة أخرى.';
  }

  @override
  String get permission_notificationRequiredToContinue =>
      'إذن الإشعارات مطلوب للمتابعة.';

  @override
  String get permission_notificationSettingsText =>
      'تم إيقاف الإشعارات لـ FG Tracker. افتح الإعدادات ← الإشعارات واسمح بها.';

  @override
  String get permission_notificationStatusBlocked =>
      'الإشعارات محظورة. يرجى تفعيلها من الإعدادات.';

  @override
  String get permission_notificationStatusDone => 'مسموح به';

  @override
  String get permission_notificationStatusNotAllowed =>
      'إذن الإشعارات غير مسموح به بعد.';

  @override
  String get permission_notifications => 'الإشعارات';

  @override
  String get permission_notificationsDescription =>
      'مطلوب لتلقي المكالمات الواردة ورسائل الدردشة وتنبيهات الحضور والأمان.';

  @override
  String get permission_notificationsWhyExtra =>
      'لن يرن الهاتف عند ورود مكالمات بدون هذا الإذن.';

  @override
  String get permission_openSettings => 'فتح الإعدادات';

  @override
  String get permission_preciseLocation => 'الموقع الدقيق';

  @override
  String get permission_pushNotifications => 'الإشعارات الفورية';

  @override
  String get permission_reasonLocation =>
      'الموقع الجغرافي مطلوب للحضور والتتبع المباشر وتنبيهات المنطقة الآمنة.';

  @override
  String get permission_reasonLocationAlways =>
      'اختر \"السماح طوال الوقت\" ليعمل التتبع المباشر والمنطقة الآمنة عندما يكون التطبيق في الخلفية.';

  @override
  String get permission_reasonNotification =>
      'الإشعارات ضرورية لتلقي المكالمات الواردة ورسائل الدردشة وتنبيهات الحضور والمناطق الآمنة.';

  @override
  String get permission_reasonPrecise =>
      'الموقع الدقيق ضروري لتسجيل الحضور بدقة والتتبع المباشر وتنبيهات الأمان.';

  @override
  String get permission_required => 'إذن مطلوب';

  @override
  String get permission_selectAllowAllTheTime =>
      'يرجى تحديد \"السماح طوال الوقت\" للمتابعة.';

  @override
  String get permission_settingsAndroidAlways =>
      'افتح الإعدادات ← الأذونات ← الموقع واختر \"السماح طوال الوقت\".';

  @override
  String get permission_settingsAndroidBlocked =>
      'تم حظر الوصول إلى الموقع لـ FG Tracker. افتح الإعدادات ← الأذونات ← الموقع واختر \"السماح طوال الوقت\".';

  @override
  String get permission_settingsAndroidPrecise =>
      'افتح الإعدادات ← الأذونات ← الموقع وقم بتفعيل \"استخدام الموقع الدقيق\".';

  @override
  String get permission_settingsIosAlways =>
      'افتح الإعدادات ← الموقع واختر \"دائمًا\".';

  @override
  String get permission_settingsIosBlocked =>
      'تم إيقاف إذن الموقع لـ FG Tracker. افتح الإعدادات ← الموقع واختر \"دائمًا\".';

  @override
  String get permission_settingsIosPrecise =>
      'افتح الإعدادات ← الموقع وقم بتشغيل \"الموقع الدقيق\".';

  @override
  String get permission_skipAndContinue => 'تخطي ومتابعة';

  @override
  String get permission_turnOnLocation => 'تشغيل خدمة الموقع';

  @override
  String get permission_turnOnPreciseLocation => 'تشغيل الموقع الدقيق';

  @override
  String get permission_unableToRequest => 'تعذر طلب الإذن.';

  @override
  String get permission_whyWeNeedThis => 'لماذا نحتاج هذا الإذن؟';

  @override
  String get registration_contactNumberHint => 'أدخل رقم الاتصال';

  @override
  String get registration_contactNumberLabel => 'رقم الاتصال';

  @override
  String get registration_doneButton => 'تم';

  @override
  String get registration_emailHint => 'أدخل البريد الإلكتروني';

  @override
  String get registration_emailLabel => 'البريد الإلكتروني';

  @override
  String get registration_genderFemale => 'أنثى';

  @override
  String get registration_genderLabel => 'حدد الجنس';

  @override
  String get registration_genderMale => 'ذكر';

  @override
  String get registration_genderOther => 'آخر';

  @override
  String get registration_selectGenderError => 'يرجى تحديد جنسك';

  @override
  String get registration_userNameHint => 'أدخل اسم المستخدم';

  @override
  String get registration_userNameLabel => 'اسم المستخدم';

  @override
  String get repo_allCallsCleared => 'تم مسح كامل سجل المكالمات بنجاح';

  @override
  String get repo_callDeleted => 'تم حذف سجل المكالمات بنجاح';

  @override
  String get repo_invalidResponse => 'تنسيق استجابة غير صالح';

  @override
  String get repo_loadLocationsFailed => 'فشل تحميل مواقع المجموعة';

  @override
  String get repo_pkgConflict =>
      'هذه الخطة نشطة بالفعل أو هناك عملية دفع قيد التنفيذ.';

  @override
  String get repo_pkgNotFound =>
      'الخطط غير متوفرة حالياً. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get repo_pkgOffline =>
      'لا يوجد اتصال بالإنترنت. تحقق من شبكتك وحاول مرة أخرى.';

  @override
  String get repo_pkgSessionExpired =>
      'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get repo_pkgTimeout =>
      'يستغرق الخادم وقتاً طويلاً للاستجابة. يرجى المحاولة مرة أخرى.';

  @override
  String get repo_selectedCallsDeleted => 'تم حذف المكالمات المحددة بنجاح';

  @override
  String get repo_unnamedGroup => 'مجموعة بدون اسم';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return 'المسافة الإجمالية: $distance  •  الانحراف المسموح: $deviation';
  }

  @override
  String get safeRoute_activeTitle => 'المسار الآمن النشط';

  @override
  String get safeRoute_alertSettingsDesc =>
      'إدارة تنبيهات المسار الآمن، وحدود الانحراف، وتفضيلات الإشعارات.';

  @override
  String get safeRoute_alertSheetDesc =>
      'تنبيهات فورية في الوقت الحقيقي عند انحراف الأعضاء عن المسار الآمن';

  @override
  String get safeRoute_alertTitle => 'تنبيه المسار الآمن';

  @override
  String get safeRoute_appBarSubtitle => 'حدد مساراً آمناً لعضو فريقك.';

  @override
  String get safeRoute_destination => 'الوجهة المقصودة';

  @override
  String get safeRoute_deviated => 'انحرف عن المسار الآمن';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'سيتم إطلاق تنبيه إذا انحرف العضو بأكثر من $distance عن المسار الآمن.';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (الانحراف: $distance)';
  }

  @override
  String get safeRoute_deviationLimit => 'حد الانحراف المسموح';

  @override
  String get safeRoute_deviationSubtitle =>
      'حدد مسافة الانحراف المسموح بها عن المسار المختار.';

  @override
  String get safeRoute_distance => 'المسافة';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance كم • $minutes دقيقة';
  }

  @override
  String get safeRoute_edit => 'تعديل المسار الآمن';

  @override
  String get safeRoute_end => 'النهاية';

  @override
  String safeRoute_estTime(int minutes) {
    return 'الوقت المقدر: $minutes دقيقة';
  }

  @override
  String get safeRoute_featureDesc =>
      'حدد مسارات محددة مسبقًا لأعضاء فريقك وتلقَ تنبيهات فورية في حال انحراف أي شخص عن المسار.';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
    );
    return '$group ($_temp0)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'المسافة المسموح للعضو بالابتعاد عنها عن المسار المختار. ستتلقى تنبيهاً فور تجاوزه هذا الحد.';

  @override
  String get safeRoute_helpDeviationTitle => 'ما هو حد الانحراف؟';

  @override
  String get safeRoute_helpHowBody =>
      'اختر العضو، وحدد نقطة الانطلاق والوصول، ثم اختر أفضل مسار وحدد حد الانحراف المسموح.';

  @override
  String get safeRoute_helpHowTitle => 'كيفية إنشاء مسار آمن؟';

  @override
  String get safeRoute_helpTitle => 'مساعدة المسار الآمن';

  @override
  String get safeRoute_helpWhatBody =>
      'حدد نقطة بداية ووجهة لإنشاء مسار تنقل آمن لعضو فريقك.';

  @override
  String get safeRoute_helpWhatTitle => 'ما هو المسار الآمن؟';

  @override
  String safeRoute_memberDeviated(String name) {
    return 'انحرف $name عن المسار الآمن المحدد';
  }

  @override
  String get safeRoute_recommended => 'المسار الموصى به';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (موصى به)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'مسار ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'حفظ وتفعيل المسار الآمن';

  @override
  String get safeRoute_saveActivateGroup => 'حفظ وتفعيل المسار الآمن للمجموعة';

  @override
  String get safeRoute_selectedRoute => 'المسار المحدد';

  @override
  String get safeRoute_setRoutesSubtitle =>
      'أنشئ وأدر المسارات الآمنة لجميع أفراد المجموعة.';

  @override
  String get safeRoute_start => 'البداية';

  @override
  String get safeRoute_startLocation => 'موقع البداية';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. تحديد حد الانحراف المسموح';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. معاينة وتطبيق';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. معاينة المسار';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. اختيار المسار';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. تحديد المسارات للأعضاء';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. تحديد نقطة البداية والوجهة';
  }

  @override
  String get safeRoute_subtitle => 'حماية المسار المحدد';

  @override
  String get safeRoute_title => 'المسار الآمن';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return 'نصف القطر: $radius  •  المركز: $center';
  }

  @override
  String get safeZone_activePreview => 'نشط (معاينة)';

  @override
  String get safeZone_activeTitle => 'المنطقة الآمنة النشطة';

  @override
  String get safeZone_alertSettingsDesc =>
      'إدارة المنطقة الآمنة، ومسافة التنبيه، وتفضيلات الإشعارات';

  @override
  String get safeZone_alertSheetDesc =>
      'تنبيهات فورية في الوقت الحقيقي عند مغادرة الأعضاء للمنطقة الآمنة';

  @override
  String get safeZone_alertTitle => 'تنبيه المنطقة الآمنة';

  @override
  String safeZone_allMonitored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ستتم مراقبة جميع الأعضاء داخل هذه المنطقة الآمنة.',
      many: 'ستتم مراقبة جميع الأعضاء الـ $count داخل هذه المنطقة الآمنة.',
      few: 'ستتم مراقبة جميع الأعضاء الـ $count داخل هذه المنطقة الآمنة.',
      two: 'ستتم مراقبة عضوين داخل هذه المنطقة الآمنة.',
      one: 'ستتم مراقبة عضو واحد داخل هذه المنطقة الآمنة.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_appBarSubtitle =>
      'حدد منطقة آمنة. احصل على تنبيهات فور خروج أي شخص منها.';

  @override
  String safeZone_appliedToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'سيتم تطبيق هذه المنطقة الآمنة على جميع الأعضاء في المجموعة المختارة.',
      many:
          'سيتم تطبيق هذه المنطقة الآمنة على جميع الأعضاء الـ $count في المجموعة المختارة.',
      few:
          'سيتم تطبيق هذه المنطقة الآمنة على جميع الأعضاء الـ $count في المجموعة المختارة.',
      two: 'سيتم تطبيق هذه المنطقة الآمنة على العضوين في المجموعة المختارة.',
      one:
          'سيتم تطبيق هذه المنطقة الآمنة على العضو الواحد في المجموعة المختارة.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_edit => 'تعديل المنطقة الآمنة';

  @override
  String get safeZone_exited => 'غادر المنطقة الآمنة';

  @override
  String get safeZone_featureDesc =>
      'حدد منطقة جغرافية آمنة لفريقك، واحصل على تنبيهات فورية في حال خروج أي شخص منها.';

  @override
  String get safeZone_helpHowBody =>
      'اختر عضواً أو مجموعة، وحدد الموقع على الخريطة ثم اضبط نصف القطر.';

  @override
  String get safeZone_helpHowTitle => 'كيفية إنشاء منطقة آمنة؟';

  @override
  String get safeZone_helpRadiusBody =>
      'اضبط نصف قطر المنطقة (500 م، 1 كم، 2 كم، أو 5 كم) حسب احتياجك.';

  @override
  String get safeZone_helpRadiusTitle => 'ما هو نصف قطر المنطقة الآمنة؟';

  @override
  String get safeZone_helpTitle => 'مساعدة المنطقة الآمنة';

  @override
  String get safeZone_helpWhatBody =>
      'حدد منطقة جغرافية معينة على الخريطة واحصل على تنبيهات فور مغادرة العضو لها.';

  @override
  String get safeZone_helpWhatTitle => 'ما هي المنطقة الآمنة؟';

  @override
  String safeZone_memberLeft(String name) {
    return 'غادر $name المنطقة الآمنة';
  }

  @override
  String get safeZone_membersMonitored =>
      'ستتم مراقبة الأعضاء وحمايتهم ضمن هذه المنطقة الآمنة.';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return 'بالقرب من $place (خارج $zone)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place (خارج $zone)';
  }

  @override
  String get safeZone_saveActivate => 'حفظ وتفعيل المنطقة الآمنة';

  @override
  String get safeZone_saveActivateGroup => 'حفظ وتفعيل المنطقة الآمنة للمجموعة';

  @override
  String get safeZone_searchLocation => 'البحث عن موقع...';

  @override
  String get safeZone_statusLabel => 'الحالة:';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. معاينة المنطقة الآمنة';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. تحديد نصف قطر المنطقة الآمنة';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. تحديد الموقع على الخريطة';
  }

  @override
  String get safeZone_subtitle => 'حماية النطاق الجغرافي';

  @override
  String get safeZone_title => 'المنطقة الآمنة';

  @override
  String safeZone_totalMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إجمالي $count عضو',
      many: 'إجمالي $count عضوًا',
      few: 'إجمالي $count أعضاء',
      two: 'عضوان إجمالي',
      one: 'عضو إجمالي واحد',
    );
    return '$_temp0';
  }

  @override
  String get safety_active => 'نشط';

  @override
  String get safety_alertSettings => 'إعدادات التنبيهات';

  @override
  String get safety_alerts => 'التنبيهات';

  @override
  String get safety_alertsDesc => 'تتطلب انتباهاً فورياً';

  @override
  String get safety_bannerBody =>
      'تابع واحمِ فريقك باستخدام ميزات الأمان الذكية والموثوقة.';

  @override
  String get safety_bannerTitle => 'سلامتكم أولويتنا القصوى';

  @override
  String get safety_chooseFeature => 'اختر ميزة الأمان';

  @override
  String get safety_comingSoonBody =>
      'ميزات الأمان الذكية لحماية فريقك قادمة قريباً.';

  @override
  String get safety_contactSupport => 'الاتصال بالدعم';

  @override
  String get safety_editAnytime =>
      'يمكنك تعديل الإعدادات أو إيقاف التفعيل في أي وقت لاحقاً.';

  @override
  String get safety_mapCityPark => 'حديقة المدينة';

  @override
  String get safety_mapMainRoad => 'الشارع الرئيسي';

  @override
  String get safety_mapMarketLane => 'سوق المشاة';

  @override
  String get safety_mapRiver => 'النهر / القناة';

  @override
  String get safety_mapStationRoad => 'شارع المحطة';

  @override
  String get safety_needHelpBody =>
      'تواصل مع فريق الدعم للحصول على المساعدة المتعلقة بالسلامة.';

  @override
  String get safety_quickOverview => 'نظرة سريعة';

  @override
  String get safety_recentAlerts => 'التنبيهات الأخيرة';

  @override
  String get safety_recenter => 'إعادة التوسيط';

  @override
  String get safety_safeNow => 'آمن الآن';

  @override
  String get safety_safeNowDesc => 'جميع الأعضاء ضمن المنطقة / المسار الآمن';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. اختيار المجموعة';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. اختيار العضو';
  }

  @override
  String get safety_tabIndividual => 'فردي';

  @override
  String get safety_tagline => 'ابقَ محمياً. ابقَ متصلاً.';

  @override
  String get safety_title => 'السلامة والأمان';

  @override
  String get safety_viewAllMembers => 'عرض جميع الأعضاء';

  @override
  String get sheet_addGroupMember => 'إضافة عضو إلى المجموعة';

  @override
  String get sheet_admin => 'مشرف';

  @override
  String get sheet_attachSubtitle => 'شارك الملفات والوسائط مع فريقك';

  @override
  String get sheet_attachUpload => 'إرفاق / تحميل';

  @override
  String get sheet_attendance => 'الحضور';

  @override
  String get sheet_callOptions => 'خيارات الاتصال';

  @override
  String get sheet_cantRemoveSelf => 'لا يمكنك إزالة نفسك من المجموعة.';

  @override
  String get sheet_contact => 'جهة اتصال';

  @override
  String get sheet_contactsNotOnApp => 'جهات اتصالك لا تستخدم FG Tracker بعد.';

  @override
  String get sheet_document => 'مستند';

  @override
  String get sheet_groupMembers => 'أعضاء المجموعة';

  @override
  String get sheet_location => 'الموقع';

  @override
  String get sheet_memberRemoved => 'تمت إزالة العضو بنجاح';

  @override
  String get sheet_noMembers => 'لم يتم العثور على أعضاء';

  @override
  String get sheet_noRegisteredContacts => 'لا توجد جهات اتصال مسجلة';

  @override
  String get sheet_noUserFound => 'لم يتم العثور على مستخدم';

  @override
  String get sheet_normalAudioCall => 'مكالمة صوتية عادية';

  @override
  String get sheet_normalAudioCallSubtitle => 'جودة صوت واضحة قياسية';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهات اتصال مسجلة',
      one: 'جهة اتصال واحدة مسجلة',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return 'هل أنت متأكد من إزالة $name من المجموعة؟';
  }

  @override
  String get sheet_removeMemberTitle => 'إزالة العضو';

  @override
  String get sheet_searchContacts => 'بحث في جهات الاتصال';

  @override
  String get sheet_walkieCall => 'مكالمة لاسلكية (Walkie-Talkie)';

  @override
  String get sheet_walkieCallSubtitle => 'تواصل عبر الضغط للتحدث';

  @override
  String get sos_addDetailsMandatory => 'إضافة تفاصيل (إلزامي)';

  @override
  String get sos_addDetailsOptional => 'إضافة تفاصيل (اختياري)';

  @override
  String get sos_addFamilyMember => 'إضافة فرد من العائلة';

  @override
  String get sos_addFamilyMemberRequired =>
      'أضف فردًا واحدًا على الأقل من العائلة لإرسال تنبيه SOS';

  @override
  String get sos_addPhotoHint =>
      'أرفق صورة لمساعدة الآخرين على فهم الوضع بشكل أوضح.';

  @override
  String get sos_addPhotoOptional => 'إضافة صورة (اختياري)';

  @override
  String get sos_alertSent => 'تم إرسال تنبيه الاستغاثة SOS!';

  @override
  String get sos_alertSentToNearby =>
      'تم إرسال التنبيه للأشخاص الموجودين بالقرب منك.';

  @override
  String get sos_alertWillBeSent => 'سيتم إرسال التنبيه للمتواجدين بالقرب';

  @override
  String get sos_alertWillBeSentFamily =>
      'سيتم إرسال التنبيه للمتواجدين بالقرب ولأفراد عائلتك.';

  @override
  String sos_availableUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستخدم متاح',
      many: '$count مستخدمًا متاحًا',
      few: '$count مستخدمين متاحين',
      two: 'مستخدمان متاحان',
      one: 'مستخدم واحد متاح',
    );
    return '$_temp0';
  }

  @override
  String get sos_detailsHint => 'اكتب أي تفاصيل إضافية هنا...';

  @override
  String get sos_detailsMandatoryForOther =>
      'إضافة التفاصيل إلزامية عند اختيار السبب \'أخرى\'';

  @override
  String get sos_howItWorks => 'كيفية العمل';

  @override
  String get sos_howItWorksIntro =>
      'يساعدك تنبيه SOS في إخطار الأشخاص القريبين منك وعائلتك في حالات الطوارئ.';

  @override
  String get sos_howItWorksTitle => 'كيف يعمل تنبيه الاستغاثة SOS؟';

  @override
  String get sos_liveTrackingStarted => 'بدأ التتبع المباشر';

  @override
  String sos_locationSharedWithFamily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تتم مشاركة موقعك مع $count فرد من العائلة',
      many: 'تتم مشاركة موقعك مع $count فردًا من العائلة',
      few: 'تتم مشاركة موقعك مع $count أفراد من العائلة',
      two: 'تتم مشاركة موقعك مع فردين من العائلة',
      one: 'تتم مشاركة موقعك مع فرد واحد من العائلة',
    );
    return '$_temp0';
  }

  @override
  String sos_membersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اختيار $count عضو',
      many: 'تم اختيار $count عضوًا',
      few: 'تم اختيار $count أعضاء',
      two: 'تم اختيار عضوين',
      one: 'تم اختيار عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get sos_needHelp => 'هل تحتاج إلى مساعدة؟';

  @override
  String get sos_needHelpBody =>
      'أرسل تنبيه استغاثة SOS للمتواجدين بالقرب منك.\nسيتم إشعارهم ليتمكنوا من تقديم المساعدة فوراً.';

  @override
  String get sos_noMatchFound => 'لا توجد نتائج مطابقة';

  @override
  String get sos_noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get sos_notifyFamilyTitle => 'إشعار عائلتك (مطلوب من 1 إلى 5)';

  @override
  String get sos_notifyUpdates => 'سنوافيك بأي تحديثات فور وصولها';

  @override
  String get sos_okGotIt => 'حسناً، فهمت';

  @override
  String get sos_peopleWithinRadius => 'الأشخاص في نطاق 2 كم';

  @override
  String get sos_privacyNote =>
      'خصوصيتك مقدسة. تتم مشاركة موقعك الجغرافي فقط أثناء تفعيل تنبيه الاستغاثة.';

  @override
  String get sos_reasonAccident => 'حادث';

  @override
  String get sos_reasonMedical => 'طبي / إسعاف';

  @override
  String get sos_reasonOther => 'أخرى';

  @override
  String get sos_reasonSafety => 'أمان / طوارئ';

  @override
  String get sos_reasonThreat => 'تهديد / خطر';

  @override
  String get sos_required => 'إلزامي';

  @override
  String get sos_searchUsers => 'البحث عن مستخدمين';

  @override
  String get sos_selectReason => 'اختر سبب الطوارئ';

  @override
  String get sos_sendSosAlert => 'إرسال تنبيه SOS';

  @override
  String get sos_stayCalm => 'ابقَ هادئاً، المساعدة في طريقها إليك';

  @override
  String get sos_step1Body =>
      'اضغط على زر SOS لإرسال تنبيه فوري للأشخاص القريبين منك.';

  @override
  String get sos_step1Title => '1. إرسال تنبيه SOS';

  @override
  String get sos_step2Body =>
      'سيتلقى الأشخاص القريبون تنبيهك مصحوبًا بموقعك الدقيق.';

  @override
  String get sos_step2Title => '2. إشعار الأشخاص القريبين';

  @override
  String get sos_step3Body =>
      'يمكن للمتواجدين بالقرب رؤية موقع التنبيه والمسارعة لمساعدتك.';

  @override
  String get sos_step3Title => '3. الحصول على المساعدة بسرعة';

  @override
  String get sos_step4Body =>
      'سيتم إشعار أفراد عائلتك على الفور بحالة الطوارئ وموقعك.';

  @override
  String get sos_step4Title => '4. إشعار العائلة';

  @override
  String get sos_subtitle => 'إرسال تنبيه للأشخاص القريبين';

  @override
  String get sos_title => 'تنبيه الاستغاثة (SOS)';

  @override
  String get sos_willBeNotified => 'سيتم إشعارهم';

  @override
  String status_activeCount(int count) {
    return '$count نشط';
  }

  @override
  String get status_addToMyStatus => 'إضافة إلى حالتي';

  @override
  String get status_allContacts => 'جميع جهات الاتصال';

  @override
  String get status_cameraAccessFailed => 'تعذر الوصول إلى الكاميرا';

  @override
  String get status_captionHint => 'إضافة تسمية توضيحية...';

  @override
  String get status_changeMedia => 'تغيير الوسائط';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day، $time';
  }

  @override
  String get status_deleted => 'تم حذف الحالة';

  @override
  String get status_deletedByOwner => 'تم حذف هذه الحالة من قبل صاحبها';

  @override
  String get status_exceptContacts => 'باستثناء جهات الاتصال';

  @override
  String get status_exceptSelected => 'باستثناء المحدد';

  @override
  String get status_flip => 'قلب الكاميرا';

  @override
  String get status_gallery => 'المعرض';

  @override
  String get status_modePhoto => 'صورة';

  @override
  String get status_modeText => 'نص';

  @override
  String get status_modeVideo => 'فيديو';

  @override
  String get status_myStatus => 'حالتي';

  @override
  String get status_new => 'جديد';

  @override
  String get status_noCamera => 'لا توجد كاميرا متاحة';

  @override
  String get status_noLongerAvailable => 'هذه الحالة لم تعد متاحة';

  @override
  String get status_noViewsYet => 'لا توجد مشاهدات بعد';

  @override
  String get status_onlyShareWith => 'المشاركة فقط مع';

  @override
  String get status_pause => 'إيقاف مؤقت';

  @override
  String get status_pinchZoomHint => 'اضغط للتكبير على الصورة';

  @override
  String get status_play => 'تشغيل';

  @override
  String get status_postStatus => 'نشر الحالة';

  @override
  String get status_previewStatus => 'معاينة الحالة';

  @override
  String get status_privacy => 'الخصوصية';

  @override
  String get status_privacyTitle => 'خصوصية الحالة';

  @override
  String get status_publishFailed => 'تعذر نشر الحالة';

  @override
  String get status_replyHint => 'الرد على الحالة...';

  @override
  String get status_retake => 'إعادة التقاط';

  @override
  String get status_selectPhotoFirst => 'يرجى التقاط صورة أو اختيارها أولاً';

  @override
  String get status_selectVideoFirst => 'يرجى تسجيل فيديو أو اختياره أولاً';

  @override
  String get status_shareUpdatesHint => 'شارك التحديثات مع فريقك';

  @override
  String get status_tapVideoHint => 'اضغط على الفيديو للتشغيل / الإيقاف المؤقت';

  @override
  String get status_textRequired => 'محتوى النص مطلوب للحالة النصية';

  @override
  String get status_title => 'الحالة';

  @override
  String get status_typeHint => 'اكتب حالة...';

  @override
  String get status_uploadFailed => 'فشل التحميل';

  @override
  String get status_viewMyStatus => 'عرض حالتي';

  @override
  String get status_viewed => 'تمت المشاهدة';

  @override
  String status_viewedBy(int count) {
    return 'شاهده $count';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشاهدات',
      one: 'مشاهدة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => 'من يمكنه الرؤية؟';

  @override
  String get track_admin => 'مسؤول';

  @override
  String get track_applyRadius => 'تطبيق نصف القطر';

  @override
  String get track_checkNetworkConnection =>
      'يرجى التحقق من اتصال الشبكة والمحاولة مرة أخرى.';

  @override
  String get track_checkNetworkMembers =>
      'يرجى التحقق من الشبكة وإعادة المحاولة لعرض الأعضاء القريبين.';

  @override
  String get track_currentLocation => 'الموقع الحالي';

  @override
  String get track_custom => 'مخصص';

  @override
  String track_customWithValue(String radius) {
    return 'مخصص ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return 'يبعد $distance';
  }

  @override
  String get track_enable => 'تفعيل';

  @override
  String get track_enableGpsBody =>
      'لتتبع مجموعتك في الوقت الفعلي، يرجى تشغيل الـ GPS.';

  @override
  String get track_enableGpsTitle => 'تفعيل نظام تحديد المواقع (GPS)';

  @override
  String get track_errorFailedLoadGroups => 'فشل تحميل المجموعات';

  @override
  String get track_errorLoadGroups =>
      'تعذر تحميل المجموعات. يرجى المحاولة مرة أخرى.';

  @override
  String get track_errorLoadMembers =>
      'تعذر تحميل الأعضاء القريبين. يرجى المحاولة مرة أخرى.';

  @override
  String get track_errorNoInternet =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';

  @override
  String get track_errorServer =>
      'تعذر الاتصال بالخادم. يرجى المحاولة مرة أخرى.';

  @override
  String track_groupCode(String code) {
    return 'الرمز: $code';
  }

  @override
  String get track_groupMembers => 'أعضاء المجموعة';

  @override
  String track_groupMembersAndCode(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو • الرمز: $code',
      many: '$count عضوًا • الرمز: $code',
      few: '$count أعضاء • الرمز: $code',
      two: 'عضوان • الرمز: $code',
      one: 'عضو واحد • الرمز: $code',
    );
    return '$_temp0';
  }

  @override
  String get track_groupTab => 'المجموعة';

  @override
  String track_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String track_groupsHeader(int count) {
    return 'المجموعات ($count)';
  }

  @override
  String get track_helpGroupBody => 'أنشئ مجموعة لتتبع عدة أفراد في وقت واحد.';

  @override
  String get track_helpGroupTitle => 'كيفية إضافة مجموعة؟';

  @override
  String get track_helpLiveBody =>
      'تتبع الموقع الجغرافي لفريقك في الوقت الفعلي على الخريطة.';

  @override
  String get track_helpLiveTitle => 'ما هو التتبع المباشر؟';

  @override
  String get track_helpRadiusBody =>
      'حدد نطاق البحث للعثور على الأعضاء القريبين منك على الخريطة.';

  @override
  String get track_helpRadiusTitle => 'ما هو نطاق التتبع؟';

  @override
  String get track_helpTitle => 'مساعدة التتبع';

  @override
  String track_lastSeen(String time) {
    return 'آخر ظهور: $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count مباشر';
  }

  @override
  String get track_liveMembers => 'الأعضاء المتصلون مباشرة';

  @override
  String get track_liveTracking => 'التتبع المباشر';

  @override
  String get track_locating => 'جاري تحديد الموقع...';

  @override
  String get track_locationHidden => 'الموقع مخفي';

  @override
  String get track_locationUnavailable => 'الموقع غير متوفر';

  @override
  String get track_mapOfflineBody =>
      'الاتصال بالإنترنت مطلوب لتحميل بيانات الخريطة المباشرة ومواقع الأعضاء الآنية.';

  @override
  String get track_mapUnavailableOffline => 'الخريطة غير متوفرة دون اتصال';

  @override
  String get track_member => 'عضو';

  @override
  String track_memberPausedSharing(String name) {
    return 'أوقف $name مشاركة الموقع مؤقتاً. الموقع المباشر غير متوفر.';
  }

  @override
  String track_membersHeader(int count) {
    return 'الأعضاء ($count)';
  }

  @override
  String track_membersLive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو مباشر',
      many: '$count عضوًا مباشرًا',
      few: '$count أعضاء مباشرين',
      two: 'عضوان مباشران',
      one: 'عضو مباشر واحد',
    );
    return '$_temp0';
  }

  @override
  String get track_menuMembers => 'الأعضاء';

  @override
  String get track_menuRefreshMap => 'تحديث الخريطة';

  @override
  String get track_menuTheme => 'المظهر / النمط';

  @override
  String get track_nearbyYou => 'بالقرب منك';

  @override
  String get track_noActiveMembers => 'لا يوجد أعضاء نشطون';

  @override
  String track_noActiveMembersWithin(String radius) {
    return 'لم يتم العثور على أعضاء نشطين ضمن نطاق $radius';
  }

  @override
  String get track_noDescription => 'لا يوجد وصف';

  @override
  String get track_noGroupsFound => 'لم يتم العثور على مجموعات';

  @override
  String get track_noGroupsMatch => 'لا توجد مجموعات مطابقة';

  @override
  String track_noGroupsMatchQuery(String query) {
    return 'لا توجد مجموعات تطابق \'$query\'';
  }

  @override
  String get track_noGroupsYet => 'لم تنضم إلى أي مجموعة أو تنشئ واحدة بعد.';

  @override
  String get track_noInternetTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get track_noMembersFound => 'لم يتم العثور على أعضاء';

  @override
  String get track_noMembersFoundPlain => 'لم يتم العثور على أعضاء';

  @override
  String get track_noMembersInGroup =>
      'لم يتم العثور على أعضاء في هذه المجموعة';

  @override
  String track_noMembersMatch(String query) {
    return 'لا يوجد أعضاء يطابقون \'$query\'';
  }

  @override
  String track_noSearchMatches(String query) {
    return 'لا توجد نتائج مطابقة للأعضاء أو المجموعات';
  }

  @override
  String track_noSearchResults(String query) {
    return 'لم يتم العثور على أعضاء أو مجموعات لـ \'$query\'';
  }

  @override
  String get track_notAvailable => 'غير متوفر';

  @override
  String get track_offlineBanner =>
      'لا يوجد اتصال بالإنترنت. الخريطة والتتبع في وضع عدم الاتصال.';

  @override
  String get track_private => 'خاص';

  @override
  String get track_radius => 'نصف القطر';

  @override
  String get track_refresh => 'تحديث';

  @override
  String get track_refreshing => 'جاري التحديث...';

  @override
  String get track_retryConnection => 'إعادة محاولة الاتصال';

  @override
  String get track_searchHint => 'البحث عن أعضاء أو مجموعات...';

  @override
  String get track_searchMembersHint => 'البحث عن أعضاء...';

  @override
  String get track_selectedLocation => 'الموقع المحدد';

  @override
  String get track_setRadiusSubtitle => 'اسحب لتحديد نصف قطر المنطقة';

  @override
  String get track_setRadiusTitle => 'تحديد نطاق التتبع (نصف القطر)';

  @override
  String get track_unableToLoadGroups => 'تعذر تحميل المجموعات';

  @override
  String get track_unableToLoadMembers => 'تعذر تحميل الأعضاء';

  @override
  String get track_unnamedGroup => 'مجموعة بدون اسم';

  @override
  String get track_unnamedMember => 'عضو بدون اسم';

  @override
  String get track_yourGroups => 'مجموعاتك';

  @override
  String get track_yourLocationPaused =>
      'مشاركة موقعك المباشر متوقفة مؤقتاً وخاصة.';

  @override
  String get util_previewContact => '👤 جهة اتصال';

  @override
  String get util_previewDocument => '📄 مستند';

  @override
  String get util_previewLocation => '📍 الموقع';

  @override
  String get util_previewPhoto => '📷 صورة';

  @override
  String get util_previewVideo => '🎥 فيديو';

  @override
  String get util_previewVoice => '🎤 رسالة صوتية';

  @override
  String util_spokenEur(String amount) {
    return '$amount يورو';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amount جنيه إسترليني';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupees روبية',
      one: 'روبية واحدة',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees روبية و $paise بيزة';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount دولار أمريكي';
  }

  @override
  String get util_unableToCallContact => 'تعذر الاتصال بجهة الاتصال هذه';

  @override
  String get util_unableToStartGroupCall => 'تعذر بدء المكالمة الجماعية';

  @override
  String get validation_emailEmpty =>
      'لا يمكن أن يكون البريد الإلكتروني فارغاً';

  @override
  String get validation_emailInvalid => 'يرجى إدخال عنوان بريد إلكتروني صالح.';

  @override
  String validation_required(String field) {
    return '$field مطلوب';
  }

  @override
  String get voice_appLanguage => 'لغة التطبيق';

  @override
  String get voice_audioChip => 'صوت';

  @override
  String get voice_captionReady => 'الوصف جاهز';

  @override
  String get voice_chooseSpeechLanguage => 'اختر لغة الإدخال الصوتي';

  @override
  String get voice_couldntPlay => 'تعذر تشغيل الرسالة الصوتية';

  @override
  String get voice_didntCatch =>
      'لم نتمكن من السماع جيداً. اضغط على الميكروفون وتحدث بصوت أعلى.';

  @override
  String get voice_language => 'اللغة';

  @override
  String get voice_listenBack => 'الاستماع للتسجيل';

  @override
  String get voice_listenBeforeSending =>
      'استمع لتسجيلك قبل إرسال الرسالة الصوتية.';

  @override
  String get voice_listening => 'جاري الاستماع…';

  @override
  String get voice_micPermissionNeeded => 'إذن الميكروفون مطلوب لتسجيل الصوت.';

  @override
  String get voice_micUnavailable =>
      'الميكروفون غير متوفر. يرجى التحقق من الإعدادات.';

  @override
  String get voice_noTextCaptured =>
      'لم يتم التقاط أي نص — يرجى محاولة التسجيل مرة أخرى.';

  @override
  String get voice_openSettings => 'فتح الإعدادات';

  @override
  String get voice_permissionRequired => 'إذن مطلوب';

  @override
  String get voice_reRecord => 'إعادة التسجيل';

  @override
  String get voice_readyToSend => 'جاهز للإرسال';

  @override
  String get voice_recordVoice => 'تسجيل صوتي';

  @override
  String get voice_recordVoiceSubtitle => 'سجل وأرسل رسالة صوتية مباشرة';

  @override
  String get voice_recordingYourVoice => 'جاري تسجيل صوتك…';

  @override
  String get voice_replyReady => 'الرد جاهز';

  @override
  String get voice_reviewTextHint =>
      'استمع لتسجيلك الصوتي بالأعلى، أو عدّل النص في المربع قبل الإرسال.';

  @override
  String get voice_sendMessage => 'إرسال الرسالة';

  @override
  String get voice_sendVoiceMessage => 'إرسال الرسالة الصوتية';

  @override
  String get voice_speakNowCaption => 'تحدث الآن – نقوم بكتابة الوصف';

  @override
  String get voice_speakNowMessage =>
      'تحدث الآن – ستظهر كلماتك في مربع الرسالة';

  @override
  String get voice_speakNowReply => 'تحدث الآن – نقوم بكتابة ردك تلقائياً';

  @override
  String get voice_speakPlaceholder => 'تحدث الآن… سيظهر النص هنا';

  @override
  String get voice_speechPermissionNeeded =>
      'إذن التعرف على الصوت مطلوب لتحويل الصوت إلى نص مكتوب.';

  @override
  String get voice_tapToStop => 'اضغط للإيقاف';

  @override
  String get voice_textReady => 'النص جاهز';

  @override
  String get voice_tooMuchNoise => 'يوجد ضوضاء عالية – قرّب الهاتف وتحدث بوضوح';

  @override
  String get voice_type => 'النوع';

  @override
  String get voice_voiceToText => 'تحويل الصوت إلى نص';

  @override
  String get voice_voiceToTextSubtitle => 'تحدث للكتابة مباشرة في مربع الرسائل';

  @override
  String get voice_willSendAudioMessage => 'سيتم إرسال صوتك كرسالة صوتية';

  @override
  String get voice_willSendAudioReply => 'سيتم إرسال صوتك كرد صوتي';

  @override
  String get voice_willSendWithFile => 'سيتم إرسال تسجيلك الصوتي مرفقاً بالملف';

  @override
  String get voice_yourMessage => 'رسالتك';

  @override
  String get voice_yourVoiceMessage => 'رسالتك الصوتية';

  @override
  String get walkiePlan_availableIndividualPlans => 'الباقات الفردية';

  @override
  String get walkiePlan_availablePerMonth => '/ شهر';

  @override
  String get walkiePlan_availablePerSeat => '/ مقعد';

  @override
  String get walkiePlan_availableSingleMember => 'عضو فردي (وصول شخصي)';

  @override
  String get walkiePlan_availableSubtitle => 'اختر باقة لبدء أو ترقية اشتراكك';

  @override
  String get walkiePlan_availableTeamPlans => 'باقات الفريق';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min-$max مقاعد  •  تعاون جماعي';
  }

  @override
  String get walkiePlan_availableTitle => 'الباقات المتوفرة';

  @override
  String get walkiePlan_bottomBarAfterTrial => 'بعد انتهاء فترتك التجريبية';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'اختر باقة';

  @override
  String get walkiePlan_bottomBarContinue => 'المتابعة مع اللاسلكي';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return 'شراء مقابل $price';
  }

  @override
  String get walkiePlan_cardActive => 'نشط';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return 'نشط منذ $date';
  }

  @override
  String get walkiePlan_cardAssigned => 'مخصص';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return 'مخصص من قِبل $name';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'مخصص لك';

  @override
  String get walkiePlan_cardAvailable => 'متاح';

  @override
  String get walkiePlan_cardManageMembers => 'إدارة الأعضاء';

  @override
  String get walkiePlan_cardNoActiveIndividual => 'لا يوجد اشتراك فردي نشط';

  @override
  String get walkiePlan_cardNoActiveTeam =>
      'لا توجد باقة فريق نشطة أو مقعد مخصص';

  @override
  String get walkiePlan_cardOneSeatSelf => 'مقعد واحد (شخصي)';

  @override
  String get walkiePlan_cardPersonal => 'شخصي';

  @override
  String get walkiePlan_cardPurchased => 'مشترى';

  @override
  String get walkiePlan_cardPurchasedByYou => 'مشترى من قبلك';

  @override
  String get walkiePlan_cardPurchasedOn => 'تاريخ الشراء';

  @override
  String get walkiePlan_cardSeatsMembers => 'المقاعد / الأعضاء';

  @override
  String get walkiePlan_cardSubscribedByYou => 'مشترك من قبلك';

  @override
  String get walkiePlan_cardTeamAdministrator => 'مسؤول الفريق';

  @override
  String get walkiePlan_cardValidUntil => 'صالح حتى';

  @override
  String get walkiePlan_cardView => 'عرض';

  @override
  String get walkiePlan_cardViewPlan => 'عرض الباقة';

  @override
  String walkiePlan_couponDiscount(String value) {
    return 'خصم بقيمة $value';
  }

  @override
  String get walkiePlan_couponExpired => 'انتهت صلاحية القسيمة';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return 'خصم مباشر بقيمة $amount';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet =>
      'لم يتم استيفاء الحد الأدنى للطلب';

  @override
  String get walkiePlan_couponNotEligible => 'غير مؤهل للباقة الحالية';

  @override
  String get walkiePlan_couponNotStarted => 'عرض القسيمة غير نشط بعد';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return 'خصم $percent٪';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable =>
      'لا تسري القسيمة على هذه الباقة';

  @override
  String walkiePlan_couponValidTill(String date) {
    return 'صالح حتى $date';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'المتابعة إلى الدفع';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return 'المتابعة مع $plan';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => 'تم تطبيق القسيمة بنجاح!';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return 'تم تطبيق القسيمة! وفرت $amount';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => 'فشل تطبيق القسيمة';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'تمت إزالة القسيمة';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'خطأ Cashfree ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed => 'فشل بدء عملية الدفع.';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return 'فشل إنشاء جلسة الدفع: $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return 'تعذر معالجة الدفع: $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'جاري تحميل الباقات...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans =>
      'تعذر تحميل الباقات. يرجى المحاولة مرة أخرى.';

  @override
  String get walkiePlan_detailsAllBanks => 'دعم جميع البنوك الهندية';

  @override
  String get walkiePlan_detailsApplied => 'مطبقة';

  @override
  String get walkiePlan_detailsApply => 'تطبيق';

  @override
  String get walkiePlan_detailsApplyCaps => 'تطبيق';

  @override
  String get walkiePlan_detailsAvailableCoupons => 'القسائم المتاحة';

  @override
  String get walkiePlan_detailsCard => 'بطاقة ائتمان / خصم مباشر';

  @override
  String get walkiePlan_detailsChooseTitle => 'اختر باقة مناسبة';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'الرمز: $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'القسائم والعروض';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'أدخل رمز القسيمة';

  @override
  String get walkiePlan_detailsEnterValidCoupon => 'يرجى إدخال رمز قسيمة صالح';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'تواصل جماعي متكامل';

  @override
  String get walkiePlan_detailsFeatHqVoice => 'صوت عالي الدقة والوضوح';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => 'دعم فني بأولوية خاصة';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => 'نطاق وتغطية غير محدودة';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => 'لاسلكي غير محدود';

  @override
  String get walkiePlan_detailsHavePromoCode => 'هل لديك رمز ترويجي؟';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'واصل استخدام اللاسلكي مع الباقة التي تناسب احتياجاتك';

  @override
  String get walkiePlan_detailsLockedCaps => 'مقفل';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم الوصول للحد الأقصى ($count عضو)',
      many: 'تم الوصول للحد الأقصى ($count عضواً)',
      few: 'تم الوصول للحد الأقصى ($count أعضاء)',
      two: 'تم الوصول للحد الأقصى (عضوان)',
      one: 'تم الوصول للحد الأقصى (عضو واحد)',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMemberPlural => 'أعضاء';

  @override
  String get walkiePlan_detailsMemberSingular => 'عضو';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو × $rate',
      many: '$count عضوًا × $rate',
      few: '$count أعضاء × $rate',
      two: 'عضوان × $rate',
      one: 'عضو واحد × $rate',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الحد الأدنى لحجم الفريق هو $count عضو',
      many: 'الحد الأدنى لحجم الفريق هو $count عضواً',
      few: 'الحد الأدنى لحجم الفريق هو $count أعضاء',
      two: 'الحد الأدنى لحجم الفريق هو عضوان',
      one: 'الحد الأدنى لحجم الفريق هو عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody =>
      'يمكنك إضافة أو إزالة الأعضاء في أي وقت.';

  @override
  String get walkiePlan_detailsMoreMembersTitle => 'هل تحتاج لأعضاء أكثر؟';

  @override
  String get walkiePlan_detailsMostPopular => 'الأكثر شعبية';

  @override
  String get walkiePlan_detailsNetBanking => 'الخدمات المصرفية عبر الإنترنت';

  @override
  String get walkiePlan_detailsNoCouponsBody =>
      'لا توجد قسائم نشطة لهذه الباقة في الوقت الحالي.';

  @override
  String get walkiePlan_detailsNoCouponsTitle => 'لا توجد قسائم متاحة';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      'لا توجد باقات فردية للاسلكي متاحة حالياً. يرجى المحاولة لاحقاً.';

  @override
  String get walkiePlan_detailsNoPlansTitle => 'لا توجد باقات متاحة';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      'لا توجد باقات فريق للاسلكي متاحة حالياً. يرجى المحاولة لاحقاً.';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '$amount الإجمالي';
  }

  @override
  String get walkiePlan_detailsPayActivate => 'دفع وتفعيل الباقة';

  @override
  String get walkiePlan_detailsPerPerson => '/ شخص';

  @override
  String get walkiePlan_detailsPillAllSizes => 'بمختلف الأحجام';

  @override
  String get walkiePlan_detailsPillCommunication => 'الاتصال';

  @override
  String get walkiePlan_detailsPillForTeams => 'للفرق';

  @override
  String get walkiePlan_detailsPillInstant => 'فوري';

  @override
  String get walkiePlan_detailsPillPriority => 'أولوية';

  @override
  String get walkiePlan_detailsPillReliable => 'موثوق و';

  @override
  String get walkiePlan_detailsPillSecure => 'آمن';

  @override
  String get walkiePlan_detailsPillSupport => 'الدعم';

  @override
  String get walkiePlan_detailsPillUnlimited => 'غير محدود';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'اللاسلكي';

  @override
  String get walkiePlan_detailsPlanActivated => 'تم تفعيل الباقة بنجاح!';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'باقتك لخدمة اللاسلكي مفعلة الآن. استمتع بتواصل صوتي فوري ودون انقطاع.';

  @override
  String get walkiePlan_detailsPlanSummary => 'ملخص الباقة';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'تم تطبيق الرمز الترويجي ($code)';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => 'إزالة';

  @override
  String get walkiePlan_detailsSelectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get walkiePlan_detailsSkeletonCouponNote =>
      'صالح لجميع الباقات • ينتهي قريباً';

  @override
  String get walkiePlan_detailsStep1Subtitle =>
      'حدد عدد أفراد الفريق الذين تود إضافتهم';

  @override
  String get walkiePlan_detailsStep1Title => 'اختر عدد الأعضاء';

  @override
  String get walkiePlan_detailsStep2Subtitle => 'اختر المدة التي تناسبك';

  @override
  String get walkiePlan_detailsStep2Title => 'اختر مدة الباقة';

  @override
  String get walkiePlan_detailsSubtitleDefault =>
      'وصول صوتي فوري لخدمة اللاسلكي';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams =>
      'قيمة ممتازة للفرق المتنامية';

  @override
  String get walkiePlan_detailsSubtitleLongTerm =>
      'الخيار الأفضل للاستخدام طويل الأجل';

  @override
  String get walkiePlan_detailsSubtitleShortTerm =>
      'مثالي للاستخدام قصير المدى';

  @override
  String get walkiePlan_detailsTabIndividual => 'فردي';

  @override
  String get walkiePlan_detailsTabMultipleMembers => 'لعدة أعضاء';

  @override
  String get walkiePlan_detailsTabPerPerson => 'لكل شخص';

  @override
  String get walkiePlan_detailsTeamSubtitle =>
      'أضف أفراد الفريق وابقِ الجميع على اتصال مباشر باللاسلكي';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / رمز QR';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return 'لقد وفرت $amount باستخدام هذه القسيمة!';
  }

  @override
  String get walkiePlan_durationFallback => 'المدة';

  @override
  String get walkiePlan_durationMonthly => 'شهري';

  @override
  String walkiePlan_durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شهر',
      many: '$count شهراً',
      few: '$count أشهر',
      two: 'شهران',
      one: 'شهر واحد',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_durationQuarterly => 'ربع سنوي';

  @override
  String get walkiePlan_durationYearly => 'سنوي';

  @override
  String get walkiePlan_individualPlan => 'باقة فردية';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return 'باقة $interval';
  }

  @override
  String get walkiePlan_monthlyPlan => 'الباقة الشهرية';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';

  @override
  String get walkiePlan_order100Secure => 'آمن 100٪';

  @override
  String get walkiePlan_order3ds2Secure => 'حماية 3DS2 الآمنة';

  @override
  String get walkiePlan_orderAgreePrefix => 'بالمتابعة، فإنك توافق على ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => 'المبلغ بعد الخصم';

  @override
  String get walkiePlan_orderCards => 'البطاقات البنكية';

  @override
  String get walkiePlan_orderChangeMethod => 'تغيير الطريقة';

  @override
  String get walkiePlan_orderCouldNotStart =>
      'تعذر بدء عملية الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get walkiePlan_orderCouponApplied => 'تم تطبيق القسيمة بنجاح!';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return 'تم تطبيق القسيمة! لقد وفرت $amount';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'تمت إزالة القسيمة بنجاح';

  @override
  String get walkiePlan_orderCreateFailed =>
      'فشل إنشاء أمر الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get walkiePlan_orderDiscount => 'الخصم';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return 'خصم ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint =>
      'اختر من البطاقات البنكية أو المحافظ الرقمية أو NetBanking في الخطوة التالية.';

  @override
  String get walkiePlan_orderEncryptedPayment => 'دفع إلكتروني مشفر';

  @override
  String get walkiePlan_orderEnterValidCoupon => 'يرجى إدخال رمز قسيمة صالح';

  @override
  String get walkiePlan_orderForMultipleMembers => 'لعدة أعضاء';

  @override
  String get walkiePlan_orderForSingleMember => 'لعضو واحد';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return 'ضريبة القيمة المضافة ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      'ادفع بأمان باستخدام بطاقات الائتمان/الخصم الدولية (Visa, Mastercard, Amex).';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      'ادفع بأمان باستخدام بطاقات الائتمان/الخصم الدولية أو PayPal.';

  @override
  String get walkiePlan_orderInvalidCoupon =>
      'رمز القسيمة غير صالح أو منتهي الصلاحية';

  @override
  String walkiePlan_orderMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'الأعضاء';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو × $rate',
      many: '$count عضوًا × $rate',
      few: '$count أعضاء × $rate',
      two: 'عضوان × $rate',
      one: 'عضو واحد × $rate',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderNetBanking => 'الخدمات المصرفية عبر الإنترنت';

  @override
  String get walkiePlan_orderOnlineViaRazorpay => 'دفع إلكتروني عبر Razorpay';

  @override
  String get walkiePlan_orderOpeningCheckout =>
      'جاري فتح نافذة الدفع Razorpay...';

  @override
  String get walkiePlan_orderPaymentDetails => 'تفاصيل الدفع';

  @override
  String get walkiePlan_orderPaymentMethod => 'طريقة الدفع';

  @override
  String get walkiePlan_orderPricePerMember => 'السعر لكل عضو';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return 'متابعة الدفع • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => 'جاري معالجة عملية الدفع...';

  @override
  String get walkiePlan_orderRetryPay => 'إعادة محاولة الدفع';

  @override
  String get walkiePlan_orderSecureBadge => 'آمن';

  @override
  String get walkiePlan_orderSubtitle => 'راجع تفاصيل باقتك وتابع لإتمام الدفع';

  @override
  String get walkiePlan_orderSubtotal => 'المجموع الفرعي';

  @override
  String get walkiePlan_orderTaxExport => 'الضريبة (0٪ تصدير)';

  @override
  String get walkiePlan_orderTermsConditions => 'الشروط والأحكام';

  @override
  String get walkiePlan_orderTitle => 'ملخص الطلب';

  @override
  String get walkiePlan_orderTotalAmount => 'المبلغ الإجمالي';

  @override
  String get walkiePlan_orderTotalPayable => 'المجموع الكلي المطلوب';

  @override
  String get walkiePlan_orderUnableToLoad => 'تعذر تحميل ملخص الطلب.';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / رمز QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return 'ضريبة القيمة المضافة ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => 'المحافظ الإلكترونية';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return 'لقد وفرت $amount في هذا الطلب!';
  }

  @override
  String get walkiePlan_payAnnualPlan => 'الباقة السنوية';

  @override
  String get walkiePlan_payBadgeCompleted => 'مكتمل';

  @override
  String get walkiePlan_payBadgeInProgress => 'قيد المعالجة';

  @override
  String get walkiePlan_payBadgePending => 'معلق';

  @override
  String get walkiePlan_payCancelledByUser =>
      'تم إلغاء الدفع من قِبل المستخدم. لم يتم خصم أي مبالغ من حسابك.';

  @override
  String get walkiePlan_payCouldNotBeProcessed => 'تعذر معالجة الدفع';

  @override
  String get walkiePlan_payFailedContactSupport => 'الاتصال بالدعم الفني';

  @override
  String walkiePlan_payFailedOn(String time) {
    return 'فشل الدفع في $time';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'تعذر إكمال عملية الدفع.\nيرجى المحاولة مرة أخرى أو اختيار طريقة دفع أخرى.';

  @override
  String get walkiePlan_payFailedSubtitleShort => 'تعذر إكمال عملية الدفع';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      'هل تحتاج مساعدة في الدفع؟ فريقنا متاح على مدار الساعة لمساعدتك.';

  @override
  String get walkiePlan_payFailedTitle => 'فشلت عملية الدفع';

  @override
  String get walkiePlan_payIndividualFeatures => 'مراقبة فورية • تنبيهات لحظية';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return 'تم بدء الدفع في $time';
  }

  @override
  String get walkiePlan_payIntervalMonth => 'شهر';

  @override
  String get walkiePlan_payIntervalPlan => 'باقة';

  @override
  String get walkiePlan_payIntervalQuarter => 'ربع سنة';

  @override
  String get walkiePlan_payIntervalYear => 'سنة';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'بطاقة ائتمان ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'بطاقة خصم ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational => 'بطاقة دولية / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'الخدمات المصرفية ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'دفع Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'شاشة دفع Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / بطاقة)';

  @override
  String get walkiePlan_payMethodUpi => 'دفع عبر UPI';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'محفظة ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue =>
      'حدث انقطاع في الاتصال أثناء الدفع. يرجى التحقق من الشبكة والمحاولة مجدداً.';

  @override
  String get walkiePlan_payNotCompleted =>
      'لم تكتمل عملية الدفع. لم يتم خصم أي مبلغ من رصيدك.';

  @override
  String get walkiePlan_payOtpCharge => 'رسوم رمز التحقق';

  @override
  String get walkiePlan_payOtpChargeDetails => 'تفاصيل رسوم رمز التحقق';

  @override
  String get walkiePlan_payOtpChargedPerLogin =>
      'يتم التحصيل لكل عملية دخول. إعادة الإرسال مجانية';

  @override
  String get walkiePlan_payOtpCharges => 'رسوم OTP';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'يرجى عدم إغلاق التطبيق. سنرسل لك إشعارًا فور تأكيد الدفع وتفعيل باقتك.';

  @override
  String get walkiePlan_payPendingStillInProgress =>
      'الدفع لا يزال قيد المعالجة. سنقوم بالتحديث فور التأكيد.';

  @override
  String get walkiePlan_payPendingStillProcessing =>
      'حالة الدفع لا تزال قيد المعالجة. يرجى الانتظار قليلاً.';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      'يقوم مزود خدمة الدفع بمعالجة معاملتك الآن.\nقد يستغرق ذلك بضع دقائق.';

  @override
  String get walkiePlan_payPendingSubtitleShort => 'جاري معالجة دفعتك الآن';

  @override
  String get walkiePlan_payPendingTitle => 'الدفع معلق';

  @override
  String get walkiePlan_payPlanDetails => 'تفاصيل الباقة';

  @override
  String get walkiePlan_payRefreshStatus => 'تحديث الحالة';

  @override
  String get walkiePlan_payStatusTitle => 'حالة الدفع';

  @override
  String get walkiePlan_payStepActivate => 'تفعيل الباقة';

  @override
  String get walkiePlan_payStepActivateSub =>
      'سيتم تفعيل باقتك تلقائيًا فور اكتمال الدفع';

  @override
  String get walkiePlan_payStepInitiated => 'تم بدء الدفع';

  @override
  String get walkiePlan_payStepProcessing => 'معالجة الدفع';

  @override
  String get walkiePlan_payStepProcessingSub => 'جاري تأكيد معاملتك المالية';

  @override
  String get walkiePlan_payTeamFeatures => 'وصول لعدة أعضاء • تنبيهات فورية';

  @override
  String get walkiePlan_payTotalPerOtp => 'الإجمالي لكل رمز';

  @override
  String get walkiePlan_payTryAgain => 'حاول مرة أخرى';

  @override
  String get walkiePlan_payViewPlanDetails => 'عرض تفاصيل الباقة';

  @override
  String get walkiePlan_perMember => 'لكل عضو';

  @override
  String get walkiePlan_planFallback => 'الباقة';

  @override
  String get walkiePlan_quarterlyPlan => 'الباقة الربع سنوية';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'يرجى إكمال المعاملة داخل نافذة دفع Razorpay.';

  @override
  String get walkiePlan_razorpayCompletePayment => 'إتمام الدفع';

  @override
  String get walkiePlan_razorpayConfirmingWithBank =>
      'تم بدء الدفع. جاري تأكيد المعاملة مع البنك.';

  @override
  String get walkiePlan_razorpayConnecting => 'جاري الاتصال بـ Razorpay...';

  @override
  String get walkiePlan_razorpayCouldNotProcess =>
      'تعذر معالجة عملية الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get walkiePlan_razorpayFailedTryAgain =>
      'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get walkiePlan_razorpayOneMonthActive => 'نشط لمدة شهر واحد';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return 'دفع $amount عبر Razorpay';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => 'تم إلغاء الدفع';

  @override
  String get walkiePlan_razorpayPaymentIdCopied =>
      'تم نسخ معرف الدفع إلى الحافظة!';

  @override
  String get walkiePlan_razorpayPciCompliant =>
      'آمن 100٪ ومتوافق مع معايير PCI-DSS';

  @override
  String get walkiePlan_razorpayPendingConfirmation =>
      'الدفع معلق بانتظار التأكيد النهائي.';

  @override
  String get walkiePlan_razorpayProcessing => 'جاري المعالجة عبر Razorpay...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return 'المبلغ: $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied =>
      'تم نسخ تفاصيل الإيصال إلى الحافظة!';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return 'التاريخ: $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return 'طريقة الدفع: $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return 'رقم الطلب: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return 'معرف الدفع: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'الباقة: $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => 'الحالة: مكتمل';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'إيصال دفع FG Tracker';

  @override
  String get walkiePlan_razorpayRetryPayment => 'إعادة المحاولة';

  @override
  String get walkiePlan_razorpaySecureCheckout => 'دفع آمن مدعوم من Razorpay';

  @override
  String get walkiePlan_razorpaySslEncrypted =>
      'المعاملات مشفرة بأمان SSL عالي المستوى 256 بت.';

  @override
  String get walkiePlan_razorpaySupportedModes => 'طرق الدفع المدعومة';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => 'إجمالي المبلغ المستحق';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return 'تعذر تشغيل بوابة الدفع: $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed => 'فشل التحقق من صحة الدفع.';

  @override
  String get walkiePlan_seatAssignedSeat => 'مقعد مخصص';

  @override
  String get walkiePlan_seatAssignment => 'تخصيص المقاعد';

  @override
  String get walkiePlan_seatTeamAccess => 'صلاحية الفريق';

  @override
  String get walkiePlan_seatTeamMember => 'عضو في الفريق';

  @override
  String get walkiePlan_secureEncryptedPayment => 'دفع آمن ومشفر بنسبة 100٪';

  @override
  String get walkiePlan_successAccessActivated => 'تم تفعيل الصلاحية';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      'صلاحية استخدام اللاسلكي الشخصية مفعلة الآن.';

  @override
  String get walkiePlan_successAmountPaid => 'المبلغ المدفوع';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'يمكنك تعيين صلاحيات اللاسلكي لاحقاً في أي وقت من إعدادات الفريق.';

  @override
  String get walkiePlan_successAssignMembers => 'تعيين الأعضاء';

  @override
  String get walkiePlan_successAssignWalkieAccess => 'تعيين صلاحيات اللاسلكي';

  @override
  String get walkiePlan_successChooseMembersDesc =>
      'اختر الأعضاء المخولين باستخدام اللاسلكي.';

  @override
  String get walkiePlan_successContinueHome => 'المتابعة إلى الرئيسية';

  @override
  String get walkiePlan_successDateTime => 'التاريخ والوقت';

  @override
  String get walkiePlan_successDefaultPaymentMethod => 'Razorpay (UPI / بطاقة)';

  @override
  String get walkiePlan_successIndividualActive => 'باقتك الفردية مفعلة الآن';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      'باقتك الفردية نشطة الآن. توجه إلى الشاشة الرئيسية وابدأ التحدث فوراً.';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      'اشتراكك الفردي مفعل الآن ومرتبط مباشرة بحسابك الشخصي.';

  @override
  String get walkiePlan_successManageAccessNote =>
      'يمكنك تعديل صلاحيات اللاسلكي في أي وقت من إعدادات الفريق.';

  @override
  String get walkiePlan_successMaybeLater => 'ربما لاحقاً';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'باقتك نشطة. لن يمتلك أعضاء الفريق حق استخدام اللاسلكي حتى تقوم بتعيينهم.';

  @override
  String get walkiePlan_successNotNow => 'ليس الآن؟';

  @override
  String get walkiePlan_successPaid => 'مدفوع';

  @override
  String get walkiePlan_successPaymentId => 'معرف الدفع';

  @override
  String get walkiePlan_successPaymentIdCopied =>
      'تم نسخ معرف الدفع إلى الحافظة!';

  @override
  String get walkiePlan_successPaymentMode => 'طريقة الدفع';

  @override
  String get walkiePlan_successPaymentReceipt => 'إيصال الدفع';

  @override
  String get walkiePlan_successPushToTalkDesc =>
      'اضغط للتحدث وتواصل فورياً مع فريقك.';

  @override
  String get walkiePlan_successRazorpayVerified => 'معتمد ومؤكد عبر Razorpay';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return 'المبلغ: $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied =>
      'تم نسخ تفاصيل الإيصال إلى الحافظة!';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'إيصال دفع FG Tracker';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return 'رقم الطلب: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return 'معرف الدفع: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return 'طريقة الدفع: $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'الباقة: $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => 'الحالة: مكتمل';

  @override
  String get walkiePlan_successSelectChannel => 'اختيار القناة';

  @override
  String get walkiePlan_successSelectChannelDesc =>
      'انضم لأي مجموعة أو قناة للتواصل مع الأعضاء.';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'حدد أعضاء الفريق المصرح لهم باستخدام ميزة اللاسلكي.';

  @override
  String get walkiePlan_successSetUpTeam => 'إعداد الفريق';

  @override
  String get walkiePlan_successSetUpTeamDesc =>
      'دعوة الأعضاء وإدارة الأدوار والصلاحيات.';

  @override
  String get walkiePlan_successShareReceipt => 'مشاركة الإيصال';

  @override
  String get walkiePlan_successStartCommunicating => 'ابدأ التواصل الآن';

  @override
  String get walkiePlan_successStatus => 'الحالة';

  @override
  String get walkiePlan_successSuccessful => 'ناجح';

  @override
  String get walkiePlan_successTeamActive => 'باقة فريقك مفعلة الآن';

  @override
  String get walkiePlan_successTeamReady => 'فريقك جاهز الآن!';

  @override
  String get walkiePlan_successTitle => 'تمت عملية الشراء بنجاح!';

  @override
  String walkiePlan_successValidTill(String date) {
    return 'صالح حتى $date';
  }

  @override
  String get walkiePlan_successVisitHome => 'الذهاب للشاشة الرئيسية';

  @override
  String get walkiePlan_successWhatsNext => 'ما هي الخطوة التالية؟';

  @override
  String get walkiePlan_teamPlan => 'باقة الفريق';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'باقة الفريق ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => 'فترة تجريبية لمدة 7 أيام';

  @override
  String get walkiePlan_trialActiveLabel => 'التجربة مفعلة';

  @override
  String get walkiePlan_trialActiveSubscription => 'اشتراك نشط';

  @override
  String get walkiePlan_trialActiveSubscriptions => 'الاشتراكات النشطة';

  @override
  String get walkiePlan_trialAvailableToStart => 'جاهز للبدء';

  @override
  String get walkiePlan_trialCheckConnectionRetry =>
      'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'اختر باقة من الأسفل للبدء في استخدام اللاسلكي.';

  @override
  String get walkiePlan_trialChooseSubscription =>
      'اختر باقة اشتراك لمتابعة استخدام ميزة اللاسلكي.';

  @override
  String get walkiePlan_trialCompleted => 'اكتملت التجربة';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متبقٍ',
      many: '$count يوماً متبقياً',
      few: '$count أيام متبقية',
      two: 'يومان متبقيان',
      one: 'يوم واحد متبقٍ',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration مجاناً';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return 'انتهى في $date';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return 'استمتع بجميع ميزات اللاسلكي مجانًا لمدة $duration.\nدون الحاجة إلى الدفع.';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      'استمتع بميزة اللاسلكي طوال فترة التجربة المجانية النشطة.';

  @override
  String get walkiePlan_trialErrAccessMissing =>
      'معلومات صلاحية استخدام اللاسلكي مفقودة.';

  @override
  String get walkiePlan_trialErrFetchDetails => 'تعذر جلب تفاصيل اللاسلكي.';

  @override
  String get walkiePlan_trialErrInvalidResponse =>
      'تم استلام استجابة غير صالحة من الخادم.';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مجدداً.';

  @override
  String get walkiePlan_trialErrOverviewMissing =>
      'بيانات نظرة عامة على اللاسلكي مفقودة.';

  @override
  String get walkiePlan_trialErrTimeout =>
      'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get walkiePlan_trialErrUnableToLoad =>
      'تعذر تحميل تفاصيل اللاسلكي. يرجى التحقق من اتصالك.';

  @override
  String get walkiePlan_trialExpired => 'انتهت صلاحية التجربة';

  @override
  String get walkiePlan_trialExpiredLabel => 'انتهت التجربة';

  @override
  String get walkiePlan_trialExpiringSoon => 'تنتهي الصلاحية قريبًا';

  @override
  String get walkiePlan_trialFeatClearAudio => 'صوت نقي وواضح';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'جودة صوت فائقة النقاء';

  @override
  String get walkiePlan_trialFeatGroupComm => 'التواصل الجماعي';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => 'تواصل فوري مع فريقك';

  @override
  String get walkiePlan_trialFeatPtt => 'اضغط وتحدث (Push-to-talk)';

  @override
  String get walkiePlan_trialFeatPttDesc => 'تواصل صوتي فوري بضغطة زر';

  @override
  String get walkiePlan_trialFeatUnlimited => 'استخدام غير محدود';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => 'استخدم اللاسلكي بلا قيود';

  @override
  String get walkiePlan_trialFreeAvailable => 'تجربة مجانية متوفرة';

  @override
  String get walkiePlan_trialFreeTrialLabel => 'تجربة مجانية';

  @override
  String get walkiePlan_trialFreeTrialRunning => 'التجربة المجانية نشطة حالياً';

  @override
  String get walkiePlan_trialFullAccess => 'وصول كامل لجميع الميزات';

  @override
  String get walkiePlan_trialFullyConsumed =>
      'تم استهلاك كامل وقت التجربة المجانية الخاصة بك.';

  @override
  String get walkiePlan_trialHasEnded => 'انتهت فترتك التجريبية';

  @override
  String get walkiePlan_trialHeaderInstant => 'تواصل فوري ومباشر مع مجموعتك';

  @override
  String get walkiePlan_trialHeaderPlanStatus => 'حالة باقتك واشتراكك';

  @override
  String walkiePlan_trialHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ساعة',
      many: '$count ساعة',
      few: '$count ساعات',
      two: 'ساعتان',
      one: 'ساعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ساعة متبقية',
      many: '$count ساعة متبقية',
      few: '$count ساعات متبقية',
      two: 'ساعتان متبقيتان',
      one: 'ساعة واحدة متبقية',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHr(int count) {
    return '$count ساعة';
  }

  @override
  String walkiePlan_trialHrMin(int hours, int minutes) {
    return '$hours ساعة $minutes دقيقة';
  }

  @override
  String get walkiePlan_trialIsActive => 'فترتك التجريبية نشطة';

  @override
  String walkiePlan_trialMin(int count) {
    return '$count دقيقة';
  }

  @override
  String walkiePlan_trialMinSec(int minutes, int seconds) {
    return '$minutes دقيقة $seconds ثانية';
  }

  @override
  String walkiePlan_trialMinsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة متبقية',
      many: '$count دقيقة متبقية',
      few: '$count دقائق متبقية',
      two: 'دقيقتان متبقيتان',
      one: 'دقيقة واحدة متبقية',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_trialNoActivePlan => 'لا توجد باقة نشطة';

  @override
  String get walkiePlan_trialNoCardRequired =>
      'استخدمها في أي وقت خلال 7 أيام  •  لا يلزم وجود بطاقة بنكية';

  @override
  String get walkiePlan_trialNoInternetTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return 'لا يلزم أي دفع الآن. بعد انتهاء التجربة، يمكنك المتابعة في باقة مدفوعة ($price/شخص) إن أحببت.';
  }

  @override
  String get walkiePlan_trialPeriodMonth => 'شهر';

  @override
  String get walkiePlan_trialRetrying => 'جاري إعادة المحاولة...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count ثانية';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return 'ابدأ التجربة المجانية لمدة $duration';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial => 'ابدأ تجربتك المجانية';

  @override
  String get walkiePlan_trialStatusCompleted => 'مكتمل';

  @override
  String get walkiePlan_trialStatusExpired => 'منتهي';

  @override
  String get walkiePlan_trialSubscriptionActive => 'الاشتراك مفعل';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'انتهى اشتراك اللاسلكي الخاص بك. جدد باقتك لمواصلة التواصل مع الفريق.';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'انتهت صلاحية الاشتراك';

  @override
  String get walkiePlan_trialTalkFree => 'تحدث مجانًا مع مجموعتك.';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return 'تحدث مجانًا مع مجموعتك حتى تاريخ $date.';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg =>
      'لديك صلاحية استخدام اللاسلكي من خلال باقة الفريق.';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return 'متبقي $time';
  }

  @override
  String get walkiePlan_trialTimeRemaining => 'الوقت التجريبي المتبقي';

  @override
  String get walkiePlan_trialTimeUsedUp => 'استُنفد وقت التجربة';

  @override
  String get walkiePlan_trialTryAgain => 'حاول مجدداً';

  @override
  String get walkiePlan_trialUnableToLoadTitle => 'تعذر تحميل بيانات اللاسلكي';

  @override
  String get walkiePlan_trialUsage => 'استهلاك التجربة';

  @override
  String get walkiePlan_trialUseAnytime7Days =>
      'استخدم وقت التجربة في أي وقت خلال 7 أيام';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return 'استخدم باقة التجربة المجانية لمدة $duration في أي وقت خلال 7 أيام.';
  }

  @override
  String get walkiePlan_trialUsed => 'تم استهلاك التجربة';

  @override
  String get walkiePlan_trialValidityPeriod => 'فترة صلاحية التجربة';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'اللاسلكي (Walkie Talkie)';

  @override
  String get walkiePlan_trialWhatYouCanDo => 'ما يمكنك فعله خلال فترة التجربة';

  @override
  String get walkiePlan_unableToConnect =>
      'تعذر الاتصال بالخادم. يرجى المحاولة مرة أخرى.';

  @override
  String get walkiePlan_yearlyPlan => 'الباقة السنوية';

  @override
  String get walkie_aMember => 'عضو';

  @override
  String get walkie_accept => 'قبول';

  @override
  String get walkie_activeAccess => 'صلاحية نشطة';

  @override
  String get walkie_activeBadge => 'نشط';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نشطين في اللاسلكي',
      one: '1 نشط في اللاسلكي',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'عضو نشط';

  @override
  String get walkie_admin => 'مشرف';

  @override
  String get walkie_adminMuted => 'مشرف • مكتوم';

  @override
  String get walkie_adminOnlyAction => 'إجراء مخصص للمشرفين فقط';

  @override
  String get walkie_adminOnlyActionMessage =>
      'يمكن لمشرف المجموعة فقط إرسال تنبيهات الإشعارات إلى الأعضاء.';

  @override
  String walkie_alertSentMessage(String name) {
    return 'تم إرسال الإشعار إلى $name. يمكن إعادة المحاولة بعد 10 ثوانٍ.';
  }

  @override
  String get walkie_alertSentTitle => 'تم إرسال التنبيه';

  @override
  String get walkie_assignMembersToCommunicate =>
      'قم بتعيين أعضاء للتواصل في هذه المجموعة';

  @override
  String get walkie_assignedByYou => 'تم تعيينه بواسطتك';

  @override
  String walkie_assignedCount(int count) {
    return '$count تم تعيينهم';
  }

  @override
  String get walkie_assignedSeats => 'المقاعد المعينة';

  @override
  String get walkie_audioBluetooth => 'بلوتوث';

  @override
  String get walkie_audioHeadset => 'سماعة رأس';

  @override
  String get walkie_audioOutput => 'مخرج الصوت';

  @override
  String get walkie_audioPhone => 'الهاتف';

  @override
  String get walkie_audioSpeaker => 'مكبر الصوت';

  @override
  String get walkie_audioWiredHeadphones => 'سماعات سلكية';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return 'فتح القفل تلقائياً خلال $seconds ث';
  }

  @override
  String get walkie_availableMembers => 'الأعضاء المتاحون';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يمكنك تعيين ما يصل إلى $count أعضاء في هذه المجموعة',
      one: 'يمكنك تعيين عضو واحد في هذه المجموعة',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat =>
      'لا يمكن إزالة مقعد تم تعيينه بواسطة مشرف آخر';

  @override
  String get walkie_cannotSpeak => 'لا يمكن التحدث في هذه القناة';

  @override
  String get walkie_channelBusy => 'القناة مشغولة';

  @override
  String get walkie_channelLocked => 'القناة مقفلة';

  @override
  String get walkie_channelSpeaking => 'القناة تتحدث...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return 'تعذر تعيين $group كقناة تحدث نشطة.';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'خطأ في تبديل القناة';

  @override
  String get walkie_channelUnlocked => 'تم فتح قفل القناة';

  @override
  String get walkie_chat => 'دردشة';

  @override
  String get walkie_checkNetworkTryAgain =>
      'يرجى التحقق من اتصال الشبكة والمحاولة مرة أخرى.';

  @override
  String get walkie_chooseAPlan => 'اختر خطة';

  @override
  String get walkie_connected => 'متصل';

  @override
  String get walkie_connectedWaiting => 'متصل بالقناة • بانتظار انضمام الآخرين';

  @override
  String get walkie_connectingChannel => 'جارٍ الاتصال بالقناة...';

  @override
  String get walkie_consumingTrial => 'استهلاك الفترة التجريبية...';

  @override
  String get walkie_continueListenOnly => 'المتابعة في وضع الاستماع فقط';

  @override
  String walkie_currentlyAssigned(int count) {
    return 'تم تعيينهم حالياً ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'مجموعة اللاسلكي';

  @override
  String get walkie_description => 'الوصف';

  @override
  String get walkie_disconnected => 'غير متصل';

  @override
  String get walkie_editAssignedMembers => 'تعديل الأعضاء المعينين';

  @override
  String get walkie_enable => 'تفعيل';

  @override
  String walkie_errorWithDetails(String details) {
    return 'خطأ: $details';
  }

  @override
  String get walkie_exitWalkie => 'الخروج من اللاسلكي';

  @override
  String get walkie_exitWalkieMessage =>
      'سيتم قطع اتصالك بهذه القناة. ستظل عضواً في المجموعة.';

  @override
  String get walkie_exitWalkieTitle => 'الخروج من اللاسلكي؟';

  @override
  String get walkie_fairConnection => 'اتصال مقبول';

  @override
  String walkie_fairConnectionMs(int ms) {
    return 'اتصال مقبول ($ms م.ث)';
  }

  @override
  String get walkie_featureAllDevices => 'استخدمه على جميع الأجهزة';

  @override
  String get walkie_featureEasyCoordination => 'تنسيق جماعي سهل';

  @override
  String get walkie_featureHoldToTalk => 'اضغط مطولاً للتحدث';

  @override
  String get walkie_featurePtt => 'الضغط للتحدث';

  @override
  String get walkie_featureQuickGroup => 'اتصال جماعي سريع';

  @override
  String get walkie_featureRealtime => 'اتصال في الوقت الفعلي';

  @override
  String get walkie_featureSafeReliable => 'آمن وموثوق';

  @override
  String get walkie_featureStayConnected => 'ابقَ على اتصال دائم';

  @override
  String get walkie_featureTeamCommunication => 'تواصل الفريق';

  @override
  String get walkie_featureUnlimited => 'غير محدود';

  @override
  String get walkie_fieldTeam => 'فريق الميدان';

  @override
  String get walkie_freeTrialEnded => 'انتهت الفترة التجريبية';

  @override
  String get walkie_freeTrialEndedMessage =>
      'انتهت فترتك التجريبية المجانية لمدة ساعة واحدة للاسلكي.\nقم بالترقية الآن لمواصلة استخدام التواصل الجماعي مع فريقك.';

  @override
  String get walkie_freeTrialEndedTitle => 'انتهت الفترة التجريبية';

  @override
  String get walkie_genericError => 'خطأ في اللاسلكي';

  @override
  String get walkie_getPlan => 'الحصول على خطة';

  @override
  String walkie_goodConnectionMs(int ms) {
    return 'اتصال جيد ($ms م.ث)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'رمز المجموعة: $code';
  }

  @override
  String get walkie_groupCommunication => 'اتصالات المجموعة';

  @override
  String get walkie_groupFallback => 'المجموعة';

  @override
  String get walkie_groupMembers => 'أعضاء المجموعة';

  @override
  String get walkie_heroSubtitle =>
      'استخدم الاتصال الصوتي عبر الضغط للتحدث مع مجموعتك دون الحاجة لإجراء مكالمة هاتفية.';

  @override
  String get walkie_heroTitle => 'ابقَ على اتصال وتحدث فوراً';

  @override
  String get walkie_holdToTalk => 'اضغط مطولاً للتحدث';

  @override
  String get walkie_holdToTalkSlideLock =>
      'اضغط مطولاً للتحدث، واسحب للأعلى للقفل';

  @override
  String get walkie_inWalkieChannel => 'في قناة اللاسلكي';

  @override
  String get walkie_individualActiveUpgrade =>
      'الخطة الفردية نشطة (وصول ذاتي فقط) • قم بالترقية لخطة الفريق لتعيين الأعضاء.';

  @override
  String get walkie_individualLimitMessage =>
      'تتيح خطتك الفردية مقعداً واحداً فقط. لتعيين أعضاء متعددين وتوصيل فريقك بأكمله، يرجى الترقية إلى خطة الفريق.';

  @override
  String get walkie_individualPlan => 'خطة فردية';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (فردي)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      'خطة فردية (وصول ذاتي فقط) • قم بالترقية للفريق لتعيين الأعضاء';

  @override
  String get walkie_individualSubscribedSelf =>
      'خطة فردية • تم الاشتراك ذاتياً';

  @override
  String get walkie_info => 'معلومات';

  @override
  String walkie_isSpeaking(String name) {
    return '$name يتحدث الآن...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name يتحدث الآن...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'انضم $count',
      one: 'انضم 1',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return 'آخر ظهور $time';
  }

  @override
  String get walkie_listenOnly => 'استماع فقط';

  @override
  String get walkie_listenOnlyTapPlan => 'استماع فقط — اضغط لعرض الخطة';

  @override
  String get walkie_listening => 'استماع';

  @override
  String get walkie_listeningOnly => 'استماع فقط';

  @override
  String get walkie_live => 'مباشر';

  @override
  String get walkie_lockTimeout => 'انتهت مهلة القفل — تم تحرير الميكروفون';

  @override
  String get walkie_lockedTapMic => 'مقفل — اضغط على الميكروفون للإيقاف';

  @override
  String get walkie_maybeLater => 'ربما لاحقاً';

  @override
  String get walkie_member => 'عضو';

  @override
  String get walkie_membersInChannel => 'الأعضاء في القناة';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أعضاء متصلون',
      one: 'عضو متصل',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed => 'فشل تحديث الأعضاء المعينين';

  @override
  String get walkie_membersUpdated => 'تم تحديث الأعضاء المعينين بنجاح';

  @override
  String get walkie_micAccessRequired => 'مطلوب إذن الميكروفون للتحدث.';

  @override
  String get walkie_micDisabledMessage =>
      'الوصول إلى الميكروفون معطل في إعدادات الجهاز. للتحدث في هذه المجموعة، يرجى السماح بالوصول إلى الميكروفون في الإعدادات.\n\nلا يزال بإمكانك الاستماع إلى الأعضاء الآخرين.';

  @override
  String get walkie_micPermissionRequired => 'إذن الميكروفون مطلوب';

  @override
  String get walkie_micPermissionTitle => 'إذن الميكروفون';

  @override
  String get walkie_micRequiredMessage =>
      'مطلوب إذن الميكروفون للتحدث في مجموعة اللاسلكي هذه.\n\nلا يزال بإمكانك الاستماع للآخرين دون تفعيل الميكروفون.';

  @override
  String get walkie_muteMe => 'كتم صوتي';

  @override
  String get walkie_muted => 'مكتوم';

  @override
  String get walkie_mutedInWalkie => 'مكتوم • في اللاسلكي';

  @override
  String get walkie_mutedListeningOnly => 'أنت مكتوم — استماع فقط';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name يتحدث...';
  }

  @override
  String get walkie_noActivePlan => 'لا توجد خطة نشطة';

  @override
  String get walkie_noAvailableMembers => 'لا يوجد أعضاء متاحون';

  @override
  String get walkie_noBluetoothDevice =>
      'لا يوجد جهاز بلوتوث متصل. يرجى إقران سماعة الرأس في الإعدادات.';

  @override
  String get walkie_noGroupsFound => 'لم يتم العثور على مجموعات';

  @override
  String get walkie_noMembersAssigned => 'لم يتم تعيين أي أعضاء حالياً';

  @override
  String get walkie_noMembersFound => 'لم يتم العثور على أعضاء';

  @override
  String get walkie_noMembersFoundTitle => 'لم يتم العثور على أعضاء';

  @override
  String get walkie_noMembersMatch => 'لا يوجد أعضاء مطابقون';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return 'لا يوجد أعضاء مطابقون لـ \'$query\'';
  }

  @override
  String get walkie_noMembersToAssign =>
      'لا يوجد أعضاء متاحون للتعيين في المجموعة.';

  @override
  String get walkie_noNameGroup => 'مجموعة بدون اسم';

  @override
  String get walkie_noPlanSubscribeAssign =>
      'لا توجد خطة نشطة • اشترك لتعيين الأعضاء';

  @override
  String get walkie_noSeatMessage =>
      'لديك خطة فريق نشطة، ولكن تم تعيين جميع المقاعد الصوتية النشطة حالياً لأعضاء آخرين في الفريق.\n\nيمكنك الاستماع إلى محادثات المجموعة في الوقت الفعلي، ولكن للتحدث، يجب عليك تعيين مقعد لنفسك أو ترقية خطتك.';

  @override
  String get walkie_noSeatTitle => 'لم يتم تعيين مقعد صوتي';

  @override
  String get walkie_noSeatsRefreshing =>
      'لا تتوفر مقاعد فريق. جارٍ تحديث القائمة...';

  @override
  String get walkie_noSubscriptionMessage =>
      'ليس لديك اشتراك نشط في اللاسلكي. اشترك في خطة لتعيين الأعضاء وبدء الاتصال الصوتي الفوري.';

  @override
  String get walkie_noTeamSubscription => 'لم يتم العثور على اشتراك فريق نشط';

  @override
  String get walkie_noValidMembers => 'لم يتم تحديد أعضاء صالحين لتعيينهم';

  @override
  String get walkie_noVoiceSeatListenOnly =>
      'لم يتم تعيين مقعد صوتي — أنت في وضع الاستماع فقط';

  @override
  String get walkie_noWiredDevice =>
      'لا توجد سماعات رأس سلكية متصلة. يرجى توصيلها بجهازك.';

  @override
  String get walkie_notConnected => 'غير متصل';

  @override
  String get walkie_notifLeave => 'مغادرة';

  @override
  String get walkie_notifOpenWalkie => 'فتح اللاسلكي';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name توقف عن التحدث';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name يتحدث الآن';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return 'تعذر تحديث إعداد الإشعارات للمجموعة $group. يرجى المحاولة مرة أخرى.';
  }

  @override
  String get walkie_notificationSettingTitle => 'إعدادات الإشعارات';

  @override
  String get walkie_onlyAdminCanAlert =>
      'يمكن لمشرف المجموعة فقط إرسال تنبيهات';

  @override
  String get walkie_openWalkieTalkie => 'فتح اللاسلكي';

  @override
  String get walkie_otherTeam => 'فريق آخر';

  @override
  String get walkie_othersWontHear => 'لن يسمعك الآخرون';

  @override
  String get walkie_planRequiredTitle => 'مطلوب خطة لاسلكي';

  @override
  String get walkie_planRequiredToTalk => 'الخطة مطلوبة للتحدث';

  @override
  String get walkie_planStartsOnFirstAssign => 'تبدأ الخطة عند تعيين أول عضو.';

  @override
  String get walkie_poorConnection => 'اتصال ضعيف — قد يتأخر الصوت';

  @override
  String get walkie_preparingAudio => 'جارٍ تجهيز الصوت...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'اشترِ خطة فريق لتعيين صلاحية استخدام اللاسلكي للأعضاء.';

  @override
  String get walkie_purchaseUpgradePlan => 'شراء / ترقية الخطة';

  @override
  String get walkie_ready => 'جاهز';

  @override
  String get walkie_reconnecting => 'جارٍ إعادة الاتصال...';

  @override
  String get walkie_reconnectingServer =>
      'جارٍ إعادة الاتصال بخادم اللاسلكي...';

  @override
  String get walkie_releaseToStop => 'اترك للإيقاف';

  @override
  String get walkie_removeAll => 'إزالة الكل';

  @override
  String get walkie_searchGroups => 'بحث في المجموعات';

  @override
  String get walkie_searchMembers => 'بحث في الأعضاء...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total مقاعد';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '$total إجمالي المقاعد • $assigned معين • $available متاح';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return 'تم استخدام $assigned / $total مقعد';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds ث';
  }

  @override
  String get walkie_selectAtLeastOne => 'يرجى تحديد عضو واحد على الأقل لتعيينه';

  @override
  String get walkie_selectGroupFirst => 'يرجى تحديد مجموعة أولاً';

  @override
  String get walkie_selectGroupToConnect => 'حدد مجموعة للاتصال بها';

  @override
  String get walkie_selected => 'محدد';

  @override
  String get walkie_selfAccess => 'وصول ذاتي';

  @override
  String get walkie_selfPlan => 'خطة ذاتية';

  @override
  String get walkie_slideUpToLock => 'اسحب للأعلى للقفل';

  @override
  String get walkie_someone => 'شخص ما';

  @override
  String get walkie_someoneSpeaking => 'شخص ما يتحدث...';

  @override
  String get walkie_speaking => 'يتحدث...';

  @override
  String walkie_startFreeTrial(String duration) {
    return 'بدء فترة تجريبية مجانية لمدة $duration';
  }

  @override
  String get walkie_strongConnection => 'اتصال قوي';

  @override
  String walkie_strongConnectionMs(int ms) {
    return 'اتصال قوي ($ms م.ث)';
  }

  @override
  String get walkie_subscribeToStartTalk =>
      'اشترك لبدء التحدث الصوتي وتعيين الأعضاء';

  @override
  String get walkie_subscribed => 'مشترك';

  @override
  String get walkie_talking => 'يتحدث...';

  @override
  String get walkie_tapToUnlock => 'اضغط لفتح القفل';

  @override
  String get walkie_teamAssignedElsewhere =>
      'خطة الفريق • تم التعيين في مكان آخر';

  @override
  String get walkie_teamPlan => 'خطة الفريق';

  @override
  String get walkie_teamPlanRequired => 'مطلوب خطة فريق';

  @override
  String get walkie_teamPlanRequiredToAssign => 'مطلوب خطة فريق لتعيين الأعضاء';

  @override
  String get walkie_teamPlanStatus => 'حالة خطة الفريق';

  @override
  String get walkie_teamSeatMember => 'عضو بمقعد الفريق';

  @override
  String get walkie_title => 'لاسلكي';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجمالي',
      one: '1 إجمالي',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => 'فترة تجريبية نشطة لمدة ساعة';

  @override
  String get walkie_trialEndedSubscribe =>
      'انتهت الفترة التجريبية — يرجى الاشتراك للمتابعة';

  @override
  String get walkie_unableToConnectReconnecting =>
      'تعذر الاتصال بالقناة — جارٍ إعادة الاتصال...';

  @override
  String get walkie_unavailable => 'غير متاح';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'تحديث الأعضاء ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'جارٍ تحديث الأعضاء...';

  @override
  String get walkie_upgradeAddSeats => 'ترقية وإضافة مقاعد';

  @override
  String get walkie_upgradeNow => 'الترقية الآن';

  @override
  String get walkie_upgradeTeamAssign => 'الترقية لخطة الفريق (تعيين الأعضاء)';

  @override
  String get walkie_upgradeToTeamPlan => 'الترقية إلى خطة الفريق';

  @override
  String walkie_userCancelled(String name) {
    return 'ألغى $name';
  }

  @override
  String walkie_userJoined(String name) {
    return 'انضم $name';
  }

  @override
  String walkie_userLeft(String name) {
    return 'غادر $name';
  }

  @override
  String walkie_validTill(String date) {
    return 'صالح حتى $date';
  }

  @override
  String get walkie_viewPlan => 'عرض الخطة';

  @override
  String get walkie_voiceNotPermitted => 'إرسال الصوت غير مسموح به';

  @override
  String get walkie_weakSignal => 'إشارة ضعيفة';

  @override
  String walkie_weakSignalMs(int ms) {
    return 'إشارة ضعيفة ($ms م.ث)';
  }

  @override
  String get walkie_youAreConnected => 'أنت متصل الآن';

  @override
  String get walkie_yourVoiceAccess => 'صلاحية الصوت الخاصة بك';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'تحميل لنظام Android: $playStoreLink\n\nتحميل لنظام iOS: $appStoreLink';
  }

  @override
  String get widget_live => 'مباشر';

  @override
  String get widget_lostConnection => 'انقطع الاتصال';

  @override
  String get widget_manageGroups => 'إدارة مجموعاتك بكل سهولة';

  @override
  String get widget_noInternetBody =>
      'عفوًا... لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة';

  @override
  String get widget_notSeenYet => 'لم تتم المشاهدة بعد';

  @override
  String get widget_pinnedMessage => 'رسالة مثبتة';

  @override
  String get widget_private => 'خاص';

  @override
  String get widget_refreshPage => 'إعادة تحديث الصفحة';

  @override
  String get widget_seen => 'تمت المشاهدة';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count من $total)';
  }

  @override
  String get widget_somethingWentWrongTitle => 'حدث خطأ ما';

  @override
  String get widget_userFallback => 'مستخدم';
}
