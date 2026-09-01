import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
import 'package:sidechain_core/rpcs/stream_supervisor.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// Reads blind merged mining from the orchestrator. Bidding itself runs in the
/// backend; this provider only starts it, stops it, and shows what it did.
class BMMProvider extends ChangeNotifier {
  final SidechainRPC sidechainRPC;
  final OrchestratorBmmRPC _bmm;
  final WalletReaderProvider? _walletReader;
  final Logger _log;

  StreamSupervisor<bmmpb.WatchResponse>? _supervisor;

  bool running = false;

  /// Rate a bid pays to enter the next mainchain block, in sats per vByte,
  /// from Core's own estimate. The engine opens every bid here, and nobody can
  /// set it lower. The wallet decides the amount from the size it builds.
  double nextBlockFeeRateSatVb = 0;

  /// A bid a node relays, in sats. Core answers no estimate on a fresh node,
  /// and a manual bid of zero is not a bid.
  static const int relayMinimumBidSats = 188;

  /// A starting amount for a manual bid, from the rate and a plain bid's size.
  int get suggestedBidSats {
    final sats = (nextBlockFeeRateSatVb * 188).ceil();
    return sats > relayMinimumBidSats ? sats : relayMinimumBidSats;
  }

  double maxBidAmount = 0.0002;

  String? _selectedWalletId;

  /// Confirmed balance of the funding wallet, null until a fetch lands.
  int? fundingBalanceSats;

  /// Pending push of edited bounds to the backend. While it is armed the watch
  /// stream's values are stale by definition, so they must not overwrite what
  /// the user just typed.
  Timer? _boundsPush;

  /// The round being bid on, absent when no tip has been seen yet.
  bmmpb.Round? current;

  /// Settled rounds, newest first.
  List<bmmpb.Round> history = [];

  String? error;

  BMMProvider({
    SidechainRPC? sidechainRPC,
    OrchestratorBmmRPC? bmm,
    WalletReaderProvider? walletReader,
    Logger? logger,
  }) : sidechainRPC = sidechainRPC ?? GetIt.I.get<SidechainRPC>(),
       _bmm = bmm ?? GetIt.I.get<OrchestratorRPC>().bmm,
       _walletReader =
           walletReader ?? (GetIt.I.isRegistered<WalletReaderProvider>() ? GetIt.I.get<WalletReaderProvider>() : null),
       _log = logger ?? GetIt.I.get<Logger>() {
    _resolvedWalletId = fundingWalletId;
    _walletReader?.addListener(_onWalletsChanged);
    _listen();
    unawaited(refreshFundingBalance());
  }

  String? _resolvedWalletId;

  int get maxBidSats => btcToSatoshi(maxBidAmount);

  /// True while an edited bound is waiting to be pushed. The bid fields read this
  /// so they never overwrite what the user is still typing.
  bool get boundsPushPending => _boundsPush?.isActive ?? false;

  /// Wallet every bid spends from. Selecting it never changes the active
  /// wallet.
  String? get fundingWalletId => _walletReader?.resolveFundingWalletId(_selectedWalletId);

  void setFundingWalletId(String walletId) {
    _selectedWalletId = walletId;
    _resolvedWalletId = fundingWalletId;
    fundingBalanceSats = null;
    notifyListeners();
    unawaited(refreshFundingBalance());
    if (running) {
      unawaited(startBidding());
    }
  }

  /// True once we know the funding wallet cannot cover the highest bid.
  bool get fundingBalanceTooLow {
    final balance = fundingBalanceSats;
    return balance != null && balance < maxBidSats;
  }

  Future<void> refreshFundingBalance() async {
    final walletId = fundingWalletId;
    if (walletId == null) {
      return;
    }
    try {
      final balance = await GetIt.I.get<OrchestratorRPC>().wallet.getBalance(walletId);
      // Another wallet may have been picked while this read was in flight.
      if (walletId != fundingWalletId) {
        return;
      }
      fundingBalanceSats = balance.confirmedSats.round();
      notifyListeners();
    } catch (e) {
      _log.d('BMMProvider: read funding balance: $e');
    }
  }

  void _onWalletsChanged() {
    final resolved = fundingWalletId;
    if (resolved != _resolvedWalletId) {
      _resolvedWalletId = resolved;
      fundingBalanceSats = null;
      unawaited(refreshFundingBalance());
      if (running) {
        unawaited(_retarget(resolved));
      }
    }
    notifyListeners();
  }

  /// The engine keeps bidding from the wallet it started with, so a wallet that
  /// goes away has to move the running loop, not only the display.
  Future<void> _retarget(String? walletId) async {
    if (walletId != null) {
      await startBidding();
      return;
    }
    await stopBidding();
    error = noFundingWallet;
    notifyListeners();
  }

