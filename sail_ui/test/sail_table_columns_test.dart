import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _table({required bool withAddress}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: SailTable(
            getRowId: (index) => 'row$index',
            headerBuilder: (context) => [
              const SailTableHeaderCell(name: 'Transaction'),
              if (withAddress) const SailTableHeaderCell(name: 'Address'),
              const SailTableHeaderCell(name: 'Amount'),
            ],
            rowBuilder: (context, index, selected) => [
              const SailTableCell(value: 'd1'),
              if (withAddress) const SailTableCell(value: 'sc1'),
              const SailTableCell(value: '12300 sats'),
            ],
            rowCount: 1,
            drawGrid: false,
          ),
        ),
      ),
    ),
  );
}

void main() {
  // A source that names no address drops that column. A refresh can add it
  // back, and the table reads every width by column index.
  testWidgets('a changed column count keeps the table alive', (tester) async {
    await tester.pumpWidget(_table(withAddress: false));
    await tester.pumpAndSettle();
    expect(find.text('Address'), findsNothing);

    await tester.pumpWidget(_table(withAddress: true));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Address'), findsOneWidget);

    await tester.pumpWidget(_table(withAddress: false));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Address'), findsNothing);
  });
}
