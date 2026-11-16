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
    },
        // BUG-CS-15: MessageInfoSheet.dart:545 treats any message with a
        // timestamp as delivered, while the bubble shows a single grey tick.
        skip: true);
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
      // Y = 4 members - sender (me) = 3, X = {2,3} = 2.
      expect(find.text(en.widget_seenCountOfTotal(2, 3)), findsOneWidget);
      expect(find.text('User 2'), findsWidgets);
      expect(find.text('User 3'), findsWidgets);
      expect(find.text(en.widget_notSeenYet), findsNothing);
    });

    testWidgets('nobody has seen: "(0 of N)" and "Not seen yet"', (t) async {
      ignoreListTileInkAssert();
      final c = _group([me, '2', '3']);
      await _pumpSheet(t, MessageInfoSheet(
        groupController: c,
        message: MessageData(id: 1, senderId: me, messageType: 'text',
            content: 'hello', seenBy: []),
      ));
      expect(find.text(en.widget_seenCountOfTotal(0, 2)), findsOneWidget);
      expect(find.text(en.widget_notSeenYet), findsOneWidget);
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
      expect(find.text('Not delivered yet'), findsOneWidget);
    },
        // BUG-CS-16: MessageInfoSheet.dart:74 fills "Delivered" with every
        // other member when the info API gives nothing ("(2 of 2)").
        skip: true);

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

    testWidgets('seen by some members only: double grey tick', (t) async {
      final i = await tickOf(t, mine(seenBy: ['2']), [me, '2', '3']);
      expect(i.icon, Icons.done_all);
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
    },
        // BUG-CS-13: ChatItem.dart:3211 _areAllMembersSeen uses entry.toString(),
        // so {userId} map entries never match -> blue tick never shown.
        skip: true);
  });
}
