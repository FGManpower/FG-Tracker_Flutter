// QA: chat screen rules (private + group) - ChatScreenRules / HistoryPager.
// Pure logic, no sockets. See docs/01_CHATTING_MODULE_FRONTEND.md §1, §2, §5.1.
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter_test/flutter_test.dart';

const me = '1';
const peer = '2';

MessageData m(
  int? id, {
  dynamic sender = me,
  String type = 'text',
  String? at,
  String? content,
  dynamic seenCount,
  dynamic seenBy,
  bool delivered = false,
  String? clientId,
}) {
  final d = MessageData(
    id: id,
    senderId: sender,
    messageType: type,
    content: content ?? 'm$id',
    timestamp: at ?? DateTime.utc(2026, 1, 1, 0, id ?? 0).toIso8601String(),
    seenCount: seenCount,
    seenBy: seenBy,
    isDelivered: delivered,
  );
  d.clientMessageId = clientId;
  return d;
}

List<int?> ids(List<MessageData> l) => l.map((e) => e.id).toList();

Set<MessageMenuOption> menu(String? type, {required bool mine}) =>
    ChatScreenRules.menuOptions(messageType: type, isSentByMe: mine);

void main() {
  // ---------------------------------------------------------------------------
  group('History merge & dedupe', () {
    test('a message delivered twice in the same page shows once', () {
      final r = ChatScreenRules.merge([], [m(1), m(1), m(2)]);
      expect(ids(r.messages), [1, 2]);
      expect(r.added, 2);
    },
        // Passed in Run 1 (2026-11-16). Regression from commit 271d63a3.
        skip: 'BUG-CS-19: merge() fills `known` but never checks it, so a '
            'message repeated inside the same page is added twice '
            '(chat_screen_logic.dart:113-115)');

    test('a duplicate inside a page next to messages already on screen '
        'shows once', () {
      final r = ChatScreenRules.merge([m(1)], [m(2), m(2), m(3)]);
      expect(ids(r.messages), [1, 2, 3]);
    }, skip: 'BUG-CS-19: same root cause (chat_screen_logic.dart:113-115)');

    test('first load into an empty chat reports nothing prepended', () {
      final r = ChatScreenRules.merge([], [m(3), m(1), m(2)]);
      expect(ids(r.messages), [1, 2, 3]);
      expect(r.prepended, 0);
    });

    test('newest-first API page is shown oldest-first', () {
      final r = ChatScreenRules.merge([m(10)], [m(9), m(8), m(7)]);
      expect(ids(r.messages), [7, 8, 9, 10]);
      expect(r.prepended, 3);
    });

    test('times with different UTC offsets are ordered by real instant', () {
      final a = m(1, at: '2026-01-01T10:00:00+05:30'); // 04:30Z
      final b = m(2, at: '2026-01-01T05:00:00Z');
      final r = ChatScreenRules.merge([b], [a]);
      expect(ids(r.messages), [1, 2]);
    });

    test('messages without a timestamp keep their relative position', () {
      final list = [m(1), m(5, at: ''), m(3)];
      final sorted = ChatScreenRules.sortOldestFirst(list);
      expect(sorted.length, 3);
      expect(ids(sorted), [1, 5, 3]);
    });

    test('loaded copy is kept, a stale history copy never lowers its ticks', () {
      final loaded = m(4, seenCount: 1, delivered: true);
      final stale = m(4, seenCount: 0, delivered: false);
      final r = ChatScreenRules.merge([loaded], [stale]);
      expect(r.messages.single.seenCount, 1);
      expect(r.messages.single.isDelivered, isTrue);
    });

    test('a re-read page with newer tick state upgrades the loaded copy', () {
      // Seen while we were offline: the reconnect re-read brings seenCount 1.
      final loaded = m(4, seenCount: 0, delivered: true);
      final fresh = m(4, seenCount: 1, delivered: true);
      final r = ChatScreenRules.merge([loaded], [fresh]);
      expect(int.tryParse('${r.messages.single.seenCount}'), 1);
      expect(r.updated, isTrue);
    }); // BUG-CS-01 fixed in code (Run 2): merge() upgrades ticks / seen.

    test('a re-read page upgrades delivered, delete and first edit', () {
      final a = m(1, content: 'old');
      final b = m(2);
      final c = m(3);
      final freshA = m(1, content: 'new')..isEdited = true;
      final freshB = m(2, delivered: true);
      final freshC = m(3)..isDeleted = true;
      final r = ChatScreenRules.merge([a, b, c], [freshA, freshB, freshC]);
      expect(r.messages[0].content, 'new');
      expect(r.messages[0].isEdited, isTrue);
      expect(r.messages[1].isDelivered, isTrue);
      expect(r.messages[2].isDeleted, isTrue);
    });

    test('a SECOND edit made while offline is applied on the re-read', () {
      final loaded = m(1, content: 'v2')..isEdited = true;
      final fresh = m(1, content: 'v3')..isEdited = true;
      final r = ChatScreenRules.merge([loaded], [fresh]);
      expect(r.messages.single.content, 'v3');
    },
        skip: 'BUG-CS-22: merge() copies the text only when the loaded copy is '
            'not edited yet (chat_screen_logic.dart:107), so a later edit '
            'missed while offline keeps the old text until reopen');

    test('a message whose text is literally "This message was deleted" is '
        'not turned into a deleted message by a re-read', () {
      final loaded = m(1, content: 'This message was deleted');
      final fresh = m(1, content: 'This message was deleted');
      final r = ChatScreenRules.merge([loaded], [fresh]);
      expect(r.messages.single.isDeleted, isNot(true));
    },
        skip: 'BUG-CS-21: merge() treats the English placeholder text as a '
            'delete flag (chat_screen_logic.dart:101-102, commit 0ccd9c47)');

    test('temp bubble and its server copy (same clientMessageId) show once', () {
      final temp = m(null, clientId: 'c_1', at: '2026-01-01T00:10:00Z');
      final server = m(55, clientId: 'c_1', at: '2026-01-01T00:10:00Z');
      final r = ChatScreenRules.merge([temp], [server]);
      expect(r.messages.length, 1);
    },
        skip: 'BUG-CS-02: merge() dedupes by id only; doc §0.3 says groups also '
            'dedupe by clientMessageId, a history/sync page racing the ack '
            'gives two bubbles');

    test('temp bubbles without an id are never dropped by the merge', () {
      final r = ChatScreenRules.merge([m(null, clientId: 'c_9')], [m(1)]);
      expect(r.messages.length, 2);
    });
  });

  // ---------------------------------------------------------------------------
  group('Paging (HistoryPager + cursors)', () {
    test('no second request while one is in flight', () {
      final p = HistoryPager();
      expect(p.begin(), 1);
      expect(p.isLoading, isTrue);
      expect(p.begin(), isNull);
    });

    test('a late answer for an older page never moves the counter back', () {
      final p = HistoryPager();
      p.begin();
      p.complete(page: 3, receivedCount: 20, hasNextPage: true);
      p.begin();
      p.complete(page: 2, receivedCount: 20, hasNextPage: true);
      expect(p.lastLoadedPage, 3);
      expect(p.begin(), 4);
    });

    test('server "hasNextPage:false" stops paging even with a full page', () {
      final p = HistoryPager();
      p.begin();
      p.complete(page: 1, receivedCount: 20, hasNextPage: false);
      expect(p.hasMore, isFalse);
      expect(p.begin(), isNull);
    });

    test('server "hasNextPage:true" keeps paging after a short page', () {
      final p = HistoryPager();
      p.begin();
      p.complete(page: 1, receivedCount: 5, hasNextPage: true);
      expect(p.hasMore, isTrue);
    });

    test('reset (chat cleared) starts again from page 1', () {
      final p = HistoryPager();
      p.begin();
      p.complete(page: 1, receivedCount: 0);
      expect(p.hasMore, isFalse);
      p.reset();
      expect(p.begin(), 1);
    });

    test('oldest/newest cursor ignores id 0, negative ids and temp bubbles', () {
      final list = [m(0), m(-3), m(null), m(12), m(40)];
      expect(ChatScreenRules.oldestId(list), 12);
      expect(ChatScreenRules.newestId(list), 40);
      expect(ChatScreenRules.oldestId([m(null)]), isNull);
    });

    test('empty batch counts as cursor honoured (end of history)', () {
      expect(ChatScreenRules.cursorHonoured([], before: 10), isTrue);
    });

    test('before= cursor: a batch equal to the cursor id is "ignored"', () {
      expect(ChatScreenRules.cursorHonoured([m(9), m(10)], before: 10), isFalse);
      expect(ChatScreenRules.cursorHonoured([m(8), m(9)], before: 10), isTrue);
    });

    test('after= cursor ignores temp bubbles in the batch', () {
      expect(
          ChatScreenRules.cursorHonoured([m(null), m(21)], after: 20), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  group('Long-press menu', () {
    test('my text: Reply, Copy, Forward, Edit, Pin, Info, both deletes', () {
      expect(menu('text', mine: true), MessageMenuOption.values.toSet());
    });

    test('received text: no Edit, no Info, no Delete for everyone', () {
      final o = menu('text', mine: false);
      expect(o, containsAll([
        MessageMenuOption.reply,
        MessageMenuOption.copy,
        MessageMenuOption.forward,
        MessageMenuOption.pin,
        MessageMenuOption.deleteForMe,
      ]));
      expect(o.contains(MessageMenuOption.edit), isFalse);
      expect(o.contains(MessageMenuOption.info), isFalse);
      expect(o.contains(MessageMenuOption.deleteForEveryone), isFalse);
    });

    for (final type in [
      'image', 'media', 'video', 'audio', 'document', 'location', 'contact'
    ]) {
      test('my $type message: no Copy, no Edit, but Info + deletes', () {
        final o = menu(type, mine: true);
        expect(o.contains(MessageMenuOption.copy), isFalse);
        expect(o.contains(MessageMenuOption.edit), isFalse);
        expect(o, containsAll([
          MessageMenuOption.reply,
          MessageMenuOption.forward,
          MessageMenuOption.pin,
          MessageMenuOption.info,
          MessageMenuOption.deleteForEveryone,
          MessageMenuOption.deleteForMe,
        ]));
      });
    }

    test('message with no type is treated as text (Copy + Edit for mine)', () {
      expect(menu(null, mine: true),
          containsAll([MessageMenuOption.copy, MessageMenuOption.edit]));
      expect(menu('', mine: true), contains(MessageMenuOption.copy));
    });

    test('type is case/space-insensitive ("TEXT ")', () {
      expect(menu(' TEXT ', mine: true), contains(MessageMenuOption.edit));
      expect(menu('text_message', mine: false), contains(MessageMenuOption.copy));
    });

    test('attendance_poll: no delete of any kind, even for the creator', () {
      final o = menu('attendance_poll', mine: true);
      expect(o.contains(MessageMenuOption.deleteForEveryone), isFalse);
      expect(o.contains(MessageMenuOption.deleteForMe), isFalse);
      expect(o, contains(MessageMenuOption.info));
      expect(menu('Attendance', mine: false)
          .contains(MessageMenuOption.deleteForMe), isFalse);
    },
        // Passed in Run 1. Commit e761f45a (2026-11-16) removed the attendance
        // rule from menuOptions; guide §5.1 still says "not attendance".
        skip: 'BUG-CS-20 (needs decision): attendance cards show Delete for '
            'me / Delete for everyone again (chat_screen_logic.dart:210-225) '
            'while guide §5.1 says no delete');

    test('Pin is offered for every type (label decides Pin/Unpin)', () {
      for (final t in ['text', 'image', 'attendance', 'location']) {
        expect(menu(t, mine: false), contains(MessageMenuOption.pin));
      }
    });
  });

  // ---------------------------------------------------------------------------
  group('Edit', () {
    test('edit keyed by message_id (snake case) updates the text', () {
      final list = [m(7, content: 'old')];
      expect(ChatScreenRules.applyEdit(list, {'message_id': '7', 'content': 'new'}),
          isTrue);
      expect(list.first.content, 'new');
      expect(list.first.isEdited, isTrue);
      expect(list.first.edited, isTrue);
    });

    test('edit with nested {message:{id, content, editedAt}} payload', () {
      final list = [m(8, content: 'old')];
      final ok = ChatScreenRules.applyEdit(list, {
        'message': {'id': 8, 'content': 'nested', 'editedAt': '2026-01-02T00:00:00Z'},
      });
      expect(ok, isTrue);
      expect(list.first.content, 'nested');
      expect(list.first.editedAt, '2026-01-02T00:00:00Z');
    });

    test('edit with newContent key and a plain-string "message"', () {
      final a = [m(1, content: 'x')];
      ChatScreenRules.applyEdit(a, {'messageId': 1, 'newContent': 'y'});
      expect(a.first.content, 'y');
      final b = [m(2, content: 'x')];
      ChatScreenRules.applyEdit(b, {'id': 2, 'message': 'z'});
      expect(b.first.content, 'z');
    });

    test('edit keeps ticks, reply and sender untouched', () {
      final msg = m(3, seenCount: 1, delivered: true)..replyId = 1;
      ChatScreenRules.applyEdit([msg], {'messageId': 3, 'content': 'e'});
      expect(msg.seenCount, 1);
      expect(msg.isDelivered, isTrue);
      expect(msg.replyId, 1);
      expect(msg.senderId, me);
    });

    test('edit with an unparseable id is ignored', () {
      final list = [m(3, content: 'keep')];
      expect(ChatScreenRules.applyEdit(list, {'messageId': 'abc', 'content': 'x'}),
          isFalse);
      expect(list.first.content, 'keep');
    });

    test('a late edit event never brings back a message deleted for everyone',
        () {
      final msg = m(9, content: 'secret');
      ChatScreenRules.markDeletedForEveryone(msg);
      ChatScreenRules.applyEdit([msg], {'messageId': 9, 'content': 'secret v2'});
      expect(msg.content, 'This message was deleted');
    },
        skip: 'BUG-CS-03: applyEdit() does not check isDeleted, an edit event '
            'arriving after delete-for-everyone restores the text');
  });

  // ---------------------------------------------------------------------------
  group('Delete', () {
    test('delete-for-me with user_id as an int matches my string id', () {
      expect(ChatScreenRules.isDeleteForMeByMe({'user_id': 1}, '1'), isTrue);
      expect(ChatScreenRules.isDeleteForMeByMe({'deletedBy': ' 1 '}, '1'), isTrue);
    });

    test('delete-for-me by someone else is ignored', () {
      expect(ChatScreenRules.isDeleteForMeByMe({'userId': '2'}, '1'), isFalse);
    });

    test('delete-for-me naming a user while I am unknown is ignored', () {
      expect(ChatScreenRules.isDeleteForMeByMe({'userId': '2'}, null), isFalse);
    });

    test('delete-for-me with userId "null" falls back to removing', () {
      expect(ChatScreenRules.isDeleteForMeByMe({'userId': 'null'}, '1'), isTrue);
    });

    test('delete for everyone on a video clears videos and turns into text', () {
      final v = m(5, type: 'video', content: 'u||t||0:10')
        ..videos = [MessageVideo(videoUrl: 'u')]
        ..caption = 'cap';
      ChatScreenRules.markDeletedForEveryone(v);
      expect(v.messageType, 'text');
      expect(v.videos, isEmpty);
      expect(v.caption, isNull);
      expect(v.isDeleted, isTrue);
      expect(v.content, 'This message was deleted');
    });

    test('deleted message no longer offers a reply preview of old content', () {
      final r = m(6, content: 'hello')..replyId = 3;
      ChatScreenRules.markDeletedForEveryone(r);
      expect(r.replyId, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('Ticks - private seen', () {
    test('seen update with string ids matches int message ids', () {
      final list = [m(1), m(2)];
      final ch = ChatScreenRules.applyPrivateSeen(list,
          messageIds: ['1', '2'], readerId: peer, currentUserId: me);
      expect(ch, isTrue);
      expect(list.every((e) => e.seenCount == 1 && e.isDelivered), isTrue);
    });

    test('seen also turns on delivered (double tick) if it was missed', () {
      final list = [m(1, seenCount: 1)];
      final ch = ChatScreenRules.applyPrivateSeen(list,
          messageIds: [1], readerId: peer, currentUserId: me);
      expect(ch, isTrue);
      expect(list.first.isDelivered, isTrue);
    });

    test('ticks never go backwards: seenCount 2 stays 2, no change reported',
        () {
      final list = [m(1, seenCount: '2', delivered: true)];
      final ch = ChatScreenRules.applyPrivateSeen(list,
          messageIds: [1], readerId: peer, currentUserId: me);
      expect(ch, isFalse);
      expect(list.first.seenCount, '2');
    });

    test('the same seen event twice changes nothing the second time', () {
      final list = [m(1)];
      ChatScreenRules.applyPrivateSeen(list,
          messageIds: [1], readerId: peer, currentUserId: me);
      expect(
          ChatScreenRules.applyPrivateSeen(list,
              messageIds: [1], readerId: peer, currentUserId: me),
          isFalse);
    });

    test('peer message ids in the update never get a tick', () {
      final list = [m(1, sender: peer)];
      expect(
          ChatScreenRules.applyPrivateSeen(list,
              messageIds: [1], readerId: peer, currentUserId: me),
          isFalse);
      expect(list.first.seenCount, isNull);
    });

    test('reader without id still marks my listed messages', () {
      final list = [m(1)];
      expect(
          ChatScreenRules.applyPrivateSeen(list,
              messageIds: [1], readerId: null, currentUserId: me),
          isTrue);
    });

    test('chat-wide seen update (empty messageIds) marks all my messages', () {
      final list = [m(1), m(2), m(3, sender: peer)];
      final ch = ChatScreenRules.applyPrivateSeen(list,
          messageIds: const [], readerId: peer, currentUserId: me);
      expect(ch, isTrue);
      expect(list[0].seenCount, 1);
      expect(list[1].seenCount, 1);
    },
        skip: 'BUG-CS-04: applyPrivateSeen() ignores a seen update with an '
            'empty/missing messageIds list (mark_seen is chat-wide); ticks '
            'stay grey. Confirm backend contract.');
  });

  // ---------------------------------------------------------------------------
  group('Ticks - group seen / Seen by', () {
    test('reader id with spaces is trimmed and recorded once', () {
      final list = [m(1)];
      ChatScreenRules.applyGroupSeen(list, readerId: ' 3 ', currentUserId: me);
      ChatScreenRules.applyGroupSeen(list, readerId: '3', currentUserId: me);
      expect(list.first.seenBy, ['3']);
    });

    test('empty reader id is ignored', () {
      final list = [m(1)];
      expect(ChatScreenRules.applyGroupSeen(list, readerId: '  ', currentUserId: me),
          isFalse);
    });

    test('reader already present as an int is not added again', () {
      final list = [m(1, seenBy: [3])];
      expect(ChatScreenRules.applyGroupSeen(list, readerId: '3', currentUserId: me),
          isFalse);
      expect(list.first.seenBy, [3]);
    });

    test('reader already present as a {userId} map is not added again', () {
      final list = [m(1, seenBy: [
        {'userId': 3, 'seenAt': '2026-01-01T00:00:00Z'}
      ])];
      final ch = ChatScreenRules.applyGroupSeen(list,
          readerId: '3', currentUserId: me);
      expect(ch, isFalse);
      expect((list.first.seenBy as List).length, 1);
    },
        skip: 'BUG-CS-05: applyGroupSeen() compares entry.toString() to the id, '
            'so a {userId:3} map entry is not recognised and "3" is appended '
            '(duplicate entry + needless rebuild)');

    test('seenBy that is not a list (null/string) is replaced by a list', () {
      final list = [m(1, seenBy: 'garbage')];
      ChatScreenRules.applyGroupSeen(list, readerId: '4', currentUserId: me);
      expect(list.first.seenBy, ['4']);
    });

    test('Seen by counts maps, strings and ints the same way', () {
      final msg = m(1, seenBy: [
        {'userId': 2},
        {'user_id': '3'},
        {'id': 4},
        '5',
        6,
        null,
        'null',
        '',
      ]);
      expect(ChatScreenRules.seenByOthers(msg, currentUserId: me),
          {'2', '3', '4', '5', '6'});
    });

    test('Seen by never counts the same reader twice in mixed formats', () {
      final msg = m(1, seenBy: [{'userId': 3}, '3', 3]);
      expect(ChatScreenRules.seenCount(msg, currentUserId: me, isGroup: true), 1);
    });

    test('group seenCount without a list uses the server count', () {
      expect(ChatScreenRules.seenCount(m(1, seenCount: '4'),
          currentUserId: me, isGroup: true), 4);
      expect(ChatScreenRules.seenCount(m(1, seenCount: 'x'),
          currentUserId: me, isGroup: true), 0);
      expect(ChatScreenRules.seenCount(m(1, seenCount: -2),
          currentUserId: me), 0);
    });
  });

  // ---------------------------------------------------------------------------
  group('Unsupported messages', () {
    test('unknown type with readable text keeps showing the text', () {
      expect(ChatScreenRules.isUnsupported(m(1, type: 'sticker', content: 'hi')),
          isFalse);
    });

    test('unknown type with JSON or empty content shows the placeholder', () {
      expect(ChatScreenRules.isUnsupported(m(1, type: 'sticker', content: '{"a":1}')),
          isTrue);
      expect(ChatScreenRules.isUnsupported(m(1, type: 'poll_v2', content: '[1]')),
          isTrue);
      expect(ChatScreenRules.isUnsupported(m(1, type: 'x', content: '  ')), isTrue);
    });

    test('known types in upper case are still rendered normally', () {
      expect(ChatScreenRules.isUnsupported(m(1, type: 'IMAGE', content: '')),
          isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('Emoji panel height', () {
    test('a tiny keyboard height (<=120) uses the fallback', () {
      expect(ChatScreenRules.emojiPanelHeight(
          screenHeight: 800, lastKeyboardHeight: 100), 300);
    });

    test('very small screen: 40% even if below the 180 minimum', () {
      expect(ChatScreenRules.emojiPanelHeight(screenHeight: 400), 160);
    });
  });
}
