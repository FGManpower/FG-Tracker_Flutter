import 'package:fgtracker/app/Core/util/message_preview_builder.dart';
import 'package:fgtracker/app/Model/GroupChatListModel.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String p({
    String? type,
    String? preview,
    String? content,
    Map<String, dynamic>? data,
    bool deleted = false,
    bool group = false,
    String? senderId,
    String? senderName,
    String me = '7',
  }) =>
      MessagePreviewBuilder.build(
        type: type,
        backendPreview: preview,
        content: content,
        data: data,
        isDeleted: deleted,
        isGroup: group,
        senderId: senderId,
        senderName: senderName,
        currentUserId: me,
      ).display;

  group('existing types are unchanged', () {
    test('text / emoji pass through', () {
      expect(p(type: 'text', preview: 'hello'), 'hello');
      expect(p(type: 'text', preview: '😂🔥'), '😂🔥');
      expect(p(type: null, preview: 'no type'), 'no type');
      // A text that happens to mention a file is NOT turned into a label.
      expect(p(type: 'text', preview: 'see report.pdf'), 'see report.pdf');
    });

    test('image / video / bulk keep the backend preview', () {
      expect(p(type: 'image', preview: '📷 Photo'), '📷 Photo');
      expect(p(type: 'video', preview: '🎥 Video'), '🎥 Video');
      expect(p(type: 'media', preview: '📷 3 Photos'), '📷 3 Photos');
    });

    test('image / bulk rebuilt only when backend sends raw data', () {
      expect(p(type: 'image', preview: 'uploads/chat/a.jpg'), '📷 Photo');
      expect(
        p(type: 'media', preview: '', data: {
          'images': ['a.jpg', 'b.jpg', 'c.jpg'],
        }),
        '📷 3 Photos',
      );
      expect(p(type: 'video', preview: 'https://x/y.mp4'), '🎥 Video');
    });
  });

  group('poll / attendance', () {
    test('title from backend preview gets the poll icon', () {
      expect(p(type: 'attendance', preview: 'hcufbc'), '📊 hcufbc');
    });

    test('title from JSON content, never raw JSON', () {
      expect(
        p(
          type: 'attendance',
          preview: '{"attendancePollId":12,"title":"Team meet"}',
          content: '{"attendancePollId":12,"title":"Team meet"}',
        ),
        '📊 Team meet',
      );
      expect(
        p(type: 'attendance', content: '{"attendancePollId":12}'),
        '📊 Attendance poll',
      );
    });

    test('title from nested poll map', () {
      expect(
        p(type: 'poll', data: {
          'poll': {'question': 'Which day works?'},
        }),
        '📊 Which day works?',
      );
    });
  });

  group('group sender prefix', () {
    test('other sender and me', () {
      expect(
        p(type: 'attendance', preview: 'Q', group: true, senderId: '3', senderName: 'Rahul'),
        'Rahul: 📊 Q',
      );
      expect(
        p(type: 'text', preview: 'hi', group: true, senderId: '7', senderName: 'Me'),
        'You: hi',
      );
    });

    test('no duplicate prefix, no fake prefix', () {
      expect(
        p(type: 'text', preview: 'Rahul: hi', group: true, senderId: '3', senderName: 'Rahul'),
        'Rahul: hi',
      );
      expect(p(type: 'text', preview: 'hi', group: true), 'hi');
      expect(
        p(type: 'text', preview: 'hi', group: false, senderId: '3', senderName: 'Rahul'),
        'hi',
      );
    });
  });

  group('other types and fallbacks', () {
    test('mapped types', () {
      expect(p(type: 'audio', data: {'duration': 72}), '🎤 Voice message (1:12)');
      expect(p(type: 'document', content: 'uploads/docs/Invoice%201.pdf'), '📄 Invoice 1.pdf');
      expect(p(type: 'location', content: '{"latitude":1}'), '📍 Location');
      expect(p(type: 'contact', content: '{"name":"Priya"}'), '👤 Priya');
      expect(p(type: 'system', preview: 'Rahul added Priya', group: true, senderName: 'X'),
          'Rahul added Priya');
    });

    test('deleted', () {
      final r = MessagePreviewBuilder.build(type: 'attendance', isDeleted: true);
      expect(r.isDeleted, isTrue);
      expect(r.rowText, 'This message was deleted');
      expect(r.display, '🚫 This message was deleted');
    });

    test('unknown type never leaks raw payloads', () {
      expect(p(type: 'brand_new_type', preview: '{"id":5}'), 'New message');
      expect(p(type: 'brand_new_type', preview: '12345'), 'New message');
      expect(p(type: 'brand_new_type', preview: 'Readable text'), 'Readable text');
    });
  });

  group('model adapters', () {
    test('API/socket chat-list payload for a group poll', () {
      final chat = PrivateChatModel.fromJson({
        'id': 1,
        'isGroup': true,
        'name': 'Ops',
        'lastMessage': {
          'messageType': 'attendance',
          'content': '{"attendancePollId":4,"title":"Shift check"}',
          'senderId': 3,
          'senderName': 'Rahul',
        },
      });
      expect(
        MessagePreviewBuilder.forChat(chat, currentUserId: '7').display,
        'Rahul: 📊 Shift check',
      );
    });

    test('group card model', () {
      final m = GroupLastMessage.fromJson({
        'messageType': 'image',
        'content': 'uploads/a.jpg',
        'senderId': 7,
        'senderName': 'Me',
      });
      expect(
        MessagePreviewBuilder.forGroupLastMessage(m, currentUserId: '7').display,
        'You: 📷 Photo',
      );
    });
  });

  group('chat list: sender label exactly once', () {
    String row(Map<String, dynamic> json, {String me = '7'}) =>
        MessagePreviewBuilder.forChat(
          PrivateChatModel.fromJson(json),
          currentUserId: me,
        ).display;

    test('group: backend preview already prefixed, raw content used', () {
      expect(
        row({
          'id': 1,
          'isGroup': true,
          'name': 'Ops',
          'lastMessage': {
            'preview': 'Rahul: hi',
            'content': 'hi',
            'messageType': 'text',
            'senderId': 3,
            'senderName': 'Rahul',
          },
        }),
        'Rahul: hi',
      );
    });

    test('group: my own message with my name in the backend preview', () {
      expect(
        row({
          'id': 1,
          'isGroup': true,
          'name': 'Ops',
          'lastMessage': {
            'preview': 'Prashant: hi',
            'content': 'hi',
            'messageType': 'text',
            'senderId': 7,
            'senderName': 'Prashant',
          },
        }),
        'You: hi',
      );
    });

    test('group: short vs full name never doubles', () {
      expect(
        row({
          'id': 1,
          'isGroup': true,
          'name': 'Ops',
          'lastMessage': {
            'preview': 'Rahul: hi',
            'content': 'hi',
            'messageType': 'text',
            'senderId': 3,
            'senderName': 'Rahul Kumar',
          },
        }),
        'Rahul Kumar: hi',
      );
    });

    test('private: "You:" for mine, nothing for theirs', () {
      Map<String, dynamic> p(int sender) => {
            'id': 2,
            'userId': 3,
            'name': 'Rahul',
            'lastMessage': {
              'content': 'hello',
              'messageType': 'text',
              'senderId': sender,
              'senderName': sender == 7 ? 'Prashant' : 'Rahul',
            },
          };
      expect(row(p(7)), 'You: hello');
      expect(row(p(3)), 'hello');
    });

    test('legacy payload without raw content: no double name', () {
      expect(
        row({
          'id': 1,
          'isGroup': true,
          'name': 'Ops',
          'preview': 'Prashant: hi',
          'senderName': 'Prashant',
        }),
        'Prashant: hi',
      );
    });

    test('labels for media / poll / deleted keep a single prefix', () {
      Map<String, dynamic> g(Map<String, dynamic> last) => {
            'id': 1,
            'isGroup': true,
            'name': 'Ops',
            'lastMessage': {'senderId': 3, 'senderName': 'Rahul', ...last},
          };
      expect(
        row(g({'messageType': 'image', 'content': 'uploads/a.jpg'})),
        'Rahul: 📷 Photo',
      );
      expect(
        row(g({
          'messageType': 'attendance',
          'content': '{"attendancePollId":4,"title":"Shift check"}',
        })),
        'Rahul: 📊 Shift check',
      );
      expect(
        row(g({'messageType': 'audio', 'content': 'uploads/v.m4a'})),
        'Rahul: 🎤 Voice message',
      );
      final deleted = MessagePreviewBuilder.forChat(
        PrivateChatModel.fromJson(g({
          'messageType': 'text',
          'content': 'x',
          'isDeletedForEveryone': true,
        })),
        currentUserId: '7',
      );
      expect(deleted.rowText, 'This message was deleted');
    });
  });
}
