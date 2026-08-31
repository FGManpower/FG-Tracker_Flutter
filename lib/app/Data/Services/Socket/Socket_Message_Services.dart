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
      throw Exception("Socket not initialized");
    }
    return _socket!;
  }

  Future<void> init(
    String socketUrl, {
    required String userId,
    int? groupId,
  }) async {
    if (_socket != null && _socket!.connected) {
      if (groupId != null) {
        joinUserInGroup(userId, groupId);
        markSeen(userId, groupId);
      }

      return;
    }

    _socket = IO.io(
      "$socketUrl/chat",
      {
        "transports": ["websocket"],
        "autoConnect": true,
      },
    );

    _socket?.onConnect((_) {
      if (groupId != null) {
        joinUserInGroup(userId, groupId);
        markSeen(userId, groupId);
      }
    });

    _socket?.onDisconnect((_) {
      log("CHAT SOCKET DISCONNECTED");
    });

    _socket?.onError((error) {
      log("CHAT SOCKET ERROR =====> $error");
    });
  }

  void joinUserInGroup(
    String userId,
    int groupId,
  ) {
    if (!isSocketConnected) return;

    _socket!.emit(
      "join",
      {
        "userId": userId,
        "groupId": groupId,
      },
    );
  }

  void leaveUserFromGroup(
    String userId,
    int groupId,
  ) {
    if (!isSocketConnected) return;

    _socket!.emit(
      "leave",
      {
        "userId": userId,
        "groupId": groupId,
      },
    );
  }

  void sendMessage({
    required String receiverId,
    required int groupId,
    required String content,
    String messageType = "text",
    String? caption,
    dynamic replyId,
    String? replyMessage,
    String? replyType,
    String? replySender,
  }) {
    final msg = {
      'senderId': Global.storageServices.get(PrefConst.userId),
      'receiverId': receiverId,
      'groupId': groupId,
      'content': content,
      'messageType': messageType,
      'caption': caption,
      'replyId': replyId,
      'replyMessage': replyMessage,
      'replyType': replyType,
      'replySender': replySender,
    };



    _socket?.emit(
      "send_message",
      msg,
    );
  }

  void markSeen(
    String userId,
    int groupId,
  ) {
    _socket?.emit(
      "mark_seen",
      {
        "userId": userId,
        "groupId": groupId,
      },
    );
  }

  void RecievedMessage({
    required String senderId,
    required String recieverId,
    required int groupId,
    Function(dynamic)? callback,
  }) {
    _socket?.off('receive_message');

    _socket?.on(
      'receive_message',
      (data) {


        final dataGroupId = int.tryParse(data['groupId'].toString());

        if (dataGroupId == groupId) {
          if ((data['senderId'] == senderId &&
                  data['receiverId'] == recieverId) ||
              (data['senderId'] == recieverId &&
                  data['receiverId'] == senderId)) {
            callback?.call(data);
          }
        }
      },
    );
  }

  void listenSeenUpdate({
    required int groupId,
    required Function(dynamic) callback,
  }) {
    _socket?.off("messages_seen_update");

    _socket?.on(
      "messages_seen_update",
      (data) {
        final dataGroupId = int.tryParse(data["groupId"].toString());

        if (dataGroupId == groupId) {
          callback(data);
        }
      },
    );
  }

  void joinGroupChat({
    required int groupId,
    required String userId,
  }) {
    if (!isSocketConnected) return;

    socket.emit(
      "join_group_chat",
      {
        "groupId": groupId,
        "userId": userId,
      },
    );
  }

  void sendGroupMessage({
    required int groupId,
    required String content,
    required String messageType,
    String? caption,
    dynamic replyId,
    String? replyMessage,
    String? replyType,
    String? replySender,
  }) {
    socket.emit(
      "send_group_message",
      {
        "senderId": Global.storageServices.get(PrefConst.userId).toString(),
        "groupId": groupId,
        "content": content,
        "messageType": messageType,
        "caption": caption,
        "replyId": replyId,
        "replyMessage": replyMessage,
        "replyType": replyType,
        "replySender": replySender,
      },
    );
  }

  void receiveGroupMessage({
    required Function(dynamic) callback,
  }) {
    socket.off("receive_group_message");

    socket.on(
      "receive_group_message",
      (data) {
        print("=================================");
        print("RECEIVE GROUP MESSAGE");
        print("Message Type : ${data['messageType']}");
        print("Content      : ${data['content']}");
        print("Full Data    : $data");
        print("=================================");

        callback(data);
      },
    );
  }

  void editMessage({
    required int messageId,
    required String content,
    required String userId,
  }) {
    final payload = {
      "messageId": messageId,
      "content": content,
      "userId": userId,
    };

    socket.emit(
      "editMessage",
      payload,
    );
  }

  void listenMessageEdited({
    required Function(dynamic data) callback,
  }) {
    socket.off("messageEdited");

    socket.on(
      "messageEdited",
      (data) {
        callback(data);
      },
    );
  }

  void deleteMessage({
    required int messageId,
    required String userId,
    required String deleteType,
  }) {
    final payload = {
      "messageId": messageId,
      "userId": userId,
      "deleteType": deleteType,
    };
    socket.emit(
      "delete_message",
      payload,
    );
  }

  void listenMessageDeleted({
    required Function(dynamic data) callback,
  }) {
    socket.off("message_deleted");

    socket.on(
      "message_deleted",
      (data) {
        callback(data);
      },
    );
  }

  void pinMessage({
    required String chatType,
    int? groupId,
    String? senderId,
    String? receiverId,
    required int messageId,
    required String pinnedByName,
  }) {
    final payload = {
      "chatType": chatType,
      if (chatType == "group") "groupId": groupId,
      if (chatType == "private") "senderId": senderId,
      if (chatType == "private") "receiverId": receiverId,
      "messageId": messageId,
      "pinnedByName": pinnedByName,
    };

    socket.emit(
      "pin_message",
      payload,
    );
  }

  void unpinMessageEvent({
    required String chatType,
    int? groupId,
    String? senderId,
    String? receiverId,
  }) {
    final payload = {
      "chatType": chatType,
      if (chatType == "group") "groupId": groupId,
      if (chatType == "private") "senderId": senderId,
      if (chatType == "private") "receiverId": receiverId,
    };


    socket.emit(
      "unpin_message",
      payload,
    );
  }

  void listenPinMessage({
    required Function(Map<String, dynamic>) callback,
  }) {
    socket.off("message_pinned");

    socket.on(
      "message_pinned",
      (data) {

        callback(
          Map<String, dynamic>.from(data),
        );
      },
    );
  }

  void listenUnpinMessage({
    required Function(Map<String, dynamic>) callback,
  }) {
    socket.off("message_unpinned");

    socket.on(
      "message_unpinned",
      (data) {

        callback(
          Map<String, dynamic>.from(data),
        );
      },
    );
  }

  void forwardMessage({
    required int messageId,
    String? receiverId,
    int? groupId,
  }) {
    final payload = {
      "messageId": messageId,
      "receiverId": receiverId,
      "groupId": groupId,
    };

    print("FORWARD MESSAGE PAYLOAD =====> $payload");

    socket.emit(
      "forward_message",
      payload,
    );
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void onClose() {
    disconnectSocket();
    super.onClose();
  }
}
