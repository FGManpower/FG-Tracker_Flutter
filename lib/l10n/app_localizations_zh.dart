// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get about_aboutUs => '关于我们';

  @override
  String get about_address => '地址';

  @override
  String get about_appBarTitle => '关于 FG Tracker';

  @override
  String get about_company => '公司';

  @override
  String get about_contactUs => '联系我们';

  @override
  String get about_developerEmail => '开发者邮箱';

  @override
  String get about_downloadTitle => '📱 下载应用';

  @override
  String get about_howItWorksIntro => 'FG Tracker 让团队出行协作变得简单轻松。操作如下：';

  @override
  String get about_howItWorksTitle => '⚙️ 使用说明';

  @override
  String get about_howStep1 => '创建群组';

  @override
  String get about_howStep2 => '与同行人员分享群组代码或二维码';

  @override
  String get about_howStep3 => '每个成员使用分享的代码或二维码加入';

  @override
  String get about_howStep4 => '在共享地图上实时查看每个人的当前位置';

  @override
  String get about_howStep5 => '使用分享功能轻松邀请更多人加入';

  @override
  String get about_intro =>
      'FG Tracker 是您在团队出行时保持联系与安全的首选伴侣。无论是家庭自驾游、朋友野餐还是同事同行，FG Tracker 都能确保没有人掉队。';

  @override
  String get about_privacyBody =>
      '您的安全与隐私至关重要。FG Tracker 绝不会向群组以外的任何人共享您的位置。所有数据均经过加密，仅与您授权的人员共享。';

  @override
  String get about_privacyPolicy => '隐私政策';

  @override
  String get about_privacyTitle => '🔐 隐私与安全';

  @override
  String get about_supportEmail => '支持邮箱';

  @override
  String get about_supportTitle => '📩 支持与开发者信息';

  @override
  String get about_termsConditions => '条款与条件';

  @override
  String get about_title => '关于';

  @override
  String get about_website => '官网';

  @override
  String get about_welcomeTitle => '欢迎使用 FG Tracker';

  @override
  String get about_whyBuiltFor => '专为家庭、朋友和小型团队打造。';

  @override
  String get about_whyChooseTitle => '🌟 为什么选择 FG Tracker？';

  @override
  String get about_whyEasy => '轻量易用，并具备完善的隐私控制。';

  @override
  String get about_whyNoCalls => '无需频繁通话或发短信，直接在地图上实时追踪。';

  @override
  String get about_whyRealTime => '与所有群组成员进行实时位置共享。';

  @override
  String appUpdate_checkError(String error) {
    return '检查更新失败：$error';
  }

  @override
  String get appUpdate_exitConfirmTitle => '确定要退出吗？';

  @override
  String get appUpdate_noUpdateAvailable => '暂无可用更新';

  @override
  String get appUpdate_restartApp => '重启应用';

  @override
  String get appUpdate_updateApp => '更新应用';

  @override
  String get appUpdate_updateAvailable => '发现新版本';

  @override
  String get appUpdate_updateAvailableMessage => '有可用更新，请及时更新应用';

  @override
  String get appUpdate_updateUnavailable => '更新不可用';

  @override
  String appUpdate_updatingProgress(int progress) {
    return '正在更新... $progress%';
  }

  @override
  String get attendance_addOption => '添加其他选项';

  @override
  String get attendance_admin => '管理员';

  @override
  String get attendance_allowChange => '允许更改回答';

  @override
  String get attendance_allowChangeSubtitle => '成员可以更改或撤销其回答';

  @override
  String get attendance_askCommunity => '询问您的团队社区';

  @override
  String get attendance_cameraPermissionRequired => '标记考勤需要相机权限。';

  @override
  String get attendance_cameraStartFailed => '无法启动相机。';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return '无法启动相机 ($code)。';
  }

  @override
  String get attendance_cameraStarting => '正在启动相机…';

  @override
  String get attendance_captureFailedBlink => '未能捕获。请再次眨眼以重试';

  @override
  String attendance_capturedAtVerified(String time) {
    return '于 $time 拍摄 • 已验证';
  }

  @override
  String get attendance_capturedCheck => '已捕获 ✓';

  @override
  String get attendance_changeResponse => '更改回答';

  @override
  String get attendance_chooseFolder => '选择文件夹，例如下载';

  @override
  String get attendance_closeAction => '关闭考勤';

  @override
  String get attendance_closeConfirmBody => '关闭后成员将无法再提交回答。';

  @override
  String get attendance_closeConfirmTitle => '关闭考勤？';

  @override
  String get attendance_closeEndOfDay => '在当天结束时关闭';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return '今天将在 $time 自动关闭';
  }

  @override
  String get attendance_closeFailed => '无法关闭考勤';

  @override
  String get attendance_closeFailedShort => '无法关闭';

  @override
  String attendance_closesAt(String dateTime) {
    return '截止于 $dateTime';
  }

  @override
  String get attendance_createFailed => '无法创建考勤';

  @override
  String get attendance_createSubtitle => '向此群组发送考勤投票';

  @override
  String get attendance_createTitle => '创建考勤';

  @override
  String get attendance_created => '考勤已创建';

  @override
  String get attendance_dateEnded => '所选日期已结束。请选择其他日期或关闭自动结束。';

  @override
  String get attendance_dateToday => '日期（今天）';

  @override
  String get attendance_dateTodaySemantics => '考勤日期，今天';

  @override
  String get attendance_deleteFailed => '无法删除考勤';

  @override
  String get attendance_deletedText => '此考勤记录已删除';

  @override
  String get attendance_downloadReport => '下载报告';

  @override
  String get attendance_everyoneResponded => '所有人均已回答';

  @override
  String get attendance_faceDetectedBlink => '已检测到面部 — 请眨眼';

  @override
  String get attendance_failed => '考勤失败';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return '未回答 ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return '已回答 ($count)';
  }

  @override
  String get attendance_fixErrors => '请在提交前修正高亮显示的错误';

  @override
  String get attendance_holdStill => '请保持静止…';

  @override
  String get attendance_howToTakePhoto => '如何拍摄照片';

  @override
  String get attendance_invalidGroup => '无效群组，请重新打开聊天。';

  @override
  String get attendance_keepFaceInCircle => '请将面部保持在圆圈内';

  @override
  String get attendance_limitReached => '已达上限';

  @override
  String get attendance_loadFailed => '无法加载考勤';

  @override
  String get attendance_loadMore => '加载更多';

  @override
  String get attendance_loadMoreFailed => '无法加载更多';

  @override
  String get attendance_loadVotersFailed => '无法加载投票者';

  @override
  String get attendance_lookAtCamera => '请注视摄像头';

  @override
  String get attendance_lookStraight => '请正视摄像头';

  @override
  String get attendance_markYourAttendance => '标记您的考勤';

  @override
  String attendance_markedAs(String option) {
    return '已标记为 $option';
  }

  @override
  String get attendance_markedSuccess => '考勤标记成功';

  @override
  String attendance_maxOptions(int count) {
    return '最多只能添加 $count 个选项';
  }

  @override
  String get attendance_members => '成员';

  @override
  String attendance_membersWithCount(int count) {
    return '成员 ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return '至少需要 $count 个选项';
  }

  @override
  String get attendance_moveCloser => '请稍微靠近一些';

  @override
  String get attendance_multipleFaces => '检测到多张面孔 — 画面中应仅有您一人';

  @override
  String get attendance_noCsvApp => '未找到可打开 CSV 文件的应用。请使用保存或分享。';

  @override
  String get attendance_noFace => '未检测到面部';

  @override
  String get attendance_noFrontCamera => '此设备上未找到前置摄像头。';

  @override
  String get attendance_noLocation => '无可用位置信息';

  @override
  String get attendance_noMembersMatch => '没有匹配的成员';

  @override
  String get attendance_noResponses => '暂无回答';

  @override
  String get attendance_notResponded => '未回答';

  @override
  String get attendance_openEyes => '睁开双眼并注视摄像头';

  @override
  String get attendance_openMapFailed => '无法打开地图';

  @override
  String get attendance_openSubtitle => '在 Excel、表格或其他应用中查看';

  @override
  String get attendance_optionHint => '输入选项名称';

  @override
  String get attendance_optionLabelRequired => '所有选项都必须有名称';

  @override
  String attendance_optionNumber(int number) {
    return '选项 $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return '选项 $number • 📷 需要照片';
  }

  @override
  String get attendance_optionsUnique => '选项不能重复';

  @override
  String get attendance_photoCaptured => '照片已捕获';

  @override
  String get attendance_photoCapturedTapRetake => '照片已捕获 ✓（点击重拍）';

  @override
  String get attendance_photoProof => '照片凭证';

  @override
  String attendance_photoProofOf(String name) {
    return '$name 的照片凭证';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ $option 需要拍摄照片';
  }

  @override
  String get attendance_photoRules => '仅使用前置摄像头。眨眼时将自动拍照，禁止从相册上传。';

  @override
  String get attendance_photoSubtitle => '拍摄实时照片以验证您的考勤';

  @override
  String get attendance_photoTitle => '考勤照片';

  @override
  String get attendance_photoVerified => '照片已验证';

  @override
  String get attendance_questionHint => '您今天能参加吗？';

  @override
  String get attendance_questionLabel => '考勤问题';

  @override
  String get attendance_questionRequired => '考勤问题为必填项';

  @override
  String attendance_questionTooShort(int count) {
    return '问题至少需要 $count 个字符';
  }

  @override
  String get attendance_removeFailedShort => '无法撤销';

  @override
  String get attendance_removeResponseBody => '您在此投票中的考勤记录将被清除。';

  @override
  String get attendance_removeResponseTitle => '撤回您的回答吗？';

  @override
  String get attendance_removeVoteFailed => '无法撤销投票';

  @override
  String get attendance_reportEmpty => '报告为空';

  @override
  String get attendance_reportFailed => '报告生成失败';

  @override
  String get attendance_reportInvalid => '服务器返回了无效的报告，请重试。';

  @override
  String attendance_reportReady(String fileName) {
    return '报告已就绪 • $fileName';
  }

  @override
  String get attendance_reportSaved => '报告已保存';

  @override
  String get attendance_reportSubject => '考勤报告';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return '考勤报告 • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count 人已回答';
  }

  @override
  String get attendance_retakePhoto => '重新拍照';

  @override
  String get attendance_saveInFiles => '保存至文件应用';

  @override
  String get attendance_saveReportDialog => '保存考勤报告';

  @override
  String get attendance_saveToDevice => '保存至设备';

  @override
  String get attendance_searchMember => '搜索成员';

  @override
  String get attendance_selectPhotoOption => '选择需要实时照片验证的选项';

  @override
  String get attendance_selectStatus => '请选择您的状态';

  @override
  String get attendance_sentToAllMembers => '已发送给该群组的所有成员';

  @override
  String get attendance_sentToGroup => '考勤已发送至群组';

  @override
  String get attendance_shareSubtitle => '通过微信、邮件等发送...';

  @override
  String get attendance_statusCompleted => '已完成';

  @override
  String get attendance_statusOpen => '进行中';

  @override
  String get attendance_stepBlink => '眨眼以拍摄照片';

  @override
  String get attendance_stepEyeLevel => '将手机保持在平视位置';

  @override
  String get attendance_submit => '提交考勤';

  @override
  String get attendance_submitted => '考勤已提交';

  @override
  String get attendance_title => '考勤';

  @override
  String get attendance_update => '更新考勤';

  @override
  String get attendance_validationError => '验证错误';

  @override
  String get attendance_view => '查看';

  @override
  String get attendance_viewTitle => '查看考勤';

  @override
  String get attendance_voteFailed => '无法记录投票';

  @override
  String attendance_withinKm(String km) {
    return '$km 公里以内';
  }

  @override
  String attendance_withinMeters(int count) {
    return '$count 米以内';
  }

  @override
  String get call_accept => '接听';

  @override
  String get call_allContacts => '所有联系人';

  @override
  String get call_allowAccess => '允许访问';

  @override
  String get call_answer => '接听';

  @override
  String get call_audioOutput => '音频输出';

  @override
  String get call_callFrom => '来电自';

  @override
  String get call_callIdNotFound => '未找到通话ID';

  @override
  String get call_callInformation => '通话信息';

  @override
  String get call_callSummary => '通话摘要';

  @override
  String get call_caller => '呼叫者';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name 及另外 $count 人',
      one: '$name 及另外 1 人',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '无法删除 $count 条通话。请重试。',
      one: '无法删除 1 条通话。请重试。',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 条通话记录',
      one: '已删除 1 条通话记录',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => '相机';

  @override
  String get call_cameraMicRequired => '需要相机或麦克风权限';

  @override
  String get call_cameraOff => '相机已关闭';

  @override
  String get call_cameraOn => '相机已开启';

  @override
  String get call_cameraUnavailable => '相机访问目前不可用，请稍后重试。';

  @override
  String get call_cannotReachCallServer => '无法连接到通话服务器，请检查网络。';

  @override
  String get call_chatFallback => '聊天';

  @override
  String get call_closeFullScreen => '退出全屏';

  @override
  String get call_communicationUnavailable => '无法与该用户通信';

  @override
  String get call_connectingProgress => '正在连接…';

  @override
  String get call_connectionTimeout => '连接超时';

  @override
  String get call_contactInformation => '联系人信息';

  @override
  String get call_contactsAccessBannerMessage => '轻松查找并致电您的团队成员。';

  @override
  String get call_contactsAccessBannerTitle => '请允许我们访问您的通讯录';

  @override
  String get call_contactsAccessMessage =>
      '我们需要访问您的通讯录以显示谁在使用 FG Tracker，并方便您向其呼叫或发送邀请。';

  @override
  String get call_contactsAccessTitle => '允许访问通讯录';

  @override
  String get call_decline => '拒绝';

  @override
  String get call_deleteCallsMessage => '这些记录将从您的通话历史中移除。';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '删除 $count 条通话？',
      one: '删除 1 条通话？',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage => '确定要删除此通话记录吗？';

  @override
  String get call_deleteHistoryTitle => '删除通话记录';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '确定要删除选中的这 $count 条通话记录吗？',
      one: '确定要删除此选定的通话记录吗？',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => '删除选中的通话';

  @override
  String call_deleteWithCount(int count) {
    return '删除 ($count)';
  }

  @override
  String call_durHr(int hours) {
    return '$hours 小时';
  }

  @override
  String call_durHrMin(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String call_durMin(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String call_durMinSec(int minutes, int seconds) {
    return '$minutes 分钟 $seconds 秒';
  }

  @override
  String call_durSec(int seconds) {
    return '$seconds 秒';
  }

  @override
  String call_durShortHr(int hours) {
    return '$hours小时';
  }

  @override
  String call_durShortHrMin(int hours, int minutes) {
    return '$hours小时 $minutes分';
  }

  @override
  String call_durShortMin(int minutes) {
    return '$minutes分';
  }

  @override
  String call_durShortMinSec(int minutes, int seconds) {
    return '$minutes分 $seconds秒';
  }

  @override
  String call_durShortSec(int seconds) {
    return '$seconds秒';
  }

  @override
  String get call_duration => '时长';

  @override
  String call_durationValue(String duration) {
    return '时长：$duration';
  }

  @override
  String get call_earpiece => '听筒';

  @override
  String get call_endCall => '结束通话';

  @override
  String get call_ended => '结束时间';

  @override
  String get call_enterNumber => '输入号码';

  @override
  String get call_enterPhoneNumber => '请输入电话号码';

  @override
  String get call_entryDeleteFailed => '删除通话记录失败';

  @override
  String call_entryDeleteFailedError(String error) {
    return '删除通话记录失败：$error';
  }

  @override
  String get call_entryDeleted => '通话记录已删除';

  @override
  String get call_everyoneInCall => '所有人均已在通话中';

  @override
  String get call_failedTitle => '通话失败';

  @override
  String get call_groupBadge => '群组';

  @override
  String get call_groupCallComingSoon => '群组通话即将推出';

  @override
  String get call_groupCallInitFailed => '无法初始化群组通话';

  @override
  String get call_groupCallStartFailed => '无法发起群组通话，请重试。';

  @override
  String get call_groupInformation => '群组信息';

  @override
  String call_groupWithId(String id) {
    return '群组 $id';
  }

  @override
  String get call_headphones => '耳机';

  @override
  String call_historyCancelled(String callType) {
    return '已取消的 $callType';
  }

  @override
  String get call_historyClearFailed => '清除通话记录失败';

  @override
  String call_historyClearFailedError(String error) {
    return '清除通话记录失败：$error';
  }

  @override
  String get call_historyCleared => '所有通话记录已清除';

  @override
  String call_historyIncoming(String callType) {
    return '呼入 $callType';
  }

  @override
  String call_historyMissed(String callType) {
    return '未接 $callType';
  }

  @override
  String call_historyOutgoing(String callType) {
    return '呼出 $callType';
  }

  @override
  String call_historyRejected(String callType) {
    return '已拒绝 $callType';
  }

  @override
  String get call_inCall => '通话中';

  @override
  String call_inCallWithGroup(String groupName) {
    return '通话中 · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return '通话中 ($count)';
  }

  @override
  String get call_incomingAudio => '语音来电';

  @override
  String get call_incomingCallChannelName => '来电';

  @override
  String get call_incomingGroupAudio => '群组语音来电';

  @override
  String get call_incomingGroupVideo => '群组视频来电';

  @override
  String get call_incomingVideo => '视频来电';

  @override
  String get call_infoDescription => '描述';

  @override
  String get call_infoEmail => '电子邮件';

  @override
  String get call_infoGroupCode => '群组代码';

  @override
  String get call_infoGroupName => '群组名称';

  @override
  String get call_infoMobile => '手机';

  @override
  String get call_infoTotalMembers => '总成员数';

  @override
  String get call_invite => '邀请';

  @override
  String get call_inviteToApp => '邀请加入 FG Tracker';

  @override
  String get call_join => '加入';

  @override
  String get call_joinOnAnswer => '接听后立即加入';

  @override
  String get call_kindAudio => '语音通话';

  @override
  String get call_kindCall => '通话';

  @override
  String get call_kindGroupAudio => '群组语音通话';

  @override
  String get call_kindGroupCall => '群组通话';

  @override
  String call_kindGroupOther(String kind) {
    return '群组 $kind 通话';
  }

  @override
  String get call_kindGroupVideo => '群组视频通话';

  @override
  String call_kindOther(String kind) {
    return '$kind 通话';
  }

  @override
  String get call_kindVideo => '视频通话';

  @override
  String get call_loadDetailFailed => '加载通话详情失败';

  @override
  String get call_loadMore => '加载更多';

  @override
  String get call_loadRecentFailed => '加载最近通话失败';

  @override
  String get call_loginToCall => '请先登录后再拨打电话';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位成员在此通话中',
      one: '1 位成员在此通话中',
    );
    return '$_temp0';
  }

  @override
  String get call_message => '消息';

  @override
  String get call_micActive => '麦克风处于活动状态';

  @override
  String get call_missedCall => '未接来电';

  @override
  String get call_missedCallChannelName => '未接来电';

  @override
  String get call_missedCallNotification => '未接来电';

  @override
  String get call_more => '更多';

  @override
  String get call_mute => '静音';

  @override
  String get call_muted => '已静音';

  @override
  String call_nameYou(String name) {
    return '$name（您）';
  }

  @override
  String get call_noActiveParticipants => '无活跃参与者';

  @override
  String get call_noContactsMatch => '没有匹配的联系人';

  @override
  String get call_noGroupsFound => '未找到群组';

  @override
  String get call_noGroupsYet => '暂无群组';

  @override
  String get call_noNameGroup => '未命名群组';

  @override
  String get call_noRecentCalls => '无最近通话';

  @override
  String get call_noRecentMatch => '没有匹配的最近通话';

  @override
  String get call_noRecentYet => '暂无最近通话';

  @override
  String get call_noRegisteredContacts => '未找到已注册的联系人';

  @override
  String get call_notInContacts => '此号码不在您的联系人中';

  @override
  String call_notInThisCall(int count) {
    return '未在通话中 ($count)';
  }

  @override
  String get call_notReady => '通话未就绪';

  @override
  String get call_notificationPermissionRationale => '用于显示来电。';

  @override
  String get call_notificationPermissionSettings => '在设置中启用通知。';

  @override
  String get call_notificationPermissionTitle => '通知权限';

  @override
  String get call_notify => '通知';

  @override
  String get call_notifyFailed => '通知失败';

  @override
  String get call_notifySent => '通知已发送';

  @override
  String get call_ongoingChannelDescription => '保持通话和屏幕共享';

  @override
  String get call_ongoingChannelName => '正在通话';

  @override
  String get call_otherAlreadySharing => '对方已经在共享屏幕';

  @override
  String get call_otherStartingVideo => '对方正在开启视频';

  @override
  String get call_participant => '参与者';

  @override
  String get call_participants => '参与者';

  @override
  String call_personIsSharing(String name) {
    return '$name 正在共享';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name 正在共享屏幕';
  }

  @override
  String get call_phone => '电话';

  @override
  String get call_pleaseWait => '请稍候';

  @override
  String get call_recentCalls => '最近通话';

  @override
  String get call_resetZoom => '重置缩放';

  @override
  String get call_returnToCall => '返回通话';

  @override
  String get call_screenBeingShared => '正在共享屏幕';

  @override
  String get call_screenShareChannelDescription => '活跃屏幕共享会话通知';

  @override
  String get call_screenShareChannelName => '屏幕共享服务';

  @override
  String get call_screenSharePermissionDenied => '屏幕共享权限被拒绝';

  @override
  String get call_screenShareStartFailed => '无法启动屏幕共享';

  @override
  String get call_screenShareStopped => '屏幕共享已停止';

  @override
  String get call_screenSharingTitle => '屏幕共享';

  @override
  String call_screenVisibleToName(String name) {
    return '$name 可以看到您的屏幕';
  }

  @override
  String get call_screenVisibleToOther => '对方可以看到您的屏幕';

  @override
  String get call_searchHint => '搜索联系人或群组';

  @override
  String get call_sectionLastWeek => '上周';

  @override
  String get call_sectionOlder => '更早';

  @override
  String get call_sectionThisWeek => '本周';

  @override
  String get call_selectAll => '全选';

  @override
  String call_selectedCount(int count) {
    return '已选择 $count 项';
  }

  @override
  String get call_selectedDeleteFailed => '删除选中的通话失败';

  @override
  String call_selectedDeleteFailedError(String error) {
    return '删除选中的通话失败：$error';
  }

  @override
  String get call_selectedDeleted => '已删除选中的通话';

  @override
  String get call_selfCallWarning => '您不能拨打自己的号码。';

  @override
  String get call_sessionConnectFailed => '连接通话会话失败';

  @override
  String get call_shareScreen => '共享屏幕';

  @override
  String get call_shareScreenShort => '共享';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return '在 $groupName 中共享 • 点击返回通话';
  }

  @override
  String get call_sharingYourScreen => '正在共享您的屏幕';

  @override
  String get call_someone => '某人';

  @override
  String get call_speaker => '扬声器';

  @override
  String get call_started => '开始时间';

  @override
  String get call_startingScreenShare => '正在启动屏幕共享…';

  @override
  String get call_statusBusy => '占线';

  @override
  String get call_statusCalling => '正在呼叫';

  @override
  String get call_statusCancelled => '已取消';

  @override
  String get call_statusCompleted => '已完成';

  @override
  String get call_statusConnected => '已连接';

  @override
  String get call_statusConnecting => '正在连接';

  @override
  String get call_statusDeclined => '已拒绝';

  @override
  String get call_statusJoined => '已加入';

  @override
  String get call_statusMissed => '未接';

  @override
  String get call_statusReconnecting => '正在重新连接';

  @override
  String get call_statusRinging => '响铃中';

  @override
  String get call_statusVideoConnecting => '正在连接视频';

  @override
  String get call_stop => '停止';

  @override
  String get call_stopSharing => '停止共享';

  @override
  String get call_subtitle => '音频 / 视频通话';

  @override
  String get call_swipeUpToAnswer => '上滑接听';

  @override
  String get call_switch => '切换';

  @override
  String get call_switchCameraFailed => '无法切换相机';

  @override
  String get call_switchToVideoToShare => '切换到视频通话以共享屏幕';

  @override
  String get call_tabContacts => '联系人';

  @override
  String get call_tabGroups => '群组';

  @override
  String get call_tabRecent => '最近';

  @override
  String get call_tapNotifyToInvite => '点击通知以邀请';

  @override
  String get call_tapStartBroadcastHint => '如果出现系统提示，请点击“开始直播”';

  @override
  String get call_title => '通话';

  @override
  String call_todayAt(String value) {
    return '今天 $value';
  }

  @override
  String get call_total => '总计';

  @override
  String get call_turnOnVideo => '开启视频';

  @override
  String get call_unableToCallContact => '无法呼叫此联系人';

  @override
  String get call_unableToMakeCall => '无法拨打电话';

  @override
  String get call_unableToOpenChat => '无法为此联系人打开聊天';

  @override
  String get call_unableToShareScreen => '无法共享屏幕';

  @override
  String get call_unavailableTitle => '通话不可用';

  @override
  String get call_unexpectedResponse => '服务器返回异常响应';

  @override
  String get call_unknown => '未知';

  @override
  String get call_unknownGroup => '未知群组';

  @override
  String get call_unknownUser => '未知用户';

  @override
  String get call_unmute => '取消静音';

  @override
  String get call_unselectAll => '取消全选';

  @override
  String get call_user => '用户';

  @override
  String get call_userNotFound => '未找到用户';

  @override
  String call_userWithId(String id) {
    return '用户 $id';
  }

  @override
  String get call_video => '视频';

  @override
  String get call_waitingForBroadcast => '等待开始直播';

  @override
  String get call_waitingForBroadcastMessage => '请在系统弹窗中点击“开始直播”以共享屏幕。';

  @override
  String get call_waitingForMedia => '正在等待媒体流...';

  @override
  String get call_wired => '有线';

  @override
  String get call_yesDelete => '是，删除';

  @override
  String call_yesterdayAt(String value) {
    return '昨天 $value';
  }

  @override
  String get call_youAreSharing => '您正在共享';

  @override
  String get call_youAreSharingScreen => '您正在共享屏幕';

  @override
  String get call_zoomIn => '放大';

  @override
  String get call_zoomOut => '缩小';

  @override
  String get chatList_allChats => '所有聊天';

  @override
  String get chatList_allContacts => '所有联系人';

  @override
  String get chatList_allowAccess => '允许访问';

  @override
  String get chatList_allowContactsBody =>
      '我们需要访问您的通讯录以显示谁在使用 FG Tracker，并方便您发起聊天或发送邀请。';

  @override
  String get chatList_allowContactsTitle => '允许访问通讯录';

  @override
  String get chatList_archiveChat => '归档聊天';

  @override
  String get chatList_archived => '已归档';

  @override
  String get chatList_archivedChatsSubtitle => '您的隐藏会话';

  @override
  String get chatList_archivedChatsTitle => '已归档聊天';

  @override
  String chatList_archivedCount(int count) {
    return '已归档 ($count)';
  }

  @override
  String get chatList_block => '屏蔽';

  @override
  String get chatList_blockFailed => '无法屏蔽用户';

  @override
  String chatList_blockName(String name) {
    return '屏蔽 $name';
  }

  @override
  String get chatList_blockUser => '屏蔽用户';

  @override
  String get chatList_blockUserConfirm => '确定要屏蔽此用户吗？';

  @override
  String get chatList_blocked => '已屏蔽';

  @override
  String get chatList_chatCleared => '聊天已清空';

  @override
  String get chatList_chooseContactToShare => '选择要在聊天中分享的联系人。';

  @override
  String get chatList_clear => '清空';

  @override
  String get chatList_clearChat => '清空聊天';

  @override
  String get chatList_clearChatConfirm => '删除与此用户的所有消息吗？';

  @override
  String get chatList_clearChatFailed => '无法清空聊天';

  @override
  String get chatList_clearSearch => '清除搜索';

  @override
  String get chatList_contactAndInfo => '联系人与信息';

  @override
  String get chatList_contactPermissionNeededMsg => '在聊天中共享联系人需要通讯录权限。';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个联系人',
      one: '1 个联系人',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return '加载联系人失败：$error';
  }

  @override
  String get chatList_contactsPermissionNeeded => '需要通讯录权限';

  @override
  String get chatList_contactsWillAppear => '您的联系人将在就绪后显示在此处。';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
      one: '1 天',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => '已停用';

  @override
  String get chatList_defaultAbout => '您好！我正在使用 FG Tracker';

  @override
  String get chatList_deleteChat => '删除聊天';

  @override
  String get chatList_deleteChatConfirm => '从聊天列表中删除此会话吗？';

  @override
  String get chatList_forwardFailed => '无法转发消息。';

  @override
  String get chatList_forwardListLoadFailed => '无法加载转发列表。';

  @override
  String get chatList_forwardTo => '转发至...';

  @override
  String get chatList_forwarded => '已转发';

  @override
  String get chatList_groupChatFallback => '群聊';

  @override
  String get chatList_groupDeactivatedBanner => '该群组已被管理员停用';

  @override
  String get chatList_groupFallback => '群组';

  @override
  String get chatList_howToAllow => '如何允许';

  @override
  String get chatList_howToAllowStep1 => '点击“允许访问”以打开设置';

  @override
  String get chatList_howToAllowStep2 => '点击“权限”';

  @override
  String get chatList_howToAllowStep3 => '选择“通讯录”';

  @override
  String get chatList_howToAllowStep4 => '选择“允许”，然后返回应用';

  @override
  String get chatList_invite => '邀请';

  @override
  String get chatList_inviteChooseHow => '选择发送邀请的方式';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return '您好 $name！快来 FG Tracker 加入我吧。\n\nAndroid 下载：$playStoreLink\n\niOS 下载：$appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => '更多应用';

  @override
  String chatList_inviteName(String name) {
    return '邀请 $name';
  }

  @override
  String get chatList_inviteViaMessage => '短信';

  @override
  String get chatList_locationHidden => '位置已隐藏';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1、$name2 等 $count 人正在输入...';
  }

  @override
  String get chatList_markAsRead => '标为已读';

  @override
  String get chatList_markAsUnread => '标为未读';

  @override
  String get chatList_mediaLinksDocs => '媒体、链接和文档';

  @override
  String get chatList_memberFallback => '成员';

  @override
  String get chatList_messageDeleted => '此消息已删除';

  @override
  String get chatList_messageForwarded => '消息已转发';

  @override
  String get chatList_messageIdMissing => '缺少消息ID。';

  @override
  String chatList_minutesShort(int count) {
    return '$count 分钟';
  }

  @override
  String get chatList_mute1Hour => '1 小时';

  @override
  String get chatList_mute8Hours => '8 小时';

  @override
  String get chatList_muteAlways => '直到我手动开启';

  @override
  String get chatList_muteSubtitle => '选择暂停接收通知的时间。';

  @override
  String get chatList_muteTitle => '静音通知';

  @override
  String get chatList_muteUntilTomorrow => '直到明天';

  @override
  String get chatList_newChat => '新聊天';

  @override
  String get chatList_newChatSectionContacts => '发起新聊天（联系人）';

  @override
  String get chatList_newChatSectionInvite => '邀请加入聊天（未注册联系人）';

  @override
  String get chatList_noArchivedChats => '没有已归档的聊天';

  @override
  String get chatList_noArchivedChatsSubtitle => '已归档的会话将在此显示。';

  @override
  String get chatList_noChatsFound => '未找到聊天';

  @override
  String get chatList_noChatsSubtitle => '您的私聊消息将在此显示。';

  @override
  String get chatList_noContactsAvailable => '无可用联系人';

  @override
  String get chatList_noContactsFound => '未找到联系人';

  @override
  String get chatList_noGroupsAvailable => '没有可用的群组';

  @override
  String get chatList_noGroupsFound => '未找到群组';

  @override
  String get chatList_noMediaYet => '暂无共享媒体';

  @override
  String get chatList_noMessagesYet => '暂无消息';

  @override
  String get chatList_noPeopleOrGroups => '未找到人员或群组';

  @override
  String chatList_noResultsFor(String query) {
    return '未找到与“$query”相关的结果';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return '没有关于“$query”的结果';
  }

  @override
  String get chatList_noTrackerContacts => '未找到活跃的追踪联系人';

  @override
  String get chatList_offlineNotSaved => '您处于离线状态。更改未保存，请重试。';

  @override
  String chatList_oneTyping(String name) {
    return '$name 正在输入...';
  }

  @override
  String get chatList_openSettings => '打开设置';

  @override
  String get chatList_pinChat => '置顶聊天';

  @override
  String get chatList_pinnedChats => '置顶聊天';

  @override
  String get chatList_pleaseTryAgain => '请重试。';

  @override
  String get chatList_profileCall => '通话';

  @override
  String get chatList_profileMessage => '消息';

  @override
  String get chatList_profileNotFound => '未找到个人资料';

  @override
  String get chatList_profileVideoCall => '视频通话';

  @override
  String get chatList_quickCommSubtitle => '即时连接您的团队';

  @override
  String get chatList_quickCommTitle => '快捷沟通';

  @override
  String get chatList_quickGroups => '群组';

  @override
  String get chatList_quickGroupsSub => '团队群聊';

  @override
  String get chatList_quickSafeZone => '安全区域';

  @override
  String get chatList_quickSafeZoneSub => '安全与警报';

  @override
  String get chatList_quickTracking => '追踪';

  @override
  String get chatList_quickTrackingSub => '实时位置';

  @override
  String get chatList_quickWalkie => '对讲';

  @override
  String get chatList_quickWalkieSub => '一键对讲';

  @override
  String get chatList_searchByNameOrNumber => '按姓名或号码搜索...';

  @override
  String get chatList_searchGroupsHint => '搜索群组...';

  @override
  String get chatList_searchHint => '搜索聊天或消息...';

  @override
  String get chatList_searchHintShort => '搜索...';

  @override
  String get chatList_searchNameOrNumber => '搜索姓名或号码';

  @override
  String get chatList_searchResults => '搜索结果';

  @override
  String get chatList_sectionGroups => '群组';

  @override
  String get chatList_sectionMyContacts => '我的联系人';

  @override
  String get chatList_sectionOtherContacts => '其他联系人';

  @override
  String get chatList_sectionRecentChats => '最近聊天';

  @override
  String get chatList_selectDestination => '选择目标';

  @override
  String get chatList_selectDestinationMsg => '请选择至少一个人或群组。';

  @override
  String chatList_selectedCount(int count) {
    return '已选择 $count 项';
  }

  @override
  String get chatList_shareContactTitle => '分享联系人';

  @override
  String chatList_shareMenuFailed(String error) {
    return '无法打开分享菜单：$error';
  }

  @override
  String get chatList_smsOpenFailed => '无法打开短信应用';

  @override
  String get chatList_someone => '某人';

  @override
  String get chatList_startConversation => '发起会话';

  @override
  String get chatList_subtitle => '与您的团队保持联系';

  @override
  String get chatList_telegramOpenFailed => '无法打开 Telegram';

  @override
  String get chatList_title => '聊天';

  @override
  String get chatList_tryAnotherNameOrNumber => '请尝试搜索其他姓名或电话号码。';

  @override
  String get chatList_tryDifferentSearch => '请尝试用其他名称或消息内容搜索。';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1、$name2 正在输入...';
  }

  @override
  String get chatList_typing => '正在输入...';

  @override
  String get chatList_unableToCallContact => '无法呼叫此联系人';

  @override
  String get chatList_unableToLoadContacts => '无法加载联系人';

  @override
  String get chatList_unarchiveChat => '取消归档聊天';

  @override
  String get chatList_unblock => '解除屏蔽';

  @override
  String get chatList_unblockFailed => '无法解除屏蔽用户';

  @override
  String chatList_unblockName(String name) {
    return '解除屏蔽 $name';
  }

  @override
  String get chatList_unblockUser => '解除屏蔽用户';

  @override
  String get chatList_unblockUserConfirm => '确定要解除屏蔽此用户吗？';

  @override
  String get chatList_unknown => '未知';

  @override
  String get chatList_unknownUser => '未知用户';

  @override
  String get chatList_unnamedContact => '未命名联系人';

  @override
  String get chatList_unpinChat => '取消置顶';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条未读消息',
      one: '1 条未读消息',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed => '无法更新聊天，请重试。';

  @override
  String get chatList_userFallback => '用户';

  @override
  String get chatList_userNotFound => '未找到用户';

  @override
  String get chatList_viewArchived => '查看已归档的会话';

  @override
  String get chatList_whatsappOpenFailed => '无法打开 WhatsApp';

  @override
  String get chatList_yourContacts => '您的通讯录';

  @override
  String get chat_addCaptionHint => '添加说明...';

  @override
  String get chat_audioUnavailable => '此音频已不再可用';

  @override
  String get chat_blockFailed => '无法屏蔽用户';

  @override
  String get chat_call => '通话';

  @override
  String get chat_cameraAccessNeeded => '在聊天中拍摄照片和视频需要相机权限。';

  @override
  String get chat_cameraModePhoto => '照片';

  @override
  String get chat_cameraModePortrait => '人像';

  @override
  String get chat_cameraModeVideo => '视频';

  @override
  String get chat_cameraStartFailed => '无法启动相机。';

  @override
  String get chat_cantMessageUser => '您无法向此用户发送消息';

  @override
  String get chat_chatActionsSubtitle => '管理您的聊天';

  @override
  String get chat_chatActionsTitle => '聊天操作';

  @override
  String get chat_clear => '清空';

  @override
  String get chat_clearChat => '清空聊天';

  @override
  String get chat_clearChatConfirm => '清除此聊天的所有消息吗？';

  @override
  String get chat_clearGroupChatFailed => '清除群聊失败';

  @override
  String get chat_contactBlockedYou => '此联系人已将您屏蔽';

  @override
  String get chat_contactUnavailable => '联系人不可用';

  @override
  String get chat_deleteForEveryone => '为所有人删除';

  @override
  String get chat_deleteForEveryoneConfirm => '确定要为所有人删除此消息吗？';

  @override
  String get chat_deleteForMe => '为我删除';

  @override
  String get chat_deleteForMeConfirm => '确定要为您删除此消息吗？';

  @override
  String get chat_deleteMember => '删除成员';

  @override
  String get chat_deleteMemberSubtitle => '从此群组中移除成员';

  @override
  String get chat_documentAvailable => '文档可用';

  @override
  String get chat_documentDownloadFailed => '文档无法下载。';

  @override
  String get chat_documentOpenFailed => '无法打开文档，请重试。';

  @override
  String get chat_documentPreviewUnavailable => '此类文件不支持预览。请使用已安装的应用程序打开文档。';

  @override
  String get chat_documentUnavailable => '此文档已不再可用';

  @override
  String get chat_downloadFailed => '下载失败';

  @override
  String get chat_edited => '已编辑';

  @override
  String get chat_emptySubtitle => '打个招呼 👋 开始聊天吧';

  @override
  String get chat_emptyTitle => '这里还没有消息';

  @override
  String get chat_fetchingLocation => '正在获取位置...';

  @override
  String get chat_finishVoiceRecordingFirst => '请先完成或取消语音录音';

  @override
  String get chat_forwarded => '已转发';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get chat_groupActionsSubtitle => '管理您的群组设置';

  @override
  String get chat_groupActionsTitle => '群组操作';

  @override
  String get chat_groupChatCleared => '群聊已成功清除';

  @override
  String get chat_groupDeactivated => '该群组已被管理员停用';

  @override
  String get chat_imageFailed => '图片加载失败';

  @override
  String get chat_listen => '收听';

  @override
  String get chat_listenEnglish => '收听（英语）';

  @override
  String get chat_listenHindi => '收听（印地语）';

  @override
  String get chat_loadFailedSubtitle => '请检查网络连接并重试。';

  @override
  String get chat_loadFailedTitle => '无法加载消息';

  @override
  String get chat_locationFetchFailed => '无法获取您的位置，请重试。';

  @override
  String get chat_locationPermissionNeeded => '共享位置需要位置权限。';

  @override
  String get chat_locationPermissionOff => '此应用的位置权限已关闭。请在设置中启用它以共享您的位置。';

  @override
  String get chat_locationServicesOff => '请开启位置服务以共享您的位置。';

  @override
  String get chat_locationUnavailable => '位置不可用';

  @override
  String get chat_mediaMissing => '媒体缺失';

  @override
  String get chat_mediaMissingToast => '媒体缺失。此文件已不再可用。';

  @override
  String get chat_mediaUnavailable => '此媒体已不再可用';

  @override
  String get chat_menuForward => '转发';

  @override
  String get chat_menuMessageInfo => '消息信息';

  @override
  String get chat_menuPin => '置顶消息';

  @override
  String get chat_menuReply => '回复';

  @override
  String get chat_menuUnpin => '取消置顶消息';

  @override
  String get chat_messageCopied => '消息已复制';

  @override
  String get chat_messageDeleted => '此消息已删除';

  @override
  String get chat_messageNotAvailable => '消息不可用';

  @override
  String get chat_messageNotSent => '消息未发送，请重试。';

  @override
  String get chat_noCameraFound => '在此设备上未找到相机。';

  @override
  String get chat_noLongerMember => '您已不再是此群组成员';

  @override
  String get chat_noMediaAvailable => '无可用媒体';

  @override
  String get chat_offlineNotSent => '您处于离线状态。消息未发送。';

  @override
  String get chat_openDocument => '打开文档';

  @override
  String get chat_openInGoogleMaps => '在 Google 地图中打开';

  @override
  String get chat_openSettings => '打开设置';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人',
      one: '1人',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => '此照片已不再可用';

  @override
  String get chat_previewAttendancePoll => '考勤投票';

  @override
  String get chat_previewAudio => '音频';

  @override
  String get chat_previewContact => '联系人';

  @override
  String get chat_previewDocument => '文档';

  @override
  String get chat_previewLocation => '位置';

  @override
  String get chat_previewMessage => '消息';

  @override
  String get chat_previewNewMessage => '新消息';

  @override
  String get chat_previewOwnDeleted => '您删除了此消息';

  @override
  String get chat_previewPhoto => '照片';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count张照片',
      one: '1张照片',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => '投票';

  @override
  String get chat_previewSticker => '贴纸';

  @override
  String get chat_previewVideo => '视频';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个视频',
      one: '1个视频',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => '语音消息';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return '语音消息 ($duration)';
  }

  @override
  String get chat_recordingFailed => '录制失败';

  @override
  String get chat_removeMember => '移除成员';

  @override
  String get chat_removeMemberConfirm => '确定要将此成员从群组中移除吗？';

  @override
  String get chat_replyHint => '回复消息...';

  @override
  String get chat_searchMessages => '搜索消息';

  @override
  String get chat_searchMessagesHint => '搜索消息...';

  @override
  String get chat_searchMessagesSubtitle => '按关键词查找消息';

  @override
  String get chat_sendLocation => '发送位置';

  @override
  String get chat_shareLocation => '共享位置';

  @override
  String get chat_shareVideoFailed => '无法分享视频';

  @override
  String get chat_sharedFromApp => '分享自 FG Tracker';

  @override
  String get chat_sharedLocation => '共享位置';

  @override
  String get chat_showOriginal => '显示原文';

  @override
  String get chat_someone => '某人';

  @override
  String get chat_statusLabel => '状态';

  @override
  String get chat_statusUnavailable => '此状态更新已不再可用';

  @override
  String get chat_stop => '停止';

  @override
  String get chat_stopEnglish => '停止（英语）';

  @override
  String get chat_stopHindi => '停止（印地语）';

  @override
  String get chat_takePhotoFailed => '拍照失败';

  @override
  String get chat_translatedToEnglish => '已翻译为英语';

  @override
  String get chat_translatedToHindi => '已翻译为印地语';

  @override
  String get chat_translating => '翻译中...';

  @override
  String get chat_tryAgain => '重试';

  @override
  String get chat_typeMessageHint => '输入消息...';

  @override
  String get chat_typing => '正在输入...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人正在输入...',
      one: '1人正在输入...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name 正在输入...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1、$name2 正在输入...';
  }

  @override
  String get chat_unableToOpen => '无法打开';

  @override
  String get chat_unableToOpenGoogleMaps => '无法打开 Google 地图';

  @override
  String get chat_unblock => '解除屏蔽';

  @override
  String get chat_unblockContact => '解除屏蔽联系人';

  @override
  String get chat_unblockContactConfirm => '确定要解除屏蔽此联系人吗？';

  @override
  String get chat_unblockFailed => '无法解除屏蔽用户';

  @override
  String get chat_unknown => '未知';

  @override
  String get chat_unknownLocation => '未知位置';

  @override
  String get chat_unsupportedMessage => '此版本的应用不支持此消息';

  @override
  String get chat_updateGroup => '更新群组';

  @override
  String get chat_updateGroupSubtitle => '更改当前群组详细信息';

  @override
  String chat_uploadFileFailed(String path) {
    return '上传 $path 失败';
  }

  @override
  String get chat_userBlocked => '用户已被成功屏蔽';

  @override
  String get chat_userUnblocked => '用户已解除屏蔽';

  @override
  String get chat_videoDownloaded => '视频下载成功';

  @override
  String get chat_videoThumbnailFailed => '生成视频缩略图失败';

  @override
  String get chat_videoUnavailable => '此视频已不再可用';

  @override
  String get chat_videoUploadFailed => '视频上传失败';

  @override
  String get chat_voicePlayFailed => '无法播放语音消息';

  @override
  String get chat_voiceUploadFailed => '语音消息上传失败，请重试。';

  @override
  String get chat_youBlockedContact => '您已屏蔽此联系人';

  @override
  String get common_add => '添加';

  @override
  String get common_allow => '允许';

  @override
  String get common_back => '返回';

  @override
  String get common_cancel => '取消';

  @override
  String get common_close => '关闭';

  @override
  String get common_comingSoon => '敬请期待';

  @override
  String get common_confirm => '确认';

  @override
  String get common_continue => '继续';

  @override
  String get common_copied => '已复制';

  @override
  String get common_copy => '复制';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count天前',
      one: '1天前',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => '删除';

  @override
  String get common_dismiss => '关闭';

  @override
  String get common_done => '完成';

  @override
  String get common_edit => '编辑';

  @override
  String get common_error => '错误';

  @override
  String get common_exit => '退出';

  @override
  String get common_gotIt => '知道了';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时前',
      one: '1小时前',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => '刚刚';

  @override
  String common_lastSeen(String time) {
    return '最后上线: $time';
  }

  @override
  String get common_loading => '加载中…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count位成员',
      one: '1位成员',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分钟前',
      one: '1分钟前',
    );
    return '$_temp0';
  }

  @override
  String get common_next => '下一步';

  @override
  String get common_no => '否';

  @override
  String get common_noData => '暂无数据';

  @override
  String get common_noInternet => '无网络连接';

  @override
  String get common_notNow => '暂不';

  @override
  String get common_offline => '离线';

  @override
  String get common_ok => '确定';

  @override
  String get common_online => '在线';

  @override
  String get common_open => '打开';

  @override
  String get common_permissionDenied => '权限被拒绝';

  @override
  String get common_remove => '移除';

  @override
  String get common_retry => '重试';

  @override
  String get common_save => '保存';

  @override
  String get common_search => '搜索';

  @override
  String get common_send => '发送';

  @override
  String get common_settings => '设置';

  @override
  String get common_share => '分享';

  @override
  String get common_somethingWentWrong => '出错了，请重试。';

  @override
  String get common_submit => '提交';

  @override
  String get common_success => '成功';

  @override
  String get common_today => '今天';

  @override
  String common_todayAt(String time) {
    return '今天 $time';
  }

  @override
  String get common_tryAgain => '再试一次';

  @override
  String get common_viewAll => '查看全部';

  @override
  String get common_yes => '是';

  @override
  String get common_yesterday => '昨天';

  @override
  String get common_you => '你';

  @override
  String get dialog_allowLocationAccess => '允许访问位置信息';

  @override
  String get dialog_anErrorOccurred => '发生错误！';

  @override
  String get dialog_important => '重要！';

  @override
  String get dialog_locationPermissionRequired => '需要位置权限';

  @override
  String get dialog_locationPurposeBody =>
      '为了提高服务效率，我们的应用程序请求访问并保存您的位置信息，以方便准确导航至指定工作地点。';

  @override
  String get dialog_locationSettingsAndroid =>
      '没有位置访问权限，我们将无法检测到您的当前位置。请点击“设置”，然后点击“权限”，允许访问位置。';

  @override
  String get dialog_locationSettingsIos =>
      '此应用需要访问您的位置信息以提供基于位置的服务。请前往“设置”并启用位置权限。';

  @override
  String get dialog_loggedInElsewhere => '您已在另一台设备上登录。';

  @override
  String get dialog_loggedInElsewhereLogInAgain => '您已在另一台设备上登录，请重新登录。';

  @override
  String get dialog_logoutConfirm => '您确定要退出登录吗？';

  @override
  String get dialog_selectAllowAllTheTime => '在接下来的弹窗中，请选择\n“始终允许”。';

  @override
  String get dialog_sessionExpiredTitle => '会话已过期';

  @override
  String get editProfile_fullNameLabel => '全名';

  @override
  String get editProfile_personalInfo => '个人信息';

  @override
  String get editProfile_phoneLabel => '电话号码';

  @override
  String get editProfile_saveButton => '保存更改';

  @override
  String get editProfile_tapPhotoHint => '点击照片以更换';

  @override
  String get editProfile_title => '编辑个人资料';

  @override
  String get forceUpdate_currentInstalled => '当前安装版本';

  @override
  String get forceUpdate_defaultMessage => 'FG Tracker 有新版本可用。请更新后继续使用。';

  @override
  String get forceUpdate_defaultTitle => '需要更新';

  @override
  String get forceUpdate_fallbackMessage =>
      'FG Tracker 包含重要优化的新版本已发布。请更新以继续使用该应用。';

  @override
  String get forceUpdate_footer => '必须更新才能继续使用 FG Tracker';

  @override
  String get forceUpdate_requiredVersion => '要求版本';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return '在 $storeName 上更新';
  }

  @override
  String get groupDialog_audioCall => '语音通话';

  @override
  String get groupDialog_audioCallSubtitle => '发起语音通话';

  @override
  String get groupDialog_call => '通话';

  @override
  String get groupDialog_chat => '聊天';

  @override
  String get groupDialog_codeEmpty => '群组代码不能为空';

  @override
  String get groupDialog_codeLabel => '群组代码';

  @override
  String get groupDialog_createButton => '创建群组';

  @override
  String get groupDialog_createTitle => '创建新群组';

  @override
  String get groupDialog_descHint => '输入群组描述';

  @override
  String get groupDialog_descLabel => '群组描述（选填）';

  @override
  String groupDialog_distance(String distance) {
    return '距离：$distance';
  }

  @override
  String get groupDialog_enterCodeManually => '手动输入群组代码';

  @override
  String get groupDialog_enterCodeTitle => '输入群组代码';

  @override
  String get groupDialog_fillDetails => '请填写以下详细信息';

  @override
  String get groupDialog_getDirections => '获取路线';

  @override
  String get groupDialog_join => '加入群组';

  @override
  String groupDialog_lastSeen(String time) {
    return '最后上线: $time';
  }

  @override
  String get groupDialog_locationHidden => '位置已隐藏';

  @override
  String get groupDialog_locationUnavailable => '位置不可用';

  @override
  String get groupDialog_member => '成员';

  @override
  String get groupDialog_memberInfo => '成员信息';

  @override
  String get groupDialog_nameHint => '输入群组名称';

  @override
  String get groupDialog_nameLabel => '群组名称';

  @override
  String get groupDialog_noQrInImage => '所选图片中未找到二维码。';

  @override
  String get groupDialog_noValidQr => '未找到有效的二维码。';

  @override
  String groupDialog_qrDecodeError(String error) {
    return '从相册解析二维码出错：$error';
  }

  @override
  String get groupDialog_scanCamera => '用相机扫描';

  @override
  String get groupDialog_selectCallType => '选择通话类型';

  @override
  String get groupDialog_update => '更新';

  @override
  String get groupDialog_updateTitle => '更新群组';

  @override
  String get groupDialog_uploadGallery => '从相册上传';

  @override
  String get groupDialog_videoCall => '视频通话';

  @override
  String get groupDialog_videoCallSubtitle => '发起视频通话';

  @override
  String get groupDialog_yourLocation => '您的当前位置';

  @override
  String get groupInfo_active => '活跃';

  @override
  String get groupInfo_admin => '管理员';

  @override
  String get groupInfo_allGroups => '所有群组';

  @override
  String get groupInfo_allGroupsSubtitle => '与您的团队保持联系';

  @override
  String get groupInfo_areYouSure => '确定吗？';

  @override
  String get groupInfo_audioCall => '语音通话';

  @override
  String get groupInfo_clearChatConfirm => '从此设备删除所有消息吗？';

  @override
  String get groupInfo_createdBy => '创建者';

  @override
  String get groupInfo_detailsNotFound => '未找到群组详细信息';

  @override
  String get groupInfo_exitGroup => '退出群组';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return '确定要退出“$groupName”吗？';
  }

  @override
  String get groupInfo_exitGroupQuestion => '您要退出此群组吗？';

  @override
  String get groupInfo_group => '群组';

  @override
  String get groupInfo_groupAdmin => '群组管理员';

  @override
  String get groupInfo_groupCallFailed => '无法发起群组通话，请重试。';

  @override
  String get groupInfo_groupCodeCopied => '群组代码已复制！';

  @override
  String get groupInfo_groupSettings => '群组设置';

  @override
  String get groupInfo_groupSettingsSubtitle => '编辑群组信息、隐私等';

  @override
  String get groupInfo_inactive => '未激活';

  @override
  String get groupInfo_inviteCopied => '邀请文本已复制';

  @override
  String groupInfo_inviteText(String groupName) {
    return '加入我在 FG Tracker 上的群组“$groupName”';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return '加入我在 FG Tracker 上的群组“$groupName”。代码：$code';
  }

  @override
  String get groupInfo_inviteViaLink => '通过链接邀请';

  @override
  String get groupInfo_mediaLinksDocs => '媒体、链接和文档';

  @override
  String get groupInfo_member => '成员';

  @override
  String get groupInfo_members => '成员';

  @override
  String get groupInfo_messageAction => '发送消息';

  @override
  String groupInfo_nameYou(String name) {
    return '$name（您）';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return '未找到与“$query”相关的群组';
  }

  @override
  String get groupInfo_noGroupsYet => '您尚未加入或创建任何群组。\n立即开始探索吧！';

  @override
  String get groupInfo_noMediaYet => '暂无共享媒体';

  @override
  String get groupInfo_removeFromGroup => '从群组中移除';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return '确定要将 $name 从群组中移除吗？';
  }

  @override
  String get groupInfo_searchGroupsHint => '搜索群组...';

  @override
  String get groupInfo_showLess => '收起';

  @override
  String get groupInfo_teamCode => '团队代码';

  @override
  String groupInfo_totalCount(int count) {
    return '共 $count 个';
  }

  @override
  String get groupInfo_unknownGroup => '未知群组';

  @override
  String get groupInfo_unnamedGroup => '未命名群组';

  @override
  String get groupInfo_videoCall => '视频通话';

  @override
  String get groupInfo_viewAllMembers => '查看全部成员';

  @override
  String get group_activatedSuccess => '群组已成功激活';

  @override
  String get group_addMember => '添加成员';

  @override
  String get group_alignQr => '将二维码对准扫描框内';

  @override
  String get group_areYouSure => '确定吗？';

  @override
  String get group_chatWithMembers => '与群组成员聊天';

  @override
  String get group_codeCopied => '群组代码已复制！';

  @override
  String group_codeShareInfo(String code) {
    return '群组代码：$code — 分享给他人即可加入';
  }

  @override
  String get group_copyCode => '复制代号';

  @override
  String get group_created => '已创建';

  @override
  String get group_createdJustNow => '刚刚创建';

  @override
  String get group_deactivatedSuccess => '群组已停用';

  @override
  String get group_defaultName => '群组';

  @override
  String get group_deleteGroup => '解散群组';

  @override
  String get group_deleteGroupConfirm => '确定要解散该群组吗？';

  @override
  String get group_deletedSuccess => '群组已成功解散';

  @override
  String get group_download => '下载';

  @override
  String get group_downloadChannelDescription => '二维码下载完成后发送提醒';

  @override
  String get group_downloadChannelName => '下载通知';

  @override
  String get group_enableLocationToJoin => '请开启定位服务以加入群组。';

  @override
  String get group_exitGroup => '退出群组';

  @override
  String get group_exitGroupConfirm => '确定要退出该群组吗？';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return '确定要退出“$groupName”吗？重新加入需要群组代码。';
  }

  @override
  String get group_exitedSuccess => '已成功退出群组';

  @override
  String get group_goToGroups => '前往群组 →';

  @override
  String get group_groupMessage => '群组消息';

  @override
  String get group_invalidResponseFormat => '格式无效';

  @override
  String get group_joinedJustNow => '刚刚加入';

  @override
  String get group_joinedRecently => '最近';

  @override
  String get group_leftJustNow => '刚刚退出';

  @override
  String get group_locationNoLongerShared => '您的实时位置已停止与该群组共享';

  @override
  String get group_locationPermissionToJoin => '加入群组需要位置权限。';

  @override
  String get group_locationShared => '您的位置正在与该群组共享';

  @override
  String get group_memberFallbackName => '成员';

  @override
  String group_membersMeta(int count, String when) {
    return '$count 名成员 · $when';
  }

  @override
  String get group_noContactsFound => '未找到联系人';

  @override
  String get group_noGroupCode => '暂无可用群组代码';

  @override
  String get group_noNewMessages => '您将不会收到来自该群组的新消息';

  @override
  String get group_noNumber => '无号码';

  @override
  String get group_openGroup => '进入群组 →';

  @override
  String get group_other => '其他';

  @override
  String get group_qrSavedBody => '点击打开二维码';

  @override
  String get group_qrSavedTitle => '二维码已保存';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 群组代码：$groupCode\n\n使用上述代码或扫描二维码即可快速加入群组。\n\n📲 下载应用保持联系：\n$appLink';
  }

  @override
  String get group_scanToJoin => '扫描此二维码加入群组';

  @override
  String get group_searchMemberHint => '搜索成员...';

  @override
  String get group_shareCodeInfo => '分享群组代码以便他人加入';

  @override
  String get group_shareQr => '分享二维码';

  @override
  String get group_shareQrToInvite => '分享二维码邀请成员';

  @override
  String get group_sheetCreatedSubtitle => '群组已创建完毕。分享代码即可邀请成员加入。';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name，您的群组已准备就绪。分享代码即可邀请成员加入。';
  }

  @override
  String get group_sheetCreatedTitle => '群组创建成功！';

  @override
  String get group_sheetJoinedSubtitle => '欢迎，您现在已成为该群组成员。';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return '欢迎 $name，您现在已加入该群组。';
  }

  @override
  String get group_sheetJoinedTitle => '加入成功！';

  @override
  String get group_sheetLeftSubtitle => '您已不再是该群组的成员。';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name，您已退出该群组。';
  }

  @override
  String get group_sheetLeftTitle => '您已退出该群组';

  @override
  String get group_showQrCode => '显示二维码';

  @override
  String get group_startConversation => '随时发送第一条消息开启畅聊';

  @override
  String get group_statusUpdateFailed => '更新群组状态失败';

  @override
  String get group_teamCode => '团队代码';

  @override
  String get group_teamCodeLabel => '团队代码：';

  @override
  String get group_track => '追踪';

  @override
  String get group_unnamedMember => '未命名成员';

  @override
  String get group_unnamedTrip => '未命名行程';

  @override
  String get group_updateGroupConfirm => '确定要更新该群组资料吗？';

  @override
  String get group_updateGroupTitle => '更新群组';

  @override
  String get group_youAreAdmin => '您是该群组的管理员';

  @override
  String get home_actionAllContacts => '所有联系人';

  @override
  String get home_actionAudioVideoCall => '语音/视频通话';

  @override
  String get home_actionChatting => '聊天';

  @override
  String get home_actionSafeZone => '安全区域';

  @override
  String get home_actionTracking => '实时追踪';

  @override
  String get home_actionWalkieTalkie => '对讲机';

  @override
  String get home_active => '活跃';

  @override
  String get home_activeSessions => '活跃会话';

  @override
  String home_activeSessionsCount(int count) {
    return '$count 个活跃会话';
  }

  @override
  String get home_allMembers => '全部成员';

  @override
  String get home_createGroup => '创建群组';

  @override
  String get home_createGroupSubtitle => '创建新群组';

  @override
  String get home_goodToSeeYou => '很高兴再次见到您 👋';

  @override
  String home_groupsCount(int count) {
    return '$count 个群组';
  }

  @override
  String home_helloName(String name) {
    return '您好，$name';
  }

  @override
  String get home_inactive => '非活跃';

  @override
  String get home_joinGroup => '加入群组';

  @override
  String get home_joinGroupSubtitle => '加入现有群组';

  @override
  String home_lastSeen(String time) {
    return '最后在线：$time';
  }

  @override
  String get home_newThisMonth => '本月新增';

  @override
  String get home_noActivePrivateSessions => '暂无活跃的隐身会话';

  @override
  String get home_noGroupsAvailable => '暂无群组';

  @override
  String get home_noGroupsFound => '未找到群组';

  @override
  String get home_noMembersFound => '未找到成员';

  @override
  String home_noMembersMatch(String query) {
    return '未找到匹配“$query”的成员';
  }

  @override
  String get home_noMembersOnline => '当前没有成员在线';

  @override
  String get home_noNameGroup => '未命名群组';

  @override
  String get home_noRecentlyActiveMembers => '最近没有活跃成员';

  @override
  String get home_onlineNow => '当前在线';

  @override
  String get home_peopleOnline => '在线用户';

  @override
  String get home_peopleOnlineSubtitle => '这些成员当前在应用中保持活跃，可随时发起联络。';

  @override
  String get home_privateMode => '隐身模式';

  @override
  String get home_privateModeIsOn => '隐身模式已开启';

  @override
  String get home_privateModeOffHint => '关闭隐身模式后，授权成员可以查看您的实时位置。';

  @override
  String get home_privateModeOnHint => '开启隐身模式后，其他人无法查看您的实时位置。';

  @override
  String get home_quickActionsSubtitle => '触手可及，一键直达所有功能。';

  @override
  String get home_quickActionsTitle => '快捷操作';

  @override
  String get home_recentlyOnline => '最近在线';

  @override
  String get home_searchGroupsHint => '搜索群组...';

  @override
  String get home_searchMembersHint => '搜索成员...';

  @override
  String get home_showLess => '收起';

  @override
  String get home_sortNameAsc => '排序：姓名 (A-Z)';

  @override
  String get home_sortNameDesc => '排序：姓名 (Z-A)';

  @override
  String home_startedAt(String time) {
    return '开始于 $time';
  }

  @override
  String get home_statGroups => '群组';

  @override
  String get home_statMembers => '成员';

  @override
  String get home_statNow => '现在';

  @override
  String get home_statTotal => '总计';

  @override
  String get home_totalMembers => '总成员数';

  @override
  String home_totalMembersCount(int count) {
    return '共 $count 名成员';
  }

  @override
  String get home_unableToFetchGroups => '获取群组列表失败';

  @override
  String get home_unknownMember => '未知成员';

  @override
  String get home_upgradeSubtitle => '为您的团队解锁高级功能';

  @override
  String get home_upgradeToPremium => '升级至高级版';

  @override
  String get home_viewPlans => '查看套餐';

  @override
  String get home_walkieExpired => '已过期';

  @override
  String get home_walkieOneHourFree => '1小时免费';

  @override
  String get home_walkieRenew => '续订';

  @override
  String get home_walkieSubscribed => '已订阅';

  @override
  String get home_youAreInvisible => '您当前处于隐身状态';

  @override
  String get home_youAreVisible => '您当前对他人可见';

  @override
  String get http_networkError => '发生错误，请重试！';

  @override
  String get http_sessionExpired => '会话已过期，请重新登录。';

  @override
  String get http_unexpectedError => '发生意外错误，请重试。';

  @override
  String get imagePicker_camera => '相机';

  @override
  String get imagePicker_cancel => '取消';

  @override
  String get imagePicker_cropTitle => '裁剪图片';

  @override
  String get imagePicker_gallery => '相册';

  @override
  String get imagePicker_title => '选择一个选项';

  @override
  String get intro_realTimeTrackingSubtitle => '在地图上即时查看朋友、家人或团队成员的实时位置。';

  @override
  String get intro_realTimeTrackingTitle => '实时追踪';

  @override
  String get intro_secureSubtitle => '安全私密地与指定联系人\n共享您的实时位置。';

  @override
  String get intro_secureTitle => '安全便捷';

  @override
  String get intro_skip => '跳过';

  @override
  String get intro_walkieSubtitle => '信号薄弱无须担心，随时随地\n保持联系。';

  @override
  String get intro_walkieTitle => '对讲机\n功能';

  @override
  String get media_cannotOpen => '无法打开';

  @override
  String get media_documentNotFound => '未找到文档';

  @override
  String get media_invalidLink => '无效链接';

  @override
  String get media_noDocuments => '未找到文档';

  @override
  String get media_noLinks => '未找到链接';

  @override
  String get media_noMedia => '未找到媒体';

  @override
  String get media_tabDocs => '文档';

  @override
  String media_tabDocsCount(int count) {
    return '文档 ($count)';
  }

  @override
  String get media_tabLinks => '链接';

  @override
  String media_tabLinksCount(int count) {
    return '链接 ($count)';
  }

  @override
  String get media_tabMedia => '媒体';

  @override
  String media_tabMediaCount(int count) {
    return '媒体 ($count)';
  }

  @override
  String get media_title => '媒体、链接和文档';

  @override
  String get media_videoNotFound => '未找到视频';

  @override
  String get menu_contactUsSubtitle => '了解更多关于我们';

  @override
  String get menu_editProfile => '编辑个人资料';

  @override
  String get menu_editProfileSubtitle => '更新个人信息';

  @override
  String get menu_followUsOn => '关注我们';

  @override
  String get menu_logOut => '退出登录';

  @override
  String get menu_logOutConfirmMessage => '您确定要退出登录吗？';

  @override
  String get menu_logOutSubtitle => '退出当前账号';

  @override
  String get menu_profileImageUpdateFailed => '更新头像失败';

  @override
  String get menu_profileImageUpdated => '头像更新成功';

  @override
  String get notif_accept => '接听';

  @override
  String get notif_channelHighImportanceDesc => '高优先级通知的默认渠道';

  @override
  String get notif_channelHighImportanceName => '高优先级通知';

  @override
  String get notif_channelWalkieAudioDesc => '维持实时语音通信并在后台采集麦克风音频';

  @override
  String get notif_channelWalkieAudioName => '对讲实时音频';

  @override
  String get notif_channelWalkieCallsDesc => '对讲呼入';

  @override
  String get notif_channelWalkieCallsName => '对讲呼叫';

  @override
  String get notif_channelWalkieDesc => '群组对讲通话及发言更新';

  @override
  String get notif_channelWalkieLiveDesc => '活跃对讲频道的通知';

  @override
  String get notif_channelWalkieLiveName => '对讲实时频道';

  @override
  String get notif_channelWalkieName => '对讲机';

  @override
  String notif_connectedIn(String group) {
    return '已连接至 $group • 实时音频流';
  }

  @override
  String get notif_goToWalkie => '前往对讲页面';

  @override
  String get notif_incomingWalkieTitle => '对讲呼入';

  @override
  String notif_isTalking(String name) {
    return '$name 正在讲话';
  }

  @override
  String get notif_leave => '离开';

  @override
  String get notif_openWalkie => '打开对讲';

  @override
  String get notif_reject => '拒绝';

  @override
  String notif_stoppedTalking(String name) {
    return '$name 已停止讲话';
  }

  @override
  String get notif_walkieActiveConversation => '活跃的对讲对话';

  @override
  String get notif_walkieActiveTitle => '对讲机处于活跃状态';

  @override
  String notif_wantsToTalk(String name) {
    return '$name 请求发言';
  }

  @override
  String get notifications_clearAll => '清除全部通知';

  @override
  String get notifications_clearedSuccess => '已成功清除所有通知';

  @override
  String get notifications_emptySubtitle => '您当前没有任何新通知或提醒。';

  @override
  String get notifications_emptyTitle => '暂无通知';

  @override
  String get notifications_filterAll => '全部';

  @override
  String get notifications_filterCalls => '通话';

  @override
  String get notifications_filterChats => '聊天';

  @override
  String get notifications_filterUnread => '未读';

  @override
  String get notifications_loadingDetails => '正在加载通知详情';

  @override
  String get notifications_recentCalls => '最近通话';

  @override
  String get notifications_title => '通知';

  @override
  String get otpCharges_chargedNotice =>
      '后续向该号码发送登录验证码将产生相应费用。重发验证码免费（最多 3 次）。';

  @override
  String get otpCharges_chargesApplyTo => '资费适用于';

  @override
  String get otpCharges_eachOtpCosts => '每条验证码费用';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return '每条验证码费用为 $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return '每条验证码费用为 $amount（含 $percent% 税费）';
  }

  @override
  String get otpCharges_firstLoginFree => '您的首次登录为免费体验。';

  @override
  String get otpCharges_freeBody => '发送至该号码的登录短信验证码不产生任何费用。';

  @override
  String get otpCharges_freeTitle => '您的手机号接收验证码完全免费';

  @override
  String otpCharges_gstTitle(String percent) {
    return '增值税 ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return '含 $percent% 税费';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return '含 $percent% 综合税';
  }

  @override
  String get otpCharges_noInternet => '无网络连接，请检查您的网络设置后重试。';

  @override
  String get otpCharges_otpCharge => '短信资费';

  @override
  String otpCharges_pay(String amount) {
    return '支付 $amount';
  }

  @override
  String get otpCharges_paymentCancelled => '支付已取消。您主动取消了交易，未产生任何扣费。';

  @override
  String get otpCharges_paymentFailed => '支付失败。如已扣款，费用将在 5–7 个工作日内退还。';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return '支付暂停 ($amount)';
  }

  @override
  String get otpCharges_paymentReceived => '已收到付款。验证码可能需要稍等片刻送达。';

  @override
  String get otpCharges_paymentStartFailed => '发起支付失败，请重试。';

  @override
  String get otpCharges_paymentsPaused => '管理员已暂停短信支付功能。详情请点击下方。';

  @override
  String get otpCharges_paymentsUnavailable => '短信支付服务暂时不可用，请稍后重试。';

  @override
  String get otpCharges_sessionExpired => '会话已过期，请重新发起操作。';

  @override
  String get otpCharges_title => '短信验证码费用';

  @override
  String get otpCharges_totalPerOtp => '每条验证码总计';

  @override
  String get otpCharges_tryAgainMoment => '发生未知错误，请稍后重试。';

  @override
  String get otpCharges_unknownBody => '印度号码的登录验证码免费。其他国家或地区将在登录付款前显示具体资费。';

  @override
  String get otpCharges_unknownTitle => '短信验证码费用取决于您所在的国家或地区';

  @override
  String get otpCharges_updateApp => '无法启动支付，请更新应用后重试。';

  @override
  String otpCharges_vatTitle(String percent) {
    return '税率 ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      '支付验证失败。如果已扣款，款项将在 5–7 个工作日内原路退回。';

  @override
  String get otpCharges_yourNumber => '您的号码';

  @override
  String get package_noPackages => '目前暂无可用套餐。';

  @override
  String package_plansComingSoon(String title) {
    return '$title 相关套餐即将推出';
  }

  @override
  String get package_subtitle => '选择功能模块以查看相应套餐';

  @override
  String get package_title => '套餐与定价';

  @override
  String get package_viewPlans => '查看套餐';

  @override
  String get perm_alwaysLocationBody => '为了在后台实时跟踪群组，请在应用设置中将位置访问权限设为“始终允许”。';

  @override
  String get perm_alwaysLocationTitle => '启用“始终允许”位置权限';

  @override
  String get perm_chooseAllowAllTime => '请在随后的弹窗中选择“始终允许”。';

  @override
  String get perm_collectsLocationBody =>
      '即使在应用程序关闭或未使用时，此应用也会收集位置数据，以确保顺利进行工作并提供高效跟踪。';

  @override
  String get perm_enableDeviceGpsBody => '请开启设备上的 GPS（Google 位置服务）。';

  @override
  String get perm_enableGpsTitle => '开启 GPS';

  @override
  String get perm_exitBody => '您要退出应用吗？';

  @override
  String get perm_exitTitle => '确定吗？';

  @override
  String get perm_gpsRequiredBody => '需要开启 GPS 才能实时跟踪您的群组。';

  @override
  String get perm_locationTitle => '位置权限';

  @override
  String get perm_trackingPermissionBody => 'FG Partner 应用需要您的许可才能在登录期间跟踪位置。';

  @override
  String get permission_allowAllTheTime => '始终允许';

  @override
  String get permission_allowLocation => '允许位置信息';

  @override
  String get permission_allowLocationFirst => '请先允许位置权限。';

  @override
  String permission_allowNamed(String permission) {
    return '允许 $permission';
  }

  @override
  String get permission_allowNotifications => '允许通知';

  @override
  String get permission_appPermissionsSubtitle => '查看应用所需的各项权限。';

  @override
  String get permission_appPermissionsTitle => '应用权限';

  @override
  String get permission_badgeGranted => '已授予';

  @override
  String get permission_badgeOptional => '可选';

  @override
  String get permission_badgeRecommended => '推荐';

  @override
  String get permission_badgeRequired => '必需';

  @override
  String get permission_camera => '相机';

  @override
  String get permission_cameraDescription => '供应用中拍摄照片或录制视频的功能使用。';

  @override
  String get permission_cameraSettingsMessage => '拍摄照片和视频需要相机权限，请在应用设置中开启。';

  @override
  String get permission_cameraWhy => '允许您拍摄照片和录制视频，用于个人资料、聊天及其他应用功能。';

  @override
  String get permission_contacts => '通讯录';

  @override
  String get permission_contactsDescription => '用于查找或选择联系人，以配合相关应用功能。';

  @override
  String get permission_contactsSettingsMessage => '查找和选择联系人需要通讯录权限，请在设置中开启。';

  @override
  String get permission_contactsWhy => '帮助您在使用相关功能时快速查找并选择手机联系人。';

  @override
  String get permission_gateCheckFailed => '检查权限状态失败，请重试。';

  @override
  String get permission_gateSubtitle =>
      'FG Tracker 需要这些权限来接听电话、接收通知并运行考勤、实时追踪与安全区域功能。';

  @override
  String get permission_gateTitle => '需要授权';

  @override
  String get permission_genericSettingsMessage => '需要此权限，请在应用设置中开启。';

  @override
  String get permission_iosLocationServicesOff =>
      '定位服务已关闭。请打开 设置 → 隐私与安全性 → 定位服务 并开启，然后返回。';

  @override
  String get permission_location => '位置信息';

  @override
  String get permission_locationAndNotificationRequired => '需要位置和通知权限才能继续。';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      '必须授予位置和通知权限才能继续。';

  @override
  String get permission_locationDescription => '考勤签到、实时追踪及安全区域警报（包含后台运行）所必需。';

  @override
  String get permission_locationRequiredToContinue => '需要位置权限才能继续。';

  @override
  String get permission_locationStatusApproximate => '仅允许了粗略位置，需要授予精确位置。';

  @override
  String get permission_locationStatusBlocked => '位置权限已被阻止，请在设置中开启。';

  @override
  String get permission_locationStatusDone => '始终允许 · 精确位置 · GPS已开启';

  @override
  String get permission_locationStatusGpsOff => '设备定位 (GPS) 已关闭。';

  @override
  String get permission_locationStatusNeedAlways => '需要选择“始终允许”。';

  @override
  String get permission_locationStatusNotAllowed => '尚未授予位置权限。';

  @override
  String get permission_locationWhyExtra => '请选择“始终允许”并保持“精确位置”开启。';

  @override
  String get permission_logout => '退出';

  @override
  String get permission_microphone => '麦克风 / 音频';

  @override
  String get permission_microphoneDescription => '供语音聊天、对讲机和语音呼叫等功能使用。';

  @override
  String get permission_microphoneSettingsMessage =>
      '语音、对讲和通话功能需要麦克风权限，请在设置中开启。';

  @override
  String get permission_microphoneWhy => '在您使用相关功能时支持语音交流、对讲传输和电话呼叫。';

  @override
  String permission_notGrantedNamed(String permission) {
    return '未授予 $permission 权限，请重试。';
  }

  @override
  String get permission_notificationRequiredToContinue => '需要通知权限才能继续。';

  @override
  String get permission_notificationSettingsText =>
      'FG Tracker 的通知已关闭。请打开 设置 → 通知 并允许通知。';

  @override
  String get permission_notificationStatusBlocked => '通知已被拦截，请在系统设置中开启。';

  @override
  String get permission_notificationStatusDone => '已允许';

  @override
  String get permission_notificationStatusNotAllowed => '尚未授予通知权限。';

  @override
  String get permission_notifications => '通知';

  @override
  String get permission_notificationsDescription => '接收来电呼叫、聊天消息及考勤/安全区域警报所必需。';

  @override
  String get permission_notificationsWhyExtra => '未授予该权限时，来电将无法响铃提醒。';

  @override
  String get permission_openSettings => '打开设置';

  @override
  String get permission_preciseLocation => '精确位置';

  @override
  String get permission_pushNotifications => '推送通知';

  @override
  String get permission_reasonLocation => '考勤签到、实时位置追踪及安全区域警报需要位置权限。';

  @override
  String get permission_reasonLocationAlways =>
      '请选择“始终允许”，以便在后台运行时也能保持实时追踪和安全区域警报。';

  @override
  String get permission_reasonNotification => '接收来电、聊天消息、考勤和安全区域警报需要通知权限。';

  @override
  String get permission_reasonPrecise => '精准考勤、实时追踪和安全区域警报需要精确位置权限。';

  @override
  String get permission_required => '需要权限';

  @override
  String get permission_selectAllowAllTheTime => '请选择“始终允许”以继续。';

  @override
  String get permission_settingsAndroidAlways =>
      '打开 设置 → 应用权限 → 位置信息，选择“始终允许”。';

  @override
  String get permission_settingsAndroidBlocked =>
      'FG Tracker 的位置权限被拦截。请打开 设置 → 应用权限 → 位置信息 并选择“始终允许”。';

  @override
  String get permission_settingsAndroidPrecise =>
      '打开 设置 → 应用权限 → 位置信息，开启“使用精确位置”。';

  @override
  String get permission_settingsIosAlways => '打开 设置 → 位置，选择“始终”。';

  @override
  String get permission_settingsIosBlocked =>
      'FG Tracker 的位置权限已关闭。请打开 设置 → 位置 并选择“始终”。';

  @override
  String get permission_settingsIosPrecise => '打开 设置 → 位置，开启“精确位置”。';

  @override
  String get permission_skipAndContinue => '跳过并继续';

  @override
  String get permission_turnOnLocation => '开启位置信息';

  @override
  String get permission_turnOnPreciseLocation => '开启精准位置';

  @override
  String get permission_unableToRequest => '无法请求权限。';

  @override
  String get permission_whyWeNeedThis => '为什么需要此权限？';

  @override
  String get registration_contactNumberHint => '输入联系电话';

  @override
  String get registration_contactNumberLabel => '联系电话';

  @override
  String get registration_doneButton => '完成';

  @override
  String get registration_emailHint => '输入电子邮件地址';

  @override
  String get registration_emailLabel => '电子邮件地址';

  @override
  String get registration_genderFemale => '女';

  @override
  String get registration_genderLabel => '选择性别';

  @override
  String get registration_genderMale => '男';

  @override
  String get registration_genderOther => '其他';

  @override
  String get registration_selectGenderError => '请选择您的性别';

  @override
  String get registration_userNameHint => '输入用户名';

  @override
  String get registration_userNameLabel => '用户名';

  @override
  String get repo_allCallsCleared => '所有通话记录已成功清除';

  @override
  String get repo_callDeleted => '通话记录已成功删除';

  @override
  String get repo_invalidResponse => '无效的响应格式';

  @override
  String get repo_loadLocationsFailed => '加载群组位置失败';

  @override
  String get repo_pkgConflict => '此方案已激活或付款正在进行中。';

  @override
  String get repo_pkgNotFound => '方案目前不可用，请稍后再试。';

  @override
  String get repo_pkgOffline => '无网络连接，请检查网络并重试。';

  @override
  String get repo_pkgSessionExpired => '您的会话已过期，请重新登录。';

  @override
  String get repo_pkgTimeout => '服务器响应时间过长，请重试。';

  @override
  String get repo_selectedCallsDeleted => '选定通话记录已成功删除';

  @override
  String get repo_unnamedGroup => '未命名群组';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return '总距离：$distance  •  允许偏离：$deviation';
  }

  @override
  String get safeRoute_activeTitle => '生效中的安全路线';

  @override
  String get safeRoute_alertSettingsDesc => '管理安全路线警报、偏离限额及通知偏好。';

  @override
  String get safeRoute_alertSheetDesc => '团队成员偏离既定安全路线时的实时警报';

  @override
  String get safeRoute_alertTitle => '安全路线偏离警报';

  @override
  String get safeRoute_appBarSubtitle => '为您的团队成员规划一条安全行进路线。';

  @override
  String get safeRoute_destination => '目的地点';

  @override
  String get safeRoute_deviated => '已偏离安全路线';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return '当成员偏离安全路线超过 $distance 时将触发警报。';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (偏离距离：$distance)';
  }

  @override
  String get safeRoute_deviationLimit => '偏离限额';

  @override
  String get safeRoute_deviationSubtitle => '设置允许偏离既定路线的最大距离。';

  @override
  String get safeRoute_distance => '距离';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance 公里 • $minutes 分钟';
  }

  @override
  String get safeRoute_edit => '编辑安全路线';

  @override
  String get safeRoute_end => '终点';

  @override
  String safeRoute_estTime(int minutes) {
    return '预计用时：$minutes 分钟';
  }

  @override
  String get safeRoute_featureDesc => '为成员设定预定行进路线。一旦有人偏离路线即可即时收到提醒。';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    return '$group ($count 名成员)';
  }

  @override
  String get safeRoute_helpDeviationBody => '设置成员可以偏离既定路线的距离阈值。超出阈值将自动发送警报。';

  @override
  String get safeRoute_helpDeviationTitle => '什么是偏离限额？';

  @override
  String get safeRoute_helpHowBody => '选择成员，设定起点与终点，选取最佳路线并设置允许的偏离范围。';

  @override
  String get safeRoute_helpHowTitle => '如何创建安全路线？';

  @override
  String get safeRoute_helpTitle => '安全路线帮助';

  @override
  String get safeRoute_helpWhatBody => '设定起点和目的地，为团队成员规划安全的通勤或出行路线。';

  @override
  String get safeRoute_helpWhatTitle => '什么是安全路线？';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$name 已偏离预定安全路线';
  }

  @override
  String get safeRoute_recommended => '推荐路线';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (推荐)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return '路线 ($name)';
  }

  @override
  String get safeRoute_saveActivate => '保存并激活安全路线';

  @override
  String get safeRoute_saveActivateGroup => '保存并为群组激活安全路线';

  @override
  String get safeRoute_selectedRoute => '已选路线';

  @override
  String get safeRoute_setRoutesSubtitle => '为所有群组成员创建并管理安全行进路线。';

  @override
  String get safeRoute_start => '起点';

  @override
  String get safeRoute_startLocation => '出发地点';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. 设置允许偏离限额';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. 预览并生效';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. 预览路线';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. 选择路线';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. 为成员设置路线';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. 设置起点与终点';
  }

  @override
  String get safeRoute_subtitle => '路线监护';

  @override
  String get safeRoute_title => '安全路线';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return '半径：$radius  •  中心：$center';
  }

  @override
  String get safeZone_activePreview => '生效中 (预览)';

  @override
  String get safeZone_activeTitle => '生效中的安全区域';

  @override
  String get safeZone_alertSettingsDesc => '管理安全区域、警报距离及通知偏好设置';

  @override
  String get safeZone_alertSheetDesc => '团队成员离开安全区域时的实时警报';

  @override
  String get safeZone_alertTitle => '安全区域警报';

  @override
  String safeZone_allMonitored(int count) {
    return '该安全区域内将对全部 $count 名成员进行实时监护。';
  }

  @override
  String get safeZone_appBarSubtitle => '划定安全防护区。当有人离开该区域时\n即刻向您发送警报。';

  @override
  String safeZone_appliedToGroup(int count) {
    return '该安全区域将应用于所选群组内的全部 $count 名成员。';
  }

  @override
  String get safeZone_edit => '编辑安全区域';

  @override
  String get safeZone_exited => '已离开安全区域';

  @override
  String get safeZone_featureDesc => '为团队划定安全地理区域。当有人离开安全区时立即收到警报。';

  @override
  String get safeZone_helpHowBody => '选择成员，在地图上选定中心点并设置相应半径。';

  @override
  String get safeZone_helpHowTitle => '如何创建安全区域？';

  @override
  String get safeZone_helpRadiusBody => '根据实际需求设定安全区域半径（500米、1公里、2公里或5公里）。';

  @override
  String get safeZone_helpRadiusTitle => '什么是安全区半径？';

  @override
  String get safeZone_helpTitle => '安全区域帮助';

  @override
  String get safeZone_helpWhatBody => '在地图上划定特定范围，并在成员走出该范围时自动触发警报。';

  @override
  String get safeZone_helpWhatTitle => '什么是安全区域？';

  @override
  String safeZone_memberLeft(String name) {
    return '$name 已离开安全区域';
  }

  @override
  String get safeZone_membersMonitored => '成员将在此安全区域内受到实时监护。';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return '靠近 $place (在 $zone 之外)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place (在 $zone 之外)';
  }

  @override
  String get safeZone_saveActivate => '保存并激活安全区域';

  @override
  String get safeZone_saveActivateGroup => '保存并为群组激活安全区域';

  @override
  String get safeZone_searchLocation => '搜索地点...';

  @override
  String get safeZone_statusLabel => '状态：';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. 预览安全区域';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. 设置安全区半径';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. 在地图上选择位置';
  }

  @override
  String get safeZone_subtitle => '区域防护';

  @override
  String get safeZone_title => '安全区域';

  @override
  String safeZone_totalMembers(int count) {
    return '共 $count 名成员';
  }

  @override
  String get safety_active => '有效';

  @override
  String get safety_alertSettings => '警报设置';

  @override
  String get safety_alerts => '警报';

  @override
  String get safety_alertsDesc => '需要立即处理';

  @override
  String get safety_bannerBody => '借助智能安全功能实时监护并守护您的团队。';

  @override
  String get safety_bannerTitle => '您的安全，我们的首要使命';

  @override
  String get safety_chooseFeature => '选择安全功能';

  @override
  String get safety_comingSoonBody => '保护团队安全的智能防护功能即将上线。';

  @override
  String get safety_contactSupport => '联系支持团队';

  @override
  String get safety_editAnytime => '您可以在日后随时对其进行修改或停用。';

  @override
  String get safety_mapCityPark => '城市公园';

  @override
  String get safety_mapMainRoad => '主干道';

  @override
  String get safety_mapMarketLane => '集市巷';

  @override
  String get safety_mapRiver => '河畔';

  @override
  String get safety_mapStationRoad => '车站路';

  @override
  String get safety_needHelpBody => '如需任何安全相关支持，请联络我们的技术客服团队。';

  @override
  String get safety_quickOverview => '快速概览';

  @override
  String get safety_recentAlerts => '最近警报';

  @override
  String get safety_recenter => '重新居中';

  @override
  String get safety_safeNow => '当前安全';

  @override
  String get safety_safeNowDesc => '所有成员均在安全区域/路线内';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. 选择群组';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. 选择成员';
  }

  @override
  String get safety_tabIndividual => '个人';

  @override
  String get safety_tagline => '时刻守护，保持连接。';

  @override
  String get safety_title => '安全守护';

  @override
  String get safety_viewAllMembers => '查看全部成员';

  @override
  String get sheet_addGroupMember => '添加群组成员';

  @override
  String get sheet_admin => '管理员';

  @override
  String get sheet_attachSubtitle => '与团队共享文件和媒体';

  @override
  String get sheet_attachUpload => '附加 / 上传';

  @override
  String get sheet_attendance => '考勤';

  @override
  String get sheet_callOptions => '通话选项';

  @override
  String get sheet_cantRemoveSelf => '您不能将自己从群组中移除。';

  @override
  String get sheet_contact => '联系人';

  @override
  String get sheet_contactsNotOnApp => '您的联系人尚未使用 FG Tracker。';

  @override
  String get sheet_document => '文档';

  @override
  String get sheet_groupMembers => '群组成员';

  @override
  String get sheet_location => '位置';

  @override
  String get sheet_memberRemoved => '成员已成功移除';

  @override
  String get sheet_noMembers => '未找到成员';

  @override
  String get sheet_noRegisteredContacts => '没有已注册的联系人';

  @override
  String get sheet_noUserFound => '未找到用户';

  @override
  String get sheet_normalAudioCall => '普通语音通话';

  @override
  String get sheet_normalAudioCallSubtitle => '标准清晰音质';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count位已注册联系人',
      one: '1位已注册联系人',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return '确定要将 $name 从群组中移除吗？';
  }

  @override
  String get sheet_removeMemberTitle => '移除成员';

  @override
  String get sheet_searchContacts => '搜索联系人';

  @override
  String get sheet_walkieCall => '对讲通话';

  @override
  String get sheet_walkieCallSubtitle => '一键即通通信';

  @override
  String get sos_addDetailsMandatory => '补充说明 (必填)';

  @override
  String get sos_addDetailsOptional => '补充说明 (可选)';

  @override
  String get sos_addFamilyMember => '添加家庭成员';

  @override
  String get sos_addFamilyMemberRequired => '发送 SOS 紧急求救前请至少添加 1 位家庭成员';

  @override
  String get sos_addPhotoHint => '附上照片有助于他人快速了解现场状况。';

  @override
  String get sos_addPhotoOptional => '添加现场照片 (可选)';

  @override
  String get sos_alertSent => 'SOS 求救信号已发出！';

  @override
  String get sos_alertSentToNearby => '您的求救警报已发送给附近的人。';

  @override
  String get sos_alertWillBeSent => '警报将发送给附近的联络人';

  @override
  String get sos_alertWillBeSentFamily => '您的警报将同时发送给附近人员及紧急联系家属。';

  @override
  String sos_availableUsers(int count) {
    return '$count 位可用用户';
  }

  @override
  String get sos_detailsHint => '请输入其他补充信息...';

  @override
  String get sos_detailsMandatoryForOther => '选择“其他”原因时必须填写补充说明';

  @override
  String get sos_howItWorks => '运作流程';

  @override
  String get sos_howItWorksIntro => 'SOS 求救警报可在紧急情况下及时通知附近的人员和您的家人。';

  @override
  String get sos_howItWorksTitle => 'SOS 紧急求救如何运作？';

  @override
  String get sos_liveTrackingStarted => '实时追踪已启动';

  @override
  String sos_locationSharedWithFamily(int count) {
    return '正在与 $count 位家庭成员共享您的实时位置';
  }

  @override
  String sos_membersSelected(int count) {
    return '已选择 $count 位成员';
  }

  @override
  String get sos_needHelp => '需要帮助吗？';

  @override
  String get sos_needHelpBody => '向附近的人发送 SOS 警报。\n他们将收到提醒并前来协助您。';

  @override
  String get sos_noMatchFound => '未找到匹配项';

  @override
  String get sos_noUsersFound => '未找到用户';

  @override
  String get sos_notifyFamilyTitle => '通知您的家人 (需选择 1 至 5 位)';

  @override
  String get sos_notifyUpdates => '有最新动态我们将第一时间通知您';

  @override
  String get sos_okGotIt => '知道了';

  @override
  String get sos_peopleWithinRadius => '方圆 2 公里范围内的人员';

  @override
  String get sos_privacyNote => '隐私安全第一。您的实时位置仅在 SOS 警报生效期间共享。';

  @override
  String get sos_reasonAccident => '交通事故';

  @override
  String get sos_reasonMedical => '医疗急救';

  @override
  String get sos_reasonOther => '其他';

  @override
  String get sos_reasonSafety => '人身安全';

  @override
  String get sos_reasonThreat => '威胁/危险';

  @override
  String get sos_required => '必需';

  @override
  String get sos_searchUsers => '搜索用户';

  @override
  String get sos_selectReason => '选择紧急原因';

  @override
  String get sos_sendSosAlert => '立即发送 SOS 警报';

  @override
  String get sos_stayCalm => '请保持冷静，救援正在赶来';

  @override
  String get sos_step1Body => '点击 SOS 按钮向附近人员发出紧急警报。';

  @override
  String get sos_step1Title => '1. 发出 SOS 警报';

  @override
  String get sos_step2Body => '附近人员将收到包含您精确位置的紧急警报。';

  @override
  String get sos_step2Title => '2. 通知附近人群';

  @override
  String get sos_step3Body => '附近的人可以查看警报并尽快前往协助您。';

  @override
  String get sos_step3Title => '3. 迅速获得援助';

  @override
  String get sos_step4Body => '您的家人将立即收到您的 SOS 求救信息。';

  @override
  String get sos_step4Title => '4. 家属即时获悉';

  @override
  String get sos_subtitle => '向附近人员发送警报';

  @override
  String get sos_title => 'SOS 求救';

  @override
  String get sos_willBeNotified => '将收到通知';

  @override
  String status_activeCount(int count) {
    return '$count 个有效';
  }

  @override
  String get status_addToMyStatus => '添加到我的状态';

  @override
  String get status_allContacts => '所有联系人';

  @override
  String get status_cameraAccessFailed => '无法访问相机';

  @override
  String get status_captionHint => '添加说明...';

  @override
  String get status_changeMedia => '更换媒体';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day $time';
  }

  @override
  String get status_deleted => '状态已删除';

  @override
  String get status_deletedByOwner => '此状态已被作者删除';

  @override
  String get status_exceptContacts => '排除联系人';

  @override
  String get status_exceptSelected => '排除所选';

  @override
  String get status_flip => '翻转';

  @override
  String get status_gallery => '相册';

  @override
  String get status_modePhoto => '照片';

  @override
  String get status_modeText => '文字';

  @override
  String get status_modeVideo => '视频';

  @override
  String get status_myStatus => '我的状态';

  @override
  String get status_new => '新状态';

  @override
  String get status_noCamera => '无可用相机';

  @override
  String get status_noLongerAvailable => '此状态已不可用';

  @override
  String get status_noViewsYet => '暂无浏览';

  @override
  String get status_onlyShareWith => '仅分享给';

  @override
  String get status_pause => '暂停';

  @override
  String get status_pinchZoomHint => '双指捏合可缩放照片';

  @override
  String get status_play => '播放';

  @override
  String get status_postStatus => '发布状态';

  @override
  String get status_previewStatus => '预览状态';

  @override
  String get status_privacy => '隐私';

  @override
  String get status_privacyTitle => '状态隐私';

  @override
  String get status_publishFailed => '无法发布状态';

  @override
  String get status_replyHint => '回复状态...';

  @override
  String get status_retake => '重拍';

  @override
  String get status_selectPhotoFirst => '请先拍照或选择照片';

  @override
  String get status_selectVideoFirst => '请先拍摄或选择视频';

  @override
  String get status_shareUpdatesHint => '与您的团队分享动态';

  @override
  String get status_tapVideoHint => '点击视频播放 / 暂停';

  @override
  String get status_textRequired => '文字状态需要输入文字内容';

  @override
  String get status_title => '状态';

  @override
  String get status_typeHint => '输入状态...';

  @override
  String get status_uploadFailed => '上传失败';

  @override
  String get status_viewMyStatus => '查看我的状态';

  @override
  String get status_viewed => '已查看';

  @override
  String status_viewedBy(int count) {
    return '$count 人已查看';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次浏览',
      one: '1 次浏览',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => '谁可以看到？';

  @override
  String get track_admin => '管理员';

  @override
  String get track_applyRadius => '应用半径';

  @override
  String get track_checkNetworkConnection => '请检查网络连接后重试。';

  @override
  String get track_checkNetworkMembers => '请检查网络连接后重试以查看附近成员。';

  @override
  String get track_currentLocation => '当前位置';

  @override
  String get track_custom => '自定义';

  @override
  String track_customWithValue(String radius) {
    return '自定义 ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return '距离 $distance';
  }

  @override
  String get track_enable => '开启';

  @override
  String get track_enableGpsBody => '若要实时追踪群组位置，请开启手机 GPS。';

  @override
  String get track_enableGpsTitle => '开启 GPS 定位';

  @override
  String get track_errorFailedLoadGroups => '加载群组失败';

  @override
  String get track_errorLoadGroups => '无法加载群组，请重试。';

  @override
  String get track_errorLoadMembers => '无法加载附近成员，请重试。';

  @override
  String get track_errorNoInternet => '无网络连接，请检查您的网络。';

  @override
  String get track_errorServer => '无法连接到服务器，请重试。';

  @override
  String track_groupCode(String code) {
    return '代码：$code';
  }

  @override
  String get track_groupMembers => '群组成员';

  @override
  String track_groupMembersAndCode(int count, String code) {
    return '$count 名成员 • 代码：$code';
  }

  @override
  String get track_groupTab => '群组';

  @override
  String track_groupsCount(int count) {
    return '$count 个群组';
  }

  @override
  String track_groupsHeader(int count) {
    return '群组 ($count)';
  }

  @override
  String get track_helpGroupBody => '创建群组以同时追踪多位成员。';

  @override
  String get track_helpGroupTitle => '如何添加群组？';

  @override
  String get track_helpLiveBody => '在地图上实时追踪团队成员的具体位置。';

  @override
  String get track_helpLiveTitle => '什么是实时追踪？';

  @override
  String get track_helpRadiusBody => '设定用于在地图上搜索周边成员的区域范围。';

  @override
  String get track_helpRadiusTitle => '什么是追踪半径？';

  @override
  String get track_helpTitle => '追踪帮助';

  @override
  String track_lastSeen(String time) {
    return '最后在线：$time';
  }

  @override
  String track_liveCount(int count) {
    return '$count 在线';
  }

  @override
  String get track_liveMembers => '在线成员';

  @override
  String get track_liveTracking => '实时追踪';

  @override
  String get track_locating => '正在定位...';

  @override
  String get track_locationHidden => '位置已隐藏';

  @override
  String get track_locationUnavailable => '位置不可用';

  @override
  String get track_mapOfflineBody => '需要连接网络以加载实时地图数据及成员位置。';

  @override
  String get track_mapUnavailableOffline => '离线状态下地图不可用';

  @override
  String get track_member => '成员';

  @override
  String track_memberPausedSharing(String name) {
    return '$name 已暂停位置共享，其实时位置暂不可用。';
  }

  @override
  String track_membersHeader(int count) {
    return '成员 ($count)';
  }

  @override
  String track_membersLive(int count) {
    return '$count 位成员在线';
  }

  @override
  String get track_menuMembers => '成员';

  @override
  String get track_menuRefreshMap => '刷新地图';

  @override
  String get track_menuTheme => '地图主题';

  @override
  String get track_nearbyYou => '在您附近';

  @override
  String get track_noActiveMembers => '暂无活跃成员';

  @override
  String track_noActiveMembersWithin(String radius) {
    return '在 $radius 范围内未发现活跃成员';
  }

  @override
  String get track_noDescription => '暂无描述';

  @override
  String get track_noGroupsFound => '未找到群组';

  @override
  String get track_noGroupsMatch => '未找到匹配的群组';

  @override
  String track_noGroupsMatchQuery(String query) {
    return '未找到匹配“$query”的群组';
  }

  @override
  String get track_noGroupsYet => '您尚未加入或创建任何群组。';

  @override
  String get track_noInternetTitle => '无网络连接';

  @override
  String get track_noMembersFound => '未找到成员';

  @override
  String get track_noMembersFoundPlain => '未找到成员';

  @override
  String get track_noMembersInGroup => '该群组中暂无成员';

  @override
  String track_noMembersMatch(String query) {
    return '未找到匹配“$query”的成员';
  }

  @override
  String track_noSearchMatches(String query) {
    return '未找到匹配的成员或群组';
  }

  @override
  String track_noSearchResults(String query) {
    return '未找到符合“$query”的成员或群组';
  }

  @override
  String get track_notAvailable => '无';

  @override
  String get track_offlineBanner => '无网络连接，地图与追踪当前处于离线模式。';

  @override
  String get track_private => '私密';

  @override
  String get track_radius => '半径';

  @override
  String get track_refresh => '刷新';

  @override
  String get track_refreshing => '正在刷新...';

  @override
  String get track_retryConnection => '重试连接';

  @override
  String get track_searchHint => '搜索成员或群组...';

  @override
  String get track_searchMembersHint => '搜索成员...';

  @override
  String get track_selectedLocation => '选定位置';

  @override
  String get track_setRadiusSubtitle => '滑动滑块选择区域半径';

  @override
  String get track_setRadiusTitle => '设置追踪半径';

  @override
  String get track_unableToLoadGroups => '加载群组失败';

  @override
  String get track_unableToLoadMembers => '加载成员列表失败';

  @override
  String get track_unnamedGroup => '未命名群组';

  @override
  String get track_unnamedMember => '未命名成员';

  @override
  String get track_yourGroups => '您的群组';

  @override
  String get track_yourLocationPaused => '您的实时位置共享已暂停，当前处于私密状态。';

  @override
  String get util_previewContact => '👤 联系人';

  @override
  String get util_previewDocument => '📄 文档';

  @override
  String get util_previewLocation => '📍 位置';

  @override
  String get util_previewPhoto => '📷 照片';

  @override
  String get util_previewVideo => '🎥 视频';

  @override
  String get util_previewVoice => '🎤 语音消息';

  @override
  String util_spokenEur(String amount) {
    return '$amount 欧元';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amount 英镑';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupees卢比',
      one: '1卢比',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees 卢比 $paise 派士';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount 美元';
  }

  @override
  String get util_unableToCallContact => '无法呼叫此联系人';

  @override
  String get util_unableToStartGroupCall => '无法发起群组通话';

  @override
  String get validation_emailEmpty => '电子邮件地址不能为空';

  @override
  String get validation_emailInvalid => '请输入有效的电子邮件地址。';

  @override
  String validation_required(String field) {
    return '$field 为必填项';
  }

  @override
  String get voice_appLanguage => '应用语言';

  @override
  String get voice_audioChip => '音频';

  @override
  String get voice_captionReady => '说明文字已准备就绪';

  @override
  String get voice_chooseSpeechLanguage => '选择语音识别语言';

  @override
  String get voice_couldntPlay => '无法播放语音消息';

  @override
  String get voice_didntCatch => '未能识别。请点击麦克风并稍微提高音量重试。';

  @override
  String get voice_language => '语言';

  @override
  String get voice_listenBack => '试听录音';

  @override
  String get voice_listenBeforeSending => '在发出前可先试听您的语音消息。';

  @override
  String get voice_listening => '正在聆听…';

  @override
  String get voice_micPermissionNeeded => '使用语音功能需要麦克风权限。';

  @override
  String get voice_micUnavailable => '麦克风不可用，请检查系统设置。';

  @override
  String get voice_noTextCaptured => '未能获取文本，请尝试重新录制。';

  @override
  String get voice_openSettings => '打开设置';

  @override
  String get voice_permissionRequired => '需要权限';

  @override
  String get voice_reRecord => '重新录制';

  @override
  String get voice_readyToSend => '准备发送';

  @override
  String get voice_recordVoice => '录制语音';

  @override
  String get voice_recordVoiceSubtitle => '录制并发送为语音消息';

  @override
  String get voice_recordingYourVoice => '正在录制您的语音…';

  @override
  String get voice_replyReady => '回复已准备就绪';

  @override
  String get voice_reviewTextHint => '可在上方试听语音，或在发送前于输入框中校对修改文字。';

  @override
  String get voice_sendMessage => '发送消息';

  @override
  String get voice_sendVoiceMessage => '发送语音消息';

  @override
  String get voice_speakNowCaption => '请说话 – 正在输入说明文字';

  @override
  String get voice_speakNowMessage => '请说话 – 识别出的文字将填入输入框';

  @override
  String get voice_speakNowReply => '请说话 – 正在将语音转为文字回复';

  @override
  String get voice_speakPlaceholder => '请说话… 转换的文字将显示在此处';

  @override
  String get voice_speechPermissionNeeded => '语音转文字需要语音识别权限。';

  @override
  String get voice_tapToStop => '点击停止';

  @override
  String get voice_textReady => '文字已生成';

  @override
  String get voice_tooMuchNoise => '环境噪音较大 – 请靠近手机并清晰发音';

  @override
  String get voice_type => '类型';

  @override
  String get voice_voiceToText => '语音转文字';

  @override
  String get voice_voiceToTextSubtitle => '说话即可自动转换为文字输入';

  @override
  String get voice_willSendAudioMessage => '您的声音将作为语音消息发送';

  @override
  String get voice_willSendAudioReply => '您的录音将作为语音回复发出';

  @override
  String get voice_willSendWithFile => '您的语音将随文件一同发送';

  @override
  String get voice_yourMessage => '您的消息';

  @override
  String get voice_yourVoiceMessage => '您的语音消息';

  @override
  String get walkiePlan_availableIndividualPlans => '个人套餐';

  @override
  String get walkiePlan_availablePerMonth => '/ 月';

  @override
  String get walkiePlan_availablePerSeat => '/ 席位';

  @override
  String get walkiePlan_availableSingleMember => '单成员 (个人专属权限)';

  @override
  String get walkiePlan_availableSubtitle => '选择心仪套餐以开通或升级您的订阅';

  @override
  String get walkiePlan_availableTeamPlans => '团队套餐';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min–$max 席位  •  团队高效协作';
  }

  @override
  String get walkiePlan_availableTitle => '可选套餐';

  @override
  String get walkiePlan_bottomBarAfterTrial => '免费试用期结束后';

  @override
  String get walkiePlan_bottomBarChoosePlan => '选择套餐';

  @override
  String get walkiePlan_bottomBarContinue => '继续使用对讲机';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return '$price 立即购买';
  }

  @override
  String get walkiePlan_cardActive => '已激活';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return '自 $date 起生效';
  }

  @override
  String get walkiePlan_cardAssigned => '已分配';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return '由 $name 分配';
  }

  @override
  String get walkiePlan_cardAssignedToYou => '分配给您';

  @override
  String get walkiePlan_cardAvailable => '剩余可用';

  @override
  String get walkiePlan_cardManageMembers => '管理成员';

  @override
  String get walkiePlan_cardNoActiveIndividual => '暂无有效个人订阅';

  @override
  String get walkiePlan_cardNoActiveTeam => '暂无有效团队套餐或分配席位';

  @override
  String get walkiePlan_cardOneSeatSelf => '1 席位 (本人)';

  @override
  String get walkiePlan_cardPersonal => '个人版';

  @override
  String get walkiePlan_cardPurchased => '已购';

  @override
  String get walkiePlan_cardPurchasedByYou => '本人购买';

  @override
  String get walkiePlan_cardPurchasedOn => '购买日期';

  @override
  String get walkiePlan_cardSeatsMembers => '席位 / 成员';

  @override
  String get walkiePlan_cardSubscribedByYou => '本人订阅';

  @override
  String get walkiePlan_cardTeamAdministrator => '团队管理员';

  @override
  String get walkiePlan_cardValidUntil => '有效期至';

  @override
  String get walkiePlan_cardView => '查看';

  @override
  String get walkiePlan_cardViewPlan => '查看套餐';

  @override
  String walkiePlan_couponDiscount(String value) {
    return '$value 优惠';
  }

  @override
  String get walkiePlan_couponExpired => '优惠券已过期';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return '立减 $amount';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet => '未达到最低订单金额门槛';

  @override
  String get walkiePlan_couponNotEligible => '当前套餐不满足使用条件';

  @override
  String get walkiePlan_couponNotStarted => '该优惠活动尚未开始';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent% 折扣';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable => '此优惠券不可用于该套餐';

  @override
  String walkiePlan_couponValidTill(String date) {
    return '有效期至 $date';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => '继续支付';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return '继续开通 $plan';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => '优惠券已成功生效！';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return '优惠券兑换成功！立省 $amount';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => '应用优惠券失败';

  @override
  String get walkiePlan_ctrlCouponRemoved => '已移除优惠券';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'Cashfree 错误 ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed => '支付初始化失败。';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return '创建支付会话失败：$error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return '无法处理付款：$error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => '正在加载套餐...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans => '无法加载套餐列表，请重试。';

  @override
  String get walkiePlan_detailsAllBanks => '支持所有主流印度银行';

  @override
  String get walkiePlan_detailsApplied => '已应用';

  @override
  String get walkiePlan_detailsApply => '应用';

  @override
  String get walkiePlan_detailsApplyCaps => '兑换';

  @override
  String get walkiePlan_detailsAvailableCoupons => '可用优惠券';

  @override
  String get walkiePlan_detailsCard => '信用卡 / 借记卡';

  @override
  String get walkiePlan_detailsChooseTitle => '选择套餐';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return '代码：$code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => '优惠券与促销';

  @override
  String get walkiePlan_detailsEnterCouponHint => '输入优惠券码';

  @override
  String get walkiePlan_detailsEnterValidCoupon => '请输入有效的优惠代码';

  @override
  String get walkiePlan_detailsFeatGroupComm => '团队多人对讲';

  @override
  String get walkiePlan_detailsFeatHqVoice => '高保真低延迟语音';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => '优先客服支持';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => '不受距离限制';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => '无限对讲时长';

  @override
  String get walkiePlan_detailsHavePromoCode => '拥有优惠码？';

  @override
  String get walkiePlan_detailsIndividualSubtitle => '选择最适合您的套餐，享受无缝对讲通话';

  @override
  String get walkiePlan_detailsLockedCaps => '未解锁';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    return '已达最大上限 $count 人';
  }

  @override
  String get walkiePlan_detailsMemberPlural => '人';

  @override
  String get walkiePlan_detailsMemberSingular => '人';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    return '$count 位成员 × $rate';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    return '最低团队规模为 $count 人';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody => '日后可随时添加或调整成员。';

  @override
  String get walkiePlan_detailsMoreMembersTitle => '需要更多席位？';

  @override
  String get walkiePlan_detailsMostPopular => '最受欢迎';

  @override
  String get walkiePlan_detailsNetBanking => '网银快捷支付';

  @override
  String get walkiePlan_detailsNoCouponsBody => '当前该套餐暂无生效中的优惠券。';

  @override
  String get walkiePlan_detailsNoCouponsTitle => '暂无可用优惠券';

  @override
  String get walkiePlan_detailsNoIndividualPlans => '当前暂无个人对讲套餐，请稍后重试或查看。';

  @override
  String get walkiePlan_detailsNoPlansTitle => '暂无可用套餐';

  @override
  String get walkiePlan_detailsNoTeamPlans => '当前暂无团队对讲套餐，请稍后重试或查看。';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '原价总计 $amount';
  }

  @override
  String get walkiePlan_detailsPayActivate => '支付并开通套餐';

  @override
  String get walkiePlan_detailsPerPerson => '/ 人';

  @override
  String get walkiePlan_detailsPillAllSizes => '无论团队大小';

  @override
  String get walkiePlan_detailsPillCommunication => '对讲通信';

  @override
  String get walkiePlan_detailsPillForTeams => '专为团队';

  @override
  String get walkiePlan_detailsPillInstant => '即时';

  @override
  String get walkiePlan_detailsPillPriority => '专属';

  @override
  String get walkiePlan_detailsPillReliable => '稳定且';

  @override
  String get walkiePlan_detailsPillSecure => '安全';

  @override
  String get walkiePlan_detailsPillSupport => '客服支持';

  @override
  String get walkiePlan_detailsPillUnlimited => '无限畅聊';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => '对讲机';

  @override
  String get walkiePlan_detailsPlanActivated => '套餐开通成功！';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      '您的对讲机套餐现已生效。尽情享受不间断的高清实时语音沟通。';

  @override
  String get walkiePlan_detailsPlanSummary => '套餐概要';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return '优惠代码 ($code) 已应用';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => '移除';

  @override
  String get walkiePlan_detailsSelectPaymentMethod => '选择付款方式';

  @override
  String get walkiePlan_detailsSkeletonCouponNote => '全套餐通用 • 即将到期';

  @override
  String get walkiePlan_detailsStep1Subtitle => '选择您希望开通权限的团队成员人数';

  @override
  String get walkiePlan_detailsStep1Title => '选择成员数量';

  @override
  String get walkiePlan_detailsStep2Subtitle => '选择最适合您的订阅周期';

  @override
  String get walkiePlan_detailsStep2Title => '选择套餐时长';

  @override
  String get walkiePlan_detailsSubtitleDefault => '即时对讲语音权限';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams => '成长型团队的高性价比之选';

  @override
  String get walkiePlan_detailsSubtitleLongTerm => '长期使用的最佳超值之选';

  @override
  String get walkiePlan_detailsSubtitleShortTerm => '适合短期灵活出行';

  @override
  String get walkiePlan_detailsTabIndividual => '个人版';

  @override
  String get walkiePlan_detailsTabMultipleMembers => '多成员版';

  @override
  String get walkiePlan_detailsTabPerPerson => '单人';

  @override
  String get walkiePlan_detailsTeamSubtitle => '添加团队成员，让每个人都能通过对讲机保持畅通联系';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / 二维码';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return '使用此券可立减 $amount！';
  }

  @override
  String get walkiePlan_durationFallback => '有效期';

  @override
  String get walkiePlan_durationMonthly => '包月';

  @override
  String walkiePlan_durationMonths(int count) {
    return '$count 个月';
  }

  @override
  String get walkiePlan_durationQuarterly => '包季';

  @override
  String get walkiePlan_durationYearly => '包年';

  @override
  String get walkiePlan_individualPlan => '个人套餐';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return '$interval 套餐';
  }

  @override
  String get walkiePlan_monthlyPlan => '月度套餐';

  @override
  String get walkiePlan_noInternetCheckNetwork => '无网络连接，请检查您的网络。';

  @override
  String get walkiePlan_order100Secure => '100% 安全保证';

  @override
  String get walkiePlan_order3ds2Secure => '3DS2 安全认证';

  @override
  String get walkiePlan_orderAgreePrefix => '继续操作即表示您同意我们的 ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => '折后金额';

  @override
  String get walkiePlan_orderCards => '银行卡';

  @override
  String get walkiePlan_orderChangeMethod => '更改支付方式';

  @override
  String get walkiePlan_orderCouldNotStart => '无法启动支付，请重试。';

  @override
  String get walkiePlan_orderCouponApplied => '优惠券兑换成功！';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return '优惠券已生效！为您减免 $amount';
  }

  @override
  String get walkiePlan_orderCouponRemoved => '已移除优惠券';

  @override
  String get walkiePlan_orderCreateFailed => '创建支付订单失败，请重试。';

  @override
  String get walkiePlan_orderDiscount => '优惠折扣';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return '优惠扣减 ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint => '下一步可自由选择银行卡、电子钱包或网银快捷付款。';

  @override
  String get walkiePlan_orderEncryptedPayment => '全程加密支付';

  @override
  String get walkiePlan_orderEnterValidCoupon => '请输入有效的优惠券代码';

  @override
  String get walkiePlan_orderForMultipleMembers => '多成员套餐';

  @override
  String get walkiePlan_orderForSingleMember => '单人套餐';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return '增值税 ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      '支持使用国际信用卡/借记卡（Visa、Mastercard、Amex）安全付款。';

  @override
  String get walkiePlan_orderIntlHintPaypal => '支持使用国际信用卡/借记卡或 PayPal 进行安全支付。';

  @override
  String get walkiePlan_orderInvalidCoupon => '优惠券代码无效或已过期';

  @override
  String walkiePlan_orderMemberCount(int count) {
    return '$count 位成员';
  }

  @override
  String get walkiePlan_orderMembersLabel => '成员';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    return '$count 人 × $rate';
  }

  @override
  String get walkiePlan_orderNetBanking => '网银支付';

  @override
  String get walkiePlan_orderOnlineViaRazorpay => '通过 Razorpay 在线支付';

  @override
  String get walkiePlan_orderOpeningCheckout => '正在打开 Razorpay 支付结银台...';

  @override
  String get walkiePlan_orderPaymentDetails => '支付明细';

  @override
  String get walkiePlan_orderPaymentMethod => '支付方式';

  @override
  String get walkiePlan_orderPricePerMember => '单人价格';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return '立即支付 • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => '正在处理付款...';

  @override
  String get walkiePlan_orderRetryPay => '重新支付';

  @override
  String get walkiePlan_orderSecureBadge => '安全';

  @override
  String get walkiePlan_orderSubtitle => '核对您的套餐详情并继续支付';

  @override
  String get walkiePlan_orderSubtotal => '小计';

  @override
  String get walkiePlan_orderTaxExport => '税费 (0% 境外出口)';

  @override
  String get walkiePlan_orderTermsConditions => '服务条款与协议';

  @override
  String get walkiePlan_orderTitle => '订单摘要';

  @override
  String get walkiePlan_orderTotalAmount => '总计金额';

  @override
  String get walkiePlan_orderTotalPayable => '应付总额';

  @override
  String get walkiePlan_orderUnableToLoad => '无法加载订单摘要。';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / 二维码';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return '增值税/综合税 ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => '电子钱包';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return '本单已为您节省 $amount！';
  }

  @override
  String get walkiePlan_payAnnualPlan => '年度套餐';

  @override
  String get walkiePlan_payBadgeCompleted => '已完成';

  @override
  String get walkiePlan_payBadgeInProgress => '进行中';

  @override
  String get walkiePlan_payBadgePending => '等待中';

  @override
  String get walkiePlan_payCancelledByUser => '支付已被取消，您的账户未产生任何扣费。';

  @override
  String get walkiePlan_payCouldNotBeProcessed => '未能处理您的付款';

  @override
  String get walkiePlan_payFailedContactSupport => '联系客服支持';

  @override
  String walkiePlan_payFailedOn(String time) {
    return '付款失败于 $time';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong => '未能完成付款。\n请重试或更换其他支付方式。';

  @override
  String get walkiePlan_payFailedSubtitleShort => '未能完成您的支付';

  @override
  String get walkiePlan_payFailedSupportHelp => '支付遇到问题？我们的专业团队 7x24 小时为您提供协助。';

  @override
  String get walkiePlan_payFailedTitle => '支付失败';

  @override
  String get walkiePlan_payIndividualFeatures => '实时监控 • 即时警报';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return '支付发起于 $time';
  }

  @override
  String get walkiePlan_payIntervalMonth => '月';

  @override
  String get walkiePlan_payIntervalPlan => '套餐';

  @override
  String get walkiePlan_payIntervalQuarter => '季度';

  @override
  String get walkiePlan_payIntervalYear => '年';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return '信用卡 ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return '借记卡 ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational => '国际信用卡 / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return '网银支付 ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'Razorpay 支付';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'Razorpay 收银台';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / 银行卡)';

  @override
  String get walkiePlan_payMethodUpi => 'UPI 支付';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return '电子钱包 ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue => '支付过程中网络连接中断，请检查网络后重试。';

  @override
  String get walkiePlan_payNotCompleted => '您的付款未完成，账户未发生任何扣费。';

  @override
  String get walkiePlan_payOtpCharge => '短信验证码费用';

  @override
  String get walkiePlan_payOtpChargeDetails => '验证码费用明细';

  @override
  String get walkiePlan_payOtpChargedPerLogin => '按每次登录计费。重发验证码免费';

  @override
  String get walkiePlan_payOtpCharges => '验证码资费';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      '请勿关闭应用。一旦支付确认成功且套餐开通，我们将立即通知您。';

  @override
  String get walkiePlan_payPendingStillInProgress => '支付仍在进行中，确认后将立即更新。';

  @override
  String get walkiePlan_payPendingStillProcessing => '付款状态正在处理中，请稍候。';

  @override
  String get walkiePlan_payPendingSubtitleLong => '支付渠道正在处理您的订单，\n这可能需要几分钟时间。';

  @override
  String get walkiePlan_payPendingSubtitleShort => '正在处理您的支付';

  @override
  String get walkiePlan_payPendingTitle => '待确认支付';

  @override
  String get walkiePlan_payPlanDetails => '套餐详情';

  @override
  String get walkiePlan_payRefreshStatus => '刷新状态';

  @override
  String get walkiePlan_payStatusTitle => '支付状态';

  @override
  String get walkiePlan_payStepActivate => '开通套餐';

  @override
  String get walkiePlan_payStepActivateSub => '套餐将在确认后自动为您激活';

  @override
  String get walkiePlan_payStepInitiated => '已发起支付';

  @override
  String get walkiePlan_payStepProcessing => '处理中';

  @override
  String get walkiePlan_payStepProcessingSub => '正在确认您的支付结果';

  @override
  String get walkiePlan_payTeamFeatures => '多成员权限 • 即时警报';

  @override
  String get walkiePlan_payTotalPerOtp => '每条验证码总计';

  @override
  String get walkiePlan_payTryAgain => '再试一次';

  @override
  String get walkiePlan_payViewPlanDetails => '查看套餐详情';

  @override
  String get walkiePlan_perMember => '每位成员';

  @override
  String get walkiePlan_planFallback => '套餐';

  @override
  String get walkiePlan_quarterlyPlan => '季度套餐';

  @override
  String get walkiePlan_razorpayCompleteInWindow => '请在弹出的 Razorpay 支付窗口中完成交易。';

  @override
  String get walkiePlan_razorpayCompletePayment => '完成付款';

  @override
  String get walkiePlan_razorpayConfirmingWithBank => '支付已发起，正在与银行确认交易状态。';

  @override
  String get walkiePlan_razorpayConnecting => '正在连接 Razorpay...';

  @override
  String get walkiePlan_razorpayCouldNotProcess => '未能处理您的付款，请重新尝试。';

  @override
  String get walkiePlan_razorpayFailedTryAgain => '付款失败，请重新尝试。';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1 个月有效期';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return '通过 Razorpay 支付 $amount';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => '支付已取消';

  @override
  String get walkiePlan_razorpayPaymentIdCopied => '交易订单号已复制到剪贴板！';

  @override
  String get walkiePlan_razorpayPciCompliant => '100% 安全且符合 PCI-DSS 国际安全认证';

  @override
  String get walkiePlan_razorpayPendingConfirmation => '支付处理中，等待系统最终确认。';

  @override
  String get walkiePlan_razorpayProcessing => '正在由 Razorpay 处理付款...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return '付款金额：$amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied => '收据详情已复制到剪贴板！';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return '交易时间：$date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return '支付方式：$mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return '订单编号：$id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return '交易ID：$id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return '购买套餐：$plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => '交易状态：已完成';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'FG Tracker 付款收据';

  @override
  String get walkiePlan_razorpayRetryPayment => '重试付款';

  @override
  String get walkiePlan_razorpaySecureCheckout => '由 Razorpay 提供安全支付保障';

  @override
  String get walkiePlan_razorpaySslEncrypted => '交易全程采用 256 位 SSL 端到端安全加密保护。';

  @override
  String get walkiePlan_razorpaySupportedModes => '支持的支付方式';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => '应付总金额';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return '无法打开支付网关：$error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed => '支付验证失败。';

  @override
  String get walkiePlan_seatAssignedSeat => '已分配席位';

  @override
  String get walkiePlan_seatAssignment => '席位分配';

  @override
  String get walkiePlan_seatTeamAccess => '团队权限';

  @override
  String get walkiePlan_seatTeamMember => '团队成员';

  @override
  String get walkiePlan_secureEncryptedPayment => '安全加密支付';

  @override
  String get walkiePlan_successAccessActivated => '权限已开通';

  @override
  String get walkiePlan_successAccessActivatedDesc => '您的个人对讲机权限已正式开通。';

  @override
  String get walkiePlan_successAmountPaid => '实付金额';

  @override
  String get walkiePlan_successAssignLaterNote => '您可以日后随时在“团队设置”中分配对讲机权限。';

  @override
  String get walkiePlan_successAssignMembers => '分配成员';

  @override
  String get walkiePlan_successAssignWalkieAccess => '分配对讲权限';

  @override
  String get walkiePlan_successChooseMembersDesc => '选择哪些成员拥有对讲机使用权。';

  @override
  String get walkiePlan_successContinueHome => '返回主页';

  @override
  String get walkiePlan_successDateTime => '交易时间';

  @override
  String get walkiePlan_successDefaultPaymentMethod => 'Razorpay (UPI / 银行卡)';

  @override
  String get walkiePlan_successIndividualActive => '您的个人套餐已生效';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      '您的个人套餐已生效。返回主页即可随时发起对讲。';

  @override
  String get walkiePlan_successIndividualLinkedNote => '您的个人订阅已生效并直接绑定至当前账号。';

  @override
  String get walkiePlan_successManageAccessNote => '您可以随时在团队设置中管理或更改对讲机访问权限。';

  @override
  String get walkiePlan_successMaybeLater => '稍后再说';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      '套餐已生效。在您完成分配前，团队成员暂无法使用对讲机。';

  @override
  String get walkiePlan_successNotNow => '暂不分配？';

  @override
  String get walkiePlan_successPaid => '已付款';

  @override
  String get walkiePlan_successPaymentId => '支付ID';

  @override
  String get walkiePlan_successPaymentIdCopied => '交易ID已复制！';

  @override
  String get walkiePlan_successPaymentMode => '支付方式';

  @override
  String get walkiePlan_successPaymentReceipt => '付款收据';

  @override
  String get walkiePlan_successPushToTalkDesc => '按住说话，即刻与团队沟通。';

  @override
  String get walkiePlan_successRazorpayVerified => 'Razorpay 官方认证';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return '金额：$amount';
  }

  @override
  String get walkiePlan_successReceiptCopied => '收据信息已复制！';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return '日期：$date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'FG Tracker 付款收据';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return '订单编号：$id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return '交易ID：$id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return '支付方式：$mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return '套餐：$plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => '状态：已完成';

  @override
  String get walkiePlan_successSelectChannel => '选择频道';

  @override
  String get walkiePlan_successSelectChannelDesc => '加入任意群组或对讲频道即可联系成员。';

  @override
  String get walkiePlan_successSelectMembersDesc => '选择可以使用对讲机功能的团队成员。';

  @override
  String get walkiePlan_successSetUpTeam => '设置团队';

  @override
  String get walkiePlan_successSetUpTeamDesc => '邀请成员，管理角色与访问权限。';

  @override
  String get walkiePlan_successShareReceipt => '分享收据';

  @override
  String get walkiePlan_successStartCommunicating => '立即开始对讲沟通';

  @override
  String get walkiePlan_successStatus => '状态';

  @override
  String get walkiePlan_successSuccessful => '成功';

  @override
  String get walkiePlan_successTeamActive => '您的团队套餐已生效';

  @override
  String get walkiePlan_successTeamReady => '您的团队已准备就绪！';

  @override
  String get walkiePlan_successTitle => '购买成功！';

  @override
  String walkiePlan_successValidTill(String date) {
    return '有效期至 $date';
  }

  @override
  String get walkiePlan_successVisitHome => '前往主页面';

  @override
  String get walkiePlan_successWhatsNext => '后续操作';

  @override
  String get walkiePlan_teamPlan => '团队套餐';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return '团队套餐 ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => '7 天试用有效期';

  @override
  String get walkiePlan_trialActiveLabel => '试用体验中';

  @override
  String get walkiePlan_trialActiveSubscription => '有效订阅';

  @override
  String get walkiePlan_trialActiveSubscriptions => '当前有效订阅';

  @override
  String get walkiePlan_trialAvailableToStart => '随时可开启';

  @override
  String get walkiePlan_trialCheckConnectionRetry => '请检查网络连接后重试。';

  @override
  String get walkiePlan_trialChoosePlanBelow => '在下方选择套餐以开启对讲机功能。';

  @override
  String get walkiePlan_trialChooseSubscription => '选择合适的订阅套餐以继续使用对讲机。';

  @override
  String get walkiePlan_trialCompleted => '试用已完成';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    return '还剩 $count 天';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration 免费试用';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return '结束于 $date';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return '免费体验对讲机全部功能 $duration。\n无需预先支付。';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive => '在试用有效期内尽情体验对讲机所有功能。';

  @override
  String get walkiePlan_trialErrAccessMissing => '对讲机访问权限信息缺失。';

  @override
  String get walkiePlan_trialErrFetchDetails => '获取对讲机详细信息失败。';

  @override
  String get walkiePlan_trialErrInvalidResponse => '收到服务器无效响应。';

  @override
  String get walkiePlan_trialErrNoInternetRetry => '无网络连接，请检查网络设置后重试。';

  @override
  String get walkiePlan_trialErrOverviewMissing => '对讲机概览数据缺失。';

  @override
  String get walkiePlan_trialErrTimeout => '请求超时，请重试。';

  @override
  String get walkiePlan_trialErrUnableToLoad => '无法加载对讲机详情，请检查网络连接。';

  @override
  String get walkiePlan_trialExpired => '试用已过期';

  @override
  String get walkiePlan_trialExpiredLabel => '试用已过期';

  @override
  String get walkiePlan_trialExpiringSoon => '即将到期';

  @override
  String get walkiePlan_trialFeatClearAudio => '高清音质';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => '低延迟高保真语音体验';

  @override
  String get walkiePlan_trialFeatGroupComm => '团队对讲';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => '与您的团队快速联络';

  @override
  String get walkiePlan_trialFeatPtt => '一键对讲 (PTT)';

  @override
  String get walkiePlan_trialFeatPttDesc => '按住按钮即时发送语音';

  @override
  String get walkiePlan_trialFeatUnlimited => '无限畅聊';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => '无任何时长与频次限制';

  @override
  String get walkiePlan_trialFreeAvailable => '可享受免费试用';

  @override
  String get walkiePlan_trialFreeTrialLabel => '免费试用';

  @override
  String get walkiePlan_trialFreeTrialRunning => '免费试用进行中';

  @override
  String get walkiePlan_trialFullAccess => '解锁全部功能权限';

  @override
  String get walkiePlan_trialFullyConsumed => '您的免费试用额度已全部用尽。';

  @override
  String get walkiePlan_trialHasEnded => '您的试用期已结束';

  @override
  String get walkiePlan_trialHeaderInstant => '与群组即时保持语音联络';

  @override
  String get walkiePlan_trialHeaderPlanStatus => '您的套餐与订阅状态';

  @override
  String walkiePlan_trialHours(int count) {
    return '$count 小时';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    return '还剩 $count 小时';
  }

  @override
  String walkiePlan_trialHr(int count) {
    return '$count 小时';
  }

  @override
  String walkiePlan_trialHrMin(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String get walkiePlan_trialIsActive => '试用正在生效';

  @override
  String walkiePlan_trialMin(int count) {
    return '$count 分钟';
  }

  @override
  String walkiePlan_trialMinSec(int minutes, int seconds) {
    return '$minutes 分 $seconds 秒';
  }

  @override
  String walkiePlan_trialMinsLeft(int count) {
    return '还剩 $count 分钟';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String get walkiePlan_trialNoActivePlan => '暂无有效套餐';

  @override
  String get walkiePlan_trialNoCardRequired => '7 天内随时可用  •  无需绑定信用卡';

  @override
  String get walkiePlan_trialNoInternetTitle => '无网络连接';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return '现在无需付款。试用结束后，您可以自主选择按需订阅付费套餐 ($price/人)。';
  }

  @override
  String get walkiePlan_trialPeriodMonth => '月';

  @override
  String get walkiePlan_trialRetrying => '正在重试...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count 秒';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return '开启 $duration 免费试用';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial => '开启您的免费试用';

  @override
  String get walkiePlan_trialStatusCompleted => '已完成';

  @override
  String get walkiePlan_trialStatusExpired => '已过期';

  @override
  String get walkiePlan_trialSubscriptionActive => '订阅已生效';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      '您的对讲机订阅已到期。续费后可继续与团队保持对讲联系。';

  @override
  String get walkiePlan_trialSubscriptionExpired => '订阅已过期';

  @override
  String get walkiePlan_trialTalkFree => '与群组成员免费畅聊。';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return '截至 $date 前均可与群组成员免费语音对讲。';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg => '您已通过团队套餐获得对讲机使用权限。';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return '剩余 $time';
  }

  @override
  String get walkiePlan_trialTimeRemaining => '试用剩余时长';

  @override
  String get walkiePlan_trialTimeUsedUp => '试用时长已耗尽';

  @override
  String get walkiePlan_trialTryAgain => '再试一次';

  @override
  String get walkiePlan_trialUnableToLoadTitle => '无法加载对讲机数据';

  @override
  String get walkiePlan_trialUsage => '试用用量';

  @override
  String get walkiePlan_trialUseAnytime7Days => '7 天内可随时使用';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return '可在 7 天内随时使用您的 $duration 免费试用。';
  }

  @override
  String get walkiePlan_trialUsed => '试用已用完';

  @override
  String get walkiePlan_trialValidityPeriod => '试用有效期';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => '对讲机';

  @override
  String get walkiePlan_trialWhatYouCanDo => '试用期间您可享有的特权';

  @override
  String get walkiePlan_unableToConnect => '无法连接到服务器，请重试。';

  @override
  String get walkiePlan_yearlyPlan => '年度套餐';

  @override
  String get walkie_aMember => '一位成员';

  @override
  String get walkie_accept => '接听';

  @override
  String get walkie_activeAccess => '有效权限';

  @override
  String get walkie_activeBadge => '活跃';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人在对讲中活跃',
      one: '1 人在对讲中活跃',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => '活跃成员';

  @override
  String get walkie_admin => '管理员';

  @override
  String get walkie_adminMuted => '管理员 • 已静音';

  @override
  String get walkie_adminOnlyAction => '仅限管理员操作';

  @override
  String get walkie_adminOnlyActionMessage => '仅群组管理员可向成员发送通知警报。';

  @override
  String walkie_alertSentMessage(String name) {
    return '通知已发送至 $name。可在 10 秒后重试。';
  }

  @override
  String get walkie_alertSentTitle => '警报已发送';

  @override
  String get walkie_assignMembersToCommunicate => '分配成员以在此群组中进行对讲';

  @override
  String get walkie_assignedByYou => '由您分配';

  @override
  String walkie_assignedCount(int count) {
    return '已分配 $count 人';
  }

  @override
  String get walkie_assignedSeats => '已分配席位';

  @override
  String get walkie_audioBluetooth => '蓝牙';

  @override
  String get walkie_audioHeadset => '头戴式耳机';

  @override
  String get walkie_audioOutput => '音频输出';

  @override
  String get walkie_audioPhone => '听筒';

  @override
  String get walkie_audioSpeaker => '扬声器';

  @override
  String get walkie_audioWiredHeadphones => '有线耳机';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return '$seconds 秒后自动解锁';
  }

  @override
  String get walkie_availableMembers => '可用成员';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '您可以在此群组中最多分配 $count 位成员',
      one: '您可以在此群组中最多分配 1 位成员',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat => '无法移除其他管理员分配的席位';

  @override
  String get walkie_cannotSpeak => '无法在此频道讲话';

  @override
  String get walkie_channelBusy => '频道正忙';

  @override
  String get walkie_channelLocked => '频道已锁定';

  @override
  String get walkie_channelSpeaking => '频道正在通话...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return '无法将 $group 设置为当前活跃对讲频道。';
  }

  @override
  String get walkie_channelSwitchErrorTitle => '切换频道出错';

  @override
  String get walkie_channelUnlocked => '频道已解锁';

  @override
  String get walkie_chat => '聊天';

  @override
  String get walkie_checkNetworkTryAgain => '请检查网络连接并重试。';

  @override
  String get walkie_chooseAPlan => '选择方案';

  @override
  String get walkie_connected => '已连接';

  @override
  String get walkie_connectedWaiting => '已连接至频道 • 等待其他人加入';

  @override
  String get walkie_connectingChannel => '正在连接频道...';

  @override
  String get walkie_consumingTrial => '正在使用试用...';

  @override
  String get walkie_continueListenOnly => '继续以仅收听模式运行';

  @override
  String walkie_currentlyAssigned(int count) {
    return '当前已分配 ($count)';
  }

  @override
  String get walkie_defaultGroupName => '对讲群组';

  @override
  String get walkie_description => '描述';

  @override
  String get walkie_disconnected => '已断开连接';

  @override
  String get walkie_editAssignedMembers => '编辑已分配成员';

  @override
  String get walkie_enable => '开启';

  @override
  String walkie_errorWithDetails(String details) {
    return '错误：$details';
  }

  @override
  String get walkie_exitWalkie => '退出对讲';

  @override
  String get walkie_exitWalkieMessage => '您将与此对讲频道断开连接。您仍保留群组成员身份。';

  @override
  String get walkie_exitWalkieTitle => '退出对讲机？';

  @override
  String get walkie_fairConnection => '信号一般';

  @override
  String walkie_fairConnectionMs(int ms) {
    return '信号一般 (${ms}ms)';
  }

  @override
  String get walkie_featureAllDevices => '全设备支持';

  @override
  String get walkie_featureEasyCoordination => '便捷群组协同';

  @override
  String get walkie_featureHoldToTalk => '按住通话';

  @override
  String get walkie_featurePtt => '一键对讲';

  @override
  String get walkie_featureQuickGroup => '快速群组沟通';

  @override
  String get walkie_featureRealtime => '实时连接';

  @override
  String get walkie_featureSafeReliable => '安全可靠';

  @override
  String get walkie_featureStayConnected => '时刻保持联系';

  @override
  String get walkie_featureTeamCommunication => '团队沟通';

  @override
  String get walkie_featureUnlimited => '无限制';

  @override
  String get walkie_fieldTeam => '现场团队';

  @override
  String get walkie_freeTrialEnded => '免费试用已结束';

  @override
  String get walkie_freeTrialEndedMessage =>
      '您的 1 小时对讲机免费试用已结束。\n立即升级以继续与团队进行对讲沟通。';

  @override
  String get walkie_freeTrialEndedTitle => '免费试用已结束';

  @override
  String get walkie_genericError => '对讲机错误';

  @override
  String get walkie_getPlan => '获取方案';

  @override
  String walkie_goodConnectionMs(int ms) {
    return '信号良好 (${ms}ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return '群组代码：$code';
  }

  @override
  String get walkie_groupCommunication => '群组通信';

  @override
  String get walkie_groupFallback => '群组';

  @override
  String get walkie_groupMembers => '群组成员';

  @override
  String get walkie_heroSubtitle => '无需拨打电话，即可通过一键对讲功能与群组成员进行语音沟通。';

  @override
  String get walkie_heroTitle => '保持连接，即时对讲';

  @override
  String get walkie_holdToTalk => '按住通话';

  @override
  String get walkie_holdToTalkSlideLock => '按住讲话，上滑锁定';

  @override
  String get walkie_inWalkieChannel => '在对讲频道中';

  @override
  String get walkie_individualActiveUpgrade => '个人方案已激活（仅本人可用）• 升级至团队方案以分配成员。';

  @override
  String get walkie_individualLimitMessage =>
      '您的个人方案仅支持 1 个席位。如需分配多名成员并连接整个团队，请升级至团队方案。';

  @override
  String get walkie_individualPlan => '个人方案';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (个人)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade => '个人方案（仅限个人使用）• 升级至团队方案以分配成员';

  @override
  String get walkie_individualSubscribedSelf => '个人方案 • 自行订阅';

  @override
  String get walkie_info => '信息';

  @override
  String walkie_isSpeaking(String name) {
    return '$name 正在讲话...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name 正在讲话...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人已加入',
      one: '1 人已加入',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return '上次在线 $time';
  }

  @override
  String get walkie_listenOnly => '仅收听';

  @override
  String get walkie_listenOnlyTapPlan => '仅收听 — 点击查看方案';

  @override
  String get walkie_listening => '正在收听';

  @override
  String get walkie_listeningOnly => '仅收听中';

  @override
  String get walkie_live => '实时';

  @override
  String get walkie_lockTimeout => '锁定超时 — 麦克风已释放';

  @override
  String get walkie_lockedTapMic => '已锁定 — 点击麦克风停止';

  @override
  String get walkie_maybeLater => '以后再说';

  @override
  String get walkie_member => '成员';

  @override
  String get walkie_membersInChannel => '频道中的成员';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '位在线成员',
      one: '位在线成员',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed => '更新分配成员失败';

  @override
  String get walkie_membersUpdated => '已成功更新分配的成员';

  @override
  String get walkie_micAccessRequired => '讲话需要麦克风权限。';

  @override
  String get walkie_micDisabledMessage =>
      '设备设置中已禁用麦克风访问权限。如需在此群组中讲话，请在设置中允许访问麦克风。\n\n您仍可收听其他成员的语音。';

  @override
  String get walkie_micPermissionRequired => '需要麦克风权限';

  @override
  String get walkie_micPermissionTitle => '麦克风权限';

  @override
  String get walkie_micRequiredMessage =>
      '在此对讲群组中讲话需要麦克风权限。\n\n即使不开启麦克风，您仍可收听其他人发言。';

  @override
  String get walkie_muteMe => '将我静音';

  @override
  String get walkie_muted => '已静音';

  @override
  String get walkie_mutedInWalkie => '已静音 • 正在对讲';

  @override
  String get walkie_mutedListeningOnly => '您已静音 — 仅收听';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name 正在讲话...';
  }

  @override
  String get walkie_noActivePlan => '无活跃方案';

  @override
  String get walkie_noAvailableMembers => '无可用成员';

  @override
  String get walkie_noBluetoothDevice => '未连接蓝牙音频设备。请在设置中配对您的蓝牙耳机。';

  @override
  String get walkie_noGroupsFound => '未找到群组';

  @override
  String get walkie_noMembersAssigned => '目前未分配任何成员';

  @override
  String get walkie_noMembersFound => '未找到成员';

  @override
  String get walkie_noMembersFoundTitle => '未找到成员';

  @override
  String get walkie_noMembersMatch => '没有匹配的成员';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return '没有匹配“$query”的成员';
  }

  @override
  String get walkie_noMembersToAssign => '没有可供分配的群组成员。';

  @override
  String get walkie_noNameGroup => '未命名群组';

  @override
  String get walkie_noPlanSubscribeAssign => '无活跃方案 • 订阅以分配成员';

  @override
  String get walkie_noSeatMessage =>
      '您拥有有效的团队方案，但所有语音席位当前均已分配给其他成员。\n\n您可以实时收听群组对话，但如需讲话，请为自己分配席位或升级方案。';

  @override
  String get walkie_noSeatTitle => '未分配语音席位';

  @override
  String get walkie_noSeatsRefreshing => '无可用团队席位，正在刷新成员列表...';

  @override
  String get walkie_noSubscriptionMessage => '您没有活跃的对讲机订阅。请订阅方案以分配成员并开始即时语音对讲。';

  @override
  String get walkie_noTeamSubscription => '未找到活跃的团队订阅';

  @override
  String get walkie_noValidMembers => '未选择有效的成员进行分配';

  @override
  String get walkie_noVoiceSeatListenOnly => '未分配语音席位 — 您处于仅收听模式';

  @override
  String get walkie_noWiredDevice => '未连接有线耳机。请将其插入设备。';

  @override
  String get walkie_notConnected => '未连接';

  @override
  String get walkie_notifLeave => '离开';

  @override
  String get walkie_notifOpenWalkie => '打开对讲';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name 已停止讲话';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name 正在讲话';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return '无法更新 $group 的通知设置，请重试。';
  }

  @override
  String get walkie_notificationSettingTitle => '通知设置';

  @override
  String get walkie_onlyAdminCanAlert => '仅群组管理员可发送警报';

  @override
  String get walkie_openWalkieTalkie => '打开对讲机';

  @override
  String get walkie_otherTeam => '其他团队';

  @override
  String get walkie_othersWontHear => '其他人将听不到您的声音';

  @override
  String get walkie_planRequiredTitle => '需要对讲机方案';

  @override
  String get walkie_planRequiredToTalk => '讲话需要订购方案';

  @override
  String get walkie_planStartsOnFirstAssign => '方案自第一位成员被分配时起生效。';

  @override
  String get walkie_poorConnection => '网络连接较差 — 音频可能有延迟';

  @override
  String get walkie_preparingAudio => '正在准备音频...';

  @override
  String get walkie_purchaseTeamPlanToAssign => '购买团队方案以为成员分配对讲机使用权限。';

  @override
  String get walkie_purchaseUpgradePlan => '购买 / 升级方案';

  @override
  String get walkie_ready => '准备就绪';

  @override
  String get walkie_reconnecting => '正在重新连接...';

  @override
  String get walkie_reconnectingServer => '正在重新连接对讲服务器...';

  @override
  String get walkie_releaseToStop => '松开停止';

  @override
  String get walkie_removeAll => '全部移除';

  @override
  String get walkie_searchGroups => '搜索群组';

  @override
  String get walkie_searchMembers => '搜索成员...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total 席位';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '总计 $total 席位 • 已分配 $assigned • 可用 $available';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '已使用 $assigned / $total 个席位';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get walkie_selectAtLeastOne => '请选择至少一位成员进行分配';

  @override
  String get walkie_selectGroupFirst => '请先选择一个群组';

  @override
  String get walkie_selectGroupToConnect => '选择要连接的群组';

  @override
  String get walkie_selected => '已选';

  @override
  String get walkie_selfAccess => '本人访问';

  @override
  String get walkie_selfPlan => '自购方案';

  @override
  String get walkie_slideUpToLock => '上滑锁定';

  @override
  String get walkie_someone => '某人';

  @override
  String get walkie_someoneSpeaking => '有人正在讲话...';

  @override
  String get walkie_speaking => '正在讲话...';

  @override
  String walkie_startFreeTrial(String duration) {
    return '开始 $duration 免费试用';
  }

  @override
  String get walkie_strongConnection => '信号极佳';

  @override
  String walkie_strongConnectionMs(int ms) {
    return '信号极佳 (${ms}ms)';
  }

  @override
  String get walkie_subscribeToStartTalk => '订阅以开始语音对讲并分配成员';

  @override
  String get walkie_subscribed => '已订阅';

  @override
  String get walkie_talking => '正在讲话...';

  @override
  String get walkie_tapToUnlock => '点击解锁';

  @override
  String get walkie_teamAssignedElsewhere => '团队方案 • 已在别处分配';

  @override
  String get walkie_teamPlan => '团队方案';

  @override
  String get walkie_teamPlanRequired => '需要团队方案';

  @override
  String get walkie_teamPlanRequiredToAssign => '分配成员需要团队方案';

  @override
  String get walkie_teamPlanStatus => '团队方案状态';

  @override
  String get walkie_teamSeatMember => '团队席位成员';

  @override
  String get walkie_title => '对讲机';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共 $count 人',
      one: '共 1 人',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => '1小时试用激活';

  @override
  String get walkie_trialEndedSubscribe => '免费试用已结束 — 请订阅以继续使用';

  @override
  String get walkie_unableToConnectReconnecting => '无法连接至频道 — 正在重新连接...';

  @override
  String get walkie_unavailable => '不可用';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return '更新成员 ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => '正在更新成员...';

  @override
  String get walkie_upgradeAddSeats => '升级并增添席位';

  @override
  String get walkie_upgradeNow => '立即升级';

  @override
  String get walkie_upgradeTeamAssign => '升级至团队方案（分配成员）';

  @override
  String get walkie_upgradeToTeamPlan => '升级至团队方案';

  @override
  String walkie_userCancelled(String name) {
    return '$name 已取消';
  }

  @override
  String walkie_userJoined(String name) {
    return '$name 已加入';
  }

  @override
  String walkie_userLeft(String name) {
    return '$name 已离开';
  }

  @override
  String walkie_validTill(String date) {
    return '有效期至 $date';
  }

  @override
  String get walkie_viewPlan => '查看方案';

  @override
  String get walkie_voiceNotPermitted => '不允许进行语音传输';

  @override
  String get walkie_weakSignal => '信号微弱';

  @override
  String walkie_weakSignalMs(int ms) {
    return '信号微弱 (${ms}ms)';
  }

  @override
  String get walkie_youAreConnected => '您已连接';

  @override
  String get walkie_yourVoiceAccess => '您的语音权限';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Android 下载链接：$playStoreLink\n\niOS 下载链接：$appStoreLink';
  }

  @override
  String get widget_live => '实时';

  @override
  String get widget_lostConnection => '网络连接断开';

  @override
  String get widget_manageGroups => '轻松管理您的群组';

  @override
  String get widget_noInternetBody => '哎呀... 未检测到网络连接，请检查您的网络设置';

  @override
  String get widget_notSeenYet => '尚未查看';

  @override
  String get widget_pinnedMessage => '置顶消息';

  @override
  String get widget_private => '私密';

  @override
  String get widget_refreshPage => '刷新页面';

  @override
  String get widget_seen => '已读';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count/$total)';
  }

  @override
  String get widget_somethingWentWrongTitle => '出错了';

  @override
  String get widget_userFallback => '用户';
}
