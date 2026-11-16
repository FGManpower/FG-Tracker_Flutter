// QA: ChatListController behaviour (row actions, realtime merge, archive,
// unread, delete preview, search, typing).
// Spec: docs/01_CHATTING_MODULE_FRONTEND.md §0.3, §5.2, §6.
//
// In tests there is no access token, so every REST action call fails: this
// exercises the "request failed -> rollback" path deterministically.
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/message_preview_builder.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/active_chat_tracker.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
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
  String? content = 'hello',
  String? time = '2026-11-01T10:00:00Z',
  int messageId = 1,
  String senderId = '505',
  int? unread,
  bool? archived,
  bool? pinned,
  bool? deletedForEveryone,
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
        if (content != null) 'content': content,
        'messageType': 'text',
        'senderId': senderId,
        if (time != null) 'timestamp': time,
        if (deletedForEveryone != null)
          'isDeletedForEveryone': deletedForEveryone,
      },
    };

Map<String, dynamic> groupPayload({
  int groupId = 77,
  String name = 'Ops Team',
  String content = 'team update',
  String time = '2026-11-01T10:00:00Z',
  int messageId = 10,
  String senderId = '600',
  String senderName = 'Rahul',
  int? unread,
  bool? archived,
}) =>
    {
      'id': groupId,
      'groupId': groupId,
      'name': name,
      'chatType': 'group',
      'isGroup': true,
      if (unread != null) 'unreadCount': unread,
      if (archived != null) 'isArchived': archived,
      'lastMessage': {
        'id': messageId,
        'content': content,
        'messageType': 'text',
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': time,
      },
    };

