import 'package:fgtracker/l10n/l10n.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/util/rt_log.dart';
import 'package:fgtracker/app/Data/Services/active_chat_tracker.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:socket_io_common/src/util/event_emitter.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:fgtracker/app/Core/util/rt_attachment_log.dart'; // TODO(rt-diagnostics)
import 'package:fgtracker/app/modules/Messages/Controller/message_receipts.dart';
import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';

void log(String message,
    {Object? error, StackTrace? stackTrace, String? name}) {
  if (kDebugMode) {
    developer.log(message,
        error: error,
        stackTrace: stackTrace,
        name: name ?? 'SocketMessageService');
    AppLog.d("[${name ?? 'Socket'}] $message");
  }
}

/// Which chat socket a chat-screen listener belongs to.
enum ChatSocketScope { private, group }

/// TEMPORARY receipt diagnostics (Message Info / seen / delivered). Debug
/// builds only. Remove all `[SEEN-DBG]` lines before the final commit.
void seenDbg(String message) {
  if (kDebugMode) debugPrint('[SEEN-DBG] $message');
}

/// Remembers keys for [window]; [seen] is true for a key already seen inside
/// the window. Used to apply an event once when the server sends the same
/// thing under several event names or to several rooms.
class _RecentKeys {
  _RecentKeys(this.window);
  final Duration window;
  static const int max = 300;
  final Map<String, DateTime> _at = {};

  bool seen(String key) {
    final now = DateTime.now();
    final last = _at[key];
    if (last != null && now.difference(last) < window) return true;
    _at.remove(key);
    _at[key] = now;
    if (_at.length > max) _at.remove(_at.keys.first);
    return false;
  }
}

/// A block / unblock between two users ([blockerId] blocked [blockedId]).
/// Comes from a backend block event or from a `BLOCKED` send ack.
class BlockStatusEvent {
  const BlockStatusEvent({
    required this.blockerId,
    required this.blockedId,
    required this.isBlocked,
  });
  final String blockerId;
  final String blockedId;
  final bool isBlocked;
}

class SocketMessageService extends GetxService {
  static SocketMessageService get instance => Get.put(SocketMessageService());

  /// Tests only: connect to a local fake Socket.IO server instead of the
  /// (const) server URL, which a test can no longer change.
  @visibleForTesting
  static String? debugSocketUrlOverride;
  Timer? _privateJoinDebugTimer;
  IO.Socket? _socket;
  EventHandler<dynamic>? _privateMessageHandler;

  // ---- Group receipts (read / delivered), one app-level listener ----

  final StreamController<ReceiptUpdate> _groupReceiptCtrl =
      StreamController<ReceiptUpdate>.broadcast();

  /// Every group read / delivered update, once (duplicates from several
  /// event names or rooms are dropped). Screens subscribe and cancel on
  /// dispose; the socket listener itself is registered once per socket.
  Stream<ReceiptUpdate> get groupReceipts => _groupReceiptCtrl.stream;

  /// Tests: feed a receipt payload as if it came from the socket.
  @visibleForTesting
  void debugReceiveGroupReceipt(dynamic data, {required bool isRead}) =>
      _onGroupReceipt(data, isRead: isRead);

  final StreamController<void> _chatConnectedCtrl =
      StreamController<void>.broadcast();

  /// Fires on every connect / reconnect of the /chat socket.
  Stream<void> get chatConnected => _chatConnectedCtrl.stream;

  final _RecentKeys _recentReceipts = _RecentKeys(const Duration(seconds: 3));
  final _RecentKeys _recentGroupMessages =
      _RecentKeys(const Duration(seconds: 30));
  final _RecentKeys _recentTyping =
      _RecentKeys(const Duration(milliseconds: 600));

  /// Group message ids this app already reported as delivered.
  final Set<String> _deliveredEmitted = <String>{};

  void _onGroupSeenEvent(dynamic data) => _onGroupReceipt(data, isRead: true);
  void _onGroupDeliveredEvent(dynamic data) =>
      _onGroupReceipt(data, isRead: false);

  void _onGroupReceipt(dynamic data, {required bool isRead}) {
    final update = ReceiptUpdate.parse(data, isRead: isRead);
    seenDbg('IN ${isRead ? 'seen' : 'delivered'} => $data');
    if (update == null) return;
    if (_recentReceipts.seen(update.key)) {
      seenDbg('IN duplicate dropped (${update.key})');
      return;
    }
    if (!_groupReceiptCtrl.isClosed) _groupReceiptCtrl.add(update);
  }

  /// Registers the receipt listeners on [s] once (by reference, so calling
  /// it again never stacks a second handler).
  void _registerGroupReceipts(IO.Socket? s) {
    if (s == null) return;
    for (final ev in ReceiptEvents.allGroupSeen) {
      s.off(ev, _onGroupSeenEvent);
      s.on(ev, _onGroupSeenEvent);
    }
    for (final ev in ReceiptEvents.allGroupDelivered) {
      s.off(ev, _onGroupDeliveredEvent);
      s.on(ev, _onGroupDeliveredEvent);
    }
    // Any group message reaching this phone on /chat (any screen) counts as
    // delivered.
    for (final ev in const ["receive_group_message", "receive_message"]) {
      s.off(ev, _onAnyGroupMessage);
      s.on(ev, _onAnyGroupMessage);
    }
  }

  void _onAnyGroupMessage(dynamic data) {
    if (data is! Map) return;
    final gid = data['groupId'] ?? data['group_id'];
    if (gid == null) return;
    _deliverIfFromOther(groupId: gid, message: data);
  }

  /// Chat-list payloads carry the group's last message: report it delivered
  /// when it is from someone else (covers groups whose room is not joined).
  void _deliverFromListPayload(dynamic data) {
    if (data is! Map) return;
    final gid = data['groupId'] ?? data['group_id'];
    final type = data['chatType']?.toString().toLowerCase();
    if (gid == null || (type != null && type != 'group')) return;
    final last =
        data['lastMessage'] ?? data['lastMessageData'] ?? data['message'];
    if (last is Map) _deliverIfFromOther(groupId: gid, message: last);
  }

  void _deliverIfFromOther({required dynamic groupId, required Map message}) {
    final me = Global.storageServices.get(PrefConst.userId)?.toString();
    final sender = normalizeReceiptId(
        message['senderId'] ?? message['sender_id'] ?? message['userId']);
    final id = normalizeReceiptId(message['id'] ?? message['messageId']);
    final gid = int.tryParse(groupId.toString());
    if (id == null || gid == null || sender == null || me == null) return;
    if (sender == normalizeReceiptId(me)) return;
    markGroupDelivered(groupId: gid, userId: me, messageIds: [id]);
  }

  /// Reports group messages as delivered to this phone. Ids already reported
  /// in this session are skipped, so it is safe to call often.
  void markGroupDelivered({
    required int groupId,
    required String userId,
    required Iterable<String> messageIds,
  }) {
    final fresh = messageIds
        .map(normalizeReceiptId)
        .whereType<String>()
        .where((id) => !_deliveredEmitted.contains(id))
        .toList();
    if (fresh.isEmpty) return;
    final s = _socket;
    if (s == null) return;
    _deliveredEmitted.addAll(fresh);
    final uidInt = int.tryParse(userId);
    final payload = {
      "groupId": groupId,
      "group_id": groupId,
      "userId": uidInt ?? userId,
      "user_id": uidInt ?? userId,
      "messageIds": fresh.map((id) => int.tryParse(id) ?? id).toList(),
      "deliveredAt": DateTime.now().toUtc().toIso8601String(),
    };
    seenDbg('EMIT ${ReceiptEvents.markDelivered} => $payload');
    s.emit(ReceiptEvents.markDelivered, payload);
  }

  /// Chat currently open on the /chat socket; rejoined on every reconnect.
  String? _activeUserId;
  int? _activeGroupId;

  /// Poll whose admin detail room is joined (View Attendance screen).
  int? _subscribedPollId;
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

  /// Private chat currently open. The socket's onConnect closure is created
  /// once with the FIRST chat's ids; reconnects must join the chat that is
  /// open now (or none), so they read these fields instead.
  String? _activePrivateUserId;
  String? _activePrivateReceiverId;

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

    // Remember the chat currently open, so every (re)connect rejoins the
    // right group room instead of the group the socket was first created for.
    _activeUserId = userId;
    _activeGroupId = groupId;

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

    if (_socket != null) {
      // Socket exists but is (re)connecting: don't build a second one (that
      // stacks duplicate handlers). The connect handler joins the active group.
      log("SOCKET EXISTS BUT NOT CONNECTED — RECONNECTING");
      _socket!.connect();
      return;
    }

    log("CREATING NEW SOCKET: $socketUrl/chat");

