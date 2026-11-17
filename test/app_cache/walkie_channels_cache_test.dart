// Walkie channel list on the app cache (doc 07 §3.7): live speaker state is
// never cached; offline keeps the list.
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Model/walkie_channel_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_channel_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

Map<String, dynamic> channel(int id, {bool speaking = false}) => {
      'groupId': id,
      'groupName': 'Team $id',
      'memberCount': 4,
      'isSelectedChannel': false,
      'notificationsEnabled': id == 1,
      'isChannelSpeaking': speaking,
      'activeSpeakerId': speaking ? 9 : null,
      'activeSpeakerName': speaking ? 'Ravi' : null,
      'isOnline': true,
    };

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

  Future<WalkieChannelController> open() async {
    final c = Get.put(WalkieChannelController());
    // Wait for the (failing) API call of onInit to finish (max 12 s).
    for (var i = 0;
        i < 120 && !c.refreshFailed.value && c.errorMessage.value.isEmpty;
        i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return c;
  }

  test('WK-01 cached channels show; offline keeps them + retry flag',
      () async {
    await AppCache.write(
        AppCache.walkieChannels, [channel(1), channel(2)]);
    final c = await open();
    expect(c.channels.map((ch) => ch.groupId), [1, 2]);
    expect(c.refreshFailed.value, isTrue);
    expect(c.errorMessage.value, isEmpty);
  });

  test('WK-02 live "speaking" state is never saved', () async {
    await AppCache.write(AppCache.walkieChannels, [channel(1)]);
    final c = await open();
    c.channels.assignAll([WalkieChannelItem.fromJson(channel(1, speaking: true))]);
    await AppCache.flushPendingWrites();
    final saved = (await AppCache.read(AppCache.walkieChannels)).single;
    expect(saved['isChannelSpeaking'], isFalse);
    expect(saved['activeSpeakerName'], isNull);
    expect(saved['isOnline'], isFalse);
    expect(saved['groupName'], 'Team 1');
  });
}
