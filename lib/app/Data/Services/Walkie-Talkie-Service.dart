import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket_io_client/socket_io_client.dart';

class WalkietalkieService {
  WalkietalkieService._();
  static final instance = WalkietalkieService._();

  Socket? socket;

  // ================= AUDIO =================
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamController<Uint8List>? _micStream;

  bool _recorderReady = false;
  bool _playerReady = false;

  static const int sampleRate = 16000;
  static const int channels = 1;

  // ============================================================
  // INIT
  // ============================================================
  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    log("🚀 Walkie init");

    socket = io(
      "$websocketUrl/walkie",
      {
        "transports": ["websocket"],
        "query": {"userId": selfUserId},
        "forceNew": true,
      },
    );

    socket!.onConnect((_) => log("🔌 Socket connected"));
    socket!.onDisconnect((_) => log("🔌 Socket disconnected"));

    await _initPlayer();

    socket!.on("audio_chunk", _onAudioChunk);
    socket!.on("walkie_stop", (_) {
      log("🛑 walkie_stop received");
    });

    socket!.on("walkie_incoming", (data) {

      WalkieController().onIncoming(
        remoteUserId: data['fromUserId'],
        callerName: data['fromUserName'] ?? "Unknown",
        profileImage: data['fromUserProfile'] ?? "",
      );
    });

  }

  // ============================================================
  // PLAYER (SAFE MODE)
  // ============================================================
  Future<void> _initPlayer() async {
    log("🔊 Opening player");
    try {
      await _player.openPlayer();

      await _player.startPlayerFromStream(
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: channels,
        bufferSize: 1024,
        interleaved: false,
      );

      _playerReady = true;
      log("✅ Player ready");
    } catch (e) {
      log("✅ Player is not ready");
    }
  }

  void _onAudioChunk(dynamic data) {
    if (!_playerReady) return;

    final pcm = Uint8List.fromList(List<int>.from(data));
    log("⬇️ RX audio | bytes=${pcm.length}");

    // 🔥 THIS IS THE SAFE LINE
    _player.uint8ListSink?.add(pcm);
  }

  // ============================================================
  // RECORDER (SAFE MODE)
  // ============================================================
  Future<void> initRecorder() async {
    if (_recorderReady) return;

    log("🎙️ Opening recorder");
    await _recorder.openRecorder();

    _micStream = StreamController<Uint8List>();

    _micStream!.stream.listen((Uint8List buffer) {
      if (socket?.connected == true) {
        socket!.emit("audio_chunk", buffer);
        log("🎤 TX audio | bytes=${buffer.length}");
      }
    });

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: channels,
      toStream: _micStream!.sink,
    );

    _recorderReady = true;
    log("✅ Recorder ready");
  }

  Future<void> stopRecorder() async {
    if (!_recorderReady) return;

    log("🛑 Stopping recorder");

    await _recorder.stopRecorder();
    await _micStream?.close();

    _micStream = null;
    _recorderReady = false;
  }

  // ============================================================
  // SIGNALING
  // ============================================================
  void startTalking(String remoteUserId) {
    log("📡 walkie_start → $remoteUserId");
    socket?.emit("walkie_start", remoteUserId);
  }

  void stopTalking(String remoteUserId) {
    log("📡 walkie_stop → $remoteUserId");
    socket?.emit("walkie_stop", remoteUserId);
  }

  // ============================================================
  // CLEANUP
  // ============================================================
  Future<void> dispose() async {
    log("🧹 Walkie dispose");

    if (_recorderReady) {
      await stopRecorder();
    }

    if (_playerReady) {
      await _player.stopPlayer();
      await _player.closePlayer();
      _playerReady = false;
    }

    socket?.disconnect();
    socket = null;

    log("✅ Walkie disposed");
  }
}
