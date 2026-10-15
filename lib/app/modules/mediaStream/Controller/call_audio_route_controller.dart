import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

enum CallAudioRoute {
  earpiece,
  speaker,
  bluetooth,
}

enum _DeviceType {
  bluetooth,
  builtIn,
  wired,
  speaker,
  earpiece,
  other,
}

void _arLog(String message, {StackTrace? stackTrace}) {
  debugPrint(message);
  if (stackTrace != null) debugPrint(stackTrace.toString());
}

class _DeviceSnapshot {
  final bool bluetooth;
  final String? bluetoothId;
  final String? speakerId;
  final String? earpieceId;

  final String? builtInInputId;

  const _DeviceSnapshot({
    required this.bluetooth,
    this.bluetoothId,
    this.speakerId,
    this.earpieceId,
    this.builtInInputId,
  });
}

class CallAudioRouteController extends GetxController {
  final Rx<CallAudioRoute> currentRoute = CallAudioRoute.earpiece.obs;
  final RxBool isBluetoothConnected = false.obs;
  final RxBool isVideoCall = false.obs;

  Timer? _deviceTimer;
  Future<void>? _deviceCheck;
  Future<void> _routeQueue = Future.value();

  bool _manualRouteSelected = false;
  bool _hasCheckedDevices = false;
  bool _isDisposed = false;

  String? _bluetoothDeviceId;
  String? _speakerDeviceId;
  String? _earpieceDeviceId;
  String? _builtInInputId;

  bool _iosBluetoothBlocked = false;
  String _lastDeviceSig = '';

  int _routeBusy = 0;
  DateTime _lastRouteChangeAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool get _iosShouldSkipScan =>
      Platform.isIOS &&
      (_iosBluetoothBlocked ||
          _routeBusy > 0 ||
          DateTime.now().difference(_lastRouteChangeAt) <
              const Duration(milliseconds: 1500));

  // Native iOS bridge (AudioRouteBridge.swift).
  static const MethodChannel _native = MethodChannel('fgtracker/audio_route');

  static final RegExp _scoRegex = RegExp(r'(^|[^a-z])sco([^a-z]|$)');

  // ---------------------------------------------------------------------------
  // UI getters
  // ---------------------------------------------------------------------------

  IconData get currentAudioRouteIcon {
    switch (currentRoute.value) {
      case CallAudioRoute.bluetooth:
        return Icons.bluetooth_audio_rounded;
      case CallAudioRoute.speaker:
        return Icons.volume_up_rounded;
      case CallAudioRoute.earpiece:
        return Icons.phone_in_talk_rounded;
    }
  }

  String get currentAudioRouteLabel {
    switch (currentRoute.value) {
      case CallAudioRoute.bluetooth:
        return "Bluetooth";
      case CallAudioRoute.speaker:
        return "Speaker";
      case CallAudioRoute.earpiece:
        return "Earpiece";
    }
  }

  bool get isSpeakerOn => currentRoute.value == CallAudioRoute.speaker;

  CallAudioRoute get _defaultRoute =>
      isVideoCall.value ? CallAudioRoute.speaker : CallAudioRoute.earpiece;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  Future<void> startCall({required bool isVideo}) async {
    _isDisposed = false;
    _manualRouteSelected = false;
    _hasCheckedDevices = false;
    _iosBluetoothBlocked = false;
    isVideoCall.value = isVideo;

    await checkDevices();

    if (isBluetoothConnected.value) {
      await _applyRoute(CallAudioRoute.bluetooth);
    } else {
      await _applyRoute(_defaultRoute);
    }

    _startDeviceMonitoring();
    await _dumpRoute("startCall finished");
  }

  Future<void> updateCallType({required bool isVideo}) async {
    isVideoCall.value = isVideo;

    if (!isVideo) return;

    if (isBluetoothConnected.value) return;

    if (_manualRouteSelected) return;

    await _applyRoute(CallAudioRoute.speaker);
  }

