import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/consolidation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/providers/bitcoin_conf_provider.dart';
import 'package:sidechain_core/providers/network_scoped.dart';
import 'package:sidechain_core/providers/wallet_reader_provider.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';
import 'package:sidechain_core/rpcs/orchestrator_wallet_rpc.dart';

const int _freezeChunkSize = 50;

enum ConsolidationRunStatus {
  /// The run waits for the runs before it.
  queued,

  /// BitWindow freezes the coins and broadcasts the transaction.
  sending,

  /// The transaction sits in the mempool and the coins stay frozen.
  pending,

  /// A block holds the transaction and the coins are gone.
  confirmed,

  /// The send failed. BitWindow unfroze the coins.
  failed,

  /// The user stopped the consolidation before this run started.
  stopped,
}

/// One transaction of a consolidation plan, and what happened to it.
class ConsolidationRun {
  final int index;
  final List<String> outpoints;
  final int coinCount;
  final int vbytes;
  final int outputSats;

  ConsolidationRunStatus status;
  String? txid;
  String? error;

  /// True while this run's coins carry a freeze mark.
  bool coinsFrozen = false;

  ConsolidationRun({
    required this.index,
    required this.outpoints,
    required this.coinCount,
    required this.vbytes,
    required this.outputSats,
    this.status = ConsolidationRunStatus.queued,
  });

  /// A failed run holds no confirmed transaction, so the user can start it again.
  bool get canRetry => status == ConsolidationRunStatus.failed;

  /// A run that will not broadcast again can give its coins back. A queued or
  /// sending run may not: the loop broadcasts it later without a new freeze,
  /// so the coins must stay reserved until then.
  ///
  /// A stopped run normally releases on its own. It reaches here only when
  /// that release failed, and those coins must still have a way back.
  bool get canUnfreeze =>
      coinsFrozen &&
      (status == ConsolidationRunStatus.pending ||
          status == ConsolidationRunStatus.failed ||
          status == ConsolidationRunStatus.stopped);
}

/// Runs a [ConsolidationPlan] one transaction at a time and tracks each one.
///
/// The runs live in memory only. The freeze marks live in the database, so a
/// restart still protects the coins of a transaction that waits in the mempool.
class ConsolidationProvider extends ChangeNotifier implements NetworkScoped {
  BitwindowRPC get _rpc => GetIt.I.get<BitwindowRPC>();
  OrchestratorWalletRPC get _wallet => GetIt.I.get<OrchestratorRPC>().wallet;
  CoinSelectionProvider get _coinSelection => GetIt.I.get<CoinSelectionProvider>();
  TransactionProvider get _transactions => GetIt.I.get<TransactionProvider>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();
  BitcoinConfProvider get _conf => GetIt.I.get<BitcoinConfProvider>();

  /// The chain the backend serves now. It changes before the reset callbacks
  /// run, so a write guard reads it instead of a reset counter.
  ///
  /// Every eCash fork carries the same network value, so the fork id joins it.
  /// Without that, a switch between two forks reads as no change at all.
  String get _chain => '${_conf.network.name}/${_conf.ecashNetworkId}';
  Logger get _log => GetIt.I.get<Logger>();

  List<ConsolidationRun> runs = [];
  bool running = false;
  bool _stopRequested = false;

  /// Rises on every active wallet change. The database stays the same, so
  /// cleanup still works after one.
  int _walletGeneration = 0;

  /// The wallet the current runs belong to.
  String? _walletId;

  /// Runs of a chain and wallet the user left. A network switch cannot reach
  /// the old chain's database, so its unsent coins stay frozen there. Keeping
  /// the records gives the user the Unfreeze action back on return.
  final Map<String, List<ConsolidationRun>> _runsByOwner = {};

  /// The chain and wallet [runs] belongs to.
  String? _runsOwner;

  ConsolidationProvider() {
    _transactions.addListener(_syncConfirmations);
    _walletReader.addListener(_onActiveWalletChanged);
    _walletId = _walletReader.activeWalletId;
  }

  @override
  void dispose() {
    _transactions.removeListener(_syncConfirmations);
    _walletReader.removeListener(_onActiveWalletChanged);
    super.dispose();
  }

  /// A run holds one wallet's coins and one wallet's id. Another wallet must
  /// not see those runs, and the loop must not send from the old wallet.
  void _onActiveWalletChanged() {
    final active = _walletReader.activeWalletId;
    if (active == _walletId) {
      return;
    }
    _walletId = active;
    _walletGeneration++;
    _reset();
  }

