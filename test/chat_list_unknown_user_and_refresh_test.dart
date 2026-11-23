import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/modules/Messages/widgets/chat_list_row_widgets.dart';

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

  group('Unknown User & Phone Fallback Tests', () {
    test('1. Model parses phone and uses it as fallback name when name is missing', () {
      final jsonWithPhone = {
        'id': 101,
        'chatId': 101,
        'userId': 501,
        'name': null,
        'phone': '+919876543210',
        'message': 'Hello',
      };

      final model = PrivateChatModel.fromJson(jsonWithPhone);
      expect(model.phone, '+919876543210');
      expect(model.name, '+919876543210');
    });

    test('2. Model replaces "Unknown User" with phone number when phone is present', () {
      final jsonUnknownWithPhone = {
        'id': 102,
        'chatId': 102,
        'userId': 502,
        'name': 'Unknown User',
        'phoneNumber': '+918888888888',
        'message': 'Hey',
      };

      final model = PrivateChatModel.fromJson(jsonUnknownWithPhone);
      expect(model.phone, '+918888888888');
      expect(model.name, '+918888888888');
    });

    test('3. chatListDisplayName returns phone when name is null or Unknown User', () {
      expect(chatListDisplayName(null, phone: '+919999999999'), '+919999999999');
      expect(chatListDisplayName('Unknown User', phone: '+919999999999'), '+919999999999');
      expect(chatListDisplayName('John Doe', phone: '+919999999999'), 'John Doe');
    });

    test('4. Orphan dummy row (no name, no phone, no message) is suppressed from displayedChats', () {
      final orphanDummyRow = PrivateChatModel(
        id: 999,
        chatId: 999,
        userId: 999,
        name: 'Unknown User',
        phone: null,
        message: null,
        preview: null,
      );

      final realUserWith0Messages = PrivateChatModel(
        id: 888,
        chatId: 888,
        userId: 888,
        name: 'Rohan (Contact)',
        phone: '+919123456789',
        message: null,
        preview: null,
      );

      final realUserWithPhoneOnly = PrivateChatModel(
        id: 777,
        chatId: 777,
        userId: 777,
        name: '+919876500000',
        phone: '+919876500000',
        message: null,
        preview: null,
      );

      final activeChat = PrivateChatModel(
        id: 666,
        chatId: 666,
        userId: 666,
        name: 'Pooja',
        message: 'Active conversation',
        preview: 'Active conversation',
      );

      c.privateChats.addAll([
        orphanDummyRow,
        realUserWith0Messages,
        realUserWithPhoneOnly,
        activeChat,
      ]);

      final displayed = c.displayedChats;

      // Orphan dummy row must be filtered out
      expect(displayed.any((chat) => chat.id == 999), isFalse);

      // Real users (0-messages with name or phone, and active chat) must be preserved
      expect(displayed.any((chat) => chat.id == 888), isTrue);
      expect(displayed.any((chat) => chat.id == 777), isTrue);
      expect(displayed.any((chat) => chat.id == 666), isTrue);
      expect(displayed.length, 3);
    });
  });

  group('Chat List Refresh Retention & Merge Pipeline Tests', () {
    test('5. Refresh retains 0-message chat in memory when server returns only active chats', () {
      // In-memory chat before refresh: a 0-message chat
      final emptyChat = PrivateChatModel(
        id: 50,
        chatId: 50,
        userId: 150,
        name: 'New Contact (0 msgs)',
        phone: '+919000000050',
        message: null,
        preview: null,
      );
      c.privateChats.add(emptyChat);

      expect(c.displayedChats, hasLength(1));

      // Simulate server returning only other active conversations
      final serverChats = [
        PrivateChatModel(
          id: 51,
          chatId: 51,
          userId: 151,
          name: 'Server Chat 1',
          message: 'Hello server',
          preview: 'Hello server',
        ),
      ];

      // Execute merge logic as done in getPrivateChats
      final combined = <PrivateChatModel>[...serverChats];
      for (final existing in c.privateChats) {
        if (!combined.any((item) => item.userId == existing.userId)) {
          combined.add(existing);
        }
      }
      c.privateChats.assignAll(combined);

      // 0-message chat must still be present and displayed!
      expect(c.displayedChats, hasLength(2));
      expect(c.displayedChats.any((ch) => ch.id == 50), isTrue);
      expect(c.displayedChats.any((ch) => ch.id == 51), isTrue);
    });

    test('6. Socket full chat list update retains 0-message chat and suppresses orphan dummy rows', () {
      final valid0MsgChat = PrivateChatModel(
        id: 60,
        chatId: 60,
        userId: 160,
        name: 'Amit',
        phone: '+919000000060',
        message: null,
      );
      c.privateChats.add(valid0MsgChat);

      // Socket sends a payload containing an active chat and an orphan Unknown User chat
      c.debugHandleFullChatList({
        'status': true,
        'data': [
          {
            'id': 61,
            'chatId': 61,
            'userId': 161,
            'name': 'Priya',
            'message': 'Socket text',
            'preview': 'Socket text',
          },
          {
            'id': 9999,
            'chatId': 9999,
            'userId': 9999,
            'name': 'Unknown User',
            'message': null,
            'preview': null,
          }
        ]
      });

      // displayedChats should contain Amit (0 msg preserved) and Priya (active), NOT 9999
      expect(c.displayedChats.any((ch) => ch.id == 60), isTrue);
      expect(c.displayedChats.any((ch) => ch.id == 61), isTrue);
      expect(c.displayedChats.any((ch) => ch.id == 9999), isFalse);
    });
  });
}
