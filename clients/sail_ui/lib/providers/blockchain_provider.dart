import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

class BlockchainProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();

  // raw data go here
  List<Peer> peers = [];
  List<Block> blocks = [];
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
  Timestamp? get lastBlockAt => blocks.isNotEmpty ? blocks.first.blockTime : null;
  String get verificationProgress {
    if (blockchainInfo.headers == 0 || blockchainInfo.blocks == 0) return '0';
    return ((blockchainInfo.blocks / blockchainInfo.headers) * 100).toStringAsFixed(2);
  }

  Duration _currentInterval = const Duration(seconds: 5);

  bool _isFetching = false;
  Timer? _fetchTimer;

  String? error;

  bool hasMoreBlocks = true;
  bool isLoadingMoreBlocks = false;
  Set<int> loadedBlockHeights = {};

  BlockchainProvider() {
    _startFetchTimer();
    mainchain.addListener(fetch);
  }

  // call this function from anywhere to refetch blockchain info
  Future<void> fetch() async {
    if (!api.connected || _isFetching) return;
    _isFetching = true;

    try {
      final newPeers = await api.bitcoind.listPeers();
      final newTXs = await api.bitcoind.listRecentTransactions();
      final (newBlocks, hasMore) = await api.bitcoind.listBlocks();
      final newOPReturns = await api.misc.listOPReturns();

      if (_dataHasChanged(newPeers, newTXs, newBlocks, newOPReturns)) {
        peers = newPeers;
        recentTransactions = newTXs;
        if (blocks.isEmpty) {
          blocks = newBlocks;
          loadedBlockHeights = newBlocks.map((b) => b.height).toSet();
        }
        hasMoreBlocks = hasMore;
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
    List<Block> newBlocks,
    List<OPReturn> newOPReturns,
  ) {
    if (!listEquals(peers, newPeers)) {
      return true;
    }

    if (!listEquals(recentTransactions, newTXs)) {
      return true;
    }

    if (!listEquals(blocks, newBlocks)) {
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

  Future<void> loadMoreBlocks() async {
    if (!hasMoreBlocks || isLoadingMoreBlocks) return;

    isLoadingMoreBlocks = true;
    try {
      final lastBlock = blocks.last;
      final (moreBlocks, hasMore) = await api.bitcoind.listBlocks(
        startHeight: lastBlock.height - 1,
      );

      // Filter out blocks we've already loaded
      final newBlocks = moreBlocks.where((b) => !loadedBlockHeights.contains(b.height)).toList();
      if (newBlocks.isEmpty) {
        hasMoreBlocks = false;
        return;
      }

      // Add new block heights to our set
      loadedBlockHeights.addAll(newBlocks.map((b) => b.height));

      // Sort all blocks by height in descending order (newest to oldest)
      blocks = [...blocks, ...newBlocks]..sort((a, b) => b.height.compareTo(a.height));
      hasMoreBlocks = hasMore;
      notifyListeners();
    } finally {
      isLoadingMoreBlocks = false;
    }
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    mainchain.removeListener(fetch);
    super.dispose();
  }
}
