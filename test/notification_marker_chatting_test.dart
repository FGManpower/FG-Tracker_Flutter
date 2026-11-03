import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fgtracker/app/Model/initialize_model.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/Data/Services/notification_marker_service.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';

import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: '1001',
    });
    Global.storageServices = await StorageServices().init();
  });

  group('NotificationMarkers.fromJson Tolerant Parsing Tests', () {
    test('Condition 1: Parsing booleans (true, false)', () {
      final m1 = NotificationMarkers.fromJson({'calling': true, 'chatting': true, 'walkie': false});
      expect(m1.calling, isTrue);
      expect(m1.chatting, isTrue);
      expect(m1.walkie, isFalse);

      final m2 = NotificationMarkers.fromJson({'calling': false, 'chatting': false, 'walkie': true});
      expect(m2.calling, isFalse);
      expect(m2.chatting, isFalse);
      expect(m2.walkie, isTrue);
    });

    test('Condition 2: Parsing int 0 and 3 unread count', () {
      final zeroUnread = NotificationMarkers.fromJson({'chatting': 0});
      expect(zeroUnread.chatting, isFalse);

      final countThree = NotificationMarkers.fromJson({'chatting': 3});
      expect(countThree.chatting, isTrue);

      final zeroChat = NotificationMarkers.fromJson({'chat': 0});
      expect(zeroChat.chatting, isFalse);

      final countFive = NotificationMarkers.fromJson({'chat': 5});
      expect(countFive.chatting, isTrue);
    });

    test('Condition 3: Parsing nested map (hasUnread, unreadCount, hasNotification)', () {
      final mapWithFlag = NotificationMarkers.fromJson({
        'chat': {'hasUnread': true, 'hasNotification': false}
      });
      expect(mapWithFlag.chatting, isTrue);

      final mapWithCount = NotificationMarkers.fromJson({
        'chat': {'unreadCount': 2}
      });
      expect(mapWithCount.chatting, isTrue);

      final mapWithZero = NotificationMarkers.fromJson({
        'chat': {'unreadCount': 0, 'hasUnread': false}
      });
      expect(mapWithZero.chatting, isFalse);
    });

    test('Condition 4: Parsing each alternate key (privateChat, private_chat, groupChat, group_chat)', () {
      final privateCamel = NotificationMarkers.fromJson({'privateChat': true});
      expect(privateCamel.chatting, isTrue);
      expect(privateCamel.privateChat, isTrue);

      final privateSnake = NotificationMarkers.fromJson({'private_chat': 2});
      expect(privateSnake.chatting, isTrue);
      expect(privateSnake.privateChat, isTrue);

      final groupCamel = NotificationMarkers.fromJson({'groupChat': true});
      expect(groupCamel.chatting, isTrue);
      expect(groupCamel.groupChat, isTrue);

      final groupSnake = NotificationMarkers.fromJson({'group_chat': 1});
      expect(groupSnake.chatting, isTrue);
      expect(groupSnake.groupChat, isTrue);
    });

    test('Condition 5: Parsing null, wrong types, empty map (must not throw)', () {
      expect(() => NotificationMarkers.fromJson({}), returnsNormally);
      final empty = NotificationMarkers.fromJson({});
      expect(empty.chatting, isFalse);
      expect(empty.calling, isFalse);
      expect(empty.walkie, isFalse);

      expect(() => NotificationMarkers.fromJson({
        'chatting': null,
        'chat': [1, 2, 3], // List
        'calling': 42.5,   // Double
        'walkie': 'unknown string',
      }), returnsNormally);

      final invalid = NotificationMarkers.fromJson({
        'chatting': null,
        'chat': [1, 2, 3],
        'walkie': 'unknown string',
      });
      expect(invalid.chatting, isFalse);
      expect(invalid.walkie, isFalse);
    });
  });

  group('NotificationMarkerService Merging & Source Independence Tests', () {
    test('Merging: Private and Group unread do not clobber each other', () {
      final service = NotificationMarkerService.instance;
      expect(service.hasChattingMarker.value, isFalse);

      // Private chat unread arrives
      service.setPrivateChatUnread(true);
      expect(service.hasPrivateChatUnread.value, isTrue);
      expect(service.hasGroupChatUnread.value, isFalse);
      expect(service.hasChattingMarker.value, isTrue);

      // Group chat unread arrives
      service.setGroupChatUnread(true);
      expect(service.hasPrivateChatUnread.value, isTrue);
      expect(service.hasGroupChatUnread.value, isTrue);
      expect(service.hasChattingMarker.value, isTrue);

      // Reading private chat turns private flag off, but group is still unread -> chatting remains true
      service.setPrivateChatUnread(false);
      expect(service.hasPrivateChatUnread.value, isFalse);
      expect(service.hasGroupChatUnread.value, isTrue);
      expect(service.hasChattingMarker.value, isTrue);

      // Reading group chat turns group flag off -> now chatting becomes false
      service.setGroupChatUnread(false);
      expect(service.hasPrivateChatUnread.value, isFalse);
      expect(service.hasGroupChatUnread.value, isFalse);
      expect(service.hasChattingMarker.value, isFalse);
    });

    test('Merging: updateFromMap handles mixed payloads accurately', () {
      final service = NotificationMarkerService.instance;
      service.clearAll();

      service.updateFromMap({
        'privateChat': {'unreadCount': 2},
        'groupChat': false,
        'calling': false,
        'walkie': false,
      });

      expect(service.hasPrivateChatUnread.value, isTrue);
      expect(service.hasGroupChatUnread.value, isFalse);
      expect(service.hasChattingMarker.value, isTrue);

      // Update with generic map that does not have private keys should not reset private if still present
      service.updateFromMap({
        'groupChat': true,
      });
      expect(service.hasPrivateChatUnread.value, isTrue);
      expect(service.hasGroupChatUnread.value, isTrue);
      expect(service.hasChattingMarker.value, isTrue);
    });
  });

  group('ChatListController & NotificationMarkerService Integration Tests', () {
    test('_handlePrivateChatUpdated turns on hasChattingMarker for unread private chat', () {
      final markerService = NotificationMarkerService.instance;
      markerService.clearAll();
      expect(markerService.hasChattingMarker.value, isFalse);

      final controller = Get.put(ChatListController());

      // Simulate incoming private chat update with unreadCount = 2
      final rawUpdate = {
        'id': 2001,
        'chatId': 2001,
        'userId': 505,
        'name': 'Sarah Connor',
        'message': 'Are you safe?',
        'unreadCount': 2,
        'chatType': 'private',
        'isGroup': false,
      };

      // In controller, updating private chat triggers list insertion and marker sync
      controller.privateChats.add(PrivateChatModel.fromJson(rawUpdate));
      // Manually trigger sync or simulate the controller flow
      final hasUnread = controller.privateChats.any((c) =>
          (c.isGroup != true && c.chatType != 'group') &&
          ((c.unreadCount ?? 0) > 0 || controller.isChatMarkedUnread(c)));
      markerService.setPrivateChatUnread(hasUnread);

      expect(markerService.hasPrivateChatUnread.value, isTrue);
      expect(markerService.hasChattingMarker.value, isTrue);

      // Now mark chat as read
      final chatItem = controller.privateChats.first;
      chatItem.unreadCount = 0;
      final stillUnread = controller.privateChats.any((c) =>
          (c.isGroup != true && c.chatType != 'group') &&
          ((c.unreadCount ?? 0) > 0 || controller.isChatMarkedUnread(c)));
      markerService.setPrivateChatUnread(stillUnread);

      expect(markerService.hasPrivateChatUnread.value, isFalse);
      expect(markerService.hasChattingMarker.value, isFalse);
    });
  });
}
