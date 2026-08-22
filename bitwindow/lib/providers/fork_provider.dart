import 'dart:async';

import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

/// One wallet's claimable pre-fork coins, with the exact UTXOs the sweep spends.
class WalletClaim {
  final String walletId;
  final String walletName;
  final int claimableSats;

  /// False for wallets whose claim can't be replay-protected (the enforcer
  /// wallet) — shown for awareness, but not swept.
  final bool replayProtectable;

  /// Multisig policy of the wallet that holds the coins, null for single-sig.
  /// A multisig claim builds a PSBT its cosigners sign, not a broadcast.
  final wmpb.MultisigInfo? multisig;
  final List<bwpb.UnspentOutput> utxos;

  bool get isMultisig => multisig != null;

  WalletClaim({
    required this.walletId,
    required this.walletName,
    required this.claimableSats,
    required this.replayProtectable,
    required this.utxos,
    this.multisig,
  });
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

  /// Estimated wall-clock instant of the next fork. Held stable between
  /// re-anchors; the timer widget ticks the local clock down to it.
  DateTime? forkTargetDate;
  int _anchorBucket = -1;
  int _anchorForkHeight = -1;

  Timer? _timer;
  bool _fetching = false;

  /// Claims that can actually be swept (replay-protected). Excludes the
  /// enforcer wallet, which is detected but not safely claimable.
  List<WalletClaim> get sweepableClaims => claims.where((c) => c.replayProtectable).toList();

  /// Blocks left until the next fork, by header height.
  int get blocksUntilFork => (forkHeight - currentHeaders).clamp(0, forkHeight == 0 ? 0 : forkHeight);

  void init() {
    fetch();
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
    forkTargetDate = null;
    _anchorBucket = -1;
    _anchorForkHeight = -1;
    notifyListeners();
    fetch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
              replayProtectable: c.replayProtectable,
              multisig: _walletReader.wallets.where((w) => w.id == c.walletId).firstOrNull?.multisig,
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

      _updateForkTarget();
      notifyListeners();
    } catch (e) {
      _log.e('ForkProvider.fetch failed: $e');
    } finally {
      _fetching = false;
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

  /// True while at least one sweepable wallet holds a selectable coin. The
  /// claim card hides without one — a card with every coin disabled offers
  /// no action.
  bool get hasSelectableCoins => sweepableClaims.any((c) => defaultClaimInputs(c).isNotEmpty);

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
    final amountSats = inputs.fold<int>(0, (sum, u) => sum + u.valueSats.toInt());
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
      replayProtect: true,
    );
    final draft = await _drafts.create(psbt, walletId: walletId);
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
      // Replay protection is off for now — a plain sweep so the claim flow is
      // testable end-to-end on stock Core (signet/regtest). The replay-protect
      // path (magic version + byte) stays wired behind this flag for later.
      replayProtect: false,
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
