import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _table({required bool fill}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 360,
            height: 200,
            child: SailTable(
              getRowId: (index) => 'row$index',
              headerBuilder: (context) => const [
                SailTableHeaderCell(name: 'Date'),
                SailTableHeaderCell(name: 'Status'),
                SailTableHeaderCell(name: 'Amount'),
              ],
              rowBuilder: (context, index, selected) => [
                const SailTableCell(value: '2026-10-31 18:42', width: 118),
                SailTableCell(value: 'Deposit · slot 9 · unconfirmed · a long description', fill: fill),
                const SailTableCell(value: '-0.2500,0000', width: 95),
              ],
              rowCount: 1,
              drawGrid: false,
            ),
          ),
        ),
      ),
    ),
  );
}

Rect _header(WidgetTester tester, String name) =>
    tester.getRect(find.byWidgetPredicate((w) => w is SailTableHeaderCell && w.name == name));

void main() {
  testWidgets('a fill column takes the width the other columns leave', (tester) async {
    await tester.pumpWidget(_table(fill: true));
    await tester.pumpAndSettle();

    expect(_header(tester, 'Status').left, closeTo(118 + 8, 1));
    expect(_header(tester, 'Amount').right, closeTo(360, 1));
  });

  testWidgets('a column with no fill keeps the width of its widest value', (tester) async {
    await tester.pumpWidget(_table(fill: false));
    await tester.pumpAndSettle();

    expect(_header(tester, 'Amount').right, greaterThan(361));
  });
}
