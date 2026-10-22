import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  String? _voiceToTextRecordingPath;
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
    _initSpeechEngine();
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

    // Configure iOS noise cancellation
    if (Platform.isIOS) {
      try {
        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker |
              AVAudioSessionCategoryOptions.allowBluetooth,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
        ));
        await session.setActive(true);
      } catch (e) {
        debugPrint('[VoiceInput] iOS AudioSession: $e');
      }
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
        final prefix = targetLocale.split('_').first;
        final matching = locales
            .where((l) => l.localeId.toLowerCase().startsWith(prefix.toLowerCase()))
            .toList();
        if (matching.isNotEmpty) {
          targetLocale = matching.first.localeId;
        } else {
          final sys = await _speech.systemLocale();
          if (sys != null) targetLocale = sys.localeId;
        }
      }
    } catch (_) {}

    // 1. Record audio concurrently so user can listen/replay what they spoke
    try {
      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/vt_audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
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
        _voiceToTextRecordingPath = path;
        debugPrint('[VoiceInput] VT concurrent audio recording started at $path');
      }
    } catch (e) {
      debugPrint('[VoiceInput] Concurrent recording note: $e');
      _voiceToTextRecordingPath = null;
    }

    // 2. Start speech-to-text recognition
    try {
      await _speech.listen(
        onResult: _handleSpeechResult,
        onSoundLevelChange: _handleSoundLevel,
        listenOptions: SpeechListenOptions(
          localeId: targetLocale,
          listenMode: ListenMode.deviceDefault,
          partialResults: true,
          autoPunctuation: true,
          onDevice: false,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 4),
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
      await _speech.stop();
    } catch (_) {}

    if (_voiceToTextRecordingPath != null) {
      try {
        final path = await _recorder.stop();
        _voiceToTextRecordingPath = null;
        if (path != null && File(path).existsSync()) {
          voiceToTextAudioPath.value = path;
          audioDurationSeconds.value = timerSeconds.value;
          await _preparePlayer(path);
          debugPrint('[VoiceInput] VT audio saved & player prepared at: $path');
        }
      } catch (e) {
        debugPrint('[VoiceInput] Error stopping VT recorder: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    await _finishListening();
    _isStopping = false;
  }

  Future<void> _finishListening() async {
    _stopTimer();
    if (_voiceToTextRecordingPath != null) {
      try {
        final path = await _recorder.stop();
        _voiceToTextRecordingPath = null;
        if (path != null && File(path).existsSync()) {
          voiceToTextAudioPath.value = path;
          audioDurationSeconds.value = timerSeconds.value;
          await _preparePlayer(path);
          debugPrint('[VoiceInput] VT audio saved in finish: $path');
        }
      } catch (e) {
        debugPrint('[VoiceInput] Error stopping VT recorder in finish: $e');
      }
    }

    final text = recognizedWords.value.trim();
    if (text.isEmpty && voiceToTextAudioPath.value.isEmpty) {
      didntCatchThat.value = true;
      hintMessage.value = "Didn't catch that. Tap the mic and speak a little louder.";
    } else {
      didntCatchThat.value = false;
      mode.value = VoiceInputMode.voiceToTextReview;
    }
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

    final dir = await getTemporaryDirectory();
    final path = "${dir.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a";
    recordedAudioPath.value = path;
    timerSeconds.value = 0;
    normalizedSoundLevel.value = 0.2;

    _updateRecordingHint();

    await _recorder.start(
      const RecordConfig(
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
    if (path != null && timerSeconds.value >= 1) {
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
    _player = AudioPlayer();
    try {
      await _player!.setFilePath(path);
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
    }
  }

  Future<void> togglePlayPause() async {
    if (_player == null) return;
    if (_player!.playing) {
      await _player!.pause();
    } else {
      if (_player!.processingState == ProcessingState.completed) {
        await _player!.seek(Duration.zero);
      }
      await _player!.play();
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
    _voiceToTextRecordingPath = null;
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
    super.onClose();
  }
}
