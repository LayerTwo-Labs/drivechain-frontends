import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/mocks/mocks.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/truthcoin_rpc.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:truthcoin/pages/market_detail_page.dart';
import 'package:truthcoin/providers/market_provider.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.marketGetResponse = TestData.sampleMarketDetail;
    mockRpc.marketBuyResponse = TestData.sampleMarketBuyDryRun;
    mockRpc.marketSellResponse = TestData.sampleMarketSellDryRun;
    mockRpc.marketPositionsResponse = TestData.sampleMarketPositions;

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<MainchainRPC>(() => MockMainchainRPC());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final marketProvider = MarketProvider();
    GetIt.I.registerLazySingleton<MarketProvider>(() => marketProvider);

    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  group('MarketDetailPage', () {
    testWidgets('renders market detail page', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      expect(find.byType(MarketDetailPage), findsOneWidget);
    });

    testWidgets('shows back navigation', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      // Back button with icon or text
      expect(find.textContaining('Back'), findsWidgets);
    });

    testWidgets('displays market title', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      // Market title from test data
      expect(find.textContaining('BTC'), findsWidgets);
    });

    testWidgets('shows outcomes', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      // Yes and No outcomes from test data
      expect(find.text('Yes'), findsWidgets);
      expect(find.text('No'), findsWidgets);
    });

    testWidgets('shows trading panel', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Trade'), findsWidgets);
    });

    testWidgets('shows buy and sell buttons', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Buy'), findsWidgets);
      expect(find.textContaining('Sell'), findsWidgets);
    });

    testWidgets('handles market not found', (WidgetTester tester) async {
      mockRpc.marketGetResponse = null;

      await tester.pumpSailPage(const MarketDetailPage(marketId: 'nonexistent'));
      await tester.pumpAndSettle();

      // Should show some kind of error or empty state
      expect(find.byType(MarketDetailPage), findsOneWidget);

      // Restore for other tests
      mockRpc.marketGetResponse = TestData.sampleMarketDetail;
    });
  });
}
