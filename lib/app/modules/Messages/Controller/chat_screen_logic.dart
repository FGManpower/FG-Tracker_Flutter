import 'dart:async';

import 'package:fgtracker/app/Core/util/http/http_util.dart' show HttpGetException;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:fgtracker/app/Model/GetMessage.dart';

/// Pure chat-screen rules shared by the private and group chat screens:
/// history merging, paging state, message-menu options and the seen-by list.
/// Kept free of GetX/sockets so they are unit tested.
class ChatScreenRules {
  ChatScreenRules._();

  /// Messages per history request.
  static const int pageSize = 20;

  /// First history page on open: after this the load COUNTS as failed for
  /// the "Couldn't refresh" bar (a soft timeout: the request itself is kept,
  /// and a late answer is still applied). Tests shorten it.
  static Duration historyTimeout = const Duration(seconds: 10);

  /// Waits for [request] as long as it takes, but calls [onSoftTimeout]
  /// once if it is still running after [historyTimeout] (or [timeout]).
  /// Unlike `Future.timeout`, the answer is never thrown away: a late
  /// success still reaches the caller (doc 01 §12.2.1).
  static Future<T> softTimeout<T>(
    Future<T> request, {
    required void Function() onSoftTimeout,
    Duration? timeout,
  }) {
    final timer = Timer(timeout ?? historyTimeout, onSoftTimeout);
    return request.whenComplete(timer.cancel);
  }

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
  ///
  /// The returned list is never [existing] itself, so a caller may clear
  /// [existing] and refill it from the result.
  static MergeResult merge(
    List<MessageData> existing,
    List<MessageData> incoming,
  ) {
    final existingMap = <String, MessageData>{
      for (final m in existing)
        if (_idKey(m) != null) _idKey(m)!: m,
    };
    final known = existingMap.keys.toSet();
    final added = <MessageData>[];
    bool statusUpdated = false;

    for (final m in incoming) {
      final key = _idKey(m);
      if (key != null && existingMap.containsKey(key)) {
        final existingMsg = existingMap[key]!;
        if (m.isDelivered == true && !existingMsg.isDelivered) {
          existingMsg.isDelivered = true;
          statusUpdated = true;
        }
        if (m.seenCount != null) {
          final inCount = int.tryParse(m.seenCount.toString()) ?? 0;
          final exCount = int.tryParse(existingMsg.seenCount?.toString() ?? '') ?? 0;
          if (inCount > exCount) {
            existingMsg.seenCount = inCount;
            statusUpdated = true;
          }
        }
        if (m.seenBy is List && (m.seenBy as List).isNotEmpty) {
          if (existingMsg.seenBy is! List) existingMsg.seenBy = [];
          final exList = (existingMsg.seenBy as List);
          for (final s in (m.seenBy as List)) {
            final sId = (s is Map ? (s['userId'] ?? s['user_id'] ?? s['id']) : s)?.toString();
            if (sId != null && !exList.any((e) => (e is Map ? (e['userId'] ?? e['user_id'] ?? e['id']) : e)?.toString() == sId)) {
              exList.add(s);
              statusUpdated = true;
            }
          }
        }
        final isIncomingDeleted =
            m.isDeleted == true || m.content?.toString() == 'This message was deleted';
        if (isIncomingDeleted && existingMsg.isDeleted != true) {
          markDeletedForEveryone(existingMsg);
          statusUpdated = true;
        }
        if (m.isEdited == true && existingMsg.isEdited != true) {
          existingMsg.isEdited = true;
          existingMsg.content = m.content;
          statusUpdated = true;
        }
        continue;
      }
      if (key != null) known.add(key);
      added.add(m);
    }
    if (added.isEmpty) {
      // Always a new list: callers do `_messages..clear()..addAll(merged)`,
      // so returning `existing` itself emptied the chat (BUG-CS-18).
      return MergeResult(List.of(existing), 0, 0, updated: statusUpdated);
    }

    final firstBefore = existing.isEmpty ? null : existing.first;
    final merged = sortOldestFirst([...existing, ...added]);
    final prepended =
        firstBefore == null ? 0 : merged.indexOf(firstBefore).clamp(0, merged.length);
    return MergeResult(merged, added.length, prepended, updated: statusUpdated);
  }

  static int? _realId(MessageData m) {
    final id = int.tryParse(m.id?.toString() ?? '');
    return (id != null && id > 0) ? id : null;
  }

  /// Smallest real message id (temp bubbles without an id are skipped).
  /// Cursor for `before=` when loading older history.
  static int? oldestId(List<MessageData> messages) {
    int? out;
    for (final m in messages) {
      final id = _realId(m);
      if (id != null && (out == null || id < out)) out = id;
    }
    return out;
  }

  /// Largest real message id. Cursor for `after=` when catching up.
  static int? newestId(List<MessageData> messages) {
    int? out;
    for (final m in messages) {
      final id = _realId(m);
      if (id != null && (out == null || id > out)) out = id;
    }
    return out;
  }

