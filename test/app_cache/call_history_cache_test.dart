// Call history on the app cache (doc 07 §3.5).
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/recent_call.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

String today() {
  final n = DateTime.now();
  return '${n.year}-${n.month}-${n.day}';
}

Map<String, dynamic> call(String id, {String day = ''}) => {
      'd': day.isEmpty ? today() : day,
      's': 'today',
      'c': {
        'id': id,
        'type': 'audio',
        'direction': 'outgoing',
        'status': 'completed',
        'called_at': '2026-11-17T10:00:00Z',
        'display_time': '10:00 AM',
        'callerId': '101',
        'receiverId': '202',
        'callerName': 'Me',
      },
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppCacheTestEnv env;

  setUp(() async {
    Get.reset();
    env = await AppCacheTestEnv.create();
    // Toasts have no platform side in unit tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('PonnamKarthik/fluttertoast'), (_) async => true);
    SharedPreferences.setMockInitialValues(
        {PrefConst.userId: AppCacheTestEnv.me});
    Global.storageServices = await StorageServices().init();
  });

  tearDown(() async {
    // Close controllers (onClose) so none of them writes into the next
    // test's cache; Get.reset alone keeps them alive.
    await Get.deleteAll(force: true);
    Get.reset();
    await env.dispose();
  });

  Future<CallController> open() async {
    final c = Get.put(CallController());
    for (var i = 0; i < 50 && c.recentCallLoading.value; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return c;
  }

  test('CH-01 CallingDetail round trip keeps the shown fields', () {
    final c = CallingDetail.fromJson(call('9')['c'] as Map<String, dynamic>);
    final back = CallingDetail.fromJson(c.toJson());
    expect(back.id, '9');
    expect(back.calledAt, '2026-11-17T10:00:00Z');
    expect(back.displayTime, '10:00 AM');
    expect(back.callerName, 'Me');
  });

  test('CH-02 today\'s cached calls show; offline keeps them + retry flag',
      () async {
    await AppCache.write(AppCache.callHistory, [call('1'), call('2')]);
    final c = await open();
    expect(c.recentCallList, hasLength(2));
    expect(c.recentRefreshFailed.value, isTrue);
    expect(c.recentCallResponseError.value, isEmpty);
  });

  test('CH-03 calls cached on another day are dropped (stale sections)',
      () async {
    await AppCache.write(
        AppCache.callHistory, [call('1', day: '2000-1-1')]);
    final c = await open();
    expect(c.recentCallList, isEmpty);
    expect(await AppCache.read(AppCache.callHistory), isEmpty);
  });

  test('CH-04 "clear all" is saved: no ghost calls after a restart',
      () async {
    await AppCache.write(AppCache.callHistory, [call('1'), call('2')]);
    final c = await open();
    final ok = await c.clearAllRecentCalls(
        apiCall: () async => CommonResponse(status: true, message: 'ok'));
    expect(ok, isTrue);
    await AppCache.flushPendingWrites();
    expect(await AppCache.read(AppCache.callHistory), isEmpty);
  });

  test('SC-04 app resume runs the catch-up API (and keeps the cache)',
      () async {
    await AppCache.write(AppCache.callHistory, [call('1')]);
    final c = await open();
    c.recentRefreshFailed.value = false; // reset after the first attempt
    final binding = TestWidgetsFlutterBinding.instance;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    for (var i = 0; i < 50 && !c.recentRefreshFailed.value; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    // The resume refresh ran (offline here, so it failed) and the calls
    // already on screen stayed.
    expect(c.recentRefreshFailed.value, isTrue);
    expect(c.recentCallList, hasLength(1));
  });
}
