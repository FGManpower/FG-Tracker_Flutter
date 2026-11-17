import 'dart:convert';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';

/// Last messages of a private chat kept on this device.
///
/// The server may return an empty history once one side blocks the other.
/// Like WhatsApp, a block must not erase what both people already wrote, so
/// the chat falls back to this copy. Keyed by my id + the peer's id (a block
/// can hide the chatId too). Cleared with the rest of the prefs on logout,
/// and when the chat is cleared.
class PrivateChatCache {
  PrivateChatCache._();

  static const int maxMessages = 50;

  /// SharedPreferences (Android XML file / iOS NSUserDefaults) is read into
  /// memory at app start on both platforms, so only the most recently used
  /// chats are kept (about 50 KB each at most).
  static const int maxChats = 20;
  static const String _prefix = 'private_chat_cache_';

  static String? _me() {
    final me = Global.storageServices.get(PrefConst.userId)?.toString();
    return (me == null || me.isEmpty) ? null : me;
  }

  static String? _key(String? peerId) {
    final me = _me();
    if (me == null || peerId == null || peerId.isEmpty) return null;
    return '$_prefix${me}_$peerId';
  }

  static String _indexKey(String me) => '${_prefix}index_$me';

  static List<String> _readIndex(String me) {
    try {
      final raw = Global.storageServices.get(_indexKey(me));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw);
      return list is List ? list.map((e) => e.toString()).toList() : [];
    } catch (_) {
      return [];
    }
  }

  /// Moves [peerId] to the front (or drops it) and deletes the copies of
  /// chats beyond [maxChats].
  static Future<void> _touchIndex(String peerId, {bool remove = false}) async {
    final me = _me();
    if (me == null) return;
    final index = _readIndex(me)..remove(peerId);
    if (!remove) index.insert(0, peerId);
    while (index.length > maxChats) {
      final evicted = index.removeLast();
      await Global.storageServices.remove('$_prefix${me}_$evicted');
    }
    await Global.storageServices.setString(_indexKey(me), jsonEncode(index));
  }

  /// Saves the newest [maxMessages] stored messages ([messages] is oldest
  /// first, as shown on screen). Messages without a server id (still
  /// sending) are skipped.
  static Future<void> save(String? peerId, List<MessageData> messages) async {
    final key = _key(peerId);
    if (key == null) return;
    try {
      final stored = messages.where((m) => m.id != null).toList();
      final last = stored.length > maxMessages
          ? stored.sublist(stored.length - maxMessages)
          : stored;
      if (last.isEmpty) return; // never overwrite a copy with nothing
      await Global.storageServices.setString(
        key,
        jsonEncode(last.map((m) => m.toJson()).toList()),
      );
      await _touchIndex(peerId!);
    } catch (_) {
      // A cache write must never break the chat.
    }
  }

  /// Saved messages, oldest first; empty when there is no copy.
  static List<MessageData> load(String? peerId) {
    final key = _key(peerId);
    if (key == null) return const [];
    try {
      final raw = Global.storageServices.get(key);
      if (raw == null || raw.isEmpty) return const [];
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      final out = <MessageData>[];
      for (final item in list) {
        if (item is! Map) continue;
        try {
          out.add(MessageData.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  static Future<void> clear(String? peerId) async {
    final key = _key(peerId);
    if (key == null) return;
    try {
      await Global.storageServices.remove(key);
      await _touchIndex(peerId!, remove: true);
    } catch (_) {}
  }
}