  /// Our live bid for the current round, if any.
  bmmpb.Bid? get liveBid {
    final round = current;
    if (round == null) {
      return null;
    }
    for (final bid in round.ourBids.reversed) {
      if (bid.state == 'live') {
        return bid;
      }
    }
    return null;
  }

  /// Why our newest bid of the current round failed. The auto-bid loop runs in
  /// the backend, so its failures reach the user only through here. An older
  /// failure stays hidden, because a newer bid means the loop recovered.
  String? get lastBidError {
    final newest = current?.ourBids.lastOrNull;
    if (newest == null || newest.state != 'failed' || newest.error.isEmpty) {
      return null;
    }
    return newest.error;
  }

  /// Every bid for the current round, ours and others, highest first.
  List<bmmpb.Bid> get currentBids {
    final round = current;
    if (round == null) {
      return [];
    }
    final bids = [...round.ourBids, ...round.otherBids];
    bids.sort((a, b) => b.bidSats.compareTo(a.bidSats));
    return bids;
  }

  int get wonCount => history.where((r) => r.result == 'won').length;
  int get lostCount => history.where((r) => r.result == 'lost').length;
  int get totalProfitSats => history.where((r) => r.hasProfit).fold(0, (sum, r) => sum + r.profitSats.toInt());

  void setMaxBidAmount(double value) {
    if (value == maxBidAmount) {
      return;
    }
    maxBidAmount = value;
    _scheduleBoundsPush();
    notifyListeners();
  }

  /// A running engine keeps bidding its old bounds until Start is called again,
  /// so an edit has to reach the backend to mean anything. Debounced because
  /// the bid fields push on every keystroke.
  void _scheduleBoundsPush() {
    _boundsPush?.cancel();
    _boundsPush = Timer(const Duration(milliseconds: 600), () {
      if (!running) {
        return;
      }
      unawaited(startBidding());
    });
  }

  void _listen() {
    _supervisor = StreamSupervisor<bmmpb.WatchResponse>(
      subscribe: () => _bmm.watch(sidechainRPC.binaryType),
      onEvent: _apply,
      onTransportDeath: () => GetIt.I.get<OrchestratorRPC>().recreateConnection(),
      logger: _log,
      tag: 'BMMProvider',
    )..start();
  }

  void _apply(bmmpb.WatchResponse state) {
    running = state.running;
    if (state.walletId.isNotEmpty) {
      _selectedWalletId = state.walletId;
    }
    final previousRound = current?.prevMainHash;
    current = state.hasCurrent() ? state.current : null;
    if (current != null && current!.prevMainHash != previousRound) {
      unawaited(refreshFundingBalance());
    }
    history = state.history;
    nextBlockFeeRateSatVb = state.nextBlockFeeRateSatVb;
    final edited = boundsPushPending;
    if (!edited && state.maxBidSats > 0) {
      maxBidAmount = satoshiToBTC(state.maxBidSats.toInt());
    }
    error = null;
    notifyListeners();
  }

  /// Set when no wallet can fund a bid. An empty wallet id would fall back to
  /// the active wallet, which may be one that cannot spend.
  static const noFundingWallet = 'No wallet can fund a bid. A bid needs a wallet that can spend.';

  Future<void> startBidding() async {
    final walletId = fundingWalletId;
    if (walletId == null) {
      error = noFundingWallet;
      notifyListeners();
      return;
    }
    try {
      await _bmm.start(
        sidechain: sidechainRPC.binaryType,
        walletId: walletId,
        maxBidSats: maxBidSats,
      );
      error = null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopBidding() async {
    try {
      await _bmm.stop(sidechainRPC.binaryType);
      error = null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// One bid outside the automated loop, for the manual dialog.
  Future<void> bidManually(int bidSats) async {
    final walletId = fundingWalletId;
    if (walletId == null) {
      error = noFundingWallet;
      notifyListeners();
      return;
    }
    try {
      await _bmm.createBid(sidechain: sidechainRPC.binaryType, walletId: walletId, bidSats: bidSats);
      error = null;
      unawaited(refreshFundingBalance());
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// Every bid seen for one round, for "see all bids for block".
  Future<bmmpb.Round> roundBids(String prevMainHash) {
    return _bmm.roundBids(sidechain: sidechainRPC.binaryType, prevMainHash: prevMainHash);
  }

  Future<void> clearHistory() async {
    try {
      await _bmm.clearHistory(sidechainRPC.binaryType);
      error = null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _walletReader?.removeListener(_onWalletsChanged);
    _boundsPush?.cancel();
    unawaited(_supervisor?.dispose());
    super.dispose();
  }
}
