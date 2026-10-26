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
  static const MethodChannel _iosAudioChannel = MethodChannel(
    'com.fgtracker.audio_route',
  );

  static const Map<CallAudioRoute, String> _androidOutputNames =
  <CallAudioRoute, String>{
    CallAudioRoute.earpiece: 'earpiece',
    CallAudioRoute.speaker: 'speaker',
    CallAudioRoute.bluetooth: 'bluetooth',
    CallAudioRoute.headset: 'wired-headset',
  };

  final Rx<CallAudioRoute> currentRoute = CallAudioRoute.earpiece.obs;

  final RxBool isBluetoothConnected = false.obs;
  final RxString bluetoothDeviceName = 'Bluetooth'.obs;
  final RxBool isHeadsetConnected = false.obs;
  final RxString headsetDeviceName = 'Headset'.obs;
  final RxBool isVideoCall = false.obs;

  bool _isDisposed = false;
  bool _isCheckingDevices = false;
  bool _isApplyingRoute = false;
  bool _userSelectedRoute = false;
  int _applySeq = 0;
  bool _iosSessionActivated = false;
  String? _nativeActiveOutput;
  String? _lastBluetoothName;

  Future<void> _routeQueue = Future.value();

  StreamSubscription<AudioDevicesChangedEvent>? _devicesSub;
  Timer? _deviceDebounce;
  final List<Timer> _warmupRouteTimers = <Timer>[];

  void _log(String message) => debugPrint('[AudioRoute] $message');

  void _safeUpdate() {
    try {
      update();
    } catch (error) {
      _log('update error: $error');
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Platform.isIOS) {
      _iosAudioChannel.setMethodCallHandler(_handleNativeAudioEvent);
    }
  }

  Future<dynamic> _handleNativeAudioEvent(MethodCall call) async {
    if (call.method != 'onAudioRouteChanged') return null;
    if (_isDisposed) return null;

    final Map<String, dynamic>? state = (call.arguments as Map?)
        ?.cast<String, dynamic>();
    if (state == null) return null;

    _applyNativeState(state);

    if (!_isApplyingRoute) {
      final CallAudioRoute? actual = _nativeRoute();
      if (actual != null && actual != currentRoute.value) {
        _log('native route -> $actual');
        currentRoute.value = actual;
      }
      update();
    }
    return null;
  }

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

  bool get isSwitchingRoute => _isApplyingRoute;

  List<CallAudioRoute> get availableRoutes => <CallAudioRoute>[
    if (!isVideoCall.value) CallAudioRoute.earpiece,
    CallAudioRoute.speaker,
    if (isBluetoothConnected.value) CallAudioRoute.bluetooth,
    if (isHeadsetConnected.value) CallAudioRoute.headset,
  ];

  CallAudioRoute get _defaultRoute =>
      isVideoCall.value ? CallAudioRoute.speaker : CallAudioRoute.earpiece;

  void _cancelWarmupTimers() {
    for (final Timer timer in _warmupRouteTimers) {
      timer.cancel();
    }
    _warmupRouteTimers.clear();
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

  Future<void> startCall({required bool isVideo}) async {
    _isDisposed = false;
    _userSelectedRoute = false;
    _lastBluetoothName = null;
    _nativeActiveOutput = null;
    _cancelWarmupTimers();
    isVideoCall.value = isVideo;
    currentRoute.value = _defaultRoute;

    if (Platform.isIOS) {
      await _ensureIosSessionActive();
      await _invokeIosChannel('startAudioRouteMonitoring', <String, dynamic>{
        'isVideo': isVideo,
      });
    }

    await _listenAudioDevices();

    if (Platform.isIOS) {
      for (final int ms in <int>[700, 1800]) {
        _warmupRouteTimers.add(
          Timer(Duration(milliseconds: ms), () {
            if (!_isDisposed) {
              unawaited(_setRoute(currentRoute.value));
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
      if (currentRoute.value == CallAudioRoute.earpiece) {
        _userSelectedRoute = false;
        await _setRoute(CallAudioRoute.speaker);
        return;
      }
    }

    await _setRoute(currentRoute.value);
  }

  Future<void> selectRoute(CallAudioRoute route) async {
    _log(
      'selectRoute($route) disposed=$_isDisposed applying=$_isApplyingRoute',
    );
    if (_isDisposed) return;

    if (route == CallAudioRoute.earpiece && isVideoCall.value) {
      route = CallAudioRoute.speaker;
    }

    if (route == CallAudioRoute.bluetooth || route == CallAudioRoute.headset) {
      await _refreshDevices(force: true);

      final bool available = route == CallAudioRoute.bluetooth
          ? isBluetoothConnected.value
          : isHeadsetConnected.value;

      if (!available) {
        _log('$route requested but not connected');
        return;
      }
    }

    await _setRoute(route, userInitiated: true);
  }

  Future<void> checkDevices() => _refreshDevices(force: true);

  Future<void> restoreCurrentRoute() async {
    if (_isDisposed) return;
    await _refreshDevices(force: true);
    await _setRoute(currentRoute.value, force: true);
  }

  Future<void> stopCall() async {
    _isDisposed = true;
    _userSelectedRoute = false;
    _lastBluetoothName = null;
    _nativeActiveOutput = null;
    _isApplyingRoute = false;
    _cancelWarmupTimers();
    _deviceDebounce?.cancel();
    _deviceDebounce = null;

    await _devicesSub?.cancel();
    _devicesSub = null;

    try {
      await ProximityScreenLock.setActive(false);
    } catch (_) {}

    try {
      if (Platform.isAndroid) {
        final AndroidAudioManager am = AndroidAudioManager();
        try {
          await am.stopBluetoothSco();
          await am.setBluetoothScoOn(false);
          await am.setSpeakerphoneOn(false);
          await am.setMode(AndroidAudioHardwareMode.normal);
        } catch (_) {}
        try {
          final AudioSession session = await AudioSession.instance;
          await session.setActive(false);
        } catch (_) {}
      } else if (Platform.isIOS) {
        await _invokeIosChannel('stopAudioRouteMonitoring', null);
        await _invokeIosChannel('resetAudioRoute', null);
        final bool managedByCallKit = await _hasActiveIosCallKitSession();
        if (!managedByCallKit && _iosSessionActivated) {
          try {
            final AudioSession session = await AudioSession.instance;
            await session.setActive(false);
          } catch (_) {}
        }
        _iosSessionActivated = false;
      }
    } catch (_) {}
  }

  CallAudioRoute _sanitizeRoute(CallAudioRoute route) {
    if (route == CallAudioRoute.earpiece && isVideoCall.value) {
      return CallAudioRoute.speaker;
    }
    if (route == CallAudioRoute.bluetooth && !isBluetoothConnected.value) {
      return _defaultRoute;
    }
    if (route == CallAudioRoute.headset && !isHeadsetConnected.value) {
      return _defaultRoute;
    }
    return route;
  }

  Future<void> _setRoute(
      CallAudioRoute route, {
        bool userInitiated = false,
        bool force = false,
      }) {
    if (userInitiated) {
      _userSelectedRoute = true;
    }
    _routeQueue = _routeQueue
        .then(
          (_) => _setRouteInternal(
        route,
        userInitiated: userInitiated,
        force: force,
      ),
    )
        .catchError((Object error) {
      _log('setRoute($route) failed: $error');
    });
    return _routeQueue;
  }

  Future<void> _setRouteInternal(
      CallAudioRoute requested, {
        bool userInitiated = false,
        bool force = false,
      }) async {
    if (_isDisposed) return;

    final CallAudioRoute target = _sanitizeRoute(requested);
    _isApplyingRoute = true;
    try {
      if (currentRoute.value != target) {
        currentRoute.value = target;
      }
      _safeUpdate();

      if (Platform.isIOS) {
        await _applyIosRoute(
          target,
          userInitiated: userInitiated,
          force: force,
        );
        final CallAudioRoute? confirmed = _nativeRoute();
        if (confirmed != null && confirmed != currentRoute.value) {
          _log('device reported $confirmed');
          currentRoute.value = confirmed;
        }
      } else if (Platform.isAndroid) {
        await _applyAndroidRoute(target);
      }

      await _applyProximity(currentRoute.value);
    } finally {
      _isApplyingRoute = false;
      _safeUpdate();
    }
  }

  Future<void> _applyProximity(CallAudioRoute route) async {
    final bool enable = route == CallAudioRoute.earpiece && !isVideoCall.value;
    try {
      await ProximityScreenLock.setActive(enable);
    } catch (_) {}
  }

  Future<void> _applyIosRoute(
      CallAudioRoute route, {
        required bool userInitiated,
        required bool force,
      }) async {
    final Map<String, dynamic>? applied = await _invokeIosChannel(
      'setAudioRoute',
      <String, dynamic>{
        'route': route.name,
        'isVideo': isVideoCall.value,
        'isManual': userInitiated,
        'force': force,
      },
    );
    _applyNativeState(applied);

    await Future.delayed(const Duration(milliseconds: 220));
    if (_isDisposed) return;

    final Map<String, dynamic>? state = await _invokeIosChannel(
      'getAudioState',
      null,
    );
    _applyNativeState(state);

    final CallAudioRoute? actual = _nativeRoute();
    if (actual == null || actual == route || force) return;

    final Map<String, dynamic>? retried = await _invokeIosChannel(
      'setAudioRoute',
      <String, dynamic>{
        'route': route.name,
        'isVideo': isVideoCall.value,
        'isManual': userInitiated,
        'force': true,
      },
    );
    _applyNativeState(retried);

    await Future.delayed(const Duration(milliseconds: 220));
    if (_isDisposed) return;

    final Map<String, dynamic>? confirm = await _invokeIosChannel(
      'getAudioState',
      null,
    );
    _applyNativeState(confirm);
  }

  Future<void> _applyAndroidRoute(CallAudioRoute route) async {
    final String? outputName = _androidOutputNames[route];
    if (outputName == null) return;

    final int seq = ++_applySeq;

    try {
      await _rankAndroidOutput(route);
      if (_isDisposed || seq != _applySeq) return;

      await Helper.selectAudioOutput(outputName);
      await Future.delayed(const Duration(milliseconds: 150));
      if (_isDisposed || seq != _applySeq) return;

      bool matched = await _androidRouteMatches(route);
      _log('android route $route -> $outputName matched=$matched');

      if (!matched) {
        _log('android route $route not applied, re-asserting');
        await _rankAndroidOutput(route);
        if (_isDisposed || seq != _applySeq) return;

        await Helper.selectAudioOutput(outputName);
        await Future.delayed(const Duration(milliseconds: 200));
        if (_isDisposed || seq != _applySeq) return;

        matched = await _androidRouteMatches(route);
        _log('android route $route re-assert matched=$matched');
      }
    } catch (error) {
      _log('applyAndroidRoute($route) error: $error');
    }
  }

  Future<void> _rankAndroidOutput(CallAudioRoute route) async {
    if (route == CallAudioRoute.speaker) {
      await Helper.setSpeakerphoneOn(true);
    } else if (route == CallAudioRoute.headset &&
        (isBluetoothConnected.value || isHeadsetConnected.value)) {
      await Helper.setSpeakerphoneOnButPreferBluetooth();
    } else {
      await Helper.setSpeakerphoneOn(false);
    }
    await Future.delayed(const Duration(milliseconds: 90));
  }

  Future<bool> _androidRouteMatches(CallAudioRoute route) async {
    try {
      final AndroidAudioManager manager = AndroidAudioManager();
      final bool speakerOn = await manager.isSpeakerphoneOn();

      if (route == CallAudioRoute.speaker) return speakerOn;
      if (route == CallAudioRoute.bluetooth) {
        if (speakerOn) return false;
        final bool scoOn = await manager.isBluetoothScoOn();
        return scoOn || !speakerOn;
      }
      return !speakerOn;
    } catch (_) {
      return true;
    }
  }

  Future<void> _ensureIosSessionActive() async {
    if (!Platform.isIOS) return;

    final bool managedByCallKit = await _hasActiveIosCallKitSession();
    if (managedByCallKit) {
      _iosSessionActivated = true;
      return;
    }

    try {
      final AudioSession session = await AudioSession.instance;
      final bool active = await session.setActive(true);
      _iosSessionActivated = active;
    } catch (error) {
      _log('iOS setActive failed: $error');
      _iosSessionActivated = false;
    }
  }

  Future<Map<String, dynamic>?> _invokeIosChannel(
      String method,
      Map<String, dynamic>? arguments,
      ) async {
    try {
      return await _iosAudioChannel.invokeMapMethod<String, dynamic>(
        method,
        arguments,
      );
    } catch (error) {
      _log('iOS channel $method failed: $error');
      return null;
    }
  }

  CallAudioRoute? _nativeRoute() => _routeFromNativeName(_nativeActiveOutput);

  CallAudioRoute? _routeFromNativeName(Object? raw) {
    switch ((raw ?? '').toString().trim().toLowerCase()) {
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

    final String activeOutput = (state['activeOutput'] ?? '').toString().trim();
    if (activeOutput.isNotEmpty) {
      _nativeActiveOutput = activeOutput;
    }

    if (state['isBluetoothConnected'] is bool) {
      isBluetoothConnected.value = state['isBluetoothConnected'] as bool;
    }

    final String btName = (state['bluetoothName'] ?? '').toString().trim();
    if (btName.isNotEmpty) {
      bluetoothDeviceName.value = btName;
      _lastBluetoothName = btName;
    }

    if (state['isHeadsetConnected'] is bool) {
      isHeadsetConnected.value = state['isHeadsetConnected'] as bool;
    }

    final String hsName = (state['headsetName'] ?? '').toString().trim();
    if (hsName.isNotEmpty) {
      headsetDeviceName.value = hsName;
    }
  }

  Future<void> _listenAudioDevices() async {
    try {
      final AudioSession session = await AudioSession.instance;

      await _devicesSub?.cancel();
      _devicesSub = session.devicesChangedEventStream.listen((
          AudioDevicesChangedEvent event,
          ) {
        if (event.devicesAdded.isEmpty && event.devicesRemoved.isEmpty) {
          return;
        }
        _scheduleDeviceRefresh();
      }, onError: (Object error) => _log('devices stream error: $error'));

      await _refreshDevices(force: true);
    } catch (error) {
      _log('listenAudioDevices error: $error');
    }
  }

  void _scheduleDeviceRefresh() {
    if (_isDisposed || _isApplyingRoute) return;
    _deviceDebounce?.cancel();
    _deviceDebounce = Timer(const Duration(milliseconds: 140), () {
      unawaited(_refreshDevices());
    });
  }

  Future<void> _refreshDevices({bool force = false}) async {
    if (_isDisposed || _isCheckingDevices) return;

    _isCheckingDevices = true;
    try {
      if (Platform.isIOS) {
        final Map<String, dynamic>? state = await _invokeIosChannel(
          'getAudioState',
          null,
        );
        _applyNativeState(state);
        return;
      }
      await _scanAndroidDevices(isInitial: force);
    } catch (error) {
      _log('refreshDevices error: $error');
    } finally {
      _isCheckingDevices = false;
    }
  }

  bool _isBluetoothLabel(String label, String id) {
    final String l = label.toLowerCase().trim();
    final String i = id.toLowerCase().trim();
    if (l.isEmpty && i.isEmpty) return false;

    return l.contains('bluetooth') ||
        l.contains('airpods') ||
        l.contains('beats') ||
        l.contains('buds') ||
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
    final String l = label.toLowerCase().trim();
    final String i = id.toLowerCase().trim();
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

  Future<void> _scanAndroidDevices({required bool isInitial}) async {
    bool isBtFound = false;
    bool isWiredFound = false;
    String btName = _lastBluetoothName ?? 'Bluetooth';
    String headsetName = 'Headset';

    try {
      final AudioSession session = await AudioSession.instance;
      final Iterable<AudioDevice> devices = await session.getDevices();

      for (final AudioDevice d in devices) {
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
    } catch (error) {
      _log('AudioSession getDevices error: $error');
    }

    try {
      final List<MediaDeviceInfo> webrtcDevices = await navigator.mediaDevices
          .enumerateDevices();

      for (final MediaDeviceInfo d in webrtcDevices) {
        final String id = d.deviceId.toLowerCase();
        final String label = d.label.trim();
        if (_isBluetoothLabel(label, id)) {
          isBtFound = true;
          if (label.isNotEmpty &&
              !label.toLowerCase().contains('unknown') &&
              btName == 'Bluetooth') {
            btName = label;
          }
        } else if (_isWiredLabel(label, id)) {
          isWiredFound = true;
          if (label.isNotEmpty &&
              !label.toLowerCase().contains('unknown') &&
              headsetName == 'Headset') {
            headsetName = label;
          }
        }
      }
    } catch (error) {
      _log('WebRTC enumerateDevices error: $error');
    }

    if (isBtFound && btName.isNotEmpty) {
      _lastBluetoothName = btName;
    }

    final bool prevBT = isBluetoothConnected.value;
    final bool prevHS = isHeadsetConnected.value;

    isBluetoothConnected.value = isBtFound;
    bluetoothDeviceName.value = btName;
    isHeadsetConnected.value = isWiredFound;
    headsetDeviceName.value = headsetName;

    if (isInitial) {
      if (!_userSelectedRoute) {
        await _setRoute(
          isBtFound
              ? CallAudioRoute.bluetooth
              : (isWiredFound ? CallAudioRoute.headset : _defaultRoute),
        );
      }
      return;
    }

    final bool btPlugged = isBtFound && !prevBT;
    final bool wiredPlugged = isWiredFound && !prevHS;
    final bool btUnplugged = !isBtFound && prevBT;
    final bool wiredUnplugged = !isWiredFound && prevHS;

    if (btPlugged) {
      if (_userSelectedRoute &&
          currentRoute.value != CallAudioRoute.bluetooth) {
        _log('bluetooth connected, keeping ${currentRoute.value}');
      } else {
        await _setRoute(CallAudioRoute.bluetooth);
      }
    } else if (wiredPlugged) {
      if (_userSelectedRoute && currentRoute.value != CallAudioRoute.headset) {
        _log('headset connected, keeping ${currentRoute.value}');
      } else {
        await _setRoute(CallAudioRoute.headset);
      }
    } else if (btUnplugged && currentRoute.value == CallAudioRoute.bluetooth) {
      _userSelectedRoute = false;
      await _setRoute(isWiredFound ? CallAudioRoute.headset : _defaultRoute);
    } else if (wiredUnplugged && currentRoute.value == CallAudioRoute.headset) {
      _userSelectedRoute = false;
      await _setRoute(isBtFound ? CallAudioRoute.bluetooth : _defaultRoute);
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _cancelWarmupTimers();
    _deviceDebounce?.cancel();
    unawaited(stopCall());
    super.onClose();
  }
}
