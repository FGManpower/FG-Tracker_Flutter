import 'dart:async';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class RingtoneService {
  // Singleton instance
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  final FlutterRingtonePlayer _player = FlutterRingtonePlayer();
  Timer? _ringTimer;

  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Start ringtone
  void start({int timeoutSeconds = 5}) {
    if (_isPlaying) return; // prevent multiple plays

    _isPlaying = true;

    _player.play(
      asAlarm: false,
      fromAsset: "assets/music/Incoming_Call.mp3", // your asset
      looping: true,
      volume: 1.0,
    );

    _ringTimer = Timer(Duration(seconds: timeoutSeconds), () {
      stop();
    });
  }

  /// Stop ringtone
  void stop() {
    if (!_isPlaying) return;

    _ringTimer?.cancel();
    _player.stop();
    _isPlaying = false;
  }
}
