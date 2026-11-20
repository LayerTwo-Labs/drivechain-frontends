import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/explorer/load_transaction_dialog.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:connectrpc/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart' hide DetailRow;
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.spec.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';

import 'test_utils.dart';

final _next = 'cd' * 32;
final _txid = 'ef' * 32;

class _Orchestrator implements OrchestratorRPC {
  @override
  final BitcoinServiceClient bitcoind = BitcoinServiceClient(
    FakeTransportBuilder().unary(BitcoinService.getBlock, (req, _) {
      return switch (req.height) {
        7 => GetBlockResponse(height: 7, hash: 'ab' * 32, nextBlockHash: _next, difficulty: 2.5, txids: [_txid]),
        8 => GetBlockResponse(height: 8, hash: _next, difficulty: 2.5),
        _ => throw connect.ConnectException(connect.Code.unknown, 'Block height out of range'),
      };
    }).build(),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator());
  });

  tearDown(() => GetIt.I.reset());

  Future<void> openDetails(WidgetTester tester, String height) async {
    await tester.pumpSailPage(const BlockExplorerDialog());
    await tester.pump();
    await tester.enterText(find.byType(TextField), height);
    await tester.tap(find.text('Search').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  String rowValue(WidgetTester tester, String label) {
    final row = find.ancestor(of: find.text(label), matching: find.byType(DetailRow)).first;
    return tester.widget<DetailRow>(row).value;
  }

  testWidgets('the details show the next block hash and the difficulty', (tester) async {
    await openDetails(tester, '7');

    expect(rowValue(tester, 'Next Block Hash'), _next);
    expect(rowValue(tester, 'Difficulty'), '2.5');
    expect(find.text('Chain Work'), findsNothing);
    expect(find.text('Median time'), findsNothing);
  });

  testWidgets('the chain tip has no next block hash', (tester) async {
    await openDetails(tester, '8');

    expect(rowValue(tester, 'Next Block Hash'), 'None');
  });

  testWidgets('a block txid opens the chain transaction, not the wallet one', (tester) async {
    await openDetails(tester, '7');

    tester.widget<TXIDTransactionTable>(find.byType(TXIDTransactionTable)).onTransactionSelected!(_txid);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LoadTransactionDialog), findsOneWidget);
    expect(tester.widget<LoadTransactionDialog>(find.byType(LoadTransactionDialog)).txid, _txid);
    expect(find.byType(TransactionDetailsDialog), findsNothing);
  });
}
