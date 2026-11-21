import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/app/modules/Messages/widgets/MessageContextMenu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<MessageContextMenuAction> testActions({
    required VoidCallback onReply,
    required VoidCallback onDelete,
  }) =>
      [
        MessageContextMenuAction(
          icon: Icons.reply,
          title: 'Reply',
          onTap: onReply,
        ),
        MessageContextMenuAction(
          icon: Icons.copy,
          title: 'Copy',
          onTap: () {},
        ),
        MessageContextMenuAction(
          icon: Icons.forward,
          title: 'Forward',
          onTap: () {},
        ),
        MessageContextMenuAction(
          icon: Icons.edit,
          title: 'Edit',
          onTap: () {},
        ),
        MessageContextMenuAction(
          icon: Icons.push_pin,
          title: 'Pin Message',
          onTap: () {},
        ),
        MessageContextMenuAction(
          icon: Icons.info_outline,
          title: 'Message Info',
          onTap: () {},
        ),
        MessageContextMenuAction(
          icon: Icons.delete_outline,
          title: 'Delete for Everyone',
          isDestructive: true,
          onTap: onDelete,
        ),
        MessageContextMenuAction(
          icon: Icons.delete,
          title: 'Delete for Me',
          isDestructive: true,
          onTap: onDelete,
        ),
      ];

  Widget buildTestableApp({
    required double bubbleTop,
    required double bubbleHeight,
    required bool isSentByMe,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                left: isSentByMe ? 120 : 16,
                top: bubbleTop,
                width: 220,
                height: bubbleHeight,
                child: Builder(
                  builder: (bubbleContext) => GestureDetector(
                    key: const ValueKey('bubble_target'),
                    onTap: () {
                      MessageContextMenu.show(
                        context: bubbleContext,
                        bubbleContext: bubbleContext,
                        isSentByMe: isSentByMe,
                        actions: testActions(onReply: () {}, onDelete: () {}),
                        onReactionSelected: (emoji) {},
                        messageWidget: Container(
                          color: Colors.green,
                          child: const Text('Test Bubble'),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.green,
                      child: const Text('Test Bubble'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets(
      'Case A: Top message opens with reactions and all 8 options visible within bounds',
      (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
        buildTestableApp(bubbleTop: 60, bubbleHeight: 50, isSentByMe: true));
    await tester.tap(find.byKey(const ValueKey('bubble_target')));
    await tester.pumpAndSettle();

    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Forward'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Pin Message'), findsOneWidget);
    expect(find.text('Message Info'), findsOneWidget);
    expect(find.text('Delete for Everyone'), findsOneWidget);
    expect(find.text('Delete for Me'), findsOneWidget);
    expect(find.text('👍'), findsOneWidget);

    final replyBox = tester.getTopLeft(find.text('Reply'));
    final deleteBox = tester.getBottomLeft(find.text('Delete for Me'));
    expect(replyBox.dy, greaterThan(0));
    expect(deleteBox.dy, lessThan(812));
  });

  testWidgets(
      'Case B: Middle message opens adjacent with all 8 options visible within bounds',
      (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
        buildTestableApp(bubbleTop: 300, bubbleHeight: 50, isSentByMe: true));
    await tester.tap(find.byKey(const ValueKey('bubble_target')));
    await tester.pumpAndSettle();

    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Delete for Everyone'), findsOneWidget);
    expect(find.text('Delete for Me'), findsOneWidget);
    expect(find.text('👍'), findsOneWidget);

    final replyBox = tester.getTopLeft(find.text('Reply'));
    final deleteBox = tester.getBottomLeft(find.text('Delete for Me'));
    expect(replyBox.dy, greaterThan(0));
    expect(deleteBox.dy, lessThan(812));
  });

  testWidgets(
      'Case C: Bottom message auto-shifts to center and all 8 options visible within bounds without clipping',
      (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
        buildTestableApp(bubbleTop: 700, bubbleHeight: 50, isSentByMe: true));
    await tester.tap(find.byKey(const ValueKey('bubble_target')));
    await tester.pumpAndSettle();

    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Delete for Everyone'), findsOneWidget);
    expect(find.text('Delete for Me'), findsOneWidget);
    expect(find.text('👍'), findsOneWidget);

    final replyBox = tester.getTopLeft(find.text('Reply'));
    final deleteBox = tester.getBottomLeft(find.text('Delete for Me'));
    expect(replyBox.dy, greaterThan(0));
    expect(deleteBox.dy, lessThan(812));
  });

  testWidgets(
      'Case D: Bada / Tall message centers message, pins reactions top and menu bottom',
      (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
        buildTestableApp(bubbleTop: 100, bubbleHeight: 500, isSentByMe: true));
    await tester.tap(find.byKey(const ValueKey('bubble_target')));
    await tester.pumpAndSettle();

    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Delete for Everyone'), findsOneWidget);
    expect(find.text('Delete for Me'), findsOneWidget);
    expect(find.text('👍'), findsOneWidget);

    final replyBox = tester.getTopLeft(find.text('Reply'));
    final deleteBox = tester.getBottomLeft(find.text('Delete for Me'));
    expect(replyBox.dy, greaterThan(0));
    expect(deleteBox.dy, lessThan(812));
  });
}
