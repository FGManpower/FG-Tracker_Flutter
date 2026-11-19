import 'package:flutter_test/flutter_test.dart';
import 'package:fgtracker/app/modules/Attendance/models/attendance_poll_model.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';

void main() {
  group('1. Attendance Time & Date Formatting', () {
    test('formatAttendanceTime formats 24h eventTime to 12h AM/PM properly', () {
      expect(formatAttendanceTime('14:30:00'), '02:30 PM');
      expect(formatAttendanceTime('09:05:00'), '09:05 AM');
      expect(formatAttendanceTime('00:00:00'), '12:00 AM');
      expect(formatAttendanceTime('12:00:00'), '12:00 PM');
      expect(formatAttendanceTime(''), isNull);
    });

    test('AttendancePoll parses UTC SQL string and displays correct local time', () {
      final json = {
        'id': 101,
        'title': 'Daily Morning Standup',
        'eventDate': '2026-11-19 09:00:00',
        'eventTime': '09:00:00',
        'status': 'active',
      };
      final poll = AttendancePoll.fromJson(json);
      expect(poll, isNotNull);
      expect(poll!.id, 101);
      expect(poll.title, 'Daily Morning Standup');
      expect(poll.formattedEventTime, '09:00 AM');
      expect(poll.eventDate, isNotNull);
    });

    test('AttendancePoll parses integer epoch ms and seconds', () {
      final jsonMs = {
        'id': 102,
        'eventDate': 1763544000000,
      };
      final pollMs = AttendancePoll.fromJson(jsonMs);
      expect(pollMs, isNotNull);
      expect(pollMs!.eventDate, isNotNull);

      final jsonSec = {
        'id': 103,
        'eventDate': 1763544000,
      };
      final pollSec = AttendancePoll.fromJson(jsonSec);
      expect(pollSec, isNotNull);
      expect(pollSec!.eventDate, isNotNull);
    });
  });

  group('2. Message Edit with Attachments', () {
    test('ChatScreenRules.isEditable allows text and media attachments', () {
      expect(ChatScreenRules.isEditable('text'), isTrue);
      expect(ChatScreenRules.isEditable('text_message'), isTrue);
      expect(ChatScreenRules.isEditable('image'), isTrue);
      expect(ChatScreenRules.isEditable('video'), isTrue);
      expect(ChatScreenRules.isEditable('document'), isTrue);
      expect(ChatScreenRules.isEditable('audio'), isTrue);
      expect(ChatScreenRules.isEditable('attendance'), isFalse);
    });

    test('applyEdit updates caption for attachment without mutating content URL', () {
      final msg = MessageData(
        id: 501,
        messageType: 'document',
        content: 'https://cdn.example.com/reports/financial_q3.pdf',
        caption: 'Old Caption',
      );
      final messages = [msg];

      final success = ChatScreenRules.applyEdit(
        messages,
        {
          'messageId': 501,
          'content': 'Updated Document Caption',
          'isEdited': true,
        },
      );

      expect(success, isTrue);
      expect(msg.content, 'https://cdn.example.com/reports/financial_q3.pdf');
      expect(msg.caption, 'Updated Document Caption');
      expect(msg.isEdited, isTrue);
    });

    test('applyEdit updates content for pure text message', () {
      final msg = MessageData(
        id: 502,
        messageType: 'text',
        content: 'Original message',
      );
      final messages = [msg];

      final success = ChatScreenRules.applyEdit(
        messages,
        {
          'messageId': 502,
          'content': 'Corrected message text',
          'isEdited': true,
        },
      );

      expect(success, isTrue);
      expect(msg.content, 'Corrected message text');
      expect(msg.isEdited, isTrue);
    });
  });

  group('3. Delete for Everyone (WhatsApp Parity: Preserves Position, No Ticks, Shows Deleted Text)', () {
    test('applyDelete marks message as deleted in place preserving message list position', () {
      final msg1 = MessageData(id: 601, content: 'Keep this');
      final msg2 = MessageData(id: 602, content: 'Delete this everyone');
      final msg3 = MessageData(id: 603, content: 'Keep this too');
      final messages = [msg1, msg2, msg3];

      final deleted = ChatScreenRules.applyDelete(
        messages,
        {
          'messageId': 602,
          'deleteType': 'for_everyone',
        },
        'user_1',
      );

      expect(deleted, isTrue);
      expect(messages.length, 3);
      expect(messages[1].id, 602);
      expect(messages[1].isDeleted, isTrue);
      expect(messages[1].content, 'This message was deleted');
    });

    test('merge retains deleted messages in place with isDeleted marked true', () {
      final existing = [MessageData(id: 701, content: 'Active 1')];
      final incoming = [
        MessageData(id: 702, content: 'Active 2'),
        MessageData(id: 703, content: 'This message was deleted', isDeleted: true),
      ];

      final result = ChatScreenRules.merge(
        existing,
        incoming,
      );

      expect(result.added, 2);
      expect(result.messages.length, 3);
      expect(result.messages.map((m) => m.id).toList(), [701, 702, 703]);
      expect(result.messages[2].isDeleted, isTrue);
    });
  });

  group('4. Message Sorting & Chronological Order', () {
    test('sortOldestFirst maintains ascending chronological order with various formats', () {
      final msg1 = MessageData(id: 1, timestamp: '2026-11-19 10:00:00');
      final msg2 = MessageData(id: 2, timestamp: '2026-11-19 10:15:00');
      final msg3 = MessageData(id: 3, timestamp: '2026-11-19 10:30:00');

      final sorted = ChatScreenRules.sortOldestFirst([msg3, msg1, msg2]);
      expect(sorted.map((m) => m.id).toList(), [1, 2, 3]);
    });

    test('sortOldestFirst handles epoch timestamps accurately', () {
      final msg1 = MessageData(id: 1, timestamp: 1763540000000);
      final msg2 = MessageData(id: 2, timestamp: 1763540010000);
      final msg3 = MessageData(id: 3, timestamp: 1763540020000);

      final sorted = ChatScreenRules.sortOldestFirst([msg2, msg3, msg1]);
      expect(sorted.map((m) => m.id).toList(), [1, 2, 3]);
    });
  });

  group('5. Document MIME Mapping', () {
    test('MessageRepo maps document extensions to correct IANA content types', () {
      expect(MessageRepo.getDocumentMediaType('pdf').toString(), 'application/pdf');
      expect(MessageRepo.getDocumentMediaType('doc').toString(), 'application/msword');
      expect(
        MessageRepo.getDocumentMediaType('docx').toString(),
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
      expect(MessageRepo.getDocumentMediaType('xls').toString(), 'application/vnd.ms-excel');
      expect(
        MessageRepo.getDocumentMediaType('xlsx').toString(),
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      expect(MessageRepo.getDocumentMediaType('txt').toString(), 'text/plain');
    });
  });
}
