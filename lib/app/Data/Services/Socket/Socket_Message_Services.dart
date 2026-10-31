import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:socket_io_common/src/util/event_emitter.dart';

void log(String message, {Object? error, StackTrace? stackTrace, String? name}) {
  if (kDebugMode) {
    developer.log(message, error: error, stackTrace: stackTrace, name: name ?? 'SocketMessageService');
    debugPrint("[${name ?? 'Socket'}] $message");
  }
}

class SocketMessageService extends GetxService {
  static SocketMessageService get instance => Get.put(SocketMessageService());
  Timer? _privateJoinDebugTimer;
  IO.Socket? _socket;
  EventHandler<dynamic>? _privateMessageHandler;
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
    log("========== GROUP CHAT SOCKET INIT ==========");
    log("SOCKET URL: $socketUrl/chat");
    log("USER ID: $userId");
    log("GROUP ID: ${groupId ?? 'NULL'}");
    log("EXISTING SOCKET: ${_socket != null}");
    log("EXISTING SOCKET CONNECTED: ${_socket?.connected ?? false}");

    if (_socket != null && _socket!.connected) {
      log("SOCKET ALREADY CONNECTED");

      if (groupId != null) {
        log("JOIN GROUP REQUEST: userId=$userId, groupId=$groupId");
        joinUserInGroup(userId, groupId);

        log("MARK SEEN REQUEST: userId=$userId, groupId=$groupId");
        markSeen(userId, groupId);
      } else {
        log("GROUP ID IS NULL — JOIN AND MARK SEEN SKIPPED");
      }

      return;
    }

    log("CREATING NEW SOCKET: $socketUrl/chat");

    _socket = IO.io(
      "$socketUrl/chat",
      {
        "transports": ["websocket"],
        "autoConnect": true,
      },
    );

    _socket?.onConnect((_) {
      log("========== SOCKET CONNECTED ==========");
      log("SOCKET ID: ${_socket?.id}");
      log("USER ID: $userId");
      log("GROUP ID: ${groupId ?? 'NULL'}");
      log("CONNECTED STATUS: ${_socket?.connected}");

      if (groupId != null) {
        log("EMITTING JOIN GROUP");
        log("JOIN PARAMS: userId=$userId, groupId=$groupId");
        joinUserInGroup(userId, groupId);

        log("EMITTING MARK SEEN");
        log("MARK SEEN PARAMS: userId=$userId, groupId=$groupId");
        markSeen(userId, groupId);
      } else {
        log("GROUP ID IS NULL — JOIN AND MARK SEEN SKIPPED");
      }
    });

    _socket?.onDisconnect((reason) {
      log("========== SOCKET DISCONNECTED ==========");
      log("DISCONNECT REASON: $reason");
      log("USER ID: $userId");
      log("GROUP ID: ${groupId ?? 'NULL'}");
    });

    _socket?.onConnectError((error) {
      log("========== SOCKET CONNECT ERROR ==========");
      log("ERROR: $error");
      log("USER ID: $userId");
      log("GROUP ID: ${groupId ?? 'NULL'}");
    });

    _socket?.onError((error) {
      log("========== SOCKET ERROR ==========");
      log("ERROR: $error");
      log("USER ID: $userId");
      log("GROUP ID: ${groupId ?? 'NULL'}");
    });

    void handleStatusDeleted(dynamic data) {
      if (data == null) return;
      log("[ChatSocket] status:deleted received: $data");
      Map<String, dynamic>? map;
      if (data is Map) {
        map = Map<String, dynamic>.from(data);
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            map = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
      if (map != null) {
        if (Get.isRegistered<StatusSocketService>()) {
          Get.find<StatusSocketService>().onStatusDeletedEvent.value = map;
          Get.find<StatusSocketService>().onStatusDeletedEvent.refresh();
        } else if (Get.isRegistered<StatusFeedController>()) {
          final int deletedStatusId = map['statusId'] is int
              ? map['statusId']
              : int.tryParse(map['statusId']?.toString() ?? '') ?? 0;
          final int creatorUserId = map['userId'] is int
              ? map['userId']
              : int.tryParse(map['userId']?.toString() ?? '') ?? 0;
          if (deletedStatusId > 0) {
            Get.find<StatusFeedController>().onStatusDeletedReceived(
              deletedStatusId,
              creatorUserId,
            );
          }
        }
      }
    }

    _socket?.on('status:deleted', handleStatusDeleted);
    _socket?.on('status:delete', handleStatusDeleted);

    log("SOCKET INIT COMPLETED — WAITING FOR CONNECTION");
    log("===========================================");
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

    print("GROUP SEND EVENT => $payload");
    socket.emit("send_group_message", payload);
  }