  /// Outpoints a transaction still waits to spend. The loop broadcasts a
  /// queued transaction without a new freeze, so releasing one of its coins
  /// elsewhere would break that send.
  Set<String> get reservedOutpoints => {
    for (final run in runs)
      if (run.coinsFrozen &&
          (run.status == ConsolidationRunStatus.queued || run.status == ConsolidationRunStatus.sending))
        ...run.outpoints,
  };

  int get sentCount => runs.where((r) => r.txid != null).length;
  int get confirmedCount => runs.where((r) => r.status == ConsolidationRunStatus.confirmed).length;
  int get failedCount => runs.where((r) => r.status == ConsolidationRunStatus.failed).length;

  /// Broadcasts every transaction of [plan]. Each run freezes its coins before
  /// the send, and unfreezes them again when the send fails.
  Future<void> start({
    required String walletId,
    required ConsolidationPlan plan,
  }) async {
    if (running) {
      throw StateError('a consolidation already runs');
    }
    // The runs of the last plan carry its transaction ids, its confirmation
    // tracking, and its Unfreeze actions. A new plan replaces that list, so
    // the old one must settle first.
    if (runs.any((r) => r.status == ConsolidationRunStatus.pending || r.coinsFrozen)) {
      throw StateError(
        'the last consolidation still waits. Let it confirm, or unfreeze its coins, before you start another.',
      );
    }
    if (plan.isEmpty) {
      throw ArgumentError.value(plan, 'plan', 'holds no transaction');
    }

    runs = plan.batches
        .mapIndexed(
          (index, batch) => ConsolidationRun(
            index: index,
            outpoints: batch.outpoints,
            coinCount: batch.inputs.length,
            vbytes: batch.vbytes,
            outputSats: batch.outputSats,
          ),
        )
        .toList();
    _runsOwner = _ownerKey;
    running = true;
    _stopRequested = false;
    notifyListeners();

    // Hold the list and the guards. A network or wallet change replaces them,
    // and this loop must not touch the new state.
    final active = runs;
    final chain = _chain;
    final walletGeneration = _walletGeneration;

    // Freeze every coin of the plan before the first broadcast. A coin of a
    // queued transaction is already committed, so the Send tab must not offer
    // it while an earlier transaction goes out.
    final planned = [for (final run in active) ...run.outpoints];
    try {
      await _setFrozen(planned, true);
      for (final run in active) {
        run.coinsFrozen = true;
      }
    } catch (e) {
      // A freeze that fails part way leaves some coins marked. Give back what
      // the write reached, unless the network moved: the old network's
      // database is out of reach, and the new one holds none of these coins.
      var released = false;
      String? releaseError;
      if (_chain == chain) {
        try {
          await _setFrozen(planned, false, expectedChain: chain);
          released = true;
        } catch (unfreezeError) {
          releaseError = unfreezeError.toString();
          _log.e('consolidation: unfreeze after a failed freeze: $unfreezeError');
        }
      }
      for (final run in active) {
        run.status = ConsolidationRunStatus.failed;
        // A rollback that failed leaves coins marked. The run keeps its
        // Unfreeze action, or those coins have no record at all.
        run.coinsFrozen = !released;
        run.error = releaseError == null ? e.toString() : '$e\nBitWindow could not unfreeze the coins: $releaseError';
      }
      _finish(active);
      return;
    }

    try {
      for (var i = 0; i < active.length; i++) {
        if (_chain != chain || _walletGeneration != walletGeneration) {
          return;
        }
        if (_stopRequested) {
          active[i].status = ConsolidationRunStatus.stopped;
          notifyListeners();
          continue;
        }
        await _send(walletId, active[i], plan.batches[i]);
      }
    } finally {
      // A run that never broadcast gives its coins back.
      await _releaseUnsentRuns(active, chain);
      if (_finish(active) && _chain == chain && _walletGeneration == walletGeneration) {
        await _coinSelection.fetch();
        await _transactions.fetch();
      }
    }
  }

  /// Hands the shared state back, but only while [active] is still the list
  /// this provider tracks. A reset gives it to a replacement run, and a loop
  /// that ends late must not take it from that run.
  bool _finish(List<ConsolidationRun> active) {
    if (!identical(runs, active)) {
      return false;
    }
    running = false;
    notifyListeners();
    return true;
  }

