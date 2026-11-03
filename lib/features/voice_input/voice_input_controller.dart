import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:fgtracker/app/modules/Messages/Controller/audio_player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'services/voice_to_text_audio_recorder.dart';
import 'voice_languages.dart';

enum VoiceInputMode {
  idle,
  voiceToTextListening,
  voiceToTextReview,
  voiceToTextLanguageList,
  recordVoiceRecording,
  recordVoiceReview,
}

enum VoiceContextType { normal, reply, caption }

class VoiceInputController extends GetxController {
  // Engines
  final SpeechToText _speech = SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  final VoiceToTextAudioRecorder _vttAudioRecorder = VoiceToTextAudioRecorder();
  AudioPlayer? _player;

  // Observable state
  final Rx<VoiceInputMode> mode = VoiceInputMode.idle.obs;
  final Rx<VoiceContextType> contextType = VoiceContextType.normal.obs;

  bool get isInlinePanelActive => mode.value != VoiceInputMode.idle;
  bool get isListening => mode.value == VoiceInputMode.voiceToTextListening;
  bool get isRecording => mode.value == VoiceInputMode.recordVoiceRecording;
  bool get isBusyListeningOrRecording => isListening || isRecording;

  // Voice to text data
  final RxString recognizedWords = ''.obs;
  final RxDouble normalizedSoundLevel = 0.0.obs;
  final RxInt timerSeconds = 0.obs;
  late final Rx<VoiceLanguage> selectedLanguage;
  final RxList<VoiceLanguage> availableLanguages = <VoiceLanguage>[].obs;

  final RxString hintMessage = ''.obs;
  final RxBool isTooNoisy = false.obs;
  final RxBool didntCatchThat = false.obs;

  // Record Voice data
  final RxString recordedAudioPath = ''.obs;
  final RxString voiceToTextAudioPath = ''.obs;
  final RxBool isAudioPlaying = false.obs;
  final RxDouble audioProgress = 0.0.obs;
  final RxInt audioDurationSeconds = 0.obs;

  // Restorable text baseline
  TextEditingController? _textController;
  FocusNode? _focusNode;
  RxString? _messageTextRx;
  VoidCallback? onSendCallback;
  void Function(String)? _onVoiceSendCallback;
  void Function(String)? get onVoiceSendCallback => _onVoiceSendCallback;
  String _initialTextBeforeVoice = '';
  String _prefixBeforeVoice = '';

  Timer? _sessionTimer;
  Timer? _noiseGateTimer;
  int _highNoiseTicks = 0;
  bool _isSpeechInitialized = false;
  bool _isStopping = false; // guard against double-stop race condition

  @override
  void onInit() {
    super.onInit();
    // Default to app language
    final appLocaleCode = Get.locale?.languageCode ?? Get.deviceLocale?.languageCode ?? 'en';
    selectedLanguage = VoiceLanguages.defaultLanguage(appLanguageCode: appLocaleCode).obs;
    // Speech engine init (asks mic/speech permission) runs on Voice-to-Text tap, not on chat open
  }

