import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/main.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class CallRecoveryService {
  CallRecoveryService._();

  static final instance = CallRecoveryService._();

  Future<void> checkCallOnLaunch() async {
    try {
      final sessionId =
      await ConnectycubeFlutterCallKit.getLastCallId();

      if (sessionId == null) {
        log("No last call session");
        return;
      }

      final state =
      await ConnectycubeFlutterCallKit.getCallState(
        sessionId: sessionId,
      );

      log("CALL STATE => $state");

      if (state == "accepted") {
        return;
      }

      CallSessionState.sessionId = sessionId;

      final callData =
      await ConnectycubeFlutterCallKit.getCallData(
        sessionId: sessionId,
      );

      if (callData == null) {
        return;
      }

      final userInfoRaw = callData["user_info"];

      Map<String, dynamic> data = {};

      if (userInfoRaw is String) {
        data = jsonDecode(userInfoRaw);
      } else if (userInfoRaw is Map) {
        data = Map<String, dynamic>.from(userInfoRaw);
      }

      final myUserId =
      Global.storageServices.get(PrefConst.userId).toString();

      final targetUser =
      (myUserId == data['callerId'].toString())
          ? data['receiverId'].toString()
          : data['callerId'].toString();

      socket?.emit("endCall", {
        "callId": data['callId'].toString(),
        "remoteUserId": targetUser,
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (Platform.isAndroid) {
        await ConnectycubeFlutterCallKit.clearCallData(
          sessionId: sessionId,
        );
      } else {
        await FlutterCallkitIncoming.endCall(sessionId);
      }

      CallSessionState.reset();

      log("Recovered stale call successfully");
    } catch (e) {
      log("checkCallOnLaunch error: $e");
    }
  }
}