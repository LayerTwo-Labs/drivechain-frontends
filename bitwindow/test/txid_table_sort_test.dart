import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

final _txids = ['bb' * 32, 'cc' * 32, 'aa' * 32];

void main() {
  tearDown(() => GetIt.I.reset());

  List<String> shownRows(WidgetTester tester) {
    final cells = tester.widgetList<SailTableCell>(find.byType(SailTableCell)).map((c) => c.value).toList();
    return [for (var i = 0; i < cells.length; i += 2) '${cells[i]} ${cells[i + 1].substring(0, 2)}'];
  }

  Future<void> pumpTable(WidgetTester tester) async {
    await tester.pumpSailPage(
      SizedBox(height: 300, child: TXIDTransactionTable(transactions: _txids)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the txids in block order at first', (tester) async {
    await pumpTable(tester);

    expect(shownRows(tester), ['0 bb', '1 cc', '2 aa']);
  });

  testWidgets('a tap on the txid header sorts the rows and keeps each block index', (tester) async {
    await pumpTable(tester);

    await tester.tap(find.text('txid'));
    await tester.pumpAndSettle();
    expect(shownRows(tester), ['2 aa', '0 bb', '1 cc']);

    await tester.tap(find.text('txid'));
    await tester.pumpAndSettle();
    expect(shownRows(tester), ['1 cc', '0 bb', '2 aa']);

    await tester.tap(find.text('n'));
    await tester.pumpAndSettle();
    expect(shownRows(tester), ['0 bb', '1 cc', '2 aa']);
  });
}
