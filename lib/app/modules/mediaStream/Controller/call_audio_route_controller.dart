import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

enum CallAudioRoute { earpiece, speaker, bluetooth, headset }

class CallAudioRouteController extends GetxController {
  static const MethodChannel _iosAudioChannel =
  MethodChannel('com.fgtracker.audio_route');

  final Rx<CallAudioRoute> currentRoute = CallAudioRoute.earpiece.obs;

  final RxBool isBluetoothConnected = false.obs;
  final RxString bluetoothDeviceName = 'Bluetooth'.obs;
  final RxBool isHeadsetConnected = false.obs;
  final RxString headsetDeviceName = 'Headset'.obs;
  final RxBool isVideoCall = false.obs;

  bool _isDisposed = false;
  bool _isCheckingDevices = false;
  bool _isApplyingRoute = false;

  Future<void> _routeQueue = Future.value();

  StreamSubscription? _devicesSub;
  final List<Timer> _warmupRouteTimers = <Timer>[];

  String? _bluetoothDeviceId;
  String? _wiredDeviceId;
  String? _speakerDeviceId;
  String? _earpieceDeviceId;
  String? _bluetoothInputDeviceId;
  String? _wiredInputDeviceId;

  void _log(String msg) => debugPrint('[AudioRoute] $msg');

  IconData get currentAudioRouteIcon {
    switch (currentRoute.value) {
      case CallAudioRoute.bluetooth:
        return Icons.bluetooth_audio_rounded;
      case CallAudioRoute.headset:
        return Icons.headphones_rounded;
      case CallAudioRoute.speaker:
        return Icons.volume_up_rounded;
      case CallAudioRoute.earpiece:
        return Icons.phone_in_talk_rounded;
    }
  }

  String get currentAudioRouteLabel {
    switch (currentRoute.value) {
      case CallAudioRoute.bluetooth:
        return 'Bluetooth';
      case CallAudioRoute.headset:
        return 'Headset';
      case CallAudioRoute.speaker:
        return 'Speaker';
      case CallAudioRoute.earpiece:
        return 'Earpiece';
    }
  }

  bool get isSpeakerOn => currentRoute.value == CallAudioRoute.speaker;

  List<CallAudioRoute> get availableRoutes => <CallAudioRoute>[
    if (!isVideoCall.value) CallAudioRoute.earpiece,
    CallAudioRoute.speaker,
    if (isBluetoothConnected.value) CallAudioRoute.bluetooth,
    if (isHeadsetConnected.value) CallAudioRoute.headset,
  ];

  CallAudioRoute get _defaultRoute =>
      isVideoCall.value ? CallAudioRoute.speaker : CallAudioRoute.earpiece;

  void _cancelWarmupTimers() {
    for (final t in _warmupRouteTimers) {
      t.cancel();
    }
    _warmupRouteTimers.clear();
  }

