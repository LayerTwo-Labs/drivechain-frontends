import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:truthcoin/providers/market_provider.dart';

import 'package:truthcoin/pages/market_explorer_page.dart';
import 'package:truthcoin/widgets/market_card.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.marketListResponse = TestData.sampleMarketList;
    mockRpc.marketGetResponse = TestData.sampleMarketDetail;

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
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

  group('MarketExplorerPage', () {
    testWidgets('draws one card per market', (tester) async {
      await tester.pumpSailPage(const MarketExplorerPage());
      await tester.pumpAndSettle();

      expect(find.byType(MarketCard), findsNWidgets(3));
      expect(find.text('Prediction markets'), findsOneWidget);
    });

    testWidgets('shows a chip per state and per tag', (tester) async {
      await tester.pumpSailPage(const MarketExplorerPage());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('LIVE'), findsWidgets);
      expect(find.text('RESOLVED'), findsOneWidget);
      expect(find.text('bitcoin'), findsOneWidget);
      expect(find.text('price'), findsOneWidget);
    });

    testWidgets('shows the outcome price of a market', (tester) async {
      await tester.pumpSailPage(const MarketExplorerPage());
      await tester.pumpAndSettle();

      expect(find.text('Buy Yes'), findsWidgets);
      expect(find.text('65%'), findsWidgets);
    });

    test('provider loads markets successfully', () async {
      final marketProvider = GetIt.I.get<MarketProvider>();
      await marketProvider.loadMarkets();

      expect(marketProvider.markets.length, 3);
      expect(marketProvider.markets.first.title, contains('BTC'));
    });

    test('provider handles filtering', () async {
      final marketProvider = GetIt.I.get<MarketProvider>();
      await marketProvider.loadMarkets();

      marketProvider.setSearchQuery('BTC');
      expect(marketProvider.filteredMarkets.length, 1);

      marketProvider.setSearchQuery('');
      expect(marketProvider.filteredMarkets.length, 3);
    });

    test('provider loads a price per listed market', () async {
      final marketProvider = GetIt.I.get<MarketProvider>();
      await marketProvider.loadMarkets();
      await marketProvider.loadMarketPrices(batchSize: 2);

      expect(marketProvider.marketDetails.length, 3);
      expect(marketProvider.priceError, null);
      expect(marketProvider.isLoadingPrices, false);

      final detail = marketProvider.marketDetails['market_001'];
      expect(detail, isNotNull);
      expect(detail!.outcomes.first.name, 'Yes');
    });

    test('a loaded price does not load again', () async {
      final marketProvider = GetIt.I.get<MarketProvider>();
      await marketProvider.loadMarkets();
      await marketProvider.loadMarketPrices();

      final before = mockRpc.marketGetCalls;
      await marketProvider.loadMarketPrices();
      expect(mockRpc.marketGetCalls, before);

      await marketProvider.loadMarketPrices(refresh: true);
      expect(mockRpc.marketGetCalls, before + 3);
    });

    test('the tag filter keeps the markets that carry the tag', () async {
      final marketProvider = GetIt.I.get<MarketProvider>();
      await marketProvider.loadMarkets();
      await marketProvider.loadMarketPrices();

      expect(marketProvider.availableTags, ['bitcoin', 'crypto', 'price']);

      marketProvider.setTagFilter('bitcoin');
      expect(marketProvider.filteredMarkets.length, 3);

      marketProvider.setTagFilter('football');
      expect(marketProvider.filteredMarkets, isEmpty);

      marketProvider.setTagFilter(null);
      expect(marketProvider.filteredMarkets.length, 3);
    });

    test('a price load failure lands in priceError', () async {
      final marketProvider = GetIt.I.get<MarketProvider>();
      await marketProvider.loadMarkets();

      mockRpc.shouldThrowOnMarketGet = true;
      await marketProvider.loadMarketPrices(refresh: true);
      mockRpc.shouldThrowOnMarketGet = false;

      expect(marketProvider.priceError, isNotNull);
    });
  });
}
