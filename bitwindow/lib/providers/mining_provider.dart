import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class MiningProvider extends ChangeNotifier {
  BitwindowRPC get _bitwindowd => GetIt.I.get<BitwindowRPC>();
  Logger get _log => GetIt.I.get<Logger>();

  bool isMining = false;
  double hashRate = 0.0;
  int blocksFound = 0;
  String? error;
  List<String> foundBlockHashes = [];

  Timer? _pollTimer;

  Future<void> startMining() async {
    try {
      _log.i('Starting CPU mining');
      error = null;
      await _bitwindowd.bitwindowd.startMining();
      _startPolling();
      await refreshStatus();
    } catch (e) {
      _log.e('Failed to start mining: $e');
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopMining() async {
    try {
      _log.i('Stopping CPU mining');
      await _bitwindowd.bitwindowd.stopMining();
      _stopPolling();
      await refreshStatus();
    } catch (e) {
      _log.e('Failed to stop mining: $e');
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshStatus() async {
    try {
      final status = await _bitwindowd.bitwindowd.getMiningStatus();
      isMining = status.mining;
      hashRate = status.hashRate;
      blocksFound = status.blocksFound;
      foundBlockHashes = status.recentBlockHashes;
      error = status.error.isNotEmpty ? status.error : null;
      if (isMining) {
        _startPolling();
      } else {
        _stopPolling();
      }
      notifyListeners();
    } catch (e) {
      _log.w('Failed to fetch mining status: $e');
    }
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(const Duration(seconds: 3), (_) => refreshStatus());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
