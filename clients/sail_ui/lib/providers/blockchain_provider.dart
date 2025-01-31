import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/misc/v1/misc.pbgrpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

class BlockchainProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();

  // raw data go here
  List<Peer> peers = [];
  List<Block> recentBlocks = [];
  List<RecentTransaction> recentTransactions = [];
  BlockchainInfo blockchainInfo = BlockchainInfo(
    chain: '',
    blocks: 0,
    headers: 0,
    bestBlockHash: '',
    difficulty: 0,
    time: 0,
    medianTime: 0,
    verificationProgress: 0,
    initialBlockDownload: false,
    chainWork: '',
    sizeOnDisk: 0,
    pruned: false,
    warnings: [],
  );
  List<OPReturn> opReturns = [];

  // computed field go here
  Timestamp? get lastBlockAt => recentBlocks.isNotEmpty ? recentBlocks.first.blockTime : null;
  String get verificationProgress {
    if (blockchainInfo.headers == 0 || blockchainInfo.blocks == 0) return '0';
    return ((blockchainInfo.blocks / blockchainInfo.headers) * 100).toStringAsFixed(2);
  }

  Duration _currentInterval = const Duration(seconds: 5);

  bool _isFetching = false;
  Timer? _fetchTimer;

  String? error;

  BlockchainProvider() {
    _startFetchTimer();
    mainchain.addListener(fetch);
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

  Future<void> _fetchBlockchainInfo() async {
    final newBlockchainInfo = await mainchain.getBlockchainInfo();
    blockchainInfo = newBlockchainInfo;
    notifyListeners();
  }

  void _startFetchTimer() {
    void tick() async {
      try {
        await fetch();
        await _fetchBlockchainInfo();

        // During IBD we should be pretty spammy to get up-to-date info all the time
        // After IBD however we can check less frequently, so as soon as IBD is done
        // we check every 5 seconds.

        // Check if we need to change the interval
        final newInterval = mainchain.inIBD ? const Duration(milliseconds: 200) : const Duration(seconds: 5);
        if (newInterval != _currentInterval) {
          // IBD-status changed!
          _currentInterval = newInterval;
          _fetchTimer?.cancel();
          _fetchTimer = Timer.periodic(_currentInterval, (_) => tick());
        }
      } catch (e) {
        // do nothing, swallov!
      }
    }

    _fetchTimer = Timer.periodic(_currentInterval, (_) => tick());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    mainchain.removeListener(fetch);
    super.dispose();
  }
}
