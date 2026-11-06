import 'dart:io';
import 'dart:typed_data';

import 'package:fgtracker/app/modules/Messages/widgets/ChatInputArea.dart';
import 'package:fgtracker/app/modules/Messages/widgets/chat_history_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget _app(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(home: child),
    );

/// Same structure as Chat_Screen / GroupChatScreen: Scaffold that resizes for
/// the keyboard, message list in an Expanded, the real ChatInputArea below.
Widget _chatLayout() {
  return _app(
    Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => ListTile(title: Text('message $i')),
              ),
            ),
            ChatInputArea(
              messageText: ''.obs,
              imagePath: <File>[].obs,
              videoPaths: <String>[].obs,
              documentPath: ''.obs,
              isSending: false.obs,
              textController: TextEditingController(),
              onSend: () {},
              onContactSelected: () {},
              onImageSelected: (_) {},
              onVideosSelected: (_) {},
              onDocumentSelected: (_) {},
              onVoiceSend: (_) {},
              videoThumbnails: <Uint8List?>[].obs,
              videoDurations: <String>[].obs,
              isUploadingVideo: false.obs,
              uploadProgress: 0.0.obs,
              onLocationSelected: () {},
              uploadingVideoIndexes: <int>{}.obs,
              videoUploadProgress: <int, double>{}.obs,
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('top loader shows only while an older page loads', (t) async {
    await t.pumpWidget(_app(const Scaffold(
      body: Stack(children: [ChatHistoryTopLoader(visible: true)]),
    )));
    expect(find.byKey(const ValueKey('chat_history_top_loader')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await t.pumpWidget(_app(const Scaffold(
      body: Stack(children: [ChatHistoryTopLoader(visible: false)]),
    )));
    // Settles: no hidden spinner left animating.
    await t.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('load failure shows Retry, not "No messages"', (t) async {
    var retried = 0;
    await t.pumpWidget(_app(Scaffold(
      body: ChatHistoryErrorState(onRetry: () => retried++),
    )));
    expect(find.text("Couldn't load messages"), findsOneWidget);
    expect(find.text('No messages here yet'), findsNothing);
    await t.tap(find.byKey(const ValueKey('chat_history_retry')));
    expect(retried, 1);
  });

  group('input bar with the keyboard open', () {
    for (final size in const [Size(360, 640), Size(430, 932)]) {
      testWidgets('stays above a 300px keyboard on ${size.width}x${size.height}',
          (t) async {
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = size;
        t.view.padding = const FakeViewPadding(top: 24, bottom: 34);
        t.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
        addTearDown(t.view.reset);

        await t.pumpWidget(_chatLayout());
        await t.pump();

        t.view.viewInsets = const FakeViewPadding(bottom: 300);
        await t.pump();

        final field = t.getRect(find.byType(TextField));
        expect(field.bottom, lessThanOrEqualTo(size.height - 300),
            reason: 'input must sit above the keyboard');
        expect(field.top, greaterThan(0));
        expect(t.takeException(), isNull, reason: 'no overflow');
      });
    }

    testWidgets('keeps clear of the home indicator with the keyboard closed',
        (t) async {
      const size = Size(390, 844);
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = size;
      t.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      t.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(t.view.reset);

      await t.pumpWidget(_chatLayout());
      await t.pump();

      final field = t.getRect(find.byType(TextField));
      expect(field.bottom, lessThanOrEqualTo(size.height - 34));
      expect(t.takeException(), isNull);
    });

    testWidgets('large font scale does not overflow', (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = const Size(360, 640);
      t.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);

      await t.pumpWidget(_chatLayout());
      t.view.viewInsets = const FakeViewPadding(bottom: 280);
      await t.pump();

      expect(t.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
