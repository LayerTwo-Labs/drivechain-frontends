import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'package:coinshift/providers/swap_provider.dart';

/// Time range for analytics aggregation.
enum AnalyticsTimeRange {
  hour1,
  hour24,
  day7,
  day30,
  all,
}

extension AnalyticsTimeRangeExtension on AnalyticsTimeRange {
  String get displayName => switch (this) {
        AnalyticsTimeRange.hour1 => '1 Hour',
        AnalyticsTimeRange.hour24 => '24 Hours',
        AnalyticsTimeRange.day7 => '7 Days',
        AnalyticsTimeRange.day30 => '30 Days',
        AnalyticsTimeRange.all => 'All Time',
      };

  Duration get duration => switch (this) {
        AnalyticsTimeRange.hour1 => const Duration(hours: 1),
        AnalyticsTimeRange.hour24 => const Duration(hours: 24),
        AnalyticsTimeRange.day7 => const Duration(days: 7),
        AnalyticsTimeRange.day30 => const Duration(days: 30),
        AnalyticsTimeRange.all => const Duration(days: 365 * 10),
      };
}

/// Aggregated swap statistics.
class SwapStatistics {
  final int totalSwaps;
  final int completedSwaps;
  final int pendingSwaps;
  final int cancelledSwaps;
  final int waitingConfirmations;
  final int l2AmountTotal;
  final int l1AmountTotal;
  final double successRate;
  final double averageL2Amount;
  final double averageL1Amount;
  final Map<ParentChainType, int> swapsByChain;
  final Map<SwapDirection, int> swapsByDirection;

  SwapStatistics({
    required this.totalSwaps,
    required this.completedSwaps,
    required this.pendingSwaps,
    required this.cancelledSwaps,
    required this.waitingConfirmations,
    required this.l2AmountTotal,
    required this.l1AmountTotal,
    required this.successRate,
    required this.averageL2Amount,
    required this.averageL1Amount,
    required this.swapsByChain,
    required this.swapsByDirection,
  });

  factory SwapStatistics.empty() => SwapStatistics(
        totalSwaps: 0,
        completedSwaps: 0,
        pendingSwaps: 0,
        cancelledSwaps: 0,
        waitingConfirmations: 0,
        l2AmountTotal: 0,
        l1AmountTotal: 0,
        successRate: 0,
        averageL2Amount: 0,
        averageL1Amount: 0,
        swapsByChain: {},
        swapsByDirection: {},
      );

  factory SwapStatistics.fromSwaps(List<CoinShiftSwap> swaps) {
    if (swaps.isEmpty) return SwapStatistics.empty();

    final completed = swaps.where((s) => s.state.isCompleted).length;
    final pending = swaps.where((s) => s.state.isPending).length;
    final cancelled = swaps.where((s) => s.state.isCancelled).length;
    final waitingConfirmations = swaps.where((s) => s.state.isWaitingConfirmations).length;

    final l2Total = swaps.fold<int>(0, (sum, s) => sum + s.l2Amount);
    final l1Total = swaps.fold<int>(0, (sum, s) => sum + (s.l1Amount ?? 0));

    final chainCounts = <ParentChainType, int>{};
    final directionCounts = <SwapDirection, int>{};

    for (final swap in swaps) {
      chainCounts[swap.parentChain] = (chainCounts[swap.parentChain] ?? 0) + 1;
      directionCounts[swap.direction] = (directionCounts[swap.direction] ?? 0) + 1;
    }

    return SwapStatistics(
      totalSwaps: swaps.length,
      completedSwaps: completed,
      pendingSwaps: pending,
      cancelledSwaps: cancelled,
      waitingConfirmations: waitingConfirmations,
      l2AmountTotal: l2Total,
      l1AmountTotal: l1Total,
      successRate: swaps.isNotEmpty ? completed / swaps.length : 0,
      averageL2Amount: swaps.isNotEmpty ? l2Total / swaps.length : 0,
      averageL1Amount: swaps.isNotEmpty ? l1Total / swaps.length : 0,
      swapsByChain: chainCounts,
      swapsByDirection: directionCounts,
    );
  }
}

/// Represents a data point for time-series analytics.
class SwapDataPoint {
  final DateTime timestamp;
  final int swapCount;
  final int volumeL2;
  final int volumeL1;

  SwapDataPoint({
    required this.timestamp,
    required this.swapCount,
    required this.volumeL2,
    required this.volumeL1,
  });
}

