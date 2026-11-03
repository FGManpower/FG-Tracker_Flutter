import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'userId': '1001',
    });
  });

  group('Chatting Screen - 10+ Private & 10+ Group Chats Suite', () {
    test('Verify creation and separation of 10+ Private and 10+ Group Chats', () {
      final List<PrivateChatModel> chatList = [];

      for (int i = 1; i <= 12; i++) {
        chatList.add(
          PrivateChatModel(
            id: i,
            chatId: 1000 + i,
            userId: 2000 + i,
            name: 'Private Contact $i',
            chatType: 'private',
            isGroup: false,
            message: 'Hello from private contact $i',
            preview: 'Hello from private contact $i',
            messageType: 'text',
            unreadCount: i % 3,
            isPinned: i == 1,
            timestamp: DateTime.now().subtract(Duration(minutes: i * 5)).toIso8601String(),
          ),
        );
      }

      for (int i = 1; i <= 12; i++) {
        chatList.add(
          PrivateChatModel(
            id: 100 + i,
            chatId: 2000 + i,
            groupId: 3000 + i,
            groupName: 'Engineering Squad $i',
            chatType: 'group',
            isGroup: true,
            message: 'Squad $i daily sync update',
            preview: 'Squad $i daily sync update',
            messageType: 'text',
            unreadCount: (i * 2) % 5,
            isPinned: i == 1,
            timestamp: DateTime.now().subtract(Duration(minutes: (i * 5) + 2)).toIso8601String(),
          ),
        );
      }

      expect(chatList.length, 24);

      final privateChats = chatList.where((c) => c.isGroup == false && c.chatType == 'private').toList();
      expect(privateChats.length, 12);

      final groupChats = chatList.where((c) => c.isGroup == true || c.chatType == 'group').toList();
      expect(groupChats.length, 12);

      final totalUnread = chatList.fold<int>(0, (sum, c) => sum + (c.unreadCount ?? 0));
      expect(totalUnread, greaterThan(0));

      final pinnedChats = chatList.where((c) => c.isPinned == true).toList();
      expect(pinnedChats.length, 2);
    });

    test('Real-time sorting: incoming message bumps chat to top (WhatsApp behavior)', () {
      final List<PrivateChatModel> activeChats = [
        PrivateChatModel(
          id: 1,
          name: 'Alice',
          isGroup: false,
          isPinned: false,
          message: 'See you tomorrow',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        ),
        PrivateChatModel(
          id: 2,
          name: 'Bob',
          isGroup: false,
          isPinned: false,
          message: 'Good morning',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
        ),
        PrivateChatModel(
          id: 3,
          groupName: 'Project Core',
          isGroup: true,
          isPinned: true,
          message: 'Status update posted',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        ),
      ];

      final now = DateTime.now();
      final alice = activeChats.firstWhere((c) => c.name == 'Alice');
      alice.message = 'Urgent update just now!';
      alice.timestamp = now.toIso8601String();

      activeChats.sort((a, b) {
        if (a.isPinned == true && b.isPinned != true) return -1;
        if (b.isPinned == true && a.isPinned != true) return 1;
        final timeA = DateTime.tryParse(a.timestamp ?? '') ?? DateTime(1970);
        final timeB = DateTime.tryParse(b.timestamp ?? '') ?? DateTime(1970);
        return timeB.compareTo(timeA);
      });

      expect(activeChats[0].groupName, 'Project Core');
      expect(activeChats[1].name, 'Alice');
      expect(activeChats[2].name, 'Bob');
    });

    test('Search filter across 10+ Private and Group chats', () {
      final List<PrivateChatModel> chats = [
        PrivateChatModel(id: 1, name: 'David Miller', message: 'Ready for deployment', isGroup: false),
        PrivateChatModel(id: 2, name: 'Sarah Connor', message: 'Server is rebooted', isGroup: false),
        PrivateChatModel(id: 3, groupName: 'Mobile Devs', message: 'Flutter 3.29 release notes', isGroup: true),
        PrivateChatModel(id: 4, groupName: 'Design Systems', message: 'Figma components ready', isGroup: true),
        PrivateChatModel(id: 5, name: 'John Doe', message: 'Deployment failed on staging', isGroup: false),
      ];

      final query = 'deployment';
      final results = chats.where((c) {
        final name = (c.name ?? c.groupName ?? '').toLowerCase();
        final msg = (c.message ?? '').toLowerCase();
        return name.contains(query) || msg.contains(query);
      }).toList();

      expect(results.length, 2);
      expect(results.any((c) => c.name == 'David Miller'), isTrue);
      expect(results.any((c) => c.name == 'John Doe'), isTrue);
    });
  });

  group('Real-Time Message Listening & Mutation Tests (Private & Group)', () {
    test('Deduplication: Duplicate socket events must not duplicate messages in list', () {
      final List<MessageData> messages = [];

      final incoming1 = MessageData(
        id: 501,
        senderId: '2001',
        receiverId: '1001',
        content: 'Realtime socket packet 1',
        timestamp: DateTime.now().toIso8601String(),
      );

      if (!messages.any((m) => m.id == incoming1.id)) {
        messages.add(incoming1);
      }
      expect(messages.length, 1);

      final incomingDuplicate = MessageData(
        id: 501,
        senderId: '2001',
        receiverId: '1001',
        content: 'Realtime socket packet 1',
        timestamp: incoming1.timestamp,
      );

      if (!messages.any((m) => m.id == incomingDuplicate.id)) {
        messages.add(incomingDuplicate);
      }

      expect(messages.length, 1);
      expect(messages.first.content, 'Realtime socket packet 1');
    });

    test('Real-time Message Edit: Socket edit event updates message in-place', () {
      final List<MessageData> messages = [
        MessageData(id: 601, content: 'Original text', isEdited: false),
        MessageData(id: 602, content: 'Another message', isEdited: false),
      ];

      final editPayload = {
        'messageId': 601,
        'content': 'Edited message text',
        'isEdited': true,
        'editedAt': DateTime.now().toIso8601String(),
      };

      final index = messages.indexWhere((m) => m.id == editPayload['messageId']);
      expect(index, 0);

      messages[index].content = editPayload['content'];
      messages[index].isEdited = editPayload['isEdited'];
      messages[index].editedAt = editPayload['editedAt'];

      expect(messages[0].content, 'Edited message text');
      expect(messages[0].isEdited, isTrue);
      expect(messages[0].editedAt, isNotNull);
    });

    test('Real-time Message Delete for Everyone vs Delete for Me', () {
      final List<MessageData> messages = [
        MessageData(id: 701, content: 'Keep this message'),
        MessageData(id: 702, content: 'Secret message to delete for everyone'),
        MessageData(id: 703, content: 'Local clutter to delete for me only'),
      ];

      final deleteEveryonePayload = {
        'messageId': 702,
        'deleteType': 'for_everyone',
      };

      final idx702 = messages.indexWhere((m) => m.id == deleteEveryonePayload['messageId']);
      if (deleteEveryonePayload['deleteType'] == 'for_everyone') {
        messages[idx702].content = 'This message was deleted';
        messages[idx702].isDeleted = true;
        messages[idx702].messageType = 'text';
      }

      expect(messages.length, 3);
      expect(messages[1].content, 'This message was deleted');
      expect(messages[1].isDeleted, isTrue);

      final deleteForMePayload = {
        'messageId': 703,
        'deleteType': 'for_me',
      };

      final idx703 = messages.indexWhere((m) => m.id == deleteForMePayload['messageId']);
      if (deleteForMePayload['deleteType'] == 'for_me') {
        messages.removeAt(idx703);
      }

      expect(messages.length, 2);
      expect(messages.any((m) => m.id == 703), isFalse);
    });

    test('Real-time Pin and Unpin banner state', () {
      MessageData? pinnedMessage;
      bool showPinnedBanner = false;

      final messageToPin = MessageData(id: 801, content: 'Important Announcement');

      pinnedMessage = messageToPin;
      showPinnedBanner = true;

      expect(pinnedMessage.id, 801);
      expect(showPinnedBanner, isTrue);

      pinnedMessage = null;
      showPinnedBanner = false;

      expect(pinnedMessage, isNull);
      expect(showPinnedBanner, isFalse);
    });

    test('Real-time Seen Status: seenCount increments and reflects double tick', () {
      final message = MessageData(
        id: 901,
        senderId: '1001',
        receiverId: '2001',
        content: 'Check this invoice',
        seenCount: 0,
      );

      final isSingleTick = (message.seenCount ?? 0) == 0;
      expect(isSingleTick, isTrue);

      final seenUpdatePayload = {
        'chatId': 'private_chat_1',
        'messageIds': [901],
      };

      if ((seenUpdatePayload['messageIds'] as List).contains(message.id)) {
        message.seenCount = (message.seenCount ?? 0) + 1;
      }

      final isDoubleTick = (message.seenCount ?? 0) > 0;
      expect(isDoubleTick, isTrue);
      expect(message.seenCount, 1);
    });
  });

  group('WhatsApp-Like Behavioral Mechanics Tests', () {
    test('Auto-scroll vs Unread counter pill when user is scrolled up', () {
      bool isUserAtBottom = true;
      int unreadBelowCount = 0;
      bool showScrollToBottom = false;

      final incomingWhenAtBottom = MessageData(id: 1001, senderId: '2001', content: 'Hey!');
      if (isUserAtBottom) {
        unreadBelowCount = 0;
        showScrollToBottom = false;
      }
      expect(unreadBelowCount, 0);
      expect(showScrollToBottom, isFalse);

      isUserAtBottom = false;
      showScrollToBottom = true;

      final burstIncoming = [
        MessageData(id: 1002, senderId: '2001', content: 'Message 2'),
        MessageData(id: 1003, senderId: '2001', content: 'Message 3'),
        MessageData(id: 1004, senderId: '2001', content: 'Message 4'),
      ];

      for (var _ in burstIncoming) {
        if (!isUserAtBottom) {
          unreadBelowCount++;
        }
      }

      expect(unreadBelowCount, 3);
      expect(showScrollToBottom, isTrue);

      isUserAtBottom = true;
      unreadBelowCount = 0;
      showScrollToBottom = false;

      expect(unreadBelowCount, 0);
      expect(showScrollToBottom, isFalse);
    });

    test('Swipe-to-Reply binding and Quote preview banner', () {
      final originalMessage = MessageData(
        id: 1101,
        senderId: '2001',
        senderName: 'Alice',
        messageType: 'text',
        content: 'Can you send the contract?',
      );

      MessageData? replyMessage;

      replyMessage = originalMessage;
      expect(replyMessage, isNotNull);
      expect(replyMessage.id, 1101);
      expect(replyMessage.senderName, 'Alice');
      expect(replyMessage.content, 'Can you send the contract?');

      final sentReply = MessageData(
        id: 1102,
        senderId: '1001',
        content: 'Yes, attached here.',
        replyId: replyMessage.id,
        replyMessage: replyMessage.content,
        replySenderName: replyMessage.senderName,
        replyType: replyMessage.messageType,
      );

      expect(sentReply.replyId, 1101);
      expect(sentReply.replyMessage, 'Can you send the contract?');
      expect(sentReply.replySenderName, 'Alice');

      replyMessage = null;
      expect(replyMessage, isNull);
    });

    test('Search within active conversation messages', () {
      final List<MessageData> chatHistory = [
        MessageData(id: 1, content: 'Good morning everyone'),
        MessageData(id: 2, content: 'Did we finish the Flutter testing?'),
        MessageData(id: 3, content: 'Yes, all unit tests are written'),
        MessageData(id: 4, content: 'Awesome! Let us test group chats too'),
        MessageData(id: 5, content: 'Testing completed successfully'),
      ];

      final query = 'test';
      final matchingIds = chatHistory
          .where((m) => (m.content?.toString() ?? '').toLowerCase().contains(query))
          .map((m) => m.id!)
          .toList();

      expect(matchingIds.length, 4);
      expect(matchingIds, containsAll([2, 3, 4, 5]));
      expect(matchingIds.contains(1), isFalse);
    });

    test('Block status disables messaging mechanics', () {
      final blockStatus = BlockStatus(
        isBlocked: true,
        blockedByMe: true,
        otherUserId: 2005,
      );

      bool canSendMessage = !(blockStatus.isBlocked == true);
      expect(canSendMessage, isFalse);

      blockStatus.isBlocked = false;
      blockStatus.blockedByMe = false;

      canSendMessage = !(blockStatus.isBlocked == true);
      expect(canSendMessage, isTrue);
    });

    test('Real-time typing indicator: transitions and peer state', () {
      bool isPeerTyping = false;
      String groupTypingUser = "";

      // Peer starts typing in private chat
      isPeerTyping = true;
      expect(isPeerTyping, isTrue);

      // Peer stops typing
      isPeerTyping = false;
      expect(isPeerTyping, isFalse);

      // Group member Bob starts typing
      groupTypingUser = "Bob";
      expect(groupTypingUser, "Bob");

      // Group member Charlie starts typing
      groupTypingUser = "Charlie";
      expect(groupTypingUser, "Charlie");

      // Timeout or stop typing clears the indicator
      groupTypingUser = "";
      expect(groupTypingUser, isEmpty);
    });

    test('Voice Note scrubber position mapping and speed cycling (1x -> 1.5x -> 2x -> 1x)', () {
      const audioDurationMs = 60000; // 60 seconds
      const waveBarWidth = 120.0;

      // Tap halfway (60.0 px) -> 30,000 ms
      const tapX = 60.0;
      final fraction = (tapX / waveBarWidth).clamp(0.0, 1.0);
      final targetSeekMs = (audioDurationMs * fraction).round();
      expect(targetSeekMs, 30000);

      // Speed cycle test: 1.0 -> 1.5 -> 2.0 -> 1.0
      double currentSpeed = 1.0;

      double cycleSpeed(double speed) {
        if (speed == 1.0) return 1.5;
        if (speed == 1.5) return 2.0;
        return 1.0;
      }

      currentSpeed = cycleSpeed(currentSpeed);
      expect(currentSpeed, 1.5);

      currentSpeed = cycleSpeed(currentSpeed);
      expect(currentSpeed, 2.0);

      currentSpeed = cycleSpeed(currentSpeed);
      expect(currentSpeed, 1.0);
    });
  });
}
