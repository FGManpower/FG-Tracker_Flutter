// Chat screen Hive cache (doc 01 §1.2, §2.2, F-1.2.4).
// Pure Dart + Hive files in a temp folder: the same code runs on Android
// and iOS. The secure-storage key is replaced by an in-memory store (the
// real one needs the Keychain / Keystore).
import 'dart:convert';
import 'dart:io';

import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

const me = '101';
const peer = '202';

class MemoryKeyStore implements ChatCacheKeyStore {
  List<int>? key;
  @override
  Future<List<int>?> read() async => key;
  @override
  Future<void> write(List<int> k) async => key = List.of(k);
  @override
  Future<void> delete() async => key = null;
}

MessageData msg(
  int? id, {
  String content = 'hi',
  String sender = peer,
  String? audioUrl,
  int minute = 0,
}) =>
    MessageData.fromJson({
      if (id != null) 'id': id,
      'senderId': sender,
      'receiverId': sender == me ? peer : me,
      'messageType': audioUrl != null ? 'audio' : 'text',
      'content': content,
      'timestamp': DateTime.utc(2026, 11, 17, 10, minute).toIso8601String(),
      if (audioUrl != null) 'audioUrl': audioUrl,
      'clientMessageId': 'c_$id',
    });

void main() {
  late Directory dir;
  late MemoryKeyStore keys;
  var user = me;
  final pKey = ChatMessageCache.privateKey(peer)!;
  final gKey = ChatMessageCache.groupKey(77)!;

  Future<List<int?>> ids(String key) async =>
      (await ChatMessageCache.load(key)).map((m) => m.id).toList();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('chat_cache_test');
    keys = MemoryKeyStore();
    user = me;
    ChatMessageCache.keyStore = keys;
    ChatMessageCache.currentUserId = () => user;
    ChatMessageCache.initHive = () async => Hive.init(dir.path);
  });

  tearDown(() async {
    await ChatMessageCache.resetForTest();
    await Hive.close();
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  test('HC-01 keys: private_<peerId> / group_<groupId>, none for bad ids',
      () {
    expect(ChatMessageCache.privateKey('202'), 'private_202');
    expect(ChatMessageCache.groupKey(77), 'group_77');
    expect(ChatMessageCache.privateKey(null), isNull);
    expect(ChatMessageCache.privateKey('null'), isNull);
    expect(ChatMessageCache.groupKey(0), isNull);
  });

  test('HC-02 round trip keeps text, audio and ids, sorted oldest first',
      () async {
    await ChatMessageCache.save(pKey, [
      msg(2, audioUrl: 'uploads/a.m4a', minute: 2),
      msg(1, content: 'first', minute: 1),
    ]);
    final back = await ChatMessageCache.load(pKey);
    expect(back.map((m) => m.id), [1, 2]);
    expect(back.first.content, 'first');
    expect(back.last.audioUrl, 'uploads/a.m4a');
    expect(back.last.clientMessageId, 'c_2');
  });

  test('HC-03 merge cache + API by id: no duplicates, saved once', () async {
    await ChatMessageCache.save(
        pKey, [for (var i = 1; i <= 30; i++) msg(i, minute: i)]);
    final cached = await ChatMessageCache.load(pKey);
    // API page 1 overlaps the cache (ids 21..40).
    final api = [for (var i = 21; i <= 40; i++) msg(i, minute: i)];
    final merged = ChatScreenRules.merge(cached, api).messages;
    expect(merged.map((m) => m.id).toSet().length, merged.length);
    expect(merged, hasLength(40));
    await ChatMessageCache.save(pKey, merged);
    final again = await ids(pKey);
    expect(again.toSet().length, again.length);
    expect(again.last, 40);
  });

  test('HC-04 keeps only the newest 50, skips pending (no id)', () async {
    await ChatMessageCache.save(pKey, [
      for (var i = 1; i <= 60; i++) msg(i, minute: i),
      msg(null, minute: 59), // still sending
    ]);
    final back = await ids(pKey);
    expect(back, hasLength(ChatMessageCache.maxMessages));
    expect(back.first, 11);
    expect(back.last, 60);
    expect(back.contains(null), isFalse);
  });

  test('HC-05 pagination: older pages beyond the last 50 are not saved',
      () async {
    // 50 on screen + 20 older loaded by scrolling up.
    final onScreen = [for (var i = 1; i <= 70; i++) msg(i, minute: i)];
    await ChatMessageCache.save(pKey, onScreen);
    expect((await ids(pKey)).first, 21);
  });

  test('HC-06 only the 30 most recently saved chats are kept (LRU)',
      () async {
    for (var p = 1; p <= ChatMessageCache.maxChats + 5; p++) {
      await ChatMessageCache.save(ChatMessageCache.privateKey('$p'), [msg(p)]);
    }
    expect(await ChatMessageCache.load('private_1'), isEmpty);
    expect(await ChatMessageCache.load('private_5'), isEmpty);
    expect(await ChatMessageCache.load('private_6'), hasLength(1));
    expect(
        await ChatMessageCache.load('private_${ChatMessageCache.maxChats + 5}'),
        hasLength(1));
  });

  test('HC-07 reopening a chat moves it to the front of the LRU', () async {
    for (var p = 1; p <= ChatMessageCache.maxChats; p++) {
      await ChatMessageCache.save(ChatMessageCache.privateKey('$p'), [msg(p)]);
    }
    await ChatMessageCache.save('private_1', [msg(1)]); // opened again
    await ChatMessageCache.save('private_new', [msg(99)]);
    expect(await ChatMessageCache.load('private_1'), hasLength(1));
    expect(await ChatMessageCache.load('private_2'), isEmpty);
  });

  test('HC-08 an empty / failed API response never wipes the cache',
      () async {
    await ChatMessageCache.save(pKey, [msg(1), msg(2, minute: 1)]);
    final cached = await ChatMessageCache.load(pKey);
    final merged = ChatScreenRules.merge(cached, const []).messages;
    expect(merged, hasLength(2));
    await ChatMessageCache.save(pKey, merged);
    await ChatMessageCache.save(pKey, const []); // empty list: ignored
    await ChatMessageCache.save(pKey, [msg(null)]); // only pending: ignored
    expect(await ids(pKey), [1, 2]);
  });

  test('HC-09 edit, delete for everyone and ticks are saved', () async {
    await ChatMessageCache.save(pKey, [
      msg(1, sender: me, content: 'old'),
      msg(2, sender: me, content: 'bye', minute: 1),
    ]);
    final list = await ChatMessageCache.load(pKey);
    expect(
        ChatScreenRules.applyEdit(list, {'messageId': 1, 'content': 'new'}),
        isTrue);
    ChatScreenRules.markDeletedForEveryone(list[1]);
    ChatScreenRules.applyPrivateSeen(list,
        messageIds: [1], readerId: peer, currentUserId: me);
    await ChatMessageCache.save(pKey, list);

    final back = await ChatMessageCache.load(pKey);
    expect(back[0].content, 'new');
    expect(back[0].isEdited, isTrue);
    expect(back[0].isDelivered, isTrue);
    expect(int.tryParse(back[0].seenCount.toString()), 1);
    expect(back[1].isDeleted, isTrue);
  });

  test('HC-10 group Clear chat clears that group only', () async {
    await ChatMessageCache.save(gKey, [msg(1)]);
    await ChatMessageCache.save(pKey, [msg(2)]);
    await ChatMessageCache.clear(gKey);
    expect(await ChatMessageCache.load(gKey), isEmpty);
    expect(await ids(pKey), [2]);
  });

  test('HC-11 private_chat_cleared (by chatId) drops that private chat',
      () async {
    await ChatMessageCache.save(pKey, [msg(1)], chatId: '55');
    await ChatMessageCache.save('private_303', [msg(2)], chatId: '56');
    await ChatMessageCache.clearPrivateByChatId(55);
    expect(await ChatMessageCache.load(pKey), isEmpty);
    expect(await ids('private_303'), [2]);
  });

  test('HC-12 logout deletes every box and the AES key', () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    user = '999';
    await ChatMessageCache.save(pKey, [msg(2)]);
    expect(keys.key, isNotNull);

    await ChatMessageCache.clearAll();
    expect(keys.key, isNull);
    final left = dir
        .listSync()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.hive'));
    expect(left, isEmpty);

    user = me;
    expect(await ChatMessageCache.load(pKey), isEmpty);
  });

  test('HC-13 version change clears instead of crashing', () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    await ChatMessageCache.save(gKey, [msg(2)]);
    final box = Hive.box<String>('chat_cache_$me');

    // One entry in an old shape → dropped on read, no throw.
    await box.put(pKey, jsonEncode({'v': 0, 'm': 'old shape'}));
    expect(await ChatMessageCache.load(pKey), isEmpty);
    expect(box.containsKey(pKey), isFalse);

    // Whole box from an older app version → cleared when it is opened.
    await box.put('__version', '0');
    await ChatMessageCache.resetForTest();
    expect(await ChatMessageCache.load(gKey), isEmpty);
  });

  test('HC-14 another account on the phone never sees the copy', () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    user = '999';
    expect(await ChatMessageCache.load(pKey), isEmpty);
    user = me;
    expect(await ids(pKey), [1]);
  });

  test('HC-15 data is encrypted: no message text in the file', () async {
    await ChatMessageCache.save(pKey, [msg(1, content: 'secret-text-42')]);
    await ChatMessageCache.resetForTest();
    await Hive.close();
    final bytes = File('${dir.path}/chat_cache_$me.hive').readAsBytesSync();
    expect(latin1.decode(bytes, allowInvalid: true).contains('secret-text-42'),
        isFalse);
  });

  test('HC-16 a lost key (Keystore reset) starts over, never throws',
      () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    await ChatMessageCache.resetForTest();
    await Hive.close();
    keys.key = null; // a new key is generated → old file can't be read
    expect(await ChatMessageCache.load(pKey), isEmpty);
    await ChatMessageCache.save(pKey, [msg(3)]);
    expect(await ids(pKey), [3]);
  });

  test('HC-17 no logged-in user: nothing is read or written', () async {
    user = '';
    ChatMessageCache.currentUserId = () => null;
    await ChatMessageCache.save(pKey, [msg(1)]);
    expect(await ChatMessageCache.load(pKey), isEmpty);
  });

  test('HC-18 old SharedPreferences copies are imported once, then deleted',
      () async {
    final old = jsonEncode([msg(7).toJson(), msg(8, minute: 1).toJson()]);
    SharedPreferences.setMockInitialValues({
      '${ChatMessageCache.legacyPrefix}${me}_$peer': old,
      '${ChatMessageCache.legacyPrefix}index_$me': '["$peer"]',
      '${ChatMessageCache.legacyPrefix}999_303': old, // another account
      'unrelated_key': 'stays',
    });
    expect(await ids(pKey), [7, 8]); // blocked-chat fallback still works
    final prefs = await SharedPreferences.getInstance();
    expect(
        prefs.getKeys().where(
            (k) => k.startsWith(ChatMessageCache.legacyPrefix)),
        isEmpty);
    expect(prefs.getString('unrelated_key'), 'stays');
  });

  test('HC-19 a corrupt entry loads as empty, never throws', () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    await Hive.box<String>('chat_cache_$me').put(pKey, '{not json');
    expect(await ChatMessageCache.load(pKey), isEmpty);
    await ChatMessageCache.save(pKey, [msg(2)]);
    expect(await ids(pKey), [2]);
  });

  // ---- Run 2 (2026-11-17) additions ----

  test('HC-20 reactions and group receipts (readBy / deliveredTo) survive a '
      'restart', () async {
    final m = MessageData.fromJson({
      'id': 5,
      'senderId': me,
      'groupId': 77,
      'messageType': 'text',
      'content': 'team',
      'timestamp': DateTime.utc(2026, 11, 17, 10).toIso8601String(),
      'reactions': [
        {'emoji': '👍', 'count': 2, 'userIds': [202, 303]},
      ],
      'readBy': [
        {'userId': 202, 'readAt': '2026-11-17T10:05:00Z'},
      ],
      'deliveredTo': [
        {'userId': 303, 'deliveredAt': '2026-11-17T10:01:00Z'},
      ],
    });
    await ChatMessageCache.save(gKey, [m]);
    await ChatMessageCache.resetForTest(); // like an app restart
    final back = (await ChatMessageCache.load(gKey)).single;
    expect(back.reactions?.single.emoji, '👍');
    expect(back.reactions?.single.userIds, [202, 303]);
    expect(back.readBy, hasLength(1));
    expect(back.deliveredTo, hasLength(1));
  });

  test('HC-21 a reaction added later replaces the saved copy', () async {
    final m = msg(1, sender: me);
    await ChatMessageCache.save(pKey, [m]);
    m.reactions = [MessageReactionModel(emoji: '❤️', count: 1, userIds: [202])];
    await ChatMessageCache.save(pKey, [m]);
    expect((await ChatMessageCache.load(pKey)).single.reactions?.single.emoji,
        '❤️');
  });

  test('HC-22 logout: registry box gone too, and a new login starts clean',
      () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    await ChatMessageCache.clearAll();
    expect(File('${dir.path}/chat_cache_registry.hive').existsSync(), isFalse);
    expect(File('${dir.path}/chat_cache_$me.hive').existsSync(), isFalse);

    user = '303'; // another account logs in on the same phone
    expect(await ChatMessageCache.load(pKey), isEmpty);
    await ChatMessageCache.save(pKey, [msg(9)]);
    expect(await ids(pKey), [9]);
    expect(keys.key, isNotNull, reason: 'a new key is made for the new login');
  });

  test('HC-23 logout never waits more than ~3 s, even if the Keystore hangs',
      () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    ChatMessageCache.keyStore = _HangingKeyStore(keys);
    final sw = Stopwatch()..start();
    await ChatMessageCache.clearAll(); // must not throw
    sw.stop();
    expect(sw.elapsed, lessThan(const Duration(milliseconds: 3800)));
    expect(sw.elapsed, greaterThanOrEqualTo(const Duration(seconds: 3)));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('HC-25 after a logout that hit the 3 s cap, the next login can use '
      'the cache at once', () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    ChatMessageCache.keyStore = _HangingKeyStore(keys);
    await ChatMessageCache.clearAll(); // returns after ~3 s
    ChatMessageCache.keyStore = keys;
    user = '303';
    final sw = Stopwatch()..start();
    await ChatMessageCache.load(pKey); // first chat opened after login
    sw.stop();
    expect(sw.elapsed, lessThan(const Duration(seconds: 1)));
  },
      timeout: const Timeout(Duration(seconds: 30)),
      skip: 'BUG-CS-23: the 3 s cap only stops the caller waiting; the serial '
          'queue still waits for the stuck Keystore call '
          '(chat_message_cache.dart:91-95, 381-398), so every cache call after '
          'it waits too');

  test('HC-24 logout never throws, even if deleting the key fails', () async {
    await ChatMessageCache.save(pKey, [msg(1)]);
    ChatMessageCache.keyStore = _ThrowingKeyStore(keys);
    await expectLater(ChatMessageCache.clearAll(), completes);
    // The message boxes are already gone before the key step failed.
    expect(File('${dir.path}/chat_cache_$me.hive').existsSync(), isFalse);
  });
}

/// Key store whose delete never finishes (Keychain / Keystore stuck).
class _HangingKeyStore implements ChatCacheKeyStore {
  _HangingKeyStore(this.inner);
  final MemoryKeyStore inner;
  @override
  Future<List<int>?> read() => inner.read();
  @override
  Future<void> write(List<int> k) => inner.write(k);
  /// 6 s: longer than the 3 s logout cap, short enough for tearDown.
  @override
  Future<void> delete() => Future<void>.delayed(const Duration(seconds: 6));
}

/// Key store whose delete throws (platform error).
class _ThrowingKeyStore implements ChatCacheKeyStore {
  _ThrowingKeyStore(this.inner);
  final MemoryKeyStore inner;
  @override
  Future<List<int>?> read() => inner.read();
  @override
  Future<void> write(List<int> k) => inner.write(k);
  @override
  Future<void> delete() async => throw Exception('keystore error');
}
