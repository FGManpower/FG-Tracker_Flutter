import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:flutter/material.dart';
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
    log("🔌 Initializing Call Signaling Socket…");

    socket = io(
      "$websocketUrl/callSignaling",
      {
        "transports": ["websocket"],
        "query": {"callerId": selfCallerID},
        "autoConnect": true,
        "forceNew": true,
        "reconnection": true,
        "reconnectionAttempts": 5,
        "reconnectionDelay": 1000,
      },
    );

    socket!.onConnect((_) {
      log("✅ Call Socket Connected (ID: $selfCallerID)");
    });

    socket!.onDisconnect((_) {
      log("❌ Call Socket Disconnected");
    });

    socket!.onReconnect((_) {
      log("🔄 Call Socket Reconnected");
    });

    socket!.onConnectError((err) => log("Connect Error: $err"));
    socket!.onError((err) => log("Socket Error: $err"));

    // ======= MISSED CALL =======
    socket!.on("missedCall", (data) async {
      log('📵 MissedCall received: $data');
      final sessionId = data['sessionId']?.toString() ??
          data['callId']?.toString();
      if (sessionId != null) {
        CallSessionState.sessionId = sessionId;
        await callEnded(sessionId);
      }
    });

    // ======= CALL ENDED =======
    socket!.on("callEnded", (data) async {
      log('📵 CallEnded received: $data');
      final sessionId = data['sessionId']?.toString() ??
          data['callId']?.toString();
      if (sessionId != null) {
        CallSessionState.sessionId = sessionId;
        await callEnded(sessionId);
      }
    });

    // ======= CALL REJECTED =======
    socket!.on("callRejected", (data) async {
      log('❌ CallRejected received: $data');
      final callId = data['callId']?.toString();
      if (callId != null) {
        await callEnded(callId);
      }
    });

    socket!.on("callCancelled", (data) async {
      log('🚫 callCancelled received: $data');

      final callId = data['callId']?.toString();

      // Dismiss CallKit notification on iOS
      if (CallSessionState.sessionId != null) {
        await ConnectycubeFlutterCallKit.reportCallEnded(
          sessionId: CallSessionState.sessionId!,
        );
        await ConnectycubeFlutterCallKit.clearCallData(
          sessionId: CallSessionState.sessionId!,
        );
      } else if (callId != null) {
        // Try with callId as sessionId
        try {
          await ConnectycubeFlutterCallKit.reportCallEnded(
            sessionId: callId,
          );
          await ConnectycubeFlutterCallKit.clearCallData(
            sessionId: callId,
          );
        } catch (e) {
          log("callCancelled reportCallEnded error: $e");
        }
      }

      CallStateTracker.isIncomingCallScreenOpen = false;
      CallSessionState.reset();

      log("✅ CallKit dismissed after callCancelled");
    });

    // ======= NEW CALL (iOS: VoIP, Android: show incoming screen) =======
    socket!.on("newCall", (data) async {
      log('📞 NewCall received');

      if (CallStateTracker.isIncomingCallScreenOpen) {
        log('⚠️ Already showing incoming call screen, ignoring');
        return;
      }

      try {
        final callMap = jsonDecode(data['callData']);
        final call = IncomingCallModel.fromMap(callMap);

        CallStateTracker.isIncomingCallScreenOpen = true;

        if (Platform.isIOS) {
          // iOS: CallKit will handle the UI via VoIP push
          // Socket is just a backup for foreground
          final appState = AppLifecycleTracker.state;
          if (appState == AppLifecycleState.resumed) {
            log('📲 App in foreground, CallKit showing incoming call UI');
          }
        } else {
          // Android: Navigate to incoming call screen
          final appState = AppLifecycleTracker.state;
          // if (appState == AppLifecycleState.resumed) {
          //   Get.toNamed(Routes.IncomingCallScreen,
          //       arguments: {"callDetail": call});
          // }
        }
      } catch (e) {
        log("newCall parse error: $e");
      }
    });

    socket!.onAny((event, dynamic data) {
      log("📡 Event: $event");
    });
  }

  void disconnect() {
    if (socket != null) {
      log("🔌 Disconnecting call socket…");
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }
  }
}

Future<void> callEnded(String sessionId) async {
  try {
    await ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
    await ConnectycubeFlutterCallKit.clearCallData(sessionId: sessionId);
    CallStateTracker.isIncomingCallScreenOpen = false;
    CallSessionState.reset();
    log("✅ callEnded processed: $sessionId");
  } catch (e) {
    log("callEnded error: $e");
  }
}