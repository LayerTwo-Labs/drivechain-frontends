import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/widgets/price_chart.dart';

void main() {
  PricePoint point(int secondsAgo, double price) =>
      PricePoint(DateTime.now().subtract(Duration(seconds: secondsAgo)), price);

  testWidgets('one point shows the empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PriceChart(points: [point(10, 0.5)], color: const Color(0xff2ab517)),
      ),
    );

    expect(find.textContaining('fills as the price moves'), findsOneWidget);
    expect(find.byType(CustomPaint), findsNothing);
  });

  testWidgets('two points draw the line', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PriceChart(
          points: [point(60, 0.4), point(10, 0.7)],
          color: const Color(0xff2ab517),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.textContaining('fills as the price moves'), findsNothing);
  });
}
