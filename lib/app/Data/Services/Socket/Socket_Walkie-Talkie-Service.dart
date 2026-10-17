import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_channel_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_invite_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:fgtracker/app/Data/Services/NotificationServices.dart';

enum WalkieAudioRoute { speaker, earpiece, bluetooth, headset }

class GroupWalkieService {
  GroupWalkieService._();
  static final instance = GroupWalkieService._();

  Socket? socket;
  String? _selfUserId;
  String? _currentGroupId;
  MediaStream? _localStream;
  Completer<bool>? _streamCompleter;

  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, MediaStream> _remoteStreams = {};
  final Map<String, List<RTCIceCandidate>> _pendingIce = {};
  final Set<String> _makingOffer = {};
  final Set<String> _offeredTo = {};

  bool _isTalking = false;
  int _talkSessionId = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _listenersBound = false;
  bool _isDisposed = false;
  bool _hasMicPermission = false;
  bool _audioSessionReady = false;

  Timer? _pingTimer;
  StreamSubscription? _devicesSub;
  StreamSubscription? _interruptionSub;
  bool _isCheckingDevices = false;

  String? _bluetoothDeviceId;
  String? _wiredDeviceId;
  String? _speakerDeviceId;
  String? _earpieceDeviceId;
  String? _bluetoothInputDeviceId;
  String? _wiredInputDeviceId;

  final Rx<WalkieAudioRoute> audioRoute = WalkieAudioRoute.speaker.obs;
  final RxBool hasBluetoothDevice = false.obs;
  final RxString bluetoothDeviceName = 'Bluetooth'.obs;
  final RxBool hasHeadsetDevice = false.obs;
  final RxString headsetDeviceName = 'Headset'.obs;

  bool get isTalking => _isTalking;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get hasMicPermission => _hasMicPermission;
  String? get currentGroupId => _currentGroupId;
  String? get selfUserId => _selfUserId;

