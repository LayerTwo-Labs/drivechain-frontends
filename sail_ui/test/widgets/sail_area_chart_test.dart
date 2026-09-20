import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget wrap(Widget child) => MaterialApp(
  home: SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 900, child: child),
      ),
    ),
  ),
);

void main() {
  test('the axis top', () {
    expect(chartTopValue([1, 7, 3]), 7);
    // A flat series at zero still gets a positive top, so the line draws.
    expect(chartTopValue([0, 0, 0]), 1);
    expect(chartTopValue([]), 1);
  });

  testWidgets('the chart draws its labels', (tester) async {
    final start = DateTime(2026, 9, 20, 10);
    await tester.pumpWidget(
      wrap(
        SailAreaChart(
          points: [
            for (var i = 0; i < 6; i++)
              SailChartPoint(
                at: start.add(Duration(minutes: i)),
                value: i * 1000,
              ),
          ],
          labels: const ['10:00', '10:02', '10:05'],
        ),
      ),
    );

    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('10:02'), findsOneWidget);
    expect(find.text('10:05'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('a chart with no reading still builds', (tester) async {
    await tester.pumpWidget(wrap(const SailAreaChart(points: [])));
    expect(find.byType(SailAreaChart), findsOneWidget);
  });
}
