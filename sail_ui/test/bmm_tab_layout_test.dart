import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';

/// The four sections the BMM tab stacks: two heads, and two tables that grow
/// with the rounds they list.
List<Widget> _sections(int nextBlockBids, int historicBids) => [
  const SizedBox(height: 120), // controls
  const SizedBox(height: 130), // current slot
  SizedBox(height: tableFrameHeight(nextBlockBids)),
  SizedBox(height: tableFrameHeight(historicBids)),
];

Future<void> _pumpCard(WidgetTester tester, Widget child, {required Size window}) async {
  await tester.binding.setSurfaceSize(window);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(
          body: SailCard(title: 'BMM', child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  test('a table frame grows one line per row', () {
    expect(tableFrameHeight(0), 100, reason: 'an empty table still shows its placeholder');
    expect(tableFrameHeight(1), 82);
    expect(tableFrameHeight(10), 442);
  });

  // Ten rounds of history is an ordinary evening of bidding, and the card is
  // taller than the window long before that.
  testWidgets('the stacked sections overflow a card that does not scroll', (tester) async {
    await _pumpCard(
      tester,
      SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _sections(4, 10),
      ),
      window: const Size(1200, 800),
    );

    expect(tester.takeException(), isNotNull, reason: 'this is the shape the tab had');
  });

  testWidgets('a scrolling card holds the same sections', (tester) async {
    await _pumpCard(
      tester,
      SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _sections(4, 10),
        ),
      ),
      window: const Size(1200, 800),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
