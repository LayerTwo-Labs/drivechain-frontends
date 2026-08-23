// The daemon cards resize whenever an error comes and goes, which makes the
// page jump. DaemonStatusBlock holds the same height either way, and puts a
// taller message behind a toggle the reader opens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  Widget wrap(String message) => MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 900, child: DaemonStatusBlock(message: message)),
        ),
      ),
    ),
  );

  Finder toggle(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

  const threeLines =
      'Error:  × block producer mempool task failed\n'
      '  ├─▶ mempool initial sync error\n'
      '  └─▶ Batch JSON RPC error: Block not found on disk';

  const sixLines =
      '$threeLines\n'
      '  └─▶ chain state is behind the header tip\n'
      '  └─▶ retry scheduled\n'
      '  └─▶ giving the node more time';

  testWidgets('an empty message holds the same height as a real one', (tester) async {
    await tester.pumpWidget(wrap(''));
    final empty = tester.getSize(find.byType(DaemonStatusBlock));

    await tester.pumpWidget(wrap('Initializing...'));
    final short = tester.getSize(find.byType(DaemonStatusBlock));

    await tester.pumpWidget(wrap(threeLines));
    final long = tester.getSize(find.byType(DaemonStatusBlock));

    expect(empty.height, short.height);
    expect(empty.height, long.height);
  });

  testWidgets('a message that fits offers no toggle', (tester) async {
    await tester.pumpWidget(wrap(threeLines));
    expect(toggle('Show more'), findsNothing);
  });

  testWidgets('a taller message keeps the height and offers a toggle', (tester) async {
    await tester.pumpWidget(wrap(''));
    final closed = tester.getSize(find.byType(DaemonStatusBlock));

    await tester.pumpWidget(wrap(sixLines));
    expect(tester.getSize(find.byType(DaemonStatusBlock)).height, closed.height);
    expect(toggle('Show more'), findsOneWidget);
  });

  testWidgets('the toggle opens the whole message and closes it again', (tester) async {
    await tester.pumpWidget(wrap(sixLines));
    final closed = tester.getSize(find.byType(DaemonStatusBlock));

    await tester.tap(toggle('Show more'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(DaemonStatusBlock)).height, greaterThan(closed.height));
    expect(toggle('Show less'), findsOneWidget);

    await tester.tap(toggle('Show less'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(DaemonStatusBlock)).height, closed.height);
    expect(toggle('Show more'), findsOneWidget);
  });

  testWidgets('every line of the error stays readable', (tester) async {
    await tester.pumpWidget(wrap(threeLines));

    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts, contains(threeLines));
  });

  testWidgets('the tooltip carries the whole message', (tester) async {
    await tester.pumpWidget(wrap(threeLines));

    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, threeLines);
  });

  testWidgets('an empty message gets no tooltip', (tester) async {
    await tester.pumpWidget(wrap(''));
    expect(find.byType(Tooltip), findsNothing);
  });

  test('the block reserves three rows', () {
    expect(DaemonStatusBlock.rows, 3);
  });

  testWidgets("the progress row grows with the reader's text scale", (tester) async {
    late double plain;
    late double scaled;

    Widget probe(double scale, void Function(double) sink) => MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Builder(
            builder: (context) {
              sink(progressRowHeight(context));
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(probe(1, (v) => plain = v));
    await tester.pumpWidget(probe(2, (v) => scaled = v));

    expect(plain, greaterThanOrEqualTo(progressBarHeight));
    expect(scaled, greaterThan(plain));
  });
}
