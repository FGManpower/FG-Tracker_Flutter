import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const me = '1001';

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
    c.manuallyUnreadChatKeys.clear();
  });

  tearDown(() {
    Get.reset();
  });

  group('Empty Chat (0 Messages) Visibility & Refresh Retention', () {
    test(
        'Case A: Empty chat with 0 messages (no preview, no time) is visible in displayedChats on 1st time load',
        () {
      // 1. Chat with regular messages
      final normalChat = PrivateChatModel(
        id: 1,
        chatId: 1,
        userId: 201,
        name: 'Alice',
        message: 'Hello!',
        preview: 'Hello!',
        messageType: 'text',
        time: '2026-11-20T10:00:00Z',
        timestamp: '2026-11-20T10:00:00Z',
      );

      // 2. Newly started chat with 0 messages (Jisme chat nahi hua ho)
      final emptyChat = PrivateChatModel(
        id: 2,
        chatId: 2,
        userId: 202,
        name: 'Bob (No Chat Yet)',
        message: null,
        preview: null,
        lastMessageData: null,
        messageType: 'text',
        time: null,
        timestamp: null,
        unreadCount: 0,
      );

      // 3. Newly created group with 0 messages
      final emptyGroup = PrivateChatModel(
        id: 3,
        chatId: 3,
        groupId: 301,
        groupName: 'Sales Team (New Group)',
        isGroup: true,
        message: null,
        preview: null,
        lastMessageData: null,
        time: null,
        timestamp: null,
        unreadCount: 0,
      );

      c.privateChats.addAll([normalChat, emptyChat, emptyGroup]);

      expect(c.displayedChats, hasLength(3));
      expect(c.displayedChats.any((chat) => chat.userId == 201), isTrue);
      expect(c.displayedChats.any((chat) => chat.userId == 202), isTrue);
      expect(c.displayedChats.any((chat) => chat.groupId == 301), isTrue);
    });

    test(
        'Case B: Refresh retains empty chats and does not drop them from privateChats or displayedChats',
        () {
      // Initial list in memory
      final emptyChat = PrivateChatModel(
        id: 2,
        chatId: 2,
        userId: 202,
        name: 'Bob (No Chat Yet)',
        message: '',
        preview: '',
        time: '',
        timestamp: '',
        unreadCount: 0,
      );
      c.privateChats.add(emptyChat);

      expect(c.displayedChats, hasLength(1));

      // Simulate API response received on refresh where server returns the empty chat
      final serverResponseChats = [
        PrivateChatModel(
          id: 1,
          chatId: 1,
          userId: 201,
          name: 'Alice',
          message: 'Hey there',
          preview: 'Hey there',
          time: '2026-11-23T12:00:00Z',
        ),
        PrivateChatModel(
          id: 2,
          chatId: 2,
          userId: 202,
          name: 'Bob (No Chat Yet)',
          message: null,
          preview: null,
          time: null,
          timestamp: null,
          unreadCount: 0,
        ),
      ];

      // Simulate the merge that happens on refresh in getPrivateChats
      final combined = <PrivateChatModel>[...serverResponseChats];
      for (final existing in c.privateChats) {
        if (!combined.any((item) => item.userId == existing.userId)) {
          combined.add(existing);
        }
      }
      c.privateChats.assignAll(combined);

      // Verify both Alice and Bob exist and Bob did NOT disappear
      expect(c.displayedChats, hasLength(2));
      expect(c.displayedChats.any((chat) => chat.userId == 202), isTrue);
      expect(c.displayedChats.any((chat) => chat.name == 'Bob (No Chat Yet)'),
          isTrue);
    });

    test(
        'Case C: 10 seconds later / after subsequent socket update, empty chat remains stable and identical',
        () {
      // Initial list with an empty chat and an active chat
      final emptyChat = PrivateChatModel(
        id: 2,
        chatId: 2,
        userId: 202,
        name: 'Bob (No Chat Yet)',
        message: null,
        preview: null,
        time: null,
        unreadCount: 0,
      );
      final activeChat = PrivateChatModel(
        id: 1,
        chatId: 1,
        userId: 201,
        name: 'Alice',
        message: 'Message 1',
        preview: 'Message 1',
        time: '2026-11-23T12:00:00Z',
      );
      c.privateChats.addAll([activeChat, emptyChat]);

      expect(c.displayedChats, hasLength(2));

      // Subsequent socket event updates Alice's message
      c.debugHandleChatUpdated({
        'chatId': 1,
        'userId': 201,
        'name': 'Alice',
        'message': 'Message 2 (Updated via Socket)',
        'time': '2026-11-23T12:05:00Z',
      });

      // Verify Alice updated AND Bob is STILL present without disappearing
      expect(c.displayedChats, hasLength(2));
      expect(
          c.displayedChats.firstWhere((ch) => ch.userId == 201).message,
          'Message 2 (Updated via Socket)');
      expect(c.displayedChats.any((ch) => ch.userId == 202), isTrue);
    });
  });
}
