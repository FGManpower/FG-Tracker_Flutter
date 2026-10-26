import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

enum CallAudioRoute { earpiece, speaker, bluetooth, headset }

/// iOS    : routing AppDelegate (native) mein hoti hai, Dart sirf command
///          bhejta hai aur native state mirror karta hai.
/// Android: routing sirf flutter_webrtc Helper se, detection audio_session se.
class CallAudioRouteController extends GetxController {
  static const MethodChannel _iosChannel =
      MethodChannel('com.fgtracker.audio_route');

  static const Map<CallAudioRoute, String> _androidOutputNames =
      <CallAudioRoute, String>{
    CallAudioRoute.earpiece: 'earpiece',
    CallAudioRoute.speaker: 'speaker',
    CallAudioRoute.bluetooth: 'bluetooth',
    CallAudioRoute.headset: 'wired-headset',
  };

  // ───────────── Public state ─────────────
  final Rx<CallAudioRoute> currentRoute = CallAudioRoute.earpiece.obs;
  final RxBool isBluetoothConnected = false.obs;
  final RxString bluetoothDeviceName = 'Bluetooth'.obs;
  final RxBool isHeadsetConnected = false.obs;
  final RxString headsetDeviceName = 'Headset'.obs;
  final RxBool isVideoCall = false.obs;

  // ───────────── Private state ─────────────
  bool _active = false;
  bool _userSelectedRoute = false;
  bool _isApplyingRoute = false;
  String? _nativeActiveOutput;
  DateTime _lastApplyAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _queue = Future<void>.value();

  StreamSubscription<AudioDevicesChangedEvent>? _devicesSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  Timer? _deviceDebounce;
  final List<Timer> _warmupTimers = <Timer>[];

  void _log(String m) => debugPrint('[AudioRoute] $m');

  @override
  void onInit() {
    super.onInit();
    if (Platform.isIOS) {
      _iosChannel.setMethodCallHandler(_handleNativeEvent);
    }
  }

  // ───────────── UI helpers ─────────────
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

  // ───────────── Queue ─────────────
  Future<void> _enqueue(Future<void> Function() task) {
    _queue = _queue.then((_) => task()).catchError((Object e) {
      _log('queued task failed: $e');
    });
    return _queue;
  }

  void _cancelWarmupTimers() {
    for (final Timer t in _warmupTimers) {
      t.cancel();
    }
    _warmupTimers.clear();
  }

  // ───────────── iOS native bridge ─────────────
  Future<Map<String, dynamic>?> _iosInvoke(
    String method,
    Map<String, dynamic>? args,
  ) async {
    try {
      return await _iosChannel.invokeMapMethod<String, dynamic>(method, args);
    } catch (e) {
      _log('iOS channel $method failed: $e');
      return null;
    }
  }

  Future<dynamic> _handleNativeEvent(MethodCall call) async {
    if (call.method != 'onAudioRouteChanged' || !_active) return null;

    final Map<String, dynamic>? state =
        (call.arguments as Map?)?.cast<String, dynamic>();
    if (state == null) return null;

    _applyNativeState(state);

    if (!_isApplyingRoute) {
      final CallAudioRoute? actual = _routeFromNative(_nativeActiveOutput);
      if (actual != null && actual != currentRoute.value) {
        _log('native route -> $actual');
        currentRoute.value = actual;
        unawaited(_applyProximity(actual));
      }
      update();
    }
    return null;
  }

