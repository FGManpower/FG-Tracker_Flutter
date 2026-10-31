import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceSheetState {
  listening,
  review,
  noSpeech,
  error,
}

enum VoiceTypingContext {
  normal,
  reply,
  attachment,
}

class VoiceTypingController extends GetxController with WidgetsBindingObserver {
  final TextEditingController textController;
  final FocusNode focusNode;

  void _vtLog(String message) {
    if (kDebugMode) debugPrint('[VT] $message');
  }

  VoiceTypingController({
    required this.textController,
    required this.focusNode,
  });

  // Services
  final SpeechToText _speechToText = SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // State
  final Rx<VoiceSheetState> sheetState = VoiceSheetState.listening.obs;
  final RxString currentLocale = "en_IN".obs;
  final RxString errorMessage = "".obs;

  // Live Listening Data
  final RxInt listeningSeconds = 0.obs;
  final RxDouble soundLevel = 0.0.obs;
  final RxString liveRecognizedText = "".obs;

  // Review & Playback Data
  final RxBool hasAudioRecording = false.obs;
  final RxBool isPlayingAudio = false.obs;
  final Rx<Duration> playbackPosition = Duration.zero.obs;
  final Rx<Duration> playbackTotalDuration = Duration.zero.obs;

  // Session Text Tracking
  String _initialBoxText = "";
  String _sessionAddedText = "";
  String? _recordingPath;

  // Timers
  Timer? _durationTimer;
  Timer? _silenceTimer;
  bool _isSpeechInitialized = false;
  bool _isDisposed = false;

  // Context Detection
  VoiceTypingContext get contextMode {
    if (Get.isRegistered<MessageController>()) {
      final mc = Get.find<MessageController>();
      if (mc.replyMessage.value != null) {
        return VoiceTypingContext.reply;
      }
      if (mc.imagePaths.isNotEmpty ||
          mc.videoPaths.isNotEmpty ||
          mc.documentPath.value.isNotEmpty) {
        return VoiceTypingContext.attachment;
      }
    }
    return VoiceTypingContext.normal;
  }

  String get listeningHintText {
    switch (contextMode) {
      case VoiceTypingContext.reply:
        return "Speak now – we are typing your reply";
      case VoiceTypingContext.attachment:
        return "Speak now – we are typing your caption";
      case VoiceTypingContext.normal:
        return "Speak now – your words appear in the message box";
    }
  }

  String get reviewChipText {
    switch (contextMode) {
      case VoiceTypingContext.reply:
        return "Reply ready";
      case VoiceTypingContext.attachment:
        return "Caption ready";
      case VoiceTypingContext.normal:
        return "Text ready";
    }
  }

  String get languageLabel =>
      currentLocale.value.toLowerCase().startsWith("hi") ? "HI" : "EN";

