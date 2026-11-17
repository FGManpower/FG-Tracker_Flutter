import 'dart:async';
import 'dart:convert';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the AES key of the chat cache lives. Swapped for an in-memory
/// store in unit tests (the real one needs the Keychain / Keystore).
abstract class ChatCacheKeyStore {
  Future<List<int>?> read();
  Future<void> write(List<int> key);
  Future<void> delete();
}

/// AES key in the iOS Keychain / Android Keystore (flutter_secure_storage).
class SecureChatCacheKeyStore implements ChatCacheKeyStore {
  static const String _name = 'fg_chat_cache_aes_key';
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<List<int>?> read() async {
    final raw = await _storage.read(key: _name);
    if (raw == null || raw.isEmpty) return null;
    final key = base64Decode(raw);
    return key.length == 32 ? key : null;
  }

  @override
  Future<void> write(List<int> key) =>
      _storage.write(key: _name, value: base64Encode(key));

  @override
  Future<void> delete() => _storage.delete(key: _name);
}

/// Messages of the private and group chat screens kept on the device, so a
/// chat opens at once with what was on screen last time while the API
/// refreshes it in the background.
///
/// * One AES-encrypted Hive box per user (`chat_cache_<userId>`); the key is
///   in flutter_secure_storage.
/// * Entry key `private_<peerId>` / `group_<groupId>`; value = the newest
///   [maxMessages] stored messages (`MessageData.toJson`), oldest first.
/// * Only the [maxChats] most recently saved chats are kept (LRU).
/// * [cacheVersion] is written into the box and every entry: a mismatch
///   clears the data instead of parsing an old shape.
/// * Every public call catches its own errors: a cache problem never breaks
///   the chat (the screen then simply waits for the API as before).
class ChatMessageCache {
  ChatMessageCache._();

  /// Bump when [MessageData.toJson] changes shape.
  static const int cacheVersion = 1;
  static const int maxMessages = 50;
  static const int maxChats = 30;

  static const String _boxPrefix = 'chat_cache_';
  static const String _registryBoxName = 'chat_cache_registry';
  static const String _metaVersion = '__version';
  static const String _metaLru = '__lru';
  static const String _metaLegacyDone = '__legacy_prefs_done';

  /// The old SharedPreferences cache (PrivateChatCache, before F-1.2.4).
  static const String legacyPrefix = 'private_chat_cache_';

  // ---- Test seams ----
  @visibleForTesting
  static ChatCacheKeyStore keyStore = SecureChatCacheKeyStore();
  @visibleForTesting
  static String? Function() currentUserId = _defaultUserId;
  @visibleForTesting
  static Future<void> Function() initHive = () => Hive.initFlutter();

  static bool _hiveReady = false;
  static Box<String>? _box;
  static String? _boxUser;

  /// All box work runs one call at a time (open, LRU index, eviction).
  static Future<void> _queue = Future.value();

