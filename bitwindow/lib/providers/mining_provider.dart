import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class MiningProvider extends ChangeNotifier {
  BitwindowRPC get _bitwindowd => GetIt.I.get<BitwindowRPC>();
  Logger get _log => GetIt.I.get<Logger>();

  bool isMining = false;
  double hashRate = 0.0;
  int blocksFound = 0;
  String? error;
  List<String> foundBlockHashes = [];

  StreamSubscription<MineBlocksResponse>? _miningSubscription;

  Future<void> startMining() async {
    if (isMining) {
      _log.w('Mining already started');
      return;
    }

    try {
      _log.i('Starting CPU mining');
      error = null;
      isMining = true;
      notifyListeners();

      final stream = _bitwindowd.bitwindowd.mineBlocks();
      _miningSubscription = stream.listen(
        (response) {
          if (response.hasHashRate()) {
            hashRate = response.hashRate.hashRate;
            _log.d('Hash rate: ${hashRate.toStringAsFixed(2)} H/s');
          } else if (response.hasBlockFound()) {
            final blockHash = response.blockFound.blockHash;
            blocksFound++;
            foundBlockHashes.insert(0, blockHash);
            _log.i('Block found: $blockHash (total: $blocksFound)');
          }
          notifyListeners();
        },
        onError: (e) {
          _log.e('Mining stream error: $e');
          error = e.toString();
          isMining = false;
          notifyListeners();
        },
        onDone: () {
          _log.i('Mining stream completed');
          isMining = false;
          hashRate = 0.0;
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _log.e('Failed to start mining: $e');
      error = e.toString();
      isMining = false;
      notifyListeners();
    }
  }

  Future<void> stopMining() async {
    if (!isMining) {
      _log.w('Mining not running');
      return;
    }

    try {
      _log.i('Stopping CPU mining');
      await _miningSubscription?.cancel();
      _miningSubscription = null;
      isMining = false;
      hashRate = 0.0;
      notifyListeners();
    } catch (e) {
      _log.e('Failed to stop mining: $e');
      error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _miningSubscription?.cancel();
    super.dispose();
  }
}
