// import 'dart:io';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
//
// class CallKitService {
//   static Future<void> showIncomingCall(Map<String, dynamic> callData) async {
//     if (!Platform.isIOS) return;
//     print("===incomminData:${callData}");
//     final params = CallKitParams(
//       id: callData['callId'].toString(),
//       nameCaller: callData['callerName'] ?? 'Unknown',
//       appName: 'FG Tracker',
//       avatar: callData['callerProfileImage'] ?? '',
//       handle: callData['callerId'] ?? '',
//       type: callData['isVideo'] == true ? 1 : 0,
//       duration: 30000,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       extra: callData,
//       ios: const IOSParams(
//         supportsVideo: true,
//         handleType: 'generic',
//       ),
//     );
//
//     await FlutterCallkitIncoming.showCallkitIncoming(params);
//   }
//
//   static Future<void> endAllCalls() async {
//     if (!Platform.isIOS) return;
//     await FlutterCallkitIncoming.endAllCalls();
//   }
// }
