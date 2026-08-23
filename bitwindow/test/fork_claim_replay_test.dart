import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _FakeWallet implements OrchestratorWalletRPC {
  bool? sentReplayProtect;

  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId, {wmpb.AddressType? addressType}) async =>
      wmpb.GetNewAddressResponse(address: 'bcrt1qsweep');

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
    bool replayProtect = false,
  }) async {
    sentReplayProtect = replayProtect;
    return wmpb.SendTransactionResponse(txid: 'aa' * 32);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.wallet);

  @override
  final OrchestratorWalletRPC wallet;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf implements BitcoinConfProvider {
  _FakeConf(this.network);

  @override
  final BitcoinNetwork network;

  @override
  bool get drivechainFeaturesAvailable => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions implements TransactionProvider {
  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBalance implements BalanceProvider {
  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> replace<T extends Object>(T instance) async {
  if (GetIt.I.isRegistered<T>()) {
    await GetIt.I.unregister<T>();
  }
  GetIt.I.registerSingleton<T>(instance);
}

void main() {
  late _FakeWallet wallet;

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    wallet = _FakeWallet();
    await replace<OrchestratorRPC>(_FakeOrchestrator(wallet));
    await replace<BitcoinConfProvider>(_FakeConf(BitcoinNetwork.BITCOIN_NETWORK_ECASH));
    await replace<TransactionProvider>(_FakeTransactions());
    await replace<BalanceProvider>(_FakeBalance());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('the sweep of a single-sig claim carries replay protection', () async {
    final provider = ForkProvider();
    provider.claims = [
      WalletClaim(
        walletId: 'w1',
        walletName: 'Main wallet',
        claimableSats: 100000,
        utxos: [bwpb.UnspentOutput(output: 'aa:0', valueSats: Int64(100000))],
      ),
    ];

    await provider.claim('w1');

    expect(wallet.sentReplayProtect, isTrue, reason: 'a plain sweep replays onto the other chain');
  });

  test('the sweep stays plain where the node rejects the magic locktime', () async {
    await replace<BitcoinConfProvider>(_FakeConf(BitcoinNetwork.BITCOIN_NETWORK_SIGNET));
    final provider = ForkProvider();
    provider.claims = [
      WalletClaim(
        walletId: 'w1',
        walletName: 'Main wallet',
        claimableSats: 100000,
        utxos: [bwpb.UnspentOutput(output: 'aa:0', valueSats: Int64(100000))],
      ),
    ];

    await provider.claim('w1');

    expect(wallet.sentReplayProtect, isFalse, reason: 'stock Core rejects a non-final transaction');
  });
}
