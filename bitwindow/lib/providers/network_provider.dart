import 'dart:async';

import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

class NetworkProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();

  /// Current network stats from the server
  GetNetworkStatsResponse? stats;

  /// Bandwidth history for graphing (last 60 data points = 5 minutes at 5s intervals)
  List<BandwidthDataPoint> bandwidthHistory = [];
  static const int maxDataPoints = 60;

  String? error;
  bool _isFetching = false;
  Timer? _fetchTimer;

  NetworkProvider() {
    _startFetchTimer();
    bitwindowd.addListener(fetch);
  }

  Future<void> fetch() async {
    if (!bitwindowd.connected || _isFetching) return;
    _isFetching = true;

    try {
      final response = await bitwindowd.bitwindowd.getNetworkStats();

      // Add data point to history
      _addDataPoint(response);

      stats = response;
      error = null;
      notifyListeners();
    } catch (e) {
      log.e('fetch network stats: $e');
      error = e.toString();
    } finally {
      _isFetching = false;
    }
  }

  void _addDataPoint(GetNetworkStatsResponse response) {
    final previous = bandwidthHistory.isNotEmpty ? bandwidthHistory.last : null;

    final dataPoint = BandwidthDataPoint.withRates(
      time: DateTime.now(),
      totalRxBytes: response.totalBytesReceived.toDouble(),
      totalTxBytes: response.totalBytesSent.toDouble(),
      previous: previous,
    );

    bandwidthHistory.add(dataPoint);

    // Keep only last maxDataPoints
    if (bandwidthHistory.length > maxDataPoints) {
      bandwidthHistory.removeAt(0);
    }
  }

  void _startFetchTimer() {
    fetch();

    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());
  }

  /// Get bandwidth history filtered to last N seconds
  List<BandwidthDataPoint> getHistoryForDuration(Duration duration) {
    if (bandwidthHistory.isEmpty) return [];

    final cutoff = DateTime.now().subtract(duration);
    return bandwidthHistory.where((dp) => dp.time.isAfter(cutoff)).toList();
  }

  /// Get the current RX rate in bytes/sec
  double get currentRxRate {
    if (bandwidthHistory.isEmpty) return 0;
    return bandwidthHistory.last.rxBytesPerSec;
  }

  /// Get the current TX rate in bytes/sec
  double get currentTxRate {
    if (bandwidthHistory.isEmpty) return 0;
    return bandwidthHistory.last.txBytesPerSec;
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    bitwindowd.removeListener(fetch);
    super.dispose();
  }
}
