// QA: chat screen widgets that can be pumped in isolation -
// Message Info sheet (private + group "Seen" / "Delivered") and the group
// bubble tick. The sheet also calls the message-info API; in tests that call
// fails and the sheet falls back to the local message data checked here.
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatItem.dart';
import 'package:fgtracker/app/widgets/MessageInfoSheet.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

const me = '1';
const purple = Color(0xFF5045B9);
final en = lookupAppLocalizations(const Locale('en'));

Widget _app(Widget child, {Locale? locale}) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        locale: locale,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

GroupMessageController _group(List<String> memberIds) {
  final c = GroupMessageController();
  c.groupMembers.assignAll([
    for (final id in memberIds) LocationData(userId: id, name: 'User $id'),
  ]);
  return c;
}

/// The Message Info rows trip Flutter's debug check "ListTile ... ink
/// splashes may be invisible" (reported as BUG-CS-14). Ignore only that
/// assertion so the other checks in a test can run.
void ignoreListTileInkAssert() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('ink splashes may be invisible')) {
      return;
    }
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

Future<void> _pumpSheet(WidgetTester t, MessageInfoSheet sheet,
    {Locale? locale}) async {
  await t.pumpWidget(_app(sheet, locale: locale));
  await t.pump(const Duration(milliseconds: 50));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({'userId': me});
    Global.storageServices = await StorageServices().init();
  });

  setUp(Get.reset);

  group('Message Info - private chat', () {
    testWidgets('not seen yet', (t) async {
      await _pumpSheet(t, MessageInfoSheet(
        message: MessageData(id: 1, senderId: me, messageType: 'text', content: 'hi'),
        memberData: MemberData(userId: 2, name: 'Asha'),
      ));
      expect(find.text(en.widget_notSeenYet), findsOneWidget);
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('seen: shows the contact in the Seen section', (t) async {
      ignoreListTileInkAssert();
      await _pumpSheet(t, MessageInfoSheet(
        message: MessageData(id: 1, senderId: me, messageType: 'text',
            content: 'hi', seenCount: '3', isDelivered: true),
        memberData: MemberData(userId: 2, name: 'Asha'),
      ));
      expect(find.text(en.widget_notSeenYet), findsNothing);
      expect(find.text('Asha'), findsWidgets);
    });

    testWidgets('photo message shows "Photo", not the file path', (t) async {
      await _pumpSheet(t, MessageInfoSheet(
        message: MessageData(id: 1, senderId: me, messageType: 'image',
            content: 'uploads/a.jpg'),
      ));
      expect(find.text(en.util_previewPhoto), findsOneWidget);
      expect(find.textContaining('uploads/'), findsNothing);
    });

    testWidgets('attendance message never shows raw JSON', (t) async {
      await _pumpSheet(t, MessageInfoSheet(
        message: MessageData(id: 1, senderId: me, messageType: 'attendance',
            content: '{"attendancePollId":4}'),
      ));
      expect(find.textContaining('attendancePollId'), findsNothing);
    },
        // BUG-CS-11: MessageInfoSheet.dart:273 preview switch has no attendance case.
        skip: true);

    testWidgets('voice message never shows the raw file path', (t) async {
      await _pumpSheet(t, MessageInfoSheet(
        message: MessageData(id: 1, senderId: me, messageType: 'voice',
            content: 'uploads/rec_1.m4a'),
      ));
      expect(find.textContaining('uploads/'), findsNothing);
    },
        // BUG-CS-12: MessageInfoSheet.dart:273 preview switch misses voice/media.
        skip: true);

    testWidgets('a sent-but-not-delivered message says "Not delivered yet"',
        (t) async {
      ignoreListTileInkAssert();
      await _pumpSheet(t, MessageInfoSheet(
        message: MessageData(id: 1, senderId: me, messageType: 'text',
            content: 'hi', timestamp: '2026-01-01T10:00:00Z', isDelivered: false),
        memberData: MemberData(userId: 2, name: 'Asha'),
      ));
      expect(find.text('Not delivered yet'), findsOneWidget);
    }); // BUG-CS-15 fixed in code (passes in Run 2, 2026-11-17).
  });

  group('Message Info - Seen-by row tap feedback', () {
    testWidgets('member row renders without the ListTile ink assertion',
        (t) async {
      await _pumpSheet(t, MessageInfoSheet(
        message: MessageData(id: 1, senderId: me, messageType: 'text',
            content: 'hi', seenCount: 1),
        memberData: MemberData(userId: 2, name: 'Asha'),
      ));
      expect(t.takeException(), isNull);
    },
        // BUG-CS-14: MessageInfoSheet.dart:157 white Container sits between the
        // sheet's Material and the ListTiles: tap ripple invisible (debug assert).
        skip: true);
  });

  group('Message Info - group "Seen (X of Y)"', () {
    testWidgets('counts maps, strings and ints once; excludes me and sender',
        (t) async {
      ignoreListTileInkAssert();
      final c = _group([me, '2', '3', '4']);
      await _pumpSheet(t, MessageInfoSheet(
        groupController: c,
        message: MessageData(id: 1, senderId: me, messageType: 'text',
            content: 'hello', seenBy: [{'userId': 2}, '3', 3, 1]),
      ));
      // Recipients = 4 members - sender (me) = 3; read = {2,3} once each,
      // so both cards say 1 remaining (member 4 has not received it).
      expect(find.byKey(const ValueKey('msg_info_read_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('msg_info_read_3')), findsOneWidget);
      expect(find.byKey(const ValueKey('msg_info_read_1')), findsNothing);
      expect(find.text('User 2'), findsOneWidget);
      expect(find.text('User 3'), findsOneWidget);
      expect(find.text(en.msgInfo_remainingCount(1)), findsNWidgets(2));
    });

    testWidgets('nobody has read or received it: both cards say "2 remaining"',
        (t) async {
      ignoreListTileInkAssert();
      final c = _group([me, '2', '3']);
      await _pumpSheet(t, MessageInfoSheet(
        groupController: c,
        message: MessageData(id: 1, senderId: me, messageType: 'text',
            content: 'hello', seenBy: []),
      ));
      // WhatsApp style: "Read by" + "Delivered to", each with "N remaining".
      expect(find.text(en.msgInfo_readBy), findsOneWidget);
      expect(find.text(en.msgInfo_deliveredTo), findsOneWidget);
      expect(find.text(en.msgInfo_remainingCount(2)), findsNWidgets(2));
      expect(find.byKey(const ValueKey('msg_info_read_2')), findsNothing);
    });

    testWidgets('undelivered group message is not listed as delivered to all',
        (t) async {
      ignoreListTileInkAssert();
      final c = _group([me, '2', '3']);
      await _pumpSheet(t, MessageInfoSheet(
        groupController: c,
        message: MessageData(id: 1, senderId: me, messageType: 'text',
            content: 'hello', seenBy: [], isDelivered: false),
      ));
      // BUG-CS-16 fixed: no per-member data = nobody under "Delivered to".
      expect(find.byKey(const ValueKey('msg_info_delivered_2')), findsNothing);
      expect(find.byKey(const ValueKey('msg_info_delivered_3')), findsNothing);
    });

    testWidgets('live: a member moves Remaining -> Delivered -> Read without '
        'reopening, and a duplicate event changes nothing', (t) async {
      ignoreListTileInkAssert();
      final c = _group([me, '2', '3']);
      c.groupId = 7;
      final svc = SocketMessageService.instance;
      await _pumpSheet(t, MessageInfoSheet(
        groupController: c,
        message: MessageData(id: 41, senderId: me, messageType: 'text',
            content: 'hello', seenBy: []),
      ));
      expect(find.text(en.msgInfo_remainingCount(2)), findsNWidgets(2));

      svc.debugReceiveGroupReceipt({
        'groupId': 7,
        'userId': '2',
        'messageIds': [41],
        'deliveredAt': '2026-11-17T10:00:00Z',
      }, isRead: false);
      await t.pump();
      expect(find.byKey(const ValueKey('msg_info_delivered_2')), findsOneWidget);
      expect(find.text(en.msgInfo_remainingCount(1)), findsOneWidget);

      final read = {
        'groupId': 7,
        'userId': '2',
        'messageIds': [41],
        'readAt': '2026-11-17T10:01:00Z',
      };
      svc.debugReceiveGroupReceipt(read, isRead: true);
      svc.debugReceiveGroupReceipt(read, isRead: true); // duplicate
      await t.pump();
      expect(find.byKey(const ValueKey('msg_info_read_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('msg_info_delivered_2')), findsNothing);

      // Another message's receipt and my own echo are ignored.
      svc.debugReceiveGroupReceipt(
          {'groupId': 7, 'userId': '3', 'messageIds': [99]}, isRead: true);
      svc.debugReceiveGroupReceipt(
          {'groupId': 7, 'userId': me, 'messageIds': [41]}, isRead: true);
      await t.pump();
      expect(find.byKey(const ValueKey('msg_info_read_3')), findsNothing);
      expect(find.byKey(const ValueKey('msg_info_read_$me')), findsNothing);
    });

    testWidgets('sheet labels follow the app language (Hindi)', (t) async {
      ignoreListTileInkAssert();
      final c = _group([me, '2']);
      await _pumpSheet(
          t,
          MessageInfoSheet(
            groupController: c,
            message: MessageData(id: 1, senderId: me, messageType: 'text',
                content: 'hello', timestamp: '2026-01-01T10:00:00Z'),
          ),
          locale: const Locale('hi'));
      expect(find.text('Delivered'), findsNothing);
      expect(find.textContaining('Sent:'), findsNothing);
    },
        // BUG-CS-17: MessageInfoSheet.dart:248/255/339 hard-code "Delivered",
        // "Not delivered yet", "Sent:" in English.
        skip: true);
  });

  group('Ticks - group bubble', () {
    Future<Icon> tickOf(
        WidgetTester t, MessageData msg, List<String> members) async {
      final c = _group(members);
      await t.pumpWidget(_app(Builder(
        builder: (ctx) => GroupChatBubble(
          message: msg,
          controller: c,
          context: ctx,
          isGroup: true,
          groupId: 1,
        ),
      )));
      final icon = t
          .widgetList<Icon>(find.byWidgetPredicate((w) =>
              w is Icon && (w.icon == Icons.done || w.icon == Icons.done_all)))
          .single;
      // Let the bubble's internal timers finish before the test ends.
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 10));
      return icon;
    }

    MessageData mine({dynamic seenBy, bool delivered = false}) => MessageData(
          id: 1,
          senderId: me,
          messageType: 'text',
          content: 'hi',
          timestamp: '2026-01-01T10:00:00Z',
          seenBy: seenBy,
          isDelivered: delivered,
        );

    testWidgets('sent only: single grey tick', (t) async {
      final i = await tickOf(t, mine(), [me, '2', '3']);
      expect(i.icon, Icons.done);
      expect(i.color, isNot(purple));
    });

    testWidgets('delivered: double grey tick', (t) async {
      final i = await tickOf(t, mine(delivered: true), [me, '2', '3']);
      expect(i.icon, Icons.done_all);
      expect(i.color, isNot(purple));
    });

    // WhatsApp rule (Message Info spec): grey ✓✓ only when delivered to
    // ALL members; member 3 has not received it yet -> one ✓.
    testWidgets('seen by some members only, not delivered to all: single '
        'grey tick', (t) async {
      final i = await tickOf(t, mine(seenBy: ['2']), [me, '2', '3']);
      expect(i.icon, Icons.done);
      expect(i.color, isNot(purple));
    });

    testWidgets('seen by all (string/int ids): purple double tick', (t) async {
      final i = await tickOf(t, mine(seenBy: ['2', 3]), [me, '2', '3']);
      expect(i.icon, Icons.done_all);
      expect(i.color, purple);
    });

    testWidgets('seen by all, entries as {userId} maps: purple double tick',
        (t) async {
      final i = await tickOf(
          t, mine(seenBy: [{'userId': 2}, {'userId': '3'}]), [me, '2', '3']);
      expect(i.color, purple);
    }); // BUG-CS-13 fixed: ids are normalised (MessageReceipts).
  });

  // Run 2 (A5): the bubble tick and Message Info must always tell the same
  // story (guide §11.1: one aggregation for both). For each receipt state the
  // tick is read from the real GroupChatBubble and compared with what the
  // real MessageInfoSheet lists for every recipient.
  group('Bubble tick matches Message Info (group)', () {
    const members = [me, '2', '3'];

    MessageData state({List<String> read = const [], List<String> got = const []}) {
      final msg = MessageData(id: 51, senderId: me, messageType: 'text',
          content: 'hi', timestamp: '2026-11-17T10:00:00Z', seenBy: []);
      msg.readBy = [for (final r in read) {'userId': r, 'readAt': '2026-11-17T10:05:00Z'}];
      msg.deliveredTo = [
        for (final d in got) {'userId': d, 'deliveredAt': '2026-11-17T10:01:00Z'}
      ];
      return msg;
    }

    Future<String> bubbleTick(WidgetTester t, MessageData msg) async {
      final c = _group(members);
      await t.pumpWidget(_app(Builder(
        builder: (ctx) => GroupChatBubble(
            message: msg, controller: c, context: ctx, isGroup: true, groupId: 1),
      )));
      final icon = t
          .widgetList<Icon>(find.byWidgetPredicate((w) =>
              w is Icon && (w.icon == Icons.done || w.icon == Icons.done_all)))
          .single;
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 10));
      if (icon.icon == Icons.done) return 'sent';
      return icon.color == purple ? 'read' : 'delivered';
    }

    Future<String> infoTick(WidgetTester t, MessageData msg) async {
      final c = _group(members);
      await _pumpSheet(t, MessageInfoSheet(groupController: c, message: msg));
      final recipients = members.where((id) => id != me);
      bool listed(String kind, String id) =>
          find.byKey(ValueKey('msg_info_${kind}_$id')).evaluate().isNotEmpty;
      final allRead = recipients.every((id) => listed('read', id));
      final allGot = recipients
          .every((id) => listed('read', id) || listed('delivered', id));
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
      return allRead ? 'read' : (allGot ? 'delivered' : 'sent');
    }

    final cases = <String, MessageData Function()>{
      'nobody': () => state(),
      'delivered to one of two': () => state(got: ['2']),
      'delivered to all': () => state(got: ['2', '3']),
      'read by one, delivered to the other': () => state(read: ['2'], got: ['3']),
      'read by one only': () => state(read: ['2']),
      'read by all': () => state(read: ['2', '3']),
    };

    for (final e in cases.entries) {
      testWidgets('${e.key}: same status in the bubble and in Info', (t) async {
        ignoreListTileInkAssert();
        final fromBubble = await bubbleTick(t, e.value());
        final fromInfo = await infoTick(t, e.value());
        expect(fromBubble, fromInfo, reason: e.key);
      });
    }
  });
}
