// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../Core/theme/appTheme.dart';
//
//
// class IncomingCallScreen extends StatelessWidget {
//   final String callerName;
//   final int callId;
//   final String fromUserId;
//   final bool isVideo;
//
//   const IncomingCallScreen({
//     super.key,
//     required this.callerName,
//     required this.callId,
//     required this.fromUserId,
//     required this.isVideo,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     /// ✅ ALWAYS USE GLOBAL SINGLETON
//     final cs = CallManager.instance.callService;
//
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 40),
//
//             /// Caller Photo
//              CircleAvatar(
//               radius: 55,
//               backgroundImage: NetworkImage(MyAppTheme.ProfilenotFoundImg),
//             ),
//
//             const SizedBox(height: 25),
//
//             Text(
//               callerName,
//               style: const TextStyle(
//                 fontSize: 26,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             Text(
//               isVideo ? "Incoming Video Call…" : "Incoming Audio Call…",
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.white70,
//               ),
//             ),
//
//             const SizedBox(height: 50),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // 🔴 REJECT CALL
//                 FloatingActionButton(
//                   // heroTag: "reject_call_btn",
//                   backgroundColor: Colors.red,
//                   onPressed: () {
//                     cs.rejectCall(
//                       callId: callId,
//                       userId: cs.myUserId!,
//                     );
//                     Get.back();
//                   },
//                   child: const Icon(Icons.call_end, color: Colors.white),
//                 ),
//
//                 // 🟢 ACCEPT CALL
//                 FloatingActionButton(
//                   // heroTag: "accept_call_btn",
//                   backgroundColor: Colors.green,
//                   onPressed: () async {
//                     await cs.acceptCall(
//                       callId: callId,
//                       userId: cs.myUserId!,
//                     );
//
//                     /// 🔥 Navigate to CallScreen
//                     Get.off(() => CallScreen(
//                       callService: cs,
//                       peerId: fromUserId,
//                       isVideo: isVideo,
//                     ));
//                   },
//                   child: const Icon(Icons.call, color: Colors.white),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
