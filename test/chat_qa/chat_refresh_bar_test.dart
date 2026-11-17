// Regression (F-1.2.8): inside an open chat the "Couldn't refresh · Retry"
// bar appeared ~10 s after opening when the history request was slow or
// failed once, although the chat kept working. Now one quiet retry runs
// first; the bar shows only if that fails too. An empty chat still gets the
// full error at once. Same rules in the private chat (MessageController).
import 'dart:io';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every non-loopback host goes to a dead proxy: the history API fails fast,
/// like a phone without network (same as group_open_during_build_test).
class _NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)..findProxy = (_) => 'PROXY 127.0.0.1:9';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    HttpOverrides.global = _NoNetwork();
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: '1',
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
    });
    Global.storageServices = await StorageServices().init();
    ConstRes.socketUrl = 'http://127.0.0.1:9';
  });

  tearDown(() {
    SocketMessageService.instance.disconnectAll();
    Get.reset();
    HttpOverrides.global = null;
  });

  MessageData msg(int id) => MessageData.fromJson({
        'id': id,
        'senderId': '2',
        'content': 'cached $id',
        'timestamp': '2026-11-17T10:00:00Z',
      });

  /// Waits until [done] or [max].
  Future<void> waitFor(bool Function() done,
      {Duration max = const Duration(seconds: 15)}) async {
    final end = DateTime.now().add(max);
    while (!done() && DateTime.now().isBefore(end)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  test('RB-01 messages on screen: first failure is quiet, the bar shows only '
      'after the retry also fails', () async {
    final c = Get.put(GroupMessageController());
    c.messageData.add(msg(1)); // what the cache put on screen
    // First failure: no bar, a quiet retry is scheduled.
    await waitFor(() => c.debugHistoryFailures >= 1);
    expect(c.debugHistoryFailures, 1);
    expect(c.historyLoadFailed.value, isFalse,
        reason: 'no bar after one failure');
    // The quiet retry (2 s later) fails too → now the bar.
    await waitFor(() => c.debugHistoryFailures >= 2);
    expect(c.historyLoadFailed.value, isTrue);
    expect(c.messageData, isNotEmpty, reason: 'messages stay on screen');
  }, timeout: const Timeout(Duration(seconds: 40)));

  test('RB-02 empty chat: the full error at once (as before)', () async {
    final c = Get.put(GroupMessageController());
    await waitFor(() => c.historyLoadFailed.value,
        max: const Duration(seconds: 12));
    expect(c.historyLoadFailed.value, isTrue);
    expect(c.messageData, isEmpty);
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('RB-03 Retry tapped by the user: a failure shows the bar at once',
      () async {
    final c = Get.put(GroupMessageController());
    c.messageData.add(msg(1));
    await waitFor(() => c.historyLoadFailed.value);
    expect(c.historyLoadFailed.value, isTrue);
    final tapped = DateTime.now();
    final retry = c.retryLoadHistory();
    expect(c.historyLoadFailed.value, isFalse); // hidden while retrying
    await retry;
    expect(c.historyLoadFailed.value, isTrue);
    expect(DateTime.now().difference(tapped).inSeconds, lessThan(12),
        reason: 'no extra quiet retry after a user Retry');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
