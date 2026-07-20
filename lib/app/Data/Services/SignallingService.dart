import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../Core/util/AppLifeCycle.dart';
import '../../Model/call_model.dart';
import '../../routes/app_pages.dart';
import 'CallStateTracker.dart';

class SignallingService {
  Socket? socket;

  SignallingService._();
  static final instance = SignallingService._();

  void init({
    required String websocketUrl,
    required String selfCallerID,
  }) {
    log("Initializing Call Signaling Socket…");

    socket = io(
      "$websocketUrl/callSignaling",
      {
        "transports": ["websocket"],
        "query": {"callerId": selfCallerID},
        "autoConnect": true,
        "forceNew": true,
      },
    );

    socket!.onConnect((_) {
      log("Call Socket Connected (ID: $selfCallerID)");
    });

    socket!.onDisconnect((_) {
      log("Call Socket Disconnected");
    });

    socket!.on("callRejected", (data) async {
      log('==========CallRejectedbyRemoteUserass');
    });

    socket!.on("missedCall", (data) async {
      log('==========MissedCallFromRemoteParam========${data}');
      CallSessionState.sessionId = data['sessionId'].toString();
      callEnded(data['sessionId'].toString());
    });

    socket!.on("callEnded", (data) async {
      log('==========CallEndedFromRemoteParam========${data}');
      CallSessionState.sessionId = data['sessionId'].toString();

      callEnded(data['sessionId'].toString());
    });

    // socket?.onAny((event, data) {
    //   log("CallAllEventCalled: $event => $data");
    // });
    socket?.onAny((event, dynamic data) {
      print("Event: $event, Data: $data");
    });

    socket?.on('cancelMissedCallTimer', (data) {
      print("Cancel missed call timer received");
    });
    socket!.onConnectError((err) {
      log("Connect Error: $err");
    });

    socket!.onError((err) {
      log("Socket Error: $err");
    });

    socket!.on("newCall", (data) {
      if (Platform.isIOS) {
        if (CallStateTracker.isIncomingCallScreenOpen) {
          return;
        }
        final callMap = jsonDecode(data['callData']);
        final call = IncomingCallModel.fromMap(callMap);

        CallStateTracker.isIncomingCallScreenOpen = true;
        final appState = AppLifecycleTracker.state;

        if (appState == AppLifecycleState.resumed) {
          Get.toNamed(
            Routes.IncomingCallScreen,
            arguments: {"callDetail": call},
          );
        }
      } else {
        if (CallStateTracker.isIncomingCallScreenOpen) {
          return;
        }
        final callMap = jsonDecode(data['callData']);
        final call = IncomingCallModel.fromMap(callMap);

        CallStateTracker.isIncomingCallScreenOpen = true;
        final appState = AppLifecycleTracker.state;
      }
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
}

callEnded(String sessionId) async {
  if (Platform.isAndroid) {
    await ConnectycubeFlutterCallKit.reportCallEnded(
      sessionId: sessionId,
    );

    await ConnectycubeFlutterCallKit.clearCallData(
      sessionId: sessionId,
    );
  } else {
    FlutterCallkitIncoming.endCall(
      sessionId,
    );
  }

  CallSessionState.reset();
}
