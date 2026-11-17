// "X left" system message in an open (archived) group chat: the app-level
// groupMemberChanges stream tells the open group to fetch newer messages.
// Doc 01 §2.7. Pure Dart, same on Android and iOS.
import 'dart:async';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_socket_io_server.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSocketIoServer server;
  late SocketMessageService svc;
  late List<int> changes;
  late StreamSubscription sub;

  setUp(() async {
    HttpOverrides.global = null;
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: '101',
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
    });
    Global.storageServices = await StorageServices().init();
    server = FakeSocketIoServer();
    await server.start();
    svc = SocketMessageService();
    changes = [];
    sub = svc.groupMemberChanges.listen(changes.add);
    svc.ensureChatSocket(server.url, userId: '101');
    expect(await waitFor(() => svc.isSocketConnected), isTrue);
  });

  tearDown(() async {
    await sub.cancel();
    svc.disconnectAll();
    await server.stop();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 200));

  test('GML-01 member_left / member_removed / group_left report the group',
      () async {
    server.emit('/chat', 'member_left', {'groupId': 12, 'userId': 7});
    server.emit('/chat', 'member_removed', {'group_id': '13', 'userId': 8});
    server.emit('/chat', 'group_left', {'groupId': 14, 'userId': 101});
    await settle();
    expect(changes, [12, 13, 14]);
  });

  test('GML-02 other events and payloads without a group id are ignored',
      () async {
    server.emit('/chat', 'receive_group_message', {'groupId': 12});
    server.emit('/chat', 'member_left', {'userId': 7});
    server.emit('/chat', 'member_left', 'oops');
    await settle();
    expect(changes, isEmpty);
  });

  test('GML-03 still works after old code calls off(event) without a handler',
      () async {
    // Chat list + group screen register these with off(ev) / on(ev).
    svc.listenGroupExit(callback: (_) {});
    svc.listenMemberRemoved(callback: (_) {});
    server.emit('/chat', 'member_left', {'groupId': 12, 'userId': 7});
    server.emit('/chat', 'member_removed', {'groupId': 12, 'userId': 7});
    await settle();
    expect(changes, [12, 12]);
  });
}
