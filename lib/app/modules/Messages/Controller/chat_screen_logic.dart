import 'package:fgtracker/app/Model/GetMessage.dart';

/// Pure chat-screen rules shared by the private and group chat screens:
/// history merging, paging state, message-menu options and the seen-by list.
/// Kept free of GetX/sockets so they are unit tested.
class ChatScreenRules {
  ChatScreenRules._();

  /// Messages per history request.
  static const int pageSize = 20;

  /// How many older pages a reply-jump may load while looking for the
  /// original message before giving up with "Message not available".
  static const int maxReplyJumpPages = 10;

  static DateTime messageTime(MessageData m) {
    final raw = m.timestamp?.toString().trim() ?? '';
    return DateTime.tryParse(raw)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static String? _idKey(MessageData m) {
    final id = m.id?.toString();
    return (id == null || id.isEmpty || id == 'null') ? null : id;
  }

  /// Oldest-first order. Messages without a usable timestamp keep their
  /// relative position (stable sort) instead of jumping to 1970.
  static List<MessageData> sortOldestFirst(Iterable<MessageData> input) {
    final list = input.toList();
    final indexed = List.generate(list.length, (i) => (i, list[i]));
    indexed.sort((a, b) {
      final at = a.$2.timestamp?.toString().trim() ?? '';
      final bt = b.$2.timestamp?.toString().trim() ?? '';
      final ad = DateTime.tryParse(at);
      final bd = DateTime.tryParse(bt);
      if (ad != null && bd != null) {
        final c = ad.compareTo(bd);
        if (c != 0) return c;
        final ai = int.tryParse(_idKey(a.$2) ?? '');
        final bi = int.tryParse(_idKey(b.$2) ?? '');
        if (ai != null && bi != null && ai != bi) return ai.compareTo(bi);
      }
      return a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  /// Merges an API page into the loaded list. Messages already present
  /// (same id) are kept as loaded (they may carry newer socket state), new
  /// ones are added, and the result is oldest-first.
  ///
  /// Returns the merged list and how many messages were added before the
  /// previously first message (used to keep the scroll position).
  static MergeResult merge(
    List<MessageData> existing,
    List<MessageData> incoming,
  ) {
    final known = <String>{
      for (final m in existing)
        if (_idKey(m) != null) _idKey(m)!,
    };
    final added = <MessageData>[];
    for (final m in incoming) {
      final key = _idKey(m);
      if (key != null && !known.add(key)) continue;
      added.add(m);
    }
    if (added.isEmpty) {
      return MergeResult(existing, 0, 0);
    }

    final firstBefore = existing.isEmpty ? null : existing.first;
    final merged = sortOldestFirst([...existing, ...added]);
    final prepended =
        firstBefore == null ? 0 : merged.indexOf(firstBefore).clamp(0, merged.length);
    return MergeResult(merged, added.length, prepended);
  }

  /// Message types the bubble knows how to draw.
  static const Set<String> renderableTypes = {
    'text', 'text_message', 'emoji', 'link', 'reply', //
    'image', 'image_text', 'media', 'video', 'audio', 'voice', 'document',
    'location', 'contact', 'attendance', 'attendance_poll', //
    'forward', 'forwarded', 'forward_message', 'status_reply', //
    'system', 'group_event',
  };

  /// True when the bubble should show the "unsupported message" placeholder:
  /// a row that failed to parse, or an unknown type whose content is not
  /// readable text (empty or a raw JSON payload). Unknown types that carry
  /// plain text keep showing that text.
  static bool isUnsupported(MessageData m) {
    final type = m.messageType?.toString().toLowerCase().trim() ?? '';
    if (type == MessageData.unsupportedType) return true;
    if (type.isEmpty || renderableTypes.contains(type)) return false;
    final content = m.content?.toString().trim() ?? '';
    return content.isEmpty || content.startsWith('{') || content.startsWith('[');
  }

  // ---------------------------------------------------------------------------
  // Message menu
  // ---------------------------------------------------------------------------

  static bool isAttendance(dynamic messageType) {
    final t = messageType?.toString().toLowerCase().trim() ?? '';
    return t == 'attendance' || t == 'attendance_poll';
  }

  static bool isText(dynamic messageType) {
    final t = messageType?.toString().toLowerCase().trim() ?? '';
    return t.isEmpty || t == 'text' || t == 'text_message';
  }

  /// Long-press options for a message. Attendance messages can never be
  /// deleted from the chat (the poll is managed from its own card), so they
  /// get no delete option for any user.
  static Set<MessageMenuOption> menuOptions({
    required dynamic messageType,
    required bool isSentByMe,
  }) {
    final text = isText(messageType);
    final attendance = isAttendance(messageType);
    return {
      MessageMenuOption.reply,
      if (text) MessageMenuOption.copy,
      MessageMenuOption.forward,
      if (isSentByMe && text) MessageMenuOption.edit,
      MessageMenuOption.pin,
      if (isSentByMe) MessageMenuOption.info,
      if (isSentByMe && !attendance) MessageMenuOption.deleteForEveryone,
      if (!attendance) MessageMenuOption.deleteForMe,
    };
  }

  // ---------------------------------------------------------------------------
  // Edit / delete events
  // ---------------------------------------------------------------------------

  /// Applies a `messageEdited` event in place (keeps ticks, reply, media).
  /// Accepts `messageId` or `id`, and `content`/`newContent`/`message`.
  static bool applyEdit(List<MessageData> messages, Map<String, dynamic> data) {
    final nested = data['message'] is Map
        ? Map<String, dynamic>.from(data['message'] as Map)
        : null;
    final id = MessageData.parseIntOrNull(
      data['messageId'] ?? data['message_id'] ?? data['id'] ?? nested?['id'],
    );
    if (id == null) return false;
    final index = messages.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final content = data['content'] ??
        data['newContent'] ??
        (data['message'] is String ? data['message'] : null) ??
        nested?['content'];
    if (content == null) return false;

    final msg = messages[index];
    msg.content = content.toString();
    msg.isEdited = data['isEdited'] ?? nested?['isEdited'] ?? true;
    msg.edited = msg.isEdited;
    msg.editedAt = data['editedAt'] ?? nested?['editedAt'] ?? msg.editedAt;
    return true;
  }

  /// A `for_me` delete must only remove the message for the user who
  /// deleted it. When the event names the deleting user and it isn't me,
  /// it must be ignored. Without a user id, keep the old behaviour.
  static bool isDeleteForMeByMe(Map data, String? currentUserId) {
    final by = (data['userId'] ?? data['user_id'] ?? data['deletedBy'])
        ?.toString()
        .trim();
    if (by == null || by.isEmpty || by == 'null') return true;
    return by == currentUserId?.trim();
  }

  /// "Deleted for everyone": no text, media, caption or reply left behind.
  static void markDeletedForEveryone(MessageData msg) {
    msg.messageType = 'text';
    msg.content = 'This message was deleted';
    msg.caption = null;
    msg.images = [];
    msg.videos = [];
    msg.replyId = null;
    msg.isDeleted = true;
  }

  // ---------------------------------------------------------------------------
  // Keyboard / emoji panel
  // ---------------------------------------------------------------------------

  /// Emoji panel height: the last keyboard height when known (so swapping
  /// keyboard <-> emoji panel doesn't make the screen jump), otherwise
  /// [fallback]; never more than 40% of the screen so the message list and
  /// input keep room on small phones and with a large font scale.
  static double emojiPanelHeight({
    required double screenHeight,
    double? lastKeyboardHeight,
    double fallback = 300,
  }) {
    final wanted = (lastKeyboardHeight != null && lastKeyboardHeight > 120)
        ? lastKeyboardHeight
        : fallback;
    final max = screenHeight * 0.4;
    const min = 180.0;
    if (max < min) return max;
    return wanted.clamp(min, max).toDouble();
  }

  // ---------------------------------------------------------------------------
  // Seen by
  // ---------------------------------------------------------------------------

  /// User ids that have seen [message], without the logged-in user and
  /// without the message's sender. Compared by id, never by name.
  static Set<String> seenByOthers(
    MessageData message, {
    required String? currentUserId,
  }) {
    final raw = message.seenBy;
    if (raw is! List) return const {};
    final me = currentUserId?.trim() ?? '';
    final sender = message.senderId?.toString().trim() ?? '';
    final ids = <String>{};
    for (final entry in raw) {
      final id = (entry is Map
              ? (entry['userId'] ?? entry['user_id'] ?? entry['id'])
              : entry)
          ?.toString()
          .trim();
      if (id == null || id.isEmpty || id == 'null') continue;
      if (id == me || id == sender) continue;
      ids.add(id);
    }
    return ids;
  }

  /// Number shown next to "Seen". Uses the id list when present; otherwise
  /// the server count, which in a private chat can only be 0 or 1.
  static int seenCount(
    MessageData message, {
    required String? currentUserId,
    bool isGroup = false,
  }) {
    if (message.seenBy is List) {
      return seenByOthers(message, currentUserId: currentUserId).length;
    }
    final count = message.seenCount is int
        ? message.seenCount as int
        : int.tryParse(message.seenCount?.toString() ?? '') ?? 0;
    if (count <= 0) return 0;
    return isGroup ? count : 1;
  }

  /// Applies a group `seen_update` (reader [readerId]) to the loaded
  /// messages. My own read receipt never marks anything, and a reader is
  /// never recorded on their own messages. Returns true if anything changed.
  static bool applyGroupSeen(
    List<MessageData> messages, {
    required String readerId,
    required String? currentUserId,
  }) {
    final reader = readerId.trim();
    if (reader.isEmpty || reader == currentUserId?.trim()) return false;
    var changed = false;
    for (final msg in messages) {
      if (msg.senderId?.toString() == reader) continue;
      if (msg.seenBy is! List) msg.seenBy = <dynamic>[];
      final list = msg.seenBy as List;
      if (!list.any((e) => e?.toString() == reader)) {
        list.add(reader);
        changed = true;
      }
    }
    return changed;
  }

  /// Applies a private `messages_seen` update. Only messages I sent can be
  /// "seen", and only by the other person; my own read echo is ignored.
  static bool applyPrivateSeen(
    List<MessageData> messages, {
    required List<dynamic> messageIds,
    required String? readerId,
    required String? currentUserId,
  }) {
    final me = currentUserId?.trim() ?? '';
    if (readerId != null && readerId.trim().isNotEmpty && readerId.trim() == me) {
      return false;
    }
    final ids = messageIds.map((e) => e.toString()).toSet();
    var changed = false;
    for (final msg in messages) {
      if (!ids.contains(msg.id?.toString())) continue;
      if (me.isNotEmpty && msg.senderId?.toString() != me) continue;
      final current = int.tryParse(msg.seenCount?.toString() ?? '') ?? 0;
      if (current < 1) {
        msg.seenCount = 1;
        changed = true;
      }
      if (!msg.isDelivered) {
        msg.isDelivered = true;
        changed = true;
      }
    }
    return changed;
  }
}

class MergeResult {
  final List<MessageData> messages;

  /// New messages that were not loaded before.
  final int added;

  /// How many of them now sit before the previously first message.
  final int prepended;

  const MergeResult(this.messages, this.added, this.prepended);
}

enum MessageMenuOption {
  reply,
  copy,
  forward,
  edit,
  pin,
  info,
  deleteForEveryone,
  deleteForMe,
}

/// Page-number paging over the history API, made safe against the offsets
/// shifting while the chat is open (new messages push old ones to later
/// pages): every page is merged by id, the page counter always advances on
/// success, and paging stops when the API says there is no next page or a
/// page comes back empty.
///
/// TODO(backend #1): switch to `before=<oldest messageId>` once the history
/// API supports a cursor; then deletions can no longer skip messages.
class HistoryPager {
  int _lastLoadedPage = 0;
  bool _hasMore = true;
  bool _loading = false;

  int get lastLoadedPage => _lastLoadedPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _loading;

  /// Page to request next, or null if a call is in flight / nothing left.
  int? begin() {
    if (_loading || !_hasMore) return null;
    _loading = true;
    return _lastLoadedPage + 1;
  }

  /// Call when page [page] came back successfully.
  void complete({
    required int page,
    required int receivedCount,
    bool? hasNextPage,
  }) {
    _loading = false;
    if (page > _lastLoadedPage) _lastLoadedPage = page;
    _hasMore = receivedCount > 0 && (hasNextPage ?? receivedCount >= ChatScreenRules.pageSize);
  }

  /// Call when the request failed; paging can be retried.
  void fail() => _loading = false;

  /// Back to "nothing loaded" (first load / chat cleared).
  void reset() {
    _lastLoadedPage = 0;
    _hasMore = true;
    _loading = false;
  }
}
