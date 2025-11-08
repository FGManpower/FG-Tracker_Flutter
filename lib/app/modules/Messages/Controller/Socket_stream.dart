// // import 'dart:developer';
// // import 'package:fgtracker/app/Core/util/http/Constant.dart';
// // import 'package:fgtracker/app/Core/values/Utils.dart';
// // import 'package:fgtracker/app/Core/values/global.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:get/get.dart';
// //
// // import '../../../Data/Services/CallStateTracker.dart';
// //
// // class SocketStreamService extends GetxService {
// //   static SocketStreamService get instance => Get.put(SocketStreamService());
// //
// //   IO.Socket? _socket;
// //   bool get isSocketConnected => _socket?.connected == true;
// //
// //   IO.Socket get socket {
// //     if (_socket == null) {
// //       log("⚠️ Socket accessed before initialization");
// //       throw Exception("Socket not initialized");
// //     }
// //     return _socket!;
// //   }
// //
// //   Future<void> init(String socketUrl) async {
// //     _socket = IO.io("$socketUrl/streamCall", {
// //       "transports": ["websocket"],
// //       "autoConnect": true,
// //     });
// //
// //     _socket?.onConnect((_) {
// //       log("✅Stream Socket connected");
// //       _joinUser(Global.storageServices.get(PrefConst.userId).toString());
// //     });
// //
// //     _socket?.onAny((event, data) {
// //       log("StreamAllEventCalled------------- $event: $data");
// //     });
// //
// //     _socket?.onDisconnect((_) => log("❌ Stream Socket disconnected"));
// //     _socket?.onError((err) => log("❌ Socket error: $err"));
// //
// //     _socket?.on("call_ended", (data) {
// //       print("Call ended: $data");
// //       Utils().fluttertoast("CallEndedfromUserSide");
// //       Get.back();
// //     });
// //
// //   }
// //
// //   void _joinUser(String userId) {
// //     _socket?.emit("join", {
// //       "userId": userId,
// //     });
// //   }
// //
// //   void startCall({
// //     required String receiverId,
// //     required String callerName,
// //     required String profileImage,
// //     required bool isVideo,
// //     required String channelId,
// //   }) {
// //     _socket?.emit("start_call", {
// //       "caller_id": Global.storageServices.get(PrefConst.userId),
// //       "receiver_id": receiverId,
// //       "caller_name": callerName,
// //       "caller_profile_image": profileImage,
// //       "is_video": isVideo,
// //       "channel_id": channelId,
// //     });
// //   }
// //
// //   void endCall(String channelId, String receiverId, String callerName) {
// //     _socket?.emit("end_call", {
// //       "channel_id": channelId,
// //       "receiver_id": receiverId,
// //       "caller_name": callerName,
// //     });
// //   }
// //
// //   void acceptCall(String channelId, String receiverId) {
// //     _socket?.emit("accept_call", {
// //       "channel_id": channelId,
// //       "receiver_id": receiverId,
// //     });
// //   }
// //
// //   void rejectCall(
// //     String channelId,
// //     String receiverId,
// //     String senderId,
// //   ) {
// //     _socket?.emit("reject_call", {
// //       "channel_id": channelId,
// //       "receiver_id": receiverId,
// //       "senderId": senderId,
// //     });
// //   }
// //
// //   void callEnded(String channelId, void Function(bool) callBack) {
// //     _socket?.on("call_ended", (data) {
// //       if (data["channel_id"] == channelId) {
// //         callBack(true);
// //       }
// //     });
// //   }
// //
// //   void callRejected(String receiver_id, void Function(bool) callBack) {
// //     _socket?.on("call_rejected", (data) {
// //       if (data["receiver_id"] == receiver_id) {
// //         callBack(true);
// //       }
// //     });
// //   }
// //
// //   Future<void> endCallUserCall(
// //       {String? channelId,
// //       receiverId,
// //       required void Function(bool) callback}) async {
// //     try {
// //
// //       _socket?.emit("end_call", {
// //         "channelId": channelId,
// //         "receiverId": receiverId,
// //         "callerId": Global.storageServices
// //             .get(PrefConst.userId), // replace with actual callerId
// //       });
// //
// //       callback(true);
// //
// //       log("[DEBUG] Call Ended via Socket.IO and Disposed");
// //     } catch (e) {
// //       log("[DEBUG] endCall Exception: $e");
// //     }
// //   }
// //
// //   void allSocketEvent(Function(String) callback) {
// //     _socket?.onAny((event, data) {
// //       log("📦 Received $event: $data");
// //     });
// //   }
// //
// //   @override
// //   void onClose() {
// //     _socket?.dispose();
// //     super.onClose();
// //   }
// // }
//
//
// // ✅ SocketStreamService.dart
// import 'dart:developer';
// import 'package:fgtracker/app/Core/util/http/Constant.dart';
// import 'package:fgtracker/app/Core/values/Utils.dart';
// import 'package:fgtracker/app/Core/values/global.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:get/get.dart';
//
// import '../../../Data/Services/CallStateTracker.dart';
// import '../../../Model/call_model.dart';
// import '../Views/incoming_call_screen.dart';
//
//
// class SocketStreamService extends GetxService {
//   static SocketStreamService get instance => Get.put(SocketStreamService());
//
//   IO.Socket? _socket;
//   bool get isSocketConnected => _socket?.connected == true;
//
//   IO.Socket get socket {
//     if (_socket == null) {
//       log("⚠️ Socket accessed before initialization");
//       throw Exception("Socket not initialized");
//     }
//     return _socket!;
//   }
//
//   Future<void> init(String socketUrl) async {
//     _socket = IO.io("$socketUrl/streamCall", {
//       "transports": ["websocket"],
//       "autoConnect": true,
//     });
//
//     _socket?.onConnect((_) {
//       log("✅ Stream Socket connected");
//       _joinUser(Global.storageServices.get(PrefConst.userId).toString());
//     });
//
//
//     _socket?.on("call_disconnected", (data) {
//       log("📴 Call disconnected: $data");
//       Utils().fluttertoast("User disconnected");
//       if (CallStateTracker.isIncomingCallScreenOpen) {
//         CallStateTracker.isIncomingCallScreenOpen = false;
//         if (Get.isOverlaysOpen) Get.back(); // close incoming call screen
//       } else {
//         if (Get.currentRoute.contains("AgoraCallScreen")) {
//           if (Get.isOverlaysOpen) Get.back(); // close call screen if open
//         }
//       }
//     });
//
//
//     _socket?.onDisconnect((_) => log("❌ Stream Socket disconnected"));
//     _socket?.onError((err) => log("❌ Socket error: $err"));
//
//     _socket?.on("call_ended", (data) {
//       log("📴 Call ended: $data");
//       Utils().fluttertoast("Call ended");
//       CallStateTracker.isIncomingCallScreenOpen = false;
//       Get.back();
//     });
//
//     _socket?.on("call_rejected", (data) {
//       log("🚫 Call rejected: $data");
//       CallStateTracker.isIncomingCallScreenOpen = false;
//       Get.back();
//     });
//
//     _socket?.on("incoming_call", (data) {
//       log("📲 Incoming call: $data");
//       final call = CallModel(
//
//         callerId: data["caller_id"],
//         receiverId: data["receiver_id"],
//         channelId: data["channel_id"],
//         callerName: data["caller_name"],
//         callerProfileImage: data["caller_profile_image"],
//         isVideo: data["is_video"] == true || data["is_video"] == "true",
//       );
//
//       if (!CallStateTracker.isIncomingCallScreenOpen) {
//         CallStateTracker.isIncomingCallScreenOpen = true;
//         Get.to(() => IncomingCallScreen(call: call));
//       }
//     });
//   }
//
//   void _joinUser(String userId) {
//     _socket?.emit("join", {"userId": userId});
//   }
//
//
//
//
//   void startCall({
//     required String receiverId,
//     required String callerName,
//     required String profileImage,
//     required bool isVideo,
//     required String channelId,
//   }) {
//     _socket?.emit("start_call", {
//       "caller_id": Global.storageServices.get(PrefConst.userId),
//       "receiver_id": receiverId,
//       "caller_name": callerName,
//       "caller_profile_image": profileImage,
//       "is_video": isVideo,
//       "channel_id": channelId,
//     });
//   }
//
//   void endCall(String channelId, String receiverId, String callerName) {
//     _socket?.emit("end_call", {
//       "channel_id": channelId,
//       "receiver_id": receiverId,
//       "caller_id": Global.storageServices.get(PrefConst.userId),
//       "caller_name": callerName,
//     });
//   }
//
//   void acceptCall(String channelId, String receiverId) {
//     _socket?.emit("accept_call", {
//       "channel_id": channelId,
//       "receiver_id": receiverId,
//     });
//   }
//
//   void rejectCall(String channelId, String receiverId, String senderId) {
//     _socket?.emit("reject_call", {
//       "channel_id": channelId,
//       "receiver_id": receiverId,
//       "senderId": senderId,
//     });
//   }
//
//   @override
//   void onClose() {
//     // _socket?.disconnect();
//     _socket?.dispose();
//     super.onClose();
//   }
// }