  Future<void> selectRoute(CallAudioRoute route) async {
    if (route == CallAudioRoute.bluetooth && !isBluetoothConnected.value) {
      await checkDevices();
      if (!isBluetoothConnected.value) {
        _arLog("[AudioRoute] Bluetooth is not connected");
        return;
      }
    }

    _manualRouteSelected = true;
    await _applyRoute(route);
  }

  Future<void> restoreCurrentRoute() async {
    await checkDevices();
    await _applyRoute(currentRoute.value);
  }

  Future<void> stopCall() async {
    _isDisposed = true;

    _deviceTimer?.cancel();
    _deviceTimer = null;
    _deviceCheck = null;

    navigator.mediaDevices.ondevicechange = null;

    _manualRouteSelected = false;
    _hasCheckedDevices = false;

    _bluetoothDeviceId = null;
    _speakerDeviceId = null;
    _earpieceDeviceId = null;
    _builtInInputId = null;
    _iosBluetoothBlocked = false;

    try {
      await ProximityScreenLock.setActive(false);
    } catch (_) {}
  }

  Future<void> _applyRoute(CallAudioRoute route) {
    _routeQueue =
        _routeQueue.then((_) => _applyRouteInternal(route)).catchError((error) {
      _arLog("[AudioRoute] Route '$route' failed: $error");
    });
    return _routeQueue;
  }

  Future<bool> _tryApply(CallAudioRoute route) async {
    try {
      if (Platform.isIOS) {
        await _applyIosRoute(route);
      } else {
        await _applyAndroidRoute(route);
      }
      return true;
    } catch (e, st) {
      _arLog("[AudioRoute] Failed to apply $route: $e", stackTrace: st);
      return false;
    }
  }

  Future<void> _applyRouteInternal(CallAudioRoute requested) async {
    _routeBusy++;
    _lastRouteChangeAt = DateTime.now();
    try {
      await _applyRouteBody(requested);
    } finally {
      _routeBusy--;
      _lastRouteChangeAt = DateTime.now();
    }
  }

  Future<void> _applyRouteBody(CallAudioRoute requested) async {
    if (_isDisposed) return;

    CallAudioRoute target = requested;

    if (target == CallAudioRoute.bluetooth && !isBluetoothConnected.value) {
      target = _defaultRoute;
    }

    _arLog("[AudioRoute] REQUEST route=$requested target=$target "
        "bt=${isBluetoothConnected.value} manual=$_manualRouteSelected "
        "blocked=$_iosBluetoothBlocked video=${isVideoCall.value}");
    await _dumpRoute("before $target");

    bool ok = await _tryApply(target);

    if (!ok && target == CallAudioRoute.bluetooth) {
      target = _defaultRoute;
      await _tryApply(target);
    }

    if (_isDisposed) return;

    currentRoute.value = target;
    currentRoute.refresh();

    try {
      await ProximityScreenLock.setActive(
        target == CallAudioRoute.earpiece && !isVideoCall.value,
      );
    } catch (_) {}

    update();

    _arLog("[AudioRoute] UI now shows: ${currentRoute.value}");
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _dumpRoute("settled 600ms after $target");
  }

  // ---- iOS native helpers --------------------------------------------------

  Future<void> _dumpRoute(String tag) async {
    if (!Platform.isIOS) return;
    try {
      final String? d = await _native.invokeMethod<String>('dumpRoute');
      _arLog("[AudioRoute] ROUTE[$tag] $d");
    } catch (e) {
      _arLog("[AudioRoute] ROUTE[$tag] native bridge NOT available: $e");
    }
  }

  Future<String?> _iosOutputPort() async {
    try {
      return await _native.invokeMethod<String>('currentRoute');
    } catch (_) {
      return null;
    }
  }

  Future<bool> _iosNativeBool(String method) async {
    try {
      return (await _native.invokeMethod<bool>(method)) ?? false;
    } catch (e) {
      _arLog("[AudioRoute] iOS native '$method' unavailable/failed: $e");
      return false;
    }
  }

  bool _isBluetoothPort(String? port) =>
      port != null && port.toLowerCase().contains('bluetooth');

  Future<void> _iosSetAudioConfig({
    required bool allowBluetooth,
    bool defaultToSpeaker = false,
  }) async {
    try {
      final Set<AppleAudioCategoryOption> options = <AppleAudioCategoryOption>{
        if (allowBluetooth) AppleAudioCategoryOption.allowBluetooth,
        if (allowBluetooth) AppleAudioCategoryOption.allowBluetoothA2DP,
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
      _arLog("[AudioRoute] iOS audio config applied: "
          "allowBluetooth=$allowBluetooth defaultToSpeaker=$defaultToSpeaker");
    } catch (e) {
      _arLog("[AudioRoute] iOS setAppleAudioConfiguration failed: $e");
    }
  }

  Future<String?> _iosForceEarpieceNative() async {
    try {
      final r = await _native.invokeMethod<String>('forceEarpiece');
      _arLog("[AudioRoute] iOS forceEarpiece result: $r");
      return r;
    } catch (e) {
      _arLog("[AudioRoute] iOS native bridge NOT available: $e");
      return null;
    }
  }

  Future<void> _applyIosRoute(CallAudioRoute route) async {
    switch (route) {
      case CallAudioRoute.speaker:
        if (isBluetoothConnected.value) {
          _iosBluetoothBlocked = true;
          await _iosSetAudioConfig(
              allowBluetooth: false, defaultToSpeaker: true);

          final bool ok = await _iosNativeBool('forceSpeaker');
          if (!ok) {
            await Helper.setSpeakerphoneOn(true);
            await _iosSetAudioConfig(
                allowBluetooth: false, defaultToSpeaker: true);
          }
        } else {
          _iosBluetoothBlocked = false;
          await Helper.setSpeakerphoneOn(true);
        }
        break;

      case CallAudioRoute.earpiece:
        if (isBluetoothConnected.value) {
          _iosBluetoothBlocked = true;
          await _iosSetAudioConfig(allowBluetooth: false);
          await _iosForceEarpieceNative();
          await Future<void>.delayed(const Duration(milliseconds: 300));

          String? out = await _iosOutputPort();
          _arLog("[AudioRoute] iOS output after earpiece attempt 1: $out");

          if (_isBluetoothPort(out)) {
            await Helper.setSpeakerphoneOn(false);
            await _iosSetAudioConfig(allowBluetooth: false);
            await _iosForceEarpieceNative();
            await Future<void>.delayed(const Duration(milliseconds: 400));
            out = await _iosOutputPort();
            _arLog("[AudioRoute] iOS output after earpiece attempt 2: $out");
          }
        } else {
          _iosBluetoothBlocked = false;
          await Helper.setSpeakerphoneOn(false);
        }
        break;

      case CallAudioRoute.bluetooth:
        _iosBluetoothBlocked = false;
        await _iosSetAudioConfig(allowBluetooth: true);
        await _iosNativeBool('allowBluetooth');
        await Helper.setSpeakerphoneOn(false);
        await Future<void>.delayed(const Duration(milliseconds: 600));

        final snap = await _scanDevices();
        if (snap != null) _storeIds(snap);

        for (int attempt = 0; attempt < 3; attempt++) {
          final bool ok = await _iosNativeBool('preferBluetooth');
          if (!ok && _bluetoothDeviceId != null) {
            try {
              await Helper.selectAudioInput(_bluetoothDeviceId!);
            } catch (_) {
              await Helper.setSpeakerphoneOnButPreferBluetooth();
            }
          }
          await Future<void>.delayed(const Duration(milliseconds: 350));

          final out = await _iosOutputPort();
          _arLog("[AudioRoute] iOS output after Bluetooth attempt: $out");
          if (out == null || _isBluetoothPort(out)) return;
        }

        isBluetoothConnected.value = false;
        throw Exception("Bluetooth route is not active");
    }
  }

  // ---- Android -------------------------------------------------------------

  Future<void> _applyAndroidRoute(CallAudioRoute route) async {
    switch (route) {
      case CallAudioRoute.earpiece:
        await Helper.setSpeakerphoneOn(false);
        await Future<void>.delayed(const Duration(milliseconds: 150));

        bool done = false;
        for (final id in <String>[
          _earpieceDeviceId ?? "earpiece",
          "earpiece",
          "receiver",
        ]) {
          try {
            await Helper.selectAudioOutput(id);
            _arLog("[AudioRoute] Android earpiece selected with id '$id'");
            done = true;
            break;
          } catch (e) {
            _arLog("[AudioRoute] Android earpiece select '$id' failed: $e");
          }
        }
        if (!done) {
          _arLog("[AudioRoute] Android earpiece selection failed completely");
        }
        break;

      case CallAudioRoute.speaker:
        await Helper.setSpeakerphoneOn(true);
        try {
          await Helper.selectAudioOutput(_speakerDeviceId ?? "speaker");
        } catch (e) {
          _arLog("[AudioRoute] Android speaker selection failed: $e");
        }
        break;

      case CallAudioRoute.bluetooth:
        try {
          await Helper.selectAudioOutput(_bluetoothDeviceId ?? "bluetooth");
        } catch (e) {
          _arLog("[AudioRoute] Android Bluetooth selection failed: $e");
          await Helper.setSpeakerphoneOnButPreferBluetooth();
        }
        break;
    }
  }

  void _startDeviceMonitoring() {
    navigator.mediaDevices.ondevicechange = (_) {
      unawaited(checkDevices());
    };

    _deviceTimer?.cancel();
    _deviceTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(checkDevices()),
    );
  }

