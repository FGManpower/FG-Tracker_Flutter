import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

enum CallAudioRoute { earpiece, speaker, bluetooth, headset }

/// Pure-Dart in-call audio routing (no platform channels).
///
/// Android: routing ONLY via flutter_webrtc Helper (AudioSwitch owns the
///          session, so we must not touch AudioManager mode/SCO ourselves).
/// iOS    : speaker override + preferred input via Helper; if the OS still
///          keeps Bluetooth after earpiece/headset is chosen, BT HFP is
///          blocked via the category options until the user picks BT again.
/// Both   : audio_session is used for device detection + interruptions.
class CallAudioRouteController extends GetxController {
  static const Map<CallAudioRoute, String> _androidOutputNames =
  <CallAudioRoute, String>{
    CallAudioRoute.earpiece: 'earpiece',
    CallAudioRoute.speaker: 'speaker',
    CallAudioRoute.bluetooth: 'bluetooth',
    CallAudioRoute.headset: 'wired-headset',
  };

  // ───────────────────────── Public state ─────────────────────────
  final Rx<CallAudioRoute> currentRoute = CallAudioRoute.earpiece.obs;

  final RxBool isBluetoothConnected = false.obs;
  final RxString bluetoothDeviceName = 'Bluetooth'.obs;
  final RxBool isHeadsetConnected = false.obs;
  final RxString headsetDeviceName = 'Headset'.obs;
  final RxBool isVideoCall = false.obs;

  // ───────────────────────── Private state ────────────────────────
  bool _active = false;
  bool _userSelectedRoute = false;
  bool _sessionActivatedByUs = false;
  bool _iosBtBlocked = false; // iOS: allowBluetooth removed from category
  DateTime _lastApplyAt = DateTime.fromMillisecondsSinceEpoch(0);
  List<AudioDevice> _devices = const <AudioDevice>[];

  Future<void> _queue = Future<void>.value();

  StreamSubscription<AudioDevicesChangedEvent>? _devicesSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  Timer? _deviceDebounce;
  final List<Timer> _warmupTimers = <Timer>[];

  void _log(String m) => debugPrint('[AudioRoute] $m');

  // ───────────────────────── UI helpers ───────────────────────────
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

  // ───────────────────────── Queue ────────────────────────────────
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

  // ───────────────────────── Lifecycle ────────────────────────────
  Future<void> startCall({required bool isVideo}) async {
    _active = true;
    _userSelectedRoute = false;
    _iosBtBlocked = false;
    _cancelWarmupTimers();
    isVideoCall.value = isVideo;
    currentRoute.value = _defaultRoute;

    await _configureSession(isVideo);
    await _activateSession();
    await _listen();

    await _enqueue(() async {
      await _scanDevices();
      await _applyRoute(_autoRoute());
    });

    if (Platform.isIOS) {
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
    await _configureSession(isVideo);

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

    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}

    if (Platform.isIOS) {
      // Restore BT permission for the next call / the rest of the app.
      if (_iosBtBlocked) {
        try {
          await _iosSetBtBlocked(false);
        } catch (_) {}
      }
      final bool byCallKit = await _hasActiveIosCallKitSession();
      if (!byCallKit && _sessionActivatedByUs) {
        try {
          final AudioSession s = await AudioSession.instance;
          await s.setActive(false);
        } catch (_) {}
      }
    }

    _sessionActivatedByUs = false;
    _iosBtBlocked = false;
    _devices = const <AudioDevice>[];
  }

