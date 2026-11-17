import 'package:fgtracker/app/Model/GetMessage.dart';

/// Socket event names for read / delivered receipts. If the backend uses
/// different names, change them only here.
class ReceiptEvents {
  ReceiptEvents._();

  // Client -> server (on /chat for groups).
  static const String markSeen = 'mark_seen';
  static const String markDelivered = 'mark_delivered';

  // Server -> sender + group room (backend contract).
  static const String groupSeen = 'group_messages_seen';
  static const String groupDelivered = 'group_messages_delivered';

  /// Older names the server may still send; listened to as well.
  static const List<String> legacyGroupSeen = [
    'messages_seen_update',
    'group_message_seen',
  ];

  static const List<String> legacyGroupDelivered = ['messages_delivered'];

  static List<String> get allGroupSeen => [groupSeen, ...legacyGroupSeen];
  static List<String> get allGroupDelivered =>
      [groupDelivered, ...legacyGroupDelivered];
}

/// Turns an id in any shape (int, String, `{userId}` / `{user_id}` / `{_id}`
/// / `{id}` map, or a populated `{user: {...}}`) into a plain trimmed string.
/// Returns null for empty / "null".
String? normalizeReceiptId(dynamic value) {
  dynamic v = value;
  if (v is Map) {
    v = v['userId'] ??
        v['user_id'] ??
        v['readerId'] ??
        v['recipientId'] ??
        v['_id'] ??
        v['id'] ??
        (v['user'] is Map ? normalizeReceiptId(v['user']) : null);
  }
  final s = v?.toString().trim();
  if (s == null || s.isEmpty || s == 'null') return null;
  return s;
}

/// One read / delivered update for a group, parsed from a socket payload.
class ReceiptUpdate {
  ReceiptUpdate({
    required this.isRead,
    required this.groupId,
    required this.userId,
    required this.messageIds,
    required this.at,
  });

  final bool isRead;
  final String? groupId;

  /// The member who read / received the messages.
  final String? userId;

  /// Empty when the server did not say which messages (old payloads).
  final Set<String> messageIds;
  final String? at;

  /// Parses contract and legacy payloads. Returns null for a non-map.
  static ReceiptUpdate? parse(dynamic data, {required bool isRead}) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    final rawIds = map['messageIds'] ?? map['message_ids'];
    final ids = <String>{};
    if (rawIds is List) {
      for (final e in rawIds) {
        final id = normalizeReceiptId(e);
        if (id != null) ids.add(id);
      }
    } else {
      final single = normalizeReceiptId(map['messageId'] ?? map['message_id']);
      if (single != null) ids.add(single);
    }
    final seenBy = map['seenBy'];
    final user = normalizeReceiptId(map['userId'] ??
        map['user_id'] ??
        map['readerId'] ??
        map['recipientId'] ??
        (seenBy is List ? null : seenBy));
    return ReceiptUpdate(
      isRead: isRead,
      groupId: normalizeReceiptId(map['groupId'] ?? map['group_id']),
      userId: user,
      messageIds: ids,
      at: (isRead
              ? (map['readAt'] ?? map['seenAt'] ?? map['read_at'])
              : (map['deliveredAt'] ?? map['delivered_at']))
          ?.toString(),
    );
  }

  /// Dedupe key: the same update sent under several event names / rooms is
  /// applied once.
  String get key {
    final ids = messageIds.toList()..sort();
    return '${isRead ? 'r' : 'd'}|$groupId|$userId|${ids.join(',')}';
  }
}

/// Tick shown on my group message bubble.
enum GroupTick { sent, delivered, read }

/// Status of a group message from my point of view, from the per-member
/// lists. Used by BOTH the bubble ticks and Message Info so they always agree.
class GroupReceiptSummary {
  GroupReceiptSummary({
    required this.recipients,
    required this.read,
    required this.delivered,
    required this.remaining,
  });

  /// Members who should get the message (sender excluded).
  final List<String> recipients;

  /// userId -> read time (may be null when unknown).
  final Map<String, String?> read;

  /// Received but not read: userId -> delivered time.
  final Map<String, String?> delivered;

  /// Not received yet.
  final List<String> remaining;

  bool get allRead =>
      recipients.isNotEmpty && recipients.every(read.containsKey);

  bool get allDelivered =>
      recipients.isNotEmpty &&
      recipients.every((id) => read.containsKey(id) || delivered.containsKey(id));
}

/// Read / delivered receipts on a message: parsing, forward-only updates and
/// the group aggregation. Private chat keeps its own flags (`seenCount`,
/// `isDelivered`); these helpers only add the per-member lists.
class MessageReceipts {
  MessageReceipts._();

  /// userId -> time, from `readBy` plus the older `seenBy` id list.
  static Map<String, String?> readMap(MessageData m) {
    final out = <String, String?>{};
    _collect(m.readBy, out, timeKeys: const ['readAt', 'seenAt', 'read_at']);
    final seen = m.seenBy;
    if (seen is List) {
      _collect(seen, out, timeKeys: const ['readAt', 'seenAt']);
    }
    return out;
  }

  /// userId -> time, from `deliveredTo`.
  static Map<String, String?> deliveredMap(MessageData m) {
    final out = <String, String?>{};
    _collect(m.deliveredTo, out,
        timeKeys: const ['deliveredAt', 'delivered_at']);
    return out;
  }

