import 'package:coinshift/providers/analytics_provider.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUpAll(() async {
    final coinshiftRPC = MockCoinShiftRPC();
    GetIt.I.registerLazySingleton<CoinShiftRPC>(() => coinshiftRPC);
    GetIt.I.registerLazySingleton<MainchainRPC>(() => MockMainchainRPC());
    GetIt.I.registerLazySingleton<Logger>(() => Logger());

    // Register SwapProvider (needed by AnalyticsProvider)
    final swapProvider = SwapProvider();
    GetIt.I.registerLazySingleton<SwapProvider>(() => swapProvider);

    // Register AnalyticsProvider
    final analyticsProvider = AnalyticsProvider();
    GetIt.I.registerLazySingleton<AnalyticsProvider>(() => analyticsProvider);
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('SwapStatistics', () {
    test('empty statistics returns zeros', () {
      final stats = SwapStatistics.empty();

      expect(stats.totalSwaps, 0);
      expect(stats.completedSwaps, 0);
      expect(stats.pendingSwaps, 0);
      expect(stats.cancelledSwaps, 0);
      expect(stats.successRate, 0);
      expect(stats.l2AmountTotal, 0);
      expect(stats.l1AmountTotal, 0);
    });

    test('fromSwaps with empty list returns empty statistics', () {
      final stats = SwapStatistics.fromSwaps([]);

      expect(stats.totalSwaps, 0);
      expect(stats.successRate, 0);
    });
  });

  group('AnalyticsTimeRange', () {
    test('displayName returns correct values', () {
      expect(AnalyticsTimeRange.hour1.displayName, '1 Hour');
      expect(AnalyticsTimeRange.hour24.displayName, '24 Hours');
      expect(AnalyticsTimeRange.day7.displayName, '7 Days');
      expect(AnalyticsTimeRange.day30.displayName, '30 Days');
      expect(AnalyticsTimeRange.all.displayName, 'All Time');
    });

    test('duration returns correct values', () {
      expect(AnalyticsTimeRange.hour1.duration, const Duration(hours: 1));
      expect(AnalyticsTimeRange.hour24.duration, const Duration(hours: 24));
      expect(AnalyticsTimeRange.day7.duration, const Duration(days: 7));
      expect(AnalyticsTimeRange.day30.duration, const Duration(days: 30));
    });
  });

  group('AnalyticsProvider', () {
    test('initializes with default time range', () {
      final provider = GetIt.I.get<AnalyticsProvider>();

      expect(provider.selectedTimeRange, AnalyticsTimeRange.all);
      expect(provider.statistics, isNotNull);
      expect(provider.chainHealth, isNotNull);
    });

    test('setTimeRange updates selected time range', () {
      final provider = GetIt.I.get<AnalyticsProvider>();

      provider.setTimeRange(AnalyticsTimeRange.day7);
      expect(provider.selectedTimeRange, AnalyticsTimeRange.day7);

      provider.setTimeRange(AnalyticsTimeRange.all);
      expect(provider.selectedTimeRange, AnalyticsTimeRange.all);
    });
  });

  group('ChainHealth', () {
    test('creates chain health with correct values', () {
      final health = ChainHealth(
        chain: ParentChainType.btc,
        activeSwaps: 5,
        pendingVolume: 100000,
        avgConfirmationTime: 10.5,
        successRate: 0.85,
        isHealthy: true,
      );

      expect(health.chain, ParentChainType.btc);
      expect(health.activeSwaps, 5);
      expect(health.pendingVolume, 100000);
      expect(health.avgConfirmationTime, 10.5);
      expect(health.successRate, 0.85);
      expect(health.isHealthy, true);
    });
  });
}