  static Future<T> _serial<T>(Future<T> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  static String? _defaultUserId() {
    try {
      final me = Global.storageServices.get(PrefConst.userId)?.toString();
      return (me == null || me.isEmpty || me == 'null') ? null : me;
    } catch (_) {
      return null;
    }
  }

  static String? privateKey(Object? peerId) {
    final id = peerId?.toString() ?? '';
    return (id.isEmpty || id == 'null') ? null : 'private_$id';
  }

  static String? groupKey(Object? groupId) {
    final id = groupId?.toString() ?? '';
    return (id.isEmpty || id == 'null' || id == '0') ? null : 'group_$id';
  }

  static void _log(String message) {
    if (kDebugMode) debugPrint('[CHAT-CACHE] $message');
  }

  // ---------------------------------------------------------------------
  // Box handling
  // ---------------------------------------------------------------------

  /// The logged-in user every cache box belongs to (null = nobody).
  static String? activeUserId() => currentUserId();

  /// One key read / creation at a time, shared with [AppCache]: two caches
  /// creating a key at once would leave one box with a key that is lost.
  static Future<List<int>>? _keyFuture;

  static Future<List<int>> _cipherKey() {
    return _keyFuture ??= () async {
      final existing = await keyStore.read();
      if (existing != null) return existing;
      final key = Hive.generateSecureKey();
      await keyStore.write(key);
      return key;
    }()
        .catchError((Object e) {
      _keyFuture = null; // retry next time
      throw e;
    });
  }

  // ---- Shared with AppCache (same key, Hive init and registry) ----

  /// Initialises Hive once for every cache.
  static Future<void> ensureHive() async {
    if (_hiveReady) return;
    await initHive();
    _hiveReady = true;
  }

  /// The AES key used by every encrypted cache box.
  static Future<List<int>> sharedCipherKey() => _cipherKey();

  /// Adds [name] to the registry, so the logout [clearAll] deletes it.
  static Future<void> registerBox(String name) => _registerBox(name);

  static final List<Future<void> Function()> _beforeClearAll = [];

  /// Runs before [clearAll] deletes the boxes (other caches close their
  /// boxes and drop pending writes). The logout call itself is unchanged.
  static void addBeforeClearAllHook(Future<void> Function() hook) {
    if (!_beforeClearAll.contains(hook)) _beforeClearAll.add(hook);
  }

  /// The current user's box, opened (and checked) on first use.
  static Future<Box<String>?> _openBox() async {
    final me = currentUserId();
    if (me == null) return null;
    if (_box != null && _box!.isOpen && _boxUser == me) return _box;

    if (!_hiveReady) {
      await initHive();
      _hiveReady = true;
    }
    if (_box != null && _box!.isOpen) await _box!.close();
    _box = null;
    _boxUser = null;

    final name = '$_boxPrefix$me';
    final cipher = HiveAesCipher(await _cipherKey());
    Box<String> box;
    try {
      box = await Hive.openBox<String>(name, encryptionCipher: cipher);
    } catch (e) {
      // Wrong key (Keychain / Keystore reset) or a damaged file: start over.
      _log('open failed, recreating $name: $e');
      await Hive.deleteBoxFromDisk(name);
      box = await Hive.openBox<String>(name, encryptionCipher: cipher);
    }

    if (box.get(_metaVersion) != '$cacheVersion') {
      await box.clear();
      await box.put(_metaVersion, '$cacheVersion');
    }
    await _registerBox(name);
    if (box.get(_metaLegacyDone) != '1') {
      await _migrateLegacyPrefs(box, me);
      await box.put(_metaLegacyDone, '1');
    }

    _box = box;
    _boxUser = me;
    return box;
  }

  /// Names of every user box on this device, so logout can delete them all.
  static Future<void> _registerBox(String name) async {
    final registry = await Hive.openBox<String>(_registryBoxName);
    if (!registry.containsKey(name)) await registry.put(name, name);
  }

  // ---------------------------------------------------------------------
  // One-time move off the old SharedPreferences cache
  // ---------------------------------------------------------------------

  /// Imports this user's old private-chat copies (the blocked-chat fallback
  /// must keep working) and deletes every old `private_chat_cache_*` key.
  static Future<void> _migrateLegacyPrefs(Box<String> box, String me) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs.getKeys().where((k) => k.startsWith(legacyPrefix)).toList();
      final mine = '$legacyPrefix${me}_';
      for (final k in keys) {
        if (!k.startsWith(mine) || k.startsWith('${legacyPrefix}index_')) {
          continue;
        }
        final chatKey = privateKey(k.substring(mine.length));
        if (chatKey == null || box.containsKey(chatKey)) continue;
        try {
          final list = jsonDecode(prefs.getString(k) ?? '');
          if (list is! List) continue;
          final messages = <MessageData>[
            for (final item in list)
              if (item is Map)
                MessageData.fromJson(Map<String, dynamic>.from(item)),
          ];
          await _write(box, chatKey, messages, null);
        } catch (_) {}
      }
      for (final k in keys) {
        await prefs.remove(k);
      }
      if (keys.isNotEmpty) _log('removed ${keys.length} old prefs chat keys');
    } catch (e) {
      _log('legacy migration skipped: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Entries + LRU
  // ---------------------------------------------------------------------

  static List<String> _lru(Box<String> box) {
    try {
      final list = jsonDecode(box.get(_metaLru) ?? '[]');
      return list is List ? list.map((e) => e.toString()).toList() : [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> _touch(Box<String> box, String chatKey,
      {bool remove = false}) async {
    final lru = _lru(box)..remove(chatKey);
    if (!remove) lru.insert(0, chatKey);
    while (lru.length > maxChats) {
      await box.delete(lru.removeLast());
    }
    await box.put(_metaLru, jsonEncode(lru));
  }

  /// Keeps the newest [maxMessages] messages that have a server id.
  static List<MessageData> trimForCache(List<MessageData> messages) {
    final stored = messages.where((m) {
      final id = m.id?.toString() ?? '';
      return id.isNotEmpty && id != 'null';
    });
    final sorted = ChatScreenRules.sortOldestFirst(stored);
    return sorted.length > maxMessages
        ? sorted.sublist(sorted.length - maxMessages)
        : sorted;
  }

  static Future<bool> _write(Box<String> box, String chatKey,
      List<MessageData> messages, String? chatId) async {
    final last = trimForCache(messages);
    if (last.isEmpty) return false; // never overwrite a copy with nothing
    await box.put(
      chatKey,
      jsonEncode({
        'v': cacheVersion,
        if (chatId != null && chatId.isNotEmpty) 'chatId': chatId,
        'm': [for (final m in last) m.toJson()],
      }),
    );
    await _touch(box, chatKey);
    return true;
  }

  // ---------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------

  /// Cached messages of [chatKey], oldest first; empty when there is none.
  static Future<List<MessageData>> load(String? chatKey) async {
    if (chatKey == null) return const [];
    try {
      return await _serial(() async {
        final box = await _openBox();
        final raw = box?.get(chatKey);
        if (box == null || raw == null || raw.isEmpty) {
          _log('load $chatKey: no copy (${box == null ? 'no user' : 'first open'})');
          return const [];
        }
        final decoded = jsonDecode(raw);
        if (decoded is! Map || decoded['v'] != cacheVersion) {
          await box.delete(chatKey);
          await _touch(box, chatKey, remove: true);
          return const [];
        }
        final out = <MessageData>[];
        for (final item in (decoded['m'] as List? ?? const [])) {
          if (item is! Map) continue;
          try {
            out.add(MessageData.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
        _log('load $chatKey: ${out.length} msgs');
        return out;
      });
    } catch (e) {
      _log('load $chatKey failed: $e');
      return const [];
    }
  }

  /// Saves the newest [maxMessages] stored messages of [messages] (any
  /// order). Messages still sending (no id) are skipped; an empty result
  /// never replaces an existing copy.
  static Future<void> save(String? chatKey, List<MessageData> messages,
      {String? chatId}) async {
    if (chatKey == null) return;
    // Encode now: the controller keeps changing these objects.
    final snapshot = List<MessageData>.of(messages);
    try {
      await _serial(() async {
        final box = await _openBox();
        if (box == null) return;
        if (await _write(box, chatKey, snapshot, chatId)) {
          _log('saved $chatKey: ${trimForCache(snapshot).length} msgs');
        }
      });
    } catch (e) {
      _log('save $chatKey failed: $e');
    }
  }

  /// Opens the current user's box in the background at app start, so the
  /// first chat opened after a cold start shows its cache without waiting
  /// for Hive / the Keystore. No user logged in → nothing happens.
  static Future<void> warmUp() async {
    try {
      await _serial(() async {
        final box = await _openBox();
        if (box != null) _log('ready (${box.length} entries)');
      });
    } catch (e) {
      _log('warm-up failed: $e');
    }
  }

  /// Drops one chat (Clear chat).
  static Future<void> clear(String? chatKey) async {
    if (chatKey == null) return;
    try {
      await _serial(() async {
        final box = await _openBox();
        if (box == null) return;
        await box.delete(chatKey);
        await _touch(box, chatKey, remove: true);
      });
    } catch (e) {
      _log('clear $chatKey failed: $e');
    }
  }

  /// Drops the private chat whose conversation id is [chatId] (a
  /// `private_chat_cleared` event names the chat, not the peer).
  static Future<void> clearPrivateByChatId(Object? chatId) async {
    final id = chatId?.toString() ?? '';
    if (id.isEmpty || id == 'null') return;
    try {
      await _serial(() async {
        final box = await _openBox();
        if (box == null) return;
        for (final key in box.keys.whereType<String>().toList()) {
          if (!key.startsWith('private_')) continue;
          try {
            final decoded = jsonDecode(box.get(key) ?? '');
            if (decoded is Map && decoded['chatId']?.toString() == id) {
              await box.delete(key);
              await _touch(box, key, remove: true);
            }
          } catch (_) {}
        }
      });
    } catch (e) {
      _log('clear chatId $id failed: $e');
    }
  }

  /// Logout: deletes every user's box and the AES key.
  static Future<void> clearAll() async {
    try {
      await _serial(() async {
        for (final hook in List.of(_beforeClearAll)) {
          try {
            await hook();
          } catch (e) {
            _log('before-clear hook failed: $e');
          }
        }
        if (!_hiveReady) {
          await initHive();
          _hiveReady = true;
        }
        if (_box != null && _box!.isOpen) await _box!.close();
        _box = null;
        _boxUser = null;
        final registry = await Hive.openBox<String>(_registryBoxName);
        for (final name in registry.values.toList()) {
          await Hive.deleteBoxFromDisk(name);
        }
        await registry.close();
        await Hive.deleteBoxFromDisk(_registryBoxName);
        await keyStore.delete();
        _keyFuture = null;
      }).timeout(const Duration(seconds: 3)); // logout never waits longer
    } catch (e) {
      _log('clearAll failed: $e');
    }
  }

  /// Closes the open box (tests).
  @visibleForTesting
  static Future<void> resetForTest() async {
    await _queue;
    if (_box != null && _box!.isOpen) await _box!.close();
    _box = null;
    _boxUser = null;
    _hiveReady = false;
    _keyFuture = null;
  }
}

/// `[CHAT-PERF]` timings of one chat open (debug builds only):
/// open → cache shown → API done → list rendered.
class ChatOpenPerf {
  ChatOpenPerf(this.chat) : _watch = Stopwatch()..start();

  final String chat;
  final Stopwatch _watch;
  final Set<String> _done = {};

  /// Logs [step] once with the time since the chat was opened.
  void mark(String step, {String? extra}) {
    if (!kDebugMode || !_done.add(step)) return;
    // debugPrint (not developer.log) so it shows in `flutter run` / logcat.
    debugPrint('[CHAT-PERF] $chat $step: ${_watch.elapsedMilliseconds} ms'
        '${extra == null ? '' : ' ($extra)'}');
  }
}
