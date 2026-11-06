import 'package:fgtracker/app/modules/Messages/widgets/chat_list_row_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: SizedBox(width: 320, child: child)),
      ),
    );

void main() {
  testWidgets('typing text renders the label on one line', (tester) async {
    await tester.pumpWidget(host(const ChatTypingText(label: 'Rahul is typing...')));
    final text = tester.widget<Text>(find.byKey(const ValueKey('chat_typing_text')));
    expect(text.data, 'Rahul is typing...');
    expect(text.maxLines, 1);
    expect(text.style?.fontStyle, FontStyle.italic);
  });

  testWidgets('Archived entry shows count and unread badge', (tester) async {
    await tester.pumpWidget(
      host(const ArchivedEntryLabels(archivedCount: 3, unreadCount: 5)),
    );
    expect(find.text('Archived (3)'), findsOneWidget);
    expect(find.text('5 unread messages'), findsOneWidget);
    expect(find.byKey(const ValueKey('archived_entry_badge')), findsOneWidget);
  });

  testWidgets('Archived entry without unread has no badge', (tester) async {
    await tester.pumpWidget(
      host(const ArchivedEntryLabels(archivedCount: 1, unreadCount: 0)),
    );
    expect(find.text('Archived (1)'), findsOneWidget);
    expect(find.text('View archived conversations'), findsOneWidget);
    expect(find.byKey(const ValueKey('archived_entry_badge')), findsNothing);
  });

  testWidgets('large text scale does not overflow', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: host(const ArchivedEntryLabels(archivedCount: 120, unreadCount: 250)),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('99+'), findsOneWidget);
  });
}
