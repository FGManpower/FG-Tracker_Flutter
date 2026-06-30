import 'dart:developer';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import '../../Data/Services/CallStateTracker.dart';
import '../../Data/Services/SignallingService.dart';
import '../../Model/call_model.dart';
import '../../routes/app_pages.dart';
import '../constant/pref_res.dart';
import '../global/launchedFromCall.dart';
import '../values/global.dart';
import 'decomPress.dart';
import 'package:uuid/uuid.dart';

class CallUtils {
  CallUtils._privateConstructor();

  static final CallUtils instance = CallUtils._privateConstructor();

  final socket = SignallingService.instance.socket;
  final _uuid = const Uuid();

  Future<void> showIncomingCall({required Map<String, dynamic> data}) async {
    final String currentUuid = _uuid.v4();
    CallSessionState.sessionId = currentUuid;

    final isVideo = data['isVideo'] == true;

    final CallKitParams params = CallKitParams(
      id: currentUuid,
      nameCaller: data['callerName'] ?? 'Unknown',
      appName: 'FG Tracker',
      avatar: data['callerProfileImage'] ?? '',
      handle: data['callerId'] ?? '',
      type: isVideo ? 1 : 0,

      // textAccept: 'Accept',
      // textDecline: 'Decline',
      duration: 30000,
      extra: data,
      headers: {'apiKey': 'Abc@123!', 'platform': 'flutter'},
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      callingNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Calling...',
        callbackText: 'Hang Up',
      ),

      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        isShowCallID: false,

        isShowFullLockedScreen: true, // Required for terminated/locked state
        isBot: true,
      ),

      ios: IOSParams(
        iconName: data['callerProfileImage'] ?? 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    print("=======paramsofNotificaiton=====${params.extra}");
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> listenCallKitEvents() async {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      log("[CallKit Event] ${event?.eventName}");

      switch (event) {
        case CallEventActionCallIncoming():
          log("Incoming Call");
          break;

        case CallEventActionCallStart():
          log("Outgoing Call Started");
          break;

        case CallEventActionCallAccept():
          print("============ActiveCall:${CallSessionState.isCallActive}");

          if (CallSessionState.isCallActive) return;

          final params = event.callKitParams;

          await FlutterCallkitIncoming.setCallConnected(params.id);

          CallSessionState.isCallActive = true;
          CallSessionState.launchedFromCall = true;

          final extra = decomPress().extractExtra(params.extra ?? {});
          navigateToCallScreen(extra);
          break;

        case CallEventActionCallDecline():
          final params = event.callKitParams;

          CallSessionState.reset();

          await FlutterCallkitIncoming.endCall(params.id);

          final extra = decomPress().extractExtra(params.extra ?? {});
          declineCall(extra);
          break;

        case CallEventActionCallEnded():
          final params = event.callKitParams;

          CallSessionState.reset();

          final extra = decomPress().extractExtra(params.extra ?? {});
          declineCall(extra);
          break;

        // case CallEventActionCallTimeout():
        //   final params = event.callKitParams;
        //
        //   CallSessionState.reset();
        //
        //   final extra = decomPress().extractExtra(params.extra ?? {});
        //   _handleMissedCall(extra);
        //   break;

        case CallEventActionCallCallback():
          log("Call Callback");
          break;

        case CallEventActionCallToggleHold():
          log("Hold");
          break;

        case CallEventActionCallToggleMute():
          log("Mute");
          break;

        case CallEventActionCallToggleDmtf():
          log("DTMF");
          break;

        case CallEventActionCallToggleGroup():
          log("Group");
          break;

        case CallEventActionCallToggleAudioSession():
          log("Audio Session");
          break;

        case CallEventActionDidUpdateDevicePushTokenVoip():
          log("VoIP Token Updated");
          break;

        default:
          log("Unhandled Event: ${event?.eventName}");
          break;
      }
    });
  }

  // void _handleMissedCall(Map<String, dynamic> data) {
  //   final call = IncomingCallModel.fromMap(data);
  //
  //   // socket?.emit("missedCall", {
  //   //   "remoteUserId": call.callerId,
  //   // });
  //
  //   CallStateTracker.isIncomingCallScreenOpen = false;
  // }

  Future<void> declineCall(Map<String, dynamic> data) async {
    final call = IncomingCallModel.fromMap(data);
    final myId = Global.storageServices.get(PrefConst.userId).toString();

    log("=======callRejected;=${data}");
    socket?.emit("rejectCall", {
      "remoteUserId": myId == call.callerId ? call.receiverId : call.callerId,
    });
    socket?.emit("rejectCall", {
      "callId": call.callId,
      "remoteUserId": myId,
    });

    CallStateTracker.isIncomingCallScreenOpen = false;
  }

  Future<void> navigateToCallScreen(Map<String, dynamic> data) async {
    try {
      print("=======navigatoretoCallscree;=${data}");
      final call = IncomingCallModel.fromMap(data);

      // CallStateTracker.isIncomingCallScreenOpen = false;

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
      await NotificationController().markAsRead(
        int.parse(data["notificationId"].toString()),
      );
    } catch (e) {
      log("[CallKit] Navigation error: $e");
    }
  }
}