  String get formattedListeningTimer {
    final minutes = (listeningSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (listeningSeconds.value % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  String get formattedPlaybackTimer {
    final total = playbackTotalDuration.value.inSeconds;
    final current = playbackPosition.value.inSeconds;
    final displaySec = isPlayingAudio.value ? current : total;
    final minutes = (displaySec ~/ 60).toString().padLeft(2, '0');
    final seconds = (displaySec % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  double get playbackProgressFraction {
    final totalMs = playbackTotalDuration.value.inMilliseconds;
    if (totalMs <= 0) return 0.0;
    return (playbackPosition.value.inMilliseconds / totalMs).clamp(0.0, 1.0);
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initialBoxText = textController.text;
    _setupAudioPlayerStreams();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (sheetState.value == VoiceSheetState.listening) {
        stopListening();
      }
    }
  }

  void _setupAudioPlayerStreams() {
    _audioPlayer.playerStateStream.listen((state) {
      if (_isDisposed) return;
      isPlayingAudio.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer.pause();
        _audioPlayer.seek(Duration.zero);
        isPlayingAudio.value = false;
        playbackPosition.value = Duration.zero;
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (_isDisposed) return;
      playbackPosition.value = pos;
    });

    _audioPlayer.durationStream.listen((dur) {
      if (_isDisposed) return;
      if (dur != null) {
        playbackTotalDuration.value = dur;
      }
    });
  }

  Future<void> startListening() async {
    sheetState.value = VoiceSheetState.listening;
    errorMessage.value = "";
    listeningSeconds.value = 0;
    liveRecognizedText.value = "";
    _sessionAddedText = "";
    soundLevel.value = 0.0;

    _vtLog("startListening() called");

    // Permission status check
    final micPerm = await Permission.microphone.status;
    final speechPerm = await Permission.speech.status;
    _vtLog("Permissions -> mic: $micPerm, speech: $speechPerm");

    // 1. Initialize Speech Recognizer if not yet initialized
    if (!_isSpeechInitialized) {
      try {
        _isSpeechInitialized = await _speechToText.initialize(
          onStatus: _handleSpeechStatus,
          onError: _handleSpeechError,
          debugLogging: true,
          options: [
            SpeechConfigOption('android', 'noBluetooth', true),
          ],
        );
        _vtLog("speech.initialize() result: $_isSpeechInitialized");

        final sysLocale = await _speechToText.systemLocale();
        _vtLog("System locale: ${sysLocale?.localeId}");
        if (sysLocale != null &&
            sysLocale.localeId.isNotEmpty &&
            !currentLocale.value.toLowerCase().startsWith("hi")) {
          currentLocale.value = sysLocale.localeId;
        }
        
        final availableLocales = await _speechToText.locales();
        _vtLog("speech.locales() [${availableLocales.length}]: ${availableLocales.map((l) => l.localeId).toList()}");
      } catch (e) {
        _vtLog("speech.initialize() exception: $e");
        _isSpeechInitialized = false;
      }
    }

    if (!_isSpeechInitialized) {
      errorMessage.value = "Voice typing isn't available on this device.";
      sheetState.value = VoiceSheetState.error;
      return;
    }

    // 1.1 Ensure Android hardware is in MODE_NORMAL for SpeechRecognizer
    if (Platform.isAndroid) {
      try {
        final am = AndroidAudioManager();
        await am.setMode(AndroidAudioHardwareMode.normal);
      } catch (e) {
        _vtLog("Audio mode reset: $e");
      }
    }

    // Ensure any leftover recognizer is cancelled before starting new
    if (_speechToText.isListening) {
      try {
        await _speechToText.cancel();
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {}
    }

    // 2. Start Concurrent Local Audio Recording for replay (iOS only; Android mic cannot be shared)
    if (!Platform.isAndroid) {
      await _startLocalRecording();
    } else {
      hasAudioRecording.value = false;
      _recordingPath = null;
    }

    // Check if recorder / audio player is active while recognition starts
    final isRecorderRecording = await _audioRecorder.isRecording();
    _vtLog("During recognition start -> AudioRecorder.isRecording: $isRecorderRecording, AudioPlayer.playing: ${_audioPlayer.playing}");

    // 3. Start Duration Timer
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      listeningSeconds.value++;
      if (listeningSeconds.value >= 60) {
        _vtLog("60s duration timeout reached -> stopping listening");
        stopListening();
      }
    });

    // 4. Determine best localeId
    String targetLocale = currentLocale.value;
    try {
      final locales = await _speechToText.locales();
      final hasExact = locales.any((l) => l.localeId == targetLocale);
      if (!hasExact) {
        final prefix = targetLocale.split('_').first;
        final matching = locales.where((l) => l.localeId.toLowerCase().startsWith(prefix)).toList();
        if (matching.isNotEmpty) {
          targetLocale = matching.first.localeId;
        } else {
          final sys = await _speechToText.systemLocale();
          if (sys != null) targetLocale = sys.localeId;
        }
      }
    } catch (_) {}
    _vtLog("localeId passed to listen(): $targetLocale");

    // 5. Start Listening with Speech Recognizer
    try {
      await _speechToText.listen(
        onResult: _handleSpeechResult,
        onSoundLevelChange: (level) {
          _vtLog("onSoundLevelChange: level=$level");
          if (_isDisposed || sheetState.value != VoiceSheetState.listening) return;
          final normalized = ((level + 2.0) / 10.0).clamp(0.0, 1.0);
          soundLevel.value = normalized;
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.deviceDefault,
          cancelOnError: false,
          partialResults: true,
          autoPunctuation: true,
          localeId: targetLocale,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 5),
        ),
      );
      _vtLog("speech.listen() started successfully");
    } catch (e) {
      _vtLog("speech.listen() exception: $e");
      stopListening();
    }
  }

  Future<void> _startLocalRecording() async {
    if (Platform.isAndroid) {
      hasAudioRecording.value = false;
      _recordingPath = null;
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      _recordingPath =
          "${dir.path}/vt_${DateTime.now().millisecondsSinceEpoch}.m4a";

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );
      hasAudioRecording.value = true;
      _vtLog("_audioRecorder started successfully: $_recordingPath");
    } catch (e) {
      _vtLog("_audioRecorder start failed: $e");
      hasAudioRecording.value = false;
      _recordingPath = null;
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    _vtLog("onResult -> recognizedWords: '${result.recognizedWords}', finalResult: ${result.finalResult}, confidence: ${result.confidence}");
    if (_isDisposed || sheetState.value != VoiceSheetState.listening) return;

    final words = result.recognizedWords.trim();
    liveRecognizedText.value = words;
    _resetSilenceTimer();

    if (words.isNotEmpty) {
      _applyTextToBox(words);
    }
  }

  void _applyTextToBox(String words) {
    String newFullText;
    if (_initialBoxText.isEmpty) {
      newFullText = words;
    } else if (_initialBoxText.endsWith(" ")) {
      newFullText = "$_initialBoxText$words";
    } else {
      newFullText = "$_initialBoxText $words";
    }

    textController.text = newFullText;
    textController.selection = TextSelection.collapsed(offset: newFullText.length);
    _sessionAddedText = words;
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    // Auto-stop after ~4 seconds of silence once speech has been recognized
    _silenceTimer = Timer(const Duration(milliseconds: 4000), () {
      if (sheetState.value == VoiceSheetState.listening) {
        _vtLog("Silence timer triggered stopListening()");
        stopListening();
      }
    });
  }

  void _handleSpeechStatus(String status) {
    _vtLog("onStatus: $status");
    if (_isDisposed) return;
    // Allow user to continue speaking naturally without premature kill
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    _vtLog("onError: errorMsg=${error.errorMsg}, permanent=${error.permanent}");
    if (_isDisposed) return;
    if (error.errorMsg == "error_language_unavailable") {
      _vtLog("Language unavailable -> falling back to system locale");
      _speechToText.systemLocale().then((sys) {
        if (sys != null && currentLocale.value != sys.localeId) {
          currentLocale.value = sys.localeId;
          Future.delayed(const Duration(milliseconds: 250), () {
            if (_isDisposed || sheetState.value != VoiceSheetState.listening) return;
            startListening();
          });
        } else {
          _showNoSpeech();
        }
      });
      return;
    }
    if (error.errorMsg == "error_no_match" || error.errorMsg == "error_speech_timeout") {
      // If user is still in listening session and under 15 seconds, keep mic alive
      if (sheetState.value == VoiceSheetState.listening &&
          listeningSeconds.value < 15 &&
          _sessionAddedText.trim().isEmpty) {
        _vtLog("Brief silence timeout -> seamless restart listening");
        Future.delayed(const Duration(milliseconds: 250), () {
          if (_isDisposed || sheetState.value != VoiceSheetState.listening) return;
          startListening();
        });
      } else if (_sessionAddedText.trim().isNotEmpty) {
        stopListening();
      } else {
        _showNoSpeech();
      }
    } else {
      // Generic or network error
      if (_sessionAddedText.isEmpty) {
        errorMessage.value = "Couldn't connect. Please check internet connection.";
        sheetState.value = VoiceSheetState.error;
        _cleanUpAfterStop();
      } else {
        stopListening();
      }
    }
  }

  void _showNoSpeech() {
    _cleanUpAfterStop();
    sheetState.value = VoiceSheetState.noSpeech;
  }

  Future<void> stopListening() async {
    if (sheetState.value != VoiceSheetState.listening) return;

    _durationTimer?.cancel();
    _silenceTimer?.cancel();

    try {
      await _speechToText.stop();
    } catch (_) {}

    // Wait 350ms to allow Google SpeechRecognizer to deliver pending final words
    await Future.delayed(const Duration(milliseconds: 350));

    String? savedAudioPath;
    try {
      if (hasAudioRecording.value) {
        savedAudioPath = await _audioRecorder.stop();
      }
    } catch (_) {
      hasAudioRecording.value = false;
    }

    // Check if any words were captured
    if (_sessionAddedText.trim().isEmpty) {
      _deleteRecordedFile(savedAudioPath);
      sheetState.value = VoiceSheetState.noSpeech;
      return;
    }

    // Prepare audio playback if recorded file is present and valid
    if (savedAudioPath != null && File(savedAudioPath).existsSync()) {
      _recordingPath = savedAudioPath;
      try {
        await _audioPlayer.setFilePath(savedAudioPath);
        hasAudioRecording.value = true;
      } catch (_) {
        hasAudioRecording.value = false;
      }
    } else {
      hasAudioRecording.value = false;
    }

    sheetState.value = VoiceSheetState.review;
  }

  void _cleanUpAfterStop() {
    _durationTimer?.cancel();
    _silenceTimer?.cancel();
    try {
      _speechToText.stop();
    } catch (_) {}
    try {
      if (hasAudioRecording.value) {
        _audioRecorder.stop();
      }
    } catch (_) {}
    _deleteRecordedFile(_recordingPath);
    _recordingPath = null;
    hasAudioRecording.value = false;
  }

  Future<void> toggleLanguage() async {
    final isHindi = currentLocale.value.toLowerCase().startsWith("hi");
    if (isHindi) {
      final sys = await _speechToText.systemLocale();
      currentLocale.value = sys?.localeId ?? "en_GB";
    } else {
      currentLocale.value = "hi_IN";
    }

    // If currently listening, restart with the new language
    if (sheetState.value == VoiceSheetState.listening) {
      await _speechToText.cancel();
      _durationTimer?.cancel();
      _silenceTimer?.cancel();
      await Future.delayed(const Duration(milliseconds: 300));
      await startListening();
    }
  }

  // Playback Controls
  Future<void> togglePlayPause() async {
    if (!hasAudioRecording.value) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      if (playbackPosition.value >= playbackTotalDuration.value &&
          playbackTotalDuration.value > Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    }
  }

  Future<void> seekPlaybackFraction(double fraction) async {
    if (!hasAudioRecording.value) return;
    final totalMs = playbackTotalDuration.value.inMilliseconds;
    if (totalMs > 0) {
      final targetMs = (totalMs * fraction).round();
      await _audioPlayer.seek(Duration(milliseconds: targetMs));
    }
  }

  // Action: Cancel (from Listening)
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (_) {}
    _cleanUpAfterStop();
    _revertAddedText();
  }

  // Action: Re-record (from Review)
  Future<void> reRecord() async {
    await _audioPlayer.stop();
    _deleteRecordedFile(_recordingPath);
    _recordingPath = null;
    hasAudioRecording.value = false;
    _revertAddedText();
    await startListening();
  }

  // Action: Delete (from Review)
  Future<void> deleteSession() async {
    await _audioPlayer.stop();
    _cleanUpAfterStop();
    _revertAddedText();
  }

  // Action: Done (from Review)
  Future<void> completeSession() async {
    await _audioPlayer.stop();
    _cleanUpPlaybackOnly();
  }

  void _cleanUpPlaybackOnly() {
    try {
      _audioPlayer.stop();
    } catch (_) {}
    _deleteRecordedFile(_recordingPath);
    _recordingPath = null;
  }

  void _revertAddedText() {
    textController.text = _initialBoxText;
    textController.selection = TextSelection.collapsed(offset: _initialBoxText.length);
    _sessionAddedText = "";
  }

  void _deleteRecordedFile(String? path) {
    if (path == null) return;
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _durationTimer?.cancel();
    _silenceTimer?.cancel();
    try {
      _speechToText.stop();
    } catch (_) {}
    try {
      _audioRecorder.dispose();
    } catch (_) {}
    try {
      _audioPlayer.dispose();
    } catch (_) {}
    _deleteRecordedFile(_recordingPath);
    super.onClose();
  }
}