    _socket = IO.io(
      "${debugSocketUrlOverride ?? socketUrl}/chat",
      {
        "transports": ["websocket"],
        "autoConnect": true,
        // Opts in to attendance socket events (server checks auth or query).
        // token: lets the server identify the user for attendance rooms
        // (attendance:subscribe / sync / my_vote), same as the status socket.
        // A function, not a map: socket.io calls it on EVERY (re)connect
        // handshake, so a reconnect always sends the current stored token
        // (backend v2.3.0 re-checks the JWT on each reconnect).
        "auth": (Function cb) => cb({
              "attendanceSupported": "1",
              "token": Global.storageServices.getaccesstoken() ?? "",
            }),
        "query": {"attendanceSupported": "1"},
      },
    );
    _registerGroupStatus(_socket);
    _registerBlockStatus(_socket);
    _registerGroupMemberChanges(_socket);
    // App-level, once per socket: group read / delivered receipts and the
    // "delivered" report for any group message reaching this phone.
    _registerGroupReceipts(_socket);

    // Realtime debug: every attendance / chat-list event reaching /chat.
    _socket?.onAny((event, data) {
      if (event.startsWith("attendance") ||
          event.contains("chat_list") ||
          event == "conversation_updated") {
        rtLog("[RT_DEBUG] /chat <= $event");
      }
    });

    _socket?.onConnect((_) {
      final activeUserId = _activeUserId ?? userId;
      final activeGroupId = _activeGroupId;
      log("========== SOCKET CONNECTED ==========");
      log("SOCKET ID: ${_socket?.id}");
      log("USER ID: $activeUserId");
      log("GROUP ID: ${activeGroupId ?? 'NULL'}");
      log("CONNECTED STATUS: ${_socket?.connected}");

      if (activeGroupId != null) {
        log("EMITTING JOIN GROUP");
        log("JOIN PARAMS: userId=$activeUserId, groupId=$activeGroupId");
        joinUserInGroup(activeUserId, activeGroupId);
        joinGroupChat(groupId: activeGroupId, userId: activeUserId);

        log("EMITTING MARK SEEN");
        log("MARK SEEN PARAMS: userId=$activeUserId, groupId=$activeGroupId");
        // A reconnect while the app is in the background must not mark
        // the group read; the group screen sends it again on resume.
        if (ActiveChatTracker.isAppInForeground) {
          markSeen(activeUserId, activeGroupId);
        }
      } else {
        log("GROUP ID IS NULL — JOIN AND MARK SEEN SKIPPED");
      }

      // Re-join the admin detail room the View Attendance screen is showing.
      if (_subscribedPollId != null) {
        _emitAttendanceSubscribe(_subscribedPollId!);
      }
      rtLog(
        "[RT_DEBUG] /chat connected: group=$activeGroupId poll=$_subscribedPollId",
      );
      // Re-register chat list listeners on (re)connect
      _registerChatListListeners(_socket);
      _registerFullChatListListeners(_socket);
      _registerListRemovalListeners(_socket);
      _registerListGroupLifecycleListeners(_socket);
      _registerChatListGroupTyping(_socket);
      _registerEditListener(_socket);

      // Screens re-fetch receipts / Message Info after a reconnect.
      if (!_chatConnectedCtrl.isClosed) _chatConnectedCtrl.add(null);
    });

