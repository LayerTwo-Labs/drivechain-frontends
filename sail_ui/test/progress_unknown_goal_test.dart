import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _bar({required int current, required int goal, bool justPercent = false}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: SizedBox(
          width: 300,
          child: ProgressBar(
            current: current.toDouble(),
            goal: goal.toDouble(),
            justPercent: justPercent,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a chain with no reported tip says so, rather than zero', (tester) async {
    await tester.pumpWidget(_bar(current: 3, goal: 0, justPercent: true));
    await tester.pumpAndSettle();

    expect(find.text('unknown'), findsOneWidget);
    expect(find.text('0.00%'), findsNothing);
  });

  testWidgets('a chain with no reported tip hides the goal', (tester) async {
    await tester.pumpWidget(_bar(current: 3, goal: 0));
    await tester.pumpAndSettle();

    // The bar carries the count, and the label beside it carries the percent.
    expect(find.text('3 / ?'), findsOneWidget);
    expect(find.text('unknown'), findsOneWidget);
    expect(find.text('0.00%'), findsNothing);
  });

  testWidgets('a known tip keeps the percent beside the bar', (tester) async {
    await tester.pumpWidget(_bar(current: 25, goal: 100));
    await tester.pumpAndSettle();

    expect(find.text('25.00%'), findsOneWidget);
    expect(find.text('unknown'), findsNothing);
  });

  // The index trails the node by a block or two, so the node passes the tip
  // the index reports.
  testWidgets('a node past the reported tip reads as done, not more', (tester) async {
    await tester.pumpWidget(_bar(current: 5, goal: 4, justPercent: true));
    await tester.pumpAndSettle();

    expect(find.text('100.00%'), findsOneWidget);
    expect(find.text('125.00%'), findsNothing);
  });

  testWidgets('a reported tip still reads as a percentage', (tester) async {
    await tester.pumpWidget(_bar(current: 50, goal: 100, justPercent: true));
    await tester.pumpAndSettle();

    expect(find.text('50.00%'), findsOneWidget);
  });
}
