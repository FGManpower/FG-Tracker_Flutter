import 'package:just_audio/just_audio.dart';

class GlobalAudioManager {
  static final GlobalAudioManager _instance =
  GlobalAudioManager._internal();

  factory GlobalAudioManager() => _instance;

  GlobalAudioManager._internal();

  AudioPlayer? currentPlayer;

  Future<void> play(AudioPlayer player) async {
    if (currentPlayer != null && currentPlayer != player) {
      await currentPlayer!.stop();
    }

    currentPlayer = player;
    await player.play();
  }
}