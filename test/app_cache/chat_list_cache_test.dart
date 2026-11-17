// Chat list + Archived on the app cache (doc 07 §3.1) and the socket rules
// (SC-xx). The controller runs without a server: its API calls fail, which
// is also the "offline" case.
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_cache_codec.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

Map<String, dynamic> row({
  int userId = 505,
  int chatId = 2001,
  String name = 'Sarah',
  String content = 'hello',
  String time = '2026-11-01T10:00:00Z',
  int messageId = 1,
  int? unread,
  bool? archived,
}) =>
    {
      'id': chatId,
      'chatId': chatId,
      'userId': userId,
      'name': name,
      'chatType': 'private',
      'isGroup': false,
      if (unread != null) 'unreadCount': unread,
      if (archived != null) 'isArchived': archived,
      'lastMessage': {
        'id': messageId,
        'content': content,
        'messageType': 'text',
        'senderId': '$userId',
        'timestamp': time,
      },
    };

Map<String, dynamic> cached(Map<String, dynamic> json) =>
    ChatListCacheCodec.encode(PrivateChatModel.fromJson(json));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppCacheTestEnv env;

  setUp(() async {
    Get.reset();
    env = await AppCacheTestEnv.create();
    SharedPreferences.setMockInitialValues(
        {PrefConst.userId: AppCacheTestEnv.me});
    Global.storageServices = await StorageServices().init();
  });

  tearDown(() async {
    // Close controllers (onClose) so none of them writes into the next
    // test's cache; Get.reset alone keeps them alive.
    await Get.deleteAll(force: true);
    Get.reset();
    await env.dispose();
  });

  Future<ChatListController> open() async {
    final c = Get.put(ChatListController());
    await c.debugShowCachedChatList();
    // Let the (failing) API calls of onInit finish.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return c;
  }

  test('CL-01 codec round trip is lossless (preview, last message, flags)',
      () {
    final m = PrivateChatModel.fromJson({
      ...row(unread: 3),
      'isGroup': true,
      'chatType': 'group',
      'groupId': 77,
    })
      ..preview = 'You: built preview'
      ..isOnline = true
      ..isPinned = true;
    final back = ChatListCacheCodec.decode(ChatListCacheCodec.encode(m))!;
    expect(back.preview, 'You: built preview');
    expect(back.message, m.message);
    expect(back.unreadCount, 3);
    expect(back.isOnline, isTrue); // fromJson would force false for groups
    expect(back.isPinned, isTrue);
    expect(back.lastMessageData?['content'], 'hello');
    expect(ChatListCacheCodec.decode({'name': 'no id'}), isNull);
  });

  test('CL-02 cached rows show at once, without a server', () async {
    await AppCache.write(AppCache.chatList, [
      cached(row(userId: 1, chatId: 1)),
      cached(row(userId: 2, chatId: 2, time: '2026-11-01T11:00:00Z')),
    ]);
    final c = await open();
    expect(c.displayedChats.map((r) => r.userId), containsAll([1, 2]));
  });

  test('CL-03 failed refresh: cached rows stay, no endless loader '
      '(a 4xx is not "Couldn\'t refresh"; offline is RB-L03)', () async {
    await AppCache.write(AppCache.chatList, [cached(row())]);
    final c = await open();
    // flutter_test answers every request with 400: a real answer, not
    // "server not reached" (F-1.2.9), so no bar.
    await c.refreshChats(trigger: 'retry-tap');
    expect(c.refreshFailed.value, isFalse);
    expect(c.displayedChats, hasLength(1));
    expect(c.isLoading.value, isFalse); // never an endless loader
  });

  test('SC-01 socket event BEFORE the cache read finishes is kept (merge)',
      () async {
    await AppCache.write(AppCache.chatList, [
      cached(row(userId: 1, chatId: 1, content: 'old')),
      cached(row(userId: 2, chatId: 2)),
    ]);
    final c = Get.put(ChatListController());
    // Arrives while the cache is still being read.
    c.debugHandleChatUpdated(row(
        userId: 1,
        chatId: 1,
        content: 'live',
        messageId: 9,
        time: '2026-11-01T12:00:00Z'));
    await c.debugShowCachedChatList();
    final one = c.privateChats.firstWhere((r) => r.userId == 1);
    expect(one.message, 'live');
    expect(c.privateChats.where((r) => r.userId == 1), hasLength(1));
    expect(c.privateChats.any((r) => r.userId == 2), isTrue);
  });

  test('SC-02 socket event after the cache is shown updates UI AND cache',
      () async {
    await AppCache.write(AppCache.chatList, [cached(row(content: 'old'))]);
    final c = await open();
    c.debugHandleChatUpdated(row(
        content: 'new one', messageId: 5, time: '2026-11-01T12:00:00Z'));
    expect(c.displayedChats.single.message, 'new one');
    await AppCache.flushPendingWrites();
    final saved = await AppCache.readAs(
        AppCache.chatList, ChatListCacheCodec.decode);
    expect(saved.single.message, 'new one');
  });

  test('SC-03 an older cached row never overwrites newer live data',
      () async {
    final c = Get.put(ChatListController());
    c.debugHandleChatUpdated(
        row(content: 'newest', messageId: 9, time: '2026-11-01T12:00:00Z'));
    await AppCache.write(AppCache.chatList,
        [cached(row(content: 'stale', time: '2026-11-01T08:00:00Z'))]);
    await c.debugShowCachedChatList();
    expect(c.privateChats.single.message, 'newest');
  });

  test('SC-05 delete / clear events remove the row from UI and cache '
      '(main and Archived)', () async {
    await AppCache.write(AppCache.chatList, [
      cached(row(userId: 1, chatId: 1)),
      cached(row(userId: 2, chatId: 2)),
    ]);
    await AppCache.write(AppCache.chatArchived,
        [cached(row(userId: 3, chatId: 3, archived: true))]);
    final c = await open();
    c.debugHandleChatRemoved({'chatId': 1});
    c.debugHandleChatCleared({'chatId': 3});
    expect(c.privateChats.any((r) => r.id == 1), isFalse);
    expect(c.archivedChats, isEmpty);
    await AppCache.flushPendingWrites();
    final main = await AppCache.readAs(
        AppCache.chatList, ChatListCacheCodec.decode);
    expect(main.map((r) => r.id), [2]);
    expect(await AppCache.read(AppCache.chatArchived), isEmpty);
  });

  test('SC-08 unread: cached 5, server list says 2 → shows 2', () async {
    await AppCache.write(AppCache.chatList, [cached(row(unread: 5))]);
    final c = await open();
    expect(c.displayedChats.single.unreadCount, 5); // first paint
    c.debugHandleFullChatList({
      'data': [row(unread: 2)]
    });
    expect(c.displayedChats.single.unreadCount, 2);
  });

  test('CL-04 a bad Archived payload never wipes Archive', () async {
    await AppCache.write(AppCache.chatArchived,
        [cached(row(userId: 3, chatId: 3, archived: true))]);
    final c = await open();
    c.debugHandleArchivedChats('not a map');
    c.debugHandleArchivedChats({'data': 'not a list'});
    expect(c.archivedChats, hasLength(1));
  });

  test('CL-05 an early 1-row change never overwrites the saved 50 rows',
      () async {
    await AppCache.write(AppCache.chatList, [
      for (var i = 1; i <= 30; i++) cached(row(userId: i, chatId: i)),
    ]);
    final c = Get.put(ChatListController());
    c.debugHandleChatUpdated(row(userId: 99, chatId: 99)); // before read
    await AppCache.flushPendingWrites();
    expect(await AppCache.read(AppCache.chatList), hasLength(30));
    await c.debugShowCachedChatList();
    expect(c.privateChats.length, 31);
  });

  test('CL-06 cache version bump clears only the chat list', () async {
    await AppCache.write(AppCache.chatList, [cached(row())]);
    await AppCache.write(AppCache.groups, [{'id': 1}]);
    const bumped = AppCacheArea('chat_list', version: 2, maxItems: 50);
    expect(await AppCache.read(bumped), isEmpty);
    expect(await AppCache.read(AppCache.groups), hasLength(1));
  });
}
