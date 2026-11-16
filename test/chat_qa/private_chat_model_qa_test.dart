// QA: PrivateChatModel.fromJson tolerant parsing of chat-list rows.
// Spec: docs/01_CHATTING_MODULE_FRONTEND.md §0.3 (tolerant parsing), §5.2, §6.
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:flutter_test/flutter_test.dart';

PrivateChatModel parse(Map<String, dynamic> j) => PrivateChatModel.fromJson(j);

void main() {
  group('Ids (string or int)', () {
    test('int ids are read as is', () {
      final c = parse({'id': 5, 'chatId': 6, 'userId': 7});
      expect([c.id, c.chatId, c.userId], [5, 6, 7]);
    });

    test('string ids are converted to int', () {
      final c = parse({'id': '5', 'chatId': '6', 'userId': '7', 'groupId': '8'});
      expect([c.id, c.chatId, c.userId, c.groupId], [5, 6, 7, 8]);
    });

    test('snake_case ids are accepted', () {
      final c = parse({'chat_id': 6, 'user_id': 7, 'group_id': 8});
      expect([c.chatId, c.userId, c.groupId], [6, 7, 8]);
    });

    test('ids nested in user / group objects are read', () {
      final p = parse({'chatId': 1, 'user': {'id': 33, 'name': 'Sarah'}});
      expect(p.userId, 33);
      expect(p.name, 'Sarah');
      final g = parse({'group': {'id': 44, 'groupName': 'Ops'}});
      expect(g.groupId, 44);
      expect(g.isGroup, isTrue);
      expect(g.name, 'Ops');
    });

    test('a non-numeric id is null instead of crashing', () {
      final c = parse({'id': 'abc', 'userId': 'x'});
      expect(c.id, isNull);
      expect(c.userId, isNull);
    });
  });

  group('Booleans (true/false, 0/1, "true"/"1")', () {
    for (final v in [true, 1, '1', 'true', 'TRUE', 'yes']) {
      test('isPinned=$v (${v.runtimeType}) is true', () {
        expect(parse({'isPinned': v}).isPinned, isTrue);
      });
    }
    for (final v in [false, 0, '0', 'false']) {
      test('isArchived=$v (${v.runtimeType}) is false', () {
        expect(parse({'isArchived': v}).isArchived, isFalse);
      });
    }

    test('missing isPinned defaults to false, missing isArchived stays null',
        () {
      final c = parse({'id': 1});
      expect(c.isPinned, isFalse);
      expect(c.isArchived, isNull);
    });

    test('archived / is_archived aliases are accepted', () {
      expect(parse({'archived': 1}).isArchived, isTrue);
      expect(parse({'is_archived': 'true'}).isArchived, isTrue);
    });
  });

  group('Online state', () {
    test('isOnline true gives status Online', () {
      final c = parse({'userId': 1, 'isOnline': 1});
      expect(c.isOnline, isTrue);
      expect(c.status, 'Online');
    });

    test('is_online "false" gives status Offline', () {
      final c = parse({'userId': 1, 'is_online': 'false'});
      expect(c.isOnline, isFalse);
      expect(c.status, 'Offline');
    });

    test('online flag nested in user object is read', () {
      expect(parse({'user': {'id': 1, 'isOnline': true}}).isOnline, isTrue);
    });

    test('a group is never shown online', () {
      expect(parse({'groupId': 2, 'isOnline': true}).isOnline, isFalse);
    });
  });

  group('Mute / pin / unread / mark-unread flags', () {
    test('isMuted and mutedUntil are parsed', () {
      final c = parse({
        'isMuted': 1,
        'mutedUntil': '2026-12-01T00:00:00Z',
      });
      expect(c.isMuted, isTrue);
      expect(c.mutedUntil, '2026-12-01T00:00:00Z');
    });

    test('muted_until snake_case is parsed', () {
      expect(parse({'muted_until': '2026-12-01'}).mutedUntil, '2026-12-01');
    });

    test('pinnedAt is parsed', () {
      expect(parse({'isPinned': true, 'pinnedAt': '2026-11-01T00:00:00Z'})
          .pinnedAt, '2026-11-01T00:00:00Z');
    });

    test('unreadCount accepts int, string and the unread alias', () {
      expect(parse({'unreadCount': 3}).unreadCount, 3);
      expect(parse({'unreadCount': '4'}).unreadCount, 4);
      expect(parse({'unread_count': 5}).unreadCount, 5);
      expect(parse({'unread': 6}).unreadCount, 6);
    });

    test('missing unreadCount defaults to 0', () {
      expect(parse({'id': 1}).unreadCount, 0);
    });

    test('isMarkedUnread from another device is parsed', () {
      expect(parse({'isMarkedUnread': 1}).isMarkedUnread, isTrue);
      expect(parse({'is_marked_unread': 'false'}).isMarkedUnread, isFalse);
      expect(parse({'id': 1}).isMarkedUnread, isNull);
    });
  });

  group('Last message', () {
    test('lastMessage object fills text, type, sender and time', () {
      final c = parse({
        'chatId': 1,
        'lastMessage': {
          'id': 10,
          'content': 'hello',
          'messageType': 'text',
          'senderId': 55,
          'senderName': 'Rahul',
          'createdAt': '2026-11-01T10:00:00Z',
        },
      });
      expect(c.message, 'hello');
      expect(c.messageType, 'text');
      expect(c.senderId, '55');
      expect(c.senderName, 'Rahul');
      expect(c.timestamp, '2026-11-01T10:00:00Z');
      expect(c.lastMessageData?['id'], 10);
    });

    test('lastMessage null gives an empty preview, not a crash', () {
      final c = parse({'chatId': 1, 'lastMessage': null});
      expect(c.message, '');
      expect(c.lastMessageData, isNull);
    });

    test('lastMessage given as a plain string is used as the text', () {
      expect(parse({'chatId': 1, 'lastMessage': 'yo'}).message, 'yo');
    });

    test('deleted-for-everyone flag inside lastMessage is read', () {
      final c = parse({
        'chatId': 1,
        'lastMessage': {'id': 1, 'isDeletedForEveryone': 1},
      });
      expect(c.isDeletedForEveryone, isTrue);
    });

    test('top-level is_deleted_for_everyone "true" is read', () {
      expect(parse({'is_deleted_for_everyone': 'true'}).isDeletedForEveryone,
          isTrue);
    });

    test('lastActivity is used when lastMessage is absent', () {
      final c = parse({
        'chatId': 1,
        'lastActivity': {'content': 'from activity', 'timestamp': '2026-11-01'},
      });
      expect(c.message, 'from activity');
      expect(c.timestamp, '2026-11-01');
    });

    test('row time falls back to lastMessageAt then updatedAt', () {
      expect(parse({'lastMessageAt': '2026-11-02'}).timestamp, '2026-11-02');
      expect(parse({'updatedAt': '2026-11-03'}).timestamp, '2026-11-03');
    });

    test('sender nested as an object is read', () {
      final c = parse({
        'lastMessage': {
          'content': 'x',
          'sender': {'id': 9, 'name': 'Priya'},
        },
      });
      expect(c.senderId, '9');
      expect(c.senderName, 'Priya');
    });
  });

  group('Identity / names', () {
    test('missing private name falls back to "Unknown User"', () {
      expect(parse({'chatId': 1}).name, 'Unknown User');
    });

    test('missing group name falls back to "Group"', () {
      expect(parse({'groupId': 1}).name, 'Group');
    });

    test('chatType "group" marks the row as a group', () {
      final c = parse({'id': 1, 'chatType': 'group'});
      expect(c.isGroup, isTrue);
    });

    test('explicit isGroup false wins over chatType', () {
      expect(parse({'id': 1, 'isGroup': 0, 'chatType': 'private'}).isGroup,
          isFalse);
    });
  });

  group('Response wrapper', () {
    test('unreadTotalCount and pagination are parsed (string values)', () {
      final r = PrivateChatResponse.fromJson({
        'status': 'true',
        'unreadTotalCount': '12',
        'pagination': {'currentPage': '2', 'hasNextPage': 1},
        'data': [
          {'chatId': 1},
          'junk',
          {'chatId': 2},
        ],
      });
      expect(r.status, isTrue);
      expect(r.unreadTotalCount, 12);
      expect(r.pagination?.currentPage, 2);
      expect(r.pagination?.hasNextPage, isTrue);
      expect(r.data, hasLength(2), reason: 'non-map rows are skipped');
    });

    test('data that is not a list gives an empty list', () {
      expect(PrivateChatResponse.fromJson({'data': null}).data, isEmpty);
    });
  });
}
