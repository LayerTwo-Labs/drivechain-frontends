import 'dart:io';

import 'package:bitwindow/pages/wallet/wallet_overview.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

class _Wallet implements OrchestratorWalletRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Bmm implements OrchestratorBmmRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet = _Wallet();

  @override
  final OrchestratorBmmRPC bmm = _Bmm();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions extends ChangeNotifier implements TransactionProvider {
  int reads = 0;

  @override
  List<WalletTransaction> get walletTransactions {
    reads++;
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Transactions transactions;

  setUp(() async {
    await GetIt.I.reset();
    transactions = _Transactions();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator());
    GetIt.I.registerSingleton<TransactionProvider>(transactions);
    await registerTestDependencies();
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp));
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('a closed overview does not read the transactions on an enforcer change', (tester) async {
    OverviewViewModel().dispose();
    final before = transactions.reads;

    GetIt.I.get<EnforcerRPC>().markStateChanged();
    await tester.pump(const Duration(milliseconds: 200));

    expect(transactions.reads, before);
  });
}
