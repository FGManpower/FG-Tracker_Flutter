import 'package:fgtracker/app/Model/PrivateChatModel.dart';

/// Chat-list row <-> cache map, LOSSLESS (doc 07 §3.1).
///
/// `PrivateChatModel.toJson` → `fromJson` is not a round trip: toJson writes
/// the raw last message under `lastMessage`, and fromJson reads the preview,
/// time and sender from that map first, defaults missing flags, and forces
/// `isOnline=false` for groups. A cached row must look exactly like the row
/// that was on screen, so the cache stores every field as it is and builds
/// the model back through its constructor. The model itself is unchanged
/// (`toJson` is also used by `/chat/sync`).
class ChatListCacheCodec {
  ChatListCacheCodec._();

  static Map<String, dynamic> encode(PrivateChatModel c) {
    final m = c.toJson();
    m.remove('lastMessage');
    m['lastMessageData'] = c.lastMessageData;
    return m;
  }

  static int? _i(Object? v) =>
      v == null ? null : (v is int ? v : int.tryParse(v.toString()));
  static String? _s(Object? v) => v?.toString();
  static bool? _b(Object? v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  /// Null when the map has no identity (never shown, never merged).
  static PrivateChatModel? decode(Map<String, dynamic> m) {
    final row = PrivateChatModel(
      id: _i(m['id']),
      chatId: _i(m['chatId']),
      conversationId: _i(m['conversationId']),
      groupId: _i(m['groupId']),
      chatType: _s(m['chatType']),
      userId: _i(m['userId']),
      name: _s(m['name']),
      groupName: _s(m['groupName']),
      memberCount: _i(m['memberCount']),
      role: _s(m['role']),
      message: _s(m['message']),
      preview: _s(m['preview']),
      isDeletedForEveryone: _b(m['isDeletedForEveryone']),
      time: _s(m['time']),
      timestamp: _s(m['timestamp']),
      messageType: _s(m['messageType']),
      mutedUntil: _s(m['mutedUntil']),
      unreadCount: _i(m['unreadCount']),
      status: _s(m['status']),
      isOnline: _b(m['isOnline']),
      lastSeen: _s(m['lastSeen']),
      isBlocked: _b(m['isBlocked']),
      blockedByMe: _b(m['blockedByMe']),
      isGroup: _b(m['isGroup']),
      isPinned: _b(m['isPinned']),
      pinnedAt: _s(m['pinnedAt']),
      isMuted: _b(m['isMuted']),
      isArchived: _b(m['isArchived']),
      groupStatus: _s(m['groupStatus']),
      isDeactivated: _b(m['isDeactivated']),
      isMarkedUnread: _b(m['isMarkedUnread']),
      isMember: _b(m['isMember']),
      moveToTop: _b(m['moveToTop']),
      image: _s(m['image']),
      isForwarded: _b(m['isForwarded']),
      forwardedLabel: _s(m['forwardedLabel']),
      forwardedFromMessageId: _i(m['forwardedFromMessageId']),
      senderId: _s(m['senderId']),
      senderName: _s(m['senderName']),
      lastMessageData: m['lastMessageData'] is Map
          ? Map<String, dynamic>.from(m['lastMessageData'] as Map)
          : null,
    );
    final hasIdentity = row.id != null ||
        row.chatId != null ||
        row.conversationId != null ||
        row.userId != null ||
        row.groupId != null;
    return hasIdentity ? row : null;
  }
}
