import 'dart:async';
import 'dart:io';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
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
      currentLocale.value.toLowerCase().startsWith("hi") ? "HI-IN" : "EN-IN";

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

    debugPrint("[VoiceTyping] startListening called");

    // 1. Initialize Speech Recognizer if not yet initialized
    if (!_isSpeechInitialized) {
      try {
        _isSpeechInitialized = await _speechToText.initialize(
          onStatus: _handleSpeechStatus,
          onError: _handleSpeechError,
          debugLogging: true,
        );
        debugPrint("[VoiceTyping] _speechToText initialized: $_isSpeechInitialized");

        final sysLocale = await _speechToText.systemLocale();
        debugPrint("[VoiceTyping] System locale: ${sysLocale?.localeId}");
        
        final availableLocales = await _speechToText.locales();
        debugPrint("[VoiceTyping] Available locales count: ${availableLocales.length}");
      } catch (e) {
        debugPrint("[VoiceTyping] initialize error: $e");
        _isSpeechInitialized = false;
      }
    }

    if (!_isSpeechInitialized) {
      errorMessage.value = "Speech recognition is not available on this device.";
      sheetState.value = VoiceSheetState.error;
      return;
    }

    // 2. Start Concurrent Local Audio Recording for replay
    await _startLocalRecording();

    // 3. Start Duration Timer
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      listeningSeconds.value++;
      if (listeningSeconds.value >= 60) {
        debugPrint("[VoiceTyping] 60s timeout reached");
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
    debugPrint("[VoiceTyping] Listening with locale: $targetLocale");

    // 5. Start Listening with Speech Recognizer
    try {
      await _speechToText.listen(
        onResult: _handleSpeechResult,
        onSoundLevelChange: (level) {
          if (_isDisposed || sheetState.value != VoiceSheetState.listening) return;
          final normalized = ((level + 2.0) / 10.0).clamp(0.0, 1.0);
          soundLevel.value = normalized;
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          autoPunctuation: true,
          localeId: targetLocale,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 5),
        ),
      );
      debugPrint("[VoiceTyping] _speechToText.listen started successfully");
    } catch (e) {
      debugPrint("[VoiceTyping] listen exception: $e");
      stopListening();
    }
  }

  Future<void> _startLocalRecording() async {
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
      debugPrint("[VoiceTyping] _audioRecorder started successfully: $_recordingPath");
    } catch (e) {
      debugPrint("[VoiceTyping] _audioRecorder start failed: $e");
      // Hardware mic concurrency restriction on specific Android devices
      hasAudioRecording.value = false;
      _recordingPath = null;
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    debugPrint("[VoiceTyping] _handleSpeechResult: ${result.recognizedWords} (final: ${result.finalResult})");
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
        debugPrint("[VoiceTyping] Silence timer triggered stopListening");
        stopListening();
      }
    });
  }

  void _handleSpeechStatus(String status) {
    debugPrint("[VoiceTyping] Speech status changed: $status");
    if (_isDisposed) return;
    if (status == "done" || status == "notListening") {
      if (sheetState.value == VoiceSheetState.listening) {
        debugPrint("[VoiceTyping] Status is $status, stopping listening");
        stopListening();
      }
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    debugPrint("[VoiceTyping] Speech error occurred: errorMsg=${error.errorMsg}, permanent=${error.permanent}");
    if (_isDisposed) return;
    if (error.errorMsg == "error_no_match" || error.errorMsg == "error_speech_timeout") {
      if (_sessionAddedText.isEmpty) {
        debugPrint("[VoiceTyping] No text added yet -> showing noSpeech view");
        _showNoSpeech();
      } else {
        stopListening();
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
    final newLocale = currentLocale.value.startsWith("hi") ? "en_IN" : "hi_IN";
    currentLocale.value = newLocale;

    // If currently listening, restart with the new language
    if (sheetState.value == VoiceSheetState.listening) {
      await _speechToText.stop();
      _durationTimer?.cancel();
      _silenceTimer?.cancel();
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
