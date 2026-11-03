import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class GlobalAudioController extends GetxController {
  final AudioPlayer player = AudioPlayer();

  RxString currentUrl = "".obs;
  RxBool isPlaying = false.obs;
  Rx<Duration> position = Duration.zero.obs;

  final RxMap<String, Duration> durationCache = <String, Duration>{}.obs;
  RxString loadingUrl = "".obs;
  RxString errorUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _configureSpeakerSession();

    await player.setLoopMode(LoopMode.off);

    player.positionStream.listen((p) {
      position.value = p;
    });

    player.playerStateStream.listen((state) async {
      isPlaying.value = player.playing;

      if (state.processingState == ProcessingState.completed) {
        await player.pause();
        await player.seek(Duration.zero);
        isPlaying.value = false;
      }
    });

    // Errors while streaming (bad file, network drop) → mark that bubble failed
    player.playbackEventStream.listen((_) {}, onError: (Object e, StackTrace _) {
      if (kDebugMode) debugPrint('[VM] playback error: $e');
      _markFailed(currentUrl.value);
    });
  }

  Future<void> _configureSpeakerSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        // defaultToSpeaker is only valid with playAndRecord; with playback iOS rejects it
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      await session.setActive(true);
    } catch (e) {
      if (kDebugMode) debugPrint('[VM] audio session error: $e');
    }
  }

  Future<void> loadDuration(String url) async {
    if (url.trim().isEmpty || durationCache.containsKey(url)) return;

    Future.microtask(() async {
      AudioPlayer? tempPlayer;
      try {
        tempPlayer = AudioPlayer();
        final dur = await tempPlayer
            .setUrl(url)
            .timeout(const Duration(seconds: 4));
        if (dur != null) {
          durationCache[url] = dur;
        }
      } catch (_) {
      } finally {
        await tempPlayer?.dispose();
      }
    });
  }

  Future<void> play(String url) async {
    if (kDebugMode) debugPrint('[VM] play url=$url current=${currentUrl.value}');
    errorUrl.value = "";
    try {
      await _configureSpeakerSession();
      if (currentUrl.value != url ||
          player.processingState == ProcessingState.idle) {
        await player.stop();
        currentUrl.value = url;
        loadingUrl.value = url;
        final source = url.startsWith('http')
            ? AudioSource.uri(Uri.parse(url))
            : AudioSource.file(url.replaceFirst('file://', ''));
        final dur = await player.setAudioSource(source);
        if (dur != null) durationCache[url] = dur;
        if (kDebugMode) debugPrint('[VM] loaded duration=$dur');
      }
      loadingUrl.value = "";
      unawaited(player.play());
    } on PlayerInterruptedException catch (e) {
      // Another voice note was tapped while this one was loading
      if (kDebugMode) debugPrint('[VM] load interrupted: $e');
    } catch (e) {
      if (kDebugMode) debugPrint('[VM] play failed: $e');
      await _markFailed(url);
    }
  }

  Future<void> _markFailed(String url) async {
    try {
      await player.stop();
    } catch (_) {}
    if (currentUrl.value == url) currentUrl.value = "";
    loadingUrl.value = "";
    isPlaying.value = false;
    position.value = Duration.zero;
    errorUrl.value = url;
  }

  Future<void> pause() async {
    await player.pause();
    isPlaying.value = false;
  }

  Duration getDuration(String url) {
    return durationCache[url] ?? Duration.zero;
  }

  bool isCurrent(String url) => currentUrl.value == url;

  RxDouble playbackSpeed = 1.0.obs;

  Future<void> seek(Duration newPosition) async {
    try {
      await player.seek(newPosition);
      position.value = newPosition;
    } catch (_) {}
  }

  Future<void> toggleSpeed() async {
    try {
      if (playbackSpeed.value == 1.0) {
        playbackSpeed.value = 1.5;
      } else if (playbackSpeed.value == 1.5) {
        playbackSpeed.value = 2.0;
      } else {
        playbackSpeed.value = 1.0;
      }
      await player.setSpeed(playbackSpeed.value);
    } catch (_) {}
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