/// Provider for swap analytics and historical data.
class AnalyticsProvider extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();
  SwapProvider get _swapProvider => GetIt.I.get<SwapProvider>();

  bool isLoading = false;
  String? error;
  Timer? _refreshTimer;

  AnalyticsTimeRange selectedTimeRange = AnalyticsTimeRange.all;
  SwapStatistics statistics = SwapStatistics.empty();
  List<SwapDataPoint> timeSeriesData = [];

  // Chain health metrics
  Map<ParentChainType, ChainHealth> chainHealth = {};

  AnalyticsProvider() {
    _swapProvider.addListener(_onSwapProviderChanged);
    _calculateStatistics();
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _calculateStatistics();
    });
  }

  void _onSwapProviderChanged() {
    _calculateStatistics();
  }

  /// Set the time range filter.
  void setTimeRange(AnalyticsTimeRange range) {
    selectedTimeRange = range;
    _calculateStatistics();
    notifyListeners();
  }

  /// Calculate statistics from current swaps.
  void _calculateStatistics() {
    final swaps = _swapProvider.swaps;

    // Filter by time range if not "all"
    final filteredSwaps = _filterByTimeRange(swaps);

    statistics = SwapStatistics.fromSwaps(filteredSwaps);
    timeSeriesData = _generateTimeSeriesData(filteredSwaps);
    _updateChainHealth();

    notifyListeners();
  }

  List<CoinShiftSwap> _filterByTimeRange(List<CoinShiftSwap> swaps) {
    if (selectedTimeRange == AnalyticsTimeRange.all) {
      return swaps;
    }

    // Filter by created height - approximate since we don't have timestamps
    // Assuming ~10 minutes per block
    final blocksPerHour = 6;
    final currentHeight = swaps.isNotEmpty ? swaps.map((s) => s.createdAtHeight).reduce((a, b) => a > b ? a : b) : 0;

    final blocksToInclude = switch (selectedTimeRange) {
      AnalyticsTimeRange.hour1 => blocksPerHour,
      AnalyticsTimeRange.hour24 => blocksPerHour * 24,
      AnalyticsTimeRange.day7 => blocksPerHour * 24 * 7,
      AnalyticsTimeRange.day30 => blocksPerHour * 24 * 30,
      AnalyticsTimeRange.all => currentHeight + 1,
    };

    final minHeight = currentHeight - blocksToInclude;
    return swaps.where((s) => s.createdAtHeight >= minHeight).toList();
  }

  List<SwapDataPoint> _generateTimeSeriesData(List<CoinShiftSwap> swaps) {
    if (swaps.isEmpty) return [];

    // Group swaps by height buckets
    final bucketSize = switch (selectedTimeRange) {
      AnalyticsTimeRange.hour1 => 1,
      AnalyticsTimeRange.hour24 => 6,
      AnalyticsTimeRange.day7 => 36,
      AnalyticsTimeRange.day30 => 144,
      AnalyticsTimeRange.all => 144,
    };

    final Map<int, List<CoinShiftSwap>> buckets = {};
    for (final swap in swaps) {
      final bucket = (swap.createdAtHeight / bucketSize).floor() * bucketSize;
      buckets.putIfAbsent(bucket, () => []).add(swap);
    }

    final sortedBuckets = buckets.keys.toList()..sort();

    return sortedBuckets.map((bucket) {
      final bucketSwaps = buckets[bucket]!;
      return SwapDataPoint(
        timestamp: DateTime.now().subtract(Duration(minutes: (sortedBuckets.last - bucket) * 10)),
        swapCount: bucketSwaps.length,
        volumeL2: bucketSwaps.fold(0, (sum, s) => sum + s.l2Amount),
        volumeL1: bucketSwaps.fold(0, (sum, s) => sum + (s.l1Amount ?? 0)),
      );
    }).toList();
  }

  void _updateChainHealth() {
    // Calculate health metrics per chain
    final swaps = _swapProvider.swaps;

    for (final chain in ParentChainType.values) {
      final chainSwaps = swaps.where((s) => s.parentChain == chain).toList();
      if (chainSwaps.isEmpty) {
        chainHealth[chain] = ChainHealth(
          chain: chain,
          activeSwaps: 0,
          pendingVolume: 0,
          avgConfirmationTime: 0,
          successRate: 0,
          isHealthy: true,
        );
        continue;
      }

      final activeSwaps = chainSwaps.where((s) => !s.state.isCompleted && !s.state.isCancelled).length;
      final pendingVolume = chainSwaps
          .where((s) => s.state.isPending || s.state.isWaitingConfirmations)
          .fold<int>(0, (sum, s) => sum + s.l2Amount);
      final completedSwaps = chainSwaps.where((s) => s.state.isCompleted).toList();
      final successRate = chainSwaps.isNotEmpty ? completedSwaps.length / chainSwaps.length : 0.0;

      chainHealth[chain] = ChainHealth(
        chain: chain,
        activeSwaps: activeSwaps,
        pendingVolume: pendingVolume,
        avgConfirmationTime: 0, // Would need actual timing data
        successRate: successRate,
        isHealthy: successRate >= 0.8 || chainSwaps.length < 5,
      );
    }
  }

  /// Get swaps that may need attention (stuck, failing, etc.)
  List<CoinShiftSwap> get swapsNeedingAttention {
    return _swapProvider.swaps.where((swap) {
      // Pending for too long
      if (swap.state.isPending && swap.createdAtHeight > 0) {
        return true;
      }
      // Waiting for confirmations for a while
      if (swap.state.isWaitingConfirmations) {
        final current = swap.state.currentConfirmations ?? 0;
        final required = swap.state.requiredConfirmations ?? 1;
        // If less than 50% confirmed after being created
        return current < required / 2;
      }
      return false;
    }).toList();
  }

  /// Get the most active chain by volume.
  ParentChainType? get mostActiveChain {
    if (statistics.swapsByChain.isEmpty) return null;

    ParentChainType? maxChain;
    int maxCount = 0;

    for (final entry in statistics.swapsByChain.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        maxChain = entry.key;
      }
    }

    return maxChain;
  }

  /// Manually refresh analytics.
  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();

    await _swapProvider.refresh();
    _calculateStatistics();

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _swapProvider.removeListener(_onSwapProviderChanged);
    super.dispose();
  }
}

/// Health metrics for a specific chain.
class ChainHealth {
  final ParentChainType chain;
  final int activeSwaps;
  final int pendingVolume;
  final double avgConfirmationTime;
  final double successRate;
  final bool isHealthy;

  ChainHealth({
    required this.chain,
    required this.activeSwaps,
    required this.pendingVolume,
    required this.avgConfirmationTime,
    required this.successRate,
    required this.isHealthy,
  });
}
