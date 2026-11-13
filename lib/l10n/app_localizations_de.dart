// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about_aboutUs => 'Über uns';

  @override
  String get about_address => 'Adresse';

  @override
  String get about_appBarTitle => 'Über FG Tracker';

  @override
  String get about_company => 'Unternehmen';

  @override
  String get about_contactUs => 'Kontaktieren Sie uns';

  @override
  String get about_developerEmail => 'Entwickler-E-Mail';

  @override
  String get about_downloadTitle => '📱 App herunterladen';

  @override
  String get about_howItWorksIntro =>
      'FG Tracker vereinfacht die Gruppenkoordination beim Reisen. So geht’s:';

  @override
  String get about_howItWorksTitle => '⚙️ Wie es funktioniert';

  @override
  String get about_howStep1 => 'Erstellen Sie eine Gruppe';

  @override
  String get about_howStep2 =>
      'Teilen Sie den Gruppencode oder QR-Code mit Ihren Begleitern';

  @override
  String get about_howStep3 =>
      'Jedes Mitglied tritt über den geteilten Code oder QR-Code bei';

  @override
  String get about_howStep4 =>
      'Verfolgen Sie den Live-Standort aller Personen in Echtzeit auf einer geteilten Karte';

  @override
  String get about_howStep5 =>
      'Nutzen Sie die Freigabefunktion, um mühelos weitere Personen einzuladen';

  @override
  String get about_intro =>
      'FG Tracker ist Ihr verlässlicher Begleiter, um bei Gruppenreisen verbunden und geschützt zu bleiben. Ob Familienausflug, Picknick mit Freunden oder Fahrgemeinschaft mit Kollegen – FG Tracker stellt sicher, dass niemand zurückbleibt.';

  @override
  String get about_privacyBody =>
      'Ihre Sicherheit und Privatsphäre sind uns wichtig. FG Tracker teilt Ihren Standort mit niemandem außerhalb Ihrer Gruppe. Alle Daten sind verschlüsselt und werden nur mit autorisierten Personen geteilt.';

  @override
  String get about_privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get about_privacyTitle => '🔐 Datenschutz & Sicherheit';

  @override
  String get about_supportEmail => 'Support-E-Mail';

  @override
  String get about_supportTitle => '📩 Support & Entwickler-Info';

  @override
  String get about_termsConditions => 'Allgemeine Geschäftsbedingungen';

  @override
  String get about_title => 'Über uns';

  @override
  String get about_website => 'Website';

  @override
  String get about_welcomeTitle => 'Willkommen bei FG Tracker';

  @override
  String get about_whyBuiltFor =>
      'Entwickelt für Familien, Freunde und kleine Teams.';

  @override
  String get about_whyChooseTitle => '🌟 Warum FG Tracker wählen?';

  @override
  String get about_whyEasy =>
      'Einfach zu bedienen, leichtgewichtig und mit Datenschutzkontrolle.';

  @override
  String get about_whyNoCalls =>
      'Kein Anrufen oder Schreiben nötig – live auf der Karte verfolgen.';

  @override
  String get about_whyRealTime =>
      'Echtzeit-Standortfreigabe mit allen Gruppenmitgliedern.';

  @override
  String appUpdate_checkError(String error) {
    return 'Fehler beim Suchen nach Updates: $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => 'Möchten Sie beenden?';

  @override
  String get appUpdate_noUpdateAvailable => 'Kein Update verfügbar';

  @override
  String get appUpdate_restartApp => 'App neu starten';

  @override
  String get appUpdate_updateApp => 'App aktualisieren';

  @override
  String get appUpdate_updateAvailable => 'Update verfügbar';

  @override
  String get appUpdate_updateAvailableMessage =>
      'Ein neues Update ist verfügbar. Bitte aktualisieren Sie die App';

  @override
  String get appUpdate_updateUnavailable => 'Update nicht verfügbar';

  @override
  String appUpdate_updatingProgress(int progress) {
    return 'Wird aktualisiert... $progress%';
  }

  @override
  String get attendance_addOption => 'Weitere Option hinzufügen';

  @override
  String get attendance_admin => 'Admin';

  @override
  String get attendance_allowChange => 'Antwortänderung erlauben';

  @override
  String get attendance_allowChangeSubtitle =>
      'Mitglieder können ihre Antwort ändern oder entfernen';

  @override
  String get attendance_askCommunity => 'Frage deine Community';

  @override
  String get attendance_cameraPermissionRequired =>
      'Kameraberechtigung zur Erfassung der Anwesenheit erforderlich.';

  @override
  String get attendance_cameraStartFailed =>
      'Kamera konnte nicht gestartet werden.';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'Kamera konnte nicht gestartet werden ($code).';
  }

  @override
  String get attendance_cameraStarting => 'Kamera startet…';

  @override
  String get attendance_captureFailedBlink =>
      'Konnte nicht erfassen. Erneut blinzeln';

  @override
  String attendance_capturedAtVerified(String time) {
    return 'Aufgenommen um $time • Verifiziert';
  }

  @override
  String get attendance_capturedCheck => 'Erfasst ✓';

  @override
  String get attendance_changeResponse => 'Antwort ändern';

  @override
  String get attendance_chooseFolder => 'Ordner wählen (z.B. Downloads)';

  @override
  String get attendance_closeAction => 'Anwesenheit schließen';

  @override
  String get attendance_closeConfirmBody =>
      'Mitglieder können nach dem Schließen nicht mehr antworten.';

  @override
  String get attendance_closeConfirmTitle => 'Anwesenheit schließen?';

  @override
  String get attendance_closeEndOfDay => 'Am Ende des Tages schließen';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return 'Schließt heute automatisch um $time';
  }

  @override
  String get attendance_closeFailed =>
      'Anwesenheit konnte nicht geschlossen werden';

  @override
  String get attendance_closeFailedShort => 'Konnte nicht geschlossen werden';

  @override
  String attendance_closesAt(String dateTime) {
    return 'Schließt am $dateTime';
  }

  @override
  String get attendance_createFailed =>
      'Anwesenheit konnte nicht erstellt werden';

  @override
  String get attendance_createSubtitle =>
      'Eine Anwesenheitsumfrage an diese Gruppe senden';

  @override
  String get attendance_createTitle => 'Anwesenheit erstellen';

  @override
  String get attendance_created => 'Anwesenheit erstellt';

  @override
  String get attendance_dateEnded =>
      'Das ausgewählte Datum ist bereits abgelaufen.';

  @override
  String get attendance_dateToday => 'Datum (heute)';

  @override
  String get attendance_dateTodaySemantics => 'Anwesenheitsdatum, heute';

  @override
  String get attendance_deleteFailed =>
      'Anwesenheit konnte nicht gelöscht werden';

  @override
  String get attendance_deletedText => 'Diese Anwesenheit wurde gelöscht';

  @override
  String get attendance_downloadReport => 'Bericht herunterladen';

  @override
  String get attendance_everyoneResponded => 'Alle haben geantwortet';

  @override
  String get attendance_faceDetectedBlink => 'Gesicht erkannt — jetzt blinzeln';

  @override
  String get attendance_failed => 'Anwesenheit fehlgeschlagen';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return 'Nicht geantwortet ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return 'Geantwortet ($count)';
  }

  @override
  String get attendance_fixErrors =>
      'Bitte markierte Fehler vor dem Absenden korrigieren';

  @override
  String get attendance_holdStill => 'Stillhalten…';

  @override
  String get attendance_howToTakePhoto => 'So nimmst du dein Foto auf';

  @override
  String get attendance_invalidGroup =>
      'Ungültige Gruppe. Bitte Chat erneut öffnen.';

  @override
  String get attendance_keepFaceInCircle => 'Halte dein Gesicht im Kreis';

  @override
  String get attendance_limitReached => 'Limit erreicht';

  @override
  String get attendance_loadFailed => 'Anwesenheit konnte nicht geladen werden';

  @override
  String get attendance_loadMore => 'Mehr laden';

  @override
  String get attendance_loadMoreFailed => 'Konnte nicht mehr laden';

  @override
  String get attendance_loadVotersFailed =>
      'Wähler konnten nicht geladen werden';

  @override
  String get attendance_lookAtCamera => 'Schau in die Kamera';

  @override
  String get attendance_lookStraight => 'Schau geradeaus in die Kamera';

  @override
  String get attendance_markYourAttendance => 'Erfasse deine Anwesenheit';

  @override
  String attendance_markedAs(String option) {
    return 'Als $option markiert';
  }

  @override
  String get attendance_markedSuccess => 'Anwesenheit erfolgreich erfasst';

  @override
  String attendance_maxOptions(int count) {
    return 'Du kannst nur bis zu $count Optionen hinzufügen';
  }

  @override
  String get attendance_members => 'Mitglieder';

  @override
  String attendance_membersWithCount(int count) {
    return 'Mitglieder ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return 'Mindestens $count Optionen sind erforderlich';
  }

  @override
  String get attendance_moveCloser => 'Gehe etwas näher heran';

  @override
  String get attendance_multipleFaces =>
      'Mehrere Gesichter erkannt — bitte nur du im Bild';

  @override
  String get attendance_noCsvApp =>
      'Keine App zum Öffnen von CSV-Dateien gefunden. Bitte Speichern oder Teilen nutzen.';

  @override
  String get attendance_noFace => 'Kein Gesicht erkannt';

  @override
  String get attendance_noFrontCamera =>
      'Keine Frontkamera auf diesem Gerät gefunden.';

  @override
  String get attendance_noLocation => 'Kein Standort verfügbar';

  @override
  String get attendance_noMembersMatch => 'Keine passenden Mitglieder gefunden';

  @override
  String get attendance_noResponses => 'Noch keine Antworten';

  @override
  String get attendance_notResponded => 'Nicht geantwortet';

  @override
  String get attendance_openEyes => 'Öffne die Augen und schau in die Kamera';

  @override
  String get attendance_openMapFailed => 'Karte konnte nicht geöffnet werden';

  @override
  String get attendance_openSubtitle =>
      'In Excel, Sheets oder anderer App öffnen';

  @override
  String get attendance_optionHint => 'Optionsbezeichnung eingeben';

  @override
  String get attendance_optionLabelRequired =>
      'Alle Optionen müssen eine Bezeichnung haben';

  @override
  String attendance_optionNumber(int number) {
    return 'Option $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return 'Option $number • 📷 Foto erforderlich';
  }

  @override
  String get attendance_optionsUnique => 'Optionen müssen eindeutig sein';

  @override
  String get attendance_photoCaptured => 'Foto aufgenommen';

  @override
  String get attendance_photoCapturedTapRetake =>
      'Foto aufgenommen ✓ (Tippen zum Wiederholen)';

  @override
  String get attendance_photoProof => 'Fotonachweis';

  @override
  String attendance_photoProofOf(String name) {
    return 'Fotonachweis von $name';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ Foto erforderlich für $option';
  }

  @override
  String get attendance_photoRules =>
      'Nur die Frontkamera wird genutzt. Das Foto wird automatisch beim Blinzeln aufgenommen, Galerie-Uploads sind nicht erlaubt.';

  @override
  String get attendance_photoSubtitle =>
      'Mache ein Live-Foto zur Anwesenheitsüberprüfung';

  @override
  String get attendance_photoTitle => 'Anwesenheitsfoto';

  @override
  String get attendance_photoVerified => 'Foto verifiziert';

  @override
  String get attendance_questionHint => 'Bist du heute verfügbar?';

  @override
  String get attendance_questionLabel => 'Anwesenheitsfrage';

  @override
  String get attendance_questionRequired =>
      'Anwesenheitsfrage ist erforderlich';

  @override
  String attendance_questionTooShort(int count) {
    return 'Frage muss mindestens $count Zeichen lang sein';
  }

  @override
  String get attendance_removeFailedShort => 'Konnte nicht entfernt werden';

  @override
  String get attendance_removeResponseBody =>
      'Deine Anwesenheit für diese Umfrage wird gelöscht.';

  @override
  String get attendance_removeResponseTitle => 'Deine Antwort entfernen?';

  @override
  String get attendance_removeVoteFailed =>
      'Stimme konnte nicht entfernt werden';

  @override
  String get attendance_reportEmpty => 'Der Bericht ist leer';

  @override
  String get attendance_reportFailed => 'Bericht fehlgeschlagen';

  @override
  String get attendance_reportInvalid =>
      'Der Server hat einen ungültigen Bericht zurückgegeben.';

  @override
  String attendance_reportReady(String fileName) {
    return 'Bericht bereit • $fileName';
  }

  @override
  String get attendance_reportSaved => 'Bericht gespeichert';

  @override
  String get attendance_reportSubject => 'Anwesenheitsbericht';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return 'Anwesenheitsbericht • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count haben geantwortet';
  }

  @override
  String get attendance_retakePhoto => 'Foto wiederholen';

  @override
  String get attendance_saveInFiles => 'In Datei-App speichern';

  @override
  String get attendance_saveReportDialog => 'Anwesenheitsbericht speichern';

  @override
  String get attendance_saveToDevice => 'Auf Gerät speichern';

  @override
  String get attendance_searchMember => 'Mitglied suchen';

  @override
  String get attendance_selectPhotoOption =>
      'Option auswählen, die ein Live-Foto erfordert';

  @override
  String get attendance_selectStatus => 'Bitte wähle deinen Status';

  @override
  String get attendance_sentToAllMembers =>
      'An alle Gruppenmitglieder gesendet';

  @override
  String get attendance_sentToGroup => 'Anwesenheit an die Gruppe gesendet';

  @override
  String get attendance_shareSubtitle => 'Über WhatsApp, E-Mail senden...';

  @override
  String get attendance_statusCompleted => 'Abgeschlossen';

  @override
  String get attendance_statusOpen => 'Offen';

  @override
  String get attendance_stepBlink => 'Blinzle, um dein Foto aufzunehmen';

  @override
  String get attendance_stepEyeLevel => 'Halte dein Smartphone auf Augenhöhe';

  @override
  String get attendance_submit => 'Anwesenheit absenden';

  @override
  String get attendance_submitted => 'Anwesenheit übermittelt';

  @override
  String get attendance_title => 'Anwesenheit';

  @override
  String get attendance_update => 'Anwesenheit aktualisieren';

  @override
  String get attendance_validationError => 'Validierungsfehler';

  @override
  String get attendance_view => 'Anzeigen';

  @override
  String get attendance_viewTitle => 'Anwesenheit anzeigen';

  @override
  String get attendance_voteFailed => 'Stimme konnte nicht erfasst werden';

  @override
  String attendance_withinKm(String km) {
    return 'Innerhalb von $km km';
  }

  @override
  String attendance_withinMeters(int count) {
    return 'Innerhalb von $count m';
  }

  @override
  String get call_accept => 'Annehmen';

  @override
  String get call_allContacts => 'Alle Kontakte';

  @override
  String get call_allowAccess => 'Zugriff erlauben';

  @override
  String get call_answer => 'Antworten';

  @override
  String get call_audioOutput => 'Audioausgabe';

  @override
  String get call_callFrom => 'Anruf von';

  @override
  String get call_callIdNotFound => 'Anruf-ID nicht gefunden';

  @override
  String get call_callInformation => 'Anrufinformationen';

  @override
  String get call_callSummary => 'Anrufzusammenfassung';

  @override
  String get call_caller => 'Anrufer';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name und $count weitere',
      one: '$name und 1 weiterer',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Anrufe konnten nicht gelöscht werden. Bitte erneut versuchen.',
      one: '1 Anruf konnte nicht gelöscht werden. Bitte erneut versuchen.',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Anrufe gelöscht',
      one: '1 Anruf gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'Kamera';

  @override
  String get call_cameraMicRequired =>
      'Kamera- oder Mikrofonberechtigungen erforderlich';

  @override
  String get call_cameraOff => 'Kamera aus';

  @override
  String get call_cameraOn => 'Kamera an';

  @override
  String get call_cameraUnavailable =>
      'Kamerazugriff ist derzeit nicht verfügbar. Bitte später erneut versuchen.';

  @override
  String get call_cannotReachCallServer =>
      'Verbindung zum Anrufserver fehlgeschlagen. Bitte Netzwerk prüfen.';

  @override
  String get call_chatFallback => 'Chat';

  @override
  String get call_closeFullScreen => 'Vollbild schließen';

  @override
  String get call_communicationUnavailable =>
      'Kommunikation mit diesem Benutzer nicht verfügbar';

  @override
  String get call_connectingProgress => 'Verbindet…';

  @override
  String get call_connectionTimeout => 'Verbindungszeitüberschreitung';

  @override
  String get call_contactInformation => 'Kontaktinformationen';

  @override
  String get call_contactsAccessBannerMessage =>
      'Finde und rufe deine Teammitglieder einfach an.';

  @override
  String get call_contactsAccessBannerTitle =>
      'Erlaube uns den Zugriff auf deine Kontakte';

  @override
  String get call_contactsAccessMessage =>
      'Wir benötigen Zugriff auf deine Kontakte, um zu sehen, wer FG Tracker nutzt, und damit du sie anrufen oder einladen kannst.';

  @override
  String get call_contactsAccessTitle => 'Kontaktzugriff erlauben';

  @override
  String get call_decline => 'Ablehnen';

  @override
  String get call_deleteCallsMessage =>
      'Diese Anrufe werden aus deinem Verlauf entfernt.';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Anrufe löschen?',
      one: '1 Anruf löschen?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage =>
      'Möchtest du diesen Anrufverlauf wirklich löschen?';

  @override
  String get call_deleteHistoryTitle => 'Anrufverlauf löschen';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Möchtest du diese $count ausgewählten Anrufeinträge wirklich löschen?',
      one: 'Möchtest du diesen ausgewählten Anrufverlauf wirklich löschen?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => 'Ausgewählte Anrufe löschen';

  @override
  String call_deleteWithCount(int count) {
    return 'Löschen ($count)';
  }

  @override
  String call_durHr(int hours) {
    return '$hours Std.';
  }

  @override
  String call_durHrMin(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String call_durMin(int minutes) {
    return '$minutes Min.';
  }

  @override
  String call_durMinSec(int minutes, int seconds) {
    return '$minutes Min. $seconds Sek.';
  }

  @override
  String call_durSec(int seconds) {
    return '$seconds Sek.';
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
  String get call_duration => 'Dauer';

  @override
  String call_durationValue(String duration) {
    return 'Dauer: $duration';
  }

  @override
  String get call_earpiece => 'Hörmuschel';

  @override
  String get call_endCall => 'Anruf beenden';

  @override
  String get call_ended => 'Beendet';

  @override
  String get call_enterNumber => 'Nummer eingeben';

  @override
  String get call_enterPhoneNumber => 'Bitte gib eine Telefonnummer ein';

  @override
  String get call_entryDeleteFailed =>
      'Anrufeintrag konnte nicht gelöscht werden';

  @override
  String call_entryDeleteFailedError(String error) {
    return 'Anrufeintrag konnte nicht gelöscht werden: $error';
  }

  @override
  String get call_entryDeleted => 'Anrufeintrag gelöscht';

  @override
  String get call_everyoneInCall => 'Alle sind bereits im Anruf';

  @override
  String get call_failedTitle => 'Anruf fehlgeschlagen';

  @override
  String get call_groupBadge => 'Gruppe';

  @override
  String get call_groupCallComingSoon => 'Gruppenanrufe demnächst verfügbar';

  @override
  String get call_groupCallInitFailed =>
      'Gruppenanruf konnte nicht initialisiert werden';

  @override
  String get call_groupCallStartFailed =>
      'Gruppenanruf konnte nicht gestartet werden. Bitte erneut versuchen.';

  @override
  String get call_groupInformation => 'Gruppeninformationen';

  @override
  String call_groupWithId(String id) {
    return 'Gruppe $id';
  }

  @override
  String get call_headphones => 'Kopfhörer';

  @override
  String call_historyCancelled(String callType) {
    return 'Abgebrochener $callType';
  }

  @override
  String get call_historyClearFailed =>
      'Anrufverlauf konnte nicht gelöscht werden';

  @override
  String call_historyClearFailedError(String error) {
    return 'Anrufverlauf konnte nicht gelöscht werden: $error';
  }

  @override
  String get call_historyCleared => 'Gesamter Anrufverlauf gelöscht';

  @override
  String call_historyIncoming(String callType) {
    return 'Eingehender $callType';
  }

  @override
  String call_historyMissed(String callType) {
    return 'Verpasster $callType';
  }

  @override
  String call_historyOutgoing(String callType) {
    return 'Ausgehender $callType';
  }

  @override
  String call_historyRejected(String callType) {
    return 'Abgelehnter $callType';
  }

  @override
  String get call_inCall => 'Im Anruf';

  @override
  String call_inCallWithGroup(String groupName) {
    return 'Im Anruf · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return 'In diesem Anruf ($count)';
  }

  @override
  String get call_incomingAudio => 'Eingehender Sprachanruf';

  @override
  String get call_incomingCallChannelName => 'Eingehender Anruf';

  @override
  String get call_incomingGroupAudio => 'Eingehender Gruppen-Sprachanruf';

  @override
  String get call_incomingGroupVideo => 'Eingehender Gruppen-Videoanruf';

  @override
  String get call_incomingVideo => 'Eingehender Videoanruf';

  @override
  String get call_infoDescription => 'Beschreibung';

  @override
  String get call_infoEmail => 'E-Mail';

  @override
  String get call_infoGroupCode => 'Gruppencode';

  @override
  String get call_infoGroupName => 'Gruppenname';

  @override
  String get call_infoMobile => 'Mobil';

  @override
  String get call_infoTotalMembers => 'Gesamtmitglieder';

  @override
  String get call_invite => 'Einladen';

  @override
  String get call_inviteToApp => 'Zu FG Tracker einladen';

  @override
  String get call_join => 'Beitreten';

  @override
  String get call_joinOnAnswer => 'Du trittst bei, sobald du abhebst';

  @override
  String get call_kindAudio => 'Sprachanruf';

  @override
  String get call_kindCall => 'Anruf';

  @override
  String get call_kindGroupAudio => 'Gruppen-Sprachanruf';

  @override
  String get call_kindGroupCall => 'Gruppenanruf';

  @override
  String call_kindGroupOther(String kind) {
    return 'Gruppen-$kind-Anruf';
  }

  @override
  String get call_kindGroupVideo => 'Gruppen-Videoanruf';

  @override
  String call_kindOther(String kind) {
    return '$kind-Anruf';
  }

  @override
  String get call_kindVideo => 'Videoanruf';

  @override
  String get call_loadDetailFailed =>
      'Anrufdetails konnten nicht geladen werden';

  @override
  String get call_loadMore => 'Mehr laden';

  @override
  String get call_loadRecentFailed =>
      'Letzte Anrufe konnten nicht geladen werden';

  @override
  String get call_loginToCall => 'Bitte anmelden, um anzurufen';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder im Anruf',
      one: '1 Mitglied im Anruf',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'Nachricht';

  @override
  String get call_micActive => 'Mikrofon ist aktiv';

  @override
  String get call_missedCall => 'Verpasster Anruf';

  @override
  String get call_missedCallChannelName => 'Verpasster Anruf';

  @override
  String get call_missedCallNotification => 'Verpasster Anruf';

  @override
  String get call_more => 'Mehr';

  @override
  String get call_mute => 'Stummschalten';

  @override
  String get call_muted => 'Stumm';

  @override
  String call_nameYou(String name) {
    return '$name (Du)';
  }

  @override
  String get call_noActiveParticipants => 'Keine aktiven Teilnehmer';

  @override
  String get call_noContactsMatch =>
      'Keine Kontakte stimmen mit deiner Suche überein';

  @override
  String get call_noGroupsFound => 'Keine Gruppen gefunden';

  @override
  String get call_noGroupsYet => 'Noch keine Gruppen';

  @override
  String get call_noNameGroup => 'Unbenannte Gruppe';

  @override
  String get call_noRecentCalls => 'Keine letzten Anrufe';

  @override
  String get call_noRecentMatch =>
      'Keine letzten Anrufe stimmen mit deiner Suche überein';

  @override
  String get call_noRecentYet => 'Noch keine Anrufe vorhanden';

  @override
  String get call_noRegisteredContacts =>
      'Keine registrierten Kontakte gefunden';

  @override
  String get call_notInContacts => 'Diese Nummer ist nicht in deinen Kontakten';

  @override
  String call_notInThisCall(int count) {
    return 'Nicht in diesem Anruf ($count)';
  }

  @override
  String get call_notReady => 'Anruf nicht bereit';

  @override
  String get call_notificationPermissionRationale =>
      'Erforderlich zur Anzeige eingehender Anrufe.';

  @override
  String get call_notificationPermissionSettings =>
      'Benachrichtigungen in den Einstellungen aktivieren.';

  @override
  String get call_notificationPermissionTitle =>
      'Benachrichtigungsberechtigung';

  @override
  String get call_notify => 'Benachrichtigen';

  @override
  String get call_notifyFailed => 'Benachrichtigung fehlgeschlagen';

  @override
  String get call_notifySent => 'Erfolgreich benachrichtigt';

  @override
  String get call_ongoingChannelDescription =>
      'Hält den Anruf und die Bildschirmfreigabe aktiv';

  @override
  String get call_ongoingChannelName => 'Laufender Anruf';

  @override
  String get call_otherAlreadySharing =>
      'Die andere Person teilt bereits den Bildschirm';

  @override
  String get call_otherStartingVideo => 'Die andere Person startet das Video';

  @override
  String get call_participant => 'Teilnehmer';

  @override
  String get call_participants => 'Teilnehmer';

  @override
  String call_personIsSharing(String name) {
    return '$name teilt';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name teilt den Bildschirm';
  }

  @override
  String get call_phone => 'Telefon';

  @override
  String get call_pleaseWait => 'Bitte warten';

  @override
  String get call_recentCalls => 'Letzte Anrufe';

  @override
  String get call_resetZoom => 'Zoom zurücksetzen';

  @override
  String get call_returnToCall => 'Zurück zum Anruf';

  @override
  String get call_screenBeingShared => 'Bildschirm wird geteilt';

  @override
  String get call_screenShareChannelDescription =>
      'Benachrichtigung für aktive Bildschirmfreigabesitzung';

  @override
  String get call_screenShareChannelName => 'Bildschirmfreigabe-Dienst';

  @override
  String get call_screenSharePermissionDenied =>
      'Berechtigung zur Bildschirmfreigabe verweigert';

  @override
  String get call_screenShareStartFailed =>
      'Bildschirmfreigabe konnte nicht gestartet werden';

  @override
  String get call_screenShareStopped => 'Bildschirmfreigabe beendet';

  @override
  String get call_screenSharingTitle => 'Bildschirmfreigabe';

  @override
  String call_screenVisibleToName(String name) {
    return 'Dein Bildschirm ist für $name sichtbar';
  }

  @override
  String get call_screenVisibleToOther =>
      'Dein Bildschirm ist für die andere Person sichtbar';

  @override
  String get call_searchHint => 'Kontakte oder Gruppen suchen';

  @override
  String get call_sectionLastWeek => 'Letzte Woche';

  @override
  String get call_sectionOlder => 'Älter';

  @override
  String get call_sectionThisWeek => 'Diese Woche';

  @override
  String get call_selectAll => 'Alle auswählen';

  @override
  String call_selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get call_selectedDeleteFailed =>
      'Ausgewählte Anrufe konnten nicht gelöscht werden';

  @override
  String call_selectedDeleteFailedError(String error) {
    return 'Ausgewählte Anrufe konnten nicht gelöscht werden: $error';
  }

  @override
  String get call_selectedDeleted => 'Ausgewählte Anrufe gelöscht';

  @override
  String get call_selfCallWarning =>
      'Du kannst deine eigene Nummer nicht anrufen.';

  @override
  String get call_sessionConnectFailed =>
      'Verbindung zur Anrufsitzung fehlgeschlagen';

  @override
  String get call_shareScreen => 'Bildschirm teilen';

  @override
  String get call_shareScreenShort => 'Teilen';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return 'Freigabe in $groupName • Tippe zum Zurückkehren';
  }

  @override
  String get call_sharingYourScreen => 'Du teilst deinen Bildschirm';

  @override
  String get call_someone => 'Jemand';

  @override
  String get call_speaker => 'Lautsprecher';

  @override
  String get call_started => 'Gestartet';

  @override
  String get call_startingScreenShare => 'Bildschirmfreigabe startet…';

  @override
  String get call_statusBusy => 'Besetzt';

  @override
  String get call_statusCalling => 'Ruft an';

  @override
  String get call_statusCancelled => 'Abgebrochen';

  @override
  String get call_statusCompleted => 'Beendet';

  @override
  String get call_statusConnected => 'Verbunden';

  @override
  String get call_statusConnecting => 'Verbinden';

  @override
  String get call_statusDeclined => 'Abgelehnt';

  @override
  String get call_statusJoined => 'Beigetreten';

  @override
  String get call_statusMissed => 'Verpasst';

  @override
  String get call_statusReconnecting => 'Neu verbinden';

  @override
  String get call_statusRinging => 'Klingelt';

  @override
  String get call_statusVideoConnecting => 'Video verbindet';

  @override
  String get call_stop => 'Stopp';

  @override
  String get call_stopSharing => 'Freigabe beenden';

  @override
  String get call_subtitle => 'Audio- / Videoanruf';

  @override
  String get call_swipeUpToAnswer => 'Nach oben wischen zum Annehmen';

  @override
  String get call_switch => 'Wechseln';

  @override
  String get call_switchCameraFailed => 'Kamera konnte nicht gewechselt werden';

  @override
  String get call_switchToVideoToShare =>
      'Wechsle zum Videoanruf, um deinen Bildschirm zu teilen';

  @override
  String get call_tabContacts => 'Kontakte';

  @override
  String get call_tabGroups => 'Gruppen';

  @override
  String get call_tabRecent => 'Letzte';

  @override
  String get call_tapNotifyToInvite => 'Tippe auf Benachrichtigen zum Einladen';

  @override
  String get call_tapStartBroadcastHint =>
      'Tippe auf Übertragung starten, falls die Systemmeldung erscheint';

  @override
  String get call_title => 'Anruf';

  @override
  String call_todayAt(String value) {
    return 'Heute, $value';
  }

  @override
  String get call_total => 'Gesamt';

  @override
  String get call_turnOnVideo => 'Video einschalten';

  @override
  String get call_unableToCallContact =>
      'Dieser Kontakt kann nicht angerufen werden';

  @override
  String get call_unableToMakeCall => 'Anruf kann nicht getätigt werden';

  @override
  String get call_unableToOpenChat =>
      'Chat für diesen Kontakt kann nicht geöffnet werden';

  @override
  String get call_unableToShareScreen => 'Bildschirm kann nicht geteilt werden';

  @override
  String get call_unavailableTitle => 'Anruf nicht verfügbar';

  @override
  String get call_unexpectedResponse => 'Unerwartete Serverantwort';

  @override
  String get call_unknown => 'Unbekannt';

  @override
  String get call_unknownGroup => 'Unbekannte Gruppe';

  @override
  String get call_unknownUser => 'Unbekannter Benutzer';

  @override
  String get call_unmute => 'Laut schalten';

  @override
  String get call_unselectAll => 'Auswahl aufheben';

  @override
  String get call_user => 'Benutzer';

  @override
  String get call_userNotFound => 'Benutzer nicht gefunden';

  @override
  String call_userWithId(String id) {
    return 'Benutzer $id';
  }

  @override
  String get call_video => 'Video';

  @override
  String get call_waitingForBroadcast => 'Warten auf Übertragungsstart';

  @override
  String get call_waitingForBroadcastMessage =>
      'Tippe im Systemdialog auf „Übertragung starten“, um deinen Bildschirm zu teilen.';

  @override
  String get call_waitingForMedia => 'Warten auf Medien-Stream...';

  @override
  String get call_wired => 'Kabelgebunden';

  @override
  String get call_yesDelete => 'Ja, löschen';

  @override
  String call_yesterdayAt(String value) {
    return 'Gestern, $value';
  }

  @override
  String get call_youAreSharing => 'Du teilst';

  @override
  String get call_youAreSharingScreen => 'Du teilst deinen Bildschirm';

  @override
  String get call_zoomIn => 'Vergrößern';

  @override
  String get call_zoomOut => 'Verkleinern';

  @override
  String get chatList_allChats => 'Alle Chats';

  @override
  String get chatList_allContacts => 'Alle Kontakte';

  @override
  String get chatList_allowAccess => 'Zugriff erlauben';

  @override
  String get chatList_allowContactsBody =>
      'Wir benötigen Zugriff auf deine Kontakte, um zu zeigen, wer FG Tracker nutzt, und dir zu ermöglichen, Chats zu starten oder Einladungen zu senden.';

  @override
  String get chatList_allowContactsTitle => 'Kontaktzugriff erlauben';

  @override
  String get chatList_archiveChat => 'Chat archivieren';

  @override
  String get chatList_archived => 'Archiviert';

  @override
  String get chatList_archivedChatsSubtitle =>
      'Deine ausgeblendeten Unterhaltungen';

  @override
  String get chatList_archivedChatsTitle => 'Archivierte Chats';

  @override
  String chatList_archivedCount(int count) {
    return 'Archiviert ($count)';
  }

  @override
  String get chatList_block => 'Blockieren';

  @override
  String get chatList_blockFailed => 'Benutzer konnte nicht blockiert werden';

  @override
  String chatList_blockName(String name) {
    return '$name blockieren';
  }

  @override
  String get chatList_blockUser => 'Benutzer blockieren';

  @override
  String get chatList_blockUserConfirm =>
      'Möchtest du diesen Benutzer wirklich blockieren?';

  @override
  String get chatList_blocked => 'Blockiert';

  @override
  String get chatList_chatCleared => 'Chat geleert';

  @override
  String get chatList_chooseContactToShare =>
      'Wähle einen Kontakt zum Teilen im Chat.';

  @override
  String get chatList_clear => 'Leeren';

  @override
  String get chatList_clearChat => 'Chat leeren';

  @override
  String get chatList_clearChatConfirm =>
      'Alle Nachrichten mit diesem Benutzer löschen?';

  @override
  String get chatList_clearChatFailed => 'Chat konnte nicht geleert werden';

  @override
  String get chatList_clearSearch => 'Suche löschen';

  @override
  String get chatList_contactAndInfo => 'Kontakt & Info';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'Kontaktberechtigung ist erforderlich, um Kontakte im Chat zu teilen.';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte',
      one: '1 Kontakt',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return 'Fehler beim Laden der Kontakte: $error';
  }

  @override
  String get chatList_contactsPermissionNeeded =>
      'Kontaktberechtigung erforderlich';

  @override
  String get chatList_contactsWillAppear =>
      'Deine Kontakte werden hier angezeigt, sobald verfügbar.';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => 'Deaktiviert';

  @override
  String get chatList_defaultAbout => 'Hallo! Ich nutze FG Tracker';

  @override
  String get chatList_deleteChat => 'Chat löschen';

  @override
  String get chatList_deleteChatConfirm =>
      'Diese Unterhaltung aus deiner Chatliste löschen?';

  @override
  String get chatList_forwardFailed =>
      'Nachricht konnte nicht weitergeleitet werden.';

  @override
  String get chatList_forwardListLoadFailed =>
      'Weiterleitungsliste konnte nicht geladen werden.';

  @override
  String get chatList_forwardTo => 'Weiterleiten an...';

  @override
  String get chatList_forwarded => 'Weitergeleitet';

  @override
  String get chatList_groupChatFallback => 'Gruppenchat';

  @override
  String get chatList_groupDeactivatedBanner =>
      'Diese Gruppe wurde vom Administrator deaktiviert';

  @override
  String get chatList_groupFallback => 'Gruppe';

  @override
  String get chatList_howToAllow => 'So erlaubst du den Zugriff';

  @override
  String get chatList_howToAllowStep1 =>
      'Tippe auf „Zugriff erlauben“, um die Einstellungen zu öffnen';

  @override
  String get chatList_howToAllowStep2 => 'Tippe auf „Berechtigungen“';

  @override
  String get chatList_howToAllowStep3 => 'Wähle „Kontakte“';

  @override
  String get chatList_howToAllowStep4 =>
      'Wähle „Zulassen“ und kehre zur App zurück';

  @override
  String get chatList_invite => 'Einladen';

  @override
  String get chatList_inviteChooseHow =>
      'Wähle, wie du die Einladung senden möchtest';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return 'Hallo $name! Mach mit bei FG Tracker.\n\nDownload für Android: $playStoreLink\n\nDownload für iOS: $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'Weitere Apps';

  @override
  String chatList_inviteName(String name) {
    return '$name einladen';
  }

  @override
  String get chatList_inviteViaMessage => 'Nachricht';

  @override
  String get chatList_locationHidden => 'Standort ausgeblendet';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1, $name2 +$count schreiben...';
  }

  @override
  String get chatList_markAsRead => 'Als gelesen markieren';

  @override
  String get chatList_markAsUnread => 'Als ungelesen markieren';

  @override
  String get chatList_mediaLinksDocs => 'Medien, Links und Dokumente';

  @override
  String get chatList_memberFallback => 'Mitglied';

  @override
  String get chatList_messageDeleted => 'Diese Nachricht wurde gelöscht';

  @override
  String get chatList_messageForwarded => 'Nachricht weitergeleitet';

  @override
  String get chatList_messageIdMissing => 'Nachrichten-ID fehlt.';

  @override
  String chatList_minutesShort(int count) {
    return '$count Min.';
  }

  @override
  String get chatList_mute1Hour => '1 Stunde';

  @override
  String get chatList_mute8Hours => '8 Stunden';

  @override
  String get chatList_muteAlways => 'Bis zum Wiedereinschalten';

  @override
  String get chatList_muteSubtitle =>
      'Wähle, wie lange Benachrichtigungen pausiert werden sollen.';

  @override
  String get chatList_muteTitle => 'Benachrichtigungen stummschalten';

  @override
  String get chatList_muteUntilTomorrow => 'Bis morgen';

  @override
  String get chatList_newChat => 'Neuer Chat';

  @override
  String get chatList_newChatSectionContacts => 'Neuen Chat starten (Kontakte)';

  @override
  String get chatList_newChatSectionInvite =>
      'Zum Chat einladen (Nicht registriert)';

  @override
  String get chatList_noArchivedChats => 'Keine archivierten Chats';

  @override
  String get chatList_noArchivedChatsSubtitle =>
      'Archivierte Unterhaltungen werden hier angezeigt.';

  @override
  String get chatList_noChatsFound => 'Keine Chats gefunden';

  @override
  String get chatList_noChatsSubtitle =>
      'Deine privaten Chats werden hier angezeigt.';

  @override
  String get chatList_noContactsAvailable => 'Keine Kontakte verfügbar';

  @override
  String get chatList_noContactsFound => 'Keine Kontakte gefunden';

  @override
  String get chatList_noGroupsAvailable => 'Keine Gruppen verfügbar';

  @override
  String get chatList_noGroupsFound => 'Keine Gruppen gefunden';

  @override
  String get chatList_noMediaYet => 'Noch keine Medien geteilt';

  @override
  String get chatList_noMessagesYet => 'Noch keine Nachrichten';

  @override
  String get chatList_noPeopleOrGroups =>
      'Keine Personen oder Gruppen gefunden';

  @override
  String chatList_noResultsFor(String query) {
    return 'Keine Ergebnisse für „$query“ gefunden';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return 'Keine Ergebnisse für \'$query\'';
  }

  @override
  String get chatList_noTrackerContacts =>
      'Keine aktiven Tracker-Kontakte gefunden';

  @override
  String get chatList_offlineNotSaved =>
      'Du bist offline. Die Änderung wurde nicht gespeichert.';

  @override
  String chatList_oneTyping(String name) {
    return '$name schreibt...';
  }

  @override
  String get chatList_openSettings => 'Einstellungen öffnen';

  @override
  String get chatList_pinChat => 'Chat anpinnen';

  @override
  String get chatList_pinnedChats => 'Angepinnte Chats';

  @override
  String get chatList_pleaseTryAgain => 'Bitte versuche es erneut.';

  @override
  String get chatList_profileCall => 'Anrufen';

  @override
  String get chatList_profileMessage => 'Nachricht';

  @override
  String get chatList_profileNotFound => 'Profildetails nicht gefunden';

  @override
  String get chatList_profileVideoCall => 'Videoanruf';

  @override
  String get chatList_quickCommSubtitle =>
      'Verbinde dich sofort mit deinem Team';

  @override
  String get chatList_quickCommTitle => 'Schnelle Kommunikation';

  @override
  String get chatList_quickGroups => 'Gruppen';

  @override
  String get chatList_quickGroupsSub => 'Team-Chats';

  @override
  String get chatList_quickSafeZone => 'Sicherheitszone';

  @override
  String get chatList_quickSafeZoneSub => 'Sicherheit & Alarme';

  @override
  String get chatList_quickTracking => 'Tracking';

  @override
  String get chatList_quickTrackingSub => 'Live-Standort';

  @override
  String get chatList_quickWalkie => 'Walkie';

  @override
  String get chatList_quickWalkieSub => 'Push-to-Talk';

  @override
  String get chatList_searchByNameOrNumber => 'Nach Name oder Nummer suchen...';

  @override
  String get chatList_searchGroupsHint => 'Gruppen suchen...';

  @override
  String get chatList_searchHint => 'Chats oder Nachrichten suchen...';

  @override
  String get chatList_searchHintShort => 'Suchen...';

  @override
  String get chatList_searchNameOrNumber => 'Name oder Nummer suchen';

  @override
  String get chatList_searchResults => 'Suchergebnisse';

  @override
  String get chatList_sectionGroups => 'GRUPPEN';

  @override
  String get chatList_sectionMyContacts => 'MEINE KONTAKTE';

  @override
  String get chatList_sectionOtherContacts => 'ANDERE KONTAKTE';

  @override
  String get chatList_sectionRecentChats => 'LETZTE CHATS';

  @override
  String get chatList_selectDestination => 'Ziel auswählen';

  @override
  String get chatList_selectDestinationMsg =>
      'Bitte wähle mindestens eine Person oder Gruppe aus.';

  @override
  String chatList_selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get chatList_shareContactTitle => 'Kontakt teilen';

  @override
  String chatList_shareMenuFailed(String error) {
    return 'Teilen-Menü konnte nicht geöffnet werden: $error';
  }

  @override
  String get chatList_smsOpenFailed =>
      'Nachrichten-App konnte nicht geöffnet werden';

  @override
  String get chatList_someone => 'Jemand';

  @override
  String get chatList_startConversation => 'Unterhaltung starten';

  @override
  String get chatList_subtitle => 'Bleibe mit deinem Team in Verbindung';

  @override
  String get chatList_telegramOpenFailed =>
      'Telegram konnte nicht geöffnet werden';

  @override
  String get chatList_title => 'Chat';

  @override
  String get chatList_tryAnotherNameOrNumber =>
      'Probiere einen anderen Namen oder eine Telefonnummer.';

  @override
  String get chatList_tryDifferentSearch =>
      'Versuche es mit einem anderen Namen oder einer Nachricht.';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1, $name2 schreiben...';
  }

  @override
  String get chatList_typing => 'schreibt...';

  @override
  String get chatList_unableToCallContact =>
      'Dieser Kontakt kann nicht angerufen werden';

  @override
  String get chatList_unableToLoadContacts =>
      'Kontakte konnten nicht geladen werden';

  @override
  String get chatList_unarchiveChat => 'Chat aus Archiv holen';

  @override
  String get chatList_unblock => 'Entsperren';

  @override
  String get chatList_unblockFailed => 'Benutzer konnte nicht entsperrt werden';

  @override
  String chatList_unblockName(String name) {
    return '$name entsperren';
  }

  @override
  String get chatList_unblockUser => 'Benutzer entsperren';

  @override
  String get chatList_unblockUserConfirm =>
      'Möchtest du diesen Benutzer wirklich entsperren?';

  @override
  String get chatList_unknown => 'Unbekannt';

  @override
  String get chatList_unknownUser => 'Unbekannter Benutzer';

  @override
  String get chatList_unnamedContact => 'Unbenannter Kontakt';

  @override
  String get chatList_unpinChat => 'Chat lösen';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Nachrichten',
      one: '1 ungelesene Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed =>
      'Chat konnte nicht aktualisiert werden. Bitte erneut versuchen.';

  @override
  String get chatList_userFallback => 'Benutzer';

  @override
  String get chatList_userNotFound => 'Benutzer nicht gefunden';

  @override
  String get chatList_viewArchived => 'Archivierte Unterhaltungen anzeigen';

  @override
  String get chatList_whatsappOpenFailed =>
      'WhatsApp konnte nicht geöffnet werden';

  @override
  String get chatList_yourContacts => 'Deine Kontakte';

  @override
  String get chat_addCaptionHint => 'Bildunterschrift hinzufügen...';

  @override
  String get chat_audioUnavailable => 'Dieses Audio ist nicht mehr verfügbar';

  @override
  String get chat_blockFailed => 'Benutzer konnte nicht blockiert werden';

  @override
  String get chat_call => 'Anrufen';

  @override
  String get chat_cameraAccessNeeded =>
      'Kamerazugriff ist erforderlich, um Fotos und Videos im Chat aufzunehmen.';

  @override
  String get chat_cameraModePhoto => 'FOTO';

  @override
  String get chat_cameraModePortrait => 'PORTRÄT';

  @override
  String get chat_cameraModeVideo => 'VIDEO';

  @override
  String get chat_cameraStartFailed => 'Kamera konnte nicht gestartet werden.';

  @override
  String get chat_cantMessageUser =>
      'Du kannst diesem Benutzer keine Nachrichten senden';

  @override
  String get chat_chatActionsSubtitle => 'Verwalte deinen Chat';

  @override
  String get chat_chatActionsTitle => 'Chat-Aktionen';

  @override
  String get chat_clear => 'Leeren';

  @override
  String get chat_clearChat => 'Chat leeren';

  @override
  String get chat_clearChatConfirm =>
      'Alle Nachrichten aus diesem Chat löschen?';

  @override
  String get chat_clearGroupChatFailed =>
      'Gruppenchat konnte nicht geleert werden';

  @override
  String get chat_contactBlockedYou => 'Dieser Kontakt hat dich blockiert';

  @override
  String get chat_contactUnavailable => 'Kontakt nicht verfügbar';

  @override
  String get chat_deleteForEveryone => 'Für alle löschen';

  @override
  String get chat_deleteForEveryoneConfirm =>
      'Möchtest du diese Nachricht wirklich für alle löschen?';

  @override
  String get chat_deleteForMe => 'Für mich löschen';

  @override
  String get chat_deleteForMeConfirm =>
      'Möchtest du diese Nachricht wirklich für dich löschen?';

  @override
  String get chat_deleteMember => 'Mitglied entfernen';

  @override
  String get chat_deleteMemberSubtitle =>
      'Ein Mitglied aus dieser Gruppe entfernen';

  @override
  String get chat_documentAvailable => 'Dokument ist verfügbar';

  @override
  String get chat_documentDownloadFailed =>
      'Das Dokument konnte nicht heruntergeladen werden.';

  @override
  String get chat_documentOpenFailed =>
      'Dokument konnte nicht geöffnet werden. Bitte versuche es erneut.';

  @override
  String get chat_documentPreviewUnavailable =>
      'Vorschau für diesen Dateityp nicht verfügbar. Öffne das Dokument mit einer installierten App.';

  @override
  String get chat_documentUnavailable =>
      'Dieses Dokument ist nicht mehr verfügbar';

  @override
  String get chat_downloadFailed => 'Download fehlgeschlagen';

  @override
  String get chat_edited => 'bearbeitet';

  @override
  String get chat_emptySubtitle => 'Sag Hallo 👋, um das Gespräch zu beginnen';

  @override
  String get chat_emptyTitle => 'Hier gibt es noch keine Nachrichten';

  @override
  String get chat_fetchingLocation => 'Standort wird abgerufen...';

  @override
  String get chat_finishVoiceRecordingFirst =>
      'Sprachaufnahme zuerst beenden oder abbrechen';

  @override
  String get chat_forwarded => 'Weitergeleitet';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current von $total';
  }

  @override
  String get chat_groupActionsSubtitle => 'Verwalte deine Gruppeneinstellungen';

  @override
  String get chat_groupActionsTitle => 'Gruppenaktionen';

  @override
  String get chat_groupChatCleared => 'Gruppenchat erfolgreich geleert';

  @override
  String get chat_groupDeactivated =>
      'Diese Gruppe wurde vom Administrator deaktiviert';

  @override
  String get chat_imageFailed => 'Bildfehler';

  @override
  String get chat_listen => 'Anhören';

  @override
  String get chat_listenEnglish => 'Anhören (Englisch)';

  @override
  String get chat_listenHindi => 'Anhören (Hindi)';

  @override
  String get chat_loadFailedSubtitle =>
      'Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get chat_loadFailedTitle => 'Nachrichten konnten nicht geladen werden';

  @override
  String get chat_locationFetchFailed =>
      'Dein Standort konnte nicht ermittelt werden. Bitte versuche es erneut.';

  @override
  String get chat_locationPermissionNeeded =>
      'Standortberechtigung wird benötigt, um deinen Standort zu teilen.';

  @override
  String get chat_locationPermissionOff =>
      'Standortberechtigung ist für diese App deaktiviert. Aktiviere sie in den Einstellungen, um deinen Standort zu teilen.';

  @override
  String get chat_locationServicesOff =>
      'Aktiviere die Standortdienste, um deinen Standort zu teilen.';

  @override
  String get chat_locationUnavailable => 'Standort nicht verfügbar';

  @override
  String get chat_mediaMissing => 'Medien fehlen';

  @override
  String get chat_mediaMissingToast =>
      'Medien fehlen. Diese Datei ist nicht mehr verfügbar.';

  @override
  String get chat_mediaUnavailable => 'Dieses Medium ist nicht mehr verfügbar';

  @override
  String get chat_menuForward => 'Weiterleiten';

  @override
  String get chat_menuMessageInfo => 'Nachrichten-Info';

  @override
  String get chat_menuPin => 'Nachricht anpinnen';

  @override
  String get chat_menuReply => 'Antworten';

  @override
  String get chat_menuUnpin => 'Nachricht lösen';

  @override
  String get chat_messageCopied => 'Nachricht kopiert';

  @override
  String get chat_messageDeleted => 'Diese Nachricht wurde gelöscht';

  @override
  String get chat_messageNotAvailable => 'Nachricht nicht verfügbar';

  @override
  String get chat_messageNotSent =>
      'Nachricht nicht gesendet. Bitte erneut versuchen.';

  @override
  String get chat_noCameraFound => 'Keine Kamera auf diesem Gerät gefunden.';

  @override
  String get chat_noLongerMember => 'Du bist kein Mitglied dieser Gruppe mehr';

  @override
  String get chat_noMediaAvailable => 'Keine Medien verfügbar';

  @override
  String get chat_offlineNotSent =>
      'Du bist offline. Nachricht nicht gesendet.';

  @override
  String get chat_openDocument => 'Dokument öffnen';

  @override
  String get chat_openInGoogleMaps => 'In Google Maps öffnen';

  @override
  String get chat_openSettings => 'Einstellungen öffnen';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'Dieses Foto ist nicht mehr verfügbar';

  @override
  String get chat_previewAttendancePoll => 'Anwesenheitsumfrage';

  @override
  String get chat_previewAudio => 'Audio';

  @override
  String get chat_previewContact => 'Kontakt';

  @override
  String get chat_previewDocument => 'Dokument';

  @override
  String get chat_previewLocation => 'Standort';

  @override
  String get chat_previewMessage => 'Nachricht';

  @override
  String get chat_previewNewMessage => 'Neue Nachricht';

  @override
  String get chat_previewOwnDeleted => 'Du hast diese Nachricht gelöscht';

  @override
  String get chat_previewPhoto => 'Foto';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '1 Foto',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => 'Umfrage';

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
  String get chat_previewVoiceMessage => 'Sprachnachricht';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return 'Sprachnachricht ($duration)';
  }

  @override
  String get chat_recordingFailed => 'Aufnahme fehlgeschlagen';

  @override
  String get chat_removeMember => 'Mitglied entfernen';

  @override
  String get chat_removeMemberConfirm =>
      'Möchtest du dieses Mitglied wirklich aus der Gruppe entfernen?';

  @override
  String get chat_replyHint => 'Auf Nachricht antworten...';

  @override
  String get chat_searchMessages => 'Nachrichten suchen';

  @override
  String get chat_searchMessagesHint => 'Nachrichten suchen...';

  @override
  String get chat_searchMessagesSubtitle => 'Nachrichten nach Stichwort finden';

  @override
  String get chat_sendLocation => 'Standort senden';

  @override
  String get chat_shareLocation => 'Standort teilen';

  @override
  String get chat_shareVideoFailed => 'Video konnte nicht geteilt werden';

  @override
  String get chat_sharedFromApp => 'Geteilt über FG Tracker';

  @override
  String get chat_sharedLocation => 'Geteilter Standort';

  @override
  String get chat_showOriginal => 'Original anzeigen';

  @override
  String get chat_someone => 'Jemand';

  @override
  String get chat_statusLabel => 'Status';

  @override
  String get chat_statusUnavailable =>
      'Dieses Status-Update ist nicht mehr verfügbar';

  @override
  String get chat_stop => 'Stoppen';

  @override
  String get chat_stopEnglish => 'Stoppen (Englisch)';

  @override
  String get chat_stopHindi => 'Stoppen (Hindi)';

  @override
  String get chat_takePhotoFailed => 'Foto konnte nicht aufgenommen werden';

  @override
  String get chat_translatedToEnglish => 'Ins Englische übersetzt';

  @override
  String get chat_translatedToHindi => 'Ins Hindi übersetzt';

  @override
  String get chat_translating => 'Übersetzen...';

  @override
  String get chat_tryAgain => 'Erneut versuchen';

  @override
  String get chat_typeMessageHint => 'Nachricht schreiben...';

  @override
  String get chat_typing => 'schreibt...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen schreiben...',
      one: '1 Person schreibt...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name schreibt...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1, $name2 schreiben...';
  }

  @override
  String get chat_unableToOpen => 'Kann nicht geöffnet werden';

  @override
  String get chat_unableToOpenGoogleMaps =>
      'Google Maps kann nicht geöffnet werden';

  @override
  String get chat_unblock => 'Entsperren';

  @override
  String get chat_unblockContact => 'Kontakt entsperren';

  @override
  String get chat_unblockContactConfirm =>
      'Möchtest du diesen Kontakt wirklich entsperren?';

  @override
  String get chat_unblockFailed => 'Benutzer konnte nicht entsperrt werden';

  @override
  String get chat_unknown => 'Unbekannt';

  @override
  String get chat_unknownLocation => 'Unbekannter Standort';

  @override
  String get chat_unsupportedMessage =>
      'Diese Nachricht wird in dieser App-Version nicht unterstützt';

  @override
  String get chat_updateGroup => 'Gruppe aktualisieren';

  @override
  String get chat_updateGroupSubtitle => 'Aktuelle Gruppendetails ändern';

  @override
  String chat_uploadFileFailed(String path) {
    return 'Fehler beim Hochladen von $path';
  }

  @override
  String get chat_userBlocked => 'Benutzer erfolgreich blockiert';

  @override
  String get chat_userUnblocked => 'Benutzer erfolgreich entsperrt';

  @override
  String get chat_videoDownloaded => 'Video erfolgreich heruntergeladen';

  @override
  String get chat_videoThumbnailFailed =>
      'Video-Miniaturbild konnte nicht erstellt werden';

  @override
  String get chat_videoUnavailable => 'Dieses Video ist nicht mehr verfügbar';

  @override
  String get chat_videoUploadFailed => 'Video konnte nicht hochgeladen werden';

  @override
  String get chat_voicePlayFailed =>
      'Sprachnachricht konnte nicht abgespielt werden';

  @override
  String get chat_voiceUploadFailed =>
      'Sprachnachricht konnte nicht hochgeladen werden. Bitte erneut versuchen.';

  @override
  String get chat_youBlockedContact => 'Du hast diesen Kontakt blockiert';

  @override
  String get common_add => 'Hinzufügen';

  @override
  String get common_allow => 'Erlauben';

  @override
  String get common_back => 'Zurück';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_close => 'Schließen';

  @override
  String get common_comingSoon => 'Demnächst';

  @override
  String get common_confirm => 'Bestätigen';

  @override
  String get common_continue => 'Weiter';

  @override
  String get common_copied => 'Kopiert';

  @override
  String get common_copy => 'Kopieren';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Tagen',
      one: 'Vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => 'Löschen';

  @override
  String get common_dismiss => 'Verwerfen';

  @override
  String get common_done => 'Fertig';

  @override
  String get common_edit => 'Bearbeiten';

  @override
  String get common_error => 'Fehler';

  @override
  String get common_exit => 'Beenden';

  @override
  String get common_gotIt => 'Verstanden';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Stunden',
      one: 'Vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'Gerade eben';

  @override
  String common_lastSeen(String time) {
    return 'Zuletzt gesehen: $time';
  }

  @override
  String get common_loading => 'Laden…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Min.',
      one: 'Vor 1 Min.',
    );
    return '$_temp0';
  }

  @override
  String get common_next => 'Weiter';

  @override
  String get common_no => 'Nein';

  @override
  String get common_noData => 'Keine Daten gefunden';

  @override
  String get common_noInternet => 'Keine Internetverbindung';

  @override
  String get common_notNow => 'Nicht jetzt';

  @override
  String get common_offline => 'Offline';

  @override
  String get common_ok => 'OK';

  @override
  String get common_online => 'Online';

  @override
  String get common_open => 'Öffnen';

  @override
  String get common_permissionDenied => 'Berechtigung verweigert';

  @override
  String get common_remove => 'Entfernen';

  @override
  String get common_retry => 'Wiederholen';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_search => 'Suchen';

  @override
  String get common_send => 'Senden';

  @override
  String get common_settings => 'Einstellungen';

  @override
  String get common_share => 'Teilen';

  @override
  String get common_somethingWentWrong =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get common_submit => 'Absenden';

  @override
  String get common_success => 'Erfolg';

  @override
  String get common_today => 'Heute';

  @override
  String common_todayAt(String time) {
    return 'Heute, $time';
  }

  @override
  String get common_tryAgain => 'Erneut versuchen';

  @override
  String get common_viewAll => 'Alle anzeigen';

  @override
  String get common_yes => 'Ja';

  @override
  String get common_yesterday => 'Gestern';

  @override
  String get common_you => 'Du';

  @override
  String get dialog_allowLocationAccess => 'Standortzugriff erlauben';

  @override
  String get dialog_anErrorOccurred => 'Ein Fehler ist aufgetreten!';

  @override
  String get dialog_important => 'Wichtig!';

  @override
  String get dialog_locationPermissionRequired =>
      'Standortberechtigung erforderlich';

  @override
  String get dialog_locationPurposeBody =>
      'Um die Serviceeffizienz zu verbessern, bittet unsere App um die Erlaubnis, auf deinen Standort zuzugreifen und ihn zu speichern. Dies ermöglicht eine genaue Navigation zu deinem Einsatzort.';

  @override
  String get dialog_locationSettingsAndroid =>
      'Ohne Standortzugriff können wir deinen aktuellen Standort nicht ermitteln. Bitte tippe auf \'Einstellungen\', dann \'Berechtigungen\' und erlaube den Standortzugriff.';

  @override
  String get dialog_locationSettingsIos =>
      'Diese App benötigt Zugriff auf deinen Standort, um standortbasierte Dienste bereitzustellen. Bitte gehe zu \'Einstellungen\' und aktiviere die Standortberechtigungen.';

  @override
  String get dialog_loggedInElsewhere =>
      'Du wurdest von einem anderen Gerät angemeldet.';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      'Du wurdest von einem anderen Gerät angemeldet. Bitte melde dich erneut an.';

  @override
  String get dialog_logoutConfirm => 'Möchtest du dich abmelden?';

  @override
  String get dialog_selectAllowAllTheTime =>
      'Im nächsten Popup wähle bitte\n\'Immer zulassen\'.';

  @override
  String get dialog_sessionExpiredTitle => 'Sitzung abgelaufen';

  @override
  String get editProfile_fullNameLabel => 'Vollständiger Name';

  @override
  String get editProfile_personalInfo => 'Persönliche Angaben';

  @override
  String get editProfile_phoneLabel => 'Telefonnummer';

  @override
  String get editProfile_saveButton => 'Änderungen speichern';

  @override
  String get editProfile_tapPhotoHint => 'Tippe auf das Foto zum Ändern';

  @override
  String get editProfile_title => 'Profil bearbeiten';

  @override
  String get forceUpdate_currentInstalled => 'AKTUELL INSTALLIERT';

  @override
  String get forceUpdate_defaultMessage =>
      'Eine neue Version von FG Tracker ist verfügbar. Bitte aktualisieren Sie, um fortzufahren.';

  @override
  String get forceUpdate_defaultTitle => 'Update erforderlich';

  @override
  String get forceUpdate_fallbackMessage =>
      'Eine neue Version von FG Tracker mit wichtigen Verbesserungen ist verfügbar. Bitte aktualisieren Sie die App.';

  @override
  String get forceUpdate_footer =>
      'Aktualisierung erforderlich, um FG Tracker zu nutzen';

  @override
  String get forceUpdate_requiredVersion => 'ERFORDERLICHE VERSION';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return 'Auf $storeName aktualisieren';
  }

  @override
  String get groupDialog_audioCall => 'Sprachanruf';

  @override
  String get groupDialog_audioCallSubtitle => 'Sprachgespräch starten';

  @override
  String get groupDialog_call => 'Anrufen';

  @override
  String get groupDialog_chat => 'Chat';

  @override
  String get groupDialog_codeEmpty => 'Gruppencode darf nicht leer sein';

  @override
  String get groupDialog_codeLabel => 'Gruppencode';

  @override
  String get groupDialog_createButton => 'Gruppe erstellen';

  @override
  String get groupDialog_createTitle => 'Neue Gruppe erstellen';

  @override
  String get groupDialog_descHint => 'Gruppenbeschreibung eingeben';

  @override
  String get groupDialog_descLabel => 'Gruppenbeschreibung (Optional)';

  @override
  String groupDialog_distance(String distance) {
    return 'Entfernung: $distance';
  }

  @override
  String get groupDialog_enterCodeManually => 'Gruppencode manuell eingeben';

  @override
  String get groupDialog_enterCodeTitle => 'Gruppencode eingeben';

  @override
  String get groupDialog_fillDetails => 'Fülle die folgenden Details aus';

  @override
  String get groupDialog_getDirections => 'Route berechnen';

  @override
  String get groupDialog_join => 'Gruppe beitreten';

  @override
  String groupDialog_lastSeen(String time) {
    return 'Zuletzt gesehen: $time';
  }

  @override
  String get groupDialog_locationHidden => 'Standort ausgeblendet';

  @override
  String get groupDialog_locationUnavailable => 'Standort nicht verfügbar';

  @override
  String get groupDialog_member => 'Mitglied';

  @override
  String get groupDialog_memberInfo => 'Mitglieder-Info';

  @override
  String get groupDialog_nameHint => 'Gruppennamen eingeben';

  @override
  String get groupDialog_nameLabel => 'Gruppenname';

  @override
  String get groupDialog_noQrInImage =>
      'Kein QR-Code im ausgewählten Bild gefunden.';

  @override
  String get groupDialog_noValidQr => 'Kein gültiger QR-Code gefunden.';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'Fehler beim Decodieren des QR-Codes aus der Galerie: $error';
  }

  @override
  String get groupDialog_scanCamera => 'Mit Kamera scannen';

  @override
  String get groupDialog_selectCallType => 'Anruftyp auswählen';

  @override
  String get groupDialog_update => 'Aktualisieren';

  @override
  String get groupDialog_updateTitle => 'Gruppe aktualisieren';

  @override
  String get groupDialog_uploadGallery => 'Aus Galerie hochladen';

  @override
  String get groupDialog_videoCall => 'Videoanruf';

  @override
  String get groupDialog_videoCallSubtitle => 'Videogespräch starten';

  @override
  String get groupDialog_yourLocation => 'Dein aktueller Standort';

  @override
  String get groupInfo_active => 'Aktiv';

  @override
  String get groupInfo_admin => 'Admin';

  @override
  String get groupInfo_allGroups => 'Alle Gruppen';

  @override
  String get groupInfo_allGroupsSubtitle =>
      'Bleibe mit deinen Teams in Verbindung';

  @override
  String get groupInfo_areYouSure => 'Bist du sicher?';

  @override
  String get groupInfo_audioCall => 'Sprachanruf';

  @override
  String get groupInfo_clearChatConfirm =>
      'Alle Nachrichten von diesem Gerät löschen?';

  @override
  String get groupInfo_createdBy => 'Erstellt von';

  @override
  String get groupInfo_detailsNotFound => 'Gruppendetails nicht gefunden';

  @override
  String get groupInfo_exitGroup => 'Gruppe verlassen';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return 'Möchtest du \"$groupName\" wirklich verlassen?';
  }

  @override
  String get groupInfo_exitGroupQuestion =>
      'Möchtest du diese Gruppe verlassen?';

  @override
  String get groupInfo_group => 'Gruppe';

  @override
  String get groupInfo_groupAdmin => 'Gruppen-Admin';

  @override
  String get groupInfo_groupCallFailed =>
      'Gruppenanruf konnte nicht gestartet werden. Bitte erneut versuchen.';

  @override
  String get groupInfo_groupCodeCopied => 'Gruppencode kopiert!';

  @override
  String get groupInfo_groupSettings => 'Gruppeneinstellungen';

  @override
  String get groupInfo_groupSettingsSubtitle =>
      'Gruppeninfo, Privatsphäre und mehr bearbeiten';

  @override
  String get groupInfo_inactive => 'Inaktiv';

  @override
  String get groupInfo_inviteCopied => 'Einladungstext kopiert';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'Tritt meiner Gruppe \"$groupName\" auf FG Tracker bei';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'Tritt meiner Gruppe \"$groupName\" auf FG Tracker bei. Code: $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'Über Link einladen';

  @override
  String get groupInfo_mediaLinksDocs => 'Medien, Links & Doks';

  @override
  String get groupInfo_member => 'Mitglied';

  @override
  String get groupInfo_members => 'Mitglieder';

  @override
  String get groupInfo_messageAction => 'Nachricht';

  @override
  String groupInfo_nameYou(String name) {
    return '$name (Du)';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return 'Keine Gruppe für \'$query\' gefunden';
  }

  @override
  String get groupInfo_noGroupsYet =>
      'Du bist noch keinen Gruppen beigetreten oder hast welche erstellt.\nJetzt entdecken!';

  @override
  String get groupInfo_noMediaYet => 'Noch keine Medien geteilt';

  @override
  String get groupInfo_removeFromGroup => 'Aus Gruppe entfernen';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return 'Möchtest du $name wirklich aus der Gruppe entfernen?';
  }

  @override
  String get groupInfo_searchGroupsHint => 'Gruppen suchen...';

  @override
  String get groupInfo_showLess => 'Weniger anzeigen';

  @override
  String get groupInfo_teamCode => 'Team-Code';

  @override
  String groupInfo_totalCount(int count) {
    return '$count Gesamt';
  }

  @override
  String get groupInfo_unknownGroup => 'Unbekannte Gruppe';

  @override
  String get groupInfo_unnamedGroup => 'Unbenannte Gruppe';

  @override
  String get groupInfo_videoCall => 'Videoanruf';

  @override
  String get groupInfo_viewAllMembers => 'Alle Mitglieder anzeigen';

  @override
  String get group_activatedSuccess => 'Gruppe erfolgreich aktiviert';

  @override
  String get group_addMember => 'Mitglied hinzufügen';

  @override
  String get group_alignQr => 'QR-Code im Rahmen ausrichten';

  @override
  String get group_areYouSure => 'Sind Sie sicher?';

  @override
  String get group_chatWithMembers => 'Mit Gruppenmitgliedern chatten';

  @override
  String get group_codeCopied => 'Gruppencode kopiert!';

  @override
  String group_codeShareInfo(String code) {
    return 'Gruppencode: $code – teilen, damit andere beitreten können';
  }

  @override
  String get group_copyCode => 'Code kopieren';

  @override
  String get group_created => 'Erstellt';

  @override
  String get group_createdJustNow => 'Gerade eben erstellt';

  @override
  String get group_deactivatedSuccess => 'Gruppe erfolgreich deaktiviert';

  @override
  String get group_defaultName => 'Gruppe';

  @override
  String get group_deleteGroup => 'Gruppe löschen';

  @override
  String get group_deleteGroupConfirm => 'Möchten Sie diese Gruppe löschen?';

  @override
  String get group_deletedSuccess => 'Gruppe erfolgreich gelöscht';

  @override
  String get group_download => 'Herunterladen';

  @override
  String get group_downloadChannelDescription =>
      'Benachrichtigt beim Herunterladen des QR-Codes';

  @override
  String get group_downloadChannelName => 'Download-Benachrichtigungen';

  @override
  String get group_enableLocationToJoin =>
      'Bitte Standortdienste aktivieren, um der Gruppe beizutreten.';

  @override
  String get group_exitGroup => 'Gruppe verlassen';

  @override
  String get group_exitGroupConfirm => 'Möchten Sie diese Gruppe verlassen?';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return 'Möchten Sie „$groupName“ wirklich verlassen? Zum erneuten Beitreten ist der Code nötig.';
  }

  @override
  String get group_exitedSuccess => 'Gruppe erfolgreich verlassen';

  @override
  String get group_goToGroups => 'Zu Gruppen gehen →';

  @override
  String get group_groupMessage => 'Gruppennachricht';

  @override
  String get group_invalidResponseFormat => 'Ungültiges Format';

  @override
  String get group_joinedJustNow => 'Gerade beigetreten';

  @override
  String get group_joinedRecently => 'Kürzlich';

  @override
  String get group_leftJustNow => 'Gerade verlassen';

  @override
  String get group_locationNoLongerShared =>
      'Ihr Standort wird nicht mehr mit dieser Gruppe geteilt';

  @override
  String get group_locationPermissionToJoin =>
      'Standortberechtigung ist erforderlich, um einer Gruppe beizutreten.';

  @override
  String get group_locationShared =>
      'Ihr Standort wird mit dieser Gruppe geteilt';

  @override
  String get group_memberFallbackName => 'Mitglied';

  @override
  String group_membersMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder · $when',
      one: '1 Mitglied · $when',
    );
    return '$_temp0';
  }

  @override
  String get group_noContactsFound => 'Keine Kontakte gefunden';

  @override
  String get group_noGroupCode => 'Kein Gruppencode verfügbar';

  @override
  String get group_noNewMessages =>
      'Sie erhalten keine neuen Nachrichten aus dieser Gruppe';

  @override
  String get group_noNumber => 'Keine Nummer';

  @override
  String get group_openGroup => 'Gruppe öffnen →';

  @override
  String get group_other => 'Andere';

  @override
  String get group_qrSavedBody => 'Tippen, um QR-Code zu öffnen';

  @override
  String get group_qrSavedTitle => 'QR-Code gespeichert';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 Gruppencode: $groupCode\n\nTreten Sie meiner Gruppe mit dem QR-Code oder obigen Code bei.\n\n📲 App herunterladen:\n$appLink';
  }

  @override
  String get group_scanToJoin => 'QR-Code scannen, um der Gruppe beizutreten';

  @override
  String get group_searchMemberHint => 'Mitglied suchen...';

  @override
  String get group_shareCodeInfo =>
      'Teilen Sie den Gruppencode, damit andere beitreten können';

  @override
  String get group_shareQr => 'QR teilen';

  @override
  String get group_shareQrToInvite =>
      'QR-Code teilen, um Mitglieder einzuladen';

  @override
  String get group_sheetCreatedSubtitle =>
      'Ihre Gruppe ist bereit. Teilen Sie den Code, damit Mitglieder beitreten können.';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name, Ihre Gruppe ist bereit. Teilen Sie den Code zum Beitreten.';
  }

  @override
  String get group_sheetCreatedTitle => 'Gruppe erstellt!';

  @override
  String get group_sheetJoinedSubtitle =>
      'Willkommen, Sie sind jetzt Mitglied dieser Gruppe.';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return 'Willkommen $name, Sie sind jetzt Mitglied dieser Gruppe.';
  }

  @override
  String get group_sheetJoinedTitle => 'Erfolgreich beigetreten!';

  @override
  String get group_sheetLeftSubtitle =>
      'Sie sind kein Mitglied dieser Gruppe mehr.';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name, Sie sind kein Mitglied dieser Gruppe mehr.';
  }

  @override
  String get group_sheetLeftTitle => 'Sie haben die Gruppe verlassen';

  @override
  String get group_showQrCode => 'QR-Code anzeigen';

  @override
  String get group_startConversation => 'Starten Sie gerne ein Gespräch';

  @override
  String get group_statusUpdateFailed =>
      'Aktualisierung des Gruppenstatus fehlgeschlagen';

  @override
  String get group_teamCode => 'Team-Code';

  @override
  String get group_teamCodeLabel => 'Team-Code: ';

  @override
  String get group_track => 'Verfolgen';

  @override
  String get group_unnamedMember => 'Unbenanntes Mitglied';

  @override
  String get group_unnamedTrip => 'Unbenannte Reise';

  @override
  String get group_updateGroupConfirm =>
      'Möchten Sie die Gruppendetails wirklich aktualisieren?';

  @override
  String get group_updateGroupTitle => 'Gruppe aktualisieren';

  @override
  String get group_youAreAdmin => 'Sie sind der Administrator dieser Gruppe';

  @override
  String get home_actionAllContacts => 'Alle Kontakte';

  @override
  String get home_actionAudioVideoCall => 'Audio-/Videoanruf';

  @override
  String get home_actionChatting => 'Chatten';

  @override
  String get home_actionSafeZone => 'Sicherheitszone';

  @override
  String get home_actionTracking => 'Ortung';

  @override
  String get home_actionWalkieTalkie => 'Walkie-Talkie';

  @override
  String get home_active => 'Aktiv';

  @override
  String get home_activeSessions => 'Aktive Sitzungen';

  @override
  String home_activeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive Sitzungen',
      one: '1 aktive Sitzung',
    );
    return '$_temp0';
  }

  @override
  String get home_allMembers => 'Alle Mitglieder';

  @override
  String get home_createGroup => 'Gruppe erstellen';

  @override
  String get home_createGroupSubtitle => 'Neue Gruppe erstellen';

  @override
  String get home_goodToSeeYou => 'Schön, Sie wiederzusehen 👋';

  @override
  String home_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gruppen',
      one: '1 Gruppe',
    );
    return '$_temp0';
  }

  @override
  String home_helloName(String name) {
    return 'Hallo $name';
  }

  @override
  String get home_inactive => 'Inaktiv';

  @override
  String get home_joinGroup => 'Gruppe beitreten';

  @override
  String get home_joinGroupSubtitle => 'Bestehender Gruppe beitreten';

  @override
  String home_lastSeen(String time) {
    return 'Zuletzt gesehen $time';
  }

  @override
  String get home_newThisMonth => 'Neu in diesem Monat';

  @override
  String get home_noActivePrivateSessions => 'Keine aktiven privaten Sitzungen';

  @override
  String get home_noGroupsAvailable => 'Keine Gruppen verfügbar';

  @override
  String get home_noGroupsFound => 'Keine Gruppen gefunden';

  @override
  String get home_noMembersFound => 'Keine Mitglieder gefunden';

  @override
  String home_noMembersMatch(String query) {
    return 'Keine Mitglieder entsprechen \'$query\'';
  }

  @override
  String get home_noMembersOnline => 'Derzeit keine Mitglieder online';

  @override
  String get home_noNameGroup => 'Gruppe ohne Namen';

  @override
  String get home_noRecentlyActiveMembers =>
      'Keine kürzlich aktiven Mitglieder';

  @override
  String get home_onlineNow => 'Jetzt online';

  @override
  String get home_peopleOnline => 'Personen online';

  @override
  String get home_peopleOnlineSubtitle =>
      'Diese Mitglieder sind gerade in der App aktiv und erreichbar.';

  @override
  String get home_privateMode => 'Privater Modus';

  @override
  String get home_privateModeIsOn => 'Privater Modus ist AN';

  @override
  String get home_privateModeOffHint =>
      'Wenn der private Modus aus ist, können andere Ihren Standort sehen.';

  @override
  String get home_privateModeOnHint =>
      'Im privaten Modus können andere Ihren Standort nicht sehen.';

  @override
  String get home_quickActionsSubtitle =>
      'Alles, was Sie brauchen, nur einen Fingertipp entfernt.';

  @override
  String get home_quickActionsTitle => 'Schnellaktionen';

  @override
  String get home_recentlyOnline => 'Kürzlich online';

  @override
  String get home_searchGroupsHint => 'Gruppen suchen...';

  @override
  String get home_searchMembersHint => 'Mitglieder suchen...';

  @override
  String get home_showLess => 'Weniger anzeigen';

  @override
  String get home_sortNameAsc => 'Sortierung: Name (A-Z)';

  @override
  String get home_sortNameDesc => 'Sortierung: Name (Z-A)';

  @override
  String home_startedAt(String time) {
    return 'Begonnen um $time';
  }

  @override
  String get home_statGroups => 'Gruppen';

  @override
  String get home_statMembers => 'Mitglieder';

  @override
  String get home_statNow => 'Jetzt';

  @override
  String get home_statTotal => 'Gesamt';

  @override
  String get home_totalMembers => 'Mitglieder insgesamt';

  @override
  String home_totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder insgesamt',
      one: '1 Mitglied insgesamt',
    );
    return '$_temp0';
  }

  @override
  String get home_unableToFetchGroups => 'Gruppen konnten nicht geladen werden';

  @override
  String get home_unknownMember => 'Unbekanntes Mitglied';

  @override
  String get home_upgradeSubtitle =>
      'Schalten Sie erweiterte Funktionen für Ihr Team frei';

  @override
  String get home_upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get home_viewPlans => 'Pläne anzeigen';

  @override
  String get home_walkieExpired => 'Abgelaufen';

  @override
  String get home_walkieOneHourFree => '1 Std. gratis';

  @override
  String get home_walkieRenew => 'Verlängern';

  @override
  String get home_walkieSubscribed => 'Abonniert';

  @override
  String get home_youAreInvisible => 'Sie sind unsichtbar';

  @override
  String get home_youAreVisible => 'Sie sind sichtbar';

  @override
  String get http_networkError =>
      'Ein Fehler ist aufgetreten. Bitte versuche es erneut!';

  @override
  String get http_sessionExpired =>
      'Sitzung abgelaufen. Bitte erneut anmelden.';

  @override
  String get http_unexpectedError =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte erneut versuchen.';

  @override
  String get imagePicker_camera => 'Kamera';

  @override
  String get imagePicker_cancel => 'Abbrechen';

  @override
  String get imagePicker_cropTitle => 'Bild zuschneiden';

  @override
  String get imagePicker_gallery => 'Galerie';

  @override
  String get imagePicker_title => 'Option auswählen';

  @override
  String get intro_realTimeTrackingSubtitle =>
      'Sehen Sie Live-Standorte von Freunden, Familie oder Teammitgliedern sofort auf der Karte.';

  @override
  String get intro_realTimeTrackingTitle => 'Echtzeit-Tracking';

  @override
  String get intro_secureSubtitle =>
      'Teilen Sie Ihren Live-Standort sicher\nund privat mit ausgewählten Kontakten.';

  @override
  String get intro_secureTitle => 'Sicher & Einfach';

  @override
  String get intro_skip => 'Überspringen';

  @override
  String get intro_walkieSubtitle =>
      'Kein Netz? Kein Problem. Bleiben Sie\nüberall verbunden.';

  @override
  String get intro_walkieTitle => 'Walkie-Talkie-\nFunktion';

  @override
  String get media_cannotOpen => 'Kann nicht geöffnet werden';

  @override
  String get media_documentNotFound => 'Dokument nicht gefunden';

  @override
  String get media_invalidLink => 'Ungültiger Link';

  @override
  String get media_noDocuments => 'Keine Dokumente gefunden';

  @override
  String get media_noLinks => 'Keine Links gefunden';

  @override
  String get media_noMedia => 'Keine Medien gefunden';

  @override
  String get media_tabDocs => 'Dokumente';

  @override
  String media_tabDocsCount(int count) {
    return 'Dokumente ($count)';
  }

  @override
  String get media_tabLinks => 'Links';

  @override
  String media_tabLinksCount(int count) {
    return 'Links ($count)';
  }

  @override
  String get media_tabMedia => 'Medien';

  @override
  String media_tabMediaCount(int count) {
    return 'Medien ($count)';
  }

  @override
  String get media_title => 'Medien, Links und Doks';

  @override
  String get media_videoNotFound => 'Video nicht gefunden';

  @override
  String get menu_contactUsSubtitle => 'Erfahren Sie mehr über uns';

  @override
  String get menu_editProfile => 'Profil bearbeiten';

  @override
  String get menu_editProfileSubtitle => 'Aktualisieren Sie Ihre Daten';

  @override
  String get menu_followUsOn => 'Folgen Sie uns auf';

  @override
  String get menu_logOut => 'Abmelden';

  @override
  String get menu_logOutConfirmMessage => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get menu_logOutSubtitle => 'Von der App abmelden';

  @override
  String get menu_profileImageUpdateFailed =>
      'Profilbild konnte nicht aktualisiert werden';

  @override
  String get menu_profileImageUpdated => 'Profilbild erfolgreich aktualisiert';

  @override
  String get notif_accept => 'Annehmen';

  @override
  String get notif_channelHighImportanceDesc =>
      'Standardkanal für wichtige Benachrichtigungen';

  @override
  String get notif_channelHighImportanceName => 'Wichtige Benachrichtigungen';

  @override
  String get notif_channelWalkieAudioDesc =>
      'Ermöglicht Live-Sprachkommunikation und Mikrofonaufnahme im Hintergrund';

  @override
  String get notif_channelWalkieAudioName => 'Live-Audio von Walkie-Talkie';

  @override
  String get notif_channelWalkieCallsDesc => 'Eingehende Walkie-Talkie-Anrufe';

  @override
  String get notif_channelWalkieCallsName => 'Walkie-Talkie-Anrufe';

  @override
  String get notif_channelWalkieDesc =>
      'Gruppen-Walkie-Anrufe und Sprech-Updates';

  @override
  String get notif_channelWalkieLiveDesc =>
      'Benachrichtigungen für aktive Walkie-Talkie-Kanäle';

  @override
  String get notif_channelWalkieLiveName => 'Live-Walkie-Talkie-Kanäle';

  @override
  String get notif_channelWalkieName => 'Walkie-Talkie';

  @override
  String notif_connectedIn(String group) {
    return 'Verbunden in $group • Live-Audiostream';
  }

  @override
  String get notif_goToWalkie => 'Zum Walkie-Bildschirm gehen';

  @override
  String get notif_incomingWalkieTitle => 'Eingehender Walkie-Talkie-Anruf';

  @override
  String notif_isTalking(String name) {
    return '$name spricht';
  }

  @override
  String get notif_leave => 'Verlassen';

  @override
  String get notif_openWalkie => 'Walkie öffnen';

  @override
  String get notif_reject => 'Ablehnen';

  @override
  String notif_stoppedTalking(String name) {
    return '$name hat aufgehört zu sprechen';
  }

  @override
  String get notif_walkieActiveConversation =>
      'Aktive Walkie-Talkie-Unterhaltung';

  @override
  String get notif_walkieActiveTitle => 'Walkie-Talkie aktiv';

  @override
  String notif_wantsToTalk(String name) {
    return '$name möchte sprechen';
  }

  @override
  String get notifications_clearAll => 'Alle Benachrichtigungen löschen';

  @override
  String get notifications_clearedSuccess =>
      'Alle Benachrichtigungen erfolgreich gelöscht';

  @override
  String get notifications_emptySubtitle =>
      'Sie haben derzeit keine neuen Warnungen.';

  @override
  String get notifications_emptyTitle => 'Noch keine Benachrichtigungen';

  @override
  String get notifications_filterAll => 'Alle';

  @override
  String get notifications_filterCalls => 'Anrufe';

  @override
  String get notifications_filterChats => 'Chats';

  @override
  String get notifications_filterUnread => 'Ungelesen';

  @override
  String get notifications_loadingDetails =>
      'Benachrichtigungsdetails werden geladen';

  @override
  String get notifications_recentCalls => 'Letzte Anrufe';

  @override
  String get notifications_title => 'Benachrichtigungen';

  @override
  String get otpCharges_chargedNotice =>
      'Ab jetzt ist jeder Login-OTP kostenpflichtig. Erneutes Senden ist kostenlos (bis zu 3 Versuche).';

  @override
  String get otpCharges_chargesApplyTo => 'Gebühren gelten für';

  @override
  String get otpCharges_eachOtpCosts => 'Jeder OTP kostet';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'Jeder OTP kostet $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'Jeder OTP kostet $amount, inklusive $percent% MwSt.';
  }

  @override
  String get otpCharges_firstLoginFree => 'Ihr erster Login war kostenlos.';

  @override
  String get otpCharges_freeBody =>
      'Login-OTPs an diese Nummer sind gebührenfrei.';

  @override
  String get otpCharges_freeTitle => 'OTP ist für Ihre Nummer kostenlos';

  @override
  String otpCharges_gstTitle(String percent) {
    return 'MwSt. ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return 'Inkl. $percent% MwSt.';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return 'Inkl. $percent% Steuern';
  }

  @override
  String get otpCharges_noInternet =>
      'Keine Internetverbindung. Prüfen Sie Ihr Netzwerk und versuchen Sie es erneut.';

  @override
  String get otpCharges_otpCharge => 'OTP-Gebühr';

  @override
  String otpCharges_pay(String amount) {
    return '$amount bezahlen';
  }

  @override
  String get otpCharges_paymentCancelled =>
      'Zahlung abgebrochen. Sie haben abgebrochen. Es wurde kein Geld abgebucht.';

  @override
  String get otpCharges_paymentFailed =>
      'Zahlung fehlgeschlagen. Abgebuchtes Geld wird in 5–7 Werktagen erstattet.';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return 'Zahlung pausiert ($amount)';
  }

  @override
  String get otpCharges_paymentReceived =>
      'Zahlung erhalten. Ihr OTP benötigt eventuell einen Moment.';

  @override
  String get otpCharges_paymentStartFailed =>
      'Zahlung konnte nicht gestartet werden. Bitte erneut versuchen.';

  @override
  String get otpCharges_paymentsPaused =>
      'OTP-Zahlungen wurden vorübergehend pausiert. Für Details unten tippen.';

  @override
  String get otpCharges_paymentsUnavailable =>
      'OTP-Zahlungen sind vorübergehend nicht verfügbar. Später erneut versuchen.';

  @override
  String get otpCharges_sessionExpired =>
      'Sitzung abgelaufen. Bitte neu starten.';

  @override
  String get otpCharges_title => 'OTP-Gebühren';

  @override
  String get otpCharges_totalPerOtp => 'Gesamt pro OTP';

  @override
  String get otpCharges_tryAgainMoment =>
      'Etwas ist schiefgelaufen. Bitte versuchen Sie es gleich erneut.';

  @override
  String get otpCharges_unknownBody =>
      'Login-OTPs an indische Nummern sind kostenlos. Für andere Länder wird der Betrag vor der Zahlung angezeigt.';

  @override
  String get otpCharges_unknownTitle => 'OTP-Gebühren hängen von Ihrem Land ab';

  @override
  String get otpCharges_updateApp =>
      'Zahlung konnte nicht starten. Bitte aktualisieren Sie die App.';

  @override
  String otpCharges_vatTitle(String percent) {
    return 'MwSt. / Steuer ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      'Zahlungsverifizierung fehlgeschlagen. Abgebuchtes Geld wird in 5–7 Werktagen erstattet.';

  @override
  String get otpCharges_yourNumber => 'Ihre Nummer';

  @override
  String get package_noPackages => 'Derzeit sind keine Pakete verfügbar.';

  @override
  String package_plansComingSoon(String title) {
    return '$title-Pläne sind bald verfügbar';
  }

  @override
  String get package_subtitle => 'Wählen Sie ein Modul, um Pläne zu sehen';

  @override
  String get package_title => 'Pakete & Preise';

  @override
  String get package_viewPlans => 'Pläne anzeigen';

  @override
  String get perm_alwaysLocationBody =>
      'Um deine Gruppe in Echtzeit und im Hintergrund zu verfolgen, setze den Standortzugriff in den App-Einstellungen bitte auf \'Immer zulassen\'.';

  @override
  String get perm_alwaysLocationTitle =>
      'Berechtigung \'Immer\' für den Standort aktivieren';

  @override
  String get perm_chooseAllowAllTime =>
      'Bitte wähle \'Immer zulassen\' im folgenden Popup.';

  @override
  String get perm_collectsLocationBody =>
      'Diese App erfasst Standortdaten, um einen reibungslosen Ablauf und effizientes Tracking zu gewährleisten, auch wenn die App geschlossen ist oder nicht verwendet wird.';

  @override
  String get perm_enableDeviceGpsBody =>
      'Bitte aktiviere das GPS deines Geräts (Google Standort).';

  @override
  String get perm_enableGpsTitle => 'GPS aktivieren';

  @override
  String get perm_exitBody => 'Möchtest du die App beenden?';

  @override
  String get perm_exitTitle => 'Bist du sicher?';

  @override
  String get perm_gpsRequiredBody =>
      'GPS ist erforderlich, um deine Gruppe in Echtzeit zu verfolgen.';

  @override
  String get perm_locationTitle => 'Standortberechtigung';

  @override
  String get perm_trackingPermissionBody =>
      'Die FG Partner App benötigt deine Erlaubnis, den Standort zu erfassen, während du angemeldet bist.';

  @override
  String get permission_allowAllTheTime => 'Immer zulassen';

  @override
  String get permission_allowLocation => 'Standort zulassen';

  @override
  String get permission_allowLocationFirst =>
      'Bitte zuerst den Standort erlauben.';

  @override
  String permission_allowNamed(String permission) {
    return '$permission zulassen';
  }

  @override
  String get permission_allowNotifications => 'Benachrichtigungen zulassen';

  @override
  String get permission_appPermissionsSubtitle =>
      'Überprüfen Sie die erforderlichen Berechtigungen.';

  @override
  String get permission_appPermissionsTitle => 'App-Berechtigungen';

  @override
  String get permission_badgeGranted => 'Erteilt';

  @override
  String get permission_badgeOptional => 'Optional';

  @override
  String get permission_badgeRecommended => 'Empfohlen';

  @override
  String get permission_badgeRequired => 'Erforderlich';

  @override
  String get permission_camera => 'Kamera';

  @override
  String get permission_cameraDescription =>
      'Wird für Funktionen genutzt, die Fotos oder Videos aufnehmen.';

  @override
  String get permission_cameraSettingsMessage =>
      'Kameraberechtigung wird zum Aufnehmen von Fotos/Videos benötigt. Bitte in den Einstellungen aktivieren.';

  @override
  String get permission_cameraWhy =>
      'Ermöglicht das Aufnehmen von Fotos und Videos für Profil, Chat und weitere Funktionen.';

  @override
  String get permission_contacts => 'Kontakte';

  @override
  String get permission_contactsDescription =>
      'Wird verwendet, um Kontakte in der App zu finden oder auszuwählen.';

  @override
  String get permission_contactsSettingsMessage =>
      'Kontaktberechtigung wird benötigt, um Kontakte zu finden. Bitte in den Einstellungen aktivieren.';

  @override
  String get permission_contactsWhy =>
      'Hilft Ihnen, Kontakte schnell zu finden und auszuwählen.';

  @override
  String get permission_gateCheckFailed =>
      'Berechtigungen konnten nicht überprüft werden. Bitte erneut versuchen.';

  @override
  String get permission_gateSubtitle =>
      'FG Tracker benötigt diese Berechtigungen für Anrufe, Warnungen, Anwesenheitserfassung, Live-Tracking und Sicherheitszonen.';

  @override
  String get permission_gateTitle => 'Berechtigungen erforderlich';

  @override
  String get permission_genericSettingsMessage =>
      'Diese Berechtigung wird benötigt. Bitte in den Einstellungen aktivieren.';

  @override
  String get permission_iosLocationServicesOff =>
      'Ortungsdienste sind deaktiviert. Einstellungen → Datenschutz & Sicherheit → Ortungsdienste öffnen und aktivieren.';

  @override
  String get permission_location => 'Standort';

  @override
  String get permission_locationAndNotificationRequired =>
      'Standort- und Benachrichtigungsberechtigungen sind erforderlich.';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      'Standort und Benachrichtigungen sind zum Fortfahren erforderlich.';

  @override
  String get permission_locationDescription =>
      'Wird für Anwesenheit, Live-Tracking und Sicherheitszone benötigt – auch im Hintergrund.';

  @override
  String get permission_locationRequiredToContinue =>
      'Standortberechtigung ist erforderlich, um fortzufahren.';

  @override
  String get permission_locationStatusApproximate =>
      'Nur ungefährer Standort erlaubt. Genau ist erforderlich.';

  @override
  String get permission_locationStatusBlocked =>
      'Standort ist blockiert. In den Einstellungen aktivieren.';

  @override
  String get permission_locationStatusDone =>
      'Immer zugelassen · Genau · GPS ein';

  @override
  String get permission_locationStatusGpsOff =>
      'Gerätestandort (GPS) ist ausgeschaltet.';

  @override
  String get permission_locationStatusNeedAlways =>
      '„Immer zulassen“ ist erforderlich.';

  @override
  String get permission_locationStatusNotAllowed =>
      'Standortberechtigung noch nicht erteilt.';

  @override
  String get permission_locationWhyExtra =>
      'Bitte wählen Sie „Immer zulassen“ und lassen Sie den genauen Standort an.';

  @override
  String get permission_logout => 'Abmelden';

  @override
  String get permission_microphone => 'Mikrofon / Audio';

  @override
  String get permission_microphoneDescription =>
      'Wird für Sprach-, Walkie-Talkie- und Anruffunktionen verwendet.';

  @override
  String get permission_microphoneSettingsMessage =>
      'Mikrofonberechtigung wird für Sprache, Walkie-Talkie und Anrufe benötigt. Bitte in den Einstellungen aktivieren.';

  @override
  String get permission_microphoneWhy =>
      'Ermöglicht Sprachkommunikation, Walkie-Talkie-Übertragung und Anrufe.';

  @override
  String permission_notGrantedNamed(String permission) {
    return 'Berechtigung $permission wurde nicht erteilt. Bitte erneut versuchen.';
  }

  @override
  String get permission_notificationRequiredToContinue =>
      'Benachrichtigungsberechtigung erforderlich, um fortzufahren.';

  @override
  String get permission_notificationSettingsText =>
      'Benachrichtigungen sind für FG Tracker ausgeschaltet. Einstellungen → Benachrichtigungen öffnen und zulassen.';

  @override
  String get permission_notificationStatusBlocked =>
      'Benachrichtigungen blockiert. In den Einstellungen aktivieren.';

  @override
  String get permission_notificationStatusDone => 'Zugelassen';

  @override
  String get permission_notificationStatusNotAllowed =>
      'Benachrichtigungsberechtigung noch nicht erteilt.';

  @override
  String get permission_notifications => 'Benachrichtigungen';

  @override
  String get permission_notificationsDescription =>
      'Erforderlich für eingehende Anrufe, Chatnachrichten und Sicherheitswarnungen.';

  @override
  String get permission_notificationsWhyExtra =>
      'Eingehende Anrufe können ohne diese Berechtigung nicht klingeln.';

  @override
  String get permission_openSettings => 'Einstellungen öffnen';

  @override
  String get permission_preciseLocation => 'Genauer Standort';

  @override
  String get permission_pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get permission_reasonLocation =>
      'Der Standort wird für Anwesenheit, Live-Tracking und Sicherheitszonen-Warnungen benötigt.';

  @override
  String get permission_reasonLocationAlways =>
      'Wählen Sie „Immer zulassen“, damit Live-Tracking und Sicherheitszone auch im Hintergrund funktionieren.';

  @override
  String get permission_reasonNotification =>
      'Benachrichtigungen werden für Anrufe, Chats und Sicherheitswarnungen benötigt.';

  @override
  String get permission_reasonPrecise =>
      'Ein genauer Standort wird für verlässliche Anwesenheit, Live-Tracking und Warnungen benötigt.';

  @override
  String get permission_required => 'Berechtigung erforderlich';

  @override
  String get permission_selectAllowAllTheTime =>
      'Bitte wählen Sie „Immer zulassen“, um fortzufahren.';

  @override
  String get permission_settingsAndroidAlways =>
      'Einstellungen → Berechtigungen → Standort öffnen und „Immer zulassen“ wählen.';

  @override
  String get permission_settingsAndroidBlocked =>
      'Standortzugriff für FG Tracker blockiert. Einstellungen → Berechtigungen → Standort öffnen und „Immer zulassen“ wählen.';

  @override
  String get permission_settingsAndroidPrecise =>
      'Einstellungen → Berechtigungen → Standort öffnen und „Genauen Standort verwenden“ aktivieren.';

  @override
  String get permission_settingsIosAlways =>
      'Einstellungen → Standort öffnen und „Immer“ wählen.';

  @override
  String get permission_settingsIosBlocked =>
      'Standortzugriff für FG Tracker deaktiviert. Einstellungen → Standort öffnen und „Immer“ wählen.';

  @override
  String get permission_settingsIosPrecise =>
      'Einstellungen → Standort öffnen und „Genauer Standort“ aktivieren.';

  @override
  String get permission_skipAndContinue => 'Überspringen & Weiter';

  @override
  String get permission_turnOnLocation => 'Standort einschalten';

  @override
  String get permission_turnOnPreciseLocation => 'Genaue Position aktivieren';

  @override
  String get permission_unableToRequest =>
      'Berechtigung konnte nicht angefordert werden.';

  @override
  String get permission_whyWeNeedThis => 'Warum wird dies benötigt?';

  @override
  String get registration_contactNumberHint => 'Kontaktnummer eingeben';

  @override
  String get registration_contactNumberLabel => 'Kontaktnummer';

  @override
  String get registration_doneButton => 'Fertig';

  @override
  String get registration_emailHint => 'E-Mail-Adresse eingeben';

  @override
  String get registration_emailLabel => 'E-Mail-Adresse';

  @override
  String get registration_genderFemale => 'Weiblich';

  @override
  String get registration_genderLabel => 'Geschlecht auswählen';

  @override
  String get registration_genderMale => 'Männlich';

  @override
  String get registration_genderOther => 'Divers';

  @override
  String get registration_selectGenderError => 'Bitte wähle dein Geschlecht';

  @override
  String get registration_userNameHint => 'Benutzernamen eingeben';

  @override
  String get registration_userNameLabel => 'Benutzername';

  @override
  String get repo_allCallsCleared =>
      'Gesamter Anrufverlauf erfolgreich gelöscht';

  @override
  String get repo_callDeleted => 'Anrufverlauf erfolgreich gelöscht';

  @override
  String get repo_invalidResponse => 'Ungültiges Antwortformat';

  @override
  String get repo_loadLocationsFailed =>
      'Gruppenstandorte konnten nicht geladen werden';

  @override
  String get repo_pkgConflict =>
      'Dieser Plan ist bereits aktiv oder eine Zahlung wird verarbeitet.';

  @override
  String get repo_pkgNotFound =>
      'Pläne sind derzeit nicht verfügbar. Bitte versuche es später erneut.';

  @override
  String get repo_pkgOffline =>
      'Keine Internetverbindung. Prüfe dein Netzwerk und versuche es erneut.';

  @override
  String get repo_pkgSessionExpired =>
      'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.';

  @override
  String get repo_pkgTimeout =>
      'Der Server braucht zu lange zum Antworten. Bitte versuche es erneut.';

  @override
  String get repo_selectedCallsDeleted =>
      'Ausgewählte Anrufe erfolgreich gelöscht';

  @override
  String get repo_unnamedGroup => 'Unbenannte Gruppe';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return 'Gesamtdistanz: $distance  •  Zulässige Abweichung: $deviation';
  }

  @override
  String get safeRoute_activeTitle => 'Aktive sichere Route';

  @override
  String get safeRoute_alertSettingsDesc =>
      'Routenalarme, Abweichungslimits und Benachrichtigungen verwalten.';

  @override
  String get safeRoute_alertSheetDesc =>
      'Echtzeit-Warnungen bei Abweichung von der Route';

  @override
  String get safeRoute_alertTitle => 'Sichere-Route-Alarm';

  @override
  String get safeRoute_appBarSubtitle =>
      'Legen Sie eine sichere Route für Ihr Mitglied fest.';

  @override
  String get safeRoute_destination => 'Zielort';

  @override
  String get safeRoute_deviated => 'Von sicherer Route abgewichen';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'Alarm wird ausgelöst, wenn das Mitglied mehr als $distance abweicht.';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (Abweichung: $distance)';
  }

  @override
  String get safeRoute_deviationLimit => 'Abweichungslimit';

  @override
  String get safeRoute_deviationSubtitle =>
      'Legen Sie die zulässige Abweichung von der Route fest.';

  @override
  String get safeRoute_distance => 'Entfernung';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance km • $minutes Min.';
  }

  @override
  String get safeRoute_edit => 'Sichere Route bearbeiten';

  @override
  String get safeRoute_end => 'Ende';

  @override
  String safeRoute_estTime(int minutes) {
    return 'Geschätzte Zeit: $minutes Min.';
  }

  @override
  String get safeRoute_featureDesc =>
      'Legen Sie Routen fest. Erhalten Sie Warnungen bei Abweichungen von der Route.';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$group ($_temp0)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'Erlaubte Entfernung zur Route. Sie erhalten eine Warnung, falls diese überschritten wird.';

  @override
  String get safeRoute_helpDeviationTitle => 'Was ist das Abweichungslimit?';

  @override
  String get safeRoute_helpHowBody =>
      'Mitglied wählen, Start und Ziel bestimmen, Route aussuchen und Abweichungslimit setzen.';

  @override
  String get safeRoute_helpHowTitle => 'Wie erstelle ich eine sichere Route?';

  @override
  String get safeRoute_helpTitle => 'Sichere-Route-Hilfe';

  @override
  String get safeRoute_helpWhatBody =>
      'Legen Sie Start und Ziel fest, um eine sichere Reiseroute zu erstellen.';

  @override
  String get safeRoute_helpWhatTitle => 'Was ist eine sichere Route?';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$name ist von der sicheren Route abgewichen';
  }

  @override
  String get safeRoute_recommended => 'Empfohlen';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (Empfohlen)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'Route ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'Sichere Route speichern & aktivieren';

  @override
  String get safeRoute_saveActivateGroup =>
      'Sichere Route für Gruppe speichern & aktivieren';

  @override
  String get safeRoute_selectedRoute => 'Ausgewählte Route';

  @override
  String get safeRoute_setRoutesSubtitle =>
      'Erstellen und verwalten Sie Routen für alle Gruppenmitglieder.';

  @override
  String get safeRoute_start => 'Start';

  @override
  String get safeRoute_startLocation => 'Startort';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. Abweichungslimit festlegen';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. Vorschau & Anwenden';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. Routenvorschau';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. Route auswählen';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. Routen für Mitglieder festlegen';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. Start & Ziel festlegen';
  }

  @override
  String get safeRoute_subtitle => 'Routenschutz';

  @override
  String get safeRoute_title => 'Sichere Route';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return 'Radius: $radius  •  Zentrum: $center';
  }

  @override
  String get safeZone_activePreview => 'Aktiv (Vorschau)';

  @override
  String get safeZone_activeTitle => 'Aktive Sicherheitszone';

  @override
  String get safeZone_alertSettingsDesc =>
      'Sicherheitszone, Alarmdistanz und Benachrichtigungen verwalten';

  @override
  String get safeZone_alertSheetDesc =>
      'Echtzeit-Warnungen beim Verlassen der Sicherheitszone';

  @override
  String get safeZone_alertTitle => 'Sicherheitszonen-Alarm';

  @override
  String safeZone_allMonitored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Alle $count Mitglieder werden in dieser\nSicherheitszone überwacht.',
      one: '1 Mitglied wird in dieser\nSicherheitszone überwacht.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_appBarSubtitle =>
      'Sicheren Bereich festlegen. Warnung erhalten, wenn\njemand die Zone verlässt.';

  @override
  String safeZone_appliedToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Diese Sicherheitszone gilt für alle $count Mitglieder der Gruppe.',
      one:
          'Diese Sicherheitszone gilt für das 1 Mitglied der ausgewählten Gruppe.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_edit => 'Sicherheitszone bearbeiten';

  @override
  String get safeZone_exited => 'Sicherheitszone verlassen';

  @override
  String get safeZone_featureDesc =>
      'Definieren Sie einen sicheren Bereich. Erhalten Sie Warnungen, wenn jemand die Zone verlässt.';

  @override
  String get safeZone_helpHowBody =>
      'Wählen Sie ein Mitglied, einen Ort auf der Karte und legen Sie den Radius fest.';

  @override
  String get safeZone_helpHowTitle => 'Wie erstelle ich eine Sicherheitszone?';

  @override
  String get safeZone_helpRadiusBody =>
      'Wählen Sie den Radius (500 m, 1 km, 2 km oder 5 km) nach Bedarf.';

  @override
  String get safeZone_helpRadiusTitle => 'Was ist der Sicherheitszonen-Radius?';

  @override
  String get safeZone_helpTitle => 'Sicherheitszonen-Hilfe';

  @override
  String get safeZone_helpWhatBody =>
      'Legen Sie einen Bereich fest und erhalten Sie Warnungen beim Verlassen.';

  @override
  String get safeZone_helpWhatTitle => 'Was ist eine Sicherheitszone?';

  @override
  String safeZone_memberLeft(String name) {
    return '$name hat die Sicherheitszone verlassen';
  }

  @override
  String get safeZone_membersMonitored =>
      'Mitglieder werden innerhalb dieser Zone überwacht.';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return 'Nahe $place (Außerhalb von $zone)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place (Außerhalb von $zone)';
  }

  @override
  String get safeZone_saveActivate => 'Sicherheitszone speichern & aktivieren';

  @override
  String get safeZone_saveActivateGroup =>
      'Sicherheitszone für Gruppe speichern & aktivieren';

  @override
  String get safeZone_searchLocation => 'Ort suchen...';

  @override
  String get safeZone_statusLabel => 'Status:';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. Sicherheitszone vorschauen';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. Sicherheitszonen-Radius festlegen';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. Ort auf der Karte auswählen';
  }

  @override
  String get safeZone_subtitle => 'Bereichsschutz';

  @override
  String get safeZone_title => 'Sicherheitszone';

  @override
  String safeZone_totalMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Insgesamt $count Mitglieder',
      one: 'Insgesamt 1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get safety_active => 'Aktiv';

  @override
  String get safety_alertSettings => 'Alarmeinstellungen';

  @override
  String get safety_alerts => 'Warnungen';

  @override
  String get safety_alertsDesc => 'Sofortige Aufmerksamkeit erforderlich';

  @override
  String get safety_bannerBody =>
      'Überwachen und schützen Sie Ihr Team mit smarten Funktionen.';

  @override
  String get safety_bannerTitle => 'Ihre Sicherheit, unsere Priorität';

  @override
  String get safety_chooseFeature => 'Sicherheitsfunktion wählen';

  @override
  String get safety_comingSoonBody =>
      'Smarte Sicherheitsfunktionen zum Schutz Ihres Teams kommen bald.';

  @override
  String get safety_contactSupport => 'Support kontaktieren';

  @override
  String get safety_editAnytime =>
      'Sie können dies später jederzeit bearbeiten oder deaktivieren.';

  @override
  String get safety_mapCityPark => 'Stadtpark';

  @override
  String get safety_mapMainRoad => 'Hauptstraße';

  @override
  String get safety_mapMarketLane => 'Marktgasse';

  @override
  String get safety_mapRiver => 'Fluss';

  @override
  String get safety_mapStationRoad => 'Bahnhofstraße';

  @override
  String get safety_needHelpBody =>
      'Kontaktieren Sie den Support bei Sicherheitsfragen.';

  @override
  String get safety_quickOverview => 'Kurzübersicht';

  @override
  String get safety_recentAlerts => 'Letzte Warnungen';

  @override
  String get safety_recenter => 'Neu zentrieren';

  @override
  String get safety_safeNow => 'Jetzt sicher';

  @override
  String get safety_safeNowDesc => 'Mitglieder sind in der sicheren Zone/Route';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. Gruppe auswählen';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. Mitglied auswählen';
  }

  @override
  String get safety_tabIndividual => 'Einzeln';

  @override
  String get safety_tagline => 'Bleiben Sie geschützt. Bleiben Sie verbunden.';

  @override
  String get safety_title => 'Sicherheit';

  @override
  String get safety_viewAllMembers => 'Alle Mitglieder anzeigen';

  @override
  String get sheet_addGroupMember => 'Gruppenmitglied hinzufügen';

  @override
  String get sheet_admin => 'Admin';

  @override
  String get sheet_attachSubtitle => 'Teile Dateien und Medien mit deinem Team';

  @override
  String get sheet_attachUpload => 'Anhängen / Hochladen';

  @override
  String get sheet_attendance => 'Anwesenheit';

  @override
  String get sheet_callOptions => 'Anrufoptionen';

  @override
  String get sheet_cantRemoveSelf =>
      'Du kannst dich nicht selbst aus der Gruppe entfernen.';

  @override
  String get sheet_contact => 'Kontakt';

  @override
  String get sheet_contactsNotOnApp =>
      'Deine Kontakte nutzen FG Tracker noch nicht.';

  @override
  String get sheet_document => 'Dokument';

  @override
  String get sheet_groupMembers => 'Gruppenmitglieder';

  @override
  String get sheet_location => 'Standort';

  @override
  String get sheet_memberRemoved => 'Mitglied erfolgreich entfernt';

  @override
  String get sheet_noMembers => 'Keine Mitglieder gefunden';

  @override
  String get sheet_noRegisteredContacts => 'Keine registrierten Kontakte';

  @override
  String get sheet_noUserFound => 'Kein Benutzer gefunden';

  @override
  String get sheet_normalAudioCall => 'Normaler Sprachanruf';

  @override
  String get sheet_normalAudioCallSubtitle => 'Klare Standard-Sprachqualität';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registrierte Kontakte',
      one: '1 registrierter Kontakt',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return 'Möchtest du $name wirklich aus der Gruppe entfernen?';
  }

  @override
  String get sheet_removeMemberTitle => 'Mitglied entfernen';

  @override
  String get sheet_searchContacts => 'Kontakte suchen';

  @override
  String get sheet_walkieCall => 'Walkie-Talkie-Anruf';

  @override
  String get sheet_walkieCallSubtitle => 'Push-to-Talk-Kommunikation';

  @override
  String get sos_addDetailsMandatory => 'Details hinzufügen (erforderlich)';

  @override
  String get sos_addDetailsOptional => 'Details hinzufügen (optional)';

  @override
  String get sos_addFamilyMember => 'Familienmitglied hinzufügen';

  @override
  String get sos_addFamilyMemberRequired =>
      'Fügen Sie mindestens 1 Familienmitglied hinzu, um SOS zu senden';

  @override
  String get sos_addPhotoHint =>
      'Fügen Sie ein Foto an, um die Situation zu verdeutlichen.';

  @override
  String get sos_addPhotoOptional => 'Foto hinzufügen (optional)';

  @override
  String get sos_alertSent => 'SOS-Alarm gesendet!';

  @override
  String get sos_alertSentToNearby =>
      'Ihr Alarm wurde an Personen in der Nähe gesendet.';

  @override
  String get sos_alertWillBeSent =>
      'Alarm wird an Personen in der Nähe gesendet';

  @override
  String get sos_alertWillBeSentFamily =>
      'Ihr Alarm wird an Personen in der Nähe und Ihre Familie gesendet.';

  @override
  String sos_availableUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verfügbare Benutzer',
      one: '1 verfügbarer Benutzer',
    );
    return '$_temp0';
  }

  @override
  String get sos_detailsHint => 'Weitere Details eingeben...';

  @override
  String get sos_detailsMandatoryForOther =>
      'Details sind erforderlich, wenn \'Andere\' ausgewählt ist';

  @override
  String get sos_howItWorks => 'Wie es funktioniert';

  @override
  String get sos_howItWorksIntro =>
      'Der SOS-Alarm benachrichtigt Personen in der Nähe und Ihre Familie im Notfall.';

  @override
  String get sos_howItWorksTitle => 'Wie funktioniert der SOS-Alarm?';

  @override
  String get sos_liveTrackingStarted => 'Live-Tracking gestartet';

  @override
  String sos_locationSharedWithFamily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ihr Standort wird mit $count Familienmitgliedern geteilt',
      one: 'Ihr Standort wird mit 1 Familienmitglied geteilt',
    );
    return '$_temp0';
  }

  @override
  String sos_membersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder ausgewählt',
      one: '1 Mitglied ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get sos_needHelp => 'Brauchen Sie Hilfe?';

  @override
  String get sos_needHelpBody =>
      'Senden Sie einen SOS-Alarm an Personen in der Nähe.\nSie werden benachrichtigt und können helfen.';

  @override
  String get sos_noMatchFound => 'Keine Übereinstimmung gefunden';

  @override
  String get sos_noUsersFound => 'Keine Benutzer gefunden';

  @override
  String get sos_notifyFamilyTitle =>
      'Familie benachrichtigen (1 bis 5 erforderlich)';

  @override
  String get sos_notifyUpdates => 'Wir informieren Sie über Neuigkeiten';

  @override
  String get sos_okGotIt => 'Verstanden';

  @override
  String get sos_peopleWithinRadius => 'Personen im Umkreis von 2 km';

  @override
  String get sos_privacyNote =>
      'Ihre Privatsphäre ist wichtig. Ihr Standort wird nur während eines aktiven SOS-Alarms geteilt.';

  @override
  String get sos_reasonAccident => 'Unfall';

  @override
  String get sos_reasonMedical => 'Medizinisch';

  @override
  String get sos_reasonOther => 'Andere';

  @override
  String get sos_reasonSafety => 'Sicherheit';

  @override
  String get sos_reasonThreat => 'Bedrohung';

  @override
  String get sos_required => 'Erforderlich';

  @override
  String get sos_searchUsers => 'Benutzer suchen';

  @override
  String get sos_selectReason => 'Grund auswählen';

  @override
  String get sos_sendSosAlert => 'SOS-Alarm senden';

  @override
  String get sos_stayCalm => 'Bleiben Sie ruhig, Hilfe ist unterwegs';

  @override
  String get sos_step1Body =>
      'Tippen Sie auf die SOS-Taste, um Personen in der Nähe zu warnen.';

  @override
  String get sos_step1Title => '1. SOS-Alarm senden';

  @override
  String get sos_step2Body =>
      'Personen in der Nähe erhalten Ihren Alarm samt Standort.';

  @override
  String get sos_step2Title => '2. Personen in der Nähe benachrichtigen';

  @override
  String get sos_step3Body =>
      'Personen in der Nähe können Ihren Alarm sehen und zur Hilfe eilen.';

  @override
  String get sos_step3Title => '3. Schneller Hilfe erhalten';

  @override
  String get sos_step4Body =>
      'Ihre Familienmitglieder werden sofort über Ihr SOS informiert.';

  @override
  String get sos_step4Title => '4. Familie wird benachrichtigt';

  @override
  String get sos_subtitle => 'Alarm an Personen in der Nähe senden';

  @override
  String get sos_title => 'SOS-Alarm';

  @override
  String get sos_willBeNotified => 'werden benachrichtigt';

  @override
  String status_activeCount(int count) {
    return '$count aktiv';
  }

  @override
  String get status_addToMyStatus => 'Zu meinem Status hinzufügen';

  @override
  String get status_allContacts => 'Alle Kontakte';

  @override
  String get status_cameraAccessFailed => 'Kamerazugriff fehlgeschlagen';

  @override
  String get status_captionHint => 'Bildunterschrift hinzufügen...';

  @override
  String get status_changeMedia => 'Medien ändern';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get status_deleted => 'Status gelöscht';

  @override
  String get status_deletedByOwner =>
      'Dieser Status wurde vom Eigentümer gelöscht';

  @override
  String get status_exceptContacts => 'Außer Kontakte';

  @override
  String get status_exceptSelected => 'Außer ausgewählte';

  @override
  String get status_flip => 'Kamera drehen';

  @override
  String get status_gallery => 'Galerie';

  @override
  String get status_modePhoto => 'Foto';

  @override
  String get status_modeText => 'Text';

  @override
  String get status_modeVideo => 'Video';

  @override
  String get status_myStatus => 'Mein Status';

  @override
  String get status_new => 'Neu';

  @override
  String get status_noCamera => 'Keine Kamera verfügbar';

  @override
  String get status_noLongerAvailable =>
      'Dieser Status ist nicht mehr verfügbar';

  @override
  String get status_noViewsYet => 'Noch keine Aufrufe';

  @override
  String get status_onlyShareWith => 'Nur teilen mit';

  @override
  String get status_pause => 'Pause';

  @override
  String get status_pinchZoomHint => 'Pinch zum Zoomen des Fotos';

  @override
  String get status_play => 'Abspielen';

  @override
  String get status_postStatus => 'Status posten';

  @override
  String get status_previewStatus => 'Statusvorschau';

  @override
  String get status_privacy => 'Privatsphäre';

  @override
  String get status_privacyTitle => 'Status-Privatsphäre';

  @override
  String get status_publishFailed =>
      'Status konnte nicht veröffentlicht werden';

  @override
  String get status_replyHint => 'Auf Status antworten...';

  @override
  String get status_retake => 'Wiederholen';

  @override
  String get status_selectPhotoFirst =>
      'Bitte zuerst ein Foto aufnehmen oder auswählen';

  @override
  String get status_selectVideoFirst =>
      'Bitte zuerst ein Video aufnehmen oder auswählen';

  @override
  String get status_shareUpdatesHint => 'Teile Updates mit deinem Team';

  @override
  String get status_tapVideoHint =>
      'Auf Video tippen zum Abspielen / Pausieren';

  @override
  String get status_textRequired =>
      'Textinhalt ist für Textstatus erforderlich';

  @override
  String get status_title => 'Status';

  @override
  String get status_typeHint => 'Status eingeben...';

  @override
  String get status_uploadFailed => 'Upload fehlgeschlagen';

  @override
  String get status_viewMyStatus => 'Meinen Status anzeigen';

  @override
  String get status_viewed => 'Gesehen';

  @override
  String status_viewedBy(int count) {
    return 'Gesehen von $count';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufrufe',
      one: '1 Aufruf',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => 'Wer kann das sehen?';

  @override
  String get track_admin => 'Admin';

  @override
  String get track_applyRadius => 'Radius anwenden';

  @override
  String get track_checkNetworkConnection =>
      'Bitte prüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut.';

  @override
  String get track_checkNetworkMembers =>
      'Bitte Netzwerk prüfen und erneut versuchen, um Mitglieder in der Nähe zu sehen.';

  @override
  String get track_currentLocation => 'Aktueller Standort';

  @override
  String get track_custom => 'Benutzerdefiniert';

  @override
  String track_customWithValue(String radius) {
    return 'Benutzerdefiniert ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return '$distance entfernt';
  }

  @override
  String get track_enable => 'Aktivieren';

  @override
  String get track_enableGpsBody =>
      'Um Ihre Gruppe in Echtzeit zu verfolgen, schalten Sie bitte Ihr GPS ein.';

  @override
  String get track_enableGpsTitle => 'GPS aktivieren';

  @override
  String get track_errorFailedLoadGroups =>
      'Gruppen konnten nicht geladen werden';

  @override
  String get track_errorLoadGroups =>
      'Gruppen konnten nicht geladen werden. Bitte erneut versuchen.';

  @override
  String get track_errorLoadMembers =>
      'Mitglieder in der Nähe konnten nicht geladen werden.';

  @override
  String get track_errorNoInternet =>
      'Keine Internetverbindung. Bitte Netzwerk prüfen.';

  @override
  String get track_errorServer =>
      'Verbindung zum Server fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String track_groupCode(String code) {
    return 'Code: $code';
  }

  @override
  String get track_groupMembers => 'Gruppenmitglieder';

  @override
  String track_groupMembersAndCode(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder • Code: $code',
      one: '1 Mitglied • Code: $code',
    );
    return '$_temp0';
  }

  @override
  String get track_groupTab => 'Gruppe';

  @override
  String track_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gruppen',
      one: '1 Gruppe',
    );
    return '$_temp0';
  }

  @override
  String track_groupsHeader(int count) {
    return 'GRUPPEN ($count)';
  }

  @override
  String get track_helpGroupBody =>
      'Erstellen Sie eine Gruppe, um mehrere Mitglieder zu verfolgen.';

  @override
  String get track_helpGroupTitle => 'Wie füge ich eine Gruppe hinzu?';

  @override
  String get track_helpLiveBody =>
      'Verfolgen Sie den Echtzeit-Standort Ihres Teams auf der Karte.';

  @override
  String get track_helpLiveTitle => 'Was ist Live-Tracking?';

  @override
  String get track_helpRadiusBody =>
      'Legen Sie den Bereich fest, um Mitglieder auf der Karte zu finden.';

  @override
  String get track_helpRadiusTitle => 'Was ist der Tracking-Radius?';

  @override
  String get track_helpTitle => 'Tracking-Hilfe';

  @override
  String track_lastSeen(String time) {
    return 'Zuletzt gesehen: $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count live';
  }

  @override
  String get track_liveMembers => 'Live-Mitglieder';

  @override
  String get track_liveTracking => 'Live-Tracking';

  @override
  String get track_locating => 'Standort wird ermittelt...';

  @override
  String get track_locationHidden => 'Standort verborgen';

  @override
  String get track_locationUnavailable => 'Standort nicht verfügbar';

  @override
  String get track_mapOfflineBody =>
      'Eine Internetverbindung ist erforderlich, um Live-Kartendaten und Mitgliederstandorte zu laden.';

  @override
  String get track_mapUnavailableOffline => 'Karte offline nicht verfügbar';

  @override
  String get track_member => 'Mitglied';

  @override
  String track_memberPausedSharing(String name) {
    return '$name hat die Standortfreigabe pausiert. Live-Standort ist nicht verfügbar.';
  }

  @override
  String track_membersHeader(int count) {
    return 'MITGLIEDER ($count)';
  }

  @override
  String track_membersLive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder live',
      one: '1 Mitglied live',
    );
    return '$_temp0';
  }

  @override
  String get track_menuMembers => 'Mitglieder';

  @override
  String get track_menuRefreshMap => 'Karte aktualisieren';

  @override
  String get track_menuTheme => 'Design';

  @override
  String get track_nearbyYou => 'In Ihrer Nähe';

  @override
  String get track_noActiveMembers => 'Keine aktiven Mitglieder';

  @override
  String track_noActiveMembersWithin(String radius) {
    return 'Keine aktiven Mitglieder im Umkreis von $radius gefunden';
  }

  @override
  String get track_noDescription => 'Keine Beschreibung';

  @override
  String get track_noGroupsFound => 'Keine Gruppen gefunden';

  @override
  String get track_noGroupsMatch => 'Keine passenden Gruppen';

  @override
  String track_noGroupsMatchQuery(String query) {
    return 'Keine Gruppen entsprechen \'$query\'';
  }

  @override
  String get track_noGroupsYet =>
      'Sie sind noch keiner Gruppe beigetreten und haben keine erstellt.';

  @override
  String get track_noInternetTitle => 'Keine Internetverbindung';

  @override
  String get track_noMembersFound => 'Keine Mitglieder gefunden';

  @override
  String get track_noMembersFoundPlain => 'Keine Mitglieder gefunden';

  @override
  String get track_noMembersInGroup =>
      'Keine Mitglieder in dieser Gruppe gefunden';

  @override
  String track_noMembersMatch(String query) {
    return 'Keine Mitglieder entsprechen \'$query\'';
  }

  @override
  String track_noSearchMatches(String query) {
    return 'Keine übereinstimmenden Mitglieder oder Gruppen';
  }

  @override
  String track_noSearchResults(String query) {
    return 'Keine Mitglieder oder Gruppen für \'$query\' gefunden';
  }

  @override
  String get track_notAvailable => 'k. A.';

  @override
  String get track_offlineBanner =>
      'Keine Internetverbindung. Karte & Tracking sind offline.';

  @override
  String get track_private => 'Privat';

  @override
  String get track_radius => 'Radius';

  @override
  String get track_refresh => 'Aktualisieren';

  @override
  String get track_refreshing => 'Wird aktualisiert...';

  @override
  String get track_retryConnection => 'Verbindung erneut versuchen';

  @override
  String get track_searchHint => 'Mitglieder oder Gruppen suchen...';

  @override
  String get track_searchMembersHint => 'Mitglieder suchen...';

  @override
  String get track_selectedLocation => 'Ausgewählter Ort';

  @override
  String get track_setRadiusSubtitle => 'Schieben, um den Radius zu wählen';

  @override
  String get track_setRadiusTitle => 'Tracking-Radius festlegen';

  @override
  String get track_unableToLoadGroups => 'Gruppen konnten nicht geladen werden';

  @override
  String get track_unableToLoadMembers =>
      'Mitglieder konnten nicht geladen werden';

  @override
  String get track_unnamedGroup => 'Gruppe ohne Namen';

  @override
  String get track_unnamedMember => 'Unbenanntes Mitglied';

  @override
  String get track_yourGroups => 'Ihre Gruppen';

  @override
  String get track_yourLocationPaused =>
      'Ihre Live-Standortfreigabe ist pausiert und privat.';

  @override
  String get util_previewContact => '👤 Kontakt';

  @override
  String get util_previewDocument => '📄 Dokument';

  @override
  String get util_previewLocation => '📍 Standort';

  @override
  String get util_previewPhoto => '📷 Foto';

  @override
  String get util_previewVideo => '🎥 Video';

  @override
  String get util_previewVoice => '🎤 Sprachnachricht';

  @override
  String util_spokenEur(String amount) {
    return '$amount Euro';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amount britische Pfund';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupees Rupien',
      one: '1 Rupie',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees Rupien und $paise Paise';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount US-Dollar';
  }

  @override
  String get util_unableToCallContact =>
      'Dieser Kontakt kann nicht angerufen werden';

  @override
  String get util_unableToStartGroupCall =>
      'Gruppenanruf kann nicht gestartet werden';

  @override
  String get validation_emailEmpty => 'E-Mail-Adresse darf nicht leer sein';

  @override
  String get validation_emailInvalid =>
      'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String validation_required(String field) {
    return '$field ist erforderlich';
  }

  @override
  String get voice_appLanguage => 'App-Sprache';

  @override
  String get voice_audioChip => 'AUDIO';

  @override
  String get voice_captionReady => 'Bildunterschrift bereit';

  @override
  String get voice_chooseSpeechLanguage => 'Sprachausgabe-Sprache wählen';

  @override
  String get voice_couldntPlay =>
      'Sprachnachricht konnte nicht abgespielt werden';

  @override
  String get voice_didntCatch =>
      'Nicht verstanden. Aufs Mikrofon tippen und lauter sprechen.';

  @override
  String get voice_language => 'Sprache';

  @override
  String get voice_listenBack => 'Anhören';

  @override
  String get voice_listenBeforeSending => 'Vor dem Absenden anhören.';

  @override
  String get voice_listening => 'Zuhören…';

  @override
  String get voice_micPermissionNeeded =>
      'Mikrofonberechtigung wird benötigt, um Sprache zu verwenden.';

  @override
  String get voice_micUnavailable =>
      'Mikrofon nicht verfügbar. Bitte Einstellungen prüfen.';

  @override
  String get voice_noTextCaptured =>
      'Kein Text erfasst – versuchen Sie die Aufnahme erneut.';

  @override
  String get voice_openSettings => 'Einstellungen öffnen';

  @override
  String get voice_permissionRequired => 'Berechtigung erforderlich';

  @override
  String get voice_reRecord => 'Neu aufnehmen';

  @override
  String get voice_readyToSend => 'Bereit zum Senden';

  @override
  String get voice_recordVoice => 'Stimme aufnehmen';

  @override
  String get voice_recordVoiceSubtitle =>
      'Aufnehmen und als Sprachnachricht senden';

  @override
  String get voice_recordingYourVoice => 'Sprachaufnahme läuft…';

  @override
  String get voice_replyReady => 'Antwort bereit';

  @override
  String get voice_reviewTextHint =>
      'Hören Sie oben Ihre Sprache ab oder bearbeiten Sie den Text vor dem Senden.';

  @override
  String get voice_sendMessage => 'Nachricht senden';

  @override
  String get voice_sendVoiceMessage => 'Sprachnachricht senden';

  @override
  String get voice_speakNowCaption =>
      'Jetzt sprechen – wir tippen Ihre Bildunterschrift';

  @override
  String get voice_speakNowMessage =>
      'Jetzt sprechen – Ihre Worte erscheinen im Textfeld';

  @override
  String get voice_speakNowReply => 'Jetzt sprechen – wir tippen Ihre Antwort';

  @override
  String get voice_speakPlaceholder => 'Sprechen Sie… Ihr Text erscheint hier';

  @override
  String get voice_speechPermissionNeeded =>
      'Spracherkennungsberechtigung ist erforderlich, um Sprache in Text umzuwandeln.';

  @override
  String get voice_tapToStop => 'Tippen zum Stoppen';

  @override
  String get voice_textReady => 'Text bereit';

  @override
  String get voice_tooMuchNoise =>
      'Zu viel Lärm – halten Sie das Telefon näher und sprechen Sie deutlich';

  @override
  String get voice_type => 'Typ';

  @override
  String get voice_voiceToText => 'Sprache zu Text';

  @override
  String get voice_voiceToTextSubtitle => 'Sprechen Sie, um Text einzugeben';

  @override
  String get voice_willSendAudioMessage =>
      'Ihre Sprache wird als Sprachnachricht gesendet';

  @override
  String get voice_willSendAudioReply =>
      'Ihre Sprache wird als Audio-Antwort gesendet';

  @override
  String get voice_willSendWithFile =>
      'Ihre Sprache wird als Audiodatei mitgesendet';

  @override
  String get voice_yourMessage => 'Ihre Nachricht';

  @override
  String get voice_yourVoiceMessage => 'Ihre Sprachnachricht';

  @override
  String get walkiePlan_availableIndividualPlans => 'Einzelpläne';

  @override
  String get walkiePlan_availablePerMonth => '/ Monat';

  @override
  String get walkiePlan_availablePerSeat => '/ Platz';

  @override
  String get walkiePlan_availableSingleMember =>
      'Einzelmitglied (Persönlicher Zugriff)';

  @override
  String get walkiePlan_availableSubtitle =>
      'Wählen Sie einen Plan zum Starten oder Upgraden';

  @override
  String get walkiePlan_availableTeamPlans => 'Team-Pläne';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min-$max Plätze  •  Gruppenzusammenarbeit';
  }

  @override
  String get walkiePlan_availableTitle => 'Verfügbare Pläne';

  @override
  String get walkiePlan_bottomBarAfterTrial => 'Nach Ihrem kostenlosen Test';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'Plan wählen';

  @override
  String get walkiePlan_bottomBarContinue => 'Mit Walkie-Talkie fortfahren';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return 'Für $price kaufen';
  }

  @override
  String get walkiePlan_cardActive => 'Aktiv';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return 'Aktiv seit $date';
  }

  @override
  String get walkiePlan_cardAssigned => 'Zugewiesen';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return 'Zugewiesen von $name';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'Ihnen zugewiesen';

  @override
  String get walkiePlan_cardAvailable => 'Verfügbar';

  @override
  String get walkiePlan_cardManageMembers => 'Mitglieder verwalten';

  @override
  String get walkiePlan_cardNoActiveIndividual =>
      'Kein aktives Einzelabonnement';

  @override
  String get walkiePlan_cardNoActiveTeam =>
      'Kein aktiver Team-Plan oder zugewiesener Platz';

  @override
  String get walkiePlan_cardOneSeatSelf => '1 Platz (Selbst)';

  @override
  String get walkiePlan_cardPersonal => 'Persönlich';

  @override
  String get walkiePlan_cardPurchased => 'Gekauft';

  @override
  String get walkiePlan_cardPurchasedByYou => 'Von Ihnen gekauft';

  @override
  String get walkiePlan_cardPurchasedOn => 'Gekauft am';

  @override
  String get walkiePlan_cardSeatsMembers => 'Plätze / Mitglieder';

  @override
  String get walkiePlan_cardSubscribedByYou => 'Von Ihnen abonniert';

  @override
  String get walkiePlan_cardTeamAdministrator => 'Team-Administrator';

  @override
  String get walkiePlan_cardValidUntil => 'Gültig bis';

  @override
  String get walkiePlan_cardView => 'Ansehen';

  @override
  String get walkiePlan_cardViewPlan => 'Plan ansehen';

  @override
  String walkiePlan_couponDiscount(String value) {
    return '$value Rabatt';
  }

  @override
  String get walkiePlan_couponExpired => 'Gutschein ist abgelaufen';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return 'Pauschal $amount RABATT';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet =>
      'Mindestbestellwert nicht erreicht';

  @override
  String get walkiePlan_couponNotEligible =>
      'Nicht für aktuellen Plan berechtigt';

  @override
  String get walkiePlan_couponNotStarted => 'Gutscheinangebot noch nicht aktiv';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent% RABATT';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable =>
      'Für diesen Plan nicht anwendbar';

  @override
  String walkiePlan_couponValidTill(String date) {
    return 'Gültig bis $date';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'Weiter zur Zahlung';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return 'Mit $plan fortfahren';
  }

  @override
  String get walkiePlan_ctrlCouponApplied =>
      'Gutschein erfolgreich angewendet!';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return 'Gutschein angewendet! Sie sparen $amount';
  }

  @override
  String get walkiePlan_ctrlCouponFailed =>
      'Gutschein konnte nicht angewendet werden';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'Gutschein entfernt';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'Cashfree-Fehler ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed =>
      'Zahlungsinitialisierung fehlgeschlagen.';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return 'Zahlungssitzung konnte nicht erstellt werden: $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return 'Zahlung konnte nicht verarbeitet werden: $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'Pläne werden geladen...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans =>
      'Pläne konnten nicht geladen werden. Bitte erneut versuchen.';

  @override
  String get walkiePlan_detailsAllBanks => 'Alle indischen Banken unterstützt';

  @override
  String get walkiePlan_detailsApplied => 'Angewendet';

  @override
  String get walkiePlan_detailsApply => 'Anwenden';

  @override
  String get walkiePlan_detailsApplyCaps => 'ANWENDEN';

  @override
  String get walkiePlan_detailsAvailableCoupons => 'Verfügbare Gutscheine';

  @override
  String get walkiePlan_detailsCard => 'Kredit- / Debitkarte';

  @override
  String get walkiePlan_detailsChooseTitle => 'Plan auswählen';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'Code: $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'Gutscheine & Angebote';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'Gutscheincode eingeben';

  @override
  String get walkiePlan_detailsEnterValidCoupon =>
      'Bitte einen gültigen Code eingeben';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'Gruppenkommunikation';

  @override
  String get walkiePlan_detailsFeatHqVoice => 'Hohe Sprachqualität';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => 'Prioritäts-Support';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => 'Unbegrenzte Reichweite';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie =>
      'Unbegrenztes Walkie-Talkie';

  @override
  String get walkiePlan_detailsHavePromoCode =>
      'Haben Sie einen Gutscheincode?';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'Nutzen Sie Walkie-Talkie mit dem passenden Plan weiter';

  @override
  String get walkiePlan_detailsLockedCaps => 'GESPERRT';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Limit von $count Mitgliedern erreicht',
      one: 'Limit von 1 Mitglied erreicht',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMemberPlural => 'Mitglieder';

  @override
  String get walkiePlan_detailsMemberSingular => 'Mitglied';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder × $rate',
      one: '1 Mitglied × $rate',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mindestgröße ist $count Mitglieder',
      one: 'Mindestgröße ist 1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody =>
      'Mitglieder jederzeit hinzufügen oder entfernen.';

  @override
  String get walkiePlan_detailsMoreMembersTitle => 'Mehr Mitglieder?';

  @override
  String get walkiePlan_detailsMostPopular => 'Beliebtest';

  @override
  String get walkiePlan_detailsNetBanking => 'Online-Banking';

  @override
  String get walkiePlan_detailsNoCouponsBody =>
      'Für diesen Plan sind aktuell keine Gutscheine vorhanden.';

  @override
  String get walkiePlan_detailsNoCouponsTitle => 'Keine Gutscheine verfügbar';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      'Derzeit sind keine Einzelpläne verfügbar. Bitte später erneut versuchen.';

  @override
  String get walkiePlan_detailsNoPlansTitle => 'Keine Pläne verfügbar';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      'Derzeit sind keine Team-Pläne verfügbar. Bitte später erneut versuchen.';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '$amount gesamt';
  }

  @override
  String get walkiePlan_detailsPayActivate => 'Zahlen & Plan aktivieren';

  @override
  String get walkiePlan_detailsPerPerson => '/ Person';

  @override
  String get walkiePlan_detailsPillAllSizes => 'jeder Größe';

  @override
  String get walkiePlan_detailsPillCommunication => 'Kommunikation';

  @override
  String get walkiePlan_detailsPillForTeams => 'Für Teams';

  @override
  String get walkiePlan_detailsPillInstant => 'Sofortige';

  @override
  String get walkiePlan_detailsPillPriority => 'Prioritäts-';

  @override
  String get walkiePlan_detailsPillReliable => 'Zuverlässig &';

  @override
  String get walkiePlan_detailsPillSecure => 'Sicher';

  @override
  String get walkiePlan_detailsPillSupport => 'Support';

  @override
  String get walkiePlan_detailsPillUnlimited => 'Unbegrenzt';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'Walkie-Talkie';

  @override
  String get walkiePlan_detailsPlanActivated => 'Plan erfolgreich aktiviert!';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'Ihr Walkie-Talkie-Plan ist aktiv. Genießen Sie unterbrechungsfreie Kommunikation.';

  @override
  String get walkiePlan_detailsPlanSummary => 'Plan-Übersicht';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'Promo ($code) angewendet';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => 'ENTFERNEN';

  @override
  String get walkiePlan_detailsSelectPaymentMethod => 'Zahlungsart wählen';

  @override
  String get walkiePlan_detailsSkeletonCouponNote =>
      'Gültig für alle Pläne • Läuft bald ab';

  @override
  String get walkiePlan_detailsStep1Subtitle =>
      'Wählen Sie die gewünschte Mitgliederanzahl';

  @override
  String get walkiePlan_detailsStep1Title => 'Anzahl der Mitglieder wählen';

  @override
  String get walkiePlan_detailsStep2Subtitle =>
      'Wählen Sie die passende Laufzeit';

  @override
  String get walkiePlan_detailsStep2Title => 'Plandauer wählen';

  @override
  String get walkiePlan_detailsSubtitleDefault =>
      'Sofortiger Walkie-Talkie-Sprachzugriff';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams =>
      'Ideal für wachsende Teams';

  @override
  String get walkiePlan_detailsSubtitleLongTerm =>
      'Am besten für langfristige Nutzung';

  @override
  String get walkiePlan_detailsSubtitleShortTerm =>
      'Perfekt für kurzfristige Nutzung';

  @override
  String get walkiePlan_detailsTabIndividual => 'Einzeln';

  @override
  String get walkiePlan_detailsTabMultipleMembers => 'Für mehrere Mitglieder';

  @override
  String get walkiePlan_detailsTabPerPerson => 'Pro Person';

  @override
  String get walkiePlan_detailsTeamSubtitle =>
      'Mitglieder hinzufügen und alle mit Walkie-Talkie verbinden';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / QR-Code';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return 'Sie sparen $amount mit diesem Gutschein!';
  }

  @override
  String get walkiePlan_durationFallback => 'Dauer';

  @override
  String get walkiePlan_durationMonthly => 'Monatlich';

  @override
  String walkiePlan_durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate',
      one: '1 Monat',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_durationQuarterly => 'Vierteljährlich';

  @override
  String get walkiePlan_durationYearly => 'Jährlich';

  @override
  String get walkiePlan_individualPlan => 'Einzelplan';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return '$interval-Plan';
  }

  @override
  String get walkiePlan_monthlyPlan => 'Monatsplan';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'Keine Internetverbindung. Bitte Netzwerk prüfen.';

  @override
  String get walkiePlan_order100Secure => '100% Sicher';

  @override
  String get walkiePlan_order3ds2Secure => '3DS2-Sicherheit';

  @override
  String get walkiePlan_orderAgreePrefix =>
      'Mit dem Fortfahren akzeptieren Sie unsere ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => 'Betrag nach Rabatt';

  @override
  String get walkiePlan_orderCards => 'Karten';

  @override
  String get walkiePlan_orderChangeMethod => 'Methode ändern';

  @override
  String get walkiePlan_orderCouldNotStart =>
      'Zahlung konnte nicht gestartet werden. Bitte erneut versuchen.';

  @override
  String get walkiePlan_orderCouponApplied =>
      'Gutschein erfolgreich angewendet!';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return 'Gutschein angewendet! Sie sparen $amount';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'Gutschein erfolgreich entfernt';

  @override
  String get walkiePlan_orderCreateFailed =>
      'Zahlungsauftrag konnte nicht erstellt werden. Bitte erneut versuchen.';

  @override
  String get walkiePlan_orderDiscount => 'Rabatt';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return 'Rabatt ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint =>
      'Wählen Sie im nächsten Schritt aus GPay, PhonePe, Karten oder Banking.';

  @override
  String get walkiePlan_orderEncryptedPayment => 'Verschlüsselte Zahlung';

  @override
  String get walkiePlan_orderEnterValidCoupon =>
      'Bitte einen gültigen Gutscheincode eingeben';

  @override
  String get walkiePlan_orderForMultipleMembers => 'Für mehrere Mitglieder';

  @override
  String get walkiePlan_orderForSingleMember => 'Für ein einzelnes Mitglied';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return 'MwSt. ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      'Sicher bezahlen mit internationalen Karten (Visa, Mastercard, Amex).';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      'Sicher bezahlen mit internationalen Karten oder PayPal.';

  @override
  String get walkiePlan_orderInvalidCoupon =>
      'Ungültiger oder abgelaufener Gutscheincode';

  @override
  String walkiePlan_orderMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'Mitglieder';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder × $rate',
      one: '1 Mitglied × $rate',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderNetBanking => 'Online-Banking';

  @override
  String get walkiePlan_orderOnlineViaRazorpay =>
      'Online-Zahlung über Razorpay';

  @override
  String get walkiePlan_orderOpeningCheckout =>
      'Razorpay-Checkout wird geöffnet...';

  @override
  String get walkiePlan_orderPaymentDetails => 'Zahlungsdetails';

  @override
  String get walkiePlan_orderPaymentMethod => 'Zahlungsmethode';

  @override
  String get walkiePlan_orderPricePerMember => 'Preis pro Mitglied';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return 'Zur Zahlung fortfahren • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => 'Zahlung wird verarbeitet...';

  @override
  String get walkiePlan_orderRetryPay => 'Zahlung wiederholen';

  @override
  String get walkiePlan_orderSecureBadge => 'SICHER';

  @override
  String get walkiePlan_orderSubtitle =>
      'Plandetails prüfen & zur Zahlung übergehen';

  @override
  String get walkiePlan_orderSubtotal => 'Zwischensumme';

  @override
  String get walkiePlan_orderTaxExport => 'Steuer (0% Export)';

  @override
  String get walkiePlan_orderTermsConditions =>
      'Allgemeine Geschäftsbedingungen';

  @override
  String get walkiePlan_orderTitle => 'Bestellübersicht';

  @override
  String get walkiePlan_orderTotalAmount => 'Gesamtbetrag';

  @override
  String get walkiePlan_orderTotalPayable => 'Gesamt zu zahlen';

  @override
  String get walkiePlan_orderUnableToLoad =>
      'Bestellübersicht konnte nicht geladen werden.';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return 'MwSt. / Steuer ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => 'Wallets';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return 'Sie haben $amount bei dieser Bestellung gespart!';
  }

  @override
  String get walkiePlan_payAnnualPlan => 'Jahresplan';

  @override
  String get walkiePlan_payBadgeCompleted => 'Abgeschlossen';

  @override
  String get walkiePlan_payBadgeInProgress => 'In Bearbeitung';

  @override
  String get walkiePlan_payBadgePending => 'Ausstehend';

  @override
  String get walkiePlan_payCancelledByUser =>
      'Zahlung vom Nutzer abgebrochen. Es wurde kein Betrag abgebucht.';

  @override
  String get walkiePlan_payCouldNotBeProcessed =>
      'Zahlung konnte nicht verarbeitet werden';

  @override
  String get walkiePlan_payFailedContactSupport => 'Support kontaktieren';

  @override
  String walkiePlan_payFailedOn(String time) {
    return 'Zahlung fehlgeschlagen am $time';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'Zahlung konnte nicht abgeschlossen werden.\nBitte erneut versuchen oder andere Methode wählen.';

  @override
  String get walkiePlan_payFailedSubtitleShort =>
      'Zahlung konnte nicht abgeschlossen werden';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      'Hilfe bei der Zahlung nötig? Unser Team ist rund um die Uhr für Sie da.';

  @override
  String get walkiePlan_payFailedTitle => 'Zahlung fehlgeschlagen';

  @override
  String get walkiePlan_payIndividualFeatures =>
      'Echtzeit-Überwachung • Sofortwarnungen';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return 'Zahlung gestartet am $time';
  }

  @override
  String get walkiePlan_payIntervalMonth => 'Monat';

  @override
  String get walkiePlan_payIntervalPlan => 'Plan';

  @override
  String get walkiePlan_payIntervalQuarter => 'Quartal';

  @override
  String get walkiePlan_payIntervalYear => 'Jahr';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'Kreditkarte ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'Debitkarte ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational =>
      'Internationale Karte / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'Online-Banking ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'Razorpay-Zahlung';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'Razorpay-Checkout';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / Karte)';

  @override
  String get walkiePlan_payMethodUpi => 'UPI-Zahlung';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'Wallet ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue =>
      'Netzwerkfehler während der Zahlung. Bitte Verbindung prüfen.';

  @override
  String get walkiePlan_payNotCompleted =>
      'Ihre Zahlung wurde nicht abgeschlossen. Es wurde kein Betrag abgebucht.';

  @override
  String get walkiePlan_payOtpCharge => 'OTP-Gebühr';

  @override
  String get walkiePlan_payOtpChargeDetails => 'OTP-Gebührendetails';

  @override
  String get walkiePlan_payOtpChargedPerLogin =>
      'Kosten pro Login. Erneutes Senden gratis';

  @override
  String get walkiePlan_payOtpCharges => 'OTP-Gebühren';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'Bitte die App nicht schließen. Sie erhalten eine Benachrichtigung.';

  @override
  String get walkiePlan_payPendingStillInProgress =>
      'Zahlung läuft noch. Wir aktualisieren nach Bestätigung.';

  @override
  String get walkiePlan_payPendingStillProcessing =>
      'Zahlung wird noch verarbeitet. Bitte warten.';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      'Ihre Zahlung wird vom Zahlungsanbieter verarbeitet.\nDies kann einige Minuten dauern.';

  @override
  String get walkiePlan_payPendingSubtitleShort =>
      'Ihre Zahlung wird verarbeitet';

  @override
  String get walkiePlan_payPendingTitle => 'Zahlung ausstehend';

  @override
  String get walkiePlan_payPlanDetails => 'Plandetails';

  @override
  String get walkiePlan_payRefreshStatus => 'Status aktualisieren';

  @override
  String get walkiePlan_payStatusTitle => 'Zahlungsstatus';

  @override
  String get walkiePlan_payStepActivate => 'Plan aktivieren';

  @override
  String get walkiePlan_payStepActivateSub =>
      'Ihr Plan wird automatisch aktiviert';

  @override
  String get walkiePlan_payStepInitiated => 'Zahlung initiiert';

  @override
  String get walkiePlan_payStepProcessing => 'Zahlung wird verarbeitet';

  @override
  String get walkiePlan_payStepProcessingSub => 'Ihre Zahlung wird bestätigt';

  @override
  String get walkiePlan_payTeamFeatures =>
      'Mehrbenutzerzugriff • Sofortwarnungen';

  @override
  String get walkiePlan_payTotalPerOtp => 'Gesamt pro OTP';

  @override
  String get walkiePlan_payTryAgain => 'Erneut versuchen';

  @override
  String get walkiePlan_payViewPlanDetails => 'Plandetails anzeigen';

  @override
  String get walkiePlan_perMember => 'pro Mitglied';

  @override
  String get walkiePlan_planFallback => 'Plan';

  @override
  String get walkiePlan_quarterlyPlan => 'Quartalsplan';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'Bitte schließen Sie die Zahlung im Razorpay-Fenster ab.';

  @override
  String get walkiePlan_razorpayCompletePayment => 'Zahlung abschließen';

  @override
  String get walkiePlan_razorpayConfirmingWithBank =>
      'Zahlung initiiert. Wir bestätigen mit der Bank.';

  @override
  String get walkiePlan_razorpayConnecting =>
      'Verbindung zu Razorpay wird hergestellt...';

  @override
  String get walkiePlan_razorpayCouldNotProcess =>
      'Die Zahlung konnte nicht verarbeitet werden. Bitte erneut versuchen.';

  @override
  String get walkiePlan_razorpayFailedTryAgain =>
      'Zahlung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1 Monat aktiv';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return '$amount über Razorpay bezahlen';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => 'Zahlung abgebrochen';

  @override
  String get walkiePlan_razorpayPaymentIdCopied =>
      'Zahlungs-ID in die Zwischenablage kopiert!';

  @override
  String get walkiePlan_razorpayPciCompliant => '100% Sicher & PCI-DSS-konform';

  @override
  String get walkiePlan_razorpayPendingConfirmation =>
      'Zahlung wartet auf Bestätigung.';

  @override
  String get walkiePlan_razorpayProcessing =>
      'Wird über Razorpay verarbeitet...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return 'Betrag: $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied =>
      'Belegdetails in die Zwischenablage kopiert!';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return 'Datum: $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return 'Zahlungsart: $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return 'Bestell-ID: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return 'Zahlungs-ID: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'Plan: $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted =>
      'Status: Abgeschlossen';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'FG Tracker Zahlungsbeleg';

  @override
  String get walkiePlan_razorpayRetryPayment => 'Zahlung wiederholen';

  @override
  String get walkiePlan_razorpaySecureCheckout =>
      'Sicherer Checkout powered by Razorpay';

  @override
  String get walkiePlan_razorpaySslEncrypted =>
      'Transaktionen sind mit 256-Bit-SSL-Verschlüsselung geschützt.';

  @override
  String get walkiePlan_razorpaySupportedModes => 'Unterstützte Zahlungsarten';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => 'Gesamtbetrag fällig';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return 'Zahlungs-Gateway konnte nicht gestartet werden: $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed =>
      'Zahlungsüberprüfung fehlgeschlagen.';

  @override
  String get walkiePlan_seatAssignedSeat => 'Zugewiesener Platz';

  @override
  String get walkiePlan_seatAssignment => 'Platzzuweisung';

  @override
  String get walkiePlan_seatTeamAccess => 'Team-Zugriff';

  @override
  String get walkiePlan_seatTeamMember => 'Teammitglied';

  @override
  String get walkiePlan_secureEncryptedPayment =>
      'Sichere & verschlüsselte Zahlung';

  @override
  String get walkiePlan_successAccessActivated => 'Zugriff aktiviert';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      'Ihr persönlicher Walkie-Talkie-Zugriff ist aktiv.';

  @override
  String get walkiePlan_successAmountPaid => 'Bezahlter Betrag';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'Sie können den Zugriff später in den Team-Einstellungen zuweisen.';

  @override
  String get walkiePlan_successAssignMembers => 'Mitglieder zuweisen';

  @override
  String get walkiePlan_successAssignWalkieAccess => 'Walkie-Zugriff zuweisen';

  @override
  String get walkiePlan_successChooseMembersDesc =>
      'Wählen Sie, wer Walkie-Talkie nutzen darf.';

  @override
  String get walkiePlan_successContinueHome => 'Weiter zur Startseite';

  @override
  String get walkiePlan_successDateTime => 'Datum & Uhrzeit';

  @override
  String get walkiePlan_successDefaultPaymentMethod => 'Razorpay (UPI / Karte)';

  @override
  String get walkiePlan_successIndividualActive =>
      'Ihr Einzelplan ist jetzt aktiv';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      'Ihr Plan ist aktiv. Gehen Sie zur Startseite und sprechen Sie los.';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      'Ihr Einzelabo ist aktiv und mit Ihrem Konto verknüpft.';

  @override
  String get walkiePlan_successManageAccessNote =>
      'Zugriff kann jederzeit in den Team-Einstellungen geändert werden.';

  @override
  String get walkiePlan_successMaybeLater => 'Vielleicht später';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'Ihr Plan ist aktiv. Mitglieder haben erst nach Zuweisung Zugriff.';

  @override
  String get walkiePlan_successNotNow => 'Nicht jetzt?';

  @override
  String get walkiePlan_successPaid => 'BEZAHLT';

  @override
  String get walkiePlan_successPaymentId => 'Zahlungs-ID';

  @override
  String get walkiePlan_successPaymentIdCopied =>
      'Zahlungs-ID in die Zwischenablage kopiert!';

  @override
  String get walkiePlan_successPaymentMode => 'Zahlungsart';

  @override
  String get walkiePlan_successPaymentReceipt => 'Zahlungsbeleg';

  @override
  String get walkiePlan_successPushToTalkDesc =>
      'Push-to-Talk und sofort mit dem Team verbinden.';

  @override
  String get walkiePlan_successRazorpayVerified => 'Von Razorpay verifiziert';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return 'Betrag: $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied =>
      'Belegdetails in die Zwischenablage kopiert!';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return 'Datum: $date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'FG Tracker Zahlungsbeleg';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return 'Bestell-ID: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return 'Zahlungs-ID: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return 'Zahlungsart: $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'Plan: $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted =>
      'Status: Abgeschlossen';

  @override
  String get walkiePlan_successSelectChannel => 'Kanal auswählen';

  @override
  String get walkiePlan_successSelectChannelDesc =>
      'Treten Sie einer Gruppe bei, um sich zu verbinden.';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'Wählen Sie die Mitglieder für Walkie-Talkie.';

  @override
  String get walkiePlan_successSetUpTeam => 'Team einrichten';

  @override
  String get walkiePlan_successSetUpTeamDesc =>
      'Mitglieder einladen, Rollen & Rechte verwalten.';

  @override
  String get walkiePlan_successShareReceipt => 'Beleg teilen';

  @override
  String get walkiePlan_successStartCommunicating => 'Kommunikation starten';

  @override
  String get walkiePlan_successStatus => 'Status';

  @override
  String get walkiePlan_successSuccessful => 'Erfolgreich';

  @override
  String get walkiePlan_successTeamActive => 'Ihr Team-Plan ist jetzt aktiv';

  @override
  String get walkiePlan_successTeamReady => 'Ihr Team ist einsatzbereit!';

  @override
  String get walkiePlan_successTitle => 'Kauf erfolgreich!';

  @override
  String walkiePlan_successValidTill(String date) {
    return 'Gültig bis $date';
  }

  @override
  String get walkiePlan_successVisitHome => 'Zur Startseite';

  @override
  String get walkiePlan_successWhatsNext => 'Was kommt als Nächstes?';

  @override
  String get walkiePlan_teamPlan => 'Team-Plan';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'Team-Plan ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => '7 Tage Testphase';

  @override
  String get walkiePlan_trialActiveLabel => 'TESTPHASE AKTIV';

  @override
  String get walkiePlan_trialActiveSubscription => 'Aktives Abonnement';

  @override
  String get walkiePlan_trialActiveSubscriptions => 'Aktive Abonnements';

  @override
  String get walkiePlan_trialAvailableToStart => 'Bereit zum Starten';

  @override
  String get walkiePlan_trialCheckConnectionRetry =>
      'Bitte Internetverbindung prüfen und erneut versuchen.';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'Wählen Sie unten einen Plan, um Walkie-Talkie zu starten.';

  @override
  String get walkiePlan_trialChooseSubscription =>
      'Wählen Sie ein Abo, um Walkie-Talkie weiter zu nutzen.';

  @override
  String get walkiePlan_trialCompleted => 'Test abgeschlossen';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage übrig',
      one: '1 Tag übrig',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration Kostenlos';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return 'Beendet am $date';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return 'Alle Walkie-Talkie-Funktionen $duration kostenlos nutzen.\nKeine Zahlung erforderlich.';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      'Nutzen Sie Walkie-Talkie während der Testphase.';

  @override
  String get walkiePlan_trialErrAccessMissing =>
      'Zugriffsinformationen fehlen.';

  @override
  String get walkiePlan_trialErrFetchDetails =>
      'Walkie-Talkie-Details konnten nicht abgerufen werden.';

  @override
  String get walkiePlan_trialErrInvalidResponse =>
      'Ungültige Antwort vom Server erhalten.';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'Keine Internetverbindung. Bitte Netzwerk prüfen und erneut versuchen.';

  @override
  String get walkiePlan_trialErrOverviewMissing => 'Übersichtsdaten fehlen.';

  @override
  String get walkiePlan_trialErrTimeout =>
      'Zeitüberschreitung der Anforderung. Bitte erneut versuchen.';

  @override
  String get walkiePlan_trialErrUnableToLoad =>
      'Walkie-Talkie-Details konnten nicht geladen werden.';

  @override
  String get walkiePlan_trialExpired => 'Test abgelaufen';

  @override
  String get walkiePlan_trialExpiredLabel => 'TESTPHASE ABGELAUFEN';

  @override
  String get walkiePlan_trialExpiringSoon => 'Läuft bald ab';

  @override
  String get walkiePlan_trialFeatClearAudio => 'Kristallklarer Ton';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'Hohe Sprachqualität';

  @override
  String get walkiePlan_trialFeatGroupComm => 'Gruppenkommunikation';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => 'Mit Ihrem Team verbinden';

  @override
  String get walkiePlan_trialFeatPtt => 'Push-to-Talk';

  @override
  String get walkiePlan_trialFeatPttDesc => 'Sofortige Sprachkommunikation';

  @override
  String get walkiePlan_trialFeatUnlimited => 'Unbegrenzte Nutzung';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => 'Ohne Einschränkungen nutzen';

  @override
  String get walkiePlan_trialFreeAvailable => 'Kostenloser Test verfügbar';

  @override
  String get walkiePlan_trialFreeTrialLabel => 'KOSTENLOSE TESTPHASE';

  @override
  String get walkiePlan_trialFreeTrialRunning => 'Kostenloser Test läuft';

  @override
  String get walkiePlan_trialFullAccess => 'Voller Zugriff auf alle Funktionen';

  @override
  String get walkiePlan_trialFullyConsumed =>
      'Ihre kostenlose Testphase ist vollständig verbraucht.';

  @override
  String get walkiePlan_trialHasEnded => 'Ihre Testphase ist beendet';

  @override
  String get walkiePlan_trialHeaderInstant =>
      'Sofort mit Ihrer Gruppe kommunizieren';

  @override
  String get walkiePlan_trialHeaderPlanStatus => 'Ihr Plan- & Abonnementstatus';

  @override
  String walkiePlan_trialHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden übrig',
      one: '1 Stunde übrig',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHr(int count) {
    return '$count Std.';
  }

  @override
  String walkiePlan_trialHrMin(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String get walkiePlan_trialIsActive => 'Ihr Test ist aktiv';

  @override
  String walkiePlan_trialMin(int count) {
    return '$count Min.';
  }

  @override
  String walkiePlan_trialMinSec(int minutes, int seconds) {
    return '$minutes Min. $seconds Sek.';
  }

  @override
  String walkiePlan_trialMinsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Min. übrig',
      one: '1 Min. übrig',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_trialNoActivePlan => 'Kein aktiver Plan';

  @override
  String get walkiePlan_trialNoCardRequired =>
      'Jederzeit in 7 Tagen nutzbar  •  Keine Kreditkarte nötig';

  @override
  String get walkiePlan_trialNoInternetTitle => 'Keine Internetverbindung';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return 'Jetzt keine Zahlung nötig. Danach können Sie einen Bezahlplan ($price/Person) wählen.';
  }

  @override
  String get walkiePlan_trialPeriodMonth => 'Monat';

  @override
  String get walkiePlan_trialRetrying => 'Wiederholung...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count Sek.';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return '$duration kostenlosen Test starten';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial => 'Kostenlosen Test starten';

  @override
  String get walkiePlan_trialStatusCompleted => 'Abgeschlossen';

  @override
  String get walkiePlan_trialStatusExpired => 'Abgelaufen';

  @override
  String get walkiePlan_trialSubscriptionActive => 'Abonnement aktiv';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'Ihr Walkie-Talkie-Abo ist beendet. Verlängern Sie, um weiterzureden.';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'Abo abgelaufen';

  @override
  String get walkiePlan_trialTalkFree =>
      'Sprechen Sie kostenlos mit Ihrer Gruppe.';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return 'Kostenlos mit der Gruppe sprechen bis $date.';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg =>
      'Sie haben Walkie-Talkie-Zugriff über Ihren Team-Plan.';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return '$time übrig';
  }

  @override
  String get walkiePlan_trialTimeRemaining => 'Verbleibende Testzeit';

  @override
  String get walkiePlan_trialTimeUsedUp => 'Testzeit abgelaufen';

  @override
  String get walkiePlan_trialTryAgain => 'Erneut versuchen';

  @override
  String get walkiePlan_trialUnableToLoadTitle =>
      'Walkie-Talkie konnte nicht geladen werden';

  @override
  String get walkiePlan_trialUsage => 'Test-Nutzung';

  @override
  String get walkiePlan_trialUseAnytime7Days =>
      'Test jederzeit in 7 Tagen nutzen';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return 'Nutzen Sie Ihren $duration-Test innerhalb von 7 Tagen.';
  }

  @override
  String get walkiePlan_trialUsed => 'Test genutzt';

  @override
  String get walkiePlan_trialValidityPeriod => 'Gültigkeitsdauer des Tests';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'Walkie-Talkie';

  @override
  String get walkiePlan_trialWhatYouCanDo =>
      'Was Sie während des Tests tun können';

  @override
  String get walkiePlan_unableToConnect =>
      'Verbindung zum Server fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get walkiePlan_yearlyPlan => 'Jahresplan';

  @override
  String get walkie_aMember => 'Ein Mitglied';

  @override
  String get walkie_accept => 'Annehmen';

  @override
  String get walkie_activeAccess => 'Aktiver Zugriff';

  @override
  String get walkie_activeBadge => 'Aktiv';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktiv im Walkie',
      one: '1 aktiv im Walkie',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'Aktives Mitglied';

  @override
  String get walkie_admin => 'Admin';

  @override
  String get walkie_adminMuted => 'Admin • Stumm';

  @override
  String get walkie_adminOnlyAction => 'Aktion nur für Admins';

  @override
  String get walkie_adminOnlyActionMessage =>
      'Nur Gruppen-Admins können Benachrichtigungsalarme an Mitglieder senden.';

  @override
  String walkie_alertSentMessage(String name) {
    return 'Benachrichtigung an $name gesendet. Wiederholung in 10 Sek. verfügbar.';
  }

  @override
  String get walkie_alertSentTitle => 'Alarm gesendet';

  @override
  String get walkie_assignMembersToCommunicate =>
      'Weise Mitglieder zu, um in dieser Gruppe zu sprechen';

  @override
  String get walkie_assignedByYou => 'Von dir zugewiesen';

  @override
  String walkie_assignedCount(int count) {
    return '$count zugewiesen';
  }

  @override
  String get walkie_assignedSeats => 'Zugewiesene Plätze';

  @override
  String get walkie_audioBluetooth => 'Bluetooth';

  @override
  String get walkie_audioHeadset => 'Headset';

  @override
  String get walkie_audioOutput => 'Audioausgabe';

  @override
  String get walkie_audioPhone => 'Telefon';

  @override
  String get walkie_audioSpeaker => 'Lautsprecher';

  @override
  String get walkie_audioWiredHeadphones => 'Kabelgebundene Kopfhörer';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return 'Automatische Entsperrung in $seconds Sek.';
  }

  @override
  String get walkie_availableMembers => 'Verfügbare Mitglieder';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du kannst bis zu $count Mitglieder in dieser Gruppe zuweisen',
      one: 'Du kannst bis zu 1 Mitglied in dieser Gruppe zuweisen',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat =>
      'Ein von einem anderen Admin zugewiesener Platz kann nicht entfernt werden';

  @override
  String get walkie_cannotSpeak => 'Sprechen auf diesem Kanal nicht möglich';

  @override
  String get walkie_channelBusy => 'Kanal ist belegt';

  @override
  String get walkie_channelLocked => 'Kanal gesperrt';

  @override
  String get walkie_channelSpeaking => 'Kanal überträgt...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return '$group konnte nicht als aktiver Sprechkanal festgelegt werden.';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'Kanalwechsel-Fehler';

  @override
  String get walkie_channelUnlocked => 'Kanal entsperrt';

  @override
  String get walkie_chat => 'Chat';

  @override
  String get walkie_checkNetworkTryAgain =>
      'Bitte überprüfe deine Netzwerkverbindung und versuche es erneut.';

  @override
  String get walkie_chooseAPlan => 'Wähle einen Plan';

  @override
  String get walkie_connected => 'Verbunden';

  @override
  String get walkie_connectedWaiting =>
      'Mit Kanal verbunden • Warten auf andere Teilnehmer';

  @override
  String get walkie_connectingChannel => 'Verbinde mit Kanal...';

  @override
  String get walkie_consumingTrial => 'Testversion wird genutzt...';

  @override
  String get walkie_continueListenOnly => 'Im Nur-Zuhören-Modus fortfahren';

  @override
  String walkie_currentlyAssigned(int count) {
    return 'Derzeit zugewiesen ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'Walkie-Gruppe';

  @override
  String get walkie_description => 'Beschreibung';

  @override
  String get walkie_disconnected => 'Getrennt';

  @override
  String get walkie_editAssignedMembers => 'Zugewiesene Mitglieder bearbeiten';

  @override
  String get walkie_enable => 'Aktivieren';

  @override
  String walkie_errorWithDetails(String details) {
    return 'Fehler: $details';
  }

  @override
  String get walkie_exitWalkie => 'Walkie verlassen';

  @override
  String get walkie_exitWalkieMessage =>
      'Du wirst von diesem Kanal getrennt. Du bleibst weiterhin Mitglied der Gruppe.';

  @override
  String get walkie_exitWalkieTitle => 'Walkie verlassen?';

  @override
  String get walkie_fairConnection => 'Ausreichende Verbindung';

  @override
  String walkie_fairConnectionMs(int ms) {
    return 'Ausreichende Verbindung ($ms ms)';
  }

  @override
  String get walkie_featureAllDevices => 'Auf allen Geräten nutzbar';

  @override
  String get walkie_featureEasyCoordination => 'Einfache Gruppenkoordination';

  @override
  String get walkie_featureHoldToTalk => 'Zum Sprechen gedrückt halten';

  @override
  String get walkie_featurePtt => 'Push-to-Talk';

  @override
  String get walkie_featureQuickGroup => 'Schnelle Gruppenkommunikation';

  @override
  String get walkie_featureRealtime => 'Echtzeit-Konnektivität';

  @override
  String get walkie_featureSafeReliable => 'Sicher & zuverlässig';

  @override
  String get walkie_featureStayConnected => 'Immer verbunden bleiben';

  @override
  String get walkie_featureTeamCommunication => 'Team-Kommunikation';

  @override
  String get walkie_featureUnlimited => 'Unbegrenzt';

  @override
  String get walkie_fieldTeam => 'Außendienst-Team';

  @override
  String get walkie_freeTrialEnded => 'Kostenlose Testversion beendet';

  @override
  String get walkie_freeTrialEndedMessage =>
      'Deine 1-stündige Testphase für Walkie-Talkie ist abgelaufen.\nJetzt upgraden, um weiterhin mit deinem Team zu kommunizieren.';

  @override
  String get walkie_freeTrialEndedTitle => 'Kostenlose Testphase beendet';

  @override
  String get walkie_genericError => 'Walkie-Talkie-Fehler';

  @override
  String get walkie_getPlan => 'Plan holen';

  @override
  String walkie_goodConnectionMs(int ms) {
    return 'Gute Verbindung ($ms ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'Gruppencode: $code';
  }

  @override
  String get walkie_groupCommunication => 'Gruppenkommunikation';

  @override
  String get walkie_groupFallback => 'Gruppe';

  @override
  String get walkie_groupMembers => 'Gruppenmitglieder';

  @override
  String get walkie_heroSubtitle =>
      'Nutze Push-to-Talk-Sprachkommunikation mit deiner Gruppe ohne Telefonanruf.';

  @override
  String get walkie_heroTitle => 'Verbunden bleiben, sofort sprechen';

  @override
  String get walkie_holdToTalk => 'Gedrückt halten zum Sprechen';

  @override
  String get walkie_holdToTalkSlideLock =>
      'Halten zum Sprechen, nach oben wischen zum Sperren';

  @override
  String get walkie_inWalkieChannel => 'Im Walkie-Kanal';

  @override
  String get walkie_individualActiveUpgrade =>
      'Einzelplan aktiv (Nur Eigenzugriff) • Auf Team-Plan upgraden.';

  @override
  String get walkie_individualLimitMessage =>
      'Dein Einzelplan erlaubt nur 1 Platz. Um mehrere Mitglieder zuzuweisen, upgrade bitte auf einen Team-Plan.';

  @override
  String get walkie_individualPlan => 'Einzelplan';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (Einzeln)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      'Einzelplan (Nur Eigenzugriff) • Upgrade auf Team';

  @override
  String get walkie_individualSubscribedSelf => 'Einzelplan • Selbst abonniert';

  @override
  String get walkie_info => 'Info';

  @override
  String walkie_isSpeaking(String name) {
    return '$name spricht...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name spricht...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beigetreten',
      one: '1 beigetreten',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return 'Zuletzt gesehen $time';
  }

  @override
  String get walkie_listenOnly => 'Nur Zuhören';

  @override
  String get walkie_listenOnlyTapPlan =>
      'Nur Zuhören — Tippen, um Plan anzuzeigen';

  @override
  String get walkie_listening => 'Hört zu';

  @override
  String get walkie_listeningOnly => 'Hört nur zu';

  @override
  String get walkie_live => 'LIVE';

  @override
  String get walkie_lockTimeout =>
      'Sperrzeit abgelaufen — Mikrofon freigegeben';

  @override
  String get walkie_lockedTapMic =>
      'Gesperrt — Auf Mikrofon tippen zum Stoppen';

  @override
  String get walkie_maybeLater => 'Vielleicht später';

  @override
  String get walkie_member => 'Mitglied';

  @override
  String get walkie_membersInChannel => 'Mitglieder im Kanal';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mitglieder online',
      one: 'Mitglied online',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed =>
      'Aktualisierung der zugewiesenen Mitglieder fehlgeschlagen';

  @override
  String get walkie_membersUpdated =>
      'Zugewiesene Mitglieder erfolgreich aktualisiert';

  @override
  String get walkie_micAccessRequired =>
      'Mikrofonzugriff erforderlich, um zu sprechen.';

  @override
  String get walkie_micDisabledMessage =>
      'Mikrofonzugriff ist in den Geräteeinstellungen deaktiviert. Bitte erlaube den Zugriff in den Einstellungen, um zu sprechen.\n\nDu kannst andere weiterhin hören.';

  @override
  String get walkie_micPermissionRequired =>
      'Mikrofonberechtigung erforderlich';

  @override
  String get walkie_micPermissionTitle => 'Mikrofonberechtigung';

  @override
  String get walkie_micRequiredMessage =>
      'Mikrofonberechtigung ist erforderlich, um in dieser Walkie-Talkie-Gruppe zu sprechen.\n\nDu kannst weiterhin zuhören, ohne das Mikrofon zu aktivieren.';

  @override
  String get walkie_muteMe => 'Mich stummschalten';

  @override
  String get walkie_muted => 'Stumm';

  @override
  String get walkie_mutedInWalkie => 'Stumm • Im Walkie';

  @override
  String get walkie_mutedListeningOnly =>
      'Du bist stummgeschaltet — Nur Zuhören';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name spricht...';
  }

  @override
  String get walkie_noActivePlan => 'Kein aktiver Plan';

  @override
  String get walkie_noAvailableMembers => 'Keine verfügbaren Mitglieder';

  @override
  String get walkie_noBluetoothDevice =>
      'Kein Bluetooth-Gerät verbunden. Bitte kopple dein Headset in den Einstellungen.';

  @override
  String get walkie_noGroupsFound => 'Keine Gruppen gefunden';

  @override
  String get walkie_noMembersAssigned => 'Derzeit keine Mitglieder zugewiesen';

  @override
  String get walkie_noMembersFound => 'Keine Mitglieder gefunden';

  @override
  String get walkie_noMembersFoundTitle => 'Keine Mitglieder gefunden';

  @override
  String get walkie_noMembersMatch => 'Keine passenden Mitglieder';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return 'Keine Mitglieder entsprechen \'$query\'';
  }

  @override
  String get walkie_noMembersToAssign =>
      'Keine Gruppenmitglieder zum Zuweisen verfügbar.';

  @override
  String get walkie_noNameGroup => 'Gruppe ohne Namen';

  @override
  String get walkie_noPlanSubscribeAssign =>
      'Kein aktiver Plan • Abonnieren zur Zuweisung';

  @override
  String get walkie_noSeatMessage =>
      'Du hast einen aktiven Team-Plan, aber alle Sprachplätze sind derzeit anderen Teammitgliedern zugewiesen.\n\nDu kannst Gespräche in Echtzeit mithören. Um zu sprechen, weise dir einen Platz zu oder erweitere deinen Plan.';

  @override
  String get walkie_noSeatTitle => 'Kein Sprachplatz zugewiesen';

  @override
  String get walkie_noSeatsRefreshing =>
      'Keine Teamplätze verfügbar. Liste wird aktualisiert...';

  @override
  String get walkie_noSubscriptionMessage =>
      'Du hast kein aktives Walkie-Talkie-Abonnement. Schließe ein Abo ab, um Mitglieder zuzuweisen und sofort zu sprechen.';

  @override
  String get walkie_noTeamSubscription =>
      'Kein aktives Team-Abonnement gefunden';

  @override
  String get walkie_noValidMembers =>
      'Keine gültigen Mitglieder zum Zuweisen ausgewählt';

  @override
  String get walkie_noVoiceSeatListenOnly =>
      'Kein Sprachplatz zugewiesen — Nur-Zuhören-Modus';

  @override
  String get walkie_noWiredDevice =>
      'Keine kabelgebundenen Kopfhörer angeschlossen. Bitte einstecken.';

  @override
  String get walkie_notConnected => 'Nicht verbunden';

  @override
  String get walkie_notifLeave => 'Verlassen';

  @override
  String get walkie_notifOpenWalkie => 'Walkie öffnen';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name hat aufgehört zu sprechen';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name spricht';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return 'Benachrichtigungseinstellung für $group konnte nicht aktualisiert werden. Bitte erneut versuchen.';
  }

  @override
  String get walkie_notificationSettingTitle => 'Benachrichtigungseinstellung';

  @override
  String get walkie_onlyAdminCanAlert =>
      'Nur der Gruppen-Admin kann Alarme senden';

  @override
  String get walkie_openWalkieTalkie => 'Walkie-Talkie öffnen';

  @override
  String get walkie_otherTeam => 'Anderes Team';

  @override
  String get walkie_othersWontHear => 'Andere werden dich nicht hören';

  @override
  String get walkie_planRequiredTitle => 'Walkie-Talkie-Plan erforderlich';

  @override
  String get walkie_planRequiredToTalk => 'Plan erforderlich zum Sprechen';

  @override
  String get walkie_planStartsOnFirstAssign =>
      'Der Plan beginnt, sobald das erste Mitglied zugewiesen wird.';

  @override
  String get walkie_poorConnection =>
      'Schwache Verbindung — Audio kann verzögert sein';

  @override
  String get walkie_preparingAudio => 'Audio wird vorbereitet...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'Kaufe einen Team-Plan, um Mitgliedern Zugang zuzuweisen.';

  @override
  String get walkie_purchaseUpgradePlan => 'Plan kaufen / upgraden';

  @override
  String get walkie_ready => 'Bereit';

  @override
  String get walkie_reconnecting => 'Verbindet neu...';

  @override
  String get walkie_reconnectingServer => 'Neuverbindung zum Walkie-Server...';

  @override
  String get walkie_releaseToStop => 'Loslassen zum Beenden';

  @override
  String get walkie_removeAll => 'Alle entfernen';

  @override
  String get walkie_searchGroups => 'Gruppen suchen';

  @override
  String get walkie_searchMembers => 'Mitglieder suchen...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total Plätze';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '$total Plätze gesamt • $assigned zugewiesen • $available verfügbar';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '$assigned / $total Plätze belegt';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds Sek.';
  }

  @override
  String get walkie_selectAtLeastOne =>
      'Bitte wähle mindestens ein Mitglied zum Zuweisen aus';

  @override
  String get walkie_selectGroupFirst => 'Bitte wähle zuerst eine Gruppe aus';

  @override
  String get walkie_selectGroupToConnect => 'Wähle eine Gruppe zum Verbinden';

  @override
  String get walkie_selected => 'Ausgewählt';

  @override
  String get walkie_selfAccess => 'Eigenzugriff';

  @override
  String get walkie_selfPlan => 'Eigener Plan';

  @override
  String get walkie_slideUpToLock => 'Zum Sperren nach oben wischen';

  @override
  String get walkie_someone => 'Jemand';

  @override
  String get walkie_someoneSpeaking => 'Jemand spricht...';

  @override
  String get walkie_speaking => 'Spricht...';

  @override
  String walkie_startFreeTrial(String duration) {
    return 'Kostenlose $duration-Testversion starten';
  }

  @override
  String get walkie_strongConnection => 'Starke Verbindung';

  @override
  String walkie_strongConnectionMs(int ms) {
    return 'Starke Verbindung ($ms ms)';
  }

  @override
  String get walkie_subscribeToStartTalk =>
      'Abonnieren, um zu sprechen und Mitglieder zuzuweisen';

  @override
  String get walkie_subscribed => 'Abonniert';

  @override
  String get walkie_talking => 'Spricht...';

  @override
  String get walkie_tapToUnlock => 'Tippen zum Entsperren';

  @override
  String get walkie_teamAssignedElsewhere => 'Team-Plan • Woanders zugewiesen';

  @override
  String get walkie_teamPlan => 'Team-Plan';

  @override
  String get walkie_teamPlanRequired => 'Team-Plan erforderlich';

  @override
  String get walkie_teamPlanRequiredToAssign =>
      'Team-Plan zum Zuweisen von Mitgliedern erforderlich';

  @override
  String get walkie_teamPlanStatus => 'Team-Plan-Status';

  @override
  String get walkie_teamSeatMember => 'Team-Platz-Mitglied';

  @override
  String get walkie_title => 'Walkie-Talkie';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gesamt',
      one: '1 Gesamt',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => '1 Std. Testversion aktiv';

  @override
  String get walkie_trialEndedSubscribe =>
      'Testversion beendet — Bitte abonnieren, um fortzufahren';

  @override
  String get walkie_unableToConnectReconnecting =>
      'Kanalverbindung fehlgeschlagen — Neuverbindung...';

  @override
  String get walkie_unavailable => 'Nicht verfügbar';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'Mitglieder aktualisieren ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'Mitglieder werden aktualisiert...';

  @override
  String get walkie_upgradeAddSeats => 'Upgraden & Plätze hinzufügen';

  @override
  String get walkie_upgradeNow => 'Jetzt upgraden';

  @override
  String get walkie_upgradeTeamAssign =>
      'Auf Team-Plan upgraden (Mitglieder zuweisen)';

  @override
  String get walkie_upgradeToTeamPlan => 'Auf Team-Plan upgraden';

  @override
  String walkie_userCancelled(String name) {
    return '$name hat abgebrochen';
  }

  @override
  String walkie_userJoined(String name) {
    return '$name ist beigetreten';
  }

  @override
  String walkie_userLeft(String name) {
    return '$name hat verlassen';
  }

  @override
  String walkie_validTill(String date) {
    return 'Gültig bis $date';
  }

  @override
  String get walkie_viewPlan => 'Plan anzeigen';

  @override
  String get walkie_voiceNotPermitted => 'Sprachübertragung nicht gestattet';

  @override
  String get walkie_weakSignal => 'Schwaches Signal';

  @override
  String walkie_weakSignalMs(int ms) {
    return 'Schwaches Signal ($ms ms)';
  }

  @override
  String get walkie_youAreConnected => 'Du bist verbunden';

  @override
  String get walkie_yourVoiceAccess => 'Dein Sprachzugriff';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Download für Android: $playStoreLink\n\nDownload für iOS: $appStoreLink';
  }

  @override
  String get widget_live => 'Live';

  @override
  String get widget_lostConnection => 'Verbindung verloren';

  @override
  String get widget_manageGroups => 'Verwalten Sie Ihre Gruppen mühelos';

  @override
  String get widget_noInternetBody =>
      'Hoppla... keine Internetverbindung gefunden. Verbindung prüfen';

  @override
  String get widget_notSeenYet => 'Noch nicht gesehen';

  @override
  String get widget_pinnedMessage => 'Angeheftete Nachricht';

  @override
  String get widget_private => 'Privat';

  @override
  String get widget_refreshPage => 'Seite aktualisieren';

  @override
  String get widget_seen => 'Gesehen';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count von $total)';
  }

  @override
  String get widget_somethingWentWrongTitle => 'Etwas ist schiefgelaufen';

  @override
  String get widget_userFallback => 'Benutzer';
}
