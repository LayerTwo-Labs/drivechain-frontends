import 'dart:async';

import 'package:bitwindow/pages/wallet/check_detail_page.dart';
import 'package:bitwindow/providers/check_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

const _address = 'bcrt1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

class _FakeCheckProvider extends ChangeNotifier implements CheckProvider {
  @override
  Future<bwpb.Cheque?> getCheck(int id) async => bwpb.Cheque(
    id: Int64(1),
    derivationIndex: 1,
    address: _address,
    expectedAmountSats: Int64(210000000),
  );

  @override
  void startPolling(int checkId, {Duration interval = const Duration(seconds: 5)}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  @override
  String address = _address;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestratorWallet implements OrchestratorWalletRPC {
  int sendCalls = 0;
  final sendCompleter = Completer<wmpb.SendTransactionResponse>();

  @override
  Future<wmpb.SendTransactionResponse> sendTransaction({
    required String walletId,
    required Map<String, int> destinations,
    int? feeRateSatPerVbyte,
    int? fixedFeeSats,
    bool subtractFeeFromAmount = false,
    String? opReturnMessage,
    String? opReturnHex,
    List<bwpb.UnspentOutput>? requiredInputs,
    bool allowReplay = false,
  }) {
    sendCalls++;
    return sendCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  OrchestratorWalletRPC wallet = _FakeOrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('tapping Fund with Wallet twice sends one transaction', (tester) async {
    GetIt.I.registerSingleton<CheckProvider>(_FakeCheckProvider());
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions());
    GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());

    await tester.pumpSailPage(const CheckDetailPage(checkId: 1));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Fund with Wallet'));
    await tester.tap(find.text('Fund with Wallet'));

    final wallet = GetIt.I.get<OrchestratorRPC>().wallet as _FakeOrchestratorWallet;
    expect(wallet.sendCalls, 1);
  });
}
