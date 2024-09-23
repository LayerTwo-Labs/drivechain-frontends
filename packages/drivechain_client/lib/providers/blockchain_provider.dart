import 'dart:async';

import 'package:drivechain_client/api.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/gen/google/protobuf/timestamp.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class BlockchainProvider extends ChangeNotifier {
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

  BlockchainProvider() {
    _startFetchTimer();
  }

  // call this function from anywhere to refetch blockchain info
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newPeers = await api.drivechain.listPeers();
      final newTXs = await api.drivechain.listUnconfirmedTransactions();
      final newBlockchainInfo = await api.drivechain.getBlockchainInfo();
      final newRecentBlocks = await api.drivechain.listRecentBlocks();

      if (_dataHasChanged(newPeers, newTXs, newBlockchainInfo, newRecentBlocks)) {
        peers = newPeers;
        unconfirmedTXs = newTXs;
        blockchainInfo = newBlockchainInfo;
        recentBlocks = newRecentBlocks;
        notifyListeners();
      }
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
