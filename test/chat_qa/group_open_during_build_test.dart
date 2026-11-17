// Regression: opening a group (e.g. from a notification) while another chat
// is on screen crashed with "setState() or markNeedsBuild() called during
// build" (Obx / GroupChatScreen). The group controller is lazyPut, so it is
// created while GroupChatScreen builds; its onInit used to change other
// screens' Rx values (translation visibility, chat list unread) right then.
import 'dart:io';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Data/Services/chat_translation_service.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// T-07 (Run 2): `HttpOverrides.global = null` removed flutter_test's HTTP
/// mock, and the controller opened below calls the API, whose host is the
/// PRODUCTION constant (ConstRes.aBaseUrl). Only loopback is allowed now;
/// every other host goes to a dead proxy (connection refused).
class _LoopbackOnlyHttp extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..findProxy = (uri) =>
            (uri.host == '127.0.0.1' || uri.host == 'localhost')
                ? 'DIRECT'
                : 'PROXY 127.0.0.1:9';
}

void main() {
  setUp(() async {
    HttpOverrides.global = _LoopbackOnlyHttp();
    Get.reset();
    SharedPreferences.setMockInitialValues({
      PrefConst.userId: '1',
      PrefConst.STORAGE_USER_TOKEN_KEY: 'token-1',
    });
    Global.storageServices = await StorageServices().init();
    // Nothing listens here; the socket must not reach a real server.
    ConstRes.socketUrl = 'http://127.0.0.1:9';
  });

  tearDown(() {
    SocketMessageService.instance.disconnectAll();
    Get.reset();
    HttpOverrides.global = null;
  });

  testWidgets(
      'creating the group controller during a build does not mark another '
      'Obx dirty (no "markNeedsBuild called during build")', (t) async {
    Get.lazyPut<GroupMessageController>(() => GroupMessageController());
    final translations = ChatTranslationService.instance;
    var openGroup = false;
    late StateSetter setOuter;

    await t.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, setState) {
        setOuter = setState;
        return Column(children: [
          // A chat screen behind: its bubbles watch translation visibility.
          Obx(() => Text('translated: ${translations.showTranslated.length}')),
          if (openGroup)
            Builder(builder: (_) {
              // Same as GroupChatScreen (GetView + lazyPut): the controller
              // is created inside build.
              final c = Get.find<GroupMessageController>();
              return Text('group ${c.groupId}');
            }),
        ]);
      }),
    ));

    setOuter(() => openGroup = true);
    await t.pump();
    expect(t.takeException(), isNull);
    expect(find.text('group 0'), findsOneWidget);

    // The deferred part (translation reset, chat-list unread, sockets) ran
    // after the frame.
    await t.pump();
    expect(t.takeException(), isNull);
    Get.delete<GroupMessageController>(force: true);
    SocketMessageService.instance.disconnectAll();
    // Let debounce / socket timers started by the controller finish.
    await t.pump(const Duration(minutes: 1));
  });
}
