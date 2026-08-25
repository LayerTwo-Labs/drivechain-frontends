import 'dart:async';

import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/gen/walletpsbt/v1/walletpsbt.pb.dart' as wppb;
import 'package:sail_ui/sail_ui.dart';

/// One wallet's claimable pre-fork coins, with the exact UTXOs the sweep spends.
class WalletClaim {
  final String walletId;
  final String walletName;
  final int claimableSats;

  /// Multisig policy of the wallet that holds the coins, null for single-sig.
  /// A multisig claim builds a PSBT its cosigners sign, not a broadcast.
  final wmpb.MultisigInfo? multisig;

  /// False while the wallet list holds no record of this wallet. Its policy is
  /// unknown, so the claim offers no action until the record arrives.
  final bool walletResolved;
  final List<bwpb.UnspentOutput> utxos;

  bool get isMultisig => multisig != null;

  WalletClaim({
    required this.walletId,
    required this.walletName,
    required this.claimableSats,
    required this.utxos,
    this.multisig,
    this.walletResolved = true,
  });
}

/// The magic nLockTime a replay-protected transaction carries. A patched node
/// treats it as final; stock Bitcoin Core rejects it as non-final.
const int replayLockTime = 499999999;

/// One split draft that waits for signatures, and the coins it spends. A
/// second split of the same coins would make a conflicting draft.
class PendingSplit {
  final String walletId;
  final String draftId;
  final Set<String> outpoints;

  PendingSplit({required this.walletId, required this.draftId, required this.outpoints});
}

