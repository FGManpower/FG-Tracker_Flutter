import 'package:flutter_test/flutter_test.dart';
import 'package:fgtracker/app/Model/ForwardMessageModel.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/ForwardMessageController.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WhatsApp Forward Mechanics & Controller Suite', () {
    late ForwardMessageController controller;

    setUp(() {
      Get.reset();
      controller = ForwardMessageController();
      controller.message = MessageData(id: 999, content: "Test Forward Content");
      controller.sourceType = "private";
    });

    test('Selection toggle and count mechanics work correctly', () {
      final dest1 = ForwardDestination(
        type: 'private',
        userId: 101,
        name: 'Alice Johnson',
        mobileNo: '+1234567890',
      );
      final dest2 = ForwardDestination(
        type: 'group',
        groupId: 202,
        name: 'Development Team',
      );

      expect(controller.hasSelection, isFalse);
      expect(controller.selectedCount, 0);

      controller.toggleDestination(dest1);
      expect(controller.hasSelection, isTrue);
      expect(controller.selectedCount, 1);
      expect(controller.isSelected(dest1), isTrue);
      expect(controller.isSelected(dest2), isFalse);

      controller.toggleDestination(dest2);
      expect(controller.selectedCount, 2);
      expect(controller.isSelected(dest2), isTrue);

      // Deselect dest1
      controller.toggleDestination(dest1);
      expect(controller.selectedCount, 1);
      expect(controller.isSelected(dest1), isFalse);
      expect(controller.isSelected(dest2), isTrue);
    });

    test('Search filtering matches display name and phone number case-insensitively', () {
      final dest1 = ForwardDestination(
        type: 'private',
        userId: 1,
        name: 'Rahul Sharma',
        mobileNo: '9876543210',
      );
      final dest2 = ForwardDestination(
        type: 'private',
        userId: 2,
        name: 'Priya Patel',
        mobileNo: '9123456789',
      );
      final group1 = ForwardDestination(
        type: 'group',
        groupId: 10,
        name: 'Family Group',
      );

      controller.destinations.assignAll([dest1, dest2, group1]);
      controller.myContacts.assignAll([dest1, dest2]);
      controller.allGroups.assignAll([group1]);

      // Search by name
      controller.search('rahul');
      expect(controller.filteredDestinations.length, 1);
      expect(controller.filteredDestinations.first.displayName, 'Rahul Sharma');

      // Search by partial phone number
      controller.search('9123');
      expect(controller.filteredDestinations.length, 1);
      expect(controller.filteredDestinations.first.displayName, 'Priya Patel');

      // Search by group name
      controller.search('family');
      expect(controller.filteredDestinations.length, 1);
      expect(controller.filteredDestinations.first.displayName, 'Family Group');

      // Clear search
      controller.clearSearch();
      expect(controller.filteredDestinations.length, 3);
    });

    test('Target generation maps correctly for private and group targets', () {
      final destPrivate = ForwardDestination(
        type: 'private',
        userId: 55,
        name: 'Bob',
      );
      final destGroup = ForwardDestination(
        type: 'group',
        groupId: 77,
        name: 'Marketing',
      );

      controller.toggleDestination(destPrivate);
      controller.toggleDestination(destGroup);

      final targets = controller.selectedDestinations.map(
        (dest) => ForwardTarget(
          type: dest.isGroup ? 'group' : 'private',
          userId: dest.isGroup ? null : dest.targetId,
          groupId: dest.isGroup ? dest.targetId : null,
        ),
      ).toList();

      expect(targets.length, 2);
      expect(targets[0].type, 'private');
      expect(targets[0].userId, 55);
      expect(targets[0].groupId, isNull);

      expect(targets[1].type, 'group');
      expect(targets[1].groupId, 77);
      expect(targets[1].userId, isNull);
    });

    test('Forwarded message parsing handles flat and nested message/content payloads', () {
      // Case 1: Backend sends 'message' instead of 'content'
      final raw1 = {
        'id': 101,
        'senderId': 5,
        'receiverId': 9,
        'message': 'Important forwarded update',
        'isForwarded': true,
        'messageType': 'text',
      };
      final msg1 = MessageData.fromJson(raw1);
      expect(msg1.content, 'Important forwarded update');
      expect(msg1.isForwarded, isTrue);

      // Case 2: Backend sends nested originalMessage/forwardedMessage
      final raw2 = {
        'id': 102,
        'is_forwarded': 'true',
        'forwardedMessage': {
          'id': 88,
          'content': 'Nested original forwarded text',
          'messageType': 'text',
        },
      };
      final msg2 = MessageData.fromJson(raw2);
      expect(msg2.content, 'Nested original forwarded text');
      expect(msg2.isForwarded, isTrue);
      expect(msg2.forwardedFromMessageId, 88);

      // Case 3: Forwarded media message
      final raw3 = {
        'id': 103,
        'isForwarded': 1,
        'forwarded_from_message_id': 99,
        'messageType': 'forward',
        'images': ['https://example.com/photo.jpg'],
        'caption': 'Check this forwarded photo',
      };
      final msg3 = MessageData.fromJson(raw3);
      expect(msg3.isForwarded, isTrue);
      expect(msg3.images?.length, 1);
      expect(msg3.messageType, 'media');
      expect(msg3.caption, 'Check this forwarded photo');

      // Case 4: Backend emits snake_case 'forwarded_message' and flat 'forwarded_content'
      final raw4 = {
        'id': 104,
        'sender_id': 12,
        'receiver_id': 34,
        'forwarded_message': {
          'id': 77,
          'content': 'Real-time snake_case content',
          'message_type': 'text',
        },
      };
      final msg4 = MessageData.fromJson(raw4);
      expect(msg4.content, 'Real-time snake_case content');
      expect(msg4.isForwarded, isTrue);
      expect(msg4.forwardedFromMessageId, 77);

      // Case 5: Real-time minimal socket payload with original message in memory
      final localCache = [
        MessageData(id: 60, content: "Original message text in chat", messageType: "text"),
      ];
      final minimalSocketPayload = {
        'id': 200,
        'senderId': 5,
        'receiverId': 9,
        'isForwarded': true,
        'forwardedFromMessageId': 60,
      };
      final incoming = MessageData.fromJson(minimalSocketPayload);
      expect(incoming.content, isNull);
      expect(incoming.isForwarded, isTrue);

      // Simulate real-time resolution from local memory
      final cached = localCache.firstWhereOrNull((m) => m.id == incoming.forwardedFromMessageId);
      expect(cached, isNotNull);
      incoming.content = cached!.content;
      incoming.messageType = cached.messageType;

      expect(incoming.content, "Original message text in chat");
      expect(incoming.isForwarded, isTrue);
    });
  });
}
