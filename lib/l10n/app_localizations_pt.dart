// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get about_aboutUs => 'Sobre nós';

  @override
  String get about_address => 'Endereço';

  @override
  String get about_appBarTitle => 'Sobre o FG Tracker';

  @override
  String get about_company => 'Empresa';

  @override
  String get about_contactUs => 'Fale conosco';

  @override
  String get about_developerEmail => 'E-mail do desenvolvedor';

  @override
  String get about_downloadTitle => '📱 Baixar Aplicativo';

  @override
  String get about_howItWorksIntro =>
      'O FG Tracker simplifica a coordenação de viagens em grupo. Veja como:';

  @override
  String get about_howItWorksTitle => '⚙️ Como funciona';

  @override
  String get about_howStep1 => 'Crie um grupo';

  @override
  String get about_howStep2 =>
      'Compartilhe o código do grupo ou QR code com seus companheiros';

  @override
  String get about_howStep3 =>
      'Cada membro entra usando o código ou QR compartilhado';

  @override
  String get about_howStep4 =>
      'Acompanhe a localização ao vivo de todos em um mapa compartilhado em tempo real';

  @override
  String get about_howStep5 =>
      'Use o recurso de compartilhamento para convidar mais pessoas facilmente';

  @override
  String get about_intro =>
      'O FG Tracker é o seu companheiro ideal para se manter conectado e seguro ao viajar em grupo. Seja em uma viagem em família, um piquenique com amigos ou no trajeto com colegas, o FG Tracker garante que ninguém fique para trás.';

  @override
  String get about_privacyBody =>
      'Sua segurança e privacidade são essenciais. O FG Tracker não compartilha sua localização com ninguém fora do seu grupo. Todos os dados são criptografados e visíveis apenas para pessoas autorizadas.';

  @override
  String get about_privacyPolicy => 'Política de Privacidade';

  @override
  String get about_privacyTitle => '🔐 Privacidade e Segurança';

  @override
  String get about_supportEmail => 'E-mail de suporte';

  @override
  String get about_supportTitle => '📩 Suporte e Informações do Desenvolvedor';

  @override
  String get about_termsConditions => 'Termos e Condições';

  @override
  String get about_title => 'Sobre';

  @override
  String get about_website => 'Site';

  @override
  String get about_welcomeTitle => 'Bem-vindo ao FG Tracker';

  @override
  String get about_whyBuiltFor =>
      'Desenvolvido para famílias, amigos e pequenas equipes.';

  @override
  String get about_whyChooseTitle => '🌟 Por que escolher o FG Tracker?';

  @override
  String get about_whyEasy =>
      'Fácil de usar, leve e com controle total de privacidade.';

  @override
  String get about_whyNoCalls =>
      'Sem necessidade de ligar ou enviar mensagens: acompanhe ao vivo no mapa.';

  @override
  String get about_whyRealTime =>
      'Compartilhamento de localização em tempo real com todos os membros.';

  @override
  String appUpdate_checkError(String error) {
    return 'Erro ao verificar atualizações: $error';
  }

  @override
  String get appUpdate_exitConfirmTitle => 'Deseja sair?';

  @override
  String get appUpdate_noUpdateAvailable => 'Nenhuma atualização disponível';

  @override
  String get appUpdate_restartApp => 'Reiniciar Aplicativo';

  @override
  String get appUpdate_updateApp => 'Atualizar App';

  @override
  String get appUpdate_updateAvailable => 'Atualização Disponível';

  @override
  String get appUpdate_updateAvailableMessage =>
      'Uma nova atualização está disponível. Atualize o aplicativo';

  @override
  String get appUpdate_updateUnavailable => 'Atualização indisponível';

  @override
  String appUpdate_updatingProgress(int progress) {
    return 'Atualizando... $progress%';
  }

  @override
  String get attendance_addOption => 'Adicionar outra opção';

  @override
  String get attendance_admin => 'Admin';

  @override
  String get attendance_allowChange => 'Permitir alteração de resposta';

  @override
  String get attendance_allowChangeSubtitle =>
      'Membros podem alterar ou remover a resposta';

  @override
  String get attendance_askCommunity => 'Pergunte à sua comunidade';

  @override
  String get attendance_cameraPermissionRequired =>
      'A permissão de câmera é necessária para registrar a presença.';

  @override
  String get attendance_cameraStartFailed =>
      'Não foi possível iniciar a câmera.';

  @override
  String attendance_cameraStartFailedCode(String code) {
    return 'Não foi possível iniciar a câmera ($code).';
  }

  @override
  String get attendance_cameraStarting => 'Iniciando câmera…';

  @override
  String get attendance_captureFailedBlink =>
      'Não foi possível capturar. Pisque novamente para tentar';

  @override
  String attendance_capturedAtVerified(String time) {
    return 'Capturada às $time • Verificada';
  }

  @override
  String get attendance_capturedCheck => 'Capturado ✓';

  @override
  String get attendance_changeResponse => 'Alterar resposta';

  @override
  String get attendance_chooseFolder => 'Escolha uma pasta, ex: Downloads';

  @override
  String get attendance_closeAction => 'Encerrar presença';

  @override
  String get attendance_closeConfirmBody =>
      'Os membros não poderão responder após o encerramento.';

  @override
  String get attendance_closeConfirmTitle => 'Encerrar presença?';

  @override
  String get attendance_closeEndOfDay => 'Encerrar no fim do dia';

  @override
  String attendance_closeEndOfDaySubtitle(String time) {
    return 'Fecha automaticamente às $time de hoje';
  }

  @override
  String get attendance_closeFailed => 'Não foi possível encerrar a presença';

  @override
  String get attendance_closeFailedShort => 'Não foi possível encerrar';

  @override
  String attendance_closesAt(String dateTime) {
    return 'Fecha em $dateTime';
  }

  @override
  String get attendance_createFailed => 'Não foi possível criar a presença';

  @override
  String get attendance_createSubtitle =>
      'Enviar enquete de presença para este grupo';

  @override
  String get attendance_createTitle => 'Criar presença';

  @override
  String get attendance_created => 'Presença criada';

  @override
  String get attendance_dateEnded =>
      'A data selecionada já terminou. Escolha outra data.';

  @override
  String get attendance_dateToday => 'Data (hoje)';

  @override
  String get attendance_dateTodaySemantics => 'Data da presença, hoje';

  @override
  String get attendance_deleteFailed => 'Não foi possível excluir a presença';

  @override
  String get attendance_deletedText => 'Esta presença foi excluída';

  @override
  String get attendance_downloadReport => 'Baixar relatório';

  @override
  String get attendance_everyoneResponded => 'Todos responderam';

  @override
  String get attendance_faceDetectedBlink =>
      'Rosto detectado — agora pisque os olhos';

  @override
  String get attendance_failed => 'Falha na presença';

  @override
  String attendance_filterNotRespondedCount(int count) {
    return 'Não responderam ($count)';
  }

  @override
  String attendance_filterResponded(int count) {
    return 'Responderam ($count)';
  }

  @override
  String get attendance_fixErrors =>
      'Corrija os erros destacados antes de enviar';

  @override
  String get attendance_holdStill => 'Fique parado…';

  @override
  String get attendance_howToTakePhoto => 'Como tirar sua foto';

  @override
  String get attendance_invalidGroup =>
      'Grupo inválido. Abra a conversa novamente.';

  @override
  String get attendance_keepFaceInCircle =>
      'Mantenha seu rosto dentro do círculo';

  @override
  String get attendance_limitReached => 'Limite atingido';

  @override
  String get attendance_loadFailed => 'Não foi possível carregar a presença';

  @override
  String get attendance_loadMore => 'Carregar mais';

  @override
  String get attendance_loadMoreFailed => 'Não foi possível carregar mais';

  @override
  String get attendance_loadVotersFailed =>
      'Não foi possível carregar os votantes';

  @override
  String get attendance_lookAtCamera => 'Olhe para a câmera';

  @override
  String get attendance_lookStraight => 'Olhe direto para a câmera';

  @override
  String get attendance_markYourAttendance => 'Registre sua presença';

  @override
  String attendance_markedAs(String option) {
    return 'Marcado como $option';
  }

  @override
  String get attendance_markedSuccess => 'Presença registrada com sucesso';

  @override
  String attendance_maxOptions(int count) {
    return 'Você pode adicionar até $count opções apenas';
  }

  @override
  String get attendance_members => 'Membros';

  @override
  String attendance_membersWithCount(int count) {
    return 'Membros ($count)';
  }

  @override
  String attendance_minOptions(int count) {
    return 'Pelo menos $count opções são necessárias';
  }

  @override
  String get attendance_moveCloser => 'Aproxime-se um pouco';

  @override
  String get attendance_multipleFaces =>
      'Vários rostos detectados — apenas você deve estar no enquadramento';

  @override
  String get attendance_noCsvApp =>
      'Nenhum app encontrado para abrir arquivos CSV. Use Salvar ou Compartilhar.';

  @override
  String get attendance_noFace => 'Nenhum rosto detectado';

  @override
  String get attendance_noFrontCamera =>
      'Nenhuma câmera frontal encontrada neste dispositivo.';

  @override
  String get attendance_noLocation => 'Nenhuma localização disponível';

  @override
  String get attendance_noMembersMatch =>
      'Nenhum membro corresponde à sua pesquisa';

  @override
  String get attendance_noResponses => 'Nenhuma resposta ainda';

  @override
  String get attendance_notResponded => 'Não responderam';

  @override
  String get attendance_openEyes => 'Abra os olhos e olhe para a câmera';

  @override
  String get attendance_openMapFailed => 'Não foi possível abrir o mapa';

  @override
  String get attendance_openSubtitle => 'Ver no Excel, Sheets ou outro app';

  @override
  String get attendance_optionHint => 'Digite o rótulo da opção';

  @override
  String get attendance_optionLabelRequired =>
      'Todas as opções devem ter um rótulo';

  @override
  String attendance_optionNumber(int number) {
    return 'Opção $number';
  }

  @override
  String attendance_optionPhotoRequired(int number) {
    return 'Opção $number • 📷 Foto obrigatória';
  }

  @override
  String get attendance_optionsUnique => 'As opções devem ser exclusivas';

  @override
  String get attendance_photoCaptured => 'Foto capturada';

  @override
  String get attendance_photoCapturedTapRetake =>
      'Foto capturada ✓ (Toque para tirar novamente)';

  @override
  String get attendance_photoProof => 'Comprovante com foto';

  @override
  String attendance_photoProofOf(String name) {
    return 'Comprovante com foto de $name';
  }

  @override
  String attendance_photoRequiredFor(String option) {
    return '⚠ Foto obrigatória para $option';
  }

  @override
  String get attendance_photoRules =>
      'Apenas a câmera frontal é usada. A foto é tirada automaticamente quando você pisca, e uploads da galeria não são permitidos.';

  @override
  String get attendance_photoSubtitle =>
      'Tire uma foto ao vivo para verificar sua presença';

  @override
  String get attendance_photoTitle => 'Foto de presença';

  @override
  String get attendance_photoVerified => 'Foto verificada';

  @override
  String get attendance_questionHint => 'Você estará disponível hoje?';

  @override
  String get attendance_questionLabel => 'Pergunta de presença';

  @override
  String get attendance_questionRequired =>
      'A pergunta de presença é obrigatória';

  @override
  String attendance_questionTooShort(int count) {
    return 'A pergunta deve ter pelo menos $count caracteres';
  }

  @override
  String get attendance_removeFailedShort => 'Não foi possível remover';

  @override
  String get attendance_removeResponseBody =>
      'Sua presença nesta enquete será apagada.';

  @override
  String get attendance_removeResponseTitle => 'Remover sua resposta?';

  @override
  String get attendance_removeVoteFailed => 'Não foi possível remover o voto';

  @override
  String get attendance_reportEmpty => 'O relatório está vazio';

  @override
  String get attendance_reportFailed => 'Falha no relatório';

  @override
  String get attendance_reportInvalid =>
      'O servidor retornou um relatório inválido. Tente novamente.';

  @override
  String attendance_reportReady(String fileName) {
    return 'Relatório pronto • $fileName';
  }

  @override
  String get attendance_reportSaved => 'Relatório salvo';

  @override
  String get attendance_reportSubject => 'Relatório de presença';

  @override
  String attendance_reportSubjectWithTitle(String title) {
    return 'Relatório de presença • $title';
  }

  @override
  String attendance_respondedCount(int count) {
    return '$count responderam';
  }

  @override
  String get attendance_retakePhoto => 'Tirar foto novamente';

  @override
  String get attendance_saveInFiles => 'Salvar no app Arquivos';

  @override
  String get attendance_saveReportDialog => 'Salvar relatório de presença';

  @override
  String get attendance_saveToDevice => 'Salvar no dispositivo';

  @override
  String get attendance_searchMember => 'Pesquisar membro';

  @override
  String get attendance_selectPhotoOption =>
      'Selecione uma opção para exigir foto ao vivo';

  @override
  String get attendance_selectStatus => 'Selecione seu status';

  @override
  String get attendance_sentToAllMembers =>
      'Enviado para todos os membros deste grupo';

  @override
  String get attendance_sentToGroup => 'Presença enviada para o grupo';

  @override
  String get attendance_shareSubtitle => 'Enviar via WhatsApp, e-mail...';

  @override
  String get attendance_statusCompleted => 'Concluída';

  @override
  String get attendance_statusOpen => 'Aberta';

  @override
  String get attendance_stepBlink => 'Pisque os olhos para capturar sua foto';

  @override
  String get attendance_stepEyeLevel => 'Segure o celular na altura dos olhos';

  @override
  String get attendance_submit => 'Enviar presença';

  @override
  String get attendance_submitted => 'Presença enviada';

  @override
  String get attendance_title => 'Presença';

  @override
  String get attendance_update => 'Atualizar presença';

  @override
  String get attendance_validationError => 'Erro de validação';

  @override
  String get attendance_view => 'Ver';

  @override
  String get attendance_viewTitle => 'Visualizar presença';

  @override
  String get attendance_voteFailed => 'Não foi possível registrar o voto';

  @override
  String attendance_withinKm(String km) {
    return 'A menos de $km km';
  }

  @override
  String attendance_withinMeters(int count) {
    return 'A menos de $count m';
  }

  @override
  String get call_accept => 'Aceitar';

  @override
  String get call_allContacts => 'Todos os contatos';

  @override
  String get call_allowAccess => 'Permitir acesso';

  @override
  String get call_answer => 'Atender';

  @override
  String get call_audioOutput => 'Saída de áudio';

  @override
  String get call_callFrom => 'Chamada de';

  @override
  String get call_callIdNotFound => 'ID da chamada não encontrado';

  @override
  String get call_callInformation => 'Informações da chamada';

  @override
  String get call_callSummary => 'Resumo da chamada';

  @override
  String get call_caller => 'Autor da chamada';

  @override
  String call_callerAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name e mais $count',
      one: '$name e mais 1',
      zero: '$name',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleteFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível excluir $count chamadas. Tente novamente.',
      one: 'Não foi possível excluir 1 chamada. Tente novamente.',
    );
    return '$_temp0';
  }

  @override
  String call_callsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chamadas excluídas',
      one: '1 chamada excluída',
    );
    return '$_temp0';
  }

  @override
  String get call_camera => 'Câmera';

  @override
  String get call_cameraMicRequired =>
      'Permissões de câmera ou microfone são necessárias';

  @override
  String get call_cameraOff => 'Câmera desligada';

  @override
  String get call_cameraOn => 'Câmera ligada';

  @override
  String get call_cameraUnavailable =>
      'O acesso à câmera está indisponível no momento. Tente novamente mais tarde.';

  @override
  String get call_cannotReachCallServer =>
      'Não foi possível conectar ao servidor de chamadas. Verifique sua rede.';

  @override
  String get call_chatFallback => 'Chat';

  @override
  String get call_closeFullScreen => 'Sair da tela cheia';

  @override
  String get call_communicationUnavailable =>
      'A comunicação não está disponível com este usuário';

  @override
  String get call_connectingProgress => 'Conectando…';

  @override
  String get call_connectionTimeout => 'Tempo limite de conexão esgotado';

  @override
  String get call_contactInformation => 'Informações de contato';

  @override
  String get call_contactsAccessBannerMessage =>
      'Encontre e ligue para os membros da sua equipe facilmente.';

  @override
  String get call_contactsAccessBannerTitle =>
      'Permita o acesso aos seus contatos';

  @override
  String get call_contactsAccessMessage =>
      'Precisamos de acesso aos seus contatos para mostrar quem está no FG Tracker e permitir que você ligue ou envie um convite.';

  @override
  String get call_contactsAccessTitle => 'Permitir acesso aos contatos';

  @override
  String get call_decline => 'Recusar';

  @override
  String get call_deleteCallsMessage =>
      'Essas chamadas serão removidas do seu histórico.';

  @override
  String call_deleteCallsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count chamadas?',
      one: 'Excluir 1 chamada?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteHistoryMessage =>
      'Tem certeza de que deseja excluir este histórico de chamadas?';

  @override
  String get call_deleteHistoryTitle => 'Excluir histórico de chamadas';

  @override
  String call_deleteSelectedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tem certeza de que deseja excluir estas $count entradas selecionadas do histórico?',
      one:
          'Tem certeza de que deseja excluir este histórico de chamada selecionado?',
    );
    return '$_temp0';
  }

  @override
  String get call_deleteSelectedTitle => 'Excluir chamadas selecionadas';

  @override
  String call_deleteWithCount(int count) {
    return 'Excluir ($count)';
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
  String get call_duration => 'Duração';

  @override
  String call_durationValue(String duration) {
    return 'Duração: $duration';
  }

  @override
  String get call_earpiece => 'Auricular';

  @override
  String get call_endCall => 'Encerrar chamada';

  @override
  String get call_ended => 'Encerrada';

  @override
  String get call_enterNumber => 'Digite o número';

  @override
  String get call_enterPhoneNumber => 'Por favor, insira um número de telefone';

  @override
  String get call_entryDeleteFailed => 'Falha ao excluir registro de chamada';

  @override
  String call_entryDeleteFailedError(String error) {
    return 'Falha ao excluir registro de chamada: $error';
  }

  @override
  String get call_entryDeleted => 'Registro de chamada excluído';

  @override
  String get call_everyoneInCall => 'Todos já estão na chamada';

  @override
  String get call_failedTitle => 'Falha na chamada';

  @override
  String get call_groupBadge => 'Grupo';

  @override
  String get call_groupCallComingSoon => 'Chamadas em grupo em breve';

  @override
  String get call_groupCallInitFailed =>
      'Não foi possível inicializar a chamada em grupo';

  @override
  String get call_groupCallStartFailed =>
      'Não foi possível iniciar a chamada em grupo. Tente novamente.';

  @override
  String get call_groupInformation => 'Informações do grupo';

  @override
  String call_groupWithId(String id) {
    return 'Grupo $id';
  }

  @override
  String get call_headphones => 'Fones de ouvido';

  @override
  String call_historyCancelled(String callType) {
    return '$callType cancelada';
  }

  @override
  String get call_historyClearFailed => 'Falha ao limpar histórico de chamadas';

  @override
  String call_historyClearFailedError(String error) {
    return 'Falha ao limpar histórico de chamadas: $error';
  }

  @override
  String get call_historyCleared => 'Todo o histórico de chamadas foi limpo';

  @override
  String call_historyIncoming(String callType) {
    return '$callType recebida';
  }

  @override
  String call_historyMissed(String callType) {
    return '$callType perdida';
  }

  @override
  String call_historyOutgoing(String callType) {
    return '$callType efetuada';
  }

  @override
  String call_historyRejected(String callType) {
    return '$callType recusada';
  }

  @override
  String get call_inCall => 'Em chamada';

  @override
  String call_inCallWithGroup(String groupName) {
    return 'Em chamada · $groupName';
  }

  @override
  String call_inThisCall(int count) {
    return 'Nesta chamada ($count)';
  }

  @override
  String get call_incomingAudio => 'Chamada de voz recebida';

  @override
  String get call_incomingCallChannelName => 'Chamada recebida';

  @override
  String get call_incomingGroupAudio => 'Chamada de voz em grupo recebida';

  @override
  String get call_incomingGroupVideo => 'Chamada de vídeo em grupo recebida';

  @override
  String get call_incomingVideo => 'Chamada de vídeo recebida';

  @override
  String get call_infoDescription => 'Descrição';

  @override
  String get call_infoEmail => 'E-mail';

  @override
  String get call_infoGroupCode => 'Código do grupo';

  @override
  String get call_infoGroupName => 'Nome do grupo';

  @override
  String get call_infoMobile => 'Celular';

  @override
  String get call_infoTotalMembers => 'Total de membros';

  @override
  String get call_invite => 'Convidar';

  @override
  String get call_inviteToApp => 'Convidar para o FG Tracker';

  @override
  String get call_join => 'Entrar';

  @override
  String get call_joinOnAnswer => 'Você entrará assim que atender';

  @override
  String get call_kindAudio => 'Chamada de voz';

  @override
  String get call_kindCall => 'Chamada';

  @override
  String get call_kindGroupAudio => 'Chamada de voz em grupo';

  @override
  String get call_kindGroupCall => 'Chamada em grupo';

  @override
  String call_kindGroupOther(String kind) {
    return 'Chamada em grupo $kind';
  }

  @override
  String get call_kindGroupVideo => 'Chamada de vídeo em grupo';

  @override
  String call_kindOther(String kind) {
    return 'Chamada $kind';
  }

  @override
  String get call_kindVideo => 'Chamada de vídeo';

  @override
  String get call_loadDetailFailed => 'Falha ao carregar detalhes da chamada';

  @override
  String get call_loadMore => 'Carregar mais';

  @override
  String get call_loadRecentFailed => 'Falha ao carregar chamadas recentes';

  @override
  String get call_loginToCall => 'Por favor, faça login para fazer uma chamada';

  @override
  String call_membersInCall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros nesta chamada',
      one: '1 membro nesta chamada',
    );
    return '$_temp0';
  }

  @override
  String get call_message => 'Mensagem';

  @override
  String get call_micActive => 'O microfone está ativo';

  @override
  String get call_missedCall => 'Chamada perdida';

  @override
  String get call_missedCallChannelName => 'Chamada perdida';

  @override
  String get call_missedCallNotification => 'Chamada perdida';

  @override
  String get call_more => 'Mais';

  @override
  String get call_mute => 'Mudo';

  @override
  String get call_muted => 'Mutado';

  @override
  String call_nameYou(String name) {
    return '$name (Você)';
  }

  @override
  String get call_noActiveParticipants => 'Nenhum participante ativo';

  @override
  String get call_noContactsMatch =>
      'Nenhum contato corresponde à sua pesquisa';

  @override
  String get call_noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get call_noGroupsYet => 'Nenhum grupo ainda';

  @override
  String get call_noNameGroup => 'Grupo sem nome';

  @override
  String get call_noRecentCalls => 'Sem chamadas recentes';

  @override
  String get call_noRecentMatch =>
      'Nenhuma chamada recente corresponde à sua pesquisa';

  @override
  String get call_noRecentYet => 'Nenhuma chamada recente ainda';

  @override
  String get call_noRegisteredContacts =>
      'Nenhum contato cadastrado encontrado';

  @override
  String get call_notInContacts => 'Este número não está em seus contatos';

  @override
  String call_notInThisCall(int count) {
    return 'Fora desta chamada ($count)';
  }

  @override
  String get call_notReady => 'Chamada não pronta';

  @override
  String get call_notificationPermissionRationale =>
      'Necessário para exibir chamadas recebidas.';

  @override
  String get call_notificationPermissionSettings =>
      'Ative as notificações nas Configurações.';

  @override
  String get call_notificationPermissionTitle => 'Permissão de notificação';

  @override
  String get call_notify => 'Notificar';

  @override
  String get call_notifyFailed => 'Falha ao notificar';

  @override
  String get call_notifySent => 'Notificado com sucesso';

  @override
  String get call_ongoingChannelDescription =>
      'Mantém a chamada e o compartilhamento de tela ativos';

  @override
  String get call_ongoingChannelName => 'Chamada em andamento';

  @override
  String get call_otherAlreadySharing =>
      'A outra pessoa já está compartilhando a tela';

  @override
  String get call_otherStartingVideo => 'A outra pessoa está iniciando o vídeo';

  @override
  String get call_participant => 'Participante';

  @override
  String get call_participants => 'Participantes';

  @override
  String call_personIsSharing(String name) {
    return '$name está compartilhando';
  }

  @override
  String call_personSharingScreen(String name) {
    return '$name está compartilhando a tela';
  }

  @override
  String get call_phone => 'Telefone';

  @override
  String get call_pleaseWait => 'Por favor, aguarde';

  @override
  String get call_recentCalls => 'Chamadas recentes';

  @override
  String get call_resetZoom => 'Redefinir zoom';

  @override
  String get call_returnToCall => 'Voltar à chamada';

  @override
  String get call_screenBeingShared => 'A tela está sendo compartilhada';

  @override
  String get call_screenShareChannelDescription =>
      'Notificação de sessão ativa de compartilhamento de tela';

  @override
  String get call_screenShareChannelName =>
      'Serviço de compartilhamento de tela';

  @override
  String get call_screenSharePermissionDenied =>
      'Permissão de compartilhamento de tela negada';

  @override
  String get call_screenShareStartFailed =>
      'Não foi possível iniciar o compartilhamento de tela';

  @override
  String get call_screenShareStopped => 'Compartilhamento de tela interrompido';

  @override
  String get call_screenSharingTitle => 'Compartilhamento de tela';

  @override
  String call_screenVisibleToName(String name) {
    return 'Sua tela está visível para $name';
  }

  @override
  String get call_screenVisibleToOther =>
      'Sua tela está visível para a outra pessoa';

  @override
  String get call_searchHint => 'Pesquisar contatos ou grupos';

  @override
  String get call_sectionLastWeek => 'Semana passada';

  @override
  String get call_sectionOlder => 'Mais antigos';

  @override
  String get call_sectionThisWeek => 'Esta semana';

  @override
  String get call_selectAll => 'Selecionar tudo';

  @override
  String call_selectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String get call_selectedDeleteFailed =>
      'Falha ao excluir chamadas selecionadas';

  @override
  String call_selectedDeleteFailedError(String error) {
    return 'Falha ao excluir chamadas selecionadas: $error';
  }

  @override
  String get call_selectedDeleted => 'Chamadas selecionadas excluídas';

  @override
  String get call_selfCallWarning =>
      'Você não pode ligar para o seu próprio número.';

  @override
  String get call_sessionConnectFailed =>
      'Falha ao conectar à sessão de chamada';

  @override
  String get call_shareScreen => 'Compartilhar tela';

  @override
  String get call_shareScreenShort => 'Compartilhar';

  @override
  String call_sharingInGroupTapReturn(String groupName) {
    return 'Compartilhando em $groupName • Toque para retornar';
  }

  @override
  String get call_sharingYourScreen => 'Compartilhando sua tela';

  @override
  String get call_someone => 'Alguém';

  @override
  String get call_speaker => 'Alto-falante';

  @override
  String get call_started => 'Iniciada';

  @override
  String get call_startingScreenShare => 'Iniciando compartilhamento de tela…';

  @override
  String get call_statusBusy => 'Ocupado';

  @override
  String get call_statusCalling => 'Chamando';

  @override
  String get call_statusCancelled => 'Cancelada';

  @override
  String get call_statusCompleted => 'Concluída';

  @override
  String get call_statusConnected => 'Conectado';

  @override
  String get call_statusConnecting => 'Conectando';

  @override
  String get call_statusDeclined => 'Recusada';

  @override
  String get call_statusJoined => 'Entrou';

  @override
  String get call_statusMissed => 'Perdida';

  @override
  String get call_statusReconnecting => 'Reconectando';

  @override
  String get call_statusRinging => 'Chamando';

  @override
  String get call_statusVideoConnecting => 'Conectando vídeo';

  @override
  String get call_stop => 'Parar';

  @override
  String get call_stopSharing => 'Parar compartilhamento';

  @override
  String get call_subtitle => 'Chamada de áudio / vídeo';

  @override
  String get call_swipeUpToAnswer => 'Deslize para cima para atender';

  @override
  String get call_switch => 'Alternar';

  @override
  String get call_switchCameraFailed => 'Não foi possível alternar a câmera';

  @override
  String get call_switchToVideoToShare =>
      'Mude para chamada de vídeo para compartilhar a tela';

  @override
  String get call_tabContacts => 'Contatos';

  @override
  String get call_tabGroups => 'Grupos';

  @override
  String get call_tabRecent => 'Recentes';

  @override
  String get call_tapNotifyToInvite => 'Toque em notificar para convidar';

  @override
  String get call_tapStartBroadcastHint =>
      'Toque em Iniciar transmissão se o aviso do sistema aparecer';

  @override
  String get call_title => 'Chamada';

  @override
  String call_todayAt(String value) {
    return 'Hoje, $value';
  }

  @override
  String get call_total => 'Total';

  @override
  String get call_turnOnVideo => 'Ative seu vídeo';

  @override
  String get call_unableToCallContact =>
      'Não foi possível ligar para este contato';

  @override
  String get call_unableToMakeCall => 'Não foi possível fazer a chamada';

  @override
  String get call_unableToOpenChat =>
      'Não foi possível abrir a conversa com este contato';

  @override
  String get call_unableToShareScreen => 'Não foi possível compartilhar a tela';

  @override
  String get call_unavailableTitle => 'Chamada indisponível';

  @override
  String get call_unexpectedResponse => 'Resposta inesperada do servidor';

  @override
  String get call_unknown => 'Desconhecido';

  @override
  String get call_unknownGroup => 'Grupo desconhecido';

  @override
  String get call_unknownUser => 'Usuário desconhecido';

  @override
  String get call_unmute => 'Ativar microfone';

  @override
  String get call_unselectAll => 'Desmarcar tudo';

  @override
  String get call_user => 'Usuário';

  @override
  String get call_userNotFound => 'Usuário não encontrado';

  @override
  String call_userWithId(String id) {
    return 'Usuário $id';
  }

  @override
  String get call_video => 'Vídeo';

  @override
  String get call_waitingForBroadcast => 'Aguardando início da transmissão';

  @override
  String get call_waitingForBroadcastMessage =>
      'Toque em \"Iniciar transmissão\" na caixa de diálogo do sistema para compartilhar sua tela.';

  @override
  String get call_waitingForMedia => 'Aguardando transmissão de mídia...';

  @override
  String get call_wired => 'Com fio';

  @override
  String get call_yesDelete => 'Sim, excluir';

  @override
  String call_yesterdayAt(String value) {
    return 'Ontem, $value';
  }

  @override
  String get call_youAreSharing => 'Você está compartilhando';

  @override
  String get call_youAreSharingScreen => 'Você está compartilhando sua tela';

  @override
  String get call_zoomIn => 'Aproximar';

  @override
  String get call_zoomOut => 'Afastar';

  @override
  String get chatList_allChats => 'Todas as conversas';

  @override
  String get chatList_allContacts => 'Todos os contatos';

  @override
  String get chatList_allowAccess => 'Permitir acesso';

  @override
  String get chatList_allowContactsBody =>
      'Precisamos de acesso aos seus contatos para mostrar quem está no FG Tracker e permitir que você inicie uma conversa ou envie um convite.';

  @override
  String get chatList_allowContactsTitle => 'Permitir acesso aos contatos';

  @override
  String get chatList_archiveChat => 'Arquivar conversa';

  @override
  String get chatList_archived => 'Arquivado';

  @override
  String get chatList_archivedChatsSubtitle => 'Suas conversas ocultas';

  @override
  String get chatList_archivedChatsTitle => 'Conversas arquivadas';

  @override
  String chatList_archivedCount(int count) {
    return 'Arquivados ($count)';
  }

  @override
  String get chatList_block => 'Bloquear';

  @override
  String get chatList_blockFailed => 'Não foi possível bloquear o usuário';

  @override
  String chatList_blockName(String name) {
    return 'Bloquear $name';
  }

  @override
  String get chatList_blockUser => 'Bloquear usuário';

  @override
  String get chatList_blockUserConfirm =>
      'Tem certeza de que deseja bloquear este usuário?';

  @override
  String get chatList_blocked => 'Bloqueado';

  @override
  String get chatList_chatCleared => 'Conversa limpa';

  @override
  String get chatList_chooseContactToShare =>
      'Escolha um contato para compartilhar na conversa.';

  @override
  String get chatList_clear => 'Limpar';

  @override
  String get chatList_clearChat => 'Limpar conversa';

  @override
  String get chatList_clearChatConfirm =>
      'Excluir todas as mensagens com este usuário?';

  @override
  String get chatList_clearChatFailed => 'Não foi possível limpar a conversa';

  @override
  String get chatList_clearSearch => 'Limpar pesquisa';

  @override
  String get chatList_contactAndInfo => 'Contato e informações';

  @override
  String get chatList_contactPermissionNeededMsg =>
      'A permissão de contatos é necessária para compartilhar um contato no chat.';

  @override
  String chatList_contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos',
      one: '1 contato',
    );
    return '$_temp0';
  }

  @override
  String chatList_contactsLoadFailed(String error) {
    return 'Falha ao carregar contatos: $error';
  }

  @override
  String get chatList_contactsPermissionNeeded =>
      'Permissão de contatos necessária';

  @override
  String get chatList_contactsWillAppear =>
      'Seus contatos aparecerão aqui quando disponíveis.';

  @override
  String chatList_daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get chatList_deactivated => 'Desativado';

  @override
  String get chatList_defaultAbout => 'Olá! Estou usando o FG Tracker';

  @override
  String get chatList_deleteChat => 'Excluir conversa';

  @override
  String get chatList_deleteChatConfirm =>
      'Excluir esta conversa da sua lista de chats?';

  @override
  String get chatList_forwardFailed =>
      'Não foi possível encaminhar a mensagem.';

  @override
  String get chatList_forwardListLoadFailed =>
      'Não foi possível carregar a lista de encaminhamento.';

  @override
  String get chatList_forwardTo => 'Encaminhar para...';

  @override
  String get chatList_forwarded => 'Encaminhada';

  @override
  String get chatList_groupChatFallback => 'Conversa em grupo';

  @override
  String get chatList_groupDeactivatedBanner =>
      'Este grupo foi desativado pelo administrador';

  @override
  String get chatList_groupFallback => 'Grupo';

  @override
  String get chatList_howToAllow => 'Como permitir';

  @override
  String get chatList_howToAllowStep1 =>
      'Toque em \"Permitir acesso\" para abrir as Configurações';

  @override
  String get chatList_howToAllowStep2 => 'Toque em \"Permissões\"';

  @override
  String get chatList_howToAllowStep3 => 'Selecione \"Contatos\"';

  @override
  String get chatList_howToAllowStep4 =>
      'Escolha \"Permitir\" e volte ao aplicativo';

  @override
  String get chatList_invite => 'Convidar';

  @override
  String get chatList_inviteChooseHow => 'Escolha como deseja enviar o convite';

  @override
  String chatList_inviteMessage(
      String name, String playStoreLink, String appStoreLink) {
    return 'Olá $name! Venha para o FG Tracker.\n\nBaixar para Android: $playStoreLink\n\nBaixar para iOS: $appStoreLink';
  }

  @override
  String get chatList_inviteMoreApps => 'Mais aplicativos';

  @override
  String chatList_inviteName(String name) {
    return 'Convidar $name';
  }

  @override
  String get chatList_inviteViaMessage => 'Mensagem';

  @override
  String get chatList_locationHidden => 'Localização oculta';

  @override
  String chatList_manyTyping(String name1, String name2, int count) {
    return '$name1, $name2 +$count estão digitando...';
  }

  @override
  String get chatList_markAsRead => 'Marcar como lida';

  @override
  String get chatList_markAsUnread => 'Marcar como não lida';

  @override
  String get chatList_mediaLinksDocs => 'Mídia, links e docs';

  @override
  String get chatList_memberFallback => 'Membro';

  @override
  String get chatList_messageDeleted => 'Esta mensagem foi apagada';

  @override
  String get chatList_messageForwarded => 'Mensagem encaminhada';

  @override
  String get chatList_messageIdMissing => 'ID da mensagem ausente.';

  @override
  String chatList_minutesShort(int count) {
    return '$count min';
  }

  @override
  String get chatList_mute1Hour => '1 hora';

  @override
  String get chatList_mute8Hours => '8 horas';

  @override
  String get chatList_muteAlways => 'Até eu reativar';

  @override
  String get chatList_muteSubtitle =>
      'Escolha por quanto tempo deseja pausar as notificações.';

  @override
  String get chatList_muteTitle => 'Silenciar notificações';

  @override
  String get chatList_muteUntilTomorrow => 'Até amanhã';

  @override
  String get chatList_newChat => 'Nova conversa';

  @override
  String get chatList_newChatSectionContacts =>
      'Iniciar nova conversa (Contatos)';

  @override
  String get chatList_newChatSectionInvite =>
      'Convidar para o chat (Não cadastrados)';

  @override
  String get chatList_noArchivedChats => 'Nenhuma conversa arquivada';

  @override
  String get chatList_noArchivedChatsSubtitle =>
      'As conversas arquivadas aparecerão aqui.';

  @override
  String get chatList_noChatsFound => 'Nenhuma conversa encontrada';

  @override
  String get chatList_noChatsSubtitle =>
      'Suas conversas privadas aparecerão aqui.';

  @override
  String get chatList_noContactsAvailable => 'Nenhum contato disponível';

  @override
  String get chatList_noContactsFound => 'Nenhum contato encontrado';

  @override
  String get chatList_noGroupsAvailable => 'Nenhum grupo disponível';

  @override
  String get chatList_noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get chatList_noMediaYet => 'Nenhuma mídia compartilhada ainda';

  @override
  String get chatList_noMessagesYet => 'Nenhuma mensagem ainda';

  @override
  String get chatList_noPeopleOrGroups => 'Nenhuma pessoa ou grupo encontrado';

  @override
  String chatList_noResultsFor(String query) {
    return 'Nenhum resultado encontrado para \"$query\"';
  }

  @override
  String chatList_noResultsForQuery(String query) {
    return 'Nenhum resultado para \'$query\'';
  }

  @override
  String get chatList_noTrackerContacts =>
      'Nenhum contato ativo encontrado no rastreador';

  @override
  String get chatList_offlineNotSaved =>
      'Você está offline. A alteração não foi salva, tente novamente.';

  @override
  String chatList_oneTyping(String name) {
    return '$name está digitando...';
  }

  @override
  String get chatList_openSettings => 'Abrir Configurações';

  @override
  String get chatList_pinChat => 'Fixar conversa';

  @override
  String get chatList_pinnedChats => 'Conversas fixadas';

  @override
  String get chatList_pleaseTryAgain => 'Por favor, tente novamente.';

  @override
  String get chatList_profileCall => 'Ligar';

  @override
  String get chatList_profileMessage => 'Mensagem';

  @override
  String get chatList_profileNotFound => 'Detalhes do perfil não encontrados';

  @override
  String get chatList_profileVideoCall => 'Chamada de vídeo';

  @override
  String get chatList_quickCommSubtitle =>
      'Conecte-se com sua equipe instantaneamente';

  @override
  String get chatList_quickCommTitle => 'Comunicação rápida';

  @override
  String get chatList_quickGroups => 'Grupos';

  @override
  String get chatList_quickGroupsSub => 'Conversas de equipe';

  @override
  String get chatList_quickSafeZone => 'Zona Segura';

  @override
  String get chatList_quickSafeZoneSub => 'Segurança e alertas';

  @override
  String get chatList_quickTracking => 'Rastreamento';

  @override
  String get chatList_quickTrackingSub => 'Localização ao vivo';

  @override
  String get chatList_quickWalkie => 'Walkie';

  @override
  String get chatList_quickWalkieSub => 'Aperte para falar';

  @override
  String get chatList_searchByNameOrNumber => 'Pesquisar por nome ou número...';

  @override
  String get chatList_searchGroupsHint => 'Pesquisar grupos...';

  @override
  String get chatList_searchHint => 'Pesquisar conversas ou mensagens...';

  @override
  String get chatList_searchHintShort => 'Pesquisar...';

  @override
  String get chatList_searchNameOrNumber => 'Pesquisar nome ou número';

  @override
  String get chatList_searchResults => 'Resultados da pesquisa';

  @override
  String get chatList_sectionGroups => 'GRUPOS';

  @override
  String get chatList_sectionMyContacts => 'MEUS CONTATOS';

  @override
  String get chatList_sectionOtherContacts => 'OUTROS CONTATOS';

  @override
  String get chatList_sectionRecentChats => 'CHATS RECENTES';

  @override
  String get chatList_selectDestination => 'Selecionar destino';

  @override
  String get chatList_selectDestinationMsg =>
      'Selecione pelo menos uma pessoa ou grupo.';

  @override
  String chatList_selectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String get chatList_shareContactTitle => 'Compartilhar contato';

  @override
  String chatList_shareMenuFailed(String error) {
    return 'Não foi possível abrir o menu de compartilhamento: $error';
  }

  @override
  String get chatList_smsOpenFailed =>
      'Não foi possível abrir o app de mensagens';

  @override
  String get chatList_someone => 'Alguém';

  @override
  String get chatList_startConversation => 'Iniciar uma conversa';

  @override
  String get chatList_subtitle => 'Mantenha-se conectado com sua equipe';

  @override
  String get chatList_telegramOpenFailed => 'Não foi possível abrir o Telegram';

  @override
  String get chatList_title => 'Chat';

  @override
  String get chatList_tryAnotherNameOrNumber =>
      'Tente outro nome ou número de telefone.';

  @override
  String get chatList_tryDifferentSearch =>
      'Tente pesquisar com outro nome ou mensagem.';

  @override
  String chatList_twoTyping(String name1, String name2) {
    return '$name1, $name2 estão digitando...';
  }

  @override
  String get chatList_typing => 'digitando...';

  @override
  String get chatList_unableToCallContact =>
      'Não foi possível ligar para este contato';

  @override
  String get chatList_unableToLoadContacts =>
      'Não foi possível carregar os contatos';

  @override
  String get chatList_unarchiveChat => 'Desarquivar conversa';

  @override
  String get chatList_unblock => 'Desbloquear';

  @override
  String get chatList_unblockFailed => 'Não foi possível desbloquear o usuário';

  @override
  String chatList_unblockName(String name) {
    return 'Desbloquear $name';
  }

  @override
  String get chatList_unblockUser => 'Desbloquear usuário';

  @override
  String get chatList_unblockUserConfirm =>
      'Tem certeza de que deseja desbloquear este usuário?';

  @override
  String get chatList_unknown => 'Desconhecido';

  @override
  String get chatList_unknownUser => 'Usuário desconhecido';

  @override
  String get chatList_unnamedContact => 'Contato sem nome';

  @override
  String get chatList_unpinChat => 'Desafixar conversa';

  @override
  String chatList_unreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens não lidas',
      one: '1 mensagem não lida',
    );
    return '$_temp0';
  }

  @override
  String get chatList_updateFailed =>
      'Não foi possível atualizar o chat. Tente novamente.';

  @override
  String get chatList_userFallback => 'Usuário';

  @override
  String get chatList_userNotFound => 'Usuário não encontrado';

  @override
  String get chatList_viewArchived => 'Ver conversas arquivadas';

  @override
  String get chatList_whatsappOpenFailed => 'Não foi possível abrir o WhatsApp';

  @override
  String get chatList_yourContacts => 'Seus contatos';

  @override
  String get chat_addCaptionHint => 'Adicionar uma legenda...';

  @override
  String get chat_audioUnavailable => 'Este áudio não está mais disponível';

  @override
  String get chat_blockFailed => 'Não foi possível bloquear o usuário';

  @override
  String get chat_call => 'Ligar';

  @override
  String get chat_cameraAccessNeeded =>
      'O acesso à câmera é necessário para tirar fotos e vídeos no chat.';

  @override
  String get chat_cameraModePhoto => 'FOTO';

  @override
  String get chat_cameraModePortrait => 'RETRATO';

  @override
  String get chat_cameraModeVideo => 'VÍDEO';

  @override
  String get chat_cameraStartFailed => 'Não foi possível iniciar a câmera.';

  @override
  String get chat_cantMessageUser =>
      'Você não pode enviar mensagens para este usuário';

  @override
  String get chat_chatActionsSubtitle => 'Gerencie sua conversa';

  @override
  String get chat_chatActionsTitle => 'Ações de conversa';

  @override
  String get chat_clear => 'Limpar';

  @override
  String get chat_clearChat => 'Limpar conversa';

  @override
  String get chat_clearChatConfirm =>
      'Limpar todas as mensagens desta conversa?';

  @override
  String get chat_clearGroupChatFailed => 'Falha ao limpar conversa em grupo';

  @override
  String get chat_contactBlockedYou => 'Este contato bloqueou você';

  @override
  String get chat_contactUnavailable => 'Contato indisponível';

  @override
  String get chat_deleteForEveryone => 'Apagar para todos';

  @override
  String get chat_deleteForEveryoneConfirm =>
      'Tem certeza de que deseja apagar esta mensagem para todos?';

  @override
  String get chat_deleteForMe => 'Apagar para mim';

  @override
  String get chat_deleteForMeConfirm =>
      'Tem certeza de que deseja apagar esta mensagem para você?';

  @override
  String get chat_deleteMember => 'Remover membro';

  @override
  String get chat_deleteMemberSubtitle => 'Remover um membro deste grupo';

  @override
  String get chat_documentAvailable => 'O documento está disponível';

  @override
  String get chat_documentDownloadFailed => 'O documento não pôde ser baixado.';

  @override
  String get chat_documentOpenFailed =>
      'Não foi possível abrir o documento. Tente novamente.';

  @override
  String get chat_documentPreviewUnavailable =>
      'A visualização não está disponível para este tipo de arquivo. Abra o documento usando seu aplicativo instalado.';

  @override
  String get chat_documentUnavailable =>
      'Este documento não está mais disponível';

  @override
  String get chat_downloadFailed => 'Falha no download';

  @override
  String get chat_edited => 'editada';

  @override
  String get chat_emptySubtitle => 'Diga oi 👋 para iniciar a conversa';

  @override
  String get chat_emptyTitle => 'Nenhuma mensagem aqui ainda';

  @override
  String get chat_fetchingLocation => 'Buscando localização...';

  @override
  String get chat_finishVoiceRecordingFirst =>
      'Conclua ou cancele a gravação de voz primeiro';

  @override
  String get chat_forwarded => 'Encaminhada';

  @override
  String chat_galleryCounter(int current, int total) {
    return '$current de $total';
  }

  @override
  String get chat_groupActionsSubtitle =>
      'Gerencie as configurações do seu grupo';

  @override
  String get chat_groupActionsTitle => 'Ações do grupo';

  @override
  String get chat_groupChatCleared => 'Conversa em grupo limpa com sucesso';

  @override
  String get chat_groupDeactivated =>
      'Este grupo foi desativado pelo administrador';

  @override
  String get chat_imageFailed => 'Falha na imagem';

  @override
  String get chat_listen => 'Ouvir';

  @override
  String get chat_listenEnglish => 'Ouvir (Inglês)';

  @override
  String get chat_listenHindi => 'Ouvir (Hindi)';

  @override
  String get chat_loadFailedSubtitle =>
      'Verifique sua conexão e tente novamente.';

  @override
  String get chat_loadFailedTitle => 'Não foi possível carregar as mensagens';

  @override
  String get chat_locationFetchFailed =>
      'Não foi possível obter sua localização. Tente novamente.';

  @override
  String get chat_locationPermissionNeeded =>
      'A permissão de localização é necessária para compartilhar sua localização.';

  @override
  String get chat_locationPermissionOff =>
      'A permissão de localização está desativada para este aplicativo. Ative-a nas Configurações para compartilhar sua localização.';

  @override
  String get chat_locationServicesOff =>
      'Ative os serviços de localização para compartilhar sua localização.';

  @override
  String get chat_locationUnavailable => 'Localização indisponível';

  @override
  String get chat_mediaMissing => 'Mídia ausente';

  @override
  String get chat_mediaMissingToast =>
      'Mídia ausente. Este arquivo não está mais disponível.';

  @override
  String get chat_mediaUnavailable => 'Esta mídia não está mais disponível';

  @override
  String get chat_menuForward => 'Encaminhar';

  @override
  String get chat_menuMessageInfo => 'Dados da mensagem';

  @override
  String get chat_menuPin => 'Fixar mensagem';

  @override
  String get chat_menuReply => 'Responder';

  @override
  String get chat_menuUnpin => 'Desafixar mensagem';

  @override
  String get chat_messageCopied => 'Mensagem copiada';

  @override
  String get chat_messageDeleted => 'Esta mensagem foi apagada';

  @override
  String get chat_messageNotAvailable => 'Mensagem não disponível';

  @override
  String get chat_messageNotSent => 'Mensagem não enviada. Tente novamente.';

  @override
  String get chat_noCameraFound =>
      'Nenhuma câmera encontrada neste dispositivo.';

  @override
  String get chat_noLongerMember => 'Você não é mais membro deste grupo';

  @override
  String get chat_noMediaAvailable => 'Nenhuma mídia disponível';

  @override
  String get chat_offlineNotSent => 'Você está offline. Mensagem não enviada.';

  @override
  String get chat_openDocument => 'Abrir documento';

  @override
  String get chat_openInGoogleMaps => 'Abrir no Google Maps';

  @override
  String get chat_openSettings => 'Abrir Configurações';

  @override
  String chat_peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get chat_photoUnavailable => 'Esta foto não está mais disponível';

  @override
  String get chat_previewAttendancePoll => 'Enquete de presença';

  @override
  String get chat_previewAudio => 'Áudio';

  @override
  String get chat_previewContact => 'Contato';

  @override
  String get chat_previewDocument => 'Documento';

  @override
  String get chat_previewLocation => 'Localização';

  @override
  String get chat_previewMessage => 'Mensagem';

  @override
  String get chat_previewNewMessage => 'Nova mensagem';

  @override
  String get chat_previewOwnDeleted => 'Você apagou esta mensagem';

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
  String get chat_previewPoll => 'Enquete';

  @override
  String get chat_previewSticker => 'Figurinha';

  @override
  String get chat_previewVideo => 'Vídeo';

  @override
  String chat_previewVideosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vídeos',
      one: '1 vídeo',
    );
    return '$_temp0';
  }

  @override
  String get chat_previewVoiceMessage => 'Mensagem de voz';

  @override
  String chat_previewVoiceMessageDuration(String duration) {
    return 'Mensagem de voz ($duration)';
  }

  @override
  String get chat_recordingFailed => 'Falha na gravação';

  @override
  String get chat_removeMember => 'Remover membro';

  @override
  String get chat_removeMemberConfirm =>
      'Tem certeza de que deseja remover este membro do grupo?';

  @override
  String get chat_replyHint => 'Responder à mensagem...';

  @override
  String get chat_searchMessages => 'Pesquisar mensagens';

  @override
  String get chat_searchMessagesHint => 'Pesquisar mensagens...';

  @override
  String get chat_searchMessagesSubtitle =>
      'Encontrar mensagens por palavra-chave';

  @override
  String get chat_sendLocation => 'Enviar localização';

  @override
  String get chat_shareLocation => 'Compartilhar localização';

  @override
  String get chat_shareVideoFailed => 'Não foi possível compartilhar o vídeo';

  @override
  String get chat_sharedFromApp => 'Compartilhado pelo FG Tracker';

  @override
  String get chat_sharedLocation => 'Localização compartilhada';

  @override
  String get chat_showOriginal => 'Mostrar original';

  @override
  String get chat_someone => 'Alguém';

  @override
  String get chat_statusLabel => 'Status';

  @override
  String get chat_statusUnavailable =>
      'Esta atualização de status não está mais disponível';

  @override
  String get chat_stop => 'Parar';

  @override
  String get chat_stopEnglish => 'Parar (Inglês)';

  @override
  String get chat_stopHindi => 'Parar (Hindi)';

  @override
  String get chat_takePhotoFailed => 'Falha ao tirar foto';

  @override
  String get chat_translatedToEnglish => 'Traduzido para o inglês';

  @override
  String get chat_translatedToHindi => 'Traduzido para o hindi';

  @override
  String get chat_translating => 'Traduzindo...';

  @override
  String get chat_tryAgain => 'Tentar novamente';

  @override
  String get chat_typeMessageHint => 'Digite uma mensagem...';

  @override
  String get chat_typing => 'digitando...';

  @override
  String chat_typingMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas estão digitando...',
      one: '1 pessoa está digitando...',
    );
    return '$_temp0';
  }

  @override
  String chat_typingOne(String name) {
    return '$name está digitando...';
  }

  @override
  String chat_typingTwo(String name1, String name2) {
    return '$name1, $name2 estão digitando...';
  }

  @override
  String get chat_unableToOpen => 'Não foi possível abrir';

  @override
  String get chat_unableToOpenGoogleMaps =>
      'Não foi possível abrir o Google Maps';

  @override
  String get chat_unblock => 'Desbloquear';

  @override
  String get chat_unblockContact => 'Desbloquear contato';

  @override
  String get chat_unblockContactConfirm =>
      'Tem certeza de que deseja desbloquear este contato?';

  @override
  String get chat_unblockFailed => 'Não foi possível desbloquear o usuário';

  @override
  String get chat_unknown => 'Desconhecido';

  @override
  String get chat_unknownLocation => 'Localização desconhecida';

  @override
  String get chat_unsupportedMessage =>
      'Esta mensagem não é suportada nesta versão do aplicativo';

  @override
  String get chat_updateGroup => 'Atualizar grupo';

  @override
  String get chat_updateGroupSubtitle => 'Alterar detalhes do grupo atual';

  @override
  String chat_uploadFileFailed(String path) {
    return 'Falha ao enviar $path';
  }

  @override
  String get chat_userBlocked => 'Usuário bloqueado com sucesso';

  @override
  String get chat_userUnblocked => 'Usuário desbloqueado com sucesso';

  @override
  String get chat_videoDownloaded => 'Vídeo baixado com sucesso';

  @override
  String get chat_videoThumbnailFailed => 'Falha ao gerar miniatura do vídeo';

  @override
  String get chat_videoUnavailable => 'Este vídeo não está mais disponível';

  @override
  String get chat_videoUploadFailed => 'Falha ao enviar o vídeo';

  @override
  String get chat_voicePlayFailed =>
      'Não foi possível reproduzir a mensagem de voz';

  @override
  String get chat_voiceUploadFailed =>
      'Falha ao enviar mensagem de voz. Tente novamente.';

  @override
  String get chat_youBlockedContact => 'Você bloqueou este contato';

  @override
  String get common_add => 'Adicionar';

  @override
  String get common_allow => 'Permitir';

  @override
  String get common_back => 'Voltar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_close => 'Fechar';

  @override
  String get common_comingSoon => 'Em breve';

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
      other: 'Há $count dias',
      one: 'Há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_dismiss => 'Dispensar';

  @override
  String get common_done => 'Concluído';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_error => 'Erro';

  @override
  String get common_exit => 'Sair';

  @override
  String get common_gotIt => 'Entendi';

  @override
  String common_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count horas',
      one: 'Há 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get common_justNow => 'Agora mesmo';

  @override
  String common_lastSeen(String time) {
    return 'Visto por último: $time';
  }

  @override
  String get common_loading => 'Carregando…';

  @override
  String common_membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String common_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count min',
      one: 'Há 1 min',
    );
    return '$_temp0';
  }

  @override
  String get common_next => 'Próximo';

  @override
  String get common_no => 'Não';

  @override
  String get common_noData => 'Nenhum dado encontrado';

  @override
  String get common_noInternet => 'Sem conexão com a internet';

  @override
  String get common_notNow => 'Agora não';

  @override
  String get common_offline => 'Offline';

  @override
  String get common_ok => 'OK';

  @override
  String get common_online => 'Online';

  @override
  String get common_open => 'Abrir';

  @override
  String get common_permissionDenied => 'Permissão negada';

  @override
  String get common_remove => 'Remover';

  @override
  String get common_retry => 'Tentar novamente';

  @override
  String get common_save => 'Salvar';

  @override
  String get common_search => 'Pesquisar';

  @override
  String get common_send => 'Enviar';

  @override
  String get common_settings => 'Configurações';

  @override
  String get common_share => 'Compartilhar';

  @override
  String get common_somethingWentWrong => 'Ocorreu um erro. Tente novamente.';

  @override
  String get common_submit => 'Enviar';

  @override
  String get common_success => 'Sucesso';

  @override
  String get common_today => 'Hoje';

  @override
  String common_todayAt(String time) {
    return 'Hoje, $time';
  }

  @override
  String get common_tryAgain => 'Tentar novamente';

  @override
  String get common_viewAll => 'Ver tudo';

  @override
  String get common_yes => 'Sim';

  @override
  String get common_yesterday => 'Ontem';

  @override
  String get common_you => 'Você';

  @override
  String get dialog_allowLocationAccess => 'Permitir acesso à localização';

  @override
  String get dialog_anErrorOccurred => 'Ocorreu um erro!';

  @override
  String get dialog_important => 'Importante!';

  @override
  String get dialog_locationPermissionRequired =>
      'Permissão de localização necessária';

  @override
  String get dialog_locationPurposeBody =>
      'Para melhorar a eficiência do serviço, nosso aplicativo solicita permissão para acessar sua localização com o objetivo de salvá-la. Isso permite navegar com precisão até seu local de trabalho.';

  @override
  String get dialog_locationSettingsAndroid =>
      'Sem acesso à localização, não poderemos detectar sua localização atual. Toque em \'Configurações\', depois em \'Permissões\' e permita o acesso à localização.';

  @override
  String get dialog_locationSettingsIos =>
      'Este aplicativo requer acesso à sua localização para fornecer serviços baseados em localização. Vá em \'Configurações\' e ative as permissões de localização.';

  @override
  String get dialog_loggedInElsewhere =>
      'Você fez login a partir de outro dispositivo.';

  @override
  String get dialog_loggedInElsewhereLogInAgain =>
      'Você fez login em outro dispositivo. Por favor, faça login novamente.';

  @override
  String get dialog_logoutConfirm => 'Deseja sair da conta?';

  @override
  String get dialog_selectAllowAllTheTime =>
      'No próximo pop-up, selecione\n\'Permitir o tempo todo\'.';

  @override
  String get dialog_sessionExpiredTitle => 'Sessão expirada';

  @override
  String get editProfile_fullNameLabel => 'Nome completo';

  @override
  String get editProfile_personalInfo => 'Informações pessoais';

  @override
  String get editProfile_phoneLabel => 'Número de telefone';

  @override
  String get editProfile_saveButton => 'Salvar alterações';

  @override
  String get editProfile_tapPhotoHint => 'Toque na foto para alterar';

  @override
  String get editProfile_title => 'Editar perfil';

  @override
  String get forceUpdate_currentInstalled => 'VERSÃO INSTALADA';

  @override
  String get forceUpdate_defaultMessage =>
      'Uma nova versão do FG Tracker está disponível. Atualize para continuar.';

  @override
  String get forceUpdate_defaultTitle => 'Atualização Necessária';

  @override
  String get forceUpdate_fallbackMessage =>
      'Uma nova versão do FG Tracker com melhorias importantes está disponível. Atualize para continuar.';

  @override
  String get forceUpdate_footer =>
      'Atualização obrigatória para continuar no FG Tracker';

  @override
  String get forceUpdate_requiredVersion => 'VERSÃO NECESSÁRIA';

  @override
  String forceUpdate_updateOnStore(String storeName) {
    return 'Atualizar na $storeName';
  }

  @override
  String get groupDialog_audioCall => 'Chamada de voz';

  @override
  String get groupDialog_audioCallSubtitle => 'Iniciar conversa de voz';

  @override
  String get groupDialog_call => 'Ligar';

  @override
  String get groupDialog_chat => 'Chat';

  @override
  String get groupDialog_codeEmpty =>
      'O código do grupo não pode ficar em branco';

  @override
  String get groupDialog_codeLabel => 'Código do grupo';

  @override
  String get groupDialog_createButton => 'Criar grupo';

  @override
  String get groupDialog_createTitle => 'Criar novo grupo';

  @override
  String get groupDialog_descHint => 'Digite a descrição do grupo';

  @override
  String get groupDialog_descLabel => 'Descrição do grupo (Opcional)';

  @override
  String groupDialog_distance(String distance) {
    return 'Distância: $distance';
  }

  @override
  String get groupDialog_enterCodeManually =>
      'Digitar código do grupo manualmente';

  @override
  String get groupDialog_enterCodeTitle => 'Digite o código do grupo';

  @override
  String get groupDialog_fillDetails => 'Preencha os detalhes abaixo';

  @override
  String get groupDialog_getDirections => 'Obter direções';

  @override
  String get groupDialog_join => 'Entrar no grupo';

  @override
  String groupDialog_lastSeen(String time) {
    return 'Visto por último: $time';
  }

  @override
  String get groupDialog_locationHidden => 'Localização oculta';

  @override
  String get groupDialog_locationUnavailable => 'Localização indisponível';

  @override
  String get groupDialog_member => 'Membro';

  @override
  String get groupDialog_memberInfo => 'Informações do membro';

  @override
  String get groupDialog_nameHint => 'Digite o nome do grupo';

  @override
  String get groupDialog_nameLabel => 'Nome do grupo';

  @override
  String get groupDialog_noQrInImage =>
      'Nenhum código QR encontrado na imagem selecionada.';

  @override
  String get groupDialog_noValidQr => 'Nenhum código QR válido encontrado.';

  @override
  String groupDialog_qrDecodeError(String error) {
    return 'Erro ao decodificar QR da galeria: $error';
  }

  @override
  String get groupDialog_scanCamera => 'Escanear com a câmera';

  @override
  String get groupDialog_selectCallType => 'Selecionar tipo de chamada';

  @override
  String get groupDialog_update => 'Atualizar';

  @override
  String get groupDialog_updateTitle => 'Atualizar grupo';

  @override
  String get groupDialog_uploadGallery => 'Carregar da galeria';

  @override
  String get groupDialog_videoCall => 'Chamada de vídeo';

  @override
  String get groupDialog_videoCallSubtitle => 'Iniciar conversa de vídeo';

  @override
  String get groupDialog_yourLocation => 'Sua localização atual';

  @override
  String get groupInfo_active => 'Ativo';

  @override
  String get groupInfo_admin => 'Admin';

  @override
  String get groupInfo_allGroups => 'Todos os grupos';

  @override
  String get groupInfo_allGroupsSubtitle =>
      'Mantenha-se conectado com suas equipes';

  @override
  String get groupInfo_areYouSure => 'Tem certeza?';

  @override
  String get groupInfo_audioCall => 'Chamada de voz';

  @override
  String get groupInfo_clearChatConfirm =>
      'Apagar todas as mensagens deste dispositivo?';

  @override
  String get groupInfo_createdBy => 'Criado por';

  @override
  String get groupInfo_detailsNotFound => 'Detalhes do grupo não encontrados';

  @override
  String get groupInfo_exitGroup => 'Sair do grupo';

  @override
  String groupInfo_exitGroupConfirm(String groupName) {
    return 'Tem certeza de que deseja sair de \"$groupName\"?';
  }

  @override
  String get groupInfo_exitGroupQuestion => 'Deseja sair deste grupo?';

  @override
  String get groupInfo_group => 'Grupo';

  @override
  String get groupInfo_groupAdmin => 'Admin do grupo';

  @override
  String get groupInfo_groupCallFailed =>
      'Não foi possível iniciar a chamada em grupo. Tente novamente.';

  @override
  String get groupInfo_groupCodeCopied => 'Código do grupo copiado!';

  @override
  String get groupInfo_groupSettings => 'Configurações do grupo';

  @override
  String get groupInfo_groupSettingsSubtitle =>
      'Editar dados do grupo, privacidade e mais';

  @override
  String get groupInfo_inactive => 'Inativo';

  @override
  String get groupInfo_inviteCopied => 'Texto de convite copiado';

  @override
  String groupInfo_inviteText(String groupName) {
    return 'Entre no meu grupo \"$groupName\" no FG Tracker';
  }

  @override
  String groupInfo_inviteTextWithCode(String groupName, String code) {
    return 'Entre no meu grupo \"$groupName\" no FG Tracker. Código: $code';
  }

  @override
  String get groupInfo_inviteViaLink => 'Convidar por link';

  @override
  String get groupInfo_mediaLinksDocs => 'Mídia, links e docs';

  @override
  String get groupInfo_member => 'Membro';

  @override
  String get groupInfo_members => 'Membros';

  @override
  String get groupInfo_messageAction => 'Mensagem';

  @override
  String groupInfo_nameYou(String name) {
    return '$name (Você)';
  }

  @override
  String groupInfo_noGroupFound(String query) {
    return 'Nenhum grupo encontrado para \'$query\'';
  }

  @override
  String get groupInfo_noGroupsYet =>
      'Você ainda não entrou nem criou nenhum grupo.\nComece a explorar agora!';

  @override
  String get groupInfo_noMediaYet => 'Nenhuma mídia compartilhada ainda';

  @override
  String get groupInfo_removeFromGroup => 'Remover do grupo';

  @override
  String groupInfo_removeMemberConfirm(String name) {
    return 'Tem certeza de que deseja remover $name do grupo?';
  }

  @override
  String get groupInfo_searchGroupsHint => 'Pesquisar grupos...';

  @override
  String get groupInfo_showLess => 'Mostrar menos';

  @override
  String get groupInfo_teamCode => 'Código da equipe';

  @override
  String groupInfo_totalCount(int count) {
    return '$count no total';
  }

  @override
  String get groupInfo_unknownGroup => 'Grupo desconhecido';

  @override
  String get groupInfo_unnamedGroup => 'Grupo sem nome';

  @override
  String get groupInfo_videoCall => 'Chamada de vídeo';

  @override
  String get groupInfo_viewAllMembers => 'Ver todos os membros';

  @override
  String get group_activatedSuccess => 'Grupo ativado com sucesso';

  @override
  String get group_addMember => 'Adicionar Membro';

  @override
  String get group_alignQr => 'Alinhe o QR dentro do quadro';

  @override
  String get group_areYouSure => 'Tem certeza?';

  @override
  String get group_chatWithMembers => 'Converse com os membros do grupo';

  @override
  String get group_codeCopied => 'Código do grupo copiado!';

  @override
  String group_codeShareInfo(String code) {
    return 'Código do grupo: $code — compartilhe para que outros entrem';
  }

  @override
  String get group_copyCode => 'Copiar código';

  @override
  String get group_created => 'Criado';

  @override
  String get group_createdJustNow => 'Criado agora mesmo';

  @override
  String get group_deactivatedSuccess => 'Grupo desativado com sucesso';

  @override
  String get group_defaultName => 'Grupo';

  @override
  String get group_deleteGroup => 'Excluir Grupo';

  @override
  String get group_deleteGroupConfirm => 'Deseja excluir este grupo?';

  @override
  String get group_deletedSuccess => 'Grupo excluído com sucesso';

  @override
  String get group_download => 'Baixar';

  @override
  String get group_downloadChannelDescription =>
      'Notifica quando o QR code for baixado';

  @override
  String get group_downloadChannelName => 'Notificações de Download';

  @override
  String get group_enableLocationToJoin =>
      'Ative os serviços de localização para entrar no grupo.';

  @override
  String get group_exitGroup => 'Sair do Grupo';

  @override
  String get group_exitGroupConfirm => 'Deseja sair deste grupo?';

  @override
  String group_exitGroupNamedConfirm(String groupName) {
    return 'Tem certeza de que deseja sair de \"$groupName\"? Você precisará do código para entrar novamente.';
  }

  @override
  String get group_exitedSuccess => 'Saída do grupo com sucesso';

  @override
  String get group_goToGroups => 'Ir para Grupos →';

  @override
  String get group_groupMessage => 'Mensagem de Grupo';

  @override
  String get group_invalidResponseFormat => 'Formato inválido';

  @override
  String get group_joinedJustNow => 'Entrou agora mesmo';

  @override
  String get group_joinedRecently => 'Recente';

  @override
  String get group_leftJustNow => 'Saiu agora mesmo';

  @override
  String get group_locationNoLongerShared =>
      'Sua localização não é mais compartilhada com este grupo';

  @override
  String get group_locationPermissionToJoin =>
      'Permissão de localização é necessária para entrar no grupo.';

  @override
  String get group_locationShared =>
      'Sua localização está compartilhada com este grupo';

  @override
  String get group_memberFallbackName => 'Membro';

  @override
  String group_membersMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros · $when',
      one: '1 membro · $when',
    );
    return '$_temp0';
  }

  @override
  String get group_noContactsFound => 'Nenhum contato encontrado';

  @override
  String get group_noGroupCode => 'Nenhum código de grupo disponível';

  @override
  String get group_noNewMessages =>
      'Você não receberá novas mensagens deste grupo';

  @override
  String get group_noNumber => 'Sem número';

  @override
  String get group_openGroup => 'Abrir Grupo →';

  @override
  String get group_other => 'Outro';

  @override
  String get group_qrSavedBody => 'Toque para abrir seu QR code';

  @override
  String get group_qrSavedTitle => 'QR Code Salvo';

  @override
  String group_qrShareMessage(String groupCode, String appLink) {
    return '📌 Código do grupo: $groupCode\n\nEntre no meu grupo usando o QR code ou o código acima.\n\n📲 Baixe o app para ficar conectado:\n$appLink';
  }

  @override
  String get group_scanToJoin => 'Escaneie este QR code para entrar no grupo';

  @override
  String get group_searchMemberHint => 'Pesquisar membro...';

  @override
  String get group_shareCodeInfo =>
      'Compartilhe o código do grupo para que outros possam entrar';

  @override
  String get group_shareQr => 'Compartilhar QR';

  @override
  String get group_shareQrToInvite =>
      'Compartilhe o QR code para convidar membros';

  @override
  String get group_sheetCreatedSubtitle =>
      'Seu grupo está pronto. Compartilhe o código para que os membros entrem.';

  @override
  String group_sheetCreatedSubtitleNamed(String name) {
    return '$name, seu grupo está pronto. Compartilhe o código para que entrem.';
  }

  @override
  String get group_sheetCreatedTitle => 'Grupo criado!';

  @override
  String get group_sheetJoinedSubtitle =>
      'Bem-vindo, agora você é membro deste grupo.';

  @override
  String group_sheetJoinedSubtitleNamed(String name) {
    return 'Bem-vindo(a) $name, agora você é membro deste grupo.';
  }

  @override
  String get group_sheetJoinedTitle => 'Entrou com sucesso!';

  @override
  String get group_sheetLeftSubtitle => 'Você não é mais membro deste grupo.';

  @override
  String group_sheetLeftSubtitleNamed(String name) {
    return '$name, você não é mais membro deste grupo.';
  }

  @override
  String get group_sheetLeftTitle => 'Você saiu do grupo';

  @override
  String get group_showQrCode => 'Mostrar QR Code';

  @override
  String get group_startConversation =>
      'Fique à vontade para iniciar uma conversa';

  @override
  String get group_statusUpdateFailed => 'Falha ao atualizar status do grupo';

  @override
  String get group_teamCode => 'Código da Equipe';

  @override
  String get group_teamCodeLabel => 'Código da Equipe: ';

  @override
  String get group_track => 'Rastrear';

  @override
  String get group_unnamedMember => 'Membro Sem Nome';

  @override
  String get group_unnamedTrip => 'Viagem sem nome';

  @override
  String get group_updateGroupConfirm =>
      'Tem certeza de que deseja atualizar os detalhes do grupo?';

  @override
  String get group_updateGroupTitle => 'Atualizar Grupo';

  @override
  String get group_youAreAdmin => 'Você é o administrador deste grupo';

  @override
  String get home_actionAllContacts => 'Todos os contatos';

  @override
  String get home_actionAudioVideoCall => 'Chamada de áudio/vídeo';

  @override
  String get home_actionChatting => 'Conversas';

  @override
  String get home_actionSafeZone => 'Zona Segura';

  @override
  String get home_actionTracking => 'Rastreamento';

  @override
  String get home_actionWalkieTalkie => 'Walkie Talkie';

  @override
  String get home_active => 'Ativo';

  @override
  String get home_activeSessions => 'Sessões Ativas';

  @override
  String home_activeSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões ativas',
      one: '1 sessão ativa',
    );
    return '$_temp0';
  }

  @override
  String get home_allMembers => 'Todos os Membros';

  @override
  String get home_createGroup => 'Criar grupo';

  @override
  String get home_createGroupSubtitle => 'Criar novo grupo';

  @override
  String get home_goodToSeeYou => 'Bom ver você de novo 👋';

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
    return 'Olá $name';
  }

  @override
  String get home_inactive => 'Inativo';

  @override
  String get home_joinGroup => 'Entrar no grupo';

  @override
  String get home_joinGroupSubtitle => 'Entrar em grupo existente';

  @override
  String home_lastSeen(String time) {
    return 'Visto por último às $time';
  }

  @override
  String get home_newThisMonth => 'Novos este mês';

  @override
  String get home_noActivePrivateSessions => 'Nenhuma sessão privada ativa';

  @override
  String get home_noGroupsAvailable => 'Nenhum grupo disponível';

  @override
  String get home_noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get home_noMembersFound => 'Nenhum membro encontrado';

  @override
  String home_noMembersMatch(String query) {
    return 'Nenhum membro corresponde a \'$query\'';
  }

  @override
  String get home_noMembersOnline => 'Nenhum membro online no momento';

  @override
  String get home_noNameGroup => 'Grupo sem nome';

  @override
  String get home_noRecentlyActiveMembers => 'Nenhum membro ativo recentemente';

  @override
  String get home_onlineNow => 'Online agora';

  @override
  String get home_peopleOnline => 'Pessoas Online';

  @override
  String get home_peopleOnlineSubtitle =>
      'Estes membros estão ativos no app agora e disponíveis para contato.';

  @override
  String get home_privateMode => 'Modo Privado';

  @override
  String get home_privateModeIsOn => 'Modo Privado está ATIVADO';

  @override
  String get home_privateModeOffHint =>
      'Com o Modo Privado desativado, outros podem ver sua localização.';

  @override
  String get home_privateModeOnHint =>
      'Com o Modo Privado ativado, outros não podem ver sua localização.';

  @override
  String get home_quickActionsSubtitle => 'Tudo o que você precisa a um toque.';

  @override
  String get home_quickActionsTitle => 'Ações Rápidas';

  @override
  String get home_recentlyOnline => 'Online recentemente';

  @override
  String get home_searchGroupsHint => 'Pesquisar grupos...';

  @override
  String get home_searchMembersHint => 'Pesquisar membros...';

  @override
  String get home_showLess => 'Mostrar menos';

  @override
  String get home_sortNameAsc => 'Ordenar: Nome (A-Z)';

  @override
  String get home_sortNameDesc => 'Ordenar: Nome (Z-A)';

  @override
  String home_startedAt(String time) {
    return 'Iniciado às $time';
  }

  @override
  String get home_statGroups => 'Grupos';

  @override
  String get home_statMembers => 'Membros';

  @override
  String get home_statNow => 'Agora';

  @override
  String get home_statTotal => 'Total';

  @override
  String get home_totalMembers => 'Total de Membros';

  @override
  String home_totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros no total',
      one: '1 membro no total',
    );
    return '$_temp0';
  }

  @override
  String get home_unableToFetchGroups => 'Não foi possível carregar os grupos';

  @override
  String get home_unknownMember => 'Membro Desconhecido';

  @override
  String get home_upgradeSubtitle =>
      'Desbloqueie recursos avançados para sua equipe';

  @override
  String get home_upgradeToPremium => 'Assinar Premium';

  @override
  String get home_viewPlans => 'Ver planos';

  @override
  String get home_walkieExpired => 'Expirado';

  @override
  String get home_walkieOneHourFree => '1 h grátis';

  @override
  String get home_walkieRenew => 'Renovar';

  @override
  String get home_walkieSubscribed => 'Assinado';

  @override
  String get home_youAreInvisible => 'Você está invisível';

  @override
  String get home_youAreVisible => 'Você está visível';

  @override
  String get http_networkError => 'Ocorreu um erro. Tente novamente!';

  @override
  String get http_sessionExpired => 'Sessão expirada. Faça login novamente.';

  @override
  String get http_unexpectedError =>
      'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get imagePicker_camera => 'Câmera';

  @override
  String get imagePicker_cancel => 'Cancelar';

  @override
  String get imagePicker_cropTitle => 'Cortar imagem';

  @override
  String get imagePicker_gallery => 'Galeria';

  @override
  String get imagePicker_title => 'Escolha uma opção';

  @override
  String get intro_realTimeTrackingSubtitle =>
      'Veja a localização ao vivo de amigos, família ou membros da equipe no mapa instantaneamente.';

  @override
  String get intro_realTimeTrackingTitle => 'Rastreamento em Tempo Real';

  @override
  String get intro_secureSubtitle =>
      'Compartilhe sua localização ao vivo com\ncontatos selecionados com segurança e privacidade.';

  @override
  String get intro_secureTitle => 'Seguro e Fácil';

  @override
  String get intro_skip => 'Pular';

  @override
  String get intro_walkieSubtitle =>
      'Sem sinal? Sem problemas. Fique\nconectado em qualquer lugar.';

  @override
  String get intro_walkieTitle => 'Recurso de\nWalkie-Talkie';

  @override
  String get media_cannotOpen => 'Não foi possível abrir';

  @override
  String get media_documentNotFound => 'Documento não encontrado';

  @override
  String get media_invalidLink => 'Link inválido';

  @override
  String get media_noDocuments => 'Nenhum documento encontrado';

  @override
  String get media_noLinks => 'Nenhum link encontrado';

  @override
  String get media_noMedia => 'Nenhuma mídia encontrada';

  @override
  String get media_tabDocs => 'Documentos';

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
  String get media_tabMedia => 'Mídia';

  @override
  String media_tabMediaCount(int count) {
    return 'Mídia ($count)';
  }

  @override
  String get media_title => 'Mídia, links e docs';

  @override
  String get media_videoNotFound => 'Vídeo não encontrado';

  @override
  String get menu_contactUsSubtitle => 'Saiba mais sobre nós';

  @override
  String get menu_editProfile => 'Editar Perfil';

  @override
  String get menu_editProfileSubtitle => 'Atualize suas informações';

  @override
  String get menu_followUsOn => 'Siga-nos em';

  @override
  String get menu_logOut => 'Sair';

  @override
  String get menu_logOutConfirmMessage => 'Tem certeza de que deseja sair?';

  @override
  String get menu_logOutSubtitle => 'Desconectar do aplicativo';

  @override
  String get menu_profileImageUpdateFailed =>
      'Falha ao atualizar foto de perfil';

  @override
  String get menu_profileImageUpdated =>
      'Foto de perfil atualizada com sucesso';

  @override
  String get notif_accept => 'Aceitar';

  @override
  String get notif_channelHighImportanceDesc =>
      'Canal padrão para notificações de alta importância';

  @override
  String get notif_channelHighImportanceName =>
      'Notificações de alta importância';

  @override
  String get notif_channelWalkieAudioDesc =>
      'Mantém a comunicação de voz ao vivo e captura de microfone em segundo plano';

  @override
  String get notif_channelWalkieAudioName => 'Áudio ao vivo do Walkie-Talkie';

  @override
  String get notif_channelWalkieCallsDesc =>
      'Chamadas recebidas de Walkie-Talkie';

  @override
  String get notif_channelWalkieCallsName => 'Chamadas de Walkie-Talkie';

  @override
  String get notif_channelWalkieDesc =>
      'Chamadas em grupo de walkie e atualizações de voz';

  @override
  String get notif_channelWalkieLiveDesc =>
      'Notificações para canais ativos de Walkie-Talkie';

  @override
  String get notif_channelWalkieLiveName => 'Canais ao vivo do Walkie-Talkie';

  @override
  String get notif_channelWalkieName => 'Walkie-Talkie';

  @override
  String notif_connectedIn(String group) {
    return 'Conectado em $group • Transmissão de áudio ao vivo';
  }

  @override
  String get notif_goToWalkie => 'Ir para a tela do Walkie';

  @override
  String get notif_incomingWalkieTitle => 'Walkie-Talkie recebido';

  @override
  String notif_isTalking(String name) {
    return '$name está falando';
  }

  @override
  String get notif_leave => 'Sair';

  @override
  String get notif_openWalkie => 'Abrir Walkie';

  @override
  String get notif_reject => 'Rejeitar';

  @override
  String notif_stoppedTalking(String name) {
    return '$name parou de falar';
  }

  @override
  String get notif_walkieActiveConversation =>
      'Conversa ativa de Walkie-Talkie';

  @override
  String get notif_walkieActiveTitle => 'Walkie-Talkie ativo';

  @override
  String notif_wantsToTalk(String name) {
    return '$name quer falar';
  }

  @override
  String get notifications_clearAll => 'Limpar todas as notificações';

  @override
  String get notifications_clearedSuccess =>
      'Todas as notificações foram limpas com sucesso';

  @override
  String get notifications_emptySubtitle =>
      'Você não tem novos alertas no momento.';

  @override
  String get notifications_emptyTitle => 'Nenhuma Notificação Ainda';

  @override
  String get notifications_filterAll => 'Todas';

  @override
  String get notifications_filterCalls => 'Chamadas';

  @override
  String get notifications_filterChats => 'Conversas';

  @override
  String get notifications_filterUnread => 'Não lidas';

  @override
  String get notifications_loadingDetails =>
      'Carregando detalhes da notificação';

  @override
  String get notifications_recentCalls => 'Chamadas Recentes';

  @override
  String get notifications_title => 'Notificações';

  @override
  String get otpCharges_chargedNotice =>
      'A partir de agora, cada OTP de login será cobrado. O reenvio é gratuito (até 3 tentativas).';

  @override
  String get otpCharges_chargesApplyTo => 'Cobranças aplicam-se a';

  @override
  String get otpCharges_eachOtpCosts => 'Cada OTP custa';

  @override
  String otpCharges_eachOtpCostsSpoken(String amount) {
    return 'Cada OTP custa $amount';
  }

  @override
  String otpCharges_eachOtpCostsSpokenGst(String amount, String percent) {
    return 'Cada OTP custa $amount, incluindo $percent% de imposto';
  }

  @override
  String get otpCharges_firstLoginFree => 'Seu primeiro login foi gratuito.';

  @override
  String get otpCharges_freeBody =>
      'OTPs de login enviados para este número não são cobrados.';

  @override
  String get otpCharges_freeTitle => 'O OTP é gratuito para seu número';

  @override
  String otpCharges_gstTitle(String percent) {
    return 'Imposto ($percent%)';
  }

  @override
  String otpCharges_includingGst(String percent) {
    return 'Inclui $percent% de imposto';
  }

  @override
  String otpCharges_includingTax(String percent) {
    return 'Inclui $percent% de taxa';
  }

  @override
  String get otpCharges_noInternet =>
      'Sem conexão com a internet. Verifique sua rede e tente novamente.';

  @override
  String get otpCharges_otpCharge => 'Tarifa de OTP';

  @override
  String otpCharges_pay(String amount) {
    return 'Pagar $amount';
  }

  @override
  String get otpCharges_paymentCancelled =>
      'Pagamento cancelado. Você cancelou a operação. Nenhum valor foi debitado.';

  @override
  String get otpCharges_paymentFailed =>
      'Falha no pagamento. Se houve débito, será estornado em 5 a 7 dias úteis.';

  @override
  String otpCharges_paymentPausedButton(String amount) {
    return 'Pagamento Pausado ($amount)';
  }

  @override
  String get otpCharges_paymentReceived =>
      'Pagamento recebido. Seu OTP pode levar alguns instantes para chegar.';

  @override
  String get otpCharges_paymentStartFailed =>
      'Não foi possível iniciar o pagamento. Tente novamente.';

  @override
  String get otpCharges_paymentsPaused =>
      'Os pagamentos de OTP foram pausados temporariamente pelo administrador. Toque abaixo.';

  @override
  String get otpCharges_paymentsUnavailable =>
      'Os pagamentos de OTP estão indisponíveis temporariamente. Tente mais tarde.';

  @override
  String get otpCharges_sessionExpired => 'Sessão expirada. Inicie novamente.';

  @override
  String get otpCharges_title => 'Tarifas de OTP';

  @override
  String get otpCharges_totalPerOtp => 'Total por OTP';

  @override
  String get otpCharges_tryAgainMoment =>
      'Algo deu errado. Tente novamente em alguns instantes.';

  @override
  String get otpCharges_unknownBody =>
      'OTPs para números indianos são gratuitos. Para outros países, o preço exato é exibido antes do pagamento.';

  @override
  String get otpCharges_unknownTitle => 'As taxas de OTP dependem do seu país';

  @override
  String get otpCharges_updateApp =>
      'Não foi possível iniciar o pagamento. Atualize o app e tente novamente.';

  @override
  String otpCharges_vatTitle(String percent) {
    return 'IVA / Imposto ($percent%)';
  }

  @override
  String get otpCharges_verificationFailed =>
      'Falha na verificação do pagamento. Se o valor foi debitado, será reembolsado em 5 a 7 dias úteis.';

  @override
  String get otpCharges_yourNumber => 'Seu número';

  @override
  String get package_noPackages => 'Nenhum pacote disponível no momento.';

  @override
  String package_plansComingSoon(String title) {
    return 'Os planos de $title estarão disponíveis em breve';
  }

  @override
  String get package_subtitle => 'Escolha um módulo para ver seus planos';

  @override
  String get package_title => 'Pacotes e Preços';

  @override
  String get package_viewPlans => 'Ver planos';

  @override
  String get perm_alwaysLocationBody =>
      'Para rastrear seu grupo em tempo real e em segundo plano, defina o acesso à localização como \'Permitir o tempo todo\' nas Configurações.';

  @override
  String get perm_alwaysLocationTitle =>
      'Ativar permissão de localização \'Sempre\'';

  @override
  String get perm_chooseAllowAllTime =>
      'Por favor, escolha \'Permitir o tempo todo\' no próximo pop-up.';

  @override
  String get perm_collectsLocationBody =>
      'Este aplicativo coleta dados de localização para garantir o progresso do trabalho e fornecer rastreamento eficiente, mesmo quando o app está fechado ou em segundo plano.';

  @override
  String get perm_enableDeviceGpsBody =>
      'Por favor, ative o GPS do seu dispositivo (Localização do Google).';

  @override
  String get perm_enableGpsTitle => 'Ativar GPS';

  @override
  String get perm_exitBody => 'Deseja sair do aplicativo?';

  @override
  String get perm_exitTitle => 'Tem certeza?';

  @override
  String get perm_gpsRequiredBody =>
      'O GPS é necessário para rastrear seu grupo em tempo real.';

  @override
  String get perm_locationTitle => 'Permissão de localização';

  @override
  String get perm_trackingPermissionBody =>
      'O aplicativo FG Partner precisa de sua permissão para rastrear a localização enquanto você estiver conectado.';

  @override
  String get permission_allowAllTheTime => 'Permitir Sempre';

  @override
  String get permission_allowLocation => 'Permitir Localização';

  @override
  String get permission_allowLocationFirst => 'Permita a localização primeiro.';

  @override
  String permission_allowNamed(String permission) {
    return 'Permitir $permission';
  }

  @override
  String get permission_allowNotifications => 'Permitir Notificações';

  @override
  String get permission_appPermissionsSubtitle =>
      'Revise as permissões necessárias.';

  @override
  String get permission_appPermissionsTitle => 'Permissões do App';

  @override
  String get permission_badgeGranted => 'Concedida';

  @override
  String get permission_badgeOptional => 'Opcional';

  @override
  String get permission_badgeRecommended => 'Recomendado';

  @override
  String get permission_badgeRequired => 'Obrigatório';

  @override
  String get permission_camera => 'Câmera';

  @override
  String get permission_cameraDescription =>
      'Usado por recursos do app que capturam fotos ou vídeos.';

  @override
  String get permission_cameraSettingsMessage =>
      'A permissão da câmera é necessária para fotos e vídeos. Ative nas configurações.';

  @override
  String get permission_cameraWhy =>
      'Permite tirar fotos e gravar vídeos para perfil, chat e outros recursos.';

  @override
  String get permission_contacts => 'Contatos';

  @override
  String get permission_contactsDescription =>
      'Usado para encontrar ou selecionar contatos para os recursos do app.';

  @override
  String get permission_contactsSettingsMessage =>
      'A permissão de contatos é necessária para buscar e selecionar contatos. Ative nas configurações.';

  @override
  String get permission_contactsWhy =>
      'Ajuda a encontrar e selecionar contatos facilmente ao usar os recursos.';

  @override
  String get permission_gateCheckFailed =>
      'Não foi possível verificar suas permissões. Tente novamente.';

  @override
  String get permission_gateSubtitle =>
      'O FG Tracker precisa dessas permissões para chamadas, alertas e para operar presença, rastreamento ao vivo e zona segura.';

  @override
  String get permission_gateTitle => 'Permissões Obrigatórias';

  @override
  String get permission_genericSettingsMessage =>
      'Esta permissão é necessária. Ative-a nas configurações do aplicativo.';

  @override
  String get permission_iosLocationServicesOff =>
      'Serviços de Localização estão desativados. Abra Ajustes → Privacidade e Segurança → Serviços de Localização e ative.';

  @override
  String get permission_location => 'Localização';

  @override
  String get permission_locationAndNotificationRequired =>
      'Permissões de localização e notificações são necessárias para continuar.';

  @override
  String get permission_locationAndNotificationsRequiredHint =>
      'Localização e Notificações são necessárias para continuar.';

  @override
  String get permission_locationDescription =>
      'Necessário para presença, rastreamento ao vivo e zona segura, mesmo em segundo plano.';

  @override
  String get permission_locationRequiredToContinue =>
      'A permissão de localização é necessária para continuar.';

  @override
  String get permission_locationStatusApproximate =>
      'Apenas localização aproximada permitida. É necessária a precisa.';

  @override
  String get permission_locationStatusBlocked =>
      'A localização está bloqueada. Ative nas Configurações.';

  @override
  String get permission_locationStatusDone =>
      'Permitido sempre · Preciso · GPS ativo';

  @override
  String get permission_locationStatusGpsOff =>
      'A localização do dispositivo (GPS) está desativada.';

  @override
  String get permission_locationStatusNeedAlways =>
      '\"Permitir sempre\" é obrigatório.';

  @override
  String get permission_locationStatusNotAllowed =>
      'Permissão de localização ainda não concedida.';

  @override
  String get permission_locationWhyExtra =>
      'Escolha \"Permitir sempre\" e mantenha a localização precisa ativada.';

  @override
  String get permission_logout => 'Sair';

  @override
  String get permission_microphone => 'Microfone / Áudio';

  @override
  String get permission_microphoneDescription =>
      'Usado por recursos de voz, walkie-talkie e chamadas.';

  @override
  String get permission_microphoneSettingsMessage =>
      'A permissão do microfone é necessária para voz, walkie-talkie e chamadas. Ative nas configurações.';

  @override
  String get permission_microphoneWhy =>
      'Permite comunicação por voz, transmissão de walkie-talkie e chamadas.';

  @override
  String permission_notGrantedNamed(String permission) {
    return 'A permissão $permission não foi concedida. Tente novamente.';
  }

  @override
  String get permission_notificationRequiredToContinue =>
      'A permissão de notificações é necessária para continuar.';

  @override
  String get permission_notificationSettingsText =>
      'As notificações estão desativadas para FG Tracker. Abra Configurações → Notificações e permita-as.';

  @override
  String get permission_notificationStatusBlocked =>
      'Notificações bloqueadas. Ative nas Configurações.';

  @override
  String get permission_notificationStatusDone => 'Permitido';

  @override
  String get permission_notificationStatusNotAllowed =>
      'Permissão de notificações ainda não concedida.';

  @override
  String get permission_notifications => 'Notificações';

  @override
  String get permission_notificationsDescription =>
      'Necessário para receber chamadas, mensagens e alertas de segurança.';

  @override
  String get permission_notificationsWhyExtra =>
      'Chamadas recebidas não tocarão sem esta permissão.';

  @override
  String get permission_openSettings => 'Abrir Configurações';

  @override
  String get permission_preciseLocation => 'Localização Precisa';

  @override
  String get permission_pushNotifications => 'Notificações Push';

  @override
  String get permission_reasonLocation =>
      'A localização é necessária para presença, rastreamento ao vivo e alertas de zona segura.';

  @override
  String get permission_reasonLocationAlways =>
      'Escolha \"Permitir o tempo todo\" para manter o rastreamento e a zona segura ativos em segundo plano.';

  @override
  String get permission_reasonNotification =>
      'As notificações são necessárias para receber chamadas, mensagens e alertas.';

  @override
  String get permission_reasonPrecise =>
      'A localização precisa é necessária para presença exata, rastreamento ao vivo e alertas.';

  @override
  String get permission_required => 'Permissão Necessária';

  @override
  String get permission_selectAllowAllTheTime =>
      'Selecione \"Permitir sempre\" para continuar.';

  @override
  String get permission_settingsAndroidAlways =>
      'Abra Configurações → Permissões → Localização e escolha \"Permitir sempre\".';

  @override
  String get permission_settingsAndroidBlocked =>
      'Acesso à localização bloqueado para FG Tracker. Abra Configurações → Permissões → Localização e escolha \"Permitir sempre\".';

  @override
  String get permission_settingsAndroidPrecise =>
      'Abra Configurações → Permissões → Localização e ative \"Usar localização precisa\".';

  @override
  String get permission_settingsIosAlways =>
      'Abra Ajustes → Localização e escolha \"Sempre\".';

  @override
  String get permission_settingsIosBlocked =>
      'Acesso à localização desativado para FG Tracker. Abra Ajustes → Localização e escolha \"Sempre\".';

  @override
  String get permission_settingsIosPrecise =>
      'Abra Ajustes → Localização e ative \"Localização Precisa\".';

  @override
  String get permission_skipAndContinue => 'Pular e Continuar';

  @override
  String get permission_turnOnLocation => 'Ativar Localização';

  @override
  String get permission_turnOnPreciseLocation => 'Ativar Localização Precisa';

  @override
  String get permission_unableToRequest =>
      'Não foi possível solicitar a permissão.';

  @override
  String get permission_whyWeNeedThis => 'Por que precisamos disso?';

  @override
  String get registration_contactNumberHint => 'Digite o número de contato';

  @override
  String get registration_contactNumberLabel => 'Número de contato';

  @override
  String get registration_doneButton => 'Concluir';

  @override
  String get registration_emailHint => 'Digite o endereço de e-mail';

  @override
  String get registration_emailLabel => 'Endereço de e-mail';

  @override
  String get registration_genderFemale => 'Feminino';

  @override
  String get registration_genderLabel => 'Selecionar gênero';

  @override
  String get registration_genderMale => 'Masculino';

  @override
  String get registration_genderOther => 'Outro';

  @override
  String get registration_selectGenderError =>
      'Por favor, selecione seu gênero';

  @override
  String get registration_userNameHint => 'Digite o nome de usuário';

  @override
  String get registration_userNameLabel => 'Nome de usuário';

  @override
  String get repo_allCallsCleared => 'Todo o histórico de chamadas foi limpo';

  @override
  String get repo_callDeleted => 'Histórico de chamadas excluído com sucesso';

  @override
  String get repo_invalidResponse => 'Formato de resposta inválido';

  @override
  String get repo_loadLocationsFailed =>
      'Falha ao carregar as localizações do grupo';

  @override
  String get repo_pkgConflict =>
      'Este plano já está ativo ou há um pagamento em andamento.';

  @override
  String get repo_pkgNotFound =>
      'Os planos não estão disponíveis no momento. Tente novamente mais tarde.';

  @override
  String get repo_pkgOffline =>
      'Sem conexão com a internet. Verifique sua rede e tente novamente.';

  @override
  String get repo_pkgSessionExpired =>
      'Sua sessão expirou. Faça login novamente.';

  @override
  String get repo_pkgTimeout =>
      'O servidor está demorando muito para responder. Tente novamente.';

  @override
  String get repo_selectedCallsDeleted =>
      'Chamadas selecionadas excluídas com sucesso';

  @override
  String get repo_unnamedGroup => 'Grupo sem nome';

  @override
  String safeRoute_activeDetails(String distance, String deviation) {
    return 'Distância Total: $distance  •  Desvio Permitido: $deviation';
  }

  @override
  String get safeRoute_activeTitle => 'Rota Segura Ativa';

  @override
  String get safeRoute_alertSettingsDesc =>
      'Gerencie alertas de rota, limites de desvio e notificações.';

  @override
  String get safeRoute_alertSheetDesc =>
      'Alertas em tempo real quando membros desviam da rota segura';

  @override
  String get safeRoute_alertTitle => 'Alerta de Rota Segura';

  @override
  String get safeRoute_appBarSubtitle =>
      'Defina uma rota segura para o membro da equipe.';

  @override
  String get safeRoute_destination => 'Destino';

  @override
  String get safeRoute_deviated => 'Desviou da rota segura';

  @override
  String safeRoute_deviationAlertNote(String distance) {
    return 'Um alerta será acionado se o membro se desviar mais de $distance.';
  }

  @override
  String safeRoute_deviationAt(String place, String distance) {
    return '$place (Desvio: $distance)';
  }

  @override
  String get safeRoute_deviationLimit => 'Limite de Desvio';

  @override
  String get safeRoute_deviationSubtitle =>
      'Defina quanto desvio é permitido da rota.';

  @override
  String get safeRoute_distance => 'Distância';

  @override
  String safeRoute_distanceEta(String distance, int minutes) {
    return '$distance km • $minutes min';
  }

  @override
  String get safeRoute_edit => 'Editar Rota Segura';

  @override
  String get safeRoute_end => 'Fim';

  @override
  String safeRoute_estTime(int minutes) {
    return 'Tempo Estimado: $minutes min';
  }

  @override
  String get safeRoute_featureDesc =>
      'Defina rotas predefinidas. Receba alertas se alguém se desviar da rota segura.';

  @override
  String safeRoute_groupWithCount(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
    );
    return '$group ($_temp0)';
  }

  @override
  String get safeRoute_helpDeviationBody =>
      'Distância permitida fora da rota. Você receberá um alerta se o limite for ultrapassado.';

  @override
  String get safeRoute_helpDeviationTitle => 'O que é Limite de Desvio?';

  @override
  String get safeRoute_helpHowBody =>
      'Selecione o membro, escolha início e destino, escolha a melhor rota e defina o desvio.';

  @override
  String get safeRoute_helpHowTitle => 'Como Criar uma Rota Segura?';

  @override
  String get safeRoute_helpTitle => 'Ajuda com Rota Segura';

  @override
  String get safeRoute_helpWhatBody =>
      'Defina partida e destino para criar uma rota segura para seu membro.';

  @override
  String get safeRoute_helpWhatTitle => 'O que é Rota Segura?';

  @override
  String safeRoute_memberDeviated(String name) {
    return '$name desviou da Rota Segura';
  }

  @override
  String get safeRoute_recommended => 'Recomendado';

  @override
  String safeRoute_recommendedRoute(String name) {
    return '$name (Recomendado)';
  }

  @override
  String safeRoute_routeFor(String name) {
    return 'Rota ($name)';
  }

  @override
  String get safeRoute_saveActivate => 'Salvar e Ativar Rota Segura';

  @override
  String get safeRoute_saveActivateGroup => 'Salvar e Ativar Rota para o Grupo';

  @override
  String get safeRoute_selectedRoute => 'Rota Selecionada';

  @override
  String get safeRoute_setRoutesSubtitle =>
      'Crie e gerencie rotas seguras para todos os membros.';

  @override
  String get safeRoute_start => 'Início';

  @override
  String get safeRoute_startLocation => 'Local de Partida';

  @override
  String safeRoute_stepDeviation(int step) {
    return '$step. Definir Limite de Desvio';
  }

  @override
  String safeRoute_stepPreviewApply(int step) {
    return '$step. Visualizar e Aplicar';
  }

  @override
  String safeRoute_stepPreviewRoute(int step) {
    return '$step. Pré-visualizar Rota';
  }

  @override
  String safeRoute_stepSelectRoute(int step) {
    return '$step. Selecionar Rota';
  }

  @override
  String safeRoute_stepSetRoutesForMembers(int step) {
    return '$step. Definir Rotas para Membros';
  }

  @override
  String safeRoute_stepStartDest(int step) {
    return '$step. Definir Partida e Destino';
  }

  @override
  String get safeRoute_subtitle => 'Proteção de rota';

  @override
  String get safeRoute_title => 'Rota Segura';

  @override
  String safeZone_activeDetails(String radius, String center) {
    return 'Raio: $radius  •  Centro: $center';
  }

  @override
  String get safeZone_activePreview => 'Ativo (Pré-visualização)';

  @override
  String get safeZone_activeTitle => 'Zona Segura Ativa';

  @override
  String get safeZone_alertSettingsDesc =>
      'Gerencie zona segura, distância de alerta e notificações';

  @override
  String get safeZone_alertSheetDesc =>
      'Alertas em tempo real quando membros saem da zona segura';

  @override
  String get safeZone_alertTitle => 'Alerta de Zona Segura';

  @override
  String safeZone_allMonitored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todos os $count membros serão monitorados\nnesta zona segura.',
      one: '1 membro será monitorado\nnesta zona segura.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_appBarSubtitle =>
      'Defina uma área segura. Receba alertas se alguém\nsair da zona.';

  @override
  String safeZone_appliedToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Esta zona segura será aplicada a todos os $count membros do grupo selecionado.',
      one: 'Esta zona segura será aplicada ao 1 membro do grupo selecionado.',
    );
    return '$_temp0';
  }

  @override
  String get safeZone_edit => 'Editar Zona Segura';

  @override
  String get safeZone_exited => 'Saiu da zona segura';

  @override
  String get safeZone_featureDesc =>
      'Defina uma área segura para sua equipe. Receba alertas se alguém sair da zona segura.';

  @override
  String get safeZone_helpHowBody =>
      'Selecione um membro, escolha um local no mapa e defina o raio.';

  @override
  String get safeZone_helpHowTitle => 'Como Criar uma Zona Segura?';

  @override
  String get safeZone_helpRadiusBody =>
      'Defina o raio (500 m, 1 km, 2 km ou 5 km) conforme sua necessidade.';

  @override
  String get safeZone_helpRadiusTitle => 'O que é o Raio da Zona Segura?';

  @override
  String get safeZone_helpTitle => 'Ajuda com Zona Segura';

  @override
  String get safeZone_helpWhatBody =>
      'Defina uma área no mapa e receba alertas se o membro sair da zona.';

  @override
  String get safeZone_helpWhatTitle => 'O que é Zona Segura?';

  @override
  String safeZone_memberLeft(String name) {
    return '$name saiu da Zona Segura';
  }

  @override
  String get safeZone_membersMonitored =>
      'Os membros serão monitorados dentro desta zona segura.';

  @override
  String safeZone_nearOutsideZone(String place, String zone) {
    return 'Perto de $place (Fora da $zone)';
  }

  @override
  String safeZone_outsideZone(String place, String zone) {
    return '$place (Fora da $zone)';
  }

  @override
  String get safeZone_saveActivate => 'Salvar e Ativar Zona Segura';

  @override
  String get safeZone_saveActivateGroup =>
      'Salvar e Ativar Zona Segura para o Grupo';

  @override
  String get safeZone_searchLocation => 'Pesquisar Local...';

  @override
  String get safeZone_statusLabel => 'Status:';

  @override
  String safeZone_stepPreview(int step) {
    return '$step. Pré-visualizar Zona Segura';
  }

  @override
  String safeZone_stepRadius(int step) {
    return '$step. Definir Raio da Zona Segura';
  }

  @override
  String safeZone_stepSelectLocation(int step) {
    return '$step. Selecionar Local no Mapa';
  }

  @override
  String get safeZone_subtitle => 'Proteção de área';

  @override
  String get safeZone_title => 'Zona Segura';

  @override
  String safeZone_totalMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Total de $count Membros',
      one: 'Total 1 Membro',
    );
    return '$_temp0';
  }

  @override
  String get safety_active => 'Ativo';

  @override
  String get safety_alertSettings => 'Configurações de Alerta';

  @override
  String get safety_alerts => 'Alertas';

  @override
  String get safety_alertsDesc => 'Requerem atenção imediata';

  @override
  String get safety_bannerBody =>
      'Monitore e proteja sua equipe com recursos inteligentes de segurança.';

  @override
  String get safety_bannerTitle => 'Sua Segurança, Nossa Prioridade';

  @override
  String get safety_chooseFeature => 'Escolha um Recurso de Segurança';

  @override
  String get safety_comingSoonBody =>
      'Recursos inteligentes de segurança para proteger sua equipe em breve.';

  @override
  String get safety_contactSupport => 'Fale com o Suporte';

  @override
  String get safety_editAnytime =>
      'Você pode editar ou desativar a qualquer momento depois.';

  @override
  String get safety_mapCityPark => 'Parque da Cidade';

  @override
  String get safety_mapMainRoad => 'Estrada Principal';

  @override
  String get safety_mapMarketLane => 'Beco do Mercado';

  @override
  String get safety_mapRiver => 'Rio';

  @override
  String get safety_mapStationRoad => 'Rua da Estação';

  @override
  String get safety_needHelpBody =>
      'Entre em contato com o suporte para assistência de segurança.';

  @override
  String get safety_quickOverview => 'Visão Geral Rápida';

  @override
  String get safety_recentAlerts => 'Alertas Recentes';

  @override
  String get safety_recenter => 'Recentralizar';

  @override
  String get safety_safeNow => 'Seguro Agora';

  @override
  String get safety_safeNowDesc => 'Membros estão dentro da zona/rota segura';

  @override
  String safety_stepSelectGroup(int step) {
    return '$step. Selecionar Grupo';
  }

  @override
  String safety_stepSelectMember(int step) {
    return '$step. Selecionar Membro';
  }

  @override
  String get safety_tabIndividual => 'Individual';

  @override
  String get safety_tagline => 'Fique protegido. Fique conectado.';

  @override
  String get safety_title => 'Segurança';

  @override
  String get safety_viewAllMembers => 'Ver Todos os Membros';

  @override
  String get sheet_addGroupMember => 'Adicionar membro ao grupo';

  @override
  String get sheet_admin => 'Admin';

  @override
  String get sheet_attachSubtitle =>
      'Compartilhe arquivos e mídias com sua equipe';

  @override
  String get sheet_attachUpload => 'Anexar / Enviar';

  @override
  String get sheet_attendance => 'Presença';

  @override
  String get sheet_callOptions => 'Opções de chamada';

  @override
  String get sheet_cantRemoveSelf =>
      'Você não pode remover a si mesmo do grupo.';

  @override
  String get sheet_contact => 'Contato';

  @override
  String get sheet_contactsNotOnApp =>
      'Seus contatos ainda não usam o FG Tracker.';

  @override
  String get sheet_document => 'Documento';

  @override
  String get sheet_groupMembers => 'Membros do grupo';

  @override
  String get sheet_location => 'Localização';

  @override
  String get sheet_memberRemoved => 'Membro removido com sucesso';

  @override
  String get sheet_noMembers => 'Nenhum membro encontrado';

  @override
  String get sheet_noRegisteredContacts => 'Nenhum contato registrado';

  @override
  String get sheet_noUserFound => 'Nenhum usuário encontrado';

  @override
  String get sheet_normalAudioCall => 'Chamada de voz normal';

  @override
  String get sheet_normalAudioCallSubtitle => 'Qualidade de voz nítida padrão';

  @override
  String sheet_registeredContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos cadastrados',
      one: '1 contato cadastrado',
    );
    return '$_temp0';
  }

  @override
  String sheet_removeMemberConfirm(String name) {
    return 'Tem certeza de que deseja remover $name do grupo?';
  }

  @override
  String get sheet_removeMemberTitle => 'Remover membro';

  @override
  String get sheet_searchContacts => 'Pesquisar contatos';

  @override
  String get sheet_walkieCall => 'Chamada de Walkie-Talkie';

  @override
  String get sheet_walkieCallSubtitle => 'Comunicação aperte para falar (PTT)';

  @override
  String get sos_addDetailsMandatory => 'Adicionar Detalhes (Obrigatório)';

  @override
  String get sos_addDetailsOptional => 'Adicionar Detalhes (Opcional)';

  @override
  String get sos_addFamilyMember => 'Adicionar Membro da Família';

  @override
  String get sos_addFamilyMemberRequired =>
      'Adicione pelo menos 1 membro da família para enviar alerta SOS';

  @override
  String get sos_addPhotoHint =>
      'Anexe uma foto para ajudar a entender melhor.';

  @override
  String get sos_addPhotoOptional => 'Adicionar Foto (Opcional)';

  @override
  String get sos_alertSent => 'Alerta SOS Enviado!';

  @override
  String get sos_alertSentToNearby =>
      'Seu alerta foi enviado para pessoas próximas.';

  @override
  String get sos_alertWillBeSent =>
      'O alerta será enviado para pessoas próximas';

  @override
  String get sos_alertWillBeSentFamily =>
      'Seu alerta será enviado para pessoas próximas e sua família.';

  @override
  String sos_availableUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usuários disponíveis',
      one: '1 usuário disponível',
    );
    return '$_temp0';
  }

  @override
  String get sos_detailsHint => 'Digite detalhes adicionais...';

  @override
  String get sos_detailsMandatoryForOther =>
      'Adicionar detalhes é obrigatório ao selecionar \'Outro\'';

  @override
  String get sos_howItWorks => 'Como funciona';

  @override
  String get sos_howItWorksIntro =>
      'O Alerta SOS notifica pessoas próximas e sua família em situações de emergência.';

  @override
  String get sos_howItWorksTitle => 'Como Funciona o Alerta SOS?';

  @override
  String get sos_liveTrackingStarted => 'Rastreamento ao vivo iniciado';

  @override
  String sos_locationSharedWithFamily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sua localização está sendo compartilhada com $count familiares',
      one: 'Sua localização está sendo compartilhada com 1 familiar',
    );
    return '$_temp0';
  }

  @override
  String sos_membersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros selecionados',
      one: '1 membro selecionado',
    );
    return '$_temp0';
  }

  @override
  String get sos_needHelp => 'Precisa de Ajuda?';

  @override
  String get sos_needHelpBody =>
      'Envie um alerta SOS para pessoas próximas.\nElas serão notificadas e poderão te ajudar.';

  @override
  String get sos_noMatchFound => 'Nenhuma correspondência encontrada';

  @override
  String get sos_noUsersFound => 'Nenhum usuário encontrado';

  @override
  String get sos_notifyFamilyTitle =>
      'Notifique sua Família (1 a 5 obrigatórios)';

  @override
  String get sos_notifyUpdates =>
      'Notificaremos você sobre qualquer atualização';

  @override
  String get sos_okGotIt => 'Entendi';

  @override
  String get sos_peopleWithinRadius => 'Pessoas em um raio de 2 km';

  @override
  String get sos_privacyNote =>
      'Sua privacidade é essencial. Sua localização só é compartilhada durante um alerta SOS ativo.';

  @override
  String get sos_reasonAccident => 'Acidente';

  @override
  String get sos_reasonMedical => 'Médica';

  @override
  String get sos_reasonOther => 'Outro';

  @override
  String get sos_reasonSafety => 'Segurança';

  @override
  String get sos_reasonThreat => 'Ameaça';

  @override
  String get sos_required => 'Obrigatório';

  @override
  String get sos_searchUsers => 'Pesquisar usuários';

  @override
  String get sos_selectReason => 'Selecione o Motivo';

  @override
  String get sos_sendSosAlert => 'Enviar Alerta SOS';

  @override
  String get sos_stayCalm => 'Mantenha a calma, a ajuda está a caminho';

  @override
  String get sos_step1Body =>
      'Toque no botão SOS e envie um alerta para as pessoas próximas.';

  @override
  String get sos_step1Title => '1. Enviar Alerta SOS';

  @override
  String get sos_step2Body =>
      'Pessoas próximas receberão seu alerta com sua localização.';

  @override
  String get sos_step2Title => '2. Notificar Pessoas Próximas';

  @override
  String get sos_step3Body =>
      'Pessoas próximas podem ver seu alerta e vir em seu auxílio.';

  @override
  String get sos_step3Title => '3. Obtenha Ajuda Mais Rápido';

  @override
  String get sos_step4Body =>
      'Seus familiares serão notificados instantaneamente sobre seu SOS.';

  @override
  String get sos_step4Title => '4. Família é Notificada';

  @override
  String get sos_subtitle => 'Envie alerta para pessoas próximas';

  @override
  String get sos_title => 'Alerta SOS';

  @override
  String get sos_willBeNotified => 'serão notificados';

  @override
  String status_activeCount(int count) {
    return '$count ativos';
  }

  @override
  String get status_addToMyStatus => 'Adicionar ao meu status';

  @override
  String get status_allContacts => 'Todos os contatos';

  @override
  String get status_cameraAccessFailed => 'Não foi possível acessar a câmera';

  @override
  String get status_captionHint => 'Adicionar uma legenda...';

  @override
  String get status_changeMedia => 'Alterar mídia';

  @override
  String status_dayAtTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get status_deleted => 'Status excluído';

  @override
  String get status_deletedByOwner =>
      'Este status foi excluído pelo proprietário';

  @override
  String get status_exceptContacts => 'Exceto contatos';

  @override
  String get status_exceptSelected => 'Exceto selecionados';

  @override
  String get status_flip => 'Girar';

  @override
  String get status_gallery => 'Galeria';

  @override
  String get status_modePhoto => 'Foto';

  @override
  String get status_modeText => 'Texto';

  @override
  String get status_modeVideo => 'Vídeo';

  @override
  String get status_myStatus => 'Meu status';

  @override
  String get status_new => 'Novo';

  @override
  String get status_noCamera => 'Nenhuma câmera disponível';

  @override
  String get status_noLongerAvailable => 'Este status não está mais disponível';

  @override
  String get status_noViewsYet => 'Nenhuma visualização ainda';

  @override
  String get status_onlyShareWith => 'Compartilhar apenas com';

  @override
  String get status_pause => 'Pausar';

  @override
  String get status_pinchZoomHint =>
      'Faça movimento de pinça para zoom na foto';

  @override
  String get status_play => 'Reproduzir';

  @override
  String get status_postStatus => 'Publicar status';

  @override
  String get status_previewStatus => 'Prévia do status';

  @override
  String get status_privacy => 'Privacidade';

  @override
  String get status_privacyTitle => 'Privacidade do status';

  @override
  String get status_publishFailed => 'Não foi possível publicar o status';

  @override
  String get status_replyHint => 'Responder ao status...';

  @override
  String get status_retake => 'Repetir';

  @override
  String get status_selectPhotoFirst =>
      'Por favor, tire ou selecione uma foto primeiro';

  @override
  String get status_selectVideoFirst =>
      'Por favor, grave ou selecione um vídeo primeiro';

  @override
  String get status_shareUpdatesHint =>
      'Compartilhe atualizações com sua equipe';

  @override
  String get status_tapVideoHint => 'Toque no vídeo para reproduzir / pausar';

  @override
  String get status_textRequired =>
      'Conteúdo de texto obrigatório para status de texto';

  @override
  String get status_title => 'Status';

  @override
  String get status_typeHint => 'Digite um status...';

  @override
  String get status_uploadFailed => 'Falha no envio';

  @override
  String get status_viewMyStatus => 'Ver meu status';

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
      other: '$count visualizações',
      one: '1 visualização',
    );
    return '$_temp0';
  }

  @override
  String get status_whoCanSee => 'Quem pode ver?';

  @override
  String get track_admin => 'Admin';

  @override
  String get track_applyRadius => 'Aplicar Raio';

  @override
  String get track_checkNetworkConnection =>
      'Verifique sua conexão de rede e tente novamente.';

  @override
  String get track_checkNetworkMembers =>
      'Verifique sua rede e tente novamente para ver membros próximos.';

  @override
  String get track_currentLocation => 'Localização Atual';

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
  String get track_enable => 'Ativar';

  @override
  String get track_enableGpsBody =>
      'Para rastrear seu grupo em tempo real, ative o GPS.';

  @override
  String get track_enableGpsTitle => 'Ativar GPS';

  @override
  String get track_errorFailedLoadGroups => 'Falha ao carregar grupos';

  @override
  String get track_errorLoadGroups =>
      'Não foi possível carregar grupos. Tente novamente.';

  @override
  String get track_errorLoadMembers =>
      'Não foi possível carregar membros próximos. Tente novamente.';

  @override
  String get track_errorNoInternet =>
      'Sem conexão com a internet. Verifique sua rede.';

  @override
  String get track_errorServer =>
      'Não foi possível conectar ao servidor. Tente novamente.';

  @override
  String track_groupCode(String code) {
    return 'Código: $code';
  }

  @override
  String get track_groupMembers => 'Membros do Grupo';

  @override
  String track_groupMembersAndCode(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros • Código: $code',
      one: '1 membro • Código: $code',
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
      'Crie um grupo para rastrear vários membros.';

  @override
  String get track_helpGroupTitle => 'Como Adicionar um Grupo?';

  @override
  String get track_helpLiveBody =>
      'Acompanhe a localização em tempo real da equipe no mapa.';

  @override
  String get track_helpLiveTitle => 'O que é Rastreamento ao Vivo?';

  @override
  String get track_helpRadiusBody =>
      'Defina a área para encontrar membros próximos no mapa.';

  @override
  String get track_helpRadiusTitle => 'O que é o Raio de Rastreamento?';

  @override
  String get track_helpTitle => 'Ajuda com Rastreamento';

  @override
  String track_lastSeen(String time) {
    return 'Visto pela última vez: $time';
  }

  @override
  String track_liveCount(int count) {
    return '$count Ao Vivo';
  }

  @override
  String get track_liveMembers => 'Membros ao Vivo';

  @override
  String get track_liveTracking => 'Rastreamento ao Vivo';

  @override
  String get track_locating => 'Localizando...';

  @override
  String get track_locationHidden => 'Localização Oculta';

  @override
  String get track_locationUnavailable => 'Localização indisponível';

  @override
  String get track_mapOfflineBody =>
      'Conexão com a internet necessária para carregar mapa e localizações em tempo real.';

  @override
  String get track_mapUnavailableOffline => 'Mapa Indisponível Offline';

  @override
  String get track_member => 'Membro';

  @override
  String track_memberPausedSharing(String name) {
    return '$name pausou o compartilhamento de localização. Localização ao vivo indisponível.';
  }

  @override
  String track_membersHeader(int count) {
    return 'MEMBROS ($count)';
  }

  @override
  String track_membersLive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros ao vivo',
      one: '1 membro ao vivo',
    );
    return '$_temp0';
  }

  @override
  String get track_menuMembers => 'Membros';

  @override
  String get track_menuRefreshMap => 'Atualizar Mapa';

  @override
  String get track_menuTheme => 'Tema';

  @override
  String get track_nearbyYou => 'Perto de você';

  @override
  String get track_noActiveMembers => 'Nenhum membro ativo';

  @override
  String track_noActiveMembersWithin(String radius) {
    return 'Nenhum membro ativo encontrado dentro de $radius';
  }

  @override
  String get track_noDescription => 'Sem descrição';

  @override
  String get track_noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get track_noGroupsMatch => 'Nenhum grupo correspondente';

  @override
  String track_noGroupsMatchQuery(String query) {
    return 'Nenhum grupo corresponde a \'$query\'';
  }

  @override
  String get track_noGroupsYet =>
      'Você ainda não entrou nem criou nenhum grupo.';

  @override
  String get track_noInternetTitle => 'Sem Conexão com a Internet';

  @override
  String get track_noMembersFound => 'Nenhum membro encontrado';

  @override
  String get track_noMembersFoundPlain => 'Nenhum membro encontrado';

  @override
  String get track_noMembersInGroup => 'Nenhum membro encontrado neste grupo';

  @override
  String track_noMembersMatch(String query) {
    return 'Nenhum membro corresponde a \'$query\'';
  }

  @override
  String track_noSearchMatches(String query) {
    return 'Nenhum membro ou grupo correspondente';
  }

  @override
  String track_noSearchResults(String query) {
    return 'Nenhum membro ou grupo encontrado para \'$query\'';
  }

  @override
  String get track_notAvailable => 'N/D';

  @override
  String get track_offlineBanner =>
      'Sem conexão com a internet. Mapa e rastreamento estão offline.';

  @override
  String get track_private => 'Privado';

  @override
  String get track_radius => 'Raio';

  @override
  String get track_refresh => 'Atualizar';

  @override
  String get track_refreshing => 'Atualizando...';

  @override
  String get track_retryConnection => 'Tentar Conexão Novamente';

  @override
  String get track_searchHint => 'Pesquisar membros ou grupos...';

  @override
  String get track_searchMembersHint => 'Pesquisar Membros...';

  @override
  String get track_selectedLocation => 'Local Selecionado';

  @override
  String get track_setRadiusSubtitle =>
      'Deslize para selecionar o raio da área';

  @override
  String get track_setRadiusTitle => 'Definir Raio de Rastreamento';

  @override
  String get track_unableToLoadGroups => 'Não foi possível carregar os grupos';

  @override
  String get track_unableToLoadMembers =>
      'Não foi possível carregar os membros';

  @override
  String get track_unnamedGroup => 'Grupo sem nome';

  @override
  String get track_unnamedMember => 'Membro Sem Nome';

  @override
  String get track_yourGroups => 'Seus Grupos';

  @override
  String get track_yourLocationPaused =>
      'Seu compartilhamento de localização está pausado e privado.';

  @override
  String get util_previewContact => '👤 Contato';

  @override
  String get util_previewDocument => '📄 Documento';

  @override
  String get util_previewLocation => '📍 Localização';

  @override
  String get util_previewPhoto => '📷 Foto';

  @override
  String get util_previewVideo => '🎥 Vídeo';

  @override
  String get util_previewVoice => '🎤 Mensagem de voz';

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
      other: '$rupees rúpias',
      one: '1 rúpia',
    );
    return '$_temp0';
  }

  @override
  String util_spokenRupeesPaise(int rupees, int paise) {
    return '$rupees rúpias e $paise paise';
  }

  @override
  String util_spokenUsd(String amount) {
    return '$amount dólares americanos';
  }

  @override
  String get util_unableToCallContact =>
      'Não foi possível ligar para este contato';

  @override
  String get util_unableToStartGroupCall =>
      'Não foi possível iniciar a chamada em grupo';

  @override
  String get validation_emailEmpty =>
      'O endereço de e-mail não pode ficar em branco';

  @override
  String get validation_emailInvalid => 'Por favor, insira um e-mail válido.';

  @override
  String validation_required(String field) {
    return '$field é obrigatório';
  }

  @override
  String get voice_appLanguage => 'Idioma do app';

  @override
  String get voice_audioChip => 'ÁUDIO';

  @override
  String get voice_captionReady => 'Legenda pronta';

  @override
  String get voice_chooseSpeechLanguage => 'Escolher Idioma da Fala';

  @override
  String get voice_couldntPlay =>
      'Não foi possível reproduzir a mensagem de voz';

  @override
  String get voice_didntCatch =>
      'Não entendi. Toque no microfone e fale um pouco mais alto.';

  @override
  String get voice_language => 'Idioma';

  @override
  String get voice_listenBack => 'Ouvir gravação';

  @override
  String get voice_listenBeforeSending =>
      'Ouça antes de enviar sua mensagem de voz.';

  @override
  String get voice_listening => 'Ouvindo…';

  @override
  String get voice_micPermissionNeeded =>
      'A permissão do microfone é necessária para usar voz.';

  @override
  String get voice_micUnavailable =>
      'Microfone indisponível. Verifique as configurações.';

  @override
  String get voice_noTextCaptured =>
      'Nenhum texto capturado — tente gravar novamente.';

  @override
  String get voice_openSettings => 'Abrir configurações';

  @override
  String get voice_permissionRequired => 'Permissão Necessária';

  @override
  String get voice_reRecord => 'Gravar Novamente';

  @override
  String get voice_readyToSend => 'Pronto para enviar';

  @override
  String get voice_recordVoice => 'Gravar Voz';

  @override
  String get voice_recordVoiceSubtitle => 'Grave e envie como mensagem de voz';

  @override
  String get voice_recordingYourVoice => 'Gravando sua voz…';

  @override
  String get voice_replyReady => 'Resposta pronta';

  @override
  String get voice_reviewTextHint =>
      'Ouça sua voz acima ou edite o texto na caixa antes de enviar.';

  @override
  String get voice_sendMessage => 'Enviar mensagem';

  @override
  String get voice_sendVoiceMessage => 'Enviar mensagem de voz';

  @override
  String get voice_speakNowCaption =>
      'Fale agora – estamos digitando sua legenda';

  @override
  String get voice_speakNowMessage =>
      'Fale agora – suas palavras aparecerão na caixa de texto';

  @override
  String get voice_speakNowReply =>
      'Fale agora – estamos digitando sua resposta';

  @override
  String get voice_speakPlaceholder => 'Fale… seu texto aparecerá aqui';

  @override
  String get voice_speechPermissionNeeded =>
      'A permissão de reconhecimento de voz é necessária para transcrever.';

  @override
  String get voice_tapToStop => 'Toque para parar';

  @override
  String get voice_textReady => 'Texto pronto';

  @override
  String get voice_tooMuchNoise =>
      'Muito barulho – aproxime o telefone e fale com clareza';

  @override
  String get voice_type => 'Tipo';

  @override
  String get voice_voiceToText => 'Voz para Texto';

  @override
  String get voice_voiceToTextSubtitle =>
      'Fale para digitar na caixa de mensagens';

  @override
  String get voice_willSendAudioMessage =>
      'Sua voz será enviada como mensagem de voz';

  @override
  String get voice_willSendAudioReply =>
      'Sua voz será enviada como resposta de áudio';

  @override
  String get voice_willSendWithFile =>
      'Sua voz será enviada junto com o arquivo';

  @override
  String get voice_yourMessage => 'Sua mensagem';

  @override
  String get voice_yourVoiceMessage => 'Sua mensagem de voz';

  @override
  String get walkiePlan_availableIndividualPlans => 'Planos Individuais';

  @override
  String get walkiePlan_availablePerMonth => '/ mês';

  @override
  String get walkiePlan_availablePerSeat => '/ vaga';

  @override
  String get walkiePlan_availableSingleMember =>
      'Membro Individual (Acesso Pessoal)';

  @override
  String get walkiePlan_availableSubtitle =>
      'Selecione um plano para iniciar ou atualizar sua assinatura';

  @override
  String get walkiePlan_availableTeamPlans => 'Planos de Equipe';

  @override
  String walkiePlan_availableTeamSeats(int min, int max) {
    return '$min-$max vagas  •  Colaboração em Grupo';
  }

  @override
  String get walkiePlan_availableTitle => 'Planos Disponíveis';

  @override
  String get walkiePlan_bottomBarAfterTrial => 'Após seu teste grátis';

  @override
  String get walkiePlan_bottomBarChoosePlan => 'Escolha um Plano';

  @override
  String get walkiePlan_bottomBarContinue => 'Continuar com Walkie Talkie';

  @override
  String walkiePlan_bottomBarPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String walkiePlan_bottomBarPurchaseFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get walkiePlan_cardActive => 'Ativo';

  @override
  String walkiePlan_cardActiveSince(String date) {
    return 'Ativo desde $date';
  }

  @override
  String get walkiePlan_cardAssigned => 'Atribuído';

  @override
  String walkiePlan_cardAssignedBy(String name) {
    return 'Atribuído por $name';
  }

  @override
  String get walkiePlan_cardAssignedToYou => 'Atribuído a Você';

  @override
  String get walkiePlan_cardAvailable => 'Disponível';

  @override
  String get walkiePlan_cardManageMembers => 'Gerenciar Membros';

  @override
  String get walkiePlan_cardNoActiveIndividual =>
      'Nenhuma assinatura individual ativa';

  @override
  String get walkiePlan_cardNoActiveTeam =>
      'Nenhum plano de equipe ativo ou vaga atribuída';

  @override
  String get walkiePlan_cardOneSeatSelf => '1 Vaga (Próprio)';

  @override
  String get walkiePlan_cardPersonal => 'Pessoal';

  @override
  String get walkiePlan_cardPurchased => 'Comprado';

  @override
  String get walkiePlan_cardPurchasedByYou => 'Comprado por Você';

  @override
  String get walkiePlan_cardPurchasedOn => 'Comprado em';

  @override
  String get walkiePlan_cardSeatsMembers => 'Vagas / Membros';

  @override
  String get walkiePlan_cardSubscribedByYou => 'Assinado por Você';

  @override
  String get walkiePlan_cardTeamAdministrator => 'Administrador da Equipe';

  @override
  String get walkiePlan_cardValidUntil => 'Válido Até';

  @override
  String get walkiePlan_cardView => 'Ver';

  @override
  String get walkiePlan_cardViewPlan => 'Ver Plano';

  @override
  String walkiePlan_couponDiscount(String value) {
    return 'Desconto de $value';
  }

  @override
  String get walkiePlan_couponExpired => 'O cupom expirou';

  @override
  String walkiePlan_couponFlatOff(String amount) {
    return 'Desconto direto de $amount';
  }

  @override
  String get walkiePlan_couponMinOrderNotMet =>
      'Valor mínimo do pedido não atingido';

  @override
  String get walkiePlan_couponNotEligible => 'Não elegível para o plano atual';

  @override
  String get walkiePlan_couponNotStarted =>
      'A oferta do cupom ainda não está ativa';

  @override
  String walkiePlan_couponPercentOff(int percent) {
    return '$percent% de Desconto';
  }

  @override
  String get walkiePlan_couponPlanNotApplicable => 'Não aplicável a este plano';

  @override
  String walkiePlan_couponValidTill(String date) {
    return 'Válido até $date';
  }

  @override
  String get walkiePlan_ctrlContinueToPayment => 'Continuar para o Pagamento';

  @override
  String walkiePlan_ctrlContinueWith(String plan) {
    return 'Continuar com $plan';
  }

  @override
  String get walkiePlan_ctrlCouponApplied => 'Cupom aplicado com sucesso!';

  @override
  String walkiePlan_ctrlCouponAppliedSave(String amount) {
    return 'Cupom aplicado! Você economiza $amount';
  }

  @override
  String get walkiePlan_ctrlCouponFailed => 'Falha ao aplicar cupom';

  @override
  String get walkiePlan_ctrlCouponRemoved => 'Cupom removido';

  @override
  String walkiePlan_ctrlGatewayError(String code) {
    return 'Erro do Cashfree ($code)';
  }

  @override
  String get walkiePlan_ctrlGatewayInitFailed =>
      'Falha na inicialização do pagamento.';

  @override
  String walkiePlan_ctrlGatewaySessionFailed(String error) {
    return 'Falha ao criar sessão de pagamento: $error';
  }

  @override
  String walkiePlan_ctrlGatewayUnableToProcess(String error) {
    return 'Não foi possível processar o pagamento: $error';
  }

  @override
  String get walkiePlan_ctrlLoadingPlans => 'Carregando planos...';

  @override
  String get walkiePlan_ctrlUnableToLoadPlans =>
      'Não foi possível carregar os planos. Tente novamente.';

  @override
  String get walkiePlan_detailsAllBanks =>
      'Compatível com todos os bancos indianos';

  @override
  String get walkiePlan_detailsApplied => 'Aplicado';

  @override
  String get walkiePlan_detailsApply => 'Aplicar';

  @override
  String get walkiePlan_detailsApplyCaps => 'APLICAR';

  @override
  String get walkiePlan_detailsAvailableCoupons => 'Cupons Disponíveis';

  @override
  String get walkiePlan_detailsCard => 'Cartão de Crédito / Débito';

  @override
  String get walkiePlan_detailsChooseTitle => 'Escolha um Plano';

  @override
  String walkiePlan_detailsCodeLabel(String code) {
    return 'Código: $code';
  }

  @override
  String get walkiePlan_detailsCouponsOffers => 'Cupons e Ofertas';

  @override
  String get walkiePlan_detailsEnterCouponHint => 'Insira o código do cupom';

  @override
  String get walkiePlan_detailsEnterValidCoupon =>
      'Insira um código de cupom válido';

  @override
  String get walkiePlan_detailsFeatGroupComm => 'Comunicação em Grupo';

  @override
  String get walkiePlan_detailsFeatHqVoice => 'Voz em Alta Definição';

  @override
  String get walkiePlan_detailsFeatPrioritySupport => 'Suporte Prioritário';

  @override
  String get walkiePlan_detailsFeatUnlimitedRange => 'Alcance Ilimitado';

  @override
  String get walkiePlan_detailsFeatUnlimitedWalkie => 'Walkie Talkie Ilimitado';

  @override
  String get walkiePlan_detailsHavePromoCode => 'Tem um Código Promocional?';

  @override
  String get walkiePlan_detailsIndividualSubtitle =>
      'Continue usando o Walkie Talkie com o plano ideal para você';

  @override
  String get walkiePlan_detailsLockedCaps => 'BLOQUEADO';

  @override
  String walkiePlan_detailsMaxMembersReached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Limite de $count membros atingido',
      one: 'Limite de 1 membro atingido',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMemberPlural => 'Membros';

  @override
  String get walkiePlan_detailsMemberSingular => 'Membro';

  @override
  String walkiePlan_detailsMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Membros × $rate',
      one: '1 Membro × $rate',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_detailsMinTeamSize(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tamanho mínimo de $count membros',
      one: 'Tamanho mínimo de 1 membro',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_detailsMoreMembersBody =>
      'Adicione ou remova membros a qualquer momento.';

  @override
  String get walkiePlan_detailsMoreMembersTitle => 'Mais Membros?';

  @override
  String get walkiePlan_detailsMostPopular => 'Mais Popular';

  @override
  String get walkiePlan_detailsNetBanking => 'Internet Banking';

  @override
  String get walkiePlan_detailsNoCouponsBody =>
      'Não há cupons ativos para este plano no momento.';

  @override
  String get walkiePlan_detailsNoCouponsTitle => 'Nenhum Cupom Disponível';

  @override
  String get walkiePlan_detailsNoIndividualPlans =>
      'Nenhum plano individual disponível no momento. Tente novamente mais tarde.';

  @override
  String get walkiePlan_detailsNoPlansTitle => 'Nenhum Plano Disponível';

  @override
  String get walkiePlan_detailsNoTeamPlans =>
      'Nenhum plano de equipe disponível no momento. Tente novamente mais tarde.';

  @override
  String walkiePlan_detailsOriginalTotal(String amount) {
    return '$amount total';
  }

  @override
  String get walkiePlan_detailsPayActivate => 'Pagar e Ativar Plano';

  @override
  String get walkiePlan_detailsPerPerson => '/ pessoa';

  @override
  String get walkiePlan_detailsPillAllSizes => 'de todos os tamanhos';

  @override
  String get walkiePlan_detailsPillCommunication => 'Comunicação';

  @override
  String get walkiePlan_detailsPillForTeams => 'Para Equipes';

  @override
  String get walkiePlan_detailsPillInstant => 'Instantâneo';

  @override
  String get walkiePlan_detailsPillPriority => 'Prioritário';

  @override
  String get walkiePlan_detailsPillReliable => 'Confiável e';

  @override
  String get walkiePlan_detailsPillSecure => 'Seguro';

  @override
  String get walkiePlan_detailsPillSupport => 'Suporte';

  @override
  String get walkiePlan_detailsPillUnlimited => 'Ilimitado';

  @override
  String get walkiePlan_detailsPillWalkieTalkie => 'Walkie Talkie';

  @override
  String get walkiePlan_detailsPlanActivated => 'Plano Ativado com Sucesso!';

  @override
  String get walkiePlan_detailsPlanActiveBody =>
      'Seu plano do Walkie Talkie está ativo. Aproveite a comunicação instantânea.';

  @override
  String get walkiePlan_detailsPlanSummary => 'Resumo do Plano';

  @override
  String walkiePlan_detailsPromoApplied(String code) {
    return 'Promo ($code) aplicado';
  }

  @override
  String get walkiePlan_detailsRemoveCaps => 'REMOVER';

  @override
  String get walkiePlan_detailsSelectPaymentMethod =>
      'Selecione a Forma de Pagamento';

  @override
  String get walkiePlan_detailsSkeletonCouponNote =>
      'Válido em todos os planos • Expira em breve';

  @override
  String get walkiePlan_detailsStep1Subtitle =>
      'Escolha quantos membros deseja adicionar';

  @override
  String get walkiePlan_detailsStep1Title => 'Selecione o Número de Membros';

  @override
  String get walkiePlan_detailsStep2Subtitle =>
      'Escolha a duração ideal para você';

  @override
  String get walkiePlan_detailsStep2Title => 'Selecione a Duração do Plano';

  @override
  String get walkiePlan_detailsSubtitleDefault =>
      'Acesso de voz instantâneo ao Walkie Talkie';

  @override
  String get walkiePlan_detailsSubtitleGrowingTeams =>
      'Ótimo custo-benefício para equipes em crescimento';

  @override
  String get walkiePlan_detailsSubtitleLongTerm =>
      'Ideal para uso a longo prazo';

  @override
  String get walkiePlan_detailsSubtitleShortTerm =>
      'Perfeito para uso de curto prazo';

  @override
  String get walkiePlan_detailsTabIndividual => 'Individual';

  @override
  String get walkiePlan_detailsTabMultipleMembers => 'Para Múltiplos Membros';

  @override
  String get walkiePlan_detailsTabPerPerson => 'Por Pessoa';

  @override
  String get walkiePlan_detailsTeamSubtitle =>
      'Adicione membros da equipe e conecte todos com Walkie Talkie';

  @override
  String get walkiePlan_detailsUpiQr => 'UPI / QR Code';

  @override
  String walkiePlan_detailsYouSaveWithCoupon(String amount) {
    return 'Você economiza $amount com este cupom!';
  }

  @override
  String get walkiePlan_durationFallback => 'Duração';

  @override
  String get walkiePlan_durationMonthly => 'Mensal';

  @override
  String walkiePlan_durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Meses',
      one: '1 Mês',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_durationQuarterly => 'Trimestral';

  @override
  String get walkiePlan_durationYearly => 'Anual';

  @override
  String get walkiePlan_individualPlan => 'Plano Individual';

  @override
  String walkiePlan_intervalPlan(String interval) {
    return 'Plano $interval';
  }

  @override
  String get walkiePlan_monthlyPlan => 'Plano Mensal';

  @override
  String get walkiePlan_noInternetCheckNetwork =>
      'Sem conexão com a internet. Verifique sua rede.';

  @override
  String get walkiePlan_order100Secure => '100% Seguro';

  @override
  String get walkiePlan_order3ds2Secure => 'Seguro 3DS2';

  @override
  String get walkiePlan_orderAgreePrefix =>
      'Ao continuar, você concorda com nossos ';

  @override
  String get walkiePlan_orderAmountAfterDiscount => 'Valor após Desconto';

  @override
  String get walkiePlan_orderCards => 'Cartões';

  @override
  String get walkiePlan_orderChangeMethod => 'Alterar Método';

  @override
  String get walkiePlan_orderCouldNotStart =>
      'Não foi possível iniciar o pagamento. Tente novamente.';

  @override
  String get walkiePlan_orderCouponApplied => 'Cupom aplicado com sucesso!';

  @override
  String walkiePlan_orderCouponAppliedSaved(String amount) {
    return 'Cupom aplicado! Você economizou $amount';
  }

  @override
  String get walkiePlan_orderCouponRemoved => 'Cupom removido com sucesso';

  @override
  String get walkiePlan_orderCreateFailed =>
      'Falha ao criar ordem de pagamento. Tente novamente.';

  @override
  String get walkiePlan_orderDiscount => 'Desconto';

  @override
  String walkiePlan_orderDiscountWithCode(String code) {
    return 'Desconto ($code)';
  }

  @override
  String get walkiePlan_orderDomesticHint =>
      'Escolha entre cartões, carteiras ou transferências no próximo passo.';

  @override
  String get walkiePlan_orderEncryptedPayment => 'Pagamento Criptografado';

  @override
  String get walkiePlan_orderEnterValidCoupon =>
      'Insira um código de cupom válido';

  @override
  String get walkiePlan_orderForMultipleMembers => 'Para Múltiplos Membros';

  @override
  String get walkiePlan_orderForSingleMember => 'Para Membro Individual';

  @override
  String walkiePlan_orderGstTitle(String percent) {
    return 'Imposto ($percent%)';
  }

  @override
  String get walkiePlan_orderIntlHint =>
      'Pague com segurança com cartões internacionais (Visa, Mastercard, Amex).';

  @override
  String get walkiePlan_orderIntlHintPaypal =>
      'Pague com segurança com cartões internacionais ou PayPal.';

  @override
  String get walkiePlan_orderInvalidCoupon =>
      'Código de cupom inválido ou expirado';

  @override
  String walkiePlan_orderMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Membros',
      one: '1 Membro',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderMembersLabel => 'Membros';

  @override
  String walkiePlan_orderMembersTimesRate(int count, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Membros × $rate',
      one: '1 Membro × $rate',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_orderNetBanking => 'Internet Banking';

  @override
  String get walkiePlan_orderOnlineViaRazorpay =>
      'Pagamento online via Razorpay';

  @override
  String get walkiePlan_orderOpeningCheckout =>
      'Abrindo checkout do Razorpay...';

  @override
  String get walkiePlan_orderPaymentDetails => 'Detalhes do Pagamento';

  @override
  String get walkiePlan_orderPaymentMethod => 'Forma de Pagamento';

  @override
  String get walkiePlan_orderPricePerMember => 'Preço por membro';

  @override
  String walkiePlan_orderProceedToPay(String amount) {
    return 'Continuar para Pagamento • $amount';
  }

  @override
  String get walkiePlan_orderProcessingPayment => 'Processando Pagamento...';

  @override
  String get walkiePlan_orderRetryPay => 'Tentar Novamente';

  @override
  String get walkiePlan_orderSecureBadge => 'SEGURO';

  @override
  String get walkiePlan_orderSubtitle =>
      'Revise os detalhes do seu plano e pague';

  @override
  String get walkiePlan_orderSubtotal => 'Subtotal';

  @override
  String get walkiePlan_orderTaxExport => 'Taxa (0% Exportação)';

  @override
  String get walkiePlan_orderTermsConditions => 'Termos e Condições';

  @override
  String get walkiePlan_orderTitle => 'Resumo do Pedido';

  @override
  String get walkiePlan_orderTotalAmount => 'Valor Total';

  @override
  String get walkiePlan_orderTotalPayable => 'Total a Pagar';

  @override
  String get walkiePlan_orderUnableToLoad =>
      'Não foi possível carregar o resumo do pedido.';

  @override
  String get walkiePlan_orderUpiQr => 'UPI / QR';

  @override
  String walkiePlan_orderVatTitle(String percent) {
    return 'IVA / Taxa ($percent%)';
  }

  @override
  String get walkiePlan_orderWallets => 'Carteiras Digitais';

  @override
  String walkiePlan_orderYouSaved(String amount) {
    return 'Você economizou $amount neste pedido!';
  }

  @override
  String get walkiePlan_payAnnualPlan => 'Plano Anual';

  @override
  String get walkiePlan_payBadgeCompleted => 'Concluído';

  @override
  String get walkiePlan_payBadgeInProgress => 'Em Andamento';

  @override
  String get walkiePlan_payBadgePending => 'Pendente';

  @override
  String get walkiePlan_payCancelledByUser =>
      'O pagamento foi cancelado pelo usuário. Nenhum valor foi debitado.';

  @override
  String get walkiePlan_payCouldNotBeProcessed =>
      'O pagamento não pôde ser processado';

  @override
  String get walkiePlan_payFailedContactSupport => 'Contatar Suporte';

  @override
  String walkiePlan_payFailedOn(String time) {
    return 'Falha no pagamento em $time';
  }

  @override
  String get walkiePlan_payFailedSubtitleLong =>
      'Não conseguimos concluir o pagamento.\nTente novamente ou use outro método.';

  @override
  String get walkiePlan_payFailedSubtitleShort =>
      'Não conseguimos concluir seu pagamento';

  @override
  String get walkiePlan_payFailedSupportHelp =>
      'Precisa de ajuda com o pagamento? Suporte disponível 24/7.';

  @override
  String get walkiePlan_payFailedTitle => 'Falha no Pagamento';

  @override
  String get walkiePlan_payIndividualFeatures =>
      'Monitoramento em tempo real • Alertas instantâneos';

  @override
  String walkiePlan_payInitiatedOn(String time) {
    return 'Pagamento iniciado em $time';
  }

  @override
  String get walkiePlan_payIntervalMonth => 'mês';

  @override
  String get walkiePlan_payIntervalPlan => 'plano';

  @override
  String get walkiePlan_payIntervalQuarter => 'trimestre';

  @override
  String get walkiePlan_payIntervalYear => 'ano';

  @override
  String walkiePlan_payMethodCreditCard(String network) {
    return 'Cartão de Crédito ($network)';
  }

  @override
  String walkiePlan_payMethodDebitCard(String network) {
    return 'Cartão de Débito ($network)';
  }

  @override
  String get walkiePlan_payMethodInternational =>
      'Cartão Internacional / PayPal';

  @override
  String walkiePlan_payMethodNetBanking(String bank) {
    return 'Internet Banking ($bank)';
  }

  @override
  String get walkiePlan_payMethodRazorpay => 'Pagamento Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayCheckout => 'Checkout Razorpay';

  @override
  String get walkiePlan_payMethodRazorpayUpiCard => 'Razorpay (UPI / Cartão)';

  @override
  String get walkiePlan_payMethodUpi => 'Pagamento UPI';

  @override
  String walkiePlan_payMethodWallet(String wallet) {
    return 'Carteira ($wallet)';
  }

  @override
  String get walkiePlan_payNetworkIssue =>
      'Problema de conexão durante o pagamento. Verifique sua internet.';

  @override
  String get walkiePlan_payNotCompleted =>
      'Seu pagamento não foi concluído. Nenhum valor foi cobrado.';

  @override
  String get walkiePlan_payOtpCharge => 'Tarifa de OTP';

  @override
  String get walkiePlan_payOtpChargeDetails => 'Detalhes da Tarifa de OTP';

  @override
  String get walkiePlan_payOtpChargedPerLogin =>
      'Cobrado por login. Reenvio gratuito';

  @override
  String get walkiePlan_payOtpCharges => 'Tarifas de OTP';

  @override
  String get walkiePlan_payPendingDoNotClose =>
      'Por favor, não feche o aplicativo. Notificaremos você assim que o pagamento for confirmado.';

  @override
  String get walkiePlan_payPendingStillInProgress =>
      'Pagamento em andamento. Atualizaremos assim que confirmado.';

  @override
  String get walkiePlan_payPendingStillProcessing =>
      'O pagamento ainda está sendo processado. Aguarde.';

  @override
  String get walkiePlan_payPendingSubtitleLong =>
      'Seu pagamento está sendo processado pelo provedor.\nIsso pode levar alguns minutos.';

  @override
  String get walkiePlan_payPendingSubtitleShort =>
      'Seu pagamento está sendo processado';

  @override
  String get walkiePlan_payPendingTitle => 'Pagamento Pendente';

  @override
  String get walkiePlan_payPlanDetails => 'Detalhes do Plano';

  @override
  String get walkiePlan_payRefreshStatus => 'Atualizar Status';

  @override
  String get walkiePlan_payStatusTitle => 'Status do Pagamento';

  @override
  String get walkiePlan_payStepActivate => 'Ativar Plano';

  @override
  String get walkiePlan_payStepActivateSub =>
      'Seu plano será ativado automaticamente';

  @override
  String get walkiePlan_payStepInitiated => 'Pagamento Iniciado';

  @override
  String get walkiePlan_payStepProcessing => 'Processando Pagamento';

  @override
  String get walkiePlan_payStepProcessingSub =>
      'Seu pagamento está sendo confirmado';

  @override
  String get walkiePlan_payTeamFeatures =>
      'Acesso para múltiplos membros • Alertas instantâneos';

  @override
  String get walkiePlan_payTotalPerOtp => 'Total por OTP';

  @override
  String get walkiePlan_payTryAgain => 'Tentar Novamente';

  @override
  String get walkiePlan_payViewPlanDetails => 'Ver Detalhes do Plano';

  @override
  String get walkiePlan_perMember => 'por membro';

  @override
  String get walkiePlan_planFallback => 'Plano';

  @override
  String get walkiePlan_quarterlyPlan => 'Plano Trimestral';

  @override
  String get walkiePlan_razorpayCompleteInWindow =>
      'Conclua a transação na janela do Razorpay.';

  @override
  String get walkiePlan_razorpayCompletePayment => 'Concluir Pagamento';

  @override
  String get walkiePlan_razorpayConfirmingWithBank =>
      'Pagamento iniciado. Estamos confirmando com o banco.';

  @override
  String get walkiePlan_razorpayConnecting => 'Conectando ao Razorpay...';

  @override
  String get walkiePlan_razorpayCouldNotProcess =>
      'O pagamento não pôde ser processado. Tente novamente.';

  @override
  String get walkiePlan_razorpayFailedTryAgain =>
      'Pagamento falhou. Tente novamente.';

  @override
  String get walkiePlan_razorpayOneMonthActive => '1 Mês Ativo';

  @override
  String walkiePlan_razorpayPayAmountVia(String amount) {
    return 'Pagar $amount via Razorpay';
  }

  @override
  String get walkiePlan_razorpayPaymentCancelled => 'Pagamento Cancelado';

  @override
  String get walkiePlan_razorpayPaymentIdCopied =>
      'ID do pagamento copiado para a área de transferência!';

  @override
  String get walkiePlan_razorpayPciCompliant =>
      '100% Seguro e Conforme PCI-DSS';

  @override
  String get walkiePlan_razorpayPendingConfirmation =>
      'O pagamento está pendente de confirmação.';

  @override
  String get walkiePlan_razorpayProcessing => 'Processando com Razorpay...';

  @override
  String walkiePlan_razorpayReceiptAmount(String amount) {
    return 'Valor: $amount';
  }

  @override
  String get walkiePlan_razorpayReceiptCopied =>
      'Comprovante copiado para a área de transferência!';

  @override
  String walkiePlan_razorpayReceiptDate(String date) {
    return 'Data: $date';
  }

  @override
  String walkiePlan_razorpayReceiptMode(String mode) {
    return 'Forma de Pagamento: $mode';
  }

  @override
  String walkiePlan_razorpayReceiptOrderId(String id) {
    return 'ID do Pedido: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPaymentId(String id) {
    return 'ID do Pagamento: $id';
  }

  @override
  String walkiePlan_razorpayReceiptPlan(String plan) {
    return 'Plano: $plan';
  }

  @override
  String get walkiePlan_razorpayReceiptStatusCompleted => 'Status: Concluído';

  @override
  String get walkiePlan_razorpayReceiptTitle =>
      'Recibo de Pagamento FG Tracker';

  @override
  String get walkiePlan_razorpayRetryPayment => 'Tentar Novamente';

  @override
  String get walkiePlan_razorpaySecureCheckout =>
      'Checkout Seguro powered by Razorpay';

  @override
  String get walkiePlan_razorpaySslEncrypted =>
      'Transações protegidas com criptografia SSL de 256 bits.';

  @override
  String get walkiePlan_razorpaySupportedModes => 'Formas de Pagamento Aceitas';

  @override
  String get walkiePlan_razorpayTotalPayableAmount => 'Valor Total a Pagar';

  @override
  String walkiePlan_razorpayUnableToLaunch(String error) {
    return 'Não foi possível abrir o gateway de pagamento: $error';
  }

  @override
  String get walkiePlan_razorpayVerifyFailed =>
      'Falha na verificação do pagamento.';

  @override
  String get walkiePlan_seatAssignedSeat => 'Vaga Atribuída';

  @override
  String get walkiePlan_seatAssignment => 'Atribuição de Vagas';

  @override
  String get walkiePlan_seatTeamAccess => 'Acesso de Equipe';

  @override
  String get walkiePlan_seatTeamMember => 'Membro da Equipe';

  @override
  String get walkiePlan_secureEncryptedPayment =>
      'Pagamento Seguro e Criptografado';

  @override
  String get walkiePlan_successAccessActivated => 'Acesso Ativado';

  @override
  String get walkiePlan_successAccessActivatedDesc =>
      'Seu acesso pessoal ao Walkie-Talkie está ativo.';

  @override
  String get walkiePlan_successAmountPaid => 'Valor Pago';

  @override
  String get walkiePlan_successAssignLaterNote =>
      'Você pode atribuir o acesso depois nas Configurações da Equipe.';

  @override
  String get walkiePlan_successAssignMembers => 'Atribuir Membros';

  @override
  String get walkiePlan_successAssignWalkieAccess =>
      'Atribuir Acesso ao Walkie';

  @override
  String get walkiePlan_successChooseMembersDesc =>
      'Escolha quais membros podem usar o Walkie Talkie.';

  @override
  String get walkiePlan_successContinueHome => 'Continuar para o Início';

  @override
  String get walkiePlan_successDateTime => 'Data e Hora';

  @override
  String get walkiePlan_successDefaultPaymentMethod =>
      'Razorpay (UPI / Cartão)';

  @override
  String get walkiePlan_successIndividualActive =>
      'Seu Plano Individual está ativo';

  @override
  String get walkiePlan_successIndividualActiveDesc =>
      'Seu plano está ativo. Vá para o início e comece a falar.';

  @override
  String get walkiePlan_successIndividualLinkedNote =>
      'Sua assinatura individual está ativa e vinculada à sua conta.';

  @override
  String get walkiePlan_successManageAccessNote =>
      'Você pode gerenciar ou alterar o acesso nas Configurações da Equipe.';

  @override
  String get walkiePlan_successMaybeLater => 'Talvez Mais Tarde';

  @override
  String get walkiePlan_successNoAccessUntilAssigned =>
      'Seu plano está ativo. Os membros não terão acesso até que você os atribua.';

  @override
  String get walkiePlan_successNotNow => 'Agora não?';

  @override
  String get walkiePlan_successPaid => 'PAGO';

  @override
  String get walkiePlan_successPaymentId => 'ID do Pagamento';

  @override
  String get walkiePlan_successPaymentIdCopied =>
      'ID do pagamento copiado para a área de transferência!';

  @override
  String get walkiePlan_successPaymentMode => 'Forma de Pagamento';

  @override
  String get walkiePlan_successPaymentReceipt => 'Comprovante de Pagamento';

  @override
  String get walkiePlan_successPushToTalkDesc =>
      'Aperte para falar e conecte-se com sua equipe.';

  @override
  String get walkiePlan_successRazorpayVerified => 'Verificado pelo Razorpay';

  @override
  String walkiePlan_successReceiptAmount(String amount) {
    return 'Valor: $amount';
  }

  @override
  String get walkiePlan_successReceiptCopied => 'Detalhes do recibo copiados!';

  @override
  String walkiePlan_successReceiptDate(String date) {
    return 'Data: $date';
  }

  @override
  String get walkiePlan_successReceiptHeader =>
      'Comprovante de Pagamento FG Tracker';

  @override
  String walkiePlan_successReceiptOrderId(String id) {
    return 'ID do Pedido: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentId(String id) {
    return 'ID do Pagamento: $id';
  }

  @override
  String walkiePlan_successReceiptPaymentMode(String mode) {
    return 'Forma de Pagamento: $mode';
  }

  @override
  String walkiePlan_successReceiptPlan(String plan) {
    return 'Plano: $plan';
  }

  @override
  String get walkiePlan_successReceiptStatusCompleted => 'Status: Concluído';

  @override
  String get walkiePlan_successSelectChannel => 'Selecionar Canal';

  @override
  String get walkiePlan_successSelectChannelDesc =>
      'Entre em qualquer canal para se conectar.';

  @override
  String get walkiePlan_successSelectMembersDesc =>
      'Selecione os membros que usarão o Walkie Talkie.';

  @override
  String get walkiePlan_successSetUpTeam => 'Configurar Equipe';

  @override
  String get walkiePlan_successSetUpTeamDesc =>
      'Convide membros, gerencie funções e permissões.';

  @override
  String get walkiePlan_successShareReceipt => 'Compartilhar Comprovante';

  @override
  String get walkiePlan_successStartCommunicating => 'Comece a se Comunicar';

  @override
  String get walkiePlan_successStatus => 'Status';

  @override
  String get walkiePlan_successSuccessful => 'Sucesso';

  @override
  String get walkiePlan_successTeamActive => 'Seu Plano de Equipe está ativo';

  @override
  String get walkiePlan_successTeamReady => 'Sua equipe está pronta!';

  @override
  String get walkiePlan_successTitle => 'Compra Realizada com Sucesso!';

  @override
  String walkiePlan_successValidTill(String date) {
    return 'Válido até $date';
  }

  @override
  String get walkiePlan_successVisitHome => 'Ir para a Tela Inicial';

  @override
  String get walkiePlan_successWhatsNext => 'O que vem a seguir?';

  @override
  String get walkiePlan_teamPlan => 'Plano de Equipe';

  @override
  String walkiePlan_teamPlanWithDuration(String duration) {
    return 'Plano de Equipe ($duration)';
  }

  @override
  String get walkiePlan_trial7DaysPeriod => 'Período de Teste de 7 Dias';

  @override
  String get walkiePlan_trialActiveLabel => 'TESTE ATIVO';

  @override
  String get walkiePlan_trialActiveSubscription => 'Assinatura Ativa';

  @override
  String get walkiePlan_trialActiveSubscriptions => 'Assinaturas Ativas';

  @override
  String get walkiePlan_trialAvailableToStart => 'Disponível para iniciar';

  @override
  String get walkiePlan_trialCheckConnectionRetry =>
      'Verifique sua conexão com a internet e tente novamente.';

  @override
  String get walkiePlan_trialChoosePlanBelow =>
      'Escolha um plano abaixo para começar a usar o Walkie Talkie.';

  @override
  String get walkiePlan_trialChooseSubscription =>
      'Escolha uma assinatura para continuar usando o Walkie Talkie.';

  @override
  String get walkiePlan_trialCompleted => 'Teste Concluído';

  @override
  String walkiePlan_trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restam $count dias',
      one: 'Resta 1 dia',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialDurationFree(String duration) {
    return '$duration Grátis';
  }

  @override
  String walkiePlan_trialEndedOn(String date) {
    return 'Terminou em $date';
  }

  @override
  String walkiePlan_trialEnjoyAllFeatures(String duration) {
    return 'Aproveite todos os recursos do Walkie Talkie grátis por $duration.\nSem cobrança.';
  }

  @override
  String get walkiePlan_trialEnjoyDuringActive =>
      'Aproveite o Walkie Talkie durante seu período de teste.';

  @override
  String get walkiePlan_trialErrAccessMissing =>
      'Informações de acesso ao Walkie-Talkie ausentes.';

  @override
  String get walkiePlan_trialErrFetchDetails =>
      'Não foi possível obter os detalhes do Walkie-Talkie.';

  @override
  String get walkiePlan_trialErrInvalidResponse =>
      'Resposta inválida recebida do servidor.';

  @override
  String get walkiePlan_trialErrNoInternetRetry =>
      'Sem conexão com a internet. Verifique sua rede e tente novamente.';

  @override
  String get walkiePlan_trialErrOverviewMissing =>
      'Dados da visão geral do Walkie-Talkie ausentes.';

  @override
  String get walkiePlan_trialErrTimeout =>
      'A solicitação expirou. Tente novamente.';

  @override
  String get walkiePlan_trialErrUnableToLoad =>
      'Não foi possível carregar detalhes do Walkie-Talkie.';

  @override
  String get walkiePlan_trialExpired => 'Teste Expirado';

  @override
  String get walkiePlan_trialExpiredLabel => 'TESTE EXPIRADO';

  @override
  String get walkiePlan_trialExpiringSoon => 'Expira em breve';

  @override
  String get walkiePlan_trialFeatClearAudio => 'Áudio Cristalino';

  @override
  String get walkiePlan_trialFeatClearAudioDesc => 'Qualidade de voz superior';

  @override
  String get walkiePlan_trialFeatGroupComm => 'Comunicação em Grupo';

  @override
  String get walkiePlan_trialFeatGroupCommDesc => 'Conecte-se com sua equipe';

  @override
  String get walkiePlan_trialFeatPtt => 'Push-to-talk';

  @override
  String get walkiePlan_trialFeatPttDesc => 'Comunicação de voz instantânea';

  @override
  String get walkiePlan_trialFeatUnlimited => 'Uso Ilimitado';

  @override
  String get walkiePlan_trialFeatUnlimitedDesc => 'Use sem limites';

  @override
  String get walkiePlan_trialFreeAvailable => 'Teste Grátis Disponível';

  @override
  String get walkiePlan_trialFreeTrialLabel => 'TESTE GRÁTIS';

  @override
  String get walkiePlan_trialFreeTrialRunning => 'Teste Grátis em Andamento';

  @override
  String get walkiePlan_trialFullAccess => 'Acesso total a todos os recursos';

  @override
  String get walkiePlan_trialFullyConsumed =>
      'Seu teste grátis foi totalmente consumido.';

  @override
  String get walkiePlan_trialHasEnded => 'Seu Teste Terminou';

  @override
  String get walkiePlan_trialHeaderInstant =>
      'Comunique-se instantaneamente com seu grupo';

  @override
  String get walkiePlan_trialHeaderPlanStatus =>
      'Status do seu plano e assinatura';

  @override
  String walkiePlan_trialHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Horas',
      one: '1 Hora',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restam $count horas',
      one: 'Resta 1 hora',
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
  String get walkiePlan_trialIsActive => 'Seu Teste Está Ativo';

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
      other: 'Restam $count mins',
      one: 'Resta 1 min',
    );
    return '$_temp0';
  }

  @override
  String walkiePlan_trialMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minutos',
      one: '1 Minuto',
    );
    return '$_temp0';
  }

  @override
  String get walkiePlan_trialNoActivePlan => 'Nenhum Plano Ativo';

  @override
  String get walkiePlan_trialNoCardRequired =>
      'Use em 7 dias  •  Sem cartão de crédito';

  @override
  String get walkiePlan_trialNoInternetTitle => 'Sem Conexão com a Internet';

  @override
  String walkiePlan_trialNoPaymentNow(String price) {
    return 'Nenhum pagamento agora. Depois do teste, você pode assinar um plano ($price/pessoa).';
  }

  @override
  String get walkiePlan_trialPeriodMonth => 'mês';

  @override
  String get walkiePlan_trialRetrying => 'Tentando novamente...';

  @override
  String walkiePlan_trialSec(int count) {
    return '$count s';
  }

  @override
  String walkiePlan_trialStartFreeTrial(String duration) {
    return 'Iniciar Teste Grátis de $duration';
  }

  @override
  String get walkiePlan_trialStartYourFreeTrial => 'Inicie seu Teste Grátis';

  @override
  String get walkiePlan_trialStatusCompleted => 'Concluído';

  @override
  String get walkiePlan_trialStatusExpired => 'Expirado';

  @override
  String get walkiePlan_trialSubscriptionActive => 'Assinatura Ativa';

  @override
  String get walkiePlan_trialSubscriptionEndedMsg =>
      'Sua assinatura terminou. Renove para continuar conversando.';

  @override
  String get walkiePlan_trialSubscriptionExpired => 'Assinatura Expirada';

  @override
  String get walkiePlan_trialTalkFree => 'Fale grátis com seu grupo.';

  @override
  String walkiePlan_trialTalkFreeTill(String date) {
    return 'Fale grátis com seu grupo até $date.';
  }

  @override
  String get walkiePlan_trialTeamAccessMsg =>
      'Você tem acesso ao Walkie Talkie através do plano de equipe.';

  @override
  String walkiePlan_trialTimeLeft(String time) {
    return 'Resta $time';
  }

  @override
  String get walkiePlan_trialTimeRemaining => 'Tempo de Teste Restante';

  @override
  String get walkiePlan_trialTimeUsedUp => 'Tempo de teste esgotado';

  @override
  String get walkiePlan_trialTryAgain => 'Tentar Novamente';

  @override
  String get walkiePlan_trialUnableToLoadTitle =>
      'Não foi possível carregar o Walkie Talkie';

  @override
  String get walkiePlan_trialUsage => 'Uso do Teste';

  @override
  String get walkiePlan_trialUseAnytime7Days =>
      'Use o teste quando quiser em 7 dias';

  @override
  String walkiePlan_trialUseWithin7Days(String duration) {
    return 'Use seu teste de $duration a qualquer momento em 7 dias.';
  }

  @override
  String get walkiePlan_trialUsed => 'Teste Utilizado';

  @override
  String get walkiePlan_trialValidityPeriod => 'Validade do Teste';

  @override
  String get walkiePlan_trialWalkieTalkieTitle => 'Walkie Talkie';

  @override
  String get walkiePlan_trialWhatYouCanDo =>
      'O que você pode fazer durante o teste';

  @override
  String get walkiePlan_unableToConnect =>
      'Não foi possível conectar ao servidor. Tente novamente.';

  @override
  String get walkiePlan_yearlyPlan => 'Plano Anual';

  @override
  String get walkie_aMember => 'Um membro';

  @override
  String get walkie_accept => 'Aceitar';

  @override
  String get walkie_activeAccess => 'Acesso ativo';

  @override
  String get walkie_activeBadge => 'Ativo';

  @override
  String walkie_activeInWalkie(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ativos no Walkie',
      one: '1 ativo no Walkie',
    );
    return '$_temp0';
  }

  @override
  String get walkie_activeMember => 'Membro ativo';

  @override
  String get walkie_admin => 'Admin';

  @override
  String get walkie_adminMuted => 'Admin • Mutado';

  @override
  String get walkie_adminOnlyAction => 'Ação exclusiva para administradores';

  @override
  String get walkie_adminOnlyActionMessage =>
      'Apenas o administrador do grupo pode enviar alertas de notificação para os membros.';

  @override
  String walkie_alertSentMessage(String name) {
    return 'Notificação enviada para $name. Nova tentativa em 10 s.';
  }

  @override
  String get walkie_alertSentTitle => 'Alerta enviado';

  @override
  String get walkie_assignMembersToCommunicate =>
      'Atribua membros para se comunicar neste grupo';

  @override
  String get walkie_assignedByYou => 'Atribuído por você';

  @override
  String walkie_assignedCount(int count) {
    return '$count atribuídos';
  }

  @override
  String get walkie_assignedSeats => 'Postos atribuídos';

  @override
  String get walkie_audioBluetooth => 'Bluetooth';

  @override
  String get walkie_audioHeadset => 'Headset';

  @override
  String get walkie_audioOutput => 'Saída de áudio';

  @override
  String get walkie_audioPhone => 'Telefone';

  @override
  String get walkie_audioSpeaker => 'Alto-falante';

  @override
  String get walkie_audioWiredHeadphones => 'Fones de ouvido com fio';

  @override
  String walkie_autoUnlockIn(int seconds) {
    return 'Desbloqueio automático em $seconds s';
  }

  @override
  String get walkie_availableMembers => 'Membros disponíveis';

  @override
  String walkie_canAssignUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você pode atribuir até $count membros neste grupo',
      one: 'Você pode atribuir até 1 membro neste grupo',
    );
    return '$_temp0';
  }

  @override
  String get walkie_cannotRemoveOtherAdminSeat =>
      'Não é possível remover o posto atribuído por outro administrador';

  @override
  String get walkie_cannotSpeak => 'Não é possível falar neste canal';

  @override
  String get walkie_channelBusy => 'O canal está ocupado';

  @override
  String get walkie_channelLocked => 'Canal bloqueado';

  @override
  String get walkie_channelSpeaking => 'Canal transmitindo...';

  @override
  String walkie_channelSwitchErrorMessage(String group) {
    return 'Não foi possível definir $group como canal ativo.';
  }

  @override
  String get walkie_channelSwitchErrorTitle => 'Erro ao alternar canal';

  @override
  String get walkie_channelUnlocked => 'Canal desbloqueado';

  @override
  String get walkie_chat => 'Chat';

  @override
  String get walkie_checkNetworkTryAgain =>
      'Verifique sua conexão de rede e tente novamente.';

  @override
  String get walkie_chooseAPlan => 'Escolha um plano';

  @override
  String get walkie_connected => 'Conectado';

  @override
  String get walkie_connectedWaiting =>
      'Conectado ao canal • Aguardando outros entrarem';

  @override
  String get walkie_connectingChannel => 'Conectando ao canal...';

  @override
  String get walkie_consumingTrial => 'Utilizando teste...';

  @override
  String get walkie_continueListenOnly => 'Continuar no modo apenas ouvir';

  @override
  String walkie_currentlyAssigned(int count) {
    return 'Atualmente atribuídos ($count)';
  }

  @override
  String get walkie_defaultGroupName => 'Grupo de Walkie';

  @override
  String get walkie_description => 'Descrição';

  @override
  String get walkie_disconnected => 'Desconectado';

  @override
  String get walkie_editAssignedMembers => 'Editar membros atribuídos';

  @override
  String get walkie_enable => 'Ativar';

  @override
  String walkie_errorWithDetails(String details) {
    return 'Erro: $details';
  }

  @override
  String get walkie_exitWalkie => 'Sair do Walkie';

  @override
  String get walkie_exitWalkieMessage =>
      'Você será desconectado deste canal. Você ainda continuará membro do grupo.';

  @override
  String get walkie_exitWalkieTitle => 'Sair do Walkie?';

  @override
  String get walkie_fairConnection => 'Conexão regular';

  @override
  String walkie_fairConnectionMs(int ms) {
    return 'Conexão regular ($ms ms)';
  }

  @override
  String get walkie_featureAllDevices => 'Use em todos os dispositivos';

  @override
  String get walkie_featureEasyCoordination => 'Coordenação fácil em grupo';

  @override
  String get walkie_featureHoldToTalk => 'Segure para falar';

  @override
  String get walkie_featurePtt => 'Aperte para falar';

  @override
  String get walkie_featureQuickGroup => 'Comunicação rápida em grupo';

  @override
  String get walkie_featureRealtime => 'Conectividade em tempo real';

  @override
  String get walkie_featureSafeReliable => 'Seguro e confiável';

  @override
  String get walkie_featureStayConnected => 'Fique sempre conectado';

  @override
  String get walkie_featureTeamCommunication => 'Comunicação da equipe';

  @override
  String get walkie_featureUnlimited => 'Ilimitado';

  @override
  String get walkie_fieldTeam => 'Equipe de campo';

  @override
  String get walkie_freeTrialEnded => 'Teste grátis encerrado';

  @override
  String get walkie_freeTrialEndedMessage =>
      'Seu teste grátis de 1 hora para o Walkie-Talkie terminou.\nAtualize agora para continuar se comunicando com sua equipe.';

  @override
  String get walkie_freeTrialEndedTitle => 'Teste grátis encerrado';

  @override
  String get walkie_genericError => 'Erro no Walkie-Talkie';

  @override
  String get walkie_getPlan => 'Obter plano';

  @override
  String walkie_goodConnectionMs(int ms) {
    return 'Boa conexão ($ms ms)';
  }

  @override
  String walkie_groupCode(String code) {
    return 'Código do grupo: $code';
  }

  @override
  String get walkie_groupCommunication => 'Comunicação em grupo';

  @override
  String get walkie_groupFallback => 'Grupo';

  @override
  String get walkie_groupMembers => 'Membros do grupo';

  @override
  String get walkie_heroSubtitle =>
      'Use a comunicação de voz aperte para falar (PTT) com seu grupo sem precisar fazer ligação telefônica.';

  @override
  String get walkie_heroTitle => 'Fique conectado, fale instantaneamente';

  @override
  String get walkie_holdToTalk => 'Segure para falar';

  @override
  String get walkie_holdToTalkSlideLock =>
      'Segure para falar, deslize para travar';

  @override
  String get walkie_inWalkieChannel => 'No canal de Walkie';

  @override
  String get walkie_individualActiveUpgrade =>
      'Plano Individual ativo (Apenas próprio) • Atualize para Plano de Equipe.';

  @override
  String get walkie_individualLimitMessage =>
      'Seu Plano Individual permite apenas 1 posto. Para atribuir vários membros e conectar toda a equipe, atualize para um Plano de Equipe.';

  @override
  String get walkie_individualPlan => 'Plano individual';

  @override
  String walkie_individualSelectedCount(int count) {
    return '$count/1 (Individual)';
  }

  @override
  String get walkie_individualSelfOnlyUpgrade =>
      'Plano Individual (Apenas acesso próprio) • Atualize para Equipe';

  @override
  String get walkie_individualSubscribedSelf =>
      'Plano Individual • Assinado pelo próprio';

  @override
  String get walkie_info => 'Informações';

  @override
  String walkie_isSpeaking(String name) {
    return '$name está falando...';
  }

  @override
  String walkie_isTalking(String name) {
    return '$name está falando...';
  }

  @override
  String walkie_joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conectados',
      one: '1 conectado',
    );
    return '$_temp0';
  }

  @override
  String walkie_lastSeen(String time) {
    return 'Visto por último $time';
  }

  @override
  String get walkie_listenOnly => 'Apenas ouvir';

  @override
  String get walkie_listenOnlyTapPlan =>
      'Apenas ouvir — Toque para ver o plano';

  @override
  String get walkie_listening => 'Ouvindo';

  @override
  String get walkie_listeningOnly => 'Apenas ouvindo';

  @override
  String get walkie_live => 'AO VIVO';

  @override
  String get walkie_lockTimeout =>
      'Tempo limite de bloqueio esgotado — Microfone liberado';

  @override
  String get walkie_lockedTapMic => 'Travado — Toque no microfone para parar';

  @override
  String get walkie_maybeLater => 'Talvez mais tarde';

  @override
  String get walkie_member => 'Membro';

  @override
  String get walkie_membersInChannel => 'Membros no canal';

  @override
  String walkie_membersOnlineLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Membros online',
      one: 'Membro online',
    );
    return '$_temp0';
  }

  @override
  String get walkie_membersUpdateFailed =>
      'Falha ao atualizar membros atribuídos';

  @override
  String get walkie_membersUpdated =>
      'Membros atribuídos atualizados com sucesso';

  @override
  String get walkie_micAccessRequired =>
      'Acesso ao microfone necessário para falar.';

  @override
  String get walkie_micDisabledMessage =>
      'O acesso ao microfone está desativado nas configurações do dispositivo. Para falar, permita o acesso nas Configurações.\n\nVocê ainda pode ouvir os outros membros.';

  @override
  String get walkie_micPermissionRequired =>
      'Permissão de microfone necessária';

  @override
  String get walkie_micPermissionTitle => 'Permissão de microfone';

  @override
  String get walkie_micRequiredMessage =>
      'A permissão de microfone é necessária para falar neste grupo de Walkie-Talkie.\n\nVocê pode continuar ouvindo os outros sem ativar o microfone.';

  @override
  String get walkie_muteMe => 'Silenciar-me';

  @override
  String get walkie_muted => 'Mutado';

  @override
  String get walkie_mutedInWalkie => 'Mutado • No Walkie';

  @override
  String get walkie_mutedListeningOnly => 'Você está mutado — Apenas ouvindo';

  @override
  String walkie_nameSpeaking(String name) {
    return '$name falando...';
  }

  @override
  String get walkie_noActivePlan => 'Nenhum plano ativo';

  @override
  String get walkie_noAvailableMembers => 'Nenhum membro disponível';

  @override
  String get walkie_noBluetoothDevice =>
      'Nenhum dispositivo Bluetooth conectado. Conecte seu fone nas configurações.';

  @override
  String get walkie_noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get walkie_noMembersAssigned => 'Nenhum membro atribuído no momento';

  @override
  String get walkie_noMembersFound => 'Nenhum membro encontrado';

  @override
  String get walkie_noMembersFoundTitle => 'Nenhum membro encontrado';

  @override
  String get walkie_noMembersMatch => 'Nenhum membro correspondente';

  @override
  String walkie_noMembersMatchQuery(String query) {
    return 'Nenhum membro corresponde a \'$query\'';
  }

  @override
  String get walkie_noMembersToAssign =>
      'Nenhum membro do grupo disponível para atribuir.';

  @override
  String get walkie_noNameGroup => 'Grupo sem nome';

  @override
  String get walkie_noPlanSubscribeAssign =>
      'Nenhum plano ativo • Assine para atribuir membros';

  @override
  String get walkie_noSeatMessage =>
      'Você tem um Plano de Equipe ativo, mas todos os postos de voz estão atribuídos a outros membros.\n\nVocê pode ouvir as conversas em tempo real, mas para falar é necessário atribuir um posto a si mesmo ou atualizar seu plano.';

  @override
  String get walkie_noSeatTitle => 'Nenhum posto de voz atribuído';

  @override
  String get walkie_noSeatsRefreshing =>
      'Sem postos de equipe disponíveis. Atualizando lista...';

  @override
  String get walkie_noSubscriptionMessage =>
      'Você não tem uma assinatura ativa do Walkie-Talkie. Assine um plano para atribuir membros e iniciar a comunicação de voz.';

  @override
  String get walkie_noTeamSubscription =>
      'Nenhuma assinatura de equipe ativa encontrada';

  @override
  String get walkie_noValidMembers =>
      'Nenhum membro válido selecionado para atribuir';

  @override
  String get walkie_noVoiceSeatListenOnly =>
      'Nenhum posto de voz atribuído — Você está no modo apenas ouvir';

  @override
  String get walkie_noWiredDevice =>
      'Nenhum fone de ouvido com fio conectado. Conecte-o ao seu dispositivo.';

  @override
  String get walkie_notConnected => 'Não conectado';

  @override
  String get walkie_notifLeave => 'Sair';

  @override
  String get walkie_notifOpenWalkie => 'Abrir Walkie';

  @override
  String walkie_notifStoppedTalking(String name) {
    return '$name parou de falar';
  }

  @override
  String walkie_notifTalking(String name) {
    return '$name está falando';
  }

  @override
  String walkie_notificationSettingFailed(String group) {
    return 'Não foi possível atualizar as configurações de notificação para $group. Tente novamente.';
  }

  @override
  String get walkie_notificationSettingTitle => 'Configurações de notificação';

  @override
  String get walkie_onlyAdminCanAlert =>
      'Apenas o administrador do grupo pode enviar alertas';

  @override
  String get walkie_openWalkieTalkie => 'Abrir Walkie-Talkie';

  @override
  String get walkie_otherTeam => 'Outra equipe';

  @override
  String get walkie_othersWontHear => 'Os outros não ouvirão você';

  @override
  String get walkie_planRequiredTitle => 'Plano de Walkie-Talkie necessário';

  @override
  String get walkie_planRequiredToTalk => 'Plano necessário para falar';

  @override
  String get walkie_planStartsOnFirstAssign =>
      'O plano começa quando o primeiro membro é atribuído.';

  @override
  String get walkie_poorConnection =>
      'Conexão fraca — O áudio pode apresentar atrasos';

  @override
  String get walkie_preparingAudio => 'Preparando áudio...';

  @override
  String get walkie_purchaseTeamPlanToAssign =>
      'Compre um Plano de Equipe para atribuir acesso de Walkie-Talkie aos membros.';

  @override
  String get walkie_purchaseUpgradePlan => 'Comprar / Atualizar plano';

  @override
  String get walkie_ready => 'Pronto';

  @override
  String get walkie_reconnecting => 'Reconectando...';

  @override
  String get walkie_reconnectingServer =>
      'Reconectando ao servidor de walkie...';

  @override
  String get walkie_releaseToStop => 'Solte para parar';

  @override
  String get walkie_removeAll => 'Remover todos';

  @override
  String get walkie_searchGroups => 'Pesquisar grupos';

  @override
  String get walkie_searchMembers => 'Pesquisar membros...';

  @override
  String walkie_seatsFraction(int assigned, int total) {
    return '$assigned/$total postos';
  }

  @override
  String walkie_seatsSummary(int total, int assigned, int available) {
    return '$total postos no total • $assigned atribuídos • $available disponíveis';
  }

  @override
  String walkie_seatsUsed(String assigned, String total) {
    return '$assigned / $total postos usados';
  }

  @override
  String walkie_secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get walkie_selectAtLeastOne =>
      'Selecione pelo menos um membro para atribuir';

  @override
  String get walkie_selectGroupFirst =>
      'Por favor, selecione um grupo primeiro';

  @override
  String get walkie_selectGroupToConnect => 'Selecione um grupo para conectar';

  @override
  String get walkie_selected => 'Selecionado';

  @override
  String get walkie_selfAccess => 'Acesso próprio';

  @override
  String get walkie_selfPlan => 'Plano próprio';

  @override
  String get walkie_slideUpToLock => 'Deslize para cima para travar';

  @override
  String get walkie_someone => 'Alguém';

  @override
  String get walkie_someoneSpeaking => 'Alguém está falando...';

  @override
  String get walkie_speaking => 'Falando...';

  @override
  String walkie_startFreeTrial(String duration) {
    return 'Iniciar teste grátis de $duration';
  }

  @override
  String get walkie_strongConnection => 'Conexão forte';

  @override
  String walkie_strongConnectionMs(int ms) {
    return 'Conexão forte ($ms ms)';
  }

  @override
  String get walkie_subscribeToStartTalk =>
      'Assine para falar por voz e atribuir membros';

  @override
  String get walkie_subscribed => 'Inscrito';

  @override
  String get walkie_talking => 'Falando...';

  @override
  String get walkie_tapToUnlock => 'Toque para destravar';

  @override
  String get walkie_teamAssignedElsewhere =>
      'Plano de Equipe • Atribuído em outro lugar';

  @override
  String get walkie_teamPlan => 'Plano de equipe';

  @override
  String get walkie_teamPlanRequired => 'Plano de equipe necessário';

  @override
  String get walkie_teamPlanRequiredToAssign =>
      'Plano de Equipe necessário para atribuir membros';

  @override
  String get walkie_teamPlanStatus => 'Status do Plano de Equipe';

  @override
  String get walkie_teamSeatMember => 'Membro com posto de equipe';

  @override
  String get walkie_title => 'Walkie-Talkie';

  @override
  String walkie_totalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no total',
      one: '1 no total',
    );
    return '$_temp0';
  }

  @override
  String get walkie_trialActive1hr => 'Teste de 1 h ativo';

  @override
  String get walkie_trialEndedSubscribe =>
      'Teste grátis finalizado — Assine para continuar';

  @override
  String get walkie_unableToConnectReconnecting =>
      'Não foi possível conectar ao canal — Reconectando...';

  @override
  String get walkie_unavailable => 'Indisponível';

  @override
  String walkie_updateMembers(int assigned, int total) {
    return 'Atualizar membros ($assigned/$total)';
  }

  @override
  String get walkie_updatingMembers => 'Atualizando membros...';

  @override
  String get walkie_upgradeAddSeats => 'Atualizar e adicionar postos';

  @override
  String get walkie_upgradeNow => 'Atualizar agora';

  @override
  String get walkie_upgradeTeamAssign =>
      'Atualizar para Plano de Equipe (Atribuir membros)';

  @override
  String get walkie_upgradeToTeamPlan => 'Atualizar para Plano de Equipe';

  @override
  String walkie_userCancelled(String name) {
    return '$name cancelou';
  }

  @override
  String walkie_userJoined(String name) {
    return '$name entrou';
  }

  @override
  String walkie_userLeft(String name) {
    return '$name saiu';
  }

  @override
  String walkie_validTill(String date) {
    return 'Válido até $date';
  }

  @override
  String get walkie_viewPlan => 'Ver plano';

  @override
  String get walkie_voiceNotPermitted => 'Transmissão de voz não permitida';

  @override
  String get walkie_weakSignal => 'Sinal fraco';

  @override
  String walkie_weakSignalMs(int ms) {
    return 'Sinal fraco ($ms ms)';
  }

  @override
  String get walkie_youAreConnected => 'Você está conectado';

  @override
  String get walkie_yourVoiceAccess => 'Seu acesso de voz';

  @override
  String widget_inviteDownloadLinks(String playStoreLink, String appStoreLink) {
    return 'Baixar para Android: $playStoreLink\n\nBaixar para iOS: $appStoreLink';
  }

  @override
  String get widget_live => 'Ao Vivo';

  @override
  String get widget_lostConnection => 'Conexão Perdida';

  @override
  String get widget_manageGroups => 'Gerencie seus grupos com facilidade';

  @override
  String get widget_noInternetBody =>
      'Ops... sem conexão com a internet. Verifique sua conexão';

  @override
  String get widget_notSeenYet => 'Não visto ainda';

  @override
  String get widget_pinnedMessage => 'Mensagem Fixada';

  @override
  String get widget_private => 'Privado';

  @override
  String get widget_refreshPage => 'Atualizar a página';

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
  String get widget_somethingWentWrongTitle => 'Algo deu errado';

  @override
  String get widget_userFallback => 'Usuário';
}