  /// Unfreezes every run that still waits or stopped before it sent. A network
  /// change puts the metadata database out of reach, so nothing happens then.
  Future<void> _releaseUnsentRuns(List<ConsolidationRun> runs, String chain) async {
    for (final run in runs) {
      final unsent = run.status == ConsolidationRunStatus.queued || run.status == ConsolidationRunStatus.stopped;
      if (!unsent || !run.coinsFrozen) {
        continue;
      }

      // Each unfreeze awaits, so the chain can move between two of them. A run
      // this cannot release still records itself, or a queued run comes back
      // frozen with no action at all.
      if (_chain != chain) {
        run.status = ConsolidationRunStatus.failed;
        run.error = _frozenOnTheOldChain;
        continue;
      }
      await _unfreezeQuietly(run, chain);
    }
    notifyListeners();
  }

  static const String _frozenOnTheOldChain =
      'The chain changed before this transaction went out. '
      'The coins stay frozen on the old chain, so unfreeze them there.';

  /// Drops every run when the user changes network. The coins of a broadcast
  /// transaction stay frozen in the old network's database, where they belong.
  @override
  Future<void> onNetworkChanged() async => _reset();

  /// Ends the current run loop and drops its runs.
  void _reset() {
    _stopRequested = true;

    // Park the old records under the chain and wallet they belong to, and
    // pick up whatever the new one left behind.
    final previousOwner = _runsOwner;
    if (previousOwner != null && runs.isNotEmpty) {
      _runsByOwner[previousOwner] = runs;
    }
    _runsOwner = _ownerKey;
    runs = _runsByOwner.remove(_ownerKey) ?? [];

    running = false;
    notifyListeners();
  }

  /// Runs belong to one chain and one wallet together.
  String get _ownerKey => '$_chain|$_walletId';

  /// Sends one run again after a failure.
  Future<void> retry({
    required String walletId,
    required ConsolidationRun run,
    required ConsolidationBatch batch,
  }) async {
    if (!run.canRetry) {
      throw StateError('run ${run.index + 1} is not in a failed state');
    }
    run.error = null;
    await _send(walletId, run, batch);
  }

  /// Gives the coins of a stuck run back to the wallet. The transaction may
  /// still confirm, so the user takes that risk on purpose.
  Future<void> unfreeze(ConsolidationRun run) async {
    await _setFrozen(run.outpoints, false);
    run.coinsFrozen = false;
    // The transaction may confirm while the writes run. A confirmed run must
    // not read as failed, because nothing promotes it back.
    if (run.status == ConsolidationRunStatus.pending) {
      run.status = ConsolidationRunStatus.failed;
      run.error = 'You unfroze the coins. The transaction may still confirm.';
    }
    notifyListeners();
  }

  /// Stops the consolidation after the transaction that runs now.
  void requestStop() {
    _stopRequested = true;
    notifyListeners();
  }

  void clear() {
    if (running) {
      throw StateError('a consolidation still runs');
    }
    // These runs are the only record of the coins they hold. Dropping them
    // would leave those coins frozen with nothing to release them.
    if (runs.any((r) => r.coinsFrozen)) {
      throw StateError('some coins are still frozen. Unfreeze them before you clear these runs.');
    }
    runs = [];
    notifyListeners();
  }

  Future<void> _send(String walletId, ConsolidationRun run, ConsolidationBatch batch) async {
    final chain = _chain;
    final walletGeneration = _walletGeneration;

    run.status = ConsolidationRunStatus.sending;
    notifyListeners();

    final String address;
    try {
      // start() froze every coin of the plan already.
      address = (await _wallet.getNewAddress(
        walletId,
        addressType: addressTypeFor(batch.destinationKind),
      )).address;
    } catch (e) {
      // Nothing reached the node yet, so the coins go back.
      await _failAndUnfreeze(run, chain, e);
      return;
    }

    // A change here cancels the send before any broadcast.
    if (_chain != chain) {
      // The metadata database moved out of reach. Writing would put the old
      // chain's outpoints into the new one, so the freezes stay.
      //
      // The run still has to record what happened. A run parked as sending
      // has no action at all, so the user could never release these coins
      // after returning to this chain.
      run.status = ConsolidationRunStatus.failed;
      run.error = _frozenOnTheOldChain;
      notifyListeners();
      return;
    }
    if (_walletGeneration != walletGeneration) {
      // The same database still holds these outpoints, so give the coins back.
      await _unfreezeQuietly(run, chain);
      run.status = ConsolidationRunStatus.stopped;
      notifyListeners();
      return;
    }

    try {
      final response = await _wallet.sendTransaction(
        walletId: walletId,
        destinations: {address: batch.inputSats},
        feeRateSatPerVbyte: batch.feeRateSatPerVbyte,
        subtractFeeFromAmount: true,
        requiredInputs: batch.inputs,
      );

      // Record the result even when the chain or wallet moved. This writes to
      // the run alone, never to a database, and a run parked as sending has no
      // action at all: it cannot unfreeze, clear, or start another plan.
      run.txid = response.txid;
      run.status = ConsolidationRunStatus.pending;
      notifyListeners();
    } catch (e) {
      // A lost reply does not mean a lost transaction. The node may hold it,
      // so the coins stay frozen and the user releases them on purpose.
      run.status = ConsolidationRunStatus.failed;
      run.error =
          '$e\nThe coins stay frozen, because the node may still hold the transaction. '
          'Unfreeze them once you know it does not.';
      notifyListeners();
    }
  }