  /// True when the server really applied the cursor: every returned id is
  /// older than [before] / newer than [after]. False means an older server
  /// ignored it (e.g. sent the newest page), so the caller falls back to
  /// page paging.
  static bool cursorHonoured(
    List<MessageData> batch, {
    int? before,
    int? after,
  }) {
    for (final m in batch) {
      final id = _realId(m);
      if (id == null) continue;
      if (before != null && id >= before) return false;
      if (after != null && id <= after) return false;
    }
    return true;
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

  /// Long-press options for a message.
  static Set<MessageMenuOption> menuOptions({
    required dynamic messageType,
    required bool isSentByMe,
  }) {
    final text = isText(messageType);
    return {
      MessageMenuOption.reply,
      if (text) MessageMenuOption.copy,
      MessageMenuOption.forward,
      if (isSentByMe && text) MessageMenuOption.edit,
      MessageMenuOption.pin,
      if (isSentByMe) MessageMenuOption.info,
      if (isSentByMe) MessageMenuOption.deleteForEveryone,
      MessageMenuOption.deleteForMe,
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

  /// Whether any already-loaded message had its tick/seen/deleted status updated.
  final bool updated;

  const MergeResult(this.messages, this.added, this.prepended, {this.updated = false});
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

/// The server answered, but said the request failed (`status: false`). The
/// data on screen may be stale, like a 5xx; it is never "0 rows".
class ServerAnswerFailure implements Exception {
  ServerAnswerFailure(this.message);
  final String? message;
  @override
  String toString() => message ?? 'status:false';
}

/// What a screen does after a failed load (see [RefreshBarState]).
enum RefreshBarAction {
  /// Nothing visible (background load, a bug / 4xx, already counted).
  none,

  /// Retry the same foreground load quietly after [RefreshBarState.quietRetryDelay].
  quietRetry,

  /// Data on screen + really stale: show "Couldn't refresh · Retry".
  showBar,

  /// Nothing on screen: the full "Couldn't load" view (as before).
  fullError,
}

/// When the "Couldn't refresh · Retry" bar shows (chat list, private chat,
/// group chat; doc 01 §12.2.1, doc 07 §4). Plain Dart, unit tested.
///
/// * It shows only when data is on screen, the latest FOREGROUND load
///   failed twice (the first failure is retried quietly) and no sync has
///   succeeded since. A user Retry / pull that fails shows it at once.
/// * Only "the server could not be reached" counts: timeout, connection
///   error, 5xx, `status:false` ([isStaleDataFailure]). A 4xx or a parse /
///   processing error is a bug or a real answer, never "Couldn't refresh".
/// * Background loads (reconnect, resume, socket refetch) never raise it.
/// * Any success (full load, incremental sync, gap fill, socket full list)
///   clears it.
/// * Each load attempt counts once (two reports of the same attempt, e.g.
///   socket "joined" without chatId + the API failure, are one failure).
/// * An empty screen gets [RefreshBarAction.fullError] at once, as before.
class RefreshBarState {
  RefreshBarState({this.onChanged});

  /// Called when [visible] changes (reason for the log).
  final void Function(bool visible, String reason)? onChanged;

  /// Pause before the automatic retry after a first failure (tests shorten it).
  static Duration quietRetryDelay = const Duration(seconds: 2);

  bool _visible = false;
  bool _loadedOnce = false;
  int _failures = 0;
  int _attempt = 0;
  final Set<int> _countedAttempts = {};

  /// The flag the screen shows (bar over data / full error when empty).
  bool get visible => _visible;

  /// A load or sync has succeeded since the screen opened (or the reset).
  bool get loadedOnce => _loadedOnce;

  /// Number of the next load attempt (pass it to [failure]).
  int startAttempt() => ++_attempt;

  /// Offline, timed out, server down or `status:false`.
  static bool isStaleDataFailure(Object error) {
    if (error is TimeoutException) return true;
    if (error is ServerAnswerFailure) return true;
    if (error is HttpGetException) return error.isNetworkOrServer;
    return false;
  }

  void _set(bool v, String reason) {
    if (_visible == v) return;
    _visible = v;
    onChanged?.call(v, reason);
  }

  /// A full load, an incremental sync, a gap fill or a socket full list
  /// succeeded: the data is fresh, the bar goes.
  void success(String reason) {
    _loadedOnce = true;
    _failures = 0;
    _set(false, reason);
  }

  /// The user tapped Retry / pulled: hide while it runs.
  void retrying() => _set(false, 'retry');

  RefreshBarAction failure({
    required Object error,
    required bool foreground,
    required bool hasData,
    bool userRetry = false,
    int? attempt,
  }) {
    if (attempt != null && !_countedAttempts.add(attempt)) {
      return RefreshBarAction.none; // this attempt was already counted
    }
    if (!hasData) {
      _set(true, 'empty screen, load failed');
      return RefreshBarAction.fullError;
    }
    if (!isStaleDataFailure(error)) return RefreshBarAction.none;
    if (userRetry) {
      _set(true, 'user retry failed');
      return RefreshBarAction.showBar;
    }
    if (!foreground || _loadedOnce) return RefreshBarAction.none;
    _failures++;
    if (_failures == 1) return RefreshBarAction.quietRetry;
    _set(true, 'foreground load failed twice');
    return RefreshBarAction.showBar;
  }

  /// Logout / account switch / Back.
  void reset() {
    _loadedOnce = false;
    _failures = 0;
    _countedAttempts.clear();
    _set(false, 'reset');
  }
}
