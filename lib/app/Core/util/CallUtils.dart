import 'dart:developer';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallUtils {

  Future<void> showIncomingCall(Map<String, dynamic> data) async {
    try {
      final callId = data['channelId']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final isVideo =
          (data['isVideo']?.toString().toLowerCase() ?? 'false') == 'true';

      final params = CallKitParams(
        id: callId,
        nameCaller: data['callerName'] ?? 'Unknown Caller',
        appName: 'FG Tracker',
        avatar: data['callerProfileImage'] ?? '',
        handle: data['callerId'] ?? '',
        type: isVideo ? 1 : 0, // 0 = audio, 1 = video
        duration: 30000, // 30 seconds timeout
        textAccept: 'Accept',
        textDecline: 'Decline',
        extra: data,
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: true,
          backgroundColor: '#0955fa',
          actionColor: '#4CAF50',
        ),
        ios: const IOSParams(
          handleType: 'generic',
          supportsVideo: true,
        ),
      );

      // Save incoming call data so we can retrieve later
      final sp = await SharedPreferences.getInstance();
      await sp.setString('incoming_call_data', data.toString());

      await FlutterCallkitIncoming.showCallkitIncoming(params);
      log('[CallUtils] Incoming call shown with ID: $callId');
    } catch (e, st) {
      log('[CallUtils] showIncomingCall error: $e\n$st');
    }
  }



  /// End call
  Future<void> endCall(String uuid) async {
    await FlutterCallkitIncoming.endCall(uuid);
  }

  /// Accept call (navigate to call screen)
  void acceptCall(Map<String, dynamic> data) {
    log("[Accept Call] Data: $data");
    // TODO: Navigate to your call screen here
  }

}
