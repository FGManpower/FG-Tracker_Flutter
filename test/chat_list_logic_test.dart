import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_logic.dart';
import 'package:flutter_test/flutter_test.dart';

PrivateChatModel chat({
  int? userId,
  int? groupId,
  String? time,
  bool pinned = false,
  String? msgId,
  String message = 'hi',
  int? unread,
  String? senderId,
}) =>
    PrivateChatModel(
      userId: userId,
      groupId: groupId,
      isGroup: groupId != null,
      chatType: groupId != null ? 'group' : 'private',
      time: time,
      timestamp: time,
      isPinned: pinned,
      message: message,
      preview: message,
      unreadCount: unread,
      senderId: senderId,
      lastMessageData: msgId == null ? null : {'id': msgId},
    );

void main() {
  group('ChatListRules.sort', () {
    test('pinned first, then newest message, then stable key', () {
      final a = chat(userId: 1, time: '2026-11-01T10:00:00Z');
      final b = chat(userId: 2, time: '2026-11-01T12:00:00Z');
      final p = chat(userId: 3, time: '2026-10-01T09:00:00Z', pinned: true);
      final tie1 = chat(userId: 5, time: '2026-11-01T11:00:00Z');
      final tie2 = chat(userId: 4, time: '2026-11-01T11:00:00Z');

      final sorted = ChatListRules.sort([a, tie1, b, p, tie2]);
      expect(sorted.map(ChatListRules.chatKey).toList(), [
        'private_3', // pinned
        'private_2', // 12:00
        'private_4', // 11:00, key tie-break
        'private_5', // 11:00
        'private_1', // 10:00
      ]);
    });

    test('pinned chats are ordered among themselves by latest message', () {
      final old = chat(userId: 1, time: '2026-11-01T08:00:00Z', pinned: true);
      final recent = chat(userId: 2, time: '2026-11-01T09:00:00Z', pinned: true);
      expect(ChatListRules.sort([old, recent]).first, recent);
    });

    test('sorting is deterministic for equal timestamps', () {
      final list = [
        for (var i = 0; i < 20; i++) chat(userId: i, time: '2026-11-01T10:00:00Z'),
      ];
      final first = ChatListRules.sort(list).map(ChatListRules.chatKey).toList();
      final again = ChatListRules.sort(list.reversed)
          .map(ChatListRules.chatKey)
          .toList();
      expect(again, first);
    });
  });

  group('ChatListRules.isNewMessage', () {
    test('different id and not older => new', () {
      final cur = chat(userId: 1, time: '2026-11-01T10:00:00Z', msgId: '1');
      final upd = chat(userId: 1, time: '2026-11-01T10:01:00Z', msgId: '2');
      expect(ChatListRules.isNewMessage(cur, upd), isTrue);
    });

    test('same id with a newer time (read/seen) => not new', () {
      final cur = chat(userId: 1, time: '2026-11-01T10:00:00Z', msgId: '1');
      final upd = chat(userId: 1, time: '2026-11-01T10:05:00Z', msgId: '1');
      expect(ChatListRules.isNewMessage(cur, upd), isFalse);
    });

    test('older message (stale event) => not new', () {
      final cur = chat(userId: 1, time: '2026-11-01T10:00:00Z', msgId: '2');
      final upd = chat(userId: 1, time: '2026-11-01T09:00:00Z', msgId: '1');
      expect(ChatListRules.isNewMessage(cur, upd), isFalse);
    });

    test('no ids: falls back to a strictly newer time', () {
      final cur = chat(userId: 1, time: '2026-11-01T10:00:00Z');
      expect(
        ChatListRules.isNewMessage(cur, chat(userId: 1, time: '2026-11-01T10:00:00Z')),
        isFalse,
      );
      expect(
        ChatListRules.isNewMessage(cur, chat(userId: 1, time: '2026-11-01T10:00:01Z')),
        isTrue,
      );
    });

    test('payload without any message => not new', () {
      final cur = chat(userId: 1, time: '2026-11-01T10:00:00Z');
      final upd = chat(userId: 1, time: '2026-11-01T11:00:00Z', message: '');
      expect(ChatListRules.isNewMessage(cur, upd), isFalse);
    });
  });

  group('ChatListRules.resolveUnread', () {
    int resolve({
      int? current,
      int? server,
      bool newMessage = true,
      bool viewing = false,
      String? sender,
    }) =>
        ChatListRules.resolveUnread(
          current: chat(userId: 1, unread: current),
          updated: chat(userId: 1, unread: server, senderId: sender),
          newMessage: newMessage,
          isViewing: viewing,
          myUserId: '7',
        );

    test('server value is used for messages from others', () {
      expect(resolve(current: 1, server: 2, sender: '3'), 2);
    });

    test('my own message never raises my badge', () {
      expect(resolve(current: 0, server: 1, sender: '7'), 0);
    });

    test('open chat is always 0', () {
      expect(resolve(current: 0, server: 4, sender: '3', viewing: true), 0);
    });

    test('missing count keeps the current value', () {
      expect(resolve(current: 3, server: null), 3);
    });

    test('server reset to 0 (read on another device) is accepted', () {
      expect(resolve(current: 5, server: 0, newMessage: false), 0);
    });
  });

  group('ChatTypingTracker', () {
    testWidgets('private label, expiry after 5s', (tester) async {
      var changes = 0;
      final t = ChatTypingTracker(onChanged: () => changes++);
      t.start('private_3', '3', name: 'Rahul');
      expect(t.label('private_3', isGroup: false), 'typing...');

      await tester.pump(const Duration(seconds: 4));
      t.start('private_3', '3', name: 'Rahul'); // refresh keeps it alive
      await tester.pump(const Duration(seconds: 4));
      expect(t.isTyping('private_3'), isTrue);

      await tester.pump(const Duration(seconds: 2));
      expect(t.isTyping('private_3'), isFalse);
      expect(changes, 2); // started once, expired once
    });

    testWidgets('group labels for one, two and many typists', (tester) async {
      final t = ChatTypingTracker(onChanged: () {});
      t.start('group_9', '1', name: 'Rahul');
      expect(t.label('group_9', isGroup: true), 'Rahul is typing...');
      t.start('group_9', '2', name: 'Priya');
      expect(t.label('group_9', isGroup: true), 'Rahul, Priya are typing...');
      t.start('group_9', '3', name: 'Amit');
      expect(t.label('group_9', isGroup: true), 'Rahul, Priya +1 are typing...');
      t.stop('group_9', '1');
      expect(t.label('group_9', isGroup: true), 'Priya, Amit are typing...');
      t.clearAll();
    });

    testWidgets('stop and clearChat clear immediately', (tester) async {
      final t = ChatTypingTracker(onChanged: () {});
      t.start('group_9', '1', name: 'Rahul');
      t.start('group_9', '2', name: 'Priya');
      t.clearChat('group_9');
      expect(t.isTyping('group_9'), isFalse);
      t.start('private_1', '1');
      t.stop('private_1', '1');
      expect(t.label('private_1', isGroup: false), isNull);
      await tester.pump(const Duration(seconds: 6));
    });
  });
}