/// Shape of a `receive_message` event heard by the list socket: a MESSAGE,
/// whose `id` is the message id, not the chat id.
Map<String, dynamic> receiveMessagePayload({
  int messageId = 9001,
  int conversationId = 2001,
  String senderId = '505',
  String content = 'hey there',
  String time = '2026-11-01T11:00:00Z',
}) =>
    {
      'id': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': me,
      'content': content,
      'messageType': 'text',
      'createdAt': time,
    };

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ChatListController c;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({PrefConst.userId: me});
    Global.storageServices = await StorageServices().init();
    c = Get.put(ChatListController());
    await settle(); // let the initial (failing) loads finish
    c.privateChats.clear();
    c.archivedChats.clear();
    c.manuallyUnreadChatKeys.clear();
  });

  tearDown(() {
    ActiveChatTracker.closePrivate('505');
    ActiveChatTracker.closeGroup(77);
  });

  List<String> order() => c.displayedChats.map(ChatListRules.chatKey).toList();
  List<String> archivedOrder() =>
      c.displayedArchivedChats.map(ChatListRules.chatKey).toList();
  PrivateChatModel rowOf(String key) =>
      [...c.privateChats, ...c.archivedChats]
          .firstWhere((r) => ChatListRules.chatKey(r) == key);
  String previewOf(String key) =>
      MessagePreviewBuilder.forChat(rowOf(key), currentUserId: me).rowText;

  void seedThree() {
    c.debugHandleChatUpdated(
        privatePayload(userId: 1, chatId: 1, time: '2026-11-01T08:00:00Z'));
    c.debugHandleChatUpdated(
        privatePayload(userId: 2, chatId: 2, time: '2026-11-01T09:00:00Z'));
    c.debugHandleChatUpdated(
        privatePayload(userId: 3, chatId: 3, time: '2026-11-01T10:00:00Z'));
  }

  // -------------------------------------------------------------------------
  group('New message moves the row to the top', () {
    test('a newer message moves an older chat to the top', () {
      seedThree();
      c.debugHandleChatUpdated(privatePayload(
          userId: 1,
          chatId: 1,
          messageId: 50,
          content: 'newest',
          time: '2026-11-01T12:00:00Z'));
      expect(order(), ['private_1', 'private_3', 'private_2']);
      expect(rowOf('private_1').message, 'newest');
    });

    test(
        'a new message whose payload carries no time still moves the row '
        'to the top (suspected bug #1)', () {
      seedThree();
      c.debugHandleChatUpdated(privatePayload(
          userId: 1, chatId: 1, messageId: 50, content: 'no time', time: null));
      expect(rowOf('private_1').message, 'no time');
      expect(order().first, 'private_1');
    },
        skip: 'BUG-CL-01: update without a time keeps the old row time, so '
            'the row does not move to the top (chat_list_controller.dart:1643-1651)');

    test('a brand-new chat appears in the list with its preview', () {
      c.debugHandleChatUpdated(privatePayload(unread: 1));
      expect(order(), ['private_505']);
      expect(previewOf('private_505'), 'hello');
    });

    test('a group and a private chat with the same number are two rows', () {
      c.debugHandleChatUpdated(privatePayload(userId: 77, chatId: 77));
      c.debugHandleChatUpdated(groupPayload(groupId: 77,
          time: '2026-11-01T11:00:00Z'));
      expect(order(), ['group_77', 'private_77']);
      // An update to the group leaves the private row untouched.
      c.debugHandleChatUpdated(groupPayload(groupId: 77, messageId: 11,
          content: 'group only', time: '2026-11-01T12:00:00Z'));
      expect(rowOf('private_77').message, 'hello');
      expect(rowOf('group_77').message, 'group only');
    });

    test('read receipt for the same message does not move the row', () {
      seedThree();
      c.debugHandleChatUpdated(privatePayload(
          userId: 1, chatId: 1, time: '2026-11-01T13:00:00Z', unread: 0));
      expect(order(), ['private_3', 'private_2', 'private_1']);
    });

    test('a receive_message event updates the row preview', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      c.debugHandleChatUpdated(receiveMessagePayload());
      expect(c.displayedChats, hasLength(1));
      expect(rowOf('private_505').message, 'hey there');
    });

    test(
        'a receive_message event does not overwrite the chat id with the '
        'message id (suspected bug #2)', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      c.debugHandleChatUpdated(receiveMessagePayload(messageId: 9001));
      expect(rowOf('private_505').id, 2001);
    },
        skip: 'BUG-CL-02: receive_message `id` (message id) replaces the row '
            'id (PrivateChatModel.dart:294-300 + chat_list_controller.dart:1654)');
  });

  // -------------------------------------------------------------------------
  group('Unread badge', () {
    test('server unreadCount wins', () {
      c.debugHandleChatUpdated(privatePayload(unread: 1));
      c.debugHandleChatUpdated(privatePayload(
          messageId: 2, content: 'x', time: '2026-11-01T10:01:00Z', unread: 7));
      expect(rowOf('private_505').unreadCount, 7);
    });

    test('without a server count a new peer message adds exactly 1', () {
      c.debugHandleChatUpdated(privatePayload(unread: 2));
      c.debugHandleChatUpdated(privatePayload(
          messageId: 2, content: 'x', time: '2026-11-01T10:01:00Z'));
      expect(rowOf('private_505').unreadCount, 3);
    });

    test('the same message delivered twice counts once (dedupe by id)', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      final p = privatePayload(
          messageId: 2, content: 'x', time: '2026-11-01T10:01:00Z');
      c.debugHandleChatUpdated(p);
      c.debugHandleChatUpdated(Map<String, dynamic>.from(p)
        ..['lastMessage'] = Map<String, dynamic>.from(p['lastMessage'] as Map));
      expect(rowOf('private_505').unreadCount, 1);
    });

    test('receive_message delivered twice never counts twice', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      c.debugHandleChatUpdated(receiveMessagePayload());
      final afterFirst = rowOf('private_505').unreadCount;
      c.debugHandleChatUpdated(receiveMessagePayload());
      expect(rowOf('private_505').unreadCount, afterFirst);
    });

    test('a receive_message from the peer (no server count) adds 1', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      c.debugHandleChatUpdated(receiveMessagePayload());
      expect(rowOf('private_505').unreadCount, 1);
    },
        skip: 'BUG-CL-06: top-level senderId of a receive_message is not read '
            '(only lastMessage.senderId), so the sender is "unknown" and the '
            'badge stays 0 (PrivateChatModel.dart:266, chat_list_logic.dart:154)');

    test('a message deleted for everyone never raises the badge', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      c.debugHandleChatUpdated(privatePayload(
          messageId: 2,
          content: MessagePreviewBuilder.deletedText,
          time: '2026-11-01T10:01:00Z',
          deletedForEveryone: true));
      expect(rowOf('private_505').unreadCount, 0);
    });

    test('my own message never raises my badge', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      c.debugHandleChatUpdated(privatePayload(
          messageId: 2, content: 'mine', senderId: me,
          time: '2026-11-01T10:01:00Z'));
      expect(rowOf('private_505').unreadCount, 0);
    });

    test('the chat open on screen always shows 0 unread', () {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      ActiveChatTracker.openPrivate(peerUserId: '505', chatId: '2001');
      c.debugHandleChatUpdated(privatePayload(
          messageId: 2, content: 'x', time: '2026-11-01T10:01:00Z', unread: 4));
      expect(rowOf('private_505').unreadCount, 0);
    });

    test('a newly appearing chat that is open on screen shows 0 unread', () {
      ActiveChatTracker.openGroup(77);
      c.debugHandleChatUpdated(groupPayload(unread: 3));
      expect(rowOf('group_77').unreadCount, 0);
    });

    test('closing a chat clears its badge locally', () {
      c.debugHandleChatUpdated(privatePayload(unread: 5));
      c.clearUnreadForOpenedChat(chatId: 2001, peerUserId: 505);
      expect(rowOf('private_505').unreadCount, 0);
      expect(c.totalUnreadCount, 0);
    });

    test('read grace: a stale server count right after reading is ignored',
        () {
      c.debugHandleChatUpdated(privatePayload(unread: 5));
      c.clearUnreadForOpenedChat(chatId: 2001, peerUserId: 505);
      // Same last message re-sent with the count computed before the read.
      c.debugHandleChatUpdated(privatePayload(unread: 5));
      expect(rowOf('private_505').unreadCount, 0);
    });

    test('read grace: a truly new message still counts', () {
      c.debugHandleChatUpdated(privatePayload(unread: 5));
      c.clearUnreadForOpenedChat(chatId: 2001, peerUserId: 505);
      c.debugHandleChatUpdated(privatePayload(
          messageId: 2, content: 'new', time: '2026-11-01T10:05:00Z',
          unread: 1));
      expect(rowOf('private_505').unreadCount, 1);
    });

    test('read grace ends after 15 seconds (server count wins again)',
        () async {
      c.debugHandleChatUpdated(privatePayload(unread: 5));
      c.clearUnreadForOpenedChat(chatId: 2001, peerUserId: 505);
      await Future<void>.delayed(const Duration(seconds: 16));
      c.debugHandleChatUpdated(privatePayload(unread: 2));
      expect(rowOf('private_505').unreadCount, 2);
    }, timeout: const Timeout(Duration(seconds: 40)));

    test('main total excludes archived chats', () {
      c.debugHandleChatUpdated(privatePayload(unread: 2));
      c.debugHandleChatUpdated(groupPayload(unread: 4, archived: true));
      expect(c.totalUnreadCount, 2);
      expect(c.archivedUnreadCount, 4);
    });
  });

  // -------------------------------------------------------------------------
  group('Delete (preview)', () {
    test('lastMessage null clears the preview in the main list', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandleChatUpdated(
          {'chatId': 2001, 'userId': 505, 'lastMessage': null});
      final r = rowOf('private_505');
      expect(r.message, isEmpty);
      expect(r.preview, isEmpty);
      expect(r.lastMessageData, isNull);
    });

    test('lastMessage null clears the preview in the Archive list', () {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.debugHandleChatUpdated(
          {'chatId': 2001, 'userId': 505, 'lastMessage': null});
      expect(c.displayedArchivedChats.single.message, isEmpty);
    });

    test('peer deleted for everyone: "This message was deleted"', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandleChatUpdated(privatePayload(
          content: MessagePreviewBuilder.deletedText,
          deletedForEveryone: true));
      expect(previewOf('private_505'), 'This message was deleted');
    });

    test('I deleted for everyone: "You deleted this message"', () {
      c.debugHandleChatUpdated(privatePayload(senderId: me));
      c.debugHandleChatUpdated(privatePayload(
          senderId: me,
          content: MessagePreviewBuilder.deletedText,
          deletedForEveryone: true));
      expect(previewOf('private_505'), 'You deleted this message');
    });

    test(
        'delete-for-everyone payload with no message text still shows the '
        'deleted preview (suspected bug #4)', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandleChatUpdated(privatePayload(
          content: null, deletedForEveryone: true));
      expect(previewOf('private_505'), 'This message was deleted');
    });

    test('a later presence-only update keeps the deleted preview', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandleChatUpdated(privatePayload(
          content: MessagePreviewBuilder.deletedText,
          deletedForEveryone: true));
      c.debugHandleChatUpdated(
          {'chatId': 2001, 'userId': 505, 'isOnline': true});
      expect(previewOf('private_505'), 'This message was deleted');
    });

    test(
        'a later presence-only update keeps the deleted flag when the delete '
        'payload had no text', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandleChatUpdated(
          privatePayload(content: null, deletedForEveryone: true));
      expect(rowOf('private_505').isDeletedForEveryone, isTrue);
      c.debugHandleChatUpdated(
          {'chatId': 2001, 'userId': 505, 'isOnline': true});
      expect(rowOf('private_505').isDeletedForEveryone, isTrue);
      expect(previewOf('private_505'), 'This message was deleted');
    },
        skip: 'BUG-CL-07: fromJson defaults a missing isDeletedForEveryone to '
            'false and _clearAbsentFlags does not null it, so any partial update '
            'un-deletes the row and the old text reappears '
            '(PrivateChatModel.dart:333-339, chat_list_controller.dart:1349-1358)');

    test('delete for me (older last message) does not bump unread or move up',
        () {
      seedThree();
      c.debugHandleChatUpdated(privatePayload(
          userId: 2, chatId: 2, messageId: 5, content: 'second',
          time: '2026-11-01T11:00:00Z', unread: 0));
      final before = order();
      expect(before.first, 'private_2');
      // Server answers "delete for me" with the previous (older) message.
      c.debugHandleChatUpdated(privatePayload(
          userId: 2, chatId: 2, messageId: 1, content: 'hello',
          time: '2026-11-01T09:00:00Z'));
      expect(rowOf('private_2').unreadCount, 0);
      expect(rowOf('private_2').message, 'hello');
    });

    test('open chat pushes a deleted last message to its row', () {
      c.debugHandleChatUpdated(privatePayload());
      c.syncLastMessageFromChat(
        chatId: 2001,
        peerUserId: 505,
        last: MessageData(
          id: 1,
          senderId: 505,
          content: MessagePreviewBuilder.deletedText,
          messageType: 'text',
          timestamp: '2026-11-01T10:00:00Z',
        ),
      );
      expect(rowOf('private_505').isDeletedForEveryone, isTrue);
      expect(previewOf('private_505'), 'This message was deleted');
    });

    test('open chat cleared (no messages) empties the row preview', () {
      c.debugHandleChatUpdated(privatePayload());
      c.syncLastMessageFromChat(chatId: 2001, peerUserId: 505, last: null);
      expect(rowOf('private_505').message, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('Archive / Unarchive', () {
    test('archive moves the chat to Archive immediately (optimistic)', () {
      c.debugHandleChatUpdated(privatePayload());
      c.archiveChat(c.displayedChats.single);
      expect(c.displayedChats, isEmpty);
      expect(archivedOrder(), ['private_505']);
    });

    test('archiving a pinned chat unpins it', () {
      c.debugHandleChatUpdated(privatePayload(pinned: true));
      c.archiveChat(c.displayedChats.single);
      expect(c.displayedArchivedChats.single.isPinned, isFalse);
    });

    test('archive failure rolls the chat back to the main list', () async {
      c.debugHandleChatUpdated(privatePayload());
      c.archiveChat(c.displayedChats.single);
      await settle();
      expect(order(), ['private_505']);
      expect(c.displayedArchivedChats, isEmpty);
    });

    test('server confirmation before the failure keeps the chat archived',
        () async {
      c.debugHandleChatUpdated(privatePayload());
      c.archiveChat(c.displayedChats.single);
      c.debugHandleChatUpdated(privatePayload(archived: true));
      await settle();
      expect(c.displayedChats, isEmpty);
      expect(archivedOrder(), ['private_505']);
    });

    test('unarchive moves the chat back to the main list (optimistic)', () {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.unarchiveChat(c.displayedArchivedChats.single);
      expect(order(), ['private_505']);
      expect(c.displayedArchivedChats, isEmpty);
    });

    test('unarchive failure puts the chat back into Archive', () async {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.unarchiveChat(c.displayedArchivedChats.single);
      await settle();
      expect(c.displayedChats, isEmpty);
      expect(archivedOrder(), ['private_505']);
    });

    test('a group can be archived and rolled back too', () async {
      c.debugHandleChatUpdated(groupPayload());
      c.archiveChat(c.displayedChats.single);
      expect(archivedOrder(), ['group_77']);
      await settle();
      expect(order(), ['group_77']);
    });

    test('an event with isArchived:false never un-archives an archived chat',
        () {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.debugHandleChatUpdated(privatePayload(
          archived: false, messageId: 2, content: 'x',
          time: '2026-11-01T10:01:00Z'));
      expect(c.displayedChats, isEmpty);
      expect(archivedOrder(), ['private_505']);
    });

    test('server archived list removes the chat from the main list', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandleArchivedChats({'data': [privatePayload()]});
      expect(c.displayedChats, isEmpty);
      expect(archivedOrder(), ['private_505']);
    });

    test('archived lists are merged: a private-only reply keeps archived groups',
        () {
      c.debugHandleArchivedChats({'data': [groupPayload()]});
      c.debugHandleArchivedChats({'data': [privatePayload()]});
      expect(archivedOrder().toSet(), {'group_77', 'private_505'});
    });

    test('an error/malformed archived reply does not wipe the Archive list',
        () {
      c.debugHandleArchivedChats({'data': [groupPayload()]});
      c.debugHandleArchivedChats({'status': false, 'message': 'server error'});
      expect(archivedOrder(), ['group_77']);
    },
        skip: 'BUG-CL-03: archived_private_chats without a data list clears '
            'the whole Archive (chat_list_controller.dart:2267-2279), '
            'contradicts "merge, never replace" (doc §6.1)');

    test('pending unarchive is not undone by an archived list push', () {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.unarchiveChat(c.displayedArchivedChats.single);
      c.debugHandleArchivedChats({'data': [privatePayload()]});
      expect(order(), ['private_505']);
    });

    test('archived list push in any order is shown newest first', () {
      c.debugHandleArchivedChats({
        'data': [
          privatePayload(userId: 1, chatId: 1, time: '2026-11-01T08:00:00Z'),
          privatePayload(userId: 2, chatId: 2, time: '2026-11-01T10:00:00Z'),
        ],
      });
      expect(archivedOrder(), ['private_2', 'private_1']);
    });
  });

  // -------------------------------------------------------------------------
  group('Pin / Unpin', () {
    test('pin puts the chat on top at once and stamps pinnedAt', () {
      seedThree();
      c.pinChat(rowOf('private_1'));
      expect(order().first, 'private_1');
      expect(rowOf('private_1').isPinned, isTrue);
      expect(rowOf('private_1').pinnedAt, isNotNull);
    });

    test('pin failure rolls back the pin and the order', () async {
      seedThree();
      c.pinChat(rowOf('private_1'));
      await settle();
      expect(rowOf('private_1').isPinned, isNot(true));
      expect(order(), ['private_3', 'private_2', 'private_1']);
    });

    test('unpin removes the pin at once', () {
      c.debugHandleChatUpdated(privatePayload(pinned: true));
      c.unpinChat(rowOf('private_505'));
      expect(rowOf('private_505').isPinned, isFalse);
      expect(rowOf('private_505').pinnedAt, isNull);
    });

    test('unpin failure restores the pin', () async {
      c.debugHandleChatUpdated(privatePayload(pinned: true));
      c.unpinChat(rowOf('private_505'));
      await settle();
      expect(rowOf('private_505').isPinned, isTrue);
    });

    test('server action error rolls back the matching pending action', () {
      c.debugHandleChatUpdated(privatePayload());
      c.pinChat(rowOf('private_505'));
      c.debugHandleActionError({'chatId': 2001, 'message': 'not allowed'});
      expect(rowOf('private_505').isPinned, isNot(true));
    });

    test('an action error with nothing pending does not crash or change rows',
        () {
      c.debugHandleChatUpdated(privatePayload(pinned: true));
      c.debugHandleActionError({'message': 'oops'});
      expect(rowOf('private_505').isPinned, isTrue);
    });

    test('a partial update never unpins a pinned chat', () {
      c.debugHandleChatUpdated(privatePayload(pinned: true));
      c.debugHandleChatUpdated({'chatId': 2001, 'userId': 505, 'isOnline': true});
      expect(rowOf('private_505').isPinned, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('Mute', () {
    test('mute with a duration sets isMuted and mutedUntil at once', () {
      c.debugHandleChatUpdated(privatePayload());
      c.muteChat(rowOf('private_505'), mutedUntil: '2026-12-01T00:00:00Z');
      expect(rowOf('private_505').isMuted, isTrue);
      expect(rowOf('private_505').mutedUntil, '2026-12-01T00:00:00Z');
    });

    test('unmute clears isMuted and mutedUntil', () {
      c.debugHandleChatUpdated(privatePayload());
      c.muteChat(rowOf('private_505'), mutedUntil: '2026-12-01T00:00:00Z');
      c.unmuteChat(rowOf('private_505'));
      expect(rowOf('private_505').isMuted, isFalse);
      expect(rowOf('private_505').mutedUntil, isNull);
    });

    test('mute failure rolls the mute back (doc §5.2: all actions)', () async {
      c.debugHandleChatUpdated(privatePayload());
      c.muteChat(rowOf('private_505'), mutedUntil: '2026-12-01T00:00:00Z');
      await settle();
      expect(rowOf('private_505').isMuted, isNot(true));
    },
        skip: 'BUG-CL-04: mute/unmute swallow the API error with no rollback '
            '(chat_list_controller.dart:1733-1739, 1764-1770)');
  });

  // -------------------------------------------------------------------------
  group('Mark as read / unread', () {
    test('mark as unread shows the dot and counts the chat as unread',
        () async {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      await c.markChatAsUnread(rowOf('private_505'));
      expect(c.isChatMarkedUnread(rowOf('private_505')), isTrue);
      expect(c.mainUnreadChatCount, 1);
    });

    test('mark as unread is kept even when the server call fails', () async {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      await c.markChatAsUnread(rowOf('private_505'));
      await settle();
      expect(c.isChatMarkedUnread(rowOf('private_505')), isTrue);
    });

    test('mark as unread survives an app restart (saved locally)', () async {
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      await c.markChatAsUnread(rowOf('private_505'));
      Get.delete<ChatListController>(force: true);
      final again = Get.put(ChatListController());
      await settle();
      expect(again.manuallyUnreadChatKeys, contains('private_505'));
    });

    test('mark as read clears badge, manual dot and server dot', () async {
      c.debugHandleChatUpdated(privatePayload(unread: 4));
      await c.markChatAsUnread(rowOf('private_505'));
      rowOf('private_505').isMarkedUnread = true;
      await c.markChatAsRead(rowOf('private_505'));
      final r = rowOf('private_505');
      expect(r.unreadCount, 0);
      expect(r.isMarkedUnread, isFalse);
      expect(c.isChatMarkedUnread(r), isFalse);
      expect(c.mainUnreadChatCount, 0);
    });

    test('isMarkedUnread from another device shows the dot', () {
      c.debugHandleChatUpdated(
          {...privatePayload(unread: 0), 'isMarkedUnread': true});
      expect(c.isChatMarkedUnread(rowOf('private_505')), isTrue);
    });

    test('opening the chat clears a server marked-unread dot', () async {
      c.debugHandleChatUpdated(
          {...privatePayload(unread: 0), 'isMarkedUnread': true});
      await c.clearManualUnreadForPrivate(userId: 505, chatId: 2001);
      expect(c.isChatMarkedUnread(rowOf('private_505')), isFalse);
    });

    test('group mark unread is cleared when the group is opened', () async {
      c.debugHandleChatUpdated(groupPayload(unread: 0));
      await c.markChatAsUnread(rowOf('group_77'));
      expect(c.isChatMarkedUnread(rowOf('group_77')), isTrue);
      await c.clearManualUnreadForGroup(77);
      expect(c.isChatMarkedUnread(rowOf('group_77')), isFalse);
    });

    test('marking a group unread does not mark the private chat with same id',
        () async {
      c.debugHandleChatUpdated(groupPayload(groupId: 77, unread: 0));
      c.debugHandleChatUpdated(privatePayload(userId: 77, chatId: 77, unread: 0));
      await c.markChatAsUnread(rowOf('group_77'));
      expect(c.isChatMarkedUnread(rowOf('private_77')), isFalse);
    });

    test(
        'marking one private chat unread does not mark another person '
        'whose user id equals its chat id', () async {
      // Chat with Sarah: userId 505, chatId 2001.
      c.debugHandleChatUpdated(privatePayload(unread: 0));
      // Chat with a different person whose userId is 2001.
      c.debugHandleChatUpdated(privatePayload(
          userId: 2001, chatId: 3000, name: 'Amit', unread: 0));
      await c.markChatAsUnread(rowOf('private_505'));
      expect(c.isChatMarkedUnread(rowOf('private_2001')), isFalse);
    },
        skip: 'BUG-CL-05: manual-unread keys mix user ids and chat ids '
            '(private_<chatId>), so another chat is also shown unread '
            '(chat_list_controller.dart:219-224)');
  });

  // -------------------------------------------------------------------------
  group('Delete chat', () {
    test('delete removes the chat at once (main list)', () {
      seedThree();
      c.deleteChat(rowOf('private_2'));
      expect(order(), ['private_3', 'private_1']);
    });

    test('delete removes an archived chat at once', () {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.deleteChat(c.displayedArchivedChats.single);
      expect(c.displayedArchivedChats, isEmpty);
    });

    test('delete failure brings the chat back in its place', () async {
      seedThree();
      c.deleteChat(rowOf('private_2'));
      await settle();
      expect(order(), ['private_3', 'private_2', 'private_1']);
    });

    test('delete failure of an archived chat restores it into Archive',
        () async {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.deleteChat(c.displayedArchivedChats.single);
      await settle();
      expect(archivedOrder(), ['private_505']);
      expect(c.displayedChats, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('Search', () {
    setUp(() {
      c.debugHandleChatUpdated(privatePayload(
          userId: 1, chatId: 1, name: 'Sarah Khan', content: 'see you'));
      c.debugHandleChatUpdated(privatePayload(
          userId: 2, chatId: 2, name: 'Amit', content: 'Invoice ready',
          time: '2026-11-01T11:00:00Z'));
      c.debugHandleChatUpdated(groupPayload(name: 'Ops Team'));
    });

    tearDown(() => c.searchQuery.value = '');

    test('matches the chat name, case-insensitive', () {
      c.searchQuery.value = 'sArAh';
      expect(order(), ['private_1']);
    });

    test('matches the last message text', () {
      c.searchQuery.value = 'invoice';
      expect(order(), ['private_2']);
    });

    test('matches a group name', () {
      c.searchQuery.value = 'ops';
      expect(order(), ['group_77']);
    });

    test('surrounding spaces are ignored', () {
      c.searchQuery.value = '  amit  ';
      expect(order(), ['private_2']);
    });

    test('no match gives an empty list', () {
      c.searchQuery.value = 'zzz';
      expect(c.displayedChats, isEmpty);
    });

    test('clearing the search shows every chat again', () {
      c.searchQuery.value = 'amit';
      c.clearSearch();
      expect(c.displayedChats, hasLength(3));
    });

    test('archived chats never appear in main-list search', () {
      c.debugHandleChatUpdated(privatePayload(
          userId: 9, chatId: 9, name: 'Hidden', archived: true));
      c.searchQuery.value = 'hidden';
      expect(c.displayedChats, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('Typing labels', () {
    test('private typing routed by chatId shows "typing..." on that row', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandlePrivateTyping({'chatId': 2001, 'userId': 505});
      expect(c.typingLabelFor(rowOf('private_505')), 'typing...');
      c.debugHandlePrivateTyping({'chatId': 2001, 'userId': 505},
          typing: false);
      expect(c.typingLabelFor(rowOf('private_505')), isNull);
    });

    test('my own typing event is ignored', () {
      c.debugHandleChatUpdated(privatePayload());
      c.debugHandlePrivateTyping({'chatId': 2001, 'userId': me});
      expect(c.typingLabelFor(rowOf('private_505')), isNull);
    });

    test('"typing" event carrying a groupId goes to the group row only', () {
      c.debugHandleChatUpdated(privatePayload(userId: 600, chatId: 3));
      c.debugHandleChatUpdated(groupPayload());
      c.debugHandlePrivateTyping(
          {'groupId': 77, 'userId': 600, 'userName': 'Rahul'});
      expect(c.typingLabelFor(rowOf('group_77')), 'Rahul is typing...');
      expect(c.typingLabelFor(rowOf('private_600')), isNull);
      c.debugHandleGroupTyping({'groupId': 77, 'userId': 600}, typing: false);
    });

    test('isTyping:false inside a typing event stops the indicator', () {
      c.debugHandleChatUpdated(groupPayload());
      c.debugHandleGroupTyping(
          {'groupId': 77, 'userId': 600, 'userName': 'Rahul'});
      c.debugHandleGroupTyping(
          {'groupId': 77, 'userId': 600, 'isTyping': false});
      expect(c.typingLabelFor(rowOf('group_77')), isNull);
    });

    test('typing shows on an archived chat row too', () {
      c.debugHandleChatUpdated(privatePayload(archived: true));
      c.debugHandlePrivateTyping({'chatId': 2001, 'userId': 505});
      expect(c.typingLabelFor(c.displayedArchivedChats.single), 'typing...');
      c.debugHandlePrivateTyping({'chatId': 2001, 'userId': 505},
          typing: false);
    });

    test('a group message from the typist clears the group typing label', () {
      c.debugHandleChatUpdated(groupPayload());
      c.debugHandleGroupTyping(
          {'groupId': 77, 'userId': 600, 'userName': 'Rahul'});
      c.debugHandleChatUpdated(groupPayload(
          messageId: 11, content: 'done', time: '2026-11-01T10:05:00Z'));
      expect(c.typingLabelFor(rowOf('group_77')), isNull);
    });
  });
}
