import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const me = '1001';

Map<String, dynamic> privatePayload({
  int userId = 505,
  int chatId = 2001,
  String name = 'Sarah',
  String content = 'hello',
  String time = '2026-11-01T10:00:00Z',
  int messageId = 1,
  String senderId = '505',
  int? unread,
  bool? archived,
  bool? pinned,
}) =>
    {
      'id': chatId,
      'chatId': chatId,
      'userId': userId,
      'name': name,
      'chatType': 'private',
      'isGroup': false,
      if (unread != null) 'unreadCount': unread,
      if (archived != null) 'isArchived': archived,
      if (pinned != null) 'isPinned': pinned,
      'lastMessage': {
        'id': messageId,
        'content': content,
        'messageType': 'text',
        'senderId': senderId,
        'timestamp': time,
      },
    };

Map<String, dynamic> groupPayload({
  int groupId = 77,
  String content = 'team update',
  String time = '2026-11-01T10:00:00Z',
  int messageId = 10,
  String senderId = '600',
  String senderName = 'Rahul',
  int? unread,
}) =>
    {
      'id': groupId,
      'groupId': groupId,
      'name': 'Ops Team',
      'chatType': 'group',
      'isGroup': true,
      if (unread != null) 'unreadCount': unread,
      'lastMessage': {
        'id': messageId,
        'content': content,
        'messageType': 'text',
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': time,
      },
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ChatListController c;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({PrefConst.userId: me});
    Global.storageServices = await StorageServices().init();
    c = Get.put(ChatListController());
    c.privateChats.clear();
    c.archivedChats.clear();
  });

  List<String> order() =>
      c.displayedChats.map(ChatListRules.chatKey).toList();

  group('new messages', () {
    test('private and group messages insert, newest on top', () {
      c.debugHandleChatUpdated(privatePayload(unread: 1));
      c.debugHandleChatUpdated(
        groupPayload(time: '2026-11-01T11:00:00Z', unread: 2),
      );
      expect(order(), ['group_77', 'private_505']);
      expect(c.displayedChats.first.unreadCount, 2);
    });

    test('wrapped payload ({data: …}) is accepted', () {
      c.debugHandleChatUpdated({'data': privatePayload(unread: 1)});
      expect(order(), ['private_505']);
    });

    test('a newer message moves the chat to the top, below pinned', () {
      c.debugHandleChatUpdated(privatePayload(userId: 1, chatId: 1, pinned: true,
          time: '2026-11-01T08:00:00Z'));
      c.debugHandleChatUpdated(privatePayload(userId: 2, chatId: 2,
          time: '2026-11-01T09:00:00Z'));
      c.debugHandleChatUpdated(privatePayload(userId: 3, chatId: 3,
          time: '2026-11-01T10:00:00Z'));
      c.debugHandleChatUpdated(privatePayload(userId: 2, chatId: 2,
          time: '2026-11-01T11:00:00Z', messageId: 9, content: 'new'));
      expect(order(), ['private_1', 'private_2', 'private_3']);
    });

    test('my own message updates the preview without raising unread', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      c.debugHandleChatUpdated(privatePayload(
        messageId: 2,
        content: 'sent by me',
        senderId: me,
        time: '2026-11-01T10:05:00Z',
        unread: 1, // what a backend sending the receiver's row would send
      ));
      final row = c.displayedChats.single;
      expect(row.unreadCount, 0);
      expect(row.message, 'sent by me');
    });

    test('the same event delivered twice does not double anything', () {
      final payload = privatePayload(unread: 3);
      c.debugHandleChatUpdated(payload);
      c.debugHandleChatUpdated(Map<String, dynamic>.from(payload));
      expect(c.displayedChats, hasLength(1));
      expect(c.displayedChats.single.unreadCount, 3);
      expect(c.totalUnreadCount, 3);
    });

    test('unknown chat with an incomplete payload is not inserted blindly', () {
      c.debugHandleChatUpdated({'chatId': 999, 'unreadCount': 1});
      expect(c.displayedChats, isEmpty);
    });
  });

  group('partial updates never break a row', () {
    test('a partial payload keeps the row, its badge and its pin', () {
      c.debugHandleChatUpdated(privatePayload(unread: 2, pinned: true));
      c.debugHandleChatUpdated({'chatId': 2001, 'userId': 505, 'isOnline': true});
      final row = c.displayedChats.single;
      expect(row.unreadCount, 2);
      expect(row.isPinned, isTrue);
      expect(row.message, 'hello');
    });

    test('read/seen re-send of the same message does not reorder', () {
      c.debugHandleChatUpdated(privatePayload(userId: 1, chatId: 1,
          time: '2026-11-01T09:00:00Z', messageId: 1));
      c.debugHandleChatUpdated(privatePayload(userId: 2, chatId: 2,
          time: '2026-11-01T10:00:00Z', messageId: 2));
      // Same last message of chat 1, newer timestamp (seen update).
      c.debugHandleChatUpdated(privatePayload(userId: 1, chatId: 1,
          time: '2026-11-01T12:00:00Z', messageId: 1, unread: 0));
      expect(order(), ['private_2', 'private_1']);
    });
  });

  group('archived', () {
    test('a new message in an archived chat keeps it archived', () {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.debugHandleChatUpdated(privatePayload(
        messageId: 2,
        content: 'still archived',
        time: '2026-11-01T10:10:00Z',
        unread: 1,
      )); // no isArchived in payload
      expect(c.displayedChats, isEmpty);
      expect(c.displayedArchivedChats, hasLength(1));
      expect(c.archivedUnreadCount, 1);
      expect(c.totalUnreadCount, 0, reason: 'archived excluded from main total');
    });

    test('server push in any order is shown sorted and stays stable', () {
      c.debugHandleArchivedChats({
        'data': [
          privatePayload(userId: 1, chatId: 1, time: '2026-11-01T08:00:00Z'),
          privatePayload(userId: 2, chatId: 2, time: '2026-11-01T10:00:00Z'),
          privatePayload(userId: 3, chatId: 3, time: '2026-11-01T09:00:00Z'),
        ],
      });
      final first =
          c.displayedArchivedChats.map(ChatListRules.chatKey).toList();
      expect(first, ['private_2', 'private_3', 'private_1']);

      // The remote user opens chat 1: a seen update arrives.
      c.debugHandleChatUpdated(privatePayload(userId: 1, chatId: 1,
          time: '2026-11-01T12:00:00Z', unread: 0));
      expect(
        c.displayedArchivedChats.map(ChatListRules.chatKey).toList(),
        first,
      );
    });
  });

  group('typing', () {
    testWidgets('private: shows "typing...", ignores me, clears on message',
        (tester) async {
      c.debugHandleChatUpdated(privatePayload());
      final row = c.displayedChats.single;

      c.debugHandlePrivateTyping({'chatId': 2001, 'userId': me});
      expect(c.typingLabelFor(row), isNull);

      c.debugHandlePrivateTyping(
          {'chatId': 2001, 'userId': 505, 'userName': 'Sarah'});
      expect(c.typingLabelFor(row), 'typing...');
      final before = order();

      c.debugHandleChatUpdated(privatePayload(
          messageId: 5, content: 'done', time: '2026-11-01T10:30:00Z'));
      expect(c.typingLabelFor(c.displayedChats.single), isNull);
      expect(order(), before);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('group: names, stop event and 5s timeout', (tester) async {
      c.debugHandleChatUpdated(groupPayload());
      final row = c.displayedChats.single;

      c.debugHandleGroupTyping({'groupId': 77, 'userId': 600, 'userName': 'Rahul'});
      c.debugHandleGroupTyping({'groupId': 77, 'userId': 601, 'userName': 'Priya'});
      expect(c.typingLabelFor(row), 'Rahul, Priya are typing...');

      c.debugHandleGroupTyping({'groupId': 77, 'userId': 600}, typing: false);
      expect(c.typingLabelFor(row), 'Priya is typing...');

      await tester.pump(const Duration(seconds: 6));
      expect(c.typingLabelFor(row), isNull);
    });
  });

  group('actions', () {
    test('pin while offline is rolled back', () {
      c.debugHandleChatUpdated(privatePayload());
      final row = c.displayedChats.single;
      c.pinChat(row);
      expect(c.displayedChats.single.isPinned, isNot(true));
    });

    test('archive while offline is rolled back to the main list', () {
      c.debugHandleChatUpdated(privatePayload());
      c.archiveChat(c.displayedChats.single);
      expect(c.displayedChats, hasLength(1));
      expect(c.displayedArchivedChats, isEmpty);
    });

    test('mark as unread shows a dot and counts as unread', () async {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      final row = c.displayedChats.single;
      await c.markChatAsUnread(row);
      expect(c.isChatMarkedUnread(row), isTrue);
      expect(c.mainUnreadChatCount, 1);
    });
  });

  test('group preview shows the sender once', () {
    c.debugHandleChatUpdated(groupPayload(content: 'hi'));
    final PrivateChatModel row = c.displayedChats.single;
    expect(row.senderName, 'Rahul');
    expect(row.lastMessageData?['content'], 'hi');
  });
}
