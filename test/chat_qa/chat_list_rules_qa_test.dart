// QA: pure chat-list rules (ChatListRules + ChatTypingTracker).
// Spec: docs/01_CHATTING_MODULE_FRONTEND.md §0.3, §6.2 rules 2, 3, 5, 7.
import 'package:fake_async/fake_async.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_logic.dart';
import 'package:flutter_test/flutter_test.dart';

PrivateChatModel row({
  int? id,
  int? userId,
  int? chatId,
  int? groupId,
  String? time,
  bool pinned = false,
  String? pinnedAt,
  String? msgId,
  String? msgCreatedAt,
  String? message = 'hi',
  int? unread,
  String? senderId,
  bool? deleted,
}) =>
    PrivateChatModel(
      id: id,
      userId: userId,
      chatId: chatId,
      groupId: groupId,
      isGroup: groupId != null,
      chatType: groupId != null ? 'group' : 'private',
      time: time,
      timestamp: time,
      isPinned: pinned,
      pinnedAt: pinnedAt,
      message: message,
      preview: message,
      unreadCount: unread,
      senderId: senderId,
      isDeletedForEveryone: deleted,
      lastMessageData: (msgId == null && msgCreatedAt == null)
          ? null
          : {
              if (msgId != null) 'id': msgId,
              if (msgCreatedAt != null) 'createdAt': msgCreatedAt,
            },
    );

List<String> keys(Iterable<PrivateChatModel> l) =>
    l.map(ChatListRules.chatKey).toList();

