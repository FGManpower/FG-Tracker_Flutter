import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';

class WalkietalkieService {
  WalkietalkieService._();
  static final instance = WalkietalkieService._();

  Socket? socket;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamController<Uint8List>? _micStream;

  bool _recorderReady = false;
  bool _playerReady = false;
  bool _isTalking = false;
  bool _isReceiving = false;
  String? _currentTransmissionId;
  int _sequenceNumber = 0;

  // Audio settings - optimized for VOICE
  static const int sampleRate = 16000; // 16kHz for voice (not 44.1kHz)
  static const int channels = 1; // Mono
  static const int frameSize = 640; // 20ms at 16kHz (16000 * 0.02 * 2 bytes)

  // ============================================================
  // INIT
  // ============================================================
  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    log("🚀 Walkie init started");

    await _configureAudioSession();
    await _initPlayer();

    socket = io(
      "$websocketUrl/walkie",
      {
        "transports": ["websocket"],
        "query": {"userId": selfUserId},
        "forceNew": true,
        "autoConnect": true,
        "reconnection": true,
        "reconnectionAttempts": 5,
        "reconnectionDelay": 1000,
      },
    );

    socket!.onConnect((_) => log("🔌 Walkie socket connected"));
    socket!.onDisconnect((_) => log("🔌 Walkie socket disconnected"));
    socket!.onConnectError((err) => log("❌ Connect error: $err"));
    socket!.onError((err) => log("❌ Socket error: $err"));

