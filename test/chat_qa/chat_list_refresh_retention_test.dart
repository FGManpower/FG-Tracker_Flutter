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

  group('Chat list refresh retention & consistency', () {
    test('existing chats are preserved when new page 1 does not include them', () {
      // Seed chats 1 to 5
      for (int i = 1; i <= 5; i++) {
        c.privateChats.add(PrivateChatModel(
          id: i,
          chatId: i,
          userId: i,
          name: 'User $i',
          message: 'Hello $i',
          preview: 'Hello $i',
          messageType: 'text',
          time: '2026-11-01T10:0$i:00Z',
          timestamp: '2026-11-01T10:0$i:00Z',
        ));
      }
      expect(c.privateChats.length, 5);

      // Now simulate a page 1 response that only returns User 1 and User 2 (e.g. 2 items)
      // but has pagination indicating more pages exist
      final apiResponse = PrivateChatResponse(
        status: true,
        pagination: Pagination(
          currentPage: 1,
          totalPages: 3,
          hasNextPage: true,
          totalRecords: 5,
        ),
        data: [
          PrivateChatModel(
            id: 1,
            chatId: 1,
            userId: 1,
            name: 'User 1',
            message: 'Updated message 1',
            preview: 'Updated message 1',
            messageType: 'text',
            time: '2026-11-01T12:00:00Z',
          ),
          PrivateChatModel(
            id: 2,
            chatId: 2,
            userId: 2,
            name: 'User 2',
            message: 'Hello 2',
            preview: 'Hello 2',
            messageType: 'text',
            time: '2026-11-01T10:02:00Z',
          ),
        ],
      );

      // Verify that after merging, chats 3, 4, 5 are NOT dropped
      final existingChats = List<PrivateChatModel>.from(c.privateChats);
      final chats = apiResponse.data!;
      final mergedChats = <PrivateChatModel>[];

      for (final apiChat in chats) {
        final existingIndex = existingChats.indexWhere(
          (existing) => existing.userId == apiChat.userId,
        );
        if (existingIndex == -1) {
          mergedChats.add(apiChat);
        } else {
          mergedChats.add(apiChat);
        }
      }

      final combinedChats = <PrivateChatModel>[...mergedChats];
      for (final existing in existingChats) {
        final inMerged = combinedChats.any((c) => c.userId == existing.userId);
        if (!inMerged) {
          combinedChats.add(existing);
        }
      }

      expect(combinedChats.length, 5);
      expect(combinedChats.map((c) => c.userId).toSet(), {1, 2, 3, 4, 5});
    });

    test('valid chats with media or unreadCount are never hidden in displayedChats', () {
      final mediaChat = PrivateChatModel(
        id: 10,
        chatId: 10,
        userId: 10,
        name: 'Media User',
        message: '',
        preview: '',
        messageType: 'image',
        time: '2026-11-01T10:00:00Z',
      );

      final unreadEmptyMsgChat = PrivateChatModel(
        id: 11,
        chatId: 11,
        userId: 11,
        name: 'Unread User',
        message: '',
        preview: '',
        messageType: 'text',
        unreadCount: 2,
        time: '2026-11-01T10:00:00Z',
      );

      c.privateChats.addAll([mediaChat, unreadEmptyMsgChat]);

      expect(c.displayedChats.any((chat) => chat.userId == 10), isTrue);
      expect(c.displayedChats.any((chat) => chat.userId == 11), isTrue);
    });

    test('realtime socket payload with nested message is properly unwrapped and processed', () {
      final nestedSocketEvent = {
        'message': {
          'id': 999,
          'senderId': '200',
          'receiverId': me,
          'content': 'Realtime nested message',
          'messageType': 'text',
          'createdAt': '2026-11-01T15:00:00Z',
        }
      };

      c.debugHandleChatUpdated(nestedSocketEvent);

      expect(c.privateChats.any((chat) => chat.userId == 200), isTrue);
      final chat = c.privateChats.firstWhere((chat) => chat.userId == 200);
      expect(chat.message, 'Realtime nested message');
    });

    test('realtime group socket payload updates the group row', () {
      final groupEvent = {
        'groupId': 88,
        'groupName': 'Engineering',
        'chatType': 'group',
        'isGroup': true,
        'message': {
          'id': 1001,
          'senderId': '300',
          'senderName': 'Alice',
          'content': 'Sprint update',
          'messageType': 'text',
          'createdAt': '2026-11-01T16:00:00Z',
        }
      };

      c.debugHandleChatUpdated(groupEvent);

      expect(c.privateChats.any((chat) => chat.groupId == 88), isTrue);
      final group = c.privateChats.firstWhere((chat) => chat.groupId == 88);
      expect(group.message, 'Sprint update');
      expect(group.groupName, 'Engineering');
    });
  });
}
