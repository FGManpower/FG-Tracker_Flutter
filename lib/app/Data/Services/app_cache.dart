import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// One cached area (a screen's list): its name, version and size cap.
///
/// Bump [version] whenever the shape of the saved maps changes; a saved
/// list with another version is dropped (never parsed), so the screen just
/// waits for the API once. See docs/07_APP_CACHE_FRONTEND.md.
@immutable
class AppCacheArea {
  final String name;
  final int version;
  final int maxItems;

  const AppCacheArea(this.name, {required this.version, required this.maxItems});

  @override
  String toString() => name;
}

/// "Show the last known data at once, then refresh from the server" for the
/// screens outside the chat screen (doc 07).
///
/// * One AES-encrypted Hive box per user: `app_cache_<userId>`. Same key,
///   Hive setup and registry as [ChatMessageCache], so the existing logout
///   call `ChatMessageCache.clearAll()` deletes this box too (no new edit in
///   the logout code). The chat cache boxes and key are not touched.
/// * Entry key = area name; value =
///   `{"v": version, "uid": userId, "savedAt": ms, "items": [ {...}, ... ]}`.
/// * Plain JSON maps only (each model's `toJson()`), no Hive adapters.
/// * Every call catches its own errors. A cache problem never breaks a
///   screen: it then simply waits for the API as before.
/// * The server is always the source of truth; this is for the first paint.
class AppCache {
  AppCache._();

  // ---- Areas (bump a version when that area's saved shape changes) ----
  static const chatList = AppCacheArea('chat_list', version: 1, maxItems: 50);
  static const chatArchived =
      AppCacheArea('chat_archived', version: 1, maxItems: 100);
  static const fgContacts =
      AppCacheArea('fg_contacts', version: 1, maxItems: 1000);
  static const groups = AppCacheArea('groups', version: 1, maxItems: 200);
  static const banners = AppCacheArea('banners', version: 1, maxItems: 7);
  static const callHistory =
      AppCacheArea('call_history', version: 1, maxItems: 50);
  static const statusFeed =
      AppCacheArea('status_feed', version: 1, maxItems: 50);
  static const statusMine = AppCacheArea('status_mine', version: 1, maxItems: 30);
  static const walkieChannels =
      AppCacheArea('walkie_channels', version: 1, maxItems: 200);
  static const notifications =
      AppCacheArea('notifications', version: 1, maxItems: 100);

  static const List<AppCacheArea> allAreas = [
    chatList,
    chatArchived,
    fgContacts,
    groups,
    banners,
    callHistory,
    statusFeed,
    statusMine,
    walkieChannels,
    notifications,
  ];

  static const String _boxPrefix = 'app_cache_';

  /// Lists longer than this (as JSON text) are decoded off the UI thread.
  static const int _isolateDecodeChars = 64 * 1024;

  // ---- Test seams ----
  @visibleForTesting
  static Duration writeDelay = const Duration(seconds: 1);

  static Box<String>? _box;
  static String? _boxUser;
  static Future<void> _queue = Future.value();
  static bool _hooked = false;

  /// Bumped on logout: a write scheduled by the old session is dropped.
  static int _generation = 0;
  static int get generation => _generation;

  static final Map<String, Timer> _timers = {};
  static final Map<String, Future<void> Function()> _pending = {};

