// QA: tolerant parsing of chat messages (MessageData.fromJson / GetMessage).
// See docs/01_CHATTING_MODULE_FRONTEND.md §0.3 "Tolerant parsing".
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter_test/flutter_test.dart';

MessageData p(Map<String, dynamic> json) => MessageData.fromJson(json);

void main() {
  group('Parsing - ids and wrappers', () {
    test('id as string, int or messageId alias', () {
      expect(p({'id': '42'}).id, 42);
      expect(p({'id': 42}).id, 42);
      expect(p({'messageId': ' 7 '}).id, 7);
      expect(p({'message_id': 8.0}).id, 8);
      expect(p({'id': 'abc'}).id, isNull);
    });

    test('socket {message:{...}} wrapper gives id, sender, type and text', () {
      final d = p({
        'message': {
          'id': 5,
          'senderId': 3,
          'messageType': 'text',
          'content': 'hi',
          'createdAt': '2026-01-01T00:00:00Z',
        }
      });
      expect(d.id, 5);
      expect(d.senderId, 3);
      expect(d.content, 'hi');
      expect(d.timestamp, '2026-01-01T00:00:00Z');
    });

    test('{data:{...}} wrapper is read like the flat shape', () {
      final d = p({'data': {'id': '6', 'sender_id': 4, 'text': 'yo'}});
      expect(d.id, 6);
      expect(d.senderId, 4);
      expect(d.content, 'yo');
      expect(d.messageType, 'text');
    });

    test('clientMessageId (both spellings) survives for the temp-bubble swap', () {
      expect(p({'clientMessageId': 'c_1'}).clientMessageId, 'c_1');
      expect(p({'client_message_id': 'c_2'}).clientMessageId, 'c_2');
      expect(p({'message': {'clientMessageId': 'c_3'}}).clientMessageId, 'c_3');
    });

    test('GetMessage reads messages/data keys and skips non-map rows', () {
      final g = GetMessage.fromJson({
        'status': '1',
        'messages': [
          {'id': 1, 'content': 'a'},
          'junk',
          42,
          {'id': 2, 'content': 'b'},
        ],
      });
      expect(g.status, isTrue);
      expect(g.messageData!.map((e) => e.id), [1, 2]);
      final g2 = GetMessage.fromJson({'data': [{'id': 3}]});
      expect(g2.messageData!.single.id, 3);
    });

    test('unsupported placeholder keeps id, sender and time', () {
      final u = MessageData.unsupported(
          {'id': '9', 'sender_id': 2, 'created_at': '2026-01-01T00:00:00Z'});
      expect(u.id, 9);
      expect(u.senderId, 2);
      expect(u.timestamp, '2026-01-01T00:00:00Z');
      expect(ChatScreenRules.isUnsupported(u), isTrue);
    });
  });

  group('Parsing - forwarded', () {
    for (final v in [true, 1, '1', 'true', 'TRUE']) {
      test('isForwarded = $v (${v.runtimeType}) shows the Forwarded label', () {
        expect(p({'id': 1, 'isForwarded': v}).isForwarded, isTrue);
      });
    }

    for (final v in [false, 0, '0', 'false', null]) {
      test('isForwarded = $v is not forwarded', () {
        expect(p({'id': 1, 'content': 'x', 'isForwarded': v}).isForwarded,
            isFalse);
      });
    }

    test('type "forwarded" takes the real type from the nested original', () {
      final d = p({
        'id': 10,
        'messageType': 'forwarded',
        'forwardedMessage': {'id': 3, 'messageType': 'image', 'images': ['a.jpg']},
      });
      expect(d.messageType, 'image');
      expect(d.images, ['a.jpg']);
      expect(d.isForwarded, isTrue);
      expect(d.id, 10);
      expect(d.forwardedFromMessageId, 3);
    });

    test('forward without any type: images -> media, videos -> video, file -> document',
        () {
      expect(p({'messageType': 'forward', 'images': ['a.jpg']}).messageType,
          'media');
      expect(
          p({'type': 'forward_message', 'videos': [{'videoUrl': 'v.mp4'}]})
              .messageType,
          'video');
      expect(p({'messageType': 'forwarded', 'content': 'up/a.pdf||a.pdf'})
          .messageType, 'document');
      expect(p({'messageType': 'forwarded', 'content': 'hey'}).messageType,
          'text');
    });

    test('{data:{forwardedMessage:{...}}} shows the Forwarded label', () {
      final d = p({
        'data': {
          'forwardedMessage': {'id': 3, 'messageType': 'text', 'content': 'hi'}
        }
      });
      expect(d.content, 'hi');
      expect(d.isForwarded, isTrue);
    },
        skip: 'BUG-CS-06: GetMessage.dart:816 only checks top-level forward keys; '
            'a forward wrapped as data.forwardedMessage loses the Forwarded label');
  });

  group('Parsing - booleans 0/1/"true"', () {
    for (final v in [true, 1, '1', 'true']) {
      test('isEdited = $v (${v.runtimeType}) shows the Edited label', () {
        // The bubble checks `message.isEdited == true`.
        expect(p({'id': 1, 'isEdited': v}).isEdited == true, isTrue);
      }, skip: v == true
          ? false
          : 'BUG-CS-07: isEdited is stored raw (GetMessage.dart:652); 1/"1"/'
              '"true" from the server never show "Edited" (ChatItem checks == true)');
    }

    test('isDeleted from true, 1 and "1"', () {
      expect(p({'isDeleted': true}).isDeleted, isTrue);
      expect(p({'isDeleted': 1}).isDeleted, isTrue);
      expect(p({'is_deleted': '1'}).isDeleted, isTrue);
      expect(p({'deleted_for_everyone': true}).isDeleted, isTrue);
      expect(p({'isDeleted': 0}).isDeleted, isFalse);
    });

    test('isDeleted from "true" / deletedForEveryone 1', () {
      expect(p({'isDeleted': 'true'}).isDeleted, isTrue);
      expect(p({'deletedForEveryone': 1}).isDeleted, isTrue);
    },
        skip: 'BUG-CS-08: GetMessage.dart:846 accepts only true/"1"; "true" or '
            'deletedForEveryone:1 show the old text instead of "deleted"');

    test('delivered from 1 / "true" / status "delivered" / seenCount > 0', () {
      expect(p({'isDelivered': 1}).isDelivered, isTrue);
      expect(p({'is_delivered': 'TRUE'}).isDelivered, isTrue);
      expect(p({'status': 'Delivered'}).isDelivered, isTrue);
      expect(p({'status': 'seen'}).isDelivered, isTrue);
      expect(p({'seenCount': '2'}).isDelivered, isTrue);
      expect(p({'message': {'delivered': true}}).isDelivered, isTrue);
    });

    test('not delivered: false / 0 / status "sent" / bad seenCount', () {
      expect(p({'isDelivered': false}).isDelivered, isFalse);
      expect(p({'isDelivered': 0}).isDelivered, isFalse);
      expect(p({'status': 'sent'}).isDelivered, isFalse);
      expect(p({'seenCount': 'n/a'}).isDelivered, isFalse);
    });
  });

  group('Parsing - Seen by formats', () {
    test('seen_by list of maps / strings / ints is kept as a list', () {
      final d = p({'senderId': 1, 'seen_by': [{'userId': 2}, '3', 4]});
      expect(ChatScreenRules.seenByOthers(d, currentUserId: '1'), {'2', '3', '4'});
    });

    test('seenBy sent as a JSON string is counted', () {
      final d = p({'senderId': 1, 'seenBy': '["2","3"]'});
      expect(ChatScreenRules.seenByOthers(d, currentUserId: '1'), {'2', '3'});
    },
        skip: 'BUG-CS-09: seenBy is stored raw (GetMessage.dart:650); a JSON-string '
            'list (doc §0.3) gives an empty "Seen by" and no blue tick');
  });

  group('Parsing - reply fields', () {
    test('reply fields in camel and snake case', () {
      final a = p({
        'replyId': 5,
        'replyMessage': 'orig',
        'replyType': 'image',
        'replySender': 'Asha',
      });
      expect([a.replyId, a.replyMessage, a.replyType, a.replySenderName],
          [5, 'orig', 'image', 'Asha']);
      final b = p({
        'reply_id': '6',
        'reply_message': 'o2',
        'reply_type': 'text',
        'reply_sender_name': 'Ravi',
      });
      expect([b.replyId, b.replyMessage, b.replyType, b.replySenderName],
          ['6', 'o2', 'text', 'Ravi']);
    });

    test('reply fields inside a nested message are read too', () {
      final d = p({'message': {'id': 1, 'replyId': 9, 'replyMessage': 'x'}});
      expect(d.replyId, 9);
      expect(d.replyMessage, 'x');
    });
  });

  group('Parsing - media types', () {
    test('images as a JSON string list (socket echo)', () {
      expect(p({'messageType': 'image', 'images': '["a.jpg"," b.jpg "]'}).images,
          ['a.jpg', 'b.jpg']);
    });

    test('a single image path string becomes a one-item list', () {
      expect(p({'messageType': 'image', 'images': 'uploads/a.jpg'}).images,
          ['uploads/a.jpg']);
      expect(p({'messageType': 'image', 'image': 'x.png'}).images, ['x.png']);
    });

    test('bulk media falls back to mediaUrls', () {
      expect(p({'messageType': 'media', 'mediaUrls': ['m1.jpg', 'm2.jpg']}).images,
          ['m1.jpg', 'm2.jpg']);
    });

    test('mediaUrls are NOT treated as images for a text message', () {
      expect(p({'messageType': 'text', 'mediaUrls': ['m1.jpg']}).images, isNull);
    });

    test('videos as JSON string of maps, or as plain url strings', () {
      final a = p({
        'messageType': 'video',
        'videos': '[{"videoUrl":"v.mp4","thumbnail":"t.jpg","duration":"0:12"}]'
      });
      expect(a.videos!.single.videoUrl, 'v.mp4');
      expect(a.videos!.single.duration, '0:12');
      expect(p({'messageType': 'video', 'videos': ['w.mp4']}).videos!.single.videoUrl,
          'w.mp4');
    });

    test('live video with only videoUrl (no content) gets a video entry', () {
      final d = p({'messageType': 'video', 'videoUrl': 'v.mp4', 'thumbnail': 't.jpg'});
      expect(d.videos!.single.videoUrl, 'v.mp4');
      expect(d.videos!.single.thumbnail, 't.jpg');
    });

    test('audio url: audioUrl > audios[0] > mediaUrls[0] (voice only)', () {
      expect(p({'messageType': 'audio', 'audioUrl': 'a.m4a'}).audioUrl, 'a.m4a');
      expect(p({'messageType': 'audio', 'audios': [{'url': 'b.m4a'}]}).audioUrl,
          'b.m4a');
      expect(p({'messageType': 'voice', 'mediaUrls': ['c.m4a']}).audioUrl, 'c.m4a');
      expect(p({'messageType': 'image', 'mediaUrls': ['c.jpg']}).audioUrl, isNull);
    });

    test('document from files[0] becomes "path||name||size"', () {
      final d = p({
        'messageType': 'document',
        'files': [{'url': 'up/r.pdf', 'originalName': 'Report.pdf', 'size': '12KB'}]
      });
      expect(d.content, 'up/r.pdf||Report.pdf||12KB');
    });

    test('document content already sent is never overwritten by files[]', () {
      final d = p({
        'messageType': 'document',
        'content': 'up/a.pdf||A.pdf',
        'files': [{'url': 'up/b.pdf'}]
      });
      expect(d.content, 'up/a.pdf||A.pdf');
    });

    test('location JSON content fills locationMeta', () {
      final d = p({
        'messageType': 'location',
        'content': '{"latitude":20.1,"longitude":85.8,"address":"Cuttack"}'
      });
      expect(d.locationMeta!['address'], 'Cuttack');
    });

    test('contact JSON content fills contactMeta; explicit contactMeta wins', () {
      expect(p({'messageType': 'contact', 'content': '{"name":"Asha","phone":"9"}'})
          .contactMeta!['name'], 'Asha');
      expect(p({
        'messageType': 'contact',
        'content': '{"name":"Old"}',
        'contactMeta': {'name': 'New'}
      }).contactMeta!['name'], 'New');
    });

    test('broken JSON in location content does not throw', () {
      final d = p({'messageType': 'location', 'content': '{latitude:'});
      expect(d.locationMeta, isNull);
    });
  });

  group('Parsing - attendance / poll', () {
    test('attendance summary as map or JSON string', () {
      expect(p({'messageType': 'attendance', 'attendance': {'title': 'Roll'}})
          .attendance!['title'], 'Roll');
      expect(p({'messageType': 'attendance', 'attendance': '{"title":"Roll2"}'})
          .attendance!['title'], 'Roll2');
    });

    test('old attendance rows: poll id read from the JSON content', () {
      final d = p({'messageType': 'attendance', 'content': '{"attendancePollId":77}'});
      expect(d.attendancePollId, 77);
    });

    test('pollId / attendancePollId top-level aliases', () {
      expect(p({'pollId': 5}).attendancePollId, 5);
      expect(p({'attendanceId': '6'}).attendancePollId, '6');
    });
  });

  group('Parsing - attachment merge (duplicate socket events)', () {
    test('second event fills missing images but never replaces text', () {
      final first = MessageData(id: 1, messageType: 'image', content: 'cap');
      final second = MessageData(
          id: 1, messageType: 'image', content: 'other', images: ['a.jpg']);
      expect(first.mergeAttachmentFrom(second), isTrue);
      expect(first.images, ['a.jpg']);
      expect(first.content, 'cap');
    });

    test('server copy replacing a temp bubble wins with overwrite', () {
      final temp = MessageData(messageType: 'audio', content: '/local/a.m4a')
        ..audioUrl = '/local/a.m4a';
      final server = MessageData(id: 3, messageType: 'audio', content: 'up/a.m4a')
        ..audioUrl = 'up/a.m4a';
      expect(temp.mergeAttachmentFrom(server, overwrite: true), isTrue);
      expect(temp.audioUrl, 'up/a.m4a');
      expect(temp.content, 'up/a.m4a');
    });

    test('identical event twice reports no change', () {
      final a = MessageData(id: 1, messageType: 'image', images: ['a.jpg']);
      final b = MessageData(id: 1, messageType: 'image');
      expect(a.mergeAttachmentFrom(b), isFalse);
    });
  });
}
