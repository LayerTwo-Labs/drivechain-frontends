import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
import 'package:sail_ui/rpcs/stream_supervisor.dart';
import 'package:sail_ui/sail_ui.dart';

/// Reads blind merged mining from the orchestrator. Bidding itself runs in the
/// backend; this provider only starts it, stops it, and shows what it did.
class BMMProvider extends ChangeNotifier {
  final SidechainRPC sidechainRPC;
  final OrchestratorBmmRPC _bmm;
  final Logger _log;

  StreamSupervisor<bmmpb.WatchResponse>? _supervisor;

  bool running = false;
  double minBidAmount = 0.00005;
  double maxBidAmount = 0.0002;

  /// The round being bid on, absent when no tip has been seen yet.
  bmmpb.Round? current;

  /// Settled rounds, newest first.
  List<bmmpb.Round> history = [];

  String? error;

  BMMProvider({
    SidechainRPC? sidechainRPC,
    OrchestratorBmmRPC? bmm,
    Logger? logger,
  }) : sidechainRPC = sidechainRPC ?? GetIt.I.get<SidechainRPC>(),
       _bmm = bmm ?? GetIt.I.get<OrchestratorRPC>().bmm,
       _log = logger ?? GetIt.I.get<Logger>() {
    _listen();
  }

  int get minBidSats => btcToSatoshi(minBidAmount);
  int get maxBidSats => btcToSatoshi(maxBidAmount);

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

  void setMinBidAmount(double value) {
    minBidAmount = value;
    notifyListeners();
  }

  void setMaxBidAmount(double value) {
    maxBidAmount = value;
    notifyListeners();
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
    current = state.hasCurrent() ? state.current : null;
    history = state.history;
    if (state.minBidSats > 0) {
      minBidAmount = satoshiToBTC(state.minBidSats.toInt());
    }
    if (state.maxBidSats > 0) {
      maxBidAmount = satoshiToBTC(state.maxBidSats.toInt());
    }
    error = null;
    notifyListeners();
  }

  Future<void> startBidding() async {
    try {
      await _bmm.start(
        sidechain: sidechainRPC.binaryType,
        minBidSats: minBidSats,
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
    try {
      await _bmm.createBid(sidechain: sidechainRPC.binaryType, bidSats: bidSats);
      error = null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  int griefBidsSent = 0;
  int griefSatsSpent = 0;
  String? griefTxid;

  /// Broadcast an M8 committing to no real block, stalling the honest producer
  /// if a miner takes it. Rejected on mainnet by the backend.
  Future<void> griefBid() async {
    try {
      final res = await _bmm.griefBid(sidechain: sidechainRPC.binaryType, bidSats: minBidSats);
      griefBidsSent++;
      griefSatsSpent += minBidSats;
      griefTxid = res.bmmTxid;
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
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
    unawaited(_supervisor?.dispose());
    super.dispose();
  }
}