  Future<bool> _initSpeechEngine() async {
    if (_isSpeechInitialized && _speech.isAvailable) return true;
    try {
      final available = await _speech.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
        debugLogging: false,
        options: [
          SpeechConfigOption('android', 'noBluetooth', true),
        ],
      );
      _isSpeechInitialized = available;
      if (available) {
        await _loadAvailableLanguages();
      }
      return available;
    } catch (e) {
      debugPrint('[VoiceInput] initSpeechEngine error: $e');
      _isSpeechInitialized = false;
      return false;
    }
  }

  Future<void> _loadAvailableLanguages() async {
    try {
      final locales = await _speech.locales();
      final List<VoiceLanguage> list = [];
      for (final lang in VoiceLanguages.supported) {
        final hasMatch = locales.any((l) =>
            l.localeId.toLowerCase().startsWith(lang.code.toLowerCase()) ||
            l.localeId.toLowerCase().startsWith(lang.code.split('_')[0].toLowerCase()));
        if (hasMatch) {
          list.add(lang);
        }
      }
      availableLanguages.value = list.isNotEmpty ? list : VoiceLanguages.supported;
    } catch (_) {
      availableLanguages.value = VoiceLanguages.supported;
    }
  }

  // ---------------------------------------------------------------------------
  // 1. VOICE TO TEXT
  // ---------------------------------------------------------------------------
  Future<void> startVoiceToText({
    required TextEditingController textController,
    required FocusNode focusNode,
    required VoiceContextType type,
    RxString? messageText,
    VoidCallback? onSend,
  }) async {
    await _stopAnyAudioPlayer();
    _textController = textController;
    _focusNode = focusNode;
    _messageTextRx = messageText;
    onSendCallback = onSend;
    contextType.value = type;

    _initialTextBeforeVoice = textController.text;
    _prefixBeforeVoice = _initialTextBeforeVoice.trim().isNotEmpty
        ? '${_initialTextBeforeVoice.trim()} '
        : '';

    recognizedWords.value = '';
    voiceToTextAudioPath.value = '';
    audioProgress.value = 0.0;
    audioDurationSeconds.value = 0;
    didntCatchThat.value = false;
    isTooNoisy.value = false;
    timerSeconds.value = 0;
    _highNoiseTicks = 0;
    _updateListeningHint();

    // Ensure Android hardware is in MODE_NORMAL for SpeechRecognizer
    if (Platform.isAndroid) {
      try {
        final am = AndroidAudioManager();
        await am.setMode(AndroidAudioHardwareMode.normal);
      } catch (e) {
        debugPrint('[VoiceInput] Audio mode reset: $e');
      }
    }

    // Cancel leftover recognizer before starting new
    if (_speech.isListening) {
      try {
        await _speech.cancel();
        await Future.delayed(const Duration(milliseconds: 150));
      } catch (_) {}
    }

    final ready = await _initSpeechEngine();
    if (!ready) {
      hintMessage.value = "Microphone unavailable. Please check settings.";
      mode.value = VoiceInputMode.voiceToTextListening;
      return;
    }

    mode.value = VoiceInputMode.voiceToTextListening;
    _startTimer();
    _startNoiseGate();

    String targetLocale = selectedLanguage.value.code;
    try {
      final locales = await _speech.locales();
      final hasExact = locales.any((l) => l.localeId == targetLocale);
      if (!hasExact) {
        final prefix = targetLocale.split(RegExp(r'[-_]')).first.toLowerCase();
        final matching = locales.where((l) {
          final lId = l.localeId.toLowerCase();
          return lId == targetLocale.toLowerCase() ||
              lId.startsWith(prefix) ||
              lId.replaceAll('_', '-') == targetLocale.toLowerCase().replaceAll('_', '-');
        }).toList();
        if (matching.isNotEmpty) {
          targetLocale = matching.first.localeId;
        } else {
          final sys = await _speech.systemLocale();
          if (sys != null) targetLocale = sys.localeId;
        }
      }
    } catch (_) {}

    // Start speech-to-text recognition
    try {
      await _speech.listen(
        onResult: _handleSpeechResult,
        onSoundLevelChange: _handleSoundLevel,
        listenOptions: SpeechListenOptions(
          localeId: targetLocale,
          listenMode: ListenMode.dictation,
          partialResults: true,
          autoPunctuation: true,
          cancelOnError: false,
        ),
      );
    } catch (e) {
      debugPrint('[VoiceInput] listen error: $e');
    }
  }

  void _updateListeningHint() {
    switch (contextType.value) {
      case VoiceContextType.reply:
        hintMessage.value = "Speak now – we are typing your reply";
        break;
      case VoiceContextType.caption:
        hintMessage.value = "Speak now – we are typing your caption";
        break;
      case VoiceContextType.normal:
        hintMessage.value = "Speak now – your words appear in the message box";
        break;
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    if (!isListening) return;

    final raw = result.recognizedWords.trim();
    if (raw.isEmpty) return;

    // Filter low-confidence junk (< 0.3)
    if (result.finalResult && result.hasConfidenceRating && result.confidence > 0 && result.confidence < 0.3) {
      return;
    }

    final formatted = _formatResultText(raw);
    recognizedWords.value = formatted;

    if (_textController != null) {
      final combined = '$_prefixBeforeVoice$formatted';
      _textController!.text = combined;
      _textController!.selection = TextSelection.fromPosition(
        TextPosition(offset: combined.length),
      );
      if (_messageTextRx != null) {
        _messageTextRx!.value = combined;
      }
    }

    if (isTooNoisy.value) {
      isTooNoisy.value = false;
      _updateListeningHint();
    }
    _highNoiseTicks = 0;
  }

  String _formatResultText(String text) {
    if (text.isEmpty) return '';
    final trimmed = text.trim();
    if (trimmed.length == 1) return trimmed.toUpperCase();
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  void _handleSoundLevel(double level) {
    double norm = 0.0;
    if (Platform.isAndroid) {
      norm = ((level + 2) / 12).clamp(0.0, 1.0);
    } else {
      norm = level.clamp(0.0, 1.0);
    }
    normalizedSoundLevel.value = norm;

    if (norm > 0.45 && recognizedWords.value.isEmpty) {
      _highNoiseTicks++;
    } else {
      if (_highNoiseTicks > 0) _highNoiseTicks--;
    }
  }

  void _startNoiseGate() {
    _noiseGateTimer?.cancel();
    _noiseGateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isListening) {
        timer.cancel();
        return;
      }
      if (_highNoiseTicks >= 3 && recognizedWords.value.isEmpty) {
        isTooNoisy.value = true;
        hintMessage.value = "Too much noise – hold the phone closer and speak clearly";
      }
    });
  }

  void _handleSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      // Guard: don't trigger a second stopListening while one is already running
      if (isListening && !_isStopping && timerSeconds.value >= 2) {
        stopListening();
      }
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    debugPrint('[VoiceInput] STT error: ${error.errorMsg}');
    if (error.errorMsg.contains('error_speech_timeout') || error.errorMsg.contains('error_no_match')) {
      if (recognizedWords.value.trim().isEmpty) {
        didntCatchThat.value = true;
        hintMessage.value = "Didn't catch that. Tap the mic and speak a little louder.";
      }
    }
  }

  Future<void> stopListening() async {
    if (_isStopping) return; // already stopping — don't run twice
    _isStopping = true;
    _stopTimer();

    try {
      if (_speech.isListening) {
        await _speech.stop().timeout(
          const Duration(milliseconds: 600),
          onTimeout: () async {
            await _speech.cancel();
          },
        );
      }
    } catch (_) {
      try {
        await _speech.cancel();
      } catch (_) {}
    }

    final text = recognizedWords.value.trim();
    if (text.isNotEmpty) {
      try {
        final path = await _vttAudioRecorder.generateAudioForText(
          text,
          selectedLanguage.value.code,
        );
        if (path != null) {
          voiceToTextAudioPath.value = path;
          await _preparePlayer(path);
          if (_player?.duration != null && _player!.duration!.inSeconds > 0) {
            audioDurationSeconds.value = _player!.duration!.inSeconds;
          } else {
            audioDurationSeconds.value =
                timerSeconds.value > 0 ? timerSeconds.value : 1;
          }
        }
      } catch (e) {
        debugPrint('[VoiceInput] VTT audio generation error: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 100));
    await _finishListening();
    _isStopping = false;
  }

  Future<void> _finishListening() async {
    _stopTimer();
    final text = recognizedWords.value.trim();
    if (text.isEmpty) {
      didntCatchThat.value = true;
      hintMessage.value = "Didn't catch that. Tap the mic and speak a little louder.";
    } else {
      didntCatchThat.value = false;
    }
    mode.value = VoiceInputMode.voiceToTextReview;
  }

  void openLanguagePicker() {
    if (isListening) {
      try {
        _speech.stop();
      } catch (_) {}
    }
    mode.value = VoiceInputMode.voiceToTextLanguageList;
  }

  Future<void> selectLanguage(VoiceLanguage lang) async {
    selectedLanguage.value = lang;
    if (_textController != null && _focusNode != null) {
      await startVoiceToText(
        textController: _textController!,
        focusNode: _focusNode!,
        type: contextType.value,
        messageText: _messageTextRx,
        onSend: onSendCallback,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 2. RECORD VOICE
  // ---------------------------------------------------------------------------
  Future<void> startRecordVoice({
    required TextEditingController textController,
    required FocusNode focusNode,
    required VoiceContextType type,
    void Function(String)? onVoiceSend,
  }) async {
    await _stopAnyAudioPlayer();
    _textController = textController;
    _focusNode = focusNode;
    contextType.value = type;
    _onVoiceSendCallback = onVoiceSend;

    if (!await _recorder.hasPermission()) {
      return;
    }

    if (Platform.isIOS) {
      // Stop chat bubble player before recording
      if (Get.isRegistered<GlobalAudioController>()) {
        await Get.find<GlobalAudioController>().pause();
      }
      try {
        final s = await AudioSession.instance;
        await s.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker |
                  AVAudioSessionCategoryOptions.allowBluetooth,
          // Not voiceChat (walkie sets it app-wide at launch)
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
        ));
        await s.setActive(true);
      } catch (e) {
        if (kDebugMode) debugPrint('[VM] iOS record session error: $e');
      }
    }

    final String path;
    if (Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      final voiceDir = Directory('${docs.path}/voice')
        ..createSync(recursive: true);
      path = '${voiceDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    } else {
      final dir = await getTemporaryDirectory();
      path = "${dir.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a";
    }
    recordedAudioPath.value = path;
    timerSeconds.value = 0;
    normalizedSoundLevel.value = 0.2;

    _updateRecordingHint();

    await _recorder.start(
      Platform.isIOS
          ? const RecordConfig(
              encoder: AudioEncoder.aacLc,
              sampleRate: 44100,
              bitRate: 64000,
              numChannels: 1,
            )
          : const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 16000,
              numChannels: 1,
              echoCancel: true,
              noiseSuppress: true,
              autoGain: true,
            ),
      path: path,
    );
    await _vmIosLog('record started (aacLc 44100 64000 mono)', path: path);

    mode.value = VoiceInputMode.recordVoiceRecording;
    _startTimer();
  }

  void _updateRecordingHint() {
    switch (contextType.value) {
      case VoiceContextType.reply:
        hintMessage.value = "Your voice will be sent as an audio reply";
        break;
      case VoiceContextType.caption:
        hintMessage.value = "Your voice will be sent with the file as audio";
        break;
      case VoiceContextType.normal:
        hintMessage.value = "Your voice will be sent as an audio message";
        break;
    }
  }

  Future<void> stopRecordVoice() async {
    _stopTimer();
    final path = await _recorder.stop();
    await _vmIosLog('after stop', path: path);
    // iOS: reject empty/unfinished files (< 1 KB)
    final tooSmall = Platform.isIOS &&
        path != null &&
        (!File(path).existsSync() || File(path).lengthSync() < 1024);
    if (path != null && timerSeconds.value >= 1 && !tooSmall) {
      recordedAudioPath.value = path;
      audioDurationSeconds.value = timerSeconds.value;
      await _preparePlayer(path);
      mode.value = VoiceInputMode.recordVoiceReview;
    } else {
      if (path != null) {
        try {
          File(path).deleteSync();
        } catch (_) {}
      }
      mode.value = VoiceInputMode.idle;
    }
  }

  Future<void> _preparePlayer(String path) async {
    await _stopAnyAudioPlayer();
    if (Platform.isIOS) await _setIosPlaybackSession();
    _player = AudioPlayer();
    try {
      if (Platform.isIOS) {
        await _vmIosLog('before setAudioSource(AudioSource.file)', path: path);
        await _player!.setAudioSource(AudioSource.file(path));
      } else {
        await _player!.setFilePath(path);
      }
      _player!.playerStateStream.listen((state) {
        isAudioPlaying.value = state.playing;
        if (state.processingState == ProcessingState.completed) {
          isAudioPlaying.value = false;
          audioProgress.value = 0.0;
        }
      });
      _player!.positionStream.listen((pos) {
        final total = _player!.duration ?? Duration.zero;
        if (total.inMilliseconds > 0) {
          audioProgress.value = (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
        }
      });
    } catch (e) {
      debugPrint('[VoiceInput] player setup error: $e');
      if (kDebugMode && Platform.isIOS) {
        debugPrint('[VM] review load failed: ${e is PlayerException ? 'code=${e.code} message=${e.message}' : e}');
      }
    }
  }

  // iOS: playback session for voice notes (plays with silent switch ON, on speaker)
  Future<void> _setIosPlaybackSession() async {
    try {
      final s = await AudioSession.instance;
      await s.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ));
      await s.setActive(true);
    } catch (e) {
      if (kDebugMode) debugPrint('[VM] iOS playback session error: $e');
    }
  }

  Future<void> _vmIosLog(String where, {String? path}) async {
    if (!kDebugMode || !Platform.isIOS) return;
    final c = (await AudioSession.instance).configuration;
    final f = path == null ? null : File(path);
    final exists = f?.existsSync() ?? false;
    debugPrint('[VM] $where cat=${c?.avAudioSessionCategory} '
        'mode=${c?.avAudioSessionMode} opts=${c?.avAudioSessionCategoryOptions?.value}'
        '${f == null ? '' : ' path=$path exists=$exists bytes=${exists ? f.lengthSync() : 0}'}');
  }

  Future<void> togglePlayPause() async {
    if (_player == null) return;
    if (_player!.playing) {
      await _player!.pause();
    } else {
      if (_player!.processingState == ProcessingState.completed) {
        await _player!.seek(Duration.zero);
      }
      if (Platform.isIOS) {
        try {
          await _setIosPlaybackSession();
          await _vmIosLog('before review play');
          unawaited(_player!.play());
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[VM] review play failed: ${e is PlayerException ? 'code=${e.code} message=${e.message}' : e}');
          }
          isAudioPlaying.value = false;
          audioProgress.value = 0.0;
          hintMessage.value = "Couldn't play voice message";
        }
      } else {
        await _player!.play();
      }
    }
  }

  Future<void> seekAudio(double fraction) async {
    if (_player == null) return;
    final total = _player!.duration ?? Duration.zero;
    final target = Duration(milliseconds: (total.inMilliseconds * fraction).round());
    await _player!.seek(target);
  }

  Future<void> _stopAnyAudioPlayer() async {
    if (_player != null) {
      try {
        await _player!.stop();
        await _player!.dispose();
      } catch (_) {}
      _player = null;
    }
    isAudioPlaying.value = false;
    audioProgress.value = 0.0;
  }

  // ---------------------------------------------------------------------------
  // 3. COMMON ACTIONS (Cancel, Delete, Re-record, Send)
  // ---------------------------------------------------------------------------
  Future<void> cancelSession() async {
    _stopTimer();
    await _stopAnyAudioPlayer();

    if (isListening) {
      try {
        await _speech.cancel();
      } catch (_) {}
    }
    await _vttAudioRecorder.cancel();
    if (isRecording) {
      try {
        final path = await _recorder.stop();
        if (path != null) File(path).deleteSync();
      } catch (_) {}
    }

    // Restore text without touching attachments or reply state
    if (_textController != null) {
      _textController!.text = _initialTextBeforeVoice;
      if (_messageTextRx != null) {
        _messageTextRx!.value = _initialTextBeforeVoice;
      }
    }
    _cleanupTempAudio();
    mode.value = VoiceInputMode.idle;
  }

  Future<void> deleteSession() async {
    _stopTimer();
    await _stopAnyAudioPlayer();
    await _vttAudioRecorder.cancel();

    if (_textController != null) {
      _textController!.text = _initialTextBeforeVoice;
      if (_messageTextRx != null) {
        _messageTextRx!.value = _initialTextBeforeVoice;
      }
    }
    _cleanupTempAudio();
    mode.value = VoiceInputMode.idle;
  }

  Future<void> reRecord() async {
    _stopTimer();
    await _stopAnyAudioPlayer();
    await _vttAudioRecorder.cancel();
    _cleanupTempAudio();

    final prevMode = mode.value;
    if (prevMode == VoiceInputMode.voiceToTextReview) {
      if (_textController != null) {
        _textController!.text = _initialTextBeforeVoice;
        if (_messageTextRx != null) {
          _messageTextRx!.value = _initialTextBeforeVoice;
        }
      }
      await Future.delayed(const Duration(milliseconds: 250));
      if (_textController != null && _focusNode != null) {
        await startVoiceToText(
          textController: _textController!,
          focusNode: _focusNode!,
          type: contextType.value,
          messageText: _messageTextRx,
          onSend: onSendCallback,
        );
      }
    } else if (prevMode == VoiceInputMode.recordVoiceReview) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (_textController != null && _focusNode != null) {
        await startRecordVoice(
          textController: _textController!,
          focusNode: _focusNode!,
          type: contextType.value,
          onVoiceSend: _onVoiceSendCallback,
        );
      }
    }
  }

  String consumeRecordedAudio() {
    _stopTimer();
    _stopAnyAudioPlayer();
    final path = recordedAudioPath.value;
    recordedAudioPath.value = '';
    mode.value = VoiceInputMode.idle;
    return path;
  }

  /// Closes the inline voice panel and resets state.
  /// Also syncs [_messageTextRx] with the current text controller value so
  /// the ChatInputArea Obx sees the text and shows the send button.
  void closeInlinePanel() {
    _stopTimer();
    _isStopping = false;
    _stopAnyAudioPlayer();
    try {
      _speech.cancel();
    } catch (_) {}
    _vttAudioRecorder.cancel();
    _cleanupTempAudio();
    // Sync reactive message text so the send button becomes visible
    if (_textController != null && _messageTextRx != null) {
      _messageTextRx!.value = _textController!.text;
    }
    mode.value = VoiceInputMode.idle;
  }

  void _cleanupTempAudio() {
    if (recordedAudioPath.value.isNotEmpty) {
      try {
        final f = File(recordedAudioPath.value);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
      recordedAudioPath.value = '';
    }
    if (voiceToTextAudioPath.value.isNotEmpty) {
      try {
        final f = File(voiceToTextAudioPath.value);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
      voiceToTextAudioPath.value = '';
    }
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      timerSeconds.value++;
    });
  }

  void _stopTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _noiseGateTimer?.cancel();
    _noiseGateTimer = null;
  }

  String get formattedTimer {
    final m = (timerSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (timerSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get formattedAudioDuration {
    final m = (audioDurationSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (audioDurationSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void onClose() {
    _stopTimer();
    _stopAnyAudioPlayer();
    try {
      _speech.cancel();
    } catch (_) {}
    _vttAudioRecorder.dispose();
    super.onClose();
  }
}
