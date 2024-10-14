import 'dart:async';

import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/gen/google/protobuf/timestamp.pb.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class BlockchainProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  API get api => GetIt.I.get<API>();

  // raw data go here
  List<Peer> peers = [];
  List<ListRecentBlocksResponse_RecentBlock> recentBlocks = [];
  List<UnconfirmedTransaction> unconfirmedTXs = [];
  GetBlockchainInfoResponse blockchainInfo = GetBlockchainInfoResponse();

  // computed field go here
  Timestamp? get lastBlockAt => recentBlocks.isNotEmpty ? recentBlocks.first.blockTime : null;

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
      final newTXs = await api.bitcoind.listUnconfirmedTransactions();
      final newBlockchainInfo = await api.bitcoind.getBlockchainInfo();
      final newRecentBlocks = await api.bitcoind.listRecentBlocks();

      if (_dataHasChanged(newPeers, newTXs, newBlockchainInfo, newRecentBlocks)) {
        peers = newPeers;
        unconfirmedTXs = newTXs;
        blockchainInfo = newBlockchainInfo;
        recentBlocks = newRecentBlocks;
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
    List<UnconfirmedTransaction> newTXs,
    GetBlockchainInfoResponse newBlockchainInfo,
    List<ListRecentBlocksResponse_RecentBlock> newRecentBlocks,
  ) {
    if (!listEquals(peers, newPeers)) {
      return true;
    }

    if (!listEquals(unconfirmedTXs, newTXs)) {
      return true;
    }

    if (!listEquals(recentBlocks, newRecentBlocks)) {
      return true;
    }

    if (blockchainInfo.toProto3Json() != newBlockchainInfo.toProto3Json()) {
      return true;
    }

    return false;
  }

  void _startFetchTimer() {
    _fetchTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    super.dispose();
  }
}
