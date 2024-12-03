import 'dart:async';

import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/gen/google/protobuf/timestamp.pb.dart';
import 'package:bitwindow/gen/misc/v1/misc.pbgrpc.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class BlockchainProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  API get api => GetIt.I.get<API>();

  // raw data go here
  List<Peer> peers = [];
  List<Block> recentBlocks = [];
  List<RecentTransaction> recentTransactions = [];
  GetBlockchainInfoResponse blockchainInfo = GetBlockchainInfoResponse();
  List<OPReturn> opReturns = [];

  // computed field go here
  Timestamp? get lastBlockAt => recentBlocks.isNotEmpty ? recentBlocks.first.blockTime : null;
  String get verificationProgress => ((blockchainInfo.blocks / blockchainInfo.headers) * 100).toStringAsFixed(2);

  bool _isFetching = false;
  Timer? _fetchTimer;

  String? error;

  BlockchainProvider() {
    _startFetchTimer();
  }

  // call this function from anywhere to refetch blockchain info
  Future<void> fetch() async {
    if (!api.connected) {
      return;
    }

    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newPeers = await api.bitcoind.listPeers();
      final newTXs = await api.bitcoind.listRecentTransactions();
      final newRecentBlocks = await api.bitcoind.listRecentBlocks();
      final newOPReturns = await api.misc.listOPReturns();

      if (_dataHasChanged(newPeers, newTXs, newRecentBlocks, newOPReturns)) {
        peers = newPeers;
        recentTransactions = newTXs;
        recentBlocks = newRecentBlocks;
        opReturns = newOPReturns;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      log.e('Error fetching blockchain data: $e');
      error = e.toString();
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    List<Peer> newPeers,
    List<RecentTransaction> newTXs,
    List<Block> newRecentBlocks,
    List<OPReturn> newOPReturns,
  ) {
    if (!listEquals(peers, newPeers)) {
      return true;
    }

    if (!listEquals(recentTransactions, newTXs)) {
      return true;
    }

    if (!listEquals(recentBlocks, newRecentBlocks)) {
      return true;
    }

    if (!listEquals(opReturns, newOPReturns)) {
      return true;
    }

    return false;
  }

  void _fetchBlockchainInfo() async {
    final newBlockchainInfo = await api.bitcoind.getBlockchainInfo();
    blockchainInfo = newBlockchainInfo;
    notifyListeners();
  }

  void _startFetchTimer() {
    _fetchTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetch();
      _fetchBlockchainInfo();
    });
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    super.dispose();
  }
}
