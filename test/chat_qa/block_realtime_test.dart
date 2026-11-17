// Real-time block / unblock (doc 01 §1.6, F-1.1.8) and the local chat copy
// that keeps old messages visible after a block. Pure Dart: the same code
// runs on Android and iOS (no platform channel involved).
import 'dart:async';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_socket_io_server.dart';

const me = '101';
const peer = '202';

MessageData msg(int? id, {String content = 'hi', String? audioUrl}) =>
    MessageData.fromJson({
      if (id != null) 'id': id,
      'senderId': peer,
      'receiverId': me,
      'messageType': audioUrl != null ? 'audio' : 'text',
      'content': content,
      'timestamp': '2026-11-17T10:00:00Z',
      if (audioUrl != null) 'audioUrl': audioUrl,
      'clientMessageId': 'c_$id',
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> prefs([Map<String, Object> extra = const {}]) async {
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: me,
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
      ...extra,
    });
    Global.storageServices = await StorageServices().init();
  }

  group('Block events from the server', () {
    late FakeSocketIoServer server;
    late SocketMessageService svc;
    late List<BlockStatusEvent> events;
    late List<String> touched;
    late StreamSubscription a;
    late StreamSubscription b;

    setUp(() async {
      HttpOverrides.global = null;
      Get.reset();
      // The rejected-send toast is a plugin call; answer it in tests.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('PonnamKarthik/fluttertoast'),
        (_) async => true,
      );
      await prefs();
      server = FakeSocketIoServer();
      await server.start();
      svc = SocketMessageService();
      events = [];
      touched = [];
      a = svc.blockStatusEvents.listen(events.add);
      b = svc.privateChatTouched.listen(touched.add);
      svc.initPrivateChatListSocket(server.url, userId: me);
      expect(await waitFor(() => svc.isPrivateChatListSocketConnected), isTrue);
    });

    tearDown(() async {
      await a.cancel();
      await b.cancel();
      svc.disconnectAll();
      await server.stop();
    });

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 200));

    test('BLK-01 user_blocked: peer blocked me', () async {
      server.emit('/privateChat', 'user_blocked',
          {'blockerId': 202, 'blockedUserId': 101});
      await settle();
      expect(events, hasLength(1));
      expect(events.single.blockerId, peer);
      expect(events.single.blockedId, me);
      expect(events.single.isBlocked, isTrue);
    });

    test('BLK-02 user_unblocked → isBlocked false', () async {
      server.emit('/privateChat', 'user_unblocked',
          {'blockerId': '202', 'blockedUserId': '101'});
      await settle();
      expect(events.single.isBlocked, isFalse);
    });

    test('BLK-03 alias event with action / aliased ids', () async {
      server.emit('/privateChat', 'block_status_changed',
          {'blockedBy': 202, 'blockedId': 101, 'action': 'unblock'});
      server.emit('/privateChat', 'block_status_updated',
          {'userId': 202, 'targetUserId': 101, 'isBlocked': 'true'});
      await settle();
      expect(events.map((e) => e.isBlocked), [false, true]);
    });

    test('BLK-04 payload without ids or state is ignored', () async {
      server.emit('/privateChat', 'user_blocked', {'blockerId': 202});
      server.emit('/privateChat', 'block_status_changed',
          {'blockerId': 202, 'blockedUserId': 101});
      server.emit('/privateChat', 'user_blocked', 'oops');
      await settle();
      expect(events, isEmpty);
    });

    test('BLK-05 chat-list event names the touched chat ids', () async {
      server.emit('/privateChat', 'chat_list_updated',
          {'chatId': 77, 'isBlocked': true});
      server.emit('/privateChat', 'conversation_updated', {
        'data': [
          {'conversationId': 78},
          {'chat': {'chat_id': '79'}},
        ],
      });
      await settle();
      expect(touched.toSet(), {'77', '78', '79'});
    });

    test('BLK-06 BLOCKED send ack → peer blocked me', () async {
      server.ackReplies['send_message'] = {
        'ok': false,
        'code': 'BLOCKED',
        'message': 'You cannot message this user',
      };
      unawaited(svc.initPrivateChat(server.url, userId: me, receiverId: peer));
      expect(await waitFor(() => svc.isPrivateChatSocketConnected), isTrue);
      svc.sendPrivateMessage(receiverId: peer, content: 'hello');
      expect(await waitFor(() => events.isNotEmpty), isTrue);
      expect(events.first.blockerId, peer);
      expect(events.first.blockedId, me);
      expect(events.first.isBlocked, isTrue);
    });

    test('BLK-07 other rejected sends do not report a block', () async {
      server.ackReplies['send_message'] = {'ok': false, 'code': 'SEND_FAILED'};
      unawaited(svc.initPrivateChat(server.url, userId: me, receiverId: peer));
      expect(await waitFor(() => svc.isPrivateChatSocketConnected), isTrue);
      svc.sendPrivateMessage(receiverId: peer, content: 'hello');
      await settle();
      expect(events, isEmpty);
    });
  });

  // The local chat copy tests (CACHE-01 … 07) moved to
  // test/chat_qa/chat_message_cache_test.dart with the Hive cache (F-1.2.4).
}