  void receiveGroupMessage({
    required Function(dynamic) callback,
  }) {
    final events = [
      "receive_group_message",
      "group_forward_message",
      "forward_message",
      "receive_forward_message",
      "message_forwarded",
      "forwarded_message",
    ];

    for (final event in events) {
      socket.off(event);
      socket.on(
        event,
        (data) {
          callback(data);
        },
      );
    }
  }

  void sendGroupTyping({
    required int groupId,
    required String userId,
    required String userName,
  }) {
    final payload = {
      "groupId": groupId,
      "userId": userId,
      "senderId": userId,
      "userName": userName,
      "senderName": userName,
      "isTyping": true,
    };
    log("EMIT group_typing => $payload");
    if (!isSocketConnected) return;
    try {
      socket.emit("group_typing", payload);
    } catch (e) {
      log("Error emitting group_typing: $e");
    }
  }

  void sendGroupStopTyping({
    required int groupId,
    required String userId,
    String? userName,
  }) {
    final payload = {
      "groupId": groupId,
      "userId": userId,
      "senderId": userId,
      if (userName != null) "userName": userName,
      if (userName != null) "senderName": userName,
      "isTyping": false,
    };
    log("EMIT group_stop_typing => $payload");
    if (!isSocketConnected) return;
    try {
      socket.emit("group_stop_typing", payload);
    } catch (e) {
      log("Error emitting group_stop_typing: $e");
    }
  }

  void listenGroupTyping({
    required Function(dynamic) onTyping,
    required Function(dynamic) onStopTyping,
  }) {
    final s = _socket;
    if (s == null) {
      log("listenGroupTyping skipped: _socket is null");
      return;
    }
    s.off("group_typing");
    s.off("group_stop_typing");
    s.on("group_typing", (data) {
      log("RECEIVED group_typing => $data");
      onTyping(data);
    });
    s.on("group_stop_typing", (data) {
      log("RECEIVED group_stop_typing => $data");
      onStopTyping(data);
    });
  }

  void stopListeningGroupTyping() {
    _socket?.off("group_typing");
    _socket?.off("group_stop_typing");
  }

  Future<void> initPrivateChat(
      String socketUrl, {
        required String userId,
        required String receiverId,
        Function(dynamic)? onJoined,
      }) async {
    // Reuse existing connected socket.
    if (_privateChatSocket != null && _privateChatSocket!.connected) {
      log("PRIVATE CHAT SOCKET ALREADY CONNECTED");

      _privateChatSocket?.off("joined");

      if (onJoined != null) {
        _privateChatSocket?.on("joined", (data) {
          _privateJoinDebugTimer?.cancel();

          log("========== PRIVATE CHAT JOINED ==========");
          log("JOINED RAW DATA => $data");

          if (data is Map) {
            _privateChatId = data["chatId"]?.toString();
          }

          log("SAVED CHAT ID => $_privateChatId");

          onJoined.call(data);
        });
      }

      joinPrivateChat(
        userId: userId,
        receiverId: receiverId,
      );

      return;
    }

    // Dispose the old disconnected socket.
    if (_privateChatSocket != null) {
      _privateChatSocket?.disconnect();
      _privateChatSocket?.dispose();
      _privateChatSocket = null;
      _privateMessageHandler = null;
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
      log("PRIVATE CHAT SOCKET CONNECTED");
      log("NAMESPACE => /privateChat");

      _privateJoinDebugTimer?.cancel();

      joinPrivateChat(
        userId: userId,
        receiverId: receiverId,
      );

      _privateJoinDebugTimer = Timer(
        const Duration(seconds: 8),
            () {
          log("========== JOIN TIMEOUT DEBUG ==========");
          log("JOINED EVENT NOT RECEIVED WITHIN 8 SECONDS");
          log("SOCKET CONNECTED => $isPrivateChatSocketConnected");
          log("SOCKET ID => ${_privateChatSocket?.id}");
          log("PRIVATE CHAT ID => $_privateChatId");
        },
      );
    });

