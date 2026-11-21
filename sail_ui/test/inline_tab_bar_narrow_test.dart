import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  testWidgets('a long tab strip scrolls in a phone-wide row instead of overflowing', (tester) async {
    const labels = ['Overview', 'Send', 'Receive', 'UTXOs', 'Checks', 'Timestamps', 'Tools'];
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: SizedBox(
              width: 393,
              height: 300,
              child: InlineTabBar(
                tabs: [for (final l in labels) TabItem(label: l, child: Text('$l body'))],
                initialIndex: 0,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final strip = find.descendant(of: find.byType(InlineTabBar), matching: find.byType(SingleChildScrollView)).first;
    expect(tester.getSize(strip).width, lessThanOrEqualTo(393));

    await tester.drag(strip, const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    expect(find.text('Tools body'), findsOneWidget);
  });
}
