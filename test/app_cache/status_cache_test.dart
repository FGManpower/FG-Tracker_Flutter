// Status strip on the app cache (doc 07 §3.6): expiry, no viewer lists,
// logout / account switch for the permanent controllers.
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Data/Services/chat_message_cache.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/modules/Attendance/controller/attendance_controller.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

Map<String, dynamic> status(int id, {Duration expiresIn = const Duration(hours: 5)}) => {
      'id': id,
      'userId': 7,
      'type': 'text',
      'content': 'hello $id',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'expiresAt': DateTime.now().toUtc().add(expiresIn).toIso8601String(),
      'viewers': [
        {'viewerId': 3, 'name': 'Viewer', 'viewedAt': '2026-11-17T10:00:00Z'}
      ],
      'creator': {'id': 7, 'name': 'Asha', 'profilePic': 'https://x/y.jpg'},
    };

Map<String, dynamic> feedGroup(int userId, List<Map<String, dynamic>> s) => {
      'user': {'id': userId, 'name': 'User $userId'},
      'isAllViewed': false,
      'latestTimestamp': DateTime.now().toUtc().toIso8601String(),
      'statuses': s,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppCacheTestEnv env;

  Future<void> loginAs(String id) async {
    env.user = id;
    SharedPreferences.setMockInitialValues({PrefConst.userId: id});
    Global.storageServices = await StorageServices().init();
  }

  setUp(() async {
    Get.reset();
    env = await AppCacheTestEnv.create();
    await loginAs(AppCacheTestEnv.me);
    // Registered but never connected: no network in unit tests.
    Get.put(StatusSocketService(), permanent: true);
  });

  tearDown(() async {
    // Close controllers (onClose) so none of them writes into the next
    // test's cache; Get.reset alone keeps them alive.
    await Get.deleteAll(force: true);
    Get.reset();
    await env.dispose();
  });

  Future<StatusFeedController> open() async {
    final c = Get.put(StatusFeedController(), permanent: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return c;
  }

  test('ST-01 toJson → fromJson keeps the item; viewers are not stored', () {
    final s = StatusItemModel.fromJson(status(1));
    final back = StatusItemModel.fromJson(s.toJson());
    expect(back.id, 1);
    expect(back.content, 'hello 1');
    expect(back.creator?.name, 'Asha');
    expect(back.creator?.profilePic, 'https://x/y.jpg');
    expect(back.expiresAt, s.expiresAt);
    expect(back.viewers, isEmpty);
    expect(back.viewsCount, 1); // the count stays
  });

  test('ST-02 cached strip shows at once; expired items never show',
      () async {
    await AppCache.write(AppCache.statusFeed, [
      feedGroup(7, [status(1), status(2, expiresIn: const Duration(hours: -1))]),
      feedGroup(8, [status(3, expiresIn: const Duration(minutes: -5))]),
    ]);
    await AppCache.write(AppCache.statusMine, [
      status(10),
      status(11, expiresIn: const Duration(hours: -2)),
    ]);
    final c = await open();
    expect(c.contactGroups, hasLength(1)); // user 8 had only expired
    expect(c.contactGroups.single.statuses.map((s) => s.id), [1]);
    expect(c.myStatuses.map((s) => s.id), [10]);
  });

  test('ST-03 status:deleted removes it from UI and cache', () async {
    await AppCache.write(AppCache.statusFeed, [
      feedGroup(7, [status(1)])
    ]);
    final c = await open();
    c.onStatusDeletedReceived(1, 7);
    expect(c.contactGroups, isEmpty);
    await AppCache.flushPendingWrites();
    expect(await AppCache.read(AppCache.statusFeed), isEmpty);
  });

  test('ST-04 logout empties the permanent controllers at once', () async {
    await AppCache.write(AppCache.statusMine, [status(10)]);
    final c = await open();
    expect(c.myStatuses, isNotEmpty);
    final att = AttendanceController.instance;
    att.deletedPolls.add(5);
    await ChatMessageCache.clearAll(); // the existing logout call
    expect(c.myStatuses, isEmpty);
    expect(c.contactGroups, isEmpty);
    expect(att.deletedPolls, isEmpty);
  });

  test('ST-05 account switch: B never sees A\'s statuses', () async {
    await AppCache.write(AppCache.statusMine, [status(10)]);
    final c = await open();
    expect(c.myStatuses, isNotEmpty);
    await loginAs('202'); // no logout call (e.g. token replaced)
    c.ensureLoadedForCurrentUser();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(c.myStatuses, isEmpty);
  });
}