  /// Marks a run failed and gives its coins back. Only for a failure before
  /// the broadcast, where no transaction can exist.
  Future<void> _failAndUnfreeze(ConsolidationRun run, String chain, Object error) async {
    // Record first, always. A guard protects a database write, never the run's
    // own record: a run with no record has no action, and its coins no way out.
    run.status = ConsolidationRunStatus.failed;
    run.error = error.toString();

    // A chain change moves the metadata database. Unfreezing would write the
    // old chain's outpoints into the new one, so the coins stay marked there.
    if (_chain != chain) {
      run.error = '${run.error}\n$_frozenOnTheOldChain';
      notifyListeners();
      return;
    }

    try {
      await _setFrozen(run.outpoints, false);
      run.coinsFrozen = false;
    } catch (unfreezeError) {
      run.error = '${run.error}\nBitWindow could not unfreeze the coins: $unfreezeError';
      _log.e('consolidation run ${run.index + 1}: unfreeze after a failed freeze: $unfreezeError');
    }
    notifyListeners();
  }

  /// One RPC per outpoint, in chunks, because a batch holds up to 1448 coins.
  ///
  /// The Send tab filters coins through the metadata cache, so the cache
  /// refreshes here. A stale cache offers a frozen coin for a second spend
  /// while this run still broadcasts.
  Future<void> _setFrozen(List<String> outpoints, bool frozen, {String? expectedChain}) async {
    final chain = expectedChain ?? _chain;

    for (final chunk in outpoints.slices(_freezeChunkSize)) {
      // A chain change between two chunks would write the rest of these
      // outpoints into the new chain's database.
      if (_chain != chain) {
        throw StateError('the chain changed while the coins froze');
      }
      await Future.wait(chunk.map((o) => _rpc.wallet.setUTXOMetadata(o, isFrozen: frozen)));
    }
    await _coinSelection.refresh();
  }

  /// Gives a run's coins back without touching its status. The caller drops
  /// the run, so an error here has nowhere to show.
  Future<void> _unfreezeQuietly(ConsolidationRun run, String chain) async {
    try {
      await _setFrozen(run.outpoints, false, expectedChain: chain);
      run.coinsFrozen = false;
    } catch (e) {
      // The coins stay marked, so the run keeps its Unfreeze action.
      _log.e('consolidation run ${run.index + 1}: unfreeze: $e');
    }
  }

  void _syncConfirmations() {
    // An empty list carries no information. Reading it as "nothing confirms"
    // would revert every run on each refetch.
    if (runs.isEmpty || _transactions.walletTransactions.isEmpty) {
      return;
    }

    final confirmed = <String>{};
    final known = <String>{};
    for (final tx in _transactions.walletTransactions) {
      known.add(tx.txid);
      if (tx.hasConfirmationTime() && tx.confirmationTime.height > 0) {
        confirmed.add(tx.txid);
      }
    }

    var changed = false;
    for (final run in runs) {
      final txid = run.txid;
      if (txid == null) {
        continue;
      }
      final holdsIt = confirmed.contains(txid);

      if (run.status == ConsolidationRunStatus.pending && holdsIt) {
        run.status = ConsolidationRunStatus.confirmed;
        // A block holds the transaction, so the coins are spent. There is
        // nothing left to unfreeze.
        run.coinsFrozen = false;
        changed = true;
      } else if (run.status == ConsolidationRunStatus.confirmed && known.contains(txid) && !holdsIt) {
        // The list still carries the transaction, and it lost its block, so a
        // reorganisation moved it. Its coins may carry a freeze mark again.
        //
        // A transaction that fell out of the list says nothing: the history
        // is bounded, and an old consolidation ages out of it.
        run.status = ConsolidationRunStatus.pending;
        run.coinsFrozen = true;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }
}
