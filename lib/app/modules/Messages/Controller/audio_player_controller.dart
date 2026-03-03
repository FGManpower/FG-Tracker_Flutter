import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class GlobalAudioController extends GetxController {
  final AudioPlayer player = AudioPlayer();

  RxString currentUrl = "".obs;
  RxBool isPlaying = false.obs;
  Rx<Duration> position = Duration.zero.obs;

  final RxMap<String, Duration> durationCache = <String, Duration>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

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
  }

  Future<void> loadDuration(String url) async {
    if (durationCache.containsKey(url)) return;

    final tempPlayer = AudioPlayer();
    await tempPlayer.setUrl(url);

    durationCache[url] = tempPlayer.duration ?? Duration.zero;

    await tempPlayer.dispose();
  }

  Future<void> play(String url) async {
    if (currentUrl.value != url) {
      await player.stop();
      await player.setUrl(url);
      currentUrl.value = url;
    }

    await player.play();
    isPlaying.value = true;
  }

  Future<void> pause() async {
    await player.pause();
    isPlaying.value = false;
  }

  Duration getDuration(String url) {
    return durationCache[url] ?? Duration.zero;
  }

  bool isCurrent(String url) => currentUrl.value == url;

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
