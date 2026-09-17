import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sidechain_core/sidechain_core.dart';
import 'package:sail_ui/sail_ui.dart';

class BlockchainProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();
  BitcoindConnection get mainchain => GetIt.I.get<BitcoindConnection>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  SyncProvider get syncProvider => GetIt.I.get<SyncProvider>();

  // raw data go here
  List<Peer> peers = [];
  List<Block> blocks = [];
  List<RecentTransaction> recentTransactions = [];

  List<String> errors = [];
  bool hasMoreBlocks = true;
  bool isLoadingMoreBlocks = false;
  Set<int> loadedBlockHeights = {};

  static const _fetchInterval = Duration(seconds: 5);
  bool _isFetching = false;
  Timer? _fetchTimer;

  BlockchainProvider() {
    _startFetchTimer();
    mainchain.addListener(fetch);
    bitwindowd.addListener(fetch);
    enforcer.addListener(fetch);
    syncProvider.addListener(notifyListeners);
  }

  // call this function from anywhere to refetch blockchain info
  Future<void> fetch() async {
    // Light mode runs no local Bitcoin Core, and blocks, transactions and peers read it.
    if (!NodeModeProvider.runsLocalBackends) {
      if (blocks.isNotEmpty || recentTransactions.isNotEmpty || peers.isNotEmpty || errors.isNotEmpty) {
        clear();
      }
      return;
    }
    if (!bitwindowd.connected || _isFetching) {
      return;
    }
    // bitwindowd answers both list calls with nothing while it waits for Core,
    // and each one still costs Core an RPC under cs_main. A node that re-enters
    // IBD holds rows from the chain it left, so drop them.
    if (syncProvider.bitwindowdSyncInfo?.waitsForCore ?? false) {
      if (blocks.isNotEmpty || recentTransactions.isNotEmpty || peers.isNotEmpty || errors.isNotEmpty) {
        clear();
      }
      return;
    }
    _isFetching = true;

    try {
      errors = [];
      final tReq = bitwindowd.bitwindowd.listRecentTransactions().onError(_return(recentTransactions));
      final bReq = bitwindowd.bitwindowd.listBlocks().onError(_return((blocks, false)));
      final pReq = _orchestrator.bitcoind
          .getPeerInfo(GetPeerInfoRequest())
          .onError(_return(GetPeerInfoResponse(peers: peers)));

      final newTXs = await tReq;
      final newPeers = (await pReq).peers;
      final (newBlocks, hasMore) = await bReq;

      var hasChanges = recentTransactions.updateWith(newTXs);
      hasChanges = hasChanges | peers.updateWith(newPeers);
      hasChanges =
          hasChanges |
          blocks.updateWith(
            newBlocks,
            afterUpdate: () {
              hasMoreBlocks = hasMore;
              loadedBlockHeights = newBlocks.map((b) => b.height).toSet();
            },
          );
      if (hasChanges) {
        notifyListeners();
      }
      if (errors.isNotEmpty) {
        log.e(errors.join('\n'));
      }
    } catch (e) {
      log.e(e);
    } finally {
      _isFetching = false;
    }
  }

  FutureOr<T> Function(Object? e, StackTrace stt) _return<T>(T previous) {
    return (e, stt) {
      errors.add(e.toString() + stt.toString());
      return previous;
    };
  }

  void _startFetchTimer() {
    fetch();

    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(_fetchInterval, (_) => fetch());
  }

  /// Wipe cached state on network swap so the UI stops showing the previous
  /// network's data while the next fetch repopulates from new bitwindowd.
  void clear() {
    peers = [];
    blocks = [];
    recentTransactions = [];
    loadedBlockHeights = {};
    hasMoreBlocks = true;
    isLoadingMoreBlocks = false;
    errors.clear();
    notifyListeners();
  }

  Future<void> loadMoreBlocks() async {
    if (!hasMoreBlocks || isLoadingMoreBlocks) {
      return;
    }

    isLoadingMoreBlocks = true;
    try {
      final lastBlock = blocks.last;
      final (moreBlocks, hasMore) = await bitwindowd.bitwindowd.listBlocks(
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

extension on List {
  bool updateWith<T>(List<T> newest, {void Function()? afterUpdate}) {
    if (listEquals(this, newest)) {
      return false;
    }
    this
      ..clear()
      ..addAll(newest);
    afterUpdate?.call();
    return true;
  }
}
