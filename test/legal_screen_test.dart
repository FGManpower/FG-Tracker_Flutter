import 'dart:io';

import 'package:fgtracker/app/modules/Legal/Views/legal_document_screen.dart';
import 'package:fgtracker/app/modules/Legal/Views/legal_screen.dart';
import 'package:fgtracker/app/modules/Legal/legal_documents.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Phone-sized surface (375×812) so ScreenUtil and layout agree.
void _phone(WidgetTester tester, {Size size = const Size(375, 812)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _app({
  Widget? home,
  String? initialRoute,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Brightness brightness = Brightness.light,
}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        locale: locale,
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
        initialRoute: home == null ? initialRoute : null,
        getPages: [
          GetPage(name: Routes.Legal, page: () => const LegalScreen()),
          GetPage(
            name: Routes.LegalDocument,
            page: () => const LegalDocumentScreen(),
          ),
        ],
      ),
    );

/// Serves fixed Markdown for every asset path.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.text);
  final String text;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(text.codeUnits));

  @override
  Future<String> loadString(String key, {bool cache = true}) async => text;
}

class _FailingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => throw FlutterError('missing $key');

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      throw FlutterError('missing $key');
}

final _sampleMarkdown = '''
# Sample Policy

Intro paragraph with **bold text** and a [link](https://example.com).

## 1. Section

- First bullet
- Second bullet

1. Step one
2. Step two

| Column A | Column B | Column C | Column D |
|---|---|---|---|
| a long cell value that must wrap inside the cell | b | c | d |

${'Paragraph line for scrolling.\n\n' * 40}
LAST LINE OF THE DOCUMENT
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(Get.reset);

  final en = lookupAppLocalizations(const Locale('en'));

  group('Legal config + assets', () {
    test('has the 6 documents in the required order', () {
      expect(legalDocuments, hasLength(6));
      expect(legalDocuments.map((d) => d.assetPath).toList(), [
        'assets/legal/01_global_privacy_policy.md',
        'assets/legal/02_terms_and_eula.md',
        'assets/legal/03_enterprise_service_agreement.md',
        'assets/legal/04_data_processing_agreement.md',
        'assets/legal/05_data_retention_and_deletion_policy.md',
        'assets/legal/06_data_protection_and_information_security_policy.md',
      ]);
      expect(legalDocuments.map((d) => d.title(en)).toList(), [
        'Privacy Policy',
        'Terms & Conditions (EULA)',
        'Enterprise Service Agreement',
        'Data Processing Agreement',
        'Data Retention & Deletion Policy',
        'Data Protection & Information Security Policy',
      ]);
    });

    test('ids and asset paths are unique, lookup by id works', () {
      expect(legalDocuments.map((d) => d.id).toSet(), hasLength(6));
      expect(legalDocuments.map((d) => d.assetPath).toSet(), hasLength(6));
      for (final d in legalDocuments) {
        expect(legalDocumentById(d.id), same(d));
      }
      expect(legalDocumentById('nope'), isNull);
      expect(legalDocumentById(null), isNull);
    });

    test('assets/legal/ is registered in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/legal/'));
    });

    test('all 6 asset files exist and load from the asset bundle', () async {
      for (final d in legalDocuments) {
        expect(File(d.assetPath).existsSync(), isTrue,
            reason: '${d.assetPath} is missing on disk');
        // Throws if the file is not bundled.
        // cache: false so this real-async load is not reused by widget tests.
        final text = await rootBundle.loadString(d.assetPath, cache: false);
        expect(text, isA<String>());
      }
    });

    test('every language has all Legal strings, none empty', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final l = lookupAppLocalizations(locale);
        final values = [
          l.legal_title,
          l.legal_menuSubtitle,
          l.legal_draftNotice,
          l.legal_emptyDocument,
          l.legal_loadError,
          for (final d in legalDocuments) ...[d.title(l), d.subtitle(l)],
        ];
        for (final v in values) {
          expect(v.trim(), isNotEmpty, reason: 'empty string in $locale');
        }
      }
    });
  });

  group('Legal screen', () {
    testWidgets('shows the draft note and 6 items with subtitles',
        (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(home: const LegalScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Legal'), findsOneWidget);
      expect(find.byKey(const ValueKey('legal_draft_notice')),
          showLegalDraftNotice ? findsOneWidget : findsNothing);
      if (showLegalDraftNotice) {
        expect(find.text('These documents are drafts and may change.'),
            findsOneWidget);
      }
      for (final d in legalDocuments) {
        await tester.scrollUntilVisible(find.text(d.title(en)), 80);
        expect(find.text(d.title(en)), findsOneWidget);
        expect(find.text(d.subtitle(en)), findsOneWidget);
      }
    });

    test('website links and contacts match fgtracker.fgmanpower.com', () {
      expect(legalDocuments.map((d) => d.websiteUrl).toList(), [
        'https://fgtracker.fgmanpower.com/privacy-policy/',
        'https://fgtracker.fgmanpower.com/terms/',
        'https://fgtracker.fgmanpower.com/enterprise-service-agreement/',
        'https://fgtracker.fgmanpower.com/data-processing-agreement/',
        'https://fgtracker.fgmanpower.com/data-retention-policy/',
        'https://fgtracker.fgmanpower.com/information-security-policy/',
      ]);
      final byId = {for (final c in legalContacts) c.id: c};
      expect(byId.keys, ['phone', 'email', 'address', 'website']);
      expect(byId['phone']!.uri, 'tel:+919372723727');
      expect(byId['email']!.uri, 'mailto:fgtracker@fgmanpower.com');
      expect(Uri.parse(byId['address']!.uri).queryParameters['query'],
          byId['address']!.value);
      expect(byId['website']!.uri, 'https://fgtracker.fgmanpower.com/');
    });

    testWidgets('tapping each document opens its link',
        (tester) async {
      _phone(tester);
      final opened = <Uri>[];
      await tester.pumpWidget(_app(
        home: LegalScreen(launcher: (uri) async {
          opened.add(uri);
          return true;
        }),
      ));
      await tester.pumpAndSettle();

      final keys = [
        for (final d in legalDocuments) 'legal_row_${d.id}',
      ];
      for (final k in keys) {
        final row = find.byKey(ValueKey(k));
        await tester.scrollUntilVisible(row, 80);
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        await tester.tap(row);
        await tester.pumpAndSettle();
      }

      expect(opened.map((u) => u.toString()).toList(), [
        for (final d in legalDocuments) d.websiteUrl,
      ]);
      // Opens outside the app; the in-app document screen is not pushed.
      expect(find.byType(LegalDocumentScreen), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a link that cannot open shows a message', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(
        home: LegalScreen(launcher: (_) async => false),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('legal_row_privacy_policy')));
      await tester.pumpAndSettle();
      expect(find.text(en.legal_loadError), findsOneWidget);
    });

    testWidgets('no overflow at large font size, small phone', (tester) async {
      _phone(tester, size: const Size(320, 568));
      await tester.pumpWidget(_app(home: const LegalScreen(), textScale: 2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final locale in const [Locale('hi'), Locale('mr'), Locale('ar')]) {
      testWidgets('$locale + dark mode + large font render without errors',
          (tester) async {
        _phone(tester);
        final l = lookupAppLocalizations(locale);
        await tester.pumpWidget(_app(
          home: const LegalScreen(),
          locale: locale,
          brightness: Brightness.dark,
          textScale: 1.5,
        ));
        await tester.pumpAndSettle();
        expect(find.text(l.legal_title), findsOneWidget);
        expect(find.text(legalDocuments.first.title(l)), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Legal document screen', () {
    testWidgets('renders Markdown: headings, lists, bold, table',
        (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(
        home: LegalDocumentScreen(
          document: legalDocuments.first,
          bundle: _FakeBundle(_sampleMarkdown),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Markdown), findsOneWidget);
      expect(find.byType(Table), findsOneWidget);
      // Table sits in a horizontal scroll view, so it can't overflow.
      expect(
        find.ancestor(
          of: find.byType(Table),
          matching: find.byWidgetPredicate((w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Sample Policy', findRichText: true),
          findsWidgets);
      expect(find.textContaining('First bullet', findRichText: true),
          findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('document scrolls to the end', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(
        home: LegalDocumentScreen(
          document: legalDocuments.last,
          bundle: _FakeBundle(_sampleMarkdown),
        ),
      ));
      await tester.pumpAndSettle();

      final last = find.textContaining('LAST LINE OF THE DOCUMENT',
          findRichText: true);
      await tester.scrollUntilVisible(
        last,
        300,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('legal_markdown')),
          matching: find.byType(Scrollable),
        ).first,
      );
      expect(last, findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('large font + dark mode: no overflow', (tester) async {
      _phone(tester, size: const Size(320, 568));
      await tester.pumpWidget(_app(
        home: LegalDocumentScreen(
          document: legalDocuments.last,
          bundle: _FakeBundle(_sampleMarkdown),
        ),
        textScale: 2.0,
        brightness: Brightness.dark,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty file shows the "not available yet" message',
        (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(
        home: LegalDocumentScreen(
          document: legalDocuments.first,
          bundle: _FakeBundle('   \n'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(en.legal_emptyDocument), findsOneWidget);
      expect(find.byType(Markdown), findsNothing);
    });

    testWidgets('missing asset shows an error with Retry', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(
        home: LegalDocumentScreen(
          document: legalDocuments.first,
          bundle: _FailingBundle(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(en.legal_loadError), findsOneWidget);
      expect(find.text(en.common_retry), findsOneWidget);
    });

    testWidgets('unknown route argument shows the error, no crash',
        (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(initialRoute: Routes.Legal));
      await tester.pumpAndSettle();
      Get.toNamed(Routes.LegalDocument, arguments: 'unknown-id');
      await tester.pumpAndSettle();
      expect(find.text(en.legal_loadError), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