    // The chat list may have registered before this socket existed.
    _registerChatListListeners(_socket);
    _registerFullChatListListeners(_socket);
    _registerListRemovalListeners(_socket);
    _registerListGroupLifecycleListeners(_socket);
    _registerChatListGroupTyping(_socket);

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
      _onTokenRejected(_socket, error);
    });

    _socket?.onError((error) {
      log("========== SOCKET ERROR ==========");
      log("ERROR: $error");
      log("USER ID: $userId");
      log("GROUP ID: ${groupId ?? 'NULL'}");
    });

    void handleStatusNew(dynamic data) {
      if (data == null) return;
      log("[ChatSocket] status:new received: $data");
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
          Get.find<StatusSocketService>().onNewStatusEvent.value = map;
          Get.find<StatusSocketService>().onNewStatusEvent.refresh();
        }
        if (Get.isRegistered<StatusFeedController>()) {
          Get.find<StatusFeedController>().refreshAll();
        }
      }
    }

    _socket?.on('status:new', handleStatusNew);
    _socket?.on('status_new', handleStatusNew);

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
    _activeUserId = userId;
    _activeGroupId = groupId;
    if (!isSocketConnected) return;

    final uidInt = int.tryParse(userId.toString());
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    final payload = {
      "userId": uidInt ?? userId,
      "groupId": gidInt,
      "user_id": uidInt ?? userId,
      "group_id": gidInt,
      "chatId": gidInt,
      "chat_id": gidInt,
    };
    _socket!.emit("join_group", payload);
    _socket!.emit("join", payload);
    _socket!.emit("join_group_chat", payload);
  }

  void leaveUserFromGroup(
    String userId,
    int groupId,
  ) {
    if (!isSocketConnected) return;

    final uidInt = int.tryParse(userId.toString());
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    _socket!.emit(
      "leave",
      {
        "userId": uidInt ?? userId,
        "groupId": gidInt,
        "user_id": uidInt ?? userId,
        "group_id": gidInt,
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
    final senderId = Global.storageServices.get(PrefConst.userId).toString();
    final senderIdInt = int.tryParse(senderId);
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    final msg = {
      'senderId': senderIdInt ?? senderId,
      'userId': senderIdInt ?? senderId,
      // Group message: there is no single receiver (was the sender's own id).
      'receiverId': null,
      'groupId': gidInt,
      'group_id': gidInt,
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

  /// Group read receipt. [messageIds] = the messages being marked read (from
  /// other members); omitted when not known yet (e.g. before history loads).
  void markSeen(
    String userId,
    int groupId, {
    Iterable<String>? messageIds,
  }) {
    final uidInt = int.tryParse(userId.toString());
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    final ids = messageIds
        ?.map(normalizeReceiptId)
        .whereType<String>()
        .map((id) => int.tryParse(id) ?? id)
        .toList();
    final payload = {
      "userId": uidInt ?? userId,
      "groupId": gidInt,
      "user_id": uidInt ?? userId,
      "group_id": gidInt,
      if (ids != null && ids.isNotEmpty) "messageIds": ids,
      "readAt": DateTime.now().toUtc().toIso8601String(),
    };
    seenDbg('EMIT ${ReceiptEvents.markSeen} (group) => $payload');
    _socket?.emit(ReceiptEvents.markSeen, payload);
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

  void joinGroupChat({
    required int groupId,
    required String userId,
  }) {
    _activeGroupId = groupId;
    _activeUserId = userId;
    if (!isSocketConnected) {
      log("SOCKET NOT CONNECTED YET — ROOM JOIN QUEUED FOR CONNECT: groupId=$groupId");
      return;
    }

    final uidInt = int.tryParse(userId.toString());
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    final payload = {
      "groupId": gidInt,
      "userId": uidInt ?? userId,
      "group_id": gidInt,
      "user_id": uidInt ?? userId,
      "chatId": gidInt,
      "chat_id": gidInt,
    };
    log("JOIN GROUP CHAT EMIT: $payload");
    socket.emit("join_group", payload);
    socket.emit("join", payload);
    socket.emit("join_group_chat", payload);
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
    String? clientMessageId,
    Map<String, dynamic>? locationMeta,
    Map<String, dynamic>? contactMeta,
    dynamic duration,
  }) {
    if (!isSocketConnected) {
      log("SOCKET NOT CONNECTED - CANNOT SEND GROUP MESSAGE");
      return;
    }

    final senderId = Global.storageServices.get(PrefConst.userId).toString();
    final senderIdInt = int.tryParse(senderId);
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    final effectiveClientMsgId =
        clientMessageId ?? 'c_${DateTime.now().microsecondsSinceEpoch}';

    final payload = <String, dynamic>{
      "senderId": senderIdInt ?? senderId,
      "userId": senderIdInt ?? senderId,
      // Group message: there is no single receiver (was the sender's own id).
      "receiverId": null,
      "groupId": gidInt,
      "group_id": gidInt,
      "messageType": messageType,
      "content": content,
      "clientMessageId": effectiveClientMsgId,
      if (images != null && images.isNotEmpty) "images": images,
      if (videos != null && videos.isNotEmpty) "videos": videos,
      if (caption != null) "caption": caption,
      if (replyId != null) "replyId": replyId,
      if (replyMessage != null) "replyMessage": replyMessage,
      if (replyType != null) "replyType": replyType,
      if (replySender != null) "replySender": replySender,
      if (locationMeta != null) "locationMeta": locationMeta,
      if (contactMeta != null) "contactMeta": contactMeta,
      if (duration != null) "duration": duration,
    };

    log("EMITTING SEND GROUP MESSAGE: $payload");
    // 'send_message' is the active, verified event on /chat that works without backend ReferenceError
    socket.emitWithAck("send_message", payload, ack: _onSendAck);
  }

  static const List<String> _groupReceiveEvents = [
    "receive_group_message",
    "receive_message",
    "group_forward_message",
    "forward_message",
    "receive_forward_message",
    "message_forwarded",
    "forwarded_message",
  ];

  /// The open group screen's message handler, kept by reference so it can
  /// be replaced / removed without touching other listeners on the event.
  EventHandler<dynamic>? _groupScreenReceiveHandler;

  /// Dedupe key for an incoming group message: the server sends the same
  /// message under several event names and to several rooms.
  static String? _groupMessageKey(dynamic data) {
    if (data is! Map) return null;
    final inner = data['message'] is Map ? data['message'] as Map : data;
    final id =
        normalizeReceiptId(inner['id'] ?? inner['messageId'] ?? data['id']);
    if (id != null) return 'id:$id';
    final client =
        (inner['clientMessageId'] ?? data['clientMessageId'])?.toString();
    if (client != null && client.isNotEmpty) return 'c:$client';
    return null;
  }

  void receiveGroupMessage({
    required Function(dynamic) callback,
  }) {
    final s = socket;
    final old = _groupScreenReceiveHandler;
    if (old != null) {
      for (final event in _groupReceiveEvents) {
        s.off(event, old);
      }
    }
    void handler(dynamic data) {
      final key = _groupMessageKey(data);
      if (key != null && _recentGroupMessages.seen(key)) return;
      rtSocketRaw('group receive', data); // TODO(rt-diagnostics)
      callback(data);
    }

    _groupScreenReceiveHandler = handler;
    for (final event in _groupReceiveEvents) {
      s.on(event, handler);
    }
  }

  void sendGroupTyping({
    required int groupId,
    required String userId,
    required String userName,
  }) {
    final uidInt = int.tryParse(userId.toString());
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    final payload = {
      "groupId": gidInt,
      "userId": uidInt ?? userId,
      "senderId": uidInt ?? userId,
      "userName": userName,
      "senderName": userName,
      "group_id": gidInt,
      "chatId": gidInt,
      "user_id": uidInt ?? userId,
      "sender_id": uidInt ?? userId,
      "isTyping": true,
    };
    log("EMIT group_typing => $payload");
    if (!isSocketConnected) return;
    try {
      socket.emit("group_typing", payload);
      socket.emit("typing", payload);
    } catch (e) {
      log("Error emitting group_typing: $e");
    }
  }

  void sendGroupStopTyping({
    required int groupId,
    required String userId,
    String? userName,
  }) {
    final uidInt = int.tryParse(userId.toString());
    final gidInt = int.tryParse(groupId.toString()) ?? groupId;
    final payload = {
      "groupId": gidInt,
      "userId": uidInt ?? userId,
      "senderId": uidInt ?? userId,
      if (userName != null) "userName": userName,
      if (userName != null) "senderName": userName,
      "group_id": gidInt,
      "chatId": gidInt,
      "user_id": uidInt ?? userId,
      "sender_id": uidInt ?? userId,
      "isTyping": false,
    };
    log("EMIT group_stop_typing => $payload");
    if (!isSocketConnected) return;
    try {
      socket.emit("group_stop_typing", payload);
      socket.emit("stop_typing", payload);
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
    // Remove only this screen's previous handlers: the chat list keeps its
    // own group typing listener on the same /chat socket.
    _removeGroupScreenTypingHandlers(s);
    _groupScreenTypingHandler = (data) {
      if (_isRepeatedTyping('screen', true, data)) return;
      log("RECEIVED group_typing => $data");
      onTyping(data);
    };
    _groupScreenStopTypingHandler = (data) {
      if (_isRepeatedTyping('screen', false, data)) return;
      log("RECEIVED group_stop_typing => $data");
      onStopTyping(data);
    };
    s.on("group_typing", _groupScreenTypingHandler!);
    s.on("group_stop_typing", _groupScreenStopTypingHandler!);
  }

  EventHandler<dynamic>? _groupScreenTypingHandler;
  EventHandler<dynamic>? _groupScreenStopTypingHandler;

  /// The server repeats one typing change (several event names / rooms);
  /// each consumer handles it once per short window.
  bool _isRepeatedTyping(String consumer, bool typing, dynamic data) {
    if (data is! Map) return false;
    final gid = data['groupId'] ?? data['group_id'] ?? data['chatId'];
    final uid = data['userId'] ?? data['senderId'] ?? data['user_id'];
    return _recentTyping.seen('$consumer|$typing|$gid|$uid');
  }

  void _removeGroupScreenTypingHandlers(IO.Socket? s) {
    if (s == null) return;
    if (_groupScreenTypingHandler != null) {
      s.off("group_typing", _groupScreenTypingHandler);
    }
    if (_groupScreenStopTypingHandler != null) {
      s.off("group_stop_typing", _groupScreenStopTypingHandler);
    }
  }

  void stopListeningGroupTyping() {
    _removeGroupScreenTypingHandlers(_socket);
    _groupScreenTypingHandler = null;
    _groupScreenStopTypingHandler = null;
  }

  // ---------------------------------------------------------------------------
  // Chat list: typing, reconnect and the always-on /chat socket.
  // Handlers are kept by reference so they are registered once per socket and
  // never removed by a chat screen's own off() calls.
  // ---------------------------------------------------------------------------

  Function(dynamic)? _chatListPrivateTyping;
  Function(dynamic)? _chatListPrivateStopTyping;
  Function(dynamic)? _chatListGroupTyping;
  Function(dynamic)? _chatListGroupStopTyping;
  EventHandler<dynamic>? _listPrivateTypingHandler;
  EventHandler<dynamic>? _listPrivateStopTypingHandler;
  EventHandler<dynamic>? _listGroupTypingHandler;
  EventHandler<dynamic>? _listGroupStopTypingHandler;
  void Function()? _chatListReconnectCallback;

  /// A group chat screen closed: stop re-joining (and auto-marking seen) that
  /// group on reconnect. Another group opened in the meantime is kept.
  void clearActiveGroup(int? groupId) {
    if (groupId != null && _activeGroupId == groupId) _activeGroupId = null;
  }

  /// Opens the /chat namespace (group list updates, group typing, group
  /// read) without joining any group. No-op when it already exists, so an
  /// open group chat keeps its room.
  void ensureChatSocket(String socketUrl, {required String userId}) {
    if (_socket != null) return;
    init(socketUrl, userId: userId);
  }

  void listenChatListTyping({
    required Function(dynamic) onPrivateTyping,
    required Function(dynamic) onPrivateStopTyping,
    required Function(dynamic) onGroupTyping,
    required Function(dynamic) onGroupStopTyping,
  }) {
    _chatListPrivateTyping = onPrivateTyping;
    _chatListPrivateStopTyping = onPrivateStopTyping;
    _chatListGroupTyping = onGroupTyping;
    _chatListGroupStopTyping = onGroupStopTyping;
    _registerChatListPrivateTyping(_privateChatListSocket);
    _registerChatListGroupTyping(_socket);
  }

  /// Called on every (re)connect of the chat-list socket.
  void listenChatListReconnect(void Function() callback) {
    _chatListReconnectCallback = callback;
  }

  void _registerChatListPrivateTyping(IO.Socket? s) {
    if (s == null || _chatListPrivateTyping == null) return;
    if (_listPrivateTypingHandler != null) {
      s.off("typing", _listPrivateTypingHandler);
    }
    if (_listPrivateStopTypingHandler != null) {
      s.off("stop_typing", _listPrivateStopTypingHandler);
    }
    _listPrivateTypingHandler = (data) => _chatListPrivateTyping?.call(data);
    _listPrivateStopTypingHandler =
        (data) => _chatListPrivateStopTyping?.call(data);
    s.on("typing", _listPrivateTypingHandler!);
    s.on("stop_typing", _listPrivateStopTypingHandler!);
  }

  void _registerChatListGroupTyping(IO.Socket? s) {
    if (s == null || _chatListGroupTyping == null) return;
    if (_listGroupTypingHandler != null) {
      s.off("group_typing", _listGroupTypingHandler);
    }
    if (_listGroupStopTypingHandler != null) {
      s.off("group_stop_typing", _listGroupStopTypingHandler);
    }
    _listGroupTypingHandler = (data) {
      if (_isRepeatedTyping('list', true, data)) return;
      _chatListGroupTyping?.call(data);
    };
    _listGroupStopTypingHandler = (data) {
      if (_isRepeatedTyping('list', false, data)) return;
      _chatListGroupStopTyping?.call(data);
    };
    s.on("group_typing", _listGroupTypingHandler!);
    s.on("group_stop_typing", _listGroupStopTypingHandler!);
  }

  static const List<String> _attendanceEvents = [
    "attendance:created",
    "attendance:updated",
    "attendance:my_vote",
    "attendance:edited",
    "attendance:closed",
    "attendance:deleted",
  ];
  EventHandler<dynamic>? _attendanceReconnectHandler;
  int _attendanceListenerToken = 0;

  /// Group-room attendance events. [onReconnect] runs on every (re)connect so
  /// the caller can `attendance:sync` the polls it is showing.
  /// Returns a token for [stopListeningAttendanceEvents], so a closing chat
  /// can't remove listeners a newly opened chat already registered.
  int? listenAttendanceEvents({
    required void Function(String event, dynamic data) onEvent,
    void Function()? onReconnect,
  }) {
    final s = _socket;
    if (s == null) {
      log("listenAttendanceEvents skipped: _socket is null");
      return null;
    }
    _removeAttendanceListeners();
    final token = ++_attendanceListenerToken;
    for (final event in _attendanceEvents) {
      s.on(event, (data) {
        log("RECEIVED $event => $data");
        onEvent(event, data);
      });
    }
    if (onReconnect != null) {
      _attendanceReconnectHandler = (_) => onReconnect();
      s.on("connect", _attendanceReconnectHandler!);
    }
    return token;
  }

  void stopListeningAttendanceEvents(int? token) {
    if (token == null || token != _attendanceListenerToken) return;
    _removeAttendanceListeners();
  }

  void _removeAttendanceListeners() {
    for (final event in _attendanceEvents) {
      _socket?.off(event);
    }
    if (_attendanceReconnectHandler != null) {
      _socket?.off("connect", _attendanceReconnectHandler);
      _attendanceReconnectHandler = null;
    }
  }

  /// Joins the admin detail room for live `attendance:vote_changed` events.
  /// If the socket isn't connected yet, the connect handler sends the
  /// subscribe once it is (and again after every reconnect).
  void subscribeAttendance(
    int pollId,
    void Function(dynamic data) onVoteChanged,
  ) {
    _subscribedPollId = pollId;
    final s = _socket;
    if (s == null) return;
    s.off("attendance:vote_changed");
    s.on("attendance:vote_changed", (data) {
      log("RECEIVED attendance:vote_changed => $data");
      onVoteChanged(data);
    });
    if (isSocketConnected) _emitAttendanceSubscribe(pollId);
  }

  void _emitAttendanceSubscribe(int pollId) {
    _socket?.emitWithAck(
      "attendance:subscribe",
      {"pollId": pollId},
      ack: (data) => rtLog(
        "[RT_DEBUG] attendance:subscribe poll=$pollId ack => $data",
      ),
    );
  }

  void unsubscribeAttendance(int pollId) {
    // A newer screen may already have subscribed to another poll.
    if (_subscribedPollId != pollId) return;
    _subscribedPollId = null;
    _socket?.off("attendance:vote_changed");
    if (isSocketConnected) {
      _socket!.emit("attendance:unsubscribe", {"pollId": pollId});
    }
  }

  /// Fetches the latest summaries for [pollIds] (reconnect recovery).
  void syncAttendance(
    List<int> pollIds,
    void Function(List<dynamic> polls) onPolls,
  ) {
    if (!isSocketConnected || pollIds.isEmpty) return;
    _socket!.emitWithAck(
      "attendance:sync",
      {"pollIds": pollIds},
      ack: (data) {
        if (data is Map && data["polls"] is List) {
          onPolls(data["polls"] as List);
        }
      },
    );
  }

  Future<void> initPrivateChat(
    String socketUrl, {
    required String userId,
    required String receiverId,
    Function(dynamic)? onJoined,
  }) async {
    _activePrivateUserId = userId;
    _activePrivateReceiverId = receiverId;

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
      "${debugSocketUrlOverride ?? socketUrl}/privateChat",
      {
        "transports": ["websocket"],
        "autoConnect": true,
        // Re-read on every (re)connect: current token, never a stale one.
        "auth": (Function cb) => cb({
              "userId": userId,
              "token": Global.storageServices.getaccesstoken() ?? "",
            }),
      },
    );
    _registerGroupStatus(_privateChatSocket);
    _registerBlockStatus(_privateChatSocket);
    _registerEditListener(_privateChatSocket);

    _privateChatSocket?.onConnect((_) {
      log("PRIVATE CHAT SOCKET CONNECTED");
      log("NAMESPACE => /privateChat");

      _privateJoinDebugTimer?.cancel();

      final activeUser = _activePrivateUserId;
      final activeReceiver = _activePrivateReceiverId;
      // No private chat open (it was left): nothing to re-join.
      if (activeUser == null || activeReceiver == null) return;

      joinPrivateChat(
        userId: activeUser,
        receiverId: activeReceiver,
      );

      _flushPendingPrivateMessages();

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
        _flushPendingPrivateMessages();
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
      _onTokenRejected(_privateChatSocket, error);
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

  final List<Map<String, dynamic>> _pendingPrivateMessages = [];

  void _flushPendingPrivateMessages() {
    if (!isPrivateChatSocketConnected) return;
    while (_pendingPrivateMessages.isNotEmpty) {
      final payload = _pendingPrivateMessages.removeAt(0);
      try {
        final receiverId = payload["receiverId"]?.toString();
        log("FLUSHING QUEUED PRIVATE MESSAGE => $payload");
        _privateChatSocket!.emitWithAck(
          "send_message",
          payload,
          ack: (res) => _onSendAck(res, receiverId: receiverId),
        );
      } catch (e) {
        log("Error flushing pending private message: $e");
      }
    }
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
    String? clientMessageId,
  }) {
    final senderId = Global.storageServices.get(PrefConst.userId).toString();
    final effectiveClientMsgId =
        clientMessageId ?? 'c_${DateTime.now().microsecondsSinceEpoch}';

    final payload = <String, dynamic>{
      "senderId": senderId,
      "receiverId": receiverId,
      "messageType": messageType,
      "content": content,
      "clientMessageId": effectiveClientMsgId,
      if (images != null && images.isNotEmpty) "images": images,
      if (videos != null && videos.isNotEmpty) "videos": videos,
      if (caption != null) "caption": caption,
      if (replyId != null) "replyId": replyId,
      if (replyMessage != null) "replyMessage": replyMessage,
      if (replyType != null) "replyType": replyType,
      if (replySender != null) "replySender": replySender,
    };

    if (!isPrivateChatSocketConnected) {
      log("PRIVATE SOCKET NOT CONNECTED => QUEUEING MESSAGE TO SEND ON CONNECT");
      _pendingPrivateMessages.add(payload);
      _privateChatSocket?.connect();
      return;
    }

    _privateChatSocket!.emitWithAck(
      "send_message",
      payload,
      ack: (res) => _onSendAck(res, receiverId: receiverId),
    );
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
      rtSocketRaw("private", data); // TODO(rt-diagnostics)

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

      // Strictly reject group messages in 1-on-1 private chat
      final hasGroupId = inner["groupId"] != null ||
          inner["group_id"] != null ||
          dataMap["groupId"] != null ||
          dataMap["group_id"] != null ||
          inner["chatType"]?.toString().toLowerCase() == "group" ||
          dataMap["chatType"]?.toString().toLowerCase() == "group";

      if (hasGroupId) {
        log("MESSAGE IGNORED IN PRIVATE CHAT => IS A GROUP MESSAGE");
        return;
      }

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

      final eventChatId = (inner["chatId"] ??
              inner["chat_id"] ??
              dataMap["chatId"] ??
              dataMap["chat_id"])
          ?.toString();
      final currentChatId = _privateChatId;

      final isSameChat = (currentChatId != null &&
              eventChatId != null &&
              currentChatId == eventChatId) ||
          (dataSenderId == senderId &&
              (dataReceiverId == null || dataReceiverId == receiverId)) ||
          (dataSenderId == receiverId &&
              (dataReceiverId == null || dataReceiverId == senderId));

      log("EXPECTED SENDER => $senderId");
      log("EXPECTED RECEIVER => $receiverId");
      log("ACTUAL SENDER => $dataSenderId");
      log("ACTUAL RECEIVER => $dataReceiverId");
      log("IS SAME CHAT => $isSameChat");

      if (!isSameChat) {
        log("MESSAGE IGNORED => DIFFERENT CHAT");
        rtDecision("private listener", data,
            "SKIPPED: different chat (sender=$dataSenderId receiver=$dataReceiverId expected=$senderId/$receiverId)"); // TODO(rt-diagnostics)
        return;
      }

      log("MESSAGE ACCEPTED => CALLING CONTROLLER CALLBACK");
      rtDecision("private listener", data, "ACCEPTED"); // TODO(rt-diagnostics)

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
      "${debugSocketUrlOverride ?? socketUrl}/privateChat",
      {
        "transports": ["websocket"],
        "autoConnect": true,
        // Re-read on every (re)connect: current token, never a stale one.
        "auth": (Function cb) => cb({
              "userId": userId,
              "token": Global.storageServices.getaccesstoken() ?? "",
            }),
      },
    );
    _registerGroupStatus(_privateChatListSocket);
    _registerBlockStatus(_privateChatListSocket);

    _privateChatListSocket?.onAny((event, data) {
      if (event.contains("chat_list") || event == "conversation_updated") {
        rtLog("[RT_DEBUG] /privateChat <= $event");
      }
      if (event.contains("chat_list") ||
          event == "conversation_updated" ||
          event == "private_chat_updated") {
        _publishTouchedChats(data);
      }
    });

    _registerChatListPrivateTyping(_privateChatListSocket);

    _privateChatListSocket?.on(
      "archived_private_chats",
      (data) {
        _archivedPrivateChatsCallback?.call(data);
      },
    );

    _privateChatListSocket?.onConnectError(
      (error) => _onTokenRejected(_privateChatListSocket, error),
    );

    _privateChatListSocket?.onConnect((_) {
      _registerChatListListeners(_privateChatListSocket);
      _registerFullChatListListeners(_privateChatListSocket);
      _registerListRemovalListeners(_privateChatListSocket);
      _registerListGroupLifecycleListeners(_privateChatListSocket);
      _registerChatListPrivateTyping(_privateChatListSocket);

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

      // Anything missed while disconnected is refetched from the API.
      _chatListReconnectCallback?.call();
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
    // Register even while a socket is still connecting: listeners attach to
    // the socket object and fire once it connects. The /chat socket is also
    // registered when it is created later (see init).
    _registerChatListListeners(_privateChatListSocket);
    _registerChatListListeners(_socket);
  }

  void _registerChatListListeners(IO.Socket? s) {
    if (s == null || _privateChatListUpdatedCallback == null) return;
    final events = [
      "chat_list_updated",
      "common_chat_list_updated",
      "unified_chat_list_updated",
      "private_chat_list_updated",
      "group_chat_list_updated",
      "conversation_updated",
      "group_chat_updated",
      "update_group_chat_list",
      "receive_message",
      "receive_private_message",
      "receive_group_message",
      "new_message",
      "message_forwarded",
      "receive_forward_message",
    ];
    for (final ev in events) {
      s.off(ev);
      s.on(ev, (data) {
        // A group's newest message from someone else reached this phone.
        _deliverFromListPayload(data);
        _privateChatListUpdatedCallback?.call(data);
      });
    }
  }

  void listenFullChatList({
    required Function(dynamic) callback,
  }) {
    _unifiedFullChatListCallback = callback;
    _registerFullChatListListeners(_privateChatListSocket);
    _registerFullChatListListeners(_socket);
  }

  void _registerFullChatListListeners(IO.Socket? s) {
    if (s == null || _unifiedFullChatListCallback == null) return;
    s.off("chat_list");
    s.off("common_chat_list");
    s.off("unified_chat_list");
    s.on("chat_list", (data) => _unifiedFullChatListCallback?.call(data));
    s.on(
        "common_chat_list", (data) => _unifiedFullChatListCallback?.call(data));
    s.on("unified_chat_list",
        (data) => _unifiedFullChatListCallback?.call(data));
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
    if (_activePrivateReceiverId == receiverId) {
      _activePrivateUserId = null;
      _activePrivateReceiverId = null;
    }
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
    _privateChatSocket?.off("message_edited");
    _privateChatSocket?.off("editMessage");
    _privateChatSocket?.off("edit_message");
    _privateChatSocket?.off("message_update");
    _privateChatSocket?.off("messageUpdated");
    _privateChatSocket?.off("update_message");
    _privateChatSocket?.off("updateMessage");
    _privateChatSocket?.off("message_deleted");
    _privateChatSocket?.off("message_pinned");
    _privateChatSocket?.off("message_unpinned");
    _privateMessageHandler = null;
    _privateChatId = null;
    _privateJoinDebugTimer?.cancel();
  }

  void connectPrivateChat() {
    _privateChatSocket?.connect();
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

    if (_socket != null) {
      if (_listGroupTypingHandler != null) {
        _socket!.off("group_typing", _listGroupTypingHandler);
      }
      if (_listGroupStopTypingHandler != null) {
        _socket!.off("group_stop_typing", _listGroupStopTypingHandler);
      }
      if (_listGroupUpdatedHandler != null) {
        _socket!.off("group_updated", _listGroupUpdatedHandler);
        _socket!.off("group_info_updated", _listGroupUpdatedHandler);
      }
      if (_listGroupExitHandler != null) {
        for (final ev in const [
          "user_removed_from_group",
          "group_left",
          "member_removed",
          "group_chat_removed",
          "group_removed",
        ]) {
          _socket!.off(ev, _listGroupExitHandler);
        }
      }
      if (_listChatRemovedHandler != null) {
        for (final ev in const [
          "private_chat_removed",
          "chat_removed",
          "group_chat_removed",
        ]) {
          _socket!.off(ev, _listChatRemovedHandler);
        }
      }
      if (_listChatClearedHandler != null) {
        for (final ev in const [
          "private_chat_cleared",
          "chat_cleared",
          "group_chat_cleared",
        ]) {
          _socket!.off(ev, _listChatClearedHandler);
        }
      }
    }
    _chatListPrivateTyping = null;
    _chatListPrivateStopTyping = null;
    _chatListGroupTyping = null;
    _chatListGroupStopTyping = null;
    _listPrivateTypingHandler = null;
    _listPrivateStopTypingHandler = null;
    _listGroupTypingHandler = null;
    _listGroupStopTypingHandler = null;
    _listGroupUpdatedHandler = null;
    _listGroupExitHandler = null;
    _listChatRemovedHandler = null;
    _listChatClearedHandler = null;
    _chatListReconnectCallback = null;
  }

  void Function(dynamic data)? _messageEditedCallback;

  void _registerEditListener(IO.Socket? s) {
    if (s == null || _messageEditedCallback == null) return;
    for (final ev in const [
      "messageEdited",
      "message_edited",
      "editMessage",
      "edit_message",
      "message_update",
      "messageUpdated",
      "update_message",
      "updateMessage",
    ]) {
      s.off(ev);
      s.on(ev, (data) {
        AppLog.d("SOCKET EDIT EVENT RECEIVED ($ev) => $data");
        _messageEditedCallback?.call(data);
      });
    }
  }

  void editMessage({
    required int messageId,
    required String content,
    required String userId,
    String? otherUserId,
    dynamic groupId,
    dynamic chatId,
    String? caption,
    String? messageType,
    String? mediaUrl,
  }) {
    final effectiveChatId = chatId ?? (groupId ?? _privateChatId);
    final payload = {
      "messageId": messageId,
      "id": messageId,
      "content": content,
      "caption": caption ?? content,
      "text": caption ?? content,
      "newContent": caption ?? content,
      "body": caption ?? content,
      "message": caption ?? content,
      "userId": userId,
      "isEdited": true,
      "is_edited": true,
      "edited": true,
      if (mediaUrl != null && mediaUrl.isNotEmpty) ...{
        "mediaUrl": mediaUrl,
        "fileUrl": mediaUrl,
      },
      if (messageType != null) ...{
        "messageType": messageType,
        "type": messageType,
      },
      if (otherUserId != null) ...{
        "otherUserId": otherUserId,
        "receiverId": otherUserId,
        "targetId": otherUserId,
      },
      if (groupId != null) ...{
        "groupId": groupId,
        "group_id": groupId,
      },
      if (effectiveChatId != null) ...{
        "chatId": effectiveChatId,
        "conversationId": effectiveChatId,
      },
      "chatType": otherUserId != null ? "private" : "group",
    };

    AppLog.d("========== SOCKET EDIT MESSAGE EMIT ==========");
    AppLog.d("EVENT: editMessage / edit_message");
    AppLog.d("PAYLOAD: $payload");

    if (otherUserId != null && isPrivateChatSocketConnected) {
      AppLog.d("EMITTING editMessage ON PRIVATE CHAT SOCKET");
      try {
        _privateChatSocket!.emit(
          "editMessage",
          payload,
        );
        _privateChatSocket!.emit(
          "edit_message",
          payload,
        );
      } catch (e) {
        AppLog.d("Private chat socket emit error: $e");
      }
    }

    if (_socket != null && _socket!.connected) {
      AppLog.d("EMITTING editMessage ON GROUP/MAIN SOCKET");
      try {
        _socket!.emit(
          "editMessage",
          payload,
        );
        _socket!.emit(
          "edit_message",
          payload,
        );
      } catch (e) {
        AppLog.d("Main socket emit error: $e");
      }
    }
  }

  // ==========================================
  // WHATSAPP PARITY: MESSAGE REACTIONS
  // ==========================================
  void sendReaction({
    required int messageId,
    required String emoji,
    required String userId,
    String? chatType,
    dynamic chatId,
    String? otherUserId,
    Function(dynamic)? ack,
  }) {
    final payload = {
      "messageId": messageId,
      "emoji": emoji,
      "userId": userId,
      "chatType": chatType ?? (otherUserId != null ? "private" : "group"),
      if (chatId != null) "chatId": chatId,
      if (chatId != null && chatType == "group") "groupId": chatId,
      if (otherUserId != null) "otherUserId": otherUserId,
    };

    if (chatType == "private" || otherUserId != null) {
      if (isPrivateChatSocketConnected) {
        try {
          _privateChatSocket?.emitWithAck("send_message_reaction", payload,
              ack: (res) {
            ack?.call(res);
          });
        } catch (_) {
          _privateChatSocket?.emit("send_message_reaction", payload);
        }
        return;
      }
    }

    if (isSocketConnected) {
      try {
        socket.emitWithAck("send_message_reaction", payload, ack: (res) {
          ack?.call(res);
        });
      } catch (_) {
        socket.emit("send_message_reaction", payload);
      }
    }
  }

  void listenMessageReactionUpdated({
    required Function(Map<String, dynamic>) callback,
    ChatSocketScope scope = ChatSocketScope.private,
  }) {
    final s = scope == ChatSocketScope.private ? _privateChatSocket : _socket;
    if (s == null) return;
    s.off("message_reaction_updated");
    s.on("message_reaction_updated", (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void stopListeningMessageReactionUpdated({
    ChatSocketScope scope = ChatSocketScope.private,
  }) {
    final s = scope == ChatSocketScope.private ? _privateChatSocket : _socket;
    s?.off("message_reaction_updated");
  }

  /// Server ack for `send_message` (backend v2.3.0, item #9):
  /// `{status, ok, code, message}`. A rejected send (BLOCKED, INVALID_DATA,
  /// SEND_FAILED) used to fail silently; now the user is told. Success needs
  /// nothing here: the message still arrives via the normal receive event
  /// (deduped by id). Older servers never call the ack: nothing happens.
  ///
  /// A private send rejected with `BLOCKED` means [receiverId] has blocked
  /// me: it is published on [blockStatusEvents] so the open chat swaps the
  /// input bar for the "blocked" banner right away (not only after reopening).
  void _onSendAck(dynamic res, {String? receiverId}) {
    final data = res is List && res.isNotEmpty ? res.first : res;
    if (data is! Map) return;
    final ok = data['ok'] ?? data['status'];
    if (ok != false) return;
    final code = data['code']?.toString() ?? '';
    final me = Global.storageServices.get(PrefConst.userId)?.toString();
    if (code == 'BLOCKED' &&
        receiverId != null &&
        receiverId.isNotEmpty &&
        me != null &&
        me.isNotEmpty) {
      _blockStatusController.add(BlockStatusEvent(
        blockerId: receiverId,
        blockedId: me,
        isBlocked: true,
      ));
    }
    final serverText =
        data['message'] is String ? data['message'] as String : '';
    final text = serverText.trim().isNotEmpty
        ? serverText.trim()
        : (code == 'BLOCKED'
            ? appL10n.chat_cantMessageUser
            : appL10n.chat_messageNotSent);
    log("SEND REJECTED => code=$code message=$text");
    Utils().fluttertoast(text);
  }

  /// Last time each socket was retried after a TOKEN_EXPIRED rejection.
  final Map<IO.Socket, DateTime> _tokenRetryAt = {};

  /// Backend v2.3.0 re-checks the JWT on every reconnect and rejects an
  /// expired one with connect_error "TOKEN_EXPIRED" (401); socket.io then
  /// stops reconnecting. Retry once (at most every 60 s): the `auth`
  /// callback sends the token stored NOW, so a renewed token reconnects
  /// without restarting the app.
  ///
  /// Backend v2.8.0: no refresh endpoint (single 90-day token). First
  /// rejection: retry once (a token renewed by a fresh login reconnects).
  /// Rejected again within 60 s: the session is over -> the same logout the
  /// HTTP 401 handler uses (handleForceLogout has its own guards: no session,
  /// already on login/OTP, new-login grace period).
  void _onTokenRejected(IO.Socket? socket, dynamic error) {
    if (socket == null) return;
    final text = error is Map
        ? '${error['message']} ${error['data']?['message']} ${error['code']}'
        : error.toString();
    if (!text.contains('TOKEN_EXPIRED')) return;

    final last = _tokenRetryAt[socket];
    if (last != null && DateTime.now().difference(last).inSeconds < 60) {
      log("SOCKET TOKEN_EXPIRED again => session expired, logging out");
      _tokenRetryAt.clear();
      LogoutUser().handleForceLogout(
        message: "Your session has expired. Please log in again.",
      );
      return;
    }
    _tokenRetryAt[socket] = DateTime.now();

    log("SOCKET TOKEN_EXPIRED => retrying once with the current stored token");
    Future.delayed(const Duration(seconds: 3), () {
      if (!socket.connected) socket.connect();
    });
  }

  /// Sockets a chat screen listens on. Private screens use /privateChat,
  /// group screens use /chat. `null` keeps the old "both" behaviour.
  ///
  /// Registering on both made the last opened screen steal the other one's
  /// edit/delete/pin events (e.g. private chat -> group -> back).
  List<IO.Socket> _socketsFor(ChatSocketScope? scope) => [
        if (scope != ChatSocketScope.private && _socket != null) _socket!,
        if (scope != ChatSocketScope.group && _privateChatSocket != null)
          _privateChatSocket!,
      ];

  void _listenScoped(
    String event,
    ChatSocketScope? scope,
    void Function(dynamic data) handler,
  ) {
    for (final s in _socketsFor(scope)) {
      s.off(event);
      s.on(event, handler);
    }
  }

  /// Group screen that currently owns the /chat chat-screen listeners.
  Object? _groupChatOwner;

  /// Called by a group chat screen before it registers its listeners.
  void claimGroupChatEvents(Object owner) => _groupChatOwner = owner;

  /// Removes the group chat-screen listeners, but only if [owner] still
  /// owns them: a newer group screen may already have registered its own
  /// (its onInit runs before the old screen's onClose).
  void releaseGroupChatEvents(Object owner) {
    if (!identical(_groupChatOwner, owner)) return;
    _groupChatOwner = null;
    // Message events: remove only this screen's handler. The app-level
    // "delivered", receipt and ChatListController listeners stay intact.
    final receive = _groupScreenReceiveHandler;
    if (receive != null) {
      for (final event in _groupReceiveEvents) {
        _socket?.off(event, receive);
      }
      _groupScreenReceiveHandler = null;
    }
    if (_groupScreenUpdatedHandler != null) {
      for (final s in <IO.Socket?>[_socket, _privateChatSocket]) {
        s?.off("group_updated", _groupScreenUpdatedHandler);
        s?.off("group_info_updated", _groupScreenUpdatedHandler);
      }
      _groupScreenUpdatedHandler = null;
    }
    if (_groupScreenClearedHandler != null) {
      _socket?.off("group_chat_cleared", _groupScreenClearedHandler);
      _groupScreenClearedHandler = null;
    }
    if (_groupScreenMemberRemovedHandler != null) {
      for (final event in const [
        "member_removed",
        "member_left",
        "user_removed_from_group",
        "group_left",
      ]) {
        _socket?.off(event, _groupScreenMemberRemovedHandler);
      }
      _groupScreenMemberRemovedHandler = null;
    }
    for (final event in const [
      "messageEdited",
      "message_edited",
      "editMessage",
      "edit_message",
      "message_update",
      "messageUpdated",
      "update_message",
      "updateMessage",
      "message_deleted",
      "message_pinned",
      "message_unpinned",
      "message_sent",
      "group_message_sent",
    ]) {
      _socket?.off(event);
    }
  }

  /// Private chat screen that currently owns the /privateChat listeners.
  Object? _privateChatOwner;

  void claimPrivateChatEvents(Object owner) => _privateChatOwner = owner;

  /// [clearPrivateChatListeners] only if [owner] still owns the listeners.
  void releasePrivateChatEvents(Object owner) {
    if (!identical(_privateChatOwner, owner)) return;
    _privateChatOwner = null;
    clearPrivateChatListeners();
  }

  void listenMessageEdited({
    required Function(dynamic data) callback,
    ChatSocketScope? scope,
  }) {
    _messageEditedCallback = callback;
    final socketsToListen = <IO.Socket>{
      if (_socket != null) _socket!,
      if (_privateChatSocket != null) _privateChatSocket!,
      if (_privateChatListSocket != null) _privateChatListSocket!,
    };
    for (final s in socketsToListen) {
      _registerEditListener(s);
    }
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

    AppLog.d("========== SOCKET DELETE EMIT ==========");
    AppLog.d("EVENT: delete_message");
    AppLog.d("PAYLOAD: $payload");
    AppLog.d("GROUP SOCKET CONNECTED: ${_socket?.connected}");
    AppLog.d("PRIVATE SOCKET CONNECTED: ${_privateChatSocket?.connected}");

    if (otherUserId != null && isPrivateChatSocketConnected) {
      AppLog.d("EMITTING ON PRIVATE CHAT SOCKET");
      _privateChatSocket!.emit("delete_message", payload);
      return;
    }

    AppLog.d("EMITTING ON CHAT SOCKET");
    _socket?.emit("delete_message", payload);
  }

  void listenMessageDeleted({
    required Function(dynamic data) callback,
    ChatSocketScope? scope,
  }) {
    _listenScoped("message_deleted", scope, (data) {
      AppLog.d("message_deleted => $data");
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
    ChatSocketScope? scope,
  }) {
    // Non-map payloads used to throw inside the socket callback.
    _listenScoped("message_pinned", scope, (data) {
      if (data is Map) callback(Map<String, dynamic>.from(data));
    });
  }

  void listenUnpinMessage({
    required Function(Map<String, dynamic>) callback,
    ChatSocketScope? scope,
  }) {
    _listenScoped("message_unpinned", scope, (data) {
      if (data is Map) callback(Map<String, dynamic>.from(data));
    });
  }

  /// Listens for WhatsApp 3-tick server confirmation (single grey tick ✓).
  /// Emitted when server successfully saves the message to DB.
  void listenMessageSent({
    required Function(Map<String, dynamic>) callback,
    ChatSocketScope? scope,
  }) {
    void handler(dynamic data) {
      if (data is Map) callback(Map<String, dynamic>.from(data));
    }

    _listenScoped("message_sent", scope, handler);
    _listenScoped("group_message_sent", scope, handler);
  }

  // Group read / delivered receipts: see [groupReceipts] (one app-level
  // listener per socket, registered in init). The old per-screen
  // listenGroupMessageSeen / listenGroupMessagesDelivered / listenSeenUpdate
  // replaced each other's handlers with off(event) and were removed.

  EventHandler<dynamic>? _groupScreenUpdatedHandler;
  EventHandler<dynamic>? _listGroupUpdatedHandler;

  void _registerListGroupUpdated(IO.Socket? s) {
    if (s == null || _listGroupUpdatedHandler == null) return;
    s.off("group_updated", _listGroupUpdatedHandler);
    s.on("group_updated", _listGroupUpdatedHandler!);
    s.off("group_info_updated", _listGroupUpdatedHandler);
    s.on("group_info_updated", _listGroupUpdatedHandler!);
  }

  /// Listens for real-time group info updates (groupName, groupProfile, groupDesc).
  /// Set [forChatList] = true from [ChatListController] so closing a group chat screen
  /// never detaches the chat list listener.
  void listenGroupUpdated({
    required Function(Map<String, dynamic>) callback,
    bool forChatList = false,
  }) {
    if (forChatList) {
      if (_listGroupUpdatedHandler != null) {
        for (final s in <IO.Socket?>[_socket, _privateChatSocket, _privateChatListSocket]) {
          s?.off("group_updated", _listGroupUpdatedHandler);
          s?.off("group_info_updated", _listGroupUpdatedHandler);
        }
      }
      _listGroupUpdatedHandler = (dynamic data) {
        if (data is Map) callback(Map<String, dynamic>.from(data));
      };
      _registerListGroupUpdated(_socket);
      _registerListGroupUpdated(_privateChatSocket);
      _registerListGroupUpdated(_privateChatListSocket);
      return;
    }

    if (_groupScreenUpdatedHandler != null) {
      _socket?.off("group_updated", _groupScreenUpdatedHandler);
      _socket?.off("group_info_updated", _groupScreenUpdatedHandler);
      _privateChatSocket?.off("group_updated", _groupScreenUpdatedHandler);
    }
    _groupScreenUpdatedHandler = (dynamic data) {
      if (data is Map) callback(Map<String, dynamic>.from(data));
    };

    _socket?.on("group_updated", _groupScreenUpdatedHandler!);
    _socket?.on("group_info_updated", _groupScreenUpdatedHandler!);
    _privateChatSocket?.on("group_updated", _groupScreenUpdatedHandler!);
  }

  /// Backend v2.5.0: groups deactivated / reactivated by the admin.
  /// groupId -> true when deactivated. Filled by `group_status_updated` on
  /// every chat socket; the chat list and the open group chat read it.
  final RxMap<String, bool> groupDeactivated = <String, bool>{}.obs;

  void _onGroupStatusUpdated(dynamic data) {
    if (data is! Map) return;
    final id = (data['groupId'] ?? data['group_id'] ?? data['id'])?.toString();
    if (id == null || id.isEmpty || id == 'null') return;
    final status = data['groupStatus']?.toString().toLowerCase();
    final deactivated = data['isDeactivated'] == true ||
        status == 'deactivated' ||
        (data['isDeactivated'] == null &&
            status == null &&
            (data['isActive'] == false || data['isActive']?.toString() == '0'));
    groupDeactivated[id] = deactivated;
  }

  /// Registered on each socket right after it is created; socket.io keeps
  /// the handler across reconnects. off(handler) first = never doubled.
  void _registerGroupStatus(IO.Socket? s) {
    if (s == null) return;
    s.off("group_status_updated", _onGroupStatusUpdated);
    s.on("group_status_updated", _onGroupStatusUpdated);
  }

  // ---- Block / unblock in real time ----

  final StreamController<BlockStatusEvent> _blockStatusController =
      StreamController<BlockStatusEvent>.broadcast();

  /// Block / unblock changes for private chats, from the backend block
  /// events (any socket) or a `BLOCKED` send ack. The same change may arrive
  /// more than once (several sockets); applying it is idempotent.
  Stream<BlockStatusEvent> get blockStatusEvents =>
      _blockStatusController.stream;

  /// Event names the backend may use for a block change (open item #25 in
  /// docs/01_CHATTING_MODULE_FRONTEND.md asks for `user_blocked` /
  /// `user_unblocked`); the others are accepted so either naming works.
  static const List<String> _blockEventNames = [
    "user_blocked",
    "user_unblocked",
    "block_status_changed",
    "block_status_updated",
    "blockStatusChanged",
  ];

  late final Map<String, void Function(dynamic)> _blockHandlers = {
    for (final e in _blockEventNames) e: (dynamic d) => _onBlockEvent(e, d),
  };

  /// App-level, once per socket (like group status): the change may be
  /// pushed to the user's room on any namespace.
  void _registerBlockStatus(IO.Socket? s) {
    if (s == null) return;
    _blockHandlers.forEach((event, handler) {
      s.off(event, handler);
      s.on(event, handler);
    });
  }

  final StreamController<String> _chatTouchedController =
      StreamController<String>.broadcast();

  /// Private chat ids named in a chat-list event (`chat_list_updated`,
  /// `conversation_updated`, `private_chat_updated`). The server may send
  /// one after a block / unblock (with `isBlocked`); the open chat then
  /// re-reads its `blockStatus` instead of waiting for the periodic check.
  Stream<String> get privateChatTouched => _chatTouchedController.stream;

  void _publishTouchedChats(dynamic data) {
    final ids = <String>{};
    void scan(dynamic v, int depth) {
      if (depth > 3 || v == null) return;
      if (v is List) {
        for (final e in v.take(100)) {
          scan(e, depth + 1);
        }
        return;
      }
      if (v is! Map) return;
      for (final k in const [
        'chatId',
        'chat_id',
        'conversationId',
        'conversation_id',
      ]) {
        final id = v[k]?.toString().trim();
        if (id != null && id.isNotEmpty && id != 'null') ids.add(id);
      }
      for (final k in const ['chat', 'data', 'chats', 'conversation']) {
        if (v[k] is Map || v[k] is List) scan(v[k], depth + 1);
      }
    }

    try {
      scan(data, 0);
    } catch (_) {}
    for (final id in ids) {
      _chatTouchedController.add(id);
    }
  }

  // ---- Group member left / removed (any group, app level) ----

  final StreamController<int> _groupMemberChangesController =
      StreamController<int>.broadcast();

  /// Group id of every `member_left` / `member_removed` / `group_left` /
  /// `user_removed_from_group` on `/chat`. The open group chat uses it to
  /// fetch the "X left" system message from the server when it isn't
  /// pushed live (seen for archived groups).
  Stream<int> get groupMemberChanges => _groupMemberChangesController.stream;

  static const Set<String> _groupMemberChangeEvents = {
    "member_left",
    "member_removed",
    "group_left",
    "user_removed_from_group",
  };

  void _onGroupMemberAny(String event, dynamic data) {
    if (!_groupMemberChangeEvents.contains(event)) return;
    final m = data is List && data.isNotEmpty ? data.first : data;
    if (m is! Map) return;
    final gid = int.tryParse(
        (m['groupId'] ?? m['group_id'] ?? m['chatId'])?.toString() ?? '');
    if (gid != null) _groupMemberChangesController.add(gid);
  }

  /// `onAny`, not `on(event)`: other code calls `off(event)` without a
  /// handler for these events (removes every handler); an any-listener is
  /// not affected, so this keeps working.
  void _registerGroupMemberChanges(IO.Socket? s) {
    if (s == null) return;
    s.offAny(_onGroupMemberAny);
    s.onAny(_onGroupMemberAny);
  }

  /// Payload: `{blockerId, blockedUserId, isBlocked?}` (aliases accepted).
  void _onBlockEvent(String event, dynamic raw) {
    final data = raw is List && raw.isNotEmpty ? raw.first : raw;
    if (data is! Map) return;
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = data[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString().trim();
        }
      }
      return null;
    }

    final blocker = pick(const [
      'blockerId',
      'blocker_id',
      'blockedBy',
      'blocked_by',
      'userId',
      'user_id',
    ]);
    final blocked = pick(const [
      'blockedUserId',
      'blocked_user_id',
      'blockedId',
      'blocked_id',
      'targetUserId',
      'target_user_id',
    ]);

    bool? isBlocked;
    if (event == 'user_blocked') {
      isBlocked = true;
    } else if (event == 'user_unblocked') {
      isBlocked = false;
    } else {
      final v = data['isBlocked'] ?? data['is_blocked'] ?? data['blocked'];
      final action = data['action']?.toString().toLowerCase();
      if (v is bool) {
        isBlocked = v;
      } else if (v != null) {
        final t = v.toString().toLowerCase();
        if (t == 'true' || t == '1') isBlocked = true;
        if (t == 'false' || t == '0') isBlocked = false;
      } else if (action == 'block' || action == 'blocked') {
        isBlocked = true;
      } else if (action == 'unblock' || action == 'unblocked') {
        isBlocked = false;
      }
    }

    log("BLOCK EVENT => $event blocker=$blocker blocked=$blocked isBlocked=$isBlocked");
    if (blocker == null || blocked == null || isBlocked == null) return;
    _blockStatusController.add(BlockStatusEvent(
      blockerId: blocker,
      blockedId: blocked,
      isBlocked: isBlocked,
    ));
  }

  /// A private chat was cleared (from the chat list, or on another device):
  /// drop its saved copy so reopening it does not show the old messages.
  /// Cache only; the chat list callback itself is unchanged.
  void _dropClearedPrivateChatCache(Map data) {
    final chatId = data['conversationId'] ??
        data['conversation_id'] ??
        data['chatId'] ??
        data['chat_id'];
    ChatMessageCache.clearPrivateByChatId(chatId);
  }

  EventHandler<dynamic>? _groupScreenClearedHandler;
  EventHandler<dynamic>? _groupScreenMemberRemovedHandler;
  EventHandler<dynamic>? _listGroupExitHandler;

  void _registerListGroupLifecycleListeners(IO.Socket? s) {
    _registerListGroupUpdated(s);
    if (s == null || _listGroupExitHandler == null) return;
    for (final ev in const [
      "user_removed_from_group",
      "group_left",
      "member_removed",
      "group_chat_removed",
      "group_removed",
    ]) {
      s.off(ev, _listGroupExitHandler);
      s.on(ev, _listGroupExitHandler!);
    }
  }

  /// Listens for group chat cleared event (clear chat history strictly for calling user).
  void listenGroupChatCleared({
    required Function(Map<String, dynamic>) callback,
  }) {
    if (_groupScreenClearedHandler != null) {
      _socket?.off("group_chat_cleared", _groupScreenClearedHandler);
    }
    _groupScreenClearedHandler = (dynamic data) {
      if (data is Map) callback(Map<String, dynamic>.from(data));
    };
    _socket?.on("group_chat_cleared", _groupScreenClearedHandler!);
  }

  /// Listens for member removed or member left events in group.
  void listenMemberRemoved({
    required Function(Map<String, dynamic>) callback,
  }) {
    if (_groupScreenMemberRemovedHandler != null) {
      for (final ev in const [
        "member_removed",
        "member_left",
        "user_removed_from_group",
        "group_left",
      ]) {
        _socket?.off(ev, _groupScreenMemberRemovedHandler);
      }
    }
    _groupScreenMemberRemovedHandler = (dynamic data) {
      if (data is Map) callback(Map<String, dynamic>.from(data));
    };

    _socket?.on("member_removed", _groupScreenMemberRemovedHandler!);
    _socket?.on("member_left", _groupScreenMemberRemovedHandler!);
    // Backend v2.8.0: sent to the removed / leaving user themself.
    _socket?.on("user_removed_from_group", _groupScreenMemberRemovedHandler!);
    _socket?.on("group_left", _groupScreenMemberRemovedHandler!);
  }

  void listenGroupExit({required Function(dynamic) callback}) {
    if (_listGroupExitHandler != null) {
      for (final ev in const [
        "user_removed_from_group",
        "group_left",
        "member_removed",
        "group_chat_removed",
        "group_removed",
      ]) {
        _privateChatListSocket?.off(ev, _listGroupExitHandler);
        _socket?.off(ev, _listGroupExitHandler);
      }
    }
    _listGroupExitHandler = (dynamic data) => callback(data);
    _registerListGroupLifecycleListeners(_privateChatListSocket);
    _registerListGroupLifecycleListeners(_socket);
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

  /// Returns false when the list socket is offline (nothing was sent).
  bool pinPrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return false;
    }

    final payload = {
      "userId": userId,
      "chatId": chatId,
    };

    _privateChatListSocket!.emit(
      "pin_private_chat",
      payload,
    );
    return true;
  }

  /// Returns false when the list socket is offline (nothing was sent).
  bool unpinPrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return false;
    }

    final payload = {
      "userId": userId,
      "chatId": chatId,
    };

    _privateChatListSocket!.emit(
      "unpin_private_chat",
      payload,
    );
    return true;
  }

  /// Returns false when the list socket is offline (nothing was sent).
  bool mutePrivateChat({
    required String userId,
    required String chatId,
    String? mutedUntil,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return false;
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
    return true;
  }

  /// Returns false when the list socket is offline (nothing was sent).
  bool unmutePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return false;
    }

    final payload = {
      "userId": userId,
      "chatId": chatId,
    };

    _privateChatListSocket!.emit(
      "unmute_private_chat",
      payload,
    );
    return true;
  }

  /// Returns false when the list socket is offline (nothing was sent).
  bool archivePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return false;
    }

    final payload = {
      "chatId": chatId,
      "userId": userId,
    };

    _privateChatListSocket!.emit(
      "archive_private_chat",
      payload,
    );
    return true;
  }

  /// Returns false when the list socket is offline (nothing was sent).
  bool unarchivePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return false;
    }

    final payload = {
      "chatId": chatId,
      "userId": userId,
    };

    _privateChatListSocket!.emit(
      "unarchive_private_chat",
      payload,
    );
    return true;
  }

  /// Returns false when the list socket is offline (nothing was sent).
  bool markPrivateChatRead({
    required String userId,
    required String chatId,
  }) {
    log("========== MARK PRIVATE CHAT READ DEBUG ==========");
    log("Socket Connected => $isPrivateChatListSocketConnected");
    log("User ID => $userId");
    log("Chat ID => $chatId");

    if (!isPrivateChatListSocketConnected) {
      log("MARK PRIVATE CHAT READ FAILED => SOCKET NOT CONNECTED");
      return false;
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
    return true;
  }

  /// Returns false when the list socket is offline (nothing was sent).
  bool deletePrivateChat({
    required String userId,
    required String chatId,
  }) {
    if (!isPrivateChatListSocketConnected) {
      return false;
    }

    final payload = {
      "chatId": int.tryParse(chatId) ?? chatId,
      "userId": int.tryParse(userId) ?? userId,
    };

    _privateChatListSocket!.emit(
      "delete_private_chat",
      payload,
    );
    return true;
  }

  Function(dynamic)? _privateChatRemovedCallback;
  EventHandler<dynamic>? _listChatRemovedHandler;
  EventHandler<dynamic>? _listChatClearedHandler;

  void _registerListRemovalListeners(IO.Socket? s) {
    if (s == null) return;
    if (_listChatRemovedHandler != null) {
      for (final ev in const [
        "private_chat_removed",
        "chat_removed",
        "group_chat_removed",
      ]) {
        s.off(ev, _listChatRemovedHandler);
        s.on(ev, _listChatRemovedHandler!);
      }
    }
    if (_listChatClearedHandler != null) {
      for (final ev in const [
        "private_chat_cleared",
        "chat_cleared",
        "group_chat_cleared",
      ]) {
        s.off(ev, _listChatClearedHandler);
        s.on(ev, _listChatClearedHandler!);
      }
    }
  }

  void listenPrivateChatRemoved({
    required Function(dynamic) callback,
  }) {
    _privateChatRemovedCallback = callback;
    if (_listChatRemovedHandler != null) {
      for (final ev in const [
        "private_chat_removed",
        "chat_removed",
        "group_chat_removed",
      ]) {
        _privateChatListSocket?.off(ev, _listChatRemovedHandler);
        _socket?.off(ev, _listChatRemovedHandler);
      }
    }
    _listChatRemovedHandler = (dynamic data) {
      _privateChatRemovedCallback?.call(data);
    };
    _registerListRemovalListeners(_privateChatListSocket);
    _registerListRemovalListeners(_socket);
  }

  void listenPrivateChatClearedOnListSocket({
    required Function(Map<String, dynamic>) callback,
  }) {
    _privateChatClearedListCallback = callback;
    if (_listChatClearedHandler != null) {
      for (final ev in const [
        "private_chat_cleared",
        "chat_cleared",
        "group_chat_cleared",
      ]) {
        _privateChatListSocket?.off(ev, _listChatClearedHandler);
        _socket?.off(ev, _listChatClearedHandler);
      }
    }
    _listChatClearedHandler = (dynamic data) {
      if (data is Map) {
        _dropClearedPrivateChatCache(data);
        _privateChatClearedListCallback?.call(
          Map<String, dynamic>.from(data),
        );
      }
    };
    _registerListRemovalListeners(_privateChatListSocket);
    _registerListRemovalListeners(_socket);
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
    // Next user starts with a clean receipt state.
    _deliveredEmitted.clear();
    _groupScreenReceiveHandler = null;
    try {
      disconnectPrivateChatSocket();
    } catch (_) {}
    try {
      disconnectPrivateChatListSocket();
    } catch (_) {}
  }
}
