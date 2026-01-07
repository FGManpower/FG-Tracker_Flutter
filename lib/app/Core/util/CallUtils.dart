// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:get/get.dart';
//
// import '../../Data/Services/CallStateTracker.dart';
// import '../../Data/Services/SignallingService.dart';
// import '../../Model/call_model.dart';
// import '../../routes/app_pages.dart';
// import '../constant/pref_res.dart';
// import '../values/global.dart';
// import 'decomPress.dart';
//
// class CallUtils {
//   final socket = SignallingService.instance.socket;
//
//   CallUtils() {
//     setupSocketCallEvents();
//   }
//
//   Future<void> showIncomingCall(IncomingCallModel data) async {
//     try {
//       final callId = data.callId?.toString() ??
//           DateTime.now().millisecondsSinceEpoch.toString();
//
//       final isVideo = data.isVideo == true;
//
//       final callMap = data.toMap();
//       jsonEncode(callMap);
//
//       final params = CallKitParams(
//         id: callId,
//         nameCaller: data.callerName ?? 'Unknown Caller',
//         appName: 'FG Tracker',
//         avatar: data.callerProfileImage ?? '',
//         handle: data.callerId ?? '',
//         type: isVideo ? 1 : 0,
//         duration: 30000,
//         textAccept: 'Accept',
//         textDecline: 'Decline',
//         extra: callMap,
//         android: const AndroidParams(
//           isCustomNotification: true,
//           isShowLogo: true,
//           backgroundColor: '#0955fa',
//           actionColor: '#4CAF50',
//           isShowFullLockedScreen: false,
//         ),
//         ios: const IOSParams(
//           handleType: 'generic',
//           supportsVideo: true,
//         ),
//       );
//
//       await FlutterCallkitIncoming.showCallkitIncoming(params);
//       log('[CallUtils] Incoming call shown with ID: $callId');
//     } catch (e, st) {
//       log('[CallUtils] showIncomingCall error: $e\n$st');
//     }
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
//           final extra = decomPress().extractExtra(event.body);
//           _navigateToCallScreen(extra);
//           break;
//
//         case Event.actionCallDecline:
//           final extra = decomPress().extractExtra(event.body);
//           declineCall(extra);
//           break;
//
//         case Event.actionCallEnded:
//           final extra = decomPress().extractExtra(event.body);
//           declineCall(extra);
//           break;
//
//         case Event.actionCallTimeout:
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
//
//
//   void _handleMissedCall(Map<String, dynamic> data) {
//     final call = IncomingCallModel.fromMap(data);
//
//     socket?.emit("missedCall", {
//       "remoteUserId": call.callerId,
//     });
//
//     CallStateTracker.isIncomingCallScreenOpen = false;
//     FlutterCallkitIncoming.endAllCalls();
//   }
//
//   Future<void> declineCall(Map<String, dynamic> data) async {
//     final call = IncomingCallModel.fromMap(data);
//     final myId = Global.storageServices.get(PrefConst.userId).toString();
//
//     socket?.emit("rejectCall", {
//       "remoteUserId": myId == call.callerId ? call.receiverId : call.callerId,
//     });
//
//     CallStateTracker.isIncomingCallScreenOpen = false;
//     FlutterCallkitIncoming.endAllCalls();
//   }
//
//   Future<void> _navigateToCallScreen(Map<String, dynamic> data) async {
//     try {
//       final call = IncomingCallModel.fromMap(data);
//
//       CallStateTracker.isIncomingCallScreenOpen = false;
//
//       Map<String, dynamic>? offer =
//       await decomPress().decompressSDPOffer(call.sdpOfferCompressed);
//
//       Get.offNamed(
//         Routes.callScreen,
//         arguments: {
//           "callerId": call.callerId,
//           "remoteUserId":
//           Global.storageServices.get(PrefConst.userId).toString(),
//           "offer": offer,
//           "is_video": call.isVideo,
//           "callerName": call.callerName,
//           "callId": call.callId,
//           "callerProfile": call.callerProfileImage,
//         },
//       );
//     } catch (e) {
//       log("[CallKit] Navigation error: $e");
//     }
//   }
//
//   void setupSocketCallEvents() {
//     socket?.on("callEnded", (data) {
//       CallStateTracker.isIncomingCallScreenOpen = false;
//       FlutterCallkitIncoming.endAllCalls();
//
//       if (Get.isOverlaysOpen || Get.isDialogOpen == true) {
//         Get.back();
//       } else if (Get.currentRoute == Routes.callScreen) {
//         Get.back();
//       }
//     });
//
//     socket?.on("missedCall", (data) {
//       CallStateTracker.isIncomingCallScreenOpen = false;
//       FlutterCallkitIncoming.endAllCalls();
//
//       if (Get.currentRoute == Routes.callScreen) {
//         Get.back();
//       }
//     });
//   }
// }
