import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

class BlockInfoProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  final RPCConnection connection;

  // raw data go here
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

  // computed field go here
  double get verificationProgress => blockchainInfo.blocks / blockchainInfo.headers;
  Timestamp? get lastBlockAt => blockchainInfo.time != 0 ? Timestamp(seconds: Int64(blockchainInfo.time)) : null;

  bool _isFetching = false;
  Timer? _fetchTimer;

  String? error;

  BlockInfoProvider({
    required this.connection,
    bool startTimer = true,
  }) {
    if (startTimer) {
      if (Environment.isInTest) {
        return;
      }
      _startFetchTimer();
    }
  }

  // call this function from anywhere to refetch blockchain info
  Future<void> fetch() async {
    if (!connection.connected) {
      return;
    }

    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      await _fetchBlockchainInfo();
    } catch (e) {
      log.e('Error fetching blockchain data: $e');
      error = e.toString();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _fetchBlockchainInfo() async {
    final newBlockchainInfo = await connection.getBlockchainInfo();
    blockchainInfo = newBlockchainInfo;
    notifyListeners();
  }

  void _startFetchTimer() {
    void tick() async {
      try {
        await fetch();
      } catch (e) {
        // do nothing, swallov!
      }
    }

    final Duration interval = const Duration(seconds: 5);
    _fetchTimer = Timer.periodic(interval, (_) => tick());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    super.dispose();
  }
}
