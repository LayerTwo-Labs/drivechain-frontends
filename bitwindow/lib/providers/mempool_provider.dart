import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

/// Statistics about a fee bucket
class FeeBucket {
  final double minFeeRate; // sat/vB
  final double maxFeeRate; // sat/vB
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
  final double feeRate; // sat/vB

  FeeEstimate({
    required this.blocks,
    required this.feeRate,
  });

  String get urgency {
    if (blocks <= 1) return 'Next block';
    if (blocks <= 3) return 'High priority';
    if (blocks <= 6) return 'Medium priority';
    if (blocks <= 24) return 'Low priority';
    return 'Economy';
  }
}

/// Overall mempool statistics
class MempoolStats {
  final int txCount;
  final int totalVsize;
  final double totalFees; // in satoshis
  final double medianFeeRate; // sat/vB
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

  MempoolStats stats = MempoolStats.empty();
  String? error;
  bool isFetching = false;

  Timer? _fetchTimer;

  MempoolProvider() {
    _startFetchTimer();
  }

  void _startFetchTimer() {
    fetch();

    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());
  }

  Future<void> fetch() async {
    if (!api.connected || isFetching) return;
    isFetching = true;

    try {
      final mempoolResponse = await api.bitcoind.getRawMempool();
      final transactions = mempoolResponse.transactions;

      // Calculate fee buckets
      final bucketRanges = [
        (0.0, 1.0),
        (1.0, 2.0),
        (2.0, 5.0),
        (5.0, 10.0),
        (10.0, 20.0),
        (20.0, 50.0),
        (50.0, 100.0),
        (100.0, double.infinity),
      ];

      final List<FeeBucket> feeBuckets = [];
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
      }

      // Sort fee rates for median calculation
      feeRates.sort();
      final medianFeeRate = feeRates.isEmpty ? 0.0 : feeRates[feeRates.length ~/ 2];

      // Calculate fee buckets
      for (final range in bucketRanges) {
        final (minFee, maxFee) = range;
        int bucketTxCount = 0;
        int bucketVsize = 0;
        double bucketFees = 0;

        for (final tx in transactions.values) {
          final vsize = tx.virtualSize;
          final fees = tx.fees.base.toDouble();
          final feeRate = vsize > 0 ? fees / vsize : 0.0;

          if (feeRate >= minFee && feeRate < maxFee) {
            bucketTxCount++;
            bucketVsize += vsize;
            bucketFees += fees;
          }
        }

        if (bucketTxCount > 0) {
          feeBuckets.add(
            FeeBucket(
              minFeeRate: minFee,
              maxFeeRate: maxFee,
              txCount: bucketTxCount,
              totalVsize: bucketVsize,
              totalFees: bucketFees,
            ),
          );
        }
      }

      // Get fee estimates
      final List<FeeEstimate> feeEstimates = [];
      final confTargets = [1, 3, 6, 12, 24, 144];
      for (final target in confTargets) {
        try {
          final estimate = await api.bitcoind.estimateSmartFee(target);
          if (estimate.feeRate > 0) {
            // Convert BTC/kB to sat/vB
            final satPerVb = (estimate.feeRate * 100000000 / 1000).toDouble();
            feeEstimates.add(FeeEstimate(blocks: target, feeRate: satPerVb));
          }
        } catch (e) {
          // Skip failed estimates
        }
      }

      stats = MempoolStats(
        txCount: transactions.length,
        totalVsize: totalVsize,
        totalFees: totalFees,
        medianFeeRate: medianFeeRate,
        feeBuckets: feeBuckets,
        feeEstimates: feeEstimates,
      );
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      log.e('Error fetching mempool: $e');
    } finally {
      isFetching = false;
    }
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    super.dispose();
  }
}
