import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sail_ui/sail_ui.dart';

/// Statistics about a fee bucket
class FeeBucket {
  final double minFeeRate; // ${activeTicker.feeRate}
  final double maxFeeRate; // ${activeTicker.feeRate}
  final int txCount;
  final int totalVsize;
  final double totalFees; // in satoshis

  FeeBucket({
    required this.minFeeRate,
    required this.maxFeeRate,
    required this.txCount,
    required this.totalVsize,
    required this.totalFees,
  });

  @override
  bool operator ==(Object other) =>
      other is FeeBucket &&
      other.minFeeRate == minFeeRate &&
      other.maxFeeRate == maxFeeRate &&
      other.txCount == txCount &&
      other.totalVsize == totalVsize &&
      other.totalFees == totalFees;

  @override
  int get hashCode => Object.hash(minFeeRate, maxFeeRate, txCount, totalVsize, totalFees);

  String get label {
    if (maxFeeRate == double.infinity) {
      return '${minFeeRate.toInt()}+';
    }
    return '${minFeeRate.toInt()}-${maxFeeRate.toInt()}';
  }
}

/// Fee estimate for a specific confirmation target
class FeeEstimate {
  final int blocks; // Confirmation target in blocks
  final double feeRate; // ${activeTicker.feeRate}

  FeeEstimate({
    required this.blocks,
    required this.feeRate,
  });

  @override
  bool operator ==(Object other) => other is FeeEstimate && other.blocks == blocks && other.feeRate == feeRate;

  @override
  int get hashCode => Object.hash(blocks, feeRate);

  String get urgency {
    if (blocks <= 1) {
      return 'Next block';
    }
    if (blocks <= 3) {
      return 'High priority';
    }
    if (blocks <= 6) {
      return 'Medium priority';
    }
    if (blocks <= 24) {
      return 'Low priority';
    }
    return 'Economy';
  }
}

/// Overall mempool statistics
class MempoolStats {
  final int txCount;
  final int totalVsize;
  final double totalFees; // in satoshis
  final double medianFeeRate; // ${activeTicker.feeRate}
  final List<FeeBucket> feeBuckets;
  final List<FeeEstimate> feeEstimates;

  MempoolStats({
    required this.txCount,
    required this.totalVsize,
    required this.totalFees,
    required this.medianFeeRate,
    required this.feeBuckets,
    required this.feeEstimates,
  });

  double get totalVsizeMB => totalVsize / 1000000;

  @override
  bool operator ==(Object other) =>
      other is MempoolStats &&
      other.txCount == txCount &&
      other.totalVsize == totalVsize &&
      other.totalFees == totalFees &&
      other.medianFeeRate == medianFeeRate &&
      listEquals(other.feeBuckets, feeBuckets) &&
      listEquals(other.feeEstimates, feeEstimates);

  @override
  int get hashCode => Object.hash(
    txCount,
    totalVsize,
    totalFees,
    medianFeeRate,
    Object.hashAll(feeBuckets),
    Object.hashAll(feeEstimates),
  );

  static MempoolStats empty() => MempoolStats(
    txCount: 0,
    totalVsize: 0,
    totalFees: 0,
    medianFeeRate: 0,
    feeBuckets: [],
    feeEstimates: [],
  );
}

class MempoolProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  MempoolStats stats = MempoolStats.empty();
  String? error;
  bool isFetching = false;

  Timer? _fetchTimer;

  static const _bucketRanges = [
    (0.0, 1.0),
    (1.0, 2.0),
    (2.0, 5.0),
    (5.0, 10.0),
    (10.0, 20.0),
    (20.0, 50.0),
    (50.0, 100.0),
    (100.0, double.infinity),
  ];
  static const _confTargets = [1, 3, 6, 12, 24, 144];

  /// Polls only while a widget listens.
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    if (_fetchTimer != null) {
      return;
    }
    fetch();
    if (Environment.isInTest) {
      return;
    }
    _fetchTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());
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
    if (!api.connected || isFetching) {
      return;
    }
    isFetching = true;

    try {
      final mempoolResponse = await _orchestrator.bitcoind.getRawMempool(GetRawMempoolRequest());
      final transactions = mempoolResponse.transactions;

      final bucketTxCount = List.filled(_bucketRanges.length, 0);
      final bucketVsize = List.filled(_bucketRanges.length, 0);
      final bucketFees = List.filled(_bucketRanges.length, 0.0);
      final List<double> feeRates = [];
      double totalFees = 0;
      int totalVsize = 0;

      for (final tx in transactions.values) {
        final vsize = tx.virtualSize;
        final fees = tx.fees.base.toDouble();
        final feeRate = vsize > 0 ? fees / vsize : 0.0;
        feeRates.add(feeRate);
        totalFees += fees;
        totalVsize += vsize;
        for (var i = 0; i < _bucketRanges.length; i++) {
          final (minFee, maxFee) = _bucketRanges[i];
          if (feeRate >= minFee && feeRate < maxFee) {
            bucketTxCount[i]++;
            bucketVsize[i] += vsize;
            bucketFees[i] += fees;
          }
        }
      }

      feeRates.sort();
      final medianFeeRate = feeRates.isEmpty ? 0.0 : feeRates[feeRates.length ~/ 2];

      final feeBuckets = [
        for (var i = 0; i < _bucketRanges.length; i++)
          if (bucketTxCount[i] > 0)
            FeeBucket(
              minFeeRate: _bucketRanges[i].$1,
              maxFeeRate: _bucketRanges[i].$2,
              txCount: bucketTxCount[i],
              totalVsize: bucketVsize[i],
              totalFees: bucketFees[i],
            ),
      ];

      final estimates = await Future.wait(_confTargets.map(_estimate));

      final next = MempoolStats(
        txCount: transactions.length,
        totalVsize: totalVsize,
        totalFees: totalFees,
        medianFeeRate: medianFeeRate,
        feeBuckets: feeBuckets,
        feeEstimates: estimates.nonNulls.toList(),
      );
      if (next != stats || error != null) {
        stats = next;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      log.e('Error fetching mempool: $e');
    } finally {
      isFetching = false;
    }
  }

  /// The fee estimate for [target], or null when the node has none.
  Future<FeeEstimate?> _estimate(int target) async {
    try {
      final estimate = await _orchestrator.bitcoind.estimateSmartFee(
        EstimateSmartFeeRequest()..confTarget = Int64(target),
      );
      if (estimate.feeRate <= 0) {
        return null;
      }
      // Convert BTC/kB to ${activeTicker.feeRate}
      return FeeEstimate(blocks: target, feeRate: (estimate.feeRate * 100000000 / 1000).toDouble());
    } catch (e) {
      // Skip failed estimates
      return null;
    }
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    super.dispose();
  }
}
