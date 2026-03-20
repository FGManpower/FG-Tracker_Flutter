import 'dart:convert';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
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
  static final CallKitService instance = CallKitService._privateConstructor();
  CallKitService._privateConstructor();

  final socket = SignallingService.instance.socket;

  /// Initialize CallKit
  void init() {
    ConnectycubeFlutterCallKit.instance.init(
      icon: 'ic_launcher',
      color: '#0955fa',

      /// ACCEPT CALL
      onCallAccepted: (CallEvent event) async {
        print("Call Accepted: ${event.sessionId}");

        CallSessionState.sessionId = event.sessionId;

        final data = Map<String, dynamic>.from(event.userInfo ?? {});

        if (data.isNotEmpty) {
          navigateToCallScreen(data);
        }
      },

      /// REJECT CALL
      onCallRejected: (CallEvent event) async {
        print("Call Rejected: ${event.sessionId}");

        final data = Map<String, dynamic>.from(event.userInfo ?? {});

        if (data.isNotEmpty) {
          declineCall(data);
        }
      },
    );
  }

  /// Reject Call
  Future<void> declineCall(Map<String, dynamic> data) async {

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

    final myId = Global.storageServices.get(PrefConst.userId).toString();

    CallStateTracker.isIncomingCallScreenOpen = false;

    if (CallSessionState.sessionId != null) {
      await ConnectycubeFlutterCallKit.clearCallData(
          sessionId: CallSessionState.sessionId!);
    }

    socket?.emit("rejectCall", {
      "remoteUserId": myId == call.callerId ? call.receiverId : call.callerId,
    });

    socket?.emit("rejectCall", {
      "callId": call.callId,
      "remoteUserId": myId,
    });
  }

  /// Navigate to Call Screen
  Future<void> navigateToCallScreen(Map<String, dynamic> data) async {
    try {
      if (CallSessionState.isCallActive) return;

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

      print("Parsed Call Data: $parsedData");

      final call = IncomingCallModel.fromMap(parsedData);

      Map<String, dynamic>? offer =
          await decomPress().decompressSDPOffer(call.sdpOfferCompressed);

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
    } catch (e) {
      print("[CallKit] Navigation error: $e");
    }
  }

  /// Recover call when app launches from terminated state
  Future<void> checkCallOnLaunch() async {
    try {
      final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();

      if (sessionId == null) {
        print("No last call session");
        return;
      }

      final state =
          await ConnectycubeFlutterCallKit.getCallState(sessionId: sessionId);

      print("Call state: $state");

      if (state == "accepted") {
        CallSessionState.sessionId = sessionId;

        final callData =
            await ConnectycubeFlutterCallKit.getCallData(sessionId: sessionId);

        if (callData != null) {
          final userInfoRaw = callData["user_info"];

          Map<String, dynamic> data = {};

          if (userInfoRaw is String) {
            data = jsonDecode(userInfoRaw);
          } else if (userInfoRaw is Map) {
            data = Map<String, dynamic>.from(userInfoRaw);
          }

          print("Recovered call data: $data");

          navigateToCallScreen(data);
        }
      }
    } catch (e) {
      print("checkCallOnLaunch error: $e");
    }
  }
}
