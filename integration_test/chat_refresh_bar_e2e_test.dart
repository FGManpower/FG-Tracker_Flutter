// E2E: the "Couldn't refresh · Retry" bar on the chat list and in chats
// (F-1.2.9). Runs the real app against STAGING on a real device / emulator.
//
// Before running:
//  * Device logged in with the staging test account (the app opens on Home).
//  * Open the chat list and the two chats below once (fills the cache).
//  * Bots (scripts/chat_qa/) can send messages during the waits.
//
// Run (3 times per platform; one failure out of 3 = flaky, record it):
//   flutter test integration_test/chat_refresh_bar_e2e_test.dart \
//     -d <device> --dart-define=IS_PROD=false \
//     --dart-define=E2E_PRIVATE_CHAT="<private chat name>" \
//     --dart-define=E2E_GROUP_CHAT="<1000+ message group name>"
//
// Network steps print `E2E-ACTION: …` and then wait (max 90 s) for the
// expected result:
//   Android: adb shell cmd connectivity airplane-mode enable|disable
//   iOS:     Control Centre → Airplane mode (manual)
// Cases E2E-RB-04 (new chat with a bot), -07 (slow network), -09 (Wi-Fi ↔
// data) and -10 (account B) need a second account / network tools and are in
// docs/testing/chatting/manual_testing/manual_checklist.md.
import 'package:fgtracker/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _privateChat = String.fromEnvironment('E2E_PRIVATE_CHAT');
const _groupChat = String.fromEnvironment('E2E_GROUP_CHAT');
const _barKey = ValueKey('chat_refresh_failed_bar');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder bar() => find.byKey(_barKey);

  /// Pumps until [ok] (or fails after [max]).
  Future<void> waitUntil(WidgetTester t, bool Function() ok, String what,
      {Duration max = const Duration(seconds: 90)}) async {
    final end = DateTime.now().add(max);
    while (!ok()) {
      if (DateTime.now().isAfter(end)) fail('timed out: $what');
      await t.pump(const Duration(milliseconds: 500));
    }
  }

  /// Pumps for [d] and fails if the bar appears at any point.
  Future<void> noBarFor(WidgetTester t, Duration d, String where) async {
    final end = DateTime.now().add(d);
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 500));
      expect(bar(), findsNothing, reason: 'false bar on $where');
    }
  }

  void noFalseEmpty(String where) {
    expect(find.text('No messages here yet'), findsNothing,
        reason: 'false "No messages here yet" on $where');
  }

  Future<void> launchToChatList(WidgetTester t) async {
    app.main();
    await waitUntil(t, () => find.text('Chatting').evaluate().isNotEmpty,
        'Home with the Chatting quick action');
    await t.tap(find.text('Chatting').first);
    await t.pump(const Duration(seconds: 1));
  }

  Future<void> openChat(WidgetTester t, String name) async {
    await waitUntil(
        t, () => find.text(name).evaluate().isNotEmpty, 'row "$name"');
    await t.tap(find.text(name).first);
    await t.pump(const Duration(seconds: 1));
  }

  testWidgets('E2E-RB-01 cold start → chat list, 30 s: no bar', (t) async {
    await launchToChatList(t);
    await noBarFor(t, const Duration(seconds: 30), 'chat list');
  });

  testWidgets('E2E-RB-02 cached private chat, 30 s: no bar, never empty',
      (t) async {
    expect(_privateChat, isNotEmpty, reason: 'set E2E_PRIVATE_CHAT');
    await launchToChatList(t);
    await openChat(t, _privateChat);
    await noBarFor(t, const Duration(seconds: 30), 'private chat');
    noFalseEmpty('private chat');
  });

  testWidgets('E2E-RB-03 big group, 30 s: no bar, never blank', (t) async {
    expect(_groupChat, isNotEmpty, reason: 'set E2E_GROUP_CHAT');
    await launchToChatList(t);
    await openChat(t, _groupChat);
    await noBarFor(t, const Duration(seconds: 30), 'group chat');
    noFalseEmpty('group chat');
  });

  testWidgets('E2E-RB-05/06 airplane on → bar within ~12 s, rows stay; '
      'airplane off → the bar hides by itself', (t) async {
    expect(_privateChat, isNotEmpty, reason: 'set E2E_PRIVATE_CHAT');
    await launchToChatList(t);
    await t.pump(const Duration(seconds: 5));
    // ignore: avoid_print
    print('E2E-ACTION: airplane-on, then pull the chat list down');
    await waitUntil(t, () => bar().evaluate().isNotEmpty,
        'bar on the chat list while offline');
    expect(find.text(_privateChat), findsWidgets, reason: 'rows stay');
    await openChat(t, _privateChat);
    await waitUntil(t, () => bar().evaluate().isNotEmpty,
        'bar in the chat while offline (≤ ~12 s)',
        max: const Duration(seconds: 20));
    noFalseEmpty('offline private chat');
    // ignore: avoid_print
    print('E2E-ACTION: airplane-off (do not tap Retry)');
    await waitUntil(t, () => bar().evaluate().isEmpty,
        'bar hides by itself after the reconnect');
  });

  testWidgets('E2E-RB-08 background 10 min → resume: no bar', (t) async {
    expect(_privateChat, isNotEmpty, reason: 'set E2E_PRIVATE_CHAT');
    await launchToChatList(t);
    await openChat(t, _privateChat);
    // ignore: avoid_print
    print('E2E-ACTION: send the app to the background for 10 minutes '
        '(bots may send messages), then bring it back');
    await t.pump(const Duration(minutes: 11));
    await noBarFor(t, const Duration(seconds: 20), 'resumed chat');
  }, timeout: const Timeout(Duration(minutes: 15)));
}
