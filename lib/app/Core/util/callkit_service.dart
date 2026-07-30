import 'dart:convert';
import 'dart:developer';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:get/get.dart';
import '../../Data/Services/CallStateTracker.dart';
import '../../Data/Services/SignallingService.dart';
import '../../Model/call_model.dart';
import '../../routes/app_pages.dart';
import '../constant/pref_res.dart';
import '../global/launchedFromCall.dart';
import '../values/global.dart';
import 'decomPress.dart';

class CallKitService {
  static final CallKitService instance = CallKitService._();
  CallKitService._();

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    log("=== CallKitService Init ===");

    ConnectycubeFlutterCallKit.instance.init(
      icon: 'ic_launcher',
      color: '#0955fa',

      // ✅ User tapped Accept
      onCallAccepted: (CallEvent event) async {
        log("onCallAccepted sessionId: ${event.sessionId}");
        log("onCallAccepted userInfo: ${event.userInfo}");
        log("onCallAccepted userInfo type: ${event.userInfo.runtimeType}");

        CallSessionState.sessionId = event.sessionId;

        final rawUserInfo = event.userInfo;
        Map<String, dynamic> data = {};

        if (rawUserInfo != null && rawUserInfo.isNotEmpty) {
          // ✅ Check if userInfo is stored as JSON string in a single key
          // (happens on iOS when backend sends user_info as JSON string)
          if (rawUserInfo.length == 1 &&
              rawUserInfo.values.first.trim().startsWith("{")) {
            try {
              data = jsonDecode(rawUserInfo.values.first);
            } catch (e) {
              log("Error parsing userInfo JSON: $e");
              data = Map<String, dynamic>.from(rawUserInfo);
            }
          } else {
            // ✅ Regular Map<String, String>
            data = Map<String, dynamic>.from(rawUserInfo);
          }
        }

        log("onCallAccepted parsed data: $data");

        if (data.isNotEmpty) {
          await navigateToCallScreen(data);
        } else {
          // ✅ Fallback if userInfo is empty
          log("userInfo empty → using fallback");
          await _fallbackGetCallData(event.sessionId, accept: true);
        }
      },

      // ✅ User tapped Reject
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
        }
      },
    );
  }

  // ✅ Fallback when userInfo is empty
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

  // ✅ Navigate to call screen
  Future<void> navigateToCallScreen(Map<String, dynamic> data) async {
    try {
      if (CallSessionState.isCallActive) return;

      log("navigateToCallScreen data: $data");

      CallSessionState.isCallActive = true;
      CallSessionState.launchedFromCall = true;

      final parsedData = {
        "callId":             int.tryParse(data["callId"].toString()),
        "callerId":           int.tryParse(data["callerId"].toString()),
        "receiverId":         int.tryParse(data["receiverId"].toString()),
        "isVideo":            data["isVideo"] == "true" || data["isVideo"] == true,
        "callerName":         data["callerName"],
        "callerProfileImage": data["callerProfileImage"],
        "sdpOfferCompressed": data["sdpOfferCompressed"],
      };

      final call = IncomingCallModel.fromMap(parsedData);

      final offer = await decomPress().decompressSDPOffer(
        call.sdpOfferCompressed,
      );

      Get.offNamed(
        Routes.callScreen,
        arguments: {
          "callerId":     call.callerId,
          "remoteUserId": Global.storageServices.get(PrefConst.userId).toString(),
          "offer":        offer,
          "is_video":     call.isVideo,
          "callerName":   call.callerName,
          "callId":       call.callId,
          "callerProfile":call.callerProfileImage,
          "callType":     "Incoming",
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

  // ✅ Decline call
  Future<void> declineCall(Map<String, dynamic> data) async {
    try {
      final parsedData = {
        "callId":             int.tryParse(data["callId"].toString()),
        "callerId":           int.tryParse(data["callerId"].toString()),
        "receiverId":         int.tryParse(data["receiverId"].toString()),
        "isVideo":            data["isVideo"] == "true" || data["isVideo"] == true,
        "callerName":         data["callerName"],
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

      SignallingService.instance.socket?.emit("rejectCall", {
        "callId":       call.callId,
        "remoteUserId": call.callerId,
      });
    } catch (e) {
      log("declineCall error: $e");
    }
  }

  // ✅ Check call when app launched from killed state
  Future<void> checkCallOnLaunch() async {
    try {
      final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
      log("checkCallOnLaunch sessionId: $sessionId");

      if (sessionId == null) return;

      final state = await ConnectycubeFlutterCallKit.getCallState(
        sessionId: sessionId,
      );
      log("checkCallOnLaunch state: $state");

      if (state == "accepted") {
        final callData = await ConnectycubeFlutterCallKit.getCallData(
          sessionId: sessionId,
        );
        log("checkCallOnLaunch callData: $callData");

        final userInfoRaw = callData?["user_info"];
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

        CallSessionState.sessionId = sessionId;

        if (data.isNotEmpty) {
          await navigateToCallScreen(data);
        }
      } else {
        // ✅ Call was missed/rejected - end it
        CallSessionState.sessionId = sessionId;
        final callData = await ConnectycubeFlutterCallKit.getCallData(
          sessionId: sessionId,
        );

        if (callData != null) {
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

          if (data.isNotEmpty) {
            final myUserId = Global.storageServices
                .get(PrefConst.userId)
                .toString();
            final targetUser = (myUserId == data['callerId'].toString())
                ? myUserId
                : data['callerId'].toString();

            SignallingService.instance.socket?.emit("endCall", {
              "callId":       data['callId'].toString(),
              "remoteUserId": targetUser,
            });
          }

          await ConnectycubeFlutterCallKit.clearCallData(
            sessionId: sessionId,
          );
          CallSessionState.reset();
        }
      }
    } catch (e) {
      log("checkCallOnLaunch error: $e");
    }
  }
}