import 'dart:developer';
import 'package:fgtracker/app/Data/Services/Custom_NotificationServices.dart';
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

    socket!.onConnectError((err) {
      log("Connect Error: $err");
    });

    socket!.onError((err) {
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
}
