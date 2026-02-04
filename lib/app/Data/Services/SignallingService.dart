import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:fgtracker/app/Data/Services/CallEvents_NotificationServices.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../Core/util/AppLifeCycle.dart';
import '../../Model/call_model.dart';
import '../../modules/Walkie-talkie/Controller/walkieController.dart';
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
      CustomNotificationServices().setupSocketCallEvents();
    });

    socket!.onDisconnect((_) {
      log("Call Socket Disconnected");
    });

    socket?.onAny((event, data) {
      log("CallAllEventCalled: $event => $data");
    });
    socket!.onConnectError((err) {
      log("Connect Error: $err");
    });

    socket!.onError((err) {
      log("Socket Error: $err");
    });

    socket!.on("newCall", (data) {

      // WalkieController().onIncoming(
      //   remoteUserId: data['fromUserId'],
      //   callerName: data['fromUserName'] ?? "Unknown",
      //   profileImage: data['fromUserProfile'] ?? "",
      //

      if(Platform.isIOS){
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