  CallAudioRoute? _routeFromNative(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'speaker':
        return CallAudioRoute.speaker;
      case 'bluetooth':
        return CallAudioRoute.bluetooth;
      case 'headset':
        return CallAudioRoute.headset;
      case 'earpiece':
        return CallAudioRoute.earpiece;
      default:
        return null;
    }
  }

  void _applyNativeState(Map<String, dynamic>? state) {
    if (state == null) return;

    final String out = (state['activeOutput'] ?? '').toString().trim();
    if (out.isNotEmpty) _nativeActiveOutput = out;

    if (state['isBluetoothConnected'] is bool) {
      isBluetoothConnected.value = state['isBluetoothConnected'] as bool;
    }
    final String bt = (state['bluetoothName'] ?? '').toString().trim();
    if (bt.isNotEmpty) bluetoothDeviceName.value = bt;

    if (state['isHeadsetConnected'] is bool) {
      isHeadsetConnected.value = state['isHeadsetConnected'] as bool;
    }
    final String hs = (state['headsetName'] ?? '').toString().trim();
    if (hs.isNotEmpty) headsetDeviceName.value = hs;
  }

  // ───────────── Lifecycle ─────────────
  Future<void> startCall({required bool isVideo}) async {
    _active = true;
    _userSelectedRoute = false;
    _nativeActiveOutput = null;
    _cancelWarmupTimers();
    isVideoCall.value = isVideo;
    currentRoute.value = _defaultRoute;

    if (Platform.isIOS) {
      final Map<String, dynamic>? s = await _iosInvoke(
        'startAudioRouteMonitoring',
        <String, dynamic>{'isVideo': isVideo},
      );
      _applyNativeState(s);
    } else {
      await _listenAndroid();
    }

    await _enqueue(() async {
      await _scanDevices();
      await _applyRoute(_autoRoute());
    });

    if (Platform.isIOS) {
      // CallKit didActivate ke baad native phir category set kar sakta hai.
      for (final int ms in <int>[700, 1800]) {
        _warmupTimers.add(Timer(Duration(milliseconds: ms), () {
          if (_active) {
            unawaited(_enqueue(() => _applyRoute(currentRoute.value)));
          }
        }));
      }
    }
  }

  Future<void> updateCallType({required bool isVideo}) async {
    if (!_active) return;
    isVideoCall.value = isVideo;

    await _enqueue(() async {
      if (isVideo) {
        _cancelWarmupTimers();
        if (currentRoute.value == CallAudioRoute.earpiece) {
          _userSelectedRoute = false;
          await _applyRoute(CallAudioRoute.speaker);
          return;
        }
      }
      await _applyRoute(currentRoute.value);
    });
  }

  Future<void> selectRoute(CallAudioRoute route) async {
    if (!_active) return;

    if (route == CallAudioRoute.earpiece && isVideoCall.value) {
      route = CallAudioRoute.speaker;
    }

    await _enqueue(() async {
      await _scanDevices();

      if (route == CallAudioRoute.bluetooth && !isBluetoothConnected.value) {
        _log('bluetooth requested but not connected');
        return;
      }
      if (route == CallAudioRoute.headset && !isHeadsetConnected.value) {
        _log('headset requested but not connected');
        return;
      }

      _userSelectedRoute = true;
      await _applyRoute(route);
    });
  }

  Future<void> checkDevices() => _enqueue(_refreshInternal);

  Future<void> restoreCurrentRoute() async {
    if (!_active) return;
    await _enqueue(() async {
      await _scanDevices();
      await _applyRoute(currentRoute.value);
    });
  }

  Future<void> stopCall() async {
    _active = false;
    _userSelectedRoute = false;
    _cancelWarmupTimers();
    _deviceDebounce?.cancel();
    _deviceDebounce = null;

    await _devicesSub?.cancel();
    _devicesSub = null;
    await _interruptionSub?.cancel();
    _interruptionSub = null;

    await _enqueue(_cleanup);
  }

  Future<void> _cleanup() async {
    try {
      await ProximityScreenLock.setActive(false);
    } catch (_) {}

    if (Platform.isIOS) {
      await _iosInvoke('stopAudioRouteMonitoring', null);
      await _iosInvoke('resetAudioRoute', null);
    } else {
      try {
        await Helper.setSpeakerphoneOn(false);
      } catch (_) {}
    }

    _nativeActiveOutput = null;
    _isApplyingRoute = false;
  }

  // ───────────── Android listeners ─────────────
  Future<void> _listenAndroid() async {
    try {
      final AudioSession session = await AudioSession.instance;

      await _devicesSub?.cancel();
      _devicesSub = session.devicesChangedEventStream.listen(
        (AudioDevicesChangedEvent e) {
          if (e.devicesAdded.isEmpty && e.devicesRemoved.isEmpty) return;
          _scheduleRefresh();
        },
        onError: (Object e) => _log('devices stream error: $e'),
      );

      await _interruptionSub?.cancel();
      _interruptionSub = session.interruptionEventStream.listen(
        (AudioInterruptionEvent e) {
          if (!e.begin && _active) unawaited(restoreCurrentRoute());
        },
        onError: (Object e) => _log('interruption stream error: $e'),
      );
    } catch (e) {
      _log('listen error: $e');
    }
  }

  void _scheduleRefresh() {
    if (!_active) return;
    _deviceDebounce?.cancel();
    _deviceDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_enqueue(_refreshInternal));
    });
  }

  // ───────────── Device scan ─────────────
  bool _isBt(AudioDeviceType t) =>
      t == AudioDeviceType.bluetoothA2dp ||
      t == AudioDeviceType.bluetoothSco ||
      t == AudioDeviceType.bluetoothLe;

  bool _isWired(AudioDeviceType t) =>
      t == AudioDeviceType.wiredHeadset ||
      t == AudioDeviceType.wiredHeadphones ||
      t == AudioDeviceType.usbAudio;

  Future<void> _scanDevices() async {
    if (Platform.isIOS) {
      _applyNativeState(await _iosInvoke('getAudioState', null));
      return;
    }

    List<AudioDevice> devices;
    try {
      final AudioSession session = await AudioSession.instance;
      devices = (await session.getDevices()).toList();
    } catch (e) {
      _log('getDevices error: $e');
      return;
    }

    bool bt = false;
    bool wired = false;
    String btName = '';
    String wiredName = '';

    for (final AudioDevice d in devices) {
      final String name = d.name.trim();
      if (_isBt(d.type)) {
        bt = true;
        if (btName.isEmpty && name.isNotEmpty) btName = name;
      } else if (_isWired(d.type)) {
        wired = true;
        if (wiredName.isEmpty && name.isNotEmpty) wiredName = name;
      }
    }

    isBluetoothConnected.value = bt;
    bluetoothDeviceName.value = btName.isNotEmpty ? btName : 'Bluetooth';
    isHeadsetConnected.value = wired;
    headsetDeviceName.value = wiredName.isNotEmpty ? wiredName : 'Headset';
  }

  CallAudioRoute _autoRoute() {
    if (isBluetoothConnected.value) return CallAudioRoute.bluetooth;
    if (isHeadsetConnected.value) return CallAudioRoute.headset;
    return _defaultRoute;
  }

  Future<void> _refreshInternal() async {
    if (!_active) return;

    // iOS: connect/disconnect ka auto-switch native handle karta hai,
    // Dart sirf state refresh karta hai.
    if (Platform.isIOS) {
      await _scanDevices();
      final CallAudioRoute? actual = _routeFromNative(_nativeActiveOutput);
      if (actual != null && actual != currentRoute.value) {
        currentRoute.value = actual;
        await _applyProximity(actual);
      }
      update();
      return;
    }

    final bool prevBt = isBluetoothConnected.value;
    final bool prevHs = isHeadsetConnected.value;

    await _scanDevices();

    final bool bt = isBluetoothConnected.value;
    final bool hs = isHeadsetConnected.value;
    final CallAudioRoute cur = currentRoute.value;

    if (bt && !prevBt) {
      if (_userSelectedRoute && cur != CallAudioRoute.bluetooth) {
        _log('bluetooth connected, keeping $cur (user choice)');
      } else {
        await _applyRoute(CallAudioRoute.bluetooth);
      }
    } else if (hs && !prevHs) {
      if (_userSelectedRoute && cur != CallAudioRoute.headset) {
        _log('headset connected, keeping $cur (user choice)');
      } else {
        await _applyRoute(CallAudioRoute.headset);
      }
    } else if (!bt && prevBt && cur == CallAudioRoute.bluetooth) {
      _userSelectedRoute = false;
      await _applyRoute(hs ? CallAudioRoute.headset : _defaultRoute);
    } else if (!hs && prevHs && cur == CallAudioRoute.headset) {
      _userSelectedRoute = false;
      await _applyRoute(bt ? CallAudioRoute.bluetooth : _defaultRoute);
    } else if ((!bt && cur == CallAudioRoute.bluetooth) ||
        (!hs && cur == CallAudioRoute.headset)) {
      _userSelectedRoute = false;
      await _applyRoute(_autoRoute());
    } else if (_userSelectedRoute &&
        DateTime.now().difference(_lastApplyAt) >
            const Duration(milliseconds: 2500)) {
      // AudioSwitch BT ko khud pick kar sakta hai -> user ka choice dobara lagao.
      await _applyRoute(cur);
    }
  }

  // ───────────── Apply route ─────────────
  CallAudioRoute _sanitize(CallAudioRoute r) {
    if (r == CallAudioRoute.earpiece && isVideoCall.value) {
      return CallAudioRoute.speaker;
    }
    if (r == CallAudioRoute.bluetooth && !isBluetoothConnected.value) {
      return _autoRouteWithout(CallAudioRoute.bluetooth);
    }
    if (r == CallAudioRoute.headset && !isHeadsetConnected.value) {
      return _autoRouteWithout(CallAudioRoute.headset);
    }
    return r;
  }

  CallAudioRoute _autoRouteWithout(CallAudioRoute excluded) {
    if (excluded != CallAudioRoute.bluetooth && isBluetoothConnected.value) {
      return CallAudioRoute.bluetooth;
    }
    if (excluded != CallAudioRoute.headset && isHeadsetConnected.value) {
      return CallAudioRoute.headset;
    }
    return _defaultRoute;
  }

  Future<void> _applyRoute(CallAudioRoute requested) async {
    if (!_active) return;

    final CallAudioRoute target = _sanitize(requested);
    _isApplyingRoute = true;
    if (currentRoute.value != target) currentRoute.value = target;
    update();
    _lastApplyAt = DateTime.now();

    try {
      if (Platform.isAndroid) {
        await _applyAndroid(target);
      } else if (Platform.isIOS) {
        await _applyIos(target);
      }
      await _applyProximity(target);
    } catch (e) {
      _log('applyRoute($target) failed: $e');
    } finally {
      _isApplyingRoute = false;
      _lastApplyAt = DateTime.now();
      update();
    }
  }

  // ── iOS: sab kuch native ──
  Future<void> _applyIos(CallAudioRoute route) async {
    final Map<String, dynamic>? state = await _iosInvoke(
      'setAudioRoute',
      <String, dynamic>{
        'route': route.name,
        'isVideo': isVideoCall.value,
        'isManual': _userSelectedRoute,
        'force': true,
      },
    );
    _applyNativeState(state);

    final CallAudioRoute? actual = _routeFromNative(_nativeActiveOutput);
    if (actual != null && actual != route) {
      _log('iOS asked $route but native reports $actual');
    }
  }

  // ── Android: sirf Helper ──
  Future<void> _applyAndroid(CallAudioRoute route) async {
    final String? name = _androidOutputNames[route];
    if (name == null) return;

    try {
      if (route == CallAudioRoute.speaker) {
        await Helper.setSpeakerphoneOn(true);
        await Future<void>.delayed(const Duration(milliseconds: 90));
      } else if (route == CallAudioRoute.bluetooth) {
        await Helper.setSpeakerphoneOn(false);
        await Future<void>.delayed(const Duration(milliseconds: 90));
      }

      await Helper.selectAudioOutput(name);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!_active) return;
      await Helper.selectAudioOutput(name);

      Future<void>.delayed(const Duration(milliseconds: 800), () {
        if (_active && currentRoute.value == route) {
          unawaited(_enqueue(() async {
            if (_active && currentRoute.value == route) {
              await Helper.selectAudioOutput(name);
            }
          }));
        }
      });
    } catch (e) {
      _log('applyAndroid($route) error: $e');
    }
  }

  Future<void> _applyProximity(CallAudioRoute route) async {
    final bool enable = route == CallAudioRoute.earpiece && !isVideoCall.value;
    try {
      await ProximityScreenLock.setActive(enable);
    } catch (_) {}
  }

  @override
  void onClose() {
    unawaited(stopCall());
    super.onClose();
  }
}
