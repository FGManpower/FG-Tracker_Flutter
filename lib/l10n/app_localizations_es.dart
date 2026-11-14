// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about_aboutUs => 'Sobre nosotros';

  @override
  String get about_address => 'Dirección';

  @override
  String get about_appBarTitle => 'Acerca de FG Tracker';

  @override
  String get about_company => 'Empresa';

  @override
  String get about_contactUs => 'Contáctanos';

  @override
  String get about_developerEmail => 'Correo del desarrollador';

  @override
  String get about_downloadTitle => '📱 Descargar aplicación';

  @override
  String get about_howItWorksIntro =>
      'FG Tracker simplifica la coordinación de viajes en grupo. Así funciona:';

  @override
  String get about_howItWorksTitle => '⚙️ Cómo funciona';

  @override
  String get about_howStep1 => 'Crea un grupo';

  @override
  String get about_howStep2 =>
      'Comparte el código del grupo o el código QR con tus acompañantes';

  @override
  String get about_howStep3 =>
      'Cada miembro se une usando el código o el QR compartido';

  @override
  String get about_howStep4 =>
      'Sigue la ubicación en vivo de todos en un mapa compartido en tiempo real';

  @override
  String get about_howStep5 =>
      'Usa la función de compartir para invitar a más personas fácilmente';

  @override
  String get about_intro =>
      'FG Tracker es tu compañero ideal para mantenerte conectado y seguro mientras viajas en grupo. Ya sea un viaje familiar por carretera, un picnic con amigos o el trayecto diario con colegas, FG Tracker garantiza que nadie se quede atrás.';

  @override
  String get about_privacyBody =>
      'Tu seguridad y privacidad son lo primero. FG Tracker no comparte tu ubicación con nadie fuera de tu grupo. Todos los datos están encriptados y solo se comparten con las personas autorizadas.';

  @override
  String get about_privacyPolicy => 'Política de privacidad';

  @override
  String get about_privacyTitle => '🔐 Privacidad y seguridad';

  @override
  String get about_supportEmail => 'Correo de soporte';

  @override
  String get about_supportTitle => '📩 Soporte e información del desarrollador';

  @override
  String get about_termsConditions => 'Términos y condiciones';

  @override
  String get about_title => 'Acerca de';

  @override
  String get about_website => 'Sitio web';

  @override
  String get about_welcomeTitle => 'Bienvenido a FG Tracker';

  @override
  String get about_whyBuiltFor =>
      'Creado para familias, amigos y equipos pequeños.';

  @override
  String get about_whyChooseTitle => '🌟 ¿Por qué elegir FG Tracker?';

  @override
  String get about_whyEasy =>
      'Fácil de usar, liviana y con control de privacidad.';

  @override
  String get about_whyNoCalls =>
      'Sin necesidad de llamar o enviar mensajes: sigue en vivo en el mapa.';

  @override
  String get about_whyRealTime =>
      'Ubicación en tiempo real compartida con todos los miembros.';

  @override
  String appUpdate_checkError(String error) {
    return 'Error al buscar actualizaciones: $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => '¿Quieres salir?';

  @override
  String get appUpdate_noUpdateAvailable =>
      'No hay actualizaciones disponibles';

  @override
  String get appUpdate_restartApp => 'Reiniciar aplicación';

  @override
  String get appUpdate_updateApp => 'Actualizar app';

  @override
  String get appUpdate_updateAvailable => 'Actualización disponible';

  @override
  String get appUpdate_updateAvailableMessage =>
      'Hay una nueva actualización disponible. Actualiza la aplicación';

  @override
  String get appUpdate_updateUnavailable => 'Actualización no disponible';

  @override
  String appUpdate_updatingProgress(int progress) {
    return 'Actualizando... $progress%';
  }

  @override
  String get attendance_addOption => 'Añadir otra opción';

  @override
  String get attendance_admin => 'Admin';

  @override
  String get attendance_allowChange => 'Permitir cambiar la respuesta';

  @override
  String get attendance_allowChangeSubtitle =>
      'Los miembros pueden cambiar o eliminar su respuesta';

  @override
  String get attendance_askCommunity => 'Pregunta a tu comunidad';

  @override
  String get attendance_cameraPermissionRequired =>
      'Se requiere permiso de cámara para marcar asistencia.';

  @override
  String get attendance_cameraStartFailed => 'No se pudo iniciar la cámara.';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'No se pudo iniciar la cámara ($code).';
  }

  @override
  String get attendance_cameraStarting => 'Iniciando cámara…';

  @override
  String get attendance_captureFailedBlink =>
      'No se pudo capturar. Parpadea de nuevo para reintentar';

  @override
  String attendance_capturedAtVerified(String time) {
    return 'Capturada a las $time • Verificada';
  }

  @override
  String get attendance_capturedCheck => 'Capturado ✓';

  @override
  String get attendance_changeResponse => 'Cambiar respuesta';

  @override
  String get attendance_chooseFolder => 'Elige una carpeta, p. ej., Descargas';

  @override
  String get attendance_closeAction => 'Cerrar asistencia';

  @override
  String get attendance_closeConfirmBody =>
      'Los miembros ya no podrán responder después de cerrarla.';

  @override
  String get attendance_closeConfirmTitle => '¿Cerrar asistencia?';

  @override
  String get attendance_closeEndOfDay => 'Cerrar al final del día';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return 'Se cierra automáticamente a las $time hoy';
  }

  @override
  String get attendance_closeFailed => 'No se puede cerrar la asistencia';

  @override
  String get attendance_closeFailedShort => 'No se puede cerrar';

  @override
  String attendance_closesAt(String dateTime) {
    return 'Se cierra el $dateTime';
  }

  @override
  String get attendance_createFailed => 'No se puede crear la asistencia';

  @override
  String get attendance_createSubtitle =>
      'Envía una encuesta de asistencia a este grupo';

  @override
  String get attendance_createTitle => 'Crear asistencia';

  @override
  String get attendance_created => 'Asistencia creada';

  @override
  String get attendance_dateEnded =>
      'La fecha seleccionada ya ha finalizado. Elige otra fecha o desactiva el cierre automático.';

  @override
  String get attendance_dateToday => 'Fecha (hoy)';

  @override
  String get attendance_dateTodaySemantics => 'Fecha de asistencia, hoy';

  @override
  String get attendance_deleteFailed => 'No se puede eliminar la asistencia';

  @override
  String get attendance_deletedText => 'Esta asistencia fue eliminada';

  @override
  String get attendance_downloadReport => 'Descargar informe';

  @override
  String get attendance_everyoneResponded => 'Todos han respondido';

  @override
  String get attendance_faceDetectedBlink =>
      'Rostro detectado — ahora parpadea';

  @override
  String get attendance_failed => 'Error en asistencia';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return 'No respondieron ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return 'Respondieron ($count)';
  }

  @override
  String get attendance_fixErrors =>
      'Por favor, corrige los errores resaltados antes de enviar';

  @override
  String get attendance_holdStill => 'No te muevas…';

  @override
  String get attendance_howToTakePhoto => 'Cómo tomar la foto';

  @override
  String get attendance_invalidGroup =>
      'Grupo no válido. Por favor, reabre el chat.';

  @override
  String get attendance_keepFaceInCircle =>
      'Mantén tu rostro dentro del círculo';

  @override
  String get attendance_limitReached => 'Límite alcanzado';

  @override
  String get attendance_loadFailed => 'No se pudo cargar la asistencia';

  @override
  String get attendance_loadMore => 'Cargar más';

  @override
  String get attendance_loadMoreFailed => 'No se puede cargar más';

  @override
  String get attendance_loadVotersFailed => 'No se pueden cargar los votantes';

  @override
  String get attendance_lookAtCamera => 'Mira a la cámara';

  @override
  String get attendance_lookStraight => 'Mira directamente a la cámara';

  @override
  String get attendance_markYourAttendance => 'Marca tu asistencia';

  @override
  String attendance_markedAs(String option) {
    return 'Marcado como $option';
  }

  @override
  String get attendance_markedSuccess => 'Asistencia marcada con éxito';

  @override
  String attendance_maxOptions(int count) {
    return 'Puedes añadir hasta $count opciones únicamente';
  }

  @override
  String get attendance_members => 'Miembros';

  @override
  String attendance_membersWithCount(int count) {
    return 'Miembros ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return 'Se requieren al menos $count opciones';
  }

  @override
  String get attendance_moveCloser => 'Acércate un poco más';

  @override
  String get attendance_multipleFaces =>
      'Se detectaron varios rostros — solo tú debes estar en el encuadre';

  @override
  String get attendance_noCsvApp =>
      'No se encontró ninguna aplicación para abrir archivos CSV. Usa Guardar o Compartir.';

  @override
  String get attendance_noFace => 'No se detectó ningún rostro';

  @override
  String get attendance_noFrontCamera =>
      'No se encontró cámara frontal en este dispositivo.';

  @override
  String get attendance_noLocation => 'Sin ubicación disponible';

  @override
  String get attendance_noMembersMatch =>
      'Ningún miembro coincide con tu búsqueda';

  @override
  String get attendance_noResponses => 'Aún no hay respuestas';

  @override
  String get attendance_notResponded => 'No respondieron';

  @override
  String get attendance_openEyes => 'Abre los ojos y mira a la cámara';

  @override
  String get attendance_openMapFailed => 'No se puede abrir el mapa';

  @override
  String get attendance_openSubtitle => 'Ver en Excel, Sheets u otra app';

  @override
  String get attendance_optionHint => 'Introduce la etiqueta de la opción';

  @override
  String get attendance_optionLabelRequired =>
      'Todas las opciones deben tener una etiqueta';

  @override
  String attendance_optionNumber(int number) {
    return 'Opción $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return 'Opción $number • 📷 Foto requerida';
  }

  @override
  String get attendance_optionsUnique => 'Las opciones deben ser únicas';

  @override
  String get attendance_photoCaptured => 'Foto capturada';

  @override
  String get attendance_photoCapturedTapRetake =>
      'Foto capturada ✓ (Toca para repetir)';

  @override
  String get attendance_photoProof => 'Prueba fotográfica';

  @override
  String attendance_photoProofOf(String name) {
    return 'Prueba fotográfica de $name';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ Foto requerida para $option';
  }

  @override
  String get attendance_photoRules =>
      'Solo se utiliza la cámara frontal. La foto se toma automáticamente cuando parpadeas y no se permiten cargas desde la galería.';

  @override
  String get attendance_photoSubtitle =>
      'Toma una foto en vivo para verificar tu asistencia';

  @override
  String get attendance_photoTitle => 'Foto de asistencia';

  @override
  String get attendance_photoVerified => 'Foto verificada';

  @override
  String get attendance_questionHint => '¿Estarás disponible hoy?';

  @override
  String get attendance_questionLabel => 'Pregunta de asistencia';

  @override
  String get attendance_questionRequired =>
      'La pregunta de asistencia es obligatoria';

  @override
  String attendance_questionTooShort(int count) {
    return 'La pregunta debe tener al menos $count caracteres';
  }

  @override
  String get attendance_removeFailedShort => 'No se puede eliminar';

  @override
  String get attendance_removeResponseBody =>
      'Tu asistencia para esta encuesta será borrada.';

  @override
  String get attendance_removeResponseTitle => '¿Eliminar tu respuesta?';

  @override
  String get attendance_removeVoteFailed => 'No se puede eliminar el voto';

  @override
  String get attendance_reportEmpty => 'El informe está vacío';

  @override
  String get attendance_reportFailed => 'Error en el informe';

  @override
  String get attendance_reportInvalid =>
      'El servidor devolvió un informe no válido. Inténtalo de nuevo.';

  @override
  String attendance_reportReady(String fileName) {
    return 'Informe listo • $fileName';
  }

  @override
  String get attendance_reportSaved => 'Informe guardado';

  @override
  String get attendance_reportSubject => 'Informe de asistencia';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return 'Informe de asistencia • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count respondieron';
  }

  @override
  String get attendance_retakePhoto => 'Repetir foto';

  @override
  String get attendance_saveInFiles => 'Guardar en la app Archivos';

  @override
  String get attendance_saveReportDialog => 'Guardar informe de asistencia';

  @override
  String get attendance_saveToDevice => 'Guardar en el dispositivo';

  @override
  String get attendance_searchMember => 'Buscar miembro';

  @override
  String get attendance_selectPhotoOption =>
      'Selecciona una opción para requerir una foto en vivo';

  @override
  String get attendance_selectStatus => 'Por favor, selecciona tu estado';

  @override
  String get attendance_sentToAllMembers =>
      'Enviado a todos los miembros de este grupo';

  @override
  String get attendance_sentToGroup => 'Asistencia enviada al grupo';

  @override
  String get attendance_shareSubtitle => 'Enviar por WhatsApp, correo...';

  @override
  String get attendance_statusCompleted => 'Completada';

  @override
  String get attendance_statusOpen => 'Abierta';

  @override
  String get attendance_stepBlink => 'Parpadea para capturar tu foto';

  @override
  String get attendance_stepEyeLevel =>
      'Sostén el teléfono al nivel de los ojos';

  @override
  String get attendance_submit => 'Enviar asistencia';

  @override
  String get attendance_submitted => 'Asistencia enviada';

  @override
  String get attendance_title => 'Asistencia';

  @override
  String get attendance_update => 'Actualizar asistencia';

  @override
  String get attendance_validationError => 'Error de validación';

  @override
  String get attendance_view => 'Ver';

  @override
  String get attendance_viewTitle => 'Ver asistencia';

  @override
  String get attendance_voteFailed => 'No se puede registrar el voto';

  @override
  String attendance_withinKm(String km) {
    return 'A menos de $km km';
  }

  @override
  String attendance_withinMeters(int count) {
    return 'A menos de $count m';
  }

  @override
  String get call_accept => 'Aceptar';

  @override
  String get call_allContacts => 'Todos los contactos';

  @override
  String get call_allowAccess => 'Permitir acceso';

  @override
  String get call_answer => 'Responder';

  @override
  String get call_audioOutput => 'Salida de audio';

  @override
  String get call_callFrom => 'Llamada de';

  @override
  String get call_callIdNotFound => 'ID de llamada no encontrado';

  @override
  String get call_callInformation => 'Información de la llamada';

  @override
  String get call_callSummary => 'Resumen de la llamada';

  @override
  String get call_caller => 'Llamante';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name y $count más',
      one: '$name y 1 más',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron eliminar $count llamadas. Inténtalo de nuevo.',
      one: 'No se pudo eliminar 1 llamada. Inténtalo de nuevo.',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count llamadas eliminadas',
      one: '1 llamada eliminada',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'Cámara';

  @override
  String get call_cameraMicRequired =>
      'Se requieren permisos de cámara o micrófono';

  @override
  String get call_cameraOff => 'Cámara desactivada';

  @override
  String get call_cameraOn => 'Cámara activada';

  @override
  String get call_cameraUnavailable =>
      'El acceso a la cámara no está disponible en este momento. Inténtalo más tarde.';

  @override
  String get call_cannotReachCallServer =>
      'No se puede conectar al servidor de llamadas. Comprueba tu red.';

  @override
  String get call_chatFallback => 'Chat';

  @override
  String get call_closeFullScreen => 'Cerrar pantalla completa';

  @override
  String get call_communicationUnavailable =>
      'La comunicación no está disponible con este usuario';

  @override
  String get call_connectingProgress => 'Conectando…';

  @override
  String get call_connectionTimeout => 'Tiempo de conexión agotado';

  @override
  String get call_contactInformation => 'Información de contacto';

  @override
  String get call_contactsAccessBannerMessage =>
      'Encuentra y llama fácilmente a los miembros de tu equipo.';

  @override
  String get call_contactsAccessBannerTitle =>
      'Permítenos acceder a tus contactos';

  @override
  String get call_contactsAccessMessage =>
      'Necesitamos acceso a tus contactos para mostrar quién está en FG Tracker y permitirte llamarlos o enviar una invitación.';

  @override
  String get call_contactsAccessTitle => 'Permitir acceso a contactos';

  @override
  String get call_decline => 'Rechazar';

  @override
  String get call_deleteCallsMessage =>
      'Estas llamadas se eliminarán de tu historial.';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count llamadas?',
      one: '¿Eliminar 1 llamada?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage =>
      '¿Seguro que deseas eliminar este historial de llamadas?';

  @override
  String get call_deleteHistoryTitle => 'Eliminar historial de llamadas';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Seguro que deseas eliminar estas $count entradas seleccionadas del historial de llamadas?',
      one:
          '¿Seguro que deseas eliminar este historial de llamadas seleccionado?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => 'Eliminar llamadas seleccionadas';

  @override
  String call_deleteWithCount(int count) {
    return 'Eliminar ($count)';
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
  String get call_duration => 'Duración';

  @override
  String call_durationValue(String duration) {
    return 'Duración: $duration';
  }

  @override
  String get call_earpiece => 'Auricular';

  @override
  String get call_endCall => 'Finalizar llamada';

  @override
  String get call_ended => 'Finalizada';

  @override
  String get call_enterNumber => 'Introduce el número';

  @override
  String get call_enterPhoneNumber =>
      'Por favor, introduce un número de teléfono';

  @override
  String get call_entryDeleteFailed =>
      'Error al eliminar el registro de llamada';

  @override
  String call_entryDeleteFailedError(String error) {
    return 'Error al eliminar el registro de llamada: $error';
  }

  @override
  String get call_entryDeleted => 'Registro de llamada eliminado';

  @override
  String get call_everyoneInCall => 'Todos ya están en la llamada';

  @override
  String get call_failedTitle => 'Llamada fallida';

  @override
  String get call_groupBadge => 'Grupo';

  @override
  String get call_groupCallComingSoon =>
      'Las llamadas grupales estarán disponibles pronto';

  @override
  String get call_groupCallInitFailed =>
      'No se pudo inicializar la llamada grupal';

  @override
  String get call_groupCallStartFailed =>
      'No se pudo iniciar la llamada grupal. Inténtalo de nuevo.';

  @override
  String get call_groupInformation => 'Información del grupo';

  @override
  String call_groupWithId(String id) {
    return 'Grupo $id';
  }

  @override
  String get call_headphones => 'Auriculares';

  @override
  String call_historyCancelled(String callType) {
    return '$callType cancelada';
  }

  @override
  String get call_historyClearFailed =>
      'Error al borrar el historial de llamadas';

  @override
  String call_historyClearFailedError(String error) {
    return 'Error al borrar el historial de llamadas: $error';
  }

  @override
  String get call_historyCleared =>
      'Todo el historial de llamadas ha sido borrado';

  @override
  String call_historyIncoming(String callType) {
    return '$callType entrante';
  }

  @override
  String call_historyMissed(String callType) {
    return '$callType perdida';
  }

  @override
  String call_historyOutgoing(String callType) {
    return '$callType saliente';
  }

  @override
  String call_historyRejected(String callType) {
    return '$callType rechazada';
  }

  @override
  String get call_inCall => 'En llamada';

  @override
  String call_inCallWithGroup(String groupName) {
    return 'En llamada · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return 'En esta llamada ($count)';
  }

  @override
  String get call_incomingAudio => 'Llamada de voz entrante';

  @override
  String get call_incomingCallChannelName => 'Llamada entrante';

  @override
  String get call_incomingGroupAudio => 'Llamada de voz grupal entrante';

  @override
  String get call_incomingGroupVideo => 'Videollamada grupal entrante';

  @override
  String get call_incomingVideo => 'Videollamada entrante';

  @override
  String get call_infoDescription => 'Descripción';

  @override
  String get call_infoEmail => 'Correo';

  @override
  String get call_infoGroupCode => 'Código del grupo';

  @override
  String get call_infoGroupName => 'Nombre del grupo';

  @override
  String get call_infoMobile => 'Móvil';

  @override
  String get call_infoTotalMembers => 'Miembros totales';

  @override
  String get call_invite => 'Invitar';

  @override
  String get call_inviteToApp => 'Invitar a FG Tracker';

  @override
  String get call_join => 'Unirse';

  @override
  String get call_joinOnAnswer => 'Te unirás tan pronto como respondas';

  @override
  String get call_kindAudio => 'Llamada de voz';

  @override
  String get call_kindCall => 'Llamada';

  @override
  String get call_kindGroupAudio => 'Llamada de voz grupal';

  @override
  String get call_kindGroupCall => 'Llamada grupal';

  @override
  String call_kindGroupOther(String kind) {
    return 'Llamada grupal $kind';
  }

  @override
  String get call_kindGroupVideo => 'Videollamada grupal';

  @override
  String call_kindOther(String kind) {
    return 'Llamada $kind';
  }

  @override
  String get call_kindVideo => 'Videollamada';

  @override
  String get call_loadDetailFailed =>
      'Error al cargar los detalles de la llamada';

  @override
  String get call_loadMore => 'Cargar más';

  @override
  String get call_loadRecentFailed => 'Error al cargar las llamadas recientes';

  @override
  String get call_loginToCall =>
      'Por favor, inicia sesión para realizar una llamada';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros en esta llamada',
      one: '1 miembro en esta llamada',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'Mensaje';

  @override
  String get call_micActive => 'El micrófono está activo';

  @override
  String get call_missedCall => 'Llamada perdida';

  @override
  String get call_missedCallChannelName => 'Llamada perdida';

  @override
  String get call_missedCallNotification => 'Llamada perdida';

  @override
  String get call_more => 'Más';

  @override
  String get call_mute => 'Silenciar';

  @override
  String get call_muted => 'Silenciado';

  @override
  String call_nameYou(String name) {
    return '$name (Tú)';
  }

  @override
  String get call_noActiveParticipants => 'No hay participantes activos';

  @override
  String get call_noContactsMatch => 'Ningún contacto coincide con tu búsqueda';

  @override
  String get call_noGroupsFound => 'No se encontraron grupos';

  @override
  String get call_noGroupsYet => 'Aún no hay grupos';

  @override
  String get call_noNameGroup => 'Grupo sin nombre';

  @override
  String get call_noRecentCalls => 'No hay llamadas recientes';

  @override
  String get call_noRecentMatch =>
      'Ninguna llamada reciente coincide con tu búsqueda';

  @override
  String get call_noRecentYet => 'Aún no hay llamadas recientes';

  @override
  String get call_noRegisteredContacts =>
      'No se encontraron contactos registrados';

  @override
  String get call_notInContacts => 'Este número no está en tus contactos';

  @override
  String call_notInThisCall(int count) {
    return 'No están en esta llamada ($count)';
  }

  @override
  String get call_notReady => 'Llamada no lista';

  @override
  String get call_notificationPermissionRationale =>
      'Necesario para mostrar llamadas entrantes.';

  @override
  String get call_notificationPermissionSettings =>
      'Activa las notificaciones en Ajustes.';

  @override
  String get call_notificationPermissionTitle => 'Permiso de notificación';

  @override
  String get call_notify => 'Notificar';

  @override
  String get call_notifyFailed => 'Error al notificar';

  @override
  String get call_notifySent => 'Notificado con éxito';

  @override
  String get call_ongoingChannelDescription =>
      'Mantiene activa la llamada y el uso compartido de pantalla';

  @override
  String get call_ongoingChannelName => 'Llamada en curso';

  @override
  String get call_otherAlreadySharing =>
      'La otra persona ya está compartiendo la pantalla';

  @override
  String get call_otherStartingVideo =>
      'La otra persona está activando el video';

  @override
  String get call_participant => 'Participante';

  @override
  String get call_participants => 'Participantes';

  @override
  String call_personIsSharing(String name) {
    return '$name está compartiendo';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name está compartiendo la pantalla';
  }

  @override
  String get call_phone => 'Teléfono';

  @override
  String get call_pleaseWait => 'Por favor, espera';

  @override
  String get call_recentCalls => 'Llamadas recientes';

  @override
  String get call_resetZoom => 'Restablecer zoom';

  @override
  String get call_returnToCall => 'Volver a la llamada';

  @override
  String get call_screenBeingShared => 'Se está compartiendo la pantalla';

  @override
  String get call_screenShareChannelDescription =>
      'Notificación de sesión activa de pantalla compartida';

  @override
  String get call_screenShareChannelName =>
      'Servicio de uso compartido de pantalla';

  @override
  String get call_screenSharePermissionDenied =>
      'Permiso para compartir pantalla denegado';

  @override
  String get call_screenShareStartFailed =>
      'No se pudo iniciar el uso compartido de pantalla';

  @override
  String get call_screenShareStopped =>
      'Se detuvo el uso compartido de pantalla';

  @override
  String get call_screenSharingTitle => 'Compartiendo pantalla';

  @override
  String call_screenVisibleToName(String name) {
    return 'Tu pantalla es visible para $name';
  }

  @override
  String get call_screenVisibleToOther =>
      'Tu pantalla es visible para la otra persona';

  @override
  String get call_searchHint => 'Buscar contactos o grupos';

  @override
  String get call_sectionLastWeek => 'La semana pasada';

  @override
  String get call_sectionOlder => 'Anteriores';

  @override
  String get call_sectionThisWeek => 'Esta semana';

  @override
  String get call_selectAll => 'Seleccionar todo';

  @override
  String call_selectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get call_selectedDeleteFailed =>
      'Error al eliminar las llamadas seleccionadas';

  @override
  String call_selectedDeleteFailedError(String error) {
    return 'Error al eliminar las llamadas seleccionadas: $error';
  }

  @override
  String get call_selectedDeleted => 'Llamadas seleccionadas eliminadas';

  @override
  String get call_selfCallWarning => 'No puedes llamar a tu propio número.';

  @override
  String get call_sessionConnectFailed =>
      'Error al conectar a la sesión de llamada';

  @override
  String get call_shareScreen => 'Compartir pantalla';

  @override
  String get call_shareScreenShort => 'Compartir';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return 'Compartiendo en $groupName • Toca para volver a la llamada';
  }

  @override
  String get call_sharingYourScreen => 'Compartiendo tu pantalla';

  @override
  String get call_someone => 'Alguien';

  @override
  String get call_speaker => 'Altavoz';

  @override
  String get call_started => 'Iniciada';

  @override
  String get call_startingScreenShare =>
      'Iniciando uso compartido de pantalla…';

  @override
  String get call_statusBusy => 'Ocupado';

  @override
  String get call_statusCalling => 'Llamando';

  @override
  String get call_statusCancelled => 'Cancelada';

  @override
  String get call_statusCompleted => 'Completada';

  @override
  String get call_statusConnected => 'Conectado';

  @override
  String get call_statusConnecting => 'Conectando';

  @override
  String get call_statusDeclined => 'Rechazada';

  @override
  String get call_statusJoined => 'Se unió';

  @override
  String get call_statusMissed => 'Perdida';

  @override
  String get call_statusReconnecting => 'Reconectando';

  @override
  String get call_statusRinging => 'Sonando';

  @override
  String get call_statusVideoConnecting => 'Conectando video';

  @override
  String get call_stop => 'Detener';

  @override
  String get call_stopSharing => 'Dejar de compartir';

  @override
  String get call_subtitle => 'Llamada de audio / video';

  @override
  String get call_swipeUpToAnswer => 'Desliza hacia arriba para responder';

  @override
  String get call_switch => 'Cambiar';

  @override
  String get call_switchCameraFailed => 'No se puede cambiar de cámara';

  @override
  String get call_switchToVideoToShare =>
      'Cambia a videollamada para compartir tu pantalla';

  @override
  String get call_tabContacts => 'Contactos';

  @override
  String get call_tabGroups => 'Grupos';

  @override
  String get call_tabRecent => 'Recientes';

  @override
  String get call_tapNotifyToInvite => 'Toca notificar para invitar';

  @override
  String get call_tapStartBroadcastHint =>
      'Toca Iniciar transmisión si aparece el mensaje del sistema';

  @override
  String get call_title => 'Llamada';

  @override
  String call_todayAt(String value) {
    return 'Hoy, $value';
  }

  @override
  String get call_total => 'Total';

  @override
  String get call_turnOnVideo => 'Activa tu video';

  @override
  String get call_unableToCallContact => 'No se puede llamar a este contacto';

  @override
  String get call_unableToMakeCall => 'No se puede realizar la llamada';

  @override
  String get call_unableToOpenChat =>
      'No se puede abrir el chat con este contacto';

  @override
  String get call_unableToShareScreen => 'No se puede compartir la pantalla';

  @override
  String get call_unavailableTitle => 'Llamada no disponible';

  @override
  String get call_unexpectedResponse => 'Respuesta inesperada del servidor';

  @override
  String get call_unknown => 'Desconocido';

  @override
  String get call_unknownGroup => 'Grupo desconocido';

  @override
  String get call_unknownUser => 'Usuario desconocido';

  @override
  String get call_unmute => 'Activar sonido';

  @override
  String get call_unselectAll => 'Deseleccionar todo';

  @override
  String get call_user => 'Usuario';

  @override
  String get call_userNotFound => 'Usuario no encontrado';

  @override
  String call_userWithId(String id) {
    return 'Usuario $id';
  }

  @override
  String get call_video => 'Video';

  @override
  String get call_waitingForBroadcast => 'Esperando inicio de transmisión';

  @override
  String get call_waitingForBroadcastMessage =>
      'Toca \"Iniciar transmisión\" en el cuadro de diálogo del sistema para compartir tu pantalla.';

  @override
  String get call_waitingForMedia => 'Esperando transmisión de medios...';

  @override
  String get call_wired => 'Con cable';

  @override
  String get call_yesDelete => 'Sí, eliminar';

  @override
  String call_yesterdayAt(String value) {
    return 'Ayer, $value';
  }

  @override
  String get call_youAreSharing => 'Estás compartiendo';

  @override
  String get call_youAreSharingScreen => 'Estás compartiendo tu pantalla';

  @override
  String get call_zoomIn => 'Acercar';

  @override
  String get call_zoomOut => 'Alejar';

  @override
  String get chatList_allChats => 'Todos los chats';

  @override
  String get chatList_allContacts => 'Todos los contactos';

  @override
  String get chatList_allowAccess => 'Permitir acceso';

  @override
  String get chatList_allowContactsBody =>
      'Necesitamos acceso a tus contactos para mostrar quién está en FG Tracker y permitirte iniciar un chat o enviar una invitación.';

  @override
  String get chatList_allowContactsTitle => 'Permitir acceso a contactos';

  @override
  String get chatList_archiveChat => 'Archivar chat';

  @override
  String get chatList_archived => 'Archivado';

  @override
  String get chatList_archivedChatsSubtitle => 'Tus conversaciones ocultas';

  @override
  String get chatList_archivedChatsTitle => 'Chats archivados';

  @override
  String chatList_archivedCount(int count) {
    return 'Archivados ($count)';
  }

  @override
  String get chatList_block => 'Bloquear';

  @override
  String get chatList_blockFailed => 'No se puede bloquear al usuario';

  @override
  String chatList_blockName(String name) {
    return 'Bloquear a $name';
  }

  @override
  String get chatList_blockUser => 'Bloquear usuario';

  @override
  String get chatList_blockUserConfirm =>
      '¿Seguro que deseas bloquear a este usuario?';

  @override
  String get chatList_blocked => 'Bloqueado';

  @override
  String get chatList_chatCleared => 'Chat vaciado';

  @override
  String get chatList_chooseContactToShare =>
      'Elige un contacto para compartir en tu chat.';

  @override
  String get chatList_clear => 'Vaciar';

  @override
  String get chatList_clearChat => 'Vaciar chat';

  @override
  String get chatList_clearChatConfirm =>
      '¿Eliminar todos los mensajes con este usuario?';

  @override
  String get chatList_clearChatFailed => 'No se puede vaciar el chat';

  @override
  String get chatList_clearSearch => 'Borrar búsqueda';

  @override
  String get chatList_contactAndInfo => 'Contacto e información';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'Se necesita permiso de contactos para compartir un contacto en el chat.';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contactos',
      one: '1 contacto',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return 'Error al cargar contactos: $error';
  }

  @override
  String get chatList_contactsPermissionNeeded =>
      'Se necesita permiso para contactos';

  @override
  String get chatList_contactsWillAppear =>
      'Tus contactos aparecerán aquí cuando estén disponibles.';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => 'Desactivado';

  @override
  String get chatList_defaultAbout => '¡Hola! Estoy usando FG Tracker';

  @override
  String get chatList_deleteChat => 'Eliminar chat';

  @override
  String get chatList_deleteChatConfirm =>
      '¿Eliminar esta conversación de tu lista de chats?';

  @override
  String get chatList_forwardFailed => 'No se puede reenviar el mensaje.';

  @override
  String get chatList_forwardListLoadFailed =>
      'No se puede cargar la lista de reenvío.';

  @override
  String get chatList_forwardTo => 'Reenviar a...';

  @override
  String get chatList_forwarded => 'Reenviado';

  @override
  String get chatList_groupChatFallback => 'Chat grupal';

  @override
  String get chatList_groupDeactivatedBanner =>
      'Este grupo ha sido desactivado por el administrador';

  @override
  String get chatList_groupFallback => 'Grupo';

  @override
  String get chatList_howToAllow => 'Cómo permitir';

  @override
  String get chatList_howToAllowStep1 =>
      'Toca \"Permitir acceso\" para abrir Ajustes';

  @override
  String get chatList_howToAllowStep2 => 'Toca en \"Permisos\"';

  @override
  String get chatList_howToAllowStep3 => 'Selecciona \"Contactos\"';

  @override
  String get chatList_howToAllowStep4 =>
      'Elige \"Permitir\" y regresa a la app';

  @override
  String get chatList_invite => 'Invitar';

  @override
  String get chatList_inviteChooseHow =>
      'Elige cómo deseas enviar la invitación';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return '¡Hola $name! Únete a mí en FG Tracker.\n\nDescargar para Android: $playStoreLink\n\nDescargar para iOS: $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'Más aplicaciones';

  @override
  String chatList_inviteName(String name) {
    return 'Invitar a $name';
  }

  @override
  String get chatList_inviteViaMessage => 'Mensaje';

  @override
  String get chatList_locationHidden => 'Ubicación oculta';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1, $name2 +$count están escribiendo...';
  }

  @override
  String get chatList_markAsRead => 'Marcar como leído';

  @override
  String get chatList_markAsUnread => 'Marcar como no leído';

  @override
  String get chatList_mediaLinksDocs => 'Archivos, enlaces y docs';

  @override
  String get chatList_memberFallback => 'Miembro';

  @override
  String get chatList_messageDeleted => 'Este mensaje fue eliminado';

  @override
  String get chatList_messageForwarded => 'Mensaje reenviado';

  @override
  String get chatList_messageIdMissing => 'Falta el ID del mensaje.';

  @override
  String chatList_minutesShort(int count) {
    return '$count min';
  }

  @override
  String get chatList_mute1Hour => '1 hora';

  @override
  String get chatList_mute8Hours => '8 horas';

  @override
  String get chatList_muteAlways => 'Hasta que lo vuelva a activar';

  @override
  String get chatList_muteSubtitle =>
      'Elige cuánto tiempo deseas pausar las notificaciones.';

  @override
  String get chatList_muteTitle => 'Silenciar notificaciones';

  @override
  String get chatList_muteUntilTomorrow => 'Hasta mañana';

  @override
  String get chatList_newChat => 'Nuevo chat';

  @override
  String get chatList_newChatSectionContacts =>
      'Iniciar nuevo chat (Contactos)';

  @override
  String get chatList_newChatSectionInvite =>
      'Invitar al chat (Contactos no registrados)';

  @override
  String get chatList_noArchivedChats => 'No hay chats archivados';

  @override
  String get chatList_noArchivedChatsSubtitle =>
      'Las conversaciones archivadas aparecerán aquí.';

  @override
  String get chatList_noChatsFound => 'No se encontraron chats';

  @override
  String get chatList_noChatsSubtitle => 'Tus chats privados aparecerán aquí.';

  @override
  String get chatList_noContactsAvailable => 'No hay contactos disponibles';

  @override
  String get chatList_noContactsFound => 'No se encontraron contactos';

  @override
  String get chatList_noGroupsAvailable => 'No hay grupos disponibles';

  @override
  String get chatList_noGroupsFound => 'No se encontraron grupos';

  @override
  String get chatList_noMediaYet => 'Aún no se han compartido archivos';

  @override
  String get chatList_noMessagesYet => 'Aún no hay mensajes';

  @override
  String get chatList_noPeopleOrGroups => 'No se encontraron personas o grupos';

  @override
  String chatList_noResultsFor(String query) {
    return 'No se encontraron resultados para \"$query\"';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return 'No hay resultados para \'$query\'';
  }

  @override
  String get chatList_noTrackerContacts =>
      'No se encontraron contactos activos en el rastreador';

  @override
  String get chatList_offlineNotSaved =>
      'Estás desconectado. El cambio no se guardó, inténtalo de nuevo.';

  @override
  String chatList_oneTyping(String name) {
    return '$name está escribiendo...';
  }

  @override
  String get chatList_openSettings => 'Abrir Ajustes';

  @override
  String get chatList_pinChat => 'Fijar chat';

  @override
  String get chatList_pinnedChats => 'Chats fijados';

  @override
  String get chatList_pleaseTryAgain => 'Por favor, inténtalo de nuevo.';

  @override
  String get chatList_profileCall => 'Llamar';

  @override
  String get chatList_profileMessage => 'Mensaje';

  @override
  String get chatList_profileNotFound => 'Detalles del perfil no encontrados';

  @override
  String get chatList_profileVideoCall => 'Videollamada';

  @override
  String get chatList_quickCommSubtitle =>
      'Conéctate con tu equipo al instante';

  @override
  String get chatList_quickCommTitle => 'Comunicación rápida';

  @override
  String get chatList_quickGroups => 'Grupos';

  @override
  String get chatList_quickGroupsSub => 'Chats de equipo';

  @override
  String get chatList_quickSafeZone => 'Zona segura';

  @override
  String get chatList_quickSafeZoneSub => 'Seguridad y alertas';

  @override
  String get chatList_quickTracking => 'Rastreo';

  @override
  String get chatList_quickTrackingSub => 'Ubicación en vivo';

  @override
  String get chatList_quickWalkie => 'Walkie';

  @override
  String get chatList_quickWalkieSub => 'Pulsar para hablar';

  @override
  String get chatList_searchByNameOrNumber => 'Buscar por nombre o número...';

  @override
  String get chatList_searchGroupsHint => 'Buscar grupos...';

  @override
  String get chatList_searchHint => 'Buscar chats o mensajes...';

  @override
  String get chatList_searchHintShort => 'Buscar...';

  @override
  String get chatList_searchNameOrNumber => 'Buscar nombre o número';

  @override
  String get chatList_searchResults => 'Resultados de búsqueda';

  @override
  String get chatList_sectionGroups => 'GRUPOS';

  @override
  String get chatList_sectionMyContacts => 'MIS CONTACTOS';

  @override
  String get chatList_sectionOtherContacts => 'OTROS CONTACTOS';

  @override
  String get chatList_sectionRecentChats => 'CHATS RECIENTES';

  @override
  String get chatList_selectDestination => 'Seleccionar destino';

  @override
  String get chatList_selectDestinationMsg =>
      'Por favor, selecciona al menos una persona o grupo.';

  @override
  String chatList_selectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get chatList_shareContactTitle => 'Compartir contacto';

  @override
  String chatList_shareMenuFailed(String error) {
    return 'No se pudo abrir el menú para compartir: $error';
  }

  @override
  String get chatList_smsOpenFailed => 'No se pudo abrir la app de mensajería';

  @override
  String get chatList_someone => 'Alguien';

  @override
  String get chatList_startConversation => 'Iniciar una conversación';

  @override
  String get chatList_subtitle => 'Mantente conectado con tu equipo';

  @override
  String get chatList_telegramOpenFailed => 'No se pudo abrir Telegram';

  @override
  String get chatList_title => 'Chat';

  @override
  String get chatList_tryAnotherNameOrNumber =>
      'Prueba con otro nombre o número de teléfono.';

  @override
  String get chatList_tryDifferentSearch =>
      'Intenta buscar con otro nombre o mensaje.';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1, $name2 están escribiendo...';
  }

  @override
  String get chatList_typing => 'escribiendo...';

  @override
  String get chatList_unableToCallContact =>
      'No se puede llamar a este contacto';

  @override
  String get chatList_unableToLoadContacts =>
      'No se pueden cargar los contactos';

  @override
  String get chatList_unarchiveChat => 'Desarchivar chat';

  @override
  String get chatList_unblock => 'Desbloquear';

  @override
  String get chatList_unblockFailed => 'No se puede desbloquear al usuario';

  @override
  String chatList_unblockName(String name) {
    return 'Desbloquear a $name';
  }

  @override
  String get chatList_unblockUser => 'Desbloquear usuario';

  @override
  String get chatList_unblockUserConfirm =>
      '¿Seguro que deseas desbloquear a este usuario?';

  @override
  String get chatList_unknown => 'Desconocido';

  @override
  String get chatList_unknownUser => 'Usuario desconocido';

  @override
  String get chatList_unnamedContact => 'Contacto sin nombre';

  @override
  String get chatList_unpinChat => 'Desfijar chat';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes no leídos',
      one: '1 mensaje no leído',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed =>
      'No se pudo actualizar el chat. Inténtalo de nuevo.';

  @override
  String get chatList_userFallback => 'Usuario';

  @override
  String get chatList_userNotFound => 'Usuario no encontrado';

  @override
  String get chatList_viewArchived => 'Ver conversaciones archivadas';

  @override
  String get chatList_whatsappOpenFailed => 'No se pudo abrir WhatsApp';

  @override
  String get chatList_yourContacts => 'Tus contactos';

  @override
  String get chat_addCaptionHint => 'Añadir un comentario...';

  @override
  String get chat_audioUnavailable => 'Este audio ya no está disponible';

  @override
  String get chat_blockFailed => 'No se puede bloquear al usuario';

  @override
  String get chat_call => 'Llamar';

  @override
  String get chat_cameraAccessNeeded =>
      'Se necesita acceso a la cámara para tomar fotos y videos en el chat.';

  @override
  String get chat_cameraModePhoto => 'FOTO';

  @override
  String get chat_cameraModePortrait => 'RETRATO';

  @override
  String get chat_cameraModeVideo => 'VIDEO';

  @override
  String get chat_cameraStartFailed => 'No se pudo iniciar la cámara.';

  @override
  String get chat_cantMessageUser => 'No puedes enviar mensajes a este usuario';

  @override
  String get chat_chatActionsSubtitle => 'Administra tu chat';

  @override
  String get chat_chatActionsTitle => 'Acciones del chat';

  @override
  String get chat_clear => 'Vaciar';

  @override
  String get chat_clearChat => 'Vaciar chat';

  @override
  String get chat_clearChatConfirm =>
      '¿Vaciar todos los mensajes de este chat?';

  @override
  String get chat_clearGroupChatFailed => 'Error al vaciar el chat grupal';

  @override
  String get chat_contactBlockedYou => 'Este contacto te ha bloqueado';

  @override
  String get chat_contactUnavailable => 'Contacto no disponible';

  @override
  String get chat_deleteForEveryone => 'Eliminar para todos';

  @override
  String get chat_deleteForEveryoneConfirm =>
      '¿Seguro que deseas eliminar este mensaje para todos?';

  @override
  String get chat_deleteForMe => 'Eliminar para mí';

  @override
  String get chat_deleteForMeConfirm =>
      '¿Seguro que deseas eliminar este mensaje para ti?';

  @override
  String get chat_deleteMember => 'Eliminar miembro';

  @override
  String get chat_deleteMemberSubtitle => 'Eliminar a un miembro de este grupo';

  @override
  String get chat_documentAvailable => 'El documento está disponible';

  @override
  String get chat_documentDownloadFailed =>
      'No se pudo descargar el documento.';

  @override
  String get chat_documentOpenFailed =>
      'No se pudo abrir el documento. Inténtalo de nuevo.';

  @override
  String get chat_documentPreviewUnavailable =>
      'La vista previa no está disponible para este tipo de archivo. Abre el documento con la aplicación instalada.';

  @override
  String get chat_documentUnavailable => 'Este documento ya no está disponible';

  @override
  String get chat_downloadFailed => 'Error de descarga';

  @override
  String get chat_edited => 'editado';

  @override
  String get chat_emptySubtitle =>
      'Saluda con un 👋 para iniciar la conversación';

  @override
  String get chat_emptyTitle => 'Aún no hay mensajes aquí';

  @override
  String get chat_fetchingLocation => 'Obteniendo ubicación...';

  @override
  String get chat_finishVoiceRecordingFirst =>
      'Termina o cancela primero la grabación de voz';

  @override
  String get chat_forwarded => 'Reenviado';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current de $total';
  }

  @override
  String get chat_groupActionsSubtitle => 'Administra los ajustes de tu grupo';

  @override
  String get chat_groupActionsTitle => 'Acciones de grupo';

  @override
  String get chat_groupChatCleared => 'Chat grupal vaciado con éxito';

  @override
  String get chat_groupDeactivated =>
      'Este grupo ha sido desactivado por el administrador';

  @override
  String get chat_imageFailed => 'Error en la imagen';

  @override
  String get chat_listen => 'Escuchar';

  @override
  String get chat_listenEnglish => 'Escuchar (Inglés)';

  @override
  String get chat_listenHindi => 'Escuchar (Hindi)';

  @override
  String get chat_loadFailedSubtitle =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get chat_loadFailedTitle => 'No se pudieron cargar los mensajes';

  @override
  String get chat_locationFetchFailed =>
      'No se pudo obtener tu ubicación. Inténtalo de nuevo.';

  @override
  String get chat_locationPermissionNeeded =>
      'Se necesita permiso de ubicación para compartir tu ubicación.';

  @override
  String get chat_locationPermissionOff =>
      'El permiso de ubicación está desactivado para esta app. Actívalo en Ajustes para compartir tu ubicación.';

  @override
  String get chat_locationServicesOff =>
      'Activa los servicios de ubicación para compartir tu ubicación.';

  @override
  String get chat_locationUnavailable => 'Ubicación no disponible';

  @override
  String get chat_mediaMissing => 'Falta el archivo multimedia';

  @override
  String get chat_mediaMissingToast =>
      'Falta el archivo multimedia. Este archivo ya no está disponible.';

  @override
  String get chat_mediaUnavailable =>
      'Este archivo multimedia ya no está disponible';

  @override
  String get chat_menuForward => 'Reenviar';

  @override
  String get chat_menuMessageInfo => 'Información del mensaje';

  @override
  String get chat_menuPin => 'Fijar mensaje';

  @override
  String get chat_menuReply => 'Responder';

  @override
  String get chat_menuUnpin => 'Desfijar mensaje';

  @override
  String get chat_messageCopied => 'Mensaje copiado';

  @override
  String get chat_messageDeleted => 'Este mensaje fue eliminado';

  @override
  String get chat_messageNotAvailable => 'Mensaje no disponible';

  @override
  String get chat_messageNotSent => 'Mensaje no enviado. Inténtalo de nuevo.';

  @override
  String get chat_noCameraFound =>
      'No se encontró ninguna cámara en este dispositivo.';

  @override
  String get chat_noLongerMember => 'Ya no eres miembro de este grupo';

  @override
  String get chat_noMediaAvailable => 'No hay archivos multimedia disponibles';

  @override
  String get chat_offlineNotSent => 'Estás desconectado. Mensaje no enviado.';

  @override
  String get chat_openDocument => 'Abrir documento';

  @override
  String get chat_openInGoogleMaps => 'Abrir en Google Maps';

  @override
  String get chat_openSettings => 'Abrir Ajustes';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'Esta foto ya no está disponible';

  @override
  String get chat_previewAttendancePoll => 'Encuesta de asistencia';

  @override
  String get chat_previewAudio => 'Audio';

  @override
  String get chat_previewContact => 'Contacto';

  @override
  String get chat_previewDocument => 'Documento';

  @override
  String get chat_previewLocation => 'Ubicación';

  @override
  String get chat_previewMessage => 'Mensaje';

  @override
  String get chat_previewNewMessage => 'Nuevo mensaje';

  @override
  String get chat_previewOwnDeleted => 'Eliminaste este mensaje';

  @override
  String get chat_previewPhoto => 'Foto';

  @override
  String chat_previewPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewPoll => 'Encuesta';

  @override
  String get chat_previewSticker => 'Sticker';

  @override
  String get chat_previewVideo => 'Video';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => 'Mensaje de voz';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return 'Mensaje de voz ($duration)';
  }

  @override
  String get chat_recordingFailed => 'Error en la grabación';

  @override
  String get chat_removeMember => 'Eliminar miembro';

  @override
  String get chat_removeMemberConfirm =>
      '¿Seguro que deseas eliminar a este miembro del grupo?';

  @override
  String get chat_replyHint => 'Responder al mensaje...';

  @override
  String get chat_searchMessages => 'Buscar mensajes';

  @override
  String get chat_searchMessagesHint => 'Buscar mensajes...';

  @override
  String get chat_searchMessagesSubtitle => 'Buscar mensajes por palabra clave';

  @override
  String get chat_sendLocation => 'Enviar ubicación';

  @override
  String get chat_shareLocation => 'Compartir ubicación';

  @override
  String get chat_shareVideoFailed => 'No se puede compartir el video';

  @override
  String get chat_sharedFromApp => 'Compartido desde FG Tracker';

  @override
  String get chat_sharedLocation => 'Ubicación compartida';

  @override
  String get chat_showOriginal => 'Mostrar original';

  @override
  String get chat_someone => 'Alguien';

  @override
  String get chat_statusLabel => 'Estado';

  @override
  String get chat_statusUnavailable =>
      'Esta actualización de estado ya no está disponible';

  @override
  String get chat_stop => 'Detener';

  @override
  String get chat_stopEnglish => 'Detener (Inglés)';

  @override
  String get chat_stopHindi => 'Detener (Hindi)';

  @override
  String get chat_takePhotoFailed => 'Error al tomar la foto';

  @override
  String get chat_translatedToEnglish => 'Traducido al inglés';

  @override
  String get chat_translatedToHindi => 'Traducido al hindi';

  @override
  String get chat_translating => 'Traduciendo...';

  @override
  String get chat_tryAgain => 'Reintentar';

  @override
  String get chat_typeMessageHint => 'Escribe un mensaje...';

  @override
  String get chat_typing => 'escribiendo...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas están escribiendo...',
      one: '1 persona está escribiendo...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name está escribiendo...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1, $name2 están escribiendo...';
  }

  @override
  String get chat_unableToOpen => 'No se puede abrir';

  @override
  String get chat_unableToOpenGoogleMaps => 'No se puede abrir Google Maps';

  @override
  String get chat_unblock => 'Desbloquear';

  @override
  String get chat_unblockContact => 'Desbloquear contacto';

  @override
  String get chat_unblockContactConfirm =>
      '¿Seguro que deseas desbloquear a este contacto?';

  @override
  String get chat_unblockFailed => 'No se puede desbloquear al usuario';

  @override
  String get chat_unknown => 'Desconocido';

  @override
  String get chat_unknownLocation => 'Ubicación desconocida';

  @override
  String get chat_unsupportedMessage =>
      'Este mensaje no es compatible con esta versión de la aplicación';

  @override
  String get chat_updateGroup => 'Actualizar grupo';

  @override
  String get chat_updateGroupSubtitle => 'Cambiar los datos del grupo actual';

  @override
  String chat_uploadFileFailed(String path) {
    return 'Error al subir $path';
  }

  @override
  String get chat_userBlocked => 'Usuario bloqueado con éxito';

  @override
  String get chat_userUnblocked => 'Usuario desbloqueado con éxito';

  @override
  String get chat_videoDownloaded => 'Video descargado con éxito';

  @override
  String get chat_videoThumbnailFailed =>
      'Error al generar la miniatura del video';

  @override
  String get chat_videoUnavailable => 'Este video ya no está disponible';

  @override
  String get chat_videoUploadFailed => 'Error al subir el video';

  @override
  String get chat_voicePlayFailed => 'No se pudo reproducir el mensaje de voz';

  @override
  String get chat_voiceUploadFailed =>
      'Error al subir el mensaje de voz. Inténtalo de nuevo.';

  @override
  String get chat_youBlockedContact => 'Bloqueaste a este contacto';

  @override
  String get common_add => 'Añadir';

  @override
  String get common_allow => 'Permitir';

  @override
  String get common_back => 'Atrás';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_comingSoon => 'Próximamente';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_continue => 'Continuar';

  @override
  String get common_copied => 'Copiado';

  @override
  String get common_copy => 'Copiar';

  @override
  String common_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_dismiss => 'Descartar';

  @override
  String get common_done => 'Listo';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_error => 'Error';

  @override
  String get common_exit => 'Salir';

  @override
  String get common_gotIt => 'Entendido';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count horas',
      one: 'Hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'Ahora mismo';

  @override
  String common_lastSeen(String time) {
    return 'Última vez: $time';
  }

  @override
  String get common_loading => 'Cargando…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count min',
      one: 'Hace 1 min',
    );
    return '$_temp0';
  }

  @override
  String get common_next => 'Siguiente';

  @override
  String get common_no => 'No';

  @override
  String get common_noData => 'No se encontraron datos';

  @override
  String get common_noInternet => 'Sin conexión a internet';

  @override
  String get common_notNow => 'Ahora no';

  @override
  String get common_offline => 'Desconectado';

  @override
  String get common_ok => 'Aceptar';

  @override
  String get common_online => 'En línea';

  @override
  String get common_open => 'Abrir';

  @override
  String get common_permissionDenied => 'Permiso denegado';

  @override
  String get common_remove => 'Eliminar';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_send => 'Enviar';

  @override
  String get common_settings => 'Ajustes';

  @override
  String get common_share => 'Compartir';

  @override
  String get common_somethingWentWrong =>
      'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get common_submit => 'Enviar';

  @override
  String get common_success => 'Éxito';

  @override
  String get common_today => 'Hoy';

  @override
  String common_todayAt(String time) {
    return 'Hoy, $time';
  }

  @override
  String get common_tryAgain => 'Intentar de nuevo';

  @override
  String get common_viewAll => 'Ver todo';

  @override
  String get common_yes => 'Sí';

  @override
  String get common_yesterday => 'Ayer';

  @override
  String get common_you => 'Tú';

  @override
  String get dialog_allowLocationAccess => 'Permitir acceso a la ubicación';

  @override
  String get dialog_anErrorOccurred => '¡Ocurrió un error!';

  @override
  String get dialog_important => '¡Importante!';

  @override
  String get dialog_locationPermissionRequired =>
      'Permiso de ubicación requerido';

  @override
  String get dialog_locationPurposeBody =>
      'Para mejorar la eficiencia del servicio, nuestra aplicación solicita permiso para acceder a tu ubicación con el fin de guardarla. Esto permite a los miembros navegar con precisión hasta tu ubicación de trabajo.';

  @override
  String get dialog_locationSettingsAndroid =>
      'Sin acceso a la ubicación, no podremos detectar tu ubicación actual. Toca en \"Ajustes\", luego en \"Permisos\" y permite el acceso a la ubicación.';

  @override
  String get dialog_locationSettingsIos =>
      'Esta aplicación requiere acceso a tu ubicación para ofrecer servicios basados en la ubicación. Ve a \"Ajustes\" y activa los permisos de ubicación.';

  @override
  String get dialog_loggedInElsewhere =>
      'Has iniciado sesión desde otro dispositivo.';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      'Has iniciado sesión desde otro dispositivo. Por favor, inicia sesión de nuevo.';

  @override
  String get dialog_logoutConfirm => '¿Deseas cerrar sesión?';

  @override
  String get dialog_selectAllowAllTheTime =>
      'En la siguiente ventana emergente, selecciona\n\'Permitir siempre\'.';

  @override
  String get dialog_sessionExpiredTitle => 'Sesión caducada';

  @override
  String get editProfile_fullNameLabel => 'Nombre completo';

  @override
  String get editProfile_personalInfo => 'Información personal';

  @override
  String get editProfile_phoneLabel => 'Número de teléfono';

  @override
  String get editProfile_saveButton => 'Guardar cambios';

  @override
  String get editProfile_tapPhotoHint => 'Toca la foto para cambiarla';

  @override
  String get editProfile_title => 'Editar perfil';

  @override
  String get forceUpdate_currentInstalled => 'VERSIÓN INSTALADA';

  @override
  String get forceUpdate_defaultMessage =>
      'Hay una nueva versión de FG Tracker disponible. Por favor, actualiza para continuar.';

  @override
  String get forceUpdate_defaultTitle => 'Actualización requerida';

  @override
  String get forceUpdate_fallbackMessage =>
      'Hay una nueva versión de FG Tracker con mejoras críticas. Actualiza para continuar usando la aplicación.';

  @override
  String get forceUpdate_footer =>
      'Se requiere actualización para usar FG Tracker';

  @override
  String get forceUpdate_requiredVersion => 'VERSIÓN REQUERIDA';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return 'Actualizar en $storeName';
  }

  @override
  String get groupDialog_audioCall => 'Llamada de voz';

  @override
  String get groupDialog_audioCallSubtitle => 'Iniciar conversación de voz';

  @override
  String get groupDialog_call => 'Llamar';

  @override
  String get groupDialog_chat => 'Chat';

  @override
  String get groupDialog_codeEmpty => 'El código de grupo no puede estar vacío';

  @override
  String get groupDialog_codeLabel => 'Código del grupo';

  @override
  String get groupDialog_createButton => 'Crear grupo';

  @override
  String get groupDialog_createTitle => 'Crear nuevo grupo';

  @override
  String get groupDialog_descHint => 'Introduce la descripción del grupo';

  @override
  String get groupDialog_descLabel => 'Descripción del grupo (Opcional)';

  @override
  String groupDialog_distance(String distance) {
    return 'Distancia: $distance';
  }

  @override
  String get groupDialog_enterCodeManually =>
      'Introducir código de grupo manualmente';

  @override
  String get groupDialog_enterCodeTitle => 'Introduce el código del grupo';

  @override
  String get groupDialog_fillDetails => 'Rellena los datos a continuación';

  @override
  String get groupDialog_getDirections => 'Obtener indicaciones';

  @override
  String get groupDialog_join => 'Unirse al grupo';

  @override
  String groupDialog_lastSeen(String time) {
    return 'Última vez: $time';
  }

  @override
  String get groupDialog_locationHidden => 'Ubicación oculta';

  @override
  String get groupDialog_locationUnavailable => 'Ubicación no disponible';

  @override
  String get groupDialog_member => 'Miembro';

  @override
  String get groupDialog_memberInfo => 'Información del miembro';

  @override
  String get groupDialog_nameHint => 'Introduce el nombre del grupo';

  @override
  String get groupDialog_nameLabel => 'Nombre del grupo';

  @override
  String get groupDialog_noQrInImage =>
      'No se encontró código QR en la imagen seleccionada.';

  @override
  String get groupDialog_noValidQr => 'No se encontró ningún código QR válido.';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'Error al descodificar el QR de la galería: $error';
  }

  @override
  String get groupDialog_scanCamera => 'Escanear con la cámara';

  @override
  String get groupDialog_selectCallType => 'Seleccionar tipo de llamada';

  @override
  String get groupDialog_update => 'Actualizar';

  @override
  String get groupDialog_updateTitle => 'Actualizar grupo';

  @override
  String get groupDialog_uploadGallery => 'Subir desde la galería';

  @override
  String get groupDialog_videoCall => 'Videollamada';

  @override
  String get groupDialog_videoCallSubtitle => 'Iniciar conversación por video';

  @override
  String get groupDialog_yourLocation => 'Tu ubicación actual';

  @override
  String get groupInfo_active => 'Activo';

  @override
  String get groupInfo_admin => 'Admin';

  @override
  String get groupInfo_allGroups => 'Todos los grupos';

  @override
  String get groupInfo_allGroupsSubtitle =>
      'Mantente conectado con tus equipos';

  @override
  String get groupInfo_areYouSure => '¿Estás seguro?';

  @override
  String get groupInfo_audioCall => 'Llamada de voz';

  @override
  String get groupInfo_clearChatConfirm =>
      '¿Eliminar todos los mensajes de este dispositivo?';

  @override
  String get groupInfo_createdBy => 'Creado por';

  @override
  String get groupInfo_detailsNotFound => 'Detalles del grupo no encontrados';

  @override
  String get groupInfo_exitGroup => 'Salir del grupo';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return '¿Seguro que deseas salir de \"$groupName\"?';
  }

  @override
  String get groupInfo_exitGroupQuestion => '¿Deseas salir de este grupo?';

  @override
  String get groupInfo_group => 'Grupo';

  @override
  String get groupInfo_groupAdmin => 'Admin del grupo';

  @override
  String get groupInfo_groupCallFailed =>
      'No se pudo iniciar la llamada grupal. Inténtalo de nuevo.';

  @override
  String get groupInfo_groupCodeCopied => '¡Código de grupo copiado!';

  @override
  String get groupInfo_groupSettings => 'Ajustes del grupo';

  @override
  String get groupInfo_groupSettingsSubtitle =>
      'Edita la información, privacidad y más';

  @override
  String get groupInfo_inactive => 'Inactivo';

  @override
  String get groupInfo_inviteCopied => 'Texto de invitación copiado';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'Únete a mi grupo \"$groupName\" en FG Tracker';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'Únete a mi grupo \"$groupName\" en FG Tracker. Código: $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'Invitar mediante enlace';

  @override
  String get groupInfo_mediaLinksDocs => 'Archivos, enlaces y docs';

  @override
  String get groupInfo_member => 'Miembro';

  @override
  String get groupInfo_members => 'Miembros';

  @override
  String get groupInfo_messageAction => 'Mensaje';

  @override
  String groupInfo_nameYou(String name) {
    return '$name (Tú)';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return 'No se encontró ningún grupo para \'$query\'';
  }

  @override
  String get groupInfo_noGroupsYet =>
      'Aún no te has unido ni has creado ningún grupo.\n¡Empieza a explorar ahora!';

  @override
  String get groupInfo_noMediaYet => 'Aún no se han compartido archivos';

  @override
  String get groupInfo_removeFromGroup => 'Eliminar del grupo';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return '¿Seguro que deseas eliminar a $name del grupo?';
  }

  @override
  String get groupInfo_searchGroupsHint => 'Buscar grupos...';

  @override
  String get groupInfo_showLess => 'Mostrar menos';

  @override
  String get groupInfo_teamCode => 'Código de equipo';

  @override
  String groupInfo_totalCount(int count) {
    return '$count en total';
  }

  @override
  String get groupInfo_unknownGroup => 'Grupo desconocido';

  @override
  String get groupInfo_unnamedGroup => 'Grupo sin nombre';

  @override
  String get groupInfo_videoCall => 'Videollamada';

  @override
  String get groupInfo_viewAllMembers => 'Ver todos los miembros';

  @override
  String get group_activatedSuccess => 'Grupo activado con éxito';

  @override
  String get group_addMember => 'Añadir miembro';

  @override
  String get group_alignQr => 'Alinea el QR dentro del marco';

  @override
  String get group_areYouSure => '¿Estás seguro?';

  @override
  String get group_chatWithMembers => 'Chatea con miembros del grupo';

  @override
  String get group_codeCopied => '¡Código del grupo copiado!';

  @override
  String group_codeShareInfo(String code) {
    return 'Código de grupo: $code — compártelo para que otros se unan';
  }

  @override
  String get group_copyCode => 'Copiar código';

  @override
  String get group_created => 'Creado';

  @override
  String get group_createdJustNow => 'Creado recién';

  @override
  String get group_deactivatedSuccess => 'Grupo desactivado con éxito';

  @override
  String get group_defaultName => 'Grupo';

  @override
  String get group_deleteGroup => 'Eliminar grupo';

  @override
  String get group_deleteGroupConfirm => '¿Deseas eliminar este grupo?';

  @override
  String get group_deletedSuccess => 'Grupo eliminado con éxito';

  @override
  String get group_download => 'Descargar';

  @override
  String get group_downloadChannelDescription =>
      'Notifica cuando se descarga el código QR';

  @override
  String get group_downloadChannelName => 'Notificaciones de descarga';

  @override
  String get group_enableLocationToJoin =>
      'Por favor, activa los servicios de ubicación para unirte al grupo.';

  @override
  String get group_exitGroup => 'Salir del grupo';

  @override
  String get group_exitGroupConfirm => '¿Deseas salir de este grupo?';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return '¿Estás seguro de que quieres salir de \"$groupName\"? Necesitarás el código para volver a unirte.';
  }

  @override
  String get group_exitedSuccess => 'Saliste del grupo con éxito';

  @override
  String get group_goToGroups => 'Ir a Grupos →';

  @override
  String get group_groupMessage => 'Mensaje grupal';

  @override
  String get group_invalidResponseFormat => 'Formato inválido';

  @override
  String get group_joinedJustNow => 'Unido recién';

  @override
  String get group_joinedRecently => 'Reciente';

  @override
  String get group_leftJustNow => 'Salió recién';

  @override
  String get group_locationNoLongerShared =>
      'Tu ubicación ya no se comparte con este grupo';

  @override
  String get group_locationPermissionToJoin =>
      'Se requiere permiso de ubicación para unirse a un grupo.';

  @override
  String get group_locationShared => 'Tu ubicación se comparte con este grupo';

  @override
  String get group_memberFallbackName => 'Miembro';

  @override
  String group_membersMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros · $when',
      one: '1 miembro · $when',
    );
    return '$_temp0';
  }

  @override
  String get group_noContactsFound => 'No se encontraron contactos';

  @override
  String get group_noGroupCode => 'No hay código de grupo disponible';

  @override
  String get group_noNewMessages =>
      'No recibirás nuevos mensajes de este grupo';

  @override
  String get group_noNumber => 'Sin número';

  @override
  String get group_openGroup => 'Abrir grupo →';

  @override
  String get group_other => 'Otro';

  @override
  String get group_qrSavedBody => 'Toca para abrir tu código QR';

  @override
  String get group_qrSavedTitle => 'Código QR guardado';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 Código de grupo: $groupCode\n\nÚnete a mi grupo al instante usando el código QR o el código de arriba.\n\n📲 Descarga la app para mantenerte conectado:\n$appLink';
  }

  @override
  String get group_scanToJoin => 'Escanea este código QR para unirte al grupo';

  @override
  String get group_searchMemberHint => 'Buscar miembro...';

  @override
  String get group_shareCodeInfo =>
      'Comparte el código de grupo para que otros se unan';

  @override
  String get group_shareQr => 'Compartir QR';

  @override
  String get group_shareQrToInvite =>
      'Comparte el código QR para invitar miembros';

  @override
  String get group_sheetCreatedSubtitle =>
      'Tu grupo está listo. Comparte el código para que se unan.';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name, tu grupo está listo. Comparte el código para que se unan.';
  }

  @override
  String get group_sheetCreatedTitle => '¡Grupo creado!';

  @override
  String get group_sheetJoinedSubtitle =>
      'Bienvenido, ahora eres miembro de este grupo.';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return 'Bienvenido/a $name, ahora eres miembro de este grupo.';
  }

  @override
  String get group_sheetJoinedTitle => '¡Te uniste con éxito!';

  @override
  String get group_sheetLeftSubtitle => 'Ya no eres miembro de este grupo.';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name, ya no eres miembro de este grupo.';
  }

  @override
  String get group_sheetLeftTitle => 'Saliste del grupo';

  @override
  String get group_showQrCode => 'Mostrar código QR';

  @override
  String get group_startConversation =>
      'Siéntete libre de iniciar una conversación';

  @override
  String get group_statusUpdateFailed =>
      'Error al actualizar el estado del grupo';

  @override
  String get group_teamCode => 'Código de equipo';

  @override
  String get group_teamCodeLabel => 'Código de equipo: ';

  @override
  String get group_track => 'Rastrear';

  @override
  String get group_unnamedMember => 'Miembro sin nombre';

  @override
  String get group_unnamedTrip => 'Viaje sin nombre';

  @override
  String get group_updateGroupConfirm =>
      '¿Estás seguro de que deseas actualizar los detalles del grupo?';

  @override
  String get group_updateGroupTitle => 'Actualizar grupo';

  @override
  String get group_youAreAdmin => 'Eres el administrador de este grupo';

  @override
  String get home_actionAllContacts => 'Todos los contactos';

  @override
  String get home_actionAudioVideoCall => 'Llamada de audio/video';

  @override
  String get home_actionChatting => 'Chat';

  @override
  String get home_actionSafeZone => 'Zona segura';

  @override
  String get home_actionTracking => 'Rastreo';

  @override
  String get home_actionWalkieTalkie => 'Walkie-talkie';

  @override
  String get home_active => 'Activo';

  @override
  String get home_activeSessions => 'Sesiones activas';

  @override
  String home_activeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones activas',
      one: '1 sesión activa',
    );
    return '$_temp0';
  }

  @override
  String get home_allMembers => 'Todos los miembros';

  @override
  String get home_createGroup => 'Crear grupo';

  @override
  String get home_createGroupSubtitle => 'Crear un nuevo grupo';

  @override
  String get home_goodToSeeYou => '¡Qué bueno verte de nuevo! 👋';

  @override
  String home_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
    );
    return '$_temp0';
  }

  @override
  String home_helloName(String name) {
    return 'Hola $name';
  }

  @override
  String get home_inactive => 'Inactivo';

  @override
  String get home_joinGroup => 'Unirse al grupo';

  @override
  String get home_joinGroupSubtitle => 'Unirse a un grupo existente';

  @override
  String home_lastSeen(String time) {
    return 'Visto por última vez $time';
  }

  @override
  String get home_newThisMonth => 'Nuevos este mes';

  @override
  String get home_noActivePrivateSessions => 'No hay sesiones privadas activas';

  @override
  String get home_noGroupsAvailable => 'No hay grupos disponibles';

  @override
  String get home_noGroupsFound => 'No se encontraron grupos';

  @override
  String get home_noMembersFound => 'No se encontraron miembros';

  @override
  String home_noMembersMatch(String query) {
    return 'Ningún miembro coincide con \'$query\'';
  }

  @override
  String get home_noMembersOnline => 'No hay miembros en línea actualmente';

  @override
  String get home_noNameGroup => 'Grupo sin nombre';

  @override
  String get home_noRecentlyActiveMembers =>
      'No hay miembros activos recientemente';

  @override
  String get home_onlineNow => 'En línea ahora';

  @override
  String get home_peopleOnline => 'Personas en línea';

  @override
  String get home_peopleOnlineSubtitle =>
      'Estos miembros están activos en la aplicación ahora y disponibles.';

  @override
  String get home_privateMode => 'Modo privado';

  @override
  String get home_privateModeIsOn => 'El modo privado está activado';

  @override
  String get home_privateModeOffHint =>
      'Cuando el modo privado está desactivado, otros pueden ver tu ubicación.';

  @override
  String get home_privateModeOnHint =>
      'Cuando el modo privado está activado, otros no pueden ver tu ubicación.';

  @override
  String get home_quickActionsSubtitle =>
      'Todo lo que necesitas a un solo toque.';

  @override
  String get home_quickActionsTitle => 'Acciones rápidas';

  @override
  String get home_recentlyOnline => 'En línea recientemente';

  @override
  String get home_searchGroupsHint => 'Buscar grupos...';

  @override
  String get home_searchMembersHint => 'Buscar miembros...';

  @override
  String get home_showLess => 'Mostrar menos';

  @override
  String get home_sortNameAsc => 'Ordenar: Nombre (A-Z)';

  @override
  String get home_sortNameDesc => 'Ordenar: Nombre (Z-A)';

  @override
  String home_startedAt(String time) {
    return 'Iniciado a las $time';
  }

  @override
  String get home_statGroups => 'Grupos';

  @override
  String get home_statMembers => 'Miembros';

  @override
  String get home_statNow => 'Ahora';

  @override
  String get home_statTotal => 'Total';

  @override
  String get home_totalMembers => 'Miembros totales';

  @override
  String home_totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros en total',
      one: '1 miembro en total',
    );
    return '$_temp0';
  }

  @override
  String get home_unableToFetchGroups => 'No se pudieron obtener los grupos';

  @override
  String get home_unknownMember => 'Miembro desconocido';

  @override
  String get home_upgradeSubtitle =>
      'Desbloquea funciones avanzadas para tu equipo';

  @override
  String get home_upgradeToPremium => 'Mejorar a Premium';

  @override
  String get home_viewPlans => 'Ver planes';

  @override
  String get home_walkieExpired => 'Vencido';

  @override
  String get home_walkieOneHourFree => '1 h gratis';

  @override
  String get home_walkieRenew => 'Renovar';

  @override
  String get home_walkieSubscribed => 'Suscrito';

  @override
  String get home_youAreInvisible => 'Estás invisible';

  @override
  String get home_youAreVisible => 'Estás visible';

  @override
  String get http_networkError => 'Ocurrió un error. ¡Inténtalo de nuevo!';

  @override
  String get http_sessionExpired =>
      'Sesión caducada. Por favor, inicia sesión de nuevo.';

  @override
  String get http_unexpectedError =>
      'Ocurrió un error inesperado. Inténtalo de nuevo.';

  @override
  String get imagePicker_camera => 'Cámara';

  @override
  String get imagePicker_cancel => 'Cancelar';

  @override
  String get imagePicker_cropTitle => 'Recortar imagen';

  @override
  String get imagePicker_gallery => 'Galería';

  @override
  String get imagePicker_title => 'Elige una opción';

  @override
  String get intro_realTimeTrackingSubtitle =>
      'Observa la ubicación en vivo de amigos, familiares o miembros del equipo en el mapa al instante.';

  @override
  String get intro_realTimeTrackingTitle => 'Rastreo en tiempo real';

  @override
  String get intro_secureSubtitle =>
      'Comparte tu ubicación en vivo con\ncontactos seleccionados de forma segura\ny privada.';

  @override
  String get intro_secureTitle => 'Seguro y fácil';

  @override
  String get intro_skip => 'Omitir';

  @override
  String get intro_walkieSubtitle =>
      'Sin señal, sin problema. Mantente\nconectado donde sea.';

  @override
  String get intro_walkieTitle => 'Función de\nwalkie-talkie';

  @override
  String login_dataSecure(String percent) {
    return 'Tus datos están $percent seguros';
  }

  @override
  String get login_enterMobileNumber => 'Introduce el número de móvil';

  @override
  String get media_cannotOpen => 'No se puede abrir';

  @override
  String get media_documentNotFound => 'Documento no encontrado';

  @override
  String get media_invalidLink => 'Enlace no válido';

  @override
  String get media_noDocuments => 'No se encontraron documentos';

  @override
  String get media_noLinks => 'No se encontraron enlaces';

  @override
  String get media_noMedia => 'No se encontraron archivos multimedia';

  @override
  String get media_tabDocs => 'Documentos';

  @override
  String media_tabDocsCount(int count) {
    return 'Docs ($count)';
  }

  @override
  String get media_tabLinks => 'Enlaces';

  @override
  String media_tabLinksCount(int count) {
    return 'Enlaces ($count)';
  }

  @override
  String get media_tabMedia => 'Archivos';

  @override
  String media_tabMediaCount(int count) {
    return 'Archivos ($count)';
  }

  @override
  String get media_title => 'Archivos, enlaces y docs';

  @override
  String get media_videoNotFound => 'Video no encontrado';

  @override
  String get menu_contactUsSubtitle => 'Conoce más sobre nosotros';

  @override
  String get menu_editProfile => 'Editar perfil';

  @override
  String get menu_editProfileSubtitle => 'Actualiza tu información';

  @override
  String get menu_followUsOn => 'Síguenos en';

  @override
  String get menu_logOut => 'Cerrar sesión';

  @override
  String get menu_logOutConfirmMessage => '¿Realmente deseas cerrar sesión?';

  @override
  String get menu_logOutSubtitle => 'Cierra sesión en la app';

  @override
  String get menu_profileImageUpdateFailed =>
      'Error al actualizar la imagen de perfil';

  @override
  String get menu_profileImageUpdated =>
      'Imagen de perfil actualizada con éxito';

  @override
  String get notif_accept => 'Aceptar';

  @override
  String get notif_channelHighImportanceDesc =>
      'Canal predeterminado para notificaciones de alta importancia';

  @override
  String get notif_channelHighImportanceName =>
      'Notificaciones de alta importancia';

  @override
  String get notif_channelWalkieAudioDesc =>
      'Mantiene la comunicación por voz en vivo y la captura de micrófono en segundo plano';

  @override
  String get notif_channelWalkieAudioName => 'Audio en vivo de Walkie-Talkie';

  @override
  String get notif_channelWalkieCallsDesc =>
      'Llamadas entrantes de Walkie-Talkie';

  @override
  String get notif_channelWalkieCallsName => 'Llamadas de Walkie-Talkie';

  @override
  String get notif_channelWalkieDesc =>
      'Llamadas grupales de walkie y actualizaciones de voz';

  @override
  String get notif_channelWalkieLiveDesc =>
      'Notificaciones para canales activos de Walkie-Talkie';

  @override
  String get notif_channelWalkieLiveName => 'Canales en vivo de Walkie-Talkie';

  @override
  String get notif_channelWalkieName => 'Walkie-Talkie';

  @override
  String notif_connectedIn(String group) {
    return 'Conectado en $group • Transmisión de audio en vivo';
  }

  @override
  String get notif_goToWalkie => 'Ir a la pantalla de Walkie';

  @override
  String get notif_incomingWalkieTitle => 'Llamada entrante de Walkie-Talkie';

  @override
  String notif_isTalking(String name) {
    return '$name está hablando';
  }

  @override
  String get notif_leave => 'Salir';

  @override
  String get notif_openWalkie => 'Abrir Walkie';

  @override
  String get notif_reject => 'Rechazar';

  @override
  String notif_stoppedTalking(String name) {
    return '$name dejó de hablar';
  }

  @override
  String get notif_walkieActiveConversation =>
      'Conversación activa de Walkie-Talkie';

  @override
  String get notif_walkieActiveTitle => 'Walkie-Talkie activo';

  @override
  String notif_wantsToTalk(String name) {
    return '$name quiere hablar';
  }

  @override
  String get notifications_clearAll => 'Borrar todas las notificaciones';

  @override
  String get notifications_clearedSuccess =>
      'Todas las notificaciones se eliminaron con éxito';

  @override
  String get notifications_emptySubtitle =>
      'No tienes nuevas alertas en este momento.';

  @override
  String get notifications_emptyTitle => 'Aún no hay notificaciones';

  @override
  String get notifications_filterAll => 'Todas';

  @override
  String get notifications_filterCalls => 'Llamadas';

  @override
  String get notifications_filterChats => 'Chats';

  @override
  String get notifications_filterUnread => 'No leídas';

  @override
  String get notifications_loadingDetails =>
      'Cargando detalles de la notificación';

  @override
  String get notifications_recentCalls => 'Llamadas recientes';

  @override
  String get notifications_title => 'Notificaciones';

  @override
  String get otpCharges_chargedNotice =>
      'A partir de ahora, cada OTP de inicio de sesión tiene cargo. El reenvío es gratuito (hasta 3 intentos).';

  @override
  String get otpCharges_chargesApplyTo => 'Los cargos aplican a';

  @override
  String get otpCharges_eachOtpCosts => 'Cada OTP cuesta';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'Cada OTP cuesta $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'Cada OTP cuesta $amount, incluido $percent% de IVA';
  }

  @override
  String get otpCharges_firstLoginFree =>
      'Tu primer inicio de sesión fue gratuito.';

  @override
  String get otpCharges_freeBody =>
      'Los OTP de inicio de sesión a este número no tienen cargo.';

  @override
  String get otpCharges_freeTitle => 'El OTP es gratuito para tu número';

  @override
  String otpCharges_gstTitle(String percent) {
    return 'IVA ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return 'Incluye $percent% IVA';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return 'Incluye $percent% de impuestos';
  }

  @override
  String get otpCharges_noInternet =>
      'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get otpCharges_otpCharge => 'Cargo por OTP';

  @override
  String otpCharges_pay(String amount) {
    return 'Pagar $amount';
  }

  @override
  String get otpCharges_paymentCancelled =>
      'Pago cancelado. Cancelaste el pago. No se dedujo dinero.';

  @override
  String get otpCharges_paymentFailed =>
      'Pago fallido. Si se dedujo dinero, se reembolsará en 5 a 7 días hábiles.';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return 'Pago pausado ($amount)';
  }

  @override
  String get otpCharges_paymentReceived =>
      'Pago recibido. Tu OTP puede tardar unos instantes en llegar.';

  @override
  String get otpCharges_paymentStartFailed =>
      'No se pudo iniciar el pago. Inténtalo de nuevo.';

  @override
  String get otpCharges_paymentsPaused =>
      'Los pagos de OTP están pausados temporalmente por el administrador. Toca abajo para detalles.';

  @override
  String get otpCharges_paymentsUnavailable =>
      'Los pagos de OTP no están disponibles temporalmente. Inténtalo más tarde.';

  @override
  String get otpCharges_sessionExpired =>
      'Sesión caducada. Por favor, comienza de nuevo.';

  @override
  String get otpCharges_title => 'Cargos de OTP';

  @override
  String get otpCharges_totalPerOtp => 'Total por OTP';

  @override
  String get otpCharges_tryAgainMoment =>
      'Algo salió mal. Por favor, inténtalo de nuevo en un momento.';

  @override
  String get otpCharges_unknownBody =>
      'Los OTP a números de la India son gratuitos. Para otros países se mostrará el precio antes de pagar.';

  @override
  String get otpCharges_unknownTitle => 'Los cargos de OTP dependen de tu país';

  @override
  String get otpCharges_updateApp =>
      'No se pudo iniciar el pago. Actualiza la aplicación e inténtalo de nuevo.';

  @override
  String otpCharges_vatTitle(String percent) {
    return 'IVA / Impuesto ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      'Error al verificar el pago. Si se dedujo dinero, se reembolsará en 5 a 7 días hábiles.';

  @override
  String get otpCharges_yourNumber => 'Tu número';

  @override
  String get package_noPackages => 'No hay paquetes disponibles ahora.';

  @override
  String package_plansComingSoon(String title) {
    return 'Los planes de $title estarán disponibles pronto';
  }

  @override
  String get package_subtitle => 'Elige un módulo para ver sus planes';

  @override
  String get package_title => 'Paquetes y precios';

  @override
  String get package_viewPlans => 'Ver planes';

  @override
  String get perm_alwaysLocationBody =>
      'Para rastrear a tu grupo en tiempo real y en segundo plano, establece el acceso a la ubicación en \'Permitir todo el tiempo\' en los Ajustes de la app.';

  @override
  String get perm_alwaysLocationTitle =>
      'Activar permiso de ubicación \'Siempre\'';

  @override
  String get perm_chooseAllowAllTime =>
      'Por favor, elige \'Permitir todo el tiempo\' en la siguiente ventana emergente.';

  @override
  String get perm_collectsLocationBody =>
      'Esta aplicación recopila datos de ubicación para garantizar un progreso fluido y un seguimiento eficiente, incluso cuando la aplicación está cerrada o no se está utilizando.';

  @override
  String get perm_enableDeviceGpsBody =>
      'Por favor, activa el GPS de tu dispositivo (Ubicación de Google).';

  @override
  String get perm_enableGpsTitle => 'Activar GPS';

  @override
  String get perm_exitBody => '¿Deseas salir de la aplicación?';

  @override
  String get perm_exitTitle => '¿Estás seguro?';

  @override
  String get perm_gpsRequiredBody =>
      'Se requiere GPS para rastrear a tu grupo en tiempo real.';

  @override
  String get perm_locationTitle => 'Permiso de ubicación';

  @override
  String get perm_trackingPermissionBody =>
      'La aplicación FG Partner necesita tu permiso para rastrear la ubicación mientras tengas la sesión iniciada.';

  @override
  String get permission_allowAllTheTime => 'Permitir todo el tiempo';

  @override
  String get permission_allowLocation => 'Permitir ubicación';

  @override
  String get permission_allowLocationFirst =>
      'Por favor, permite la ubicación primero.';

  @override
  String permission_allowNamed(String permission) {
    return 'Permitir $permission';
  }

  @override
  String get permission_allowNotifications => 'Permitir notificaciones';

  @override
  String get permission_appPermissionsSubtitle =>
      'Revisa los permisos requeridos.';

  @override
  String get permission_appPermissionsTitle => 'Permisos de la app';

  @override
  String get permission_badgeGranted => 'Concedido';

  @override
  String get permission_badgeOptional => 'Opcional';

  @override
  String get permission_badgeRecommended => 'Recomendado';

  @override
  String get permission_badgeRequired => 'Requerido';

  @override
  String get permission_camera => 'Cámara';

  @override
  String get permission_cameraDescription =>
      'Utilizado por funciones que capturan fotos o videos.';

  @override
  String get permission_cameraSettingsMessage =>
      'Se necesita permiso de cámara para capturar fotos y videos. Habilítalo en los ajustes.';

  @override
  String get permission_cameraWhy =>
      'Te permite capturar fotos y videos para perfil, chat y otras funciones.';

  @override
  String get permission_contacts => 'Contactos';

  @override
  String get permission_contactsDescription =>
      'Utilizado para descubrir o seleccionar contactos en el app.';

  @override
  String get permission_contactsSettingsMessage =>
      'Se necesita permiso de contactos para buscar y seleccionar contactos. Habilítalo en los ajustes.';

  @override
  String get permission_contactsWhy =>
      'Te ayuda a encontrar y seleccionar contactos al usar funciones relacionadas.';

  @override
  String get permission_gateCheckFailed =>
      'No pudimos verificar tus permisos. Inténtalo de nuevo.';

  @override
  String get permission_gateSubtitle =>
      'FG Tracker necesita estos permisos para recibir llamadas, alertas y ejecutar asistencia, rastreo en vivo y zona segura.';

  @override
  String get permission_gateTitle => 'Permisos requeridos';

  @override
  String get permission_genericSettingsMessage =>
      'Este permiso es necesario. Por favor, habilítalo en los ajustes.';

  @override
  String get permission_iosLocationServicesOff =>
      'La localización está desactivada. Ve a Ajustes → Privacidad y seguridad → Localización y actívala.';

  @override
  String get permission_location => 'Ubicación';

  @override
  String get permission_locationAndNotificationRequired =>
      'Se requieren permisos de ubicación y notificaciones para continuar.';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      'Se requieren ubicación y notificaciones para continuar.';

  @override
  String get permission_locationDescription =>
      'Necesario para asistencia, rastreo en vivo y zona segura, incluso en segundo plano.';

  @override
  String get permission_locationRequiredToContinue =>
      'Se requiere permiso de ubicación para continuar.';

  @override
  String get permission_locationStatusApproximate =>
      'Solo se permite ubicación aproximada. Se requiere precisa.';

  @override
  String get permission_locationStatusBlocked =>
      'Ubicación bloqueada. Habilítala desde Ajustes.';

  @override
  String get permission_locationStatusDone =>
      'Permitido siempre · Preciso · GPS encendido';

  @override
  String get permission_locationStatusGpsOff =>
      'La ubicación del dispositivo (GPS) está desactivada.';

  @override
  String get permission_locationStatusNeedAlways =>
      'Se requiere \"Permitir todo el tiempo\".';

  @override
  String get permission_locationStatusNotAllowed =>
      'Permiso de ubicación aún no permitido.';

  @override
  String get permission_locationWhyExtra =>
      'Elige \"Permitir todo el tiempo\" y mantén activada la ubicación precisa.';

  @override
  String get permission_logout => 'Cerrar sesión';

  @override
  String get permission_microphone => 'Micrófono / Audio';

  @override
  String get permission_microphoneDescription =>
      'Utilizado por funciones de voz, walkie-talkie y llamadas.';

  @override
  String get permission_microphoneSettingsMessage =>
      'Se necesita permiso de micrófono para voz, walkie-talkie y llamadas. Habilítalo en los ajustes.';

  @override
  String get permission_microphoneWhy =>
      'Permite la comunicación por voz, transmisión por walkie-talkie y llamadas.';

  @override
  String permission_notGrantedNamed(String permission) {
    return 'No se otorgó el permiso $permission. Inténtalo de nuevo.';
  }

  @override
  String get permission_notificationRequiredToContinue =>
      'Se requiere permiso de notificaciones para continuar.';

  @override
  String get permission_notificationSettingsText =>
      'Las notificaciones están desactivadas para FG Tracker. Abre Ajustes → Notificaciones y permítelas.';

  @override
  String get permission_notificationStatusBlocked =>
      'Notificaciones bloqueadas. Habilítalas desde Ajustes.';

  @override
  String get permission_notificationStatusDone => 'Permitido';

  @override
  String get permission_notificationStatusNotAllowed =>
      'Permiso de notificaciones no permitido aún.';

  @override
  String get permission_notifications => 'Notificaciones';

  @override
  String get permission_notificationsDescription =>
      'Necesario para recibir llamadas entrantes, mensajes de chat y alertas.';

  @override
  String get permission_notificationsWhyExtra =>
      'Las llamadas entrantes no pueden sonar sin este permiso.';

  @override
  String get permission_openSettings => 'Abrir ajustes';

  @override
  String get permission_preciseLocation => 'Ubicación precisa';

  @override
  String get permission_pushNotifications => 'Notificaciones push';

  @override
  String get permission_reasonLocation =>
      'La ubicación es necesaria para asistencia, rastreo en vivo y alertas de zona segura.';

  @override
  String get permission_reasonLocationAlways =>
      'Elige \"Permitir siempre\" para que el rastreo y la zona segura sigan funcionando en segundo plano.';

  @override
  String get permission_reasonNotification =>
      'Las notificaciones son necesarias para llamadas entrantes, chats y alertas.';

  @override
  String get permission_reasonPrecise =>
      'Se necesita ubicación precisa para asistencia exacta, rastreo en vivo y alertas.';

  @override
  String get permission_required => 'Permiso requerido';

  @override
  String get permission_selectAllowAllTheTime =>
      'Selecciona \"Permitir todo el tiempo\" para continuar.';

  @override
  String get permission_settingsAndroidAlways =>
      'Abre Ajustes → Permisos → Ubicación y elige \"Permitir todo el tiempo\".';

  @override
  String get permission_settingsAndroidBlocked =>
      'El acceso a la ubicación está bloqueado para FG Tracker. Abre Ajustes → Permisos → Ubicación y elige \"Permitir todo el tiempo\".';

  @override
  String get permission_settingsAndroidPrecise =>
      'Abre Ajustes → Permisos → Ubicación y activa \"Usar ubicación precisa\".';

  @override
  String get permission_settingsIosAlways =>
      'Abre Ajustes → Ubicación y elige \"Siempre\".';

  @override
  String get permission_settingsIosBlocked =>
      'El acceso a la ubicación está desactivado para FG Tracker. Abre Ajustes → Ubicación y elige \"Siempre\".';

  @override
  String get permission_settingsIosPrecise =>
      'Abre Ajustes → Ubicación y activa \"Ubicación precisa\".';

  @override
  String get permission_skipAndContinue => 'Omitir y continuar';

  @override
  String get permission_turnOnLocation => 'Activar ubicación';

  @override
  String get permission_turnOnPreciseLocation => 'Activar ubicación precisa';

  @override
  String get permission_unableToRequest => 'No se pudo solicitar el permiso.';

  @override
  String get permission_whyWeNeedThis => '¿Por qué necesitamos esto?';

  @override
  String get registration_contactNumberHint =>
      'Introduce el número de contacto';

  @override
  String get registration_contactNumberLabel => 'Número de contacto';

  @override
  String get registration_doneButton => 'Listo';

  @override
  String get registration_emailHint => 'Introduce la dirección de correo';

  @override
  String get registration_emailLabel => 'Dirección de correo';

  @override
  String get registration_genderFemale => 'Femenino';

  @override
  String get registration_genderLabel => 'Seleccionar género';

  @override
  String get registration_genderMale => 'Masculino';

  @override
  String get registration_genderOther => 'Otro';

  @override
  String get registration_selectGenderError =>
      'Por favor, selecciona tu género';

  @override
  String get registration_userNameHint => 'Introduce el nombre de usuario';

  @override
  String get registration_userNameLabel => 'Nombre de usuario';

  @override
  String get repo_allCallsCleared =>
      'Todo el historial de llamadas borrado con éxito';

  @override
  String get repo_callDeleted => 'Historial de llamadas eliminado con éxito';

  @override
  String get repo_invalidResponse => 'Formato de respuesta no válido';

  @override
  String get repo_loadLocationsFailed =>
      'Error al cargar las ubicaciones del grupo';

  @override
  String get repo_pkgConflict =>
      'Este plan ya está activo o hay un pago en curso.';

  @override
  String get repo_pkgNotFound =>
      'Los planes no están disponibles en este momento. Inténtalo más tarde.';

  @override
  String get repo_pkgOffline =>
      'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get repo_pkgSessionExpired =>
      'Tu sesión ha caducado. Por favor, inicia sesión de nuevo.';

  @override
  String get repo_pkgTimeout =>
      'El servidor está tardando demasiado en responder. Inténtalo de nuevo.';

  @override
  String get repo_selectedCallsDeleted =>
      'Llamadas seleccionadas eliminadas con éxito';

  @override
  String get repo_unnamedGroup => 'Grupo sin nombre';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return 'Distancia total: $distance  •  Desviación permitida: $deviation';
  }

  @override
  String get safeRoute_activeTitle => 'Ruta segura activa';

  @override
  String get safeRoute_alertSettingsDesc =>
      'Gestiona alertas de ruta, límites de desvío y preferencias.';

  @override
  String get safeRoute_alertSheetDesc =>
      'Alertas en tiempo real si se desvían de la ruta segura';

  @override
  String get safeRoute_alertTitle => 'Alerta de ruta segura';

  @override
  String get safeRoute_appBarSubtitle =>
      'Establece una ruta segura para el miembro del equipo.';

  @override
  String get safeRoute_destination => 'Destino';

  @override
  String get safeRoute_deviated => 'Desviado de la ruta segura';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'Se activará una alerta si el miembro se desvía más de $distance.';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (Desviación: $distance)';
  }

  @override
  String get safeRoute_deviationLimit => 'Límite de desviación';

  @override
  String get safeRoute_deviationSubtitle =>
      'Establece cuánto desvío se permite de la ruta.';

  @override
  String get safeRoute_distance => 'Distancia';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance km • $minutes min';
  }

  @override
  String get safeRoute_edit => 'Editar ruta segura';

  @override
  String get safeRoute_end => 'Fin';

  @override
  String safeRoute_estTime(int minutes) {
    return 'Tiempo estimado: $minutes min';
  }

  @override
  String get safeRoute_featureDesc =>
      'Establece rutas predefinidas. Recibe alertas si alguien se desvía de la ruta segura.';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$group ($_temp0)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'Fija la distancia permitida fuera de la ruta. Recibirás alerta si la sobrepasan.';

  @override
  String get safeRoute_helpDeviationTitle => '¿Qué es el límite de desviación?';

  @override
  String get safeRoute_helpHowBody =>
      'Selecciona el miembro, elige inicio y destino, escoge la mejor ruta y fija el límite de desvío.';

  @override
  String get safeRoute_helpHowTitle => '¿Cómo crear una ruta segura?';

  @override
  String get safeRoute_helpTitle => 'Ayuda de ruta segura';

  @override
  String get safeRoute_helpWhatBody =>
      'Establece inicio y destino para crear una ruta de viaje segura para tu miembro.';

  @override
  String get safeRoute_helpWhatTitle => '¿Qué es una ruta segura?';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$name se ha desviado de la ruta segura';
  }

  @override
  String get safeRoute_recommended => 'Recomendado';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (Recomendado)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'Ruta ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'Guardar y activar ruta segura';

  @override
  String get safeRoute_saveActivateGroup =>
      'Guardar y activar ruta para el grupo';

  @override
  String get safeRoute_selectedRoute => 'Ruta seleccionada';

  @override
  String get safeRoute_setRoutesSubtitle =>
      'Crea y administra rutas seguras para todos los miembros.';

  @override
  String get safeRoute_start => 'Inicio';

  @override
  String get safeRoute_startLocation => 'Ubicación de inicio';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. Fijar límite de desviación';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. Vista previa y aplicar';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. Vista previa de la ruta';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. Seleccionar ruta';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. Fijar rutas para miembros';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. Fijar inicio y destino';
  }

  @override
  String get safeRoute_subtitle => 'Protección de ruta';

  @override
  String get safeRoute_title => 'Ruta segura';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return 'Radio: $radius  •  Centro: $center';
  }

  @override
  String get safeZone_activePreview => 'Activo (Vista previa)';

  @override
  String get safeZone_activeTitle => 'Zona segura activa';

  @override
  String get safeZone_alertSettingsDesc =>
      'Gestiona zona segura, distancia de alerta y preferencias';

  @override
  String get safeZone_alertSheetDesc =>
      'Alertas en tiempo real si salen de la zona segura';

  @override
  String get safeZone_alertTitle => 'Alerta de zona segura';

  @override
  String safeZone_allMonitored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Los $count miembros serán monitoreados\nen esta zona segura.',
      one: '1 miembro será monitoreado\nen esta zona segura.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_appBarSubtitle =>
      'Define un área segura. Recibe alertas si alguien\nsale de la zona segura.';

  @override
  String safeZone_appliedToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Esta zona segura se aplicará a los $count miembros del grupo seleccionado.',
      one: 'Esta zona segura se aplicará al miembro seleccionado.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_edit => 'Editar zona segura';

  @override
  String get safeZone_exited => 'Salió de la zona segura';

  @override
  String get safeZone_featureDesc =>
      'Define un área segura para tu equipo. Recibe alertas instantáneas si alguien sale de la zona.';

  @override
  String get safeZone_helpHowBody =>
      'Selecciona un miembro, elige una ubicación en el mapa y fija el radio.';

  @override
  String get safeZone_helpHowTitle => '¿Cómo crear una zona segura?';

  @override
  String get safeZone_helpRadiusBody =>
      'Fija el radio (500 m, 1 km, 2 km o 5 km) según lo necesites.';

  @override
  String get safeZone_helpRadiusTitle => '¿Qué es el radio de la zona segura?';

  @override
  String get safeZone_helpTitle => 'Ayuda de zona segura';

  @override
  String get safeZone_helpWhatBody =>
      'Fija un área en el mapa y recibe alertas si el miembro sale de la zona.';

  @override
  String get safeZone_helpWhatTitle => '¿Qué es una zona segura?';

  @override
  String safeZone_memberLeft(String name) {
    return '$name ha salido de la zona segura';
  }

  @override
  String get safeZone_membersMonitored =>
      'Los miembros serán monitoreados dentro de esta zona.';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return 'Cerca de $place (Fuera de $zone)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place (Fuera de $zone)';
  }

  @override
  String get safeZone_saveActivate => 'Guardar y activar zona segura';

  @override
  String get safeZone_saveActivateGroup =>
      'Guardar y activar zona para el grupo';

  @override
  String get safeZone_searchLocation => 'Buscar ubicación...';

  @override
  String get safeZone_statusLabel => 'Estado:';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. Vista previa de la zona segura';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. Fijar radio de la zona segura';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. Seleccionar ubicación en el mapa';
  }

  @override
  String get safeZone_subtitle => 'Protección de área';

  @override
  String get safeZone_title => 'Zona segura';

  @override
  String safeZone_totalMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Total $count miembros',
      one: 'Total 1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get safety_active => 'Activo';

  @override
  String get safety_alertSettings => 'Ajustes de alertas';

  @override
  String get safety_alerts => 'Alertas';

  @override
  String get safety_alertsDesc => 'Requieren atención inmediata';

  @override
  String get safety_bannerBody =>
      'Monitorea y protege a tu equipo con funciones inteligentes.';

  @override
  String get safety_bannerTitle => 'Tu seguridad, nuestra prioridad';

  @override
  String get safety_chooseFeature => 'Elige una función de seguridad';

  @override
  String get safety_comingSoonBody =>
      'Pronto habrá funciones de seguridad inteligentes para proteger a tu equipo.';

  @override
  String get safety_contactSupport => 'Contactar soporte';

  @override
  String get safety_editAnytime =>
      'Puedes editar o desactivar en cualquier momento.';

  @override
  String get safety_mapCityPark => 'Parque de la ciudad';

  @override
  String get safety_mapMainRoad => 'Carretera principal';

  @override
  String get safety_mapMarketLane => 'Calle del mercado';

  @override
  String get safety_mapRiver => 'Río';

  @override
  String get safety_mapStationRoad => 'Camino de la estación';

  @override
  String get safety_needHelpBody =>
      'Contacta al soporte para ayuda relacionada con la seguridad.';

  @override
  String get safety_quickOverview => 'Resumen rápido';

  @override
  String get safety_recentAlerts => 'Alertas recientes';

  @override
  String get safety_recenter => 'Recentrar';

  @override
  String get safety_safeNow => 'Seguro ahora';

  @override
  String get safety_safeNowDesc => 'Los miembros están dentro de la zona/ruta';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. Seleccionar grupo';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. Seleccionar miembro';
  }

  @override
  String get safety_tabIndividual => 'Individual';

  @override
  String get safety_tagline => 'Mantente protegido. Mantente conectado.';

  @override
  String get safety_title => 'Seguridad';

  @override
  String get safety_viewAllMembers => 'Ver todos los miembros';

  @override
  String get sheet_addGroupMember => 'Añadir miembro al grupo';

  @override
  String get sheet_admin => 'Admin';

  @override
  String get sheet_attachSubtitle =>
      'Comparte archivos y multimedia con tu equipo';

  @override
  String get sheet_attachUpload => 'Adjuntar / Subir';

  @override
  String get sheet_attendance => 'Asistencia';

  @override
  String get sheet_callOptions => 'Opciones de llamada';

  @override
  String get sheet_cantRemoveSelf =>
      'No puedes eliminarte a ti mismo del grupo.';

  @override
  String get sheet_contact => 'Contacto';

  @override
  String get sheet_contactsNotOnApp => 'Tus contactos aún no usan FG Tracker.';

  @override
  String get sheet_document => 'Documento';

  @override
  String get sheet_groupMembers => 'Miembros del grupo';

  @override
  String get sheet_location => 'Ubicación';

  @override
  String get sheet_memberRemoved => 'Miembro eliminado con éxito';

  @override
  String get sheet_noMembers => 'No se encontraron miembros';

  @override
  String get sheet_noRegisteredContacts => 'No hay contactos registrados';

  @override
  String get sheet_noUserFound => 'No se encontró ningún usuario';

  @override
  String get sheet_normalAudioCall => 'Llamada de voz normal';

  @override
  String get sheet_normalAudioCallSubtitle => 'Calidad de voz clara estándar';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contactos registrados',
      one: '1 contacto registrado',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return '¿Seguro que deseas eliminar a $name del grupo?';
  }

  @override
  String get sheet_removeMemberTitle => 'Eliminar miembro';

  @override
  String get sheet_searchContacts => 'Buscar contactos';

  @override
  String get sheet_walkieCall => 'Llamada Walkie-Talkie';

  @override
  String get sheet_walkieCallSubtitle => 'Comunicación pulsar para hablar';

  @override
  String get sos_addDetailsMandatory => 'Agregar detalles (obligatorio)';

  @override
  String get sos_addDetailsOptional => 'Agregar detalles (opcional)';

  @override
  String get sos_addFamilyMember => 'Agregar familiar';

  @override
  String get sos_addFamilyMemberRequired =>
      'Agrega al menos 1 familiar para enviar la alerta SOS';

  @override
  String get sos_addPhotoHint =>
      'Adjunta una foto para ayudar a otros a entender mejor.';

  @override
  String get sos_addPhotoOptional => 'Agregar foto (opcional)';

  @override
  String get sos_alertSent => '¡Alerta SOS enviada!';

  @override
  String get sos_alertSentToNearby =>
      'Tu alerta ha sido enviada a personas cercanas.';

  @override
  String get sos_alertWillBeSent => 'La alerta se enviará a personas cercanas';

  @override
  String get sos_alertWillBeSentFamily =>
      'Tu alerta se enviará a personas cercanas y a tu familia.';

  @override
  String sos_availableUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usuarios disponibles',
      one: '1 usuario disponible',
    );
    return '$_temp0';
  }

  @override
  String get sos_detailsHint => 'Escribe detalles adicionales...';

  @override
  String get sos_detailsMandatoryForOther =>
      'Agregar detalles es obligatorio al seleccionar \'Otro\'';

  @override
  String get sos_howItWorks => 'Cómo funciona';

  @override
  String get sos_howItWorksIntro =>
      'La alerta SOS te ayuda a notificar a personas cercanas y familiares en emergencias.';

  @override
  String get sos_howItWorksTitle => '¿Cómo funciona la alerta SOS?';

  @override
  String get sos_liveTrackingStarted => 'Rastreo en vivo iniciado';

  @override
  String sos_locationSharedWithFamily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu ubicación se comparte con $count familiares',
      one: 'Tu ubicación se comparte con 1 familiar',
    );
    return '$_temp0';
  }

  @override
  String sos_membersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros seleccionados',
      one: '1 miembro seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get sos_needHelp => '¿Necesitas ayuda?';

  @override
  String get sos_needHelpBody =>
      'Envía una alerta SOS a personas cercanas.\nSerán notificados y podrán ayudarte.';

  @override
  String get sos_noMatchFound => 'No se encontraron coincidencias';

  @override
  String get sos_noUsersFound => 'No se encontraron usuarios';

  @override
  String get sos_notifyFamilyTitle =>
      'Notifica a tu familia (de 1 a 5 requeridos)';

  @override
  String get sos_notifyUpdates => 'Te notificaremos sobre cualquier novedad';

  @override
  String get sos_okGotIt => 'Entendido';

  @override
  String get sos_peopleWithinRadius => 'Personas dentro de un radio de 2 km';

  @override
  String get sos_privacyNote =>
      'Tu privacidad es importante. Tu ubicación solo se comparte durante una alerta SOS activa.';

  @override
  String get sos_reasonAccident => 'Accidente';

  @override
  String get sos_reasonMedical => 'Médica';

  @override
  String get sos_reasonOther => 'Otro';

  @override
  String get sos_reasonSafety => 'Seguridad';

  @override
  String get sos_reasonThreat => 'Amenaza';

  @override
  String get sos_required => 'Requerido';

  @override
  String get sos_searchUsers => 'Buscar usuarios';

  @override
  String get sos_selectReason => 'Selecciona motivo';

  @override
  String get sos_sendSosAlert => 'Enviar alerta SOS';

  @override
  String get sos_stayCalm => 'Mantén la calma, la ayuda está en camino';

  @override
  String get sos_step1Body =>
      'Toca el botón SOS para enviar la alerta a personas cercanas.';

  @override
  String get sos_step1Title => '1. Enviar alerta SOS';

  @override
  String get sos_step2Body =>
      'Las personas cercanas recibirán tu alerta con tu ubicación.';

  @override
  String get sos_step2Title => '2. Notificar a personas cercanas';

  @override
  String get sos_step3Body =>
      'Las personas cercanas pueden ver tu alerta y acudir en tu ayuda.';

  @override
  String get sos_step3Title => '3. Recibe ayuda más rápido';

  @override
  String get sos_step4Body =>
      'Tus familiares serán notificados al instante sobre tu SOS.';

  @override
  String get sos_step4Title => '4. Notificación a familiares';

  @override
  String get sos_subtitle => 'Enviar alerta a personas cercanas';

  @override
  String get sos_title => 'Alerta SOS';

  @override
  String get sos_willBeNotified => 'serán notificados';

  @override
  String status_activeCount(int count) {
    return '$count activos';
  }

  @override
  String get status_addToMyStatus => 'Añadir a mi estado';

  @override
  String get status_allContacts => 'Todos los contactos';

  @override
  String get status_cameraAccessFailed => 'No se puede acceder a la cámara';

  @override
  String get status_captionHint => 'Añadir un comentario...';

  @override
  String get status_changeMedia => 'Cambiar archivo';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get status_deleted => 'Estado eliminado';

  @override
  String get status_deletedByOwner =>
      'Este estado fue eliminado por el propietario';

  @override
  String get status_exceptContacts => 'Excepto contactos';

  @override
  String get status_exceptSelected => 'Excepto seleccionados';

  @override
  String get status_flip => 'Girar cámara';

  @override
  String get status_gallery => 'Galería';

  @override
  String get status_modePhoto => 'Foto';

  @override
  String get status_modeText => 'Texto';

  @override
  String get status_modeVideo => 'Video';

  @override
  String get status_myStatus => 'Mi estado';

  @override
  String get status_new => 'Nuevo';

  @override
  String get status_noCamera => 'No hay cámara disponible';

  @override
  String get status_noLongerAvailable => 'Este estado ya no está disponible';

  @override
  String get status_noViewsYet => 'Aún no hay visualizaciones';

  @override
  String get status_onlyShareWith => 'Solo compartir con';

  @override
  String get status_pause => 'Pausar';

  @override
  String get status_pinchZoomHint => 'Pellizca para hacer zoom en la foto';

  @override
  String get status_play => 'Reproducir';

  @override
  String get status_postStatus => 'Publicar estado';

  @override
  String get status_previewStatus => 'Vista previa del estado';

  @override
  String get status_privacy => 'Privacidad';

  @override
  String get status_privacyTitle => 'Privacidad del estado';

  @override
  String get status_publishFailed => 'No se puede publicar el estado';

  @override
  String get status_replyHint => 'Responder al estado...';

  @override
  String get status_retake => 'Repetir';

  @override
  String get status_selectPhotoFirst =>
      'Por favor, captura o selecciona una foto primero';

  @override
  String get status_selectVideoFirst =>
      'Por favor, captura o selecciona un video primero';

  @override
  String get status_shareUpdatesHint => 'Comparte novedades con tu equipo';

  @override
  String get status_tapVideoHint => 'Toca el video para reproducir / pausar';

  @override
  String get status_textRequired =>
      'Se requiere contenido para el estado de texto';

  @override
  String get status_title => 'Estado';

  @override
  String get status_typeHint => 'Escribe un estado...';

  @override
  String get status_uploadFailed => 'Error al subir';

  @override
  String get status_viewMyStatus => 'Ver mi estado';

  @override
  String get status_viewed => 'Visto';

  @override
  String status_viewedBy(int count) {
    return 'Visto por $count';
  }

  @override
  String status_viewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visualizaciones',
      one: '1 visualización',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => '¿Quién puede verlo?';

  @override
  String get track_admin => 'Admin';

  @override
  String get track_applyRadius => 'Aplicar radio';

  @override
  String get track_checkNetworkConnection =>
      'Comprueba tu conexión de red e inténtalo de nuevo.';

  @override
  String get track_checkNetworkMembers =>
      'Comprueba tu red e inténtalo de nuevo para ver miembros cercanos.';

  @override
  String get track_currentLocation => 'Ubicación actual';

  @override
  String get track_custom => 'Personalizado';

  @override
  String track_customWithValue(String radius) {
    return 'Personalizado ($radius)';
  }

  @override
  String track_distanceAway(String distance) {
    return 'a $distance';
  }

  @override
  String get track_enable => 'Habilitar';

  @override
  String get track_enableGpsBody =>
      'Para rastrear a tu grupo en tiempo real, activa el GPS.';

  @override
  String get track_enableGpsTitle => 'Activar GPS';

  @override
  String get track_errorFailedLoadGroups => 'Error al cargar grupos';

  @override
  String get track_errorLoadGroups =>
      'No se pudieron cargar los grupos. Inténtalo de nuevo.';

  @override
  String get track_errorLoadMembers =>
      'No se pudieron cargar miembros cercanos. Inténtalo de nuevo.';

  @override
  String get track_errorNoInternet =>
      'Sin conexión a internet. Comprueba tu red.';

  @override
  String get track_errorServer =>
      'No se pudo conectar al servidor. Inténtalo de nuevo.';

  @override
  String track_groupCode(String code) {
    return 'Código: $code';
  }

  @override
  String get track_groupMembers => 'Miembros del grupo';

  @override
  String track_groupMembersAndCode(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros • Código: $code',
      one: '1 miembro • Código: $code',
    );
    return '$_temp0';
  }

  @override
  String get track_groupTab => 'Grupo';

  @override
  String track_groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
    );
    return '$_temp0';
  }

  @override
  String track_groupsHeader(int count) {
    return 'GRUPOS ($count)';
  }

  @override
  String get track_helpGroupBody =>
      'Crea un grupo para rastrear a varios miembros.';

  @override
  String get track_helpGroupTitle => '¿Cómo agregar un grupo?';

  @override
  String get track_helpLiveBody =>
      'Rastrea la ubicación en tiempo real de tu equipo en el mapa.';

  @override
  String get track_helpLiveTitle => '¿Qué es el rastreo en vivo?';

  @override
  String get track_helpRadiusBody =>
      'Establece el área para encontrar miembros cercanos en el mapa.';

  @override
  String get track_helpRadiusTitle => '¿Qué es el radio de rastreo?';

  @override
  String get track_helpTitle => 'Ayuda de rastreo';

  @override
  String track_lastSeen(String time) {
    return 'Última vez visto: $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count en vivo';
  }

  @override
  String get track_liveMembers => 'Miembros en vivo';

  @override
  String get track_liveTracking => 'Rastreo en vivo';

  @override
  String get track_locating => 'Ubicando...';

  @override
  String get track_locationHidden => 'Ubicación oculta';

  @override
  String get track_locationUnavailable => 'Ubicación no disponible';

  @override
  String get track_mapOfflineBody =>
      'Se requiere conexión a internet para cargar el mapa en vivo y las ubicaciones en tiempo real.';

  @override
  String get track_mapUnavailableOffline => 'Mapa no disponible sin conexión';

  @override
  String get track_member => 'Miembro';

  @override
  String track_memberPausedSharing(String name) {
    return '$name ha pausado el compartir ubicación. La ubicación en vivo no está disponible.';
  }

  @override
  String track_membersHeader(int count) {
    return 'MIEMBROS ($count)';
  }

  @override
  String track_membersLive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros en vivo',
      one: '1 miembro en vivo',
    );
    return '$_temp0';
  }

  @override
  String get track_menuMembers => 'Miembros';

  @override
  String get track_menuRefreshMap => 'Actualizar mapa';

  @override
  String get track_menuTheme => 'Tema';

  @override
  String get track_nearbyYou => 'Cerca de ti';

  @override
  String get track_noActiveMembers => 'No hay miembros activos';

  @override
  String track_noActiveMembersWithin(String radius) {
    return 'No se encontraron miembros activos dentro de $radius';
  }

  @override
  String get track_noDescription => 'Sin descripción';

  @override
  String get track_noGroupsFound => 'No se encontraron grupos';

  @override
  String get track_noGroupsMatch => 'Ningún grupo coincide';

  @override
  String track_noGroupsMatchQuery(String query) {
    return 'Ningún grupo coincide con \'$query\'';
  }

  @override
  String get track_noGroupsYet =>
      'Aún no te has unido ni has creado ningún grupo.';

  @override
  String get track_noInternetTitle => 'Sin conexión a internet';

  @override
  String get track_noMembersFound => 'No se encontraron miembros';

  @override
  String get track_noMembersFoundPlain => 'No se encontraron miembros';

  @override
  String get track_noMembersInGroup =>
      'No se encontraron miembros en este grupo';

  @override
  String track_noMembersMatch(String query) {
    return 'Ningún miembro coincide con \'$query\'';
  }

  @override
  String track_noSearchMatches(String query) {
    return 'No hay miembros o grupos coincidentes';
  }

  @override
  String track_noSearchResults(String query) {
    return 'No se encontraron miembros ni grupos para \'$query\'';
  }

  @override
  String get track_notAvailable => 'N/D';

  @override
  String get track_offlineBanner =>
      'Sin conexión a internet. El mapa y el rastreo están sin conexión.';

  @override
  String get track_private => 'Privado';

  @override
  String get track_radius => 'Radio';

  @override
  String get track_refresh => 'Actualizar';

  @override
  String get track_refreshing => 'Actualizando...';

  @override
  String get track_retryConnection => 'Reintentar conexión';

  @override
  String get track_searchHint => 'Buscar miembros o grupos...';

  @override
  String get track_searchMembersHint => 'Buscar miembros...';

  @override
  String get track_selectedLocation => 'Ubicación seleccionada';

  @override
  String get track_setRadiusSubtitle => 'Desliza para seleccionar el radio';

  @override
  String get track_setRadiusTitle => 'Establecer radio de rastreo';

  @override
  String get track_unableToLoadGroups => 'No se pudieron cargar los grupos';

  @override
  String get track_unableToLoadMembers => 'No se pudieron cargar los miembros';

  @override
  String get track_unnamedGroup => 'Grupo sin nombre';

  @override
  String get track_unnamedMember => 'Miembro sin nombre';

  @override
  String get track_yourGroups => 'Tus grupos';

  @override
  String get track_yourLocationPaused =>
      'El uso compartido de tu ubicación está pausado y privado.';

  @override
  String get util_previewContact => '👤 Contacto';

  @override
  String get util_previewDocument => '📄 Documento';

  @override
  String get util_previewLocation => '📍 Ubicación';

  @override
  String get util_previewPhoto => '📷 Foto';

  @override
  String get util_previewVideo => '🎥 Video';

  @override
  String get util_previewVoice => '🎤 Mensaje de voz';

  @override
  String util_spokenEur(String amount) {
    return '$amount euros';
  }

  @override
  String util_spokenGbp(String amount) {
    return '$amount libras esterlinas';
  }

  @override
  String util_spokenRupees(int rupees) {
    String _temp0 = intl.Intl.pluralLogic(
      rupees,
      locale: localeName,
      other: '$rupees rupias',
      one: '1 rupia',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees rupias y $paise paise';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount dólares estadounidenses';
  }

  @override
  String get util_unableToCallContact => 'No se puede llamar a este contacto';

  @override
  String get util_unableToStartGroupCall =>
      'No se puede iniciar la llamada grupal';

  @override
  String get validation_emailEmpty =>
      'El correo electrónico no puede estar vacío';

  @override
  String get validation_emailInvalid =>
      'Por favor, introduce un correo electrónico válido.';

  @override
  String validation_required(String field) {
    return '$field es obligatorio';
  }

  @override
  String get voice_appLanguage => 'Idioma de la app';

  @override
  String get voice_audioChip => 'AUDIO';

  @override
  String get voice_captionReady => 'Descripción lista';

  @override
  String get voice_chooseSpeechLanguage => 'Elegir idioma de habla';

  @override
  String get voice_couldntPlay => 'No se pudo reproducir el mensaje de voz';

  @override
  String get voice_didntCatch =>
      'No lo capté. Toca el micrófono y habla un poco más alto.';

  @override
  String get voice_language => 'Idioma';

  @override
  String get voice_listenBack => 'Escuchar grabación';

  @override
  String get voice_listenBeforeSending =>
      'Escucha antes de enviar tu mensaje de voz.';

  @override
  String get voice_listening => 'Escuchando…';

  @override
  String get voice_micPermissionNeeded =>
      'Se necesita permiso de micrófono para usar la voz.';

  @override
  String get voice_micUnavailable =>
      'Micrófono no disponible. Comprueba los ajustes.';

  @override
  String get voice_noTextCaptured =>
      'No se capturó texto: intenta grabar de nuevo.';

  @override
  String get voice_openSettings => 'Abrir ajustes';

  @override
  String get voice_permissionRequired => 'Permiso requerido';

  @override
  String get voice_reRecord => 'Grabar de nuevo';

  @override
  String get voice_readyToSend => 'Listo para enviar';

  @override
  String get voice_recordVoice => 'Grabar voz';

  @override
  String get voice_recordVoiceSubtitle => 'Graba y envía como mensaje de audio';

  @override
  String get voice_recordingYourVoice => 'Grabando tu voz…';

  @override
  String get voice_replyReady => 'Respuesta lista';

  @override
  String get voice_reviewTextHint =>
      'Escucha tu voz arriba o edita el texto en el cuadro antes de enviar.';

  @override
  String get voice_sendMessage => 'Enviar mensaje';

  @override
  String get voice_sendVoiceMessage => 'Enviar mensaje de voz';

  @override
  String get voice_speakNowCaption =>
      'Habla ahora: estamos escribiendo tu descripción';

  @override
  String get voice_speakNowMessage =>
      'Habla ahora: tus palabras aparecerán en el cuadro de mensaje';

  @override
  String get voice_speakNowReply =>
      'Habla ahora: estamos escribiendo tu respuesta';

  @override
  String get voice_speakPlaceholder => 'Habla… tu texto aparecerá aquí';

  @override
  String get voice_speechPermissionNeeded =>
      'Se necesita permiso de reconocimiento de voz para transcribir.';

  @override
  String get voice_tapToStop => 'Toca para detener';

  @override
  String get voice_textReady => 'Texto listo';

  @override
  String get voice_tooMuchNoise =>
      'Demasiado ruido: acerca el teléfono y habla claro';

  @override
  String get voice_type => 'Tipo';

  @override
  String get voice_voiceToText => 'Voz a texto';

  @override
  String get voice_voiceToTextSubtitle =>
      'Habla para escribir en el cuadro de texto';

  @override
  String get voice_willSendAudioMessage =>
      'Tu voz se enviará como mensaje de audio';

  @override
  String get voice_willSendAudioReply =>
      'Tu voz se enviará como respuesta de audio';

  @override
  String get voice_willSendWithFile =>
      'Tu voz se enviará con el archivo como audio';

  @override
  String get voice_yourMessage => 'Tu mensaje';

  @override
  String get voice_yourVoiceMessage => 'Tu mensaje de voz';

  @override
  String get walkiePlan_availableIndividualPlans => 'Planes individuales';

  @override
  String get walkiePlan_availablePerMonth => '/ mes';

  @override
  String get walkiePlan_availablePerSeat => '/ plaza';

  @override
  String get walkiePlan_availableSingleMember =>
      'Miembro único (Acceso personal)';

  @override
  String get walkiePlan_availableSubtitle =>
      'Elige un plan para iniciar o mejorar tu suscripción';

  @override
  String get walkiePlan_availableTeamPlans => 'Planes de equipo';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min-$max plazas  •  Colaboración grupal';
  }

  @override
  String get walkiePlan_availableTitle => 'Planes disponibles';

  @override
  String get walkiePlan_bottomBarAfterTrial => 'Después de tu prueba gratis';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'Elige un plan';

  @override
  String get walkiePlan_bottomBarContinue => 'Continuar con Walkie Talkie';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get walkiePlan_cardActive => 'Activo';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return 'Activo desde $date';
  }

  @override
  String get walkiePlan_cardAssigned => 'Asignado';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return 'Asignado por $name';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'Asignado a ti';

  @override
  String get walkiePlan_cardAvailable => 'Disponible';

  @override
  String get walkiePlan_cardManageMembers => 'Gestionar miembros';

  @override
  String get walkiePlan_cardNoActiveIndividual =>
      'Sin suscripción individual activa';

  @override
  String get walkiePlan_cardNoActiveTeam =>
      'Sin plan de equipo activo ni plaza asignada';

  @override
  String get walkiePlan_cardOneSeatSelf => '1 plaza (Propia)';

  @override
  String get walkiePlan_cardPersonal => 'Personal';

  @override
  String get walkiePlan_cardPurchased => 'Comprado';

  @override
  String get walkiePlan_cardPurchasedByYou => 'Comprado por ti';

  @override
  String get walkiePlan_cardPurchasedOn => 'Comprado el';

  @override
  String get walkiePlan_cardSeatsMembers => 'Plazas / Miembros';

  @override
  String get walkiePlan_cardSubscribedByYou => 'Suscrito por ti';

  @override
  String get walkiePlan_cardTeamAdministrator => 'Administrador del equipo';

  @override
  String get walkiePlan_cardValidUntil => 'Válido hasta';

  @override
  String get walkiePlan_cardView => 'Ver';

  @override
  String get walkiePlan_cardViewPlan => 'Ver plan';

  @override
  String walkiePlan_couponDiscount(String value) {
    return 'Descuento de $value';
  }

  @override
  String get walkiePlan_couponExpired => 'El cupón ha caducado';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return 'Descuento directo de $amount';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet =>
      'No se cumple el monto mínimo de compra';

  @override
  String get walkiePlan_couponNotEligible => 'No aplicable para el plan actual';

  @override
  String get walkiePlan_couponNotStarted =>
      'La oferta del cupón aún no está activa';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent% de descuento';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable => 'No aplicable a este plan';

  @override
  String walkiePlan_couponValidTill(String date) {
    return 'Válido hasta el $date';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'Continuar al pago';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return 'Continuar con $plan';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => '¡Cupón aplicado con éxito!';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return '¡Cupón aplicado! Ahorras $amount';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => 'Error al aplicar el cupón';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'Cupón eliminado';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'Error de Cashfree ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed => 'Error al iniciar el pago.';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return 'Error al crear la sesión de pago: $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return 'No se pudo procesar el pago: $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'Cargando planes...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans =>
      'No se pudieron cargar los planes. Inténtalo de nuevo.';

  @override
  String get walkiePlan_detailsAllBanks =>
      'Todos los bancos indios compatibles';

  @override
  String get walkiePlan_detailsApplied => 'Aplicado';

  @override
  String get walkiePlan_detailsApply => 'Aplicar';

  @override
  String get walkiePlan_detailsApplyCaps => 'APLICAR';

  @override
  String get walkiePlan_detailsAvailableCoupons => 'Cupones disponibles';

  @override
  String get walkiePlan_detailsCard => 'Tarjeta de crédito / débito';

  @override
  String get walkiePlan_detailsChooseTitle => 'Elige un plan';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'Código: $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'Cupones y ofertas';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'Ingresar código de cupón';

  @override
  String get walkiePlan_detailsEnterValidCoupon =>
      'Por favor, ingresa un código válido';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'Comunicación grupal';

  @override
  String get walkiePlan_detailsFeatHqVoice => 'Voz de alta calidad';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => 'Soporte prioritario';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => 'Alcance ilimitado';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => 'Walkie Talkie ilimitado';

  @override
  String get walkiePlan_detailsHavePromoCode =>
      '¿Tienes un código promocional?';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'Sigue usando Walkie Talkie con un plan a tu medida';

  @override
  String get walkiePlan_detailsLockedCaps => 'BLOQUEADO';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Límite de $count miembros alcanzado',
      one: 'Límite de 1 miembro alcanzado',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMemberPlural => 'Miembros';

  @override
  String get walkiePlan_detailsMemberSingular => 'Miembro';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros × $rate',
      one: '1 miembro × $rate',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tamaño mínimo de $count miembros',
      one: 'Tamaño mínimo de 1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody =>
      'Agrega o elimina miembros cuando quieras.';

  @override
  String get walkiePlan_detailsMoreMembersTitle => '¿Más miembros?';

  @override
  String get walkiePlan_detailsMostPopular => 'Más popular';

  @override
  String get walkiePlan_detailsNetBanking => 'Banca electrónica';

  @override
  String get walkiePlan_detailsNoCouponsBody =>
      'No hay cupones activos para este plan en este momento.';

  @override
  String get walkiePlan_detailsNoCouponsTitle => 'No hay cupones disponibles';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      'No hay planes individuales disponibles ahora. Vuelve a consultar más tarde.';

  @override
  String get walkiePlan_detailsNoPlansTitle => 'No hay planes disponibles';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      'No hay planes de equipo disponibles ahora. Vuelve a consultar más tarde.';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '$amount total';
  }

  @override
  String get walkiePlan_detailsPayActivate => 'Pagar y activar plan';

  @override
  String get walkiePlan_detailsPerPerson => '/ persona';

  @override
  String get walkiePlan_detailsPillAllSizes => 'de todo tamaño';

  @override
  String get walkiePlan_detailsPillCommunication => 'Comunicación';

  @override
  String get walkiePlan_detailsPillForTeams => 'Para equipos';

  @override
  String get walkiePlan_detailsPillInstant => 'Instantáneo';

  @override
  String get walkiePlan_detailsPillPriority => 'Prioritario';

  @override
  String get walkiePlan_detailsPillReliable => 'Confiable y';

  @override
  String get walkiePlan_detailsPillSecure => 'Seguro';

  @override
  String get walkiePlan_detailsPillSupport => 'Soporte';

  @override
  String get walkiePlan_detailsPillUnlimited => 'Ilimitado';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'Walkie Talkie';

  @override
  String get walkiePlan_detailsPlanActivated => '¡Plan activado con éxito!';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'Tu plan de Walkie Talkie está activo. Disfruta de la comunicación instantánea.';

  @override
  String get walkiePlan_detailsPlanSummary => 'Resumen del plan';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'Promo ($code) aplicada';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => 'QUITAR';

  @override
  String get walkiePlan_detailsSelectPaymentMethod =>
      'Selecciona método de pago';

  @override
  String get walkiePlan_detailsSkeletonCouponNote =>
      'Válido en todos los planes • Expira pronto';

  @override
  String get walkiePlan_detailsStep1Subtitle =>
      'Elige cuántos miembros deseas agregar';

  @override
  String get walkiePlan_detailsStep1Title => 'Selecciona el número de miembros';

  @override
  String get walkiePlan_detailsStep2Subtitle =>
      'Elige la duración que mejor se adapte a ti';

  @override
  String get walkiePlan_detailsStep2Title => 'Selecciona la duración del plan';

  @override
  String get walkiePlan_detailsSubtitleDefault =>
      'Acceso de voz instantáneo a walkie-talkie';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams =>
      'Excelente valor para equipos en crecimiento';

  @override
  String get walkiePlan_detailsSubtitleLongTerm =>
      'Lo mejor para uso a largo plazo';

  @override
  String get walkiePlan_detailsSubtitleShortTerm =>
      'Perfecto para uso a corto plazo';

  @override
  String get walkiePlan_detailsTabIndividual => 'Individual';

  @override
  String get walkiePlan_detailsTabMultipleMembers => 'Para varios miembros';

  @override
  String get walkiePlan_detailsTabPerPerson => 'Por persona';

  @override
  String get walkiePlan_detailsTeamSubtitle =>
      'Agrega miembros y conecta a todos con Walkie Talkie';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / Código QR';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return '¡Ahorras $amount con este cupón!';
  }

  @override
  String get walkiePlan_durationFallback => 'Duración';

  @override
  String get walkiePlan_durationMonthly => 'Mensual';

  @override
  String walkiePlan_durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_durationQuarterly => 'Trimestral';

  @override
  String get walkiePlan_durationYearly => 'Anual';

  @override
  String get walkiePlan_individualPlan => 'Plan individual';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return 'Plan $interval';
  }

  @override
  String get walkiePlan_monthlyPlan => 'Plan mensual';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'Sin conexión a internet. Comprueba tu red.';

  @override
  String get walkiePlan_order100Secure => '100% Seguro';

  @override
  String get walkiePlan_order3ds2Secure => 'Seguridad 3DS2';

  @override
  String get walkiePlan_orderAgreePrefix => 'Al continuar, aceptas nuestros ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => 'Monto tras descuento';

  @override
  String get walkiePlan_orderCards => 'Tarjetas';

  @override
  String get walkiePlan_orderChangeMethod => 'Cambiar método';

  @override
  String get walkiePlan_orderCouldNotStart =>
      'No se pudo iniciar el pago. Inténtalo de nuevo.';

  @override
  String get walkiePlan_orderCouponApplied => '¡Cupón aplicado con éxito!';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return '¡Cupón aplicado! Ahorraste $amount';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'Cupón eliminado con éxito';

  @override
  String get walkiePlan_orderCreateFailed =>
      'Error al crear la orden de pago. Inténtalo de nuevo.';

  @override
  String get walkiePlan_orderDiscount => 'Descuento';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return 'Descuento ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint =>
      'Elige GPay, PhonePe, tarjetas o transferencias en el siguiente paso.';

  @override
  String get walkiePlan_orderEncryptedPayment => 'Pago encriptado';

  @override
  String get walkiePlan_orderEnterValidCoupon =>
      'Ingresa un código de cupón válido';

  @override
  String get walkiePlan_orderForMultipleMembers => 'Para varios miembros';

  @override
  String get walkiePlan_orderForSingleMember => 'Para un solo miembro';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return 'IVA ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      'Paga seguro con tarjetas internacionales (Visa, Mastercard, Amex).';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      'Paga seguro con tarjetas internacionales o PayPal.';

  @override
  String get walkiePlan_orderInvalidCoupon =>
      'Código de cupón inválido o expirado';

  @override
  String walkiePlan_orderMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'Miembros';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros × $rate',
      one: '1 miembro × $rate',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderNetBanking => 'Banca por internet';

  @override
  String get walkiePlan_orderOnlineViaRazorpay => 'Pago en línea vía Razorpay';

  @override
  String get walkiePlan_orderOpeningCheckout =>
      'Abriendo la pasarela de pago Razorpay...';

  @override
  String get walkiePlan_orderPaymentDetails => 'Detalles del pago';

  @override
  String get walkiePlan_orderPaymentMethod => 'Método de pago';

  @override
  String get walkiePlan_orderPricePerMember => 'Precio por miembro';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return 'Proceder al pago • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => 'Procesando el pago...';

  @override
  String get walkiePlan_orderRetryPay => 'Reintentar pago';

  @override
  String get walkiePlan_orderSecureBadge => 'SEGURO';

  @override
  String get walkiePlan_orderSubtitle =>
      'Revisa los detalles del plan y procede al pago';

  @override
  String get walkiePlan_orderSubtotal => 'Subtotal';

  @override
  String get walkiePlan_orderTaxExport => 'Impuesto (0% Exportación)';

  @override
  String get walkiePlan_orderTermsConditions => 'Términos y condiciones';

  @override
  String get walkiePlan_orderTitle => 'Resumen del pedido';

  @override
  String get walkiePlan_orderTotalAmount => 'Monto total';

  @override
  String get walkiePlan_orderTotalPayable => 'Total a pagar';

  @override
  String get walkiePlan_orderUnableToLoad =>
      'No se pudo cargar el resumen del pedido.';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return 'IVA / Impuesto ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => 'Billeteras';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return '¡Ahorraste $amount en este pedido!';
  }

  @override
  String get walkiePlan_payAnnualPlan => 'Plan anual';

  @override
  String get walkiePlan_payBadgeCompleted => 'Completado';

  @override
  String get walkiePlan_payBadgeInProgress => 'En progreso';

  @override
  String get walkiePlan_payBadgePending => 'Pendiente';

  @override
  String get walkiePlan_payCancelledByUser =>
      'El usuario canceló el pago. No se ha cobrado ningún importe.';

  @override
  String get walkiePlan_payCouldNotBeProcessed => 'No se pudo procesar el pago';

  @override
  String get walkiePlan_payFailedContactSupport => 'Contactar soporte';

  @override
  String walkiePlan_payFailedOn(String time) {
    return 'Pago fallido el $time';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'No pudimos completar tu pago.\nInténtalo de nuevo o usa otro método.';

  @override
  String get walkiePlan_payFailedSubtitleShort =>
      'No pudimos completar tu pago';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      '¿Necesitas ayuda con el pago? Nuestro equipo está disponible 24/7.';

  @override
  String get walkiePlan_payFailedTitle => 'Pago fallido';

  @override
  String get walkiePlan_payIndividualFeatures =>
      'Monitoreo en tiempo real • Alertas instantáneas';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return 'Pago iniciado el $time';
  }

  @override
  String get walkiePlan_payIntervalMonth => 'mes';

  @override
  String get walkiePlan_payIntervalPlan => 'plan';

  @override
  String get walkiePlan_payIntervalQuarter => 'trimestre';

  @override
  String get walkiePlan_payIntervalYear => 'año';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'Tarjeta de crédito ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'Tarjeta de débito ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational =>
      'Tarjeta internacional / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'Banca por internet ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'Pago con Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'Checkout Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / Tarjeta)';

  @override
  String get walkiePlan_payMethodUpi => 'Pago UPI';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'Billetera ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue =>
      'Problema de conexión durante el pago. Comprueba tu internet.';

  @override
  String get walkiePlan_payNotCompleted =>
      'Tu pago no se completó. No se ha cobrado ningún monto.';

  @override
  String get walkiePlan_payOtpCharge => 'Cargo por OTP';

  @override
  String get walkiePlan_payOtpChargeDetails => 'Detalles del cargo OTP';

  @override
  String get walkiePlan_payOtpChargedPerLogin =>
      'Cobrado por inicio de sesión. Reenvío gratis';

  @override
  String get walkiePlan_payOtpCharges => 'Cargos de OTP';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'Por favor, no cierres la app. Te notificaremos cuando se confirme el pago.';

  @override
  String get walkiePlan_payPendingStillInProgress =>
      'Pago aún en curso. Te avisaremos cuando se confirme.';

  @override
  String get walkiePlan_payPendingStillProcessing =>
      'El pago aún se está procesando. Por favor, espera.';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      'El proveedor está procesando tu pago.\nPuede tardar unos minutos.';

  @override
  String get walkiePlan_payPendingSubtitleShort => 'Tu pago se está procesando';

  @override
  String get walkiePlan_payPendingTitle => 'Pago pendiente';

  @override
  String get walkiePlan_payPlanDetails => 'Detalles del plan';

  @override
  String get walkiePlan_payRefreshStatus => 'Actualizar estado';

  @override
  String get walkiePlan_payStatusTitle => 'Estado del pago';

  @override
  String get walkiePlan_payStepActivate => 'Activar plan';

  @override
  String get walkiePlan_payStepActivateSub =>
      'Tu plan se activará automáticamente';

  @override
  String get walkiePlan_payStepInitiated => 'Pago iniciado';

  @override
  String get walkiePlan_payStepProcessing => 'Procesando pago';

  @override
  String get walkiePlan_payStepProcessingSub => 'Se está confirmando tu pago';

  @override
  String get walkiePlan_payTeamFeatures =>
      'Acceso múltiple • Alertas instantáneas';

  @override
  String get walkiePlan_payTotalPerOtp => 'Total por OTP';

  @override
  String get walkiePlan_payTryAgain => 'Intentar de nuevo';

  @override
  String get walkiePlan_payViewPlanDetails => 'Ver detalles del plan';

  @override
  String get walkiePlan_perMember => 'por miembro';

  @override
  String get walkiePlan_planFallback => 'Plan';

  @override
  String get walkiePlan_quarterlyPlan => 'Plan trimestral';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'Por favor, completa la transacción en la ventana de Razorpay.';

  @override
  String get walkiePlan_razorpayCompletePayment => 'Completar pago';

  @override
  String get walkiePlan_razorpayConfirmingWithBank =>
      'Pago iniciado. Estamos confirmando con el banco.';

  @override
  String get walkiePlan_razorpayConnecting => 'Conectando con Razorpay...';

  @override
  String get walkiePlan_razorpayCouldNotProcess =>
      'El pago no se pudo procesar. Por favor, inténtalo de nuevo.';

  @override
  String get walkiePlan_razorpayFailedTryAgain =>
      'El pago falló. Inténtalo de nuevo.';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1 mes activo';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return 'Pagar $amount vía Razorpay';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => 'Pago cancelado';

  @override
  String get walkiePlan_razorpayPaymentIdCopied =>
      '¡ID de pago copiado al portapapeles!';

  @override
  String get walkiePlan_razorpayPciCompliant =>
      '100% Seguro y conforme a PCI-DSS';

  @override
  String get walkiePlan_razorpayPendingConfirmation =>
      'El pago está pendiente de confirmación.';

  @override
  String get walkiePlan_razorpayProcessing => 'Procesando con Razorpay...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return 'Monto: $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied =>
      '¡Detalles del recibo copiados!';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return 'Fecha: $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return 'Modo de pago: $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return 'ID de orden: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return 'ID de pago: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'Plan: $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => 'Estado: Completado';

  @override
  String get walkiePlan_razorpayReceiptTitle => 'Recibo de pago de FG Tracker';

  @override
  String get walkiePlan_razorpayRetryPayment => 'Reintentar pago';

  @override
  String get walkiePlan_razorpaySecureCheckout =>
      'Pago seguro respaldado por Razorpay';

  @override
  String get walkiePlan_razorpaySslEncrypted =>
      'Transacciones encriptadas con seguridad SSL de 256 bits.';

  @override
  String get walkiePlan_razorpaySupportedModes => 'Métodos de pago admitidos';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => 'Monto total a pagar';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return 'No se pudo abrir la pasarela: $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed => 'Error al verificar el pago.';

  @override
  String get walkiePlan_seatAssignedSeat => 'Plaza asignada';

  @override
  String get walkiePlan_seatAssignment => 'Asignación de plazas';

  @override
  String get walkiePlan_seatTeamAccess => 'Acceso de equipo';

  @override
  String get walkiePlan_seatTeamMember => 'Miembro del equipo';

  @override
  String get walkiePlan_secureEncryptedPayment => 'Pago seguro y encriptado';

  @override
  String get walkiePlan_successAccessActivated => 'Acceso activado';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      'Tu acceso personal a Walkie-Talkie está activo.';

  @override
  String get walkiePlan_successAmountPaid => 'Monto pagado';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'Puedes asignar acceso más tarde desde Ajustes del equipo.';

  @override
  String get walkiePlan_successAssignMembers => 'Asignar miembros';

  @override
  String get walkiePlan_successAssignWalkieAccess => 'Asignar acceso de walkie';

  @override
  String get walkiePlan_successChooseMembersDesc =>
      'Elige qué miembros pueden usar Walkie Talkie.';

  @override
  String get walkiePlan_successContinueHome => 'Continuar al inicio';

  @override
  String get walkiePlan_successDateTime => 'Fecha y hora';

  @override
  String get walkiePlan_successDefaultPaymentMethod =>
      'Razorpay (UPI / Tarjeta)';

  @override
  String get walkiePlan_successIndividualActive =>
      'Tu plan individual ya está activo';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      'Tu plan está activo. Ve al inicio y empieza a hablar.';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      'Tu suscripción individual está activa y vinculada a tu cuenta.';

  @override
  String get walkiePlan_successManageAccessNote =>
      'Puedes gestionar o cambiar el acceso en cualquier momento desde Ajustes.';

  @override
  String get walkiePlan_successMaybeLater => 'Quizás más tarde';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'Tu plan está activo. Los miembros no tendrán acceso hasta que los asignes.';

  @override
  String get walkiePlan_successNotNow => '¿Ahora no?';

  @override
  String get walkiePlan_successPaid => 'PAGADO';

  @override
  String get walkiePlan_successPaymentId => 'ID de pago';

  @override
  String get walkiePlan_successPaymentIdCopied =>
      '¡ID de pago copiado al portapapeles!';

  @override
  String get walkiePlan_successPaymentMode => 'Modo de pago';

  @override
  String get walkiePlan_successPaymentReceipt => 'Recibo de pago';

  @override
  String get walkiePlan_successPushToTalkDesc =>
      'Pulsa para hablar y conecta al instante.';

  @override
  String get walkiePlan_successRazorpayVerified => 'Verificado por Razorpay';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return 'Monto: $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied =>
      '¡Detalles del recibo copiados!';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return 'Fecha: $date';
  }

  @override
  String get walkiePlan_successReceiptHeader => 'Recibo de pago FG Tracker';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return 'ID de orden: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return 'ID de pago: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return 'Modo de pago: $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'Plan: $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => 'Estado: Completado';

  @override
  String get walkiePlan_successSelectChannel => 'Seleccionar canal';

  @override
  String get walkiePlan_successSelectChannelDesc =>
      'Únete a un grupo o canal para conectar con miembros.';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'Selecciona qué miembros usarán Walkie Talkie.';

  @override
  String get walkiePlan_successSetUpTeam => 'Configurar equipo';

  @override
  String get walkiePlan_successSetUpTeamDesc =>
      'Invita miembros y gestiona roles y permisos.';

  @override
  String get walkiePlan_successShareReceipt => 'Compartir recibo';

  @override
  String get walkiePlan_successStartCommunicating => 'Empieza a comunicarte';

  @override
  String get walkiePlan_successStatus => 'Estado';

  @override
  String get walkiePlan_successSuccessful => 'Exitoso';

  @override
  String get walkiePlan_successTeamActive => 'Tu plan de equipo ya está activo';

  @override
  String get walkiePlan_successTeamReady => '¡Tu equipo está listo!';

  @override
  String get walkiePlan_successTitle => '¡Compra exitosa!';

  @override
  String walkiePlan_successValidTill(String date) {
    return 'Válido hasta el $date';
  }

  @override
  String get walkiePlan_successVisitHome => 'Ir a la pantalla de inicio';

  @override
  String get walkiePlan_successWhatsNext => '¿Qué sigue?';

  @override
  String get walkiePlan_teamPlan => 'Plan de equipo';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'Plan de equipo ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => 'Período de prueba de 7 días';

  @override
  String get walkiePlan_trialActiveLabel => 'PRUEBA ACTIVA';

  @override
  String get walkiePlan_trialActiveSubscription => 'Suscripción activa';

  @override
  String get walkiePlan_trialActiveSubscriptions => 'Suscripciones activas';

  @override
  String get walkiePlan_trialAvailableToStart => 'Disponible para iniciar';

  @override
  String get walkiePlan_trialCheckConnectionRetry =>
      'Comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'Elige un plan abajo para empezar a usar Walkie Talkie.';

  @override
  String get walkiePlan_trialChooseSubscription =>
      'Elige una suscripción para continuar usando Walkie Talkie.';

  @override
  String get walkiePlan_trialCompleted => 'Prueba completada';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count días',
      one: 'Queda 1 día',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration Gratis';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return 'Finalizó el $date';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return 'Disfruta de todas las funciones de Walkie Talkie gratis por $duration.\nSin pagos.';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      'Disfruta de Walkie Talkie durante tu prueba.';

  @override
  String get walkiePlan_trialErrAccessMissing =>
      'Falta la información de acceso del walkie-talkie.';

  @override
  String get walkiePlan_trialErrFetchDetails =>
      'No se pudieron obtener los detalles del walkie-talkie.';

  @override
  String get walkiePlan_trialErrInvalidResponse =>
      'Respuesta no válida del servidor.';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get walkiePlan_trialErrOverviewMissing =>
      'Faltan datos generales del walkie-talkie.';

  @override
  String get walkiePlan_trialErrTimeout =>
      'Se agotó el tiempo de espera. Inténtalo de nuevo.';

  @override
  String get walkiePlan_trialErrUnableToLoad =>
      'No se pudieron cargar los detalles del walkie-talkie.';

  @override
  String get walkiePlan_trialExpired => 'Prueba expirada';

  @override
  String get walkiePlan_trialExpiredLabel => 'PRUEBA VENCIDA';

  @override
  String get walkiePlan_trialExpiringSoon => 'Expira pronto';

  @override
  String get walkiePlan_trialFeatClearAudio => 'Audio nítido';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'Voz de alta calidad';

  @override
  String get walkiePlan_trialFeatGroupComm => 'Comunicación grupal';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => 'Conecta con tu equipo';

  @override
  String get walkiePlan_trialFeatPtt => 'Pulsar para hablar';

  @override
  String get walkiePlan_trialFeatPttDesc => 'Comunicación de voz instantánea';

  @override
  String get walkiePlan_trialFeatUnlimited => 'Uso ilimitado';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => 'Usa sin ningún límite';

  @override
  String get walkiePlan_trialFreeAvailable => 'Prueba gratis disponible';

  @override
  String get walkiePlan_trialFreeTrialLabel => 'PRUEBA GRATIS';

  @override
  String get walkiePlan_trialFreeTrialRunning => 'Prueba gratis en curso';

  @override
  String get walkiePlan_trialFullAccess => 'Acceso total a todas las funciones';

  @override
  String get walkiePlan_trialFullyConsumed =>
      'Tu prueba gratis se ha consumido por completo.';

  @override
  String get walkiePlan_trialHasEnded => 'Tu prueba ha finalizado';

  @override
  String get walkiePlan_trialHeaderInstant =>
      'Comunícate al instante con tu grupo';

  @override
  String get walkiePlan_trialHeaderPlanStatus =>
      'Tu estado de plan y suscripción';

  @override
  String walkiePlan_trialHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count horas',
      one: 'Queda 1 hora',
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
  String get walkiePlan_trialIsActive => 'Tu prueba está activa';

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
      other: 'Quedan $count mins',
      one: 'Queda 1 min',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_trialNoActivePlan => 'Sin plan activo';

  @override
  String get walkiePlan_trialNoCardRequired =>
      'Usa en 7 días  •  Sin tarjeta requerida';

  @override
  String get walkiePlan_trialNoInternetTitle => 'Sin conexión a internet';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return 'Sin pago ahora. Luego puedes continuar con un plan de pago ($price/persona).';
  }

  @override
  String get walkiePlan_trialPeriodMonth => 'mes';

  @override
  String get walkiePlan_trialRetrying => 'Reintentando...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count s';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return 'Iniciar prueba gratis de $duration';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial => 'Comienza tu prueba gratis';

  @override
  String get walkiePlan_trialStatusCompleted => 'Completado';

  @override
  String get walkiePlan_trialStatusExpired => 'Expirado';

  @override
  String get walkiePlan_trialSubscriptionActive => 'Suscripción activa';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'Tu suscripción ha terminado. Renueva para seguir hablando.';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'Suscripción vencida';

  @override
  String get walkiePlan_trialTalkFree => 'Habla gratis con tu grupo.';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return 'Habla gratis con tu grupo hasta el $date.';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg =>
      'Tienes acceso a Walkie Talkie por el plan de equipo.';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return 'Queda $time';
  }

  @override
  String get walkiePlan_trialTimeRemaining => 'Tiempo de prueba restante';

  @override
  String get walkiePlan_trialTimeUsedUp => 'Tiempo de prueba agotado';

  @override
  String get walkiePlan_trialTryAgain => 'Intentar de nuevo';

  @override
  String get walkiePlan_trialUnableToLoadTitle =>
      'No se pudo cargar Walkie Talkie';

  @override
  String get walkiePlan_trialUsage => 'Uso de la prueba';

  @override
  String get walkiePlan_trialUseAnytime7Days =>
      'Usa la prueba cuando quieras en 7 días';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return 'Usa tu prueba de $duration en 7 días.';
  }

  @override
  String get walkiePlan_trialUsed => 'Prueba utilizada';

  @override
  String get walkiePlan_trialValidityPeriod =>
      'Período de validez de la prueba';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'Walkie-talkie';

  @override
  String get walkiePlan_trialWhatYouCanDo =>
      'Lo que puedes hacer durante la prueba';

  @override
  String get walkiePlan_unableToConnect =>
      'No se pudo conectar al servidor. Inténtalo de nuevo.';

  @override
  String get walkiePlan_yearlyPlan => 'Plan anual';

  @override
  String get walkie_aMember => 'Un miembro';

  @override
  String get walkie_accept => 'Aceptar';

  @override
  String get walkie_activeAccess => 'Acceso activo';

  @override
  String get walkie_activeBadge => 'Activo';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activos en Walkie',
      one: '1 activo en Walkie',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'Miembro activo';

  @override
  String get walkie_admin => 'Admin';

  @override
  String get walkie_adminMuted => 'Admin • Silenciado';

  @override
  String get walkie_adminOnlyAction => 'Acción solo para administradores';

  @override
  String get walkie_adminOnlyActionMessage =>
      'Solo el administrador del grupo puede enviar alertas de notificación a los miembros.';

  @override
  String walkie_alertSentMessage(String name) {
    return 'Notificación enviada a $name. Reintento disponible en 10 s.';
  }

  @override
  String get walkie_alertSentTitle => 'Alerta enviada';

  @override
  String get walkie_assignMembersToCommunicate =>
      'Asigna miembros para comunicarse en este grupo';

  @override
  String get walkie_assignedByYou => 'Asignado por ti';

  @override
  String walkie_assignedCount(int count) {
    return '$count asignados';
  }

  @override
  String get walkie_assignedSeats => 'Puestos asignados';

  @override
  String get walkie_audioBluetooth => 'Bluetooth';

  @override
  String get walkie_audioHeadset => 'Auriculares con micro';

  @override
  String get walkie_audioOutput => 'Salida de audio';

  @override
  String get walkie_audioPhone => 'Teléfono';

  @override
  String get walkie_audioSpeaker => 'Altavoz';

  @override
  String get walkie_audioWiredHeadphones => 'Auriculares con cable';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return 'Desbloqueo automático en $seconds s';
  }

  @override
  String get walkie_availableMembers => 'Miembros disponibles';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Puedes asignar hasta $count miembros en este grupo',
      one: 'Puedes asignar hasta 1 miembro en este grupo',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat =>
      'No se puede eliminar un puesto asignado por otro administrador';

  @override
  String get walkie_cannotSpeak => 'No se puede hablar en este canal';

  @override
  String get walkie_channelBusy => 'El canal está ocupado';

  @override
  String get walkie_channelLocked => 'Canal bloqueado';

  @override
  String get walkie_channelSpeaking => 'Canal transmitiendo...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return 'No se pudo establecer $group como canal de voz activo.';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'Error al cambiar de canal';

  @override
  String get walkie_channelUnlocked => 'Canal desbloqueado';

  @override
  String get walkie_chat => 'Chat';

  @override
  String get walkie_checkNetworkTryAgain =>
      'Comprueba tu conexión de red e inténtalo de nuevo.';

  @override
  String get walkie_chooseAPlan => 'Elige un plan';

  @override
  String get walkie_connected => 'Conectado';

  @override
  String get walkie_connectedWaiting =>
      'Conectado al canal • Esperando a que otros se unan';

  @override
  String get walkie_connectingChannel => 'Conectando al canal...';

  @override
  String get walkie_consumingTrial => 'Consumiendo prueba...';

  @override
  String get walkie_continueListenOnly => 'Continuar en modo de solo escucha';

  @override
  String walkie_currentlyAssigned(int count) {
    return 'Actualmente asignados ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'Grupo Walkie';

  @override
  String get walkie_description => 'Descripción';

  @override
  String get walkie_disconnected => 'Desconectado';

  @override
  String get walkie_editAssignedMembers => 'Editar miembros asignados';

  @override
  String get walkie_enable => 'Activar';

  @override
  String walkie_errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get walkie_exitWalkie => 'Salir de Walkie';

  @override
  String get walkie_exitWalkieMessage =>
      'Te desconectarás de este canal walkie. Seguirás siendo miembro del grupo.';

  @override
  String get walkie_exitWalkieTitle => '¿Salir de Walkie?';

  @override
  String get walkie_fairConnection => 'Conexión regular';

  @override
  String walkie_fairConnectionMs(int ms) {
    return 'Conexión regular ($ms ms)';
  }

  @override
  String get walkie_featureAllDevices => 'Úsalo en todos los dispositivos';

  @override
  String get walkie_featureEasyCoordination => 'Fácil coordinación grupal';

  @override
  String get walkie_featureHoldToTalk => 'Mantén pulsado para hablar';

  @override
  String get walkie_featurePtt => 'Pulsar para hablar';

  @override
  String get walkie_featureQuickGroup => 'Comunicación rápida en grupo';

  @override
  String get walkie_featureRealtime => 'Conectividad en tiempo real';

  @override
  String get walkie_featureSafeReliable => 'Seguro y confiable';

  @override
  String get walkie_featureStayConnected => 'Mantente siempre conectado';

  @override
  String get walkie_featureTeamCommunication => 'Comunicación de equipo';

  @override
  String get walkie_featureUnlimited => 'Ilimitado';

  @override
  String get walkie_fieldTeam => 'Equipo de campo';

  @override
  String get walkie_freeTrialEnded => 'Prueba gratuita finalizada';

  @override
  String get walkie_freeTrialEndedMessage =>
      'Tu prueba gratuita de 1 hora para Walkie Talkie ha finalizado.\nMejora ahora para seguir comunicándote con tu equipo.';

  @override
  String get walkie_freeTrialEndedTitle => 'Prueba gratuita finalizada';

  @override
  String get walkie_genericError => 'Error de Walkie Talkie';

  @override
  String get walkie_getPlan => 'Obtener plan';

  @override
  String walkie_goodConnectionMs(int ms) {
    return 'Buena conexión ($ms ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'Código de grupo: $code';
  }

  @override
  String get walkie_groupCommunication => 'Comunicación grupal';

  @override
  String get walkie_groupFallback => 'Grupo';

  @override
  String get walkie_groupMembers => 'Miembros del grupo';

  @override
  String get walkie_heroSubtitle =>
      'Usa la comunicación de voz pulsar para hablar con tu grupo sin hacer una llamada telefónica.';

  @override
  String get walkie_heroTitle => 'Mantente conectado, habla al instante';

  @override
  String get walkie_holdToTalk => 'Mantén pulsado para hablar';

  @override
  String get walkie_holdToTalkSlideLock =>
      'Mantén para hablar, desliza hacia arriba para bloquear';

  @override
  String get walkie_inWalkieChannel => 'En el canal Walkie';

  @override
  String get walkie_individualActiveUpgrade =>
      'Plan individual activo (Solo acceso personal) • Mejora a Plan de equipo para asignar miembros.';

  @override
  String get walkie_individualLimitMessage =>
      'Tu Plan individual permite 1 puesto solamente. Para asignar a varios miembros y conectar a todo tu equipo, actualiza a un Plan de equipo.';

  @override
  String get walkie_individualPlan => 'Plan individual';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (Individual)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      'Plan individual (Solo acceso personal) • Mejora a Equipo para asignar miembros';

  @override
  String get walkie_individualSubscribedSelf =>
      'Plan individual • Suscrito por ti mismo';

  @override
  String get walkie_info => 'Información';

  @override
  String walkie_isSpeaking(String name) {
    return '$name está hablando...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name está hablando...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidos',
      one: '1 unido',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return 'Última vez $time';
  }

  @override
  String get walkie_listenOnly => 'Solo escuchar';

  @override
  String get walkie_listenOnlyTapPlan =>
      'Solo escuchar — Toca para ver el plan';

  @override
  String get walkie_listening => 'Escuchando';

  @override
  String get walkie_listeningOnly => 'Solo escuchando';

  @override
  String get walkie_live => 'EN VIVO';

  @override
  String get walkie_lockTimeout =>
      'Tiempo de bloqueo agotado — Micrófono liberado';

  @override
  String get walkie_lockedTapMic => 'Bloqueado — Toca el micro para detener';

  @override
  String get walkie_maybeLater => 'Quizás más tarde';

  @override
  String get walkie_member => 'Miembro';

  @override
  String get walkie_membersInChannel => 'Miembros en el canal';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Miembros en línea',
      one: 'Miembro en línea',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed =>
      'Error al actualizar los miembros asignados';

  @override
  String get walkie_membersUpdated =>
      'Miembros asignados actualizados con éxito';

  @override
  String get walkie_micAccessRequired =>
      'Se requiere acceso al micrófono para hablar.';

  @override
  String get walkie_micDisabledMessage =>
      'El acceso al micrófono está desactivado en los ajustes del dispositivo. Para hablar en este grupo, permite el acceso en Ajustes.\n\nAún puedes escuchar a los demás miembros.';

  @override
  String get walkie_micPermissionRequired => 'Permiso de micrófono requerido';

  @override
  String get walkie_micPermissionTitle => 'Permiso de micrófono';

  @override
  String get walkie_micRequiredMessage =>
      'Se requiere permiso de micrófono para hablar en este grupo de Walkie-Talkie.\n\nPuedes seguir escuchando a los demás sin activar el micrófono.';

  @override
  String get walkie_muteMe => 'Silenciarme';

  @override
  String get walkie_muted => 'Silenciado';

  @override
  String get walkie_mutedInWalkie => 'Silenciado • En Walkie';

  @override
  String get walkie_mutedListeningOnly =>
      'Estás silenciado — Modo solo escucha';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name está hablando...';
  }

  @override
  String get walkie_noActivePlan => 'Sin plan activo';

  @override
  String get walkie_noAvailableMembers => 'No hay miembros disponibles';

  @override
  String get walkie_noBluetoothDevice =>
      'No hay ningún dispositivo Bluetooth conectado. Empareja tus auriculares en los ajustes.';

  @override
  String get walkie_noGroupsFound => 'No se encontraron grupos';

  @override
  String get walkie_noMembersAssigned =>
      'No hay miembros asignados actualmente';

  @override
  String get walkie_noMembersFound => 'No se encontraron miembros';

  @override
  String get walkie_noMembersFoundTitle => 'No se encontraron miembros';

  @override
  String get walkie_noMembersMatch => 'Ningún miembro coincide';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return 'Ningún miembro coincide con \'$query\'';
  }

  @override
  String get walkie_noMembersToAssign =>
      'No hay miembros del grupo disponibles para asignar.';

  @override
  String get walkie_noNameGroup => 'Grupo sin nombre';

  @override
  String get walkie_noPlanSubscribeAssign =>
      'Sin plan activo • Suscríbete para asignar miembros';

  @override
  String get walkie_noSeatMessage =>
      'Tienes un Plan de equipo activo, pero todos los puestos de voz están asignados actualmente a otros miembros.\n\nPuedes escuchar las conversaciones en tiempo real, pero para hablar debes asignarte un puesto o mejorar tu plan.';

  @override
  String get walkie_noSeatTitle => 'Sin puesto de voz asignado';

  @override
  String get walkie_noSeatsRefreshing =>
      'No hay puestos de equipo disponibles. Actualizando lista...';

  @override
  String get walkie_noSubscriptionMessage =>
      'No tienes una suscripción activa de Walkie Talkie. Suscríbete a un plan para asignar miembros y comenzar la comunicación de voz instantánea.';

  @override
  String get walkie_noTeamSubscription =>
      'No se encontró ninguna suscripción de equipo activa';

  @override
  String get walkie_noValidMembers =>
      'No hay miembros válidos seleccionados para asignar';

  @override
  String get walkie_noVoiceSeatListenOnly =>
      'Sin puesto de voz asignado — Modo solo escucha';

  @override
  String get walkie_noWiredDevice =>
      'No hay auriculares con cable conectados. Conéctalos a tu dispositivo.';

  @override
  String get walkie_notConnected => 'No conectado';

  @override
  String get walkie_notifLeave => 'Salir';

  @override
  String get walkie_notifOpenWalkie => 'Abrir Walkie';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name dejó de hablar';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name está hablando';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return 'No se pudo actualizar el ajuste de notificaciones para $group. Inténtalo de nuevo.';
  }

  @override
  String get walkie_notificationSettingTitle => 'Ajustes de notificaciones';

  @override
  String get walkie_onlyAdminCanAlert =>
      'Solo el admin del grupo puede enviar alertas';

  @override
  String get walkie_openWalkieTalkie => 'Abrir Walkie Talkie';

  @override
  String get walkie_otherTeam => 'Otro equipo';

  @override
  String get walkie_othersWontHear => 'Los demás no te escucharán';

  @override
  String get walkie_planRequiredTitle => 'Plan de Walkie Talkie requerido';

  @override
  String get walkie_planRequiredToTalk => 'Se requiere plan para hablar';

  @override
  String get walkie_planStartsOnFirstAssign =>
      'El plan comienza cuando se asigna el primer miembro.';

  @override
  String get walkie_poorConnection =>
      'Conexión débil — El audio puede tener retraso';

  @override
  String get walkie_preparingAudio => 'Preparando audio...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'Compra un Plan de equipo para asignar acceso de Walkie-Talkie a los miembros.';

  @override
  String get walkie_purchaseUpgradePlan => 'Comprar / Mejorar plan';

  @override
  String get walkie_ready => 'Listo';

  @override
  String get walkie_reconnecting => 'Reconectando...';

  @override
  String get walkie_reconnectingServer =>
      'Reconectando con el servidor walkie...';

  @override
  String get walkie_releaseToStop => 'Suelta para detener';

  @override
  String get walkie_removeAll => 'Eliminar todos';

  @override
  String get walkie_searchGroups => 'Buscar grupos';

  @override
  String get walkie_searchMembers => 'Buscar miembros...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total puestos';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '$total puestos totales • $assigned asignados • $available disponibles';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '$assigned / $total puestos usados';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get walkie_selectAtLeastOne =>
      'Por favor, selecciona al menos un miembro para asignar';

  @override
  String get walkie_selectGroupFirst =>
      'Por favor, selecciona un grupo primero';

  @override
  String get walkie_selectGroupToConnect => 'Selecciona un grupo para conectar';

  @override
  String get walkie_selected => 'Seleccionado';

  @override
  String get walkie_selfAccess => 'Acceso propio';

  @override
  String get walkie_selfPlan => 'Plan personal';

  @override
  String get walkie_slideUpToLock => 'Desliza hacia arriba para bloquear';

  @override
  String get walkie_someone => 'Alguien';

  @override
  String get walkie_someoneSpeaking => 'Alguien está hablando...';

  @override
  String get walkie_speaking => 'Hablando...';

  @override
  String walkie_startFreeTrial(String duration) {
    return 'Iniciar prueba gratuita de $duration';
  }

  @override
  String get walkie_strongConnection => 'Conexión fuerte';

  @override
  String walkie_strongConnectionMs(int ms) {
    return 'Conexión fuerte ($ms ms)';
  }

  @override
  String get walkie_subscribeToStartTalk =>
      'Suscríbete para hablar por voz y asignar miembros';

  @override
  String get walkie_subscribed => 'Suscrito';

  @override
  String get walkie_talking => 'Hablando...';

  @override
  String get walkie_tapToUnlock => 'Toca para desbloquear';

  @override
  String get walkie_teamAssignedElsewhere =>
      'Plan de equipo • Asignado en otro lugar';

  @override
  String get walkie_teamPlan => 'Plan de equipo';

  @override
  String get walkie_teamPlanRequired => 'Plan de equipo requerido';

  @override
  String get walkie_teamPlanRequiredToAssign =>
      'Se requiere Plan de equipo para asignar miembros';

  @override
  String get walkie_teamPlanStatus => 'Estado del Plan de equipo';

  @override
  String get walkie_teamSeatMember => 'Miembro con puesto de equipo';

  @override
  String get walkie_title => 'Walkie Talkie';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en total',
      one: '1 en total',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => 'Prueba activa de 1 h';

  @override
  String get walkie_trialEndedSubscribe =>
      'Prueba gratuita finalizada — Suscríbete para continuar';

  @override
  String get walkie_unableToConnectReconnecting =>
      'No se puede conectar al canal — Reconectando...';

  @override
  String get walkie_unavailable => 'No disponible';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'Actualizar miembros ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'Actualizando miembros...';

  @override
  String get walkie_upgradeAddSeats => 'Mejorar y añadir puestos';

  @override
  String get walkie_upgradeNow => 'Mejorar ahora';

  @override
  String get walkie_upgradeTeamAssign =>
      'Mejorar a Plan de equipo (Asignar miembros)';

  @override
  String get walkie_upgradeToTeamPlan => 'Mejorar a Plan de equipo';

  @override
  String walkie_userCancelled(String name) {
    return '$name canceló';
  }

  @override
  String walkie_userJoined(String name) {
    return '$name se unió';
  }

  @override
  String walkie_userLeft(String name) {
    return '$name salió';
  }

  @override
  String walkie_validTill(String date) {
    return 'Válido hasta $date';
  }

  @override
  String get walkie_viewPlan => 'Ver plan';

  @override
  String get walkie_voiceNotPermitted => 'Transmisión de voz no permitida';

  @override
  String get walkie_weakSignal => 'Señal débil';

  @override
  String walkie_weakSignalMs(int ms) {
    return 'Señal débil ($ms ms)';
  }

  @override
  String get walkie_youAreConnected => 'Estás conectado';

  @override
  String get walkie_yourVoiceAccess => 'Tu acceso de voz';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Descargar para Android: $playStoreLink\n\nDescargar para iOS: $appStoreLink';
  }

  @override
  String get widget_live => 'En vivo';

  @override
  String get widget_lostConnection => 'Conexión perdida';

  @override
  String get widget_manageGroups => 'Gestiona tus grupos fácilmente';

  @override
  String get widget_noInternetBody =>
      'Ups... no hay conexión a internet. Comprueba tu conexión';

  @override
  String get widget_notSeenYet => 'No visto aún';

  @override
  String get widget_pinnedMessage => 'Mensaje fijado';

  @override
  String get widget_private => 'Privado';

  @override
  String get widget_refreshPage => 'Actualizar la página';

  @override
  String get widget_seen => 'Visto';

  @override
  String widget_seenCount(int count) {
    return '($count)';
  }

  @override
  String widget_seenCountOfTotal(int count, int total) {
    return '($count de $total)';
  }

  @override
  String get widget_somethingWentWrongTitle => 'Algo salió mal';

  @override
  String get widget_userFallback => 'Usuario';
}
