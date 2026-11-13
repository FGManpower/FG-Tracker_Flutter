// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get about_aboutUs => '会社概要';

  @override
  String get about_address => '住所';

  @override
  String get about_appBarTitle => 'FG Trackerについて';

  @override
  String get about_company => '企業情報';

  @override
  String get about_contactUs => 'お問い合わせ';

  @override
  String get about_developerEmail => '開発者メール';

  @override
  String get about_downloadTitle => '📱 アプリをダウンロード';

  @override
  String get about_howItWorksIntro => 'FG Trackerはグループでの移動や調整を快適にします。手順はこちら:';

  @override
  String get about_howItWorksTitle => '⚙️ 使い方';

  @override
  String get about_howStep1 => 'グループを作成';

  @override
  String get about_howStep2 => 'グループコードまたはQRコードを仲間に共有';

  @override
  String get about_howStep3 => '各メンバーが共有コードまたはQRで参加';

  @override
  String get about_howStep4 => '共有マップ上で全員の現在地をリアルタイムに確認';

  @override
  String get about_howStep5 => '共有機能を使って手軽にメンバーを追加招待';

  @override
  String get about_intro =>
      'FG Trackerは、グループでの旅行や移動中に安全につながり続けるための頼もしいパートナーです。家族旅行や友達とのピクニック、同僚との通勤でも、誰一人取り残されることはありません。';

  @override
  String get about_privacyBody =>
      '安全性とプライバシーを最優先に保護します。FG Trackerはグループ外の誰とも位置情報を共有しません。すべてのデータは暗号化され、許可されたメンバーのみに共有されます。';

  @override
  String get about_privacyPolicy => 'プライバシーポリシー';

  @override
  String get about_privacyTitle => '🔐 プライバシーとセキュリティ';

  @override
  String get about_supportEmail => 'サポートメール';

  @override
  String get about_supportTitle => '📩 サポート・開発者情報';

  @override
  String get about_termsConditions => '利用規約';

  @override
  String get about_title => 'アプリについて';

  @override
  String get about_website => 'ウェブサイト';

  @override
  String get about_welcomeTitle => 'FG Trackerへようこそ';

  @override
  String get about_whyBuiltFor => '家族、友人、少人数のチーム向けに設計されています。';

  @override
  String get about_whyChooseTitle => '🌟 FG Trackerを選ぶ理由';

  @override
  String get about_whyEasy => '使いやすく軽量で、プライバシー管理も万全。';

  @override
  String get about_whyNoCalls => '電話やメッセージは不要。地図上でリアルタイムに追跡できます。';

  @override
  String get about_whyRealTime => 'グループ全員とのリアルタイムな位置情報共有。';

  @override
  String appUpdate_checkError(String error) {
    return '更新確認エラー: $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => '終了しますか？';

  @override
  String get appUpdate_noUpdateAvailable => '最新の状態です';

  @override
  String get appUpdate_restartApp => 'アプリを再起動';

  @override
  String get appUpdate_updateApp => 'アプリを更新';

  @override
  String get appUpdate_updateAvailable => 'アップデートが利用可能です';

  @override
  String get appUpdate_updateAvailableMessage => '新しい更新があります。アプリをアップデートしてください';

  @override
  String get appUpdate_updateUnavailable => '更新は現在利用できません';

  @override
  String appUpdate_updatingProgress(int progress) {
    return '更新中... $progress%';
  }

  @override
  String get attendance_addOption => '選択肢を追加';

  @override
  String get attendance_admin => '管理者';

  @override
  String get attendance_allowChange => '回答の変更を許可';

  @override
  String get attendance_allowChangeSubtitle => 'メンバーは回答の変更や取り消しができます';

  @override
  String get attendance_askCommunity => 'コミュニティに質問';

  @override
  String get attendance_cameraPermissionRequired => '出欠を記録するにはカメラの権限が必要です。';

  @override
  String get attendance_cameraStartFailed => 'カメラを起動できませんでした。';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'カメラを起動できませんでした ($code)。';
  }

  @override
  String get attendance_cameraStarting => 'カメラを起動中…';

  @override
  String get attendance_captureFailedBlink => '撮影できませんでした。もう一度まばたきしてください';

  @override
  String attendance_capturedAtVerified(String time) {
    return '$timeに撮影 • 確認済み';
  }

  @override
  String get attendance_capturedCheck => '撮影完了 ✓';

  @override
  String get attendance_changeResponse => '回答を変更';

  @override
  String get attendance_chooseFolder => 'フォルダ（ダウンロードなど）を選択';

  @override
  String get attendance_closeAction => '出欠確認を締め切る';

  @override
  String get attendance_closeConfirmBody => '締め切り後はメンバーが回答できなくなります。';

  @override
  String get attendance_closeConfirmTitle => '出欠確認を締め切りますか？';

  @override
  String get attendance_closeEndOfDay => '当日の終わりに締め切る';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return '本日 $time に自動的に締め切られます';
  }

  @override
  String get attendance_closeFailed => '出欠確認を締め切れませんでした';

  @override
  String get attendance_closeFailedShort => '締め切れません';

  @override
  String attendance_closesAt(String dateTime) {
    return '$dateTimeに終了';
  }

  @override
  String get attendance_createFailed => '出欠確認を作成できませんでした';

  @override
  String get attendance_createSubtitle => 'このグループに出欠確認を送信';

  @override
  String get attendance_createTitle => '出欠確認を作成';

  @override
  String get attendance_created => '出欠確認を作成しました';

  @override
  String get attendance_dateEnded => '選択した日付は既に終了しています。別の日付を選択してください。';

  @override
  String get attendance_dateToday => '日付（今日）';

  @override
  String get attendance_dateTodaySemantics => '出欠日、今日';

  @override
  String get attendance_deleteFailed => '出欠確認を削除できませんでした';

  @override
  String get attendance_deletedText => 'この出欠確認は削除されました';

  @override
  String get attendance_downloadReport => 'レポートをダウンロード';

  @override
  String get attendance_everyoneResponded => '全員が回答しました';

  @override
  String get attendance_faceDetectedBlink => '顔が検出されました — まばたきしてください';

  @override
  String get attendance_failed => '出欠処理に失敗しました';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return '未回答 ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return '回答済み ($count)';
  }

  @override
  String get attendance_fixErrors => '送信する前に強調表示されたエラーを修正してください';

  @override
  String get attendance_holdStill => '動かないでください…';

  @override
  String get attendance_howToTakePhoto => '写真の撮影方法';

  @override
  String get attendance_invalidGroup => '無効なグループです。チャットを開き直してください。';

  @override
  String get attendance_keepFaceInCircle => '顔を円の中に収めてください';

  @override
  String get attendance_limitReached => '上限に達しました';

  @override
  String get attendance_loadFailed => '出欠確認を読み込めませんでした';

  @override
  String get attendance_loadMore => 'もっと読み込む';

  @override
  String get attendance_loadMoreFailed => 'さらに読み込むことができませんでした';

  @override
  String get attendance_loadVotersFailed => '投票者を読み込めませんでした';

  @override
  String get attendance_lookAtCamera => 'カメラを見てください';

  @override
  String get attendance_lookStraight => 'カメラをまっすぐ見てください';

  @override
  String get attendance_markYourAttendance => '出欠を記録してください';

  @override
  String attendance_markedAs(String option) {
    return '$optionとして記録';
  }

  @override
  String get attendance_markedSuccess => '出欠を記録しました';

  @override
  String attendance_maxOptions(int count) {
    return '追加できる選択肢は最大$count個です';
  }

  @override
  String get attendance_members => 'メンバー';

  @override
  String attendance_membersWithCount(int count) {
    return 'メンバー ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return '最低$count個の選択肢が必要です';
  }

  @override
  String get attendance_moveCloser => 'もう少し近づいてください';

  @override
  String get attendance_multipleFaces => '複数の顔が検出されました — 枠内にはご自身のみが写るようにしてください';

  @override
  String get attendance_noCsvApp =>
      'CSVファイルを開くアプリが見つかりません。代わりに保存または共有をご利用ください。';

  @override
  String get attendance_noFace => '顔が検出されませんでした';

  @override
  String get attendance_noFrontCamera => 'この端末にフロントカメラが見つかりません。';

  @override
  String get attendance_noLocation => '位置情報がありません';

  @override
  String get attendance_noMembersMatch => '検索に一致するメンバーはいません';

  @override
  String get attendance_noResponses => '回答はまだありません';

  @override
  String get attendance_notResponded => '未回答';

  @override
  String get attendance_openEyes => '目を開けてカメラを見てください';

  @override
  String get attendance_openMapFailed => 'マップを開けませんでした';

  @override
  String get attendance_openSubtitle => 'Excel、スプレッドシートなどのアプリで表示';

  @override
  String get attendance_optionHint => '選択肢名を入力';

  @override
  String get attendance_optionLabelRequired => 'すべての選択肢にラベルを入力してください';

  @override
  String attendance_optionNumber(int number) {
    return '選択肢 $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return '選択肢 $number • 📷 写真必須';
  }

  @override
  String get attendance_optionsUnique => '選択肢は重複しないようにしてください';

  @override
  String get attendance_photoCaptured => '写真を撮影しました';

  @override
  String get attendance_photoCapturedTapRetake => '写真撮影済み ✓ (タップして再撮影)';

  @override
  String get attendance_photoProof => '写真による証明';

  @override
  String attendance_photoProofOf(String name) {
    return '$nameさんの写真証明';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ $optionには写真が必要です';
  }

  @override
  String get attendance_photoRules =>
      'フロントカメラのみが使用されます。まばたきすると自動的に撮影され、ギャラリーからのアップロードはできません。';

  @override
  String get attendance_photoSubtitle => 'リアルタイム写真を撮影して出欠を確認します';

  @override
  String get attendance_photoTitle => '出欠用写真';

  @override
  String get attendance_photoVerified => '写真確認済み';

  @override
  String get attendance_questionHint => '今日参加できますか？';

  @override
  String get attendance_questionLabel => '出欠の質問';

  @override
  String get attendance_questionRequired => '出欠の質問項目は必須です';

  @override
  String attendance_questionTooShort(int count) {
    return '質問は$count文字以上で入力してください';
  }

  @override
  String get attendance_removeFailedShort => '取り消せません';

  @override
  String get attendance_removeResponseBody => 'この出欠確認の回答が消去されます。';

  @override
  String get attendance_removeResponseTitle => '回答を取り消しますか？';

  @override
  String get attendance_removeVoteFailed => '投票を削除できませんでした';

  @override
  String get attendance_reportEmpty => 'レポートは空です';

  @override
  String get attendance_reportFailed => 'レポートの生成に失敗しました';

  @override
  String get attendance_reportInvalid => 'サーバーから無効なレポートが返されました。もう一度お試しください。';

  @override
  String attendance_reportReady(String fileName) {
    return 'レポート作成完了 • $fileName';
  }

  @override
  String get attendance_reportSaved => 'レポートを保存しました';

  @override
  String get attendance_reportSubject => '出欠レポート';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return '出欠レポート • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count名が回答済み';
  }

  @override
  String get attendance_retakePhoto => '写真を撮り直す';

  @override
  String get attendance_saveInFiles => 'ファイルアプリに保存';

  @override
  String get attendance_saveReportDialog => '出欠レポートを保存';

  @override
  String get attendance_saveToDevice => '端末に保存';

  @override
  String get attendance_searchMember => 'メンバーを検索';

  @override
  String get attendance_selectPhotoOption => 'リアルタイム写真が必要な選択肢を指定してください';

  @override
  String get attendance_selectStatus => 'ステータスを選択してください';

  @override
  String get attendance_sentToAllMembers => 'このグループの全メンバーに送信されます';

  @override
  String get attendance_sentToGroup => '出欠確認をグループに送信しました';

  @override
  String get attendance_shareSubtitle => 'WhatsAppやメールで送信...';

  @override
  String get attendance_statusCompleted => '完了';

  @override
  String get attendance_statusOpen => '受付中';

  @override
  String get attendance_stepBlink => 'まばたきして写真を撮影します';

  @override
  String get attendance_stepEyeLevel => 'スマートフォンを目の高さで持ってください';

  @override
  String get attendance_submit => '出欠を提出';

  @override
  String get attendance_submitted => '出欠を提出しました';

  @override
  String get attendance_title => '出欠確認';

  @override
  String get attendance_update => '出欠を更新';

  @override
  String get attendance_validationError => '入力エラー';

  @override
  String get attendance_view => '表示';

  @override
  String get attendance_viewTitle => '出欠確認を表示';

  @override
  String get attendance_voteFailed => '投票を記録できませんでした';

  @override
  String attendance_withinKm(String km) {
    return '${km}km以内';
  }

  @override
  String attendance_withinMeters(int count) {
    return '${count}m以内';
  }

  @override
  String get call_accept => '応答';

  @override
  String get call_allContacts => 'すべての連絡先';

  @override
  String get call_allowAccess => 'アクセスを許可';

  @override
  String get call_answer => '応答';

  @override
  String get call_audioOutput => '音声出力';

  @override
  String get call_callFrom => '着信:';

  @override
  String get call_callIdNotFound => '通話IDが見つかりません';

  @override
  String get call_callInformation => '通話情報';

  @override
  String get call_callSummary => '通話概要';

  @override
  String get call_caller => '発信者';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name と他$count名',
      one: '$name と他1名',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の通話を削除できませんでした。もう一度お試しください。',
      one: '1件の通話を削除できませんでした。もう一度お試しください。',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の通話を削除しました',
      one: '1件の通話を削除しました',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'カメラ';

  @override
  String get call_cameraMicRequired => 'カメラまたはマイクの権限が必要です';

  @override
  String get call_cameraOff => 'カメラオフ';

  @override
  String get call_cameraOn => 'カメラオン';

  @override
  String get call_cameraUnavailable => 'カメラへのアクセスは現在利用できません。後でもう一度お試しください。';

  @override
  String get call_cannotReachCallServer => '通話サーバーに接続できません。ネットワークを確認してください。';

  @override
  String get call_chatFallback => 'チャット';

  @override
  String get call_closeFullScreen => '全画面を閉じる';

  @override
  String get call_communicationUnavailable => 'このユーザーとは通話できません';

  @override
  String get call_connectingProgress => '接続中…';

  @override
  String get call_connectionTimeout => '接続がタイムアウトしました';

  @override
  String get call_contactInformation => '連絡先情報';

  @override
  String get call_contactsAccessBannerMessage => 'チームメンバーを簡単に見つけて通話できます。';

  @override
  String get call_contactsAccessBannerTitle => '連絡先へのアクセスを許可してください';

  @override
  String get call_contactsAccessMessage =>
      'FG Trackerを利用しているユーザーを表示し、通話や招待を行えるようにするために連絡先へのアクセスが必要です。';

  @override
  String get call_contactsAccessTitle => '連絡先へのアクセスを許可';

  @override
  String get call_decline => '拒否';

  @override
  String get call_deleteCallsMessage => 'これらの通話は履歴から削除されます。';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の通話を削除しますか？',
      one: '1件の通話を削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage => 'この通話履歴を削除してもよろしいですか？';

  @override
  String get call_deleteHistoryTitle => '通話履歴を削除';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '選択したこれら $count 件の通話履歴を削除してもよろしいですか？',
      one: '選択したこの通話履歴を削除してもよろしいですか？',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => '選択した通話を削除';

  @override
  String call_deleteWithCount(int count) {
    return '削除 ($count)';
  }

  @override
  String call_durHr(int hours) {
    return '$hours時間';
  }

  @override
  String call_durHrMin(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String call_durMin(int minutes) {
    return '$minutes分';
  }

  @override
  String call_durMinSec(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String call_durSec(int seconds) {
    return '$seconds秒';
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
  String get call_duration => '通話時間';

  @override
  String call_durationValue(String duration) {
    return '通話時間: $duration';
  }

  @override
  String get call_earpiece => 'イヤピース';

  @override
  String get call_endCall => '通話を終了';

  @override
  String get call_ended => '終了';

  @override
  String get call_enterNumber => '番号を入力';

  @override
  String get call_enterPhoneNumber => '電話番号を入力してください';

  @override
  String get call_entryDeleteFailed => '通話履歴の削除に失敗しました';

  @override
  String call_entryDeleteFailedError(String error) {
    return '通話履歴の削除に失敗しました: $error';
  }

  @override
  String get call_entryDeleted => '通話履歴を削除しました';

  @override
  String get call_everyoneInCall => '全員が既に参加しています';

  @override
  String get call_failedTitle => '通話失敗';

  @override
  String get call_groupBadge => 'グループ';

  @override
  String get call_groupCallComingSoon => 'グループ通話は近日公開予定です';

  @override
  String get call_groupCallInitFailed => 'グループ通話を初期化できませんでした';

  @override
  String get call_groupCallStartFailed => 'グループ通話を開始できませんでした。もう一度お試しください。';

  @override
  String get call_groupInformation => 'グループ情報';

  @override
  String call_groupWithId(String id) {
    return 'グループ $id';
  }

  @override
  String get call_headphones => 'ヘッドホン';

  @override
  String call_historyCancelled(String callType) {
    return 'キャンセルされた $callType';
  }

  @override
  String get call_historyClearFailed => '通話履歴の消去に失敗しました';

  @override
  String call_historyClearFailedError(String error) {
    return '通話履歴の消去に失敗しました: $error';
  }

  @override
  String get call_historyCleared => 'すべての通話履歴を消去しました';

  @override
  String call_historyIncoming(String callType) {
    return '着信 $callType';
  }

  @override
  String call_historyMissed(String callType) {
    return '不在着信 $callType';
  }

  @override
  String call_historyOutgoing(String callType) {
    return '発信 $callType';
  }

  @override
  String call_historyRejected(String callType) {
    return '拒否した $callType';
  }

  @override
  String get call_inCall => '通話中';

  @override
  String call_inCallWithGroup(String groupName) {
    return '通話中 · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return '通話中 ($count)';
  }

  @override
  String get call_incomingAudio => '着信音声通話';

  @override
  String get call_incomingCallChannelName => '着信通話';

  @override
  String get call_incomingGroupAudio => '着信グループ音声通話';

  @override
  String get call_incomingGroupVideo => '着信グループビデオ通話';

  @override
  String get call_incomingVideo => '着信ビデオ通話';

  @override
  String get call_infoDescription => '説明';

  @override
  String get call_infoEmail => 'メール';

  @override
  String get call_infoGroupCode => 'グループコード';

  @override
  String get call_infoGroupName => 'グループ名';

  @override
  String get call_infoMobile => '携帯電話';

  @override
  String get call_infoTotalMembers => '総メンバー数';

  @override
  String get call_invite => '招待';

  @override
  String get call_inviteToApp => 'FG Trackerに招待';

  @override
  String get call_join => '参加';

  @override
  String get call_joinOnAnswer => '応答するとすぐに参加します';

  @override
  String get call_kindAudio => '音声通話';

  @override
  String get call_kindCall => '通話';

  @override
  String get call_kindGroupAudio => 'グループ音声通話';

  @override
  String get call_kindGroupCall => 'グループ通話';

  @override
  String call_kindGroupOther(String kind) {
    return 'グループ$kind通話';
  }

  @override
  String get call_kindGroupVideo => 'グループビデオ通話';

  @override
  String call_kindOther(String kind) {
    return '$kind通話';
  }

  @override
  String get call_kindVideo => 'ビデオ通話';

  @override
  String get call_loadDetailFailed => '通話詳細の読み込みに失敗しました';

  @override
  String get call_loadMore => 'もっと読み込む';

  @override
  String get call_loadRecentFailed => '最近の通話の読み込みに失敗しました';

  @override
  String get call_loginToCall => '通話を発信するにはログインしてください';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count名がこの通話に参加中',
      one: '1名がこの通話に参加中',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'メッセージ';

  @override
  String get call_micActive => 'マイクがアクティブです';

  @override
  String get call_missedCall => '不在着信';

  @override
  String get call_missedCallChannelName => '不在着信';

  @override
  String get call_missedCallNotification => '不在着信';

  @override
  String get call_more => 'その他';

  @override
  String get call_mute => 'ミュート';

  @override
  String get call_muted => 'ミュート中';

  @override
  String call_nameYou(String name) {
    return '$name（あなた）';
  }

  @override
  String get call_noActiveParticipants => 'アクティブな参加者はいません';

  @override
  String get call_noContactsMatch => '検索に一致する連絡先がありません';

  @override
  String get call_noGroupsFound => 'グループが見つかりません';

  @override
  String get call_noGroupsYet => 'グループがまだありません';

  @override
  String get call_noNameGroup => '名称未設定のグループ';

  @override
  String get call_noRecentCalls => '最近の通話はありません';

  @override
  String get call_noRecentMatch => '検索に一致する最近の通話はありません';

  @override
  String get call_noRecentYet => '最近の通話履歴はありません';

  @override
  String get call_noRegisteredContacts => '登録済みの連絡先が見つかりません';

  @override
  String get call_notInContacts => 'この番号は連絡先に登録されていません';

  @override
  String call_notInThisCall(int count) {
    return '通話外 ($count)';
  }

  @override
  String get call_notReady => '通話の準備ができていません';

  @override
  String get call_notificationPermissionRationale => '着信を表示するために必要です。';

  @override
  String get call_notificationPermissionSettings => '設定で通知を有効にしてください。';

  @override
  String get call_notificationPermissionTitle => '通知の権限';

  @override
  String get call_notify => '通知';

  @override
  String get call_notifyFailed => '通知に失敗しました';

  @override
  String get call_notifySent => '正常に通知されました';

  @override
  String get call_ongoingChannelDescription => '通話と画面共有を維持します';

  @override
  String get call_ongoingChannelName => '通話中';

  @override
  String get call_otherAlreadySharing => '相手が既に画面を共有しています';

  @override
  String get call_otherStartingVideo => '相手がビデオを開始しています';

  @override
  String get call_participant => '参加者';

  @override
  String get call_participants => '参加者';

  @override
  String call_personIsSharing(String name) {
    return '$nameが共有中';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$nameが画面を共有しています';
  }

  @override
  String get call_phone => '電話';

  @override
  String get call_pleaseWait => 'お待ちください';

  @override
  String get call_recentCalls => '最近の通話';

  @override
  String get call_resetZoom => 'ズームをリセット';

  @override
  String get call_returnToCall => '通話に戻る';

  @override
  String get call_screenBeingShared => '画面が共有されています';

  @override
  String get call_screenShareChannelDescription => 'アクティブな画面共有セッションの通知';

  @override
  String get call_screenShareChannelName => '画面共有サービス';

  @override
  String get call_screenSharePermissionDenied => '画面共有の権限が拒否されました';

  @override
  String get call_screenShareStartFailed => '画面共有を開始できませんでした';

  @override
  String get call_screenShareStopped => '画面共有が停止しました';

  @override
  String get call_screenSharingTitle => '画面共有中';

  @override
  String call_screenVisibleToName(String name) {
    return '$nameに画面が表示されています';
  }

  @override
  String get call_screenVisibleToOther => '相手に画面が表示されています';

  @override
  String get call_searchHint => '連絡先またはグループを検索';

  @override
  String get call_sectionLastWeek => '先週';

  @override
  String get call_sectionOlder => '以前';

  @override
  String get call_sectionThisWeek => '今週';

  @override
  String get call_selectAll => 'すべて選択';

  @override
  String call_selectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String get call_selectedDeleteFailed => '選択した通話の削除に失敗しました';

  @override
  String call_selectedDeleteFailedError(String error) {
    return '選択した通話の削除に失敗しました: $error';
  }

  @override
  String get call_selectedDeleted => '選択した通話を削除しました';

  @override
  String get call_selfCallWarning => '自分自身の番号には発信できません。';

  @override
  String get call_sessionConnectFailed => '通話セッションへの接続に失敗しました';

  @override
  String get call_shareScreen => '画面共有';

  @override
  String get call_shareScreenShort => '共有';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return '$groupNameで共有中 • タップして通話に戻る';
  }

  @override
  String get call_sharingYourScreen => '画面を共有中';

  @override
  String get call_someone => '誰か';

  @override
  String get call_speaker => 'スピーカー';

  @override
  String get call_started => '開始';

  @override
  String get call_startingScreenShare => '画面共有を開始しています…';

  @override
  String get call_statusBusy => '通話中';

  @override
  String get call_statusCalling => '発信中';

  @override
  String get call_statusCancelled => 'キャンセル';

  @override
  String get call_statusCompleted => '終了';

  @override
  String get call_statusConnected => '接続完了';

  @override
  String get call_statusConnecting => '接続中';

  @override
  String get call_statusDeclined => '拒否';

  @override
  String get call_statusJoined => '参加しました';

  @override
  String get call_statusMissed => '不在着信';

  @override
  String get call_statusReconnecting => '再接続中';

  @override
  String get call_statusRinging => '呼び出し中';

  @override
  String get call_statusVideoConnecting => 'ビデオ接続中';

  @override
  String get call_stop => '停止';

  @override
  String get call_stopSharing => '共有を停止';

  @override
  String get call_subtitle => '音声 / ビデオ通話';

  @override
  String get call_swipeUpToAnswer => '上にスワイプして応答';

  @override
  String get call_switch => '切り替え';

  @override
  String get call_switchCameraFailed => 'カメラを切り替えられませんでした';

  @override
  String get call_switchToVideoToShare => '画面を共有するにはビデオ通話に切り替えてください';

  @override
  String get call_tabContacts => '連絡先';

  @override
  String get call_tabGroups => 'グループ';

  @override
  String get call_tabRecent => '履歴';

  @override
  String get call_tapNotifyToInvite => '通知をタップして招待';

  @override
  String get call_tapStartBroadcastHint =>
      'システムの確認メッセージが表示されたら「ブロードキャストを開始」をタップしてください';

  @override
  String get call_title => '通話';

  @override
  String call_todayAt(String value) {
    return '今日、$value';
  }

  @override
  String get call_total => '合計';

  @override
  String get call_turnOnVideo => 'ビデオをオンにする';

  @override
  String get call_unableToCallContact => 'この連絡先に通話を発信できません';

  @override
  String get call_unableToMakeCall => '通話を発信できません';

  @override
  String get call_unableToOpenChat => 'この連絡先のチャットを開けません';

  @override
  String get call_unableToShareScreen => '画面を共有できません';

  @override
  String get call_unavailableTitle => '通話を利用できません';

  @override
  String get call_unexpectedResponse => 'サーバーからの予期しない応答です';

  @override
  String get call_unknown => '不明';

  @override
  String get call_unknownGroup => '不明なグループ';

  @override
  String get call_unknownUser => '不明なユーザー';

  @override
  String get call_unmute => 'ミュート解除';

  @override
  String get call_unselectAll => '選択を解除';

  @override
  String get call_user => 'ユーザー';

  @override
  String get call_userNotFound => 'ユーザーが見つかりません';

  @override
  String call_userWithId(String id) {
    return 'ユーザー $id';
  }

  @override
  String get call_video => 'ビデオ';

  @override
  String get call_waitingForBroadcast => '配信開始を待機中';

  @override
  String get call_waitingForBroadcastMessage =>
      '画面を共有するには、システムダイアログで「ブロードキャストを開始」をタップしてください。';

  @override
  String get call_waitingForMedia => 'メディアストリームを待機中...';

  @override
  String get call_wired => '有線';

  @override
  String get call_yesDelete => 'はい、削除します';

  @override
  String call_yesterdayAt(String value) {
    return '昨日、$value';
  }

  @override
  String get call_youAreSharing => '共有中';

  @override
  String get call_youAreSharingScreen => '画面を共有しています';

  @override
  String get call_zoomIn => '拡大';

  @override
  String get call_zoomOut => '縮小';

  @override
  String get chatList_allChats => 'すべてのチャット';

  @override
  String get chatList_allContacts => 'すべての連絡先';

  @override
  String get chatList_allowAccess => 'アクセスを許可';

  @override
  String get chatList_allowContactsBody =>
      'FG Trackerを利用しているユーザーを表示し、チャットや招待を開始できるようにするために連絡先へのアクセスが必要です。';

  @override
  String get chatList_allowContactsTitle => '連絡先へのアクセスを許可';

  @override
  String get chatList_archiveChat => 'チャットをアーカイブ';

  @override
  String get chatList_archived => 'アーカイブ済み';

  @override
  String get chatList_archivedChatsSubtitle => '非表示の会話';

  @override
  String get chatList_archivedChatsTitle => 'アーカイブされたチャット';

  @override
  String chatList_archivedCount(int count) {
    return 'アーカイブ ($count)';
  }

  @override
  String get chatList_block => 'ブロック';

  @override
  String get chatList_blockFailed => 'ユーザーをブロックできませんでした';

  @override
  String chatList_blockName(String name) {
    return '$nameをブロック';
  }

  @override
  String get chatList_blockUser => 'ユーザーをブロック';

  @override
  String get chatList_blockUserConfirm => 'このユーザーをブロックしてもよろしいですか？';

  @override
  String get chatList_blocked => 'ブロック中';

  @override
  String get chatList_chatCleared => 'チャットを消去しました';

  @override
  String get chatList_chooseContactToShare => 'チャットで共有する連絡先を選択してください。';

  @override
  String get chatList_clear => '消去';

  @override
  String get chatList_clearChat => 'チャットを消去';

  @override
  String get chatList_clearChatConfirm => 'このユーザーとのすべてのメッセージを削除しますか？';

  @override
  String get chatList_clearChatFailed => 'チャットを消去できませんでした';

  @override
  String get chatList_clearSearch => '検索をクリア';

  @override
  String get chatList_contactAndInfo => '連絡先と情報';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'チャットで連絡先を共有するには連絡先の権限が必要です。';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の連絡先',
      one: '1件の連絡先',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return '連絡先の読み込みに失敗しました: $error';
  }

  @override
  String get chatList_contactsPermissionNeeded => '連絡先の権限が必要です';

  @override
  String get chatList_contactsWillAppear => '連絡先が利用可能になるとここに表示されます。';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日',
      one: '1日',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => '無効化済み';

  @override
  String get chatList_defaultAbout => 'こんにちは！FG Tracker を使用しています';

  @override
  String get chatList_deleteChat => 'チャットを削除';

  @override
  String get chatList_deleteChatConfirm => 'この会話をチャット一覧から削除しますか？';

  @override
  String get chatList_forwardFailed => 'メッセージを転送できませんでした。';

  @override
  String get chatList_forwardListLoadFailed => '転送先リストを読み込めませんでした。';

  @override
  String get chatList_forwardTo => '転送先...';

  @override
  String get chatList_forwarded => '転送済み';

  @override
  String get chatList_groupChatFallback => 'グループチャット';

  @override
  String get chatList_groupDeactivatedBanner => 'このグループは管理者によって無効化されました';

  @override
  String get chatList_groupFallback => 'グループ';

  @override
  String get chatList_howToAllow => '許可する方法';

  @override
  String get chatList_howToAllowStep1 => '「アクセスを許可」をタップして設定を開きます';

  @override
  String get chatList_howToAllowStep2 => '「権限」をタップします';

  @override
  String get chatList_howToAllowStep3 => '「連絡先」を選択します';

  @override
  String get chatList_howToAllowStep4 => '「許可」を選択し、アプリに戻ります';

  @override
  String get chatList_invite => '招待';

  @override
  String get chatList_inviteChooseHow => '招待の送信方法を選択してください';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return '$nameさん、こんにちは！FG Trackerでつながりましょう。\n\nAndroid版ダウンロード: $playStoreLink\n\niOS版ダウンロード: $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'その他のアプリ';

  @override
  String chatList_inviteName(String name) {
    return '$nameを招待';
  }

  @override
  String get chatList_inviteViaMessage => 'メッセージ';

  @override
  String get chatList_locationHidden => '現在地は非公開です';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1、$name2 他$count名が入力中...';
  }

  @override
  String get chatList_markAsRead => '既読にする';

  @override
  String get chatList_markAsUnread => '未読にする';

  @override
  String get chatList_mediaLinksDocs => 'メディア・リンク・ドキュメント';

  @override
  String get chatList_memberFallback => 'メンバー';

  @override
  String get chatList_messageDeleted => 'このメッセージは削除されました';

  @override
  String get chatList_messageForwarded => 'メッセージを転送しました';

  @override
  String get chatList_messageIdMissing => 'メッセージIDが見つかりません。';

  @override
  String chatList_minutesShort(int count) {
    return '$count分';
  }

  @override
  String get chatList_mute1Hour => '1時間';

  @override
  String get chatList_mute8Hours => '8時間';

  @override
  String get chatList_muteAlways => '再度オンにするまで';

  @override
  String get chatList_muteSubtitle => '通知を一時停止する期間を選択してください。';

  @override
  String get chatList_muteTitle => '通知をミュート';

  @override
  String get chatList_muteUntilTomorrow => '明日まで';

  @override
  String get chatList_newChat => '新しいチャット';

  @override
  String get chatList_newChatSectionContacts => '新しいチャットを開始（連絡先）';

  @override
  String get chatList_newChatSectionInvite => 'チャットに招待（未登録の連絡先）';

  @override
  String get chatList_noArchivedChats => 'アーカイブされたチャットはありません';

  @override
  String get chatList_noArchivedChatsSubtitle => 'アーカイブされた会話がここに表示されます。';

  @override
  String get chatList_noChatsFound => 'チャットが見つかりません';

  @override
  String get chatList_noChatsSubtitle => '個別のチャットがここに表示されます。';

  @override
  String get chatList_noContactsAvailable => '利用可能な連絡先はありません';

  @override
  String get chatList_noContactsFound => '連絡先が見つかりません';

  @override
  String get chatList_noGroupsAvailable => '利用可能なグループはありません';

  @override
  String get chatList_noGroupsFound => 'グループが見つかりません';

  @override
  String get chatList_noMediaYet => '共有されたメディアはまだありません';

  @override
  String get chatList_noMessagesYet => 'メッセージはまだありません';

  @override
  String get chatList_noPeopleOrGroups => 'ユーザーまたはグループが見つかりません';

  @override
  String chatList_noResultsFor(String query) {
    return '「$query」の検索結果はありません';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return '「$query」の結果はありません';
  }

  @override
  String get chatList_noTrackerContacts => 'アクティブなトラッカー連絡先が見つかりません';

  @override
  String get chatList_offlineNotSaved => 'オフラインです。変更は保存されませんでした。もう一度お試しください。';

  @override
  String chatList_oneTyping(String name) {
    return '$nameが入力中...';
  }

  @override
  String get chatList_openSettings => '設定を開く';

  @override
  String get chatList_pinChat => 'チャットを固定';

  @override
  String get chatList_pinnedChats => '固定されたチャット';

  @override
  String get chatList_pleaseTryAgain => 'もう一度お試しください。';

  @override
  String get chatList_profileCall => '通話';

  @override
  String get chatList_profileMessage => 'メッセージ';

  @override
  String get chatList_profileNotFound => 'プロフィールの詳細が見つかりません';

  @override
  String get chatList_profileVideoCall => 'ビデオ通話';

  @override
  String get chatList_quickCommSubtitle => 'チームと即座につながる';

  @override
  String get chatList_quickCommTitle => 'クイック通信';

  @override
  String get chatList_quickGroups => 'グループ';

  @override
  String get chatList_quickGroupsSub => 'チームチャット';

  @override
  String get chatList_quickSafeZone => 'セーフゾーン';

  @override
  String get chatList_quickSafeZoneSub => '安全とアラート';

  @override
  String get chatList_quickTracking => '追跡';

  @override
  String get chatList_quickTrackingSub => 'リアルタイム位置情報';

  @override
  String get chatList_quickWalkie => 'トランシーバー';

  @override
  String get chatList_quickWalkieSub => 'プッシュツートーク';

  @override
  String get chatList_searchByNameOrNumber => '名前または番号で検索...';

  @override
  String get chatList_searchGroupsHint => 'グループを検索...';

  @override
  String get chatList_searchHint => 'チャットまたはメッセージを検索...';

  @override
  String get chatList_searchHintShort => '検索...';

  @override
  String get chatList_searchNameOrNumber => '名前または番号を検索';

  @override
  String get chatList_searchResults => '検索結果';

  @override
  String get chatList_sectionGroups => 'グループ';

  @override
  String get chatList_sectionMyContacts => 'マイ連絡先';

  @override
  String get chatList_sectionOtherContacts => 'その他の連絡先';

  @override
  String get chatList_sectionRecentChats => '最近のチャット';

  @override
  String get chatList_selectDestination => '送信先を選択';

  @override
  String get chatList_selectDestinationMsg => '少なくとも1人または1つのグループを選択してください。';

  @override
  String chatList_selectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String get chatList_shareContactTitle => '連絡先を共有';

  @override
  String chatList_shareMenuFailed(String error) {
    return '共有メニューを開けませんでした: $error';
  }

  @override
  String get chatList_smsOpenFailed => 'メッセージアプリを開けませんでした';

  @override
  String get chatList_someone => '誰か';

  @override
  String get chatList_startConversation => '会話を始める';

  @override
  String get chatList_subtitle => 'チームとつながりを維持';

  @override
  String get chatList_telegramOpenFailed => 'Telegramを開けませんでした';

  @override
  String get chatList_title => 'チャット';

  @override
  String get chatList_tryAnotherNameOrNumber => '別の名前または電話番号でお試しください。';

  @override
  String get chatList_tryDifferentSearch => '別の名前やメッセージで検索してみてください。';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1と$name2が入力中...';
  }

  @override
  String get chatList_typing => '入力中...';

  @override
  String get chatList_unableToCallContact => 'この連絡先に発信できません';

  @override
  String get chatList_unableToLoadContacts => '連絡先を読み込めません';

  @override
  String get chatList_unarchiveChat => 'アーカイブを解除';

  @override
  String get chatList_unblock => 'ブロック解除';

  @override
  String get chatList_unblockFailed => 'ユーザーのブロックを解除できませんでした';

  @override
  String chatList_unblockName(String name) {
    return '$nameのブロックを解除';
  }

  @override
  String get chatList_unblockUser => 'ユーザーのブロックを解除';

  @override
  String get chatList_unblockUserConfirm => 'このユーザーのブロックを解除してもよろしいですか？';

  @override
  String get chatList_unknown => '不明';

  @override
  String get chatList_unknownUser => '不明なユーザー';

  @override
  String get chatList_unnamedContact => '名称未設定の連絡先';

  @override
  String get chatList_unpinChat => '固定を解除';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未読メッセージ $count件',
      one: '未読メッセージ 1件',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed => 'チャットを更新できませんでした。もう一度お試しください。';

  @override
  String get chatList_userFallback => 'ユーザー';

  @override
  String get chatList_userNotFound => 'ユーザーが見つかりません';

  @override
  String get chatList_viewArchived => 'アーカイブされた会話を表示';

  @override
  String get chatList_whatsappOpenFailed => 'WhatsAppを開けませんでした';

  @override
  String get chatList_yourContacts => '連絡先';

  @override
  String get chat_addCaptionHint => 'キャプションを追加...';

  @override
  String get chat_audioUnavailable => 'この音声は利用できなくなりました';

  @override
  String get chat_blockFailed => 'ユーザーをブロックできませんでした';

  @override
  String get chat_call => '発信';

  @override
  String get chat_cameraAccessNeeded => 'チャットで写真や動画を撮影するにはカメラへのアクセスが必要です。';

  @override
  String get chat_cameraModePhoto => '写真';

  @override
  String get chat_cameraModePortrait => 'ポートレート';

  @override
  String get chat_cameraModeVideo => '動画';

  @override
  String get chat_cameraStartFailed => 'カメラを起動できませんでした。';

  @override
  String get chat_cantMessageUser => 'このユーザーにメッセージを送信することはできません';

  @override
  String get chat_chatActionsSubtitle => 'チャットを管理';

  @override
  String get chat_chatActionsTitle => 'チャット操作';

  @override
  String get chat_clear => '消去';

  @override
  String get chat_clearChat => 'チャットを消去';

  @override
  String get chat_clearChatConfirm => 'このチャットのすべてのメッセージを消去しますか？';

  @override
  String get chat_clearGroupChatFailed => 'グループチャットの消去に失敗しました';

  @override
  String get chat_contactBlockedYou => 'この連絡先にブロックされています';

  @override
  String get chat_contactUnavailable => '連絡先が利用できません';

  @override
  String get chat_deleteForEveryone => '全員に対して削除';

  @override
  String get chat_deleteForEveryoneConfirm => 'このメッセージを全員に対して削除してもよろしいですか？';

  @override
  String get chat_deleteForMe => '自分のみ削除';

  @override
  String get chat_deleteForMeConfirm => 'このメッセージをご自身のアカウントから削除してもよろしいですか？';

  @override
  String get chat_deleteMember => 'メンバーを削除';

  @override
  String get chat_deleteMemberSubtitle => 'このグループからメンバーを削除';

  @override
  String get chat_documentAvailable => 'ドキュメントを利用できます';

  @override
  String get chat_documentDownloadFailed => 'ドキュメントをダウンロードできませんでした。';

  @override
  String get chat_documentOpenFailed => 'ドキュメントを開けませんでした。もう一度お試しください。';

  @override
  String get chat_documentPreviewUnavailable =>
      'このファイル形式のプレビューは利用できません。インストールされているアプリを使用してドキュメントを開いてください。';

  @override
  String get chat_documentUnavailable => 'このドキュメントは利用できなくなりました';

  @override
  String get chat_downloadFailed => 'ダウンロードに失敗しました';

  @override
  String get chat_edited => '編集済み';

  @override
  String get chat_emptySubtitle => '「こんにちは 👋」と挨拶して会話を始めましょう';

  @override
  String get chat_emptyTitle => 'まだメッセージはありません';

  @override
  String get chat_fetchingLocation => '現在地を取得中...';

  @override
  String get chat_finishVoiceRecordingFirst => '先に音声録音を完了またはキャンセルしてください';

  @override
  String get chat_forwarded => '転送済み';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get chat_groupActionsSubtitle => 'グループ設定を管理';

  @override
  String get chat_groupActionsTitle => 'グループ操作';

  @override
  String get chat_groupChatCleared => 'グループチャットを消去しました';

  @override
  String get chat_groupDeactivated => 'このグループは管理者によって無効化されました';

  @override
  String get chat_imageFailed => '画像の読み込みに失敗しました';

  @override
  String get chat_listen => '聴く';

  @override
  String get chat_listenEnglish => '聴く（英語）';

  @override
  String get chat_listenHindi => '聴く（ヒンディー語）';

  @override
  String get chat_loadFailedSubtitle => '接続を確認してもう一度お試しください。';

  @override
  String get chat_loadFailedTitle => 'メッセージを読み込めませんでした';

  @override
  String get chat_locationFetchFailed => '現在地を取得できませんでした。もう一度お試しください。';

  @override
  String get chat_locationPermissionNeeded => '現在地を共有するには位置情報の権限が必要です。';

  @override
  String get chat_locationPermissionOff =>
      'このアプリの位置情報の権限がオフになっています。現在地を共有するには設定で有効にしてください。';

  @override
  String get chat_locationServicesOff => '現在地を共有するには位置情報サービスをオンにしてください。';

  @override
  String get chat_locationUnavailable => '現在地を利用できません';

  @override
  String get chat_mediaMissing => 'メディアが見つかりません';

  @override
  String get chat_mediaMissingToast => 'メディアが見つかりません。このファイルは利用できなくなりました。';

  @override
  String get chat_mediaUnavailable => 'このメディアは利用できなくなりました';

  @override
  String get chat_menuForward => '転送';

  @override
  String get chat_menuMessageInfo => 'メッセージ情報';

  @override
  String get chat_menuPin => 'メッセージを固定';

  @override
  String get chat_menuReply => '返信';

  @override
  String get chat_menuUnpin => '固定を解除';

  @override
  String get chat_messageCopied => 'メッセージをコピーしました';

  @override
  String get chat_messageDeleted => 'このメッセージは削除されました';

  @override
  String get chat_messageNotAvailable => 'メッセージを利用できません';

  @override
  String get chat_messageNotSent => 'メッセージは送信されませんでした。もう一度お試しください。';

  @override
  String get chat_noCameraFound => 'この端末にカメラが見つかりません。';

  @override
  String get chat_noLongerMember => 'あなたはこのグループのメンバーではなくなりました';

  @override
  String get chat_noMediaAvailable => '利用可能なメディアがありません';

  @override
  String get chat_offlineNotSent => 'オフラインです。メッセージは送信されませんでした。';

  @override
  String get chat_openDocument => 'ドキュメントを開く';

  @override
  String get chat_openInGoogleMaps => 'Google マップで開く';

  @override
  String get chat_openSettings => '設定を開く';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count名',
      one: '1名',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'この写真は利用できなくなりました';

  @override
  String get chat_previewAttendancePoll => '出欠確認の投票';

  @override
  String get chat_previewAudio => '音声';

  @override
  String get chat_previewContact => '連絡先';

  @override
  String get chat_previewDocument => 'ドキュメント';

  @override
  String get chat_previewLocation => '現在地';

  @override
  String get chat_previewMessage => 'メッセージ';

  @override
  String get chat_previewNewMessage => '新しいメッセージ';

  @override
  String get chat_previewOwnDeleted => 'このメッセージを削除しました';

  @override
  String get chat_previewPhoto => '写真';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚の写真',
      one: '1枚の写真',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => '投票';

  @override
  String get chat_previewSticker => 'ステッカー';

  @override
  String get chat_previewVideo => '動画';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の動画',
      one: '1件の動画',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => '音声メッセージ';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return '音声メッセージ ($duration)';
  }

  @override
  String get chat_recordingFailed => '録音・録画に失敗しました';

  @override
  String get chat_removeMember => 'メンバーを削除';

  @override
  String get chat_removeMemberConfirm => 'このメンバーをグループから削除してもよろしいですか？';

  @override
  String get chat_replyHint => 'メッセージに返信...';

  @override
  String get chat_searchMessages => 'メッセージを検索';

  @override
  String get chat_searchMessagesHint => 'メッセージを検索...';

  @override
  String get chat_searchMessagesSubtitle => 'キーワードでメッセージを検索';

  @override
  String get chat_sendLocation => '現在地を送信';

  @override
  String get chat_shareLocation => '現在地を共有';

  @override
  String get chat_shareVideoFailed => '動画を共有できませんでした';

  @override
  String get chat_sharedFromApp => 'FG Tracker から共有';

  @override
  String get chat_sharedLocation => '共有された現在地';

  @override
  String get chat_showOriginal => '原文を表示';

  @override
  String get chat_someone => '誰か';

  @override
  String get chat_statusLabel => 'ステータス';

  @override
  String get chat_statusUnavailable => 'このステータスの更新は利用できなくなりました';

  @override
  String get chat_stop => '停止';

  @override
  String get chat_stopEnglish => '停止（英語）';

  @override
  String get chat_stopHindi => '停止（ヒンディー語）';

  @override
  String get chat_takePhotoFailed => '写真の撮影に失敗しました';

  @override
  String get chat_translatedToEnglish => '英語に翻訳済み';

  @override
  String get chat_translatedToHindi => 'ヒンディー語に翻訳済み';

  @override
  String get chat_translating => '翻訳中...';

  @override
  String get chat_tryAgain => '再試行';

  @override
  String get chat_typeMessageHint => 'メッセージを入力...';

  @override
  String get chat_typing => '入力中...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count名が入力中...',
      one: '1名が入力中...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$nameが入力中...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1と$name2が入力中...';
  }

  @override
  String get chat_unableToOpen => '開けません';

  @override
  String get chat_unableToOpenGoogleMaps => 'Google マップを開けません';

  @override
  String get chat_unblock => 'ブロック解除';

  @override
  String get chat_unblockContact => '連絡先のブロックを解除';

  @override
  String get chat_unblockContactConfirm => 'この連絡先のブロックを解除してもよろしいですか？';

  @override
  String get chat_unblockFailed => 'ユーザーのブロック解除に失敗しました';

  @override
  String get chat_unknown => '不明';

  @override
  String get chat_unknownLocation => '不明な現在地';

  @override
  String get chat_unsupportedMessage => 'このメッセージはこのバージョンのアプリではサポートされていません';

  @override
  String get chat_updateGroup => 'グループを更新';

  @override
  String get chat_updateGroupSubtitle => '現在のグループ詳細を変更';

  @override
  String chat_uploadFileFailed(String path) {
    return '$pathのアップロードに失敗しました';
  }

  @override
  String get chat_userBlocked => 'ユーザーをブロックしました';

  @override
  String get chat_userUnblocked => 'ユーザーのブロックを解除しました';

  @override
  String get chat_videoDownloaded => '動画をダウンロードしました';

  @override
  String get chat_videoThumbnailFailed => '動画サムネイルの生成に失敗しました';

  @override
  String get chat_videoUnavailable => 'この動画は利用できなくなりました';

  @override
  String get chat_videoUploadFailed => '動画のアップロードに失敗しました';

  @override
  String get chat_voicePlayFailed => '音声メッセージを再生できませんでした';

  @override
  String get chat_voiceUploadFailed => '音声メッセージのアップロードに失敗しました。もう一度お試しください。';

  @override
  String get chat_youBlockedContact => 'この連絡先をブロックしました';

  @override
  String get common_add => '追加';

  @override
  String get common_allow => '許可';

  @override
  String get common_back => '戻る';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get common_close => '閉じる';

  @override
  String get common_comingSoon => '近日公開';

  @override
  String get common_confirm => '確認';

  @override
  String get common_continue => '続行';

  @override
  String get common_copied => 'コピーしました';

  @override
  String get common_copy => 'コピー';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日前',
      one: '1日前',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => '削除';

  @override
  String get common_dismiss => '閉じる';

  @override
  String get common_done => '完了';

  @override
  String get common_edit => '編集';

  @override
  String get common_error => 'エラー';

  @override
  String get common_exit => '退出';

  @override
  String get common_gotIt => '了解';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間前',
      one: '1時間前',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'たった今';

  @override
  String common_lastSeen(String time) {
    return '最終ログイン: $time';
  }

  @override
  String get common_loading => '読み込み中…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count名のメンバー',
      one: '1名のメンバー',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分前',
      one: '1分前',
    );
    return '$_temp0';
  }

  @override
  String get common_next => '次へ';

  @override
  String get common_no => 'いいえ';

  @override
  String get common_noData => 'データが見つかりません';

  @override
  String get common_noInternet => 'インターネット接続がありません';

  @override
  String get common_notNow => '後で';

  @override
  String get common_offline => 'オフライン';

  @override
  String get common_ok => 'OK';

  @override
  String get common_online => 'オンライン';

  @override
  String get common_open => '開く';

  @override
  String get common_permissionDenied => '権限が拒否されました';

  @override
  String get common_remove => '削除';

  @override
  String get common_retry => '再試行';

  @override
  String get common_save => '保存';

  @override
  String get common_search => '検索';

  @override
  String get common_send => '送信';

  @override
  String get common_settings => '設定';

  @override
  String get common_share => '共有';

  @override
  String get common_somethingWentWrong => '問題が発生しました。もう一度お試しください。';

  @override
  String get common_submit => '提出';

  @override
  String get common_success => '成功';

  @override
  String get common_today => '今日';

  @override
  String common_todayAt(String time) {
    return '今日、$time';
  }

  @override
  String get common_tryAgain => '再試行';

  @override
  String get common_viewAll => 'すべて表示';

  @override
  String get common_yes => 'はい';

  @override
  String get common_yesterday => '昨日';

  @override
  String get common_you => 'あなた';

  @override
  String get dialog_allowLocationAccess => '位置情報へのアクセスを許可';

  @override
  String get dialog_anErrorOccurred => 'エラーが発生しました！';

  @override
  String get dialog_important => '重要！';

  @override
  String get dialog_locationPermissionRequired => '位置情報の権限が必要です';

  @override
  String get dialog_locationPurposeBody =>
      'サービスの効率を向上させるため、アプリは位置情報を保存する目的でアクセス権限をリクエストします。これにより指定の作業場所まで正確にナビゲートできます。';

  @override
  String get dialog_locationSettingsAndroid =>
      '位置情報へのアクセスがないと、現在地を検出できません。「設定」をタップし、「権限」を選択して位置情報へのアクセスを許可してください。';

  @override
  String get dialog_locationSettingsIos =>
      'このアプリは位置情報サービスを提供するために現在地へのアクセスが必要です。「設定」から位置情報の権限を有効にしてください。';

  @override
  String get dialog_loggedInElsewhere => '他の端末からログインされました。';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      '他の端末からログインされました。再度ログインしてください。';

  @override
  String get dialog_logoutConfirm => 'ログアウトしますか？';

  @override
  String get dialog_selectAllowAllTheTime => '次のポップアップで\n「常に許可」を選択してください。';

  @override
  String get dialog_sessionExpiredTitle => 'セッションの有効期限が切れました';

  @override
  String get editProfile_fullNameLabel => '氏名';

  @override
  String get editProfile_personalInfo => '個人情報';

  @override
  String get editProfile_phoneLabel => '電話番号';

  @override
  String get editProfile_saveButton => '変更を保存';

  @override
  String get editProfile_tapPhotoHint => '写真をタップして変更';

  @override
  String get editProfile_title => 'プロフィールを編集';

  @override
  String get forceUpdate_currentInstalled => '現在のバージョン';

  @override
  String get forceUpdate_defaultMessage =>
      'FG Trackerの最新バージョンが利用可能です。続行するには更新してください。';

  @override
  String get forceUpdate_defaultTitle => 'アップデートが必要です';

  @override
  String get forceUpdate_fallbackMessage =>
      '重要な改善が含まれた新バージョンが利用可能です。利用を続けるには更新してください。';

  @override
  String get forceUpdate_footer => 'FG Trackerを利用するには更新が必要です';

  @override
  String get forceUpdate_requiredVersion => '必要なバージョン';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return '$storeNameで更新';
  }

  @override
  String get groupDialog_audioCall => '音声通話';

  @override
  String get groupDialog_audioCallSubtitle => '音声での会話を開始';

  @override
  String get groupDialog_call => '通話';

  @override
  String get groupDialog_chat => 'チャット';

  @override
  String get groupDialog_codeEmpty => 'グループコードを入力してください';

  @override
  String get groupDialog_codeLabel => 'グループコード';

  @override
  String get groupDialog_createButton => 'グループを作成';

  @override
  String get groupDialog_createTitle => '新しいグループを作成';

  @override
  String get groupDialog_descHint => 'グループの説明を入力';

  @override
  String get groupDialog_descLabel => 'グループの説明（任意）';

  @override
  String groupDialog_distance(String distance) {
    return '距離: $distance';
  }

  @override
  String get groupDialog_enterCodeManually => 'グループコードを手動で入力';

  @override
  String get groupDialog_enterCodeTitle => 'グループコードを入力';

  @override
  String get groupDialog_fillDetails => '以下の詳細を入力してください';

  @override
  String get groupDialog_getDirections => 'ルートを検索';

  @override
  String get groupDialog_join => 'グループに参加';

  @override
  String groupDialog_lastSeen(String time) {
    return '最終ログイン: $time';
  }

  @override
  String get groupDialog_locationHidden => '現在地は非公開です';

  @override
  String get groupDialog_locationUnavailable => '現在地を利用できません';

  @override
  String get groupDialog_member => 'メンバー';

  @override
  String get groupDialog_memberInfo => 'メンバー情報';

  @override
  String get groupDialog_nameHint => 'グループ名を入力';

  @override
  String get groupDialog_nameLabel => 'グループ名';

  @override
  String get groupDialog_noQrInImage => '選択した画像にQRコードが見つかりませんでした。';

  @override
  String get groupDialog_noValidQr => '有効なQRコードが見つかりませんでした。';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'ギャラリーからのQRコードデコードエラー: $error';
  }

  @override
  String get groupDialog_scanCamera => 'カメラからスキャン';

  @override
  String get groupDialog_selectCallType => '通話タイプを選択';

  @override
  String get groupDialog_update => '更新';

  @override
  String get groupDialog_updateTitle => 'グループを更新';

  @override
  String get groupDialog_uploadGallery => 'ギャラリーからアップロード';

  @override
  String get groupDialog_videoCall => 'ビデオ通話';

  @override
  String get groupDialog_videoCallSubtitle => 'ビデオでの会話を開始';

  @override
  String get groupDialog_yourLocation => '現在の位置情報';

  @override
  String get groupInfo_active => 'アクティブ';

  @override
  String get groupInfo_admin => '管理者';

  @override
  String get groupInfo_allGroups => 'すべてのグループ';

  @override
  String get groupInfo_allGroupsSubtitle => 'チームとつながりを保ちましょう';

  @override
  String get groupInfo_areYouSure => '本当によろしいですか？';

  @override
  String get groupInfo_audioCall => '音声通話';

  @override
  String get groupInfo_clearChatConfirm => 'この端末からすべてのメッセージを削除しますか？';

  @override
  String get groupInfo_createdBy => '作成者';

  @override
  String get groupInfo_detailsNotFound => 'グループの詳細が見つかりません';

  @override
  String get groupInfo_exitGroup => 'グループを退出';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return '「$groupName」を退出してもよろしいですか？';
  }

  @override
  String get groupInfo_exitGroupQuestion => 'このグループを退出しますか？';

  @override
  String get groupInfo_group => 'グループ';

  @override
  String get groupInfo_groupAdmin => 'グループ管理者';

  @override
  String get groupInfo_groupCallFailed => 'グループ通話を開始できませんでした。もう一度お試しください。';

  @override
  String get groupInfo_groupCodeCopied => 'グループコードをコピーしました！';

  @override
  String get groupInfo_groupSettings => 'グループ設定';

  @override
  String get groupInfo_groupSettingsSubtitle => 'グループ情報やプライバシーなどを編集';

  @override
  String get groupInfo_inactive => '非アクティブ';

  @override
  String get groupInfo_inviteCopied => '招待テキストをコピーしました';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'FG Trackerの私のグループ「$groupName」に参加してください';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'FG Trackerの私のグループ「$groupName」に参加してください。コード: $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'リンクで招待';

  @override
  String get groupInfo_mediaLinksDocs => 'メディア・リンク・ドキュメント';

  @override
  String get groupInfo_member => 'メンバー';

  @override
  String get groupInfo_members => 'メンバー';

  @override
  String get groupInfo_messageAction => 'メッセージ';

  @override
  String groupInfo_nameYou(String name) {
    return '$name（あなた）';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return '「$query」に一致するグループが見つかりません';
  }

  @override
  String get groupInfo_noGroupsYet => 'まだグループに参加または作成していません。\n今すぐ始めましょう！';

  @override
  String get groupInfo_noMediaYet => '共有されたメディアはまだありません';

  @override
  String get groupInfo_removeFromGroup => 'グループから削除';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return '$nameをグループから削除してもよろしいですか？';
  }

  @override
  String get groupInfo_searchGroupsHint => 'グループを検索...';

  @override
  String get groupInfo_showLess => '一部のみ表示';

  @override
  String get groupInfo_teamCode => 'チームコード';

  @override
  String groupInfo_totalCount(int count) {
    return '合計 $count';
  }

  @override
  String get groupInfo_unknownGroup => '不明なグループ';

  @override
  String get groupInfo_unnamedGroup => '名称未設定のグループ';

  @override
  String get groupInfo_videoCall => 'ビデオ通話';

  @override
  String get groupInfo_viewAllMembers => '全メンバーを表示';

  @override
  String get group_activatedSuccess => 'グループが有効化されました';

  @override
  String get group_addMember => 'メンバーを追加';

  @override
  String get group_alignQr => 'フレーム内にQRコードを合わせてください';

  @override
  String get group_areYouSure => 'よろしいですか？';

  @override
  String get group_chatWithMembers => 'グループのメンバーとチャット';

  @override
  String get group_codeCopied => 'グループコードをコピーしました！';

  @override
  String group_codeShareInfo(String code) {
    return 'グループコード: $code — 共有してメンバーを招待しましょう';
  }

  @override
  String get group_copyCode => 'コードをコピー';

  @override
  String get group_created => '作成済み';

  @override
  String get group_createdJustNow => 'たった今作成';

  @override
  String get group_deactivatedSuccess => 'グループが無効化されました';

  @override
  String get group_defaultName => 'グループ';

  @override
  String get group_deleteGroup => 'グループ削除';

  @override
  String get group_deleteGroupConfirm => 'このグループを削除しますか？';

  @override
  String get group_deletedSuccess => 'グループを削除しました';

  @override
  String get group_download => 'ダウンロード';

  @override
  String get group_downloadChannelDescription => 'QRコードの保存完了時に通知します';

  @override
  String get group_downloadChannelName => 'ダウンロード通知';

  @override
  String get group_enableLocationToJoin => 'グループに参加するには位置情報サービスを有効にしてください。';

  @override
  String get group_exitGroup => 'グループを退出';

  @override
  String get group_exitGroupConfirm => 'このグループから退出しますか？';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return '「$groupName」から退出しますか？再参加にはグループコードが必要になります。';
  }

  @override
  String get group_exitedSuccess => 'グループから退出しました';

  @override
  String get group_goToGroups => 'グループ一覧へ →';

  @override
  String get group_groupMessage => 'グループメッセージ';

  @override
  String get group_invalidResponseFormat => '無効な形式';

  @override
  String get group_joinedJustNow => 'たった今参加';

  @override
  String get group_joinedRecently => '最近';

  @override
  String get group_leftJustNow => 'たった今退出';

  @override
  String get group_locationNoLongerShared => 'このグループとの位置情報共有は停止されました';

  @override
  String get group_locationPermissionToJoin => 'グループに参加するには位置情報の権限が必要です。';

  @override
  String get group_locationShared => '現在地がこのグループに共有されています';

  @override
  String get group_memberFallbackName => 'メンバー';

  @override
  String group_membersMeta(int count, String when) {
    return '$count名のメンバー · $when';
  }

  @override
  String get group_noContactsFound => '連絡先が見つかりません';

  @override
  String get group_noGroupCode => 'グループコードがありません';

  @override
  String get group_noNewMessages => 'このグループからの新しいメッセージは届きません';

  @override
  String get group_noNumber => '番号なし';

  @override
  String get group_openGroup => 'グループを開く →';

  @override
  String get group_other => 'その他';

  @override
  String get group_qrSavedBody => 'タップしてQRコードを表示';

  @override
  String get group_qrSavedTitle => 'QRコードを保存しました';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 グループコード: $groupCode\n\n上記コードまたはQRコードをスキャンしてグループに参加してください。\n\n📲 アプリダウンロードはこちら:\n$appLink';
  }

  @override
  String get group_scanToJoin => 'このQRコードをスキャンしてグループに参加';

  @override
  String get group_searchMemberHint => 'メンバーを検索...';

  @override
  String get group_shareCodeInfo => 'グループコードを共有してメンバーを参加させましょう';

  @override
  String get group_shareQr => 'QRを共有';

  @override
  String get group_shareQrToInvite => 'QRコードを共有してメンバーを招待';

  @override
  String get group_sheetCreatedSubtitle =>
      'グループの準備が整いました。コードを共有してメンバーを招待しましょう。';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$nameさん、グループの準備ができました。コードを共有してメンバーを招待してください。';
  }

  @override
  String get group_sheetCreatedTitle => 'グループが作成されました！';

  @override
  String get group_sheetJoinedSubtitle => 'ようこそ！これであなたもこのグループのメンバーです。';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return '$nameさん、ようこそ！このグループのメンバーになりました。';
  }

  @override
  String get group_sheetJoinedTitle => 'グループに参加しました！';

  @override
  String get group_sheetLeftSubtitle => 'このグループのメンバーではなくなりました。';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$nameさん、このグループから退出しました。';
  }

  @override
  String get group_sheetLeftTitle => 'グループを退出しました';

  @override
  String get group_showQrCode => 'QRコードを表示';

  @override
  String get group_startConversation => '気軽にメッセージを送りましょう';

  @override
  String get group_statusUpdateFailed => 'グループ状態の更新に失敗しました';

  @override
  String get group_teamCode => 'チームコード';

  @override
  String get group_teamCodeLabel => 'チームコード: ';

  @override
  String get group_track => '追跡';

  @override
  String get group_unnamedMember => '名前なしメンバー';

  @override
  String get group_unnamedTrip => '未設定の旅行';

  @override
  String get group_updateGroupConfirm => 'グループの詳細を更新してもよろしいですか？';

  @override
  String get group_updateGroupTitle => 'グループ情報を更新';

  @override
  String get group_youAreAdmin => 'あなたはこのグループの管理者です';

  @override
  String get home_actionAllContacts => 'すべての連絡先';

  @override
  String get home_actionAudioVideoCall => '音声/ビデオ通話';

  @override
  String get home_actionChatting => 'チャット';

  @override
  String get home_actionSafeZone => 'セーフゾーン';

  @override
  String get home_actionTracking => '位置追跡';

  @override
  String get home_actionWalkieTalkie => 'トランシーバー';

  @override
  String get home_active => 'アクティブ';

  @override
  String get home_activeSessions => 'アクティブなセッション';

  @override
  String home_activeSessionsCount(int count) {
    return '$count件のアクティブセッション';
  }

  @override
  String get home_allMembers => 'すべてのメンバー';

  @override
  String get home_createGroup => 'グループ作成';

  @override
  String get home_createGroupSubtitle => '新しいグループを作成';

  @override
  String get home_goodToSeeYou => 'またお会いできて嬉しいです 👋';

  @override
  String home_groupsCount(int count) {
    return '$count個のグループ';
  }

  @override
  String home_helloName(String name) {
    return 'こんにちは、$nameさん';
  }

  @override
  String get home_inactive => '非アクティブ';

  @override
  String get home_joinGroup => 'グループに参加';

  @override
  String get home_joinGroupSubtitle => '既存のグループに参加';

  @override
  String home_lastSeen(String time) {
    return '最終ログイン: $time';
  }

  @override
  String get home_newThisMonth => '今月の新規';

  @override
  String get home_noActivePrivateSessions => 'アクティブなプライベートセッションはありません';

  @override
  String get home_noGroupsAvailable => '利用可能なグループはありません';

  @override
  String get home_noGroupsFound => 'グループが見つかりません';

  @override
  String get home_noMembersFound => 'メンバーが見つかりません';

  @override
  String home_noMembersMatch(String query) {
    return '\'$query\' に一致するメンバーはいません';
  }

  @override
  String get home_noMembersOnline => '現在オンラインのメンバーはいません';

  @override
  String get home_noNameGroup => '名前なしグループ';

  @override
  String get home_noRecentlyActiveMembers => '最近アクティブなメンバーはいません';

  @override
  String get home_onlineNow => '現在オンライン';

  @override
  String get home_peopleOnline => 'オンライン中のユーザー';

  @override
  String get home_peopleOnlineSubtitle => 'アプリを開いており、すぐに連絡を取ることができます。';

  @override
  String get home_privateMode => 'プライベートモード';

  @override
  String get home_privateModeIsOn => 'プライベートモードはONです';

  @override
  String get home_privateModeOffHint => 'プライベートモードがOFFの場合、他の人にあなたの現在地が共有されます。';

  @override
  String get home_privateModeOnHint => 'プライベートモードがONの場合、他の人にはあなたの現在地は見えません。';

  @override
  String get home_quickActionsSubtitle => 'ワンタップで必要な機能へすぐアクセス。';

  @override
  String get home_quickActionsTitle => 'クイック操作';

  @override
  String get home_recentlyOnline => '最近オンライン';

  @override
  String get home_searchGroupsHint => 'グループを検索...';

  @override
  String get home_searchMembersHint => 'メンバーを検索...';

  @override
  String get home_showLess => '閉じる';

  @override
  String get home_sortNameAsc => '並び替え: 名前順 (A-Z)';

  @override
  String get home_sortNameDesc => '並び替え: 名前逆順 (Z-A)';

  @override
  String home_startedAt(String time) {
    return '$timeに開始';
  }

  @override
  String get home_statGroups => 'グループ';

  @override
  String get home_statMembers => 'メンバー';

  @override
  String get home_statNow => '現在';

  @override
  String get home_statTotal => '合計';

  @override
  String get home_totalMembers => '総メンバー数';

  @override
  String home_totalMembersCount(int count) {
    return '合計 $count 名のメンバー';
  }

  @override
  String get home_unableToFetchGroups => 'グループを取得できません';

  @override
  String get home_unknownMember => '不明なメンバー';

  @override
  String get home_upgradeSubtitle => 'チーム向けの高機能・制限解除を利用';

  @override
  String get home_upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get home_viewPlans => 'プランを見る';

  @override
  String get home_walkieExpired => '期限切れ';

  @override
  String get home_walkieOneHourFree => '1時間無料';

  @override
  String get home_walkieRenew => '更新する';

  @override
  String get home_walkieSubscribed => '登録済み';

  @override
  String get home_youAreInvisible => '非表示中（不可視）';

  @override
  String get home_youAreVisible => '表示中（可視）';

  @override
  String get http_networkError => 'エラーが発生しました。もう一度お試しください！';

  @override
  String get http_sessionExpired => 'セッションの有効期限が切れました。再度ログインしてください。';

  @override
  String get http_unexpectedError => '予期せぬエラーが発生しました。もう一度お試しください。';

  @override
  String get imagePicker_camera => 'カメラ';

  @override
  String get imagePicker_cancel => 'キャンセル';

  @override
  String get imagePicker_cropTitle => '画像を切り抜き';

  @override
  String get imagePicker_gallery => 'ギャラリー';

  @override
  String get imagePicker_title => 'オプションを選択';

  @override
  String get intro_realTimeTrackingSubtitle =>
      '地図上で友人、家族、チームメンバーの現在地を瞬時に確認できます。';

  @override
  String get intro_realTimeTrackingTitle => 'リアルタイム位置追跡';

  @override
  String get intro_secureSubtitle => '選択した連絡先とのみ、現在地を\n安全かつプライベートに共有できます。';

  @override
  String get intro_secureTitle => '安全＆シンプル';

  @override
  String get intro_skip => 'スキップ';

  @override
  String get intro_walkieSubtitle => '電波がなくても安心。どこでも\nつながり続けます。';

  @override
  String get intro_walkieTitle => 'トランシーバー\n機能';

  @override
  String get media_cannotOpen => '開けません';

  @override
  String get media_documentNotFound => 'ドキュメントが見つかりません';

  @override
  String get media_invalidLink => '無効なリンク';

  @override
  String get media_noDocuments => 'ドキュメントが見つかりません';

  @override
  String get media_noLinks => 'リンクが見つかりません';

  @override
  String get media_noMedia => 'メディアが見つかりません';

  @override
  String get media_tabDocs => 'ドキュメント';

  @override
  String media_tabDocsCount(int count) {
    return 'ドキュメント ($count)';
  }

  @override
  String get media_tabLinks => 'リンク';

  @override
  String media_tabLinksCount(int count) {
    return 'リンク ($count)';
  }

  @override
  String get media_tabMedia => 'メディア';

  @override
  String media_tabMediaCount(int count) {
    return 'メディア ($count)';
  }

  @override
  String get media_title => 'メディア・リンク・ドキュメント';

  @override
  String get media_videoNotFound => '動画が見つかりません';

  @override
  String get menu_contactUsSubtitle => 'サポートとお問い合わせ';

  @override
  String get menu_editProfile => 'プロフィール編集';

  @override
  String get menu_editProfileSubtitle => '個人情報を更新';

  @override
  String get menu_followUsOn => '公式SNSをフォロー';

  @override
  String get menu_logOut => 'ログアウト';

  @override
  String get menu_logOutConfirmMessage => '本当にログアウトしますか？';

  @override
  String get menu_logOutSubtitle => 'アプリからサインアウト';

  @override
  String get menu_profileImageUpdateFailed => 'プロフィール画像の更新に失敗しました';

  @override
  String get menu_profileImageUpdated => 'プロフィール画像が更新されました';

  @override
  String get notif_accept => '応答';

  @override
  String get notif_channelHighImportanceDesc => '重要度の高い通知のデフォルトチャンネル';

  @override
  String get notif_channelHighImportanceName => '重要度の高い通知';

  @override
  String get notif_channelWalkieAudioDesc =>
      'リアルタイムの音声通信とバックグラウンドでのマイクキャプチャを維持';

  @override
  String get notif_channelWalkieAudioName => 'トランシーバー ライブ音声';

  @override
  String get notif_channelWalkieCallsDesc => '着信トランシーバー通話';

  @override
  String get notif_channelWalkieCallsName => 'トランシーバー通話';

  @override
  String get notif_channelWalkieDesc => 'グループ通話と発言の更新';

  @override
  String get notif_channelWalkieLiveDesc => 'アクティブなトランシーバーチャンネルの通知';

  @override
  String get notif_channelWalkieLiveName => 'トランシーバー ライブチャンネル';

  @override
  String get notif_channelWalkieName => 'トランシーバー';

  @override
  String notif_connectedIn(String group) {
    return '$groupに接続中 • ライブ音声配信';
  }

  @override
  String get notif_goToWalkie => 'トランシーバー画面へ移動';

  @override
  String get notif_incomingWalkieTitle => 'トランシーバー着信';

  @override
  String notif_isTalking(String name) {
    return '$nameが話しています';
  }

  @override
  String get notif_leave => '退出';

  @override
  String get notif_openWalkie => 'トランシーバーを開く';

  @override
  String get notif_reject => '拒否';

  @override
  String notif_stoppedTalking(String name) {
    return '$nameが発言を終了しました';
  }

  @override
  String get notif_walkieActiveConversation => 'アクティブなトランシーバー通話';

  @override
  String get notif_walkieActiveTitle => 'トランシーバーがアクティブ';

  @override
  String notif_wantsToTalk(String name) {
    return '$nameが話しかけています';
  }

  @override
  String get notifications_clearAll => 'すべての通知を消去';

  @override
  String get notifications_clearedSuccess => 'すべての通知を消去しました';

  @override
  String get notifications_emptySubtitle => '現在、新しい通知やお知らせはありません。';

  @override
  String get notifications_emptyTitle => '通知はありません';

  @override
  String get notifications_filterAll => 'すべて';

  @override
  String get notifications_filterCalls => '通話';

  @override
  String get notifications_filterChats => 'チャット';

  @override
  String get notifications_filterUnread => '未読';

  @override
  String get notifications_loadingDetails => '通知の詳細を読み込み中';

  @override
  String get notifications_recentCalls => '最近の通話履歴';

  @override
  String get notifications_title => '通知';

  @override
  String get otpCharges_chargedNotice =>
      '次回以降、この番号へのログインOTP送信は有料となります。再送信は3回まで無料です。';

  @override
  String get otpCharges_chargesApplyTo => '適用対象';

  @override
  String get otpCharges_eachOtpCosts => 'OTP 1回あたりの料金';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'OTP 1回につき $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'OTP 1回につき $amount (消費税 $percent% 込)';
  }

  @override
  String get otpCharges_firstLoginFree => '初回ログインは無料でした。';

  @override
  String get otpCharges_freeBody => 'この番号へのログイン確認コード送信には料金はかかりません。';

  @override
  String get otpCharges_freeTitle => 'お使いの電話番号はOTPが無料です';

  @override
  String otpCharges_gstTitle(String percent) {
    return '消費税 ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return '$percent% 税込み';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return '$percent% 税込み';
  }

  @override
  String get otpCharges_noInternet => 'インターネットに接続されていません。ネットワークを確認してください。';

  @override
  String get otpCharges_otpCharge => 'OTP送信料';

  @override
  String otpCharges_pay(String amount) {
    return '$amount を支払う';
  }

  @override
  String get otpCharges_paymentCancelled => '支払いがキャンセルされました。金額は引き落とされていません。';

  @override
  String get otpCharges_paymentFailed =>
      '支払いに失敗しました。引き落としがあった場合は5〜7営業日以内に返金されます。';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return '決済一時停止中 ($amount)';
  }

  @override
  String get otpCharges_paymentReceived => '支払いを受領しました。確認コードが届くまで少々お待ちください。';

  @override
  String get otpCharges_paymentStartFailed => '支払いを開始できませんでした。もう一度お試しください。';

  @override
  String get otpCharges_paymentsPaused =>
      '管理者によりOTP決済が一時停止されています。詳細は以下をご確認ください。';

  @override
  String get otpCharges_paymentsUnavailable =>
      'OTP決済は現在利用できません。しばらくしてからお試しください。';

  @override
  String get otpCharges_sessionExpired => 'セッションの有効期限が切れました。最初からやり直してください。';

  @override
  String get otpCharges_title => 'OTP認証料金';

  @override
  String get otpCharges_totalPerOtp => 'OTP 1件あたりの合計';

  @override
  String get otpCharges_tryAgainMoment => '問題が発生しました。しばらくしてからもう一度お試しください。';

  @override
  String get otpCharges_unknownBody =>
      'インドの電話番号へのOTPは無料です。その他の国についてはログイン時に支払額が表示されます。';

  @override
  String get otpCharges_unknownTitle => 'OTP料金はお住まいの国によって異なります';

  @override
  String get otpCharges_updateApp => '支払いを開始できませんでした。アプリを更新してから再試行してください。';

  @override
  String otpCharges_vatTitle(String percent) {
    return '税 ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      '支払いの確認に失敗しました。引き落とされた場合は5〜7営業日以内に返金されます。';

  @override
  String get otpCharges_yourNumber => 'お客様の番号';

  @override
  String get package_noPackages => '現在利用可能なプランはありません。';

  @override
  String package_plansComingSoon(String title) {
    return '$titleのプランは近日公開予定です';
  }

  @override
  String get package_subtitle => '機能を選択してプラン一覧を表示';

  @override
  String get package_title => 'プランと料金';

  @override
  String get package_viewPlans => 'プランを見る';

  @override
  String get perm_alwaysLocationBody =>
      'グループをリアルタイムおよびバックグラウンドで追跡するには、アプリの設定で位置情報のアクセスを「常に許可」に設定してください。';

  @override
  String get perm_alwaysLocationTitle => '位置情報「常に許可」を有効にする';

  @override
  String get perm_chooseAllowAllTime => '次のポップアップで「常に許可」を選択してください。';

  @override
  String get perm_collectsLocationBody =>
      'このアプリは、アプリを閉じているときや使用していないときでも、業務の円滑な進行と効率的な追跡のために位置情報データを収集します。';

  @override
  String get perm_enableDeviceGpsBody => '端末のGPS（Google位置情報）を有効にしてください。';

  @override
  String get perm_enableGpsTitle => 'GPSを有効化';

  @override
  String get perm_exitBody => 'アプリを終了しますか？';

  @override
  String get perm_exitTitle => '本当によろしいですか？';

  @override
  String get perm_gpsRequiredBody => 'グループをリアルタイムで追跡するにはGPSが必要です。';

  @override
  String get perm_locationTitle => '位置情報の権限';

  @override
  String get perm_trackingPermissionBody =>
      'FG Partnerアプリはログイン中の位置情報を追跡するための許可が必要です。';

  @override
  String get permission_allowAllTheTime => '常に許可';

  @override
  String get permission_allowLocation => '位置情報を許可';

  @override
  String get permission_allowLocationFirst => 'まず位置情報を許可してください。';

  @override
  String permission_allowNamed(String permission) {
    return '$permissionを許可';
  }

  @override
  String get permission_allowNotifications => '通知を許可';

  @override
  String get permission_appPermissionsSubtitle => '必要な権限を確認してください。';

  @override
  String get permission_appPermissionsTitle => 'アプリの権限';

  @override
  String get permission_badgeGranted => '許可済み';

  @override
  String get permission_badgeOptional => '任意';

  @override
  String get permission_badgeRecommended => '推奨';

  @override
  String get permission_badgeRequired => '必須';

  @override
  String get permission_camera => 'カメラ';

  @override
  String get permission_cameraDescription => '写真や動画を撮影する機能で使用します。';

  @override
  String get permission_cameraSettingsMessage =>
      '写真や動画を撮影するにはカメラ権限が必要です。設定から有効にしてください。';

  @override
  String get permission_cameraWhy => 'プロフィール、チャットなどで写真や動画を撮影・送信できます。';

  @override
  String get permission_contacts => '連絡先';

  @override
  String get permission_contactsDescription => 'アプリ内で連絡先を検索・選択するために使用します。';

  @override
  String get permission_contactsSettingsMessage =>
      '連絡先の検索と選択には連絡先権限が必要です。設定から有効にしてください。';

  @override
  String get permission_contactsWhy => '連絡先関連の機能を利用する際に、メンバーをスムーズに検索・選択できます。';

  @override
  String get permission_gateCheckFailed => '権限を確認できませんでした。もう一度お試しください。';

  @override
  String get permission_gateSubtitle =>
      'FG Trackerは、着信やアラートの受信、出欠管理、リアルタイム追跡、セーフゾーン機能の実行のためにこれらの権限を必要とします。';

  @override
  String get permission_gateTitle => '必要な権限';

  @override
  String get permission_genericSettingsMessage => 'この権限が必要です。アプリ設定から有効にしてください。';

  @override
  String get permission_iosLocationServicesOff =>
      '位置情報サービスが無効です。設定 → プライバシーとセキュリティ → 位置情報サービスを開いてONにしてください。';

  @override
  String get permission_location => '位置情報';

  @override
  String get permission_locationAndNotificationRequired =>
      '続行するには位置情報と通知の権限が必要です。';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      '続行するには位置情報と通知が必須です。';

  @override
  String get permission_locationDescription =>
      '出欠確認、位置追跡、セーフゾーン機能（バックグラウンド動作含む）に必要です。';

  @override
  String get permission_locationRequiredToContinue => '続行するには位置情報の権限が必要です。';

  @override
  String get permission_locationStatusApproximate =>
      'おおよその位置情報のみ許可されています。正確な位置が必要です。';

  @override
  String get permission_locationStatusBlocked =>
      '位置情報がブロックされています。設定から許可してください。';

  @override
  String get permission_locationStatusDone => '常に許可 · 高精度 · GPS利用中';

  @override
  String get permission_locationStatusGpsOff => '端末の位置情報 (GPS) がOFFです。';

  @override
  String get permission_locationStatusNeedAlways => '「常に許可」の設定が必要です。';

  @override
  String get permission_locationStatusNotAllowed => '位置情報の権限がまだ許可されていません。';

  @override
  String get permission_locationWhyExtra => '「常に許可」を選択し、正確な位置情報を有効のままにしてください。';

  @override
  String get permission_logout => 'ログアウト';

  @override
  String get permission_microphone => 'マイク / 音声';

  @override
  String get permission_microphoneDescription =>
      '音声通話、トランシーバー、ボイスメッセージ機能で使用します。';

  @override
  String get permission_microphoneSettingsMessage =>
      '音声、トランシーバー、通話にはマイク権限が必要です。設定から有効にしてください。';

  @override
  String get permission_microphoneWhy => '音声通話、トランシーバー通信、音声録音などを可能にします。';

  @override
  String permission_notGrantedNamed(String permission) {
    return '$permissionの権限が許可されませんでした。もう一度お試しください。';
  }

  @override
  String get permission_notificationRequiredToContinue => '続行するには通知権限が必要です。';

  @override
  String get permission_notificationSettingsText =>
      'FG Trackerの通知がOFFです。設定 → 通知を開いて許可してください。';

  @override
  String get permission_notificationStatusBlocked =>
      '通知がブロックされています。設定から許可してください。';

  @override
  String get permission_notificationStatusDone => '許可済み';

  @override
  String get permission_notificationStatusNotAllowed => '通知権限がまだ許可されていません。';

  @override
  String get permission_notifications => '通知';

  @override
  String get permission_notificationsDescription =>
      '着信通話、チャット、出欠や安全ゾーンのアラートを受け取るために必要です。';

  @override
  String get permission_notificationsWhyExtra => 'この権限がないと着信音が鳴りません。';

  @override
  String get permission_openSettings => '設定を開く';

  @override
  String get permission_preciseLocation => '正確な位置情報';

  @override
  String get permission_pushNotifications => 'プッシュ通知';

  @override
  String get permission_reasonLocation => '出欠確認、リアルタイム追跡、セーフゾーン通知に位置情報が必要です。';

  @override
  String get permission_reasonLocationAlways =>
      'アプリがバックグラウンドにある時も追跡と安全ゾーンを継続するため、「常に許可」を選択してください。';

  @override
  String get permission_reasonNotification =>
      '着信通話、チャット、出欠、安全ゾーンのアラートを受け取るために通知が必要です。';

  @override
  String get permission_reasonPrecise => '正確な出欠確認、位置追跡、通知のために高精度の位置情報が必要です。';

  @override
  String get permission_required => '権限が必要です';

  @override
  String get permission_selectAllowAllTheTime => '続行するには「常に許可」を選択してください。';

  @override
  String get permission_settingsAndroidAlways =>
      '設定 → 権限 → 位置情報を開き、「常に許可」を選択してください。';

  @override
  String get permission_settingsAndroidBlocked =>
      'FG Trackerの位置情報がブロックされています。設定 → 権限 → 位置情報で「常に許可」を選択してください。';

  @override
  String get permission_settingsAndroidPrecise =>
      '設定 → 権限 → 位置情報を開き、「正確な位置情報を使用」をONにしてください。';

  @override
  String get permission_settingsIosAlways => '設定 → 位置情報を開き、「常に」を選択してください。';

  @override
  String get permission_settingsIosBlocked =>
      'FG Trackerの位置情報アクセスがOFFです。設定 → 位置情報を開き、「常に」を選択してください。';

  @override
  String get permission_settingsIosPrecise =>
      '設定 → 位置情報を開き、「正確な位置情報」をONにしてください。';

  @override
  String get permission_skipAndContinue => 'スキップして続行';

  @override
  String get permission_turnOnLocation => '位置情報をONにする';

  @override
  String get permission_turnOnPreciseLocation => '正確な位置情報をONにする';

  @override
  String get permission_unableToRequest => '権限をリクエストできません。';

  @override
  String get permission_whyWeNeedThis => '必要な理由';

  @override
  String get registration_contactNumberHint => '連絡先番号を入力';

  @override
  String get registration_contactNumberLabel => '連絡先番号';

  @override
  String get registration_doneButton => '完了';

  @override
  String get registration_emailHint => 'メールアドレスを入力';

  @override
  String get registration_emailLabel => 'メールアドレス';

  @override
  String get registration_genderFemale => '女性';

  @override
  String get registration_genderLabel => '性別を選択';

  @override
  String get registration_genderMale => '男性';

  @override
  String get registration_genderOther => 'その他';

  @override
  String get registration_selectGenderError => '性別を選択してください';

  @override
  String get registration_userNameHint => 'ユーザー名を入力';

  @override
  String get registration_userNameLabel => 'ユーザー名';

  @override
  String get repo_allCallsCleared => 'すべての通話履歴を消去しました';

  @override
  String get repo_callDeleted => '通話履歴を削除しました';

  @override
  String get repo_invalidResponse => '無効な応答形式です';

  @override
  String get repo_loadLocationsFailed => 'グループの位置情報の読み込みに失敗しました';

  @override
  String get repo_pkgConflict => 'このプランは既に有効か、支払いが処理中です。';

  @override
  String get repo_pkgNotFound => '現在プランは利用できません。後でもう一度お試しください。';

  @override
  String get repo_pkgOffline => 'インターネット接続がありません。ネットワークを確認してもう一度お試しください。';

  @override
  String get repo_pkgSessionExpired => 'セッションの有効期限が切れました。再度ログインしてください。';

  @override
  String get repo_pkgTimeout => 'サーバーの応答に時間がかかりすぎています。もう一度お試しください。';

  @override
  String get repo_selectedCallsDeleted => '選択した通話を削除しました';

  @override
  String get repo_unnamedGroup => '名称未設定のグループ';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return '総距離: $distance  •  許容偏差: $deviation';
  }

  @override
  String get safeRoute_activeTitle => '有効なセーフルート';

  @override
  String get safeRoute_alertSettingsDesc => 'セーフルート通知、許容範囲、通知設定を管理します。';

  @override
  String get safeRoute_alertSheetDesc => 'メンバーが安全ルートから外れた時のリアルタイム通知';

  @override
  String get safeRoute_alertTitle => 'セーフルート通知';

  @override
  String get safeRoute_appBarSubtitle => 'メンバーに安全な移動ルートを設定します。';

  @override
  String get safeRoute_destination => '目的地';

  @override
  String get safeRoute_deviated => 'セーフルートから逸脱しました';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'メンバーが安全ルートから $distance 以上逸脱した場合、アラートが送信されます。';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (逸脱距離: $distance)';
  }

  @override
  String get safeRoute_deviationLimit => '逸脱許容範囲';

  @override
  String get safeRoute_deviationSubtitle => '設定したルートから離れてよい許容距離を設定します。';

  @override
  String get safeRoute_distance => '距離';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance km • 約$minutes分';
  }

  @override
  String get safeRoute_edit => 'セーフルートを編集';

  @override
  String get safeRoute_end => 'ゴール';

  @override
  String safeRoute_estTime(int minutes) {
    return '所要時間目安: 約$minutes分';
  }

  @override
  String get safeRoute_featureDesc => '事前に安全なルートを設定し、ルートを外れた際に自動でアラートを通知します。';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    return '$group ($count名のメンバー)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'ルートから外れて移動できる許容距離です。これを超えると通知が届きます。';

  @override
  String get safeRoute_helpDeviationTitle => '逸脱限度とは？';

  @override
  String get safeRoute_helpHowBody => 'メンバーを選び、出発地と目的地を設定後、最適なルートと許容距離を指定します。';

  @override
  String get safeRoute_helpHowTitle => '安全ルートの作成手順';

  @override
  String get safeRoute_helpTitle => 'セーフルートのヘルプ';

  @override
  String get safeRoute_helpWhatBody => '出発地と目的地を指定して、メンバーのための安全な移動ルートを作成します。';

  @override
  String get safeRoute_helpWhatTitle => 'セーフルートとは？';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$nameさんがセーフルートから逸脱しました';
  }

  @override
  String get safeRoute_recommended => 'おすすめ';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (おすすめ)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'ルート ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'セーフルートを保存して有効化';

  @override
  String get safeRoute_saveActivateGroup => 'グループ用セーフルートを保存して有効化';

  @override
  String get safeRoute_selectedRoute => '選択されたルート';

  @override
  String get safeRoute_setRoutesSubtitle => 'グループ全メンバーの安全ルートを作成・管理します。';

  @override
  String get safeRoute_start => 'スタート';

  @override
  String get safeRoute_startLocation => '出発地';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. 逸脱許容範囲を設定';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. プレビューして適用';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. ルートをプレビュー';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. ルートを選択';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. メンバー用ルートを設定';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. 出発地と目的地を設定';
  }

  @override
  String get safeRoute_subtitle => 'ルート保護';

  @override
  String get safeRoute_title => 'セーフルート';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return '半径: $radius  •  中心: $center';
  }

  @override
  String get safeZone_activePreview => '有効 (プレビュー)';

  @override
  String get safeZone_activeTitle => '有効なセーフゾーン';

  @override
  String get safeZone_alertSettingsDesc => 'セーフゾーン、通知距離、通知設定を管理します';

  @override
  String get safeZone_alertSheetDesc => 'メンバーが安全ゾーンを離れた時のリアルタイム通知';

  @override
  String get safeZone_alertTitle => 'セーフゾーン通知';

  @override
  String safeZone_allMonitored(int count) {
    return 'このセーフゾーン内で全 $count 名のメンバーが見守られます。';
  }

  @override
  String get safeZone_appBarSubtitle => '安全なエリアを定義。エリア外へ\n出た時に即座にアラートを通知。';

  @override
  String safeZone_appliedToGroup(int count) {
    return '選択したグループの全 $count 名にこのセーフゾーンが適用されます。';
  }

  @override
  String get safeZone_edit => 'セーフゾーンを編集';

  @override
  String get safeZone_exited => 'セーフゾーンから出ました';

  @override
  String get safeZone_featureDesc => '安全なエリアを設定し、メンバーが範囲外へ出た時に即座に通知を受け取ります。';

  @override
  String get safeZone_helpHowBody => 'メンバーを選び、地図上で中心地点と半径を指定します。';

  @override
  String get safeZone_helpHowTitle => 'セーフゾーンの作成方法';

  @override
  String get safeZone_helpRadiusBody => '必要に応じて範囲半径 (500m、1km、2km、5km) を選択します。';

  @override
  String get safeZone_helpRadiusTitle => 'セーフゾーン半径とは？';

  @override
  String get safeZone_helpTitle => 'セーフゾーンのヘルプ';

  @override
  String get safeZone_helpWhatBody => '地図上に範囲を指定し、メンバーが外へ出た時に警告アラートを受け取ります。';

  @override
  String get safeZone_helpWhatTitle => 'セーフゾーンとは？';

  @override
  String safeZone_memberLeft(String name) {
    return '$nameさんがセーフゾーンから出ました';
  }

  @override
  String get safeZone_membersMonitored => 'この安全ゾーン内でメンバーが見守られます。';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return '$place 付近 ($zone の外)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place ($zone の外)';
  }

  @override
  String get safeZone_saveActivate => 'セーフゾーンを保存して有効化';

  @override
  String get safeZone_saveActivateGroup => 'グループ用セーフゾーンを保存して有効化';

  @override
  String get safeZone_searchLocation => '場所を検索...';

  @override
  String get safeZone_statusLabel => '状態:';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. セーフゾーンをプレビュー';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. セーフゾーンの半径を設定';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. 地図上で場所を選択';
  }

  @override
  String get safeZone_subtitle => 'エリア保護';

  @override
  String get safeZone_title => 'セーフゾーン';

  @override
  String safeZone_totalMembers(int count) {
    return '合計 $count 名のメンバー';
  }

  @override
  String get safety_active => '有効';

  @override
  String get safety_alertSettings => 'アラート設定';

  @override
  String get safety_alerts => 'アラート';

  @override
  String get safety_alertsDesc => '緊急の対応が必要です';

  @override
  String get safety_bannerBody => 'スマート安全機能でチームメンバーを常に見守ります。';

  @override
  String get safety_bannerTitle => '安全を最優先に';

  @override
  String get safety_chooseFeature => '安全機能を選択';

  @override
  String get safety_comingSoonBody => 'チームを守るスマートセーフティ機能がまもなく登場します。';

  @override
  String get safety_contactSupport => 'サポートに問い合わせる';

  @override
  String get safety_editAnytime => '後からいつでも変更・無効化が可能です。';

  @override
  String get safety_mapCityPark => '中央公園';

  @override
  String get safety_mapMainRoad => '本通り';

  @override
  String get safety_mapMarketLane => 'マーケット通り';

  @override
  String get safety_mapRiver => 'リバー沿い';

  @override
  String get safety_mapStationRoad => '駅前通り';

  @override
  String get safety_needHelpBody => '安全に関するご相談はサポートチームまでお問い合わせください。';

  @override
  String get safety_quickOverview => '概要';

  @override
  String get safety_recentAlerts => '最近のアラート';

  @override
  String get safety_recenter => '中心に戻す';

  @override
  String get safety_safeNow => '現在安全';

  @override
  String get safety_safeNowDesc => 'メンバーは安全ゾーン/ルート内にいます';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. グループを選択';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. メンバーを選択';
  }

  @override
  String get safety_tabIndividual => '個人';

  @override
  String get safety_tagline => 'いつも安全に、常につながる。';

  @override
  String get safety_title => 'セーフティ';

  @override
  String get safety_viewAllMembers => '全メンバーを表示';

  @override
  String get sheet_addGroupMember => 'グループメンバーを追加';

  @override
  String get sheet_admin => '管理者';

  @override
  String get sheet_attachSubtitle => 'チームとファイルやメディアを共有';

  @override
  String get sheet_attachUpload => '添付 / アップロード';

  @override
  String get sheet_attendance => '出欠確認';

  @override
  String get sheet_callOptions => '通話オプション';

  @override
  String get sheet_cantRemoveSelf => '自分自身をグループから削除することはできません。';

  @override
  String get sheet_contact => '連絡先';

  @override
  String get sheet_contactsNotOnApp => '連絡先の方はまだ FG Tracker を使用していません。';

  @override
  String get sheet_document => 'ドキュメント';

  @override
  String get sheet_groupMembers => 'グループメンバー';

  @override
  String get sheet_location => '現在地';

  @override
  String get sheet_memberRemoved => 'メンバーを削除しました';

  @override
  String get sheet_noMembers => 'メンバーが見つかりません';

  @override
  String get sheet_noRegisteredContacts => '登録済みの連絡先はありません';

  @override
  String get sheet_noUserFound => 'ユーザーが見つかりません';

  @override
  String get sheet_normalAudioCall => '通常の音声通話';

  @override
  String get sheet_normalAudioCallSubtitle => 'クリアな標準音質';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '登録済み連絡先 $count件',
      one: '登録済み連絡先 1件',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return '$nameをグループから削除してもよろしいですか？';
  }

  @override
  String get sheet_removeMemberTitle => 'メンバーを削除';

  @override
  String get sheet_searchContacts => '連絡先を検索';

  @override
  String get sheet_walkieCall => 'トランシーバー通話';

  @override
  String get sheet_walkieCallSubtitle => 'プッシュツートーク通信';

  @override
  String get sos_addDetailsMandatory => '詳細を入力 (必須)';

  @override
  String get sos_addDetailsOptional => '詳細を入力 (任意)';

  @override
  String get sos_addFamilyMember => '家族を追加';

  @override
  String get sos_addFamilyMemberRequired =>
      'SOSアラートを送信するには、少なくとも1人の家族を追加してください';

  @override
  String get sos_addPhotoHint => '状況を正しく伝えるために写真を添付できます。';

  @override
  String get sos_addPhotoOptional => '写真を追加 (任意)';

  @override
  String get sos_alertSent => 'SOSアラートを送信しました！';

  @override
  String get sos_alertSentToNearby => '周辺のユーザーにアラートが送信されました。';

  @override
  String get sos_alertWillBeSent => '周辺のユーザーへアラートが送信されます';

  @override
  String get sos_alertWillBeSentFamily => '周囲の人および登録されたご家族へアラートが送信されます。';

  @override
  String sos_availableUsers(int count) {
    return '$count名の利用可能なユーザー';
  }

  @override
  String get sos_detailsHint => '追加の詳細を入力してください...';

  @override
  String get sos_detailsMandatoryForOther => '理由に「その他」を選択した場合は詳細の入力が必須です';

  @override
  String get sos_howItWorks => '仕組み';

  @override
  String get sos_howItWorksIntro => 'SOSアラートは、緊急時に近くの人や家族へ素早く助けを求める機能です。';

  @override
  String get sos_howItWorksTitle => 'SOSアラートの仕組み';

  @override
  String get sos_liveTrackingStarted => 'リアルタイム追跡を開始しました';

  @override
  String sos_locationSharedWithFamily(int count) {
    return '$count名の家族と現在地を共有中';
  }

  @override
  String sos_membersSelected(int count) {
    return '$count名を選択中';
  }

  @override
  String get sos_needHelp => '助けが必要ですか？';

  @override
  String get sos_needHelpBody => '周辺の人へSOSアラートを送信します。\n通知が届き、すぐに支援を求められます。';

  @override
  String get sos_noMatchFound => '一致する項目がありません';

  @override
  String get sos_noUsersFound => 'ユーザーが見つかりません';

  @override
  String get sos_notifyFamilyTitle => '家族へ通知 (1〜5人必須)';

  @override
  String get sos_notifyUpdates => '最新情報が入り次第お知らせします';

  @override
  String get sos_okGotIt => '了解';

  @override
  String get sos_peopleWithinRadius => '半径2km以内のユーザー';

  @override
  String get sos_privacyNote => 'プライバシーを保護します。位置情報はアクティブなSOS発信時のみ共有されます。';

  @override
  String get sos_reasonAccident => '事故';

  @override
  String get sos_reasonMedical => '医療・救護';

  @override
  String get sos_reasonOther => 'その他';

  @override
  String get sos_reasonSafety => '安全・防犯';

  @override
  String get sos_reasonThreat => '脅迫・危険';

  @override
  String get sos_required => '必須';

  @override
  String get sos_searchUsers => 'ユーザーを検索';

  @override
  String get sos_selectReason => '理由を選択';

  @override
  String get sos_sendSosAlert => 'SOSアラートを送信';

  @override
  String get sos_stayCalm => '落ち着いてお待ちください。助けが向かっています';

  @override
  String get sos_step1Body => 'SOSボタンをタップして、周囲のユーザーへ警報を送信します。';

  @override
  String get sos_step1Title => '1. SOSアラートを送信';

  @override
  String get sos_step2Body => '近くの人にあなたの現在地と共にアラートが届きます。';

  @override
  String get sos_step2Title => '2. 周囲の人へ通知';

  @override
  String get sos_step3Body => '周囲の人がアラートを確認し、すぐに救援に向かうことができます。';

  @override
  String get sos_step3Title => '3. 素早く助けを得る';

  @override
  String get sos_step4Body => '指定されたご家族にも即座にSOSメッセージが届きます。';

  @override
  String get sos_step4Title => '4. 家族への自動通知';

  @override
  String get sos_subtitle => '周辺のユーザーへアラートを送信';

  @override
  String get sos_title => 'SOSアラート';

  @override
  String get sos_willBeNotified => 'に通知されます';

  @override
  String status_activeCount(int count) {
    return '$count件アクティブ';
  }

  @override
  String get status_addToMyStatus => 'ステータスに追加';

  @override
  String get status_allContacts => 'すべての連絡先';

  @override
  String get status_cameraAccessFailed => 'カメラにアクセスできません';

  @override
  String get status_captionHint => 'キャプションを追加...';

  @override
  String get status_changeMedia => 'メディアを変更';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day $time';
  }

  @override
  String get status_deleted => 'ステータスを削除しました';

  @override
  String get status_deletedByOwner => 'このステータスは投稿者によって削除されました';

  @override
  String get status_exceptContacts => '連絡先を除く';

  @override
  String get status_exceptSelected => '選択した連絡先を除く';

  @override
  String get status_flip => 'カメラ反転';

  @override
  String get status_gallery => 'ギャラリー';

  @override
  String get status_modePhoto => '写真';

  @override
  String get status_modeText => 'テキスト';

  @override
  String get status_modeVideo => '動画';

  @override
  String get status_myStatus => 'マイステータス';

  @override
  String get status_new => '新規';

  @override
  String get status_noCamera => 'カメラを利用できません';

  @override
  String get status_noLongerAvailable => 'このステータスは利用できなくなりました';

  @override
  String get status_noViewsYet => '閲覧者はまだいません';

  @override
  String get status_onlyShareWith => '指定した連絡先とのみ共有';

  @override
  String get status_pause => '一時停止';

  @override
  String get status_pinchZoomHint => 'ピンチ操作で写真を拡大';

  @override
  String get status_play => '再生';

  @override
  String get status_postStatus => 'ステータスを投稿';

  @override
  String get status_previewStatus => 'ステータスのプレビュー';

  @override
  String get status_privacy => 'プライバシー';

  @override
  String get status_privacyTitle => 'ステータスのプライバシー';

  @override
  String get status_publishFailed => 'ステータスを公開できませんでした';

  @override
  String get status_replyHint => 'ステータスに返信...';

  @override
  String get status_retake => '再撮影';

  @override
  String get status_selectPhotoFirst => '先に写真を撮影または選択してください';

  @override
  String get status_selectVideoFirst => '先に動画を撮影または選択してください';

  @override
  String get status_shareUpdatesHint => 'チームと近況を共有';

  @override
  String get status_tapVideoHint => '動画をタップして再生 / 一時停止';

  @override
  String get status_textRequired => 'テキストステータスには内容の入力が必要です';

  @override
  String get status_title => 'ステータス';

  @override
  String get status_typeHint => 'ステータスを入力...';

  @override
  String get status_uploadFailed => 'アップロードに失敗しました';

  @override
  String get status_viewMyStatus => 'ステータスを表示';

  @override
  String get status_viewed => '閲覧済み';

  @override
  String status_viewedBy(int count) {
    return '$count人が閲覧';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回の閲覧',
      one: '1回の閲覧',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => '公開範囲';

  @override
  String get track_admin => '管理者';

  @override
  String get track_applyRadius => '半径を適用';

  @override
  String get track_checkNetworkConnection => 'ネットワーク接続を確認して再試行してください。';

  @override
  String get track_checkNetworkMembers => '近くのメンバーを表示するにはネットワークを確認して再試行してください。';

  @override
  String get track_currentLocation => '現在地';

  @override
  String get track_custom => 'カスタム';

  @override
  String track_customWithValue(String radius) {
    return 'カスタム ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return '$distance 離れた場所';
  }

  @override
  String get track_enable => '有効化';

  @override
  String get track_enableGpsBody => 'グループをリアルタイムで追跡するには、GPSをオンにしてください。';

  @override
  String get track_enableGpsTitle => 'GPSを有効にする';

  @override
  String get track_errorFailedLoadGroups => 'グループの読み込みに失敗しました';

  @override
  String get track_errorLoadGroups => 'グループを読み込めません。もう一度お試しください。';

  @override
  String get track_errorLoadMembers => '近くのメンバーを読み込めません。もう一度お試しください。';

  @override
  String get track_errorNoInternet => 'インターネットに接続されていません。ネットワークを確認してください。';

  @override
  String get track_errorServer => 'サーバーに接続できません。もう一度お試しください。';

  @override
  String track_groupCode(String code) {
    return 'コード: $code';
  }

  @override
  String get track_groupMembers => 'グループメンバー';

  @override
  String track_groupMembersAndCode(int count, String code) {
    return '$count名のメンバー • コード: $code';
  }

  @override
  String get track_groupTab => 'グループ';

  @override
  String track_groupsCount(int count) {
    return '$count個のグループ';
  }

  @override
  String track_groupsHeader(int count) {
    return 'グループ ($count)';
  }

  @override
  String get track_helpGroupBody => '複数人を同時に追跡するにはグループを作成します。';

  @override
  String get track_helpGroupTitle => 'グループを追加するには？';

  @override
  String get track_helpLiveBody => '地図上でチームメンバーの現在地をリアルタイムに確認できます。';

  @override
  String get track_helpLiveTitle => 'リアルタイム追跡とは？';

  @override
  String get track_helpRadiusBody => '地図上で周囲のメンバーを検出する範囲を設定します。';

  @override
  String get track_helpRadiusTitle => '追跡半径とは？';

  @override
  String get track_helpTitle => '追跡ヘルプ';

  @override
  String track_lastSeen(String time) {
    return '最終確認: $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count名 ライブ中';
  }

  @override
  String get track_liveMembers => 'ライブ中のメンバー';

  @override
  String get track_liveTracking => 'ライブ追跡';

  @override
  String get track_locating => '測位中...';

  @override
  String get track_locationHidden => '位置情報非公開';

  @override
  String get track_locationUnavailable => '位置情報を取得できません';

  @override
  String get track_mapOfflineBody =>
      'リアルタイムの地図データとメンバー位置情報を読み込むにはインターネット接続が必要です。';

  @override
  String get track_mapUnavailableOffline => 'オフラインのため地図を表示できません';

  @override
  String get track_member => 'メンバー';

  @override
  String track_memberPausedSharing(String name) {
    return '$nameさんは位置情報の共有を一時停止しました。現在地は表示されません。';
  }

  @override
  String track_membersHeader(int count) {
    return 'メンバー ($count)';
  }

  @override
  String track_membersLive(int count) {
    return '$count名がライブ配信中';
  }

  @override
  String get track_menuMembers => 'メンバー';

  @override
  String get track_menuRefreshMap => '地図を再読み込み';

  @override
  String get track_menuTheme => 'テーマ';

  @override
  String get track_nearbyYou => 'あなたの近く';

  @override
  String get track_noActiveMembers => 'アクティブなメンバーはいません';

  @override
  String track_noActiveMembersWithin(String radius) {
    return '$radius以内にアクティブなメンバーはいません';
  }

  @override
  String get track_noDescription => '説明なし';

  @override
  String get track_noGroupsFound => 'グループが見つかりません';

  @override
  String get track_noGroupsMatch => '一致するグループがありません';

  @override
  String track_noGroupsMatchQuery(String query) {
    return '\'$query\' に一致するグループはありません';
  }

  @override
  String get track_noGroupsYet => '参加または作成したグループはまだありません。';

  @override
  String get track_noInternetTitle => 'インターネット未接続';

  @override
  String get track_noMembersFound => 'メンバーが見つかりません';

  @override
  String get track_noMembersFoundPlain => 'メンバーが見つかりません';

  @override
  String get track_noMembersInGroup => 'このグループにはメンバーがいません';

  @override
  String track_noMembersMatch(String query) {
    return '\'$query\' に一致するメンバーはいません';
  }

  @override
  String track_noSearchMatches(String query) {
    return '一致するメンバーまたはグループがありません';
  }

  @override
  String track_noSearchResults(String query) {
    return '\'$query\' に該当するメンバーまたはグループは見つかりませんでした';
  }

  @override
  String get track_notAvailable => 'なし';

  @override
  String get track_offlineBanner => 'インターネット未接続。地図と追跡機能はオフラインです。';

  @override
  String get track_private => '非公開';

  @override
  String get track_radius => '半径';

  @override
  String get track_refresh => '更新';

  @override
  String get track_refreshing => '更新中...';

  @override
  String get track_retryConnection => '再接続する';

  @override
  String get track_searchHint => 'メンバーまたはグループを検索...';

  @override
  String get track_searchMembersHint => 'メンバーを検索...';

  @override
  String get track_selectedLocation => '選択した場所';

  @override
  String get track_setRadiusSubtitle => 'スライダーで半径を選択してください';

  @override
  String get track_setRadiusTitle => '追跡範囲を設定';

  @override
  String get track_unableToLoadGroups => 'グループを読み込めません';

  @override
  String get track_unableToLoadMembers => 'メンバーを読み込めません';

  @override
  String get track_unnamedGroup => '名前なしグループ';

  @override
  String get track_unnamedMember => '名前なしメンバー';

  @override
  String get track_yourGroups => '所属グループ';

  @override
  String get track_yourLocationPaused => '位置情報の共有は一時停止中で非公開です。';

  @override
  String get util_previewContact => '👤 連絡先';

  @override
  String get util_previewDocument => '📄 ドキュメント';

  @override
  String get util_previewLocation => '📍 現在地';

  @override
  String get util_previewPhoto => '📷 写真';

  @override
  String get util_previewVideo => '🎥 動画';

  @override
  String get util_previewVoice => '🎤 音声メッセージ';

  @override
  String util_spokenEur(String amount) {
    return '$amountユーロ';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amountポンド';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupeesルピー',
      one: '1ルピー',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupeesルピー $paiseパイサ';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount米ドル';
  }

  @override
  String get util_unableToCallContact => 'この連絡先に通話を発信できません';

  @override
  String get util_unableToStartGroupCall => 'グループ通話を開始できません';

  @override
  String get validation_emailEmpty => 'メールアドレスを入力してください';

  @override
  String get validation_emailInvalid => '有効なメールアドレスを入力してください。';

  @override
  String validation_required(String field) {
    return '$fieldは必須です';
  }

  @override
  String get voice_appLanguage => 'アプリの言語';

  @override
  String get voice_audioChip => '音声';

  @override
  String get voice_captionReady => 'キャプション準備完了';

  @override
  String get voice_chooseSpeechLanguage => '音声認識の言語を選択';

  @override
  String get voice_couldntPlay => 'ボイスメッセージを再生できませんでした';

  @override
  String get voice_didntCatch => '聞き取れませんでした。マイクをタップしてもう少し大きな声で話してください。';

  @override
  String get voice_language => '言語';

  @override
  String get voice_listenBack => '聞き直す';

  @override
  String get voice_listenBeforeSending => '送信前にボイスメッセージを試聴できます。';

  @override
  String get voice_listening => '聞き取り中…';

  @override
  String get voice_micPermissionNeeded => '音声機能を利用するにはマイクの権限が必要です。';

  @override
  String get voice_micUnavailable => 'マイクが利用できません。設定を確認してください。';

  @override
  String get voice_noTextCaptured => 'テキストを取得できませんでした。録音し直してください。';

  @override
  String get voice_openSettings => '設定を開く';

  @override
  String get voice_permissionRequired => '権限が必要です';

  @override
  String get voice_reRecord => '再録音';

  @override
  String get voice_readyToSend => '送信の準備ができました';

  @override
  String get voice_recordVoice => '音声を録音';

  @override
  String get voice_recordVoiceSubtitle => '録音してボイスメッセージとして送信';

  @override
  String get voice_recordingYourVoice => '音声を録音中…';

  @override
  String get voice_replyReady => '返信準備完了';

  @override
  String get voice_reviewTextHint => '上の音声を再生して確認するか、送信前に入力ボックスで編集できます。';

  @override
  String get voice_sendMessage => 'メッセージを送信';

  @override
  String get voice_sendVoiceMessage => 'ボイスメッセージを送信';

  @override
  String get voice_speakNowCaption => '話してください – キャプションを入力しています';

  @override
  String get voice_speakNowMessage => '話してください – メッセージ入力欄にテキストが表示されます';

  @override
  String get voice_speakNowReply => '話してください – 返信を入力しています';

  @override
  String get voice_speakPlaceholder => '話してください… ここに文字が表示されます';

  @override
  String get voice_speechPermissionNeeded => '音声をテキストに変換するには音声認識権限が必要です。';

  @override
  String get voice_tapToStop => 'タップして停止';

  @override
  String get voice_textReady => 'テキスト準備完了';

  @override
  String get voice_tooMuchNoise => '周囲の雑音が多すぎます – 電話を近づけてはっきり話してください';

  @override
  String get voice_type => 'タイプ';

  @override
  String get voice_voiceToText => '音声入力';

  @override
  String get voice_voiceToTextSubtitle => '話してメッセージを入力';

  @override
  String get voice_willSendAudioMessage => 'ボイスメッセージとして送信されます';

  @override
  String get voice_willSendAudioReply => '音声メッセージとして返信されます';

  @override
  String get voice_willSendWithFile => 'ファイルと共に音声が送信されます';

  @override
  String get voice_yourMessage => 'あなたのメッセージ';

  @override
  String get voice_yourVoiceMessage => 'あなたのボイスメッセージ';

  @override
  String get walkiePlan_availableIndividualPlans => '個人向けプラン';

  @override
  String get walkiePlan_availablePerMonth => '/ 月';

  @override
  String get walkiePlan_availablePerSeat => '/ 席';

  @override
  String get walkiePlan_availableSingleMember => '1名様 (個人利用)';

  @override
  String get walkiePlan_availableSubtitle => 'プランを選択して利用を開始またはアップグレード';

  @override
  String get walkiePlan_availableTeamPlans => 'チーム向けプラン';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min〜$max席  •  グループ連携';
  }

  @override
  String get walkiePlan_availableTitle => '利用可能なプラン';

  @override
  String get walkiePlan_bottomBarAfterTrial => '無料トライアル終了後';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'プランを選択';

  @override
  String get walkiePlan_bottomBarContinue => 'トランシーバーを継続利用';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return '$price で購入';
  }

  @override
  String get walkiePlan_cardActive => '有効';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return '$date より有効';
  }

  @override
  String get walkiePlan_cardAssigned => '割り当て済み';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return '$name から割り当て済み';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'あなたに割り当て済み';

  @override
  String get walkiePlan_cardAvailable => '利用可能';

  @override
  String get walkiePlan_cardManageMembers => 'メンバー管理';

  @override
  String get walkiePlan_cardNoActiveIndividual => '有効な個人サブスクリプションはありません';

  @override
  String get walkiePlan_cardNoActiveTeam => '有効なチームプランまたは割り当て座席はありません';

  @override
  String get walkiePlan_cardOneSeatSelf => '1席 (ご自身)';

  @override
  String get walkiePlan_cardPersonal => '個人用';

  @override
  String get walkiePlan_cardPurchased => '購入済み';

  @override
  String get walkiePlan_cardPurchasedByYou => 'ご自身で購入';

  @override
  String get walkiePlan_cardPurchasedOn => '購入日';

  @override
  String get walkiePlan_cardSeatsMembers => '座席数 / メンバー';

  @override
  String get walkiePlan_cardSubscribedByYou => 'ご自身で加入';

  @override
  String get walkiePlan_cardTeamAdministrator => 'チーム管理者';

  @override
  String get walkiePlan_cardValidUntil => '有効期限';

  @override
  String get walkiePlan_cardView => '表示';

  @override
  String get walkiePlan_cardViewPlan => 'プラン詳細';

  @override
  String walkiePlan_couponDiscount(String value) {
    return '$value 割引';
  }

  @override
  String get walkiePlan_couponExpired => 'クーポンの有効期限が切れています';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return '$amount 引き';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet => '最低注文金額に達していません';

  @override
  String get walkiePlan_couponNotEligible => '選択中のプランでは利用できません';

  @override
  String get walkiePlan_couponNotStarted => 'このクーポンはまだ開始されていません';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent% OFF';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable => 'このプランには適用できません';

  @override
  String walkiePlan_couponValidTill(String date) {
    return '$date まで有効';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'お支払いへ進む';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return '$plan で続ける';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => 'クーポンが適用されました！';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return 'クーポン適用！ $amount お得';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => 'クーポンの適用に失敗しました';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'クーポンを解除しました';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'Cashfree エラー ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed => '支払いの初期化に失敗しました。';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return '決済セッションの作成に失敗しました: $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return '支払いを処理できません: $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'プランを読み込み中...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans => 'プランを読み込めません。もう一度お試しください。';

  @override
  String get walkiePlan_detailsAllBanks => 'すべての主要銀行に対応';

  @override
  String get walkiePlan_detailsApplied => '適用済み';

  @override
  String get walkiePlan_detailsApply => '適用';

  @override
  String get walkiePlan_detailsApplyCaps => '適用';

  @override
  String get walkiePlan_detailsAvailableCoupons => '利用可能なクーポン';

  @override
  String get walkiePlan_detailsCard => 'クレジットカード / デビットカード';

  @override
  String get walkiePlan_detailsChooseTitle => 'プランを選択';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'コード: $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'クーポン＆割引';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'クーポンコードを入力';

  @override
  String get walkiePlan_detailsEnterValidCoupon => '有効なクーポンコードを入力してください';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'グループコミュニケーション';

  @override
  String get walkiePlan_detailsFeatHqVoice => '高音質音声通話';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => '優先サポート';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => '距離無制限';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => '無制限トランシーバー';

  @override
  String get walkiePlan_detailsHavePromoCode => 'プロモーションコードをお持ちですか？';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'ご自身やチームに合ったプランでトランシーバーをご利用ください';

  @override
  String get walkiePlan_detailsLockedCaps => 'ロック中';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    return '最大上限の $count 名に達しました';
  }

  @override
  String get walkiePlan_detailsMemberPlural => '名';

  @override
  String get walkiePlan_detailsMemberSingular => '名';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    return '$count名 × $rate';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    return '最小チームサイズは $count 名です';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody => 'いつでもメンバーの追加・解除が可能です。';

  @override
  String get walkiePlan_detailsMoreMembersTitle => 'さらにメンバーを追加しますか？';

  @override
  String get walkiePlan_detailsMostPopular => '一番人気';

  @override
  String get walkiePlan_detailsNetBanking => 'ネットバンキング';

  @override
  String get walkiePlan_detailsNoCouponsBody => '現在このプランで利用できるクーポンはありません。';

  @override
  String get walkiePlan_detailsNoCouponsTitle => '利用可能なクーポンはありません';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      '現在利用可能な個人プランはありません。後ほど再度ご確認ください。';

  @override
  String get walkiePlan_detailsNoPlansTitle => '利用可能なプランがありません';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      '現在利用可能なチームプランはありません。後ほど再度ご確認ください。';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '合計 $amount';
  }

  @override
  String get walkiePlan_detailsPayActivate => '支払ってプランを有効化';

  @override
  String get walkiePlan_detailsPerPerson => '/ 人';

  @override
  String get walkiePlan_detailsPillAllSizes => '規模を問わず';

  @override
  String get walkiePlan_detailsPillCommunication => 'コミュニケーション';

  @override
  String get walkiePlan_detailsPillForTeams => 'チーム向け';

  @override
  String get walkiePlan_detailsPillInstant => '即時';

  @override
  String get walkiePlan_detailsPillPriority => '優先';

  @override
  String get walkiePlan_detailsPillReliable => '高信頼＆';

  @override
  String get walkiePlan_detailsPillSecure => 'セキュア';

  @override
  String get walkiePlan_detailsPillSupport => 'サポート';

  @override
  String get walkiePlan_detailsPillUnlimited => '無制限';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'トランシーバー';

  @override
  String get walkiePlan_detailsPlanActivated => 'プランが有効化されました！';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'トランシーバープランが有効になりました。いつでも快適な音声通話をお楽しみください。';

  @override
  String get walkiePlan_detailsPlanSummary => 'プランの概要';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'プロモ ($code) 適用済み';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => '削除';

  @override
  String get walkiePlan_detailsSelectPaymentMethod => 'お支払い方法を選択';

  @override
  String get walkiePlan_detailsSkeletonCouponNote => '全プラン対象 • まもなく期限切れ';

  @override
  String get walkiePlan_detailsStep1Subtitle => '追加するチームメンバーの人数を指定してください';

  @override
  String get walkiePlan_detailsStep1Title => 'メンバー数を選択';

  @override
  String get walkiePlan_detailsStep2Subtitle => 'ご希望のプラン期間を選択してください';

  @override
  String get walkiePlan_detailsStep2Title => '利用期間を選択';

  @override
  String get walkiePlan_detailsSubtitleDefault => '即座に使えるトランシーバー音声機能';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams => '成長中のチームにおすすめ';

  @override
  String get walkiePlan_detailsSubtitleLongTerm => '長期利用に最もお得';

  @override
  String get walkiePlan_detailsSubtitleShortTerm => '短期利用に最適';

  @override
  String get walkiePlan_detailsTabIndividual => '個人';

  @override
  String get walkiePlan_detailsTabMultipleMembers => '複数メンバー';

  @override
  String get walkiePlan_detailsTabPerPerson => '1名あたり';

  @override
  String get walkiePlan_detailsTeamSubtitle => 'チームメンバーを追加し、全員でトランシーバーを利用できます';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / QRコード';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return 'このクーポンで $amount お得になります！';
  }

  @override
  String get walkiePlan_durationFallback => '期間';

  @override
  String get walkiePlan_durationMonthly => '月額';

  @override
  String walkiePlan_durationMonths(int count) {
    return '$countヶ月';
  }

  @override
  String get walkiePlan_durationQuarterly => '3ヶ月';

  @override
  String get walkiePlan_durationYearly => '年額';

  @override
  String get walkiePlan_individualPlan => '個人プラン';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return '$intervalプラン';
  }

  @override
  String get walkiePlan_monthlyPlan => '月額プラン';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'インターネットに接続されていません。ネットワークを確認してください。';

  @override
  String get walkiePlan_order100Secure => '100% 安全';

  @override
  String get walkiePlan_order3ds2Secure => '3DS2 認証対応';

  @override
  String get walkiePlan_orderAgreePrefix => '続行することで、以下に同意したものとみなされます: ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => '割引後金額';

  @override
  String get walkiePlan_orderCards => 'クレジットカード';

  @override
  String get walkiePlan_orderChangeMethod => '支払い方法を変更';

  @override
  String get walkiePlan_orderCouldNotStart => '支払いを開始できませんでした。もう一度お試しください。';

  @override
  String get walkiePlan_orderCouponApplied => 'クーポンが適用されました！';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return 'クーポンが適用されました！ $amount 割引';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'クーポンを解除しました';

  @override
  String get walkiePlan_orderCreateFailed => '支払い注文の作成に失敗しました。もう一度お試しください。';

  @override
  String get walkiePlan_orderDiscount => '割引';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return '割引 ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint => '次の画面で各種クレジットカード、決済サービスを選択できます。';

  @override
  String get walkiePlan_orderEncryptedPayment => '暗号化決済';

  @override
  String get walkiePlan_orderEnterValidCoupon => '有効なクーポンコードを入力してください';

  @override
  String get walkiePlan_orderForMultipleMembers => '複数メンバー向け';

  @override
  String get walkiePlan_orderForSingleMember => '個人向け';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return '消費税 ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      '国際ブランドカード (Visa, Mastercard, Amex) で安全に決済できます。';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      '国際クレジットカードまたは PayPal で安全にお支払いいただけます。';

  @override
  String get walkiePlan_orderInvalidCoupon => '無効または期限切れのクーポンコードです';

  @override
  String walkiePlan_orderMemberCount(int count) {
    return '$count名のメンバー';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'メンバー';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    return '$count名 × $rate';
  }

  @override
  String get walkiePlan_orderNetBanking => 'ネットバンキング';

  @override
  String get walkiePlan_orderOnlineViaRazorpay => 'Razorpay オンライン決済';

  @override
  String get walkiePlan_orderOpeningCheckout => 'Razorpay 決済画面を開いています...';

  @override
  String get walkiePlan_orderPaymentDetails => 'お支払い明細';

  @override
  String get walkiePlan_orderPaymentMethod => 'お支払い方法';

  @override
  String get walkiePlan_orderPricePerMember => 'メンバー1名あたりの料金';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return '支払いに進む • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => '決済を処理中...';

  @override
  String get walkiePlan_orderRetryPay => 'もう一度支払う';

  @override
  String get walkiePlan_orderSecureBadge => '安全';

  @override
  String get walkiePlan_orderSubtitle => 'プラン内容を確認して支払いへ進む';

  @override
  String get walkiePlan_orderSubtotal => '小計';

  @override
  String get walkiePlan_orderTaxExport => '免税 (0% 輸出)';

  @override
  String get walkiePlan_orderTermsConditions => '利用規約';

  @override
  String get walkiePlan_orderTitle => '注文の概要';

  @override
  String get walkiePlan_orderTotalAmount => '合計金額';

  @override
  String get walkiePlan_orderTotalPayable => 'お支払い合計';

  @override
  String get walkiePlan_orderUnableToLoad => '注文の概要を読み込めません。';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return '税 ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => '電子マネー/ウォレット';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return 'この注文で $amount お得になりました！';
  }

  @override
  String get walkiePlan_payAnnualPlan => '年間プラン';

  @override
  String get walkiePlan_payBadgeCompleted => '完了';

  @override
  String get walkiePlan_payBadgeInProgress => '処理中';

  @override
  String get walkiePlan_payBadgePending => '保留中';

  @override
  String get walkiePlan_payCancelledByUser =>
      '支払いがキャンセルされました。お客様の口座から引き落としは発生していません。';

  @override
  String get walkiePlan_payCouldNotBeProcessed => '決済を処理できませんでした';

  @override
  String get walkiePlan_payFailedContactSupport => 'サポートへ連絡';

  @override
  String walkiePlan_payFailedOn(String time) {
    return '$time に決済失敗';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'お支払いを完了できませんでした。\nもう一度お試しいただくか、別のお支払い方法をご利用ください。';

  @override
  String get walkiePlan_payFailedSubtitleShort => 'お支払いを完了できませんでした';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      '決済でお困りですか？サポートチームが24時間対応いたします。';

  @override
  String get walkiePlan_payFailedTitle => '決済に失敗しました';

  @override
  String get walkiePlan_payIndividualFeatures => 'リアルタイム監視 • 即時通知';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return '$time に決済開始';
  }

  @override
  String get walkiePlan_payIntervalMonth => '月';

  @override
  String get walkiePlan_payIntervalPlan => 'プラン';

  @override
  String get walkiePlan_payIntervalQuarter => '四半期';

  @override
  String get walkiePlan_payIntervalYear => '年';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'クレジットカード ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'デビットカード ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational => '国際カード / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'ネットバンキング ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'Razorpay 決済';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'Razorpay チェックアウト';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / カード)';

  @override
  String get walkiePlan_payMethodUpi => 'UPI 決済';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'ウォレット ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue => '決済中に通信エラーが発生しました。接続を確認して再試行してください。';

  @override
  String get walkiePlan_payNotCompleted => '支払いは完了しませんでした。金額は引き落とされていません。';

  @override
  String get walkiePlan_payOtpCharge => 'OTP送信料';

  @override
  String get walkiePlan_payOtpChargeDetails => 'OTP料金明細';

  @override
  String get walkiePlan_payOtpChargedPerLogin => 'ログインごとに課金されます。再送信は無料です';

  @override
  String get walkiePlan_payOtpCharges => 'OTP料金';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'アプリを閉じずにお待ちください。決済の確認およびプランの有効化が完了次第通知します。';

  @override
  String get walkiePlan_payPendingStillInProgress => '決済処理中です。確認が取れ次第反映されます。';

  @override
  String get walkiePlan_payPendingStillProcessing => '決済状況を処理中です。少々お待ちください。';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      '決済機関にてお支払いを処理中です。\n完了まで数分かかる場合があります。';

  @override
  String get walkiePlan_payPendingSubtitleShort => '決済を処理しています';

  @override
  String get walkiePlan_payPendingTitle => '決済保留中';

  @override
  String get walkiePlan_payPlanDetails => 'プラン詳細';

  @override
  String get walkiePlan_payRefreshStatus => '状態を更新';

  @override
  String get walkiePlan_payStatusTitle => '決済状況';

  @override
  String get walkiePlan_payStepActivate => 'プランを有効化';

  @override
  String get walkiePlan_payStepActivateSub => 'プランは自動的に有効化されます';

  @override
  String get walkiePlan_payStepInitiated => '決済開始';

  @override
  String get walkiePlan_payStepProcessing => '決済処理中';

  @override
  String get walkiePlan_payStepProcessingSub => '決済の確認を行っています';

  @override
  String get walkiePlan_payTeamFeatures => '複数メンバー利用 • 即時通知';

  @override
  String get walkiePlan_payTotalPerOtp => 'OTP合計';

  @override
  String get walkiePlan_payTryAgain => 'もう一度試す';

  @override
  String get walkiePlan_payViewPlanDetails => 'プラン詳細を見る';

  @override
  String get walkiePlan_perMember => 'メンバー1名あたり';

  @override
  String get walkiePlan_planFallback => 'プラン';

  @override
  String get walkiePlan_quarterlyPlan => '四半期プラン';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'Razorpay 決済ウィンドウでお支払いを完了してください。';

  @override
  String get walkiePlan_razorpayCompletePayment => '支払いを完了する';

  @override
  String get walkiePlan_razorpayConfirmingWithBank => '決済を開始しました。銀行側で承認を確認中です。';

  @override
  String get walkiePlan_razorpayConnecting => 'Razorpay に接続中...';

  @override
  String get walkiePlan_razorpayCouldNotProcess => '決済を処理できませんでした。もう一度お試しください。';

  @override
  String get walkiePlan_razorpayFailedTryAgain => '決済に失敗しました。もう一度お試しください。';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1ヶ月間有効';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return 'Razorpay で $amount を支払う';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => '決済がキャンセルされました';

  @override
  String get walkiePlan_razorpayPaymentIdCopied => '支払いIDをクリップボードにコピーしました！';

  @override
  String get walkiePlan_razorpayPciCompliant => '100% 安全・PCI-DSS 準拠';

  @override
  String get walkiePlan_razorpayPendingConfirmation => '支払いの確認待ちです。';

  @override
  String get walkiePlan_razorpayProcessing => 'Razorpay で処理中...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return '金額: $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied => '領収書情報をクリップボードにコピーしました！';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return '日付: $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return '決済方法: $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return '注文ID: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return '支払いID: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'プラン: $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => 'ステータス: 完了';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'FG Tracker お支払い領収書';

  @override
  String get walkiePlan_razorpayRetryPayment => '決済を再試行';

  @override
  String get walkiePlan_razorpaySecureCheckout => 'Razorpay 提供の安全な決済';

  @override
  String get walkiePlan_razorpaySslEncrypted => '256ビットSSL暗号化通信により安全に保護されています。';

  @override
  String get walkiePlan_razorpaySupportedModes => 'ご利用可能なお支払い方法';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => '合計お支払い金額';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return '決済ゲートウェイを起動できません: $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed => '決済の確認に失敗しました。';

  @override
  String get walkiePlan_seatAssignedSeat => '割り当て済み座席';

  @override
  String get walkiePlan_seatAssignment => '座席割り当て';

  @override
  String get walkiePlan_seatTeamAccess => 'チームアクセス';

  @override
  String get walkiePlan_seatTeamMember => 'チームメンバー';

  @override
  String get walkiePlan_secureEncryptedPayment => '安全で暗号化された決済';

  @override
  String get walkiePlan_successAccessActivated => 'アクセス権が有効化されました';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      '個人のトランシーバーアクセスが有効になりました。';

  @override
  String get walkiePlan_successAmountPaid => 'お支払い金額';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'チーム設定から後でいつでも権限を割り当てることができます。';

  @override
  String get walkiePlan_successAssignMembers => 'メンバーを割り当て';

  @override
  String get walkiePlan_successAssignWalkieAccess => 'トランシーバー権限を割り当て';

  @override
  String get walkiePlan_successChooseMembersDesc => 'トランシーバーを利用できるメンバーを指定します。';

  @override
  String get walkiePlan_successContinueHome => 'ホームへ進む';

  @override
  String get walkiePlan_successDateTime => '日時';

  @override
  String get walkiePlan_successDefaultPaymentMethod => 'Razorpay (UPI / カード)';

  @override
  String get walkiePlan_successIndividualActive => '個人プランが有効化されました';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      '個人プランが有効です。ホーム画面からすぐに通話を開始できます。';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      '個人サブスクリプションが有効化され、アカウントにリンクされました。';

  @override
  String get walkiePlan_successManageAccessNote =>
      'トランシーバー権限はチーム設定からいつでも変更できます。';

  @override
  String get walkiePlan_successMaybeLater => 'あとで';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'プランは有効です。メンバーへ割り当てを行うまで、メンバー側では利用できません。';

  @override
  String get walkiePlan_successNotNow => '今はスキップしますか？';

  @override
  String get walkiePlan_successPaid => '支払済';

  @override
  String get walkiePlan_successPaymentId => '支払いID';

  @override
  String get walkiePlan_successPaymentIdCopied => '支払いIDをコピーしました！';

  @override
  String get walkiePlan_successPaymentMode => 'お支払い方法';

  @override
  String get walkiePlan_successPaymentReceipt => '領収書';

  @override
  String get walkiePlan_successPushToTalkDesc => 'ボタンを押して話すだけで、即座に仲間へ声が届きます。';

  @override
  String get walkiePlan_successRazorpayVerified => 'Razorpay 確認済み';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return '金額: $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied => '領収書内容をコピーしました！';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return '日付: $date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'FG Tracker お支払い領収書';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return '注文ID: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return '支払いID: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return '決済方法: $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'プラン: $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => 'ステータス: 完了';

  @override
  String get walkiePlan_successSelectChannel => 'チャンネルを選択';

  @override
  String get walkiePlan_successSelectChannelDesc => 'グループやチャンネルに参加してメンバーと会話。';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'トランシーバーを使用するメンバーを選択してください。';

  @override
  String get walkiePlan_successSetUpTeam => 'チームを設定';

  @override
  String get walkiePlan_successSetUpTeamDesc => 'メンバーを招待し、役割と権限を管理します。';

  @override
  String get walkiePlan_successShareReceipt => '領収書を共有';

  @override
  String get walkiePlan_successStartCommunicating => '通話を開始する';

  @override
  String get walkiePlan_successStatus => '状態';

  @override
  String get walkiePlan_successSuccessful => '成功';

  @override
  String get walkiePlan_successTeamActive => 'チームプランが有効化されました';

  @override
  String get walkiePlan_successTeamReady => 'チームの準備が整いました！';

  @override
  String get walkiePlan_successTitle => 'ご購入が完了しました！';

  @override
  String walkiePlan_successValidTill(String date) {
    return '$date まで有効';
  }

  @override
  String get walkiePlan_successVisitHome => 'ホーム画面へ移動';

  @override
  String get walkiePlan_successWhatsNext => '次のステップ';

  @override
  String get walkiePlan_teamPlan => 'チームプラン';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'チームプラン ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => '7日間のトライアル期間';

  @override
  String get walkiePlan_trialActiveLabel => 'トライアル有効中';

  @override
  String get walkiePlan_trialActiveSubscription => '有効なサブスクリプション';

  @override
  String get walkiePlan_trialActiveSubscriptions => '有効なサブスクリプション';

  @override
  String get walkiePlan_trialAvailableToStart => '今すぐ開始可能';

  @override
  String get walkiePlan_trialCheckConnectionRetry => 'インターネット接続を確認して再試行してください。';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'トランシーバーを利用するには、以下のプランを選択してください。';

  @override
  String get walkiePlan_trialChooseSubscription =>
      '引き続きご利用いただくには、有料プランをお選びください。';

  @override
  String get walkiePlan_trialCompleted => 'トライアル完了';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    return '残り $count 日';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration 無料';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return '$date に終了';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return '$durationの間、すべてのトランシーバー機能を無料でお試しいただけます。\nお支払いは不要です。';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      '有効期間中、トランシーバー機能を自由にご利用いただけます。';

  @override
  String get walkiePlan_trialErrAccessMissing => 'アクセス権限情報が見つかりません。';

  @override
  String get walkiePlan_trialErrFetchDetails => 'トランシーバー情報を取得できません。';

  @override
  String get walkiePlan_trialErrInvalidResponse => 'サーバーから無効な応答を受信しました。';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'インターネットに接続されていません。接続を確認して再試行してください。';

  @override
  String get walkiePlan_trialErrOverviewMissing => 'トランシーバーの概要データがありません。';

  @override
  String get walkiePlan_trialErrTimeout => 'タイムアウトしました。もう一度お試しください。';

  @override
  String get walkiePlan_trialErrUnableToLoad => 'トランシーバーの詳細情報を読み込めません。';

  @override
  String get walkiePlan_trialExpired => 'トライアル期限切れ';

  @override
  String get walkiePlan_trialExpiredLabel => 'トライアル終了';

  @override
  String get walkiePlan_trialExpiringSoon => 'まもなく有効期限切れ';

  @override
  String get walkiePlan_trialFeatClearAudio => 'クリアな高音質';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'ノイズの少ないクリアな音声';

  @override
  String get walkiePlan_trialFeatGroupComm => 'グループ通話';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => 'チームと瞬時につながる';

  @override
  String get walkiePlan_trialFeatPtt => 'プッシュ・トゥ・トーク (PTT)';

  @override
  String get walkiePlan_trialFeatPttDesc => 'ボタンを押して即座に通話';

  @override
  String get walkiePlan_trialFeatUnlimited => '無制限の利用';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => '利用回数の制限なし';

  @override
  String get walkiePlan_trialFreeAvailable => '無料トライアル利用可能';

  @override
  String get walkiePlan_trialFreeTrialLabel => '無料トライアル';

  @override
  String get walkiePlan_trialFreeTrialRunning => '無料トライアル利用中';

  @override
  String get walkiePlan_trialFullAccess => 'すべての機能へのフルアクセス';

  @override
  String get walkiePlan_trialFullyConsumed => '無料トライアルの利用枠をすべて消費しました。';

  @override
  String get walkiePlan_trialHasEnded => 'トライアルが終了しました';

  @override
  String get walkiePlan_trialHeaderInstant => 'グループメンバーと即座に音声通話';

  @override
  String get walkiePlan_trialHeaderPlanStatus => '現在のプランと加入状況';

  @override
  String walkiePlan_trialHours(int count) {
    return '$count時間';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    return '残り $count 時間';
  }

  @override
  String walkiePlan_trialHr(int count) {
    return '$count時間';
  }

  @override
  String walkiePlan_trialHrMin(int hours, int minutes) {
    return '$hours時間 $minutes分';
  }

  @override
  String get walkiePlan_trialIsActive => 'トライアル期間中です';

  @override
  String walkiePlan_trialMin(int count) {
    return '$count分';
  }

  @override
  String walkiePlan_trialMinSec(int minutes, int seconds) {
    return '$minutes分 $seconds秒';
  }

  @override
  String walkiePlan_trialMinsLeft(int count) {
    return '残り $count 分';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    return '$count分';
  }

  @override
  String get walkiePlan_trialNoActivePlan => '有効なプランがありません';

  @override
  String get walkiePlan_trialNoCardRequired => '7日間いつでも利用可能  •  クレジットカード登録不要';

  @override
  String get walkiePlan_trialNoInternetTitle => 'インターネット未接続';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return '今すぐのお支払いは不要です。試用終了後、有料プラン ($price/人) へ移行するかご選択いただけます。';
  }

  @override
  String get walkiePlan_trialPeriodMonth => '月';

  @override
  String get walkiePlan_trialRetrying => '再試行中...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count秒';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return '$duration 無料トライアルを開始';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial => '無料トライアルを開始';

  @override
  String get walkiePlan_trialStatusCompleted => '完了';

  @override
  String get walkiePlan_trialStatusExpired => '期限切れ';

  @override
  String get walkiePlan_trialSubscriptionActive => 'サブスクリプション有効中';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'サブスクリプションが終了しました。継続して会話するには更新してください。';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'サブスクリプション期限切れ';

  @override
  String get walkiePlan_trialTalkFree => 'グループメンバーと無料で通話。';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return '$date までグループメンバーと無料で通話できます。';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg => 'チームプランによりトランシーバーをご利用いただけます。';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return '残り $time';
  }

  @override
  String get walkiePlan_trialTimeRemaining => '残りトライアル時間';

  @override
  String get walkiePlan_trialTimeUsedUp => '試用時間を使い切りました';

  @override
  String get walkiePlan_trialTryAgain => 'もう一度試す';

  @override
  String get walkiePlan_trialUnableToLoadTitle => 'トランシーバーを読み込めません';

  @override
  String get walkiePlan_trialUsage => '試用実績';

  @override
  String get walkiePlan_trialUseAnytime7Days => '7日間いつでもご利用可能';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return '7日以内ならいつでも $duration の無料試用をご利用いただけます。';
  }

  @override
  String get walkiePlan_trialUsed => 'トライアル使用済み';

  @override
  String get walkiePlan_trialValidityPeriod => 'トライアル有効期間';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'トランシーバー';

  @override
  String get walkiePlan_trialWhatYouCanDo => '試用期間中に利用できること';

  @override
  String get walkiePlan_unableToConnect => 'サーバーに接続できません。もう一度お試しください。';

  @override
  String get walkiePlan_yearlyPlan => '年額プラン';

  @override
  String get walkie_aMember => 'メンバー';

  @override
  String get walkie_accept => '応答';

  @override
  String get walkie_activeAccess => '有効なアクセス権';

  @override
  String get walkie_activeBadge => 'アクティブ';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count名が通信中',
      one: '1名が通信中',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'アクティブメンバー';

  @override
  String get walkie_admin => '管理者';

  @override
  String get walkie_adminMuted => '管理者 • ミュート中';

  @override
  String get walkie_adminOnlyAction => '管理者専用のアクション';

  @override
  String get walkie_adminOnlyActionMessage => 'メンバーへの通知アラート送信はグループ管理者のみが行えます。';

  @override
  String walkie_alertSentMessage(String name) {
    return '$nameに通知を送信しました。10秒後に再試行できます。';
  }

  @override
  String get walkie_alertSentTitle => 'アラートを送信しました';

  @override
  String get walkie_assignMembersToCommunicate => 'このグループで通話するメンバーを割り当ててください';

  @override
  String get walkie_assignedByYou => 'あなたが割り当てました';

  @override
  String walkie_assignedCount(int count) {
    return '$count名割り当て済み';
  }

  @override
  String get walkie_assignedSeats => '割り当て済みシート';

  @override
  String get walkie_audioBluetooth => 'Bluetooth';

  @override
  String get walkie_audioHeadset => 'ヘッドセット';

  @override
  String get walkie_audioOutput => '音声出力';

  @override
  String get walkie_audioPhone => '電話';

  @override
  String get walkie_audioSpeaker => 'スピーカー';

  @override
  String get walkie_audioWiredHeadphones => '有線ヘッドホン';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return '$seconds秒後に自動ロック解除';
  }

  @override
  String get walkie_availableMembers => '利用可能なメンバー';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'このグループで最大$count名を割り当て可能',
      one: 'このグループで最大1名を割り当て可能',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat => '他の管理者によって割り当てられたシートは削除できません';

  @override
  String get walkie_cannotSpeak => 'このチャンネルでは発言できません';

  @override
  String get walkie_channelBusy => 'チャンネルが通話中です';

  @override
  String get walkie_channelLocked => 'チャンネルがロックされました';

  @override
  String get walkie_channelSpeaking => 'チャンネル通話中...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return '$groupをアクティブな通話チャンネルに設定できませんでした。';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'チャンネル切り替えエラー';

  @override
  String get walkie_channelUnlocked => 'チャンネルのロックが解除されました';

  @override
  String get walkie_chat => 'チャット';

  @override
  String get walkie_checkNetworkTryAgain => 'ネットワーク接続を確認してもう一度お試しください。';

  @override
  String get walkie_chooseAPlan => 'プランを選択';

  @override
  String get walkie_connected => '接続済み';

  @override
  String get walkie_connectedWaiting => 'チャンネルに接続しました • 他のメンバーの参加を待機中';

  @override
  String get walkie_connectingChannel => 'チャンネルに接続中...';

  @override
  String get walkie_consumingTrial => 'トライアルを適用中...';

  @override
  String get walkie_continueListenOnly => '受話専用モードで続行';

  @override
  String walkie_currentlyAssigned(int count) {
    return '現在割り当て中 ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'トランシーバーグループ';

  @override
  String get walkie_description => '説明';

  @override
  String get walkie_disconnected => '切断されました';

  @override
  String get walkie_editAssignedMembers => '割り当てメンバーを編集';

  @override
  String get walkie_enable => '有効にする';

  @override
  String walkie_errorWithDetails(String details) {
    return 'エラー: $details';
  }

  @override
  String get walkie_exitWalkie => 'トランシーバーを退出';

  @override
  String get walkie_exitWalkieMessage =>
      'このトランシーバーチャンネルから切断されます。グループのメンバーシップは維持されます。';

  @override
  String get walkie_exitWalkieTitle => 'トランシーバーを終了しますか？';

  @override
  String get walkie_fairConnection => '普通の接続';

  @override
  String walkie_fairConnectionMs(int ms) {
    return '普通の接続 (${ms}ms)';
  }

  @override
  String get walkie_featureAllDevices => 'すべての端末で使用可能';

  @override
  String get walkie_featureEasyCoordination => '円滑なグループ連携';

  @override
  String get walkie_featureHoldToTalk => '長押しして通話';

  @override
  String get walkie_featurePtt => 'プッシュツートーク';

  @override
  String get walkie_featureQuickGroup => '迅速なグループ通信';

  @override
  String get walkie_featureRealtime => 'リアルタイム接続';

  @override
  String get walkie_featureSafeReliable => '安全で信頼性が高い';

  @override
  String get walkie_featureStayConnected => 'いつでもつながる';

  @override
  String get walkie_featureTeamCommunication => 'チーム通信';

  @override
  String get walkie_featureUnlimited => '無制限';

  @override
  String get walkie_fieldTeam => 'フィールドチーム';

  @override
  String get walkie_freeTrialEnded => '無料トライアルが終了しました';

  @override
  String get walkie_freeTrialEndedMessage =>
      'トランシーバーの1時間無料トライアルが終了しました。\nチームとのグループ通信を継続するには今すぐアップグレードしてください。';

  @override
  String get walkie_freeTrialEndedTitle => '無料トライアル終了';

  @override
  String get walkie_genericError => 'トランシーバーエラー';

  @override
  String get walkie_getPlan => 'プランを取得';

  @override
  String walkie_goodConnectionMs(int ms) {
    return '安定した接続 (${ms}ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'グループコード: $code';
  }

  @override
  String get walkie_groupCommunication => 'グループ通信';

  @override
  String get walkie_groupFallback => 'グループ';

  @override
  String get walkie_groupMembers => 'グループメンバー';

  @override
  String get walkie_heroSubtitle => '電話をかけずにグループメンバーとプッシュツートーク音声通信を利用できます。';

  @override
  String get walkie_heroTitle => '常時接続、即座に通話';

  @override
  String get walkie_holdToTalk => '長押しして通話';

  @override
  String get walkie_holdToTalkSlideLock => '長押しで通話、上にスライドでロック';

  @override
  String get walkie_inWalkieChannel => 'トランシーバーチャンネル内';

  @override
  String get walkie_individualActiveUpgrade =>
      '個人プランが有効（個人のみ利用可能）• メンバーを割り当てるにはチームプランへアップグレード。';

  @override
  String get walkie_individualLimitMessage =>
      '個人プランでは1席のみ許可されています。複数のメンバーを割り当ててチーム全体をつなぐには、チームプランにアップグレードしてください。';

  @override
  String get walkie_individualPlan => '個人プラン';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (個人)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      '個人プラン（本人のみ利用可能）• メンバーを割り当てるにはチームにアップグレード';

  @override
  String get walkie_individualSubscribedSelf => '個人プラン • 本人契約';

  @override
  String get walkie_info => '情報';

  @override
  String walkie_isSpeaking(String name) {
    return '$nameが話しています...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$nameが話しています...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count名参加',
      one: '1名参加',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return '最終オンライン $time';
  }

  @override
  String get walkie_listenOnly => '受話のみ';

  @override
  String get walkie_listenOnlyTapPlan => '受話専用 — タップしてプランを確認';

  @override
  String get walkie_listening => '受信中';

  @override
  String get walkie_listeningOnly => '受話のみ';

  @override
  String get walkie_live => 'LIVE';

  @override
  String get walkie_lockTimeout => 'ロックがタイムアウトしました — マイクを解放しました';

  @override
  String get walkie_lockedTapMic => 'ロック中 — マイクをタップして停止';

  @override
  String get walkie_maybeLater => '後で';

  @override
  String get walkie_member => 'メンバー';

  @override
  String get walkie_membersInChannel => 'チャンネル内のメンバー';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'オンラインメンバー',
      one: 'オンラインメンバー',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed => '割り当てメンバーの更新に失敗しました';

  @override
  String get walkie_membersUpdated => '割り当てメンバーを更新しました';

  @override
  String get walkie_micAccessRequired => '通話にはマイクへのアクセス権が必要です。';

  @override
  String get walkie_micDisabledMessage =>
      '端末の設定でマイクへのアクセスが無効になっています。このグループで発言するには、設定でマイクへのアクセスを許可してください。\n\n他のメンバーの音声を聴くことは引き続き可能です。';

  @override
  String get walkie_micPermissionRequired => 'マイクの権限が必要です';

  @override
  String get walkie_micPermissionTitle => 'マイクの権限';

  @override
  String get walkie_micRequiredMessage =>
      'このトランシーバーグループで発言するにはマイクの権限が必要です。\n\nマイクを有効にしなくても、他のメンバーの音声を聴くことはできます。';

  @override
  String get walkie_muteMe => '自分をミュート';

  @override
  String get walkie_muted => 'ミュート中';

  @override
  String get walkie_mutedInWalkie => 'ミュート中 • トランシーバー内';

  @override
  String get walkie_mutedListeningOnly => 'ミュート中 — 受話専用';

  @override
  String walkie_nameSpeaking(String name) {
    return '$nameが話しています...';
  }

  @override
  String get walkie_noActivePlan => '有効なプランがありません';

  @override
  String get walkie_noAvailableMembers => '利用可能なメンバーはいません';

  @override
  String get walkie_noBluetoothDevice =>
      'Bluetoothオーディオ機器が接続されていません。設定からペアリングしてください。';

  @override
  String get walkie_noGroupsFound => 'グループが見つかりません';

  @override
  String get walkie_noMembersAssigned => '現在割り当てられているメンバーはいません';

  @override
  String get walkie_noMembersFound => 'メンバーが見つかりません';

  @override
  String get walkie_noMembersFoundTitle => 'メンバーが見つかりません';

  @override
  String get walkie_noMembersMatch => '一致するメンバーがいません';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return '「$query」に一致するメンバーはいません';
  }

  @override
  String get walkie_noMembersToAssign => '割り当て可能なグループメンバーがいません。';

  @override
  String get walkie_noNameGroup => '名称未設定グループ';

  @override
  String get walkie_noPlanSubscribeAssign => '有効なプランがありません • 定期購入してメンバーを割り当て';

  @override
  String get walkie_noSeatMessage =>
      '有効なチームプランがありますが、現在すべての音声シートが他のメンバーに割り当てられています。\n\n会話をリアルタイムで聴くことはできますが、発言するにはシートをご自身に割り当てるかプランをアップグレードしてください。';

  @override
  String get walkie_noSeatTitle => '音声シートが割り当てられていません';

  @override
  String get walkie_noSeatsRefreshing => '利用可能なチームシートがありません。リストを更新しています...';

  @override
  String get walkie_noSubscriptionMessage =>
      '有効なトランシーバーの定期購入がありません。プランに登録してメンバーを割り当て、即時音声通信を開始してください。';

  @override
  String get walkie_noTeamSubscription => '有効なチーム定期購入が見つかりません';

  @override
  String get walkie_noValidMembers => '割り当て可能な有効なメンバーが選択されていません';

  @override
  String get walkie_noVoiceSeatListenOnly => '音声シートが割り当てられていません — 受話専用モードです';

  @override
  String get walkie_noWiredDevice => '有線イヤホンが接続されていません。端末に接続してください。';

  @override
  String get walkie_notConnected => '未接続';

  @override
  String get walkie_notifLeave => '退出';

  @override
  String get walkie_notifOpenWalkie => 'トランシーバーを開く';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$nameが発言を終了しました';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$nameが話しています';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return '$groupの通知設定を更新できませんでした。もう一度お試しください。';
  }

  @override
  String get walkie_notificationSettingTitle => '通知設定';

  @override
  String get walkie_onlyAdminCanAlert => 'アラートを送信できるのはグループ管理者のみです';

  @override
  String get walkie_openWalkieTalkie => 'トランシーバーを開く';

  @override
  String get walkie_otherTeam => '他のチーム';

  @override
  String get walkie_othersWontHear => '他の人にはあなたの声が聞こえません';

  @override
  String get walkie_planRequiredTitle => 'トランシーバープランが必要です';

  @override
  String get walkie_planRequiredToTalk => '発言にはプランが必要です';

  @override
  String get walkie_planStartsOnFirstAssign => '最初のメンバーが割り当てられた時点でプランが開始されます。';

  @override
  String get walkie_poorConnection => '通信状態が不安定です — 音声に遅延が発生する可能性があります';

  @override
  String get walkie_preparingAudio => '音声を準備中...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'メンバーにトランシーバー利用権を割り当てるにはチームプランをご購入ください。';

  @override
  String get walkie_purchaseUpgradePlan => 'プランを購入 / アップグレード';

  @override
  String get walkie_ready => '準備完了';

  @override
  String get walkie_reconnecting => '再接続中...';

  @override
  String get walkie_reconnectingServer => 'トランシーバーサーバーに再接続中...';

  @override
  String get walkie_releaseToStop => '離して停止';

  @override
  String get walkie_removeAll => 'すべて削除';

  @override
  String get walkie_searchGroups => 'グループを検索';

  @override
  String get walkie_searchMembers => 'メンバーを検索...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total 席';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '合計 $total 席 • 割り当て済み $assigned • 利用可能 $available';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '$assigned / $total 席使用中';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds秒';
  }

  @override
  String get walkie_selectAtLeastOne => '割り当てるメンバーを少なくとも1名選択してください';

  @override
  String get walkie_selectGroupFirst => '先にグループを選択してください';

  @override
  String get walkie_selectGroupToConnect => '接続するグループを選択してください';

  @override
  String get walkie_selected => '選択済み';

  @override
  String get walkie_selfAccess => '本人アクセス';

  @override
  String get walkie_selfPlan => '自身のプラン';

  @override
  String get walkie_slideUpToLock => '上にスライドしてロック';

  @override
  String get walkie_someone => '誰か';

  @override
  String get walkie_someoneSpeaking => '誰かが話しています...';

  @override
  String get walkie_speaking => '通話中...';

  @override
  String walkie_startFreeTrial(String duration) {
    return '$duration無料トライアルを開始';
  }

  @override
  String get walkie_strongConnection => '強力な接続';

  @override
  String walkie_strongConnectionMs(int ms) {
    return '良好な接続 (${ms}ms)';
  }

  @override
  String get walkie_subscribeToStartTalk => '定期購入して音声通話とメンバー割り当てを開始';

  @override
  String get walkie_subscribed => 'サブスクリプション登録済み';

  @override
  String get walkie_talking => '通話中...';

  @override
  String get walkie_tapToUnlock => 'タップしてロック解除';

  @override
  String get walkie_teamAssignedElsewhere => 'チームプラン • 他で割り当て済み';

  @override
  String get walkie_teamPlan => 'チームプラン';

  @override
  String get walkie_teamPlanRequired => 'チームプランが必要です';

  @override
  String get walkie_teamPlanRequiredToAssign => 'メンバーを割り当てるにはチームプランが必要です';

  @override
  String get walkie_teamPlanStatus => 'チームプランのステータス';

  @override
  String get walkie_teamSeatMember => 'チームシートメンバー';

  @override
  String get walkie_title => 'トランシーバー';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '合計 $count名',
      one: '合計 1名',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => '1時間トライアル有効';

  @override
  String get walkie_trialEndedSubscribe =>
      '無料トライアルが終了しました — 継続するにはサブスクリプションに登録してください';

  @override
  String get walkie_unableToConnectReconnecting => 'チャンネルに接続できません — 再接続中...';

  @override
  String get walkie_unavailable => '利用不可';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'メンバーを更新 ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'メンバーを更新中...';

  @override
  String get walkie_upgradeAddSeats => 'アップグレードしてシートを追加';

  @override
  String get walkie_upgradeNow => '今すぐアップグレード';

  @override
  String get walkie_upgradeTeamAssign => 'チームプランにアップグレード（メンバーを割り当て）';

  @override
  String get walkie_upgradeToTeamPlan => 'チームプランにアップグレード';

  @override
  String walkie_userCancelled(String name) {
    return '$nameがキャンセルしました';
  }

  @override
  String walkie_userJoined(String name) {
    return '$nameが参加しました';
  }

  @override
  String walkie_userLeft(String name) {
    return '$nameが退出しました';
  }

  @override
  String walkie_validTill(String date) {
    return '$dateまで有効';
  }

  @override
  String get walkie_viewPlan => 'プランを表示';

  @override
  String get walkie_voiceNotPermitted => '音声送信が許可されていません';

  @override
  String get walkie_weakSignal => '微弱な信号';

  @override
  String walkie_weakSignalMs(int ms) {
    return '微弱な信号 (${ms}ms)';
  }

  @override
  String get walkie_youAreConnected => '接続しています';

  @override
  String get walkie_yourVoiceAccess => 'あなたの音声アクセス権';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Android版ダウンロード: $playStoreLink\n\niOS版ダウンロード: $appStoreLink';
  }

  @override
  String get widget_live => 'ライブ';

  @override
  String get widget_lostConnection => '接続が切断されました';

  @override
  String get widget_manageGroups => 'グループを簡単に管理';

  @override
  String get widget_noInternetBody => 'おっと... インターネット接続がありません。接続を確認してください';

  @override
  String get widget_notSeenYet => '未読';

  @override
  String get widget_pinnedMessage => '固定メッセージ';

  @override
  String get widget_private => 'プライベート';

  @override
  String get widget_refreshPage => 'ページを更新する';

  @override
  String get widget_seen => '既読';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count / $total)';
  }

  @override
  String get widget_somethingWentWrongTitle => '問題が発生しました';

  @override
  String get widget_userFallback => 'ユーザー';
}
