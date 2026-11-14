// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about_aboutUs => 'À propos de nous';

  @override
  String get about_address => 'Adresse';

  @override
  String get about_appBarTitle => 'À propos de FG Tracker';

  @override
  String get about_company => 'Entreprise';

  @override
  String get about_contactUs => 'Contactez-nous';

  @override
  String get about_developerEmail => 'E-mail du développeur';

  @override
  String get about_downloadTitle => '📱 Télécharger l’application';

  @override
  String get about_howItWorksIntro =>
      'FG Tracker simplifie la coordination des voyages de groupe. Voici comment :';

  @override
  String get about_howItWorksTitle => '⚙️ Comment ça marche';

  @override
  String get about_howStep1 => 'Créez un groupe';

  @override
  String get about_howStep2 =>
      'Partagez le code de groupe ou le code QR avec vos proches';

  @override
  String get about_howStep3 =>
      'Chaque membre rejoint à l’aide du code ou QR partagé';

  @override
  String get about_howStep4 =>
      'Suivez la position en direct de chacun sur une carte partagée en temps réel';

  @override
  String get about_howStep5 =>
      'Utilisez la fonction de partage pour inviter d’autres personnes sans effort';

  @override
  String get about_intro =>
      'FG Tracker est votre compagnon idéal pour rester connecté et en sécurité lors de vos déplacements en groupe. Qu’il s’agisse d’un voyage en famille, d’un pique-nique entre amis ou de trajets entre collègues, FG Tracker veille à ce que personne ne soit laissé pour compte.';

  @override
  String get about_privacyBody =>
      'Votre sécurité et votre vie privée comptent. FG Tracker ne partage pas votre position en dehors de votre groupe. Toutes les données sont chiffrées et uniquement partagées avec les personnes que vous autorisez.';

  @override
  String get about_privacyPolicy => 'Politique de confidentialité';

  @override
  String get about_privacyTitle => '🔐 Confidentialité et sécurité';

  @override
  String get about_supportEmail => 'E-mail d’assistance';

  @override
  String get about_supportTitle => '📩 Support et informations développeur';

  @override
  String get about_termsConditions => 'Conditions générales';

  @override
  String get about_title => 'À propos';

  @override
  String get about_website => 'Site web';

  @override
  String get about_welcomeTitle => 'Bienvenue sur FG Tracker';

  @override
  String get about_whyBuiltFor =>
      'Conçu pour les familles, les amis et les petites équipes.';

  @override
  String get about_whyChooseTitle => '🌟 Pourquoi choisir FG Tracker ?';

  @override
  String get about_whyEasy =>
      'Facile à utiliser, légère et avec contrôle de la confidentialité.';

  @override
  String get about_whyNoCalls =>
      'Inutile d’appeler ou d’envoyer un SMS : suivez en direct sur la carte.';

  @override
  String get about_whyRealTime =>
      'Partage de localisation en temps réel avec tous les membres.';

  @override
  String appUpdate_checkError(String error) {
    return 'Erreur lors de la recherche de mise à jour : $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => 'Voulez-vous quitter ?';

  @override
  String get appUpdate_noUpdateAvailable => 'Aucune mise à jour disponible';

  @override
  String get appUpdate_restartApp => 'Redémarrer l’application';

  @override
  String get appUpdate_updateApp => 'Mettre à jour l’app';

  @override
  String get appUpdate_updateAvailable => 'Mise à jour disponible';

  @override
  String get appUpdate_updateAvailableMessage =>
      'Une nouvelle mise à jour est disponible. Veuillez mettre à jour l’application';

  @override
  String get appUpdate_updateUnavailable => 'Mise à jour non disponible';

  @override
  String appUpdate_updatingProgress(int progress) {
    return 'Mise à jour... $progress%';
  }

  @override
  String get attendance_addOption => 'Ajouter une autre option';

  @override
  String get attendance_admin => 'Admin';

  @override
  String get attendance_allowChange => 'Autoriser la modification';

  @override
  String get attendance_allowChangeSubtitle =>
      'Les membres peuvent modifier ou retirer leur réponse';

  @override
  String get attendance_askCommunity => 'Demandez à votre communauté';

  @override
  String get attendance_cameraPermissionRequired =>
      'Autorisation de la caméra requise pour marquer la présence.';

  @override
  String get attendance_cameraStartFailed =>
      'Impossible de démarrer la caméra.';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'Impossible de démarrer la caméra ($code).';
  }

  @override
  String get attendance_cameraStarting => 'Démarrage de la caméra…';

  @override
  String get attendance_captureFailedBlink =>
      'Échec de capture. Clignez à nouveau';

  @override
  String attendance_capturedAtVerified(String time) {
    return 'Capturée à $time • Vérifiée';
  }

  @override
  String get attendance_capturedCheck => 'Capturé ✓';

  @override
  String get attendance_changeResponse => 'Modifier la réponse';

  @override
  String get attendance_chooseFolder =>
      'Choisissez un dossier (ex: Téléchargements)';

  @override
  String get attendance_closeAction => 'Clôturer la présence';

  @override
  String get attendance_closeConfirmBody =>
      'Les membres ne pourront plus répondre après la clôture.';

  @override
  String get attendance_closeConfirmTitle => 'Clôturer la présence ?';

  @override
  String get attendance_closeEndOfDay => 'Clôturer en fin de journée';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return 'Ferme automatiquement à $time aujourd’hui';
  }

  @override
  String get attendance_closeFailed => 'Impossible de clôturer la présence';

  @override
  String get attendance_closeFailedShort => 'Impossible de clôturer';

  @override
  String attendance_closesAt(String dateTime) {
    return 'Ferme le $dateTime';
  }

  @override
  String get attendance_createFailed => 'Impossible de créer la présence';

  @override
  String get attendance_createSubtitle =>
      'Envoyer un sondage de présence à ce groupe';

  @override
  String get attendance_createTitle => 'Créer une présence';

  @override
  String get attendance_created => 'Présence créée';

  @override
  String get attendance_dateEnded =>
      'La date sélectionnée est déjà passée. Choisissez une autre date.';

  @override
  String get attendance_dateToday => 'Date (aujourd’hui)';

  @override
  String get attendance_dateTodaySemantics => 'Date de présence, aujourd’hui';

  @override
  String get attendance_deleteFailed => 'Impossible de supprimer la présence';

  @override
  String get attendance_deletedText => 'Cette présence a été supprimée';

  @override
  String get attendance_downloadReport => 'Télécharger le rapport';

  @override
  String get attendance_everyoneResponded => 'Tout le monde a répondu';

  @override
  String get attendance_faceDetectedBlink =>
      'Visage détecté — clignez des yeux';

  @override
  String get attendance_failed => 'Échec de la présence';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return 'Non répondu ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return 'Ont répondu ($count)';
  }

  @override
  String get attendance_fixErrors =>
      'Veuillez corriger les erreurs avant de soumettre';

  @override
  String get attendance_holdStill => 'Ne bougez pas…';

  @override
  String get attendance_howToTakePhoto => 'Comment prendre votre photo';

  @override
  String get attendance_invalidGroup =>
      'Groupe invalide. Veuillez rouvrir la discussion.';

  @override
  String get attendance_keepFaceInCircle =>
      'Gardez votre visage dans le cercle';

  @override
  String get attendance_limitReached => 'Limite atteinte';

  @override
  String get attendance_loadFailed => 'Impossible de charger la présence';

  @override
  String get attendance_loadMore => 'Charger plus';

  @override
  String get attendance_loadMoreFailed => 'Impossible de charger plus';

  @override
  String get attendance_loadVotersFailed => 'Impossible de charger les votants';

  @override
  String get attendance_lookAtCamera => 'Regardez la caméra';

  @override
  String get attendance_lookStraight => 'Regardez droit vers la caméra';

  @override
  String get attendance_markYourAttendance => 'Marquez votre présence';

  @override
  String attendance_markedAs(String option) {
    return 'Marqué comme $option';
  }

  @override
  String get attendance_markedSuccess => 'Présence enregistrée avec succès';

  @override
  String attendance_maxOptions(int count) {
    return 'Vous ne pouvez ajouter que jusqu’à $count options';
  }

  @override
  String get attendance_members => 'Membres';

  @override
  String attendance_membersWithCount(int count) {
    return 'Membres ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return 'Au moins $count options sont requises';
  }

  @override
  String get attendance_moveCloser => 'Rapprochez-vous un peu';

  @override
  String get attendance_multipleFaces =>
      'Plusieurs visages détectés — vous seul devez être cadré';

  @override
  String get attendance_noCsvApp =>
      'Aucune app trouvée pour ouvrir les CSV. Utilisez Enregistrer ou Partager.';

  @override
  String get attendance_noFace => 'Aucun visage détecté';

  @override
  String get attendance_noFrontCamera => 'Aucune caméra frontale trouvée.';

  @override
  String get attendance_noLocation => 'Aucune position disponible';

  @override
  String get attendance_noMembersMatch =>
      'Aucun membre ne correspond à votre recherche';

  @override
  String get attendance_noResponses => 'Aucune réponse pour le moment';

  @override
  String get attendance_notResponded => 'Non répondu';

  @override
  String get attendance_openEyes => 'Ouvrez les yeux et regardez la caméra';

  @override
  String get attendance_openMapFailed => 'Impossible d’ouvrir la carte';

  @override
  String get attendance_openSubtitle => 'Afficher dans Excel, Sheets ou autre';

  @override
  String get attendance_optionHint => 'Entrez le libellé de l’option';

  @override
  String get attendance_optionLabelRequired =>
      'Toutes les options doivent avoir un libellé';

  @override
  String attendance_optionNumber(int number) {
    return 'Option $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return 'Option $number • 📷 Photo requise';
  }

  @override
  String get attendance_optionsUnique => 'Les options doivent être uniques';

  @override
  String get attendance_photoCaptured => 'Photo capturée';

  @override
  String get attendance_photoCapturedTapRetake =>
      'Photo capturée ✓ (Toucher pour reprendre)';

  @override
  String get attendance_photoProof => 'Preuve photo';

  @override
  String attendance_photoProofOf(String name) {
    return 'Preuve photo de $name';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ Photo requise pour $option';
  }

  @override
  String get attendance_photoRules =>
      'Seule la caméra frontale est utilisée. La photo est prise automatiquement lors du clignement, l\'import depuis la galerie est interdit.';

  @override
  String get attendance_photoSubtitle =>
      'Prenez une photo en direct pour vérifier';

  @override
  String get attendance_photoTitle => 'Photo de présence';

  @override
  String get attendance_photoVerified => 'Photo vérifiée';

  @override
  String get attendance_questionHint => 'Serez-vous disponible aujourd’hui ?';

  @override
  String get attendance_questionLabel => 'Question de présence';

  @override
  String get attendance_questionRequired =>
      'La question de présence est requise';

  @override
  String attendance_questionTooShort(int count) {
    return 'La question doit comporter au moins $count caractères';
  }

  @override
  String get attendance_removeFailedShort => 'Impossible de retirer';

  @override
  String get attendance_removeResponseBody =>
      'Votre présence pour ce sondage sera effacée.';

  @override
  String get attendance_removeResponseTitle => 'Supprimer votre réponse ?';

  @override
  String get attendance_removeVoteFailed => 'Impossible de retirer le vote';

  @override
  String get attendance_reportEmpty => 'Le rapport est vide';

  @override
  String get attendance_reportFailed => 'Échec du rapport';

  @override
  String get attendance_reportInvalid =>
      'Le serveur a renvoyé un rapport invalide. Réessayez.';

  @override
  String attendance_reportReady(String fileName) {
    return 'Rapport prêt • $fileName';
  }

  @override
  String get attendance_reportSaved => 'Rapport enregistré';

  @override
  String get attendance_reportSubject => 'Rapport de présence';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return 'Rapport de présence • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count ont répondu';
  }

  @override
  String get attendance_retakePhoto => 'Reprendre la photo';

  @override
  String get attendance_saveInFiles => 'Enregistrer dans Fichiers';

  @override
  String get attendance_saveReportDialog =>
      'Enregistrer le rapport de présence';

  @override
  String get attendance_saveToDevice => 'Enregistrer sur l’appareil';

  @override
  String get attendance_searchMember => 'Rechercher un membre';

  @override
  String get attendance_selectPhotoOption =>
      'Sélectionnez une option nécessitant une photo en direct';

  @override
  String get attendance_selectStatus => 'Veuillez sélectionner votre statut';

  @override
  String get attendance_sentToAllMembers =>
      'Envoyé à tous les membres de ce groupe';

  @override
  String get attendance_sentToGroup => 'Présence envoyée au groupe';

  @override
  String get attendance_shareSubtitle => 'Envoyer via WhatsApp, e-mail...';

  @override
  String get attendance_statusCompleted => 'Terminée';

  @override
  String get attendance_statusOpen => 'Ouverte';

  @override
  String get attendance_stepBlink => 'Clignez des yeux pour prendre la photo';

  @override
  String get attendance_stepEyeLevel =>
      'Tenez votre téléphone à la hauteur des yeux';

  @override
  String get attendance_submit => 'Soumettre la présence';

  @override
  String get attendance_submitted => 'Présence soumise';

  @override
  String get attendance_title => 'Présence';

  @override
  String get attendance_update => 'Mettre à jour la présence';

  @override
  String get attendance_validationError => 'Erreur de validation';

  @override
  String get attendance_view => 'Afficher';

  @override
  String get attendance_viewTitle => 'Afficher la présence';

  @override
  String get attendance_voteFailed => 'Impossible d’enregistrer le vote';

  @override
  String attendance_withinKm(String km) {
    return 'À moins de $km km';
  }

  @override
  String attendance_withinMeters(int count) {
    return 'À moins de $count m';
  }

  @override
  String get call_accept => 'Accepter';

  @override
  String get call_allContacts => 'Tous les contacts';

  @override
  String get call_allowAccess => 'Autoriser l\'accès';

  @override
  String get call_answer => 'Répondre';

  @override
  String get call_audioOutput => 'Sortie audio';

  @override
  String get call_callFrom => 'Appel de';

  @override
  String get call_callIdNotFound => 'ID d\'appel introuvable';

  @override
  String get call_callInformation => 'Informations sur l\'appel';

  @override
  String get call_callSummary => 'Résumé de l\'appel';

  @override
  String get call_caller => 'Appelant';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name et $count autres',
      one: '$name et 1 autre',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impossible de supprimer $count appels. Réessayez.',
      one: 'Impossible de supprimer 1 appel. Réessayez.',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appels supprimés',
      one: '1 appel supprimé',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'Caméra';

  @override
  String get call_cameraMicRequired =>
      'Autorisations de caméra ou micro requises';

  @override
  String get call_cameraOff => 'Caméra désactivée';

  @override
  String get call_cameraOn => 'Caméra activée';

  @override
  String get call_cameraUnavailable =>
      'L\'accès à la caméra est actuellement indisponible. Veuillez réessayer plus tard.';

  @override
  String get call_cannotReachCallServer =>
      'Impossible de joindre le serveur d’appels. Vérifiez votre réseau.';

  @override
  String get call_chatFallback => 'Discussion';

  @override
  String get call_closeFullScreen => 'Quitter plein écran';

  @override
  String get call_communicationUnavailable =>
      'La communication n\'est pas disponible avec cet utilisateur';

  @override
  String get call_connectingProgress => 'Connexion…';

  @override
  String get call_connectionTimeout => 'Délai de connexion dépassé';

  @override
  String get call_contactInformation => 'Informations sur le contact';

  @override
  String get call_contactsAccessBannerMessage =>
      'Trouvez et appelez facilement les membres de votre équipe.';

  @override
  String get call_contactsAccessBannerTitle =>
      'Autorisez l’accès à vos contacts';

  @override
  String get call_contactsAccessMessage =>
      'Nous avons besoin d\'accéder à vos contacts pour savoir qui est sur FG Tracker et vous permettre de les appeler ou de les inviter.';

  @override
  String get call_contactsAccessTitle => 'Autoriser l\'accès aux contacts';

  @override
  String get call_decline => 'Refuser';

  @override
  String get call_deleteCallsMessage =>
      'Ces appels seront retirés de votre historique.';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count appels ?',
      one: 'Supprimer 1 appel ?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage =>
      'Voulez-vous vraiment supprimer cet historique d’appels ?';

  @override
  String get call_deleteHistoryTitle => 'Supprimer l\'historique des appels';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Voulez-vous vraiment supprimer ces $count appels sélectionnés de l’historique ?',
      one: 'Voulez-vous vraiment supprimer cet appel sélectionné ?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => 'Supprimer les appels sélectionnés';

  @override
  String call_deleteWithCount(int count) {
    return 'Supprimer ($count)';
  }

  @override
  String call_durHr(int hours) {
    return '$hours h';
  }

  @override
  String call_durHrMin(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String call_durMin(int minutes) {
    return '$minutes min';
  }

  @override
  String call_durMinSec(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String call_durSec(int seconds) {
    return '$seconds s';
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
  String get call_duration => 'Durée';

  @override
  String call_durationValue(String duration) {
    return 'Durée : $duration';
  }

  @override
  String get call_earpiece => 'Écouteur';

  @override
  String get call_endCall => 'Terminer l’appel';

  @override
  String get call_ended => 'Terminé';

  @override
  String get call_enterNumber => 'Entrez le numéro';

  @override
  String get call_enterPhoneNumber => 'Veuillez entrer un numéro de téléphone';

  @override
  String get call_entryDeleteFailed =>
      'Échec de suppression de l\'entrée d\'appel';

  @override
  String call_entryDeleteFailedError(String error) {
    return 'Échec de suppression de l\'entrée d\'appel : $error';
  }

  @override
  String get call_entryDeleted => 'Entrée d\'appel supprimée';

  @override
  String get call_everyoneInCall => 'Tout le monde est déjà dans l’appel';

  @override
  String get call_failedTitle => 'Échec de l’appel';

  @override
  String get call_groupBadge => 'Groupe';

  @override
  String get call_groupCallComingSoon =>
      'Les appels de groupe arrivent bientôt';

  @override
  String get call_groupCallInitFailed =>
      'Impossible d\'initialiser l\'appel de groupe';

  @override
  String get call_groupCallStartFailed =>
      'Impossible de démarrer l\'appel de groupe. Veuillez réessayer.';

  @override
  String get call_groupInformation => 'Informations sur le groupe';

  @override
  String call_groupWithId(String id) {
    return 'Groupe $id';
  }

  @override
  String get call_headphones => 'Casque';

  @override
  String call_historyCancelled(String callType) {
    return '$callType annulé';
  }

  @override
  String get call_historyClearFailed =>
      'Échec de l\'effacement de l\'historique des appels';

  @override
  String call_historyClearFailedError(String error) {
    return 'Échec de l\'effacement de l\'historique des appels : $error';
  }

  @override
  String get call_historyCleared => 'Tout l’historique des appels est effacé';

  @override
  String call_historyIncoming(String callType) {
    return '$callType entrant';
  }

  @override
  String call_historyMissed(String callType) {
    return '$callType manqué';
  }

  @override
  String call_historyOutgoing(String callType) {
    return '$callType sortant';
  }

  @override
  String call_historyRejected(String callType) {
    return '$callType rejeté';
  }

  @override
  String get call_inCall => 'En appel';

  @override
  String call_inCallWithGroup(String groupName) {
    return 'En appel · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return 'Dans cet appel ($count)';
  }

  @override
  String get call_incomingAudio => 'Appel audio entrant';

  @override
  String get call_incomingCallChannelName => 'Appel entrant';

  @override
  String get call_incomingGroupAudio => 'Appel audio de groupe entrant';

  @override
  String get call_incomingGroupVideo => 'Appel vidéo de groupe entrant';

  @override
  String get call_incomingVideo => 'Appel vidéo entrant';

  @override
  String get call_infoDescription => 'Description';

  @override
  String get call_infoEmail => 'E-mail';

  @override
  String get call_infoGroupCode => 'Code de groupe';

  @override
  String get call_infoGroupName => 'Nom du groupe';

  @override
  String get call_infoMobile => 'Mobile';

  @override
  String get call_infoTotalMembers => 'Total des membres';

  @override
  String get call_invite => 'Inviter';

  @override
  String get call_inviteToApp => 'Inviter sur FG Tracker';

  @override
  String get call_join => 'Rejoindre';

  @override
  String get call_joinOnAnswer => 'Vous rejoindrez dès que vous répondrez';

  @override
  String get call_kindAudio => 'Appel audio';

  @override
  String get call_kindCall => 'Appel';

  @override
  String get call_kindGroupAudio => 'Appel audio de groupe';

  @override
  String get call_kindGroupCall => 'Appel de groupe';

  @override
  String call_kindGroupOther(String kind) {
    return 'Appel de groupe $kind';
  }

  @override
  String get call_kindGroupVideo => 'Appel vidéo de groupe';

  @override
  String call_kindOther(String kind) {
    return 'Appel $kind';
  }

  @override
  String get call_kindVideo => 'Appel vidéo';

  @override
  String get call_loadDetailFailed =>
      'Échec du chargement des détails de l\'appel';

  @override
  String get call_loadMore => 'Charger plus';

  @override
  String get call_loadRecentFailed => 'Échec du chargement des appels récents';

  @override
  String get call_loginToCall => 'Veuillez vous connecter pour passer un appel';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres dans cet appel',
      one: '1 membre dans cet appel',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'Message';

  @override
  String get call_micActive => 'Le micro est actif';

  @override
  String get call_missedCall => 'Appel manqué';

  @override
  String get call_missedCallChannelName => 'Appel manqué';

  @override
  String get call_missedCallNotification => 'Appel manqué';

  @override
  String get call_more => 'Plus';

  @override
  String get call_mute => 'Muet';

  @override
  String get call_muted => 'Désactivé';

  @override
  String call_nameYou(String name) {
    return '$name (Vous)';
  }

  @override
  String get call_noActiveParticipants => 'Aucun participant actif';

  @override
  String get call_noContactsMatch =>
      'Aucun contact ne correspond à votre recherche';

  @override
  String get call_noGroupsFound => 'Aucun groupe trouvé';

  @override
  String get call_noGroupsYet => 'Aucun groupe pour le moment';

  @override
  String get call_noNameGroup => 'Groupe sans nom';

  @override
  String get call_noRecentCalls => 'Aucun appel récent';

  @override
  String get call_noRecentMatch =>
      'Aucun appel récent ne correspond à votre recherche';

  @override
  String get call_noRecentYet => 'Aucun appel récent pour le moment';

  @override
  String get call_noRegisteredContacts => 'Aucun contact enregistré trouvé';

  @override
  String get call_notInContacts => 'Ce numéro n\'est pas dans vos contacts';

  @override
  String call_notInThisCall(int count) {
    return 'Pas dans cet appel ($count)';
  }

  @override
  String get call_notReady => 'Appel non prêt';

  @override
  String get call_notificationPermissionRationale =>
      'Nécessaire pour afficher les appels entrants.';

  @override
  String get call_notificationPermissionSettings =>
      'Activez les notifications dans Paramètres.';

  @override
  String get call_notificationPermissionTitle => 'Autorisation de notification';

  @override
  String get call_notify => 'Notifier';

  @override
  String get call_notifyFailed => 'Échec de la notification';

  @override
  String get call_notifySent => 'Notifié avec succès';

  @override
  String get call_ongoingChannelDescription =>
      'Maintient l\'appel et le partage d\'écran actifs';

  @override
  String get call_ongoingChannelName => 'Appel en cours';

  @override
  String get call_otherAlreadySharing =>
      'L\'autre personne partage déjà son écran';

  @override
  String get call_otherStartingVideo => 'L\'autre personne active la vidéo';

  @override
  String get call_participant => 'Participant';

  @override
  String get call_participants => 'Participants';

  @override
  String call_personIsSharing(String name) {
    return '$name partage';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name partage son écran';
  }

  @override
  String get call_phone => 'Téléphone';

  @override
  String get call_pleaseWait => 'Veuillez patienter';

  @override
  String get call_recentCalls => 'Appels récents';

  @override
  String get call_resetZoom => 'Réinitialiser le zoom';

  @override
  String get call_returnToCall => 'Retour à l’appel';

  @override
  String get call_screenBeingShared => 'L\'écran est en cours de partage';

  @override
  String get call_screenShareChannelDescription =>
      'Notification de session de partage d’écran active';

  @override
  String get call_screenShareChannelName => 'Service de partage d\'écran';

  @override
  String get call_screenSharePermissionDenied =>
      'Autorisation de partage d\'écran refusée';

  @override
  String get call_screenShareStartFailed =>
      'Impossible de démarrer le partage d\'écran';

  @override
  String get call_screenShareStopped => 'Le partage d\'écran s\'est arrêté';

  @override
  String get call_screenSharingTitle => 'Partage d\'écran';

  @override
  String call_screenVisibleToName(String name) {
    return 'Votre écran est visible par $name';
  }

  @override
  String get call_screenVisibleToOther =>
      'Votre écran est visible par l\'autre personne';

  @override
  String get call_searchHint => 'Rechercher des contacts ou groupes';

  @override
  String get call_sectionLastWeek => 'La semaine dernière';

  @override
  String get call_sectionOlder => 'Plus ancien';

  @override
  String get call_sectionThisWeek => 'Cette semaine';

  @override
  String get call_selectAll => 'Tout sélectionner';

  @override
  String call_selectedCount(int count) {
    return '$count sélectionnés';
  }

  @override
  String get call_selectedDeleteFailed =>
      'Échec de suppression des appels sélectionnés';

  @override
  String call_selectedDeleteFailedError(String error) {
    return 'Échec de suppression des appels sélectionnés : $error';
  }

  @override
  String get call_selectedDeleted => 'Appels sélectionnés supprimés';

  @override
  String get call_selfCallWarning =>
      'Vous ne pouvez pas appeler votre propre numéro.';

  @override
  String get call_sessionConnectFailed =>
      'Échec de connexion à la session d\'appel';

  @override
  String get call_shareScreen => 'Partager l’écran';

  @override
  String get call_shareScreenShort => 'Partager';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return 'Partage dans $groupName • Appuyez pour revenir';
  }

  @override
  String get call_sharingYourScreen => 'Partage de votre écran';

  @override
  String get call_someone => 'Quelqu’un';

  @override
  String get call_speaker => 'Haut-parleur';

  @override
  String get call_started => 'Débuté';

  @override
  String get call_startingScreenShare => 'Démarrage du partage d\'écran…';

  @override
  String get call_statusBusy => 'Occupé';

  @override
  String get call_statusCalling => 'Appel...';

  @override
  String get call_statusCancelled => 'Annulé';

  @override
  String get call_statusCompleted => 'Terminé';

  @override
  String get call_statusConnected => 'Connecté';

  @override
  String get call_statusConnecting => 'Connexion...';

  @override
  String get call_statusDeclined => 'Refusé';

  @override
  String get call_statusJoined => 'Rejoint';

  @override
  String get call_statusMissed => 'Manqué';

  @override
  String get call_statusReconnecting => 'Reconnexion';

  @override
  String get call_statusRinging => 'Sonnerie';

  @override
  String get call_statusVideoConnecting => 'Connexion vidéo';

  @override
  String get call_stop => 'Arrêter';

  @override
  String get call_stopSharing => 'Arrêter le partage';

  @override
  String get call_subtitle => 'Appel audio / vidéo';

  @override
  String get call_swipeUpToAnswer => 'Glissez vers le haut pour répondre';

  @override
  String get call_switch => 'Changer';

  @override
  String get call_switchCameraFailed => 'Impossible de basculer la caméra';

  @override
  String get call_switchToVideoToShare =>
      'Passez en appel vidéo pour partager l\'écran';

  @override
  String get call_tabContacts => 'Contacts';

  @override
  String get call_tabGroups => 'Groupes';

  @override
  String get call_tabRecent => 'Récents';

  @override
  String get call_tapNotifyToInvite => 'Appuyez sur notifier pour inviter';

  @override
  String get call_tapStartBroadcastHint =>
      'Appuyez sur Démarrer la diffusion si l\'invite apparaît';

  @override
  String get call_title => 'Appel';

  @override
  String call_todayAt(String value) {
    return 'Aujourd\'hui, $value';
  }

  @override
  String get call_total => 'Total';

  @override
  String get call_turnOnVideo => 'Activez votre vidéo';

  @override
  String get call_unableToCallContact => 'Impossible d’appeler ce contact';

  @override
  String get call_unableToMakeCall => 'Impossible de passer l’appel';

  @override
  String get call_unableToOpenChat =>
      'Impossible d\'ouvrir le chat pour ce contact';

  @override
  String get call_unableToShareScreen => 'Impossible de partager l’écran';

  @override
  String get call_unavailableTitle => 'Appel indisponible';

  @override
  String get call_unexpectedResponse => 'Réponse inattendue du serveur';

  @override
  String get call_unknown => 'Inconnu';

  @override
  String get call_unknownGroup => 'Groupe inconnu';

  @override
  String get call_unknownUser => 'Utilisateur inconnu';

  @override
  String get call_unmute => 'Réactiver micro';

  @override
  String get call_unselectAll => 'Tout désélectionner';

  @override
  String get call_user => 'Utilisateur';

  @override
  String get call_userNotFound => 'Utilisateur introuvable';

  @override
  String call_userWithId(String id) {
    return 'Utilisateur $id';
  }

  @override
  String get call_video => 'Vidéo';

  @override
  String get call_waitingForBroadcast =>
      'En attente du lancement de la diffusion';

  @override
  String get call_waitingForBroadcastMessage =>
      'Appuyez sur « Démarrer la diffusion » dans la boîte de dialogue pour partager votre écran.';

  @override
  String get call_waitingForMedia => 'En attente du flux média...';

  @override
  String get call_wired => 'Filaire';

  @override
  String get call_yesDelete => 'Oui, supprimer';

  @override
  String call_yesterdayAt(String value) {
    return 'Hier, $value';
  }

  @override
  String get call_youAreSharing => 'Vous partagez';

  @override
  String get call_youAreSharingScreen => 'Vous partagez votre écran';

  @override
  String get call_zoomIn => 'Zoom avant';

  @override
  String get call_zoomOut => 'Zoom arrière';

  @override
  String get chatList_allChats => 'Toutes les discussions';

  @override
  String get chatList_allContacts => 'Tous les contacts';

  @override
  String get chatList_allowAccess => 'Autoriser l\'accès';

  @override
  String get chatList_allowContactsBody =>
      'Nous avons besoin d\'accéder à vos contacts pour savoir qui utilise FG Tracker et vous permettre de discuter ou d\'inviter.';

  @override
  String get chatList_allowContactsTitle => 'Autoriser l\'accès aux contacts';

  @override
  String get chatList_archiveChat => 'Archiver la discussion';

  @override
  String get chatList_archived => 'Archivé';

  @override
  String get chatList_archivedChatsSubtitle => 'Vos conversations masquées';

  @override
  String get chatList_archivedChatsTitle => 'Discussions archivées';

  @override
  String chatList_archivedCount(int count) {
    return 'Archivés ($count)';
  }

  @override
  String get chatList_block => 'Bloquer';

  @override
  String get chatList_blockFailed => 'Impossible de bloquer l’utilisateur';

  @override
  String chatList_blockName(String name) {
    return 'Bloquer $name';
  }

  @override
  String get chatList_blockUser => 'Bloquer l’utilisateur';

  @override
  String get chatList_blockUserConfirm =>
      'Voulez-vous vraiment bloquer cet utilisateur ?';

  @override
  String get chatList_blocked => 'Bloqué';

  @override
  String get chatList_chatCleared => 'Discussion effacée';

  @override
  String get chatList_chooseContactToShare =>
      'Choisissez un contact à partager.';

  @override
  String get chatList_clear => 'Effacer';

  @override
  String get chatList_clearChat => 'Effacer la discussion';

  @override
  String get chatList_clearChatConfirm =>
      'Supprimer tous les messages avec cet utilisateur ?';

  @override
  String get chatList_clearChatFailed => 'Impossible d’effacer la discussion';

  @override
  String get chatList_clearSearch => 'Effacer la recherche';

  @override
  String get chatList_contactAndInfo => 'Contact et infos';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'L\'autorisation des contacts est requise pour partager un contact.';

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
    return 'Échec du chargement des contacts : $error';
  }

  @override
  String get chatList_contactsPermissionNeeded =>
      'Autorisation des contacts requise';

  @override
  String get chatList_contactsWillAppear =>
      'Vos contacts apparaîtront ici dès que possible.';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => 'Désactivé';

  @override
  String get chatList_defaultAbout => 'Bonjour ! J’utilise FG Tracker';

  @override
  String get chatList_deleteChat => 'Supprimer la discussion';

  @override
  String get chatList_deleteChatConfirm =>
      'Supprimer cette conversation de votre liste ?';

  @override
  String get chatList_forwardFailed => 'Impossible de transférer le message.';

  @override
  String get chatList_forwardListLoadFailed =>
      'Impossible de charger la liste de transfert.';

  @override
  String get chatList_forwardTo => 'Transférer à...';

  @override
  String get chatList_forwarded => 'Transféré';

  @override
  String get chatList_groupChatFallback => 'Discussion de groupe';

  @override
  String get chatList_groupDeactivatedBanner =>
      'Ce groupe a été désactivé par l’administrateur';

  @override
  String get chatList_groupFallback => 'Groupe';

  @override
  String get chatList_howToAllow => 'Comment autoriser';

  @override
  String get chatList_howToAllowStep1 =>
      'Appuyez sur « Autoriser l’accès » pour ouvrir les Réglages';

  @override
  String get chatList_howToAllowStep2 => 'Appuyez sur « Autorisations »';

  @override
  String get chatList_howToAllowStep3 => 'Sélectionnez « Contacts »';

  @override
  String get chatList_howToAllowStep4 =>
      'Choisissez « Autoriser », puis revenez à l’application';

  @override
  String get chatList_invite => 'Inviter';

  @override
  String get chatList_inviteChooseHow =>
      'Choisissez le mode d’envoi de l’invitation';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return 'Salut $name ! Rejoins-moi sur FG Tracker.\n\nTélécharger pour Android : $playStoreLink\n\nTélécharger pour iOS : $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'Plus d’applications';

  @override
  String chatList_inviteName(String name) {
    return 'Inviter $name';
  }

  @override
  String get chatList_inviteViaMessage => 'Message';

  @override
  String get chatList_locationHidden => 'Position masquée';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1, $name2 +$count écrivent...';
  }

  @override
  String get chatList_markAsRead => 'Marquer comme lu';

  @override
  String get chatList_markAsUnread => 'Marquer comme non lu';

  @override
  String get chatList_mediaLinksDocs => 'Médias, liens et documents';

  @override
  String get chatList_memberFallback => 'Membre';

  @override
  String get chatList_messageDeleted => 'Ce message a été supprimé';

  @override
  String get chatList_messageForwarded => 'Message transféré';

  @override
  String get chatList_messageIdMissing => 'L’ID du message est manquant.';

  @override
  String chatList_minutesShort(int count) {
    return '$count min';
  }

  @override
  String get chatList_mute1Hour => '1 heure';

  @override
  String get chatList_mute8Hours => '8 heures';

  @override
  String get chatList_muteAlways => 'Jusqu’à réactivation';

  @override
  String get chatList_muteSubtitle =>
      'Choisissez la durée de suspension des notifications.';

  @override
  String get chatList_muteTitle => 'Mettre en sourdine';

  @override
  String get chatList_muteUntilTomorrow => 'Jusqu\'à demain';

  @override
  String get chatList_newChat => 'Nouvelle discussion';

  @override
  String get chatList_newChatSectionContacts =>
      'Nouvelle discussion (Contacts)';

  @override
  String get chatList_newChatSectionInvite =>
      'Inviter à discuter (Non enregistrés)';

  @override
  String get chatList_noArchivedChats => 'Aucune discussion archivée';

  @override
  String get chatList_noArchivedChatsSubtitle =>
      'Les conversations archivées apparaîtront ici.';

  @override
  String get chatList_noChatsFound => 'Aucune discussion trouvée';

  @override
  String get chatList_noChatsSubtitle =>
      'Vos discussions privées apparaîtront ici.';

  @override
  String get chatList_noContactsAvailable => 'Aucun contact disponible';

  @override
  String get chatList_noContactsFound => 'Aucun contact trouvé';

  @override
  String get chatList_noGroupsAvailable => 'Aucun groupe disponible';

  @override
  String get chatList_noGroupsFound => 'Aucun groupe trouvé';

  @override
  String get chatList_noMediaYet => 'Aucun média partagé pour le moment';

  @override
  String get chatList_noMessagesYet => 'Aucun message pour le moment';

  @override
  String get chatList_noPeopleOrGroups => 'Aucune personne ou groupe trouvé';

  @override
  String chatList_noResultsFor(String query) {
    return 'Aucun résultat trouvé pour « $query »';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return 'Aucun résultat pour \'$query\'';
  }

  @override
  String get chatList_noTrackerContacts =>
      'Aucun contact actif trouvé sur le tracker';

  @override
  String get chatList_offlineNotSaved =>
      'Vous êtes hors ligne. La modification n’a pas été enregistrée.';

  @override
  String chatList_oneTyping(String name) {
    return '$name est en train d’écrire...';
  }

  @override
  String get chatList_openSettings => 'Ouvrir les Paramètres';

  @override
  String get chatList_pinChat => 'Épingler la discussion';

  @override
  String get chatList_pinnedChats => 'Discussions épinglées';

  @override
  String get chatList_pleaseTryAgain => 'Veuillez réessayer.';

  @override
  String get chatList_profileCall => 'Appeler';

  @override
  String get chatList_profileMessage => 'Message';

  @override
  String get chatList_profileNotFound => 'Détails du profil introuvables';

  @override
  String get chatList_profileVideoCall => 'Appel vidéo';

  @override
  String get chatList_quickCommSubtitle =>
      'Connectez-vous à votre équipe instantanément';

  @override
  String get chatList_quickCommTitle => 'Communication rapide';

  @override
  String get chatList_quickGroups => 'Groupes';

  @override
  String get chatList_quickGroupsSub => 'Discussions d’équipe';

  @override
  String get chatList_quickSafeZone => 'Zone de sécurité';

  @override
  String get chatList_quickSafeZoneSub => 'Sécurité et alertes';

  @override
  String get chatList_quickTracking => 'Suivi';

  @override
  String get chatList_quickTrackingSub => 'Position en direct';

  @override
  String get chatList_quickWalkie => 'Talkie';

  @override
  String get chatList_quickWalkieSub => 'Push-to-Talk';

  @override
  String get chatList_searchByNameOrNumber => 'Rechercher par nom ou numéro...';

  @override
  String get chatList_searchGroupsHint => 'Rechercher des groupes...';

  @override
  String get chatList_searchHint => 'Rechercher discussions ou messages...';

  @override
  String get chatList_searchHintShort => 'Rechercher...';

  @override
  String get chatList_searchNameOrNumber => 'Rechercher par nom ou numéro';

  @override
  String get chatList_searchResults => 'Résultats de recherche';

  @override
  String get chatList_sectionGroups => 'GROUPES';

  @override
  String get chatList_sectionMyContacts => 'MES CONTACTS';

  @override
  String get chatList_sectionOtherContacts => 'AUTRES CONTACTS';

  @override
  String get chatList_sectionRecentChats => 'DISCUSSIONS RÉCENTES';

  @override
  String get chatList_selectDestination => 'Sélectionner le destinataire';

  @override
  String get chatList_selectDestinationMsg =>
      'Veuillez sélectionner au moins une personne ou un groupe.';

  @override
  String chatList_selectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get chatList_shareContactTitle => 'Partager un contact';

  @override
  String chatList_shareMenuFailed(String error) {
    return 'Impossible d’ouvrir le menu de partage : $error';
  }

  @override
  String get chatList_smsOpenFailed =>
      'Impossible d’ouvrir l’application de messages';

  @override
  String get chatList_someone => 'Quelqu’un';

  @override
  String get chatList_startConversation => 'Démarrer une conversation';

  @override
  String get chatList_subtitle => 'Restez connecté avec votre équipe';

  @override
  String get chatList_telegramOpenFailed => 'Impossible d’ouvrir Telegram';

  @override
  String get chatList_title => 'Discussion';

  @override
  String get chatList_tryAnotherNameOrNumber =>
      'Essayez un autre nom ou numéro.';

  @override
  String get chatList_tryDifferentSearch =>
      'Essayez de rechercher un autre nom ou message.';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1, $name2 sont en train d’écrire...';
  }

  @override
  String get chatList_typing => 'écrit...';

  @override
  String get chatList_unableToCallContact => 'Impossible d’appeler ce contact';

  @override
  String get chatList_unableToLoadContacts =>
      'Impossible de charger les contacts';

  @override
  String get chatList_unarchiveChat => 'Désarchiver la discussion';

  @override
  String get chatList_unblock => 'Débloquer';

  @override
  String get chatList_unblockFailed => 'Impossible de débloquer l’utilisateur';

  @override
  String chatList_unblockName(String name) {
    return 'Débloquer $name';
  }

  @override
  String get chatList_unblockUser => 'Débloquer l’utilisateur';

  @override
  String get chatList_unblockUserConfirm =>
      'Voulez-vous vraiment débloquer cet utilisateur ?';

  @override
  String get chatList_unknown => 'Inconnu';

  @override
  String get chatList_unknownUser => 'Utilisateur inconnu';

  @override
  String get chatList_unnamedContact => 'Contact sans nom';

  @override
  String get chatList_unpinChat => 'Désépingler la discussion';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages non lus',
      one: '1 message non lu',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed =>
      'Impossible de mettre à jour la discussion. Veuillez réessayer.';

  @override
  String get chatList_userFallback => 'Utilisateur';

  @override
  String get chatList_userNotFound => 'Utilisateur introuvable';

  @override
  String get chatList_viewArchived => 'Afficher les discussions archivées';

  @override
  String get chatList_whatsappOpenFailed => 'Impossible d’ouvrir WhatsApp';

  @override
  String get chatList_yourContacts => 'Vos contacts';

  @override
  String get chat_addCaptionHint => 'Ajouter une légende...';

  @override
  String get chat_audioUnavailable => 'Cet audio n\'est plus disponible';

  @override
  String get chat_blockFailed => 'Impossible de bloquer l\'utilisateur';

  @override
  String get chat_call => 'Appeler';

  @override
  String get chat_cameraAccessNeeded =>
      'L\'accès à l\'appareil photo est nécessaire pour prendre des photos et des vidéos dans le chat.';

  @override
  String get chat_cameraModePhoto => 'PHOTO';

  @override
  String get chat_cameraModePortrait => 'PORTRAIT';

  @override
  String get chat_cameraModeVideo => 'VIDÉO';

  @override
  String get chat_cameraStartFailed =>
      'Impossible de démarrer l\'appareil photo.';

  @override
  String get chat_cantMessageUser =>
      'Vous ne pouvez pas envoyer de message à cet utilisateur';

  @override
  String get chat_chatActionsSubtitle => 'Gérez votre discussion';

  @override
  String get chat_chatActionsTitle => 'Actions de discussion';

  @override
  String get chat_clear => 'Effacer';

  @override
  String get chat_clearChat => 'Effacer la discussion';

  @override
  String get chat_clearChatConfirm =>
      'Effacer tous les messages de cette discussion ?';

  @override
  String get chat_clearGroupChatFailed =>
      'Échec de l’effacement du chat de groupe';

  @override
  String get chat_contactBlockedYou => 'Ce contact vous a bloqué';

  @override
  String get chat_contactUnavailable => 'Contact indisponible';

  @override
  String get chat_deleteForEveryone => 'Supprimer pour tous';

  @override
  String get chat_deleteForEveryoneConfirm =>
      'Voulez-vous vraiment supprimer ce message pour tous ?';

  @override
  String get chat_deleteForMe => 'Supprimer pour moi';

  @override
  String get chat_deleteForMeConfirm =>
      'Voulez-vous vraiment supprimer ce message pour vous ?';

  @override
  String get chat_deleteMember => 'Supprimer le membre';

  @override
  String get chat_deleteMemberSubtitle => 'Retirer un membre de ce groupe';

  @override
  String get chat_documentAvailable => 'Le document est disponible';

  @override
  String get chat_documentDownloadFailed =>
      'Le document n’a pas pu être téléchargé.';

  @override
  String get chat_documentOpenFailed =>
      'Impossible d\'ouvrir le document. Veuillez réessayer.';

  @override
  String get chat_documentPreviewUnavailable =>
      'L\'aperçu n\'est pas disponible pour ce type de fichier. Ouvrez le document avec l\'application appropriée.';

  @override
  String get chat_documentUnavailable => 'Ce document n\'est plus disponible';

  @override
  String get chat_downloadFailed => 'Échec du téléchargement';

  @override
  String get chat_edited => 'modifié';

  @override
  String get chat_emptySubtitle =>
      'Dites bonjour 👋 pour démarrer la conversation';

  @override
  String get chat_emptyTitle => 'Aucun message pour le moment';

  @override
  String get chat_fetchingLocation => 'Recherche de la position...';

  @override
  String get chat_finishVoiceRecordingFirst =>
      'Terminez ou annulez d\'abord l\'enregistrement vocal';

  @override
  String get chat_forwarded => 'Transféré';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get chat_groupActionsSubtitle =>
      'Gérez les paramètres de votre groupe';

  @override
  String get chat_groupActionsTitle => 'Actions de groupe';

  @override
  String get chat_groupChatCleared => 'Chat de groupe effacé avec succès';

  @override
  String get chat_groupDeactivated =>
      'Ce groupe a été désactivé par l’administrateur';

  @override
  String get chat_imageFailed => 'Échec de l\'image';

  @override
  String get chat_listen => 'Écouter';

  @override
  String get chat_listenEnglish => 'Écouter (Anglais)';

  @override
  String get chat_listenHindi => 'Écouter (Hindi)';

  @override
  String get chat_loadFailedSubtitle =>
      'Vérifiez votre connexion et réessayez.';

  @override
  String get chat_loadFailedTitle => 'Impossible de charger les messages';

  @override
  String get chat_locationFetchFailed =>
      'Impossible d’obtenir votre position. Veuillez réessayer.';

  @override
  String get chat_locationPermissionNeeded =>
      'L\'autorisation de localisation est nécessaire pour partager votre position.';

  @override
  String get chat_locationPermissionOff =>
      'L\'autorisation de localisation est désactivée pour cette application. Activez-la dans les Paramètres pour partager votre position.';

  @override
  String get chat_locationServicesOff =>
      'Activez les services de localisation pour partager votre position.';

  @override
  String get chat_locationUnavailable => 'Position indisponible';

  @override
  String get chat_mediaMissing => 'Média manquant';

  @override
  String get chat_mediaMissingToast =>
      'Le média est manquant. Ce fichier n\'est plus disponible.';

  @override
  String get chat_mediaUnavailable => 'Ce média n\'est plus disponible';

  @override
  String get chat_menuForward => 'Transférer';

  @override
  String get chat_menuMessageInfo => 'Infos sur le message';

  @override
  String get chat_menuPin => 'Épingler le message';

  @override
  String get chat_menuReply => 'Répondre';

  @override
  String get chat_menuUnpin => 'Désépingler le message';

  @override
  String get chat_messageCopied => 'Message copié';

  @override
  String get chat_messageDeleted => 'Ce message a été supprimé';

  @override
  String get chat_messageNotAvailable => 'Message non disponible';

  @override
  String get chat_messageNotSent => 'Message non envoyé. Veuillez réessayer.';

  @override
  String get chat_noCameraFound =>
      'Aucun appareil photo trouvé sur cet appareil.';

  @override
  String get chat_noLongerMember => 'Vous n\'êtes plus membre de ce groupe';

  @override
  String get chat_noMediaAvailable => 'Aucun média disponible';

  @override
  String get chat_offlineNotSent => 'Vous êtes hors ligne. Message non envoyé.';

  @override
  String get chat_openDocument => 'Ouvrir le document';

  @override
  String get chat_openInGoogleMaps => 'Ouvrir dans Google Maps';

  @override
  String get chat_openSettings => 'Ouvrir les Paramètres';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'Cette photo n\'est plus disponible';

  @override
  String get chat_previewAttendancePoll => 'Sondage de présence';

  @override
  String get chat_previewAudio => 'Audio';

  @override
  String get chat_previewContact => 'Contact';

  @override
  String get chat_previewDocument => 'Document';

  @override
  String get chat_previewLocation => 'Position';

  @override
  String get chat_previewMessage => 'Message';

  @override
  String get chat_previewNewMessage => 'Nouveau message';

  @override
  String get chat_previewOwnDeleted => 'Vous avez supprimé ce message';

  @override
  String get chat_previewPhoto => 'Photo';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => 'Sondage';

  @override
  String get chat_previewSticker => 'Autocollant';

  @override
  String get chat_previewVideo => 'Vidéo';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vidéos',
      one: '1 vidéo',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => 'Message vocal';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return 'Message vocal ($duration)';
  }

  @override
  String get chat_recordingFailed => 'Échec de l\'enregistrement';

  @override
  String get chat_removeMember => 'Retirer le membre';

  @override
  String get chat_removeMemberConfirm =>
      'Voulez-vous vraiment retirer ce membre du groupe ?';

  @override
  String get chat_replyHint => 'Répondre au message...';

  @override
  String get chat_searchMessages => 'Rechercher des messages';

  @override
  String get chat_searchMessagesHint => 'Rechercher des messages...';

  @override
  String get chat_searchMessagesSubtitle =>
      'Rechercher des messages par mot-clé';

  @override
  String get chat_sendLocation => 'Envoyer la position';

  @override
  String get chat_shareLocation => 'Partager la position';

  @override
  String get chat_shareVideoFailed => 'Impossible de partager la vidéo';

  @override
  String get chat_sharedFromApp => 'Partagé depuis FG Tracker';

  @override
  String get chat_sharedLocation => 'Position partagée';

  @override
  String get chat_showOriginal => 'Afficher l\'original';

  @override
  String get chat_someone => 'Quelqu’un';

  @override
  String get chat_statusLabel => 'Statut';

  @override
  String get chat_statusUnavailable =>
      'Cette mise à jour de statut n\'est plus disponible';

  @override
  String get chat_stop => 'Arrêter';

  @override
  String get chat_stopEnglish => 'Arrêter (Anglais)';

  @override
  String get chat_stopHindi => 'Arrêter (Hindi)';

  @override
  String get chat_takePhotoFailed => 'Échec de la prise de photo';

  @override
  String get chat_translatedToEnglish => 'Traduit en anglais';

  @override
  String get chat_translatedToHindi => 'Traduit en hindi';

  @override
  String get chat_translating => 'Traduction...';

  @override
  String get chat_tryAgain => 'Réessayer';

  @override
  String get chat_typeMessageHint => 'Écrivez un message...';

  @override
  String get chat_typing => 'écrit...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes écrivent...',
      one: '1 personne écrit...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name est en train d’écrire...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1, $name2 sont en train d’écrire...';
  }

  @override
  String get chat_unableToOpen => 'Impossible d’ouvrir';

  @override
  String get chat_unableToOpenGoogleMaps => 'Impossible d’ouvrir Google Maps';

  @override
  String get chat_unblock => 'Débloquer';

  @override
  String get chat_unblockContact => 'Débloquer le contact';

  @override
  String get chat_unblockContactConfirm =>
      'Voulez-vous vraiment débloquer ce contact ?';

  @override
  String get chat_unblockFailed => 'Impossible de débloquer l\'utilisateur';

  @override
  String get chat_unknown => 'Inconnu';

  @override
  String get chat_unknownLocation => 'Position inconnue';

  @override
  String get chat_unsupportedMessage =>
      'Ce message n\'est pas pris en charge dans cette version de l\'application';

  @override
  String get chat_updateGroup => 'Mettre à jour le groupe';

  @override
  String get chat_updateGroupSubtitle =>
      'Modifier les informations du groupe actuel';

  @override
  String chat_uploadFileFailed(String path) {
    return 'Échec du téléversement de $path';
  }

  @override
  String get chat_userBlocked => 'Utilisateur bloqué avec succès';

  @override
  String get chat_userUnblocked => 'Utilisateur débloqué avec succès';

  @override
  String get chat_videoDownloaded => 'Vidéo téléchargée avec succès';

  @override
  String get chat_videoThumbnailFailed =>
      'Échec de génération de la miniature de la vidéo';

  @override
  String get chat_videoUnavailable => 'Cette vidéo n\'est plus disponible';

  @override
  String get chat_videoUploadFailed => 'Échec du téléversement de la vidéo';

  @override
  String get chat_voicePlayFailed => 'Impossible de lire le message vocal';

  @override
  String get chat_voiceUploadFailed =>
      'Échec du téléversement du message vocal. Veuillez réessayer.';

  @override
  String get chat_youBlockedContact => 'Vous avez bloqué ce contact';

  @override
  String get common_add => 'Ajouter';

  @override
  String get common_allow => 'Autoriser';

  @override
  String get common_back => 'Retour';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_comingSoon => 'Bientôt disponible';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get common_continue => 'Continuer';

  @override
  String get common_copied => 'Copié';

  @override
  String get common_copy => 'Copier';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_dismiss => 'Ignorer';

  @override
  String get common_done => 'Terminé';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_error => 'Erreur';

  @override
  String get common_exit => 'Quitter';

  @override
  String get common_gotIt => 'Compris';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count heures',
      one: 'Il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'À l\'instant';

  @override
  String common_lastSeen(String time) {
    return 'Vu pour la dernière fois: $time';
  }

  @override
  String get common_loading => 'Chargement…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count min',
      one: 'Il y a 1 min',
    );
    return '$_temp0';
  }

  @override
  String get common_next => 'Suivant';

  @override
  String get common_no => 'Non';

  @override
  String get common_noData => 'Aucune donnée trouvée';

  @override
  String get common_noInternet => 'Pas de connexion Internet';

  @override
  String get common_notNow => 'Pas maintenant';

  @override
  String get common_offline => 'Hors ligne';

  @override
  String get common_ok => 'OK';

  @override
  String get common_online => 'En ligne';

  @override
  String get common_open => 'Ouvrir';

  @override
  String get common_permissionDenied => 'Autorisation refusée';

  @override
  String get common_remove => 'Supprimer';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_search => 'Rechercher';

  @override
  String get common_send => 'Envoyer';

  @override
  String get common_settings => 'Paramètres';

  @override
  String get common_share => 'Partager';

  @override
  String get common_somethingWentWrong =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get common_submit => 'Soumettre';

  @override
  String get common_success => 'Succès';

  @override
  String get common_today => 'Aujourd\'hui';

  @override
  String common_todayAt(String time) {
    return 'Aujourd\'hui, $time';
  }

  @override
  String get common_tryAgain => 'Réessayer';

  @override
  String get common_viewAll => 'Voir tout';

  @override
  String get common_yes => 'Oui';

  @override
  String get common_yesterday => 'Hier';

  @override
  String get common_you => 'Vous';

  @override
  String get dialog_allowLocationAccess => 'Autoriser l’accès à la position';

  @override
  String get dialog_anErrorOccurred => 'Une erreur est survenue !';

  @override
  String get dialog_important => 'Important !';

  @override
  String get dialog_locationPermissionRequired =>
      'Autorisation de localisation requise';

  @override
  String get dialog_locationPurposeBody =>
      'Pour améliorer l\'efficacité du service, notre application demande l\'autorisation d\'accéder à votre position afin de l\'enregistrer. Cela permet de naviguer avec précision vers votre lieu de travail.';

  @override
  String get dialog_locationSettingsAndroid =>
      'Sans accès à la localisation, nous ne pourrons pas détecter votre position actuelle. Appuyez sur \'Paramètres\', puis \'Autorisations\', et autorisez l\'accès à la position.';

  @override
  String get dialog_locationSettingsIos =>
      'Cette application nécessite l\'accès à votre position pour fournir des services géolocalisés. Veuillez aller dans \'Réglages\' et activer la localisation.';

  @override
  String get dialog_loggedInElsewhere =>
      'Vous avez été connecté depuis un autre appareil.';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      'Vous avez été connecté depuis un autre appareil. Veuillez vous reconnecter.';

  @override
  String get dialog_logoutConfirm => 'Voulez-vous vous déconnecter ?';

  @override
  String get dialog_selectAllowAllTheTime =>
      'Dans la prochaine fenêtre, veuillez sélectionner\n\'Toujours autoriser\'.';

  @override
  String get dialog_sessionExpiredTitle => 'Session expirée';

  @override
  String get editProfile_fullNameLabel => 'Nom complet';

  @override
  String get editProfile_personalInfo => 'Informations personnelles';

  @override
  String get editProfile_phoneLabel => 'Numéro de téléphone';

  @override
  String get editProfile_saveButton => 'Enregistrer les modifications';

  @override
  String get editProfile_tapPhotoHint => 'Appuyez sur la photo pour changer';

  @override
  String get editProfile_title => 'Modifier le profil';

  @override
  String get forceUpdate_currentInstalled => 'VERSION ACTUELLE';

  @override
  String get forceUpdate_defaultMessage =>
      'Une nouvelle version de FG Tracker est disponible. Veuillez mettre à jour pour continuer.';

  @override
  String get forceUpdate_defaultTitle => 'Mise à jour requise';

  @override
  String get forceUpdate_fallbackMessage =>
      'Une nouvelle version de FG Tracker contenant des améliorations critiques est disponible. Veuillez mettre à jour pour continuer.';

  @override
  String get forceUpdate_footer =>
      'La mise à jour est requise pour utiliser FG Tracker';

  @override
  String get forceUpdate_requiredVersion => 'VERSION REQUISE';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return 'Mettre à jour sur $storeName';
  }

  @override
  String get groupDialog_audioCall => 'Appel audio';

  @override
  String get groupDialog_audioCallSubtitle =>
      'Démarrer une conversation vocale';

  @override
  String get groupDialog_call => 'Appeler';

  @override
  String get groupDialog_chat => 'Discussion';

  @override
  String get groupDialog_codeEmpty => 'Le code de groupe ne peut pas être vide';

  @override
  String get groupDialog_codeLabel => 'Code de groupe';

  @override
  String get groupDialog_createButton => 'Créer le groupe';

  @override
  String get groupDialog_createTitle => 'Créer un nouveau groupe';

  @override
  String get groupDialog_descHint => 'Entrez la description du groupe';

  @override
  String get groupDialog_descLabel => 'Description du groupe (Facultatif)';

  @override
  String groupDialog_distance(String distance) {
    return 'Distance : $distance';
  }

  @override
  String get groupDialog_enterCodeManually =>
      'Entrer le code de groupe manuellement';

  @override
  String get groupDialog_enterCodeTitle => 'Entrez le code de groupe';

  @override
  String get groupDialog_fillDetails => 'Remplissez les détails ci-dessous';

  @override
  String get groupDialog_getDirections => 'Obtenir l’itinéraire';

  @override
  String get groupDialog_join => 'Rejoindre le groupe';

  @override
  String groupDialog_lastSeen(String time) {
    return 'Vu pour la dernière fois: $time';
  }

  @override
  String get groupDialog_locationHidden => 'Position masquée';

  @override
  String get groupDialog_locationUnavailable => 'Position indisponible';

  @override
  String get groupDialog_member => 'Membre';

  @override
  String get groupDialog_memberInfo => 'Infos sur le membre';

  @override
  String get groupDialog_nameHint => 'Entrez le nom du groupe';

  @override
  String get groupDialog_nameLabel => 'Nom du groupe';

  @override
  String get groupDialog_noQrInImage =>
      'Aucun code QR trouvé dans l’image sélectionnée.';

  @override
  String get groupDialog_noValidQr => 'Aucun code QR valide trouvé.';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'Erreur lors du décodage du QR depuis la galerie : $error';
  }

  @override
  String get groupDialog_scanCamera => 'Scanner avec l’appareil photo';

  @override
  String get groupDialog_selectCallType => 'Sélectionner le type d\'appel';

  @override
  String get groupDialog_update => 'Mettre à jour';

  @override
  String get groupDialog_updateTitle => 'Mettre à jour le groupe';

  @override
  String get groupDialog_uploadGallery => 'Importer depuis la galerie';

  @override
  String get groupDialog_videoCall => 'Appel vidéo';

  @override
  String get groupDialog_videoCallSubtitle => 'Démarrer une conversation vidéo';

  @override
  String get groupDialog_yourLocation => 'Votre position actuelle';

  @override
  String get groupInfo_active => 'Actif';

  @override
  String get groupInfo_admin => 'Admin';

  @override
  String get groupInfo_allGroups => 'Tous les groupes';

  @override
  String get groupInfo_allGroupsSubtitle => 'Restez connecté avec vos équipes';

  @override
  String get groupInfo_areYouSure => 'Êtes-vous sûr ?';

  @override
  String get groupInfo_audioCall => 'Appel audio';

  @override
  String get groupInfo_clearChatConfirm =>
      'Supprimer tous les messages de cet appareil ?';

  @override
  String get groupInfo_createdBy => 'Créé par';

  @override
  String get groupInfo_detailsNotFound => 'Détails du groupe introuvables';

  @override
  String get groupInfo_exitGroup => 'Quitter le groupe';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return 'Voulez-vous vraiment quitter \"$groupName\" ?';
  }

  @override
  String get groupInfo_exitGroupQuestion => 'Voulez-vous quitter ce groupe ?';

  @override
  String get groupInfo_group => 'Groupe';

  @override
  String get groupInfo_groupAdmin => 'Admin du groupe';

  @override
  String get groupInfo_groupCallFailed =>
      'Impossible de démarrer l\'appel de groupe. Veuillez réessayer.';

  @override
  String get groupInfo_groupCodeCopied => 'Code de groupe copié !';

  @override
  String get groupInfo_groupSettings => 'Paramètres du groupe';

  @override
  String get groupInfo_groupSettingsSubtitle =>
      'Modifier les infos, la confidentialité, etc.';

  @override
  String get groupInfo_inactive => 'Inactif';

  @override
  String get groupInfo_inviteCopied => 'Texte d\'invitation copié';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'Rejoignez mon groupe \"$groupName\" sur FG Tracker';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'Rejoignez mon groupe \"$groupName\" sur FG Tracker. Code : $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'Inviter via un lien';

  @override
  String get groupInfo_mediaLinksDocs => 'Médias, liens et documents';

  @override
  String get groupInfo_member => 'Membre';

  @override
  String get groupInfo_members => 'Membres';

  @override
  String get groupInfo_messageAction => 'Message';

  @override
  String groupInfo_nameYou(String name) {
    return '$name (Vous)';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return 'Aucun groupe trouvé pour \'$query\'';
  }

  @override
  String get groupInfo_noGroupsYet =>
      'Vous n\'avez pas encore rejoint ni créé de groupe.\nCommencez à explorer dès maintenant !';

  @override
  String get groupInfo_noMediaYet => 'Aucun média partagé pour le moment';

  @override
  String get groupInfo_removeFromGroup => 'Retirer du groupe';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return 'Voulez-vous vraiment retirer $name du groupe ?';
  }

  @override
  String get groupInfo_searchGroupsHint => 'Rechercher des groupes...';

  @override
  String get groupInfo_showLess => 'Afficher moins';

  @override
  String get groupInfo_teamCode => 'Code d\'équipe';

  @override
  String groupInfo_totalCount(int count) {
    return '$count au total';
  }

  @override
  String get groupInfo_unknownGroup => 'Groupe inconnu';

  @override
  String get groupInfo_unnamedGroup => 'Groupe sans nom';

  @override
  String get groupInfo_videoCall => 'Appel vidéo';

  @override
  String get groupInfo_viewAllMembers => 'Voir tous les membres';

  @override
  String get group_activatedSuccess => 'Groupe activé avec succès';

  @override
  String get group_addMember => 'Ajouter un membre';

  @override
  String get group_alignQr => 'Alignez le QR dans le cadre';

  @override
  String get group_areYouSure => 'Êtes-vous sûr ?';

  @override
  String get group_chatWithMembers => 'Discutez avec les membres du groupe';

  @override
  String get group_codeCopied => 'Code de groupe copié !';

  @override
  String group_codeShareInfo(String code) {
    return 'Code de groupe : $code — partagez-le pour inviter d’autres personnes';
  }

  @override
  String get group_copyCode => 'Copier le code';

  @override
  String get group_created => 'Créé';

  @override
  String get group_createdJustNow => 'Créé à l’instant';

  @override
  String get group_deactivatedSuccess => 'Groupe désactivé avec succès';

  @override
  String get group_defaultName => 'Groupe';

  @override
  String get group_deleteGroup => 'Supprimer le groupe';

  @override
  String get group_deleteGroupConfirm => 'Voulez-vous supprimer ce groupe ?';

  @override
  String get group_deletedSuccess => 'Groupe supprimé avec succès';

  @override
  String get group_download => 'Télécharger';

  @override
  String get group_downloadChannelDescription =>
      'Notifie lorsque le code QR est téléchargé';

  @override
  String get group_downloadChannelName => 'Notifications de téléchargement';

  @override
  String get group_enableLocationToJoin =>
      'Veuillez activer les services de localisation pour rejoindre un groupe.';

  @override
  String get group_exitGroup => 'Quitter le groupe';

  @override
  String get group_exitGroupConfirm => 'Voulez-vous quitter ce groupe ?';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return 'Voulez-vous vraiment quitter « $groupName » ? Vous aurez besoin du code pour rejoindre.';
  }

  @override
  String get group_exitedSuccess => 'Vous avez quitté le groupe avec succès';

  @override
  String get group_goToGroups => 'Aller aux groupes →';

  @override
  String get group_groupMessage => 'Message de groupe';

  @override
  String get group_invalidResponseFormat => 'Format non valide';

  @override
  String get group_joinedJustNow => 'Rejoint à l’instant';

  @override
  String get group_joinedRecently => 'Récent';

  @override
  String get group_leftJustNow => 'Quitté à l’instant';

  @override
  String get group_locationNoLongerShared =>
      'Votre position n’est plus partagée avec ce groupe';

  @override
  String get group_locationPermissionToJoin =>
      'L’autorisation de localisation est requise pour rejoindre un groupe.';

  @override
  String get group_locationShared =>
      'Votre position est partagée avec ce groupe';

  @override
  String get group_memberFallbackName => 'Membre';

  @override
  String group_membersMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres · $when',
      one: '1 membre · $when',
    );
    return '$_temp0';
  }

  @override
  String get group_noContactsFound => 'Aucun contact trouvé';

  @override
  String get group_noGroupCode => 'Aucun code de groupe disponible';

  @override
  String get group_noNewMessages =>
      'Vous ne recevrez plus de messages de ce groupe';

  @override
  String get group_noNumber => 'Aucun numéro';

  @override
  String get group_openGroup => 'Ouvrir le groupe →';

  @override
  String get group_other => 'Autre';

  @override
  String get group_qrSavedBody => 'Appuyez pour ouvrir votre code QR';

  @override
  String get group_qrSavedTitle => 'Code QR enregistré';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 Code de groupe : $groupCode\n\nRejoignez mon groupe instantanément avec le code QR ou le code ci-dessus.\n\n📲 Téléchargez l’application :\n$appLink';
  }

  @override
  String get group_scanToJoin => 'Scannez ce code QR pour rejoindre le groupe';

  @override
  String get group_searchMemberHint => 'Rechercher un membre...';

  @override
  String get group_shareCodeInfo =>
      'Partagez le code de groupe pour que d’autres puissent rejoindre';

  @override
  String get group_shareQr => 'Partager le QR';

  @override
  String get group_shareQrToInvite =>
      'Partagez le code QR pour inviter des membres';

  @override
  String get group_sheetCreatedSubtitle =>
      'Votre groupe est prêt. Partagez le code pour que les membres rejoignent.';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name, votre groupe est prêt. Partagez le code pour les membres.';
  }

  @override
  String get group_sheetCreatedTitle => 'Groupe créé !';

  @override
  String get group_sheetJoinedSubtitle =>
      'Bienvenue, vous êtes maintenant membre de ce groupe.';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return 'Bienvenue $name, vous êtes maintenant membre de ce groupe.';
  }

  @override
  String get group_sheetJoinedTitle => 'Rejoint avec succès !';

  @override
  String get group_sheetLeftSubtitle => 'Vous n’êtes plus membre de ce groupe.';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name, vous n’êtes plus membre de ce groupe.';
  }

  @override
  String get group_sheetLeftTitle => 'Vous avez quitté le groupe';

  @override
  String get group_showQrCode => 'Afficher le code QR';

  @override
  String get group_startConversation =>
      'N’hésitez pas à entamer la conversation';

  @override
  String get group_statusUpdateFailed =>
      'Échec de la mise à jour du statut du groupe';

  @override
  String get group_teamCode => 'Code d’équipe';

  @override
  String get group_teamCodeLabel => 'Code d’équipe : ';

  @override
  String get group_track => 'Suivre';

  @override
  String get group_unnamedMember => 'Membre sans nom';

  @override
  String get group_unnamedTrip => 'Voyage sans nom';

  @override
  String get group_updateGroupConfirm =>
      'Voulez-vous vraiment mettre à jour les détails du groupe ?';

  @override
  String get group_updateGroupTitle => 'Mettre à jour le groupe';

  @override
  String get group_youAreAdmin => 'Vous êtes l’administrateur de ce groupe';

  @override
  String get home_actionAllContacts => 'Tous les contacts';

  @override
  String get home_actionAudioVideoCall => 'Appel audio/vidéo';

  @override
  String get home_actionChatting => 'Discussion';

  @override
  String get home_actionSafeZone => 'Zone sécurisée';

  @override
  String get home_actionTracking => 'Suivi';

  @override
  String get home_actionWalkieTalkie => 'Talkie-walkie';

  @override
  String get home_active => 'Actif';

  @override
  String get home_activeSessions => 'Sessions actives';

  @override
  String home_activeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions actives',
      one: '1 session active',
    );
    return '$_temp0';
  }

  @override
  String get home_allMembers => 'Tous les membres';

  @override
  String get home_createGroup => 'Créer un groupe';

  @override
  String get home_createGroupSubtitle => 'Créer un nouveau groupe';

  @override
  String get home_goodToSeeYou => 'Ravi de vous revoir 👋';

  @override
  String home_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
    );
    return '$_temp0';
  }

  @override
  String home_helloName(String name) {
    return 'Bonjour $name';
  }

  @override
  String get home_inactive => 'Inactif';

  @override
  String get home_joinGroup => 'Rejoindre un groupe';

  @override
  String get home_joinGroupSubtitle => 'Rejoindre un groupe existant';

  @override
  String home_lastSeen(String time) {
    return 'Vu pour la dernière fois $time';
  }

  @override
  String get home_newThisMonth => 'Nouveaux ce mois-ci';

  @override
  String get home_noActivePrivateSessions => 'Aucune session privée active';

  @override
  String get home_noGroupsAvailable => 'Aucun groupe disponible';

  @override
  String get home_noGroupsFound => 'Aucun groupe trouvé';

  @override
  String get home_noMembersFound => 'Aucun membre trouvé';

  @override
  String home_noMembersMatch(String query) {
    return 'Aucun membre ne correspond à \'$query\'';
  }

  @override
  String get home_noMembersOnline => 'Aucun membre en ligne actuellement';

  @override
  String get home_noNameGroup => 'Groupe sans nom';

  @override
  String get home_noRecentlyActiveMembers => 'Aucun membre actif récemment';

  @override
  String get home_onlineNow => 'En ligne maintenant';

  @override
  String get home_peopleOnline => 'Personnes en ligne';

  @override
  String get home_peopleOnlineSubtitle =>
      'Ces membres sont actifs dans l’application et disponibles.';

  @override
  String get home_privateMode => 'Mode privé';

  @override
  String get home_privateModeIsOn => 'Le mode privé est activé';

  @override
  String get home_privateModeOffHint =>
      'Lorsque le mode privé est désactivé, les autres peuvent voir votre position.';

  @override
  String get home_privateModeOnHint =>
      'Lorsque le mode privé est activé, les autres ne peuvent pas voir votre position.';

  @override
  String get home_quickActionsSubtitle =>
      'Tout ce dont vous avez besoin, à portée de main.';

  @override
  String get home_quickActionsTitle => 'Actions rapides';

  @override
  String get home_recentlyOnline => 'En ligne récemment';

  @override
  String get home_searchGroupsHint => 'Rechercher des groupes...';

  @override
  String get home_searchMembersHint => 'Rechercher des membres...';

  @override
  String get home_showLess => 'Afficher moins';

  @override
  String get home_sortNameAsc => 'Trier : Nom (A-Z)';

  @override
  String get home_sortNameDesc => 'Trier : Nom (Z-A)';

  @override
  String home_startedAt(String time) {
    return 'Commencé à $time';
  }

  @override
  String get home_statGroups => 'Groupes';

  @override
  String get home_statMembers => 'Membres';

  @override
  String get home_statNow => 'Maintenant';

  @override
  String get home_statTotal => 'Total';

  @override
  String get home_totalMembers => 'Membres au total';

  @override
  String home_totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres au total',
      one: '1 membre au total',
    );
    return '$_temp0';
  }

  @override
  String get home_unableToFetchGroups => 'Impossible de récupérer les groupes';

  @override
  String get home_unknownMember => 'Membre inconnu';

  @override
  String get home_upgradeSubtitle =>
      'Débloquez des fonctionnalités avancées pour votre équipe';

  @override
  String get home_upgradeToPremium => 'Passer à Premium';

  @override
  String get home_viewPlans => 'Voir les forfaits';

  @override
  String get home_walkieExpired => 'Expiré';

  @override
  String get home_walkieOneHourFree => '1 h gratuite';

  @override
  String get home_walkieRenew => 'Renouveler';

  @override
  String get home_walkieSubscribed => 'Abonné';

  @override
  String get home_youAreInvisible => 'Vous êtes invisible';

  @override
  String get home_youAreVisible => 'Vous êtes visible';

  @override
  String get http_networkError =>
      'Une erreur est survenue. Veuillez réessayer !';

  @override
  String get http_sessionExpired =>
      'Session expirée. Veuillez vous reconnecter.';

  @override
  String get http_unexpectedError =>
      'Une erreur inattendue est survenue. Veuillez réessayer.';

  @override
  String get imagePicker_camera => 'Appareil photo';

  @override
  String get imagePicker_cancel => 'Annuler';

  @override
  String get imagePicker_cropTitle => 'Recadrer l\'image';

  @override
  String get imagePicker_gallery => 'Galerie';

  @override
  String get imagePicker_title => 'Choisissez une option';

  @override
  String get intro_realTimeTrackingSubtitle =>
      'Visualisez instantanément la position de vos proches ou collègues sur la carte.';

  @override
  String get intro_realTimeTrackingTitle => 'Suivi en temps réel';

  @override
  String get intro_secureSubtitle =>
      'Partagez votre position en direct avec\nvos contacts en toute sécurité et confidentialité.';

  @override
  String get intro_secureTitle => 'Sécurisé et simple';

  @override
  String get intro_skip => 'Passer';

  @override
  String get intro_walkieSubtitle =>
      'Pas de réseau ? Aucun problème. Restez\nconnecté partout.';

  @override
  String get intro_walkieTitle => 'Fonction\ntalkie-walkie';

  @override
  String login_dataSecure(String percent) {
    return 'Vos données sont $percent sécurisées';
  }

  @override
  String get login_enterMobileNumber => 'Entrez le numéro de portable';

  @override
  String get media_cannotOpen => 'Impossible d’ouvrir';

  @override
  String get media_documentNotFound => 'Document introuvable';

  @override
  String get media_invalidLink => 'Lien non valide';

  @override
  String get media_noDocuments => 'Aucun document trouvé';

  @override
  String get media_noLinks => 'Aucun lien trouvé';

  @override
  String get media_noMedia => 'Aucun média trouvé';

  @override
  String get media_tabDocs => 'Documents';

  @override
  String media_tabDocsCount(int count) {
    return 'Documents ($count)';
  }

  @override
  String get media_tabLinks => 'Liens';

  @override
  String media_tabLinksCount(int count) {
    return 'Liens ($count)';
  }

  @override
  String get media_tabMedia => 'Médias';

  @override
  String media_tabMediaCount(int count) {
    return 'Médias ($count)';
  }

  @override
  String get media_title => 'Médias, liens et documents';

  @override
  String get media_videoNotFound => 'Vidéo introuvable';

  @override
  String get menu_contactUsSubtitle => 'En savoir plus sur nous';

  @override
  String get menu_editProfile => 'Modifier le profil';

  @override
  String get menu_editProfileSubtitle => 'Mettez à jour vos informations';

  @override
  String get menu_followUsOn => 'Suivez-nous sur';

  @override
  String get menu_logOut => 'Déconnexion';

  @override
  String get menu_logOutConfirmMessage =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get menu_logOutSubtitle => 'Déconnectez-vous de l’app';

  @override
  String get menu_profileImageUpdateFailed =>
      'Échec de la mise à jour de la photo de profil';

  @override
  String get menu_profileImageUpdated =>
      'Photo de profil mise à jour avec succès';

  @override
  String get notif_accept => 'Accepter';

  @override
  String get notif_channelHighImportanceDesc =>
      'Canal par défaut pour les notifications de haute importance';

  @override
  String get notif_channelHighImportanceName =>
      'Notifications de haute importance';

  @override
  String get notif_channelWalkieAudioDesc =>
      'Maintient la communication vocale en direct et la capture du micro en arrière-plan';

  @override
  String get notif_channelWalkieAudioName => 'Audio en direct du talkie-walkie';

  @override
  String get notif_channelWalkieCallsDesc => 'Appels entrants de talkie-walkie';

  @override
  String get notif_channelWalkieCallsName => 'Appels de talkie-walkie';

  @override
  String get notif_channelWalkieDesc =>
      'Appels de groupe et mises à jour vocales';

  @override
  String get notif_channelWalkieLiveDesc =>
      'Notifications pour les canaux de talkie-walkie actifs';

  @override
  String get notif_channelWalkieLiveName => 'Canaux de talkie-walkie en direct';

  @override
  String get notif_channelWalkieName => 'Talkie-walkie';

  @override
  String notif_connectedIn(String group) {
    return 'Connecté dans $group • Flux audio en direct';
  }

  @override
  String get notif_goToWalkie => 'Aller à l’écran Talkie-walkie';

  @override
  String get notif_incomingWalkieTitle => 'Talkie-walkie entrant';

  @override
  String notif_isTalking(String name) {
    return '$name est en train de parler';
  }

  @override
  String get notif_leave => 'Quitter';

  @override
  String get notif_openWalkie => 'Ouvrir Talkie-walkie';

  @override
  String get notif_reject => 'Refuser';

  @override
  String notif_stoppedTalking(String name) {
    return '$name a fini de parler';
  }

  @override
  String get notif_walkieActiveConversation =>
      'Conversation talkie-walkie active';

  @override
  String get notif_walkieActiveTitle => 'Talkie-walkie actif';

  @override
  String notif_wantsToTalk(String name) {
    return '$name souhaite parler';
  }

  @override
  String get notifications_clearAll => 'Effacer toutes les notifications';

  @override
  String get notifications_clearedSuccess =>
      'Toutes les notifications ont été effacées avec succès';

  @override
  String get notifications_emptySubtitle =>
      'Vous n’avez aucune nouvelle alerte pour le moment.';

  @override
  String get notifications_emptyTitle => 'Aucune notification pour le moment';

  @override
  String get notifications_filterAll => 'Tout';

  @override
  String get notifications_filterCalls => 'Appels';

  @override
  String get notifications_filterChats => 'Discussions';

  @override
  String get notifications_filterUnread => 'Non lues';

  @override
  String get notifications_loadingDetails =>
      'Chargement des détails de la notification';

  @override
  String get notifications_recentCalls => 'Appels récents';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get otpCharges_chargedNotice =>
      'Désormais, chaque OTP de connexion vers votre numéro est payant. Le renvoi est gratuit (jusqu’à 3 essais).';

  @override
  String get otpCharges_chargesApplyTo => 'Les frais s’appliquent à';

  @override
  String get otpCharges_eachOtpCosts => 'Chaque OTP coûte';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'Chaque OTP coûte $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'Chaque OTP coûte $amount, y compris $percent % de TVA';
  }

  @override
  String get otpCharges_firstLoginFree =>
      'Votre première connexion était gratuite.';

  @override
  String get otpCharges_freeBody =>
      'Les OTP de connexion envoyés à ce numéro sont gratuits.';

  @override
  String get otpCharges_freeTitle => 'L’OTP est gratuit pour votre numéro';

  @override
  String otpCharges_gstTitle(String percent) {
    return 'TVA ($percent %)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return 'TVA de $percent % incluse';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return 'Taxe de $percent % incluse';
  }

  @override
  String get otpCharges_noInternet =>
      'Pas de connexion Internet. Vérifiez votre réseau et réessayez.';

  @override
  String get otpCharges_otpCharge => 'Frais d’OTP';

  @override
  String otpCharges_pay(String amount) {
    return 'Payer $amount';
  }

  @override
  String get otpCharges_paymentCancelled =>
      'Paiement annulé. Vous avez annulé le paiement. Aucun montant n’a été débité.';

  @override
  String get otpCharges_paymentFailed =>
      'Échec du paiement. Si vous avez été débité, le montant sera remboursé sous 5 à 7 jours ouvrés.';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return 'Paiement suspendu ($amount)';
  }

  @override
  String get otpCharges_paymentReceived =>
      'Paiement reçu. Votre OTP peut mettre quelques instants à arriver.';

  @override
  String get otpCharges_paymentStartFailed =>
      'Impossible de lancer le paiement. Veuillez réessayer.';

  @override
  String get otpCharges_paymentsPaused =>
      'Les paiements OTP sont temporairement suspendus. Appuyez ci-dessous pour les détails.';

  @override
  String get otpCharges_paymentsUnavailable =>
      'Les paiements OTP sont momentanément indisponibles. Réessayez plus tard.';

  @override
  String get otpCharges_sessionExpired =>
      'Session expirée. Veuillez recommencer.';

  @override
  String get otpCharges_title => 'Frais OTP';

  @override
  String get otpCharges_totalPerOtp => 'Total par OTP';

  @override
  String get otpCharges_tryAgainMoment =>
      'Une erreur est survenue. Veuillez réessayer dans un instant.';

  @override
  String get otpCharges_unknownBody =>
      'Les OTP vers les numéros indiens sont gratuits. Pour les autres pays, le prix exact s’affiche avant paiement.';

  @override
  String get otpCharges_unknownTitle =>
      'Les frais d’OTP dépendent de votre pays';

  @override
  String get otpCharges_updateApp =>
      'Impossible de lancer le paiement. Veuillez mettre à jour l’application et réessayer.';

  @override
  String otpCharges_vatTitle(String percent) {
    return 'TVA / Taxe ($percent %)';
  }

  @override
  String get otpCharges_verificationFailed =>
      'Échec de la vérification du paiement. Si vous avez été débité, le montant sera remboursé sous 5 à 7 jours ouvrés.';

  @override
  String get otpCharges_yourNumber => 'Votre numéro';

  @override
  String get package_noPackages => 'Aucun forfait disponible pour le moment.';

  @override
  String package_plansComingSoon(String title) {
    return 'Les forfaits $title arrivent bientôt';
  }

  @override
  String get package_subtitle => 'Choisissez un module pour voir ses forfaits';

  @override
  String get package_title => 'Forfaits et tarifs';

  @override
  String get package_viewPlans => 'Voir les forfaits';

  @override
  String get perm_alwaysLocationBody =>
      'Pour suivre votre groupe en temps réel et en arrière-plan, veuillez définir l\'accès à la position sur \'Toujours autoriser\' dans les Paramètres.';

  @override
  String get perm_alwaysLocationTitle =>
      'Activer l\'autorisation de localisation \'Toujours\'';

  @override
  String get perm_chooseAllowAllTime =>
      'Veuillez choisir \'Toujours autoriser\' dans la fenêtre qui va s\'afficher.';

  @override
  String get perm_collectsLocationBody =>
      'Cette application collecte des données de localisation pour garantir le bon déroulement du travail et un suivi efficace, même lorsque l\'application est fermée ou inutilisée.';

  @override
  String get perm_enableDeviceGpsBody =>
      'Veuillez activer le GPS de votre appareil (Localisation Google).';

  @override
  String get perm_enableGpsTitle => 'Activer le GPS';

  @override
  String get perm_exitBody => 'Voulez-vous quitter l’application ?';

  @override
  String get perm_exitTitle => 'Êtes-vous sûr ?';

  @override
  String get perm_gpsRequiredBody =>
      'Le GPS est requis pour suivre votre groupe en temps réel.';

  @override
  String get perm_locationTitle => 'Autorisation de localisation';

  @override
  String get perm_trackingPermissionBody =>
      'L\'application FG Partner a besoin de votre autorisation pour suivre votre position tant que vous êtes connecté.';

  @override
  String get permission_allowAllTheTime => 'Autoriser tout le temps';

  @override
  String get permission_allowLocation => 'Autoriser la localisation';

  @override
  String get permission_allowLocationFirst =>
      'Veuillez d’abord autoriser la localisation.';

  @override
  String permission_allowNamed(String permission) {
    return 'Autoriser $permission';
  }

  @override
  String get permission_allowNotifications => 'Autoriser les notifications';

  @override
  String get permission_appPermissionsSubtitle =>
      'Vérifiez les autorisations requises.';

  @override
  String get permission_appPermissionsTitle => 'Autorisations de l’application';

  @override
  String get permission_badgeGranted => 'Accordé';

  @override
  String get permission_badgeOptional => 'Optionnel';

  @override
  String get permission_badgeRecommended => 'Recommandé';

  @override
  String get permission_badgeRequired => 'Requis';

  @override
  String get permission_camera => 'Appareil photo';

  @override
  String get permission_cameraDescription =>
      'Utilisé par les fonctionnalités qui capturent des photos ou vidéos.';

  @override
  String get permission_cameraSettingsMessage =>
      'L’autorisation de l’appareil photo est requise pour prendre des photos et vidéos. Activez-la dans les réglages.';

  @override
  String get permission_cameraWhy =>
      'Vous permet de capturer des photos et vidéos pour le profil, le chat, etc.';

  @override
  String get permission_contacts => 'Contacts';

  @override
  String get permission_contactsDescription =>
      'Utilisé pour découvrir ou sélectionner des contacts dans l’app.';

  @override
  String get permission_contactsSettingsMessage =>
      'L’autorisation des contacts est nécessaire pour rechercher des contacts. Activez-la dans les réglages.';

  @override
  String get permission_contactsWhy =>
      'Vous aide à trouver et sélectionner des contacts facilement.';

  @override
  String get permission_gateCheckFailed =>
      'Impossible de vérifier vos autorisations. Veuillez réessayer.';

  @override
  String get permission_gateSubtitle =>
      'FG Tracker a besoin de ces autorisations pour recevoir des appels et alertes et exécuter la présence, le suivi en direct et la zone sécurisée.';

  @override
  String get permission_gateTitle => 'Autorisations requises';

  @override
  String get permission_genericSettingsMessage =>
      'Cette autorisation est nécessaire. Veuillez l’activer dans les paramètres.';

  @override
  String get permission_iosLocationServicesOff =>
      'Le service de localisation est désactivé. Allez dans Réglages → Confidentialité et sécurité → Service de localisation et activez-le.';

  @override
  String get permission_location => 'Position';

  @override
  String get permission_locationAndNotificationRequired =>
      'Les autorisations de localisation et de notification sont requises pour continuer.';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      'La localisation et les notifications sont requises pour continuer.';

  @override
  String get permission_locationDescription =>
      'Nécessaire pour la présence, le suivi et la zone sécurisée, y compris en arrière-plan.';

  @override
  String get permission_locationRequiredToContinue =>
      'L’autorisation de localisation est requise pour continuer.';

  @override
  String get permission_locationStatusApproximate =>
      'Seule la position approximative est autorisée. Précise requise.';

  @override
  String get permission_locationStatusBlocked =>
      'Localisation bloquée. Activez-la dans les paramètres.';

  @override
  String get permission_locationStatusDone =>
      'Autorisé tout le temps · Précis · GPS activé';

  @override
  String get permission_locationStatusGpsOff =>
      'La localisation de l’appareil (GPS) est désactivée.';

  @override
  String get permission_locationStatusNeedAlways =>
      '« Toujours autoriser » est requis.';

  @override
  String get permission_locationStatusNotAllowed =>
      'Autorisation de localisation pas encore accordée.';

  @override
  String get permission_locationWhyExtra =>
      'Veuillez choisir « Toujours autoriser » et laisser la position précise activée.';

  @override
  String get permission_logout => 'Déconnexion';

  @override
  String get permission_microphone => 'Microphone / Audio';

  @override
  String get permission_microphoneDescription =>
      'Utilisé par les fonctions vocales, talkie-walkie et appels.';

  @override
  String get permission_microphoneSettingsMessage =>
      'L’autorisation du micro est requise pour la voix, le talkie-walkie et les appels. Activez-la dans les réglages.';

  @override
  String get permission_microphoneWhy =>
      'Permet la communication vocale, le talkie-walkie et les appels.';

  @override
  String permission_notGrantedNamed(String permission) {
    return 'L’autorisation $permission n’a pas été accordée. Veuillez réessayer.';
  }

  @override
  String get permission_notificationRequiredToContinue =>
      'L’autorisation de notification est requise pour continuer.';

  @override
  String get permission_notificationSettingsText =>
      'Les notifications sont désactivées pour FG Tracker. Allez dans Réglages → Notifications et autorisez-les.';

  @override
  String get permission_notificationStatusBlocked =>
      'Notifications bloquées. Activez-les dans les paramètres.';

  @override
  String get permission_notificationStatusDone => 'Autorisé';

  @override
  String get permission_notificationStatusNotAllowed =>
      'Autorisation de notification pas encore accordée.';

  @override
  String get permission_notifications => 'Notifications';

  @override
  String get permission_notificationsDescription =>
      'Requis pour recevoir les appels entrants, les chats et les alertes.';

  @override
  String get permission_notificationsWhyExtra =>
      'Les appels entrants ne peuvent pas sonner sans cette autorisation.';

  @override
  String get permission_openSettings => 'Ouvrir les paramètres';

  @override
  String get permission_preciseLocation => 'Position précise';

  @override
  String get permission_pushNotifications => 'Notifications push';

  @override
  String get permission_reasonLocation =>
      'La localisation est nécessaire pour la présence, le suivi en direct et les alertes de zone de sécurité.';

  @override
  String get permission_reasonLocationAlways =>
      'Choisissez « Toujours autoriser » pour que le suivi et la zone sécurisée fonctionnent en arrière-plan.';

  @override
  String get permission_reasonNotification =>
      'Les notifications sont requises pour recevoir les appels, les messages et les alertes.';

  @override
  String get permission_reasonPrecise =>
      'Une position précise est requise pour une présence exacte, le suivi en direct et les alertes.';

  @override
  String get permission_required => 'Autorisation requise';

  @override
  String get permission_selectAllowAllTheTime =>
      'Veuillez sélectionner « Toujours autoriser » pour continuer.';

  @override
  String get permission_settingsAndroidAlways =>
      'Ouvrez Paramètres → Autorisations → Localisation et choisissez « Toujours autoriser ».';

  @override
  String get permission_settingsAndroidBlocked =>
      'L’accès à la position est bloqué pour FG Tracker. Allez dans Paramètres → Autorisations → Localisation et choisissez « Toujours autoriser ».';

  @override
  String get permission_settingsAndroidPrecise =>
      'Ouvrez Paramètres → Autorisations → Localisation et activez « Position exacte ».';

  @override
  String get permission_settingsIosAlways =>
      'Ouvrez Réglages → Localisation et choisissez « Toujours ».';

  @override
  String get permission_settingsIosBlocked =>
      'L’accès à la position est désactivé pour FG Tracker. Allez dans Réglages → Localisation et choisissez « Toujours ».';

  @override
  String get permission_settingsIosPrecise =>
      'Ouvrez Réglages → Localisation et activez « Position précise ».';

  @override
  String get permission_skipAndContinue => 'Ignorer et continuer';

  @override
  String get permission_turnOnLocation => 'Activer la localisation';

  @override
  String get permission_turnOnPreciseLocation => 'Activer la position précise';

  @override
  String get permission_unableToRequest =>
      'Impossible de demander l’autorisation.';

  @override
  String get permission_whyWeNeedThis => 'Pourquoi en avons-nous besoin ?';

  @override
  String get registration_contactNumberHint => 'Entrez le numéro de contact';

  @override
  String get registration_contactNumberLabel => 'Numéro de contact';

  @override
  String get registration_doneButton => 'Terminé';

  @override
  String get registration_emailHint => 'Entrez l\'adresse e-mail';

  @override
  String get registration_emailLabel => 'Adresse e-mail';

  @override
  String get registration_genderFemale => 'Femme';

  @override
  String get registration_genderLabel => 'Sélectionner le genre';

  @override
  String get registration_genderMale => 'Homme';

  @override
  String get registration_genderOther => 'Autre';

  @override
  String get registration_selectGenderError =>
      'Veuillez sélectionner votre genre';

  @override
  String get registration_userNameHint => 'Entrez le nom d\'utilisateur';

  @override
  String get registration_userNameLabel => 'Nom d\'utilisateur';

  @override
  String get repo_allCallsCleared =>
      'Tout l’historique des appels a été effacé';

  @override
  String get repo_callDeleted => 'Historique des appels supprimé avec succès';

  @override
  String get repo_invalidResponse => 'Format de réponse invalide';

  @override
  String get repo_loadLocationsFailed =>
      'Échec du chargement des positions du groupe';

  @override
  String get repo_pkgConflict =>
      'Ce forfait est déjà actif ou un paiement est en cours.';

  @override
  String get repo_pkgNotFound =>
      'Les forfaits ne sont pas disponibles pour le moment. Veuillez réessayer plus tard.';

  @override
  String get repo_pkgOffline =>
      'Pas de connexion Internet. Vérifiez votre réseau et réessayez.';

  @override
  String get repo_pkgSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get repo_pkgTimeout =>
      'Le serveur met trop de temps à répondre. Veuillez réessayer.';

  @override
  String get repo_selectedCallsDeleted =>
      'Appels sélectionnés supprimés avec succès';

  @override
  String get repo_unnamedGroup => 'Groupe sans nom';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return 'Distance totale : $distance  •  Écart autorisé : $deviation';
  }

  @override
  String get safeRoute_activeTitle => 'Itinéraire sécurisé actif';

  @override
  String get safeRoute_alertSettingsDesc =>
      'Gérez alertes de route, limites d’écart et notifications.';

  @override
  String get safeRoute_alertSheetDesc =>
      'Alertes en direct quand les membres dévient de l’itinéraire';

  @override
  String get safeRoute_alertTitle => 'Alerte d’itinéraire sécurisé';

  @override
  String get safeRoute_appBarSubtitle =>
      'Définissez un itinéraire sûr pour votre membre.';

  @override
  String get safeRoute_destination => 'Destination';

  @override
  String get safeRoute_deviated => 'Écarté de l’itinéraire sûr';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'Une alerte se déclenche si le membre s’écarte de plus de $distance.';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (Écart : $distance)';
  }

  @override
  String get safeRoute_deviationLimit => 'Limite d’écart';

  @override
  String get safeRoute_deviationSubtitle =>
      'Définissez l’écart autorisé par rapport au trajet.';

  @override
  String get safeRoute_distance => 'Distance';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance km • $minutes min';
  }

  @override
  String get safeRoute_edit => 'Modifier l’itinéraire sécurisé';

  @override
  String get safeRoute_end => 'Arrivée';

  @override
  String safeRoute_estTime(int minutes) {
    return 'Temps estimé : $minutes min';
  }

  @override
  String get safeRoute_featureDesc =>
      'Définissez des itinéraires prédéfinis. Recevez des alertes si quelqu’un s’en écarte.';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$group ($_temp0)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'Définissez la distance maximale autorisée hors du trajet. Une alerte vous prévient si elle est dépassée.';

  @override
  String get safeRoute_helpDeviationTitle =>
      'Qu’est-ce que la limite d’écart ?';

  @override
  String get safeRoute_helpHowBody =>
      'Sélectionnez le membre, choisissez départ et arrivée, le meilleur trajet et fixez l’écart.';

  @override
  String get safeRoute_helpHowTitle => 'Comment créer un itinéraire sûr ?';

  @override
  String get safeRoute_helpTitle => 'Aide à l’itinéraire sécurisé';

  @override
  String get safeRoute_helpWhatBody =>
      'Définissez départ et destination pour sécuriser le trajet de votre membre.';

  @override
  String get safeRoute_helpWhatTitle => 'Qu’est-ce qu’un itinéraire sécurisé ?';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$name s’est écarté de l’itinéraire sécurisé';
  }

  @override
  String get safeRoute_recommended => 'Recommandé';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (Recommandé)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'Itinéraire ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'Enregistrer et activer l’itinéraire';

  @override
  String get safeRoute_saveActivateGroup =>
      'Enregistrer et activer pour le groupe';

  @override
  String get safeRoute_selectedRoute => 'Itinéraire sélectionné';

  @override
  String get safeRoute_setRoutesSubtitle =>
      'Créez et gérez des itinéraires sûrs pour tous les membres.';

  @override
  String get safeRoute_start => 'Départ';

  @override
  String get safeRoute_startLocation => 'Lieu de départ';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. Définir la limite d’écart';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. Prévisualiser et appliquer';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. Aperçu de l’itinéraire';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. Sélectionner l’itinéraire';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. Définir les itinéraires pour les membres';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. Définir départ et destination';
  }

  @override
  String get safeRoute_subtitle => 'Protection d’itinéraire';

  @override
  String get safeRoute_title => 'Itinéraire sécurisé';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return 'Rayon : $radius  •  Centre : $center';
  }

  @override
  String get safeZone_activePreview => 'Actif (Aperçu)';

  @override
  String get safeZone_activeTitle => 'Zone sécurisée active';

  @override
  String get safeZone_alertSettingsDesc =>
      'Gérez zone sûre, distance d’alerte et notifications';

  @override
  String get safeZone_alertSheetDesc =>
      'Alertes en direct quand les membres quittent la zone';

  @override
  String get safeZone_alertTitle => 'Alerte de zone sécurisée';

  @override
  String safeZone_allMonitored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'L’ensemble des $count membres sera surveillé\ndans cette zone sécurisée.',
      one: '1 membre sera surveillé\ndans cette zone sécurisée.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_appBarSubtitle =>
      'Définissez une zone sûre. Recevez des alertes si\nquelqu’un en sort.';

  @override
  String safeZone_appliedToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Cette zone sécurisée sera appliquée à l’ensemble des $count membres du groupe sélectionné.',
      one:
          'Cette zone sécurisée sera appliquée au membre du groupe sélectionné.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_edit => 'Modifier la zone sécurisée';

  @override
  String get safeZone_exited => 'Sorti de la zone sécurisée';

  @override
  String get safeZone_featureDesc =>
      'Définissez une zone géographique sûre. Recevez des alertes si quelqu’un sort de la zone.';

  @override
  String get safeZone_helpHowBody =>
      'Sélectionnez un membre, un lieu sur la carte et définissez le rayon.';

  @override
  String get safeZone_helpHowTitle => 'Comment créer une zone sécurisée ?';

  @override
  String get safeZone_helpRadiusBody =>
      'Réglez le rayon (500 m, 1 km, 2 km ou 5 km) selon vos besoins.';

  @override
  String get safeZone_helpRadiusTitle => 'Qu’est-ce que le rayon de sécurité ?';

  @override
  String get safeZone_helpTitle => 'Aide à la zone sécurisée';

  @override
  String get safeZone_helpWhatBody =>
      'Définissez une zone sur la carte et soyez alerté si le membre en sort.';

  @override
  String get safeZone_helpWhatTitle => 'Qu’est-ce qu’une zone sécurisée ?';

  @override
  String safeZone_memberLeft(String name) {
    return '$name a quitté la zone sécurisée';
  }

  @override
  String get safeZone_membersMonitored =>
      'Les membres seront surveillés dans cette zone sûre.';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return 'Près de $place (Hors de $zone)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place (Hors de $zone)';
  }

  @override
  String get safeZone_saveActivate => 'Enregistrer et activer la zone';

  @override
  String get safeZone_saveActivateGroup =>
      'Enregistrer et activer la zone pour le groupe';

  @override
  String get safeZone_searchLocation => 'Rechercher un lieu...';

  @override
  String get safeZone_statusLabel => 'Statut :';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. Aperçu de la zone sécurisée';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. Définir le rayon de sécurité';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. Sélectionner le lieu sur la carte';
  }

  @override
  String get safeZone_subtitle => 'Protection de zone';

  @override
  String get safeZone_title => 'Zone sécurisée';

  @override
  String safeZone_totalMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Total $count membres',
      one: '1 membre au total',
    );
    return '$_temp0';
  }

  @override
  String get safety_active => 'Actif';

  @override
  String get safety_alertSettings => 'Paramètres d’alerte';

  @override
  String get safety_alerts => 'Alertes';

  @override
  String get safety_alertsDesc => 'Nécessitent une attention immédiate';

  @override
  String get safety_bannerBody =>
      'Surveillez et protégez votre équipe grâce à des fonctions intelligentes.';

  @override
  String get safety_bannerTitle => 'Votre sécurité, notre priorité';

  @override
  String get safety_chooseFeature => 'Choisir une fonction de sécurité';

  @override
  String get safety_comingSoonBody =>
      'Des fonctionnalités de sécurité intelligentes pour votre équipe arrivent bientôt.';

  @override
  String get safety_contactSupport => 'Contacter l’assistance';

  @override
  String get safety_editAnytime =>
      'Vous pouvez modifier ou désactiver à tout moment.';

  @override
  String get safety_mapCityPark => 'Parc de la ville';

  @override
  String get safety_mapMainRoad => 'Route principale';

  @override
  String get safety_mapMarketLane => 'Allée du Marché';

  @override
  String get safety_mapRiver => 'Rivière';

  @override
  String get safety_mapStationRoad => 'Rue de la Gare';

  @override
  String get safety_needHelpBody =>
      'Contactez l’équipe d’assistance pour toute aide liée à la sécurité.';

  @override
  String get safety_quickOverview => 'Aperçu rapide';

  @override
  String get safety_recentAlerts => 'Alertes récentes';

  @override
  String get safety_recenter => 'Recentrer';

  @override
  String get safety_safeNow => 'En sécurité maintenant';

  @override
  String get safety_safeNowDesc =>
      'Les membres sont dans la zone/itinéraire sécurisé';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. Sélectionner un groupe';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. Sélectionner un membre';
  }

  @override
  String get safety_tabIndividual => 'Individuel';

  @override
  String get safety_tagline => 'Restez protégé. Restez connecté.';

  @override
  String get safety_title => 'Sécurité';

  @override
  String get safety_viewAllMembers => 'Voir tous les membres';

  @override
  String get sheet_addGroupMember => 'Ajouter un membre au groupe';

  @override
  String get sheet_admin => 'Admin';

  @override
  String get sheet_attachSubtitle =>
      'Partagez fichiers et médias avec votre équipe';

  @override
  String get sheet_attachUpload => 'Joindre / Téléverser';

  @override
  String get sheet_attendance => 'Présence';

  @override
  String get sheet_callOptions => 'Options d\'appel';

  @override
  String get sheet_cantRemoveSelf =>
      'Vous ne pouvez pas vous retirer vous-même du groupe.';

  @override
  String get sheet_contact => 'Contact';

  @override
  String get sheet_contactsNotOnApp =>
      'Vos contacts n’utilisent pas encore FG Tracker.';

  @override
  String get sheet_document => 'Document';

  @override
  String get sheet_groupMembers => 'Membres du groupe';

  @override
  String get sheet_location => 'Position';

  @override
  String get sheet_memberRemoved => 'Membre retiré avec succès';

  @override
  String get sheet_noMembers => 'Aucun membre trouvé';

  @override
  String get sheet_noRegisteredContacts => 'Aucun contact enregistré';

  @override
  String get sheet_noUserFound => 'Aucun utilisateur trouvé';

  @override
  String get sheet_normalAudioCall => 'Appel audio normal';

  @override
  String get sheet_normalAudioCallSubtitle =>
      'Qualité vocale standard et claire';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts enregistrés',
      one: '1 contact enregistré',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return 'Voulez-vous vraiment retirer $name du groupe ?';
  }

  @override
  String get sheet_removeMemberTitle => 'Retirer le membre';

  @override
  String get sheet_searchContacts => 'Rechercher des contacts';

  @override
  String get sheet_walkieCall => 'Appel talkie-walkie';

  @override
  String get sheet_walkieCallSubtitle => 'Communication Push-to-Talk';

  @override
  String get sos_addDetailsMandatory => 'Ajouter des détails (obligatoire)';

  @override
  String get sos_addDetailsOptional => 'Ajouter des détails (facultatif)';

  @override
  String get sos_addFamilyMember => 'Ajouter un membre de la famille';

  @override
  String get sos_addFamilyMemberRequired =>
      'Ajoutez au moins 1 membre de la famille pour envoyer l’alerte SOS';

  @override
  String get sos_addPhotoHint =>
      'Joignez une photo pour mieux décrire la situation.';

  @override
  String get sos_addPhotoOptional => 'Ajouter une photo (facultatif)';

  @override
  String get sos_alertSent => 'Alerte SOS envoyée !';

  @override
  String get sos_alertSentToNearby =>
      'Votre alerte a été envoyée aux personnes à proximité.';

  @override
  String get sos_alertWillBeSent =>
      'L’alerte sera envoyée aux personnes à proximité';

  @override
  String get sos_alertWillBeSentFamily =>
      'Votre alerte sera envoyée aux personnes à proximité et à votre famille.';

  @override
  String sos_availableUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilisateurs disponibles',
      one: '1 utilisateur disponible',
    );
    return '$_temp0';
  }

  @override
  String get sos_detailsHint => 'Écrivez des précisions supplémentaires...';

  @override
  String get sos_detailsMandatoryForOther =>
      'Les détails sont obligatoires lorsque la raison « Autre » est sélectionnée';

  @override
  String get sos_howItWorks => 'Comment ça marche';

  @override
  String get sos_howItWorksIntro =>
      'L’alerte SOS prévient les personnes à proximité et votre famille en cas d’urgence.';

  @override
  String get sos_howItWorksTitle => 'Comment fonctionne l’alerte SOS ?';

  @override
  String get sos_liveTrackingStarted => 'Suivi en direct démarré';

  @override
  String sos_locationSharedWithFamily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votre position est partagée avec $count membres de la famille',
      one: 'Votre position est partagée avec 1 membre de la famille',
    );
    return '$_temp0';
  }

  @override
  String sos_membersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres sélectionnés',
      one: '1 membre sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get sos_needHelp => 'Besoin d’aide ?';

  @override
  String get sos_needHelpBody =>
      'Envoyez une alerte SOS aux personnes à proximité.\nElles seront notifiées et pourront vous aider.';

  @override
  String get sos_noMatchFound => 'Aucune correspondance trouvée';

  @override
  String get sos_noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get sos_notifyFamilyTitle => 'Prévenez votre famille (1 à 5 requis)';

  @override
  String get sos_notifyUpdates =>
      'Nous vous tiendrons informé de toute mise à jour';

  @override
  String get sos_okGotIt => 'Compris';

  @override
  String get sos_peopleWithinRadius => 'Personnes dans un rayon de 2 km';

  @override
  String get sos_privacyNote =>
      'Votre vie privée est importante. Votre position n’est partagée que pendant une alerte SOS active.';

  @override
  String get sos_reasonAccident => 'Accident';

  @override
  String get sos_reasonMedical => 'Médical';

  @override
  String get sos_reasonOther => 'Autre';

  @override
  String get sos_reasonSafety => 'Sécurité';

  @override
  String get sos_reasonThreat => 'Menace';

  @override
  String get sos_required => 'Requis';

  @override
  String get sos_searchUsers => 'Rechercher des utilisateurs';

  @override
  String get sos_selectReason => 'Sélectionnez une raison';

  @override
  String get sos_sendSosAlert => 'Envoyer l’alerte SOS';

  @override
  String get sos_stayCalm => 'Restez calme, les secours arrivent';

  @override
  String get sos_step1Body =>
      'Appuyez sur le bouton SOS pour envoyer l’alerte aux personnes à proximité.';

  @override
  String get sos_step1Title => '1. Envoyer l’alerte SOS';

  @override
  String get sos_step2Body =>
      'Les personnes proches recevront votre alerte avec votre position.';

  @override
  String get sos_step2Title => '2. Notifier les personnes à proximité';

  @override
  String get sos_step3Body =>
      'Les personnes à proximité peuvent voir votre alerte et venir vous aider.';

  @override
  String get sos_step3Title => '3. Obtenir de l’aide plus vite';

  @override
  String get sos_step4Body =>
      'Les membres de votre famille seront immédiatement informés de votre SOS.';

  @override
  String get sos_step4Title => '4. La famille est notifiée';

  @override
  String get sos_subtitle => 'Envoyer une alerte aux personnes à proximité';

  @override
  String get sos_title => 'Alerte SOS';

  @override
  String get sos_willBeNotified => 'seront notifiés';

  @override
  String status_activeCount(int count) {
    return '$count actif(s)';
  }

  @override
  String get status_addToMyStatus => 'Ajouter à mon statut';

  @override
  String get status_allContacts => 'Tous les contacts';

  @override
  String get status_cameraAccessFailed => 'Impossible d’accéder à la caméra';

  @override
  String get status_captionHint => 'Ajouter une légende...';

  @override
  String get status_changeMedia => 'Changer de média';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get status_deleted => 'Statut supprimé';

  @override
  String get status_deletedByOwner =>
      'Ce statut a été supprimé par son propriétaire';

  @override
  String get status_exceptContacts => 'Sauf les contacts';

  @override
  String get status_exceptSelected => 'Sauf la sélection';

  @override
  String get status_flip => 'Retourner';

  @override
  String get status_gallery => 'Galerie';

  @override
  String get status_modePhoto => 'Photo';

  @override
  String get status_modeText => 'Texte';

  @override
  String get status_modeVideo => 'Vidéo';

  @override
  String get status_myStatus => 'Mon statut';

  @override
  String get status_new => 'Nouveau';

  @override
  String get status_noCamera => 'Aucune caméra disponible';

  @override
  String get status_noLongerAvailable => 'Ce statut n\'est plus disponible';

  @override
  String get status_noViewsYet => 'Aucune vue pour le moment';

  @override
  String get status_onlyShareWith => 'Partager seulement avec';

  @override
  String get status_pause => 'Pause';

  @override
  String get status_pinchZoomHint => 'Pincez pour zoomer sur la photo';

  @override
  String get status_play => 'Lecture';

  @override
  String get status_postStatus => 'Publier le statut';

  @override
  String get status_previewStatus => 'Aperçu du statut';

  @override
  String get status_privacy => 'Confidentialité';

  @override
  String get status_privacyTitle => 'Confidentialité du statut';

  @override
  String get status_publishFailed => 'Impossible de publier le statut';

  @override
  String get status_replyHint => 'Répondre au statut...';

  @override
  String get status_retake => 'Reprendre';

  @override
  String get status_selectPhotoFirst =>
      'Veuillez d’abord prendre ou choisir une photo';

  @override
  String get status_selectVideoFirst =>
      'Veuillez d’abord prendre ou choisir une vidéo';

  @override
  String get status_shareUpdatesHint => 'Partagez des actus avec votre équipe';

  @override
  String get status_tapVideoHint => 'Appuyez pour lire / mettre en pause';

  @override
  String get status_textRequired => 'Contenu textuel requis';

  @override
  String get status_title => 'Statut';

  @override
  String get status_typeHint => 'Écrivez un statut...';

  @override
  String get status_uploadFailed => 'Échec du téléversement';

  @override
  String get status_viewMyStatus => 'Voir mon statut';

  @override
  String get status_viewed => 'Vu';

  @override
  String status_viewedBy(int count) {
    return 'Vu par $count';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vues',
      one: '1 vue',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => 'Qui peut voir ?';

  @override
  String get track_admin => 'Admin';

  @override
  String get track_applyRadius => 'Appliquer le rayon';

  @override
  String get track_checkNetworkConnection =>
      'Veuillez vérifier votre connexion réseau et réessayer.';

  @override
  String get track_checkNetworkMembers =>
      'Vérifiez votre réseau et réessayez pour voir les membres à proximité.';

  @override
  String get track_currentLocation => 'Position actuelle';

  @override
  String get track_custom => 'Personnalisé';

  @override
  String track_customWithValue(String radius) {
    return 'Personnalisé ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return 'à $distance';
  }

  @override
  String get track_enable => 'Activer';

  @override
  String get track_enableGpsBody =>
      'Pour suivre votre groupe en temps réel, veuillez activer votre GPS.';

  @override
  String get track_enableGpsTitle => 'Activer le GPS';

  @override
  String get track_errorFailedLoadGroups => 'Échec du chargement des groupes';

  @override
  String get track_errorLoadGroups =>
      'Impossible de charger les groupes. Veuillez réessayer.';

  @override
  String get track_errorLoadMembers =>
      'Impossible de charger les membres proches. Veuillez réessayer.';

  @override
  String get track_errorNoInternet =>
      'Pas de connexion Internet. Veuillez vérifier votre réseau.';

  @override
  String get track_errorServer =>
      'Impossible de se connecter au serveur. Veuillez réessayer.';

  @override
  String track_groupCode(String code) {
    return 'Code : $code';
  }

  @override
  String get track_groupMembers => 'Membres du groupe';

  @override
  String track_groupMembersAndCode(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres • Code : $code',
      one: '1 membre • Code : $code',
    );
    return '$_temp0';
  }

  @override
  String get track_groupTab => 'Groupe';

  @override
  String track_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
    );
    return '$_temp0';
  }

  @override
  String track_groupsHeader(int count) {
    return 'GROUPES ($count)';
  }

  @override
  String get track_helpGroupBody =>
      'Créez un groupe pour suivre plusieurs membres.';

  @override
  String get track_helpGroupTitle => 'Comment ajouter un groupe ?';

  @override
  String get track_helpLiveBody =>
      'Suivez la position en temps réel de votre équipe sur la carte.';

  @override
  String get track_helpLiveTitle => 'Qu’est-ce que le suivi en direct ?';

  @override
  String get track_helpRadiusBody =>
      'Définissez la zone pour trouver des membres proches sur la carte.';

  @override
  String get track_helpRadiusTitle => 'Qu’est-ce que le rayon de suivi ?';

  @override
  String get track_helpTitle => 'Aide au suivi';

  @override
  String track_lastSeen(String time) {
    return 'Vu pour la dernière fois : $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count en direct';
  }

  @override
  String get track_liveMembers => 'Membres en direct';

  @override
  String get track_liveTracking => 'Suivi en direct';

  @override
  String get track_locating => 'Localisation en cours...';

  @override
  String get track_locationHidden => 'Position masquée';

  @override
  String get track_locationUnavailable => 'Position non disponible';

  @override
  String get track_mapOfflineBody =>
      'Une connexion Internet est requise pour charger la carte et les positions en direct.';

  @override
  String get track_mapUnavailableOffline => 'Carte non disponible hors ligne';

  @override
  String get track_member => 'Membre';

  @override
  String track_memberPausedSharing(String name) {
    return '$name a suspendu le partage de position. La position en direct est indisponible.';
  }

  @override
  String track_membersHeader(int count) {
    return 'MEMBRES ($count)';
  }

  @override
  String track_membersLive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres en direct',
      one: '1 membre en direct',
    );
    return '$_temp0';
  }

  @override
  String get track_menuMembers => 'Membres';

  @override
  String get track_menuRefreshMap => 'Actualiser la carte';

  @override
  String get track_menuTheme => 'Thème';

  @override
  String get track_nearbyYou => 'Près de vous';

  @override
  String get track_noActiveMembers => 'Aucun membre actif';

  @override
  String track_noActiveMembersWithin(String radius) {
    return 'Aucun membre actif trouvé dans un rayon de $radius';
  }

  @override
  String get track_noDescription => 'Aucune description';

  @override
  String get track_noGroupsFound => 'Aucun groupe trouvé';

  @override
  String get track_noGroupsMatch => 'Aucun groupe correspondant';

  @override
  String track_noGroupsMatchQuery(String query) {
    return 'Aucun groupe ne correspond à \'$query\'';
  }

  @override
  String get track_noGroupsYet =>
      'Vous n’avez encore rejoint ni créé aucun groupe.';

  @override
  String get track_noInternetTitle => 'Pas de connexion Internet';

  @override
  String get track_noMembersFound => 'Aucun membre trouvé';

  @override
  String get track_noMembersFoundPlain => 'Aucun membre trouvé';

  @override
  String get track_noMembersInGroup => 'Aucun membre trouvé dans ce groupe';

  @override
  String track_noMembersMatch(String query) {
    return 'Aucun membre ne correspond à \'$query\'';
  }

  @override
  String track_noSearchMatches(String query) {
    return 'Aucun membre ou groupe correspondant';
  }

  @override
  String track_noSearchResults(String query) {
    return 'Aucun membre ou groupe trouvé pour \'$query\'';
  }

  @override
  String get track_notAvailable => 'N/D';

  @override
  String get track_offlineBanner =>
      'Pas de connexion Internet. Carte et suivi hors ligne.';

  @override
  String get track_private => 'Privé';

  @override
  String get track_radius => 'Rayon';

  @override
  String get track_refresh => 'Actualiser';

  @override
  String get track_refreshing => 'Actualisation...';

  @override
  String get track_retryConnection => 'Réessayer la connexion';

  @override
  String get track_searchHint => 'Rechercher des membres ou groupes...';

  @override
  String get track_searchMembersHint => 'Rechercher des membres...';

  @override
  String get track_selectedLocation => 'Emplacement sélectionné';

  @override
  String get track_setRadiusSubtitle => 'Glissez pour sélectionner le rayon';

  @override
  String get track_setRadiusTitle => 'Définir le rayon de suivi';

  @override
  String get track_unableToLoadGroups => 'Impossible de charger les groupes';

  @override
  String get track_unableToLoadMembers => 'Impossible de charger les membres';

  @override
  String get track_unnamedGroup => 'Groupe sans nom';

  @override
  String get track_unnamedMember => 'Membre sans nom';

  @override
  String get track_yourGroups => 'Vos groupes';

  @override
  String get track_yourLocationPaused =>
      'Votre partage de position est en pause et privé.';

  @override
  String get util_previewContact => '👤 Contact';

  @override
  String get util_previewDocument => '📄 Document';

  @override
  String get util_previewLocation => '📍 Position';

  @override
  String get util_previewPhoto => '📷 Photo';

  @override
  String get util_previewVideo => '🎥 Vidéo';

  @override
  String get util_previewVoice => '🎤 Message vocal';

  @override
  String util_spokenEur(String amount) {
    return '$amount euros';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amount livres sterling';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupees roupies',
      one: '1 roupie',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees roupies et $paise paise';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount dollars américains';
  }

  @override
  String get util_unableToCallContact => 'Impossible d’appeler ce contact';

  @override
  String get util_unableToStartGroupCall =>
      'Impossible de démarrer l’appel de groupe';

  @override
  String get validation_emailEmpty => 'L\'adresse e-mail ne peut pas être vide';

  @override
  String get validation_emailInvalid =>
      'Veuillez saisir une adresse e-mail valide.';

  @override
  String validation_required(String field) {
    return '$field est requis';
  }

  @override
  String get voice_appLanguage => 'Langue de l’app';

  @override
  String get voice_audioChip => 'AUDIO';

  @override
  String get voice_captionReady => 'Légende prête';

  @override
  String get voice_chooseSpeechLanguage => 'Choisir la langue vocale';

  @override
  String get voice_couldntPlay => 'Impossible de lire le message vocal';

  @override
  String get voice_didntCatch =>
      'Nous n’avons pas bien saisi. Appuyez sur le micro et parlez plus fort.';

  @override
  String get voice_language => 'Langue';

  @override
  String get voice_listenBack => 'Réécouter';

  @override
  String get voice_listenBeforeSending =>
      'Écoutez avant d’envoyer votre message vocal.';

  @override
  String get voice_listening => 'Écoute en cours…';

  @override
  String get voice_micPermissionNeeded =>
      'L’autorisation du microphone est requise pour utiliser la voix.';

  @override
  String get voice_micUnavailable =>
      'Microphone indisponible. Veuillez vérifier les paramètres.';

  @override
  String get voice_noTextCaptured =>
      'Aucun texte capturé — essayez de réenregistrer.';

  @override
  String get voice_openSettings => 'Ouvrir les paramètres';

  @override
  String get voice_permissionRequired => 'Autorisation requise';

  @override
  String get voice_reRecord => 'Réenregistrer';

  @override
  String get voice_readyToSend => 'Prêt à envoyer';

  @override
  String get voice_recordVoice => 'Enregistrer la voix';

  @override
  String get voice_recordVoiceSubtitle =>
      'Enregistrez et envoyez en message audio';

  @override
  String get voice_recordingYourVoice => 'Enregistrement de votre voix…';

  @override
  String get voice_replyReady => 'Réponse prête';

  @override
  String get voice_reviewTextHint =>
      'Écoutez votre voix ci-dessus ou modifiez le texte avant d’envoyer.';

  @override
  String get voice_sendMessage => 'Envoyer le message';

  @override
  String get voice_sendVoiceMessage => 'Envoyer le message vocal';

  @override
  String get voice_speakNowCaption =>
      'Parlez maintenant – nous écrivons votre légende';

  @override
  String get voice_speakNowMessage =>
      'Parlez maintenant – vos mots apparaîtront dans le message';

  @override
  String get voice_speakNowReply =>
      'Parlez maintenant – nous écrivons votre réponse';

  @override
  String get voice_speakPlaceholder => 'Parlez… votre texte apparaîtra ici';

  @override
  String get voice_speechPermissionNeeded =>
      'L’autorisation de reconnaissance vocale est requise pour transcrire la voix.';

  @override
  String get voice_tapToStop => 'Appuyez pour arrêter';

  @override
  String get voice_textReady => 'Texte prêt';

  @override
  String get voice_tooMuchNoise =>
      'Trop de bruit – rapprochez le téléphone et parlez clairement';

  @override
  String get voice_type => 'Type';

  @override
  String get voice_voiceToText => 'Voix en texte';

  @override
  String get voice_voiceToTextSubtitle =>
      'Parlez pour écrire dans la zone de message';

  @override
  String get voice_willSendAudioMessage =>
      'Votre voix sera envoyée sous forme de message audio';

  @override
  String get voice_willSendAudioReply =>
      'Votre voix sera envoyée en réponse audio';

  @override
  String get voice_willSendWithFile =>
      'Votre voix sera envoyée avec le fichier sous forme audio';

  @override
  String get voice_yourMessage => 'Votre message';

  @override
  String get voice_yourVoiceMessage => 'Votre message vocal';

  @override
  String get walkiePlan_availableIndividualPlans => 'Forfaits individuels';

  @override
  String get walkiePlan_availablePerMonth => '/ mois';

  @override
  String get walkiePlan_availablePerSeat => '/ place';

  @override
  String get walkiePlan_availableSingleMember =>
      'Membre individuel (Accès personnel)';

  @override
  String get walkiePlan_availableSubtitle =>
      'Choisissez un forfait pour démarrer ou changer d’offre';

  @override
  String get walkiePlan_availableTeamPlans => 'Forfaits d’équipe';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min-$max places  •  Collaboration de groupe';
  }

  @override
  String get walkiePlan_availableTitle => 'Forfaits disponibles';

  @override
  String get walkiePlan_bottomBarAfterTrial => 'Après votre essai gratuit';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'Choisir un forfait';

  @override
  String get walkiePlan_bottomBarContinue => 'Continuer avec le talkie-walkie';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return 'Acheter pour $price';
  }

  @override
  String get walkiePlan_cardActive => 'Actif';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return 'Actif depuis le $date';
  }

  @override
  String get walkiePlan_cardAssigned => 'Assigné';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return 'Assigné par $name';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'Assigné à vous';

  @override
  String get walkiePlan_cardAvailable => 'Disponible';

  @override
  String get walkiePlan_cardManageMembers => 'Gérer les membres';

  @override
  String get walkiePlan_cardNoActiveIndividual =>
      'Aucun abonnement individuel actif';

  @override
  String get walkiePlan_cardNoActiveTeam =>
      'Aucun forfait d’équipe actif ni place attribuée';

  @override
  String get walkiePlan_cardOneSeatSelf => '1 place (Soi-même)';

  @override
  String get walkiePlan_cardPersonal => 'Personnel';

  @override
  String get walkiePlan_cardPurchased => 'Acheté';

  @override
  String get walkiePlan_cardPurchasedByYou => 'Acheté par vous';

  @override
  String get walkiePlan_cardPurchasedOn => 'Acheté le';

  @override
  String get walkiePlan_cardSeatsMembers => 'Places / Membres';

  @override
  String get walkiePlan_cardSubscribedByYou => 'Abonné par vous';

  @override
  String get walkiePlan_cardTeamAdministrator => 'Administrateur d’équipe';

  @override
  String get walkiePlan_cardValidUntil => 'Valide jusqu’au';

  @override
  String get walkiePlan_cardView => 'Voir';

  @override
  String get walkiePlan_cardViewPlan => 'Voir le forfait';

  @override
  String walkiePlan_couponDiscount(String value) {
    return 'Remise de $value';
  }

  @override
  String get walkiePlan_couponExpired => 'Le coupon a expiré';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return 'Remise fixe de $amount';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet => 'Montant minimum non atteint';

  @override
  String get walkiePlan_couponNotEligible => 'Non éligible pour ce forfait';

  @override
  String get walkiePlan_couponNotStarted =>
      'L’offre de coupon n’est pas encore active';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent % de remise';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable =>
      'Non applicable à ce forfait';

  @override
  String walkiePlan_couponValidTill(String date) {
    return 'Valable jusqu’au $date';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'Continuer vers le paiement';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return 'Continuer avec $plan';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => 'Coupon appliqué avec succès !';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return 'Coupon appliqué ! Vous économisez $amount';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => 'Échec de l’application du coupon';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'Coupon retiré';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'Erreur Cashfree ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed =>
      'Échec de l’initiation du paiement.';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return 'Échec de session de paiement : $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return 'Impossible de traiter le paiement : $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'Chargement des forfaits...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans =>
      'Impossible de charger les forfaits. Veuillez réessayer.';

  @override
  String get walkiePlan_detailsAllBanks =>
      'Toutes les banques indiennes supportées';

  @override
  String get walkiePlan_detailsApplied => 'Appliqué';

  @override
  String get walkiePlan_detailsApply => 'Appliquer';

  @override
  String get walkiePlan_detailsApplyCaps => 'APPLIQUER';

  @override
  String get walkiePlan_detailsAvailableCoupons => 'Coupons disponibles';

  @override
  String get walkiePlan_detailsCard => 'Carte de crédit / débit';

  @override
  String get walkiePlan_detailsChooseTitle => 'Choisir un forfait';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'Code : $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'Coupons et offres';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'Entrez le code coupon';

  @override
  String get walkiePlan_detailsEnterValidCoupon =>
      'Veuillez entrer un code valide';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'Communication de groupe';

  @override
  String get walkiePlan_detailsFeatHqVoice => 'Qualité vocale supérieure';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => 'Assistance prioritaire';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => 'Portée illimitée';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => 'Talkie-walkie illimité';

  @override
  String get walkiePlan_detailsHavePromoCode => 'Vous avez un code promo ?';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'Continuez à utiliser le talkie-walkie avec un forfait adapté';

  @override
  String get walkiePlan_detailsLockedCaps => 'VERROUILLÉ';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Limite de $count membres atteinte',
      one: 'Limite de 1 membre atteinte',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMemberPlural => 'Membres';

  @override
  String get walkiePlan_detailsMemberSingular => 'Membre';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres × $rate',
      one: '1 membre × $rate',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Taille minimum de $count membres',
      one: 'Taille minimum de 1 membre',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody =>
      'Ajoutez ou retirez des membres à tout moment.';

  @override
  String get walkiePlan_detailsMoreMembersTitle => 'Plus de membres ?';

  @override
  String get walkiePlan_detailsMostPopular => 'Le plus populaire';

  @override
  String get walkiePlan_detailsNetBanking => 'Banque en ligne';

  @override
  String get walkiePlan_detailsNoCouponsBody =>
      'Il n’y a aucun coupon actif pour ce forfait actuellement.';

  @override
  String get walkiePlan_detailsNoCouponsTitle => 'Aucun coupon disponible';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      'Aucun forfait individuel disponible. Veuillez réessayer plus tard.';

  @override
  String get walkiePlan_detailsNoPlansTitle => 'Aucun forfait disponible';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      'Aucun forfait d’équipe disponible. Veuillez réessayer plus tard.';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '$amount au total';
  }

  @override
  String get walkiePlan_detailsPayActivate => 'Payer et activer le forfait';

  @override
  String get walkiePlan_detailsPerPerson => '/ personne';

  @override
  String get walkiePlan_detailsPillAllSizes => 'de toutes tailles';

  @override
  String get walkiePlan_detailsPillCommunication => 'Communication';

  @override
  String get walkiePlan_detailsPillForTeams => 'Pour équipes';

  @override
  String get walkiePlan_detailsPillInstant => 'Instantané';

  @override
  String get walkiePlan_detailsPillPriority => 'Prioritaire';

  @override
  String get walkiePlan_detailsPillReliable => 'Fiable et';

  @override
  String get walkiePlan_detailsPillSecure => 'Sécurisé';

  @override
  String get walkiePlan_detailsPillSupport => 'Assistance';

  @override
  String get walkiePlan_detailsPillUnlimited => 'Illimité';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'Talkie-walkie';

  @override
  String get walkiePlan_detailsPlanActivated => 'Forfait activé avec succès !';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'Votre forfait talkie-walkie est actif. Profitez d’une communication instantanée.';

  @override
  String get walkiePlan_detailsPlanSummary => 'Résumé du forfait';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'Promo ($code) appliquée';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => 'RETIRER';

  @override
  String get walkiePlan_detailsSelectPaymentMethod =>
      'Sélectionnez le moyen de paiement';

  @override
  String get walkiePlan_detailsSkeletonCouponNote =>
      'Valable sur tous les forfaits • Expire bientôt';

  @override
  String get walkiePlan_detailsStep1Subtitle =>
      'Choisissez combien de membres ajouter';

  @override
  String get walkiePlan_detailsStep1Title =>
      'Sélectionnez le nombre de membres';

  @override
  String get walkiePlan_detailsStep2Subtitle =>
      'Choisissez la durée qui vous convient';

  @override
  String get walkiePlan_detailsStep2Title => 'Sélectionnez la durée du forfait';

  @override
  String get walkiePlan_detailsSubtitleDefault =>
      'Accès vocal immédiat au talkie-walkie';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams =>
      'Idéal pour les équipes en expansion';

  @override
  String get walkiePlan_detailsSubtitleLongTerm =>
      'Le meilleur choix à long terme';

  @override
  String get walkiePlan_detailsSubtitleShortTerm =>
      'Parfait pour un usage à court terme';

  @override
  String get walkiePlan_detailsTabIndividual => 'Individuel';

  @override
  String get walkiePlan_detailsTabMultipleMembers => 'Pour plusieurs membres';

  @override
  String get walkiePlan_detailsTabPerPerson => 'Par personne';

  @override
  String get walkiePlan_detailsTeamSubtitle =>
      'Ajoutez des membres et connectez tout le monde avec le talkie-walkie';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / Code QR';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return 'Vous économisez $amount avec ce coupon !';
  }

  @override
  String get walkiePlan_durationFallback => 'Durée';

  @override
  String get walkiePlan_durationMonthly => 'Mensuel';

  @override
  String walkiePlan_durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '1 mois',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_durationQuarterly => 'Trimestriel';

  @override
  String get walkiePlan_durationYearly => 'Annuel';

  @override
  String get walkiePlan_individualPlan => 'Forfait individuel';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return 'Forfait $interval';
  }

  @override
  String get walkiePlan_monthlyPlan => 'Forfait mensuel';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'Pas de connexion Internet. Veuillez vérifier votre réseau.';

  @override
  String get walkiePlan_order100Secure => '100 % Sécurisé';

  @override
  String get walkiePlan_order3ds2Secure => 'Sécurisé 3DS2';

  @override
  String get walkiePlan_orderAgreePrefix => 'En continuant, vous acceptez nos ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => 'Montant après remise';

  @override
  String get walkiePlan_orderCards => 'Cartes bancaires';

  @override
  String get walkiePlan_orderChangeMethod => 'Changer de moyen';

  @override
  String get walkiePlan_orderCouldNotStart =>
      'Impossible de lancer le paiement. Veuillez réessayer.';

  @override
  String get walkiePlan_orderCouponApplied => 'Coupon appliqué avec succès !';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return 'Coupon appliqué ! Vous avez économisé $amount';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'Coupon supprimé avec succès';

  @override
  String get walkiePlan_orderCreateFailed =>
      'Échec de création de la commande. Veuillez réessayer.';

  @override
  String get walkiePlan_orderDiscount => 'Remise';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return 'Remise ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint =>
      'Choisissez parmi GPay, PhonePe, cartes, banques ou portefeuilles à l’étape suivante.';

  @override
  String get walkiePlan_orderEncryptedPayment => 'Paiement chiffré';

  @override
  String get walkiePlan_orderEnterValidCoupon =>
      'Veuillez saisir un code coupon valide';

  @override
  String get walkiePlan_orderForMultipleMembers => 'Pour plusieurs membres';

  @override
  String get walkiePlan_orderForSingleMember => 'Pour un seul membre';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return 'TVA ($percent %)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      'Payez en sécurité par carte internationale (Visa, Mastercard, Amex).';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      'Payez en sécurité par carte internationale ou PayPal.';

  @override
  String get walkiePlan_orderInvalidCoupon => 'Code coupon invalide ou expiré';

  @override
  String walkiePlan_orderMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'Membres';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres × $rate',
      one: '1 membre × $rate',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderNetBanking => 'NetBanking';

  @override
  String get walkiePlan_orderOnlineViaRazorpay =>
      'Paiement en ligne via Razorpay';

  @override
  String get walkiePlan_orderOpeningCheckout =>
      'Ouverture du paiement Razorpay...';

  @override
  String get walkiePlan_orderPaymentDetails => 'Détails du paiement';

  @override
  String get walkiePlan_orderPaymentMethod => 'Moyen de paiement';

  @override
  String get walkiePlan_orderPricePerMember => 'Prix par membre';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return 'Procéder au paiement • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => 'Paiement en cours...';

  @override
  String get walkiePlan_orderRetryPay => 'Réessayer le paiement';

  @override
  String get walkiePlan_orderSecureBadge => 'SÉCURISÉ';

  @override
  String get walkiePlan_orderSubtitle =>
      'Vérifiez les détails et procédez au paiement';

  @override
  String get walkiePlan_orderSubtotal => 'Sous-total';

  @override
  String get walkiePlan_orderTaxExport => 'Taxe (0 % Export)';

  @override
  String get walkiePlan_orderTermsConditions => 'Conditions générales';

  @override
  String get walkiePlan_orderTitle => 'Récapitulatif de commande';

  @override
  String get walkiePlan_orderTotalAmount => 'Montant total';

  @override
  String get walkiePlan_orderTotalPayable => 'Total à payer';

  @override
  String get walkiePlan_orderUnableToLoad =>
      'Impossible de charger le récapitulatif.';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return 'TVA / Taxe ($percent %)';
  }

  @override
  String get walkiePlan_orderWallets => 'Portefeuilles';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return 'Vous avez économisé $amount sur cette commande !';
  }

  @override
  String get walkiePlan_payAnnualPlan => 'Forfait annuel';

  @override
  String get walkiePlan_payBadgeCompleted => 'Terminé';

  @override
  String get walkiePlan_payBadgeInProgress => 'En cours';

  @override
  String get walkiePlan_payBadgePending => 'En attente';

  @override
  String get walkiePlan_payCancelledByUser =>
      'Paiement annulé par l’utilisateur. Aucun montant n’a été débité.';

  @override
  String get walkiePlan_payCouldNotBeProcessed =>
      'Le paiement n’a pas pu être traité';

  @override
  String get walkiePlan_payFailedContactSupport => 'Contacter l’assistance';

  @override
  String walkiePlan_payFailedOn(String time) {
    return 'Paiement échoué le $time';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'Paiement non abouti.\nVeuillez réessayer ou changer de méthode.';

  @override
  String get walkiePlan_payFailedSubtitleShort =>
      'Nous n’avons pas pu finaliser le paiement';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      'Besoin d’aide pour le paiement ? Équipe disponible 24/7.';

  @override
  String get walkiePlan_payFailedTitle => 'Échec du paiement';

  @override
  String get walkiePlan_payIndividualFeatures =>
      'Surveillance en direct • Alertes instantanées';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return 'Paiement initié le $time';
  }

  @override
  String get walkiePlan_payIntervalMonth => 'mois';

  @override
  String get walkiePlan_payIntervalPlan => 'forfait';

  @override
  String get walkiePlan_payIntervalQuarter => 'trimestre';

  @override
  String get walkiePlan_payIntervalYear => 'an';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'Carte de crédit ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'Carte de débit ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational =>
      'Carte internationale / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'NetBanking ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'Paiement Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'Caisse Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / Carte)';

  @override
  String get walkiePlan_payMethodUpi => 'Paiement UPI';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'Portefeuille ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue =>
      'Problème de réseau pendant le paiement. Vérifiez votre connexion.';

  @override
  String get walkiePlan_payNotCompleted =>
      'Votre paiement n’a pas abouti. Aucun montant n’a été débité.';

  @override
  String get walkiePlan_payOtpCharge => 'Frais OTP';

  @override
  String get walkiePlan_payOtpChargeDetails => 'Détails des frais OTP';

  @override
  String get walkiePlan_payOtpChargedPerLogin =>
      'Facturé par connexion. Renvoi gratuit';

  @override
  String get walkiePlan_payOtpCharges => 'Frais OTP';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'Veuillez ne pas fermer l’application. Nous vous notifierons dès confirmation.';

  @override
  String get walkiePlan_payPendingStillInProgress =>
      'Paiement en cours. Nous mettrons à jour dès confirmation.';

  @override
  String get walkiePlan_payPendingStillProcessing =>
      'Le paiement est toujours en cours. Veuillez patienter.';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      'Votre paiement est en cours de traitement par le fournisseur.\nCela peut prendre quelques minutes.';

  @override
  String get walkiePlan_payPendingSubtitleShort =>
      'Votre paiement est en cours';

  @override
  String get walkiePlan_payPendingTitle => 'Paiement en attente';

  @override
  String get walkiePlan_payPlanDetails => 'Détails du forfait';

  @override
  String get walkiePlan_payRefreshStatus => 'Actualiser le statut';

  @override
  String get walkiePlan_payStatusTitle => 'Statut du paiement';

  @override
  String get walkiePlan_payStepActivate => 'Activer le forfait';

  @override
  String get walkiePlan_payStepActivateSub =>
      'Votre forfait s’activera automatiquement';

  @override
  String get walkiePlan_payStepInitiated => 'Paiement initié';

  @override
  String get walkiePlan_payStepProcessing => 'Traitement en cours';

  @override
  String get walkiePlan_payStepProcessingSub =>
      'Votre paiement est en cours de confirmation';

  @override
  String get walkiePlan_payTeamFeatures =>
      'Accès multi-membres • Alertes instantanées';

  @override
  String get walkiePlan_payTotalPerOtp => 'Total par OTP';

  @override
  String get walkiePlan_payTryAgain => 'Réessayer';

  @override
  String get walkiePlan_payViewPlanDetails => 'Voir les détails du forfait';

  @override
  String get walkiePlan_perMember => 'par membre';

  @override
  String get walkiePlan_planFallback => 'Forfait';

  @override
  String get walkiePlan_quarterlyPlan => 'Forfait trimestriel';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'Veuillez finaliser la transaction dans la fenêtre Razorpay.';

  @override
  String get walkiePlan_razorpayCompletePayment => 'Finaliser le paiement';

  @override
  String get walkiePlan_razorpayConfirmingWithBank =>
      'Paiement initié. Nous confirmons auprès de la banque.';

  @override
  String get walkiePlan_razorpayConnecting => 'Connexion à Razorpay...';

  @override
  String get walkiePlan_razorpayCouldNotProcess =>
      'Le paiement n’a pas pu être traité. Veuillez réessayer.';

  @override
  String get walkiePlan_razorpayFailedTryAgain =>
      'Échec du paiement. Veuillez réessayer.';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1 mois actif';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return 'Payer $amount via Razorpay';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => 'Paiement annulé';

  @override
  String get walkiePlan_razorpayPaymentIdCopied =>
      'Identifiant de paiement copié !';

  @override
  String get walkiePlan_razorpayPciCompliant => '100 % Sûr et conforme PCI-DSS';

  @override
  String get walkiePlan_razorpayPendingConfirmation =>
      'Paiement en attente de confirmation.';

  @override
  String get walkiePlan_razorpayProcessing => 'Traitement avec Razorpay...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return 'Montant : $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied =>
      'Reçu copié dans le presse-papier !';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return 'Date : $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return 'Moyen de paiement : $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return 'ID commande : $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return 'ID paiement : $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'Forfait : $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => 'Statut : Complété';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'Reçu de paiement FG Tracker';

  @override
  String get walkiePlan_razorpayRetryPayment => 'Réessayer le paiement';

  @override
  String get walkiePlan_razorpaySecureCheckout =>
      'Paiement sécurisé propulsé par Razorpay';

  @override
  String get walkiePlan_razorpaySslEncrypted =>
      'Transactions chiffrées avec sécurité SSL 256 bits.';

  @override
  String get walkiePlan_razorpaySupportedModes => 'Moyens de paiement acceptés';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => 'Montant total à payer';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return 'Impossible de lancer la passerelle : $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed =>
      'Échec de la vérification du paiement.';

  @override
  String get walkiePlan_seatAssignedSeat => 'Place attribuée';

  @override
  String get walkiePlan_seatAssignment => 'Attribution des places';

  @override
  String get walkiePlan_seatTeamAccess => 'Accès d’équipe';

  @override
  String get walkiePlan_seatTeamMember => 'Membre de l’équipe';

  @override
  String get walkiePlan_secureEncryptedPayment =>
      'Paiement sécurisé et chiffré';

  @override
  String get walkiePlan_successAccessActivated => 'Accès activé';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      'Votre accès personnel au talkie-walkie est activé.';

  @override
  String get walkiePlan_successAmountPaid => 'Montant payé';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'Vous pourrez attribuer l’accès plus tard dans les paramètres.';

  @override
  String get walkiePlan_successAssignMembers => 'Attribuer des membres';

  @override
  String get walkiePlan_successAssignWalkieAccess => 'Attribuer l’accès talkie';

  @override
  String get walkiePlan_successChooseMembersDesc =>
      'Choisissez les membres qui peuvent utiliser le talkie-walkie.';

  @override
  String get walkiePlan_successContinueHome => 'Continuer vers l’accueil';

  @override
  String get walkiePlan_successDateTime => 'Date et heure';

  @override
  String get walkiePlan_successDefaultPaymentMethod => 'Razorpay (UPI / Carte)';

  @override
  String get walkiePlan_successIndividualActive =>
      'Votre forfait individuel est actif';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      'Votre forfait est actif. Allez à l’accueil pour discuter.';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      'Votre abonnement individuel est actif et lié à votre compte.';

  @override
  String get walkiePlan_successManageAccessNote =>
      'Vous pouvez modifier l’accès talkie à tout moment dans les paramètres.';

  @override
  String get walkiePlan_successMaybeLater => 'Peut-être plus tard';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'Votre forfait est actif. Les membres n’auront pas accès tant que vous ne les aurez pas assignés.';

  @override
  String get walkiePlan_successNotNow => 'Pas maintenant ?';

  @override
  String get walkiePlan_successPaid => 'PAYÉ';

  @override
  String get walkiePlan_successPaymentId => 'ID paiement';

  @override
  String get walkiePlan_successPaymentIdCopied =>
      'Identifiant de paiement copié !';

  @override
  String get walkiePlan_successPaymentMode => 'Moyen de paiement';

  @override
  String get walkiePlan_successPaymentReceipt => 'Reçu de paiement';

  @override
  String get walkiePlan_successPushToTalkDesc =>
      'Appuyez pour parler avec votre équipe.';

  @override
  String get walkiePlan_successRazorpayVerified => 'Vérifié par Razorpay';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return 'Montant : $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied => 'Détails du reçu copiés !';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return 'Date : $date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'Reçu de paiement FG Tracker';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return 'ID commande : $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return 'ID paiement : $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return 'Moyen de paiement : $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'Forfait : $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => 'Statut : Complété';

  @override
  String get walkiePlan_successSelectChannel => 'Sélectionner un canal';

  @override
  String get walkiePlan_successSelectChannelDesc =>
      'Rejoignez un groupe ou canal pour communiquer.';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'Sélectionnez les membres qui utiliseront le talkie-walkie.';

  @override
  String get walkiePlan_successSetUpTeam => 'Configurer l’équipe';

  @override
  String get walkiePlan_successSetUpTeamDesc =>
      'Invitez des membres, gérez rôles et autorisations.';

  @override
  String get walkiePlan_successShareReceipt => 'Partager le reçu';

  @override
  String get walkiePlan_successStartCommunicating => 'Commencez à communiquer';

  @override
  String get walkiePlan_successStatus => 'Statut';

  @override
  String get walkiePlan_successSuccessful => 'Réussi';

  @override
  String get walkiePlan_successTeamActive => 'Votre forfait d’équipe est actif';

  @override
  String get walkiePlan_successTeamReady => 'Votre équipe est prête !';

  @override
  String get walkiePlan_successTitle => 'Achat réussi !';

  @override
  String walkiePlan_successValidTill(String date) {
    return 'Valable jusqu’au $date';
  }

  @override
  String get walkiePlan_successVisitHome => 'Aller à l’écran d’accueil';

  @override
  String get walkiePlan_successWhatsNext => 'Et ensuite ?';

  @override
  String get walkiePlan_teamPlan => 'Forfait d’équipe';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'Forfait d’équipe ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => 'Période d’essai de 7 jours';

  @override
  String get walkiePlan_trialActiveLabel => 'ESSAI ACTIF';

  @override
  String get walkiePlan_trialActiveSubscription => 'Abonnement actif';

  @override
  String get walkiePlan_trialActiveSubscriptions => 'Abonnements actifs';

  @override
  String get walkiePlan_trialAvailableToStart => 'Prêt à démarrer';

  @override
  String get walkiePlan_trialCheckConnectionRetry =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'Choisissez un forfait ci-dessous pour utiliser le talkie-walkie.';

  @override
  String get walkiePlan_trialChooseSubscription =>
      'Choisissez un abonnement pour continuer avec le talkie-walkie.';

  @override
  String get walkiePlan_trialCompleted => 'Essai terminé';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours restants',
      one: '1 jour restant',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration Gratuit';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return 'Terminé le $date';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return 'Profitez de toutes les fonctions gratuitement pendant $duration.\nAucun paiement requis.';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      'Profitez du talkie-walkie pendant votre période d’essai.';

  @override
  String get walkiePlan_trialErrAccessMissing =>
      'Informations d’accès manquantes.';

  @override
  String get walkiePlan_trialErrFetchDetails =>
      'Impossible de récupérer les détails du talkie-walkie.';

  @override
  String get walkiePlan_trialErrInvalidResponse =>
      'Réponse non valide reçue du serveur.';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'Pas de connexion Internet. Vérifiez votre réseau et réessayez.';

  @override
  String get walkiePlan_trialErrOverviewMissing =>
      'Les données de vue d’ensemble sont manquantes.';

  @override
  String get walkiePlan_trialErrTimeout =>
      'La demande a expiré. Veuillez réessayer.';

  @override
  String get walkiePlan_trialErrUnableToLoad =>
      'Impossible de charger les détails du talkie-walkie.';

  @override
  String get walkiePlan_trialExpired => 'Essai expiré';

  @override
  String get walkiePlan_trialExpiredLabel => 'ESSAI EXPIRÉ';

  @override
  String get walkiePlan_trialExpiringSoon => 'Expire bientôt';

  @override
  String get walkiePlan_trialFeatClearAudio => 'Audio clair';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'Haute qualité vocale';

  @override
  String get walkiePlan_trialFeatGroupComm => 'Communication de groupe';

  @override
  String get walkiePlan_trialFeatGroupCommDesc =>
      'Connectez-vous avec votre équipe';

  @override
  String get walkiePlan_trialFeatPtt => 'Push-to-talk';

  @override
  String get walkiePlan_trialFeatPttDesc => 'Communication vocale instantanée';

  @override
  String get walkiePlan_trialFeatUnlimited => 'Utilisation illimitée';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => 'Utilisez sans limites';

  @override
  String get walkiePlan_trialFreeAvailable => 'Essai gratuit disponible';

  @override
  String get walkiePlan_trialFreeTrialLabel => 'ESSAI GRATUIT';

  @override
  String get walkiePlan_trialFreeTrialRunning => 'Essai gratuit en cours';

  @override
  String get walkiePlan_trialFullAccess =>
      'Accès complet à toutes les fonctionnalités';

  @override
  String get walkiePlan_trialFullyConsumed =>
      'Votre essai gratuit a été totalement utilisé.';

  @override
  String get walkiePlan_trialHasEnded => 'Votre période d’essai est terminée';

  @override
  String get walkiePlan_trialHeaderInstant =>
      'Communiquez instantanément avec votre groupe';

  @override
  String get walkiePlan_trialHeaderPlanStatus =>
      'Statut de votre forfait et abonnement';

  @override
  String walkiePlan_trialHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures',
      one: '1 heure',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures restantes',
      one: '1 heure restante',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHr(int count) {
    return '$count h';
  }

  @override
  String walkiePlan_trialHrMin(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get walkiePlan_trialIsActive => 'Votre essai est actif';

  @override
  String walkiePlan_trialMin(int count) {
    return '$count min';
  }

  @override
  String walkiePlan_trialMinSec(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String walkiePlan_trialMinsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mins restantes',
      one: '1 min restante',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_trialNoActivePlan => 'Aucun forfait actif';

  @override
  String get walkiePlan_trialNoCardRequired =>
      'Utilisable sous 7 jours  •  Sans carte bancaire';

  @override
  String get walkiePlan_trialNoInternetTitle => 'Pas de connexion Internet';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return 'Aucun paiement immédiat. Vous pourrez continuer avec un forfait payant ($price/personne).';
  }

  @override
  String get walkiePlan_trialPeriodMonth => 'mois';

  @override
  String get walkiePlan_trialRetrying => 'Nouvelle tentative...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count s';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return 'Démarrer l’essai gratuit de $duration';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial =>
      'Démarrez votre essai gratuit';

  @override
  String get walkiePlan_trialStatusCompleted => 'Complété';

  @override
  String get walkiePlan_trialStatusExpired => 'Expiré';

  @override
  String get walkiePlan_trialSubscriptionActive => 'Abonnement actif';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'Votre abonnement a pris fin. Renouvelez pour continuer.';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'Abonnement expiré';

  @override
  String get walkiePlan_trialTalkFree =>
      'Parlez gratuitement avec votre groupe.';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return 'Parlez gratuitement en groupe jusqu’au $date.';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg =>
      'Vous avez accès au talkie-walkie via le forfait d’équipe.';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return '$time restant';
  }

  @override
  String get walkiePlan_trialTimeRemaining => 'Temps d’essai restant';

  @override
  String get walkiePlan_trialTimeUsedUp => 'Temps d’essai écoulé';

  @override
  String get walkiePlan_trialTryAgain => 'Réessayer';

  @override
  String get walkiePlan_trialUnableToLoadTitle =>
      'Impossible de charger le talkie-walkie';

  @override
  String get walkiePlan_trialUsage => 'Utilisation de l’essai';

  @override
  String get walkiePlan_trialUseAnytime7Days =>
      'Utilisez l’essai à tout moment sous 7 jours';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return 'Profitez de vos $duration d’essai sous 7 jours.';
  }

  @override
  String get walkiePlan_trialUsed => 'Essai utilisé';

  @override
  String get walkiePlan_trialValidityPeriod => 'Période de validité de l’essai';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'Talkie-walkie';

  @override
  String get walkiePlan_trialWhatYouCanDo =>
      'Ce que vous pouvez faire pendant l’essai';

  @override
  String get walkiePlan_unableToConnect =>
      'Impossible de se connecter au serveur. Veuillez réessayer.';

  @override
  String get walkiePlan_yearlyPlan => 'Forfait annuel';

  @override
  String get walkie_aMember => 'Un membre';

  @override
  String get walkie_accept => 'Accepter';

  @override
  String get walkie_activeAccess => 'Accès actif';

  @override
  String get walkie_activeBadge => 'Actif';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actifs sur le talkie',
      one: '1 actif sur le talkie',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'Membre actif';

  @override
  String get walkie_admin => 'Admin';

  @override
  String get walkie_adminMuted => 'Admin • Muet';

  @override
  String get walkie_adminOnlyAction => 'Action réservée aux administrateurs';

  @override
  String get walkie_adminOnlyActionMessage =>
      'Seul l\'administrateur du groupe peut envoyer des alertes de notification aux membres.';

  @override
  String walkie_alertSentMessage(String name) {
    return 'Notification envoyée à $name. Réessai possible dans 10 s.';
  }

  @override
  String get walkie_alertSentTitle => 'Alerte envoyée';

  @override
  String get walkie_assignMembersToCommunicate =>
      'Assignez des membres pour communiquer';

  @override
  String get walkie_assignedByYou => 'Attribué par vous';

  @override
  String walkie_assignedCount(int count) {
    return '$count attribués';
  }

  @override
  String get walkie_assignedSeats => 'Sièges attribués';

  @override
  String get walkie_audioBluetooth => 'Bluetooth';

  @override
  String get walkie_audioHeadset => 'Casque micro';

  @override
  String get walkie_audioOutput => 'Sortie audio';

  @override
  String get walkie_audioPhone => 'Téléphone';

  @override
  String get walkie_audioSpeaker => 'Haut-parleur';

  @override
  String get walkie_audioWiredHeadphones => 'Casque filaire';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return 'Déverrouillage auto dans $seconds s';
  }

  @override
  String get walkie_availableMembers => 'Membres disponibles';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous pouvez assigner jusqu’à $count membres',
      one: 'Vous pouvez assigner jusqu’à 1 membre',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat =>
      'Impossible de retirer un siège attribué par un autre admin';

  @override
  String get walkie_cannotSpeak => 'Impossible de parler sur ce canal';

  @override
  String get walkie_channelBusy => 'Le canal est occupé';

  @override
  String get walkie_channelLocked => 'Canal verrouillé';

  @override
  String get walkie_channelSpeaking => 'Canal en cours...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return 'Impossible de définir $group comme canal vocal actif.';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'Erreur de changement de canal';

  @override
  String get walkie_channelUnlocked => 'Canal déverrouillé';

  @override
  String get walkie_chat => 'Discussion';

  @override
  String get walkie_checkNetworkTryAgain =>
      'Vérifiez votre connexion réseau et réessayez.';

  @override
  String get walkie_chooseAPlan => 'Choisir un forfait';

  @override
  String get walkie_connected => 'Connecté';

  @override
  String get walkie_connectedWaiting =>
      'Connecté au canal • En attente des autres';

  @override
  String get walkie_connectingChannel => 'Connexion au canal...';

  @override
  String get walkie_consumingTrial => 'Utilisation de l’essai...';

  @override
  String get walkie_continueListenOnly => 'Continuer en mode écoute seule';

  @override
  String walkie_currentlyAssigned(int count) {
    return 'Actuellement attribués ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'Groupe Talkie';

  @override
  String get walkie_description => 'Description';

  @override
  String get walkie_disconnected => 'Déconnecté';

  @override
  String get walkie_editAssignedMembers => 'Modifier les membres attribués';

  @override
  String get walkie_enable => 'Activer';

  @override
  String walkie_errorWithDetails(String details) {
    return 'Erreur : $details';
  }

  @override
  String get walkie_exitWalkie => 'Quitter le talkie';

  @override
  String get walkie_exitWalkieMessage =>
      'Vous serez déconnecté de ce canal. Vous resterez toujours membre du groupe.';

  @override
  String get walkie_exitWalkieTitle => 'Quitter le talkie-walkie ?';

  @override
  String get walkie_fairConnection => 'Connexion moyenne';

  @override
  String walkie_fairConnectionMs(int ms) {
    return 'Connexion moyenne ($ms ms)';
  }

  @override
  String get walkie_featureAllDevices => 'Utilisable sur tous les appareils';

  @override
  String get walkie_featureEasyCoordination => 'Coordination de groupe facile';

  @override
  String get walkie_featureHoldToTalk => 'Maintenez pour parler';

  @override
  String get walkie_featurePtt => 'Push-to-talk';

  @override
  String get walkie_featureQuickGroup => 'Communication de groupe rapide';

  @override
  String get walkie_featureRealtime => 'Connectivité en temps réel';

  @override
  String get walkie_featureSafeReliable => 'Sûr et fiable';

  @override
  String get walkie_featureStayConnected => 'Restez toujours connecté';

  @override
  String get walkie_featureTeamCommunication => 'Communication d\'équipe';

  @override
  String get walkie_featureUnlimited => 'Illimité';

  @override
  String get walkie_fieldTeam => 'Équipe de terrain';

  @override
  String get walkie_freeTrialEnded => 'Essai gratuit terminé';

  @override
  String get walkie_freeTrialEndedMessage =>
      'Votre essai gratuit d’une heure est terminé.\nPassez à la version supérieure pour continuer à communiquer.';

  @override
  String get walkie_freeTrialEndedTitle => 'Essai gratuit terminé';

  @override
  String get walkie_genericError => 'Erreur de Talkie-walkie';

  @override
  String get walkie_getPlan => 'Obtenir un forfait';

  @override
  String walkie_goodConnectionMs(int ms) {
    return 'Bonne connexion ($ms ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'Code de groupe : $code';
  }

  @override
  String get walkie_groupCommunication => 'Communication de groupe';

  @override
  String get walkie_groupFallback => 'Groupe';

  @override
  String get walkie_groupMembers => 'Membres du groupe';

  @override
  String get walkie_heroSubtitle =>
      'Utilisez la communication vocale Push-to-Talk sans passer d\'appel téléphonique.';

  @override
  String get walkie_heroTitle => 'Restez connecté, parlez instantanément';

  @override
  String get walkie_holdToTalk => 'Maintenez pour parler';

  @override
  String get walkie_holdToTalkSlideLock =>
      'Maintenez pour parler, glissez pour verrouiller';

  @override
  String get walkie_inWalkieChannel => 'Dans le canal talkie';

  @override
  String get walkie_individualActiveUpgrade =>
      'Forfait individuel actif (Accès perso) • Passez au forfait d’équipe.';

  @override
  String get walkie_individualLimitMessage =>
      'Votre forfait individuel permet 1 seul siège. Pour connecter toute votre équipe, passez au forfait d’équipe.';

  @override
  String get walkie_individualPlan => 'Forfait individuel';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (Individuel)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      'Forfait individuel (Accès personnel) • Passez à Équipe';

  @override
  String get walkie_individualSubscribedSelf =>
      'Forfait individuel • Souscrit par vous';

  @override
  String get walkie_info => 'Infos';

  @override
  String walkie_isSpeaking(String name) {
    return '$name est en train de parler...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name parle...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rejoints',
      one: '1 rejoint',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return 'Vu pour la dernière fois $time';
  }

  @override
  String get walkie_listenOnly => 'Écoute uniquement';

  @override
  String get walkie_listenOnlyTapPlan =>
      'Écoute seule — Touchez pour voir le forfait';

  @override
  String get walkie_listening => 'Écoute';

  @override
  String get walkie_listeningOnly => 'Écoute seule';

  @override
  String get walkie_live => 'EN DIRECT';

  @override
  String get walkie_lockTimeout => 'Délai dépassé — Micro libéré';

  @override
  String get walkie_lockedTapMic =>
      'Verrouillé — Touchez le micro pour arrêter';

  @override
  String get walkie_maybeLater => 'Peut-être plus tard';

  @override
  String get walkie_member => 'Membre';

  @override
  String get walkie_membersInChannel => 'Membres dans le canal';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Membres en ligne',
      one: 'Membre en ligne',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed =>
      'Échec de mise à jour des membres attribués';

  @override
  String get walkie_membersUpdated =>
      'Membres attribués mis à jour avec succès';

  @override
  String get walkie_micAccessRequired => 'Accès au micro requis pour parler.';

  @override
  String get walkie_micDisabledMessage =>
      'L\'accès au micro est désactivé dans les paramètres de l\'appareil. Pour parler, autorisez le micro dans les Réglages.\n\nVous pouvez toujours écouter les autres.';

  @override
  String get walkie_micPermissionRequired => 'Autorisation du micro requise';

  @override
  String get walkie_micPermissionTitle => 'Autorisation du microphone';

  @override
  String get walkie_micRequiredMessage =>
      'L\'autorisation du micro est requise pour parler dans ce groupe de talkie-walkie.\n\nVous pouvez toujours écouter les autres sans activer le micro.';

  @override
  String get walkie_muteMe => 'Me couper le micro';

  @override
  String get walkie_muted => 'Muet';

  @override
  String get walkie_mutedInWalkie => 'Muet • Sur le talkie';

  @override
  String get walkie_mutedListeningOnly =>
      'Vous êtes en sourdine — Écoute seule';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name parle...';
  }

  @override
  String get walkie_noActivePlan => 'Aucun forfait actif';

  @override
  String get walkie_noAvailableMembers => 'Aucun membre disponible';

  @override
  String get walkie_noBluetoothDevice =>
      'Aucun appareil Bluetooth connecté. Associez votre casque dans les paramètres.';

  @override
  String get walkie_noGroupsFound => 'Aucun groupe trouvé';

  @override
  String get walkie_noMembersAssigned => 'Aucun membre actuellement attribué';

  @override
  String get walkie_noMembersFound => 'Aucun membre trouvé';

  @override
  String get walkie_noMembersFoundTitle => 'Aucun membre trouvé';

  @override
  String get walkie_noMembersMatch => 'Aucun membre ne correspond';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return 'Aucun membre ne correspond à \'$query\'';
  }

  @override
  String get walkie_noMembersToAssign =>
      'Aucun membre du groupe disponible à assigner.';

  @override
  String get walkie_noNameGroup => 'Groupe sans nom';

  @override
  String get walkie_noPlanSubscribeAssign =>
      'Aucun forfait actif • Abonnez-vous pour assigner';

  @override
  String get walkie_noSeatMessage =>
      'Vous avez un forfait d\'équipe actif, mais tous les sièges vocaux sont actuellement attribués à d\'autres membres.\n\nVous pouvez écouter les conversations en direct, mais pour parler, vous devez vous attribuer un siège ou mettre à niveau votre forfait.';

  @override
  String get walkie_noSeatTitle => 'Aucun siège vocal attribué';

  @override
  String get walkie_noSeatsRefreshing =>
      'Aucun siège disponible. Actualisation...';

  @override
  String get walkie_noSubscriptionMessage =>
      'Vous n\'avez pas d\'abonnement actif. Abonnez-vous pour assigner des membres et commencer à communiquer.';

  @override
  String get walkie_noTeamSubscription =>
      'Aucun abonnement d’équipe actif trouvé';

  @override
  String get walkie_noValidMembers => 'Aucun membre valide sélectionné';

  @override
  String get walkie_noVoiceSeatListenOnly =>
      'Aucun siège vocal attribué — Mode écoute seule';

  @override
  String get walkie_noWiredDevice =>
      'Aucun écouteur filaire connecté. Veuillez les brancher.';

  @override
  String get walkie_notConnected => 'Non connecté';

  @override
  String get walkie_notifLeave => 'Quitter';

  @override
  String get walkie_notifOpenWalkie => 'Ouvrir Talkie';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name a fini de parler';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name est en train de parler';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return 'Impossible de mettre à jour les notifications pour $group. Veuillez réessayer.';
  }

  @override
  String get walkie_notificationSettingTitle => 'Paramètres de notification';

  @override
  String get walkie_onlyAdminCanAlert =>
      'Seul l’admin du groupe peut envoyer des alertes';

  @override
  String get walkie_openWalkieTalkie => 'Ouvrir le Talkie-walkie';

  @override
  String get walkie_otherTeam => 'Autre équipe';

  @override
  String get walkie_othersWontHear => 'Les autres ne vous entendront pas';

  @override
  String get walkie_planRequiredTitle => 'Forfait Talkie-walkie requis';

  @override
  String get walkie_planRequiredToTalk => 'Forfait requis pour parler';

  @override
  String get walkie_planStartsOnFirstAssign =>
      'Le forfait commence dès l’attribution du premier membre.';

  @override
  String get walkie_poorConnection =>
      'Connexion faible — L’audio peut être saccadé';

  @override
  String get walkie_preparingAudio => 'Préparation de l’audio...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'Achetez un forfait d’équipe pour attribuer l’accès aux membres.';

  @override
  String get walkie_purchaseUpgradePlan =>
      'Acheter / Mettre à niveau le forfait';

  @override
  String get walkie_ready => 'Prêt';

  @override
  String get walkie_reconnecting => 'Reconnexion...';

  @override
  String get walkie_reconnectingServer =>
      'Reconnexion au serveur talkie-walkie...';

  @override
  String get walkie_releaseToStop => 'Relâchez pour arrêter';

  @override
  String get walkie_removeAll => 'Tout retirer';

  @override
  String get walkie_searchGroups => 'Rechercher des groupes';

  @override
  String get walkie_searchMembers => 'Rechercher des membres...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total sièges';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '$total sièges au total • $assigned attribués • $available disponibles';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '$assigned / $total sièges utilisés';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get walkie_selectAtLeastOne =>
      'Veuillez sélectionner au moins un membre';

  @override
  String get walkie_selectGroupFirst =>
      'Veuillez sélectionner un groupe d’abord';

  @override
  String get walkie_selectGroupToConnect =>
      'Sélectionnez un groupe à connecter';

  @override
  String get walkie_selected => 'Sélectionné';

  @override
  String get walkie_selfAccess => 'Accès personnel';

  @override
  String get walkie_selfPlan => 'Forfait personnel';

  @override
  String get walkie_slideUpToLock => 'Glissez vers le haut pour verrouiller';

  @override
  String get walkie_someone => 'Quelqu’un';

  @override
  String get walkie_someoneSpeaking => 'Quelqu’un parle...';

  @override
  String get walkie_speaking => 'Parle...';

  @override
  String walkie_startFreeTrial(String duration) {
    return 'Démarrer l’essai gratuit de $duration';
  }

  @override
  String get walkie_strongConnection => 'Connexion excellente';

  @override
  String walkie_strongConnectionMs(int ms) {
    return 'Connexion excellente ($ms ms)';
  }

  @override
  String get walkie_subscribeToStartTalk =>
      'Abonnez-vous pour parler et assigner des membres';

  @override
  String get walkie_subscribed => 'Abonné';

  @override
  String get walkie_talking => 'Parle...';

  @override
  String get walkie_tapToUnlock => 'Touchez pour déverrouiller';

  @override
  String get walkie_teamAssignedElsewhere =>
      'Forfait d’équipe • Attribué ailleurs';

  @override
  String get walkie_teamPlan => 'Forfait d\'équipe';

  @override
  String get walkie_teamPlanRequired => 'Forfait d’équipe requis';

  @override
  String get walkie_teamPlanRequiredToAssign =>
      'Forfait d’équipe requis pour assigner des membres';

  @override
  String get walkie_teamPlanStatus => 'Statut du forfait d\'équipe';

  @override
  String get walkie_teamSeatMember => 'Membre d\'un siège d\'équipe';

  @override
  String get walkie_title => 'Talkie-walkie';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count au total',
      one: '1 au total',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => 'Essai actif 1 h';

  @override
  String get walkie_trialEndedSubscribe =>
      'Essai gratuit terminé — Abonnez-vous pour continuer';

  @override
  String get walkie_unableToConnectReconnecting =>
      'Impossible de se connecter au canal — Reconnexion...';

  @override
  String get walkie_unavailable => 'Indisponible';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'Mettre à jour les membres ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'Mise à jour des membres...';

  @override
  String get walkie_upgradeAddSeats => 'Mettre à niveau et ajouter des sièges';

  @override
  String get walkie_upgradeNow => 'Mettre à niveau maintenant';

  @override
  String get walkie_upgradeTeamAssign =>
      'Passer au forfait d’équipe (Assigner)';

  @override
  String get walkie_upgradeToTeamPlan => 'Passer au forfait d’équipe';

  @override
  String walkie_userCancelled(String name) {
    return '$name a annulé';
  }

  @override
  String walkie_userJoined(String name) {
    return '$name a rejoint';
  }

  @override
  String walkie_userLeft(String name) {
    return '$name est parti';
  }

  @override
  String walkie_validTill(String date) {
    return 'Valable jusqu\'au $date';
  }

  @override
  String get walkie_viewPlan => 'Voir le forfait';

  @override
  String get walkie_voiceNotPermitted => 'Transmission vocale non autorisée';

  @override
  String get walkie_weakSignal => 'Signal faible';

  @override
  String walkie_weakSignalMs(int ms) {
    return 'Signal faible ($ms ms)';
  }

  @override
  String get walkie_youAreConnected => 'Vous êtes connecté';

  @override
  String get walkie_yourVoiceAccess => 'Votre accès vocal';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Télécharger pour Android : $playStoreLink\n\nTélécharger pour iOS : $appStoreLink';
  }

  @override
  String get widget_live => 'En direct';

  @override
  String get widget_lostConnection => 'Connexion perdue';

  @override
  String get widget_manageGroups => 'Gérez vos groupes facilement';

  @override
  String get widget_noInternetBody =>
      'Oups... aucune connexion Internet trouvée. Vérifiez votre réseau';

  @override
  String get widget_notSeenYet => 'Pas encore vu';

  @override
  String get widget_pinnedMessage => 'Message épinglé';

  @override
  String get widget_private => 'Privé';

  @override
  String get widget_refreshPage => 'Actualiser la page';

  @override
  String get widget_seen => 'Vu';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count sur $total)';
  }

  @override
  String get widget_somethingWentWrongTitle => 'Une erreur est survenue';

  @override
  String get widget_userFallback => 'Utilisateur';
}
