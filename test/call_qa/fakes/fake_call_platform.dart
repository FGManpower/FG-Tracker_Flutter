// Test doubles for the 1:1 call lifecycle (docs/testing/calling).
//
// FakeCallPlatform replaces CallPlatform.instance so CallingController runs
// without WebRTC, CallKit, wakelock, proximity, ringtone or the Android
// foreground service. Every side effect is recorded for assertions.
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FakeAudioRoute extends CallAudioRouteController {
  int stopCalls = 0;

  @override
  Future<void> prepareCall({required bool isVideo}) async {}

  @override
  Future<void> startCall({
    required bool isVideo,
    bool isIncoming = false,
  }) async {}

  @override
  Future<void> stopCall() async => stopCalls++;

  @override
  Future<void> restoreCurrentRoute() async {}

  @override
  Future<void> reapplyCurrentRoute() async {}

  @override
  Future<void> updateCallType({required bool isVideo}) async {}

  @override
  Future<void> onRemoteAudioTrack(MediaStreamTrack track) async {}

  @override
  Future<void> checkDevices() async {}
}

class FakeCallPlatform extends CallPlatform {
  final List<String> log = <String>[];
  final List<bool> serviceStarts = <bool>[];
  int serviceStops = 0;
  final List<String> dismissed = <String>[];
  int trackingKeepAlive = 0;
  final List<FakeAudioRoute> routes = <FakeAudioRoute>[];

  @override
  bool get mediaEnabled => false;

  @override
  CallAudioRouteController audioRoute() {
    final FakeAudioRoute r = FakeAudioRoute();
    routes.add(r);
    return r;
  }

  @override
  String get ringbackAsset => 'ringing.mp3';

  @override
  void playRingback(String asset) => log.add('ringback');

  @override
  void stopRingtone() => log.add('stopRingtone');

  @override
  Future<void> setWakelock(bool on) async => log.add('wakelock:$on');

  @override
  Future<void> setProximity(bool on) async => log.add('proximity:$on');

  @override
  Future<void> startCallService({required bool video}) async =>
      serviceStarts.add(video);

  @override
  Future<void> stopCallService() async => serviceStops++;

  @override
  void clearCallKitAudioHandover(String sessionId, {String callId = ''}) {}

  @override
  Future<void> dismissCallKit(String sessionId) async =>
      dismissed.add(sessionId);

  @override
  Future<void> markCallKitConnected(String sessionId) async {}

  @override
  Future<void> callEndedCleanup(String sessionId, {String? type}) async =>
      log.add('callEnded:$type');

  @override
  Future<void> keepTrackingAlive() async => trackingKeepAlive++;

  // Phase 3
  final List<String> tones = <String>[];
  final List<bool> autoPip = <bool>[];
  final List<String> callKitOutgoing = <String>[];
  final List<bool> callKitMute = <bool>[];

  @override
  void playTone(String asset) => tones.add(asset);

  @override
  Future<void> setAutoPip(bool enabled) async => autoPip.add(enabled);

  @override
  Future<void> reportOutgoingToCallKit({
    required String uuid,
    required String name,
    required String handle,
    required bool isVideo,
  }) async =>
      callKitOutgoing.add(uuid);

  @override
  Future<void> syncCallKitMute(String id, bool muted) async =>
      callKitMute.add(muted);
}
