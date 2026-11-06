import 'package:fgtracker/app/Core/util/message_preview_builder.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter_test/flutter_test.dart';

MessageData reply({
  dynamic replyType,
  dynamic replyMessage,
  dynamic replySenderName,
}) =>
    MessageData(
      id: 2,
      replyId: 1,
      replyType: replyType,
      replyMessage: replyMessage,
      replySenderName: replySenderName,
    );

String quoted(MessageData r, {MessageData? original}) =>
    MessagePreviewBuilder.forQuotedReply(r, original: original).display;

void main() {
  group('quoted reply is never empty', () {
    test('bulk media with empty content', () {
      expect(quoted(reply(replyType: 'media', replyMessage: '')), '📷 Photo');
    });

    test('contact JSON is not shown raw', () {
      final r = reply(
        replyType: 'contact',
        replyMessage: '{"name":"Ravi","phone":"999"}',
      );
      expect(quoted(r), '👤 Ravi');
    });

    test('poll / attendance / sticker get a label', () {
      expect(quoted(reply(replyType: 'poll')), '📊 Poll');
      expect(quoted(reply(replyType: 'attendance')), '📊 Attendance poll');
      expect(quoted(reply(replyType: 'sticker')), 'Sticker');
    });

    test('document shows its file name', () {
      final r = reply(
        replyType: 'document',
        replyMessage: 'uploads/abc.pdf||Invoice.pdf||1.2 MB',
      );
      expect(quoted(r), '📄 Invoice.pdf');
    });

    test('missing type with a media path is inferred', () {
      expect(quoted(reply(replyMessage: 'uploads/x/photo.jpg')), '📷 Photo');
      expect(quoted(reply(replyMessage: 'uploads/song.mp3')), '🎵 Audio');
    });

    test('nothing at all falls back to "Message"', () {
      expect(quoted(reply()), MessagePreviewBuilder.replyFallbackText);
      expect(quoted(reply(replyType: 'something_new')),
          MessagePreviewBuilder.replyFallbackText);
    });

    test('plain text and links are kept', () {
      expect(quoted(reply(replyType: 'text', replyMessage: 'Hello')), 'Hello');
      expect(
        quoted(reply(replyType: 'text', replyMessage: 'https://example.com')),
        'https://example.com',
      );
    });

    test('loaded original message wins over stale reply fields', () {
      final original = MessageData(
        id: 1,
        messageType: 'media',
        images: ['a.jpg', 'b.jpg', 'c.jpg'],
      );
      expect(quoted(reply(replyType: 'media'), original: original),
          '📷 3 Photos');
    });
  });

  group('reply sender label', () {
    test('"You" for my own original message', () {
      final original = MessageData(id: 1, senderId: 7, senderName: 'Me');
      expect(
        MessagePreviewBuilder.replySenderLabel(
          reply(replySenderName: 'Me'),
          original: original,
          currentUserId: '7',
        ),
        'You',
      );
    });

    test('falls back to the original sender name', () {
      final original = MessageData(id: 1, senderId: 9, senderName: 'Asha');
      expect(
        MessagePreviewBuilder.replySenderLabel(
          reply(),
          original: original,
          currentUserId: '7',
        ),
        'Asha',
      );
    });
  });
}
