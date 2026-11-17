import 'dart:io';

import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory stand-in for the Keychain / Keystore.
class MemoryKeyStore implements ChatCacheKeyStore {
  List<int>? key;
  @override
  Future<List<int>?> read() async => key;
  @override
  Future<void> write(List<int> k) async => key = List.of(k);
  @override
  Future<void> delete() async => key = null;
}

/// Hive in a temp folder + a fake key store + a switchable user id, shared
/// by every app-cache test.
class AppCacheTestEnv {
  AppCacheTestEnv._(this.dir, this.keys);

  static const me = '101';

  final Directory dir;
  final MemoryKeyStore keys;
  String? user = me;

  static Future<AppCacheTestEnv> create() async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('app_cache_test');
    final env = AppCacheTestEnv._(dir, MemoryKeyStore());
    ChatMessageCache.keyStore = env.keys;
    ChatMessageCache.currentUserId = () {
      final u = env.user;
      return (u == null || u.isEmpty) ? null : u;
    };
    ChatMessageCache.initHive = () async => Hive.init(dir.path);
    AppCache.writeDelay = const Duration(milliseconds: 10);
    return env;
  }

  /// Closes every box (simulates an app restart).
  Future<void> closeAll() async {
    await AppCache.resetForTest();
    await ChatMessageCache.resetForTest();
    await Hive.close();
  }

  List<String> hiveFiles() => dir
      .listSync()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n.endsWith('.hive'))
      .toList();

  Future<void> dispose() async {
    await closeAll();
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  }
}
