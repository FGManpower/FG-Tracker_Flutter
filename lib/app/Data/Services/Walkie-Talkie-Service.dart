import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';

import '../../Core/util/WalkieUtils.dart';

class WalkietalkieService {
  WalkietalkieService._();
  static final instance = WalkietalkieService._();

  Socket? socket;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamController<Uint8List>? _micStream;

  bool _recorderReady = false;
  bool _playerReady = false;

  static const int sampleRate = 16000;
  static const int channels = 1;

  static const int frameSize = 640; // 16kHz * 20ms * 2 bytes

  // ============================================================
  // INIT
  // ============================================================
  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    log("🚀 Walkie init");

    await _configureAudioSession();

    socket = io(
      "$websocketUrl/walkie",
      {
        "transports": ["websocket"],
        "query": {"userId": selfUserId},
        "forceNew": true,
        "autoConnect": true,
      },
    );

    socket!.onConnect((_) => log("🔌 Socket connected"));
    socket!.onDisconnect((_) => log("🔌 Socket disconnected"));

    await _initPlayer();

    socket!.on("audio_chunk", _onAudioChunk);

    socket!.on("walkie_stop", (_) {
      log("🛑 walkie_stop received");
      WalkieUtils().endWalkieCall();
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
  // AUDIO SESSION (CRITICAL FOR iOS)
  // ============================================================
  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;

    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        avAudioSessionCategoryOptions:
        AVAudioSessionCategoryOptions.allowBluetooth |
        AVAudioSessionCategoryOptions.defaultToSpeaker,
        androidAudioAttributes: const AndroidAudioAttributes(
          usage: AndroidAudioUsage.voiceCommunication,
          contentType: AndroidAudioContentType.speech,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );

    log("🎧 AudioSession configured");
  }

  // ============================================================
  // PLAYER
  // ============================================================
  Future<void> _initPlayer() async {
    log("🔊 Opening player");

    await _player.openPlayer();

    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      // codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: channels,
      bufferSize: 2048,
      // interleaved: true,
      interleaved: Platform.isIOS, // 🔥 CRITICAL
    );

    _playerReady = true;
    log("✅ Player ready");
  }

  // void _onAudioChunk(dynamic data) {
  //   if (!_playerReady) return;
  //
  //   final Uint8List pcm = Uint8List.fromList(List<int>.from(data));
  //   log("⬇️ RX audio | bytes=${pcm.length}");
  //
  //   _player.uint8ListSink?.add(pcm);
  // }

  Uint8List applyGain(Uint8List pcm, {double gain = 2.0}) {
    final Int16List samples = pcm.buffer.asInt16List();
    for (int i = 0; i < samples.length; i++) {
      int boosted = (samples[i] * gain).toInt();

      // clamp to int16 range
      if (boosted > 32767) boosted = 32767;
      if (boosted < -32768) boosted = -32768;

      samples[i] = boosted;
    }
    return Uint8List.view(samples.buffer);
  }

  void _onAudioChunk(dynamic data) {
    if (!_playerReady) return;

    Uint8List pcm = Uint8List.fromList(List<int>.from(data));

    pcm = applyGain(pcm, gain: 2.5); //  BOOST HERE

    _player.uint8ListSink?.add(pcm);
  }


  // ============================================================
  // RECORDER
  // ============================================================
  Future<void> initRecorder() async {
    if (_recorderReady) return;

    log("🎙️ Opening recorder");
    await _recorder.openRecorder();

    _micStream = StreamController<Uint8List>();

    _micStream!.stream.listen((Uint8List buffer) {
      if (socket?.connected != true) return;

      int offset = 0;
      while (offset + frameSize <= buffer.length) {
        final frame = buffer.sublist(offset, offset + frameSize);
        socket!.emit("audio_chunk", frame);
        offset += frameSize;
      }

      log("🎤 TX audio | bytes=${buffer.length}");
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

  Future<void> toggleSpeaker(bool speakerOn) async {
    log("🔊 Toggle Speaker → $speakerOn");

    final session = await AudioSession.instance;

    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        avAudioSessionCategoryOptions:
        (speakerOn
            ? AVAudioSessionCategoryOptions.defaultToSpeaker
            : AVAudioSessionCategoryOptions.none) |
        AVAudioSessionCategoryOptions.allowBluetooth,
        androidAudioAttributes: const AndroidAudioAttributes(
          usage: AndroidAudioUsage.voiceCommunication,
          contentType: AndroidAudioContentType.speech,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );

    await session.setActive(true);

    // 🔥 VERY IMPORTANT
    if (_playerReady) {
      await _player.stopPlayer();
      await _player.startPlayerFromStream(
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: channels,
        bufferSize: 2048,
        interleaved: Platform.isIOS,
      );
    }

    log("✅ Speaker switched");
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
