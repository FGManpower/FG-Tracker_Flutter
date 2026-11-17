// Notifications on the app cache (doc 07 §3.8) and SC-07 (open / close a
// cached screen many times: listeners once, an event handled once).
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Model/notification_model.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_cache_codec.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_cache_test_support.dart';

Map<String, dynamic> note(int id, {bool read = false}) => NotificationModel(
      id: id,
      title: 'Title $id',
      body: 'Body $id',
      type: 'chat',
      createdAt: '2026-11-17T10:00:00Z',
      isRead: read,
      data: {'screen_name': 'chat'},
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

  Future<NotificationController> open() async {
    final c = Get.put(NotificationController());
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return c;
  }

  test('NT-01 NotificationModel round trip keeps data', () {
    final back = NotificationModel.fromJson(note(3));
    expect(back.id, 3);
    expect(back.title, 'Title 3');
    expect(back.isRead, isFalse);
    expect(back.data?['screen_name'], 'chat');
  });

  test('NT-02 cached notifications show at once', () async {
    await AppCache.write(AppCache.notifications, [note(1), note(2)]);
    final c = await open();
    expect(c.filteredNotifications.map((n) => n.id), [1, 2]);
  });

  test('NT-03 offline: list stays + retry flag, never "no notifications"',
      () async {
    await AppCache.write(AppCache.notifications, [note(1)]);
    final c = await open();
    await c.getNotifications(); // no server
    expect(c.notifications, hasLength(1));
    expect(c.refreshFailed.value, isTrue);
    expect(c.responseError.value, isEmpty);
    expect(c.isLoading.value, isFalse);
  });

  test('NT-04 read flag / clear-all are written through', () async {
    await AppCache.write(AppCache.notifications, [note(1), note(2)]);
    final c = await open();
    c.notifications.first.isRead = true;
    c.notifications.refresh();
    await AppCache.flushPendingWrites();
    expect((await AppCache.read(AppCache.notifications)).first['isRead'],
        isTrue);
    c.notifications.clear(); // what "clear all" does after the server OK
    await AppCache.flushPendingWrites();
    expect(await AppCache.read(AppCache.notifications), isEmpty);
  });

  test('SC-07 open / close 10×: one logout listener, one event → one row',
      () async {
    Get.put(StatusSocketService(), permanent: true);
    final before = AppCache.logoutListenerCount;
    for (var i = 0; i < 10; i++) {
      Get.put(StatusFeedController(), permanent: true);
      await Get.delete<StatusFeedController>(force: true);
    }
    expect(AppCache.logoutListenerCount, before);

    ChatListController? c;
    for (var i = 0; i < 10; i++) {
      final put = Get.put(ChatListController());
      c = put;
      await put.debugShowCachedChatList();
      if (i < 9) await Get.delete<ChatListController>(force: true);
    }
    c!.debugHandleChatUpdated({
      'id': 1,
      'chatId': 1,
      'userId': 5,
      'name': 'Asha',
      'chatType': 'private',
      'lastMessage': {
        'id': 1,
        'content': 'hi',
        'messageType': 'text',
        'senderId': '5',
        'timestamp': '2026-11-17T10:00:00Z'
      },
    });
    expect(c.privateChats, hasLength(1));
    await AppCache.flushPendingWrites();
    final saved = await AppCache.readAs<PrivateChatModel>(
        AppCache.chatList, ChatListCacheCodec.decode);
    expect(saved, hasLength(1));
  });
}