  static final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {
        'urls': ['stun:stun.l.google.com:19302'],
      },
      {
        'urls': Urls.rtcUrl,
        'username': Urls.rtcUserName,
        'credential': Urls.rtcCredential,
      },
    ],
    'iceTransportPolicy': 'all',
    'sdpSemantics': 'unified-plan',
  };

  void _log(String msg) {
    log('WALKIE[$_selfUserId][g=$_currentGroupId] $msg');
  }

  Future<void> _setMicMuteHelper(bool mute) async {
    if (_localStream != null) {
      final tracks = _localStream!.getAudioTracks();
      if (tracks.isNotEmpty) {
        try {
          await Helper.setMicrophoneMute(mute, tracks.first);
        } catch (_) {}
      }
    }
  }

  Future<void> init({
    required String websocketUrl,
    required String selfUserId,
  }) async {
    _isDisposed = false;
    _selfUserId = selfUserId;
    _log('GroupWalkieService init user=$selfUserId');

    await _listenAudioDevices();
    await _configureAudioSession(route: audioRoute.value);

    socket = io(
      '$websocketUrl/groupWalkie',
      OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': selfUserId})
          .enableForceNew()
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .setTimeout(20000)
          .build(),
    );

    socket!.onConnect((_) {
      _log('✅ Socket connected');
      _listenersBound = false;
      _bindSocketListeners();
      _startPing();
      _notifyConnectionState(true);
      if (_currentGroupId != null) {
        _offeredTo.clear();
        _makingOffer.clear();
        socket?.emit('join_walkie_session', {'groupId': _currentGroupId});
      }
      if (Get.isRegistered<WalkieChannelController>()) {
        Get.find<WalkieChannelController>().subscribeChannelUpdates();
      }
    });

    socket!.onDisconnect((_) async {
      _log('⚠️ Socket disconnected');
      _listenersBound = false;
      _stopPing();
      _notifyConnectionState(false);

      if (_isTalking) {
        _isTalking = false;
        await _enableMic(false);
        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>().forceUnlockAndReset();
        }
      }

      _offeredTo.clear();
      _makingOffer.clear();
      for (final id in _peers.keys.toList()) {
        await _closePeer(id);
      }
    });

    socket!.onConnectError((e) => _log('connect_error: $e'));
    socket!.onError((e) => _log('error: $e'));
  }

  int? _lastPingTime;
  int _lastLatencyMs = 0;

  void _notifyConnectionState(bool connected) {
    if (Get.isRegistered<GroupWalkieController>()) {
      final c = Get.find<GroupWalkieController>();
      c.setConnected(connected);
      if (!connected) {
        c.updateNetworkQuality(WalkieNetworkQuality.disconnected, 0);
      } else {
        c.updateNetworkQuality(WalkieNetworkQuality.good, _lastLatencyMs > 0 ? _lastLatencyMs : 60);
      }
    }
  }

  void _startPing() {
    _stopPing();
    _lastPingTime = DateTime.now().millisecondsSinceEpoch;
    socket?.emit('ping_walkie', {'t': _lastPingTime});

    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isDisposed || socket?.connected != true) return;
      _lastPingTime = DateTime.now().millisecondsSinceEpoch;
      socket?.emit('ping_walkie', {'t': _lastPingTime});
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _updateLatency(int ms) {
    if (_isDisposed) return;
    _lastLatencyMs = ms;
    final WalkieNetworkQuality quality;
    if (ms < 150) {
      quality = WalkieNetworkQuality.strong;
    } else if (ms < 300) {
      quality = WalkieNetworkQuality.good;
    } else if (ms < 600) {
      quality = WalkieNetworkQuality.fair;
    } else {
      quality = WalkieNetworkQuality.weak;
    }
    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().updateNetworkQuality(quality, ms);
    }
  }

  Future<WalkieMicPermissionState> checkMicPermissionSilently() async {
    try {
      final status = await Permission.microphone.status;
      _hasMicPermission = status.isGranted;
      final WalkieMicPermissionState state;
      if (status.isGranted) {
        state = WalkieMicPermissionState.granted;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        state = WalkieMicPermissionState.permanentlyDenied;
      } else {
        state = WalkieMicPermissionState.denied;
      }

      if (Get.isRegistered<GroupWalkieController>()) {
        final ctrl = Get.find<GroupWalkieController>();
        ctrl.setMicPermissionState(state);
        ctrl.setMicPermission(status.isGranted);
      }
      return state;
    } catch (e) {
      _log('checkMicPermissionSilently error: $e');
      return WalkieMicPermissionState.denied;
    }
  }

  Future<bool> requestMicPermissionUserInitiated() async {
    try {
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>()
            .setMicPermissionState(WalkieMicPermissionState.checking);
      }

      var status = await Permission.microphone.status;
      if (status.isGranted) {
        _hasMicPermission = true;
        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>()
            ..setMicPermissionState(WalkieMicPermissionState.granted)
            ..setMicPermission(true);
        }
        final ok = await _ensureLocalStream();
        if (ok) await _attachLocalTrackToExistingPeers();
        return ok;
      }

      status = await Permission.microphone.request();
      _hasMicPermission = status.isGranted;

      // On iOS: If permission_handler did not grant, invoke native WebRTC getUserMedia
      // which directly calls AVAudioSession.requestRecordPermission
      if (!_hasMicPermission && Platform.isIOS) {
        _log('Triggering iOS native AVAudioSession record permission via getUserMedia...');
        try {
          final mediaConstraints = <String, dynamic>{
            'audio': {
              'echoCancellation': true,
              'noiseSuppression': true,
              'autoGainControl': true,
            },
            'video': false,
          };
          final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
          if (stream.getAudioTracks().isNotEmpty) {
            _localStream = stream;
            for (final t in stream.getAudioTracks()) {
              t.enabled = false;
            }
            await _setMicMuteHelper(true);
            _hasMicPermission = true;
            status = PermissionStatus.granted;
            _log('✅ iOS native getUserMedia granted mic permission!');
          }
        } catch (webrtcErr) {
          _log('iOS native WebRTC mic prompt error / user denied: $webrtcErr');
        }
      }

      if (Get.isRegistered<GroupWalkieController>()) {
        final ctrl = Get.find<GroupWalkieController>();
        if (_hasMicPermission || status.isGranted) {
          ctrl.setMicPermissionState(WalkieMicPermissionState.granted);
          ctrl.setMicPermission(true);
        } else if (status.isPermanentlyDenied || status.isRestricted) {
          ctrl.setMicPermissionState(WalkieMicPermissionState.permanentlyDenied);
          ctrl.setMicPermission(false);
        } else {
          ctrl.setMicPermissionState(WalkieMicPermissionState.denied);
          ctrl.setMicPermission(false);
        }
      }

      if (_hasMicPermission) {
        final ok = await _ensureLocalStream();
        if (ok) {
          await _attachLocalTrackToExistingPeers();
        }
        return ok;
      }
      return false;
    } catch (e) {
      _log('requestMicPermissionUserInitiated error: $e');
      return false;
    }
  }

  Future<bool> ensureLocalStreamAndAttach() async {
    final ok = await _ensureLocalStream();
    if (ok) {
      await _attachLocalTrackToExistingPeers();
    }
    return ok;
  }

  Future<bool> _requestMicPermission() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }
      _hasMicPermission = status.isGranted;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setMicPermission(_hasMicPermission);
        Get.find<GroupWalkieController>().setMicPermissionState(
          _hasMicPermission
              ? WalkieMicPermissionState.granted
              : WalkieMicPermissionState.denied,
        );
      }
      return _hasMicPermission;
    } catch (e) {
      _log('mic permission error: $e');
      return false;
    }
  }

  bool _isBluetoothLabel(String label, String id) {
    final l = label.toLowerCase().trim();
    final i = id.toLowerCase().trim();
    if (l.isEmpty && i.isEmpty) return false;

    return l.contains('bluetooth') ||
        l.contains('airpods') ||
        l.contains('beats') ||
        l.contains('buds') ||
        l.contains('galaxy buds') ||
        l.contains('hands-free') ||
        l.contains('handsfree') ||
        l.contains('headset bt') ||
        l.contains('hfp') ||
        l.contains('a2dp') ||
        l.contains('le audio') ||
        i.contains('bluetooth') ||
        i.contains('airpods') ||
        i.contains('btheadset') ||
        i.contains('bt_a2dp') ||
        i.contains('a2dp') ||
        i.contains('hfp') ||
        i.contains('sco') ||
        i == 'bluetooth';
  }

  bool _isWiredLabel(String label, String id) {
    final l = label.toLowerCase().trim();
    final i = id.toLowerCase().trim();
    if (l.isEmpty && i.isEmpty) return false;

    if (_isBluetoothLabel(label, id)) return false;

    if (l.contains('receiver') ||
        l.contains('earpiece') ||
        l.contains('handset') ||
        l.contains('built-in') ||
        l.contains('speaker') ||
        i == 'earpiece' ||
        i == 'speaker' ||
        i.contains('receiver') ||
        i.contains('builtin') ||
        i.contains('built-in')) {
      return false;
    }

    if (i == 'wired-headset' ||
        i == 'wired_headset' ||
        i == 'headphones' ||
        i == 'wired' ||
        i.contains('usb')) {
      return true;
    }
    if (l.contains('earpods')) return true;
    if (l.contains('wired')) return true;
    if (l == 'headphones' || l.contains('headphones')) return true;
    if (l.contains('headphone') && !l.contains('microphone')) return true;
    if (l.contains('headset')) return true;
    if (l.contains('usb-c') || l.contains('type-c') || l.contains('lightning')) {
      return true;
    }

    return false;
  }

  Future<void> _checkAudioDevices({bool isInitial = false}) async {
    if (_isDisposed || _isCheckingDevices) return;
    _isCheckingDevices = true;

    try {
      bool isBtFound = false;
      bool isWiredFound = false;
      String btName = 'Bluetooth';
      String headsetName = 'Headset';

      // 1. WebRTC device enumeration
      try {
        final webrtcDevices = await navigator.mediaDevices.enumerateDevices();
        for (final d in webrtcDevices) {
          final kind = (d.kind ?? '').toLowerCase();
          final id = d.deviceId.toLowerCase();
          final label = d.label.trim();

          final isInput = kind.contains('audioinput');
          final isOutput = kind.contains('audiooutput');

          if (_isBluetoothLabel(label, id)) {
            isBtFound = true;
            if (isOutput && d.deviceId.isNotEmpty) {
              _bluetoothDeviceId = d.deviceId;
            }
            if (isInput && d.deviceId.isNotEmpty) {
              _bluetoothInputDeviceId = d.deviceId;
            }
            if (label.isNotEmpty &&
                !label.toLowerCase().contains('unknown') &&
                btName == 'Bluetooth') {
              btName = label;
            }
          } else if (_isWiredLabel(label, id)) {
            isWiredFound = true;
            if (isOutput && d.deviceId.isNotEmpty) {
              _wiredDeviceId = d.deviceId;
            }
            if (isInput && d.deviceId.isNotEmpty) {
              _wiredInputDeviceId = d.deviceId;
            }
            if (label.isNotEmpty &&
                !label.toLowerCase().contains('unknown') &&
                headsetName == 'Headset') {
              headsetName = label;
            }
          } else if (isOutput) {
            if (id == 'speaker' ||
                id.contains('speaker') ||
                label.toLowerCase().contains('speaker')) {
              _speakerDeviceId = d.deviceId;
            } else if (id == 'earpiece' ||
                id.contains('receiver') ||
                label.toLowerCase().contains('earpiece')) {
              _earpieceDeviceId = d.deviceId;
            }
          }
        }
      } catch (e) {
        _log('WebRTC enumerateDevices error: $e');
      }

      // 2. AudioSession device enumeration
      try {
        final session = await AudioSession.instance;
        final audioSessionDevices = await session.getDevices();
        for (final d in audioSessionDevices) {
          if (d.type == AudioDeviceType.bluetoothA2dp ||
              d.type == AudioDeviceType.bluetoothSco ||
              d.type == AudioDeviceType.bluetoothLe) {
            isBtFound = true;
            if (d.name.trim().isNotEmpty && btName == 'Bluetooth') {
              btName = d.name.trim();
            }
          } else if (d.type == AudioDeviceType.wiredHeadset ||
              d.type == AudioDeviceType.wiredHeadphones ||
              d.type == AudioDeviceType.usbAudio) {
            isWiredFound = true;
            if (d.name.trim().isNotEmpty && headsetName == 'Headset') {
              headsetName = d.name.trim();
            }
          }
        }
      } catch (e) {
        _log('AudioSession getDevices error: $e');
      }

      final prevBT = hasBluetoothDevice.value;
      final prevHS = hasHeadsetDevice.value;

      hasBluetoothDevice.value = isBtFound;
      bluetoothDeviceName.value = btName;
      hasHeadsetDevice.value = isWiredFound;
      headsetDeviceName.value = headsetName;

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().updateAvailableRoutes(
          hasBt: isBtFound,
          btName: btName,
          hasHeadset: isWiredFound,
          headsetName: headsetName,
        );
      }

      if (isInitial) {
        if (isBtFound) {
          await setAudioRoute(WalkieAudioRoute.bluetooth);
        } else if (isWiredFound) {
          await setAudioRoute(WalkieAudioRoute.headset);
        } else {
          await setAudioRoute(WalkieAudioRoute.speaker);
        }
        return;
      }

      // Edge triggers
      final btPlugged = isBtFound && !prevBT;
      final wiredPlugged = isWiredFound && !prevHS;
      final btUnplugged = !isBtFound && prevBT;
      final wiredUnplugged = !isWiredFound && prevHS;

      if (btPlugged) {
        _log('🎧 BT device plugged ($btName) -> auto-switching to bluetooth');
        await setAudioRoute(WalkieAudioRoute.bluetooth);
      } else if (wiredPlugged) {
        _log('🎧 Wired device plugged ($headsetName) -> auto-switching to headset');
        await setAudioRoute(WalkieAudioRoute.headset);
      } else if (btUnplugged && audioRoute.value == WalkieAudioRoute.bluetooth) {
        _log('🎧 BT device unplugged -> switching to ${isWiredFound ? "headset" : "speaker"}');
        await setAudioRoute(
          isWiredFound ? WalkieAudioRoute.headset : WalkieAudioRoute.speaker,
        );
      } else if (wiredUnplugged &&
          audioRoute.value == WalkieAudioRoute.headset) {
        _log('🎧 Wired device unplugged -> switching to ${isBtFound ? "bluetooth" : "speaker"}');
        await setAudioRoute(
          isBtFound ? WalkieAudioRoute.bluetooth : WalkieAudioRoute.speaker,
        );
      }
    } catch (e) {
      _log('❌ _checkAudioDevices: $e');
    } finally {
      _isCheckingDevices = false;
    }
  }

  Future<void> _configureAudioSession({WalkieAudioRoute? route}) async {
    if (_isDisposed) return;
    final targetRoute = route ?? audioRoute.value;
    try {
      final session = await AudioSession.instance;

      if (Platform.isIOS) {
        final isSpeaker = targetRoute == WalkieAudioRoute.speaker;
        final options = isSpeaker
            ? (AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.allowBluetoothA2dp |
                AVAudioSessionCategoryOptions.allowAirPlay |
                AVAudioSessionCategoryOptions.defaultToSpeaker)
            : (AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.allowBluetoothA2dp |
                AVAudioSessionCategoryOptions.allowAirPlay);

        await session.configure(
          AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionMode: AVAudioSessionMode.voiceChat,
            avAudioSessionCategoryOptions: options,
          ),
        );
      } else {
        await session.configure(
          const AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionMode: AVAudioSessionMode.voiceChat,
            androidAudioAttributes: AndroidAudioAttributes(
              usage: AndroidAudioUsage.voiceCommunication,
              contentType: AndroidAudioContentType.speech,
            ),
            androidAudioFocusGainType:
                AndroidAudioFocusGainType.gainTransientMayDuck,
          ),
        );
      }

      await session.setActive(true);
      _isSpeakerOn = targetRoute == WalkieAudioRoute.speaker;
      _audioSessionReady = true;

      _log('🎧 AudioSession configured for route=$targetRoute');
    } catch (e) {
      _log('❌ AudioSession configure error: $e');
    }
  }

  Future<void> _applyCurrentAudioRoute() async {
    final route = audioRoute.value;
    try {
      if (Platform.isAndroid) {
        final am = AndroidAudioManager();
        try {
          await am.setMode(AndroidAudioHardwareMode.inCommunication);
        } catch (_) {}

        switch (route) {
          case WalkieAudioRoute.speaker:
            try {
              await am.stopBluetoothSco();
              await am.setBluetoothScoOn(false);
            } catch (_) {}
            try {
              await am.setSpeakerphoneOn(true);
              await Helper.setSpeakerphoneOn(true);
              await Helper.selectAudioOutput('speaker');
            } catch (_) {}
            try {
              await ProximityScreenLock.setActive(false);
            } catch (_) {}
            break;

          case WalkieAudioRoute.bluetooth:
            try {
              await am.setSpeakerphoneOn(false);
              await Helper.setSpeakerphoneOn(false);
            } catch (_) {}
            try {
              await am.startBluetoothSco();
              await Future.delayed(const Duration(milliseconds: 100));
              await am.setBluetoothScoOn(true);
            } catch (_) {}
            try {
              await Helper.selectAudioOutput('bluetooth');
            } catch (_) {}
            try {
              await Helper.selectAudioInput('bluetooth');
            } catch (_) {}
            try {
              await ProximityScreenLock.setActive(false);
            } catch (_) {}
            break;

          case WalkieAudioRoute.headset:
            try {
              await am.stopBluetoothSco();
              await am.setBluetoothScoOn(false);
            } catch (_) {}
            try {
              await am.setSpeakerphoneOn(false);
              await Helper.setSpeakerphoneOn(false);
              await Helper.selectAudioOutput('wired-headset');
            } catch (_) {}
            try {
              await ProximityScreenLock.setActive(false);
            } catch (_) {}
            break;

          case WalkieAudioRoute.earpiece:
            try {
              await am.stopBluetoothSco();
              await am.setBluetoothScoOn(false);
            } catch (_) {}
            try {
              await am.setSpeakerphoneOn(false);
              await Helper.setSpeakerphoneOn(false);
              await Helper.selectAudioOutput('earpiece');
            } catch (_) {}
            try {
              await ProximityScreenLock.setActive(true);
            } catch (_) {}
            break;
        }
      } else if (Platform.isIOS) {
        switch (route) {
          case WalkieAudioRoute.speaker:
            try {
              await Helper.setSpeakerphoneOn(true);
            } catch (_) {}
            try {
              if (_speakerDeviceId != null &&
                  _speakerDeviceId!.isNotEmpty &&
                  _speakerDeviceId != 'speaker') {
                await Helper.selectAudioOutput(_speakerDeviceId!);
              }
            } catch (_) {}
            try {
              await ProximityScreenLock.setActive(false);
            } catch (_) {}
            break;

          case WalkieAudioRoute.bluetooth:
            try {
              await Helper.setSpeakerphoneOnButPreferBluetooth();
            } catch (_) {
              try {
                await Helper.setSpeakerphoneOn(false);
              } catch (_) {}
            }
            try {
              await Helper.selectAudioOutput(
                _bluetoothDeviceId ?? 'bluetooth',
              );
            } catch (_) {}
            if (_bluetoothInputDeviceId != null) {
              try {
                await Helper.selectAudioInput(_bluetoothInputDeviceId!);
              } catch (_) {}
            }
            try {
              await ProximityScreenLock.setActive(false);
            } catch (_) {}
            break;

          case WalkieAudioRoute.headset:
            try {
              await Helper.setSpeakerphoneOn(false);
              await Helper.selectAudioOutput(
                _wiredDeviceId ?? 'wired-headset',
              );
            } catch (_) {}
            if (_wiredInputDeviceId != null) {
              try {
                await Helper.selectAudioInput(_wiredInputDeviceId!);
              } catch (_) {}
            }
            try {
              await ProximityScreenLock.setActive(false);
            } catch (_) {}
            break;

          case WalkieAudioRoute.earpiece:
            try {
              await Helper.setSpeakerphoneOn(false);
              await Helper.selectAudioOutput(_earpieceDeviceId ?? 'earpiece');
            } catch (_) {}
            try {
              await ProximityScreenLock.setActive(true);
            } catch (_) {}
            break;
        }
      }
    } catch (e) {
      _log('❌ _applyCurrentAudioRoute error: $e');
    }
  }

  Future<void> _ensurePlaybackPath({bool forceSession = false}) async {
    if (_isDisposed) return;
    try {
      if (forceSession || !_audioSessionReady) {
        await _configureAudioSession(route: audioRoute.value);
      } else {
        try {
          final session = await AudioSession.instance;
          await session.setActive(true);
        } catch (_) {}
      }

      await _applyCurrentAudioRoute();

      for (final stream in _remoteStreams.values) {
        for (final track in stream.getAudioTracks()) {
          try {
            track.enabled = true;
            track.enableSpeakerphone(
              audioRoute.value == WalkieAudioRoute.speaker,
            );
          } catch (_) {}
        }
      }

      _log(
        '🔊 Playback path ensured route=${audioRoute.value} speaker=$_isSpeakerOn '
        'peers=${_peers.length} remoteStreams=${_remoteStreams.length}',
      );
    } catch (e) {
      _log('❌ _ensurePlaybackPath: $e');
    }
  }

  Future<void> _listenAudioDevices() async {
    try {
      final session = await AudioSession.instance;
      await _devicesSub?.cancel();
      _devicesSub = session.devicesStream.listen((_) => _checkAudioDevices());

      await _interruptionSub?.cancel();
      _interruptionSub = session.interruptionEventStream.listen((event) async {
        _log('🔔 Audio interruption event: begin=${event.begin} type=${event.type}');
        if (event.begin) {
          if (_isTalking) {
            _isTalking = false;
            await _enableMic(false);
            if (Get.isRegistered<GroupWalkieController>()) {
              Get.find<GroupWalkieController>().forceUnlockAndReset();
            }
            if (_currentGroupId != null) {
              final payload = {
                'groupId': _currentGroupId,
                'userId': _selfUserId,
              };
              socket?.emit('ptt_release', payload);
              socket?.emit('walkie_speaker_stopped', payload);
            }
          }
        } else {
          await _configureAudioSession(route: audioRoute.value);
          await _ensurePlaybackPath(forceSession: true);
        }
      });

      await _checkAudioDevices(isInitial: true);
    } catch (e) {
      _log('❌ _listenAudioDevices error: $e');
    }
  }

  void ensureSocketListenersBound() {
    _listenersBound = false;
    _bindSocketListeners();
  }

  void _bindSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    for (final e in [
      'walkie_invite',
      'walkie_existing_peers',
      'walkie_peer_joined',
      'walkie_peer_left',
      'walkie_webrtc_offer',
      'walkie_webrtc_answer',
      'walkie_webrtc_ice',
      'ptt_granted',
      'ptt_denied',
      'ptt_release',
      'walkie_speaker_active',
      'walkie_speaker_stopped',
      'walkie_participants_update',
      'walkie_channel_locked',
      'walkie_error',
      'force_logout',
      'exit_group_success',
      'pong_walkie',
      'walkie_mute_status_changed',
      'walkie_toggle_mute',
      'walkie_user_muted',
      'walkie_peer_muted',
      'walkie_mute_status',
      'user_mute_status',
      'walkie_invite_declined',
      'walkie_invite_rejected',
      'walkie_invite_cancelled',
      'walkie_peer_declined',
      'walkie_channel_speaker_update',
    ]) {
      socket?.off(e);
    }

    socket?.on('walkie_channel_speaker_update', (data) {
      if (data == null) return;
      if (Get.isRegistered<WalkieChannelController>()) {
        Get.find<WalkieChannelController>().onChannelSpeakerUpdateFromSocket(data);
      }
    });

    socket?.on('walkie_invite', (data) {
      if (data == null) return;
      if (Get.isRegistered<WalkieChannelController>()) {
        Get.find<WalkieChannelController>().onSpeakerActiveFromSocket(data);
      }
      final rawJoinedCount = data['joinedMemberCount'] ??
          data['joinedCount'] ??
          data['activeMemberCount'] ??
          data['totalJoinedMembers'] ??
          data['membersJoined'];
      final int? joinedCount = rawJoinedCount != null
          ? int.tryParse(rawJoinedCount.toString())
          : null;

      final speakerId = (data['speakerId'] ?? data['speaker_id'])?.toString();
      if (speakerId != null && _selfUserId != null && speakerId == _selfUserId) {
        return;
      }

      final inviteGroupId = (data['groupId'] ?? data['group_id'])?.toString();
      if (inviteGroupId != null &&
          _currentGroupId != null &&
          inviteGroupId == _currentGroupId) {
        return;
      }

      final isForeground =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

      if (isForeground) {
        WalkieInviteDialog.show(
          groupId: data['groupId']?.toString() ?? '',
          groupName: data['groupName']?.toString() ?? 'Group',
          speakerName: data['speakerName']?.toString() ?? 'Someone',
          speakerImage: data['speakerImage']?.toString() ?? '',
          joinedCount: joinedCount,
        );
      } else {
        firebaseNotificationServices.showWalkieNotification(
          groupId: data['groupId']?.toString() ?? '',
          groupName: data['groupName']?.toString() ?? 'Group',
          speakerName: data['speakerName']?.toString() ?? 'Someone',
          speakerImage: data['speakerImage']?.toString() ?? '',
          joinedCount: joinedCount,
          extraData: data is Map ? Map<String, dynamic>.from(data) : null,
        );
      }
    });

    socket?.on('force_logout', (_) async => dispose());

    socket?.on('walkie_existing_peers', (data) async {
      if (_isDisposed || data == null) return;
      _log('👥 walkie_existing_peers: $data');
      final peers = (data is Map
          ? (data['peers'] ?? data['participants'])
          : null) as List? ??
          (data is List ? data : []);

      final newParticipants = <WalkieParticipant>[];
      final candidatePeerIds = <String>[];

      for (final p in peers) {
        var id = '';
        var name = 'User';
        var image = '';
        bool isMuted = false;
        if (p is Map) {
          id = p['userId']?.toString() ?? p['id']?.toString() ?? '';
          name = p['name']?.toString() ?? 'User';
          image =
              p['image']?.toString() ?? p['profileImage']?.toString() ?? '';
          isMuted = (p['isMuted'] ?? p['muted'] ?? p['is_muted']) == true;
        } else {
          id = p.toString();
        }
        if (id.isEmpty || id == _selfUserId) continue;

        newParticipants.add(
          WalkieParticipant(
            userId: id,
            name: name,
            image: image,
            isMuted: isMuted,
            isSpeaking: false,
            isListening: true,
            hasExplicitMute: p is Map &&
                (p.containsKey('isMuted') ||
                    p.containsKey('muted') ||
                    p.containsKey('is_muted')),
          ),
        );

        if (!_offeredTo.contains(id)) {
          candidatePeerIds.add(id);
        }
      }

      // 1. Immediately update UI with all participants in one reactive batch
      if (Get.isRegistered<GroupWalkieController>() && newParticipants.isNotEmpty) {
        Get.find<GroupWalkieController>().addOrUpdateParticipantsBatch(newParticipants);
      }

      // 2. Identify active speaker if present and prioritize
      String? activeSpeakerId;
      if (data is Map) {
        final activeSpeaker = data['activeSpeaker'] ??
            data['currentSpeaker'] ??
            data['speaker'];
        activeSpeakerId = (data['activeSpeakerId'] ??
                data['speakerId'] ??
                (activeSpeaker is Map ? activeSpeaker['userId'] : null))
            ?.toString();
        if (activeSpeakerId != null &&
            activeSpeakerId.isNotEmpty &&
            activeSpeakerId != _selfUserId) {
          final speakerName = (data['speakerName'] ??
                  (activeSpeaker is Map ? activeSpeaker['name'] : null) ??
                  'Someone')
              .toString();
          final speakerImage = (data['speakerImage'] ??
                  (activeSpeaker is Map ? activeSpeaker['image'] : null) ??
                  '')
              .toString();
          if (Get.isRegistered<GroupWalkieController>()) {
            Get.find<GroupWalkieController>().onSpeakerActive(
              speakerId: activeSpeakerId,
              speakerName: speakerName,
              speakerImage: speakerImage,
            );
          }
        }
      }

      // 3. Stagger WebRTC connection creations to prevent iOS thread/FD exhaustion (up to 100 users)
      if (candidatePeerIds.isNotEmpty) {
        _queuePeerOffers(candidatePeerIds, prioritizeUserId: activeSpeakerId);
      }
    });

    socket?.on('walkie_peer_joined', (data) async {
      if (_isDisposed || data == null) return;
      _log('👋 walkie_peer_joined: $data');
      var id = '';
      var name = 'User';
      var image = '';
      bool isMuted = false;
      if (data is Map) {
        id = data['userId']?.toString() ?? data['id']?.toString() ?? '';
        name = data['name']?.toString() ?? 'User';
        image =
            data['image']?.toString() ?? data['profileImage']?.toString() ?? '';
        isMuted = (data['isMuted'] ?? data['muted'] ?? data['is_muted']) == true;
      } else {
        id = data.toString();
      }
      if (id.isEmpty || id == _selfUserId) return;

      if (Get.isRegistered<GroupWalkieController>()) {
        final c = Get.find<GroupWalkieController>();
        c.addOrUpdateParticipant(
          WalkieParticipant(
            userId: id,
            name: name,
            image: image,
            isMuted: isMuted,
            isSpeaking: false,
            isListening: true,
            hasExplicitMute: data is Map &&
                (data.containsKey('isMuted') ||
                    data.containsKey('muted') ||
                    data.containsKey('is_muted')),
          ),
        );
        c.showStatusMessage("$name joined", const Color(0xFF00C853));
      }

      // Close previous stale peer connection if re-joining
      if (_peers.containsKey(id)) {
        _log('Closing previous stale peer for newly joined peer: $id');
        await _closePeer(id);
      }
      _offeredTo.remove(id);
      _makingOffer.remove(id);

      // Prepare peer connection and await offer from the joining peer
      // (avoids simultaneous offer collision/glare that delays connection by 5-10s)
      await _createPeer(id);
    });

    socket?.on('walkie_peer_left', (data) async {
      if (_isDisposed || data == null) return;
      final id = data is Map
          ? (data['userId'] ?? data['id'])?.toString()
          : data.toString();
      if (id == null || id.isEmpty) return;
      if (id == _selfUserId) return;

      String name = 'A member';
      if (data is Map && (data['name'] != null || data['userName'] != null)) {
        name = (data['name'] ?? data['userName']).toString();
      } else if (Get.isRegistered<GroupWalkieController>()) {
        final existing = Get.find<GroupWalkieController>()
            .participants
            .firstWhereOrNull((p) => p.userId == id);
        if (existing != null && existing.name.isNotEmpty) {
          name = existing.name;
        }
      }

      if (Get.isRegistered<GroupWalkieController>()) {
        final c = Get.find<GroupWalkieController>();
        c.removeParticipant(id);
        c.showStatusMessage("$name left", Colors.orange.shade800);
      }
      await _closePeer(id);
    });

    for (final eventName in [
      'walkie_invite_declined',
      'walkie_invite_rejected',
      'walkie_invite_cancelled',
      'walkie_peer_declined',
    ]) {
      socket?.on(eventName, (data) {
        if (_isDisposed || data == null) return;
        final id = data is Map ? (data['userId'] ?? data['id'])?.toString() : null;
        if (id != null && id == _selfUserId) return;

        String name = 'A member';
        if (data is Map && (data['name'] != null || data['userName'] != null)) {
          name = (data['name'] ?? data['userName']).toString();
        }

        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>()
              .showStatusMessage("$name cancelled", const Color(0xFFFF5252));
        }
      });
    }

    socket?.on('walkie_webrtc_offer', (data) async {
      if (_isDisposed || data == null) return;
      final from = data['fromUserId']?.toString();
      final sdp = data['sdp'];
      if (from == null || sdp == null) return;
      await _handleOffer(from, sdp);
    });

    socket?.on('walkie_webrtc_answer', (data) async {
      if (_isDisposed || data == null) return;
      final from = data['fromUserId']?.toString();
      final sdp = data['sdp'];
      if (from == null || sdp == null) return;
      await _handleAnswer(from, sdp);
    });

    socket?.on('walkie_webrtc_ice', (data) async {
      if (_isDisposed || data == null) return;
      final from = data['fromUserId']?.toString();
      final ice = data['iceCandidate'] ?? data['candidate'];
      if (from == null || ice == null) return;
      await _handleIce(from, ice);
    });

    socket?.on('ptt_granted', (_) async {
      if (_isDisposed) return;
      _log('✅ PTT_GRANTED');

      if (Get.isRegistered<GroupWalkieController>()) {
        final c = Get.find<GroupWalkieController>();
        if (!c.isPressed.value && !c.isSelfLocked.value) {
          _log('PTT_GRANTED cancelled — finger already up');
          _isTalking = false;
          await _enableMic(false);
          socket?.emit('ptt_release', {'groupId': _currentGroupId});
          c.stopTalking();
          return;
        }
      }

      await _enableMic(true);

      _logPeerSnapshot('after PTT_GRANTED');

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().startTalking();
      }
    });

    socket?.on('ptt_denied', (data) async {
      if (_isDisposed) return;
      _isTalking = false;
      await _enableMic(false);
      if (!Get.isRegistered<GroupWalkieController>()) return;

      final c = Get.find<GroupWalkieController>();
      c.forceUnlockAndReset();
      final reason = (data is Map
          ? (data['reason'] ?? data['error'] ?? data['message'])
          : data)
          ?.toString()
          .toUpperCase() ??
          '';
      _log('⚠️ PTT denied: $reason | $data');

      if (reason == 'BUSY') {
        c.showBusyMessage(data is Map
            ? data['speakerName']?.toString() ?? 'Someone'
            : 'Someone');
      } else if (reason == 'LOCKED') {
        c.showLockedMessage();
      } else if (reason.contains('NO_SEAT') ||
          reason.contains('NOT_ASSIGNED') ||
          reason.contains('UNASSIGNED') ||
          reason.contains('NO_VOICE')) {
        c.showNoVoiceSeatMessage();
      } else if (reason.contains('PLAN') ||
          reason.contains('SUBSCRIB') ||
          reason.contains('EXPIRED') ||
          reason.contains('TRIAL') ||
          reason.contains('UNAUTHORIZED')) {
        c.showTrialEndedMessage();
      } else if (reason.isNotEmpty) {
        c.showGenericErrorMessage(data is Map && data['message'] != null
            ? data['message'].toString()
            : 'Cannot speak on this channel');
      } else {
        c.showGenericErrorMessage('Voice transmission not permitted');
      }
    });

    socket?.on('walkie_speaker_active', (data) async {
      if (_isDisposed || data == null) return;
      if (Get.isRegistered<WalkieChannelController>()) {
        Get.find<WalkieChannelController>().onSpeakerActiveFromSocket(data);
      }
      final gId = data is Map ? data['groupId']?.toString() : null;
      if (gId != null &&
          _currentGroupId != null &&
          gId != _currentGroupId) {
        return;
      }

      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerActive(
          speakerId: data['speakerId']?.toString() ?? '',
          speakerName: data['speakerName']?.toString() ?? 'User',
          speakerImage: data['speakerImage']?.toString() ?? '',
        );
      }
    });

    socket?.on('ptt_release', (data) {
      if (_isDisposed) return;
      if (Get.isRegistered<WalkieChannelController>()) {
        Get.find<WalkieChannelController>().onSpeakerStoppedFromSocket(data);
      }
      final gId = data is Map ? data['groupId']?.toString() : null;
      if (gId != null &&
          _currentGroupId != null &&
          gId != _currentGroupId) {
        return;
      }
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }
    });

    socket?.on('walkie_speaker_stopped', (data) {
      if (_isDisposed) return;
      if (Get.isRegistered<WalkieChannelController>()) {
        Get.find<WalkieChannelController>().onSpeakerStoppedFromSocket(data);
      }
      final gId = data is Map ? data['groupId']?.toString() : null;
      if (gId != null &&
          _currentGroupId != null &&
          gId != _currentGroupId) {
        return;
      }
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().onSpeakerStopped();
      }
    });

    socket?.on('walkie_participants_update', (data) {
      if (_isDisposed || data == null) return;
      if (!Get.isRegistered<GroupWalkieController>()) return;
      final listRaw = (data['participants'] as List? ?? []);
      final list = listRaw
          .map((p) =>
          WalkieParticipant.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
      Get.find<GroupWalkieController>().updateParticipants(
        list,
        activeSpeaker: data['activeSpeaker']?.toString(),
      );
    });

    socket?.on('walkie_channel_locked', (data) {
      if (_isDisposed || data == null) return;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>()
            .onChannelLocked(isLocked: data['isLocked'] == true);
      }
    });

    socket?.on('pong_walkie', (data) {
      if (_isDisposed) return;
      int rtt = 60;
      if (_lastPingTime != null) {
        rtt = (DateTime.now().millisecondsSinceEpoch - _lastPingTime!).clamp(1, 9999);
      } else if (data is Map && data['t'] != null) {
        final sent = int.tryParse(data['t'].toString());
        if (sent != null) {
          rtt = (DateTime.now().millisecondsSinceEpoch - sent).clamp(1, 9999);
        }
      }
      _updateLatency(rtt);
    });

    for (final eventName in [
      'walkie_mute_status_changed',
      'walkie_toggle_mute',
      'walkie_user_muted',
      'walkie_peer_muted',
      'walkie_mute_status',
      'user_mute_status',
    ]) {
      socket?.on(eventName, (data) {
        if (_isDisposed || data == null) return;
        _log('🔇 Mute event received on $eventName: $data');
        String? targetUserId;
        bool isMuted = true;
        if (data is Map) {
          targetUserId = (data['userId'] ?? data['id'] ?? data['user_id'] ?? data['fromUserId'])?.toString();
          isMuted = (data['isMuted'] ?? data['muted'] ?? data['is_muted'] ?? true) == true;
        } else if (data is String) {
          targetUserId = data;
        }
        if (targetUserId != null && targetUserId.isNotEmpty) {
          if (Get.isRegistered<GroupWalkieController>()) {
            Get.find<GroupWalkieController>().setParticipantMuted(targetUserId, isMuted);
          }
        }
      });
    }

    socket?.on('walkie_error', (data) {
      if (_isDisposed || data == null) return;
      final msg = data is Map
          ? (data['message'] ?? data['error'] ?? 'Walkie Talkie Error')
          .toString()
          : data.toString();
      _log('❌ walkie_error: $msg');
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().showGenericErrorMessage(msg);
      }
    });
  }

  void _logPeerSnapshot(String tag) {
    _log(
      '🩺 $tag | peers=${_peers.length} remoteStreams=${_remoteStreams.length} '
          'talking=$_isTalking muted=$_isMuted localStream=${_localStream != null}',
    );
    _peers.forEach((id, pc) {
      _log(
        '🩺   peer=$id conn=${pc.connectionState} ice=${pc.iceConnectionState} '
            'sig=${pc.signalingState}',
      );
    });
  }

  Future<bool> _ensureLocalStream() async {
    if (_localStream != null) return true;
    if (_streamCompleter != null) return _streamCompleter!.future;

    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      _hasMicPermission = false;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setMicPermission(false);
      }
      return false;
    }

    _streamCompleter = Completer<bool>();

    try {
      await _configureAudioSession(route: audioRoute.value);

      _log('Acquiring getUserMedia...');

      final mediaConstraints = <String, dynamic>{
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      };

      _localStream =
      await navigator.mediaDevices.getUserMedia(mediaConstraints);

      final bool shouldEnable = _isTalking && !_isMuted;
      for (final t in _localStream!.getAudioTracks()) {
        t.enabled = shouldEnable;
      }
      await _setMicMuteHelper(!shouldEnable);

      _hasMicPermission = true;
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().setMicPermission(true);
        Get.find<GroupWalkieController>()
            .setMicPermissionState(WalkieMicPermissionState.granted);
      }

      _log('✅ local audio stream ready (warmed)');
      _streamCompleter!.complete(true);
      final result = await _streamCompleter!.future;
      _streamCompleter = null;
      await _attachLocalTrackToExistingPeers();
      return result;
    } catch (e) {
      _log('❌ getUserMedia failed: $e');
      _localStream = null;
      if (!(_streamCompleter?.isCompleted ?? true)) {
        _streamCompleter!.complete(false);
      }
      _streamCompleter = null;
      return false;
    }
  }

  Future<void> _attachLocalTrackToExistingPeers() async {
    if (_localStream == null) return;
    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isEmpty) return;
    final track = audioTracks.first;

    final futures = <Future>[];
    for (final entry in _peers.entries) {
      futures.add(() async {
        try {
          final pc = entry.value;
          final senders = await pc.getSenders();
          bool hasAudioSender = false;
          for (final s in senders) {
            if (s.track == null || s.track?.kind == 'audio') {
              await s.replaceTrack(track);
              s.track?.enabled = track.enabled;
              hasAudioSender = true;
            }
          }
          if (!hasAudioSender) {
            await pc.addTrack(track, _localStream!);
            _createOfferTo(entry.key);
          }
          _log('Attached local track to peer ${entry.key}');
        } catch (e) {
          _log('⚠️ attachLocalTrack ${entry.key}: $e');
        }
      }());
    }
    await Future.wait(futures);
  }

  Future<RTCPeerConnection?> _createPeer(String remoteUserId) async {
    if (_isDisposed) return null;

    if (_peers.containsKey(remoteUserId)) {
      final existing = _peers[remoteUserId]!;
      final st = existing.connectionState;
      if (st == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          st == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          st == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        await _closePeer(remoteUserId);
      } else {
        return existing;
      }
    }

    if (_hasMicPermission && _localStream == null) {
      await _ensureLocalStream();
    }

    final pc = await createPeerConnection(_rtcConfig);

    final bool shouldEnable = _isTalking && !_isMuted;
    if (_localStream != null) {
      for (final t in _localStream!.getAudioTracks()) {
        t.enabled = shouldEnable;
        await pc.addTrack(t, _localStream!);
        t.enabled = shouldEnable;
      }
    }

    pc.onTrack = (event) async {
      if (_isDisposed) return;
      if (event.track.kind != 'audio') return;

      try {
        event.track.enabled = true;
        event.track.enableSpeakerphone(_isSpeakerOn);
      } catch (_) {}

      _log('🎧 Remote AUDIO track from $remoteUserId');

      if (event.streams.isNotEmpty) {
        _remoteStreams[remoteUserId] = event.streams[0];
      } else {
        final stream = await createLocalMediaStream('remote_$remoteUserId');
        await stream.addTrack(event.track);
        _remoteStreams[remoteUserId] = stream;
      }
    };

    pc.onIceCandidate = (c) {
      if (_isDisposed) return;
      if (c.candidate == null || _currentGroupId == null) return;

      final cand = c.candidate!;
      if (cand.contains('.local') && cand.contains('typ host')) {
        _log('ICE host candidate -> $remoteUserId');
      }

      socket?.emit('walkie_webrtc_ice', {
        'groupId': _currentGroupId,
        'targetUserId': remoteUserId,
        'iceCandidate': {
          'id': c.sdpMid,
          'label': c.sdpMLineIndex,
          'candidate': c.candidate,
        },
      });
    };

    pc.onIceConnectionState = (state) async {
      _log('🧊 ICE $remoteUserId => $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        _log('🧊 ICE failed $remoteUserId — restartIce');
        try {
          await pc.restartIce();
        } catch (_) {}
      }
    };

    pc.onConnectionState = (state) async {
      _log('📡 Peer $remoteUserId state: $state');
      if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        await _closePeer(remoteUserId);
      }
    };

    _peers[remoteUserId] = pc;

    final pending = _pendingIce.remove(remoteUserId) ?? [];
    for (final ice in pending) {
      try {
        await pc.addCandidate(ice);
      } catch (_) {}
    }

    return pc;
  }

  Future<void> _queuePeerOffers(
    List<String> peerIds, {
    String? prioritizeUserId,
  }) async {
    if (_isDisposed || peerIds.isEmpty) return;

    final orderedIds = List<String>.from(peerIds);
    if (prioritizeUserId != null && orderedIds.contains(prioritizeUserId)) {
      orderedIds.remove(prioritizeUserId);
      orderedIds.insert(0, prioritizeUserId);
    }

    // Process in batches of 2 with 80ms interval to prevent iOS platform thread/socket starvation
    const batchSize = 2;
    for (int i = 0; i < orderedIds.length; i += batchSize) {
      if (_isDisposed) break;
      final batch = orderedIds.sublist(
        i,
        (i + batchSize > orderedIds.length) ? orderedIds.length : i + batchSize,
      );

      final futures = batch.map((id) async {
        if (_isDisposed) return;
        if (_offeredTo.contains(id)) return;
        _offeredTo.add(id);
        try {
          await _createPeer(id);
          await Future.delayed(const Duration(milliseconds: 40));
          if (!_isDisposed) {
            await _createOfferTo(id);
          }
        } catch (e) {
          _log('⚠️ Staggered peer creation error for $id: $e');
        }
      });

      await Future.wait(futures);
      if (i + batchSize < orderedIds.length && !_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 80));
      }
    }
  }

  Future<void> _createOfferTo(String remoteUserId) async {
    if (_isDisposed) return;
    if (remoteUserId == _selfUserId) return;
    if (_makingOffer.contains(remoteUserId)) return;

    _makingOffer.add(remoteUserId);
    try {
      final pc = await _createPeer(remoteUserId);
      if (pc == null) return;

      final signal = pc.signalingState;
      final conn = pc.connectionState;

      if (signal != null &&
          signal != RTCSignalingState.RTCSignalingStateStable) {
        return;
      }
      if (conn == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          conn == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await _closePeer(remoteUserId);
        return;
      }

      final offer = await pc.createOffer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });
      if (_peers[remoteUserId] != pc) return;

      await pc.setLocalDescription(offer);
      socket?.emit('walkie_webrtc_offer', {
        'groupId': _currentGroupId,
        'targetUserId': remoteUserId,
        'sdp': offer.toMap(),
      });
      _log('📤 offer -> $remoteUserId');
    } catch (e) {
      _log('❌ offer error $remoteUserId: $e');
    } finally {
      _makingOffer.remove(remoteUserId);
    }
  }

  Future<void> _handleOffer(String from, dynamic sdp) async {
    if (_isDisposed) return;
    try {
      final pc = await _createPeer(from);
      if (pc == null) return;

      if (pc.signalingState ==
          RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        final self = _selfUserId ?? '';
        if (self.compareTo(from) > 0) {
          _log('🤝 glare: ignore offer from $from (impolite)');
          return;
        }
        try {
          await pc.setLocalDescription(RTCSessionDescription('', 'rollback'));
        } catch (_) {}
      }

      if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
        return;
      }

      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );

      final answer = await pc.createAnswer({
        'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 0,
      });
      if (_peers[from] != pc) return;
      if (pc.signalingState == RTCSignalingState.RTCSignalingStateClosed) {
        return;
      }

      await pc.setLocalDescription(answer);
      socket?.emit('walkie_webrtc_answer', {
        'groupId': _currentGroupId,
        'targetUserId': from,
        'sdp': answer.toMap(),
      });
      _log('📥 answer -> $from');
    } catch (e) {
      _log('❌ handleOffer $from: $e');
    }
  }

  Future<void> _handleAnswer(String from, dynamic sdp) async {
    if (_isDisposed) return;
    final pc = _peers[from];
    if (pc == null) return;

    final state = pc.signalingState;
    if (state != null &&
        state != RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      return;
    }

    try {
      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
      _log('✅ answer applied from $from');
    } catch (e) {
      _log('❌ handleAnswer $from: $e');
    }
  }

  Future<void> _handleIce(String from, dynamic iceMap) async {
    if (_isDisposed) return;
    final candidate = iceMap['candidate'];
    final id = iceMap['id'] ?? iceMap['sdpMid'];
    final label = iceMap['label'] ?? iceMap['sdpMLineIndex'];

    final ice = RTCIceCandidate(
      candidate,
      id?.toString(),
      label is int ? label : int.tryParse(label?.toString() ?? ''),
    );

    final pc = _peers[from];
    if (pc == null) {
      _pendingIce.putIfAbsent(from, () => []).add(ice);
      return;
    }

    final remote = await pc.getRemoteDescription();
    if (remote == null) {
      _pendingIce.putIfAbsent(from, () => []).add(ice);
      return;
    }

    try {
      await pc.addCandidate(ice);
    } catch (_) {}
  }

  Future<void> _closePeer(String userId) async {
    final pc = _peers.remove(userId);
    _pendingIce.remove(userId);
    _makingOffer.remove(userId);
    _offeredTo.remove(userId);

    if (pc != null) {
      pc.onTrack = null;
      pc.onIceCandidate = null;
      pc.onConnectionState = null;
      pc.onIceConnectionState = null;
      pc.onIceGatheringState = null;
      pc.onSignalingState = null;
      try {
        await pc.close();
      } catch (_) {}
    }

    final s = _remoteStreams.remove(userId);
    try {
      s?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
  }

  Future<void> _enableMic(bool enabled) async {
    if (_localStream == null) return;
    final actual = enabled && !_isMuted && _isTalking;

    for (final t in _localStream!.getAudioTracks()) {
      t.enabled = actual;
    }

    await _setMicMuteHelper(!actual);

    _log('🎤 TX mic => $actual (requested=$enabled muted=$_isMuted talking=$_isTalking)');
  }

  Future<bool> joinGroup(String groupId) async {
    _isDisposed = false;
    _currentGroupId = groupId;
    _offeredTo.clear();
    ensureSocketListenersBound();
    _log('Joining group $groupId');

    final savedUserId =
        _selfUserId ?? Global.storageServices.get(PrefConst.userId)?.toString();
    if (savedUserId != null && savedUserId.isNotEmpty) {
      _selfUserId = savedUserId;
    }

    if (socket == null) {
      if (savedUserId != null && savedUserId.isNotEmpty) {
        await init(
          websocketUrl: ConstRes.socketUrl,
          selfUserId: savedUserId,
        );
      }
    }

    if (socket != null && socket?.connected != true) {
      _log('Waiting for socket to connect before joining group...');
      try {
        socket?.connect();
      } catch (_) {}
      final completer = Completer<void>();
      void onConnectHandler(_) {
        if (!completer.isCompleted) completer.complete();
      }
      socket?.once('connect', onConnectHandler);
      await completer.future.timeout(const Duration(seconds: 4), onTimeout: () {
        _log('Socket connect wait timed out');
      });
    }

    // Clean up any stale peers from previous session to guarantee fresh WebRTC negotiation
    for (final id in _peers.keys.toList()) {
      await _closePeer(id);
    }
    _peers.clear();
    _offeredTo.clear();
    _makingOffer.clear();
    _pendingIce.clear();
    _remoteStreams.clear();

    final micState = await checkMicPermissionSilently();
    if (micState == WalkieMicPermissionState.granted) {
      await _ensureLocalStream();
    }

    await _checkAudioDevices();
    await _configureAudioSession(route: audioRoute.value);
    await _ensurePlaybackPath(forceSession: true);

    socket?.emit('join_walkie_session', {'groupId': groupId});
    _log('✅ join_walkie_session emitted');

    if (Get.isRegistered<GroupWalkieController>()) {
      final ctrl = Get.find<GroupWalkieController>();
      if (micState == WalkieMicPermissionState.granted) {
        ctrl.setInitStage(WalkieInitStage.ready);
      } else {
        ctrl.setInitStage(WalkieInitStage.permissionRequired);
      }
    }

    return true;
  }

  Future<void> leaveGroup() async {
    if (_currentGroupId == null) return;
    final groupId = _currentGroupId;
    _currentGroupId = null;

    if (_isTalking) {
      _isTalking = false;
      await _enableMic(false);
      final payload = {'groupId': groupId, 'userId': _selfUserId};
      socket?.emit('ptt_release', payload);
      socket?.emit('walkie_speaker_stopped', payload);
    }

    socket?.emit('leave_walkie_session', {'groupId': groupId});

    for (final id in _peers.keys.toList()) {
      await _closePeer(id);
    }

    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    _streamCompleter = null;
    _audioSessionReady = false;
  }

  Future<void> exitGroupMembership(String groupId) async {
    await leaveGroup();
    socket?.emit('exit_group_membership', {'groupId': groupId});
  }

  Future<bool> startTalking() async {
    if (_isDisposed) _isDisposed = false;

    if (_currentGroupId == null && Get.isRegistered<GroupWalkieController>()) {
      final cGroupId = Get.find<GroupWalkieController>().currentGroupId;
      if (cGroupId != null && cGroupId.isNotEmpty) {
        _currentGroupId = cGroupId;
      }
    }

    _log(
      'startTalking disposed=$_isDisposed group=$_currentGroupId '
          'talking=$_isTalking muted=$_isMuted peers=${_peers.length}',
    );

    if (_currentGroupId == null || _currentGroupId!.isEmpty) return false;
    if (_isTalking) return true;
    if (_isMuted) return false;

    final currentSession = ++_talkSessionId;

    final ok = await _ensureLocalStream();
    if (!ok) {
      if (Get.isRegistered<GroupWalkieController>()) {
        Get.find<GroupWalkieController>().showPermissionDeniedMessage();
      }
      return false;
    }

    if (_talkSessionId != currentSession) {
      _log('startTalking cancelled while ensuring local stream');
      await _enableMic(false);
      return false;
    }

    _logPeerSnapshot('before ptt_request');

    if (_peers.isEmpty) {
      _log('⚠️ No peers yet — audio will only flow after peer connects');
    }

    _isTalking = true;
    socket?.emit('ptt_request', {'groupId': _currentGroupId});
    _log('🚀 ptt_request emitted');
    return true;
  }

  Future<void> stopTalking() async {
    _talkSessionId++;
    _isTalking = false;
    await _enableMic(false);
    if (_currentGroupId != null) {
      final payload = {
        'groupId': _currentGroupId,
        'userId': _selfUserId,
        'sessionId': _talkSessionId,
      };
      socket?.emit('ptt_release', payload);
      socket?.emit('walkie_speaker_stopped', payload);
    }
    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().stopTalking();
    }
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;

    if (_isMuted) {
      await _enableMic(false);
      if (_isTalking) {
        _isTalking = false;
        final releasePayload = {
          'groupId': _currentGroupId,
          'userId': _selfUserId,
        };
        socket?.emit('ptt_release', releasePayload);
        socket?.emit('walkie_speaker_stopped', releasePayload);
        if (Get.isRegistered<GroupWalkieController>()) {
          Get.find<GroupWalkieController>().forceUnlockAndReset();
        }
      }
    } else if (_isTalking) {
      await _enableMic(true);
    }

    final mutePayload = {
      'groupId': _currentGroupId,
      'userId': _selfUserId,
      'user_id': _selfUserId,
      'fromUserId': _selfUserId,
      'isMuted': _isMuted,
      'muted': _isMuted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    socket?.emit('walkie_mute_status_changed', mutePayload);
    socket?.emit('walkie_toggle_mute', mutePayload);
    socket?.emit('walkie_user_muted', mutePayload);
    socket?.emit('walkie_mute_status', mutePayload);

    if (Get.isRegistered<GroupWalkieController>()) {
      Get.find<GroupWalkieController>().setMuteFromService(_isMuted);
    }
  }

  Future<void> setAudioRoute(WalkieAudioRoute route) async {
    if (_isDisposed) return;
    audioRoute.value = route;
    _isSpeakerOn = route == WalkieAudioRoute.speaker;
    _log('🎧 setAudioRoute $route speaker=$_isSpeakerOn');

    await _configureAudioSession(route: route);
    await _applyCurrentAudioRoute();

    for (final stream in _remoteStreams.values) {
      for (final track in stream.getAudioTracks()) {
        try {
          track.enabled = true;
          track.enableSpeakerphone(route == WalkieAudioRoute.speaker);
        } catch (_) {}
      }
    }

    if (Get.isRegistered<GroupWalkieController>()) {
      final c = Get.find<GroupWalkieController>();
      c.setAudioRoute(route);
      c.isSpeakerOn.value = _isSpeakerOn;
    }
  }

  Future<void> toggleSpeaker(bool speakerOn) async {
    await setAudioRoute(
      speakerOn ? WalkieAudioRoute.speaker : WalkieAudioRoute.earpiece,
    );
  }

  Future<void> debugForceHear() async {
    _logPeerSnapshot('debugForceHear');
    await _ensurePlaybackPath(forceSession: true);
    if (_isTalking) await _enableMic(true);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _isTalking = false;
    _stopPing();

    try {
      if (Platform.isAndroid) {
        final am = AndroidAudioManager();
        await am.stopBluetoothSco();
        await am.setBluetoothScoOn(false);
        await am.setMode(AndroidAudioHardwareMode.normal);
      }
      await ProximityScreenLock.setActive(false);
    } catch (_) {}

    try {
      if (_currentGroupId != null) {
        socket?.emit('leave_walkie_session', {'groupId': _currentGroupId});
      }
    } catch (_) {}

    for (final id in _peers.keys.toList()) {
      await _closePeer(id);
    }

    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    _streamCompleter = null;
    _audioSessionReady = false;

    await _devicesSub?.cancel();
    _devicesSub = null;
    await _interruptionSub?.cancel();
    _interruptionSub = null;

    try {
      socket?.clearListeners();
      socket?.disconnect();
      socket?.dispose();
    } catch (_) {}
    socket = null;
    _currentGroupId = null;
    _listenersBound = false;
  }
}