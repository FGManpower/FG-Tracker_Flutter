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
import 'package:fgtracker/app/modules/Messages/Controller/private_chat_cache.dart';
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

  group('PrivateChatCache (old messages survive a block)', () {
    setUp(() async => prefs());

    test('CACHE-01 round trip keeps text, audio and ids, oldest first',
        () async {
      await PrivateChatCache.save(peer, [
        msg(1, content: 'first'),
        msg(2, audioUrl: 'uploads/a.m4a'),
      ]);
      final back = PrivateChatCache.load(peer);
      expect(back.map((m) => m.id), [1, 2]);
      expect(back.first.content, 'first');
      expect(back.last.audioUrl, 'uploads/a.m4a');
      expect(back.last.clientMessageId, 'c_2');
    });

    test('CACHE-02 keeps only the newest 50, skips unsent (no id)', () async {
      await PrivateChatCache.save(peer, [
        for (var i = 1; i <= 60; i++) msg(i),
        msg(null),
      ]);
      final back = PrivateChatCache.load(peer);
      expect(back, hasLength(PrivateChatCache.maxMessages));
      expect(back.first.id, 11);
      expect(back.last.id, 60);
    });

    test('CACHE-03 an empty list never wipes a saved copy', () async {
      await PrivateChatCache.save(peer, [msg(1)]);
      await PrivateChatCache.save(peer, []);
      expect(PrivateChatCache.load(peer), hasLength(1));
    });

    test('CACHE-04 clear removes it (Clear chat)', () async {
      await PrivateChatCache.save(peer, [msg(1)]);
      await PrivateChatCache.clear(peer);
      expect(PrivateChatCache.load(peer), isEmpty);
    });

    test('CACHE-05 only the 20 most recent chats are kept', () async {
      for (var p = 1; p <= PrivateChatCache.maxChats + 5; p++) {
        await PrivateChatCache.save('$p', [msg(p)]);
      }
      expect(PrivateChatCache.load('1'), isEmpty);
      expect(PrivateChatCache.load('5'), isEmpty);
      expect(PrivateChatCache.load('6'), hasLength(1));
      expect(PrivateChatCache.load('${PrivateChatCache.maxChats + 5}'),
          hasLength(1));
    });

    test('CACHE-06 another account on the phone never sees the copy',
        () async {
      await PrivateChatCache.save(peer, [msg(1)]);
      await Global.storageServices.setString(PrefConst.userId, '999');
      expect(PrivateChatCache.load(peer), isEmpty);
    });

    test('CACHE-07 a corrupt value loads as empty, never throws', () async {
      await prefs({'private_chat_cache_${me}_$peer': '{not json'});
      expect(PrivateChatCache.load(peer), isEmpty);
    });
  });
}