  Future<bool> _hasActiveIosCallKitSession() async {
    if (!Platform.isIOS) return false;
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      return calls is List && calls.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> startCall({required bool isVideo}) async {
    _isDisposed = false;
    _cancelWarmupTimers();
    isVideoCall.value = isVideo;
    currentRoute.value = _defaultRoute;

    await _listenAudioDevices();

    if (Platform.isIOS && !isVideo) {
      for (final ms in <int>[500, 1300]) {
        _warmupRouteTimers.add(
          Timer(Duration(milliseconds: ms), () {
            if (!_isDisposed && !isVideoCall.value) {
              unawaited(_applyCurrentAudioRoute(skipWebRtcConfig: false));
            }
          }),
        );
      }
    }
  }

  Future<void> updateCallType({required bool isVideo}) async {
    isVideoCall.value = isVideo;
    if (isVideo) {
      _cancelWarmupTimers();
    } else {
      return;
    }

    if (currentRoute.value == CallAudioRoute.earpiece) {
      await _setRoute(CallAudioRoute.speaker);
    } else if (Platform.isIOS) {
      await _applyCurrentAudioRoute(skipWebRtcConfig: false);
    }
  }

  Future<void> selectRoute(CallAudioRoute route) async {
    if (route == CallAudioRoute.earpiece && isVideoCall.value) {
      route = CallAudioRoute.speaker;
    }

    if ((route == CallAudioRoute.bluetooth && !isBluetoothConnected.value) ||
        (route == CallAudioRoute.headset && !isHeadsetConnected.value)) {
      await _checkAudioDevices();

      final bool available = route == CallAudioRoute.bluetooth
          ? isBluetoothConnected.value
          : isHeadsetConnected.value;
      if (!available) {
        _log('$route is not connected');
        return;
      }
    }

    await _setRoute(route);
  }

  Future<void> checkDevices() => _checkAudioDevices();

  Future<void> restoreCurrentRoute() async {
    if (_isDisposed) return;
    await _checkAudioDevices();
    await _setRoute(currentRoute.value);
  }

  Future<void> stopCall() async {
    _isDisposed = true;
    _isApplyingRoute = false;
    _cancelWarmupTimers();

    await _devicesSub?.cancel();
    _devicesSub = null;

    try {
      await ProximityScreenLock.setActive(false);
    } catch (_) {}

    try {
      if (Platform.isAndroid) {
        final am = AndroidAudioManager();
        try {
          await am.stopBluetoothSco();
          await am.setBluetoothScoOn(false);
          await am.setSpeakerphoneOn(false);
          await am.setMode(AndroidAudioHardwareMode.normal);
        } catch (_) {}
        try {
          final session = await AudioSession.instance;
          await session.setActive(false);
        } catch (_) {}
      } else if (Platform.isIOS) {
        try {
          await _iosAudioChannel.invokeMethod<void>('resetAudioRoute');
        } catch (_) {}
        final managedByCallKit = await _hasActiveIosCallKitSession();
        if (!managedByCallKit) {
          try {
            final session = await AudioSession.instance;
            await session.setActive(false);
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<void> _setRoute(CallAudioRoute route) {
    _routeQueue = _routeQueue.then((_) => _setRouteInternal(route)).catchError(
          (e) {
        _log('setRoute($route) failed: $e');
      },
    );
    return _routeQueue;
  }

  Future<void> _setRouteInternal(CallAudioRoute route) async {
    if (_isDisposed) return;

    if (route == CallAudioRoute.earpiece && isVideoCall.value) {
      route = CallAudioRoute.speaker;
    }
    if (route == CallAudioRoute.bluetooth && !isBluetoothConnected.value) {
      route = _defaultRoute;
    }
    if (route == CallAudioRoute.headset && !isHeadsetConnected.value) {
      route = _defaultRoute;
    }

    _isApplyingRoute = true;
    try {
      currentRoute.value = route;
      _log('setRoute $route (video=${isVideoCall.value})');

      await _configureAudioSession(route: route);
      await _applyCurrentAudioRoute(skipWebRtcConfig: true);

      update();
    } finally {
      _isApplyingRoute = false;
    }
  }

  Future<void> _listenAudioDevices() async {
    try {
      final session = await AudioSession.instance;

      await _devicesSub?.cancel();
      _devicesSub = session.devicesStream.listen((_) {
        if (!_isApplyingRoute) {
          unawaited(_checkAudioDevices());
        }
      });

      await _checkAudioDevices(isInitial: true);
    } catch (e) {
      _log('listenAudioDevices error: $e');
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
    if (l.contains('usb-c') ||
        l.contains('type-c') ||
        l.contains('lightning')) {
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
      bool anySourceAnswered = false;

      if (Platform.isIOS) {
        try {
          final Map<String, dynamic>? nativeState =
          await _iosAudioChannel.invokeMapMethod<String, dynamic>(
            'getAudioState',
          );
          if (nativeState != null) {
            anySourceAnswered = true;
            if (nativeState['isBluetoothConnected'] == true) {
              isBtFound = true;
              final String rawBtName =
              (nativeState['bluetoothName'] ?? '').toString().trim();
              if (rawBtName.isNotEmpty) {
                btName = rawBtName;
              }
            }
            if (nativeState['isHeadsetConnected'] == true) {
              isWiredFound = true;
              final String rawHsName =
              (nativeState['headsetName'] ?? '').toString().trim();
              if (rawHsName.isNotEmpty) {
                headsetName = rawHsName;
              }
            }
          }
        } catch (_) {}

        try {
          final avSession = AVAudioSession();
          final inputs = await avSession.availableInputs;
          anySourceAnswered = true;
          for (final port in inputs) {
            if (port.portType == AVAudioSessionPort.bluetoothHfp ||
                port.portType == AVAudioSessionPort.bluetoothLe ||
                port.portType == AVAudioSessionPort.bluetoothA2dp ||
                port.portType == AVAudioSessionPort.carAudio) {
              isBtFound = true;
              if (port.portName.trim().isNotEmpty && btName == 'Bluetooth') {
                btName = port.portName.trim();
              }
            } else if (port.portType == AVAudioSessionPort.headsetMic ||
                port.portType == AVAudioSessionPort.headphones ||
                port.portType == AVAudioSessionPort.usbAudio) {
              isWiredFound = true;
              if (port.portName.trim().isNotEmpty &&
                  headsetName == 'Headset') {
                headsetName = port.portName.trim();
              }
            }
          }
        } catch (_) {}
      }

      try {
        final session = await AudioSession.instance;
        final audioSessionDevices = await session.getDevices();
        anySourceAnswered = true;

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

      if (isInitial || (!Platform.isIOS && !isVideoCall.value)) {
        try {
          final webrtcDevices = await navigator.mediaDevices.enumerateDevices();
          if (webrtcDevices.isNotEmpty) anySourceAnswered = true;

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
      }

      if (!anySourceAnswered && !isInitial) return;

      final prevBT = isBluetoothConnected.value;
      final prevHS = isHeadsetConnected.value;

      isBluetoothConnected.value = isBtFound;
      bluetoothDeviceName.value = btName;
      isHeadsetConnected.value = isWiredFound;
      headsetDeviceName.value = headsetName;

      if (isInitial) {
        _log('initial devices: bluetooth=$isBtFound headset=$isWiredFound');
        await _setRoute(
          isBtFound
              ? CallAudioRoute.bluetooth
              : (isWiredFound ? CallAudioRoute.headset : _defaultRoute),
        );
        return;
      }

      final btPlugged = isBtFound && !prevBT;
      final wiredPlugged = isWiredFound && !prevHS;
      final btUnplugged = !isBtFound && prevBT;
      final wiredUnplugged = !isWiredFound && prevHS;

      if (btPlugged) {
        _log('Bluetooth plugged ($btName) -> switching to bluetooth');
        await _setRoute(CallAudioRoute.bluetooth);
      } else if (wiredPlugged) {
        _log('Headset plugged ($headsetName) -> switching to headset');
        await _setRoute(CallAudioRoute.headset);
      } else if (btUnplugged &&
          currentRoute.value == CallAudioRoute.bluetooth) {
        _log('Bluetooth unplugged');
        await _setRoute(
          isWiredFound ? CallAudioRoute.headset : _defaultRoute,
        );
      } else if (wiredUnplugged &&
          currentRoute.value == CallAudioRoute.headset) {
        _log('Headset unplugged');
        await _setRoute(
          isBtFound ? CallAudioRoute.bluetooth : _defaultRoute,
        );
      }
    } catch (e) {
      _log('checkAudioDevices error: $e');
    } finally {
      _isCheckingDevices = false;
    }
  }

  Future<void> _configureAudioSession({CallAudioRoute? route}) async {
    if (_isDisposed) return;
    final targetRoute = route ?? currentRoute.value;

    try {
      final session = await AudioSession.instance;
      final iosMode = isVideoCall.value
          ? AVAudioSessionMode.videoChat
          : AVAudioSessionMode.voiceChat;

      if (Platform.isIOS) {
        final bool isSpeaker = targetRoute == CallAudioRoute.speaker;
        final bool isBluetooth = targetRoute == CallAudioRoute.bluetooth;

        AVAudioSessionCategoryOptions options =
            AVAudioSessionCategoryOptions.allowBluetooth;
        if (isBluetooth) {
          options = options | AVAudioSessionCategoryOptions.allowBluetoothA2dp;
        }
        if (isSpeaker) {
          options = options | AVAudioSessionCategoryOptions.defaultToSpeaker;
        }

        await session.configure(
          AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionMode: iosMode,
            avAudioSessionCategoryOptions: options,
          ),
        );

        await _iosWebRtcConfig(
          enableA2dp: isBluetooth,
          defaultToSpeaker: isSpeaker,
        );

        final managedByCallKit = await _hasActiveIosCallKitSession();
        if (!managedByCallKit) {
          try {
            await session.setActive(true);
          } catch (_) {}
        }
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

        try {
          await session.setActive(true);
        } catch (_) {}
      }

      _log('AudioSession configured for route=$targetRoute');
    } catch (e) {
      _log('AudioSession configure error: $e');
    }
  }

  Future<void> _iosWebRtcConfig({
    required bool enableA2dp,
    bool defaultToSpeaker = false,
  }) async {
    if (!Platform.isIOS) return;

    try {
      final Set<AppleAudioCategoryOption> options = <AppleAudioCategoryOption>{
        AppleAudioCategoryOption.allowBluetooth,
        if (enableA2dp) AppleAudioCategoryOption.allowBluetoothA2DP,
        if (defaultToSpeaker) AppleAudioCategoryOption.defaultToSpeaker,
      };

      await Helper.setAppleAudioConfiguration(
        AppleAudioConfiguration(
          appleAudioCategory: AppleAudioCategory.playAndRecord,
          appleAudioCategoryOptions: options,
          appleAudioMode: isVideoCall.value
              ? AppleAudioMode.videoChat
              : AppleAudioMode.voiceChat,
        ),
      );
      _log('iOS WebRTC audio config: enableA2dp=$enableA2dp '
          'defaultToSpeaker=$defaultToSpeaker');
    } catch (e) {
      _log('iOS WebRTC audio config failed: $e');
    }
  }

  Future<bool> _applyNativeIosRoute(CallAudioRoute route) async {
    try {
      final Map<String, dynamic>? res =
      await _iosAudioChannel.invokeMapMethod<String, dynamic>(
        'setAudioRoute',
        <String, dynamic>{
          'route': route.name,
          'isVideo': isVideoCall.value,
        },
      );
      if (res != null) {
        _log('Native iOS route applied: requested=${route.name} '
            'actual=${res['activeOutput']}');
        return true;
      }
    } catch (e) {
      _log('Native iOS audio channel fallback ($e)');
    }
    return false;
  }

  Future<void> _applyDartIosFallbackRoute(CallAudioRoute route) async {
    final avSession = AVAudioSession();
    final inputs = await avSession.availableInputs;

    AVAudioSessionPortDescription? findPort(Set<AVAudioSessionPort> types) {
      for (final p in inputs) {
        if (types.contains(p.portType)) return p;
      }
      return null;
    }

    switch (route) {
      case CallAudioRoute.speaker:
        final builtInMic = findPort(<AVAudioSessionPort>{
          AVAudioSessionPort.builtInMic,
        });
        if (builtInMic != null) {
          try {
            await avSession.setPreferredInput(builtInMic);
          } catch (_) {}
        }
        await avSession.overrideOutputAudioPort(
          AVAudioSessionPortOverride.speaker,
        );
        break;

      case CallAudioRoute.bluetooth:
        await avSession.overrideOutputAudioPort(
          AVAudioSessionPortOverride.none,
        );
        final btInput = findPort(<AVAudioSessionPort>{
          AVAudioSessionPort.bluetoothHfp,
          AVAudioSessionPort.bluetoothLe,
          AVAudioSessionPort.carAudio,
        });
        if (btInput != null) {
          await avSession.setPreferredInput(btInput);
        }
        if (_bluetoothInputDeviceId != null) {
          try {
            await Helper.selectAudioInput(_bluetoothInputDeviceId!);
          } catch (_) {}
        }
        break;

      case CallAudioRoute.headset:
        await avSession.overrideOutputAudioPort(
          AVAudioSessionPortOverride.none,
        );
        final wiredInput = findPort(<AVAudioSessionPort>{
          AVAudioSessionPort.headsetMic,
          AVAudioSessionPort.usbAudio,
        });
        if (wiredInput != null) {
          await avSession.setPreferredInput(wiredInput);
        }
        if (_wiredInputDeviceId != null) {
          try {
            await Helper.selectAudioInput(_wiredInputDeviceId!);
          } catch (_) {}
        }
        break;

      case CallAudioRoute.earpiece:
        await avSession.overrideOutputAudioPort(
          AVAudioSessionPortOverride.none,
        );
        final builtInMic = findPort(<AVAudioSessionPort>{
          AVAudioSessionPort.builtInMic,
        });
        if (builtInMic != null) {
          await avSession.setPreferredInput(builtInMic);
        }
        break;
    }
  }

  Future<void> _applyCurrentAudioRoute({bool skipWebRtcConfig = false}) async {
    final route = currentRoute.value;
    final bool proximity =
        route == CallAudioRoute.earpiece && !isVideoCall.value;

    try {
      if (Platform.isAndroid) {
        final am = AndroidAudioManager();
        try {
          await am.setMode(AndroidAudioHardwareMode.inCommunication);
        } catch (_) {}

        switch (route) {
          case CallAudioRoute.speaker:
            try {
              await am.stopBluetoothSco();
              await am.setBluetoothScoOn(false);
            } catch (_) {}
            try {
              await am.setSpeakerphoneOn(true);
              await Helper.setSpeakerphoneOn(true);
              await Helper.selectAudioOutput('speaker');
            } catch (_) {}
            break;

          case CallAudioRoute.bluetooth:
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
            break;

          case CallAudioRoute.headset:
            try {
              await am.stopBluetoothSco();
              await am.setBluetoothScoOn(false);
            } catch (_) {}
            try {
              await am.setSpeakerphoneOn(false);
              await Helper.setSpeakerphoneOn(false);
              await Helper.selectAudioOutput('wired-headset');
            } catch (_) {}
            break;

          case CallAudioRoute.earpiece:
            try {
              await am.stopBluetoothSco();
              await am.setBluetoothScoOn(false);
            } catch (_) {}
            try {
              await am.setSpeakerphoneOn(false);
              await Helper.setSpeakerphoneOn(false);
              await Helper.selectAudioOutput('earpiece');
            } catch (_) {}
            break;
        }
      } else if (Platform.isIOS) {
        if (!skipWebRtcConfig) {
          await _iosWebRtcConfig(
            enableA2dp: route == CallAudioRoute.bluetooth,
            defaultToSpeaker: route == CallAudioRoute.speaker,
          );
        }

        final bool handledNatively = await _applyNativeIosRoute(route);
        if (!handledNatively) {
          try {
            await _applyDartIosFallbackRoute(route);
          } catch (e) {
            _log('Dart iOS fallback route error: $e');
          }
        }
      }

      try {
        await ProximityScreenLock.setActive(proximity);
      } catch (_) {}
    } catch (e) {
      _log('applyCurrentAudioRoute error: $e');
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _cancelWarmupTimers();
    unawaited(stopCall());
    super.onClose();
  }
}
