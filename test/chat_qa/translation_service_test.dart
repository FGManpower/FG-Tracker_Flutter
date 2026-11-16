// QA tests for ChatTranslationService (lib/app/Data/Services/chat_translation_service.dart).
//
// The service calls the top-level `http.get`, which honours the zone client
// set by `http.runWithClient`. All network traffic is answered by a
// MockClient, so no real request leaves the test.
import 'dart:async';
import 'dart:convert';

import 'package:fgtracker/app/Data/Services/chat_translation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _translitHost = 'inputtools.google.com';
const _gtxHost = 'translate.googleapis.com';
const _dictHost = 'clients5.google.com';

String translitBody(List<String> words) => jsonEncode([
      'SUCCESS',
      [
        for (final w in words)
          [
            'x',
            [w]
          ]
      ]
    ]);

String gtxBody(List<String> segments) => jsonEncode([
      [
        for (final s in segments) [s, 'src', null, null]
      ]
    ]);

/// Routes by host. `null` handler for a host = HTTP 500.
class FakeApis {
  http.Response Function(Uri)? translit;
  http.Response Function(Uri)? gtx;
  http.Response Function(Uri)? dict;
  final List<Uri> calls = [];

  MockClient client() => MockClient((req) async {
        calls.add(req.url);
        http.Response Function(Uri)? h;
        switch (req.url.host) {
          case _translitHost:
            h = translit;
            break;
          case _gtxHost:
            h = gtx;
            break;
          case _dictHost:
            h = dict;
            break;
        }
        if (h == null) return http.Response('err', 500);
        return h(req.url);
      });

  List<String> get hosts => calls.map((u) => u.host).toList();
}

