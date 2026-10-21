import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart';
import 'package:sail_ui/sail_ui.dart';

class _FakeTransactionsProvider extends ChangeNotifier implements SidechainTransactionsProvider {
  _FakeTransactionsProvider(this.sidechainTransactions);

  @override
  List<CoreTransaction> sidechainTransactions;

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

void main() {
  setUp(() {
    GetIt.I.registerSingleton<SidechainTransactionsProvider>(
      _FakeTransactionsProvider([
        _tx('aaaaaaaaaaaa', amount: 300000000, time: 1000),
        _tx('bbbbbbbbbbbb', amount: 100000000, time: 3000),
        _tx('cccccccccccc', amount: 200000000, time: 2000),
      ]),
    );
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('a tap on a column header sorts by that column', (tester) async {
    final model = LatestWalletTransactionsViewModel();
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 600,
              child: TransactionTable(model: model, searchWidget: const SizedBox()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Amount'));
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['bbbbbbbbbbbb:0', 'cccccccccccc:0', 'aaaaaaaaaaaa:0']);

    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();
    expect(_txidColumn(tester), ['aaaaaaaaaaaa:0', 'cccccccccccc:0', 'bbbbbbbbbbbb:0']);
  });
}
