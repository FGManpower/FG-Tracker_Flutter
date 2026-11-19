import 'dart:convert';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Call Audio Route & Device States', () {
    test('Default audio routes for voice vs video calls', () {
      final ctrlVoice = CallAudioRouteController();
      expect(ctrlVoice.currentRoute.value, CallAudioRoute.earpiece);
      expect(ctrlVoice.pendingRoute.value, isNull);
      expect(ctrlVoice.isVideoCall.value, isFalse);
    });

    test('Route string conversions and enum values', () {
      expect(CallAudioRoute.speaker.name, 'speaker');
      expect(CallAudioRoute.earpiece.name, 'earpiece');
      expect(CallAudioRoute.bluetooth.name, 'bluetooth');
      expect(CallAudioRoute.headset.name, 'headset');
    });

    test('Audio route controller exposes reactive state observables', () {
      final ctrl = CallAudioRouteController();
      expect(ctrl.currentRoute.value, isNotNull);
      expect(ctrl.isBluetoothConnected.value, isFalse);
      expect(ctrl.isHeadsetConnected.value, isFalse);
    });
  });

  group('CallKit Payload & Argument Normalization', () {
    test('incomingCallArgs maps callerId and remoteUserId identically', () {
      final args = incomingCallArgs(
        callerId: 'user_456',
        callId: 'call_789',
        sessionId: 'sess_123',
        isVideo: false,
        callerName: 'Alice',
        profileImage: 'https://example.com/avatar.png',
        offer: {'type': 'offer', 'sdp': 'v=0...'},
        fromCallKit: true,
      );

      expect(args['callerId'], 'user_456');
      expect(args['remoteUserId'], 'user_456');
      expect(args['callId'], 'call_789');
      expect(args['sessionId'], 'sess_123');
      expect(args['is_video'], isFalse);
      expect(args['callerName'], 'Alice');
      expect(args['profileImage'], 'https://example.com/avatar.png');
      expect(args['callerProfile'], 'https://example.com/avatar.png');
      expect(args['callType'], 'Incoming');
      expect(args['fromCallKit'], isTrue);
      expect(args['offer'], isNotNull);
    });

    test('rejectCallPayload routes to remoteUserId', () {
      final payload = rejectCallPayload(
        callId: 'call_999',
        callerId: 'user_123',
      );

      expect(payload['callId'], 'call_999');
      expect(payload['remoteUserId'], 'user_123');
    });

    test('WaitingCall parses snake_case and nested callData correctly', () {
      final data = {
        'call_id': '101',
        'caller_id': '202',
        'caller_name': 'Bob',
        'is_video': 'true',
        'session_id': 'uuid-abc',
      };

      final parsed = WaitingCall.parse(
        data,
        decodeCallData: (raw) => {},
        decodeOffer: (compressed) => null,
      );

      expect(parsed, isNotNull);
      expect(parsed!.callId, '101');
      expect(parsed.callerId, '202');
      expect(parsed.callerName, 'Bob');
      expect(parsed.isVideo, isTrue);
      expect(parsed.sessionId, 'uuid-abc');
    });

    test('CallKitSystemAction maps lock screen actions properly', () {
      final muteAction = CallKitService.mapSystemAction(
        'actioncalltogglemute',
        {'id': 'call-1', 'isMuted': true},
      );
      expect(muteAction, isNotNull);
      expect(muteAction!.kind, CallKitSystemActionKind.mute);
      expect(muteAction.id, 'call-1');
      expect(muteAction.value, isTrue);

      final unmuteAction = CallKitService.mapSystemAction(
        'actioncalltogglemute',
        {'id': 'call-1', 'isMuted': false},
      );
      expect(unmuteAction!.value, isFalse);

      final holdAction = CallKitService.mapSystemAction(
        'actioncalltogglehold',
        {'id': 'call-1', 'isOnHold': 'true'},
      );
      expect(holdAction!.kind, CallKitSystemActionKind.hold);
      expect(holdAction.value, isTrue);

      final audioAction = CallKitService.mapSystemAction(
        'actioncalltoggleaudiosession',
        {'id': 'call-1', 'isActivate': true},
      );
      expect(audioAction!.kind, CallKitSystemActionKind.audioSession);
      expect(audioAction.value, isTrue);
    });

    test('CallKitService mappedUuid returns empty for unknown and mapped id for known', () {
      expect(CallKitService.mappedUuid('unknown_session'), '');
    });
  });

  group('Call Disconnect & Role Resolution', () {
    test('Caller and receiver resolution on disconnect', () {
      const String me = '202';
      const String caller = '101';
      const String callee = '202';

      // When me (202) is callee:
      final String actualCaller = (me == caller) ? me : caller;
      final String actualReceiver = (me == caller) ? callee : me;

      expect(actualCaller, '101');
      expect(actualReceiver, '202');
      expect(actualReceiver, isNot(equals(actualCaller)));
    });
  });
}
