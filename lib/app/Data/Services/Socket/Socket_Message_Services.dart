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
      if (groupId != null) {
        joinUserInGroup(userId, groupId);
        markSeen(userId, groupId);
      }
    });

    _socket?.onDisconnect((_) {});

    _socket?.onError((error) {});
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
      'senderId': Global.storageServices.get(PrefConst.userId).toString(),
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
    List<String>? images,
    List<Map<String, dynamic>>? videos,
    String? caption,
    dynamic replyId,
    String? replyMessage,
    String? replyType,
    String? replySender,
  }) {
    final payload = <String, dynamic>{
      "senderId": Global.storageServices.get(PrefConst.userId).toString(),
      "groupId": groupId,
      "messageType": messageType,
      "content": content,
      if (images != null && images.isNotEmpty) "images": images,
      if (videos != null && videos.isNotEmpty) "videos": videos,
      if (caption != null) "caption": caption,
      if (replyId != null) "replyId": replyId,
      if (replyMessage != null) "replyMessage": replyMessage,
      if (replyType != null) "replyType": replyType,
      if (replySender != null) "replySender": replySender,
    };

    socket.emit("send_group_message", payload);
  }

  void receiveGroupMessage({
    required Function(dynamic) callback,
  }) {
    socket.off("receive_group_message");

    socket.on(
      "receive_group_message",
          (data) {
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
    if (_privateChatSocket != null && _privateChatSocket!.connected) {
      _privateChatSocket?.off("joined");

      if (onJoined != null) {
        _privateChatSocket?.on(
          "joined",
              (data) {
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
      joinPrivateChat(
        userId: userId,
        receiverId: receiverId,
      );
    });

    _privateChatSocket?.on(
      "joined",
          (data) {
        if (data is Map) {
          _privateChatId = data["chatId"]?.toString();
        }

        onJoined?.call(data);
      },
    );

    _privateChatSocket?.onDisconnect((reason) {});

    _privateChatSocket?.onError((error) {});
  }

  void joinPrivateChat({
    required String userId,
    required String receiverId,
  }) {
    if (!isPrivateChatSocketConnected) {
      return;
    }

    final payload = {
      "userId": userId,
      "receiverId": receiverId,
    };

    _privateChatSocket!.emit(
      "join",
      payload,
    );
  }

  void sendPrivateMessage({
    required String receiverId,
    required String content,
    String messageType = "text",
    List<String>? images,
    List<Map<String, dynamic>>? videos,
    String? caption,
    dynamic replyId,
    String? replyMessage,
    String? replyType,
    String? replySender,
  }) {
    if (!isPrivateChatSocketConnected) {
      return;
    }

    final senderId =
    Global.storageServices.get(PrefConst.userId).toString();

    final payload = <String, dynamic>{
      "senderId": senderId,
      "receiverId": receiverId,
      "messageType": messageType,
      "content": content,
      if (images != null && images.isNotEmpty) "images": images,
      if (videos != null && videos.isNotEmpty) "videos": videos,
      if (caption != null) "caption": caption,
      if (replyId != null) "replyId": replyId,
      if (replyMessage != null) "replyMessage": replyMessage,
      if (replyType != null) "replyType": replyType,
      if (replySender != null) "replySender": replySender,
    };

    _privateChatSocket!.emit("send_message", payload);
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
        if (data is! Map) return;

        final dataSenderId = data["senderId"]?.toString();
        final dataReceiverId = data["receiverId"]?.toString();

        final isSameChat =
            (dataSenderId == senderId && dataReceiverId == receiverId) ||
                (dataSenderId == receiverId && dataReceiverId == senderId);

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

    _privateChatListSocket?.onAny((event, data) {});

    _privateChatListSocket?.on(
      "archived_private_chats",
          (data) {
        _archivedPrivateChatsCallback?.call(data);
      },
    );

    _privateChatListSocket?.onConnect((_) {
      _privateChatListSocket?.off("chat_list_updated");

      if (_privateChatListUpdatedCallback != null) {
        _privateChatListSocket?.on("chat_list_updated", (data) {
          _privateChatListUpdatedCallback?.call(data);
        });
      }

      _privateChatListSocket?.off("private_chat_removed");

      if (_privateChatRemovedCallback != null) {
        _privateChatListSocket?.on(
          "private_chat_removed",
              (data) {
            _privateChatRemovedCallback?.call(data);
          },
        );
      }

      _privateChatListSocket?.off("private_chat_action_error");

      if (_privateChatActionErrorCallback != null) {
        _privateChatListSocket?.on(
          "private_chat_action_error",
              (data) {
            _privateChatActionErrorCallback?.call(data);
          },
        );
      }

      getArchivedPrivateChats(
        page: 1,
        limit: 20,
      );
    });

    _privateChatListSocket?.onDisconnect((reason) {});

    _privateChatListSocket?.onError((error) {});
  }

  Function(dynamic)? _privateChatListUpdatedCallback;

  void listenPrivateChatListUpdated({
    required Function(dynamic) callback,
  }) {
    _privateChatListUpdatedCallback = callback;

    if (_privateChatListSocket == null ||
        !_privateChatListSocket!.connected) {
      return;
    }

    _privateChatListSocket?.off("chat_list_updated");

    _privateChatListSocket?.on("chat_list_updated", (data) {
      _privateChatListUpdatedCallback?.call(data);
    });
  }

  void listenPrivateChatUpdated({
    required Function(dynamic) callback,
  }) {
    _privateChatSocket?.off("private_chat_updated");

    _privateChatSocket?.on(
      "private_chat_updated",
          (data) {
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

    _privateChatSocket!.emit(
      "leave",
      payload,
    );
  }

  void disconnectPrivateChatSocket() {
    _privateChatSocket?.off("joined");
    _privateChatSocket?.off("receive_message");
    _privateChatSocket?.off("messages_delivered");
    _privateChatSocket?.off("messages_seen_update");
    _privateChatSocket?.off("private_chat_updated");
    _privateChatSocket?.off("private_chat_cleared");

    _privateChatSocket?.disconnect();
    _privateChatSocket?.dispose();

    _privateChatSocket = null;
    _privateChatId = null;
  }

  void disconnectPrivateChatListSocket() {
    _privateChatListSocket?.off("private_chat_updated");
    _privateChatListSocket?.off("chat_list_updated");
    _privateChatListSocket?.off("private_chat_removed");
    _privateChatListSocket?.off("private_chat_action_error");

    _privateChatListSocket?.disconnect();
    _privateChatListSocket?.dispose();

    _privateChatListSocket = null;

    _privateChatListUpdatedCallback = null;
    _privateChatRemovedCallback = null;
    _privateChatActionErrorCallback = null;
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

    if (otherUserId != null && isPrivateChatSocketConnected) {
      _privateChatSocket!.emit(
        "editMessage",
        payload,
      );

      return;
    }

    socket.emit(
      "editMessage",
      payload,
    );
  }

  void listenMessageEdited({
    required Function(dynamic data) callback,
  }) {
    _socket?.off("messageEdited");
    _privateChatSocket?.off("messageEdited");

    _socket?.on(
      "messageEdited",
          (data) {
        callback(data);
      },
    );

    _privateChatSocket?.on(
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
    String? otherUserId,
  }) {
    final payload = {
      "messageId": messageId,
      "userId": userId,
      "deleteType": deleteType,
      if (otherUserId != null) "otherUserId": otherUserId,
    };

    if (otherUserId != null && isPrivateChatSocketConnected) {
      _privateChatSocket!.emit(
        "delete_message",
        payload,
      );

      return;
    }

    socket.emit(
      "delete_message",
      payload,
    );
  }

  void listenMessageDeleted({
    required Function(dynamic data) callback,
  }) {
    _socket?.off("message_deleted");
    _privateChatSocket?.off("message_deleted");

    _socket?.on(
      "message_deleted",
          (data) {
        callback(data);
      },
    );

    _privateChatSocket?.on(
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
    if (chatType == "private") {
      final payload = {
        "userId": senderId,
        "otherUserId": receiverId,
        "messageId": messageId,
        "pinnedByName": pinnedByName,
      };

      if (!isPrivateChatSocketConnected) {
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

    if (!isSocketConnected) {
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

      if (!isPrivateChatSocketConnected) {
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

    if (!isSocketConnected) {
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

    if (receiverId != null && receiverId.isNotEmpty) {
      if (!isPrivateChatSocketConnected) {
        return;
      }

      _privateChatSocket!.emit(
        "forward_message",
        payload,
      );

      return;
    }

    if (groupId != null) {
      if (!isSocketConnected) {
        return;
      }

      socket.emit(
        "forward_message",
        payload,
      );
    }
  }

  void pinPrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "userId": userId,
      "chatId": chatId,
    };

    _privateChatListSocket!.emit(
      "pin_private_chat",
      payload,
    );
  }

  void unpinPrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "userId": userId,
      "chatId": chatId,
    };

    _privateChatListSocket!.emit(
      "unpin_private_chat",
      payload,
    );
  }

  void mutePrivateChat({
    required String userId,
    required String chatId,
    String? mutedUntil,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "userId": userId,
      "chatId": chatId,
      "mutedUntil": mutedUntil,
    };

    _privateChatListSocket!.emit(
      "mute_private_chat",
      payload,
    );
  }

  void unmutePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "userId": userId,
      "chatId": chatId,
    };

    _privateChatListSocket!.emit(
      "unmute_private_chat",
      payload,
    );
  }

  void archivePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "chatId": chatId,
      "userId": userId,
    };

    _privateChatListSocket!.emit(
      "archive_private_chat",
      payload,
    );
  }

  void unarchivePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "chatId": chatId,
      "userId": userId,
    };

    _privateChatListSocket!.emit(
      "unarchive_private_chat",
      payload,
    );
  }

  void markPrivateChatRead({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "chatId": int.tryParse(chatId) ?? chatId,
      "userId": int.tryParse(userId) ?? userId,
    };

    _privateChatListSocket!.emit(
      "mark_private_chat_read",
      payload,
    );
  }

  void deletePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "chatId": int.tryParse(chatId) ?? chatId,
      "userId": int.tryParse(userId) ?? userId,
    };

    _privateChatListSocket!.emit(
      "delete_private_chat",
      payload,
    );
  }

  Function(dynamic)? _privateChatRemovedCallback;

  void listenPrivateChatRemoved({
    required Function(dynamic) callback,
  }) {
    _privateChatRemovedCallback = callback;

    if (_privateChatListSocket == null) {
      return;
    }

    _privateChatListSocket!.off("private_chat_removed");

    _privateChatListSocket!.on(
      "private_chat_removed",
          (data) {
        _privateChatRemovedCallback?.call(data);
      },
    );
  }

  Function(dynamic)? _privateChatActionErrorCallback;

  void listenPrivateChatActionError({
    required Function(dynamic) callback,
  }) {
    _privateChatActionErrorCallback = callback;

    if (_privateChatListSocket == null) {
      return;
    }

    _privateChatListSocket?.off("private_chat_action_error");

    _privateChatListSocket?.on(
      "private_chat_action_error",
          (data) {
        _privateChatActionErrorCallback?.call(data);
      },
    );
  }

  Function(dynamic)? _archivedPrivateChatsCallback;

  void listenArchivedPrivateChats({
    required Function(dynamic) callback,
  }) {
    _archivedPrivateChatsCallback = callback;

    if (_privateChatListSocket == null) {
      return;
    }

    _privateChatListSocket!.off("archived_private_chats");

    _privateChatListSocket!.on(
      "archived_private_chats",
          (data) {
        _archivedPrivateChatsCallback?.call(data);
      },
    );
  }

  void getArchivedPrivateChats({
    required int page,
    required int limit,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return;
    }

    final payload = {
      "page": page,
      "limit": limit,
    };

    _privateChatListSocket!.emit(
      "get_archived_private_chats",
      payload,
    );
  }

  void clearPrivateChat({
    required String chatId,
  }) {
    if (!isPrivateChatSocketConnected) {
      return;
    }

    final payload = {
      "chatId": int.tryParse(chatId) ?? chatId,
    };

    _privateChatSocket!.emit(
      "clear_private_chat",
      payload,
    );
  }

  void listenPrivateChatCleared(
      Function(Map<String, dynamic>) callback,
      ) {
    if (_privateChatSocket == null) {
      return;
    }

    _privateChatSocket!.off("private_chat_cleared");

    _privateChatSocket!.on(
      "private_chat_cleared",
          (data) {
        if (data is Map) {
          callback(Map<String, dynamic>.from(data));
        }
      },
    );
  }
}