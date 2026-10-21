import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';

import 'test_utils.dart';

CoreTransaction _tx(String txid, {required double amount, required int time}) {
  return CoreTransaction(
    address: '',
    category: 'receive',
    amount: amount,
    label: '',
    vout: 0,
    fee: 0,
    confirmations: 1,
    trusted: true,
    blockhash: '',
    blockindex: 0,
    blocktime: time,
    txid: txid,
    time: DateTime.fromMillisecondsSinceEpoch(time * 1000),
    timereceived: DateTime.fromMillisecondsSinceEpoch(time * 1000),
    comment: '',
    bip125Replaceable: 'no',
    abandoned: false,
    raw: txid,
  );
}

List<String> _txidColumn(WidgetTester tester) {
  return tester
      .widgetList<SailTableCell>(find.byType(SailTableCell))
      .map((cell) => cell.copyValue)
      .whereType<String>()
      .toList();
}

Widget _table(List<CoreTransaction> entries) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: SizedBox(
          width: 1000,
          height: 600,
          child: TransactionTable(entries: entries, searchWidget: const SizedBox()),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await registerTestDependencies();
  });

  testWidgets('the table starts newest first, sorts a new list and keeps the given list', (tester) async {
    final first = [
      _tx('aaaaaaaaaaaa', amount: 300000000, time: 1000),
      _tx('bbbbbbbbbbbb', amount: 100000000, time: 3000),
    ];
    await tester.pumpWidget(_table(first));
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['bbbbbbbbbbbb:0', 'aaaaaaaaaaaa:0']);

    await tester.tap(find.text('Amount'));
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['bbbbbbbbbbbb:0', 'aaaaaaaaaaaa:0']);
    expect(first.map((tx) => tx.txid), ['aaaaaaaaaaaa', 'bbbbbbbbbbbb']);

    await tester.pumpWidget(
      _table([
        _tx('aaaaaaaaaaaa', amount: 300000000, time: 1000),
        _tx('bbbbbbbbbbbb', amount: 100000000, time: 3000),
        _tx('cccccccccccc', amount: 200000000, time: 2000),
      ]),
    );
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['bbbbbbbbbbbb:0', 'cccccccccccc:0', 'aaaaaaaaaaaa:0']);
  });
}
