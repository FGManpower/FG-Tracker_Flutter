// Widgets of the "Couldn't refresh · Retry" rules (F-1.2.9): the bar itself,
// the full error view, and the message list in every state (skeleton /
// full error / empty / list / list + bar). The bar sits ABOVE the list and
// never covers the first row.
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:fgtracker/app/modules/Messages/widgets/chat_history_widgets.dart';
import 'package:fgtracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_chat_api_server.dart';

Widget _app(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('ChatRefreshFailedBar / ChatHistoryErrorState', () {
    testWidgets('the bar shows the text, has its key and calls Retry',
        (t) async {
      var taps = 0;
      await t.pumpWidget(
          _app(ChatRefreshFailedBar(visible: true, onRetry: () => taps++)));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('chat_refresh_failed_bar')),
          findsOneWidget);
      expect(find.textContaining('Retry'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('chat_refresh_failed_bar')));
      expect(taps, 1);
    });

    testWidgets('hidden: nothing is built', (t) async {
      await t.pumpWidget(
          _app(ChatRefreshFailedBar(visible: false, onRetry: () {})));
      expect(find.byKey(const ValueKey('chat_refresh_failed_bar')),
          findsNothing);
    });

    testWidgets('the full error view calls Retry', (t) async {
      var taps = 0;
      await t.pumpWidget(_app(ChatHistoryErrorState(onRetry: () => taps++)));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('chat_history_retry')));
      expect(taps, 1);
    });
  });

  group('GroupChatList states', () {
    late _SpyGroupController c;

    setUp(() async {
      HttpOverrides.global = LoopbackOnlyHttpOverrides();
      SocketMessageService.debugSocketUrlOverride = 'http://127.0.0.1:9';
      ChatScreenRules.historyTimeout = const Duration(milliseconds: 100);
      RefreshBarState.quietRetryDelay = const Duration(milliseconds: 50);
      Get.reset();
      SharedPreferences.setMockInitialValues({
        PrefConst.userId: '1',
        PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
      });
      Global.storageServices = await StorageServices().init();
    });

    tearDown(() async {
      SocketMessageService.instance.disconnectAll();
      Get.reset();
      HttpOverrides.global = null;
      SocketMessageService.debugSocketUrlOverride = null;
      ChatScreenRules.historyTimeout = const Duration(seconds: 10);
      RefreshBarState.quietRetryDelay = const Duration(seconds: 2);
    });

    MessageData m(int id) => MessageData.fromJson({
          'id': id,
          'senderId': '2',
          'senderName': 'Asha',
          'content': 'message $id',
          'messageType': 'text',
          'timestamp': DateTime.utc(2026, 11, 17, 10, id).toIso8601String(),
        });

    /// A real controller (its own loads fail: no network), then the state
    /// under test is set directly.
    Future<void> show(WidgetTester t,
        {required bool loading,
        required bool failed,
        List<int> ids = const []}) async {
      await t.runAsync(() async {
        Get.routing.args = {'groupId': 77, 'groupName': 'QA'};
        c = Get.put<GroupMessageController>(_SpyGroupController())
            as _SpyGroupController;
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      c.messageData
        ..clear()
        ..addAll([for (final i in ids) m(i)]);
      c.isLoading.value = loading;
      c.historyLoadFailed.value = failed;
      await t.pumpWidget(_app(GroupChatList(controller: c)));
      c.updateMessageStream();
      await t.pump(const Duration(milliseconds: 300));
    }

    /// Ends the test cleanly: no widget, no controller, fake timers run out.
    Future<void> done(WidgetTester t) async {
      await t.pumpWidget(const SizedBox());
      await Get.delete<GroupMessageController>(force: true);
      await t.pump(const Duration(seconds: 15));
    }

    testWidgets('loading, nothing cached → skeleton', (t) async {
      await show(t, loading: true, failed: false);
      expect(find.byType(ChatMessageSkeleton), findsOneWidget);
      expect(find.byKey(const ValueKey('chat_refresh_failed_bar')),
          findsNothing);
      await done(t);
    });

    testWidgets('failed, nothing cached → full error, no bar', (t) async {
      await show(t, loading: false, failed: true);
      expect(find.byType(ChatHistoryErrorState), findsOneWidget);
      expect(find.byKey(const ValueKey('chat_refresh_failed_bar')),
          findsNothing);
      await done(t);
    });

    testWidgets('loaded, no messages → empty state', (t) async {
      await show(t, loading: false, failed: false);
      expect(find.byType(ChatHistoryErrorState), findsNothing);
      expect(find.byType(ChatMessageSkeleton), findsNothing);
      expect(find.text('💬'), findsOneWidget);
      await done(t);
    });

    testWidgets('messages → list, no bar', (t) async {
      await show(t, loading: false, failed: false, ids: [1, 2, 3]);
      expect(find.text('message 3'), findsOneWidget);
      expect(find.byKey(const ValueKey('chat_refresh_failed_bar')),
          findsNothing);
      await done(t);
    });

    testWidgets('messages + failure → list + bar ABOVE the first row; tap '
        'retries', (t) async {
      await show(t, loading: false, failed: true, ids: [1, 2, 3]);
      final bar = find.byKey(const ValueKey('chat_refresh_failed_bar'));
      expect(bar, findsOneWidget);
      expect(find.text('message 1'), findsOneWidget);
      final barBottom = t.getBottomLeft(bar).dy;
      final firstRowTop = t.getTopLeft(find.text('message 1')).dy;
      expect(barBottom, lessThanOrEqualTo(firstRowTop),
          reason: 'the bar must not cover the first message');
      await t.tap(bar);
      expect(c.retries, 1, reason: 'tapping the bar calls retryLoadHistory');
      await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 400)));
      await t.pump(const Duration(seconds: 1));
      await done(t);
    });
  });
}

/// Counts Retry taps (the real retry is covered by chat_refresh_bar_test).
class _SpyGroupController extends GroupMessageController {
  int retries = 0;
  @override
  Future<void> retryLoadHistory() async => retries++;
}
