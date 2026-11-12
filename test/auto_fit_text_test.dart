import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double width = 120}) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: 40, child: child),
        ),
      ),
    );

void main() {
  testWidgets('text that fits keeps its normal size', (tester) async {
    await tester.pumpWidget(
        _host(const AutoFitText('OK', style: TextStyle(fontSize: 16))));
    expect(tester.widget<Text>(find.text('OK')).style?.fontSize, 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long text in a narrow box shrinks instead of overflowing',
      (tester) async {
    await tester.pumpWidget(_host(
        const AutoFitText('रिपोर्ट डाउनलोड करें',
            style: TextStyle(fontSize: 16)),
        width: 120));
    expect(tester.takeException(), isNull);
    // Rendered narrower than the box, i.e. scaled down.
    final rect = tester.getRect(find.text('रिपोर्ट डाउनलोड करें'));
    expect(rect.width, lessThanOrEqualTo(120.01));
    // Natural width is wider than the box, so it was scaled down to fit.
    final natural = tester.renderObject<RenderBox>(find.text('रिपोर्ट डाउनलोड करें')).size.width;
    expect(natural, greaterThan(120));
  });

  testWidgets('inside a Row with Flexible: no overflow', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 160,
          child: Row(children: [
            Icon(Icons.translate),
            SizedBox(width: 8),
            Flexible(
              child: AutoFitText('ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ ಮತ್ತು ಮುಂದುವರಿಸಿ',
                  style: TextStyle(fontSize: 15)),
            ),
          ]),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('safe in a popup menu and an AlertDialog (intrinsic sizing)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(children: [
            PopupMenuButton<int>(
              key: const Key('menu'),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 1,
                  child: Row(children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Flexible(
                        child: AutoFitText(
                            'വാക്കി-ടോക്കിയിൽ നിന്ന് പുറത്തുകടക്കുക')),
                  ]),
                ),
              ],
            ),
            TextButton(
              key: const Key('dialog'),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const AutoFitText('அமைப்புகளைத் திறக்கவும்'),
                  actions: [
                    TextButton(
                        onPressed: () {},
                        child: const AutoFitText('ரத்துசெய்')),
                  ],
                ),
              ),
              child: const Text('open'),
            ),
          ]),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('menu')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dialog')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('maxLines 2 wraps and ellipsizes', (tester) async {
    await tester.pumpWidget(_host(
        const AutoFitText('one two three four five six seven eight',
            maxLines: 2),
        width: 80));
    expect(tester.widget<Text>(find.byType(Text)).maxLines, 2);
    expect(tester.takeException(), isNull);
  });
}
