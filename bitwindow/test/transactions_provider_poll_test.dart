import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _OrchestratorWallet implements OrchestratorWalletRPC {
  int listCalls = 0;
  int addressCalls = 0;
  int balanceCalls = 0;
  bool failList = false;
  bool failAddress = false;
  List<wmpb.TransactionEntry> entries = [];
  Future<void>? unspentHold;
  Future<void>? listHold;

  @override
  Future<wmpb.ListUnspentResponse> listUnspent(String walletId) async {
    await unspentHold;
    return wmpb.ListUnspentResponse();
  }

  @override
  Future<wmpb.ListTransactionsResponse> listTransactions({required String walletId, int count = 100}) async {
    listCalls++;
    final snapshot = entries;
    await listHold;
    if (failList) {
      throw Exception('drivechaind is down');
    }
    return wmpb.ListTransactionsResponse(transactions: snapshot);
  }

  @override
  Future<wmpb.ListReceiveAddressesResponse> listReceiveAddresses(String walletId) async =>
      wmpb.ListReceiveAddressesResponse();

  @override
  Future<wmpb.GetBalanceResponse> getBalance(String walletId) async {
    balanceCalls++;
    return wmpb.GetBalanceResponse();
  }

  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId, {wmpb.AddressType? addressType}) async {
    addressCalls++;
    if (failAddress) {
      throw Exception('no chain source');
    }
    return wmpb.GetNewAddressResponse(address: 'wallet-address');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  @override
  final _OrchestratorWallet wallet = _OrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BitwindowdWallet implements WalletAPI {
  @override
  Future<List<UnspentOutput>> listUnspent(String walletId) async => [];

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

  bool streamed = false;

  @override
  bool streams(RPCConnection rpc) => streamed;

  void changed() => notifyListeners();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Blockchain extends ChangeNotifier implements BlockchainProvider {
  void changed() => notifyListeners();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _OrchestratorWallet wallet;
  late _Balance balance;
  late _Blockchain blockchain;
  late TransactionProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    final orchestrator = _Orchestrator();
    wallet = orchestrator.wallet;
    balance = _Balance();
    blockchain = _Blockchain();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    GetIt.I.registerSingleton<BitwindowRPC>(_Bitwindowd());
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    GetIt.I.registerSingleton<BalanceProvider>(balance);
    GetIt.I.registerSingleton<BlockchainProvider>(blockchain);
    provider = TransactionProvider();
    await pumpEventQueue();
    wallet.listCalls = 0;
    wallet.addressCalls = 0;
    wallet.balanceCalls = 0;
  });

  tearDown(() async {
    provider.dispose();
    await GetIt.I.reset();
  });

  Future<void> ticks(int n) async {
    for (var i = 0; i < n; i++) {
      provider.tick();
      await pumpEventQueue();
    }
  }

  test('a wallet that read cleanly skips the ticks until the fallback read', () async {
    await ticks(11);
    expect(wallet.listCalls, 0);
    expect(wallet.addressCalls, 0);

    await ticks(1);
    expect(wallet.listCalls, 1);
    expect(wallet.addressCalls, 1);
  });

  test('a fetch starts the fallback count again', () async {
    await ticks(6);
    await provider.fetch();
    await ticks(11);
    expect(wallet.listCalls, 1);
  });

  test('a failed read tries again on the next tick', () async {
    wallet.failList = true;
    await provider.fetch();
    await ticks(2);
    expect(wallet.listCalls, 3);
  });

  test('a failed address read tries again on the next tick', () async {
    wallet.failAddress = true;
    await provider.fetch();
    await pumpEventQueue();
    await ticks(2);
    expect(wallet.addressCalls, 3);
  });

  test('a balance change fetches', () async {
    balance.changed();
    await pumpEventQueue();
    expect(wallet.listCalls, 1);
  });

  test('a streamed balance change reads no balance', () async {
    balance.streamed = true;
    balance.changed();
    await pumpEventQueue();
    expect(wallet.listCalls, 1);
    expect(wallet.balanceCalls, 0);

    balance.streamed = false;
    await provider.fetch();
    expect(wallet.balanceCalls, 1);
  });

  test('a new transaction does not wait for the UTXO read', () async {
    wallet.entries = [wmpb.TransactionEntry(txid: 'a', amountSats: Int64(5))];
    await provider.fetch();
    expect(provider.initialized, isTrue);
    var notifies = 0;
    provider.addListener(() => notifies++);

    final hold = Completer<void>();
    wallet.unspentHold = hold.future;
    wallet.entries = [...wallet.entries, wmpb.TransactionEntry(txid: 'b', amountSats: Int64(7))];
    final fetch = provider.fetch();
    await pumpEventQueue();
    expect(provider.walletTransactions.map((t) => t.txid), containsAll(['a', 'b']));
    expect(notifies, 1);

    hold.complete();
    await fetch;
    expect(notifies, 1, reason: 'the list showed, and the rest did not change');
  });

  test('a balance frame shows a new transaction before the full read', () async {
    wallet.entries = [wmpb.TransactionEntry(txid: 'a', amountSats: Int64(5), time: Int64(1))];
    await provider.fetch();
    final hold = Completer<void>();
    wallet.unspentHold = hold.future;

    balance.newestTransactions.value = [wmpb.TransactionEntry(txid: 'b', amountSats: Int64(7), time: Int64(2))];
    expect(provider.walletTransactions.map((t) => t.txid), ['b', 'a'], reason: 'no RPC between frame and row');
    hold.complete();
  });

  test('a full read that started before a frame keeps its tx', () async {
    wallet.entries = [wmpb.TransactionEntry(txid: 'a', amountSats: Int64(5), time: Int64(1))];
    await provider.fetch();
    final hold = Completer<void>();
    wallet.listHold = hold.future;
    wallet.entries = [
      wmpb.TransactionEntry(txid: 'a', amountSats: Int64(5), time: Int64(1), confirmations: 1),
    ];
    final fetch = provider.fetch();
    await pumpEventQueue();

    balance.newestTransactions.value = [wmpb.TransactionEntry(txid: 'b', amountSats: Int64(7), time: Int64(2))];
    hold.complete();
    await fetch;

    expect(provider.walletTransactions.map((t) => t.txid), ['b', 'a']);
    expect(provider.walletTransactions.last.confirmationTime.height, 1, reason: 'the read keeps its own rows');
  });

  test('a merge adds a new tx and changes nothing twice', () {
    final current = walletTransactionsFromEntries([
      wmpb.TransactionEntry(txid: 'a', amountSats: Int64(5), time: Int64(1)),
    ], {});
    final fresh = [
      wmpb.TransactionEntry(txid: 'b', amountSats: Int64(-7), time: Int64(2)),
      wmpb.TransactionEntry(txid: 'b', amountSats: Int64(6), time: Int64(2)),
    ];
    final merged = mergeNewestTransactions(current, fresh);
    expect(merged!.map((t) => t.txid), ['b', 'a']);
    expect(merged.first.sentSatoshi, Int64(7));
    expect(merged.first.receivedSatoshi, Int64(6));
    expect(mergeNewestTransactions(merged, fresh), isNull);
  });

  test('a block list or peer change does not fetch', () async {
    blockchain.changed();
    await pumpEventQueue();
    expect(wallet.listCalls, 0);
  });
}
