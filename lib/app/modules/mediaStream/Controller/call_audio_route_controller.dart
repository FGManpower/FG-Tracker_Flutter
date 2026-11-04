import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
enum CallAudioRoute { earpiece, speaker, bluetooth, headset }

class CallAudioRouteController extends GetxController
    with WidgetsBindingObserver {
  static final Rx<CallAudioRoute> _sharedRoute = CallAudioRoute.earpiece.obs;
  static final RxBool _sharedIsVideo = false.obs;
  static final RxBool _sharedBluetooth = false.obs;
  static final RxBool _sharedWired = false.obs;
  static final List<MediaStreamTrack> _remoteAudioTracks = <MediaStreamTrack>[];

  static int _generation = 0;

  static int _androidSdkCache = 0;
  static bool _userSelectedRoute = false;
  static bool _routeOwnerActive = false;

  Rx<CallAudioRoute> get currentRoute => _sharedRoute;
  RxBool get isVideoCall => _sharedIsVideo;
  RxBool get isBluetoothConnected => _sharedBluetooth;
  RxBool get isHeadsetConnected => _sharedWired;
  final Rx<CallAudioRoute?> pendingRoute = Rx<CallAudioRoute?>(null);

  int _myGeneration = 0;
  bool _isDisposed = false;
  bool _ownsAudio = false;
  bool _isIncomingCall = false;
  bool _isApplyingRoute = false;
  bool _routeInitialized = false;
  bool _audioSessionReady = false;
  bool _keeperRunning = false;
  int _keeperAttempt = 0;
  int _keeperStreak = 0;

  bool _hasSpeaker = true;
  bool _hasEarpiece = true;
  String _bluetoothName = 'Bluetooth';
  String _wiredName = 'Headphones';

  StreamSubscription<Set<AudioDevice>>? _devicesSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  Timer? _deviceDebounce;
  Timer? _keeperTimer;
  Timer? _driftTimer;
  final List<Timer> _warmupRouteTimers = <Timer>[];

  Future<void> _routeQueue = Future.value();

  void _log(String message) => AppLog.d('[CallAudioRoute] $message');

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
        return _bluetoothName;
      case CallAudioRoute.headset:
        return _wiredName;
      case CallAudioRoute.speaker:
        return 'Speaker';
      case CallAudioRoute.earpiece:
        return 'Earpiece';
    }
  }

  String get bluetoothDeviceName => _bluetoothName;

  String get wiredDeviceName => _wiredName;

  bool get isSpeakerOn => currentRoute.value == CallAudioRoute.speaker;

  int get _androidSdk {
    if (_androidSdkCache == 0) {
      final RegExpMatch? match =
          RegExp(r'SDK (\d+)').firstMatch(Platform.operatingSystemVersion);
      _androidSdkCache = int.tryParse(match?.group(1) ?? '') ?? 0;
    }
    return _androidSdkCache;
  }

  bool get isSwitchingRoute => _isApplyingRoute;

  bool get hasUserSelection => _userSelectedRoute;

  bool get isRouteTransitioning =>
      _isApplyingRoute && pendingRoute.value != null;

  CallAudioRoute get confirmedRoute => currentRoute.value;

  List<CallAudioRoute> get availableRoutes => <CallAudioRoute>[
        if (!isVideoCall.value && _hasEarpiece) CallAudioRoute.earpiece,
        if (_hasSpeaker) CallAudioRoute.speaker,
        if (isBluetoothConnected.value) CallAudioRoute.bluetooth,
        if (isHeadsetConnected.value) CallAudioRoute.headset,
      ];

  CallAudioRoute get _defaultRoute =>
      isVideoCall.value ? CallAudioRoute.speaker : CallAudioRoute.earpiece;

  Future<void> prepareCall({required bool isVideo}) async {
    if (!Platform.isAndroid || _isDisposed) return;
    try {
      await _configureAndroidAudioSwitch();

      final AudioSession session = await AudioSession.instance;
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

      final AndroidAudioManager am = AndroidAudioManager();
      await am.setMode(AndroidAudioHardwareMode.inCommunication);
      final bool active = await session.setActive(true);
      _audioSessionReady = active;
      _log(
        'prepareCall video=$isVideo mode=inCommunication '
        'active=$active sdk=$_androidSdk',
      );
    } catch (error) {
      _log('prepareCall error: $error');
    }
  }

  Future<void> startCall({
    required bool isVideo,
    bool isIncoming = false,
  }) async {
    _myGeneration = ++_generation;
    _ownsAudio = true;
    _isDisposed = false;
    _isIncomingCall = isIncoming;

    final bool newOwner = !_routeOwnerActive;
    _routeOwnerActive = true;
    if (newOwner) {
      _userSelectedRoute = false;
      _remoteAudioTracks.clear();
    }

    _routeInitialized = false;
    _isApplyingRoute = false;
    pendingRoute.value = null;
    _cancelWarmupTimers();
    _stopRouteKeeper();
    _stopDriftWatch();

    isVideoCall.value = isVideo;
    if (!_userSelectedRoute) {
      currentRoute.value = _sanitizeRoute(_defaultRoute);
    }

    _log(
      'startCall video=$isVideo incoming=$isIncoming os=${Platform.operatingSystemVersion} '
      'default=$_defaultRoute route=${currentRoute.value} '
      'newOwner=$newOwner userSel=$_userSelectedRoute '
      'tracks=${_remoteAudioTracks.length}',
    );

    await _resetNativeAudio();
    await _listenAudioSession();
    await refreshDevices();
    final CallAudioRoute safe = _sanitizeRoute(currentRoute.value);
    if (safe != currentRoute.value) {
      currentRoute.value = safe;
    }

    await _configureAndroidAudioSwitch();
    await _configureAudioSession(route: currentRoute.value);
    await _applyCurrentAudioRoute();

    WidgetsBinding.instance.addObserver(this);
    _startRouteKeeper(immediate: true);

    final List<int> warmups =
        Platform.isIOS ? <int>[700, 1800] : <int>[900, 2500];
    for (final int ms in warmups) {
      _warmupRouteTimers.add(
        Timer(Duration(milliseconds: ms), () {
          if (!_isDisposed) {
            _log('warmup $ms ms re-assert route=${currentRoute.value}');
            unawaited(_ensurePlaybackPath(forceSession: true));
          }
        }),
      );
    }
  }

  Future<void> stopCall() async {
    _log(
      'stopCall route=${currentRoute.value} gen=$_myGeneration/$_generation '
      'owns=$_ownsAudio',
    );

    _isDisposed = true;
    _ownsAudio = false;
    _routeInitialized = false;
    _isApplyingRoute = false;
    pendingRoute.value = null;
    _cancelWarmupTimers();
    _stopRouteKeeper();
    _stopDriftWatch();
    WidgetsBinding.instance.removeObserver(this);
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
      _log('stopCall skipped native teardown (newer call owns audio)');
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
    } catch (error) {
      _log('stopCall native error: $error');
    }

    _remoteAudioTracks.clear();
    _routeOwnerActive = false;
    _userSelectedRoute = false;
    _audioSessionReady = false;
    currentRoute.value = CallAudioRoute.earpiece;
    isVideoCall.value = false;
    _log('stopCall done');
  }

  Future<void> updateCallType({required bool isVideo}) async {
    final bool wasVideo = isVideoCall.value;
    final bool typeChanged = wasVideo != isVideo;
    isVideoCall.value = isVideo;

    if (isVideo) {
      _cancelWarmupTimers();
    }
    if (!typeChanged && _routeInitialized) return;

    if (typeChanged) {
      _userSelectedRoute = false;
    }

    final CallAudioRoute keep =
        isVideo ? CallAudioRoute.speaker : CallAudioRoute.earpiece;
    _log(
      'updateCallType(video=$isVideo) keeps $keep (was ${currentRoute.value})',
    );

    await setRoute(keep, force: true);
  }

  Future<void> selectRoute(CallAudioRoute route) async {
    _log(
      'selectRoute($route) disposed=$_isDisposed route=${currentRoute.value} '
      'available=$availableRoutes',
    );
    if (_isDisposed) return;

    if (!availableRoutes.contains(route)) {
      await refreshDevices();
      if (!availableRoutes.contains(route)) {
        _log('$route not available, ignored');
        return;
      }
    }

    await setRoute(route, userInitiated: true);
  }

  Future<void> checkDevices() => refreshDevices();

  Future<void> refreshDevices() async {
    if (_isDisposed) return;
    await _refreshHardwareRoutes();
  }

  Future<void> onRemoteAudioTrack(MediaStreamTrack track) async {
    if (_isDisposed) return;

    if (!_remoteAudioTracks.contains(track)) {
      _remoteAudioTracks.add(track);
    }

    try {
      track.enabled = true;
    } catch (_) {}

    _log(
      'onRemoteAudioTrack id=${track.id} route=${currentRoute.value} '
      'incoming=$_isIncomingCall tracks=${_remoteAudioTracks.length}',
    );

    await _applyCurrentAudioRoute();
    await _reapplyTracks();
    _startRouteKeeper(immediate: true);

    _log(
      'onRemoteAudioTrack settled route=${currentRoute.value} '
      'actual=${await _readActualRoute()}',
    );
  }

  Future<void> reapplyCurrentRoute() async {
    if (_isDisposed) return;
    _log('reapplyCurrentRoute ${currentRoute.value}');
    await _ensurePlaybackPath(forceSession: true);
    _startRouteKeeper(immediate: true);
  }

  Future<void> restoreCurrentRoute() async {
    _log(
      'restoreCurrentRoute disposed=$_isDisposed route=${currentRoute.value}',
    );
    if (_isDisposed) return;
    await _refreshHardwareRoutes();
    await _ensurePlaybackPath(forceSession: true);
  }

  Future<void> setRoute(
    CallAudioRoute route, {
    bool userInitiated = false,
    bool force = false,
  }) {
    if (userInitiated) {
      _userSelectedRoute = true;
      _log('setRoute($route) user=true immediate');
      return _setRouteInternal(route, userInitiated: true, force: true);
    }
    if (force) {
      _log('setRoute($route) force=true immediate');
      return _setRouteInternal(route, force: true);
    }
    _log('setRoute($route) user=false queued');
    _routeQueue = _routeQueue
        .then((_) => _setRouteInternal(route))
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
    if (_isDisposed) {
      _log('_setRouteInternal skipped: disposed');
      return;
    }

    final CallAudioRoute target = _sanitizeRoute(requested);

    if (!userInitiated &&
        !force &&
        _userSelectedRoute &&
        target != currentRoute.value) {
      _log('setRoute($requested) skipped: user picked ${currentRoute.value}');
      return;
    }

    _isApplyingRoute = true;
    pendingRoute.value = target;
    _safeUpdate();

    final CallAudioRoute previous = currentRoute.value;
    currentRoute.value = target;
    _log(
      'route state $previous -> $target userSel=$_userSelectedRoute '
      'user=$userInitiated',
    );

    try {
      _log(
        'apply $target speaker=${target == CallAudioRoute.speaker} '
        '(requested=$requested user=$userInitiated)',
      );

      await _configureAudioSession(route: target);
      await _applyCurrentAudioRoute();
      await _reapplyTracks();

      if (_isDisposed) return;

      _routeInitialized = true;
      if (userInitiated) {
        _userSelectedRoute = true;
      }

      await _applyProximity(target);
      _startRouteKeeper(immediate: true);

      final CallAudioRoute? actual = await _readActualRoute();
      _log('route now $target actual=$actual speaker=$isSpeakerOn');
    } catch (error) {
      _log('apply $target error: $error');
      if (currentRoute.value != previous) {
        currentRoute.value = previous;
      }
    } finally {
      _isApplyingRoute = false;
      pendingRoute.value = null;
      _safeUpdate();
    }
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
    if (route == CallAudioRoute.speaker && !_hasSpeaker) {
      return CallAudioRoute.earpiece;
    }
    if (route == CallAudioRoute.earpiece && !_hasEarpiece) {
      return CallAudioRoute.speaker;
    }
    return route;
  }

  Future<void> _applyProximity(CallAudioRoute route) async {
    final bool enable = route == CallAudioRoute.earpiece &&
        !isVideoCall.value &&
        !isBluetoothConnected.value &&
        !isHeadsetConnected.value;
    try {
      await ProximityScreenLock.setActive(enable);
    } catch (_) {}
  }

  Future<void> _resetNativeAudio() async {
    if (!Platform.isAndroid) return;
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
    _log('native audio reset for new call (default earpiece path)');
  }

  Future<void> _configureAndroidAudioSwitch() async {
    if (!Platform.isAndroid) return;
    try {
      await Helper.setAndroidAudioConfiguration(
        AndroidAudioConfiguration(
          manageAudioFocus: false,
          androidAudioMode: AndroidAudioMode.inCommunication,
          androidAudioStreamType: AndroidAudioStreamType.voiceCall,
          androidAudioAttributesUsageType:
              AndroidAudioAttributesUsageType.voiceCommunication,
          androidAudioAttributesContentType:
              AndroidAudioAttributesContentType.speech,
          forceHandleAudioRouting: false,
        ),
      );
      _log('webrtc audio switch focus=off mode=inCommunication');
    } catch (error) {
      _log('webrtc audio switch config error: $error');
    }
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
                AVAudioSessionCategoryOptions.defaultToSpeaker)
            : (AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.allowBluetoothA2dp);

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

      final bool active = await session.setActive(true);
      _audioSessionReady = active;
      _log('session configured route=$targetRoute active=$active');
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

      await _applyCurrentAudioRoute();
      await _reapplyTracks();

      _log(
        'playback path ready route=${currentRoute.value} '
        'speaker=$isSpeakerOn tracks=${_remoteAudioTracks.length} '
        'available=$availableRoutes',
      );
    } catch (error) {
      _log('ensurePlaybackPath error: $error');
    }
  }

  Future<void> _reapplyTracks() async {
    for (final MediaStreamTrack track in _remoteAudioTracks) {
      try {
        track.enabled = true;
      } catch (_) {}
    }

    try {
      await Helper.setSpeakerphoneOn(isSpeakerOn);
    } catch (error) {
      _log('track speaker push error: $error');
    }
  }

  Future<void> _applyCurrentAudioRoute() async {
    final CallAudioRoute route = currentRoute.value;
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
    final bool ok = await _assertAndroidDevice(route);
    if (!ok) {
      await Future.delayed(const Duration(milliseconds: 220));
      final bool retry = await _assertAndroidDevice(route, forceClear: true);
      _log('android re-assert -> $route matches=$retry');
    }
    _log(
      'android apply -> $route matches=$ok '
      'actual=${await _readActualRoute()} speaker=$isSpeakerOn',
    );
  }

  Future<bool> _assertAndroidDevice(
    CallAudioRoute route, {
    bool forceClear = false,
  }) async {
    final AndroidAudioManager am = AndroidAudioManager();
    final bool speaker = route == CallAudioRoute.speaker;

    try {
      await am.setMode(AndroidAudioHardwareMode.inCommunication);
    } catch (_) {}

    if (forceClear) {
      try {
        await am.clearCommunicationDevice();
        await Future.delayed(const Duration(milliseconds: 80));
        _log('forced clear before re-assert ${route.name}');
      } catch (_) {}
    }

    if (route == CallAudioRoute.bluetooth) {
      try {
        await am.startBluetoothSco();
        await Future.delayed(const Duration(milliseconds: 120));
        await am.setBluetoothScoOn(true);
      } catch (error) {
        _log('bluetooth sco error: $error');
      }
    } else {
      try {
        await am.stopBluetoothSco();
      } catch (_) {}
      try {
        await am.setBluetoothScoOn(false);
      } catch (_) {}
    }

    final bool written = await _setCommunicationDevice(route);

    try {
      await am.setSpeakerphoneOn(speaker);
    } catch (error) {
      _log('legacy speakerphone write error: $error');
    }

    await _syncAudioSwitchSelection(speaker);

    if (speaker) {
      try {
        await am.setSpeakerphoneOn(true);
      } catch (_) {}
    }

    final CallAudioRoute? actual = await _readActualRoute();
    final bool legacySpeaker = await _readLegacySpeaker();
    final bool satisfied = _routeSatisfied(route, actual, legacySpeaker);
    _log(
      'assert ${route.name} written=$written actual=$actual '
      'legacySpeaker=$legacySpeaker satisfied=$satisfied sdk=$_androidSdk '
      'mode=${await _androidModeName()} devices=${await _deviceSummary()}',
    );

    return satisfied;
  }

  Future<void> _syncAudioSwitchSelection(bool speaker) async {
    for (int pass = 0; pass < 2; pass++) {
      try {
        await Helper.setSpeakerphoneOn(speaker);
      } catch (error) {
        _log('webrtc speaker sync error pass=$pass: $error');
      }
      if (pass == 0) {
        await Future.delayed(const Duration(milliseconds: 180));
      }
    }
  }

  Future<bool> _readLegacySpeaker() async {
    if (!Platform.isAndroid) return false;
    try {
      return await AndroidAudioManager().isSpeakerphoneOn();
    } catch (_) {
      return false;
    }
  }

  bool _routeSatisfied(
    CallAudioRoute want,
    CallAudioRoute? actual,
    bool legacySpeaker,
  ) {
    if (actual != null) {
      return actual == want || _routeGroupsMatch(want, actual);
    }
    return want == CallAudioRoute.speaker && legacySpeaker;
  }

  Future<bool> _setCommunicationDevice(CallAudioRoute route) async {
    final AndroidAudioManager am = AndroidAudioManager();

    try {
      final List<AndroidAudioDeviceInfo> devices =
          await am.getAvailableCommunicationDevices();

      AndroidAudioDeviceInfo? target;
      for (final AndroidAudioDeviceInfo device in devices) {
        if (_routeOfDevice(device.type) == route) {
          target = device;
          break;
        }
      }

      if (target == null) {
        if (route == CallAudioRoute.earpiece) {
          await am.clearCommunicationDevice();
          _log('no earpiece device, cleared to platform default');
          return false;
        }
        _log('no ${route.name} device in comm devices, nothing to set');
        return false;
      }

      final bool ok = await am.setCommunicationDevice(target);
      _log(
        'setCommunicationDevice(${target.type.name}#${target.id}) '
        'route=${route.name} ok=$ok',
      );
      return ok;
    } catch (error) {
      _log('comm-device path unavailable (${error.runtimeType}), legacy route');
      try {
        await Helper.setSpeakerphoneOn(route == CallAudioRoute.speaker);
      } catch (_) {}
      return true;
    }
  }

  CallAudioRoute? _routeOfDevice(AndroidAudioDeviceType type) {
    switch (type) {
      case AndroidAudioDeviceType.builtInSpeaker:
      case AndroidAudioDeviceType.builtInSpeakerSafe:
        return CallAudioRoute.speaker;
      case AndroidAudioDeviceType.builtInEarpiece:
        return CallAudioRoute.earpiece;
      case AndroidAudioDeviceType.bluetoothSco:
      case AndroidAudioDeviceType.bluetoothA2dp:
        return CallAudioRoute.bluetooth;
      case AndroidAudioDeviceType.wiredHeadset:
      case AndroidAudioDeviceType.wiredHeadphones:
      case AndroidAudioDeviceType.usbHeadset:
      case AndroidAudioDeviceType.usbDevice:
        return CallAudioRoute.headset;
      default:
        return null;
    }
  }

  CallAudioRoute? _routeOfSessionDevice(AudioDeviceType type) {
    switch (type) {
      case AudioDeviceType.bluetoothA2dp:
      case AudioDeviceType.bluetoothSco:
      case AudioDeviceType.bluetoothLe:
        return CallAudioRoute.bluetooth;
      case AudioDeviceType.wiredHeadset:
      case AudioDeviceType.wiredHeadphones:
      case AudioDeviceType.usbAudio:
        return CallAudioRoute.headset;
      default:
        return null;
    }
  }

  Future<CallAudioRoute?> _readActualRoute() async {
    if (Platform.isAndroid) {
      try {
        final AndroidAudioManager am = AndroidAudioManager();
        final AndroidAudioDeviceInfo? device =
            await am.getCommunicationDevice();
        if (device == null) return null;
        return _routeOfDevice(device.type);
      } catch (error) {
        _log('readActualRoute error: $error');
        return null;
      }
    }

    return null;
  }

  bool _routeGroupsMatch(CallAudioRoute want, CallAudioRoute actual) {
    if (want == CallAudioRoute.bluetooth && actual == CallAudioRoute.headset) {
      return true;
    }
    if (want == CallAudioRoute.headset && actual == CallAudioRoute.bluetooth) {
      return true;
    }
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
        try {
          await Helper.selectAudioOutput('speaker');
        } catch (_) {}
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
          await Helper.selectAudioOutput('bluetooth');
        } catch (_) {}
        break;

      case CallAudioRoute.headset:
        try {
          await Helper.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.selectAudioOutput('wired-headset');
        } catch (_) {}
        break;

      case CallAudioRoute.earpiece:
        try {
          await Helper.setSpeakerphoneOn(false);
        } catch (_) {}
        try {
          await Helper.selectAudioOutput('earpiece');
        } catch (_) {}
        break;
    }

    await Future.delayed(const Duration(milliseconds: 120));
    _log('ios route applied -> $route');
  }

  void _startRouteKeeper({bool immediate = false}) {
    if (!Platform.isAndroid || _isDisposed) return;

    _stopRouteKeeper();
    _keeperRunning = true;
    _keeperAttempt = 0;
    _keeperStreak = 0;

    unawaited(_keeperStep(immediate: immediate));
  }

  Future<void> _keeperStep({bool immediate = false}) async {
    if (_isDisposed || !_keeperRunning) return;

    const List<int> backoff = <int>[
      250,
      500,
      800,
      1200,
      1500,
      1800,
      2200,
      2500,
      3000,
      3000,
    ];

    final CallAudioRoute want = currentRoute.value;
    final bool ok = await _assertAndroidDevice(
      want,
      forceClear: _keeperAttempt >= 2,
    );

    if (ok) {
      _keeperStreak++;
      if (_keeperStreak >= 2) {
        _log(
          'keeper confirmed ${want.name} after $_keeperAttempt attempt(s) '
          'actual=${await _readActualRoute()}',
        );
        _keeperRunning = false;
        _startDriftWatch();
        return;
      }
    } else {
      _keeperStreak = 0;
    }

    if (_keeperAttempt >= backoff.length) {
      _keeperRunning = false;
      _log(
        'ROUTE_UNSTABLE want=${want.name} '
        'actual=${await _readActualRoute()} devices=${await _deviceSummary()} '
        'speaker=$isSpeakerOn mode=${await _androidModeName()}',
      );
      _startDriftWatch();
      return;
    }

    final int delay = immediate
        ? backoff[_keeperAttempt.clamp(0, backoff.length - 1)] ~/ 2
        : backoff[_keeperAttempt.clamp(0, backoff.length - 1)];
    _keeperAttempt++;
    _keeperTimer = Timer(Duration(milliseconds: delay), () {
      unawaited(_keeperStep());
    });
  }

  void _stopRouteKeeper() {
    _keeperRunning = false;
    _keeperTimer?.cancel();
    _keeperTimer = null;
  }

  void _startDriftWatch() {
    if (!Platform.isAndroid || _isDisposed) return;
    _driftTimer?.cancel();
    _driftTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        _driftTimer = null;
        return;
      }
      if (_isApplyingRoute || _keeperRunning) return;

      final CallAudioRoute want = currentRoute.value;
      final CallAudioRoute? actual = await _readActualRoute();
      final bool legacySpeaker = await _readLegacySpeaker();
      if (_routeSatisfied(want, actual, legacySpeaker)) return;

      _log(
        'drift detected want=${want.name} actual=$actual '
        'legacySpeaker=$legacySpeaker',
      );
      _startRouteKeeper(immediate: true);
    });
  }

  void _stopDriftWatch() {
    _driftTimer?.cancel();
    _driftTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_isDisposed) return;
    _log('app resumed -> re-assert route=${currentRoute.value}');
    _startRouteKeeper(immediate: true);
  }

  Future<String> _deviceSummary() async {
    if (!Platform.isAndroid) return 'n/a';
    try {
      final AndroidAudioManager am = AndroidAudioManager();
      final List<AndroidAudioDeviceInfo> devices =
          await am.getAvailableCommunicationDevices();
      return devices
          .map((AndroidAudioDeviceInfo d) => '${d.type.name}#${d.id}')
          .join('|');
    } catch (error) {
      return 'error:$error';
    }
  }

  static const Map<int, String> _androidModeNames = <int, String>{
    -2: 'invalid',
    -1: 'current',
    0: 'normal',
    1: 'ringtone',
    2: 'inCall',
    3: 'inCommunication',
  };

  Future<String> _androidModeName() async {
    if (!Platform.isAndroid) return 'n/a';
    try {
      final AndroidAudioManager am = AndroidAudioManager();
      final AndroidAudioHardwareMode mode = await am.getMode();
      return _androidModeNames[mode.index] ?? 'index:${mode.index}';
    } catch (error) {
      return 'error:$error';
    }
  }

  Future<void> _refreshHardwareRoutes() async {
    bool hasSpeaker = Platform.isAndroid ? false : true;
    bool hasEarpiece = Platform.isAndroid ? false : true;
    bool hasBluetooth = false;
    bool hasWired = false;
    String bluetoothName = _bluetoothName;
    String wiredName = _wiredName;

    if (Platform.isAndroid) {
      try {
        final AndroidAudioManager am = AndroidAudioManager();
        final List<AndroidAudioDeviceInfo> devices =
            await am.getAvailableCommunicationDevices();

        if (devices.isNotEmpty) {
          _log(
            'comm devices=${devices.map((AndroidAudioDeviceInfo d) => '${d.type.name}#${d.id}').join('|')}',
          );
        }

        for (final AndroidAudioDeviceInfo device in devices) {
          final CallAudioRoute? route = _routeOfDevice(device.type);
          if (route == CallAudioRoute.speaker) {
            hasSpeaker = true;
          } else if (route == CallAudioRoute.earpiece) {
            hasEarpiece = true;
          } else if (route == CallAudioRoute.bluetooth) {
            hasBluetooth = true;
            if (device.productName.trim().isNotEmpty) {
              bluetoothName = device.productName.trim();
            }
          } else if (route == CallAudioRoute.headset) {
            hasWired = true;
            if (device.productName.trim().isNotEmpty) {
              wiredName = device.productName.trim();
            }
          }
        }
      } catch (error) {
        _log('comm devices read error: $error');
      }
    }

    try {
      final AudioSession session = await AudioSession.instance;
      final Iterable<AudioDevice> devices = await session.getDevices();
      for (final AudioDevice device in devices) {
        final CallAudioRoute? route = _routeOfSessionDevice(device.type);
        if (route == CallAudioRoute.bluetooth) {
          hasBluetooth = true;
          final String name = device.name.trim();
          if (name.isNotEmpty && !name.toLowerCase().contains('unknown')) {
            bluetoothName = name;
          }
        } else if (route == CallAudioRoute.headset) {
          hasWired = true;
          final String name = device.name.trim();
          if (name.isNotEmpty && !name.toLowerCase().contains('unknown')) {
            wiredName = name;
          }
        } else if (device.type == AudioDeviceType.builtInSpeaker) {
          hasSpeaker = true;
        } else if (device.type == AudioDeviceType.builtInEarpiece) {
          hasEarpiece = true;
        }
      }
    } catch (error) {
      _log('session getDevices error: $error');
    }

    final bool changed = hasSpeaker != _hasSpeaker ||
        hasEarpiece != _hasEarpiece ||
        hasBluetooth != isBluetoothConnected.value ||
        hasWired != isHeadsetConnected.value;

    _hasSpeaker = hasSpeaker;
    _hasEarpiece = hasEarpiece;
    _bluetoothName = bluetoothName;
    _wiredName = wiredName;
    isBluetoothConnected.value = hasBluetooth;
    isHeadsetConnected.value = hasWired;

    _log(
      'devices speaker=$hasSpeaker earpiece=$hasEarpiece '
      'bt=$hasBluetooth($bluetoothName) wired=$hasWired($wiredName) '
      'available=$availableRoutes',
    );

    if (changed) {
      final CallAudioRoute safe = _sanitizeRoute(currentRoute.value);
      if (safe != currentRoute.value && !_isDisposed) {
        _log('device change -> route ${currentRoute.value} forced to $safe');
        _userSelectedRoute = false;
        await setRoute(safe, force: true);
      }
      _safeUpdate();
    }
  }

  Future<void> _listenAudioSession() async {
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
    } catch (error) {
      _log('listenAudioSession error: $error');
    }
  }

  void _scheduleDeviceRefresh() {
    if (_isDisposed) return;
    _deviceDebounce?.cancel();
    _deviceDebounce = Timer(const Duration(milliseconds: 160), () {
      unawaited(_refreshOnDeviceChange());
    });
  }

  Future<void> _refreshOnDeviceChange() async {
    await _refreshHardwareRoutes();
    if (!_isDisposed) {
      await _ensurePlaybackPath(forceSession: true);
    }
  }

  void _cancelWarmupTimers() {
    for (final Timer timer in _warmupRouteTimers) {
      timer.cancel();
    }
    _warmupRouteTimers.clear();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _cancelWarmupTimers();
    _stopRouteKeeper();
    _stopDriftWatch();
    WidgetsBinding.instance.removeObserver(this);
    _deviceDebounce?.cancel();
    if (_ownsAudio) {
      unawaited(stopCall());
    }
    super.onClose();
  }
}
