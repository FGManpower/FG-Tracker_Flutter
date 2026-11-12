import 'dart:async';
import 'package:fgtracker/l10n/l10n.dart';

import 'package:fgtracker/app/Model/PrivateChatModel.dart';

/// Pure chat-list rules (identity, ordering, new-message detection, unread
/// policy, typing state). Kept free of GetX/sockets so they are unit tested
/// and shared by the main list and the Archived list.
class ChatListRules {
  ChatListRules._();

  static bool isGroup(PrivateChatModel c) =>
      c.isGroup == true || c.chatType == 'group' || c.groupId != null;

  /// Stable identity of a row: `group_<groupId>` or `private_<peerUserId>`.
  static String chatKey(PrivateChatModel c) {
    if (isGroup(c)) {
      return 'group_${c.groupId ?? c.id ?? c.chatId ?? c.conversationId ?? 0}';
    }
    return 'private_${c.userId ?? c.chatId ?? c.conversationId ?? c.id ?? 0}';
  }

  static DateTime parseTime(dynamic raw) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (raw == null) return epoch;
    if (raw is DateTime) return raw.toUtc();
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'undefined') return epoch;
    final numVal = int.tryParse(str);
    if (numVal != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        numVal > 10000000000 ? numVal : numVal * 1000,
        isUtc: true,
      );
    }
    return DateTime.tryParse(str)?.toUtc() ?? epoch;
  }

  /// Time of the last message, used for ordering.
  static DateTime lastMessageTime(PrivateChatModel c) {
    if (c.lastMessageData != null) {
      final msgTime = c.lastMessageData!['createdAt'] ??
          c.lastMessageData!['created_at'] ??
          c.lastMessageData!['timestamp'] ??
          c.lastMessageData!['time'];
      if (msgTime != null) {
        final parsed = parseTime(msgTime);
        if (parsed.millisecondsSinceEpoch > 0) return parsed;
      }
    }
    return parseTime(c.timestamp ?? c.time);
  }

  /// Id of the last message, when the payload carries one.
  static String? lastMessageId(PrivateChatModel c) {
    final data = c.lastMessageData;
    if (data == null) return null;
    for (final key in const ['messageId', 'message_id', 'id', '_id']) {
      final v = data[key]?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    return null;
  }

  /// Pinned first; then newest last message; then a stable key so equal
  /// timestamps never swap places between rebuilds.
  static int compare(PrivateChatModel a, PrivateChatModel b) {
    final aPinned = a.isPinned == true;
    final bPinned = b.isPinned == true;
    if (aPinned != bPinned) return aPinned ? -1 : 1;
    if (aPinned && bPinned) {
      final aPinTime = parseTime(a.pinnedAt);
      final bPinTime = parseTime(b.pinnedAt);
      final byPin = bPinTime.compareTo(aPinTime);
      if (byPin != 0) return byPin;
    }
    final byTime = lastMessageTime(b).compareTo(lastMessageTime(a));
    if (byTime != 0) return byTime;
    return chatKey(a).compareTo(chatKey(b));
  }

  static List<PrivateChatModel> sort(Iterable<PrivateChatModel> chats) =>
      List<PrivateChatModel>.of(chats)..sort(compare);

  /// True only when [updated] carries a different, not-older last message
  /// than [current]. Read/seen/online/typing updates return false, so they
  /// never reorder the list.
  static bool isNewMessage(PrivateChatModel current, PrivateChatModel updated) {
    final hasMessage = (updated.message?.trim().isNotEmpty ?? false) ||
        (updated.preview?.trim().isNotEmpty ?? false);
    if (!hasMessage) return false;

    final updatedId = lastMessageId(updated);
    final currentId = lastMessageId(current);

    // Both IDs present: new only if it isn't OLDER than what we show.
    // Backend v2.3.0 answers "delete for me" with chat_list_updated whose
    // lastMessage is the PREVIOUS (older) message; treating any different id
    // as new bumped the unread badge and reordered the row for a delete.
    if (updatedId != null && currentId != null) {
      if (updatedId == currentId) return false;
      final u = int.tryParse(updatedId);
      final c = int.tryParse(currentId);
      if (u != null && c != null) return u > c;
      return !lastMessageTime(updated).isBefore(lastMessageTime(current));
    }

    final currentText = current.message?.trim() ?? current.preview?.trim() ?? '';
    final updatedText = updated.message?.trim() ?? updated.preview?.trim() ?? '';
    if (currentText.isNotEmpty && currentText == updatedText) {
      // Same message content: if updatedId is missing or equal to currentId,
      // this is NOT a new message (e.g. read receipt, presence update, updatedAt bump).
      // Crucial: never treat a read receipt or seen event as a new message!
      if (updatedId == null || updatedId == currentId) {
        return false;
      }
    }

    final updatedTime = lastMessageTime(updated);
    final currentTime = lastMessageTime(current);

    // If message text changed, treat as new message unless timestamp is significantly older (>5s)
    if (updated.message != null &&
        current.message != null &&
        updated.message != current.message) {
      return !updatedTime.isBefore(currentTime.subtract(const Duration(seconds: 5)));
    }

    // No IDs and text did not change: same message, never reorder on read/seen updates.
    return false;
  }

  /// Unread badge after merging a realtime update.
  /// - The chat open on screen is always 0 (the screen sends "read").
  /// - If server count is provided, use it (guarding against own message raising badge).
  /// - If server count is omitted in socket events, increment on new peer message.
  static int resolveUnread({
    required PrivateChatModel current,
    required PrivateChatModel updated,
    required bool newMessage,
    required bool isViewing,
    required String myUserId,
    bool readLocally = false,
    // True when this message id was already counted (the same message
    // arrives twice over the socket); the controller dedupes by id.
    bool alreadyCounted = false,
  }) {
    if (isViewing) return 0;
    final server = updated.unreadCount;
    final local = current.unreadCount ?? 0;

    // Read on this device and no new message since: a positive server count
    // here was computed before our read reached the server (the badge used
    // to come back after the message had been seen).
    if (readLocally && !newMessage) return local;

    final sentByMe = myUserId.isNotEmpty &&
        updated.senderId != null &&
        updated.senderId.toString() == myUserId;

    if (server != null) {
      if (sentByMe && server > local) return local;
      return server < 0 ? 0 : server;
    }

    // Realtime socket events frequently omit unreadCount. +1 only for a new
    // message from a KNOWN other user that has not been counted yet (the
    // same message arriving twice must count once), never for a deleted one.
    final fromOther = updated.senderId != null &&
        updated.senderId.toString().isNotEmpty &&
        !sentByMe;
    if (newMessage &&
        fromOther &&
        !alreadyCounted &&
        updated.isDeletedForEveryone != true) {
      return local + 1;
    }
    return local;
  }
}

