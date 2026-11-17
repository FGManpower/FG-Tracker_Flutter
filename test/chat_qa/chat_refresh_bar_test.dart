// Regression (F-1.2.8): inside an open chat the "Couldn't refresh · Retry"
// bar appeared ~10 s after opening when the history request was slow or
// failed once, although the chat kept working. Now one quiet retry runs
// first; the bar shows only if that fails too. An empty chat still gets the
// full error at once. Same rules in the private chat (MessageController).
import 'dart:io';

import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import '../app_cache/app_cache_test_support.dart';
import 'fakes/fake_chat_api_server.dart';
import 'package:hive_ce/hive.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every non-loopback host goes to a dead proxy: the history API fails fast,
/// like a phone without network (same as group_open_during_build_test).
class _NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)..findProxy = (_) => 'PROXY 127.0.0.1:9';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    HttpOverrides.global = _NoNetwork();
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: '1',
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
    });
    Global.storageServices = await StorageServices().init();
    SocketMessageService.debugSocketUrlOverride = 'http://127.0.0.1:9';
  });

  tearDown(() {
    SocketMessageService.instance.disconnectAll();
    Get.reset();
    HttpOverrides.global = null;
    SocketMessageService.debugSocketUrlOverride = null;
  });

  MessageData msg(int id) => MessageData.fromJson({
        'id': id,
        'senderId': '2',
        'content': 'cached $id',
        'timestamp': '2026-11-17T10:00:00Z',
      });

  /// Waits until [done] or [max].
  Future<void> waitFor(bool Function() done,
      {Duration max = const Duration(seconds: 15)}) async {
    final end = DateTime.now().add(max);
    while (!done() && DateTime.now().isBefore(end)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  test('RB-01 messages on screen: first failure is quiet, the bar shows only '
      'after the retry also fails', () async {
    final c = Get.put(GroupMessageController());
    c.messageData.add(msg(1)); // what the cache put on screen
    // First failure: no bar, a quiet retry is scheduled.
    await waitFor(() => c.debugHistoryFailures >= 1);
    expect(c.debugHistoryFailures, 1);
    expect(c.historyLoadFailed.value, isFalse,
        reason: 'no bar after one failure');
    // The quiet retry (2 s later) fails too → now the bar.
    await waitFor(() => c.debugHistoryFailures >= 2);
    expect(c.historyLoadFailed.value, isTrue);
    expect(c.messageData, isNotEmpty, reason: 'messages stay on screen');
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('RB-02 empty chat: the full error at once (as before)', () async {
    final c = Get.put(GroupMessageController());
    await waitFor(() => c.historyLoadFailed.value,
        max: const Duration(seconds: 12));
    expect(c.historyLoadFailed.value, isTrue);
    expect(c.messageData, isEmpty);
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('RB-03 Retry tapped by the user: a failure shows the bar at once',
      () async {
    final c = Get.put(GroupMessageController());
    c.messageData.add(msg(1));
    await waitFor(() => c.historyLoadFailed.value);
    expect(c.historyLoadFailed.value, isTrue);
    final tapped = DateTime.now();
    final retry = c.retryLoadHistory();
    expect(c.historyLoadFailed.value, isFalse); // hidden while retrying
    await retry;
    expect(c.historyLoadFailed.value, isTrue);
    expect(DateTime.now().difference(tapped).inSeconds, lessThan(12),
        reason: 'no extra quiet retry after a user Retry');
  }, timeout: const Timeout(Duration(seconds: 60)));

  // ---------------------------------------------------------------------
  // F-1.2.9: RB-C01 … RB-C17 against a local fake API (private + group).
  // ---------------------------------------------------------------------
  group('RB-C (fake API)', () {
    late AppCacheTestEnv env;
    late FakeChatApiServer api;
    late String oldBase;
    final flags = <bool>[];
    const groupId = 77;
    const peer = '202';
    const chatId = 5001;
    const groupPath = '/api/getGroupMessageHistory';
    const privatePath = '/api/private-chat/$chatId/messages';
    const peerPath = '/api/private-chat/peer/$peer/messages';

    Map<String, dynamic> m(int id, {String sender = '2'}) => {
          'id': id,
          'senderId': sender,
          'content': 'server $id',
          'messageType': 'text',
          'timestamp': DateTime.utc(2026, 11, 17, 10, id % 60).toIso8601String(),
        };
    Map<String, dynamic> history(List<int> ids, {Object? chat}) => {
          'status': true,
          'data': [for (final i in ids) m(i)],
          'pagination': {'currentPage': 1, 'hasNextPage': false},
          if (chat != null) 'chatId': chat,
        };

    setUpAll(() {
      ChatScreenRules.historyTimeout = const Duration(milliseconds: 400);
      RefreshBarState.quietRetryDelay = const Duration(milliseconds: 150);
    });
    tearDownAll(() {
      ChatScreenRules.historyTimeout = const Duration(seconds: 10);
      RefreshBarState.quietRetryDelay = const Duration(seconds: 2);
    });

    setUp(() async {
      HttpOverrides.global = LoopbackOnlyHttpOverrides();
      env = await AppCacheTestEnv.create();
      env.user = '1';
      api = await FakeChatApiServer.start();
      oldBase = api.attach();
      flags.clear();
    });

    tearDown(() async {
      await Get.deleteAll(force: true);
      HttpUtil().api.sendRequest.options.baseUrl = oldBase;
      await api.close();
      await env.dispose();
    });

    Future<void> cacheGroup(List<int> ids) => ChatMessageCache.save(
        ChatMessageCache.groupKey(groupId), [for (final i in ids) msg(i)]);
    Future<void> cachePrivate(List<int> ids) => ChatMessageCache.save(
        ChatMessageCache.privateKey(peer), [for (final i in ids) msg(i)]);

    GroupMessageController openGroup() {
      Get.routing.args = {'groupId': groupId, 'groupName': 'QA'};
      final c = Get.put(GroupMessageController());
      ever<bool>(c.historyLoadFailed, flags.add);
      return c;
    }

    MessageController openPrivate({bool withChatId = true}) {
      Get.routing.args = {
        'userData': MemberData(userId: int.parse(peer), name: 'Peer'),
        if (withChatId) 'chatId': chatId,
        'type': 'chatScreen',
        'chatType': 'private',
      };
      final c = Get.put(MessageController());
      ever<bool>(c.historyLoadFailed, flags.add);
      return c;
    }

    Future<void> settle([int ms = 1500]) =>
        Future<void>.delayed(Duration(milliseconds: ms));

    /// Closes Hive; the next cache read waits 400 ms (a slow phone).
    Future<void> slowCacheOpen() async {
      await env.closeAll();
      final path = env.dir.path;
      ChatMessageCache.initHive = () async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        Hive.init(path);
      };
    }

    // ---------------- both screens ----------------
    for (final kind in ['group', 'private']) {
      final isGroup = kind == 'group';
      String path() => isGroup ? groupPath : privatePath;
      Future<void> cache(List<int> ids) =>
          isGroup ? cacheGroup(ids) : cachePrivate(ids);
      dynamic open() => isGroup ? openGroup() : openPrivate();
      bool failed(dynamic c) => (c.historyLoadFailed as RxBool).value;
      List<MessageData> msgs(dynamic c) => c.messageData as List<MessageData>;

      test('RB-C01 [$kind] history OK with cache: the bar never shows',
          () async {
        await cache([1, 2]);
        api.routes[path()] = FakeRoute(body: history([1, 2, 3]));
        final c = open();
        await settle();
        expect(msgs(c).length, 3);
        expect(flags, isNot(contains(true)));
      });

      test('RB-C02 [$kind] history OK, no cache: no bar, no error', () async {
        api.routes[path()] = FakeRoute(body: history([1]));
        final c = open();
        await settle();
        expect(msgs(c), hasLength(1));
        expect(failed(c), isFalse);
      });

      test('RB-C06 [$kind] API fails before the cache read: no instant bar',
          () async {
        await cache([1]);
        await slowCacheOpen(); // the API failure arrives first
        api.routes[path()] = FakeRoute(offline: true);
        final c = open();
        int? callsAtFirstFlag;
        ever<bool>(c.historyLoadFailed as RxBool, (v) {
          if (v) callsAtFirstFlag ??= api.callsTo(path());
        });
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(failed(c), isFalse);
        await settle(2000);
        expect(msgs(c), isNotEmpty);
        expect(flags.where((f) => f), hasLength(1),
            reason: 'bar only after the quiet retry, once');
        expect(callsAtFirstFlag, greaterThanOrEqualTo(2),
            reason: 'never an instant error before the cache showed');
      });

      test('RB-C10 [$kind] processing throws after the answer: never '
          '"Couldn\'t refresh"', () async {
        await cache([1]);
        api.routes[path()] = FakeRoute(body: history([1, 2]));
        final c = open();
        c.debugAfterApi = () => throw StateError('bug');
        await settle();
        expect(flags, isNot(contains(true)));
      });

      test('RB-C11 [$kind] API slower than the timeout: the late answer is '
          'applied, no bar stays', () async {
        await cache([1]);
        api.routes[path()] =
            FakeRoute(body: history([1, 2, 3]), delay: const Duration(milliseconds: 900));
        final c = open();
        await settle(2500);
        expect(msgs(c).length, 3);
        expect(failed(c), isFalse);
      });

      test('RB-C13 [$kind] offline with cache: the bar only after the quiet '
          'retry fails; messages stay', () async {
        await cache([1]);
        api.routes[path()] = FakeRoute(offline: true);
        final c = open();
        await settle(2000);
        expect(api.callsTo(path()), greaterThanOrEqualTo(2));
        expect(failed(c), isTrue);
        expect(msgs(c), isNotEmpty);
      });

      test('RB-C14 [$kind] offline, empty: full error at once', () async {
        api.routes[path()] = FakeRoute(offline: true);
        final c = open();
        await settle(800);
        expect(failed(c), isTrue);
        expect(msgs(c), isEmpty);
        expect(api.callsTo(path()), 1, reason: 'no quiet retry when empty');
      });

      test('RB-C15 [$kind] Retry fails → bar at once; succeeds → hides',
          () async {
        await cache([1]);
        api.routes[path()] = FakeRoute(body: history([1]));
        final c = open();
        await settle(800);
        api.routes[path()]!.offline = true;
        await c.retryLoadHistory();
        await waitFor(() => failed(c), max: const Duration(seconds: 5));
        expect(failed(c), isTrue);
        api.routes[path()]!.offline = false;
        await c.retryLoadHistory();
        await waitFor(() => !failed(c), max: const Duration(seconds: 5));
        expect(failed(c), isFalse);
      });

      test('RB-C16 [$kind] Back while loading, then a late failure: nothing '
          'changes, the cache is not overwritten', () async {
        await cache([1, 2, 3]);
        api.routes[path()] = FakeRoute(
            delay: const Duration(milliseconds: 600), failTimes: 1, failStatus: 0);
        open();
        await settle(100);
        if (isGroup) {
          await Get.delete<GroupMessageController>(force: true);
        } else {
          await Get.delete<MessageController>(force: true);
        }
        await settle(1200);
        expect(flags, isNot(contains(true)));
        final saved = isGroup
            ? await ChatMessageCache.load(ChatMessageCache.groupKey(groupId))
            : await ChatMessageCache.load(ChatMessageCache.privateKey(peer));
        expect(saved.length, 3);
      });

      test('RB-C18 [$kind] a 4xx (403) with messages on screen: no bar',
          () async {
        await cache([1]);
        api.routes[path()] =
            FakeRoute(status: 403, body: {'status': false});
        final c = open();
        await settle(2000);
        expect(failed(c), isFalse);
        expect(msgs(c), isNotEmpty);
      });

      test('RB-C17 [$kind] a new message while the bar shows: shown at once '
          'and saved', () async {
        await cache([1]);
        api.routes[path()] = FakeRoute(offline: true);
        final c = open();
        await settle(2000);
        expect(failed(c), isTrue);
        // Same path as a socket receive: add + updateMessageStream (R1, R2).
        msgs(c).add(msg(99));
        c.updateMessageStream();
        await settle(1300); // the 1 s debounced cache save
        final saved = isGroup
            ? await ChatMessageCache.load(ChatMessageCache.groupKey(groupId))
            : await ChatMessageCache.load(ChatMessageCache.privateKey(peer));
        expect(saved.map((e) => e.id), contains(99));
      });
    }

    // ---------------- private only ----------------
    test('RB-C03 [private] new chat by peer, no chatId, socket never joins: '
        'no error, "No messages here yet"', () async {
      api.routes[peerPath] = FakeRoute(body: {'status': true, 'data': []});
      final c = openPrivate(withChatId: false);
      await settle(1500); // > the (shortened) join timeout
      expect(c.historyLoadFailed.value, isFalse);
      expect(c.messageData, isEmpty);
      expect(c.isLoadingInitialMessages.value, isFalse);
    });

    test('RB-C04 [private] then the first message: no bar', () async {
      api.routes[peerPath] = FakeRoute(body: {'status': true, 'data': []});
      final c = openPrivate(withChatId: false);
      await settle(1500);
      c.messageData.add(msg(1));
      c.updateMessageStream();
      expect(c.historyLoadFailed.value, isFalse);
      expect(flags, isNot(contains(true)));
    });

    test('RB-C09 [private] 404 by peer (no conversation yet): empty chat, no '
        'error, no bar', () async {
      api.routes[peerPath] =
          FakeRoute(status: 404, body: {'status': false, 'message': 'not found'});
      final c = openPrivate(withChatId: false);
      await settle(1500);
      expect(c.historyLoadFailed.value, isFalse);
      expect(c.debugHistoryFailures, 0);
    });

    test('RB-C07 [private] bar shown → re-join gap fill OK: the bar hides',
        () async {
      await cachePrivate([1]);
      api.routes[privatePath] = FakeRoute(body: history([1, 2]));
      final c = openPrivate();
      await settle(800); // loaded once
      api.routes[privatePath]!.offline = true;
      await c.retryLoadHistory(); // user retry fails → bar
      await waitFor(() => c.historyLoadFailed.value,
          max: const Duration(seconds: 5));
      expect(c.historyLoadFailed.value, isTrue);
      api.routes[privatePath]!.offline = false;
      await c.syncNewerMessages(); // what a socket re-join runs
      expect(c.historyLoadFailed.value, isFalse);
    });

    // ---------------- group only ----------------
    test('RB-C08 [group] bar shown → /chat reconnect: history loads once, the '
        'bar hides', () async {
      await cacheGroup([1]);
      api.routes[groupPath] = FakeRoute(offline: true);
      final c = openGroup();
      await settle(2000);
      expect(c.historyLoadFailed.value, isTrue);
      api.routes[groupPath]!.offline = false;
      final before = api.callsTo(groupPath);
      c.debugOnSocketConnect();
      await waitFor(() => !c.historyLoadFailed.value,
          max: const Duration(seconds: 5));
      await settle(200);
      expect(api.callsTo(groupPath) - before, 1);
      expect(c.historyLoadFailed.value, isFalse);
    });

    test('RB-C12 [group] reconnect while the first load runs: only 1 request',
        () async {
      api.routes[groupPath] =
          FakeRoute(body: history([1]), delay: const Duration(milliseconds: 300));
      final c = openGroup();
      await settle(50);
      c.debugOnSocketConnect(); // the first /chat connect during the load
      c.debugOnSocketConnect();
      await settle(800);
      expect(api.callsTo(groupPath), 1);
      expect(c.debugHistoryRequests, 1);
    });
  });
}
