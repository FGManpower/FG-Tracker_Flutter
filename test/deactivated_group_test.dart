import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/widgets/chat_list_row_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('chat-list row: groupStatus (backend v2.5.0)', () {
    test('groupStatus "deactivated" marks the group', () {
      final c = PrivateChatModel.fromJson(
          {'chatType': 'group', 'groupId': 5, 'groupStatus': 'deactivated'});
      expect(c.groupStatus, 'deactivated');
      expect(c.isGroupDeactivated, isTrue);
    });

    test('isDeactivated flag, also inside the group object', () {
      expect(
          PrivateChatModel.fromJson({'chatType': 'group', 'isDeactivated': true})
              .isGroupDeactivated,
          isTrue);
      expect(
          PrivateChatModel.fromJson({
            'chatType': 'group',
            'group': {'id': 3, 'isDeactivated': true}
          }).isGroupDeactivated,
          isTrue);
    });

    test('active or missing status is not deactivated', () {
      expect(
          PrivateChatModel.fromJson({'chatType': 'group', 'groupStatus': 'active'})
              .isGroupDeactivated,
          isFalse);
      expect(PrivateChatModel.fromJson({'chatType': 'group'}).isGroupDeactivated,
          isFalse);
    });

    test('survives toJson round trip', () {
      final c = PrivateChatModel.fromJson(
          {'chatType': 'group', 'groupId': 5, 'groupStatus': 'deactivated'});
      expect(PrivateChatModel.fromJson(c.toJson()).isGroupDeactivated, isTrue);
    });
  });

  testWidgets('badge and banner render', (t) async {
    await t.pumpWidget(_app(const Column(children: [
      DeactivatedGroupBadge(),
      DeactivatedGroupBanner(),
    ])));
    expect(find.text('Deactivated'), findsOneWidget);
    expect(find.text('This group has been deactivated by the Admin'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