/// Thin consumer of the orchestrator's ForkEngine — the single source of truth
/// for fork state. This holds the last [getForkStatus] snapshot and renders it;
/// it does NO fork math (heights, claim detection, the claim-before-countdown
/// gate all live in the engine). The only local concern is smoothing the
/// countdown's local-clock tick.
class ForkProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  OrchestratorRPC get _orchestrator => GetIt.I<OrchestratorRPC>();
  OrchestratorWalletRPC get _wallet => _orchestrator.wallet;
  TransactionProvider get _transactions => GetIt.I<TransactionProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();
  PsbtDraftProvider get _drafts => GetIt.I<PsbtDraftProvider>();
  WalletPsbtAPI get _draftApi => GetIt.I<BitwindowRPC>().walletpsbt;
  BalanceProvider get _balance => GetIt.I<BalanceProvider>();
  Logger get _log => GetIt.I<Logger>();

  /// Fee rate used when sweeping; the fee is subtracted from the swept amount.
  static const _sweepFeeRateSatPerVbyte = 1;

  /// Countdown display assumptions (also used by the engine's height math).
  static const _minutesPerBlock = 10;

  /// Re-anchor the countdown target only when the header height crosses a new
  /// bucket of this many blocks, so the time ticks down smoothly instead of
  /// lurching whenever a block lands.
  static const _reanchorEveryBlocks = 10;

  bool simulated = false;
  int forkHeight = 0;

  /// Name of the fork being counted down to ("Alphanet"), from the published
  /// catalog. Empty until it resolves.
  String networkName = '';
  int currentHeight = 0;
  int currentHeaders = 0;
  int claimBoundary = 0;
  bool hasFundsToClaim = false;
  bool showCountdown = false;
  List<WalletClaim> claims = [];

  /// False until one fork status read succeeds. A coin the split engine did
  /// not report yet cannot be cleared while this is false.
  bool claimsLoaded = false;

  /// True only where a node accepts the magic locktime. Stock Bitcoin Core
  /// reads such a transaction as non-final and rejects it, so a split there
  /// stays a plain transaction.
  bool get replayProtectionAvailable =>
      GetIt.I.get<BitcoinConfProvider>().network == BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  /// Estimated wall-clock instant of the next fork. Held stable between
  /// re-anchors; the timer widget ticks the local clock down to it.
  DateTime? forkTargetDate;
  int _anchorBucket = -1;
  int _anchorForkHeight = -1;

  Timer? _timer;
  bool _fetching = false;
  bool _syncingSplits = false;
  bool _resyncQueued = false;
  bool _disposed = false;

  /// Unsigned drafts that hold coins, with the coins each one spends. Read
  /// back from the saved drafts, so a restart keeps holding them.
  List<PendingSplit> pendingSplits = [];

  /// The PSBT of each draft already read, so one draft is read one time.
  final Map<String, String> _readPsbtByDraft = {};

  /// Coins of a split this session still builds. They hold from the click, so
  /// a second click cannot build a conflicting draft of the same coins.
  final Set<String> _splitsInFlight = {};

  /// Transactions this session sent without protection. Their outputs exist on
  /// both chains, so spending one replays again.
  final Set<String> replayedTxids = {};

  /// Wallets whose drafts the last read did not reach. Their saved drafts can
  /// hold coins, so the claim card offers none of their coins until a read
  /// succeeds.
  Set<String> walletsWithUnreadDrafts = {};

  /// Every pre-fork coin the engine reports, whatever its BTC status. A coin
  /// outside this set came after the fork, so it exists on one chain only.
  Set<String> get claimOutpoints => claims.expand((c) => c.utxos).map((u) => u.output).toSet();

  /// The coins the user hid the claim card for. A new claimable coin brings
  /// the card back.
  Set<String> _dismissedClaimOutpoints = {};

  /// True while the user hid the card and no new claimable coin arrived.
  bool get claimCardDismissed =>
      claimOutpoints.isNotEmpty && claimOutpoints.difference(_dismissedClaimOutpoints).isEmpty;

  /// Hides the claim card until a new claimable coin arrives.
  void dismissClaimCard() {
    _dismissedClaimOutpoints = claimOutpoints;
    notifyListeners();
  }

  /// Every coin a pending split holds.
  Set<String> get pendingSplitOutpoints => {...pendingSplits.expand((p) => p.outpoints), ..._splitsInFlight};

  /// True when this coin can exist on both chains: a pre-fork coin, or an
  /// output of a transaction this session sent without protection.
  bool isReplayRisk(String outpoint) =>
      claimOutpoints.contains(outpoint) || replayedTxids.contains(outpoint.split(':').first);

  /// Records a transaction this session broadcast without replay protection.
  /// Its outputs land on both chains.
  void rememberUnprotectedSend(String txid) {
    if (txid.isEmpty) {
      return;
    }
    replayedTxids.add(txid);
    notifyListeners();
  }

  /// Claims that can actually be swept. Excludes a wallet whose record has not
  /// arrived: a multisig claim must never sweep.
  List<WalletClaim> get sweepableClaims => claims.where((c) => c.walletResolved).toList();

  /// Blocks left until the next fork, by header height.
  int get blocksUntilFork => (forkHeight - currentHeaders).clamp(0, forkHeight == 0 ? 0 : forkHeight);

  void init() {
    fetch();
    // The wallet list carries each claim's policy, so a late list must not wait
    // out the poll.
    _walletReader.addListener(fetch);
    // Any draft can hold a claimable coin, so a save must hold it at once.
    _drafts.addListener(_onDraftsChanged);
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());
  }

  /// Drop cached state on a network swap so the UI never shows the previous
  /// network's fork data, then repopulate. Mirrors the other providers' clear().
  void clear() {
    simulated = false;
    forkHeight = 0;
    networkName = '';
    currentHeight = 0;
    currentHeaders = 0;
    claimBoundary = 0;
    hasFundsToClaim = false;
    showCountdown = false;
    claims = [];
    claimsLoaded = false;
    forkTargetDate = null;
    _anchorBucket = -1;
    _anchorForkHeight = -1;
    pendingSplits = [];
    _readPsbtByDraft.clear();
    _splitsInFlight.clear();
    replayedTxids.clear();
    _dismissedClaimOutpoints = {};
    walletsWithUnreadDrafts = {};
    notifyListeners();
    fetch();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _walletReader.removeListener(fetch);
    _drafts.removeListener(_onDraftsChanged);
    super.dispose();
  }

  void _onDraftsChanged() {
    unawaited(
      _syncPendingSplits().then((_) {
        if (!_disposed) {
          notifyListeners();
        }
      }),
    );
  }

  Future<void> fetch() async {
    if (!GetIt.I.get<BitcoinConfProvider>().drivechainFeaturesAvailable) {
      return;
    }
    if (_fetching) {
      return;
    }
    _fetching = true;
    try {
      final s = await _orchestrator.getForkStatus();
      simulated = s.simulated;
      forkHeight = s.forkHeight;
      networkName = s.networkName;
      currentHeight = s.currentHeight;
      currentHeaders = s.currentHeaders;
      claimBoundary = s.claimBoundary;
      hasFundsToClaim = s.hasFundsToClaim;
      showCountdown = s.showCountdown;
      claims = s.claims
          .map(
            (c) => WalletClaim(
              walletId: c.walletId,
              walletName: c.walletName,
              claimableSats: c.claimableSats.toInt(),
              multisig: _walletReader.wallets.where((w) => w.id == c.walletId).firstOrNull?.multisig,
              walletResolved: _walletReader.wallets.any((w) => w.id == c.walletId),
              utxos: c.utxos
                  .map(
                    (u) => bwpb.UnspentOutput(
                      output: u.outpoint,
                      address: u.address,
                      label: u.label,
                      valueSats: u.sats,
                      height: u.height,
                      splittable: u.hasSplittable() ? u.splittable : null,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

      claimsLoaded = true;
      await _syncPendingSplits();
      _updateForkTarget();
      notifyListeners();
    } catch (e) {
      _log.e('ForkProvider.fetch failed: $e');
    } finally {
      _fetching = false;
    }
  }

  /// The splits that still hold their coins: one whose draft is still on the
  /// send tab, one whose wallet answered nothing, or one this read never saw
  /// because a split saved it while the read ran.
  static List<PendingSplit> keepLivePendingSplits(
    List<PendingSplit> pending,
    Set<String> liveDraftIds,
    Set<String> unreadableWallets,
    Set<String> knownBeforeRead,
  ) => pending
      .where(
        (p) =>
            liveDraftIds.contains(p.draftId) ||
            unreadableWallets.contains(p.walletId) ||
            !knownBeforeRead.contains(p.draftId),
      )
      .toList();

  /// Read the coins each unsigned draft holds, across every wallet with a
  /// claim. A draft that is gone releases the coins it held.
  Future<void> _syncPendingSplits() async {
    if (_syncingSplits) {
      // A draft saved during the read is missing from its listing, so the read
      // runs again after this one.
      _resyncQueued = true;
      return;
    }
    _syncingSplits = true;
    try {
      do {
        _resyncQueued = false;
        await _readPendingSplits();
      } while (_resyncQueued);
    } finally {
      _syncingSplits = false;
    }
  }

  Future<void> _readPendingSplits() async {
    final knownBeforeRead = pendingSplits.map((p) => p.draftId).toSet();
    final listed = <wppb.PsbtDraft>[];
    final unreadable = <String>{};
    for (final walletId in claims.map((c) => c.walletId).toSet()) {
      try {
        listed.addAll(await _draftApi.listDrafts(walletId));
      } catch (e) {
        unreadable.add(walletId);
        _log.e('ForkProvider: could not list the drafts of wallet $walletId: $e');
      }
    }
    walletsWithUnreadDrafts = unreadable;
    final unsigned = listed.where((d) => d.txid.isEmpty).toList();
    final liveIds = unsigned.map((d) => d.id).toSet();
    pendingSplits = keepLivePendingSplits(pendingSplits, liveIds, unreadable, knownBeforeRead);
    _readPsbtByDraft.removeWhere((id, _) => !liveIds.contains(id) && knownBeforeRead.contains(id));

    for (final draft in unsigned) {
      if (_readPsbtByDraft[draft.id] == draft.psbtBase64) {
        continue;
      }
      try {
        final decoded = await _wallet.decodeTransaction(input: draft.psbtBase64, walletId: draft.walletId);
        final outpoints = decoded.details.inputs.map((i) => '${i.prevTxid}:${i.prevVout}').toSet();
        pendingSplits = [
          ...pendingSplits.where((p) => p.draftId != draft.id),
          PendingSplit(walletId: draft.walletId, draftId: draft.id, outpoints: outpoints),
        ];
        _readPsbtByDraft[draft.id] = draft.psbtBase64;
      } catch (e) {
        // The draft holds coins this read did not name, so the wallet stays shut.
        walletsWithUnreadDrafts = {...walletsWithUnreadDrafts, draft.walletId};
        _log.e('ForkProvider: could not read the coins of draft ${draft.id}: $e');
      }
    }
  }

  /// Recompute the countdown target only when the header height enters a new
  /// 10-block bucket OR the fork height changes (a new cycle/network) — keeps
  /// the seconds ticking on the local clock between re-anchors, and resets
  /// cleanly the moment a new fork boundary is set.
  void _updateForkTarget() {
    if (!showCountdown || currentHeaders <= 0 || currentHeaders >= forkHeight) {
      forkTargetDate = null;
      _anchorBucket = -1;
      _anchorForkHeight = -1;
      return;
    }
    final bucket = currentHeaders ~/ _reanchorEveryBlocks;
    if (forkHeight == _anchorForkHeight && bucket == _anchorBucket && forkTargetDate != null) {
      return;
    }

    _anchorForkHeight = forkHeight;
    _anchorBucket = bucket;
    final blocksRemaining = forkHeight - currentHeaders;
    forkTargetDate = DateTime.now().add(Duration(minutes: blocksRemaining * _minutesPerBlock));
  }

  /// True while the BTC-side status is unknown, or once it is known
  /// splittable. Only a confirmed non-splittable coin is excluded — the
  /// split engine reports per coin, so a partial scan must not shrink the
  /// selectable set below the unchecked coins.
  static bool isSelectable(bwpb.UnspentOutput u) => !u.hasSplittable() || u.splittable;

  /// True when every claim in the selection needs cosigner signatures, so the
  /// split ends in a PSBT instead of a broadcast.
  static bool splitNeedsSignatures(Iterable<WalletClaim> selected) =>
      selected.isNotEmpty && selected.every((c) => c.isMultisig);

  /// The coins a claim spends when the user picks none.
  static List<bwpb.UnspentOutput> defaultClaimInputs(WalletClaim claim) => claim.utxos.where(isSelectable).toList();

  /// True while the user can still pick this coin: the BTC side allows it, no
  /// draft of it waits for signatures, and this wallet's drafts are readable.
  bool canSelect(WalletClaim claim, bwpb.UnspentOutput u) =>
      isSelectable(u) && !pendingSplitOutpoints.contains(u.output) && !walletsWithUnreadDrafts.contains(claim.walletId);

  /// The coins of one claim the user can still pick.
  List<bwpb.UnspentOutput> selectableInputs(WalletClaim claim) =>
      claim.utxos.where((u) => canSelect(claim, u)).toList();

  /// True while at least one sweepable wallet holds a selectable coin. The
  /// claim card hides without one — a card with every coin disabled offers
  /// no action.
  bool get hasSelectableCoins => sweepableClaims.any((c) => selectableInputs(c).isNotEmpty);

  /// Every wallet that still holds a coin to claim.
  Set<String> get walletsWithClaims =>
      sweepableClaims.where((c) => selectableInputs(c).isNotEmpty).map((c) => c.walletId).toSet();

  /// The claims of one wallet. The card speaks for the wallet the user has
  /// open; the wallet picker marks the rest.
  List<WalletClaim> claimsForWallet(String? walletId) => walletId == null
      ? const []
      : sweepableClaims.where((c) => c.walletId == walletId && selectableInputs(c).isNotEmpty).toList();

  /// Smallest selected sum a sweep can pay: the post-fee output must stay
  /// above dust. Generous estimate at the 1 sat/vB sweep rate.
  static int minClaimSats(int inputCount) => 546 + 150 + 70 * inputCount;

  /// The coins one claim spends, from the user's selection or the default set.
  List<bwpb.UnspentOutput> _claimInputs(WalletClaim claim, Set<String>? outpoints) {
    final inputs = outpoints == null
        ? defaultClaimInputs(claim)
        : claim.utxos.where((u) => outpoints.contains(u.output)).toList();
    if (inputs.isEmpty) {
      throw Exception('no claimable coins selected');
    }
    final amountSats = inputs.fold<int>(0, (sum, u) => sum + u.valueSats.toInt());
    if (amountSats < minClaimSats(inputs.length)) {
      throw Exception('selected amount is too small to pay the sweep fee');
    }
    return inputs;
  }

  /// Build the split of one multisig wallet's pre-fork coins and file it as a
  /// draft. The cosigners sign it on the send tab; nothing is broadcast here.
  /// Returns the draft id.
  Future<String> createSplitDraft(String walletId, {Set<String>? outpoints}) async {
    final claim = claims.firstWhere((c) => c.walletId == walletId);
    final inputs = _claimInputs(claim, outpoints);
    final reserved = inputs.map((u) => u.output).toSet();
    if (reserved.any(pendingSplitOutpoints.contains)) {
      throw Exception('a split of these coins is already under way');
    }
    // Hold the coins from here, so a second click builds nothing.
    _splitsInFlight.addAll(reserved);
    notifyListeners();
    try {
      return await _buildSplitDraft(claim, inputs);
    } finally {
      _splitsInFlight.removeAll(reserved);
      notifyListeners();
    }
  }

  Future<String> _buildSplitDraft(WalletClaim claim, List<bwpb.UnspentOutput> inputs) async {
    final walletId = claim.walletId;
    final amountSats = inputs.fold<int>(0, (sum, u) => sum + u.valueSats.toInt());
    final generation = _drafts.generation;
    final address = (await _wallet.getNewAddress(walletId)).address;

    _log.i(
      'Splitting eCash in multisig: wallet="${claim.walletName}" id=$walletId '
      'amount=$amountSats sats inputs=${inputs.length} -> $address',
    );

    final psbt = await _wallet.createPsbt(
      walletId: walletId,
      destinations: {address: amountSats},
      requiredInputs: inputs,
      subtractFeeFromAmount: true,
      feeRateSatPerVbyte: _sweepFeeRateSatPerVbyte,
    );
    if (_drafts.generation != generation) {
      throw Exception('The network changed during the build. Create the split transaction again.');
    }
    final draft = await _drafts.create(psbt, walletId: walletId);
    pendingSplits = [
      ...pendingSplits,
      PendingSplit(walletId: walletId, draftId: draft.id, outpoints: inputs.map((u) => u.output).toSet()),
    ];
    _readPsbtByDraft[draft.id] = psbt;
    notifyListeners();
    _log.i('Split draft created: wallet="${claim.walletName}" id=$walletId draft=${draft.id}');
    return draft.id;
  }

  /// Sweep one wallet's pre-fork coins (from the engine's UTXO list) to a fresh
  /// address it controls — one sendTransaction, exactly like a send. Returns txid.
  Future<String> claim(String walletId, {Set<String>? outpoints}) async {
    final claim = claims.firstWhere((c) => c.walletId == walletId);
    final inputs = _claimInputs(claim, outpoints);
    final amountSats = inputs.fold<int>(0, (sum, u) => sum + u.valueSats.toInt());
    final address = (await _wallet.getNewAddress(walletId)).address;

    _log.i(
      'Claiming eCash: wallet="${claim.walletName}" id=$walletId '
      'amount=$amountSats sats inputs=${inputs.length} -> $address',
    );

    final txid = (await _wallet.sendTransaction(
      walletId: walletId,
      destinations: {address: amountSats},
      requiredInputs: inputs,
      subtractFeeFromAmount: true,
      feeRateSatPerVbyte: _sweepFeeRateSatPerVbyte,
    )).txid;

    _log.i('Claimed eCash: wallet="${claim.walletName}" id=$walletId txid=$txid -> $address');

    // Refresh the wallet views so the swept tx + new balance show immediately,
    // like the normal send path does — otherwise they stay stale until a poll.
    await fetch();
    await _transactions.fetch();
    await _balance.fetch();
    return txid;
  }
}