void main() {
  group('Chat key (private vs group identity)', () {
    test('private row key uses the peer user id', () {
      expect(ChatListRules.chatKey(row(userId: 505, chatId: 2001)),
          'private_505');
    });

    test('private row without user id falls back to chat id', () {
      expect(ChatListRules.chatKey(row(chatId: 2001)), 'private_2001');
    });

    test('group row key uses the group id', () {
      expect(ChatListRules.chatKey(row(groupId: 77)), 'group_77');
    });

    test('a group detected only by chatType "group" is keyed as group', () {
      final c = PrivateChatModel(id: 12, chatType: 'group');
      expect(ChatListRules.isGroup(c), isTrue);
      expect(ChatListRules.chatKey(c), 'group_12');
    });

    test('private chat and group with the same number never share a key', () {
      final p = row(userId: 77);
      final g = row(groupId: 77);
      expect(ChatListRules.chatKey(p), isNot(ChatListRules.chatKey(g)));
    });
  });

  group('Sorting (pinned, pinnedAt, newest first, tie-breaker)', () {
    test('pinned chats always come before unpinned, even if older', () {
      final sorted = ChatListRules.sort([
        row(userId: 1, time: '2026-11-01T12:00:00Z'),
        row(userId: 2, time: '2020-01-01T00:00:00Z', pinned: true),
      ]);
      expect(keys(sorted), ['private_2', 'private_1']);
    });

    test('pinned chats are ordered by pinnedAt, most recently pinned first',
        () {
      final sorted = ChatListRules.sort([
        row(
            userId: 1,
            pinned: true,
            pinnedAt: '2026-11-01T08:00:00Z',
            time: '2026-11-01T12:00:00Z'),
        row(
            userId: 2,
            pinned: true,
            pinnedAt: '2026-11-01T09:00:00Z',
            time: '2026-11-01T06:00:00Z'),
      ]);
      expect(keys(sorted), ['private_2', 'private_1']);
    });

    test('pinned chats with equal pinnedAt fall back to newest message', () {
      final sorted = ChatListRules.sort([
        row(
            userId: 1,
            pinned: true,
            pinnedAt: '2026-11-01T08:00:00Z',
            time: '2026-11-01T06:00:00Z'),
        row(
            userId: 2,
            pinned: true,
            pinnedAt: '2026-11-01T08:00:00Z',
            time: '2026-11-01T07:00:00Z'),
      ]);
      expect(keys(sorted), ['private_2', 'private_1']);
    });

    test('unpinned chats are newest message first', () {
      final sorted = ChatListRules.sort([
        row(userId: 1, time: '2026-11-01T08:00:00Z'),
        row(userId: 2, time: '2026-11-01T10:00:00Z'),
        row(userId: 3, time: '2026-11-01T09:00:00Z'),
      ]);
      expect(keys(sorted), ['private_2', 'private_3', 'private_1']);
    });

    test('equal times are ordered by chat key so rows never swap', () {
      final a = row(userId: 9, time: '2026-11-01T10:00:00Z');
      final b = row(groupId: 9, time: '2026-11-01T10:00:00Z');
      expect(keys(ChatListRules.sort([a, b])), ['group_9', 'private_9']);
      expect(keys(ChatListRules.sort([b, a])), ['group_9', 'private_9']);
    });

    test('message createdAt wins over the conversation updatedAt time', () {
      // Row 1 had a read/updatedAt bump (time newer) but its message is old.
      final bumped = row(
          userId: 1,
          time: '2026-11-01T12:00:00Z',
          msgId: '1',
          msgCreatedAt: '2026-11-01T08:00:00Z');
      final recent = row(
          userId: 2,
          time: '2026-11-01T10:00:00Z',
          msgId: '2',
          msgCreatedAt: '2026-11-01T10:00:00Z');
      expect(keys(ChatListRules.sort([bumped, recent])),
          ['private_2', 'private_1']);
    });

    test('epoch seconds and epoch milliseconds are both understood', () {
      final secs = ChatListRules.parseTime(1762000000);
      final ms = ChatListRules.parseTime(1762000000000);
      expect(secs, ms);
    });

    test('missing / "null" times sort to the bottom without crashing', () {
      final sorted = ChatListRules.sort([
        row(userId: 1, time: 'null'),
        row(userId: 2, time: '2026-11-01T10:00:00Z'),
        row(userId: 3),
      ]);
      expect(keys(sorted).first, 'private_2');
    });
  });

  group('New message detection (anti-shuffle)', () {
    test('higher numeric message id is a new message', () {
      expect(
          ChatListRules.isNewMessage(
              row(userId: 1, msgId: '9'), row(userId: 1, msgId: '10')),
          isTrue,
          reason: '10 > 9 numerically even though "10" < "9" as text');
    });

    test('same message id (read receipt / seen) is not new', () {
      expect(
          ChatListRules.isNewMessage(
              row(userId: 1, msgId: '5', time: '2026-11-01T10:00:00Z'),
              row(userId: 1, msgId: '5', time: '2026-11-01T11:00:00Z')),
          isFalse);
    });

    test('older message id (delete-for-me shows previous message) is not new',
        () {
      expect(
          ChatListRules.isNewMessage(row(userId: 1, msgId: '5', message: 'b'),
              row(userId: 1, msgId: '4', message: 'a')),
          isFalse);
    });

    test('presence-only update without text is not new', () {
      expect(
          ChatListRules.isNewMessage(
              row(userId: 1), row(userId: 1, message: null)),
          isFalse);
    });

    test('same text without ids (updatedAt bump) is not new', () {
      expect(
          ChatListRules.isNewMessage(
              row(userId: 1, time: '2026-11-01T10:00:00Z'),
              row(userId: 1, time: '2026-11-01T10:30:00Z')),
          isFalse);
    });

    test('different text without ids and a newer time is new', () {
      expect(
          ChatListRules.isNewMessage(
              row(userId: 1, time: '2026-11-01T10:00:00Z', message: 'a'),
              row(userId: 1, time: '2026-11-01T10:00:10Z', message: 'b')),
          isTrue);
    });

    test('different text without ids but much older time is not new', () {
      expect(
          ChatListRules.isNewMessage(
              row(userId: 1, time: '2026-11-01T10:00:00Z', message: 'a'),
              row(userId: 1, time: '2026-11-01T09:00:00Z', message: 'b')),
          isFalse);
    });

    test('non-numeric ids: different id and not older time is new', () {
      expect(
          ChatListRules.isNewMessage(
              row(
                  userId: 1,
                  msgId: 'abc',
                  msgCreatedAt: '2026-11-01T10:00:00Z'),
              row(
                  userId: 1,
                  msgId: 'xyz',
                  msgCreatedAt: '2026-11-01T10:01:00Z')),
          isTrue);
    });
  });

  group('Unread count policy', () {
    int resolve({
      int? current,
      int? server,
      bool newMessage = true,
      bool viewing = false,
      String? sender = '3',
      bool readLocally = false,
      bool alreadyCounted = false,
      bool deleted = false,
    }) =>
        ChatListRules.resolveUnread(
          current: row(userId: 1, unread: current),
          updated: row(
              userId: 1, unread: server, senderId: sender, deleted: deleted),
          newMessage: newMessage,
          isViewing: viewing,
          myUserId: '7',
          readLocally: readLocally,
          alreadyCounted: alreadyCounted,
        );

    test('server unreadCount wins when present', () {
      expect(resolve(current: 1, server: 6), 6);
    });

    test('negative server count is clamped to 0', () {
      expect(resolve(current: 2, server: -3), 0);
    });

    test('no server count: +1 for a new message from another user', () {
      expect(resolve(current: 2, server: null), 3);
    });

    test('no server count: duplicate message id is counted once', () {
      expect(resolve(current: 2, server: null, alreadyCounted: true), 2);
    });

    test('no server count: deleted-for-everyone message never counts', () {
      expect(resolve(current: 2, server: null, deleted: true), 2);
    });

    test('no server count: unknown sender never counts', () {
      expect(resolve(current: 2, server: null, sender: null), 2);
    });

    test('no server count: my own message never counts', () {
      expect(resolve(current: 2, server: null, sender: '7'), 2);
    });

    test('open chat is always 0', () {
      expect(resolve(current: 5, server: 9, viewing: true), 0);
    });

    test('read on this device: stale server count is ignored (grace)', () {
      expect(resolve(current: 0, server: 4, newMessage: false, readLocally: true),
          0);
    });

    test('read on this device: a truly new message still counts', () {
      expect(resolve(current: 0, server: 1, newMessage: true, readLocally: true),
          1);
    });
  });

  group('Typing tracker', () {
    test('auto-clears 5 seconds after the last typing event', () {
      fakeAsync((async) {
        final t = ChatTypingTracker(onChanged: () {});
        t.start('private_1', '1');
        async.elapse(const Duration(milliseconds: 4900));
        expect(t.isTyping('private_1'), isTrue);
        async.elapse(const Duration(milliseconds: 200));
        expect(t.isTyping('private_1'), isFalse);
      });
    });

    test('a new typing event restarts the 5 second timer', () {
      fakeAsync((async) {
        final t = ChatTypingTracker(onChanged: () {});
        t.start('group_1', '5', name: 'Rahul');
        async.elapse(const Duration(seconds: 4));
        t.start('group_1', '5', name: 'Rahul');
        async.elapse(const Duration(seconds: 4));
        expect(t.isTyping('group_1'), isTrue);
        async.elapse(const Duration(seconds: 2));
        expect(t.isTyping('group_1'), isFalse);
      });
    });

    test('each typist expires independently', () {
      fakeAsync((async) {
        final t = ChatTypingTracker(onChanged: () {});
        t.start('group_1', '5', name: 'Rahul');
        async.elapse(const Duration(seconds: 3));
        t.start('group_1', '6', name: 'Priya');
        async.elapse(const Duration(seconds: 3));
        expect(t.label('group_1', isGroup: true), 'Priya is typing...');
        t.clearAll();
      });
    });

    test('group typist without a name shows "Someone is typing..."', () {
      fakeAsync((async) {
        final t = ChatTypingTracker(onChanged: () {});
        t.start('group_1', '5');
        expect(t.label('group_1', isGroup: true), 'Someone is typing...');
        t.clearAll();
      });
    });

    test('typing in a group never shows on the private row with same id', () {
      fakeAsync((async) {
        final t = ChatTypingTracker(onChanged: () {});
        t.start('group_77', '5', name: 'Rahul');
        expect(t.isTyping('private_77'), isFalse);
        final labels =
            t.labels(isGroup: (k) => k.startsWith('group_'));
        expect(labels.keys, ['group_77']);
        t.clearAll();
      });
    });

    test('empty chat key or user id is ignored', () {
      var changes = 0;
      final t = ChatTypingTracker(onChanged: () => changes++);
      t.start('', '5');
      t.start('group_1', '');
      expect(changes, 0);
    });
  });
}
