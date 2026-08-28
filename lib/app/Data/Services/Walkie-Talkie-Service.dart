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

enum WalkieAudioRoute { speaker, earpiece, bluetooth, headset }

class GroupWalkieService {
  GroupWalkieService._();
  static final instance = GroupWalkieService._();

  Socket? socket;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  StreamController<Uint8List>? _micStreamController;
  StreamSubscription<Uint8List>? _micStreamSubscription;
  StreamSubscription? _devicesSub;

  bool _recorderReady = false;
  bool _playerReady = false;
  bool _isTalking = false;
  bool _isMuted = false;
  bool _listenersBound = false;
  bool _isSpeakerOn = true;

  final Rx<WalkieAudioRoute> audioRoute = WalkieAudioRoute.speaker.obs;

  String? _currentGroupId;
  String? _activeTransmissionId;
  String _lastTransmissionId = "";
  int _sequenceCounter = 0;
  int _lastReceivedSeq = 0;
  String? _selfUserId;
  List<String> _cachedGroupIds = [];

  static const int sampleRate = 16000;
  static const int channels = 1;
  static const int frameSize = 640;

  bool get isTalking => _isTalking;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;

  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    _selfUserId = selfUserId;

    await _configureAudioSession(speakerOn: true);
    await _initializePlayer();
    await _listenAudioDevices();

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
      _listenersBound = false;
      _bindSocketListeners();
      if (_cachedGroupIds.isNotEmpty) registerGroups(_cachedGroupIds);
    });

    socket!.onDisconnect((_) {
      _listenersBound = false;
    });
  }

  Future<void> _listenAudioDevices() async {
    final session = await AudioSession.instance;

    await _devicesSub?.cancel();
    _devicesSub = session.devicesStream.listen((devices) {
      _updateRouteFromDevices(devices);
    });

    final devices = await session.getDevices();
    _updateRouteFromDevices(devices);
  }

  void _updateRouteFromDevices(Set<AudioDevice> devices) {
    final hasBluetooth = devices.any((d) =>
    d.type == AudioDeviceType.bluetoothA2dp ||
        d.type == AudioDeviceType.bluetoothSco ||
        d.type == AudioDeviceType.bluetoothLe);

    final hasHeadset = devices.any((d) =>
    d.type == AudioDeviceType.wiredHeadset ||
        d.type == AudioDeviceType.wiredHeadphones ||
        d.type == AudioDeviceType.usbAudio);

    if (hasBluetooth) {
      audioRoute.value = WalkieAudioRoute.bluetooth;
      _isSpeakerOn = false;
    } else if (hasHeadset) {
      audioRoute.value = WalkieAudioRoute.headset;
      _isSpeakerOn = false;
    } else if (_isSpeakerOn) {
      audioRoute.value = WalkieAudioRoute.speaker;
    } else {
      audioRoute.value = WalkieAudioRoute.earpiece;
    }

    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().setAudioRoute(audioRoute.value);
      Get.find<GroupWalkieController>().isSpeakerOn.value = _isSpeakerOn;
    }
  }

  void registerGroups(List<String> groupIds) {
    _cachedGroupIds = groupIds;
    if (socket?.connected == true) {
      socket?.emit("register_walkie_groups", {"groupIds": groupIds});
    }
  }

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

      // Already inside another walkie screen => don't force redirect
      if (Get.currentRoute == Routes.groupWalkieScreen) {
        final current = Get.isRegistered<GroupWalkieController>()
            ? Get.find<GroupWalkieController>().currentGroupId
            : null;
        if (current != null && current != groupId) {
          if (Get.isRegistered<GroupWalkieController>()) {
            Get.find<GroupWalkieController>().showBusyMessage(
              "Busy in another channel",
            );
          }
          return;
        }
        return;
      }

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
        if (_activeTransmissionId != null &&
            transId != _activeTransmissionId) return;

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

        // iOS needs stronger gain
        final gain = Platform.isIOS ? 8.0 : 6.0;
        pcm = _applyClampedGain(pcm, gain: gain);
        _player.uint8ListSink?.add(pcm);
      } catch (e) {
        log("audio_chunk error: $e");
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

    socket?.on("walkie_speaker_stopped", (_) {
      _activeTransmissionId = null;
      _lastTransmissionId = "";
      _lastReceivedSeq = 0;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }
    });

    socket?.on("walkie_participants_update", (data) {
      if (!Get.isRegistered<GroupWalkieController>()) return;
      final list = (data['participants'] as List? ?? [])
          .map((p) => WalkieParticipant.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
      Get.find<GroupWalkieController>().updateParticipants(
        list,
        activeSpeaker: data['activeSpeaker']?.toString(),
      );
    });

    socket?.on("walkie_status", (data) {
      if (!Get.isRegistered<GroupWalkieController>()) return;
      final c = Get.find<GroupWalkieController>();
      final status = data['status']?.toString() ?? "";
      if (status == "BUSY") {
        c.showBusyMessage(data['speakerName'] ?? "Someone");
      } else if (status == "OPEN") {
        _activeTransmissionId = data['transmissionId']?.toString();
      } else if (status == "LOCKED") {
        c.showLockedMessage();
      } else if (status == "MUTED") {
        c.showMutedMessage();
      }
    });

    socket?.on("walkie_channel_locked", (data) {
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onChannelLocked(
          isLocked: data['isLocked'] == true,
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


  Future<void> _configureAudioSession({required bool speakerOn}) async {
    final session = await AudioSession.instance;

    if (Platform.isIOS) {
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          // Use default mode to prevent DSP volume dampening
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.allowBluetoothA2dp |
          (speakerOn
              ? AVAudioSessionCategoryOptions.defaultToSpeaker
              : AVAudioSessionCategoryOptions.none),
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        ),
      );
    } else {
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
          androidAudioAttributes: AndroidAudioAttributes(
            usage: speakerOn
                ? AndroidAudioUsage.media
                : AndroidAudioUsage.voiceCommunication,
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.audibilityEnforced,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
    }

    await session.setActive(true);
    _isSpeakerOn = speakerOn;
    log("🔊 Audio Session configured: Speaker = $speakerOn");
  }


  Future<void> _initializePlayer() async {
    if (_playerReady) return;
    await _player.openPlayer();

    // Set internal player volume to max
    await _player.setVolume(1.0);

    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: channels,
      bufferSize: 1024,
      interleaved: false,
    );
    _playerReady = true;


    await _configureAudioSession(speakerOn: _isSpeakerOn);
  }

  Future<void> toggleSpeaker(bool speakerOn) async {
    // If bluetooth/headset connected, block manual speaker toggle
    if (audioRoute.value == WalkieAudioRoute.bluetooth ||
        audioRoute.value == WalkieAudioRoute.headset) {
      _isSpeakerOn = false;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setAudioRoute(audioRoute.value);
      }
      return;
    }

    if (_playerReady) {
      await _player.stopPlayer();
      await _player.startPlayerFromStream(
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: channels,
        bufferSize: 1024,
        interleaved: false,
      );
    }

    await _configureAudioSession(speakerOn: speakerOn);

    audioRoute.value =
    speakerOn ? WalkieAudioRoute.speaker : WalkieAudioRoute.earpiece;

    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().setAudioRoute(audioRoute.value);
    }
  }

  Future<void> initRecorder() async {
    if (_recorderReady) return;
    await _recorder.openRecorder();
    _recorderReady = true;
  }

  Future<void> startTalking() async {
    if (_currentGroupId == null || _isTalking) return;
    _isTalking = true;
    _sequenceCounter = 0;

    socket?.emit("walkie_start", {"groupId": _currentGroupId});
    if (!_recorderReady) await initRecorder();

    _micStreamController = StreamController<Uint8List>();
    await _micStreamSubscription?.cancel();

    _micStreamSubscription = _micStreamController!.stream.listen((buffer) {
      if (socket?.connected != true || !_isTalking) return;

      int offset = 0;
      while (offset + frameSize <= buffer.length) {
        _sequenceCounter++;
        socket!.emit("audio_chunk", {
          "chunk": buffer.sublist(offset, offset + frameSize),
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
  }

  Future<void> stopTalking() async {
    if (!_isTalking) return;
    _isTalking = false;
    socket?.emit("walkie_stop", {"groupId": _currentGroupId});

    try {
      await _recorder.stopRecorder();
      await _micStreamSubscription?.cancel();
      await _micStreamController?.close();
    } catch (_) {}

    _micStreamSubscription = null;
    _micStreamController = null;
    _sequenceCounter = 0;
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

  Uint8List _applyClampedGain(Uint8List pcm, {double gain = 6.0}) {
    if (pcm.isEmpty) return pcm;
    try {
      final byteData =
      pcm.buffer.asByteData(pcm.offsetInBytes, pcm.lengthInBytes);
      final samplesLength = pcm.lengthInBytes ~/ 2;
      final output = Uint8List(pcm.lengthInBytes);
      final out = output.buffer.asByteData();

      for (int i = 0; i < samplesLength; i++) {
        int s = byteData.getInt16(i * 2, Endian.little);
        int v = (s * gain).toInt();
        if (v > 32767) v = 32767;
        if (v < -32768) v = -32768;
        out.setInt16(i * 2, v, Endian.little);
      }
      return output;
    } catch (_) {
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
    } catch (_) {}
    _micStreamSubscription = null;
    _micStreamController = null;
    _recorderReady = false;
  }

  Future<void> dispose() async {
    _isTalking = false;
    await _devicesSub?.cancel();
    if (_recorderReady) await stopRecorder();
    if (_playerReady) {
      await _player.stopPlayer();
      await _player.closePlayer();
      _playerReady = false;
    }
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    _listenersBound = false;
  }
}