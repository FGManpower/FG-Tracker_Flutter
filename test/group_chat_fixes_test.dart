import 'package:fgtracker/app/Core/util/message_preview_builder.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('real-time media payloads (issue: media shows as missing)', () {
    test('images sent as a JSON string are parsed', () {
      final m = MessageData.fromJson({
        'id': 1,
        'messageType': 'media',
        'images': '["uploads/a.jpg","uploads/b.jpg"]',
      });
      expect(m.images, ['uploads/a.jpg', 'uploads/b.jpg']);
    });

    test('a single image path string is parsed', () {
      final m = MessageData.fromJson(
          {'id': 2, 'messageType': 'image', 'images': 'uploads/a.jpg'});
      expect(m.images, ['uploads/a.jpg']);
    });

    test('videos as a JSON string, and plain URL items, are parsed', () {
      final m = MessageData.fromJson({
        'id': 3,
        'messageType': 'media',
        'videos': '[{"videoUrl":"v.mp4","thumbnail":"t.jpg"},"w.mp4"]',
      });
      expect(m.videos!.map((v) => v.videoUrl), ['v.mp4', 'w.mp4']);
      expect(m.videos!.first.thumbnail, 't.jpg');
    });

    test('a real list still works and empty strings stay null', () {
      expect(MessageData.fromJson({'images': ['x.jpg']}).images, ['x.jpg']);
      expect(MessageData.fromJson({'images': ''}).images, isNull);
    });
  });

  group('pinned attendance banner (issue: shows code)', () {
    test('attendance preview is the poll title, never the JSON', () {
      final m = MessageData(
        id: 9,
        messageType: 'attendance',
        content: '{"attendancePollId":12}',
      )..attendance = {'id': 12, 'title': 'Morning shift'};
      final text = MessagePreviewBuilder.forMessage(m).display;
      expect(text, '📊 Morning shift');
      expect(text.contains('{'), isFalse);
    });

    test('attendance without a title still reads as a poll', () {
      final m = MessageData(
          id: 9, messageType: 'attendance', content: '{"attendancePollId":12}');
      expect(MessagePreviewBuilder.forMessage(m).display, '📊 Attendance poll');
    });
  });

  group('chat list unread after reading (issue: badge comes back)', () {
    PrivateChatModel row(int? unread) => PrivateChatModel(id: 1, unreadCount: unread);

    test('stale server count after a local read is ignored', () {
      final n = ChatListRules.resolveUnread(
        current: row(0),
        updated: row(3),
        newMessage: false,
        isViewing: false,
        myUserId: '42',
        readLocally: true,
      );
      expect(n, 0);
    });

    test('a genuinely new message still counts', () {
      final n = ChatListRules.resolveUnread(
        current: row(0),
        updated: row(1),
        newMessage: true,
        isViewing: false,
        myUserId: '42',
        readLocally: true,
      );
      expect(n, 1);
    });
  });
}
