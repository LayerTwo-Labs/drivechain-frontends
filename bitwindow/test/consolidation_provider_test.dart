import 'dart:async';

import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/consolidation_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/consolidation.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'mocks/api_mock.dart';

UnspentOutput coin(String id, int sats) =>
    UnspentOutput(output: '$id:0', valueSats: Int64(sats), address: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4');

/// Records every freeze call so a test can read the order of events.
class _RecordingWallet extends MockWalletAPI {
  final List<String> frozen = [];
  final List<String> unfrozen = [];
  Future<void> Function()? onFreeze;
  bool failUnfreeze = false;
  Future<void> Function()? onUnfreeze;

  /// Fails the freeze once this many outpoints froze. -1 never fails.
  int failFreezeAfter = -1;

  @override
  Future<void> setUTXOMetadata(String outpoint, {bool? isFrozen, String? label}) async {
    if (isFrozen == true) {
      if (failFreezeAfter >= 0 && frozen.length >= failFreezeAfter) {
        throw Exception('the database refused the freeze');
      }
      frozen.add(outpoint);
      await onFreeze?.call();
    }
    if (isFrozen == false) {
      if (failUnfreeze) {
        throw Exception('the database refused the unfreeze');
      }
      unfrozen.add(outpoint);
      await onUnfreeze?.call();
    }
  }
}

class _FakeBitwindow extends MockAPI {
  final _RecordingWallet recordingWallet = _RecordingWallet();

  _FakeBitwindow() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  @override
  WalletAPI get wallet => recordingWallet;
}

class _FakeWalletRPC implements OrchestratorWalletRPC {
  bool failSend = false;
  bool failAddress = false;
  Future<void> Function()? onSend;
  Future<void> Function()? onGetNewAddress;
  final List<int> sentAmounts = [];
  final List<bool> subtractFlags = [];
  final List<int> inputCounts = [];
  final List<wmpb.AddressType?> addressTypes = [];

  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId, {wmpb.AddressType? addressType}) async {
    addressTypes.add(addressType);
    await onGetNewAddress?.call();
    if (failAddress) {
      throw Exception('the wallet gave no address');
    }
    return wmpb.GetNewAddressResponse(address: 'tb1qfresh');
  }

  @override
  Future<wmpb.SendTransactionResponse> sendTransaction({
    required String walletId,
    required Map<String, int> destinations,
    int? feeRateSatPerVbyte,
    int? fixedFeeSats,
    bool subtractFeeFromAmount = false,
    String? opReturnMessage,
    String? opReturnHex,
    List<UnspentOutput>? requiredInputs,
    bool allowReplay = false,
  }) async {
    if (failSend) {
      throw Exception('node refused the transaction');
    }
    await onSend?.call();
    sentAmounts.add(destinations.values.first);
    subtractFlags.add(subtractFeeFromAmount);
    inputCounts.add(requiredInputs?.length ?? 0);
    return wmpb.SendTransactionResponse(txid: 'txid${sentAmounts.length}');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final _FakeWalletRPC wallet = _FakeWalletRPC();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCoinSelection extends ChangeNotifier implements CoinSelectionProvider {
  int fetchCount = 0;

  @override
  Future<void> fetch() async => fetchCount++;

  @override
  Future<void> refresh() async => fetchCount++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  String ecashNetworkId = 'alphanet';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet';

  void switchTo(String id) {
    activeWalletId = id;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  @override
  List<WalletTransaction> walletTransactions = [];

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeBitwindow bitwindow;
  late _FakeOrchestrator orchestrator;
  late _FakeTransactions transactions;
  late _FakeCoinSelection coinSelection;
  late _FakeWalletReader walletReader;
  late _FakeConf conf;
  late ConsolidationProvider provider;

  ConsolidationPlan planOf(List<UnspentOutput> coins, {int feeRate = 1}) =>
      planConsolidation(coins: coins, feeRateSatPerVbyte: feeRate);

  setUp(() async {
    await GetIt.I.reset();
    bitwindow = _FakeBitwindow();
    orchestrator = _FakeOrchestrator();
    transactions = _FakeTransactions();
    GetIt.I.registerSingleton<Logger>(Logger());
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    coinSelection = _FakeCoinSelection();
    GetIt.I.registerSingleton<CoinSelectionProvider>(coinSelection);
    GetIt.I.registerSingleton<TransactionProvider>(transactions);
    walletReader = _FakeWalletReader();
    GetIt.I.registerSingleton<WalletReaderProvider>(walletReader);
    conf = _FakeConf();
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    provider = ConsolidationProvider();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('freezes every coin of a run before it sends the transaction', () async {
    final coins = [coin('a', 50000), coin('b', 50000), coin('c', 50000)];

    await provider.start(walletId: 'wallet', plan: planOf(coins));

    expect(bitwindow.recordingWallet.frozen, ['a:0', 'b:0', 'c:0']);
    expect(bitwindow.recordingWallet.unfrozen, isEmpty);
    expect(provider.runs.single.status, ConsolidationRunStatus.pending);
    expect(provider.runs.single.txid, 'txid1');
  });

  // A queued transaction's coins are already committed. The Send tab must not
  // offer them while an earlier transaction goes out.
  test('freezes the coins of every queued transaction before the first send', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final plan = planOf(List.generate(perTransaction * 2, (i) => coin('tx$i', 50000)));
    expect(plan.transactionCount, 2);

    var frozenAtFirstSend = 0;
    orchestrator.wallet.onSend = () async {
      frozenAtFirstSend = frozenAtFirstSend == 0 ? bitwindow.recordingWallet.frozen.length : frozenAtFirstSend;
    };

    await provider.start(walletId: 'wallet', plan: plan);

    expect(frozenAtFirstSend, plan.coinCount, reason: 'the second transaction holds its coins already');
  });

  test('gives back the coins of a transaction the user stopped', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final plan = planOf(List.generate(perTransaction * 2, (i) => coin('tx$i', 50000)));

    orchestrator.wallet.onSend = () async => provider.requestStop();

    await provider.start(walletId: 'wallet', plan: plan);

    expect(provider.runs.first.status, ConsolidationRunStatus.pending);
    expect(provider.runs.last.status, ConsolidationRunStatus.stopped);
    expect(provider.runs.last.coinsFrozen, isFalse);
    expect(bitwindow.recordingWallet.unfrozen, hasLength(plan.batches.last.inputs.length));
  });

  test('subtracts the fee from the one output and adds no other coin', () async {
    final coins = [coin('a', 50000), coin('b', 50000)];
    final plan = planOf(coins);

    await provider.start(walletId: 'wallet', plan: plan);

    expect(orchestrator.wallet.subtractFlags, [true]);
    expect(orchestrator.wallet.sentAmounts, [plan.batches.single.inputSats]);
    expect(orchestrator.wallet.inputCounts, [2]);
  });

  // A freeze that fails part way must not leave coins frozen for a
  // transaction that never goes out.
  test('unfreezes the coins again when the freeze itself fails', () async {
    bitwindow.recordingWallet.failFreezeAfter = 1;

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(provider.runs.single.status, ConsolidationRunStatus.failed);
    expect(bitwindow.recordingWallet.unfrozen, containsAll(['a:0', 'b:0']));
    expect(orchestrator.wallet.sentAmounts, isEmpty, reason: 'the send never runs');
    expect(provider.runs.single.canUnfreeze, isFalse);
  });

  test('gives back every coin when the first freeze fails', () async {
    bitwindow.recordingWallet.failFreezeAfter = 2;
    final plan = planOf([coin('a', 50000), coin('b', 50000), coin('c', 50000)]);

    await provider.start(walletId: 'wallet', plan: plan);

    expect(provider.runs.single.status, ConsolidationRunStatus.failed);
    expect(provider.runs.single.coinsFrozen, isFalse);
    expect(orchestrator.wallet.sentAmounts, isEmpty);
  });

  // A lost reply does not mean a lost transaction. Unfreezing here would let
  // the Send tab spend inputs of a transaction the node already holds.
  test('keeps the coins frozen when the send fails', () async {
    orchestrator.wallet.failSend = true;

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(bitwindow.recordingWallet.frozen, ['a:0', 'b:0']);
    expect(bitwindow.recordingWallet.unfrozen, isEmpty);
    expect(provider.runs.single.status, ConsolidationRunStatus.failed);
    expect(provider.runs.single.error, contains('node refused'));
    expect(provider.runs.single.canUnfreeze, isTrue, reason: 'the user can release them');
  });

  test('gives the coins back when the address request fails', () async {
    orchestrator.wallet.failAddress = true;

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(bitwindow.recordingWallet.unfrozen, ['a:0', 'b:0']);
    expect(provider.runs.single.status, ConsolidationRunStatus.failed);
    expect(provider.runs.single.canUnfreeze, isFalse, reason: 'nothing stays frozen');
  });

  // A wallet switch between the address request and the broadcast must stop
  // the send, or it spends the coins of the wallet the user left.
  test('does not broadcast when the wallet changes during the address request', () async {
    orchestrator.wallet.onGetNewAddress = () async => walletReader.switchTo('another wallet');

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(orchestrator.wallet.sentAmounts, isEmpty);
    expect(provider.runs, isEmpty);
    // The same database still holds these outpoints, and the run record is
    // gone, so the coins must not stay frozen with no way to release them.
    expect(bitwindow.recordingWallet.unfrozen, ['a:0', 'b:0']);
  });

  // A network change moves the database. The old outpoints must not land in
  // the new one, so the freeze stops instead.
  test('stops the freeze when the network changes between chunks', () async {
    bitwindow.recordingWallet.onFreeze = () async {
      if (bitwindow.recordingWallet.frozen.length >= 50) {
        conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
        await provider.onNetworkChanged();
      }
    };
    final many = List.generate(120, (i) => coin('tx$i', 50000));

    await provider.start(walletId: 'wallet', plan: planOf(many));

    expect(bitwindow.recordingWallet.frozen.length, lessThan(120), reason: 'the freeze stops part way');
    expect(orchestrator.wallet.sentAmounts, isEmpty, reason: 'nothing broadcasts');
    expect(bitwindow.recordingWallet.unfrozen, isEmpty, reason: 'no write reaches the new database');
  });

  test('asks for the address type the plan sized', () async {
    final plan = planConsolidation(
      coins: [coin('a', 50000), coin('b', 50000)],
      feeRateSatPerVbyte: 1,
      destinationKind: CoinScriptKind.p2wpkh,
    );

    await provider.start(walletId: 'wallet', plan: plan);

    expect(orchestrator.wallet.addressTypes, [wmpb.AddressType.ADDRESS_TYPE_SEGWIT]);
  });

  test('splits a wallet that holds more coins than one transaction takes', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final coins = List.generate(perTransaction + 10, (i) => coin('tx$i', 50000));

    await provider.start(walletId: 'wallet', plan: planOf(coins));

    expect(provider.runs, hasLength(2));
    expect(provider.runs.first.coinCount, perTransaction);
    expect(provider.runs.last.coinCount, 10);
    expect(orchestrator.wallet.inputCounts, [perTransaction, 10]);
  });

  test('marks a run confirmed when a block holds its transaction', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));
    expect(provider.runs.single.status, ConsolidationRunStatus.pending);

    transactions.walletTransactions = [
      WalletTransaction(txid: 'txid1', confirmationTime: Confirmation(height: 900000)),
    ];
    transactions.notifyListeners();

    expect(provider.runs.single.status, ConsolidationRunStatus.confirmed);
    // The coins are spent, so there is nothing left to unfreeze.
    expect(provider.runs.single.canUnfreeze, isFalse);
  });

  // A network change moves the backend and the metadata database. A run loop
  // from the old network must not send against the new one.
  test('drops the runs and stops the loop when the network changes', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final many = List.generate(perTransaction * 2, (i) => coin('tx$i', 50000));
    final plan = planOf(many);
    expect(plan.transactionCount, greaterThan(1));

    orchestrator.wallet.onSend = () async {
      conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      await provider.onNetworkChanged();
    };

    await provider.start(walletId: 'wallet', plan: plan);

    expect(orchestrator.wallet.sentAmounts, hasLength(1), reason: 'the loop stops after the first send');
    expect(provider.runs, isEmpty);
    expect(provider.running, isFalse);
  });

  // The Send tab filters coins through the metadata cache. A stale cache
  // offers a frozen coin for a second spend while this run still broadcasts.
  test('refreshes the frozen coin cache before it broadcasts', () async {
    var fetchesAtSend = -1;
    orchestrator.wallet.onSend = () async => fetchesAtSend = coinSelection.fetchCount;

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(fetchesAtSend, greaterThanOrEqualTo(1), reason: 'the freeze refreshes the cache before the send');
  });

  // A network change moves the metadata database. Cleanup must not write the
  // old network's outpoints into the new network's database.
  test('does not unfreeze against the network that replaced the old one', () async {
    orchestrator.wallet.onSend = () async {
      conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      await provider.onNetworkChanged();
      throw Exception('node refused the transaction');
    };

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(bitwindow.recordingWallet.frozen, ['a:0', 'b:0']);
    expect(bitwindow.recordingWallet.unfrozen, isEmpty);
    expect(provider.runs, isEmpty);
  });

  // A run holds one wallet's coins. Another wallet must not see those runs,
  // and the loop must not keep sending from the old wallet.
  test('drops the runs and stops the loop when the active wallet changes', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final plan = planOf(List.generate(perTransaction * 2, (i) => coin('tx$i', 50000)));
    expect(plan.transactionCount, greaterThan(1));

    orchestrator.wallet.onSend = () async => walletReader.switchTo('another wallet');

    await provider.start(walletId: 'wallet', plan: plan);

    expect(orchestrator.wallet.sentAmounts, hasLength(1), reason: 'the loop stops after the first send');
    expect(provider.runs, isEmpty);
    expect(provider.running, isFalse);
  });

  // The reset callbacks run in registration order, so this provider can hear
  // about a network change late. The guard reads the live network instead.
  test('stops the freeze on the network value, before any reset callback', () async {
    bitwindow.recordingWallet.onFreeze = () async {
      if (bitwindow.recordingWallet.frozen.length >= 50) {
        conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      }
    };
    final many = List.generate(120, (i) => coin('tx$i', 50000));

    await provider.start(walletId: 'wallet', plan: planOf(many));

    expect(bitwindow.recordingWallet.frozen.length, lessThan(120));
    expect(orchestrator.wallet.sentAmounts, isEmpty);
    expect(bitwindow.recordingWallet.unfrozen, isEmpty);
  });

  // A run that still sends may broadcast after an unfreeze, so the action
  // must not appear until the send settles.
  test('offers no unfreeze while the send is in flight', () async {
    ConsolidationRunStatus? statusAtSend;
    bool? frozenAtSend;
    bool? unfreezableAtSend;
    orchestrator.wallet.onSend = () async {
      final run = provider.runs.single;
      statusAtSend = run.status;
      frozenAtSend = run.coinsFrozen;
      unfreezableAtSend = run.canUnfreeze;
    };

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(statusAtSend, ConsolidationRunStatus.sending);
    expect(frozenAtSend, isTrue, reason: 'the coins are frozen already');
    expect(unfreezableAtSend, isFalse, reason: 'the broadcast can still follow');
  });

  // Every eCash fork carries the same network value, so a guard that reads
  // only the enum sees no change when the user moves between two forks.
  test('stops the freeze when the eCash fork changes', () async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
    bitwindow.recordingWallet.onFreeze = () async {
      if (bitwindow.recordingWallet.frozen.length >= 50) {
        conf.ecashNetworkId = 'drynet2';
      }
    };
    final many = List.generate(120, (i) => coin('tx$i', 50000));

    await provider.start(walletId: 'wallet', plan: planOf(many));

    expect(bitwindow.recordingWallet.frozen.length, lessThan(120), reason: 'the freeze stops part way');
    expect(orchestrator.wallet.sentAmounts, isEmpty);
    expect(bitwindow.recordingWallet.unfrozen, isEmpty, reason: 'no write reaches the new fork');
  });

  // Coins that stay frozen must keep a record, or the user cannot release
  // them from the progress card.
  test('keeps the freeze flag when the rollback fails', () async {
    bitwindow.recordingWallet.failFreezeAfter = 1;
    bitwindow.recordingWallet.failUnfreeze = true;

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    final run = provider.runs.single;
    expect(run.status, ConsolidationRunStatus.failed);
    expect(run.coinsFrozen, isTrue);
    expect(run.canUnfreeze, isTrue);
    expect(run.error, contains('could not unfreeze'));
  });

  // Every queued run holds frozen coins already. The loop broadcasts it later
  // without a new freeze, so releasing it early leaves the send unreserved.
  test('offers no unfreeze on a transaction that has not sent', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final plan = planOf(List.generate(perTransaction * 2, (i) => coin('tx$i', 50000)));

    ConsolidationRunStatus? queuedStatus;
    bool? queuedUnfreezable;
    orchestrator.wallet.onSend = () async {
      if (orchestrator.wallet.sentAmounts.isEmpty) {
        final queued = provider.runs.last;
        queuedStatus = queued.status;
        queuedUnfreezable = queued.canUnfreeze;
      }
    };

    await provider.start(walletId: 'wallet', plan: plan);

    expect(queuedStatus, ConsolidationRunStatus.queued);
    expect(queuedUnfreezable, isFalse);
  });

  // A reset hands the shared state to a replacement run. A loop that ends
  // late must not take it back and free the new run's tracking.
  test('a stale loop leaves the replacement run alone', () async {
    final gate = Completer<void>();
    bitwindow.recordingWallet.onFreeze = () async {
      if (bitwindow.recordingWallet.frozen.length == 1) {
        await gate.future;
      }
    };

    final stale = provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));
    await Future<void>.delayed(Duration.zero);

    conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
    await provider.onNetworkChanged();
    bitwindow.recordingWallet.onFreeze = null;

    final replacement = provider.start(walletId: 'wallet', plan: planOf([coin('c', 50000), coin('d', 50000)]));
    gate.complete();
    await Future.wait([stale, replacement]);

    expect(provider.runs, hasLength(1));
    expect(provider.runs.single.txid, isNotNull, reason: 'the replacement run keeps its record');
  });

  // The old runs carry the transaction ids and the Unfreeze actions. A new
  // plan replaces that list, so the old one must settle first.
  test('refuses a second plan while the first still waits', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));
    expect(provider.runs.single.status, ConsolidationRunStatus.pending);

    expect(
      () => provider.start(walletId: 'wallet', plan: planOf([coin('c', 50000), coin('d', 50000)])),
      throwsStateError,
    );
    expect(provider.runs.single.txid, 'txid1', reason: 'the first run keeps its record');
  });

  test('refuses to clear runs that still hold frozen coins', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    expect(provider.clear, throwsStateError);
    expect(provider.runs, hasLength(1));
  });

  test('starts another plan once the first confirms', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    transactions.walletTransactions = [
      WalletTransaction(txid: 'txid1', confirmationTime: Confirmation(height: 900000)),
    ];
    transactions.notifyListeners();
    provider.clear();

    await provider.start(walletId: 'wallet', plan: planOf([coin('c', 50000), coin('d', 50000)]));

    expect(provider.runs.single.txid, 'txid2');
  });

  // A stopped run releases on its own. It keeps the flag only when that
  // release failed, and those coins must still have a way back.
  test('offers unfreeze on a stopped run whose release failed', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final plan = planOf(List.generate(perTransaction * 2, (i) => coin('tx$i', 50000)));

    orchestrator.wallet.onSend = () async {
      provider.requestStop();
      bitwindow.recordingWallet.failUnfreeze = true;
    };

    await provider.start(walletId: 'wallet', plan: plan);

    final stopped = provider.runs.last;
    expect(stopped.status, ConsolidationRunStatus.stopped);
    expect(stopped.coinsFrozen, isTrue);
    expect(stopped.canUnfreeze, isTrue, reason: 'the coins must have a way back');
  });

  // A network switch cannot reach the old chain's database, so its unsent
  // coins stay frozen there. The records must come back with the chain.
  test('gives the runs back when the user returns to the chain', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));
    expect(provider.runs.single.txid, 'txid1');

    conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
    await provider.onNetworkChanged();
    expect(provider.runs, isEmpty, reason: 'the other chain has no runs');

    conf.network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    await provider.onNetworkChanged();

    expect(provider.runs, hasLength(1));
    expect(provider.runs.single.txid, 'txid1');
    expect(provider.runs.single.canUnfreeze, isTrue);
  });

  test("keeps each wallet's runs apart", () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    walletReader.switchTo('other');
    expect(provider.runs, isEmpty);

    walletReader.switchTo('wallet');
    expect(provider.runs.single.txid, 'txid1');
  });

  // A reorganisation can put a confirmed transaction back in the mempool.
  // The run must follow it, or its coins lose their record.
  test('reverts a confirmed run when the transaction leaves the chain', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    transactions.walletTransactions = [
      WalletTransaction(txid: 'txid1', confirmationTime: Confirmation(height: 900000)),
    ];
    transactions.notifyListeners();
    expect(provider.runs.single.status, ConsolidationRunStatus.confirmed);

    transactions.walletTransactions = [WalletTransaction(txid: 'txid1')];
    transactions.notifyListeners();

    expect(provider.runs.single.status, ConsolidationRunStatus.pending);
    expect(provider.runs.single.canUnfreeze, isTrue, reason: 'the coins may carry a mark again');
  });

  test('reads an empty transaction list as no information', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    transactions.walletTransactions = [
      WalletTransaction(txid: 'txid1', confirmationTime: Confirmation(height: 900000)),
    ];
    transactions.notifyListeners();

    transactions.walletTransactions = [];
    transactions.notifyListeners();

    expect(provider.runs.single.status, ConsolidationRunStatus.confirmed, reason: 'a refetch reverts nothing');
  });

  // A transaction may confirm while the unfreeze writes run. Nothing promotes
  // a failed run back, so the confirmation must survive.
  test('keeps a confirmation that lands during an unfreeze', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));
    final run = provider.runs.single;

    bitwindow.recordingWallet.onUnfreeze = () async {
      transactions.walletTransactions = [
        WalletTransaction(txid: 'txid1', confirmationTime: Confirmation(height: 900000)),
      ];
      transactions.notifyListeners();
    };

    await provider.unfreeze(run);

    expect(run.status, ConsolidationRunStatus.confirmed);
    expect(run.coinsFrozen, isFalse);
  });

  // A run parked as sending has no action at all, so a broadcast that
  // happened must show on it.
  test('records a broadcast that lands after the chain moves', () async {
    orchestrator.wallet.onSend = () async {
      conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      await provider.onNetworkChanged();
    };

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    conf.network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    await provider.onNetworkChanged();

    final parked = provider.runs.single;
    expect(parked.status, ConsolidationRunStatus.pending);
    expect(parked.txid, 'txid1');
    expect(parked.canUnfreeze, isTrue, reason: 'the coins have a way back');
  });

  // The history is bounded. An old consolidation ages out of it, and that is
  // not evidence of a reorganisation.
  test('leaves a confirmed run alone when it ages out of the history', () async {
    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    transactions.walletTransactions = [
      WalletTransaction(txid: 'txid1', confirmationTime: Confirmation(height: 900000)),
    ];
    transactions.notifyListeners();
    expect(provider.runs.single.status, ConsolidationRunStatus.confirmed);

    transactions.walletTransactions = [WalletTransaction(txid: 'someone else')];
    transactions.notifyListeners();

    expect(provider.runs.single.status, ConsolidationRunStatus.confirmed);
    expect(provider.runs.single.canUnfreeze, isFalse);
  });

  // A run parked as sending has no action at all. A cancellation before the
  // broadcast must record itself, or the coins are stuck on return.
  test('records a chain change that cancels before the broadcast', () async {
    orchestrator.wallet.onGetNewAddress = () async {
      conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      await provider.onNetworkChanged();
    };

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    conf.network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    await provider.onNetworkChanged();

    final parked = provider.runs.single;
    expect(parked.status, ConsolidationRunStatus.failed);
    expect(parked.coinsFrozen, isTrue, reason: 'no write reached the old chain');
    expect(parked.canUnfreeze, isTrue, reason: 'the coins have a way back');
    expect(orchestrator.wallet.sentAmounts, isEmpty);
  });

  test('marks a wallet change that cancels before the broadcast', () async {
    orchestrator.wallet.onGetNewAddress = () async => walletReader.switchTo('other');

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    walletReader.switchTo('wallet');

    final parked = provider.runs.single;
    expect(parked.status, ConsolidationRunStatus.stopped);
    expect(parked.coinsFrozen, isFalse, reason: 'the same database gave them back');
  });

  // The loop broadcasts a queued transaction without freezing again, so its
  // coins must not be released anywhere else.
  test('reports the coins a queued transaction still waits to spend', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final plan = planOf(List.generate(perTransaction * 2, (i) => coin('tx$i', 50000)));

    Set<String> reservedAtFirstSend = {};
    orchestrator.wallet.onSend = () async {
      reservedAtFirstSend = reservedAtFirstSend.isEmpty ? provider.reservedOutpoints : reservedAtFirstSend;
    };

    await provider.start(walletId: 'wallet', plan: plan);

    expect(reservedAtFirstSend, containsAll(plan.batches.last.outpoints), reason: 'the queued coins are held');
    expect(provider.reservedOutpoints, isEmpty, reason: 'a broadcast run holds none');
  });

  // A guard protects a database write, never the run's own record. A run with
  // no record has no action, and its coins no way out.
  test('records a queued run the chain change left behind', () async {
    final perTransaction = planOf(List.generate(6000, (i) => coin('tx$i', 50000))).batches.first.inputs.length;
    final plan = planOf(List.generate(perTransaction * 2, (i) => coin('tx$i', 50000)));

    orchestrator.wallet.onSend = () async {
      conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      await provider.onNetworkChanged();
    };

    await provider.start(walletId: 'wallet', plan: plan);

    conf.network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    await provider.onNetworkChanged();

    final queued = provider.runs.last;
    expect(queued.status, ConsolidationRunStatus.failed, reason: 'a queued run has no action of its own');
    expect(queued.coinsFrozen, isTrue);
    expect(queued.canUnfreeze, isTrue);
    expect(bitwindow.recordingWallet.unfrozen, isEmpty, reason: 'no write reached the new chain');
  });

  test('records an address failure the chain change left behind', () async {
    orchestrator.wallet.failAddress = true;
    orchestrator.wallet.onGetNewAddress = () async {
      conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
      await provider.onNetworkChanged();
    };

    await provider.start(walletId: 'wallet', plan: planOf([coin('a', 50000), coin('b', 50000)]));

    conf.network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    await provider.onNetworkChanged();

    final parked = provider.runs.single;
    expect(parked.status, ConsolidationRunStatus.failed);
    expect(parked.canUnfreeze, isTrue, reason: 'the coins have a way back');
    expect(bitwindow.recordingWallet.unfrozen, isEmpty);
  });

  test('refuses an empty plan', () async {
    expect(
      () => provider.start(walletId: 'wallet', plan: planOf([coin('only', 50000)])),
      throwsArgumentError,
    );
  });
}