  Future<void> checkDevices() {
    return _deviceCheck ??= _checkDevicesInternal().whenComplete(
      () => _deviceCheck = null,
    );
  }

  void _storeIds(_DeviceSnapshot s) {
    _bluetoothDeviceId = s.bluetoothId ?? "bluetooth";
    _speakerDeviceId = s.speakerId ?? "speaker";
    _earpieceDeviceId = s.earpieceId ?? "earpiece";
    _builtInInputId = s.builtInInputId ?? _builtInInputId;
  }

  Future<void> _checkDevicesInternal() async {
    try {
      _DeviceSnapshot? snap = await _scanDevices();
      if (snap == null || _isDisposed) return;
      if (_iosShouldSkipScan) return;

      final bool wasConnected = isBluetoothConnected.value;

      if (wasConnected && !snap.bluetooth) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (_isDisposed) return;
        final again = await _scanDevices();
        if (again == null || _iosShouldSkipScan) return;
        snap = again;
      }

      _storeIds(snap);
      isBluetoothConnected.value = snap.bluetooth;
      if (wasConnected != snap.bluetooth) {
        _arLog(
            "[AudioRoute] BLUETOOTH CHANGE $wasConnected -> ${snap.bluetooth} "
            "(current=${currentRoute.value}, manual=$_manualRouteSelected)");
      }

      if (!_hasCheckedDevices) {
        _hasCheckedDevices = true;
        isBluetoothConnected.refresh();
        return;
      }

      final bool bluetoothConnected = snap.bluetooth && !wasConnected;
      final bool bluetoothDisconnected = !snap.bluetooth && wasConnected;

      if (bluetoothConnected) {
        _arLog("[AudioRoute] Bluetooth connected -> switching to Bluetooth");
        _manualRouteSelected = false;

        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (_isDisposed) return;
        await _applyRoute(CallAudioRoute.bluetooth);
      }

      if (bluetoothDisconnected) {
        _arLog("[AudioRoute] Bluetooth disconnected");
        if (currentRoute.value == CallAudioRoute.bluetooth) {
          _manualRouteSelected = false;
          await _applyRoute(_defaultRoute);
        }
      }

      isBluetoothConnected.refresh();
      currentRoute.refresh();
      update();
    } catch (e, st) {
      _arLog("[AudioRoute] Device detection failed: $e", stackTrace: st);
    }
  }

  Future<_DeviceSnapshot?> _scanDevices() async {
    final List<MediaDeviceInfo> devices =
        await navigator.mediaDevices.enumerateDevices();

    if (Platform.isIOS && devices.isEmpty) {
      _arLog("[AudioRoute] iOS returned an empty device list");
      return null;
    }

    String kindOf(MediaDeviceInfo d) => d.kind.toString().toLowerCase();

    final bool inputsOnly =
        Platform.isIOS && devices.any((d) => kindOf(d).contains("audioinput"));

    bool bluetooth = false;
    String? bluetoothId, speakerId, earpieceId, builtInId;
    final List<String> lines = <String>[];

    for (final d in devices) {
      final String kind = kindOf(d);
      if (!_isAudioDevice(kind)) continue;
      if (inputsOnly && !kind.contains("audioinput")) continue;

      final String id = d.deviceId.toString();
      final String label = d.label.toString();

      lines.add(
          "kind=${d.kind} id=$id label=$label -> ${_classify(id, label, kind).name}");

      switch (_classify(id, label, kind)) {
        case _DeviceType.bluetooth:
          bluetooth = true;
          bluetoothId ??= id;
          break;
        case _DeviceType.builtIn:
          builtInId ??= id;
          break;
        case _DeviceType.speaker:
          speakerId ??= id;
          break;
        case _DeviceType.earpiece:
          earpieceId ??= id;
          break;
        case _DeviceType.wired:
        case _DeviceType.other:
          break;
      }
    }

    final String sig = lines.join(' | ');
    if (sig != _lastDeviceSig) {
      _lastDeviceSig = sig;
      _arLog("[AudioRoute] DEVICES (${Platform.operatingSystem}): $sig");
    }

    return _DeviceSnapshot(
      bluetooth: bluetooth,
      bluetoothId: bluetoothId,
      speakerId: speakerId,
      earpieceId: earpieceId,
      builtInInputId: builtInId,
    );
  }

  bool _isAudioDevice(String kind) {
    return kind.isEmpty ||
        kind.contains("audiooutput") ||
        kind.contains("audioinput") ||
        kind == "audio";
  }

  bool _hasBluetoothKeyword(String v) {
    return v.contains("bluetooth") ||
        v.contains("airpods") ||
        v.contains("air pods") ||
        v.contains("beats") ||
        v.contains("buds") ||
        v.contains("hands-free") ||
        v.contains("handsfree") ||
        v.contains("a2dp") ||
        v.contains("hfp") ||
        v.contains("btheadset") ||
        _scoRegex.hasMatch(v);
  }

  _DeviceType _classify(String id, String label, String kind) {
    final String l = label.toLowerCase();
    final String i = id.toLowerCase();
    final String v = "$l $i";

    if (Platform.isIOS) {
      if (i.contains("-tsco") || i.contains("-tacl")) {
        return _DeviceType.bluetooth;
      }

      if (i.contains("built-in") ||
          i.contains("builtin") ||
          l.contains("iphone") ||
          l.contains("ipad") ||
          l.contains("ipod") ||
          l.contains("built-in")) {
        return _DeviceType.builtIn;
      }

      if (l == "headset microphone" ||
          i.contains("wired") ||
          l.contains("usb") ||
          i.contains("usb")) {
        return _DeviceType.wired;
      }

      if (kind.contains("audioinput")) {
        return _DeviceType.bluetooth;
      }

      if (_hasBluetoothKeyword(v)) return _DeviceType.bluetooth;
      if (v.contains("speaker")) return _DeviceType.speaker;
      if (v.contains("receiver")) return _DeviceType.earpiece;
      return _DeviceType.other;
    }

    // Android
    if (_hasBluetoothKeyword(v)) return _DeviceType.bluetooth;

    if (v.contains("earpiece") ||
        v.contains("receiver") ||
        v.contains("handset") ||
        v.contains("telephony")) {
      return _DeviceType.earpiece;
    }

    if (v.contains("speaker")) return _DeviceType.speaker;

    if (v.contains("wired") || v.contains("headphone")) {
      return _DeviceType.wired;
    }

    return _DeviceType.other;
  }

  @override
  void onClose() {
    _isDisposed = true;

    _deviceTimer?.cancel();
    _deviceTimer = null;

    navigator.mediaDevices.ondevicechange = null;

    unawaited(stopCall());

    super.onClose();
  }
}
