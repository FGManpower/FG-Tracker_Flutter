import 'dart:developer';

import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart'
    show callEnded;
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_foreground_service.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_pip.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Ring timeout for 1:1 calls, used by the caller's missed-call timer AND the
/// callee's CallKit / full-screen `duration` (BUG-CALL-08). Until the server
/// owns the timeout (doc 02 §5.3 Q3), this is the single source.
const Duration kCallRingTimeout = Duration(seconds: 45);

/// Short tones at the end of a call (generated, see assets/music).
const String kCallEndToneAsset = 'assets/music/call_end_tone.wav';
const String kCallBusyToneAsset = 'assets/music/call_busy_tone.wav';

/// iOS: report outgoing calls to CallKit (BUG-CALL-12). Kill switch in case
/// a device shows an audio problem with it.
const bool kReportOutgoingCallsToCallKit = true;

/// Side effects of a 1:1 call outside WebRTC and the socket: device (wakelock,
/// proximity, ringtone, foreground service), CallKit, audio route, tracking.
///
/// Production uses this class as is. Unit tests replace [instance] with a
/// fake so the call lifecycle can run without plugins (`test/call_qa/`).
class CallPlatform {
  static CallPlatform instance = CallPlatform();

  /// False in unit tests: the controller then skips renderers, getUserMedia
  /// and the peer connection.
  bool get mediaEnabled => true;

  CallAudioRouteController audioRoute() {
    if (Get.isRegistered<CallAudioRouteController>()) {
      return Get.find<CallAudioRouteController>();
    }
    // permanent: the call outlives its route when minimized. Without it,
    // GetX deleted this controller when /callScreen closed, which stopped
    // the call's audio routing and broke Speaker after the user came back.
    // CallingController.onClose deletes it (force) when the call ends.
    return Get.put(CallAudioRouteController(), permanent: true);
  }

  void playRingback(String asset) {
    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: asset,
      looping: true,
      volume: 1.0,
    );
  }

  String get ringbackAsset => Assets.music.ringing;

  void stopRingtone() => FlutterRingtonePlayer().stop();

  Future<void> setWakelock(bool on) =>
      on ? WakelockPlus.enable() : WakelockPlus.disable();

  Future<void> setProximity(bool on) => ProximityScreenLock.setActive(on);

  Future<void> startCallService({required bool video}) =>
      CallForegroundService.start(video: video);

  Future<void> stopCallService() => CallForegroundService.stop();

  void clearCallKitAudioHandover(String sessionId, {String callId = ''}) =>
      CallKitService.clearAudioHandover(sessionId, callId: callId);

  Future<void> dismissCallKit(String sessionId) =>
      CallKitService.dismiss(sessionId);

  Future<void> markCallKitConnected(String sessionId) =>
      CallKitService.setConnected(sessionId);

  Future<void> callEndedCleanup(String sessionId, {String? type}) =>
      callEnded(sessionId, type: type);

  /// One-shot tone (end / busy). Never loops.
  void playTone(String asset) {
    try {
      FlutterRingtonePlayer().play(
        asAlarm: false,
        fromAsset: asset,
        looping: false,
        volume: 0.6,
      );
    } catch (_) {}
  }

  Future<void> reportOutgoingToCallKit({
    required String uuid,
    required String name,
    required String handle,
    required bool isVideo,
  }) =>
      CallKitService.startOutgoing(
        uuid: uuid,
        name: name,
        handle: handle,
        isVideo: isVideo,
      );

  Future<void> syncCallKitMute(String id, bool muted) =>
      CallKitService.syncMute(id, muted);

  Future<void> setAutoPip(bool enabled) => CallPip.setAuto(enabled);

  /// Keeps location tracking running while the phone is locked during a call
  /// (added with group calls, commit 9a6c524a). It must never show a
  /// permission or "turn on GPS" dialog over the call screen (BUG-CALL-18),
  /// so it only runs when both are already on.
  Future<void> keepTrackingAlive() async {
    try {
      final LocationPermission p = await Geolocator.checkPermission();
      final bool granted = p == LocationPermission.always ||
          p == LocationPermission.whileInUse;
      final bool gpsOn = await Geolocator.isLocationServiceEnabled();
      if (!granted || !gpsOn) {
        if (kDebugMode) {
          log('[CALL] tracking keep-alive skipped (permission=$p gps=$gpsOn)');
        }
        return;
      }
      if (Get.isRegistered<GroupTrackingController>()) {
        GroupTrackingController.instance.initializeLocation();
      }
    } catch (e) {
      if (kDebugMode) log('[CALL] tracking keep-alive error: $e');
    }
  }
}