  static void _collect(
    List<dynamic>? list,
    Map<String, String?> out, {
    required List<String> timeKeys,
  }) {
    if (list == null) return;
    for (final e in list) {
      final id = normalizeReceiptId(e);
      if (id == null) continue;
      String? at;
      if (e is Map) {
        for (final k in timeKeys) {
          if (e[k] != null) {
            at = e[k].toString();
            break;
          }
        }
      }
      // Keep a known time over an unknown one.
      if (!out.containsKey(id) || (out[id] == null && at != null)) {
        out[id] = at;
      }
    }
  }

  /// Marks [userId] as having read [m]. Forward-only: never removes a reader,
  /// and a read also counts as delivered. Returns true if anything changed.
  static bool applyRead(MessageData m, dynamic userId, {String? at}) {
    final id = normalizeReceiptId(userId);
    if (id == null) return false;
    if (normalizeReceiptId(m.senderId) == id) return false;
    var changed = false;
    if (!readMap(m).containsKey(id)) {
      m.readBy = [...?m.readBy, {'userId': id, 'readAt': at}];
      // Keep the older id list in step for code that still reads it.
      final seen = m.seenBy is List ? m.seenBy as List : <dynamic>[];
      if (!seen.any((e) => normalizeReceiptId(e) == id)) {
        m.seenBy = [...seen, id];
      }
      changed = true;
    }
    if (applyDelivered(m, id, at: at)) changed = true;
    return changed;
  }

  /// Marks [userId] as having received [m]. Forward-only: a late "delivered"
  /// never changes an existing entry. Returns true if anything changed.
  static bool applyDelivered(MessageData m, dynamic userId, {String? at}) {
    final id = normalizeReceiptId(userId);
    if (id == null) return false;
    if (normalizeReceiptId(m.senderId) == id) return false;
    if (deliveredMap(m).containsKey(id)) return false;
    m.deliveredTo = [...?m.deliveredTo, {'userId': id, 'deliveredAt': at}];
    return true;
  }

  /// Group status of [m] for [memberIds] (all current members). The sender
  /// is never a recipient. Members in [joinedAfter] (joined after the
  /// message was sent) are left out unless they already have a receipt.
  static GroupReceiptSummary summarize(
    MessageData m, {
    required Iterable<dynamic> memberIds,
    Set<String> joinedAfter = const {},
  }) =>
      summarizeMaps(
        senderId: m.senderId,
        read: readMap(m),
        delivered: deliveredMap(m),
        memberIds: memberIds,
        joinedAfter: joinedAfter,
      );

  /// [summarize] on plain maps (userId -> time), e.g. Message Info's state.
  /// Readers / receivers who left the group are kept in [read] /
  /// [delivered] (what they reached before leaving) but are not recipients.
  static GroupReceiptSummary summarizeMaps({
    required dynamic senderId,
    required Map<String, String?> read,
    required Map<String, String?> delivered,
    required Iterable<dynamic> memberIds,
    Set<String> joinedAfter = const {},
  }) {
    final sender = normalizeReceiptId(senderId);
    read = Map.of(read)..remove(sender);
    final deliveredAll = Map.of(delivered)..remove(sender);
    final recipients = <String>[];
    for (final raw in memberIds) {
      final id = normalizeReceiptId(raw);
      if (id == null || id == sender || recipients.contains(id)) continue;
      final hasReceipt = read.containsKey(id) || deliveredAll.containsKey(id);
      if (joinedAfter.contains(id) && !hasReceipt) continue;
      recipients.add(id);
    }
    final deliveredOnly = <String, String?>{
      for (final e in deliveredAll.entries)
        if (!read.containsKey(e.key)) e.key: e.value,
    };
    final remaining = recipients
        .where((id) => !read.containsKey(id) && !deliveredOnly.containsKey(id))
        .toList();
    return GroupReceiptSummary(
      recipients: recipients,
      read: read,
      delivered: deliveredOnly,
      remaining: remaining,
    );
  }

  /// Tick for my group message. Same rule as Message Info:
  /// read by all current recipients → [GroupTick.read] (blue);
  /// received by all → [GroupTick.delivered] (grey ✓✓); else one ✓.
  /// Until the server sends per-member lists for a message, the old
  /// server-saved flag (`isDelivered`) still gives ✓✓.
  static GroupTick groupTick(
    MessageData m, {
    required Iterable<dynamic> memberIds,
  }) {
    final summary = summarize(m, memberIds: memberIds);
    if (summary.allRead) return GroupTick.read;
    if (summary.allDelivered) return GroupTick.delivered;
    final hasPerMember = (m.deliveredTo?.isNotEmpty ?? false);
    if (!hasPerMember && m.isDelivered) return GroupTick.delivered;
    return GroupTick.sent;
  }

  /// Ids (as strings) of loaded messages sent by someone other than
  /// [myUserId], newest last.
  static List<String> idsFromOthers(
    Iterable<MessageData> messages, {
    required String? myUserId,
  }) {
    final me = normalizeReceiptId(myUserId);
    final out = <String>[];
    for (final m in messages) {
      final id = normalizeReceiptId(m.id);
      if (id == null) continue;
      if (normalizeReceiptId(m.senderId) == me) continue;
      out.add(id);
    }
    return out;
  }
}
