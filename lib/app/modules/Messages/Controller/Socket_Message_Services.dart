import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketMessageService extends GetxService {
  static SocketMessageService get instance => Get.put(SocketMessageService());

  IO.Socket? _socket;

  bool get isSocketConnected => _socket?.connected == true;

  IO.Socket get socket {
    if (_socket == null) {
      log("⚠️ Socket accessed before initialization");
      throw Exception("Socket not initialized");
    }
    return _socket!;
  }

  Future<void> init(String socketUrl,
      {required String userId, required int groupId}) async {
    _socket = IO.io("$socketUrl/chat", {
      "transports": ["websocket"],
      "autoConnect": true,
    });

    _socket?.onConnect((_) {
      joinUserInGroup(userId, groupId);
      log("✅ Message Socket connected");
    });

    _socket?.onAny((event, data) {
      log("MessageAllEventCalled: $event => $data");
    });

    _socket?.onDisconnect((_) => log("❌ Socket disconnected"));
    _socket?.onError((err) => log("❌ Socket error: $err"));

    _socket?.on("call_ended", (data) {
      log("Call ended: $data");
      Get.back();
    });
  }

  void joinUserInGroup(String userId, int groupId) {
    _socket?.emit("join", {
      "userId": userId,
      "groupId": groupId,
    });
  }

  void leaveUserFromGroup(String userId, int groupId) {
    _socket?.emit("leave", {
      "userId": userId,
      "groupId": groupId,
    });
  }

  void sendMessage({
    required String receiverId,
    required int groupId,
    required String content,
    String messageType = "text",
  }) {
    final msg = {
      'senderId': Global.storageServices.get(PrefConst.userId),
      'receiverId': receiverId, //as unique id
      'groupId': groupId,
      'content': content,
      'messageType': messageType,
    };
    _socket?.emit("send_message", msg);
  }

  void RecievedMessage({
    required String senderId,
    required String recieverId,
    required int groupId,
    Function(dynamic)? callback,
  }) {
    socket.off('receive_message');

    socket.on('receive_message', (data) {
      final dataGroupId = int.tryParse(data['groupId'].toString());
      if (dataGroupId == groupId) {
        if ((data['senderId'] == senderId && data['receiverId'] == recieverId) ||
            (data['senderId'] == recieverId && data['receiverId'] == senderId)) {
          callback?.call(data);
        }
      }
    });
  }



  void allSocketEvent(Function(String) callback) {
    _socket?.onAny((event, data) {
      log("📦 Received $event: $data");
    });
  }

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }


  void disconnectSocket() {
    if (_socket != null) {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      log("🧹 Socket fully disconnected and cleared");
    }
  }

}


