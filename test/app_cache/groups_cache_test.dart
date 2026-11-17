// All Groups on the app cache (doc 07 §3.3).
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

Map<String, dynamic> group(int id, {bool creator = false}) => GroupsResData(
      id: id,
      groupName: 'Group $id',
      groupCode: 'C$id',
      isActive: true,
      isCreator: creator,
      memberCount: 3,
    ).toJson();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppCacheTestEnv env;

  setUp(() async {
    Get.reset();
    env = await AppCacheTestEnv.create();
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

  Future<GroupController> open() async {
    final c = Get.put(GroupController());
    // Let the async cache read in onInit finish.
    for (var i = 0; i < 20 && c.groupData.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    return c;
  }

  test('GR-01 GroupsResData round trip keeps every shown field', () {
    final back = GroupsResData.fromJson(group(5, creator: true));
    expect(back.id, 5);
    expect(back.groupName, 'Group 5');
    expect(back.isCreator, isTrue);
    expect(back.memberCount, 3);
  });

  test('GR-02 cached groups show at once', () async {
    await AppCache.write(AppCache.groups, [group(1), group(2)]);
    final c = await open();
    expect(c.groupData.map((g) => g.id), [1, 2]);
  });

  test('GR-03 offline: groups stay, retry flag, no full-screen error',
      () async {
    await AppCache.write(AppCache.groups, [group(1)]);
    final c = await open();
    await c.getGroupData(); // no server
    expect(c.groupData, hasLength(1));
    expect(c.refreshFailed.value, isTrue);
    expect(c.responseError.value, isEmpty);
    expect(c.groupDataLoading.value, isFalse);
  });

  test('GR-04 no cache + offline: the existing error view', () async {
    final c = await open();
    await c.getGroupData();
    expect(c.responseError.value, isNotEmpty);
  });

  test('GR-05 a change (e.g. leave → removeWhere) is written through',
      () async {
    await AppCache.write(AppCache.groups, [group(1), group(2)]);
    final c = await open();
    c.groupData.removeWhere((g) => g.id == 1);
    await AppCache.flushPendingWrites();
    expect((await AppCache.read(AppCache.groups)).map((m) => m['id']), [2]);
  });

  test('GR-06 live data that arrived first is not replaced by the cache',
      () async {
    await AppCache.write(AppCache.groups, [group(1)]);
    final c = Get.put(GroupController());
    c.groupData.assignAll([GroupsResData.fromJson(group(9))]);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(c.groupData.map((g) => g.id), [9]);
  });
}
