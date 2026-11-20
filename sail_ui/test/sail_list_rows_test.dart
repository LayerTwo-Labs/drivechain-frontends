import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _panel(List<Widget> rows, {double width = 360}) {
  return SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: SailStatList(children: rows),
        ),
      ),
    ),
  );
}

const _hash = 'f3a1c09e5b7d2468ace013579bdf2468ace013579bdf2468ace013579bdf2468';

void main() {
  testWidgets('a list row shows the title over the subtitle and the trailing widget at the right', (tester) async {
    await tester.pumpWidget(
      _panel(const [
        SailListRow(
          title: 'Nov 20, 2026 09:14',
          subtitle: 'Awaiting funding',
          trailing: SizedBox(key: Key('trailing'), width: 40, height: 20),
        ),
      ]),
    );

    expect(tester.takeException(), isNull);
    final title = tester.getRect(find.text('Nov 20, 2026 09:14'));
    final subtitle = tester.getRect(find.text('Awaiting funding'));
    final trailing = tester.getRect(find.byKey(const Key('trailing')));
    expect(subtitle.top, greaterThan(title.bottom - 1));
    expect(subtitle.left, title.left);
    expect(trailing.right, closeTo(360 - 16 - 1, 1));
  });

  testWidgets('a value row puts the label at the left and the value at the right', (tester) async {
    await tester.pumpWidget(_panel(const [SailValueRow(label: 'Amount', value: '0.01000000 BTC')]));

    final label = tester.getRect(find.text('Amount'));
    final value = tester.getRect(find.text('0.01000000 BTC'));
    expect(label.left, closeTo(16 + 1, 1));
    expect(value.right, closeTo(360 - 16 - 1, 1));
    expect(label.center.dy, closeTo(value.center.dy, 1));
  });

  testWidgets('a stacked row puts the action on the label line and the full value under it', (tester) async {
    await tester.pumpWidget(
      _panel(const [
        SailStackedValueRow(
          label: 'File Hash',
          value: _hash,
          action: SizedBox(key: Key('copy'), width: 20, height: 20),
        ),
      ]),
    );

    expect(tester.takeException(), isNull);
    final label = tester.getRect(find.text('File Hash'));
    final copy = tester.getRect(find.byKey(const Key('copy')));
    final value = tester.getRect(find.text(_hash));
    expect(copy.center.dy, closeTo(label.center.dy, 2));
    expect(copy.right, closeTo(360 - 16 - 1, 1));
    expect(value.top, greaterThan(label.bottom));
    expect(value.left, label.left);
    expect(value.height, greaterThan(label.height), reason: 'a long hash wraps, it does not cut off');
  });

  testWidgets('a divided list draws one divider between each two rows', (tester) async {
    await tester.pumpWidget(
      _panel([
        SizedBox(
          height: 200,
          child: SailDividedList(
            itemCount: 3,
            itemBuilder: (context, index) => SailListRow(title: 'Row $index'),
          ),
        ),
      ]),
    );

    expect(tester.takeException(), isNull);
    final first = tester.getRect(find.text('Row 0'));
    final second = tester.getRect(find.text('Row 1'));
    expect(second.top, greaterThan(first.bottom));
    final dividers = find.descendant(
      of: find.byType(SailDividedList),
      matching: find.byWidgetPredicate((w) => w is Container && w.constraints?.maxHeight == 1),
    );
    expect(dividers, findsNWidgets(2));
  });

  testWidgets('a value row shows a grey label and a regular value', (tester) async {
    await tester.pumpWidget(_panel(const [SailValueRow(label: 'Status', value: 'CONFIRMED')]));

    final theme = SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter);
    expect(tester.widget<Text>(find.text('Status')).style!.color, theme.colors.textSecondary);
    expect(tester.widget<Text>(find.text('CONFIRMED')).style!.fontWeight, isNot(SailStyleValues.boldWeight));
  });

  testWidgets('a stacked row with a strong label shows it in medium weight', (tester) async {
    await tester.pumpWidget(
      _panel(const [
        SailStackedValueRow(label: 'XPUB', value: 'xpub661', strongLabel: true),
        SailStackedValueRow(label: 'File Hash', value: 'f3a1'),
      ]),
    );

    final theme = SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter);
    expect(tester.widget<Text>(find.text('XPUB')).style!.fontWeight, SailStyleValues.boldWeight);
    expect(tester.widget<Text>(find.text('File Hash')).style!.color, theme.colors.textSecondary);
    expect(tester.widget<Text>(find.text('f3a1')).style!.color, theme.colors.textSecondary);
  });
}
