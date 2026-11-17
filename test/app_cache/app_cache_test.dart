// Shared app cache (doc 07). Pure Dart + Hive files in a temp folder; the
// secure-storage key is an in-memory store (the real one needs the
// Keychain / Keystore). Same code on Android and iOS.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

void main() {
  late AppCacheTestEnv env;

  setUp(() async {
    env = await AppCacheTestEnv.create();
  });

  tearDown(() => env.dispose());

  const area = AppCache.groups;
  List<Map<String, dynamic>> rows(int n, {int from = 1}) =>
      [for (var i = from; i < from + n; i++) {'id': i, 'name': 'g$i'}];

  test('AC-01 put / get round trip keeps the maps and their order', () async {
    expect(await AppCache.write(area, rows(3)), isTrue);
    final back = await AppCache.read(area);
    expect(back.map((m) => m['id']), [1, 2, 3]);
    expect(back.first['name'], 'g1');
  });

  test('AC-02 version mismatch clears only that area, never crashes',
      () async {
    await AppCache.write(area, rows(2));
    await AppCache.write(AppCache.banners, rows(1));
    // Simulate an older app version's entry for "groups".
    final box = Hive.box<String>('app_cache_${env.user}');
    await box.put(area.name, jsonEncode({'v': 0, 'uid': env.user, 'items': []}));
    expect(await AppCache.read(area), isEmpty);
    expect(box.containsKey(area.name), isFalse);
    expect(await AppCache.read(AppCache.banners), hasLength(1));
  });

  test('AC-03 a corrupt entry gives empty, no crash; next write fixes it',
      () async {
    await AppCache.write(area, rows(1));
    await Hive.box<String>('app_cache_${env.user}').put(area.name, '{nope');
    expect(await AppCache.read(area), isEmpty);
    await AppCache.write(area, rows(2));
    expect(await AppCache.read(area), hasLength(2));
  });

  test('AC-04 per-user isolation: B never sees A', () async {
    await AppCache.write(area, rows(2));
    env.user = '999';
    expect(await AppCache.read(area), isEmpty);
    await AppCache.write(area, rows(1, from: 50));
    env.user = AppCacheTestEnv.me;
    expect((await AppCache.read(area)).map((m) => m['id']), [1, 2]);
  });

  test('AC-05 logout clearAll removes every box (chat + app) and the key',
      () async {
    await AppCache.write(area, rows(2));
    await ChatMessageCache.save('private_7', [
      MessageData.fromJson({'id': 1, 'content': 'x', 'timestamp': '2026-11-17T10:00:00Z'})
    ]);
    env.user = '999';
    await AppCache.write(area, rows(1));
    expect(env.keys.key, isNotNull);

    await ChatMessageCache.clearAll();
    expect(env.keys.key, isNull);
    expect(env.hiveFiles(), isEmpty);
    env.user = AppCacheTestEnv.me;
    expect(await AppCache.read(area), isEmpty);
  });

  test('AC-06 clearAll never throws and gives up after 3 s', () async {
    final hang = Completer<void>();
    ChatMessageCache.addBeforeClearAllHook(() => hang.future);
    final watch = Stopwatch()..start();
    await ChatMessageCache.clearAll(); // must return, not throw
    expect(watch.elapsed.inSeconds, lessThan(5));
    hang.complete();
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('AC-07 size cap keeps the first maxItems', () async {
    await AppCache.write(AppCache.banners, rows(20));
    final back = await AppCache.read(AppCache.banners);
    expect(back, hasLength(AppCache.banners.maxItems));
    expect(back.first['id'], 1);
  });

  test('AC-08 lost key (Keystore reset): box cleared, no crash', () async {
    await AppCache.write(area, rows(2));
    await env.closeAll();
    env.keys.key = null;
    expect(await AppCache.read(area), isEmpty);
    await AppCache.write(area, rows(1));
    expect(await AppCache.read(area), hasLength(1));
  });

  test('AC-09 chat cache data is untouched by the app cache', () async {
    await ChatMessageCache.save('group_5', [
      MessageData.fromJson({'id': 9, 'content': 'keep me', 'timestamp': '2026-11-17T10:00:00Z'})
    ]);
    await AppCache.write(area, rows(3));
    await env.closeAll();
    final chat = await ChatMessageCache.load('group_5');
    expect(chat.single.content, 'keep me');
    expect(await AppCache.read(area), hasLength(3));
  });

  test('AC-10 both caches creating the key at once share ONE key', () async {
    await Future.wait([
      AppCache.write(area, rows(1)),
      ChatMessageCache.save('private_1', [
        MessageData.fromJson({'id': 1, 'content': 'a', 'timestamp': '2026-11-17T10:00:00Z'})
      ]),
    ]);
    await env.closeAll();
    expect(await AppCache.read(area), hasLength(1));
    expect(await ChatMessageCache.load('private_1'), hasLength(1));
  });

  test('AC-11 an empty list never wipes a copy; allowEmpty does', () async {
    await AppCache.write(area, rows(2));
    expect(await AppCache.write(area, const []), isFalse);
    expect(await AppCache.read(area), hasLength(2));
    await AppCache.write(area, const [], allowEmpty: true);
    expect(await AppCache.read(area), isEmpty);
  });

  test('AC-12 scheduleWrite: snapshot now, last call wins', () async {
    final live = rows(1);
    AppCache.scheduleWrite(area, () => List.of(live));
    live.add({'id': 2}); // later change, not in the first snapshot
    AppCache.scheduleWrite(area, () => List.of(live));
    await AppCache.flushPendingWrites();
    expect((await AppCache.read(area)).map((m) => m['id']), [1, 2]);
  });

  test('SC-06 logout while a write is pending: nothing reaches the next '
      "user's box", () async {
    AppCache.scheduleWrite(area, () => rows(2)); // user A, pending
    await ChatMessageCache.clearAll(); // logout
    env.user = '999'; // user B logs in
    await AppCache.flushPendingWrites();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(await AppCache.read(area), isEmpty);
  });

  test('AC-13 write with a stale uid / generation is refused', () async {
    expect(await AppCache.write(area, rows(1), uid: 'someone-else'), isFalse);
    expect(
        await AppCache.write(area, rows(1),
            generation: AppCache.generation - 1),
        isFalse);
    expect(await AppCache.read(area), isEmpty);
  });

  test('AC-14 a large list (> 64 KB) is decoded off the UI thread', () async {
    final big = [
      for (var i = 0; i < 900; i++)
        {'id': i, 'name': 'Contact $i', 'mobileNo': '98765${i.toString().padLeft(5, '0')}', 'pad': 'x' * 60}
    ];
    await AppCache.write(AppCache.fgContacts, big);
    final back = await AppCache.read(AppCache.fgContacts);
    expect(back, hasLength(900));
    expect(back.last['id'], 899);
  });

  test('AC-15 mergeCachedIntoLive: live wins, newer cached wins, new list',
      () {
    final live = [
      {'id': 1, 't': 5},
      {'id': 2, 't': 1},
    ];
    final cached = [
      {'id': 1, 't': 3}, // older than live → ignored
      {'id': 2, 't': 9}, // newer than live → wins
      {'id': 3, 't': 1}, // missing → added
    ];
    final out = AppCache.mergeCachedIntoLive<Map<String, int>>(
      live: live,
      cached: cached,
      keyOf: (m) => '${m['id']}',
      isNewer: (c, l) => c['t']! > l['t']!,
    );
    expect(identical(out, live), isFalse);
    expect(out.map((m) => m['t']), [5, 9, 1]);
    expect(live.map((m) => m['t']), [5, 1]); // input untouched
  });

  test('AC-16 data at rest is encrypted (no plain text in the file)',
      () async {
    await AppCache.write(area, [
      {'id': 1, 'name': 'secret-group-77', 'mobileNo': '9876543210'}
    ]);
    await env.closeAll();
    final bytes = File('${env.dir.path}/app_cache_${AppCacheTestEnv.me}.hive')
        .readAsBytesSync();
    final text = latin1.decode(bytes, allowInvalid: true);
    expect(text.contains('secret-group-77'), isFalse);
    expect(text.contains('9876543210'), isFalse);
  });

  test('AC-17 no logged-in user: nothing read or written', () async {
    env.user = null;
    expect(await AppCache.write(area, rows(1)), isFalse);
    expect(await AppCache.read(area), isEmpty);
    AppCache.scheduleWrite(area, () => rows(1));
    await AppCache.flushPendingWrites();
  });

  test('AC-18 clearArea drops one area only', () async {
    await AppCache.write(area, rows(1));
    await AppCache.write(AppCache.banners, rows(1));
    await AppCache.clearArea(area);
    expect(await AppCache.read(area), isEmpty);
    expect(await AppCache.read(AppCache.banners), hasLength(1));
  });

  test('AC-19 readAs skips rows that fail to parse', () async {
    await AppCache.write(area, [
      {'id': 1},
      {'id': 'bad'},
      {'id': 3},
    ]);
    final ids = await AppCache.readAs<int>(area, (m) => m['id'] as int);
    expect(ids, [1, 3]);
  });

  test('AC-20 warmUp opens the box, never throws without a user', () async {
    await AppCache.warmUp();
    env.user = null;
    await AppCache.warmUp();
    SharedPreferences.setMockInitialValues({});
  });
}
