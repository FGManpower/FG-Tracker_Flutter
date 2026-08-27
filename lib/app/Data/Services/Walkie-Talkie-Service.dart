import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_session/audio_session.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';


class GroupWalkieService {
  GroupWalkieService._();
  static final instance = GroupWalkieService._();

  Socket? socket;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  // ✅ Pure Uint8List Stream Controller (No Food references)
  StreamController<Uint8List>? _micStreamController;
  StreamSubscription<Uint8List>? _micStreamSubscription;

  bool _recorderReady = false;
  bool _playerReady = false;
  bool _isTalking = false;
  bool _isMuted = false;
  bool _listenersBound = false;

  String? _currentGroupId;
  String? _activeTransmissionId;
  String _lastTransmissionId = "";
  int _sequenceCounter = 0;
  int _lastReceivedSeq = 0;
  String? _selfUserId;
  List<String> _cachedGroupIds = [];

  static const int sampleRate = 16000;
  static const int channels = 1;
  static const int frameSize = 640; // 20ms @ 16kHz PCM16

  // ============================================================
  // INIT
  // ============================================================
  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    _selfUserId = selfUserId;
    await _configureAudioSession();
    await _initializePlayer();

    socket = io(
      "$websocketUrl/groupWalkie",
      OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': selfUserId})
          .enableForceNew()
          .enableAutoConnect()
          .setReconnectionDelay(1000)
          .build(),
    );

    socket!.onConnect((_) {
      log("🔌 Walkie Socket Connected (User: $selfUserId)");
      _bindSocketListeners();
      if (_cachedGroupIds.isNotEmpty) {
        registerGroups(_cachedGroupIds);
      }
    });

