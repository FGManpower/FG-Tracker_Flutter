import 'dart:convert';
import 'dart:developer';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Data/Services/CallStateTracker.dart';
import '../../Data/Services/SignallingService.dart';
import '../../Model/call_model.dart';
import '../../routes/app_pages.dart';
import '../constant/pref_res.dart';
import '../global/launchedFromCall.dart';
import '../values/global.dart';
import 'decomPress.dart';
import 'package:http/http.dart' as http;

class CallKitService {
  static final CallKitService instance = CallKitService._();
  CallKitService._();

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    ConnectycubeFlutterCallKit.instance.init(
      icon: 'ic_launcher',
      color: '#0955fa',
      onCallAccepted: (CallEvent event) async {
        log("onCallAccepted sessionId: ${event.sessionId}");
        log("onCallAccepted userInfo: ${event.userInfo}");
        log("onCallAccepted userInfo type: ${event.userInfo.runtimeType}");

        try {
          FlutterRingtonePlayer().stop();
        } catch (e) {
          log(e.toString());
        }

        CallSessionState.sessionId = event.sessionId;

        final rawUserInfo = event.userInfo;
        Map<String, dynamic> data = {};

        if (rawUserInfo != null && rawUserInfo.isNotEmpty) {
          if (rawUserInfo.length == 1 &&
              rawUserInfo.values.first.trim().startsWith("{")) {
            try {
              data = jsonDecode(rawUserInfo.values.first);
            } catch (e) {
              log("Error parsing userInfo JSON: $e");
              data = Map<String, dynamic>.from(rawUserInfo);
            }
          } else {
            data = Map<String, dynamic>.from(rawUserInfo);
          }
        }

        log("onCallAccepted parsed data: $data");

        if (data.isNotEmpty) {
          await navigateToCallScreen(data);
        } else {
          log("userInfo empty → using fallback");
          await _fallbackGetCallData(event.sessionId, accept: true);
        }
      },
      onCallRejected: (CallEvent event) async {
        log("onCallRejected sessionId: ${event.sessionId}");
        log("onCallRejected userInfo: ${event.userInfo}");

        final rawUserInfo = event.userInfo;
        Map<String, dynamic> data = {};

        if (rawUserInfo != null && rawUserInfo.isNotEmpty) {
          if (rawUserInfo.length == 1 &&
              rawUserInfo.values.first.trim().startsWith("{")) {
            try {
              data = jsonDecode(rawUserInfo.values.first);
            } catch (e) {
              log("Error parsing userInfo JSON: $e");
              data = Map<String, dynamic>.from(rawUserInfo);
            }
          } else {
            data = Map<String, dynamic>.from(rawUserInfo);
          }
        }

        if (data.isNotEmpty) {
          await declineCall(data);
        } else {
          await _fallbackGetCallData(event.sessionId, accept: false);
          log("========fallback-called");
        }
      },
    );
  }

  Map<String, dynamic> _parseRawCallData(Map<String, dynamic>? callData) {
    if (callData == null) return {};
    try {
      final userInfoRaw = callData["user_info"];
      if (userInfoRaw is String) return jsonDecode(userInfoRaw);
      if (userInfoRaw is Map) return Map<String, dynamic>.from(userInfoRaw);
    } catch (e) {
      log("❌ _parseRawCallData error: $e");
    }
    return {};
  }

  Future<void> _fallbackGetCallData(
    String sessionId, {
    required bool accept,
  }) async {
    try {
      log("_fallbackGetCallData sessionId: $sessionId");

      final callData = await ConnectycubeFlutterCallKit.getCallData(
        sessionId: sessionId,
      );

      log("_fallbackGetCallData callData: $callData");

      if (callData == null) return;

      final userInfoRaw = callData["user_info"];
      Map<String, dynamic> data = {};

      if (userInfoRaw is String) {
        try {
          data = jsonDecode(userInfoRaw);
        } catch (e) {
          log("jsonDecode error: $e");
        }
      } else if (userInfoRaw is Map) {
        data = Map<String, dynamic>.from(userInfoRaw);
      }

      log("_fallbackGetCallData data: $data");

      if (data.isNotEmpty) {
        if (accept) {
          await navigateToCallScreen(data);
        } else {
          await declineCall(data);
        }
      }
    } catch (e) {
      log("_fallbackGetCallData error: $e");
    }
  }

  Future<void> navigateToCallScreen(Map<String, dynamic> data) async {
    try {
      if (CallSessionState.isCallActive) return;

      log("navigateToCallScreen data: $data");

      CallSessionState.isCallActive = true;
      CallSessionState.launchedFromCall = true;

      final parsedData = {
        "callId": int.tryParse(data["callId"].toString()),
        "callerId": int.tryParse(data["callerId"].toString()),
        "receiverId": int.tryParse(data["receiverId"].toString()),
        "isVideo": data["isVideo"] == "true" || data["isVideo"] == true,
        "callerName": data["callerName"],
        "callerProfileImage": data["callerProfileImage"],
        "sdpOfferCompressed": data["sdpOfferCompressed"],
      };

      final call = IncomingCallModel.fromMap(parsedData);

      final offer = decomPress().decompressSDPOffer(
        call.sdpOfferCompressed,
      );

      Get.offNamed(
        Routes.callScreen,
        arguments: {
          "callerId": call.callerId,
          "remoteUserId":
              Global.storageServices.get(PrefConst.userId).toString(),
          "offer": offer,
          "is_video": call.isVideo,
          "callerName": call.callerName,
          "callId": call.callId,
          "callerProfile": call.callerProfileImage,
          "callType": "Incoming",
        },
      );

      final notificationId = int.tryParse(
        data["notificationId"]?.toString() ?? "",
      );
      if (notificationId != null && notificationId > 0) {
        await NotificationController().markAsRead(notificationId);
      }
    } catch (e) {
      log("navigateToCallScreen error: $e");
    }
  }

  Future<void> declineCall(Map<String, dynamic> data) async {
    try {
      final parsedData = {
        "callId": int.tryParse(data["callId"].toString()),
        "callerId": int.tryParse(data["callerId"].toString()),
        "receiverId": int.tryParse(data["receiverId"].toString()),
        "isVideo": data["isVideo"] == "true" || data["isVideo"] == true,
        "callerName": data["callerName"],
        "callerProfileImage": data["callerProfileImage"],
        "sdpOfferCompressed": data["sdpOfferCompressed"],
      };

      final call = IncomingCallModel.fromMap(parsedData);
      CallStateTracker.isIncomingCallScreenOpen = false;

      if (CallSessionState.sessionId != null) {
        await ConnectycubeFlutterCallKit.reportCallEnded(
          sessionId: CallSessionState.sessionId!,
        );
      }

      final socket = SignallingService.instance.socket;

      if (socket != null && socket.connected) {
        log("declineCall → via SOCKET");
        socket.emit("rejectCall", {
          "callId": call.callId,
          "remoteUserId": call.callerId,
        });
        log("========call-rejected via socket");
      } else {
        log("declineCall → via REST API (socket not available)");
        await _rejectCallViaApi(call.callId);
      }
    } catch (e) {
      log("declineCall error: $e");
    }
  }

  Future<void> _rejectCallViaApi(int? callId) async {
    if (callId == null) {
      log("_rejectCallViaApi: callId is null");
      return;
    }

    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString(PrefConst.STORAGE_USER_TOKEN_KEY) ?? "";

      if (token.isEmpty) {
        log("_rejectCallViaApi: token is empty");
        return;
      }

      final url = Uri.parse("${ConstRes.aBaseUrl}callRejected?callId=$callId");

      await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      log("_rejectCallViaApi error: $e");
    }
  }

  Future<void> checkCallOnLaunch() async {
    try {
      final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
      log("🔍 checkCallOnLaunch sessionId: $sessionId");

      if (sessionId == null) {
        log("🔍 No pending call found");
        return;
      }

      final state = await ConnectycubeFlutterCallKit.getCallState(
        sessionId: sessionId,
      );
      log("🔍 checkCallOnLaunch state: $state");

      final callData = await ConnectycubeFlutterCallKit.getCallData(
        sessionId: sessionId,
      );
      log("🔍 checkCallOnLaunch callData: $callData");

      final data = _parseRawCallData(callData);
      log("🔍 checkCallOnLaunch parsed data: $data");

      CallSessionState.sessionId = sessionId;

      switch (state) {
        case "accepted":
          log("State: accepted → navigating to CallScreen");
          if (data.isNotEmpty) {
            await navigateToCallScreen(data);
          } else {
            log("accepted but data empty → fallback");
            await _fallbackGetCallData(sessionId, accept: true);
          }
          break;

        case "rejected":
          log("State: rejected → cleaning up");
          if (data.isNotEmpty) {
            final socket = SignallingService.instance.socket;
            if (socket != null && socket.connected) {
              socket.emit("rejectCall", {
                "callId": data['callId']?.toString(),
                "remoteUserId": data['callerId']?.toString(),
              });
              log("rejectCall emitted via socket");
            } else {
              await _rejectCallViaApi(
                int.tryParse(data['callId']?.toString() ?? ""),
              );
            }
          }
          await _cleanupCall(sessionId);
          break;

        case "missed":
          await _cleanupCall(sessionId);
          break;

        case "cancelled":
          log("State: cancelled → cleaning up");
          await _cleanupCall(sessionId);
          break;

        default:
          if (data.isNotEmpty) {

            final socket = SignallingService.instance.socket;
            if (socket != null && socket.connected) {
              final myUserId =
                  Global.storageServices.get(PrefConst.userId).toString();
              final targetUser = (myUserId == data['callerId']?.toString())
                  ? myUserId
                  : data['callerId']?.toString();

              socket.emit("endCall", {
                "callId": data['callId']?.toString(),
                "remoteUserId": targetUser,
              });
              log("endCall emitted for unknown state");
            }
          }
          await _cleanupCall(sessionId);
          break;
      }
    } catch (e) {
      // await RemoteLoggerTest.log("checkCallOnLaunch", "error: $e");
      log("checkCallOnLaunch error: $e");
    }
  }

  Future<void> _cleanupCall(String sessionId) async {
    try {
      await ConnectycubeFlutterCallKit.reportCallEnded(
        sessionId: sessionId,
      );
      await ConnectycubeFlutterCallKit.clearCallData(
        sessionId: sessionId,
      );
      CallSessionState.reset();
      CallStateTracker.isIncomingCallScreenOpen = false;
      // await RemoteLoggerTest.log("_Callcleaned", "up: $sessionId");
      log("✅ Call cleaned up: $sessionId");
    } catch (e) {

      log("❌ _cleanupCall error: $e");
    }
  }
}

String callIdToUuid(String callId) {
  final padded = callId.padLeft(12, '0');
  return "00000000-0000-4000-8000-$padded";
}
