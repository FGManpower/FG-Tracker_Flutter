// QA: real-time socket behaviour of SocketMessageService, run against a local
// fake Socket.IO server (test/chat_qa/fakes/fake_socket_io_server.dart).
// No app code is changed; the service already takes the socket URL as a
// parameter. See docs/testing/chatting/ for the bug IDs (BUG-RT-xx).
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_socket_io_server.dart';

const me = '101';
const peer = '202';

/// Every chat-list event the app says it handles (doc §6.2, SMS listeners).
const listUpdateEvents = [
  'chat_list_updated',
  'conversation_updated',
  'private_chat_list_updated',
  'group_chat_list_updated',
  'common_chat_list_updated',
  'unified_chat_list_updated',
];
const fullListEvents = ['chat_list', 'common_chat_list', 'unified_chat_list'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSocketIoServer server;
  late SocketMessageService svc;

  setUp(() async {
    // flutter_test replaces HttpClient with a mock that answers 400; the
    // fake server needs real loopback sockets.
    HttpOverrides.global = null;
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: me,
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
    });
    Global.storageServices = await StorageServices().init();
    server = FakeSocketIoServer();
    await server.start();
    svc = SocketMessageService();
  });

  tearDown(() async {
    svc.disconnectAll();
    await server.stop();
  });

  Future<void> listSocketUp() async {
    svc.initPrivateChatListSocket(server.url, userId: me);
    expect(await waitFor(() => svc.isPrivateChatListSocketConnected), isTrue,
        reason: 'list socket should connect to the fake server');
  }

  Future<void> chatSocketUp() async {
    svc.ensureChatSocket(server.url, userId: me);
    expect(await waitFor(() => svc.isSocketConnected), isTrue,
        reason: '/chat socket should connect to the fake server');
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 200));

  group('Chat list events on /privateChat (list socket)', () {
    test(
      'RT-01 listeners registered BEFORE the socket exists (real app order) '
      'still hear every list event',
      () async {
        final heard = <String>[];
        // Same order as ChatListController._initializePrivateChatListSocket.
        svc.listenPrivateChatListUpdated(
            callback: (d) => heard.add((d as Map)['ev'] as String));
        svc.listenFullChatList(
            callback: (d) => heard.add((d as Map)['ev'] as String));
        await listSocketUp();

        for (final ev in [...listUpdateEvents, ...fullListEvents]) {
          server.emit('/privateChat', ev, {'ev': ev, 'chatId': 1});
        }
        await settle();

        expect(heard.toSet(), {...listUpdateEvents, ...fullListEvents});
      },
      skip: 'BUG-RT-01: only chat_list_updated / conversation_updated are '
          'heard; the other 7 list events are dropped on /privateChat '
          '(listeners attach before initPrivateChatListSocket creates the socket)',
    );

    test('RT-01b evidence: with the real app order only 2 of 9 events arrive',
        () async {
      final heard = <String>[];
      svc.listenPrivateChatListUpdated(
          callback: (d) => heard.add((d as Map)['ev'] as String));
      svc.listenFullChatList(
          callback: (d) => heard.add((d as Map)['ev'] as String));
      await listSocketUp();
      for (final ev in [...listUpdateEvents, ...fullListEvents]) {
        server.emit('/privateChat', ev, {'ev': ev, 'chatId': 1});
      }
      await settle();
      // Records the current (buggy) behaviour so a fix shows up as a change.
      expect(heard.toSet(), {'chat_list_updated', 'conversation_updated'});
    });

    test('RT-02 listeners registered AFTER the socket exists hear all 9 events',
        () async {
      await listSocketUp();
      final heard = <String>[];
      svc.listenPrivateChatListUpdated(
          callback: (d) => heard.add((d as Map)['ev'] as String));
      svc.listenFullChatList(
          callback: (d) => heard.add((d as Map)['ev'] as String));
      for (final ev in [...listUpdateEvents, ...fullListEvents]) {
        server.emit('/privateChat', ev, {'ev': ev, 'chatId': 1});
      }
      await settle();
      expect(heard.toSet(), {...listUpdateEvents, ...fullListEvents});
    });

    test('RT-03 receive_message on the list socket reaches the list callback',
        () async {
      final heard = <dynamic>[];
      svc.listenPrivateChatListUpdated(callback: heard.add);
      await listSocketUp();
      server.emit('/privateChat', 'receive_message',
          {'id': 9, 'senderId': peer, 'receiverId': me, 'content': 'hi'});
      await settle();
      expect(heard, hasLength(1));
    });

    test('RT-04 one list event is delivered exactly once (no double listeners)',
        () async {
      final heard = <dynamic>[];
      svc.listenPrivateChatListUpdated(callback: heard.add);
      await listSocketUp();
      // Calling listen again (screen rebuilt) must not stack handlers.
      svc.listenPrivateChatListUpdated(callback: heard.add);
      server.emit('/privateChat', 'chat_list_updated', {'chatId': 1});
      await settle();
      expect(heard, hasLength(1));
    });
  });

  group('Chat list events on /chat', () {
    test('RT-05 every list event on /chat reaches the list', () async {
      final heard = <String>[];
      svc.listenPrivateChatListUpdated(
          callback: (d) => heard.add((d as Map)['ev'] as String));
      svc.listenFullChatList(
          callback: (d) => heard.add((d as Map)['ev'] as String));
      await chatSocketUp();
      for (final ev in [...listUpdateEvents, ...fullListEvents]) {
        server.emit('/chat', ev, {'ev': ev, 'groupId': 7});
      }
      await settle();
      expect(heard.toSet(), {...listUpdateEvents, ...fullListEvents});
    });
  });

  group('Typing reaches the chat list', () {
    test('RT-06 private typing / stop_typing on the list socket', () async {
      final events = <String>[];
      svc.listenChatListTyping(
        onPrivateTyping: (_) => events.add('typing'),
        onPrivateStopTyping: (_) => events.add('stop'),
        onGroupTyping: (_) {},
        onGroupStopTyping: (_) {},
      );
      await listSocketUp();
      server.emit('/privateChat', 'typing', {'userId': peer, 'chatId': 1});
      server.emit('/privateChat', 'stop_typing', {'userId': peer, 'chatId': 1});
      await settle();
      expect(events, ['typing', 'stop']);
    });

    test('RT-07 group typing still reaches the list after a group screen '
        'opened and closed', () async {
      final events = <String>[];
      svc.listenChatListTyping(
        onPrivateTyping: (_) {},
        onPrivateStopTyping: (_) {},
        onGroupTyping: (_) => events.add('list'),
        onGroupStopTyping: (_) {},
      );
      await chatSocketUp();
      svc.listenGroupTyping(onTyping: (_) {}, onStopTyping: (_) {});
      svc.stopListeningGroupTyping();
      server.emit('/chat', 'group_typing', {'groupId': 7, 'userId': peer});
      await settle();
      expect(events, ['list']);
    });
  });

  group('Group info updates', () {
    test(
      'RT-08 chat list still gets group_updated after a group screen '
      'opened and closed',
      () async {
        await chatSocketUp();
        final listHeard = <Map>[];
        svc.listenGroupUpdated(callback: listHeard.add); // chat list
        final owner = Object();
        svc.claimGroupChatEvents(owner); // group screen opens
        svc.listenGroupUpdated(callback: (_) {});
        svc.releaseGroupChatEvents(owner); // group screen closes
        server.emit('/chat', 'group_updated', {'groupId': 7, 'groupName': 'X'});
        await settle();
        expect(listHeard, hasLength(1));
      },
      skip: 'BUG-RT-02: listenGroupUpdated/releaseGroupChatEvents call '
          'off(event) with no handler, removing the chat list listener',
    );

    test('RT-08b group_updated registered before /chat exists is lost',
        () async {
      final listHeard = <Map>[];
      svc.listenGroupUpdated(callback: listHeard.add); // CLC order: before
      await chatSocketUp(); // ensureChatSocket
      server.emit('/chat', 'group_updated', {'groupId': 7});
      await settle();
      // Records current behaviour: nothing is heard (BUG-RT-02).
      expect(listHeard, isEmpty);
    });
  });

  group('Group seen', () {
    test(
      'RT-09 listenSeenUpdate keeps working after listenGroupMessageSeen',
      () async {
        await chatSocketUp();
        final first = <dynamic>[];
        final second = <dynamic>[];
        svc.listenSeenUpdate(groupId: 7, callback: first.add);
        svc.listenGroupMessageSeen(callback: second.add);
        server.emit('/chat', 'messages_seen_update',
            {'groupId': 7, 'messageIds': [1], 'seenBy': peer});
        await settle();
        expect(first, hasLength(1), reason: 'first handler was removed');
        expect(second, hasLength(1));
      },
      skip: 'BUG-RT-03: listenGroupMessageSeen calls '
          'off("messages_seen_update") and drops the listenSeenUpdate handler',
    );
  });

  group('Private chat screen', () {
    test('RT-10 open/close the same chat 10 times, 1 message is handled once',
        () async {
      var handled = 0;
      for (var i = 0; i < 10; i++) {
        final owner = Object();
        svc.claimPrivateChatEvents(owner);
        await svc.initPrivateChat(server.url, userId: me, receiverId: peer);
        await waitFor(() => svc.isPrivateChatSocketConnected);
        svc.receivePrivateMessage(
            senderId: me, receiverId: peer, callback: (_) => handled++);
        if (i < 9) svc.releasePrivateChatEvents(owner);
      }
      server.emit('/privateChat', 'receive_message',
          {'id': 55, 'senderId': peer, 'receiverId': me, 'content': 'hi'});
      await settle();
      expect(handled, 1);
    });

    test('RT-11 a group message on /privateChat is ignored by the private chat',
        () async {
      var handled = 0;
      await svc.initPrivateChat(server.url, userId: me, receiverId: peer);
      await waitFor(() => svc.isPrivateChatSocketConnected);
      svc.receivePrivateMessage(
          senderId: me, receiverId: peer, callback: (_) => handled++);
      server.emit('/privateChat', 'receive_message',
          {'id': 1, 'senderId': peer, 'receiverId': me, 'groupId': 7});
      server.emit('/privateChat', 'receive_message',
          {'id': 2, 'senderId': '999', 'receiverId': me});
      await settle();
      expect(handled, 0);
    });

    test('RT-12 join is sent on open with userId + receiverId', () async {
      await svc.initPrivateChat(server.url, userId: me, receiverId: peer);
      expect(
          await waitFor(
              () => server.receivedNamed('join', nsp: '/privateChat').isNotEmpty),
          isTrue);
      final join = server.receivedNamed('join', nsp: '/privateChat').first;
      expect(join.data, {'userId': me, 'receiverId': peer});
    });

    test('RT-13 mark_seen payload (contract check for blue ticks)', () async {
      await svc.initPrivateChat(server.url, userId: me, receiverId: peer);
      await waitFor(() => svc.isPrivateChatSocketConnected);
      svc.markPrivateSeen(chatId: '5', userId: me, otherUserId: peer);
      expect(
          await waitFor(() =>
              server.receivedNamed('mark_seen', nsp: '/privateChat').isNotEmpty),
          isTrue);
      final seen = server.receivedNamed('mark_seen', nsp: '/privateChat').first;
      // No messageIds are sent: the server must answer messages_seen_update
      // with the ids (or the app must treat an empty list as "all").
      expect((seen.data as Map).keys.toSet(), {'chatId', 'userId', 'otherUserId'});
    });

    test('RT-14 typing payload names both sides of the chat', () async {
      await svc.initPrivateChat(server.url, userId: me, receiverId: peer);
      await waitFor(() => svc.isPrivateChatSocketConnected);
      svc.sendPrivateTyping(chatId: '5', userId: me, otherUserId: peer);
      expect(
          await waitFor(() =>
              server.receivedNamed('typing', nsp: '/privateChat').isNotEmpty),
          isTrue);
      final d = server.receivedNamed('typing', nsp: '/privateChat').first.data
          as Map;
      expect(d['userId'].toString(), me);
      expect(d['chatId'].toString(), '5');
    });
  });

  group('Reconnect', () {
    test(
      'RT-15 a /chat socket closed by the server is revived by ensureChatSocket',
      () async {
        await chatSocketUp();
        server.kick('/chat'); // "io server disconnect": no auto-reconnect
        expect(await waitFor(() => !svc.isSocketConnected), isTrue);
        svc.ensureChatSocket(server.url, userId: me); // e.g. app resume
        expect(await waitFor(() => svc.isSocketConnected), isTrue);
      },
      skip: 'BUG-RT-04: ensureChatSocket returns when _socket != null even if '
          'it is dead, so group list updates stop until a group is opened',
    );

    test('RT-15b evidence: after a server kick /chat stays down', () async {
      await chatSocketUp();
      server.kick('/chat');
      expect(await waitFor(() => !svc.isSocketConnected), isTrue);
      svc.ensureChatSocket(server.url, userId: me);
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(svc.isSocketConnected, isFalse);
    });

    test('RT-16 network drop: list socket reconnects and asks for a resync',
        () async {
      var resyncs = 0;
      svc.listenChatListReconnect(() => resyncs++);
      await listSocketUp();
      expect(resyncs, 1);
      await server.dropAll();
      expect(
          await waitFor(() => resyncs >= 2,
              timeout: const Duration(seconds: 10)),
          isTrue,
          reason: 'list socket should reconnect and call the resync callback');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('RT-17 network drop: open private chat re-sends join after reconnect',
        () async {
      await svc.initPrivateChat(server.url, userId: me, receiverId: peer);
      await waitFor(
          () => server.receivedNamed('join', nsp: '/privateChat').isNotEmpty);
      await server.dropAll();
      expect(
          await waitFor(
              () => server.receivedNamed('join', nsp: '/privateChat').length >= 2,
              timeout: const Duration(seconds: 10)),
          isTrue);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('RT-18 network drop: open group is re-joined after reconnect',
        () async {
      await svc.init(server.url, userId: me, groupId: 7);
      await waitFor(() => svc.isSocketConnected);
      await waitFor(
          () => server.receivedNamed('join_group', nsp: '/chat').isNotEmpty);
      final before = server.receivedNamed('join_group', nsp: '/chat').length;
      await server.dropAll();
      expect(
          await waitFor(
              () =>
                  server.receivedNamed('join_group', nsp: '/chat').length >
                  before,
              timeout: const Duration(seconds: 10)),
          isTrue);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('Auth / security', () {
    test('SEC-RT-01 token is sent in the handshake auth, not the URL query',
        () async {
      await listSocketUp();
      expect(server.authPayloads.last['token'], 'token-1');
    });

    test('SEC-RT-02 a reconnect sends the CURRENT token (rotated token)',
        () async {
      await listSocketUp();
      await Global.storageServices
          .setString(PrefConst.STORAGE_USER_TOKEN_KEY, 'token-2');
      await server.dropAll();
      expect(
          await waitFor(() => server.authPayloads.last['token'] == 'token-2',
              timeout: const Duration(seconds: 10)),
          isTrue);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('SEC-RT-03 logout (disconnectAll) closes every chat socket', () async {
      final heard = <dynamic>[];
      svc.listenPrivateChatListUpdated(callback: heard.add);
      await listSocketUp();
      await chatSocketUp();
      await svc.initPrivateChat(server.url, userId: me, receiverId: peer);
      await waitFor(() => svc.isPrivateChatSocketConnected);
      svc.disconnectAll();
      await settle();
      expect(server.clientsOn('/chat'), 0);
      expect(server.clientsOn('/privateChat'), 0);
      server.emit('/privateChat', 'chat_list_updated', {'chatId': 1});
      await settle();
      expect(heard, isEmpty);
    });
  });
}
