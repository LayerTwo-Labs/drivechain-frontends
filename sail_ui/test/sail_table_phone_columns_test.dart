import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _table({
  void Function(int column, bool ascending)? onSort,
  List<SailMenuEntity> Function(String rowId)? contextMenuItems,
}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: SailTable(
            getRowId: (index) => 'row$index',
            phoneColumns: const [0, 4, 5],
            headerBuilder: (context) => const [
              SailTableHeaderCell(name: 'Date'),
              SailTableHeaderCell(name: 'TXID'),
              SailTableHeaderCell(name: 'Address'),
              SailTableHeaderCell(name: 'Note'),
              SailTableHeaderCell(name: 'Status'),
              SailTableHeaderCell(name: 'Amount'),
            ],
            rowBuilder: (context, index, selected) => const [
              SailTableCell(value: '2026-10-31 18:42'),
              SailTableCell(value: '7c1e…9f03'),
              SailTableCell(value: 'ecash:qp3w…k8v2'),
              SailTableCell(value: 'Rent'),
              SailTableCell(value: 'Unconfirmed'),
              SailTableCell(value: '-0.2500,0000'),
            ],
            rowCount: 1,
            onSort: onSort,
            contextMenuItems: contextMenuItems,
            drawGrid: false,
          ),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('the phone layout shows only the phone columns', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpWidget(_table());
    await tester.pumpAndSettle();

    for (final shown in ['Date', 'Status', 'Amount', '2026-10-31 18:42', 'Unconfirmed', '-0.2500,0000']) {
      expect(find.text(shown), findsOneWidget, reason: shown);
    }
    for (final hidden in ['TXID', 'Address', 'Note', 'Rent']) {
      expect(find.text(hidden), findsNothing, reason: hidden);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the desktop layout shows every column', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpWidget(_table());
    await tester.pumpAndSettle();

    for (final shown in ['Date', 'TXID', 'Address', 'Note', 'Status', 'Amount']) {
      expect(find.text(shown), findsOneWidget, reason: shown);
    }
  });

  testWidgets('a sort on a phone column reports the caller column index', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    final sorts = <int>[];
    await tester.pumpWidget(_table(onSort: (column, _) => sorts.add(column)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Amount'));
    await tester.pumpAndSettle();

    expect(sorts, [5]);
  });

  testWidgets('a long press on a phone row opens the row menu', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpWidget(
      _table(
        contextMenuItems: (rowId) => [
          SailMenuItem(onSelected: () {}, child: SailText.primary12('Bump fee')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Unconfirmed'));
    await tester.pumpAndSettle();

    expect(find.text('Copy value'), findsOneWidget);
    expect(find.text('Bump fee'), findsOneWidget);
  });

  testWidgets('a long press on a desktop row opens no menu', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpWidget(_table());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Unconfirmed'));
    await tester.pumpAndSettle();

    expect(find.text('Copy value'), findsNothing);
  });
}
