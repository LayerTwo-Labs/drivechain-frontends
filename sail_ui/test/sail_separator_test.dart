import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

// SailSeparator is the design-system Phase 0 introduction. Owns rendering
// (no Material import), themed via SailColor.divider. These tests pin the
// public surface so the rest of the migration can lean on it.

void main() {
  testWidgets('SailSeparator paints a horizontal line by default', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SailSeparator(color: Color(0xFF112233), thickness: 2.0),
      ),
    );

    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, 2.0);
    expect(box.width, isNull);
  });

  testWidgets('SailSeparator.vertical flips the axis', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SailSeparator.vertical(color: Color(0xFF112233), thickness: 3.0),
      ),
    );

    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.width, 3.0);
    expect(box.height, isNull);
  });

  testWidgets('SailSeparator honours custom padding', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SailSeparator(
          color: Color(0xFF112233),
          padding: EdgeInsets.all(8.0),
        ),
      ),
    );

    expect(find.byType(Padding), findsOneWidget);
    final pad = tester.widget<Padding>(find.byType(Padding));
    expect(pad.padding, const EdgeInsets.all(8.0));
  });
}
