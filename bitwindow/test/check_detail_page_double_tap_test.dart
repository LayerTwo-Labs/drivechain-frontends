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
const _wif = 'cVjzvdHGfQDtBEq7oddDRZ9uHt6EWWSuUJHfXKgL9pUAmL7Hzc4v';

bwpb.Cheque _check({bool funded = false}) => bwpb.Cheque(
  id: Int64(1),
  derivationIndex: 1,
  address: _address,
  expectedAmountSats: Int64(210000000),
  fundedTxids: funded ? ['deadbeef'] : const [],
  privateKeyWif: _wif,
);

class _FakeCheckProvider extends ChangeNotifier implements CheckProvider {
  _FakeCheckProvider(this._cheque);

  final bwpb.Cheque _cheque;
  int sweepCalls = 0;
  final Completer<String> sweepCompleter = Completer<String>();

  @override
  Future<bwpb.Cheque?> getCheck(int id) async => _cheque;

  @override
  void startPolling(int checkId, {Duration interval = const Duration(seconds: 5)}) {}

  @override
  Future<String> sweepCheck(String privateKeyWif, String destinationAddress, int feeSatPerVbyte) {
    sweepCalls++;
    return sweepCompleter.future;
  }

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
  final Completer<wmpb.SendTransactionResponse> sendCompleter = Completer<wmpb.SendTransactionResponse>();

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

class _FakeConf implements BitcoinConfProvider {
  @override
  BitcoinNetwork get network => BitcoinNetwork.BITCOIN_NETWORK_REGTEST;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeCheckProvider> _pumpCheckDetail(WidgetTester tester, {required bool funded}) async {
  final checkProvider = _FakeCheckProvider(_check(funded: funded));
  GetIt.I.registerSingleton<CheckProvider>(checkProvider);
  GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions());
  GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
  GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());

  await tester.pumpSailPage(const CheckDetailPage(checkId: 1));
  await tester.pump();
  await tester.pump();

  return checkProvider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('tapping Fund with Wallet twice sends one transaction', (tester) async {
    await _pumpCheckDetail(tester, funded: false);
    final wallet = GetIt.I.get<OrchestratorRPC>().wallet as _FakeOrchestratorWallet;

    // Both taps land before the send resolves — the second must be dropped.
    await tester.tap(find.text('Fund with Wallet'));
    await tester.tap(find.text('Fund with Wallet'));

    expect(wallet.sendCalls, 1);
  });

  testWidgets('tapping Sweep Check to Wallet twice sweeps once', (tester) async {
    final checkProvider = await _pumpCheckDetail(tester, funded: true);

    await tester.tap(find.text('Sweep Check to Wallet'));
    await tester.tap(find.text('Sweep Check to Wallet'));

    expect(checkProvider.sweepCalls, 1);
  });
}
