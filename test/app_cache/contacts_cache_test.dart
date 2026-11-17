// New-chat contacts (FG users of the phonebook) on the app cache, and the
// account-switch fix for the static session cache (doc 07 §3.2).
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Messages/Controller/newChat_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

UserListData user(int id, String name) =>
    UserListData(userId: id, name: name, mobileNo: '98765432$id');

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
    NewChatController.clearCache();
    await loginAs(AppCacheTestEnv.me);
  });

  tearDown(() async {
    // Close controllers (onClose) so none of them writes into the next
    // test's cache; Get.reset alone keeps them alive.
    await Get.deleteAll(force: true);
    Get.reset();
    NewChatController.clearCache();
    await env.dispose();
  });

  test('CT-01 saved FG users show at once; offline keeps them + retry flag',
      () async {
    await AppCache.write(AppCache.fgContacts,
        [user(1, 'Asha').toJson(), user(2, 'Ravi').toJson()]);
    final c = Get.put(NewChatController(autoLoad: false));
    await c.getRegisteredContacts(); // phonebook / API unavailable in tests
    expect(c.matchedUsers.map((u) => u.name), ['Asha', 'Ravi']);
    expect(c.refreshFailed.value, isTrue);
    expect(c.responseError.value, isEmpty); // no full-screen error
    expect(c.contactLoading.value, isFalse);
  });

  test('CT-02 no saved list + offline → the existing error view', () async {
    final c = Get.put(NewChatController(autoLoad: false));
    await c.getRegisteredContacts();
    expect(c.matchedUsers, isEmpty);
    expect(c.responseError.value, isNotEmpty);
  });

  test('CT-03 account switch: B never sees A\'s session or saved contacts',
      () async {
    NewChatController.debugSeedSessionCache([user(1, 'A-contact')], '101');
    await AppCache.write(AppCache.fgContacts, [user(1, 'A-contact').toJson()]);
    await loginAs('202');
    final c = Get.put(NewChatController(autoLoad: false));
    await c.getRegisteredContacts();
    expect(c.matchedUsers, isEmpty);
  });

  test('CT-04 the same user still gets the session cache instantly',
      () async {
    NewChatController.debugSeedSessionCache([user(1, 'Mine')], '101');
    final c = Get.put(NewChatController(autoLoad: false));
    await c.getRegisteredContacts();
    expect(c.matchedUsers.single.name, 'Mine');
  });
}