http.Response ok(String body) =>
    http.Response.bytes(utf8.encode(body), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChatTranslationService svc;
  late FakeApis apis;

  setUp(() {
    Get.testMode = true;
    svc = ChatTranslationService();
    apis = FakeApis();
  });

  tearDown(Get.reset);

  Future<String?> run(String id, String text, {String lang = 'hi'}) =>
      http.runWithClient(
        () => svc.translateText(id, text, targetLang: lang),
        apis.client,
      );

  group('input guards', () {
    test('empty text returns null and makes no request', () async {
      expect(await run('m1', ''), isNull);
      expect(apis.calls, isEmpty);
      expect(svc.isTranslating, isEmpty);
    });

    test('whitespace-only text returns null and makes no request', () async {
      expect(await run('m1', '   \n\t '), isNull);
      expect(apis.calls, isEmpty);
    });

    test('text is trimmed before it is sent', () async {
      apis.translit = (_) => ok(translitBody(['नमस्ते']));
      await run('m1', '   kaise ho   ');
      expect(apis.calls.single.queryParameters['text'], 'kaise ho');
    });

    test('special characters are URL-encoded and arrive intact', () async {
      apis.gtx = (_) => ok(gtxBody(['ok']));
      await run('m1', 'a&b=c?d #e', lang: 'en');
      expect(apis.calls.single.queryParameters['q'], 'a&b=c?d #e');
    });
  });

  group('endpoint chain (primary -> secondary -> fallback)', () {
    test('Hindi target: transliteration result wins, cache key id_lang',
        () async {
      apis.translit = (_) => ok(translitBody(['कैसे', 'हो']));
      final res = await run('m1', 'kaise ho');
      expect(res, 'कैसे हो');
      expect(svc.translations['m1_hi'], 'कैसे हो');
      expect(svc.showTranslated['m1_hi'], isTrue);
      expect(svc.isTranslating['m1'], isFalse);
      expect(apis.hosts, [_translitHost]);
    });

    test('transliteration HTTP 500 falls back to GTX', () async {
      apis.gtx = (_) => ok(gtxBody(['नमस्ते']));
      expect(await run('m1', 'hey there'), isNotNull);
      expect(apis.hosts, [_translitHost, _gtxHost]);
    });

    test('transliteration non-SUCCESS payload falls back to GTX', () async {
      apis.translit = (_) => ok(jsonEncode(['FAILED', []]));
      apis.gtx = (_) => ok(gtxBody(['परीक्षा']));
      expect(await run('m1', 'test'), 'परीक्षा');
    });

    test('transliteration throwing (socket error) falls back to GTX',
        () async {
      apis.translit = (_) => throw http.ClientException('offline');
      apis.gtx = (_) => ok(gtxBody(['ठीक']));
      expect(await run('m1', 'ok'), 'ठीक');
    });

    test('transliteration returning invalid JSON falls back to GTX', () async {
      apis.translit = (_) => ok('<html>captcha</html>');
      apis.gtx = (_) => ok(gtxBody(['ठीक']));
      expect(await run('m1', 'ok'), 'ठीक');
    });

    test('GTX failure falls back to dict-chrome (string form)', () async {
      apis.dict = (_) => ok(jsonEncode(['सुप्रभात']));
      expect(await run('m1', 'good morning'), 'सुप्रभात');
      expect(apis.hosts, [_translitHost, _gtxHost, _dictHost]);
    });

    test('dict-chrome nested-list form is parsed', () async {
      apis.dict = (_) => ok(jsonEncode([
            ['Good morning', 'hi']
          ]));
      expect(await run('m1', 'सुप्रभात', lang: 'en'), 'Good morning');
    });

    test('all endpoints fail: null, nothing cached, spinner cleared',
        () async {
      expect(await run('m1', 'hello'), isNull);
      expect(svc.translations, isEmpty);
      expect(svc.showTranslated, isEmpty);
      expect(svc.isTranslating['m1'], isFalse);
    });

    test('English target skips transliteration and starts at GTX', () async {
      apis.gtx = (_) => ok(gtxBody(['How are you']));
      expect(await run('m1', 'आप कैसे हैं', lang: 'en'), 'How are you');
      expect(apis.hosts, [_gtxHost]);
      expect(apis.calls.single.queryParameters['tl'], 'en');
      expect(apis.calls.single.queryParameters['sl'], 'auto');
    });

    test('GTX multi-segment response is concatenated', () async {
      apis.gtx = (_) => ok(gtxBody(['First sentence. ', 'Second one.']));
      expect(await run('m1', 'पहला वाक्य। दूसरा।', lang: 'en'),
          'First sentence. Second one.');
    });

    test('isTranslating is true while the request is in flight', () async {
      final gate = Completer<http.Response>();
      final client = MockClient((_) => gate.future);
      final fut = http.runWithClient(
          () => svc.translateText('m9', 'x', targetLang: 'en'), () => client);
      await Future<void>.delayed(Duration.zero);
      expect(svc.isTranslating['m9'], isTrue);
      gate.complete(ok(gtxBody(['y'])));
      await fut;
      expect(svc.isTranslating['m9'], isFalse);
    });

    testWidgets(
        'a hanging endpoint times out after 8s and the next one is tried',
        (tester) async {
      final client = MockClient((req) {
        if (req.url.host == _translitHost) {
          return Completer<http.Response>().future; // never answers
        }
        return Future.value(ok(gtxBody(['ठीक'])));
      });
      String? result;
      http.runWithClient(
          () => svc.translateText('m1', 'ok').then((r) => result = r),
          () => client);
      await tester.pump(const Duration(seconds: 7));
      expect(result, isNull);
      expect(svc.isTranslating['m1'], isTrue);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(result, 'ठीक');
    });
  });

  group('content kinds', () {
    test('greeting "hi ..." is rewritten to हाय (no punctuation)', () async {
      apis.gtx = (_) => ok(gtxBody(['नमस्ते दोस्त']));
      expect(await run('m1', 'hi friend'), 'हाय दोस्त');
    });

    test(
      'greeting rewrite keeps a single space after punctuation',
      () async {
        apis.gtx = (_) => ok(gtxBody(['नमस्ते, दोस्त']));
        expect(await run('m1', 'hi friend'), 'हाय दोस्त');
      },
      skip: 'BUG-TS-02: greeting regex eats "नमस्ते," but not the following '
          'space and inserts "हाय " -> "हाय  दोस्त" (double space) '
          '(chat_translation_service.dart:155-156, same for हैलो at 159-160)',
    );

    test('greeting "hello" is rewritten to हैलो', () async {
      apis.gtx = (_) => ok(gtxBody(['नमस्कार!']));
      expect(await run('m1', 'Hello'), 'हैलो');
    });

    test('emoji-only text is still sent to the network (no local skip)',
        () async {
      apis.gtx = (_) => ok(gtxBody(['😀👍']));
      expect(await run('m1', '😀👍'), '😀👍');
      expect(apis.calls, isNotEmpty);
    });

    test('URL-only text is sent as-is to the endpoints (no local skip)',
        () async {
      const url = 'https://example.com/a?b=1';
      apis.gtx = (_) => ok(gtxBody([url]));
      expect(await run('m1', url), url);
      expect(apis.calls.first.queryParameters['text'], url);
    });

    test('very long text (5000 chars) is sent in one GET, untruncated',
        () async {
      final long = List.filled(1000, 'abcd ').join().trim();
      apis.translit = (_) => ok(translitBody(['लंबा']));
      await run('m1', long);
      expect(apis.calls.single.queryParameters['text'], long);
      // URL is >5k chars: real Google endpoints may reject (414). Device check.
      expect(apis.calls.single.toString().length, greaterThan(5000));
    });
  });

  group('cache', () {
    test('second call is served from cache with no network', () async {
      apis.translit = (_) => ok(translitBody(['ठीक']));
      await run('m1', 'theek');
      svc.showTranslated['m1_hi'] = false;
      apis.calls.clear();
      expect(await run('m1', 'theek'), 'ठीक');
      expect(apis.calls, isEmpty);
      expect(svc.showTranslated['m1_hi'], isTrue);
    });

    test('cache entries are separate per target language', () async {
      apis.translit = (_) => ok(translitBody(['हिंदी']));
      apis.gtx = (_) => ok(gtxBody(['English']));
      await run('m1', 'text');
      await run('m1', 'text', lang: 'en');
      expect(svc.translations.keys, containsAll(['m1_hi', 'm1_en']));
      expect(svc.translations['m1_hi'], isNot(svc.translations['m1_en']));
    });

    test('resetVisibility hides cards but keeps cached translations',
        () async {
      apis.translit = (_) => ok(translitBody(['ठीक']));
      await run('m1', 'theek');
      svc.resetVisibility();
      expect(svc.showTranslated, isEmpty);
      expect(svc.translations['m1_hi'], 'ठीक');
    });

    test(
      'edited message text gets a fresh translation',
      () async {
        apis.translit = (u) => ok(translitBody([u.queryParameters['text']!]));
        await run('m1', 'old text');
        // Message m1 is edited (same id). Chat UI calls translateText again.
        final res = await run('m1', 'new edited text');
        expect(res, 'new edited text');
      },
      skip: 'BUG-TS-01: cache key is "<messageId>_<lang>" only and no public '
          'API removes an entry, so an edited message keeps showing the '
          'translation of its old text (chat_translation_service.dart:48-53, '
          '163; ChatItem.dart:460-468 uses the unchanged message id)',
    );

    test('documents the stale-cache behaviour that BUG-TS-01 describes',
        () async {
      apis.translit = (u) => ok(translitBody([u.queryParameters['text']!]));
      await run('m1', 'old text');
      apis.calls.clear();
      expect(await run('m1', 'new edited text'), 'old text');
      expect(apis.calls, isEmpty);
    });
  });

  group('swipe + visibility toggles', () {
    test('swipe on Latin text translates to Hindi', () async {
      apis.translit = (_) => ok(translitBody(['ठीक']));
      await http.runWithClient(
          () => svc.toggleForSwipe('m1', 'theek'), apis.client);
      expect(svc.translations.containsKey('m1_hi'), isTrue);
    });

    test('swipe on Devanagari text translates to English', () async {
      apis.gtx = (_) => ok(gtxBody(['Fine']));
      await http.runWithClient(
          () => svc.toggleForSwipe('m1', 'ठीक है'), apis.client);
      expect(svc.translations['m1_en'], 'Fine');
      expect(apis.hosts, [_gtxHost]);
    });

    test('second swipe only toggles visibility, no network', () async {
      apis.translit = (_) => ok(translitBody(['ठीक']));
      await http.runWithClient(
          () => svc.toggleForSwipe('m1', 'theek'), apis.client);
      apis.calls.clear();
      await http.runWithClient(
          () => svc.toggleForSwipe('m1', 'theek'), apis.client);
      expect(svc.showTranslated['m1_hi'], isFalse);
      await http.runWithClient(
          () => svc.toggleForSwipe('m1', 'theek'), apis.client);
      expect(svc.showTranslated['m1_hi'], isTrue);
      expect(apis.calls, isEmpty);
    });

    test('swipe on empty text is a no-op', () async {
      await http.runWithClient(
          () => svc.toggleForSwipe('m1', '  '), apis.client);
      expect(apis.calls, isEmpty);
      expect(svc.isTranslating, isEmpty);
    });

    test('toggleTranslationVisibility starts from hidden', () {
      svc.toggleTranslationVisibility('m2', targetLang: 'en');
      expect(svc.showTranslated['m2_en'], isTrue);
      svc.toggleTranslationVisibility('m2', targetLang: 'en');
      expect(svc.showTranslated['m2_en'], isFalse);
    });
  });
}
