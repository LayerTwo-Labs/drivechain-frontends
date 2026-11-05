import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';

import 'test_utils.dart';

CoreTransaction _tx(String txid, {required double amount, int confirmations = 1, int vout = 0}) {
  return CoreTransaction(
    address: '',
    category: 'receive',
    amount: amount,
    label: '',
    vout: vout,
    fee: 0,
    confirmations: confirmations,
    trusted: confirmations > 0,
    blockhash: '',
    blockindex: 0,
    blocktime: 0,
    txid: txid,
    time: DateTime.fromMillisecondsSinceEpoch(0),
    timereceived: DateTime.fromMillisecondsSinceEpoch(0),
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

  testWidgets('the table starts with the unconfirmed entries, then keeps the node order', (tester) async {
    final first = [
      _tx('aaaaaaaaaaaa', amount: 300000000),
      _tx('bbbbbbbbbbbb', amount: 100000000, confirmations: 0),
      _tx('cccccccccccc', amount: 200000000),
    ];
    await tester.pumpWidget(_table(first));
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['bbbbbbbbbbbb:0', 'aaaaaaaaaaaa:0', 'cccccccccccc:0']);

    await tester.tap(find.text('Amount'));
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['bbbbbbbbbbbb:0', 'cccccccccccc:0', 'aaaaaaaaaaaa:0']);
    expect(first.map((tx) => tx.txid), ['aaaaaaaaaaaa', 'bbbbbbbbbbbb', 'cccccccccccc']);

    await tester.tap(find.text('TxID'));
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['aaaaaaaaaaaa:0', 'bbbbbbbbbbbb:0', 'cccccccccccc:0']);
  });

  testWidgets('the table shows a status and no date', (tester) async {
    await tester.pumpWidget(
      _table([
        _tx('aaaaaaaaaaaa', amount: 300000000, vout: 2),
        _tx('bbbbbbbbbbbb', amount: 100000000, confirmations: 0),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wallet Transaction History'), findsOneWidget);
    expect(
      find.text(
        'zSide records no time for a coin, so this list has no Date column. Shielded transfers do not show here.',
      ),
      findsOneWidget,
    );
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Date'), findsNothing);
    expect(find.text('Conf Height'), findsNothing);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Unconfirmed'), findsOneWidget);
    expect(find.text('aaaaaa..:2'), findsOneWidget);
  });

  testWidgets('the details dialog shows the txid, the amount and the status', (tester) async {
    await tester.pumpWidget(_table([_tx('aaaaaaaaaaaa', amount: 300000000, vout: 2)]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('aaaaaa..:2'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('aaaaaa..:2'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('aaaaaaaaaaaa:2'), findsOneWidget);
    expect(find.text('Amount'), findsNWidgets(2));
    expect(find.text('Status'), findsNWidgets(2));
    expect(find.text('Confirmed'), findsNWidgets(2));
    expect(find.text('Date'), findsNothing);
    expect(find.text('Confirmation Height'), findsNothing);
  });
}
