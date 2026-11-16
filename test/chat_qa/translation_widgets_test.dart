// QA widget tests for lib/app/modules/Messages/widgets/chat_translation_widgets.dart
// (translated card under a received bubble + Listen / Translating row).
import 'package:fgtracker/app/Data/Services/chat_translation_service.dart';
import 'package:fgtracker/app/modules/Messages/widgets/chat_translation_widgets.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget host(Widget child) => ScreenUtilInit(
      // Wide design size: the test font (Ahem) draws every glyph 1em wide,
      // which overflows the card's header Row at 375dp. Real fonts fit.
      designSize: const Size(750, 1624),
      builder: (_, __) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  late ChatTranslationService svc;

  setUp(() {
    Get.testMode = true;
    svc = ChatTranslationService.instance;
  });

  tearDown(Get.reset);

  group('ChatTranslatedCard', () {
    testWidgets('Hindi target: header, text, Listen (Hindi)', (tester) async {
      await tester.pumpWidget(host(ChatTranslatedCard(
        messageId: 'm1',
        translatedText: 'कैसे हो',
        onToggleOriginal: () {},
      )));
      expect(find.text('Translated to Hindi'), findsOneWidget);
      expect(find.text('कैसे हो'), findsOneWidget);
      expect(find.text('Listen (Hindi)'), findsOneWidget);
      expect(find.text('Show Original'), findsOneWidget);
    });

    testWidgets('English target: header + Listen (English)', (tester) async {
      await tester.pumpWidget(host(ChatTranslatedCard(
        messageId: 'm1',
        translatedText: 'How are you',
        targetLang: 'en',
        onToggleOriginal: () {},
      )));
      expect(find.text('Translated to English'), findsOneWidget);
      expect(find.text('Listen (English)'), findsOneWidget);
    });

    testWidgets('"Show Original" fires the callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(ChatTranslatedCard(
        messageId: 'm1',
        translatedText: 'x',
        onToggleOriginal: () => taps++,
      )));
      await tester.tap(find.text('Show Original'));
      expect(taps, 1);
    });

    testWidgets('shows Stop while its audio id (id_lang) is playing',
        (tester) async {
      await tester.pumpWidget(host(ChatTranslatedCard(
        messageId: 'm1',
        translatedText: 'x',
        onToggleOriginal: () {},
      )));
      svc.currentlyPlayingId.value = 'm1_hi';
      await tester.pump();
      expect(find.text('Stop (Hindi)'), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);
      svc.currentlyPlayingId.value = 'other_hi';
      await tester.pump();
      expect(find.text('Listen (Hindi)'), findsOneWidget);
    });

    testWidgets('shows a spinner while its TTS audio is loading',
        (tester) async {
      await tester.pumpWidget(host(ChatTranslatedCard(
        messageId: 'm1',
        translatedText: 'x',
        onToggleOriginal: () {},
      )));
      svc.currentlyPlayingId.value = 'm1_hi';
      svc.isAudioLoading.value = true;
      await tester.pump();
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });
  });

  group('ChatMessageActionRow', () {
    testWidgets('empty / whitespace text renders nothing', (tester) async {
      await tester.pumpWidget(host(const ChatMessageActionRow(
          messageId: 'm1', originalText: '   ', isSentByMe: false)));
      expect(find.text('Listen'), findsNothing);
    });

    testWidgets('idle row shows only Listen (translate link removed)',
        (tester) async {
      await tester.pumpWidget(host(const ChatMessageActionRow(
          messageId: 'm1', originalText: 'hello', isSentByMe: false)));
      expect(find.text('Listen'), findsOneWidget);
      expect(find.text('Translating...'), findsNothing);
    });

    testWidgets('shows "Translating..." while the swipe request runs',
        (tester) async {
      await tester.pumpWidget(host(const ChatMessageActionRow(
          messageId: 'm1', originalText: 'hello', isSentByMe: false)));
      svc.isTranslating['m1'] = true;
      svc.isTranslating.refresh();
      await tester.pump();
      expect(find.text('Translating...'), findsOneWidget);
    });

    testWidgets('row hides while the translated card is showing',
        (tester) async {
      svc.translations['m1_hi'] = 'हेलो';
      svc.showTranslated['m1_hi'] = true;
      await tester.pumpWidget(host(const ChatMessageActionRow(
          messageId: 'm1', originalText: 'hello', isSentByMe: false)));
      expect(find.text('Listen'), findsNothing);
      svc.toggleTranslationVisibility('m1'); // "Show Original"
      await tester.pump();
      expect(find.text('Listen'), findsOneWidget);
    });

    testWidgets('Hindi original uses the _en cache key', (tester) async {
      svc.translations['m1_en'] = 'Hello';
      svc.showTranslated['m1_en'] = true;
      await tester.pumpWidget(host(const ChatMessageActionRow(
          messageId: 'm1', originalText: 'नमस्ते', isSentByMe: false)));
      expect(find.text('Listen'), findsNothing);
    });

    testWidgets('original Listen shows Stop for "<id>_orig"', (tester) async {
      await tester.pumpWidget(host(const ChatMessageActionRow(
          messageId: 'm1', originalText: 'hello', isSentByMe: false)));
      svc.currentlyPlayingId.value = 'm1_orig';
      await tester.pump();
      expect(find.text('Stop'), findsOneWidget);
    });
  });
}
