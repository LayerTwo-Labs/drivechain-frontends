import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _list(double width) {
  return SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: const SailStatList(
            children: [
              SailStatRow(title: 'Lifetime fees paid', subtitle: 'across 14 transactions', value: '0.0001,2840'),
              SailStatRow(title: 'Number of UTXOs', subtitle: '5 unique addresses', value: '6'),
              SailStatRow(title: 'Sidechain deposits', subtitle: '0.0500,0000 ECX last 30 days', value: '0.2000,0000'),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('each stat shows its title and subtitle at the left and its value at the right', (tester) async {
    await tester.pumpWidget(_list(600));

    expect(tester.takeException(), isNull);
    final title = tester.getRect(find.text('Lifetime fees paid'));
    final subtitle = tester.getRect(find.text('across 14 transactions'));
    final value = tester.getRect(find.text('0.0001,2840'));
    expect(subtitle.top, greaterThan(title.bottom - 1));
    expect(value.left, greaterThan(title.right));
    expect(value.right, closeTo(600 - 16 - 1, 1));
  });

  testWidgets('the stats stack in one column', (tester) async {
    await tester.pumpWidget(_list(600));

    final first = tester.getRect(find.text('Lifetime fees paid'));
    final second = tester.getRect(find.text('Number of UTXOs'));
    final third = tester.getRect(find.text('Sidechain deposits'));
    expect(second.top, greaterThan(first.bottom));
    expect(third.top, greaterThan(second.bottom));
    expect(first.left, second.left);
  });

  testWidgets('a stat with no subtitle centers its title on the value', (tester) async {
    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 600,
              child: SailStatList(
                children: [SailStatRow(title: 'Last activity', subtitle: '', value: 'No activity')],
              ),
            ),
          ),
        ),
      ),
    );

    final title = tester.getCenter(find.text('Last activity'));
    final value = tester.getCenter(find.text('No activity'));
    expect(title.dy, closeTo(value.dy, 1));
  });

  testWidgets('a list with no panel puts its rows at the edges of its parent', (tester) async {
    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 600,
              child: SailStatList(
                panel: false,
                children: [
                  SailStatRow(title: 'Peers', subtitle: '8 in / 2 out', value: '10'),
                  SailStatRow(title: 'Block Height', subtitle: '', value: '1022811'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DecoratedBox), findsNothing);
    expect(tester.getTopLeft(find.text('Peers')).dx, 0);
    expect(tester.getTopRight(find.text('10')).dx, closeTo(600, 1));
  });

  testWidgets('a stat value takes the color it is given', (tester) async {
    const green = Color(0xFF00AA00);
    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SailStatList(
            children: [SailStatRow(title: 'Profit and loss', subtitle: '', value: '+12.4%', valueColor: green)],
          ),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('+12.4%')).style!.color, green);
  });
}