    _setupSocketListeners();
    log("✅ Walkie init completed");
  }

  // ============================================================
  // SOCKET LISTENERS - Registered ONCE only
  // ============================================================
  void _setupSocketListeners() {
    // ✅ CRITICAL: Remove old listeners before adding new ones
    socket?.off("walkie_incoming");
    socket?.off("audio_chunk");
    socket?.off("walkie_stop");
    socket?.off("walkie_status");

    // ======= INCOMING TRANSMISSION =======
    socket?.on("walkie_incoming", (data) {
      log("🔊 walkie_incoming: $data");

      _currentTransmissionId = data['transmissionId']?.toString();
      _isReceiving = true;

      WalkieController().onIncoming(
        remoteUserId: data['fromUserId']?.toString() ?? "",
        callerName: data['fromUserName'] ?? "Unknown",
        profileImage: data['fromUserProfile'] ?? "",
      );
    });

    // ======= RECEIVE AUDIO CHUNK =======
    socket?.on("audio_chunk", (data) {
      if (!_playerReady || !_isReceiving) return;

      try {
        // Extract transmissionId and sequence number
        String? transId;
        Uint8List? pcm;

        if (data is Map) {
          transId = data['transmissionId']?.toString();
          if (transId != _currentTransmissionId) {
            log("⚠️ Ignoring old transmission chunk: $transId");
            return;
          }
          pcm = Uint8List.fromList(List<int>.from(data['chunk']));
        } else if (data is List) {
          pcm = Uint8List.fromList(List<int>.from(data));
        } else if (data is Uint8List) {
          pcm = data;
        }

        if (pcm == null || pcm.isEmpty) return;

        // Apply gain boost for better volume
        pcm = _applyGain(pcm, gain: 3.0);

        // Feed to player
        _player.uint8ListSink?.add(pcm);
      } catch (e) {
        log("❌ _onAudioChunk error: $e");
      }
    });

    // ======= STOP TRANSMISSION =======
    socket?.on("walkie_stop", (data) {
      log("🛑 walkie_stop received: $data");

      _currentTransmissionId = null;
      _isReceiving = false;

      // Flush player buffer
      _player.uint8ListSink?.add(Uint8List(0));

      // Notify controller
      final controller = WalkieController();
      if (controller.audioState.value == WalkieAudioState.listening) {
        controller.stopTalking();
      }
    });

    // ======= CHANNEL STATUS =======
    socket?.on("walkie_status", (data) {
      log("📡 walkie_status: $data");
      final status = data['status']?.toString() ?? "";

      if (status == "BUSY") {
        log("⚠️ Target is busy talking");
        // Show busy indicator or trigger end
      } else if (status == "OPEN") {
        log("✅ Audio channel opened");
        _currentTransmissionId = data['transmissionId']?.toString();
      }
    });
  }

  // ============================================================
  // AUDIO SESSION CONFIGURATION
  // ============================================================
  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;

    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        avAudioSessionCategoryOptions:
        AVAudioSessionCategoryOptions.allowBluetooth |
        AVAudioSessionCategoryOptions.defaultToSpeaker |
        AVAudioSessionCategoryOptions.allowBluetoothA2dp,
        // AVAudioSessionCategoryOptions.allowBluetoothA2DP,
        androidAudioAttributes: const AndroidAudioAttributes(
          usage: AndroidAudioUsage.voiceCommunication,
          contentType: AndroidAudioContentType.speech,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );

    await session.setActive(true);
    log("🎧 AudioSession configured");
  }

  // ============================================================
  // PLAYER INIT
  // ============================================================
  Future<void> _initPlayer() async {
    log("🔊 Opening player");

    await _player.openPlayer();

    await _startPlayerStream();

    _playerReady = true;
    log("✅ Player ready");
  }

  Future<void> _startPlayerStream() async {
    // ✅ CRITICAL: Start from stream for continuous playback
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: channels,
      bufferSize: 4096, // Larger buffer for smoother playback
      interleaved: true, // Always interleaved for PCM16
    );
  }

  // ============================================================
  // AUDIO GAIN
  // ============================================================
  Uint8List _applyGain(Uint8List pcm, {double gain = 2.0}) {
    final Int16List samples = pcm.buffer.asInt16List();
    for (int i = 0; i < samples.length; i++) {
      int boosted = (samples[i] * gain).toInt();
      if (boosted > 32767) boosted = 32767;
      if (boosted < -32768) boosted = -32768;
      samples[i] = boosted;
    }
    return Uint8List.view(samples.buffer);
  }

  // ============================================================
  // RECORDER
  // ============================================================
  Future<void> initRecorder() async {
    if (_recorderReady) {
      log("⚠️ Recorder already ready");
      return;
    }

    log("🎙️ Opening recorder");

    await _recorder.openRecorder();

    _micStream = StreamController<Uint8List>();

    _micStream!.stream.listen((Uint8List buffer) {
      if (socket?.connected != true || !_isTalking) return;

      // ✅ Send frames with sequence numbers
      int offset = 0;
      while (offset + frameSize <= buffer.length) {
        final frame = buffer.sublist(offset, offset + frameSize);
        _sequenceNumber++;

        socket!.emit("audio_chunk", {
          "transmissionId": _currentTransmissionId ?? "",
          "seq": _sequenceNumber,
          "chunk": frame,
        });

        offset += frameSize;
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

    try {
      await _recorder.stopRecorder();
      await _micStream?.close();
    } catch (e) {
      log("❌ stopRecorder error: $e");
    }

    _micStream = null;
    _recorderReady = false;
    _isTalking = false;
    _sequenceNumber = 0;

    log("✅ Recorder stopped");
  }

  // ============================================================
  // START / STOP TALKING
  // ============================================================
  void startTalking(String remoteUserId) {
    log("📡 walkie_start → $remoteUserId");
    _isTalking = true;
    _sequenceNumber = 0;

    socket?.emit("walkie_start", {
      "remoteUserId": remoteUserId,
    });
  }

  void stopTalking(String remoteUserId) {
    log("📡 walkie_stop → $remoteUserId");
    _isTalking = false;

    socket?.emit("walkie_stop", {
      "remoteUserId": remoteUserId,
    });
  }

  // ============================================================
  // SPEAKER TOGGLE
  // ============================================================
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

    log("✅ Speaker switched");
  }

  // ============================================================
  // CLEANUP
  // ============================================================
  Future<void> dispose() async {
    log("🧹 Walkie dispose");

    _isTalking = false;
    _isReceiving = false;
    _currentTransmissionId = null;

    if (_recorderReady) {
      await stopRecorder();
    }

    if (_playerReady) {
      await _player.stopPlayer();
      await _player.closePlayer();
      _playerReady = false;
    }

    socket?.disconnect();
    socket?.dispose();
    socket = null;

    log("✅ Walkie disposed");
  }

  // ============================================================
  // CHECK STATE
  // ============================================================
  bool get isTalking => _isTalking;
  bool get isReceiving => _isReceiving;
  bool get isPlayerReady => _playerReady;
  bool get isRecorderReady => _recorderReady;
}