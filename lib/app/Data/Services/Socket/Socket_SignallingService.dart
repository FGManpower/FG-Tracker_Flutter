import 'dart:convert';
import 'dart:developer';

import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SignallingService {
  Socket? socket;

  SignallingService._();
  static final instance = SignallingService._();

  void init({
    required String websocketUrl,
    required String selfCallerID,
  }) {
    log("Initializing Call Signaling Socket…");

    if (socket != null) {
      try {
        socket!.dispose();
      } catch (_) {}
      socket = null;
    }

    final s = io(
      "$websocketUrl/callSignaling",
      {
        "transports": ["websocket"],
        "query": {"callerId": selfCallerID},
        "autoConnect": true,
        "forceNew": true,
      },
    );
    socket = s;

    CallKitService.instance.bindSocket(s);

    s.onConnect((_) {
      log("Call Socket Connected (ID: $selfCallerID)");
    });

    s.on('force_logout', (data) {
      log("force_logout received on callSignaling socket: $data");
      LogoutUser().handleForceLogout();
    });

    s.onDisconnect((_) {
      log("Call Socket Disconnected");
    });

    s.on("callRejected", (data) async {
      log('CallRejectedByRemoteUser: $data');
      if (data is Map) {
        final sessionId = data['sessionId'] ??
            data['callId'] ??
            data['session_id'] ??
            data['id'];
        final sid = sessionId?.toString();
        if (sid != null && sid.isNotEmpty && sid != 'null') {
          await CallKitService.dismiss(sid);
          if (CallSessionState.sessionId == sid) {
            CallSessionState.reset();
          }
        }
      }
    });

    s.on("callEnded", (data) async {
      log('CallEndedFromRemote: $data');
      final sessionId = _extractSessionId(data);
      if (sessionId.isEmpty) return;

      CallSessionState.sessionId = sessionId;
      await callEnded(sessionId, type: "socketCallEnded");
    });

    s.onAny((event, dynamic data) {
      log("SingleCallEvent: $event, Data: $data");
    });

    s.on('cancelMissedCallTimer', (data) {
      log("Cancel missed call timer received");
    });

    s.on("newCall", (data) {
      if (Get.isRegistered<CallingController>()) {
        final controller = Get.find<CallingController>();
        if (Get.currentRoute == Routes.callScreen) {
          final callKit = CallKitService.instance;

          callKit.onAcceptCall = (callId, extra, uuid) async {
            CallSessionState.sessionId = uuid ?? '';
            controller.endCall();
            CallSessionState.sessionId = uuid ?? '';

            Future.delayed(
              Duration(seconds: 2),
              () {
                final callerId = extra['callerId']?.toString() ?? '';

                log('Incoming call accepted automatic without press to notification: $extra');
                Get.toNamed(Routes.callScreen, arguments: {
                  'callerId': callerId,
                  'remoteUserId': callerId,
                  'callId': callId,
                  'sessionId': uuid,
                  'is_video':
                      extra['isVideo'] == 'true' || extra['isVideo'] == true,
                  'profileImage': extra['profileImage'],
                  'callType': 'Incoming',
                  'fromCallKit': true,
                  'callerName': extra['callerName'],
                  'offer':
                      CallKitService.decodeOffer(extra['sdpOfferCompressed']),
                });
              },
            );
          };
        }
      }
    });
    s.onConnectError((err) {
      log("Connect Error: $err");
    });

    s.onError((err) {
      log("Socket Error: $err");
    });
  }

  void disconnect() {
    if (socket != null) {
      log("Disconnecting call socket…");
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }
  }

  static String _extractSessionId(dynamic data) {
    if (data is! Map) return '';
    final v = data['sessionId'] ??
        data['session_id'] ??
        data['callId'] ??
        data['call_id'];
    final s = v?.toString() ?? '';
    return (s == 'null') ? '' : s;
  }
}

Future<void> callEnded(String sessionId, {String? type}) async {
  if (sessionId.isEmpty || sessionId == 'null') return;

  await CallKitService.dismiss(sessionId);
  log('CallEnded: $sessionId, Type: $type');

  final current = CallSessionState.sessionId;
  if (current == null || current.isEmpty || current == sessionId) {
    CallSessionState.reset();
  }
}
