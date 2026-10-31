import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

enum CallAudioRoute { earpiece, speaker, bluetooth, headset }

class CallAudioRouteController extends GetxController {
  final Rx<CallAudioRoute> currentRoute = CallAudioRoute.earpiece.obs;
  final Rx<CallAudioRoute?> pendingRoute = Rx<CallAudioRoute?>(null);

  final RxBool isBluetoothConnected = false.obs;
  final RxString bluetoothDeviceName = 'Bluetooth'.obs;
  final RxBool isHeadsetConnected = false.obs;
  final RxString headsetDeviceName = 'Headset'.obs;
  final RxBool isVideoCall = false.obs;

  static int _generation = 0;

  int _myGeneration = 0;
  bool _isDisposed = false;
  bool _isCheckingDevices = false;
  bool _isApplyingRoute = false;
  bool _userSelectedRoute = false;
  bool _routeInitialized = false;
  bool _audioSessionReady = false;
  int _applySeq = 0;

  String? _bluetoothDeviceId;
  String? _wiredDeviceId;
  String? _speakerDeviceId;
  String? _earpieceDeviceId;
  String? _bluetoothInputDeviceId;
  String? _wiredInputDeviceId;
  String? _lastBluetoothName;

  StreamSubscription<Set<AudioDevice>>? _devicesSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  Timer? _deviceDebounce;
  Timer? _routeGuardTimer;
  bool _routeGuardBusy = false;
  int _routeGuardTicks = 0;
  final List<Timer> _warmupRouteTimers = <Timer>[];

  Future<void> _routeQueue = Future.value();

  void _log(String message) => debugPrint('[CallAudioRoute] $message');

  void _safeUpdate() {
    try {
      update();
    } catch (error) {
      _log('update error: $error');
    }
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

  bool get hasUserSelection => _userSelectedRoute;

  bool get isRouteTransitioning =>
      _isApplyingRoute && pendingRoute.value != null;

  CallAudioRoute get confirmedRoute => currentRoute.value;

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

  Future<void> startCall({required bool isVideo}) async {
    _myGeneration = ++_generation;
    _isDisposed = false;
    _userSelectedRoute = false;
    _routeInitialized = false;
    _lastBluetoothName = null;
    pendingRoute.value = null;
    _cancelWarmupTimers();
    isVideoCall.value = isVideo;
    currentRoute.value = _defaultRoute;

    _log(
      'startCall video=$isVideo default=$_defaultRoute build=commDevice-pin-v1',
    );

    await _resetNativeAudioForNewCall();

    await _listenAudioDevices();
    await _ensurePlaybackPath(forceSession: true);

    _startRouteGuard();

    final List<int> warmups = Platform.isIOS
        ? <int>[700, 1800]
        : <int>[900, 2500];
    for (final int ms in warmups) {
      _warmupRouteTimers.add(
        Timer(Duration(milliseconds: ms), () {
          if (!_isDisposed) {
            unawaited(_reassertCurrentRoute());
          }
        }),
      );
    }
  }

  Future<void> _resetNativeAudioForNewCall() async {
    if (!Platform.isAndroid) return;
    try {
      final AndroidAudioManager am = AndroidAudioManager();
      await am.stopBluetoothSco();
    } catch (_) {}
    try {
      final AndroidAudioManager am = AndroidAudioManager();
      await am.setBluetoothScoOn(false);
    } catch (_) {}
    try {
      final AndroidAudioManager am = AndroidAudioManager();
      await am.setSpeakerphoneOn(false);
    } catch (_) {}
    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}
    try {
      final AndroidAudioManager am = AndroidAudioManager();
      await am.clearCommunicationDevice();
    } catch (_) {}
    _log('native audio reset for new call (speakerphone off)');
  }

