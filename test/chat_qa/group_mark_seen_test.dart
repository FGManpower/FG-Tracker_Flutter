// Run 2 (2026-11-17, F-1.2.5): the REAL GroupMessageController against the
// local fake Socket.IO server (fakes/fake_socket_io_server.dart).
//
//  * SL-MS-01..04  group `mark_seen`: exactly one per open, none on close when
//    nothing new was read, one (with the ids) for a message read while open.
//  * HC-26         after Back, a late API response can't overwrite the saved
//    copy (`_cacheFrozen`, GroupChatController.dart:85, 2126).
//  * GUARD-01      opening a group calls the API host. That is why every test
//    here blocks non-loopback hosts; a test that only sets
//    `HttpOverrides.global = null` sends real requests to PRODUCTION (T-07).
//
// No app code is changed: the controller reads Get.arguments and
// ConstRes.socketUrl, which a test can set.
import 'dart:io';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_socket_io_server.dart';

const me = '101';
const other = '202';
const groupId = 77;

/// Lets only loopback traffic through; every other host goes to a dead
/// proxy (connection refused) and is recorded.
class LoopbackOnlyHttp extends HttpOverrides {
  // Static: HttpUtil's Dio is a singleton that caches its HttpClient, so
  // the client made in the first test keeps reporting here.
  static final Set<String> blockedHosts = {};

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (uri) {
      final h = uri.host;
      if (h == '127.0.0.1' || h == 'localhost' || h == '::1') return 'DIRECT';
      blockedHosts.add(h);
      return 'PROXY 127.0.0.1:9';
    };
    return client;
  }
}

class MemoryKeyStore implements ChatCacheKeyStore {
  List<int>? key;
  @override
  Future<List<int>?> read() async => key;
  @override
  Future<void> write(List<int> k) async => key = List.of(k);
  @override
  Future<void> delete() async => key = null;
}

/// BuildContext without a Navigator: handleBackPressed runs its own steps,
/// then its `Navigator.of(context).pop()` throws, which the test ignores.
class NoNavigatorContext extends Fake implements BuildContext {}

MessageData groupMsg(int id, {String sender = other}) => MessageData.fromJson({
      'id': id,
      'groupId': groupId,
      'senderId': sender,
      'messageType': 'text',
      'content': 'm$id',
      'timestamp': DateTime.utc(2026, 11, 17, 9).add(Duration(minutes: id))
          .toIso8601String(),
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSocketIoServer server;
  late LoopbackOnlyHttp http;
  late Directory dir;

  List<FakeClientEvent> markSeen() =>
      server.receivedNamed('mark_seen', nsp: '/chat');

  Future<void> pause(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

  setUp(() async {
    http = LoopbackOnlyHttp();
    LoopbackOnlyHttp.blockedHosts.clear();
    HttpOverrides.global = http;
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: me,
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
    });
    Global.storageServices = await StorageServices().init();
    server = FakeSocketIoServer();
    await server.start();
    SocketMessageService.debugSocketUrlOverride = server.url;

    dir = await Directory.systemTemp.createTemp('group_seen_test');
    ChatMessageCache.keyStore = MemoryKeyStore();
    ChatMessageCache.currentUserId = () => me;
    ChatMessageCache.initHive = () async => Hive.init(dir.path);

    Get.routing.args = {'groupId': groupId, 'groupName': 'QA-Group'};
  });

  tearDown(() async {
    if (Get.isRegistered<GroupMessageController>()) {
      Get.delete<GroupMessageController>(force: true);
    }
    SocketMessageService.instance.disconnectAll();
    await pause(100);
    await server.stop();
    await ChatMessageCache.resetForTest();
    await Hive.close();
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
    Get.reset();
    HttpOverrides.global = null;
    SocketMessageService.debugSocketUrlOverride = null;
  });

  Future<GroupMessageController> openGroup() async {
    final c = Get.put(GroupMessageController());
    expect(await waitFor(() => SocketMessageService.instance.isSocketConnected),
        isTrue,
        reason: '/chat should connect to the fake server');
    return c;
  }

  Future<void> closeGroup() async {
    Get.delete<GroupMessageController>(force: true);
    await pause(300);
  }

  test('SL-MS-01 one group open sends exactly one mark_seen', () async {
    await openGroup();
    expect(await waitFor(() => markSeen().isNotEmpty), isTrue);
    await pause(1500); // history attempt + any late duplicate
    expect(markSeen(), hasLength(1));
    final p = markSeen().single.data as Map;
    expect(p['groupId'], groupId);
    expect(p['readAt'], isNotNull);
  });

  test('SL-MS-02 closing with nothing new read sends no mark_seen', () async {
    await openGroup();
    expect(await waitFor(() => markSeen().isNotEmpty), isTrue);
    await pause(800);
    final before = markSeen().length;
    await closeGroup();
    expect(markSeen().length, before);
  });

  test('SL-MS-03 open / close 5 times: 5 mark_seen, one per open', () async {
    for (var i = 1; i <= 5; i++) {
      await openGroup();
      expect(await waitFor(() => markSeen().length >= i), isTrue,
          reason: 'open #$i');
      await pause(400);
      await closeGroup();
    }
    await pause(500);
    expect(markSeen(), hasLength(5));
  });

  test('SL-MS-04 a message read while open: one mark_seen with its id, '
      'then none on close', () async {
    await openGroup();
    expect(await waitFor(() => markSeen().isNotEmpty), isTrue);
    await pause(500);
    server.emit('/chat', 'receive_group_message', {
      'id': 500,
      'groupId': groupId,
      'senderId': int.parse(other),
      'content': 'hello',
      'messageType': 'text',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    // 400 ms debounce in the controller.
    expect(await waitFor(() => markSeen().length >= 2), isTrue,
        reason: 'the new message should be marked read');
    await pause(600);
    expect(markSeen(), hasLength(2));
    expect((markSeen().last.data as Map)['messageIds'], [500]);

    await closeGroup();
    expect(markSeen(), hasLength(2), reason: 'nothing new since the last one');
  });

  test('HC-26 after Back, a late API response cannot overwrite the saved 50',
      () async {
    final c = await openGroup();
    final key = ChatMessageCache.groupKey(groupId);
    // 60 messages on screen -> save of the newest 50 is scheduled (1 s).
    c.messageData.addAll([for (var i = 1; i <= 60; i++) groupMsg(i)]);
    c.updateMessageStream();

    try {
      c.handleBackPressed(NoNavigatorContext());
    } catch (_) {
      // Only the final Navigator.pop fails; Back's own steps already ran.
    }
    expect(c.messageData, isEmpty, reason: 'Back clears the list');

    // A late page-1 API response lands after Back (5 messages).
    c.messageData.addAll([for (var i = 56; i <= 60; i++) groupMsg(i)]);
    c.updateMessageStream();

    await pause(2500); // scheduled save (1 s) + Hive write
    final saved = (await ChatMessageCache.load(key)).map((m) => m.id).toList();
    expect(saved, hasLength(ChatMessageCache.maxMessages));
    expect(saved.first, 11);
    expect(saved.last, 60);
  });

  test('GUARD-01 opening a group calls the API host (blocked here)', () async {
    await openGroup();
    await pause(1500);
    final apiHost = Uri.parse(ConstRes.aBaseUrl).host;
    expect(LoopbackOnlyHttp.blockedHosts, contains(apiHost),
        reason: 'without this guard the request would reach $apiHost');
  });
}
