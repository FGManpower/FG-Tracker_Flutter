// import 'dart:async';
// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fgtracker/app/Model/call_model.dart';
// import 'package:fgtracker/app/global_widget/common_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
//
// import '../../config/themes_data.dart';
// import 'Controller/call_controller.dart';
//
// class AgoraCallScreen extends StatefulWidget {
//   final CallModel call;
//
//   const AgoraCallScreen({Key? key, required this.call}) : super(key: key);
//
//   @override
//   State<AgoraCallScreen> createState() => _AgoraCallScreenState();
// }
//
// class _AgoraCallScreenState extends State<AgoraCallScreen> {
//   final CallController controller = Get.put(CallController());
//   StreamSubscription<DocumentSnapshot>? _callStreamSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller.initAgora(
//       channelId: widget.call.channelId,
//       isVideo: widget.call.isVideo,
//     );
//
//     _callStreamSubscription = FirebaseFirestore.instance
//         .collection('calls')
//         .doc(widget.call.channelId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists && snapshot.data()?['hasEnded'] == true ||
//           snapshot.data()?['status'] == 'rejected') {
//         controller.endCall(context);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _callStreamSubscription?.cancel();
//     controller.disposeAgora();
//     super.dispose();
//   }
//
//   Widget _renderLocalPreview() {
//     log("LocalPreview----------");
//     return Obx(() => controller.localJoined.value
//         ? AgoraVideoView(
//       controller: VideoViewController(
//         rtcEngine: controller.engine,
//         canvas: const VideoCanvas(uid: 0),
//       ),
//     )
//         : const Center(child: CircularProgressIndicator()));
//   }
//
//   Widget _renderRemoteVideo() {
//     return Obx(() {
//       if (controller.remoteUid.value != "") {
//         return AgoraVideoView(
//           controller: VideoViewController.remote(
//             rtcEngine: controller.engine,
//             canvas: VideoCanvas(uid: int.parse(controller.remoteUid.value)),
//             connection: RtcConnection(channelId: widget.call.channelId),
//           ),
//         );
//       } else {
//         return  Center(
//           child: reausabletext(
//             "Waiting for user to join...",
//             color: Colors.white),
//         );
//       }
//     });
//   }
//
//   Widget _buildCallControls() {
//     if (widget.call.isVideo) {
//       return Align(
//         alignment: Alignment.bottomCenter,
//         child: Padding(
//           padding: EdgeInsetsGeometry.only(left: 15.w,right: 15.w
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.all(Radius.circular(50)),
//               color: Colors.white,),
//
//             padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Speaker
//                 IconButton(
//                   icon: Icon(
//                     controller.isSpeakerOn.value ? Icons.volume_up : Icons.volume_off,
//                     color: ToggleThemeData.customBlue,
//                     size: 30.sp,
//                   ),
//                   onPressed: controller.toggleSpeaker,
//                 ),
//
//                 // Mic
//                 IconButton(
//                   icon: Icon(
//                     controller.isMuted.value ? Icons.mic_off : Icons.mic,
//                     color: ToggleThemeData.customBlue,
//                     size: 30.sp,
//                   ),
//                   onPressed: controller.toggleMute,
//                 ),
//
//                 // Camera Switch
//                  IconButton(
//                   icon: Icon(
//                     Icons.cameraswitch,
//                     color: ToggleThemeData.customBlue,
//                     size: 30.sp,
//                   ),
//                   onPressed: controller.switchCamera,
//                 ),
//
//                 // End Call
//                IconButton(
//                   icon:  Icon(Icons.call_end, color: Colors.red, size: 30.sp),
//                   onPressed: controller.isEndingCall.value
//                       ? null
//                       : () async {
//                     controller.isEndingCall.value = true;
//                     await controller.endCall(context);
//                     controller.isEndingCall.value = false;
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     } else {
//
//       return Align(
//         alignment: Alignment.bottomCenter,
//         child: Padding(
//           padding:  EdgeInsets.only(bottom: 2.h, top: 20.h),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                    SizedBox(width: 25.w
//                    ),
//                  Container(
//                     width: 70.w
//                      ,
//                     height: 70.h,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: controller.isSpeakerOn.value
//                           ? Colors.white
//                           : ToggleThemeData.customBlue,
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         controller.isSpeakerOn.value ? Icons.volume_up : Icons.volume_off,
//                         size: 35.sp,
//                         color: controller.isSpeakerOn.value
//                             ? ToggleThemeData.customBlue
//                             : Colors.white,
//                       ),
//                       onPressed: () {
//                         // controller.isSpeakerOn();
//                         controller.toggleSpeaker();
//                       },
//                   )),
//                    SizedBox(width: 25.w),
//                   // Mic
//                   Container(
//                     width: 70.w,
//                     height: 70.h,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: controller.isMuted.value
//                           ? Colors.white
//                           : ToggleThemeData.customBlue,
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         controller.isMuted.value ? Icons.mic_off : Icons.mic,
//                         size: 35.sp,
//                         color: controller.isMuted.value
//                             ? ToggleThemeData.customBlue
//                             : Colors.white,
//                       ),
//                       onPressed: controller.toggleMute,
//                     ),
//                   ),
//                    SizedBox(width: 25.w
//                    ),
//                   // Show Video Icon only for audio call
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: ToggleThemeData.customBlue,
//                     ),
//                     child: IconButton(
//                       icon:  Icon(
//                         Icons.videocam,
//                         size: 35.sp,
//                         color: Colors.white,
//                       ),
//                       onPressed: () {
//                         // Add video upgrade logic if needed
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//                SizedBox(height: 25.h
//               ),
//               // End Call
//              Container(
//                 width: 70.w
//                ,
//                 height: 70.h,
//                 decoration:  BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.red,
//                 ),
//                 child: IconButton(
//                   icon:  Icon(
//                     Icons.call_end,
//                     size: 35.sp,
//                     color: Colors.white,
//                   ),
//                   onPressed: controller.isEndingCall.value
//                       ? null
//                       : () async {
//                     controller.isEndingCall.value = true;
//                     await controller.endCall(context);
//                     controller.isEndingCall.value = false;
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         controller.endCall(context);
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: widget.call.isVideo
//             ? Stack(
//           children: [
//             Positioned.fill(child: _renderRemoteVideo()),
//             Positioned(
//               top: 40.h,
//               right: 20.w,
//               width: 120.w,
//               height: 160.h,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12.r),
//                 child: Container(
//                   color: Colors.black54,
//                   child: _renderLocalPreview(),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 20.h,
//               child: Obx(() => _buildCallControls(),)
//             ),
//           ],
//         )
//             : Center(
//           child: Obx(() {
//             if (controller.remoteUid.value != "") {
//               // Start 1-minute disconnect timer
//               // Start disconnect timer only if local user is also joined
//               if (controller.localJoined.value &&
//                   !controller.isTimerStarted.value) {}
//             }
//             return Padding(
//               padding:  EdgeInsets.symmetric(
//                   horizontal: 20.w, vertical: 40.h),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   reausabletext(
//                   'Voice Call',
//                   color: Colors.grey.shade200,
//                   fontsize: 20,),
//                   // SizedBox(height: 10.h,),
//                   reausabletext(
//                   '',
//                   color: Colors.grey.shade200,
//                   fontsize: 20,),
//                   SizedBox(height: 20.h,),
//                   Container(
//                     width: 130.w, // outer circle size (adjust as needed)
//                     height: 130.h,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       // color: Colors.red,
//                       border: Border.all(width: 2, color: Colors.green),
//                     ),
//                     child: Padding(
//                       padding:  EdgeInsets.all(6.0), // space between outer circle and avatar
//                       child: CircleAvatar(
//                         radius: 28.r,
//                         backgroundImage: NetworkImage(
//                           "${widget.call.callerProfileImage}",
//                         ),
//                         backgroundColor: Colors.grey.shade200,
//                       ),
//                     ),
//                   ),
//
//                    SizedBox(height: 30.h),
//                   Text(
//                     controller.remoteUid.value != ""
//                         ? "Connected"
//                         : "Calling...",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   reausabletext(
//                         "${widget.call.callerName}",
//                       color: Colors.white,
//                       fontsize: 24,
//                       fontweight: FontWeight.w500,
//                   ),SizedBox(height: 10.h),
//                   reausabletext(
//                         "+918779426960",
//                       color: Colors.white,
//                       fontsize: 16,
//                       fontweight: FontWeight.w500,
//                   ),
//
//                   // const SizedBox(height: 10),
//                   // controller.remoteUid.value != ""? Text(
//                   //   "You have only ${controller.countdownSeconds.value} seconds left",
//                   //   style: TextStyle(color: Colors.redAccent, fontSize: 16),
//                   // ):SizedBox(),
//
//                    SizedBox(height: 10.h),
//                   // Text(
//                   //   widget.call.callerName,
//                   //   style: const TextStyle(
//                   //     color: Colors.white,
//                   //     fontSize: 22,
//                   //     fontWeight: FontWeight.w500,
//                   //   ),
//                   // ),
//                    Spacer(),
//                   _buildCallControls(),
//                    SizedBox(height: 20.h
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }