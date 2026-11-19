import 'dart:io';

import 'package:bitwindow/pages/wallet/wallet_overview.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as walletpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

const _parent = 'aa';

class _Wallet implements OrchestratorWalletRPC {
  final rates = <int>[];

  @override
  Future<wmpb.ListUnspentResponse> listUnspent(String walletId) async => wmpb.ListUnspentResponse(
    utxos: [wmpb.UnspentOutput(txid: _parent, vout: 1, confirmations: 0)],
  );

  @override
  Future<wmpb.CreateCpfpResponse> createCpfp({
    required String walletId,
    required String parentTxid,
    required int parentVout,
    required int targetFeeRate,
  }) async {
    rates.add(targetFeeRate);
    return wmpb.CreateCpfpResponse(childTxid: 'bb');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Bmm implements OrchestratorBmmRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  @override
  final _Wallet wallet = _Wallet();

  @override
  final OrchestratorBmmRPC bmm = _Bmm();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions extends ChangeNotifier implements TransactionProvider {
  int fetches = 0;

  @override
  Future<void> fetch() async => fetches++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Orchestrator orchestrator;
  late _Transactions transactions;

  setUp(() async {
    await GetIt.I.reset();
    orchestrator = _Orchestrator();
    transactions = _Transactions();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    GetIt.I.registerSingleton<TransactionProvider>(transactions);
    await registerTestDependencies();
    final walletReader = WalletReaderProvider(Directory.systemTemp)..activeWalletId = 'wallet-1';
    GetIt.I.registerSingleton<WalletReaderProvider>(walletReader);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('a broadcast child closes the CPFP dialog and refreshes the list', (tester) async {
    final model = OverviewViewModel();
    final tx = walletpb.WalletTransaction(txid: _parent);
    await tester.pumpSailPage(
      Builder(
        builder: (context) => SailButton(label: 'Open', onPressed: () => model.accelerateCpfp(context, tx)),
      ),
    );

    await tester.tap(find.byWidgetPredicate((w) => w is SailButton && w.label == 'Open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SailCardEditValues), findsOneWidget);

    await tester.enterText(
      find.descendant(of: find.byType(SailCardEditValues), matching: find.byType(EditableText)),
      '10',
    );
    await tester.tap(find.byWidgetPredicate((w) => w is SailButton && w.label == 'Save changes'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(orchestrator.wallet.rates, [10]);
    expect(find.byType(SailCardEditValues), findsNothing);
    expect(transactions.fetches, 1);
    model.dispose();
    await tester.pump(const Duration(seconds: 10));
  });
}
