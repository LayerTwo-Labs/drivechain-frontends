import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

final _denied = 'a' * 64;
final _plain = 'b' * 64;

class _OrchestratorWallet implements OrchestratorWalletRPC {
  String newAddress = 'wallet-address';

  @override
  Future<wmpb.ListUnspentResponse> listUnspent(String walletId) async => wmpb.ListUnspentResponse(
    utxos: [
      wmpb.UnspentOutput(txid: _denied, vout: 1, amountSats: Int64(1000)),
      wmpb.UnspentOutput(txid: _plain, vout: 0, amountSats: Int64(2000)),
    ],
  );

  @override
  Future<wmpb.ListTransactionsResponse> listTransactions({required String walletId, int count = 100}) async =>
      wmpb.ListTransactionsResponse();

  @override
  Future<wmpb.ListReceiveAddressesResponse> listReceiveAddresses(String walletId) async =>
      wmpb.ListReceiveAddressesResponse();

  @override
  Future<wmpb.GetBalanceResponse> getBalance(String walletId) async => wmpb.GetBalanceResponse();

  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId, {wmpb.AddressType? addressType}) async =>
      wmpb.GetNewAddressResponse(address: newAddress);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet = _OrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BitwindowdWallet implements WalletAPI {
  @override
  Future<List<UnspentOutput>> listUnspent(String walletId) async => [
    UnspentOutput(
      output: '$_denied:1',
      denialInfo: DenialInfo(id: Int64(7), numHops: 3),
    ),
    UnspentOutput(output: '$_plain:0'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BitwindowdAPI implements BitwindowAPI {
  @override
  Future<Map<String, String>> listTransactionNotes({String walletId = ''}) async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Bitwindowd implements BitwindowRPC {
  @override
  final WalletAPI wallet = _BitwindowdWallet();

  @override
  final BitwindowAPI bitwindowd = _BitwindowdAPI();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  WalletData? get activeWallet => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Balance extends ChangeNotifier implements BalanceProvider {
  @override
  final newestTransactions = ValueNotifier<List<wmpb.TransactionEntry>?>(null);

  @override
  void setBalance(RPCConnection rpc, double confirmed, double pending) {}

  @override
  bool streams(RPCConnection rpc) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Blockchain extends ChangeNotifier implements BlockchainProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator());
    GetIt.I.registerSingleton<BitwindowRPC>(_Bitwindowd());
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    GetIt.I.registerSingleton<BalanceProvider>(_Balance());
    GetIt.I.registerSingleton<BlockchainProvider>(_Blockchain());
    await registerTestDependencies();
  });

  tearDown(() => GetIt.I.reset());

  test('the UTXO list carries the denial info of bitwindowd', () async {
    final provider = TransactionProvider();
    addTearDown(provider.dispose);
    final loaded = Completer<void>();
    provider.addListener(() {
      if ((provider.initialized || provider.error != null) && !loaded.isCompleted) {
        loaded.complete();
      }
    });
    await loaded.future;

    expect(provider.error, isNull);
    final byOutput = {for (final utxo in provider.utxos) utxo.output: utxo};
    expect(byOutput['$_denied:1']!.hasDenialInfo(), isTrue);
    expect(byOutput['$_denied:1']!.denialInfo.id, Int64(7));
    expect(byOutput['$_plain:0']!.hasDenialInfo(), isFalse);
  });

  test('a poll with the same data does not notify', () async {
    final provider = TransactionProvider();
    addTearDown(provider.dispose);
    await pumpEventQueue();
    expect(provider.address, 'wallet-address');
    var notifies = 0;
    provider.addListener(() => notifies++);

    await provider.fetch();
    await pumpEventQueue();
    expect(notifies, 0);

    (GetIt.I.get<OrchestratorRPC>().wallet as _OrchestratorWallet).newAddress = 'next-address';
    await provider.fetch();
    await pumpEventQueue();
    expect(notifies, 1);
    expect(provider.address, 'next-address');
  });
}
