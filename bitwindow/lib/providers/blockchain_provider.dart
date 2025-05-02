import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/providers/blockinfo_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';

class BlockchainProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  BlockInfoProvider get infoProvider => GetIt.I.get<BlockInfoProvider>();

  // raw data go here
  List<Peer> peers = [];
  List<Block> blocks = [];
  List<RecentTransaction> recentTransactions = [];

  String? error;
  bool hasMoreBlocks = true;
  bool isLoadingMoreBlocks = false;
  Set<int> loadedBlockHeights = {};

  Duration _currentInterval = const Duration(seconds: 5);
  bool _isFetching = false;
  Timer? _fetchTimer;

  BlockchainProvider() {
    _startFetchTimer();
    mainchain.addListener(fetch);
    bitwindowd.addListener(fetch);
    infoProvider.addListener(notifyListeners);
  }

  // call this function from anywhere to refetch blockchain info
  Future<void> fetch() async {
    if (!bitwindowd.connected || _isFetching) return;
    _isFetching = true;

    try {
      final newPeers = await bitwindowd.bitcoind.listPeers();
      final newTXs = await bitwindowd.bitcoind.listRecentTransactions();
      final (newBlocks, hasMore) = await bitwindowd.bitcoind.listBlocks();

      if (_dataHasChanged(newPeers, newTXs, newBlocks)) {
        peers = newPeers;
        recentTransactions = newTXs;
        if (blocks.isEmpty) {
          blocks = newBlocks;
          loadedBlockHeights = newBlocks.map((b) => b.height).toSet();
        }
        hasMoreBlocks = hasMore;
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

    return false;
  }

  void _startFetchTimer() {
    if (Environment.isInTest) {
      return;
    }

    void tick() async {
      try {
        await fetch();
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
      final (moreBlocks, hasMore) = await bitwindowd.bitcoind.listBlocks(
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
