import 'dart:async';
import 'dart:math';

import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/sidechain_core.dart';
import 'package:sail_ui/sail_ui.dart';

class NetworkProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();

  /// Current network stats from the server
  GetNetworkStatsResponse? stats;

  /// Bandwidth history for graphing (last 60 data points = 5 minutes at 5s intervals)
  List<BandwidthDataPoint> bandwidthHistory = [];
  static const int maxDataPoints = 60;
  static const sampleInterval = Duration(seconds: 5);

  String? error;
  bool _isFetching = false;
  Timer? _fetchTimer;

  NetworkProvider() {
    bitwindowd.addListener(fetch);
  }

  /// Polls only while a widget listens.
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    if (_fetchTimer != null) {
      return;
    }
    unawaited(fetch());
    if (Environment.isInTest) {
      return;
    }
    _fetchTimer = Timer.periodic(sampleInterval, (_) => fetch());
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _fetchTimer?.cancel();
      _fetchTimer = null;
    }
  }

  Future<void> fetch() async {
    // Light mode runs no local Bitcoin Core, and these stats read it. Drop the
    // last reading too: the cards and the traffic graph would else hold
    // full-mode numbers that no longer move.
    if (!NodeModeProvider.runsLocalBackends) {
      if (stats != null || error != null || bandwidthHistory.isNotEmpty) {
        stats = null;
        error = null;
        bandwidthHistory = [];
        notifyListeners();
      }
      return;
    }
    if (!hasListeners || !bitwindowd.connected || _isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final response = await bitwindowd.bitwindowd.getNetworkStats();

      // Add data point to history
      _addDataPoint(response);

      stats = response;
      error = null;
      notifyListeners();
    } catch (e) {
      final errStr = e.toString();
      // Bitcoin Core warmup ("-28: Loading block index") and connection-refused
      // chatter during boot are expected — silently swallow them.
      if (!isExpectedBootError(e) && !_isBitcoinCoreStartupError(errStr)) {
        log.e('fetch network stats: $e');
      }
      error = errStr;
    } finally {
      _isFetching = false;
    }
  }

  void _addDataPoint(GetNetworkStatsResponse response) {
    addSample(
      DateTime.now(),
      response.totalBytesReceived.toDouble(),
      response.totalBytesSent.toDouble(),
    );
  }

  /// Adds a sample of the byte totals. After a pause of the poll, it first
  /// adds one point for each missed interval, at the mean rate of the pause.
  @visibleForTesting
  void addSample(DateTime time, double totalRx, double totalTx) {
    final previous = bandwidthHistory.isNotEmpty ? bandwidthHistory.last : null;
    final missed = previous == null
        ? 0
        : min(
            (time.difference(previous.time).inMilliseconds / sampleInterval.inMilliseconds).round() - 1,
            maxDataPoints,
          );
    for (var i = missed; i >= 1; i--) {
      final at = time.subtract(sampleInterval * i);
      final f = at.difference(previous!.time).inMilliseconds / time.difference(previous.time).inMilliseconds;
      _append(
        at,
        previous.totalRxBytes + (totalRx - previous.totalRxBytes) * f,
        previous.totalTxBytes + (totalTx - previous.totalTxBytes) * f,
      );
    }
    _append(time, totalRx, totalTx);
  }

  void _append(DateTime time, double totalRx, double totalTx) {
    bandwidthHistory.add(
      BandwidthDataPoint.withRates(
        time: time,
        totalRxBytes: totalRx,
        totalTxBytes: totalTx,
        previous: bandwidthHistory.isNotEmpty ? bandwidthHistory.last : null,
      ),
    );
    if (bandwidthHistory.length > maxDataPoints) {
      bandwidthHistory.removeAt(0);
    }
  }

  /// Get bandwidth history filtered to last N seconds
  List<BandwidthDataPoint> getHistoryForDuration(Duration duration) {
    if (bandwidthHistory.isEmpty) {
      return [];
    }

    final cutoff = DateTime.now().subtract(duration);
    return bandwidthHistory.where((dp) => dp.time.isAfter(cutoff)).toList();
  }

  /// Get the current RX rate in bytes/sec
  double get currentRxRate {
    if (bandwidthHistory.isEmpty) {
      return 0;
    }
    return bandwidthHistory.last.rxBytesPerSec;
  }

  /// Get the current TX rate in bytes/sec
  double get currentTxRate {
    if (bandwidthHistory.isEmpty) {
      return 0;
    }
    return bandwidthHistory.last.txBytesPerSec;
  }

  /// Check if error is a Bitcoin Core startup message (e.g., "-28: Loading block index")
  bool _isBitcoinCoreStartupError(String error) {
    const startupPatterns = [
      '-28:',
      'Loading block index',
      'Verifying blocks',
      'Loading wallet',
      'Rescanning',
      'Loading P2P addresses',
    ];
    return startupPatterns.any((pattern) => error.contains(pattern));
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    bitwindowd.removeListener(fetch);
    super.dispose();
  }
}
