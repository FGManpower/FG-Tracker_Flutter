// import 'dart:developer';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/entities/notification_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:get/get.dart';
//
// import '../../Data/Services/CallStateTracker.dart';
// import '../../Data/Services/SignallingService.dart';
// import '../../Model/call_model.dart';
// import '../../routes/app_pages.dart';
// import '../constant/pref_res.dart';
// import '../global/launchedFromCall.dart';
// import '../values/global.dart';
// import 'decomPress.dart';
// import 'package:uuid/uuid.dart';
//
//
//
// class CallUtils {
//   CallUtils._privateConstructor();
//
//   static final CallUtils instance = CallUtils._privateConstructor();
//
//   // final socket = SignallingService.instance.socket;
//   final _uuid = const Uuid();
//
//   Future<void> showIncomingCall({required Map<String, dynamic> data}) async {
//     final String currentUuid = _uuid.v4();
//     CallSessionState.currentCallKitId = currentUuid;
//     print("=======currentUuid=====${currentUuid}");
//     print("=======NotificationData=====${data}");
//     final isVideo = data['isVideo'] == true;
//
//     final CallKitParams params = CallKitParams(
//       id: currentUuid,
//       nameCaller: data['callerName'] ?? 'Unknown',
//       appName: 'FG Tracker',
//       avatar: data['callerProfileImage'] ?? '',
//       handle: data['callerId'] ?? '',
//       type: isVideo ? 1 : 0,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       duration: 30000,
//       extra: data,
//       headers: {'apiKey': 'Abc@123!', 'platform': 'flutter'},
//       missedCallNotification: NotificationParams(
//         showNotification: true,
//         isShowCallback: true,
//         subtitle: 'Missed call',
//         callbackText: 'Call back',
//       ),
//       callingNotification: const NotificationParams(
//         showNotification: true,
//         isShowCallback: true,
//         subtitle: 'Calling...',
//         callbackText: 'Hang Up',
//       ),
//
//       android: AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: false,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955fa',
//         actionColor: '#4CAF50',
//         textColor: '#ffffff',
//         incomingCallNotificationChannelName: "Incoming Call",
//         missedCallNotificationChannelName: "Missed Call",
//         isShowCallID: false,
//
//         // CHANGE THESE TWO:
//         isShowFullLockedScreen: true, // Required for terminated/locked state
//         isBot: true,
//       ),
//
//       ios: IOSParams(
//         iconName: data['callerProfileImage'] ?? 'CallKitLogo',
//         handleType: 'generic',
//         supportsVideo: true,
//         maximumCallGroups: 1,
//         maximumCallsPerCallGroup: 1,
//         audioSessionMode: 'default',
//         audioSessionActive: true,
//         supportsDTMF: true,
//         supportsHolding: true,
//         supportsGrouping: false,
//         supportsUngrouping: false,
//         ringtonePath: 'system_ringtone_default',
//       ),
//     );
//     print("=======paramsofNotificaiton=====${params.extra}");
//     await FlutterCallkitIncoming.showCallkitIncoming(params);
//   }
//
//   void listenCallKitEvents() {
//     FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
//       if (event == null) return;
//
//       log("[CallKit Event] ${event.event.name}");
//       log("[CallKit Body] ${event.body}");
//
//       switch (event.event) {
//         case Event.actionCallAccept:
//           print("============ActiveCallas:${CallSessionState.isCallActive}");
//           if (CallSessionState.isCallActive) return;
//
//           final callId = event.body['id'];
//
//           await FlutterCallkitIncoming.setCallConnected(callId);
//           CallSessionState.isCallActive = true;
//           CallSessionState.launchedFromCall = true;
//
//           final extra = decomPress().extractExtra(event.body);
//           navigateToCallScreen(extra);
//           break;
//
//         case Event.actionCallDecline:
//           CallSessionState.reset();
//           final callId = event.body['id'];
//           await FlutterCallkitIncoming.endCall(callId);
//           final extra = decomPress().extractExtra(event.body);
//           declineCall(extra);
//           break;
//
//         case Event.actionCallEnded:
//           final callId = event.body['id'];
//           await FlutterCallkitIncoming.endCall(callId);
//           CallSessionState.reset();
//           final extra = decomPress().extractExtra(event.body);
//           declineCall(extra);
//           break;
//
//         case Event.actionCallTimeout:
//           final callId = event.body['id'];
//           await FlutterCallkitIncoming.endCall(callId);
//           CallSessionState.reset();
//           final extra = decomPress().extractExtra(event.body);
//           _handleMissedCall(extra);
//           break;
//
//         default:
//           break;
//       }
//     });
//   }
//
//   void _handleMissedCall(Map<String, dynamic> data) {
//     final call = IncomingCallModel.fromMap(data);
//
//     // socket?.emit("missedCall", {
//     //   "remoteUserId": call.callerId,
//     // });
//
//     CallStateTracker.isIncomingCallScreenOpen = false;
//   }
//
//   Future<void> declineCall(Map<String, dynamic> data) async {
//     final call = IncomingCallModel.fromMap(data);
//     final myId = Global.storageServices.get(PrefConst.userId).toString();
//
//     log("=======callRejected;=${data}");
//     socket?.emit("rejectCall", {
//       "remoteUserId": myId == call.callerId ? call.receiverId : call.callerId,
//     });
//     socket?.emit("rejectCall", {
//       "callId": call.callId,
//       "remoteUserId": myId,
//     });
//
//     CallStateTracker.isIncomingCallScreenOpen = false;
//   }
//
//   Future<void> navigateToCallScreen(Map<String, dynamic> data) async {
//     try {
//       print("=======navigatoretoCallscree;=${data}");
//       final call = IncomingCallModel.fromMap(data);
//
//       // CallStateTracker.isIncomingCallScreenOpen = false;
//
//       Map<String, dynamic>? offer =
//           await decomPress().decompressSDPOffer(call.sdpOfferCompressed);
//       Get.offNamed(
//         Routes.callScreen,
//         arguments: {
//           "callerId": call.callerId,
//           "remoteUserId":
//               Global.storageServices.get(PrefConst.userId).toString(),
//           "offer": offer,
//           "is_video": call.isVideo,
//           "callerName": call.callerName,
//           "callId": call.callId,
//           "callerProfile": call.callerProfileImage,
//           "callType": "Incoming",
//         },
//       );
//     } catch (e) {
//       log("[CallKit] Navigation error: $e");
//     }
//   }
// }
//
//