    socket!.onDisconnect((_) {
      log("🔌 Walkie Socket Disconnected");
      _listenersBound = false;
    });
  }

  void registerGroups(List<String> groupIds) {
    _cachedGroupIds = groupIds;
    if (socket != null && socket!.connected) {
      socket?.emit("register_walkie_groups", {"groupIds": groupIds});
      log("📻 Registered ${groupIds.length} groups with socket");
    }
  }

  // ============================================================
  // SOCKET LISTENERS
  // ============================================================
  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    socket?.off("walkie_auto_open");
    socket?.off("audio_chunk");
    socket?.off("walkie_speaker_active");
    socket?.off("walkie_speaker_stopped");
    socket?.off("walkie_participants_update");
    socket?.off("walkie_status");
    socket?.off("walkie_channel_locked");

    socket?.on("walkie_auto_open", (data) {
      final groupId = data['groupId']?.toString() ?? "";
      final speakerName = data['speakerName'] ?? "Someone";
      final groupName = data['groupName'] ?? "Group";

      if (Get.currentRoute == Routes.groupWalkieScreen) return;

      Get.toNamed(
        Routes.groupWalkieScreen,
        arguments: {
          "groupId": groupId,
          "groupName": groupName,
          "speakerName": speakerName,
          "autoOpened": true,
        },
      );
    });

    socket?.on("audio_chunk", (data) {
      if (!_playerReady || _isMuted || _isTalking) return;

      try {
        final transId = data['transmissionId']?.toString() ?? "";
        final seq = (data['seq'] as int?) ?? 0;
        final speakerId = data['speakerId']?.toString() ?? "";

        if (speakerId == _selfUserId) return;

        if (_activeTransmissionId != null && transId != _activeTransmissionId) {
          return;
        }

        if (transId != _lastTransmissionId) {
          _lastTransmissionId = transId;
          _lastReceivedSeq = 0;
        }

        if (seq > 0) {
          if (seq <= _lastReceivedSeq) return;
          _lastReceivedSeq = seq;
        }

        Uint8List? pcm = _extractPcmBytes(data['chunk']);
        if (pcm == null || pcm.isEmpty) return;

        pcm = _applyClampedGain(pcm, gain: 2.0);
        _player.uint8ListSink?.add(pcm);
      } catch (e) {
        log("❌ audio_chunk decode error: $e");
      }
    });

    socket?.on("walkie_speaker_active", (data) {
      _activeTransmissionId = data['transmissionId']?.toString();
      _lastTransmissionId = _activeTransmissionId ?? "";
      _lastReceivedSeq = 0;

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerActive(
          speakerId: data['speakerId']?.toString() ?? "",
          speakerName: data['speakerName'] ?? "User",
          speakerImage: data['speakerImage'] ?? "",
        );
      }
    });

    socket?.on("walkie_speaker_stopped", (data) {
      _activeTransmissionId = null;
      _lastTransmissionId = "";
      _lastReceivedSeq = 0;

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }
    });

    socket?.on("walkie_participants_update", (data) {
      if (Get.isRegistered<GroupWalkieController>()) {
        final list = (data['participants'] as List? ?? [])
            .map((p) => WalkieParticipant.fromMap(p))
            .toList();
        Get.find<GroupWalkieController>().updateParticipants(
          list,
          activeSpeaker: data['activeSpeaker']?.toString(),
        );
      }
    });

    socket?.on("walkie_status", (data) {
      final status = data['status']?.toString() ?? "";
      if (Get.isRegistered<GroupWalkieController>()) {
        final c = Get.find<GroupWalkieController>();
        if (status == "BUSY") c.showBusyMessage(data['speakerName'] ?? "");
        else if (status == "OPEN") _activeTransmissionId = data['transmissionId']?.toString();
        else if (status == "LOCKED") c.showLockedMessage();
        else if (status == "MUTED") c.showMutedMessage();
      }
    });

    socket?.on("walkie_channel_locked", (data) {
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onChannelLocked(
          isLocked: data['isLocked'] ?? false,
        );
      }
    });
  }

  Uint8List? _extractPcmBytes(dynamic chunk) {
    if (chunk == null) return null;
    if (chunk is Uint8List) return chunk;
    if (chunk is List<int>) return Uint8List.fromList(chunk);
    if (chunk is List) return Uint8List.fromList(chunk.cast<int>());
    if (chunk is Map && chunk['data'] is List) {
      return Uint8List.fromList((chunk['data'] as List).cast<int>());
    }
    return null;
  }

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
    await session.setActive(true);
  }

  Future<void> _initializePlayer() async {
    if (_playerReady) return;
    await _player.openPlayer();
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: channels,
      bufferSize: 2048,
      interleaved: true,
    );
    _playerReady = true;
    log("✅ Audio Player Initialized");
  }

  Future<void> initRecorder() async {
    if (_recorderReady) return;
    await _recorder.openRecorder();
    _recorderReady = true;
    log("🎙️ Microphone Hardware Ready");
  }

  // ============================================================
  // PUSH-TO-TALK (START / STOP)
  // ============================================================
  Future<void> startTalking() async {
    if (_currentGroupId == null || _isTalking) return;
    _isTalking = true;
    _sequenceCounter = 0;

    socket?.emit("walkie_start", {"groupId": _currentGroupId});

    if (!_recorderReady) await initRecorder();

    // ✅ Clean type: StreamController<Uint8List>
    _micStreamController = StreamController<Uint8List>();

    await _micStreamSubscription?.cancel();
    _micStreamSubscription = _micStreamController!.stream.listen((Uint8List buffer) {
      if (socket?.connected != true || !_isTalking) return;

      int offset = 0;
      while (offset + frameSize <= buffer.length) {
        _sequenceCounter++;
        final frame = buffer.sublist(offset, offset + frameSize);

        socket!.emit("audio_chunk", {
          "chunk": frame,
          "seq": _sequenceCounter,
        });

        offset += frameSize;
      }
    });

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: channels,
      audioSource: AudioSource.voice_communication,
      toStream: _micStreamController!.sink,
    );

    log("🎤 Microphone active and transmitting");
  }

  Future<void> stopTalking() async {
    if (!_isTalking) return;
    _isTalking = false;

    socket?.emit("walkie_stop", {"groupId": _currentGroupId});

    try {
      await _recorder.stopRecorder();
      await _micStreamSubscription?.cancel();
      await _micStreamController?.close();
    } catch (e) {
      log("stopRecorder error: $e");
    }

    _micStreamSubscription = null;
    _micStreamController = null;
    _sequenceCounter = 0;
    log("🛑 Transmission stopped");
  }

  void joinGroup(String groupId) {
    _currentGroupId = groupId;
    socket?.emit("join_group_walkie", {"groupId": groupId});
  }

  void leaveGroup() {
    if (_currentGroupId == null) return;
    socket?.emit("leave_group_walkie", {"groupId": _currentGroupId});
    _currentGroupId = null;
    _activeTransmissionId = null;
    _lastTransmissionId = "";
    _lastReceivedSeq = 0;
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    socket?.emit("walkie_toggle_mute", {
      "groupId": _currentGroupId,
      "isMuted": _isMuted,
    });
  }

  void toggleLockChannel(bool isLocked) {
    socket?.emit("walkie_lock_channel", {
      "groupId": _currentGroupId,
      "isLocked": isLocked,
    });
  }

  Uint8List _applyClampedGain(Uint8List pcm, {double gain = 2.0}) {
    if (pcm.isEmpty) return pcm;
    try {
      final byteData = pcm.buffer.asByteData(pcm.offsetInBytes, pcm.lengthInBytes);
      final samplesLength = pcm.lengthInBytes ~/ 2;
      final outputBytes = Uint8List(pcm.lengthInBytes);
      final outByteData = outputBytes.buffer.asByteData();

      for (int i = 0; i < samplesLength; i++) {
        int sample = byteData.getInt16(i * 2, Endian.little);
        int boosted = (sample * gain).toInt();
        if (boosted > 32767) boosted = 32767;
        if (boosted < -32768) boosted = -32768;
        outByteData.setInt16(i * 2, boosted, Endian.little);
      }
      return outputBytes;
    } catch (e) {
      return pcm;
    }
  }

  Future<void> stopRecorder() async {
    if (!_recorderReady) return;
    try {
      await _recorder.stopRecorder();
      await _recorder.closeRecorder();
      await _micStreamSubscription?.cancel();
      await _micStreamController?.close();
    } catch (e) {
      log("stopRecorder error: $e");
    }
    _micStreamSubscription = null;
    _micStreamController = null;
    _recorderReady = false;
    _sequenceCounter = 0;
  }

  Future<void> dispose() async {
    _isTalking = false;
    if (_recorderReady) await stopRecorder();
    if (_playerReady) {
      await _player.stopPlayer();
      await _player.closePlayer();
      _playerReady = false;
    }
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}