import 'dart:developer';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketMessageService extends GetxService {
  static SocketMessageService get instance =>
      Get.put(SocketMessageService());

  IO.Socket? _socket;

  bool get isSocketConnected => _socket?.connected == true;

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception("Chat socket not initialized");
    }

    return _socket!;
  }

  IO.Socket? _privateChatSocket;

  bool get isPrivateChatSocketConnected =>
      _privateChatSocket?.connected == true;

  IO.Socket get privateChatSocket {
    if (_privateChatSocket == null) {
      throw Exception("Private chat socket not initialized");
    }

    return _privateChatSocket!;
  }

  IO.Socket? _privateChatListSocket;

  bool get isPrivateChatListSocketConnected =>
      _privateChatListSocket?.connected == true;

  String? _privateChatId;

  String? get privateChatId => _privateChatId;

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
      log("CHAT SOCKET CONNECTED");

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
      'senderId':
      Global.storageServices.get(PrefConst.userId).toString(),
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
        final dataGroupId =
        int.tryParse(data['groupId'].toString());

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
        final dataGroupId =
        int.tryParse(data["groupId"].toString());

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
        "senderId":
        Global.storageServices.get(PrefConst.userId).toString(),
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
        log("=================================");
        log("RECEIVE GROUP MESSAGE");
        log("Message Type : ${data['messageType']}");
        log("Content      : ${data['content']}");
        log("Full Data    : $data");
        log("=================================");

        callback(data);
      },
    );
  }

  Future<void> initPrivateChat(
      String socketUrl, {
        required String userId,
        required String receiverId,
        Function(dynamic)? onJoined,
      }) async {
    if (_privateChatSocket != null &&
        _privateChatSocket!.connected) {
      log("PRIVATE CHAT SOCKET ALREADY CONNECTED");

      _privateChatSocket?.off("joined");
      if (onJoined != null) {
        _privateChatSocket?.on(
          "joined",
          (data) {
            log("=================================");
            log("PRIVATE CHAT JOINED");
            log("JOINED DATA => $data");
            log("=================================");

            if (data is Map) {
              _privateChatId = data["chatId"]?.toString();
            }

            onJoined.call(data);
          },
        );
      }

      joinPrivateChat(
        userId: userId,
        receiverId: receiverId,
      );

      return;
    }

    if (_privateChatSocket != null) {
      _privateChatSocket?.disconnect();
      _privateChatSocket?.dispose();
      _privateChatSocket = null;
    }

    _privateChatId = null;

    _privateChatSocket = IO.io(
      "$socketUrl/privateChat",
      {
        "transports": ["websocket"],
        "autoConnect": true,
        "auth": {
          "userId": userId,
        },
      },
    );

    _privateChatSocket?.onConnect((_) {
      log("=================================");
      log("PRIVATE CHAT SOCKET CONNECTED");
      log("Namespace: /privateChat");
      log("=================================");

      joinPrivateChat(
        userId: userId,
        receiverId: receiverId,
      );
    });

    _privateChatSocket?.on(
      "joined",
          (data) {
        log("=================================");
        log("PRIVATE CHAT JOINED");
        log("JOINED DATA => $data");
        log("=================================");

        if (data is Map) {
          _privateChatId = data["chatId"]?.toString();
        }

        onJoined?.call(data);
      },
    );

    _privateChatSocket?.onDisconnect((reason) {
      log("PRIVATE CHAT SOCKET DISCONNECTED");
      log("Reason => $reason");
    });

    _privateChatSocket?.onError((error) {
      log("PRIVATE CHAT SOCKET ERROR =====> $error");
    });
  }

  void joinPrivateChat({
    required String userId,
    required String receiverId,
  }) {
    if (!isPrivateChatSocketConnected) {
      log("PRIVATE CHAT SOCKET NOT CONNECTED");
      return;
    }

    final payload = {
      "userId": userId,
      "receiverId": receiverId,
    };

    log("PRIVATE CHAT JOIN PAYLOAD => $payload");

    _privateChatSocket!.emit(
      "join",
      payload,
    );
  }

  void sendPrivateMessage({
    required String receiverId,
    required String content,
    String messageType = "text",
    String? caption,
    dynamic replyId,
    String? replyMessage,
    String? replyType,
    String? replySender,
  }) {
    if (!isPrivateChatSocketConnected) {
      log("PRIVATE CHAT SOCKET NOT CONNECTED");
      return;
    }

    final senderId =
    Global.storageServices.get(PrefConst.userId).toString();

    final payload = {
      "senderId": senderId,
      "receiverId": receiverId,
      "messageType": messageType,
      "content": content,
      if (caption != null) "caption": caption,
      if (replyId != null) "replyId": replyId,
      if (replyMessage != null) "replyMessage": replyMessage,
      if (replyType != null) "replyType": replyType,
      if (replySender != null) "replySender": replySender,
    };

    log("PRIVATE SEND MESSAGE => $payload");

    _privateChatSocket!.emit(
      "send_message",
      payload,
    );
  }

  void receivePrivateMessage({
    required String senderId,
    required String receiverId,
    Function(dynamic)? callback,
  }) {
    _privateChatSocket?.off("receive_message");

    _privateChatSocket?.on(
      "receive_message",
          (data) {
        log("=================================");
        log("PRIVATE RECEIVE MESSAGE");
        log("DATA => $data");
        log("=================================");

        if (data is! Map) return;

        final dataSenderId =
        data["senderId"]?.toString();

        final dataReceiverId =
        data["receiverId"]?.toString();

        final isSameChat =
            (dataSenderId == senderId &&
                dataReceiverId == receiverId) ||
                (dataSenderId == receiverId &&
                    dataReceiverId == senderId);

        if (!isSameChat) {
          return;
        }

        callback?.call(data);
      },
    );
  }

  void markPrivateDelivered({
    required List<dynamic> messageIds,
    required String userId,
    required String otherUserId,
  }) {
    if (!isPrivateChatSocketConnected) return;

    final payload = {
      "messageIds": messageIds,
      "userId": userId,
      "otherUserId": otherUserId,
    };

    log("PRIVATE MARK DELIVERED => $payload");

    _privateChatSocket!.emit(
      "mark_delivered",
      payload,
    );
  }

  void listenPrivateMessagesDelivered({
    required Function(dynamic) callback,
  }) {
    _privateChatSocket?.off("messages_delivered");

    _privateChatSocket?.on(
      "messages_delivered",
          (data) {
        log("PRIVATE MESSAGES DELIVERED => $data");

        callback(data);
      },
    );
  }

  void markPrivateSeen({
    required String chatId,
    required String userId,
    required String otherUserId,
  }) {
    if (!isPrivateChatSocketConnected) return;

    final payload = {
      "chatId": chatId,
      "userId": userId,
      "otherUserId": otherUserId,
    };

    log("PRIVATE MARK SEEN => $payload");

    _privateChatSocket!.emit(
      "mark_seen",
      payload,
    );
  }

  void listenPrivateMessagesSeenUpdate({
    required Function(dynamic) callback,
  }) {
    _privateChatSocket?.off("messages_seen_update");

    _privateChatSocket?.on(
      "messages_seen_update",
          (data) {
        log("PRIVATE MESSAGES SEEN UPDATE => $data");

        callback(data);
      },
    );
  }

  void initPrivateChatListSocket(
      String socketUrl, {
        required String userId,
      }) {
    if (_privateChatListSocket != null &&
        _privateChatListSocket!.connected) {
      log("PRIVATE CHAT LIST SOCKET ALREADY CONNECTED");
      return;
    }

    _privateChatListSocket?.disconnect();
    _privateChatListSocket?.dispose();

    _privateChatListSocket = IO.io(
      "$socketUrl/privateChat",
      {
        "transports": ["websocket"],
        "autoConnect": true,
        "auth": {
          "userId": userId,
        },
      },
    );

    _privateChatListSocket?.onConnect((_) {
      log("=================================");
      log("PRIVATE CHAT LIST SOCKET CONNECTED");
      log("User ID => $userId");
      log("=================================");

      _privateChatListSocket?.off("private_chat_updated");

      if (_privateChatListUpdatedCallback != null) {
        _privateChatListSocket?.on(
          "private_chat_updated",
              (data) {
            log("=================================");
            log("PRIVATE CHAT LIST UPDATED");
            log("DATA => $data");
            log("=================================");

            _privateChatListUpdatedCallback?.call(data);
          },
        );
      }
    });

    _privateChatListSocket?.onDisconnect((reason) {
      log("PRIVATE CHAT LIST SOCKET DISCONNECTED");
      log("Reason => $reason");
    });

    _privateChatListSocket?.onError((error) {
      log("PRIVATE CHAT LIST SOCKET ERROR =====> $error");
    });
  }

  Function(dynamic)? _privateChatListUpdatedCallback;

  void listenPrivateChatListUpdated({
    required Function(dynamic) callback,
  }) {
    _privateChatListUpdatedCallback = callback;

    if (_privateChatListSocket == null) {
      return;
    }

    _privateChatListSocket?.off("private_chat_updated");

    _privateChatListSocket?.on(
      "private_chat_updated",
          (data) {
        log("=================================");
        log("PRIVATE CHAT LIST UPDATED");
        log("DATA => $data");
        log("=================================");

        _privateChatListUpdatedCallback?.call(data);
      },
    );
  }

  void listenPrivateChatUpdated({
    required Function(dynamic) callback,
  }) {
    _privateChatSocket?.off("private_chat_updated");

    _privateChatSocket?.on(
      "private_chat_updated",
          (data) {
        log("=================================");
        log("PRIVATE CHAT UPDATED");
        log("DATA => $data");
        log("=================================");

        callback(data);
      },
    );
  }

  void leavePrivateChat({
    required String userId,
    required String receiverId,
  }) {
    if (!isPrivateChatSocketConnected) return;

    final payload = {
      "userId": userId,
      "receiverId": receiverId,
    };

    log("PRIVATE CHAT LEAVE => $payload");

    _privateChatSocket!.emit(
      "leave",
      payload,
    );
  }

  void disconnectPrivateChatSocket() {
    log("DISCONNECTING PRIVATE CHAT SOCKET");

    _privateChatSocket?.off("joined");
    _privateChatSocket?.off("receive_message");
    _privateChatSocket?.off("messages_delivered");
    _privateChatSocket?.off("messages_seen_update");
    _privateChatSocket?.off("private_chat_updated");

    _privateChatSocket?.disconnect();
    _privateChatSocket?.dispose();

    _privateChatSocket = null;
    _privateChatId = null;
  }

  void disconnectPrivateChatListSocket() {
    log("DISCONNECTING PRIVATE CHAT LIST SOCKET");

    _privateChatListSocket?.off("private_chat_updated");

    _privateChatListSocket?.disconnect();
    _privateChatListSocket?.dispose();

    _privateChatListSocket = null;
    _privateChatListUpdatedCallback = null;
  }

  void editMessage({
    required int messageId,
    required String content,
    required String userId,
    String? otherUserId,
  }) {
    final payload = {
      "messageId": messageId,
      "content": content,
      "userId": userId,
      if (otherUserId != null) "otherUserId": otherUserId,
    };

    log("EDIT MESSAGE => payload=$payload");

    if (otherUserId != null && isPrivateChatSocketConnected) {
      _privateChatSocket!.emit(
        "editMessage",
        payload,
      );

      log("PRIVATE EDIT EMITTED => $payload");
      return;
    }

    socket.emit(
      "editMessage",
      payload,
    );

    log("GROUP EDIT EMITTED => $payload");
  }

  void listenMessageEdited({
    required Function(dynamic data) callback,
  }) {
    _socket?.off("messageEdited");
    _privateChatSocket?.off("messageEdited");

    _socket?.on(
      "messageEdited",
          (data) {
        log("GROUP MESSAGE EDITED RECEIVED => $data");
        callback(data);
      },
    );

    _privateChatSocket?.on(
      "messageEdited",
          (data) {
        log("PRIVATE MESSAGE EDITED RECEIVED => $data");
        callback(data);
      },
    );
  }

  void deleteMessage({
    required int messageId,
    required String userId,
    required String deleteType,
    String? otherUserId,
  }) {
    final payload = {
      "messageId": messageId,
      "userId": userId,
      "deleteType": deleteType,
      if (otherUserId != null) "otherUserId": otherUserId,
    };

    log("DELETE MESSAGE => payload=$payload");

    if (otherUserId != null && isPrivateChatSocketConnected) {
      _privateChatSocket!.emit(
        "delete_message",
        payload,
      );

      log("PRIVATE DELETE EMITTED => $payload");
      return;
    }

    socket.emit(
      "delete_message",
      payload,
    );

    log("GROUP DELETE EMITTED => $payload");
  }

  void listenMessageDeleted({
    required Function(dynamic data) callback,
  }) {
    _socket?.off("message_deleted");
    _privateChatSocket?.off("message_deleted");

    _socket?.on(
      "message_deleted",
          (data) {
        log("GROUP MESSAGE DELETED RECEIVED => $data");
        callback(data);
      },
    );

    _privateChatSocket?.on(
      "message_deleted",
          (data) {
        log("PRIVATE MESSAGE DELETED RECEIVED => $data");
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
    if (chatType == "private") {
      final payload = {
        "userId": senderId,
        "otherUserId": receiverId,
        "messageId": messageId,
        "pinnedByName": pinnedByName,
      };

      log("PRIVATE PIN EMIT => $payload");

      if (!isPrivateChatSocketConnected) {
        log("PRIVATE PIN ERROR => SOCKET NOT CONNECTED");
        return;
      }

      _privateChatSocket!.emit(
        "pin_message",
        payload,
      );

      return;
    }

    final payload = {
      "groupId": groupId,
      "messageId": messageId,
      "pinnedByName": pinnedByName,
    };

    log("GROUP PIN EMIT => $payload");

    if (!isSocketConnected) {
      log("GROUP PIN ERROR => SOCKET NOT CONNECTED");
      return;
    }

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
    if (chatType == "private") {
      final payload = {
        "userId": senderId,
        "otherUserId": receiverId,
      };

      log("PRIVATE UNPIN EMIT => $payload");

      if (!isPrivateChatSocketConnected) {
        log("PRIVATE UNPIN ERROR => SOCKET NOT CONNECTED");
        return;
      }

      _privateChatSocket!.emit(
        "unpin_message",
        payload,
      );

      return;
    }

    final payload = {
      "groupId": groupId,
    };

    log("GROUP UNPIN EMIT => $payload");

    if (!isSocketConnected) {
      log("GROUP UNPIN ERROR => SOCKET NOT CONNECTED");
      return;
    }

    socket.emit(
      "unpin_message",
      payload,
    );
  }

  void listenPinMessage({
    required Function(Map<String, dynamic>) callback,
  }) {
    _socket?.off("message_pinned");
    _privateChatSocket?.off("message_pinned");

    _socket?.on(
      "message_pinned",
          (data) {
        callback(
          Map<String, dynamic>.from(data),
        );
      },
    );

    _privateChatSocket?.on(
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
    _socket?.off("message_unpinned");
    _privateChatSocket?.off("message_unpinned");

    _socket?.on(
      "message_unpinned",
          (data) {
        callback(
          Map<String, dynamic>.from(data),
        );
      },
    );

    _privateChatSocket?.on(
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

    log("FORWARD MESSAGE PAYLOAD =====> $payload");

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
    disconnectPrivateChatSocket();
    disconnectPrivateChatListSocket();

    super.onClose();
  }
}