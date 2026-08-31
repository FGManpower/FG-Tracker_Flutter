// import 'dart:developer';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
//
// import '../../Data/Services/CallStateTracker.dart';
// import '../../Data/Services/Socket_Walkie-Talkie-Service.dart';
// import '../../Model/call_model.dart';
// import '../../modules/Walkie-talkie/Controller/walkieController.dart';
// import '../global/launchedFromCall.dart';
// import 'decomPress.dart';
// import 'package:uuid/uuid.dart';
//
// class WalkieUtils {
//   final socket = WalkietalkieService.instance.socket;
//   final _uuid = const Uuid();
//   WalkieUtils() {
//     setupSocketCallEvents();
//   }
//
//   Future<void> showIncomingWalkie({required Map<String, dynamic> data}) async {
//     final String currentUuid = _uuid.v4();
//
//     final CallKitParams params = CallKitParams(
//       id: currentUuid,
//       nameCaller: "Walkie Call" ?? 'Unknown',
//       appName: 'FG Tracker',
//       avatar: "" ?? '',
//       handle: 'generic',
//       type: 0,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       duration: 30000,
//       extra: data,
//       headers: {'apiKey': 'Abc@123!', 'platform': 'flutter'},
//       android: const AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: false,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955fa',
//         actionColor: '#4CAF50',
//         textColor: '#ffffff',
//         incomingCallNotificationChannelName: "Incoming Walkie",
//         missedCallNotificationChannelName: "Missed Walkie",
//       ),
//       ios: IOSParams(
//         iconName: '',
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
//
//     await FlutterCallkitIncoming.showCallkitIncoming(params);
//   }
//
//   void listenWalkieEvents() {
//     FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
//       if (event == null) return;
//
//       log("[Walkie Event] ${event.event.name}");
//       log("[Walkie Body] ${event.body}");
//
//       switch (event.event) {
//         case Event.actionCallAccept:
//           if (CallSessionState.isCallActive) return;
//
//           CallSessionState.isCallActive = true;
//           CallSessionState.launchedFromCall = true;
//
//           final extra = decomPress().extractExtra(event.body);
//           _navigateToWalkieScreen(extra);
//           break;
//
//         case Event.actionCallDecline:
//           CallSessionState.reset();
//           final extra = decomPress().extractExtra(event.body);
//           declineCall(extra);
//           break;
//
//         case Event.actionCallEnded:
//           CallSessionState.reset();
//           final extra = decomPress().extractExtra(event.body);
//           declineCall(extra);
//           break;
//
//         case Event.actionCallTimeout:
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
//     socket?.emit("missedCall", {
//       "remoteUserId": call.callerId,
//     });
//
//     CallStateTracker.isIncomingCallScreenOpen = false;
//     FlutterCallkitIncoming.endAllCalls();
//   }
//
//   Future<void> declineCall(Map<String, dynamic> data) async {
//     print("=======WalkieRejected;=${data}");
//
//     CallStateTracker.isIncomingCallScreenOpen = false;
//     FlutterCallkitIncoming.endAllCalls();
//   }
//
//   Future<void> _navigateToWalkieScreen(Map<String, dynamic> data) async {
//     try {
//       print("=======navigatoretoWalkieScreeen====>${data}");
//       WalkieController().onIncoming(
//         remoteUserId: data['fromUserId'],
//         callerName: "Unknown",
//         profileImage: "",
//       );
//
//       // endWalkieCall();
//     } catch (e) {
//       log("[CallKit] Navigation error: $e");
//     }
//   }
//
//   Future<void> endWalkieCall() async {
//     try {
//       print("🛑 Ending Walkie Call");
//
//       // Reset global call state
//       CallSessionState.reset();
//       await FlutterCallkitIncoming.endAllCalls();
//
//     } catch (e) {
//       log("Walkie end error: $e");
//     }
//   }
//
//
//   void setupSocketCallEvents() {}
// }