  void _startRouteGuard() {
    _routeGuardTimer?.cancel();
    _routeGuardTicks = 0;

    _routeGuardTimer = Timer.periodic(const Duration(milliseconds: 1500), (
        timer,
        ) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      _routeGuardTicks++;
      if (_routeGuardTicks > 12) {
        timer.cancel();
        _routeGuardTimer = null;
        return;
      }

      if (_isApplyingRoute || _routeGuardBusy) return;

      _routeGuardBusy = true;
      try {
        final CallAudioRoute want = currentRoute.value;

        if (Platform.isAndroid) {
          final bool ok = await _androidRouteMatches(want);
          if (!ok && !_isDisposed) {
            _log('guard: route drifted, re-applying $want');
            await _configureAudioSession(route: want);
            await _applyCurrentAudioRoute(want);
          } else if (!_isDisposed &&
              want == CallAudioRoute.speaker &&
              _routeGuardTicks <= 4) {
            _log('guard: speaker keep-alive tap');
            await _forceSpeakerNow();
            try {
              await Helper.selectAudioOutput('speaker');
            } catch (_) {}
          }
        } else if (Platform.isIOS &&
            _routeGuardTicks <= 6 &&
            _routeGuardTicks.isEven) {
          _log('guard: ios re-assert $want');
          await _applyCurrentAudioRoute(want);
        }
      } catch (error) {
        _log('guard error: $error');
      } finally {
        _routeGuardBusy = false;
      }
    });
  }

  Future<void> _reassertCurrentRoute() async {
    if (_isDisposed) return;
    _log('reassert route=${currentRoute.value}');
    await _ensurePlaybackPath(forceSession: true);
  }

  Future<void> updateCallType({required bool isVideo}) async {
    final bool wasVideo = isVideoCall.value;
    isVideoCall.value = isVideo;

    if (isVideo) {
      _cancelWarmupTimers();
    }
    if (wasVideo == isVideo && _routeInitialized) return;

    final CallAudioRoute keep = isVideo
        ? _preferredOnVideoUpgrade()
        : _preferredOnAudioDowngrade();
    _log(
      'updateCallType(video=$isVideo) keeps $keep (was ${currentRoute.value})',
    );

    await setRoute(keep);
  }

  CallAudioRoute _preferredOnVideoUpgrade() {
    final CallAudioRoute current = currentRoute.value;
    if (current == CallAudioRoute.bluetooth && isBluetoothConnected.value) {
      return current;
    }
    if (current == CallAudioRoute.headset && isHeadsetConnected.value) {
      return current;
    }
    if (_userSelectedRoute && current == CallAudioRoute.speaker) {
      return current;
    }
    if (isBluetoothConnected.value) return CallAudioRoute.bluetooth;
    if (isHeadsetConnected.value) return CallAudioRoute.headset;
    return CallAudioRoute.speaker;
  }

  CallAudioRoute _preferredOnAudioDowngrade() {
    final CallAudioRoute current = currentRoute.value;
    if (current == CallAudioRoute.bluetooth && isBluetoothConnected.value) {
      return current;
    }
    if (current == CallAudioRoute.headset && isHeadsetConnected.value) {
      return current;
    }
    if (_userSelectedRoute && current == CallAudioRoute.speaker) {
      return current;
    }
    if (isBluetoothConnected.value) return CallAudioRoute.bluetooth;
    return CallAudioRoute.earpiece;
  }

  Future<void> selectRoute(CallAudioRoute route) async {
    _log('selectRoute($route) disposed=$_isDisposed');
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

    _userSelectedRoute = true;
    await setRoute(route, userInitiated: true);
  }

  Future<void> checkDevices() => _refreshDevices(force: true);

  Future<void> onRemoteAudioTrack(MediaStreamTrack track) async {
    if (_isDisposed) return;

    try {
      track.enabled = true;
    } catch (_) {}

    if (Platform.isAndroid) {
      final bool speaker = currentRoute.value == CallAudioRoute.speaker;
      if (speaker) {
        await _forceSpeakerNow();
      }
      try {
        await Helper.selectAudioOutput(
          _androidOutputNameOf(currentRoute.value),
        );
      } catch (_) {}
      _log(
        'remote audio track -> route=${currentRoute.value} speaker=$speaker',
      );
    }

    if (Platform.isAndroid && currentRoute.value == CallAudioRoute.speaker) {
      _startSpeakerBurst();
    }

    await _ensurePlaybackPath(forceSession: true);
    _startRouteGuard();
  }

  Future<void> reapplyCurrentRoute() async {
    if (_isDisposed) return;
    _log('reapplyCurrentRoute ${currentRoute.value}');
    if (Platform.isAndroid && currentRoute.value == CallAudioRoute.speaker) {
      await _forceSpeakerNow();
    }
    await _ensurePlaybackPath(forceSession: true);
    _startRouteGuard();
  }

  Timer? _speakerBurstTimer;

  void _cancelSpeakerBurst() {
    _speakerBurstTimer?.cancel();
    _speakerBurstTimer = null;
  }

  void _startSpeakerBurst({int attempts = 10}) {
    if (!Platform.isAndroid) return;
    _cancelSpeakerBurst();

    int tick = 0;
    int confirmed = 0;
    _speakerBurstTimer = Timer.periodic(const Duration(milliseconds: 600), (
        timer,
        ) async {
      tick++;
      if (_isDisposed ||
          currentRoute.value != CallAudioRoute.speaker ||
          tick > attempts) {
        timer.cancel();
        _speakerBurstTimer = null;
        return;
      }

      await _forceSpeakerNow();

      bool on = false;
      AndroidAudioDeviceType? dev;
      try {
        final AndroidAudioManager am = AndroidAudioManager();
        on = await am.isSpeakerphoneOn();
        dev = (await am.getCommunicationDevice())?.type;
      } catch (_) {}

      final bool ok =
          on ||
              dev == AndroidAudioDeviceType.builtInSpeaker ||
              dev == AndroidAudioDeviceType.builtInSpeakerSafe;
      confirmed = ok ? confirmed + 1 : 0;

      _log(
        'speaker hold ${tick}/${attempts} ok=$ok speakerOn=$on commDevice=$dev',
      );

      if (confirmed >= 2 && tick >= 3) {
        _log('speaker hold confirmed at ${tick}/${attempts}');
        timer.cancel();
        _speakerBurstTimer = null;
      }
    });
  }

  Future<void> _forceSpeakerNow() async {
    final AndroidAudioManager am = AndroidAudioManager();
    try {
      await am.clearCommunicationDevice();
    } catch (_) {}
    try {
      await am.setMode(AndroidAudioHardwareMode.inCommunication);
    } catch (_) {}
    try {
      await am.setSpeakerphoneOn(true);
    } catch (_) {}
    try {
      await Helper.setSpeakerphoneOn(true);
    } catch (_) {}
    try {
      await Helper.selectAudioOutput('speaker');
    } catch (_) {}

    bool on = false;
    AndroidAudioHardwareMode mode = AndroidAudioHardwareMode.normal;
    AndroidAudioDeviceType? dev;
    try {
      on = await am.isSpeakerphoneOn();
    } catch (_) {}
    try {
      mode = await am.getMode();
    } catch (_) {}
    try {
      dev = (await am.getCommunicationDevice())?.type;
    } catch (_) {}
    _log('force speaker -> speakerOn=$on mode=$mode commDevice=$dev');
  }

  Future<void> restoreCurrentRoute() async {
    if (_isDisposed) return;
    await _refreshDevices(force: true);
    await _ensurePlaybackPath(forceSession: true);
  }

  Future<void> stopCall() async {
    _isDisposed = true;
    _userSelectedRoute = false;
    _routeInitialized = false;
    _lastBluetoothName = null;
    pendingRoute.value = null;
    _cancelWarmupTimers();
    _routeGuardTimer?.cancel();
    _routeGuardTimer = null;
    _cancelSpeakerBurst();
    _deviceDebounce?.cancel();
    _deviceDebounce = null;

    await _devicesSub?.cancel();
    _devicesSub = null;
    await _interruptionSub?.cancel();
    _interruptionSub = null;

    try {
      await ProximityScreenLock.setActive(false);
    } catch (_) {}

    if (_myGeneration != _generation) {
      _log('stopCall skipped global teardown (newer call owns audio)');
      _audioSessionReady = false;
      return;
    }

    try {
      if (Platform.isAndroid) {
        final AndroidAudioManager am = AndroidAudioManager();
        try {
          await am.stopBluetoothSco();
        } catch (_) {}
        try {
          await am.setBluetoothScoOn(false);
        } catch (_) {}
        try {
          await am.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await am.clearCommunicationDevice();
        } catch (_) {}
        try {
          await am.setMode(AndroidAudioHardwareMode.normal);
        } catch (_) {}
      }
      final AudioSession session = await AudioSession.instance;
      await session.setActive(false);
    } catch (_) {}

    currentRoute.value = CallAudioRoute.earpiece;
    isVideoCall.value = false;
    _audioSessionReady = false;
    _log('stopCall done (native reset for next call)');
  }

  CallAudioRoute _sanitizeRoute(CallAudioRoute route) {
    if (route == CallAudioRoute.earpiece && isVideoCall.value) {
      return CallAudioRoute.speaker;
    }
    if (route == CallAudioRoute.bluetooth && !isBluetoothConnected.value) {
      return isHeadsetConnected.value ? CallAudioRoute.headset : _defaultRoute;
    }
    if (route == CallAudioRoute.headset && !isHeadsetConnected.value) {
      return isBluetoothConnected.value
          ? CallAudioRoute.bluetooth
          : _defaultRoute;
    }
    return route;
  }

  Future<void> setRoute(CallAudioRoute route, {bool userInitiated = false}) {
    if (userInitiated) {
      _userSelectedRoute = true;
    }
    _routeQueue = _routeQueue
        .then((_) => _setRouteInternal(route, userInitiated: userInitiated))
        .catchError((Object error) {
      _log('setRoute($route) failed: $error');
    });
    return _routeQueue;
  }

  Future<void> _setRouteInternal(
      CallAudioRoute requested, {
        bool userInitiated = false,
      }) async {
    if (_isDisposed) return;

    final CallAudioRoute target = _sanitizeRoute(requested);
    final int seq = ++_applySeq;

    _isApplyingRoute = true;
    pendingRoute.value = target;
    _safeUpdate();

    try {
      _log('apply $target (requested=$requested user=$userInitiated)');

      await _configureAudioSession(route: target);
      await _applyCurrentAudioRoute(target);

      if (_isDisposed || seq != _applySeq) {
        _log('route $target dropped (stale seq=$seq current=$_applySeq)');
        return;
      }

      currentRoute.value = target;
      _routeInitialized = true;

      if (Platform.isAndroid && target == CallAudioRoute.speaker) {
        await _forceSpeakerNow();
        _startSpeakerBurst();
      } else {
        _cancelSpeakerBurst();
      }

      await _applyProximity(target);
      _startRouteGuard();
      _log('route now $target');
    } finally {
      if (seq == _applySeq) {
        _isApplyingRoute = false;
        pendingRoute.value = null;
      }
      _safeUpdate();
    }
  }

  Future<void> _applyProximity(CallAudioRoute route) async {
    final bool enable = route == CallAudioRoute.earpiece && !isVideoCall.value;
    try {
      await ProximityScreenLock.setActive(enable);
    } catch (_) {}
  }

  Future<void> _configureAudioSession({CallAudioRoute? route}) async {
    if (_isDisposed) return;
    final CallAudioRoute targetRoute = route ?? currentRoute.value;

    try {
      final AudioSession session = await AudioSession.instance;

      if (Platform.isIOS) {
        final bool wantsSpeaker = targetRoute == CallAudioRoute.speaker;
        final AVAudioSessionCategoryOptions options = wantsSpeaker
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
            androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          ),
        );
      }

      await session.setActive(true);
      _audioSessionReady = true;
      _log('session configured route=$targetRoute');
    } catch (error) {
      _audioSessionReady = false;
      _log('session configure error: $error');
    }
  }

  Future<void> _ensurePlaybackPath({bool forceSession = false}) async {
    if (_isDisposed) return;
    try {
      if (forceSession || !_audioSessionReady) {
        await _configureAudioSession(route: currentRoute.value);
      } else {
        try {
          final AudioSession session = await AudioSession.instance;
          await session.setActive(true);
        } catch (_) {}
      }

      await _applyCurrentAudioRoute(currentRoute.value);

      _log(
        'playback path ready route=${currentRoute.value} '
            'bt=${isBluetoothConnected.value} wired=${isHeadsetConnected.value}',
      );
    } catch (error) {
      _log('ensurePlaybackPath error: $error');
    }
  }

  Future<void> _applyCurrentAudioRoute(CallAudioRoute route) async {
    try {
      if (Platform.isAndroid) {
        await _applyAndroidRoute(route);
      } else if (Platform.isIOS) {
        await _applyIosRoute(route);
      }
    } catch (error) {
      _log('applyCurrentAudioRoute($route) error: $error');
    }
  }

  Future<void> _applyAndroidRoute(CallAudioRoute route) async {
    final AndroidAudioManager am = AndroidAudioManager();

    try {
      await am.setMode(AndroidAudioHardwareMode.inCommunication);
    } catch (_) {}

    switch (route) {
      case CallAudioRoute.speaker:
        try {
          await am.stopBluetoothSco();
        } catch (_) {}
        try {
          await am.setBluetoothScoOn(false);
        } catch (_) {}
        try {
          await am.clearCommunicationDevice();
        } catch (_) {}
        try {
          await am.setSpeakerphoneOn(true);
        } catch (error) {
          _log('speaker raw apply error: $error');
        }
        try {
          await Helper.setSpeakerphoneOn(true);
        } catch (error) {
          _log('speaker helper apply error: $error');
        }
        try {
          await Helper.selectAudioOutput('speaker');
        } catch (error) {
          _log('speaker selectAudioOutput error: $error');
        }
        await Future.delayed(const Duration(milliseconds: 150));
        try {
          await am.setMode(AndroidAudioHardwareMode.inCommunication);
        } catch (_) {}
        try {
          await am.setSpeakerphoneOn(true);
        } catch (_) {}
        try {
          await Helper.setSpeakerphoneOn(true);
        } catch (_) {}
        break;

      case CallAudioRoute.bluetooth:
        try {
          await am.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await am.startBluetoothSco();
          await Future.delayed(const Duration(milliseconds: 100));
          await am.setBluetoothScoOn(true);
        } catch (error) {
          _log('bluetooth sco error: $error');
        }
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
        } catch (_) {}
        try {
          await am.setBluetoothScoOn(false);
        } catch (_) {}
        try {
          await am.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.selectAudioOutput('wired-headset');
        } catch (error) {
          _log('headset apply error: $error');
        }
        break;

      case CallAudioRoute.earpiece:
        try {
          await am.stopBluetoothSco();
        } catch (_) {}
        try {
          await am.setBluetoothScoOn(false);
        } catch (_) {}
        try {
          await am.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.selectAudioOutput('earpiece');
        } catch (error) {
          _log('earpiece apply error: $error');
        }
        break;
    }

    await Future.delayed(const Duration(milliseconds: 120));

    bool ok = await _androidRouteMatches(route);
    _log('android apply -> $route matches=$ok');

    if (!ok) {
      _log('android route $route NOT applied, re-asserting once');
      await _reassertAndroidRoute(route);
      await Future.delayed(const Duration(milliseconds: 320));
      ok = await _androidRouteMatches(route);
      _log('android re-assert -> $route matches=$ok');
    }
  }

  Future<void> _reassertAndroidRoute(CallAudioRoute route) async {
    final AndroidAudioManager am = AndroidAudioManager();
    try {
      await am.setMode(AndroidAudioHardwareMode.inCommunication);
    } catch (_) {}

    final String deviceName = _androidOutputNameOf(route);

    if (route == CallAudioRoute.speaker) {
      try {
        await am.clearCommunicationDevice();
      } catch (_) {}
      try {
        await Helper.setSpeakerphoneOn(true);
      } catch (_) {}
      try {
        await am.setSpeakerphoneOn(true);
      } catch (_) {}
    } else {
      try {
        await Helper.setSpeakerphoneOn(false);
      } catch (_) {}
      try {
        await am.setSpeakerphoneOn(false);
      } catch (_) {}
      if (route == CallAudioRoute.bluetooth) {
        try {
          await am.startBluetoothSco();
          await Future.delayed(const Duration(milliseconds: 120));
          await am.setBluetoothScoOn(true);
        } catch (_) {}
      }
    }

    try {
      await Helper.selectAudioOutput(deviceName);
    } catch (error) {
      _log('re-assert selectAudioOutput($deviceName) error: $error');
    }

    if (route == CallAudioRoute.bluetooth) {
      try {
        await Helper.selectAudioInput('bluetooth');
      } catch (_) {}
    }
  }

  String _androidOutputNameOf(CallAudioRoute route) {
    switch (route) {
      case CallAudioRoute.speaker:
        return 'speaker';
      case CallAudioRoute.bluetooth:
        return 'bluetooth';
      case CallAudioRoute.headset:
        return 'wired-headset';
      case CallAudioRoute.earpiece:
        return 'earpiece';
    }
  }

  Future<CallAudioRoute?> _readAndroidRoute() async {
    if (!Platform.isAndroid) return null;
    try {
      final AndroidAudioManager am = AndroidAudioManager();

      bool speakerOn = false;
      try {
        speakerOn = await am.isSpeakerphoneOn();
      } catch (_) {}

      bool scoOn = false;
      try {
        scoOn = await am.isBluetoothScoOn();
      } catch (_) {}

      AndroidAudioDeviceType? devType;
      try {
        final AndroidAudioDeviceInfo? device = await am
            .getCommunicationDevice();
        devType = device?.type;
      } catch (_) {}

      AndroidAudioHardwareMode mode = AndroidAudioHardwareMode.normal;
      try {
        mode = await am.getMode();
      } catch (_) {}

      _log(
        'native state mode=$mode speakerOn=$speakerOn scoOn=$scoOn '
            'commDevice=$devType bt=${isBluetoothConnected.value} '
            'wired=${isHeadsetConnected.value}',
      );

      if (speakerOn) return CallAudioRoute.speaker;

      if (devType == AndroidAudioDeviceType.builtInSpeaker ||
          devType == AndroidAudioDeviceType.builtInSpeakerSafe) {
        return CallAudioRoute.speaker;
      }

      if (scoOn) return CallAudioRoute.bluetooth;

      if (devType == AndroidAudioDeviceType.bluetoothSco ||
          devType == AndroidAudioDeviceType.bluetoothA2dp) {
        return CallAudioRoute.bluetooth;
      }

      if (devType == AndroidAudioDeviceType.wiredHeadset ||
          devType == AndroidAudioDeviceType.wiredHeadphones ||
          devType == AndroidAudioDeviceType.usbHeadset ||
          devType == AndroidAudioDeviceType.usbDevice) {
        return CallAudioRoute.headset;
      }

      if (devType == AndroidAudioDeviceType.builtInEarpiece) {
        return CallAudioRoute.earpiece;
      }

      if (isHeadsetConnected.value) return CallAudioRoute.headset;
      if (isBluetoothConnected.value) return CallAudioRoute.bluetooth;
      return CallAudioRoute.earpiece;
    } catch (error) {
      _log('readAndroidRoute error: $error');
      return null;
    }
  }

  Future<bool> _androidRouteMatches(CallAudioRoute route) async {
    final CallAudioRoute? actual = await _readAndroidRoute();
    if (actual == null) return true;
    if (actual == route) return true;
    if (route == CallAudioRoute.bluetooth && actual == CallAudioRoute.headset) {
      return true;
    }
    _log('android mismatch expected=$route actual=$actual');
    return false;
  }

  Future<void> _applyIosRoute(CallAudioRoute route) async {
    switch (route) {
      case CallAudioRoute.speaker:
        try {
          await Helper.setSpeakerphoneOn(true);
        } catch (error) {
          _log('ios speaker error: $error');
        }
        if (_speakerDeviceId != null &&
            _speakerDeviceId!.isNotEmpty &&
            _speakerDeviceId != 'speaker') {
          try {
            await Helper.selectAudioOutput(_speakerDeviceId!);
          } catch (_) {}
        }
        break;

      case CallAudioRoute.bluetooth:
        try {
          await Helper.setSpeakerphoneOnButPreferBluetooth();
        } catch (_) {
          try {
            await Helper.setSpeakerphoneOn(false);
          } catch (_) {}
        }
        try {
          await Helper.selectAudioOutput(_bluetoothDeviceId ?? 'bluetooth');
        } catch (_) {}
        if (_bluetoothInputDeviceId != null) {
          try {
            await Helper.selectAudioInput(_bluetoothInputDeviceId!);
          } catch (_) {}
        }
        break;

      case CallAudioRoute.headset:
        try {
          await Helper.setSpeakerphoneOn(false);
          await Helper.selectAudioOutput(_wiredDeviceId ?? 'wired-headset');
        } catch (_) {}
        if (_wiredInputDeviceId != null) {
          try {
            await Helper.selectAudioInput(_wiredInputDeviceId!);
          } catch (_) {}
        }
        break;

      case CallAudioRoute.earpiece:
        try {
          await Helper.setSpeakerphoneOn(false);
          await Helper.selectAudioOutput(_earpieceDeviceId ?? 'earpiece');
        } catch (_) {}
        break;
    }

    await Future.delayed(const Duration(milliseconds: 120));
    _log('ios route applied -> $route');
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

  Future<void> _checkAudioDevices({bool isInitial = false}) async {
    if (_isDisposed || _isCheckingDevices) return;
    _isCheckingDevices = true;

    try {
      bool isBtFound = false;
      bool isWiredFound = false;
      String btName = _lastBluetoothName ?? 'Bluetooth';
      String headsetName = 'Headset';

      try {
        final List<MediaDeviceInfo> webrtcDevices = await navigator.mediaDevices
            .enumerateDevices();

        for (final MediaDeviceInfo d in webrtcDevices) {
          final String kind = (d.kind ?? '').toLowerCase();
          final String id = d.deviceId.toLowerCase();
          final String label = d.label.trim();

          final bool isInput = kind.contains('audioinput');
          final bool isOutput = kind.contains('audiooutput');

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
      } catch (error) {
        _log('WebRTC enumerateDevices error: $error');
      }

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

      if (isBtFound && btName.isNotEmpty) {
        _lastBluetoothName = btName;
      }

      final bool prevBT = isBluetoothConnected.value;
      final bool prevHS = isHeadsetConnected.value;

      isBluetoothConnected.value = isBtFound;
      bluetoothDeviceName.value = btName;
      isHeadsetConnected.value = isWiredFound;
      headsetDeviceName.value = headsetName;

      _log(
        'devices bt=$isBtFound($btName) wired=$isWiredFound($headsetName) '
            'initial=$isInitial',
      );

      if (isInitial && !_routeInitialized) {
        _routeInitialized = true;
        if (!_userSelectedRoute) {
          final CallAudioRoute initial = isBtFound
              ? CallAudioRoute.bluetooth
              : (isWiredFound ? CallAudioRoute.headset : _defaultRoute);
          await setRoute(initial);
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
          _log('bt connected, keeping ${currentRoute.value}');
        } else {
          await setRoute(CallAudioRoute.bluetooth);
        }
      } else if (wiredPlugged) {
        if (_userSelectedRoute &&
            currentRoute.value != CallAudioRoute.headset) {
          _log('wired connected, keeping ${currentRoute.value}');
        } else {
          await setRoute(CallAudioRoute.headset);
        }
      } else if (btUnplugged &&
          currentRoute.value == CallAudioRoute.bluetooth) {
        _userSelectedRoute = false;
        await setRoute(isWiredFound ? CallAudioRoute.headset : _defaultRoute);
      } else if (wiredUnplugged &&
          currentRoute.value == CallAudioRoute.headset) {
        _userSelectedRoute = false;
        await setRoute(isBtFound ? CallAudioRoute.bluetooth : _defaultRoute);
      } else {
        await _ensurePlaybackPath(forceSession: true);
      }
    } catch (error) {
      _log('checkAudioDevices error: $error');
    } finally {
      _isCheckingDevices = false;
    }
  }

  Future<void> _listenAudioDevices() async {
    try {
      final AudioSession session = await AudioSession.instance;

      await _devicesSub?.cancel();
      _devicesSub = session.devicesStream.listen(
            (_) => _scheduleDeviceRefresh(),
        onError: (Object error) => _log('devices stream error: $error'),
      );

      await _interruptionSub?.cancel();
      _interruptionSub = session.interruptionEventStream.listen((event) async {
        _log('interruption begin=${event.begin} type=${event.type}');
        if (!event.begin && !_isDisposed) {
          await _configureAudioSession(route: currentRoute.value);
          await _ensurePlaybackPath(forceSession: true);
        }
      });

      await _checkAudioDevices(isInitial: true);
    } catch (error) {
      _log('listenAudioDevices error: $error');
    }
  }

  void _scheduleDeviceRefresh() {
    if (_isDisposed) return;
    _deviceDebounce?.cancel();
    _deviceDebounce = Timer(const Duration(milliseconds: 160), () {
      unawaited(_checkAudioDevices());
    });
  }

  Future<void> _refreshDevices({bool force = false}) async {
    if (_isDisposed) return;
    await _checkAudioDevices();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _cancelWarmupTimers();
    _routeGuardTimer?.cancel();
    _routeGuardTimer = null;
    _cancelSpeakerBurst();
    _deviceDebounce?.cancel();
    unawaited(stopCall());
    super.onClose();
  }
}
