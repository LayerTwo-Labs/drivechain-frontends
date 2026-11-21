import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _long =
    'PM8TJTLJbPRGxSbc8EJi42Wrr6QbNSaSSVJ5Y3E4pbCYiTHUskHg13935Ubb7q8tx9GVbh2UuRnBc3WSyJHhUrw8KhprKnn9eDznYGieTzFcwQRya4GA';

Widget _field({Widget? bottomWidget, bool alignSuffixTop = false}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 340,
            child: SailTextField(
              controller: TextEditingController(text: _long),
              hintText: '',
              minLines: 1,
              maxLines: null,
              suffixWidget: const SizedBox(key: Key('suffix'), width: 24, height: 32),
              bottomWidget: bottomWidget,
              alignSuffixTop: alignSuffixTop,
            ),
          ),
        ),
      ),
    ),
  );
}

Rect _rect(WidgetTester tester, Finder finder) => tester.getRect(finder);

void main() {
  testWidgets('a bottom row sits inside the box, under the text', (tester) async {
    await tester.pumpWidget(_field(bottomWidget: const SizedBox(key: Key('tools'), height: 20, width: 100)));

    final text = _rect(tester, find.byType(EditableText));
    final tools = _rect(tester, find.byKey(const Key('tools')));
    final box = _rect(tester, find.byType(SailTextField));
    expect(tools.top, greaterThanOrEqualTo(text.bottom));
    expect(tools.bottom, lessThan(box.bottom));
    expect(tools.left, closeTo(box.left + 12, 2));
  });

  testWidgets('a top-aligned suffix sits beside the first line', (tester) async {
    await tester.pumpWidget(_field(alignSuffixTop: true));

    final text = _rect(tester, find.byType(EditableText));
    final suffix = _rect(tester, find.byKey(const Key('suffix')));
    expect(text.height, greaterThan(40));
    const firstLineHalf = 8.0;
    expect(suffix.center.dy, closeTo(text.top + firstLineHalf, 2));
    expect(suffix.left, greaterThanOrEqualTo(text.right));
  });

  testWidgets('the default field keeps the suffix at the vertical center', (tester) async {
    await tester.pumpWidget(_field());

    final text = _rect(tester, find.byType(EditableText));
    final suffix = _rect(tester, find.byKey(const Key('suffix')));
    expect(suffix.center.dy, closeTo(text.center.dy, 2));
  });

  testWidgets('the box border turns to the focus color on focus', (tester) async {
    await tester.pumpWidget(_field(alignSuffixTop: true));
    Color border() =>
        ((tester
                            .widget<DecoratedBox>(
                              find
                                  .descendant(of: find.byType(SailTextField), matching: find.byType(DecoratedBox))
                                  .first,
                            )
                            .decoration
                        as BoxDecoration)
                    .border!
                as Border)
            .top
            .color;
    final resting = border();

    await tester.tap(find.byType(EditableText));
    await tester.pump();

    expect(border(), isNot(resting));
  });

  testWidgets('the text shows the letters as typed, with no contextual glyphs', (tester) async {
    await tester.pumpWidget(_field());

    final style = tester.widget<EditableText>(find.byType(EditableText)).style;
    expect(style.fontFeatures, contains(const FontFeature.disable('calt')));
  });
}