  // ───────────────────────── Session setup ────────────────────────
  Future<void> _configureSession(bool isVideo) async {
    if (!Platform.isIOS) return; // Android: WebRTC/AudioSwitch owns it.
    try {
      final AudioSession session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.allowBluetoothA2dp,
          avAudioSessionMode: isVideo
              ? AVAudioSessionMode.videoChat
              : AVAudioSessionMode.voiceChat,
        ),
      );
      // Re-assert our BT allow/block state (configure resets options).
      await _iosSetBtBlocked(_iosBtBlocked);
    } catch (e) {
      _log('configure failed: $e');
    }
  }

  Future<void> _activateSession() async {
    if (!Platform.isIOS) return;
    if (await _hasActiveIosCallKitSession()) {
      _sessionActivatedByUs = false; // CallKit owns activation.
      return;
    }
    try {
      final AudioSession s = await AudioSession.instance;
      _sessionActivatedByUs = await s.setActive(true);
    } catch (e) {
      _log('setActive failed: $e');
      _sessionActivatedByUs = false;
    }
  }

  Future<bool> _hasActiveIosCallKitSession() async {
    if (!Platform.isIOS) return false;
    try {
      final dynamic calls = await FlutterCallkitIncoming.activeCalls();
      return calls is List && calls.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// iOS only. blocked=true removes allowBluetooth so the OS cannot keep
  /// routing to a Bluetooth HFP device.
  Future<void> _iosSetBtBlocked(bool blocked) async {
    await Helper.setAppleAudioConfiguration(
      AppleAudioConfiguration(
        appleAudioCategory: AppleAudioCategory.playAndRecord,
        appleAudioCategoryOptions: <AppleAudioCategoryOption>{
          if (!blocked) AppleAudioCategoryOption.allowBluetooth,
          if (!blocked) AppleAudioCategoryOption.allowBluetoothA2DP,
        },
        appleAudioMode: isVideoCall.value
            ? AppleAudioMode.videoChat
            : AppleAudioMode.voiceChat,
      ),
    );
    _iosBtBlocked = blocked;
    _log('iOS bluetooth ${blocked ? "BLOCKED" : "allowed"}');
  }

  // ───────────────────────── Listeners ────────────────────────────
  Future<void> _listen() async {
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
          if (!e.begin && _active) {
            unawaited(() async {
              await _activateSession();
              await restoreCurrentRoute();
            }());
          }
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

  // ───────────────────────── Device scan ──────────────────────────
  bool _isBt(AudioDeviceType t) =>
      t == AudioDeviceType.bluetoothA2dp ||
          t == AudioDeviceType.bluetoothSco ||
          t == AudioDeviceType.bluetoothLe;

  bool _isWired(AudioDeviceType t) =>
      t == AudioDeviceType.wiredHeadset ||
          t == AudioDeviceType.wiredHeadphones ||
          t == AudioDeviceType.usbAudio;

  Future<void> _reloadDevices() async {
    try {
      final AudioSession session = await AudioSession.instance;
      _devices = (await session.getDevices()).toList();
    } catch (e) {
      _log('getDevices error: $e');
    }
  }

  Future<void> _scanDevices() async {
    try {
      final AudioSession session = await AudioSession.instance;
      _devices = (await session.getDevices()).toList();
    } catch (e) {
      _log('getDevices error: $e');
      return; // keep previous state
    }

    bool bt = false;
    bool wired = false;
    String btName = '';
    String wiredName = '';

    for (final AudioDevice d in _devices) {
      final String name = d.name.trim();
      if (_isBt(d.type)) {
        bt = true;
        if (btName.isEmpty && name.isNotEmpty) btName = name;
      } else if (_isWired(d.type)) {
        wired = true;
        if (wiredName.isEmpty && name.isNotEmpty) wiredName = name;
      }
    }

    // iOS: while BT is blocked it can't appear in the list, so keep the last
    // known state instead of wrongly reporting "disconnected".
    if (Platform.isIOS && _iosBtBlocked) {
      bt = isBluetoothConnected.value;
      btName = bluetoothDeviceName.value == 'Bluetooth'
          ? ''
          : bluetoothDeviceName.value;
    }

    isBluetoothConnected.value = bt;
    if (btName.isNotEmpty || !bt) {
      bluetoothDeviceName.value = btName.isNotEmpty ? btName : 'Bluetooth';
    }
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
    } else if (DateTime.now().difference(_lastApplyAt) >
        const Duration(milliseconds: 2500)) {
      // Only react to "unrelated" device events once our own route change
      // has settled, otherwise we'd fight ourselves.
      if (Platform.isIOS) {
        final CallAudioRoute? actual = _iosActiveRoute();
        if (actual != null && actual != cur) {
          _log('iOS route changed externally -> $actual');
          currentRoute.value = actual;
          await _applyProximity(actual);
        }
      } else if (Platform.isAndroid && _userSelectedRoute) {
        // AudioSwitch may re-pick Bluetooth on its own; re-assert user choice.
        await _applyRoute(cur);
      }
    }
  }

  // ───────────────────────── Apply route ──────────────────────────
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

    CallAudioRoute target = _sanitize(requested);
    if (currentRoute.value != target) currentRoute.value = target;
    update();
    _lastApplyAt = DateTime.now();

    try {
      if (Platform.isAndroid) {
        await _applyAndroid(target);
      } else if (Platform.isIOS) {
        target = await _applyIos(target);
        if (currentRoute.value != target) currentRoute.value = target;
      }
      await _applyProximity(target);
    } catch (e) {
      _log('applyRoute($target) failed: $e');
    } finally {
      _lastApplyAt = DateTime.now();
      update();
    }
  }

  // ── Android ──────────────────────────────────────────────────────
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
      // Second select: AudioSwitch sometimes re-evaluates (prefers BT) right
      // after the first call; selecting again makes the choice stick.
      await Helper.selectAudioOutput(name);

      // One delayed re-assert for late SCO / device-list callbacks.
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

  // ── iOS ──────────────────────────────────────────────────────────
  bool get _iosOutputIsBt =>
      _devices.any((AudioDevice d) => d.isOutput && _isBt(d.type));

  /// Returns the route that is actually in effect.
  Future<CallAudioRoute> _applyIos(CallAudioRoute route) async {
    // Going back to Bluetooth: let HFP in again first.
    if (route == CallAudioRoute.bluetooth && _iosBtBlocked) {
      await _iosSetBtBlocked(false);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await _scanDevices();
      route = _sanitize(route); // BT may have been disconnected meanwhile
    }

    await Helper.setSpeakerphoneOn(route == CallAudioRoute.speaker);
    if (route == CallAudioRoute.speaker) return route;

    final AudioDevice? input = _iosInputFor(route);
    if (input != null) {
      try {
        await Helper.selectAudioInput(input.id);
      } catch (e) {
        _log('selectAudioInput failed: $e');
      }
    }

    // Earpiece / wired: confirm the OS really left Bluetooth.
    if (route != CallAudioRoute.bluetooth) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!_active) return route;
      await _reloadDevices();

      if (_iosOutputIsBt) {
        _log('output still on Bluetooth after $route, blocking BT');
        await _iosSetBtBlocked(true);
        await Future<void>.delayed(const Duration(milliseconds: 350));
        await Helper.setSpeakerphoneOn(false);
        await _reloadDevices();
      }
    }
    return route;
  }

  AudioDevice? _iosInputFor(CallAudioRoute route) {
    for (final AudioDevice d in _devices) {
      if (!d.isInput) continue;
      switch (route) {
        case CallAudioRoute.bluetooth:
          if (_isBt(d.type)) return d;
          break;
        case CallAudioRoute.headset:
          if (_isWired(d.type)) return d;
          break;
        case CallAudioRoute.earpiece:
          if (!_isBt(d.type) && !_isWired(d.type)) return d; // built-in mic
          break;
        case CallAudioRoute.speaker:
          break;
      }
    }
    return null;
  }

  CallAudioRoute? _iosActiveRoute() {
    final Iterable<AudioDevice> outs = _devices.where((d) => d.isOutput);
    if (outs.isEmpty) return null;
    if (outs.any((d) => _isBt(d.type))) return CallAudioRoute.bluetooth;
    if (outs.any((d) => _isWired(d.type))) return CallAudioRoute.headset;
    if (outs.any((d) => d.type == AudioDeviceType.builtInSpeaker)) {
      return CallAudioRoute.speaker;
    }
    return CallAudioRoute.earpiece;
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