/// Who is typing in which chat. Entries expire on their own, so a missed
/// "stop typing" never leaves the indicator stuck.
class ChatTypingTracker {
  ChatTypingTracker({
    required this.onChanged,
    this.expiry = const Duration(seconds: 5),
  });

  final void Function() onChanged;
  final Duration expiry;

  /// chatKey -> (userId -> display name), insertion ordered.
  final Map<String, Map<String, String>> _typists = {};
  final Map<String, Timer> _timers = {};

  bool isTyping(String chatKey) => _typists[chatKey]?.isNotEmpty ?? false;

  void start(String chatKey, String userId, {String? name}) {
    if (chatKey.isEmpty || userId.isEmpty) return;
    final users = _typists.putIfAbsent(chatKey, () => <String, String>{});
    final isNew = !users.containsKey(userId);
    users[userId] = (name?.trim().isNotEmpty ?? false) ? name!.trim() : _someone;
    final timerKey = '$chatKey|$userId';
    _timers[timerKey]?.cancel();
    _timers[timerKey] = Timer(expiry, () => stop(chatKey, userId));
    if (isNew) onChanged();
  }

  void stop(String chatKey, String userId) {
    _timers.remove('$chatKey|$userId')?.cancel();
    final users = _typists[chatKey];
    if (users == null || users.remove(userId) == null) return;
    if (users.isEmpty) _typists.remove(chatKey);
    onChanged();
  }

  /// A message arrived in [chatKey]: whoever sent it has stopped typing.
  void clearChat(String chatKey) {
    final users = _typists.remove(chatKey);
    if (users == null) return;
    for (final userId in users.keys) {
      _timers.remove('$chatKey|$userId')?.cancel();
    }
    onChanged();
  }

  void clearAll() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    final had = _typists.isNotEmpty;
    _typists.clear();
    if (had) onChanged();
  }

  /// Stored for a typist without a name; shown in the app language.
  static const String _someone = 'Someone';

  /// "typing…" (private) or "Rahul is typing…" / "Rahul, Priya are typing…".
  String? label(String chatKey, {required bool isGroup}) {
    final users = _typists[chatKey];
    if (users == null || users.isEmpty) return null;
    final l = appL10n;
    if (!isGroup) return l.chatList_typing;
    final names = [
      for (final n in users.values) n == _someone ? l.chatList_someone : n,
    ];
    if (names.length == 1) return l.chatList_oneTyping(names.first);
    if (names.length == 2) return l.chatList_twoTyping(names[0], names[1]);
    return l.chatList_manyTyping(names[0], names[1], names.length - 2);
  }

  /// All current labels, keyed by chat key.
  Map<String, String> labels({required bool Function(String chatKey) isGroup}) {
    final out = <String, String>{};
    for (final key in _typists.keys) {
      final l = label(key, isGroup: isGroup(key));
      if (l != null) out[key] = l;
    }
    return out;
  }
}
