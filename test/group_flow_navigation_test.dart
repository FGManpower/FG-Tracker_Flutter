import 'package:fgtracker/app/modules/Group/widgets/group_membership_sheet.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Exit-group navigation: back to where the user started, never to a screen
/// they didn't visit (FLUTTER_CHAT_FRONTEND_GUIDE §2.11).
const _chatList = GroupMembershipSheet.chatListRoute;
const _groupChat = '/test-group-chat';
const _groupInfo = '/test-group-info';

Widget _page(String name) => Scaffold(body: Text('page:$name'));

Future<void> _pumpApp(WidgetTester t) async {
  await t.pumpWidget(GetMaterialApp(
    initialRoute: Routes.Home_Screen,
    getPages: [
      for (final name in [
        Routes.Home_Screen,
        Routes.GroupsList,
        Routes.WalkieGroupSelect,
        Routes.groupWalkieScreen,
        _chatList,
        _groupChat,
        _groupInfo,
      ])
        GetPage(name: name, page: () => _page(name)),
    ],
  ));
  await t.pumpAndSettle();
}

Future<void> _push(WidgetTester t, List<String> routes) async {
  for (final r in routes) {
    Get.toNamed(r);
    await t.pumpAndSettle();
  }
}

Future<void> _leave(WidgetTester t) async {
  GroupMembershipSheet.navigateAfterLeave(groupId: '12');
  await t.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  tearDown(Get.reset);

  testWidgets('Chatting: exit returns to the Chat List', (t) async {
    await _pumpApp(t);
    await _push(t, [_chatList, _groupChat, _groupInfo]);
    await _leave(t);
    expect(Get.currentRoute, _chatList);
  });

  testWidgets('All Groups: exit returns to the All Group List', (t) async {
    await _pumpApp(t);
    await _push(t, [Routes.GroupsList, _groupChat, _groupInfo]);
    await _leave(t);
    expect(Get.currentRoute, Routes.GroupsList);
  });

  testWidgets('Walkie: exit returns to the Walkie group select', (t) async {
    await _pumpApp(t);
    await _push(t, [
      Routes.WalkieGroupSelect,
      Routes.groupWalkieScreen,
      _groupChat,
      _groupInfo,
    ]);
    await _leave(t);
    expect(Get.currentRoute, Routes.WalkieGroupSelect);
  });

  testWidgets('Home: exit returns to Home and opens nothing else', (t) async {
    await _pumpApp(t);
    await _push(t, [_groupChat, _groupInfo]);
    await _leave(t);
    expect(Get.currentRoute, Routes.Home_Screen);
    expect(find.text('page:${Routes.GroupsList}'), findsNothing);
  });

  testWidgets('nearest start screen wins (Chat List -> Walkie select)',
      (t) async {
    await _pumpApp(t);
    await _push(t, [
      _chatList,
      Routes.WalkieGroupSelect,
      Routes.groupWalkieScreen,
      _groupChat,
      _groupInfo,
    ]);
    await _leave(t);
    expect(Get.currentRoute, Routes.WalkieGroupSelect);
  });
}
