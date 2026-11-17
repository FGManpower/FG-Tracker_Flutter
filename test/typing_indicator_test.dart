// Typing indicator (chat list rows).
//
// T-05 (Run 2, 2026-11-17): this file used to copy the typing logic into the
// test, so it never ran app code. It now drives the real ChatTypingTracker
// (chat_list_logic.dart) and the real ChatListController payload handlers.
// Timers are real but short (the tracker takes its expiry as a parameter),
// so no fake_async / clock import is needed.
//
// Not covered here: the private chat SCREEN's own 4 s "typing..." timer in
// MessageController (needs testability change: the screen typing handler is
// private, MessageController.dart, see unit_test_report.md).
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_logic.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const me = '1001';
final en = lookupAppLocalizations(const Locale('en'));

Future<void> wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.locale = const Locale('en'));

  group('ChatTypingTracker (private row)', () {
    test('start -> "typing...", stop -> no label, onChanged once each', () {
      var changes = 0;
      final t = ChatTypingTracker(onChanged: () => changes++);
      expect(t.label('private_5', isGroup: false), isNull);

      t.start('private_5', '5');
      expect(t.isTyping('private_5'), isTrue);
      expect(t.label('private_5', isGroup: false), en.chatList_typing);
      expect(changes, 1);

      // A repeated typing event only restarts the timer.
      t.start('private_5', '5');
      expect(changes, 1);

      t.stop('private_5', '5');
      expect(t.isTyping('private_5'), isFalse);
      expect(changes, 2);
      t.clearAll();
    });

    test('expires on its own when the stop event is lost', () async {
      final t = ChatTypingTracker(
          onChanged: () {}, expiry: const Duration(milliseconds: 80));
      t.start('private_5', '5');
      await wait(40);
      t.start('private_5', '5'); // still typing: timer restarts
      await wait(60);
      expect(t.isTyping('private_5'), isTrue);
      await wait(60);
      expect(t.isTyping('private_5'), isFalse);
    });

    test('a message from the chat clears typing at once', () {
      final t = ChatTypingTracker(onChanged: () {});
      t.start('private_5', '5');
      t.clearChat('private_5');
      expect(t.isTyping('private_5'), isFalse);
      t.clearAll();
    });
  });

  group('ChatTypingTracker (group row)', () {
    test('labels for 1, 2 and 3+ typists, and back down', () {
      final t = ChatTypingTracker(onChanged: () {});
      const k = 'group_100';
      t.start(k, 'u1', name: 'Rahul');
      expect(t.label(k, isGroup: true), en.chatList_oneTyping('Rahul'));
      t.start(k, 'u2', name: 'Amit');
      expect(t.label(k, isGroup: true), en.chatList_twoTyping('Rahul', 'Amit'));
      t.start(k, 'u3', name: 'Sneha');
      t.start(k, 'u4', name: 'Priya');
      expect(t.label(k, isGroup: true),
          en.chatList_manyTyping('Rahul', 'Amit', 2));
      t.stop(k, 'u4');
      t.stop(k, 'u3');
      expect(t.label(k, isGroup: true), en.chatList_twoTyping('Rahul', 'Amit'));
      t.stop(k, 'u2');
      t.stop(k, 'u1');
      expect(t.label(k, isGroup: true), isNull);
    });

    test('a typist without a name is shown as "Someone"', () {
      final t = ChatTypingTracker(onChanged: () {});
      t.start('group_1', 'u9');
      expect(t.label('group_1', isGroup: true),
          en.chatList_oneTyping(en.chatList_someone));
      t.clearAll();
    });

    test('per-user timers expire independently', () async {
      final t = ChatTypingTracker(
          onChanged: () {}, expiry: const Duration(milliseconds: 100));
      const k = 'group_100';
      t.start(k, 'uA', name: 'Rahul');
      await wait(50);
      t.start(k, 'uB', name: 'Amit');
      await wait(70); // A expired, B still typing
      expect(t.label(k, isGroup: true), en.chatList_oneTyping('Amit'));
      await wait(60);
      expect(t.isTyping(k), isFalse);
    });

    test('empty chat key or user id is ignored', () {
      var changes = 0;
      final t = ChatTypingTracker(onChanged: () => changes++);
      t.start('', 'u1');
      t.start('group_1', '');
      expect(changes, 0);
    });
  });

  group('ChatListController typing payloads (real handlers)', () {
    late ChatListController c;

    setUp(() async {
      Get.reset();
      Get.locale = const Locale('en');
      SharedPreferences.setMockInitialValues({PrefConst.userId: me});
      Global.storageServices = await StorageServices().init();
      c = Get.put(ChatListController());
      await wait(50); // initial (failing) loads finish first
    });

    tearDown(Get.reset);

    PrivateChatModel groupRow(int id) =>
        PrivateChatModel(groupId: id, isGroup: true, chatType: 'group');

    test('own typing and other groups are ignored; members are shown', () {
      c.debugHandleGroupTyping({'groupId': 100, 'userId': me, 'userName': 'Me'});
      expect(c.typingLabelFor(groupRow(100)), isNull);

      c.debugHandleGroupTyping({'groupId': 999, 'userId': 'u1', 'userName': 'R'});
      expect(c.typingLabelFor(groupRow(100)), isNull);

      c.debugHandleGroupTyping(
          {'groupId': 100, 'userId': 'u1', 'userName': 'Rahul'});
      expect(c.typingLabelFor(groupRow(100)), en.chatList_oneTyping('Rahul'));

      c.debugHandleGroupTyping({'groupId': 100, 'userId': 'u1'}, typing: false);
      expect(c.typingLabelFor(groupRow(100)), isNull);
    });

    test('isTyping:false on the typing event counts as stop', () {
      c.debugHandleGroupTyping(
          {'groupId': 100, 'userId': 'u1', 'userName': 'Rahul'});
      c.debugHandleGroupTyping(
          {'groupId': 100, 'userId': 'u1', 'isTyping': false});
      expect(c.typingLabelFor(groupRow(100)), isNull);
    });

    test('malformed payloads (null, String, List, no ids) never throw', () {
      for (final bad in [null, 'x', [1, 2], <String, dynamic>{}, {'userId': 'u1'}]) {
        c.debugHandleGroupTyping(bad);
        c.debugHandlePrivateTyping(bad);
      }
      expect(c.typingLabelFor(groupRow(100)), isNull);
    });
  });
}
