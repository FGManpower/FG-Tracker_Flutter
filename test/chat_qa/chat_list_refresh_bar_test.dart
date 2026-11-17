// Chat list "Couldn't refresh · Retry" (F-1.2.9): RB-L01 … RB-L17 against a
// local fake API (test/chat_qa/fakes/fake_chat_api_server.dart). Sockets and
// real hosts are blocked; timeouts are shortened.
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_cache_codec.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_cache/app_cache_test_support.dart';
import 'fakes/fake_chat_api_server.dart';
import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:hive_ce/hive.dart';

const listPath = '/api/chat-list';

Map<String, dynamic> row(int id, {String content = 'hi', int minute = 0}) => {
      'id': id,
      'chatId': id,
      'userId': 500 + id,
      'name': 'User $id',
      'chatType': 'private',
      'isGroup': false,
      'lastMessage': {
        'id': id * 10,
        'content': content,
        'messageType': 'text',
        'senderId': '${500 + id}',
        'timestamp': DateTime.utc(2026, 11, 17, 10, minute).toIso8601String(),
      },
    };

Map<String, dynamic> page(List<Map<String, dynamic>> rows,
        {int current = 1, bool next = false}) =>
    {
      'status': true,
      'data': rows,
      'pagination': {'currentPage': current, 'hasNextPage': next},
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppCacheTestEnv env;
  late FakeChatApiServer api;
  late String oldBase;
  final flags = <bool>[];

  setUpAll(() {
    ChatScreenRules.historyTimeout = const Duration(milliseconds: 400);
    RefreshBarState.quietRetryDelay = const Duration(milliseconds: 150);
  });

  Future<void> login(String id) async {
    env.user = id;
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: id,
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-$id',
    });
    Global.storageServices = await StorageServices().init();
  }

  setUp(() async {
    HttpOverrides.global = LoopbackOnlyHttpOverrides();
    SocketMessageService.debugSocketUrlOverride = 'http://127.0.0.1:9';
    Get.reset();
    env = await AppCacheTestEnv.create();
    await login(AppCacheTestEnv.me);
    api = await FakeChatApiServer.start();
    oldBase = api.attach();
    api.routes['/api/archived'] = FakeRoute(body: {'status': true, 'data': []});
    api.routes['/api/chat/sync'] = FakeRoute(body: {'status': true, 'data': []});
    flags.clear();
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.reset();
    HttpUtil().api.sendRequest.options.baseUrl = oldBase;
    await api.close();
    await env.dispose();
    HttpOverrides.global = null;
    SocketMessageService.debugSocketUrlOverride = null;
  });

  Future<void> cacheRows(List<Map<String, dynamic>> rows) => AppCache.write(
      AppCache.chatList,
      [for (final r in rows) ChatListCacheCodec.encode(PrivateChatModel.fromJson(r))]);

  ChatListController open() {
    final c = Get.put(ChatListController());
    ever<bool>(c.refreshFailed, flags.add);
    return c;
  }

  Future<void> settle([int ms = 1500]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  test('RB-L01 API OK with cached rows: the bar never shows', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(body: page([row(1), row(2)]));
    final c = open();
    await settle();
    expect(c.privateChats.length, 2);
    expect(flags, isNot(contains(true)));
  });

  test('RB-L02 API OK, no cache: rows, no bar', () async {
    api.routes[listPath] = FakeRoute(body: page([row(1)]));
    final c = open();
    await settle();
    expect(c.privateChats.single.id, 1);
    expect(c.refreshFailed.value, isFalse);
  });

  test('RB-L03 offline with cached rows: quiet retry first, then the bar; '
      'rows stay', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(offline: true);
    final c = open();
    await settle(2500);
    expect(api.callsTo(listPath), greaterThanOrEqualTo(2),
        reason: 'the quiet retry ran');
    expect(c.refreshFailed.value, isTrue);
    expect(c.privateChats, isNotEmpty);
  });

  test('RB-L04 offline, no cache: full error (flag set, list empty)',
      () async {
    api.routes[listPath] = FakeRoute(offline: true);
    final c = open();
    await settle();
    expect(c.refreshFailed.value, isTrue);
    expect(c.displayedChats, isEmpty);
  });

  test('RB-L05 API slower than the timeout: the late answer is applied and '
      'no bar stays', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] =
        FakeRoute(body: page([row(1), row(2), row(3)]), delay: const Duration(milliseconds: 900));
    final c = open();
    await settle(2500);
    expect(c.privateChats.length, 3, reason: 'late answer applied');
    expect(c.refreshFailed.value, isFalse);
  });

  test('RB-L06 a row with a wrong field type: never "Couldn\'t refresh"',
      () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(body: {
      'status': true,
      'data': [
        row(1),
        {...row(2), 'name': 12345, 'unreadCount': 'abc', 'isPinned': 'maybe'},
      ],
      'pagination': {'currentPage': 1},
    });
    final c = open();
    await settle();
    expect(flags, isNot(contains(true)));
    expect(c.privateChats, isNotEmpty);
  });

  test('RB-L07 processing throws after API OK: no bar', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(body: page([row(1)]));
    final c = Get.put(ChatListController());
    c.debugAfterApi = () => throw StateError('bug after the answer');
    ever<bool>(c.refreshFailed, flags.add);
    await c.refreshChats(trigger: 'pull');
    await settle(500);
    expect(flags, isNot(contains(true)));
  });

  test('RB-L08 bar shown → incremental /chat/sync succeeds: the bar hides',
      () async {
    api.routes[listPath] = FakeRoute(body: page([row(1)]));
    final c = open();
    await settle(800); // loaded once (sets the sync time)
    api.routes[listPath]!.offline = true;
    await c.refreshChats(trigger: 'retry-tap'); // user retry fails → bar
    expect(c.refreshFailed.value, isTrue);
    c.debugResyncNow(); // resume: /chat/sync answers
    await settle(500);
    expect(api.callsTo('/api/chat/sync'), greaterThanOrEqualTo(1));
    expect(c.refreshFailed.value, isFalse);
  });

  test('RB-L09 bar shown → socket full list: the bar hides', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(offline: true);
    final c = open();
    await settle(2500);
    expect(c.refreshFailed.value, isTrue);
    c.debugHandleFullChatList(page([row(1), row(2)]));
    expect(c.refreshFailed.value, isFalse);
  });

  test('RB-L10 loaded once, then a background refetch fails: no bar',
      () async {
    api.routes[listPath] = FakeRoute(body: page([row(1)]));
    api.routes['/api/chat/sync'] = FakeRoute(offline: true);
    final c = open();
    await settle(800);
    api.routes[listPath]!.offline = true;
    c.debugResyncNow(); // sync fails → background full refetch fails
    await settle(1500);
    c.debugResyncNow(); // a second background failure
    await settle(1500);
    expect(c.refreshFailed.value, isFalse);
    expect(flags, isNot(contains(true)));
  });

  test('RB-L11 a failed search: own state, no main bar; search asks page 1',
      () async {
    api.routes[listPath] = FakeRoute(body: page([row(1)], next: true));
    final c = open();
    await settle(800);
    c.currentPage.value = 3; // scrolled before searching
    c.onSearchChanged('asha');
    await settle(800);
    final searchUri =
        api.requests.lastWhere((u) => u.queryParameters.containsKey('search'));
    expect(searchUri.queryParameters['page'], '1');
    api.routes[listPath]!.offline = true;
    c.onSearchChanged('ravi');
    await settle(800);
    expect(c.searchFailed.value, isTrue);
    expect(c.refreshFailed.value, isFalse);
  });

  test('RB-L12 API fails before the cache read: no instant error, the bar '
      'only after the quiet retry', () async {
    await cacheRows([row(1)]);
    await env.closeAll();
    final path = env.dir.path;
    ChatMessageCache.initHive = () async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      Hive.init(path);
    };
    api.routes[listPath] = FakeRoute(offline: true);
    final c = open();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(c.refreshFailed.value, isFalse, reason: 'no instant bar / error');
    await settle(2500);
    expect(c.privateChats, isNotEmpty);
    expect(flags.first, isTrue);
    expect(flags.where((f) => f), hasLength(1));
  });

  test('RB-L13 a socket update while the bar shows: row live + saved',
      () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(offline: true);
    final c = open();
    await settle(2500);
    expect(c.refreshFailed.value, isTrue);
    c.debugHandleChatUpdated(row(1, content: 'live!', minute: 30));
    expect(c.privateChats.first.message, 'live!');
    await AppCache.flushPendingWrites();
    final saved =
        await AppCache.readAs(AppCache.chatList, ChatListCacheCodec.decode);
    expect(saved.first.message, 'live!');
  });

  test('RB-L14 Retry tap: offline → bar at once; online → bar hides; no '
      'endless refresh indicator', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(body: page([row(1)]));
    final c = open();
    await settle(800);
    api.routes[listPath]!.offline = true;
    await c.refreshChats(trigger: 'retry-tap');
    expect(c.refreshFailed.value, isTrue);
    expect(c.isRefreshing.value, isFalse);
    api.routes[listPath]!.offline = false;
    await c.refreshChats(trigger: 'retry-tap');
    expect(c.refreshFailed.value, isFalse);
    expect(c.isRefreshing.value, isFalse);
  });

  test('RB-L15 page 2 fails: no bar, currentPage rolls back', () async {
    api.routes[listPath] = FakeRoute(body: page([row(1)], next: true));
    final c = open();
    await settle(800);
    expect(c.hasNextPage.value, isTrue);
    api.routes[listPath]!.offline = true;
    await c.nextPage();
    expect(c.currentPage.value, 1);
    expect(c.refreshFailed.value, isFalse);
  });

  test('RB-L16 logout → another user: no flag, no old rows', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(offline: true);
    final a = open();
    await settle(2500);
    expect(a.refreshFailed.value, isTrue);
    await Get.deleteAll(force: true);
    Get.reset();
    await login('202');
    api.routes[listPath] = FakeRoute(body: page([row(9)]));
    final b = Get.put(ChatListController());
    await settle(800);
    expect(b.refreshFailed.value, isFalse);
    expect(b.privateChats.map((r) => r.id), [9]);
  });

  test('RB-L17 401: no bar, no request loop', () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(status: 401, body: {'status': false});
    final c = open();
    await settle(2000);
    expect(c.refreshFailed.value, isFalse);
    expect(api.callsTo(listPath), lessThanOrEqualTo(2));
  });

  test('RB-L18 a 4xx (403) with rows on screen: never "Couldn\x27t refresh"',
      () async {
    await cacheRows([row(1)]);
    api.routes[listPath] = FakeRoute(status: 403, body: {'status': false});
    final c = open();
    await settle(2000);
    expect(c.refreshFailed.value, isFalse);
    expect(c.privateChats, isNotEmpty);
  });
}