  static Future<T> _serial<T>(Future<T> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  static void _log(String message) {
    if (kDebugMode) debugPrint('[APP-CACHE] $message');
  }

  static void _hook() {
    if (_hooked) return;
    _hooked = true;
    ChatMessageCache.addBeforeClearAllHook(_beforeClearAll);
  }

  static final List<void Function()> _logoutListeners = [];

  /// [listener] runs on logout (from the existing logout call, through
  /// ChatMessageCache.clearAll). Permanent controllers use it to drop the
  /// previous user's data from memory (they survive `Get.deleteAll`).
  static void addLogoutListener(void Function() listener) {
    _hook();
    if (!_logoutListeners.contains(listener)) _logoutListeners.add(listener);
  }

  static void removeLogoutListener(void Function() listener) =>
      _logoutListeners.remove(listener);

  @visibleForTesting
  static int get logoutListenerCount => _logoutListeners.length;

  /// Logout (called by ChatMessageCache.clearAll): drop pending writes,
  /// close the box. The box file itself is deleted by clearAll.
  static Future<void> _beforeClearAll() async {
    for (final l in List.of(_logoutListeners)) {
      try {
        l();
      } catch (e) {
        _log('logout listener failed: $e');
      }
    }
    _generation++;
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _pending.clear();
    await _queue;
    if (_box != null && _box!.isOpen) await _box!.close();
    _box = null;
    _boxUser = null;
  }

  static String? _me() => ChatMessageCache.activeUserId();

  static Future<Box<String>?> _openBox() async {
    _hook();
    final me = _me();
    if (me == null) return null;
    if (_box != null && _box!.isOpen && _boxUser == me) return _box;

    await ChatMessageCache.ensureHive();
    if (_box != null && _box!.isOpen) await _box!.close();
    _box = null;
    _boxUser = null;

    final name = '$_boxPrefix$me';
    final cipher = HiveAesCipher(await ChatMessageCache.sharedCipherKey());
    Box<String> box;
    try {
      box = await Hive.openBox<String>(name, encryptionCipher: cipher);
    } catch (e) {
      // Wrong key (Keystore / Keychain reset) or damaged file: start over.
      _log('open failed, recreating $name: $e');
      await Hive.deleteBoxFromDisk(name);
      box = await Hive.openBox<String>(name, encryptionCipher: cipher);
    }
    await ChatMessageCache.registerBox(name);
    _box = box;
    _boxUser = me;
    return box;
  }

  // ---------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------

  static Future<Object?> _decode(String raw) async {
    if (raw.length < _isolateDecodeChars) return jsonDecode(raw);
    return Isolate.run(() => jsonDecode(raw));
  }

  /// Saved items of [area] (as saved, newest state last written); empty
  /// when there is nothing, the version changed, it belongs to another user
  /// or it can't be read.
  static Future<List<Map<String, dynamic>>> read(AppCacheArea area) async {
    try {
      return await _serial(() async {
        final box = await _openBox();
        final raw = box?.get(area.name);
        if (box == null || raw == null || raw.isEmpty) {
          _log('read $area: no copy');
          return const <Map<String, dynamic>>[];
        }
        final decoded = await _decode(raw);
        if (decoded is! Map ||
            decoded['v'] != area.version ||
            decoded['uid']?.toString() != _boxUser) {
          await box.delete(area.name); // old shape: clear, never crash
          _log('read $area: dropped (version / owner changed)');
          return const <Map<String, dynamic>>[];
        }
        final items = decoded['items'];
        if (items is! List) return const <Map<String, dynamic>>[];
        final out = <Map<String, dynamic>>[
          for (final i in items)
            if (i is Map) Map<String, dynamic>.from(i),
        ];
        _log('read $area: ${out.length} items');
        return out;
      });
    } catch (e) {
      _log('read $area failed: $e');
      return const <Map<String, dynamic>>[];
    }
  }

  /// [read] then [parse] each map; rows that fail to parse are skipped.
  static Future<List<T>> readAs<T>(
    AppCacheArea area,
    T? Function(Map<String, dynamic> json) parse,
  ) async {
    final maps = await read(area);
    final out = <T>[];
    for (final m in maps) {
      try {
        final v = parse(m);
        if (v != null) out.add(v);
      } catch (_) {}
    }
    return out;
  }

  // ---------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------

  /// Saves [items] (first [AppCacheArea.maxItems] kept). An empty list
  /// never replaces a saved copy unless [allowEmpty] (e.g. "clear all").
  /// [uid] / [generation] (captured when the change happened) must still
  /// match, so an old listener can never write into the next user's box.
  static Future<bool> write(
    AppCacheArea area,
    List<Map<String, dynamic>> items, {
    bool allowEmpty = false,
    String? uid,
    int? generation,
  }) async {
    if (items.isEmpty && !allowEmpty) return false;
    final capped =
        items.length > area.maxItems ? items.sublist(0, area.maxItems) : items;
    try {
      return await _serial(() async {
        final me = _me();
        if (me == null) return false;
        if (uid != null && uid != me) return false;
        if (generation != null && generation != _generation) return false;
        final box = await _openBox();
        if (box == null) return false;
        await box.put(
          area.name,
          jsonEncode({
            'v': area.version,
            'uid': me,
            'savedAt': DateTime.now().millisecondsSinceEpoch,
            'items': capped,
          }),
        );
        _log('saved $area: ${capped.length} items');
        return true;
      });
    } catch (e) {
      _log('write $area failed: $e');
      return false;
    }
  }

  /// Debounced write-through (R2): [snapshot] is taken NOW (the caller
  /// keeps mutating its list), written [writeDelay] later. A newer call for
  /// the same area replaces the pending one.
  static void scheduleWrite(
    AppCacheArea area,
    List<Map<String, dynamic>> Function() snapshot, {
    bool allowEmpty = false,
  }) {
    final uid = _me();
    if (uid == null) return;
    final gen = _generation;
    List<Map<String, dynamic>> items;
    try {
      items = snapshot();
    } catch (e) {
      _log('snapshot $area failed: $e');
      return;
    }
    Future<void> run() async {
      _timers.remove(area.name);
      _pending.remove(area.name);
      await write(area, items,
          allowEmpty: allowEmpty, uid: uid, generation: gen);
    }

    _timers[area.name]?.cancel();
    _pending[area.name] = run;
    _timers[area.name] = Timer(writeDelay, run);
  }

  /// Drops one area (e.g. "clear all" on that screen).
  static Future<void> clearArea(AppCacheArea area) async {
    _timers.remove(area.name)?.cancel();
    _pending.remove(area.name);
    try {
      await _serial(() async {
        final box = await _openBox();
        await box?.delete(area.name);
      });
    } catch (e) {
      _log('clear $area failed: $e');
    }
  }

  /// Opens the box in the background at app start.
  static Future<void> warmUp() async {
    try {
      await _serial(() async {
        final box = await _openBox();
        if (box != null) _log('ready (${box.length} areas)');
      });
    } catch (e) {
      _log('warm-up failed: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Merge helpers (R3, R8)
  // ---------------------------------------------------------------------

  /// Adds the [cached] items that are not in [live] yet. Items already in
  /// [live] win (they come from the API or a socket event and are newer),
  /// unless [isNewer] says the cached copy is newer. Always returns a NEW
  /// list (BUG-CS-18: a merge must never hand back the caller's own list).
  static List<T> mergeCachedIntoLive<T>({
    required List<T> live,
    required List<T> cached,
    required String? Function(T item) keyOf,
    bool Function(T cached, T live)? isNewer,
  }) {
    final out = List<T>.of(live);
    final index = <String, int>{};
    for (var i = 0; i < out.length; i++) {
      final k = keyOf(out[i]);
      if (k != null) index[k] = i;
    }
    for (final c in cached) {
      final k = keyOf(c);
      if (k == null) continue;
      final at = index[k];
      if (at == null) {
        index[k] = out.length;
        out.add(c);
      } else if (isNewer != null && isNewer(c, out[at])) {
        out[at] = c;
      }
    }
    return out;
  }

  // ---------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------

  /// Runs the pending debounced writes now.
  @visibleForTesting
  static Future<void> flushPendingWrites() async {
    final runs = List.of(_pending.values);
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    for (final r in runs) {
      await r();
    }
    await _queue;
  }

  @visibleForTesting
  static Future<void> resetForTest() async {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _pending.clear();
    await _queue;
    if (_box != null && _box!.isOpen) await _box!.close();
    _box = null;
    _boxUser = null;
  }
}

/// `[APP-CACHE]` timings of one screen open (debug builds only):
/// open → cache shown → API done → rendered. "API done" / "rendered" is
/// also what the screen needed before the cache (the "before" number).
class AppCachePerf {
  AppCachePerf(this.screen) : _watch = Stopwatch()..start();

  final String screen;
  final Stopwatch _watch;
  final Set<String> _done = {};

  void mark(String step, {String? extra}) {
    if (!kDebugMode || !_done.add(step)) return;
    debugPrint('[APP-CACHE] $screen $step: ${_watch.elapsedMilliseconds} ms'
        '${extra == null ? '' : ' ($extra)'}');
  }

  /// Logs [step] after the next frame (the list on screen).
  void markAfterFrame(String step, {String? extra}) {
    if (!kDebugMode) return;
    SchedulerBinding.instance
        .addPostFrameCallback((_) => mark(step, extra: extra));
  }
}
