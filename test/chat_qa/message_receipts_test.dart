// Unit tests for group read / delivered receipts (MessageReceipts): id
// normalisation, forward-only status, group aggregation used by both the
// bubble tick and Message Info, and payload parsing / dedupe keys.
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/message_receipts.dart';
import 'package:flutter_test/flutter_test.dart';

MessageData _msg({
  int id = 1,
  String sender = '1',
  List<dynamic>? readBy,
  List<dynamic>? deliveredTo,
  dynamic seenBy,
  bool isDelivered = false,
}) {
  final m = MessageData.fromJson({
    'id': id,
    'senderId': sender,
    'content': 'hi',
    'messageType': 'text',
    'isDelivered': isDelivered,
  });
  m.readBy = readBy;
  m.deliveredTo = deliveredTo;
  m.seenBy = seenBy;
  return m;
}

void main() {
  group('normalizeReceiptId', () {
    test('int, String, maps and populated objects become the same string', () {
      expect(normalizeReceiptId(7), '7');
      expect(normalizeReceiptId(' 7 '), '7');
      expect(normalizeReceiptId({'userId': 7}), '7');
      expect(normalizeReceiptId({'user_id': '7'}), '7');
      expect(normalizeReceiptId({'_id': 7}), '7');
      expect(normalizeReceiptId({'id': 7}), '7');
      expect(normalizeReceiptId({'user': {'id': 7}}), '7');
    });

    test('empty and "null" are null', () {
      expect(normalizeReceiptId(null), isNull);
      expect(normalizeReceiptId(''), isNull);
      expect(normalizeReceiptId('null'), isNull);
      expect(normalizeReceiptId({'name': 'x'}), isNull);
    });
  });

  group('forward-only status', () {
    test('read adds the reader once and also counts as delivered', () {
      final m = _msg();
      expect(MessageReceipts.applyRead(m, '2', at: 'T1'), isTrue);
      expect(MessageReceipts.applyRead(m, '2', at: 'T2'), isFalse);
      expect(MessageReceipts.readMap(m), {'2': 'T1'});
      expect(MessageReceipts.deliveredMap(m), {'2': 'T1'});
    });

    test('a late delivered never changes read', () {
      final m = _msg();
      MessageReceipts.applyRead(m, '2', at: 'T1');
      expect(MessageReceipts.applyDelivered(m, '2', at: 'T9'), isFalse);
      expect(MessageReceipts.readMap(m)['2'], 'T1');
      expect(MessageReceipts.deliveredMap(m)['2'], 'T1');
    });

    test('delivered then read moves forward', () {
      final m = _msg();
      MessageReceipts.applyDelivered(m, '3', at: 'D');
      MessageReceipts.applyRead(m, '3', at: 'R');
      expect(MessageReceipts.readMap(m), {'3': 'R'});
      expect(MessageReceipts.deliveredMap(m), {'3': 'D'});
    });

    test('the sender is never a reader of their own message', () {
      final m = _msg(sender: '1');
      expect(MessageReceipts.applyRead(m, '1'), isFalse);
      expect(MessageReceipts.applyDelivered(m, 1), isFalse);
      expect(MessageReceipts.readMap(m), isEmpty);
    });

    test('ids in readBy as maps / ints / strings all match', () {
      final m = _msg(readBy: [
        {'userId': 2, 'readAt': 'T'},
        3,
        '4',
      ]);
      MessageReceipts.applyRead(m, '2');
      MessageReceipts.applyRead(m, 3);
      MessageReceipts.applyRead(m, {'userId': '4'});
      // No duplicate readers whatever the id shape.
      expect(MessageReceipts.readMap(m).keys.toSet(), {'2', '3', '4'});
      expect(m.readBy, hasLength(3));
      expect(MessageReceipts.readMap(m)['2'], 'T');
    });

    test('older seenBy id list still counts as read', () {
      final m = _msg(seenBy: [2, {'userId': '3'}]);
      expect(MessageReceipts.readMap(m).keys.toSet(), {'2', '3'});
    });
  });

  group('group aggregation (bubble + Message Info)', () {
    final members = [1, 2, 3, 4]; // 1 = sender (me)

    test('sender excluded; remaining / delivered / read split', () {
      final m = _msg(
        readBy: [{'userId': 2, 'readAt': 'R2'}],
        deliveredTo: [{'userId': 3, 'deliveredAt': 'D3'}],
      );
      final s = MessageReceipts.summarize(m, memberIds: members);
      expect(s.recipients, ['2', '3', '4']);
      expect(s.read, {'2': 'R2'});
      expect(s.delivered, {'3': 'D3'});
      expect(s.remaining, ['4']);
      expect(s.allRead, isFalse);
      expect(s.allDelivered, isFalse);
    });

    test('a reader is not also listed under delivered', () {
      final m = _msg(
        readBy: [{'userId': 2}],
        deliveredTo: [{'userId': 2}, {'userId': 3}],
      );
      final s = MessageReceipts.summarize(m, memberIds: members);
      expect(s.delivered.keys, ['3']);
    });

    test('late joiners without a receipt are not recipients', () {
      final m = _msg(readBy: [{'userId': 2}, {'userId': 3}]);
      final s = MessageReceipts.summarize(m,
          memberIds: members, joinedAfter: {'4'});
      expect(s.recipients, ['2', '3']);
      expect(s.allRead, isTrue);
    });

    test('a member who left keeps their read but is not a recipient', () {
      final m = _msg(readBy: [{'userId': 9, 'readAt': 'R'}]);
      final s = MessageReceipts.summarize(m, memberIds: members);
      expect(s.read.containsKey('9'), isTrue);
      expect(s.recipients.contains('9'), isFalse);
    });

    test('tick: read by all = blue, delivered to all = grey ✓✓, else ✓', () {
      final all = _msg(readBy: [{'userId': 2}, {'userId': 3}, {'userId': 4}]);
      expect(MessageReceipts.groupTick(all, memberIds: members), GroupTick.read);

      final delivered = _msg(
        readBy: [{'userId': 2}],
        deliveredTo: [{'userId': 3}, {'userId': 4}],
      );
      expect(MessageReceipts.groupTick(delivered, memberIds: members),
          GroupTick.delivered);

      final partial = _msg(deliveredTo: [{'userId': 3}]);
      expect(MessageReceipts.groupTick(partial, memberIds: members),
          GroupTick.sent);
    });

    test('tick falls back to the server-saved flag until per-member lists '
        'exist', () {
      final legacy = _msg(isDelivered: true);
      expect(MessageReceipts.groupTick(legacy, memberIds: members),
          GroupTick.delivered);
      expect(MessageReceipts.groupTick(_msg(), memberIds: members),
          GroupTick.sent);
    });
  });

  group('ReceiptUpdate.parse', () {
    test('contract payload', () {
      final u = ReceiptUpdate.parse({
        'groupId': 7,
        'userId': 2,
        'messageIds': [10, '11'],
        'readAt': '2026-11-17T10:00:00Z',
      }, isRead: true)!;
      expect(u.groupId, '7');
      expect(u.userId, '2');
      expect(u.messageIds, {'10', '11'});
      expect(u.at, '2026-11-17T10:00:00Z');
    });

    test('legacy payload: seenBy as reader id, single messageId', () {
      final u = ReceiptUpdate.parse(
          {'group_id': 7, 'seenBy': 2, 'messageId': 10},
          isRead: true)!;
      expect(u.userId, '2');
      expect(u.messageIds, {'10'});
    });

    test('same update -> same dedupe key, regardless of id order', () {
      final a = ReceiptUpdate.parse(
          {'groupId': 7, 'userId': 2, 'messageIds': [1, 2]}, isRead: true)!;
      final b = ReceiptUpdate.parse(
          {'groupId': '7', 'userId': '2', 'messageIds': ['2', '1']},
          isRead: true)!;
      expect(a.key, b.key);
      final d = ReceiptUpdate.parse(
          {'groupId': 7, 'userId': 2, 'messageIds': [1, 2]}, isRead: false)!;
      expect(d.key, isNot(a.key));
    });

    test('non-map payload is ignored', () {
      expect(ReceiptUpdate.parse('x', isRead: true), isNull);
    });
  });

  test('idsFromOthers skips my messages and unsent ones', () {
    final mine = _msg(id: 1, sender: '1');
    final other = _msg(id: 2, sender: '2');
    final unsent = MessageData.fromJson({'senderId': '2', 'content': 'x'});
    expect(
        MessageReceipts.idsFromOthers([mine, other, unsent], myUserId: '1'),
        ['2']);
  });
}