    _privateChatSocket?.on("joined", (data) {
      log("========== JOINED EVENT RECEIVED ==========");
      log("JOINED RAW DATA => $data");
      log("JOINED DATA TYPE => ${data.runtimeType}");

      if (data is Map) {
        log("JOINED CHAT ID => ${data["chatId"]}");

        _privateChatId = data["chatId"]?.toString();

        log("SAVED PRIVATE CHAT ID => $_privateChatId");
      } else {
        log("WARNING => JOINED DATA IS NOT A MAP");
      }

      if (onJoined != null) {
        log("CALLING CONTROLLER onJoined CALLBACK");
        onJoined.call(data);
      } else {
        log("WARNING => onJoined CALLBACK IS NULL");
      }
    });

    _privateChatSocket?.onDisconnect((reason) {
      log("========== PRIVATE SOCKET DISCONNECTED ==========");
      log("DISCONNECT REASON => $reason");
    });

    _privateChatSocket?.onError((error) {
      log("========== PRIVATE SOCKET ERROR ==========");
      log("SOCKET ERROR => $error");
    });

// Diagnostic only: checks whether the server sends this event.
// Keep this if the backend uses "connect_error" for connection failures.
    _privateChatSocket?.onConnectError((error) {
      log("========== PRIVATE SOCKET CONNECT ERROR ==========");
      log("CONNECT ERROR => $error");
    });

  }

  void joinPrivateChat({
    required String userId,
    required String receiverId,
  }) {
    log("========== PRIVATE JOIN DEBUG START ==========");
    log("JOIN USER ID => $userId");
    log("JOIN RECEIVER ID => $receiverId");
    log("SOCKET EXISTS => ${_privateChatSocket != null}");
    log("SOCKET CONNECTED => $isPrivateChatSocketConnected");
    log("SOCKET ID => ${_privateChatSocket?.id}");

    if (!isPrivateChatSocketConnected) {
      log("JOIN ABORTED => SOCKET NOT CONNECTED");
      return;
    }

    final payload = {
      "userId": userId,
      "receiverId": receiverId,
    };

    log("JOIN EVENT NAME => join");
    log("JOIN PAYLOAD => $payload");
    log("EMITTING JOIN EVENT NOW");

    _privateChatSocket!.emit("join", payload);

    log("JOIN EVENT EMIT CALLED");
    log("========== PRIVATE JOIN DEBUG END ==========");
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

    final senderId = Global.storageServices.get(PrefConst.userId).toString();

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
    final socket = _privateChatSocket;

    log("========== REGISTER PRIVATE MESSAGE LISTENER ==========");
    log("EXPECTED SENDER ID => $senderId");
    log("EXPECTED RECEIVER ID => $receiverId");
    log("PRIVATE SOCKET EXISTS => ${socket != null}");
    log("PRIVATE SOCKET CONNECTED => ${socket?.connected ?? false}");

    if (socket == null) {
      log("LISTENER NOT REGISTERED => PRIVATE SOCKET IS NULL");
      return;
    }

    final events = [
      "receive_message",
      "forward_message",
      "receive_forward_message",
      "message_forwarded",
      "forwarded_message",
    ];

    if (_privateMessageHandler != null) {
      for (final event in events) {
        socket.off(event, _privateMessageHandler);
      }
    }

    _privateMessageHandler = (dynamic data) {
      log("========== SOCKET RECEIVE MESSAGE EVENT ==========");
      log("RAW SOCKET DATA => $data");

      if (data is! Map) {
        log("MESSAGE IGNORED => DATA IS NOT A MAP");
        return;
      }

      final dataMap = Map<String, dynamic>.from(data);
      final inner = dataMap['message'] is Map
          ? Map<String, dynamic>.from(dataMap['message'])
          : (dataMap['data'] is Map
              ? Map<String, dynamic>.from(dataMap['data'])
              : dataMap);

      final dataSenderId = (inner["senderId"] ??
              inner["sender_id"] ??
              inner["userId"] ??
              inner["user_id"] ??
              dataMap["senderId"] ??
              dataMap["sender_id"])
          ?.toString();
      final dataReceiverId = (inner["receiverId"] ??
              inner["receiver_id"] ??
              inner["targetId"] ??
              inner["target_id"] ??
              dataMap["receiverId"] ??
              dataMap["receiver_id"])
          ?.toString();

      final isSameChat =
          (dataSenderId == senderId && dataReceiverId == receiverId) ||
          (dataSenderId == receiverId && dataReceiverId == senderId) ||
          (dataReceiverId == receiverId && (dataSenderId == null || dataSenderId == senderId)) ||
          (dataSenderId == receiverId && (dataReceiverId == null || dataReceiverId == senderId));

      log("EXPECTED SENDER => $senderId");
      log("EXPECTED RECEIVER => $receiverId");
      log("ACTUAL SENDER => $dataSenderId");
      log("ACTUAL RECEIVER => $dataReceiverId");
      log("IS SAME CHAT => $isSameChat");

      if (!isSameChat) {
        log("MESSAGE IGNORED => DIFFERENT CHAT");
        return;
      }

      log("MESSAGE ACCEPTED => CALLING CONTROLLER CALLBACK");

      callback?.call(dataMap);

      log("CONTROLLER CALLBACK COMPLETED");
    };

    for (final event in events) {
      socket.on(event, _privateMessageHandler!);
    }

    log("RECEIVE MESSAGE LISTENER REGISTERED");
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
    if (!isPrivateChatSocketConnected) {
      return;
    }

    final payload = {
      "chatId": chatId,
      "userId": userId,
      "otherUserId": otherUserId,
    };

    _privateChatSocket!.emit(
      "mark_seen",
      payload,
    );

    log("MARK SEEN EMIT CALLED");
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

  void sendPrivateTyping({
    required String chatId,
    required String userId,
    required String otherUserId,
    String? userName,
  }) {
    final payload = {
      "chatId": chatId,
      "userId": userId,
      "senderId": userId,
      "otherUserId": otherUserId,
      "receiverId": otherUserId,
      if (userName != null) "userName": userName,
      if (userName != null) "senderName": userName,
      "isTyping": true,
    };
    log("EMIT private typing => $payload");
    if (!isPrivateChatSocketConnected) return;
    try {
      _privateChatSocket?.emit("typing", payload);
    } catch (e) {
      log("Error emitting private typing: $e");
    }
  }

  void sendPrivateStopTyping({
    required String chatId,
    required String userId,
    required String otherUserId,
    String? userName,
  }) {
    final payload = {
      "chatId": chatId,
      "userId": userId,
      "senderId": userId,
      "otherUserId": otherUserId,
      "receiverId": otherUserId,
      if (userName != null) "userName": userName,
      if (userName != null) "senderName": userName,
      "isTyping": false,
    };
    log("EMIT private stop_typing => $payload");
    if (!isPrivateChatSocketConnected) return;
    try {
      _privateChatSocket?.emit("stop_typing", payload);
    } catch (e) {
      log("Error emitting private stop_typing: $e");
    }
  }

  void listenPrivateTyping({
    required Function(dynamic) onTyping,
    required Function(dynamic) onStopTyping,
  }) {
    final s = _privateChatSocket;
    if (s == null) {
      log("listenPrivateTyping skipped: _privateChatSocket is null");
      return;
    }
    s.off("typing");
    s.off("stop_typing");
    s.on("typing", (data) {
      log("RECEIVED private typing => $data");
      onTyping(data);
    });
    s.on("stop_typing", (data) {
      log("RECEIVED private stop_typing => $data");
      onStopTyping(data);
    });
  }

  void stopListeningPrivateTyping() {
    _privateChatSocket?.off("typing");
    _privateChatSocket?.off("stop_typing");
  }

  void initPrivateChatListSocket(
    String socketUrl, {
    required String userId,
  }) {
    if (_privateChatListSocket != null && _privateChatListSocket!.connected) {
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
      _privateChatListSocket?.off("conversation_updated");

      if (_privateChatListUpdatedCallback != null) {
        _privateChatListSocket?.on("chat_list_updated", (data) {
          _privateChatListUpdatedCallback?.call(data);
        });
        _privateChatListSocket?.on("conversation_updated", (data) {
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

      _privateChatListSocket?.off("private_chat_cleared");

      if (_privateChatClearedListCallback != null) {
        _privateChatListSocket?.on(
          "private_chat_cleared",
              (data) {
            if (data is Map) {
              _privateChatClearedListCallback?.call(
                Map<String, dynamic>.from(data),
              );
            }
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
  Function(Map<String, dynamic>)? _privateChatClearedListCallback;
  Function(dynamic)? _privateChatListUpdatedCallback;

  Function(dynamic)? _unifiedFullChatListCallback;

  void listenPrivateChatListUpdated({
    required Function(dynamic) callback,
  }) {
    _privateChatListUpdatedCallback = callback;

    void register(IO.Socket? s) {
      if (s == null) return;
      s.off("chat_list_updated");
      s.off("conversation_updated");
      s.on("chat_list_updated", (data) {
        _privateChatListUpdatedCallback?.call(data);
      });
      s.on("conversation_updated", (data) {
        _privateChatListUpdatedCallback?.call(data);
      });
    }

    if (_privateChatListSocket != null && _privateChatListSocket!.connected) {
      register(_privateChatListSocket);
    }
    if (_socket != null && _socket!.connected) {
      register(_socket);
    }
  }

  void listenFullChatList({
    required Function(dynamic) callback,
  }) {
    _unifiedFullChatListCallback = callback;

    void register(IO.Socket? s) {
      if (s == null) return;
      s.off("chat_list");
      s.off("common_chat_list");
      s.off("unified_chat_list");
      s.on("chat_list", (data) => _unifiedFullChatListCallback?.call(data));
      s.on("common_chat_list", (data) => _unifiedFullChatListCallback?.call(data));
      s.on("unified_chat_list", (data) => _unifiedFullChatListCallback?.call(data));
    }

    register(_privateChatListSocket);
    register(_socket);
  }

  void fetchUnifiedChatList({
    int page = 1,
    int limit = 50,
    String search = "",
  }) {
    final payload = {
      "page": page,
      "limit": limit,
      "search": search,
    };
    if (isPrivateChatListSocketConnected) {
      _privateChatListSocket?.emit("get_chat_list", payload);
    } else if (isSocketConnected) {
      _socket?.emit("get_chat_list", payload);
    }
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

  void clearPrivateChatListeners() {
    _privateChatSocket?.off("joined");
    _privateChatSocket?.off("receive_message");
    _privateChatSocket?.off("forward_message");
    _privateChatSocket?.off("receive_forward_message");
    _privateChatSocket?.off("message_forwarded");
    _privateChatSocket?.off("forwarded_message");
    _privateChatSocket?.off("messages_delivered");
    _privateChatSocket?.off("messages_seen_update");
    _privateChatSocket?.off("private_chat_updated");
    _privateChatSocket?.off("private_chat_cleared");
    _privateChatSocket?.off("typing");
    _privateChatSocket?.off("stop_typing");
    _privateChatSocket?.off("messageEdited");
    _privateChatSocket?.off("message_deleted");
    _privateChatSocket?.off("message_pinned");
    _privateChatSocket?.off("message_unpinned");
    _privateMessageHandler = null;
    _privateChatId = null;
    _privateJoinDebugTimer?.cancel();
  }

  void disconnectPrivateChatSocket() {
    clearPrivateChatListeners();

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
    _privateChatListSocket?.off("private_chat_cleared");
    _privateChatListSocket?.disconnect();
    _privateChatListSocket?.dispose();

    _privateChatListSocket = null;
    _privateChatClearedListCallback = null;
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

    debugPrint("========== SOCKET DELETE EMIT ==========");
    debugPrint("EVENT: delete_message");
    debugPrint("PAYLOAD: $payload");
    debugPrint("GROUP SOCKET CONNECTED: ${_socket?.connected}");
    debugPrint("PRIVATE SOCKET CONNECTED: ${_privateChatSocket?.connected}");

    if (otherUserId != null && isPrivateChatSocketConnected) {
      debugPrint("EMITTING ON PRIVATE CHAT SOCKET");
      _privateChatSocket!.emit("delete_message", payload);
      return;
    }

    debugPrint("EMITTING ON CHAT SOCKET");
    _socket?.emit("delete_message", payload);
  }

  void listenMessageDeleted({
    required Function(dynamic data) callback,
  }) {
    _socket?.off("message_deleted");
    _privateChatSocket?.off("message_deleted");

    _socket?.on("message_deleted", (data) {
      debugPrint("MAIN SOCKET message_deleted => $data");
      callback(data);
    });

    _privateChatSocket?.on("message_deleted", (data) {
      debugPrint("PRIVATE SOCKET message_deleted => $data");
      callback(data);
    });
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
    dynamic content,
    String? messageType,
    List<String>? images,
    List<Map<String, dynamic>>? videos,
    String? caption,
  }) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString();

    final payload = {
      "messageId": messageId,
      "message_id": messageId,
      "forwardedFromMessageId": messageId,
      "forwarded_from_message_id": messageId,
      "isForwarded": true,
      "is_forwarded": true,
      if (content != null) "content": content,
      if (content != null) "message": content,
      if (messageType != null) "messageType": messageType,
      if (messageType != null) "message_type": messageType,
      if (images != null && images.isNotEmpty) "images": images,
      if (videos != null && videos.isNotEmpty) "videos": videos,
      if (caption != null && caption.isNotEmpty) "caption": caption,
      if (receiverId != null) "receiverId": receiverId,
      if (receiverId != null) "receiver_id": receiverId,
      if (groupId != null) "groupId": groupId,
      if (groupId != null) "group_id": groupId,
      if (currentUserId != null) "senderId": currentUserId,
      if (currentUserId != null) "sender_id": currentUserId,
    };

    log("========== FORWARD MESSAGE START ==========");
    log("EVENT => forward_message");
    log("PAYLOAD => $payload");
    log("MESSAGE ID => $messageId");
    log("RECEIVER ID => $receiverId");
    log("GROUP ID => $groupId");
    log("PRIVATE SOCKET CONNECTED => $isPrivateChatSocketConnected");
    log("GROUP SOCKET CONNECTED => $isSocketConnected");

    if (receiverId != null && receiverId.isNotEmpty) {
      if (isPrivateChatSocketConnected) {
        _privateChatSocket!.emit("forward_message", payload);
        log("FORWARD MESSAGE EMITTED ON PRIVATE SOCKET");
      } else if (isSocketConnected) {
        socket.emit("forward_message", payload);
        log("FORWARD MESSAGE EMITTED ON FALLBACK SOCKET");
      } else {
        log("FORWARD FAILED => SOCKET NOT CONNECTED");
      }
      log("========== FORWARD MESSAGE END ==========");
      return;
    }

    if (groupId != null) {
      if (!isSocketConnected) {
        log("FORWARD FAILED => GROUP SOCKET NOT CONNECTED");
        return;
      }

      socket.emit("forward_message", payload);

      log("FORWARD MESSAGE EMITTED ON GROUP SOCKET");
      log("========== FORWARD MESSAGE END ==========");
      return;
    }

    log("FORWARD FAILED => RECEIVER ID AND GROUP ID BOTH MISSING");
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
    log("========== MARK PRIVATE CHAT READ DEBUG ==========");
    log("Socket Connected => $isPrivateChatListSocketConnected");
    log("User ID => $userId");
    log("Chat ID => $chatId");

    if (!isPrivateChatListSocketConnected) {
      log("MARK PRIVATE CHAT READ FAILED => SOCKET NOT CONNECTED");
      return;
    }

    final payload = {
      "chatId": int.tryParse(chatId) ?? chatId,
      "userId": int.tryParse(userId) ?? userId,
    };

    log("EVENT => mark_private_chat_read");
    log("PAYLOAD => $payload");

    _privateChatListSocket!.emit(
      "mark_private_chat_read",
      payload,
    );

    log("MARK PRIVATE CHAT READ EMIT CALLED");
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

  void listenPrivateChatClearedOnListSocket({
    required Function(Map<String, dynamic>) callback,
  }) {
    _privateChatClearedListCallback = callback;

    if (_privateChatListSocket == null) {
      return;
    }

    _privateChatListSocket!.off("private_chat_cleared");

    _privateChatListSocket!.on(
      "private_chat_cleared",
      (data) {
        if (data is Map) {
          _privateChatClearedListCallback?.call(
            Map<String, dynamic>.from(data),
          );
        }
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

  void disconnectAll() {
    try {
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    } catch (_) {}
    try {
      disconnectPrivateChatSocket();
    } catch (_) {}
    try {
      disconnectPrivateChatListSocket();
    } catch (_) {}
  }
}
