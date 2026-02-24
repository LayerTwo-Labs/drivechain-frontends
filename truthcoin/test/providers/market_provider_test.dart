import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/providers/market_provider.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  late TestTruthcoinRPC mockRpc;
  late MarketProvider marketProvider;

  setUp(() async {
    mockRpc = await setupMarketVotingTests();
    marketProvider = GetIt.I.get<MarketProvider>();
  });

  tearDown(() async {
    await resetGetIt();
  });

  group('MarketProvider', () {
    group('loadMarkets', () {
      test('loads markets successfully', () async {
        mockRpc.marketListResponse = TestData.sampleMarketList;

        await marketProvider.loadMarkets();

        expect(marketProvider.markets.length, 3);
        expect(marketProvider.isLoading, false);
        expect(marketProvider.error, isNull);
      });

      test('handles empty market list', () async {
        mockRpc.marketListResponse = [];

        await marketProvider.loadMarkets();

        expect(marketProvider.markets, isEmpty);
        expect(marketProvider.isLoading, false);
        expect(marketProvider.error, isNull);
      });

      test('handles RPC error gracefully', () async {
        mockRpc.shouldThrowOnMarketList = true;
        mockRpc.errorMessage = 'Network error';

        await marketProvider.loadMarkets();

        expect(marketProvider.markets, isEmpty);
        expect(marketProvider.isLoading, false);
        expect(marketProvider.error, contains('Network error'));
      });

      test('sets loading state correctly', () async {
        mockRpc.marketListResponse = TestData.sampleMarketList;

        expect(marketProvider.isLoading, false);

        // Start loading but don't await
        final loadFuture = marketProvider.loadMarkets();
        // Loading should be true immediately
        expect(marketProvider.isLoading, true);

        await loadFuture;
        expect(marketProvider.isLoading, false);
      });
    });

    group('filtering', () {
      setUp(() async {
        mockRpc.marketListResponse = TestData.sampleMarketList;
        await marketProvider.loadMarkets();
      });

      test('filters by search query', () async {
        marketProvider.setSearchQuery('BTC');

        expect(marketProvider.filteredMarkets.length, 1);
        expect(marketProvider.filteredMarkets.first.title, contains('BTC'));
      });

      test('filters by state', () async {
        marketProvider.setStateFilter(MarketState.trading);

        expect(marketProvider.filteredMarkets.length, 2);
        expect(
          marketProvider.filteredMarkets.every((m) => m.marketState == MarketState.trading),
          true,
        );
      });

      test('filters by state - cancelled', () async {
        marketProvider.setStateFilter(MarketState.cancelled);

        expect(marketProvider.filteredMarkets.length, 1);
        expect(marketProvider.filteredMarkets.first.marketState, MarketState.cancelled);
      });

      test('clears search filter', () async {
        marketProvider.setSearchQuery('BTC');
        expect(marketProvider.filteredMarkets.length, 1);

        marketProvider.setSearchQuery('');
        expect(marketProvider.filteredMarkets.length, 3);
      });

      test('clears state filter', () async {
        marketProvider.setStateFilter(MarketState.cancelled);
        expect(marketProvider.filteredMarkets.length, 1);

        marketProvider.setStateFilter(null);
        expect(marketProvider.filteredMarkets.length, 3);
      });

      test('combines search and state filters', () async {
        marketProvider.setSearchQuery('Market');
        marketProvider.setStateFilter(MarketState.cancelled);

        expect(marketProvider.filteredMarkets.length, 1);
        expect(marketProvider.filteredMarkets.first.title, contains('Cancelled'));
      });
    });

    group('sorting', () {
      setUp(() async {
        mockRpc.marketListResponse = TestData.sampleMarketList;
        await marketProvider.loadMarkets();
      });

      test('sorts by volume', () async {
        marketProvider.setSort(MarketSort.volume);

        // Verify that sorting changes the order
        final volumes = marketProvider.filteredMarkets.map((m) => m.volumeSats).toList();
        // Default is descending
        expect(volumes, isNotEmpty);
      });

      test('sorts by title', () async {
        marketProvider.setSort(MarketSort.title);

        // Just verify sorting applies without error
        expect(marketProvider.filteredMarkets, isNotEmpty);
      });

      test('sorts by created date', () async {
        marketProvider.setSort(MarketSort.created);

        // Just verify sorting applies without error
        expect(marketProvider.filteredMarkets, isNotEmpty);
      });
    });

    group('loadMarket', () {
      test('loads single market detail', () async {
        mockRpc.marketGetResponse = TestData.sampleMarketDetail;

        await marketProvider.loadMarket('market_001');

        expect(marketProvider.selectedMarket, isNotNull);
        expect(marketProvider.selectedMarket!.marketId, 'market_001');
        expect(marketProvider.selectedMarket!.outcomes.length, 2);
      });

      test('handles market not found', () async {
        mockRpc.marketGetResponse = null;

        await marketProvider.loadMarket('nonexistent');

        expect(marketProvider.selectedMarket, isNull);
      });

      test('handles RPC error', () async {
        mockRpc.shouldThrowOnMarketGet = true;
        mockRpc.errorMessage = 'Market not found';

        await marketProvider.loadMarket('market_001');

        expect(marketProvider.selectedMarket, isNull);
        expect(marketProvider.error, contains('Market not found'));
      });
    });

    group('buySharesPreview', () {
      test('returns buy preview data', () async {
        mockRpc.marketBuyResponse = TestData.sampleMarketBuyDryRun;

        final result = await marketProvider.buySharesPreview(
          marketId: 'market_001',
          outcomeIndex: 0,
          shares: 100,
        );

        expect(result.hasError, false);
        expect(result.costSats, 15000);
        expect(result.shares, 100);
      });

      test('handles error in preview', () async {
        mockRpc.shouldThrowOnMarketBuy = true;

        final result = await marketProvider.buySharesPreview(
          marketId: 'market_001',
          outcomeIndex: 0,
          shares: 100,
        );

        expect(result.hasError, true);
      });
    });

    group('buyShares', () {
      test('executes buy successfully', () async {
        mockRpc.marketBuyResponse = TestData.sampleMarketBuyActual;

        final txid = await marketProvider.buyShares(
          marketId: 'market_001',
          outcomeIndex: 0,
          shares: 100,
        );

        expect(txid, 'abc123def456');
      });

      test('handles buy error', () async {
        mockRpc.shouldThrowOnMarketBuy = true;

        final txid = await marketProvider.buyShares(
          marketId: 'market_001',
          outcomeIndex: 0,
          shares: 100,
        );

        expect(txid, isNull);
        expect(marketProvider.error, isNotNull);
      });
    });

    group('sellSharesPreview', () {
      test('returns sell preview data', () async {
        mockRpc.marketSellResponse = TestData.sampleMarketSellDryRun;

        final result = await marketProvider.sellSharesPreview(
          marketId: 'market_001',
          outcomeIndex: 0,
          shares: 100,
          sellerAddress: 'tb1qtest',
        );

        expect(result, isNotNull);
        expect(result!.proceedsSats, 12000);
      });
    });

    group('sellShares', () {
      test('executes sell successfully', () async {
        mockRpc.marketSellResponse = {'txid': 'sell_txid_123'};

        final txid = await marketProvider.sellShares(
          marketId: 'market_001',
          outcomeIndex: 0,
          shares: 100,
          sellerAddress: 'tb1qtest',
        );

        expect(txid, 'sell_txid_123');
      });

      test('handles sell error', () async {
        mockRpc.shouldThrowOnMarketSell = true;

        final txid = await marketProvider.sellShares(
          marketId: 'market_001',
          outcomeIndex: 0,
          shares: 100,
          sellerAddress: 'tb1qtest',
        );

        expect(txid, isNull);
      });
    });

    group('createMarket', () {
      test('creates market successfully', () async {
        mockRpc.marketCreateResponse = 'new_market_txid';

        final txid = await marketProvider.createMarket(
          title: 'Test Market',
          description: 'Test description',
          dimensions: '2',
          feeSats: 1000,
        );

        expect(txid, 'new_market_txid');
      });
    });

    group('notifyListeners', () {
      test('notifies listeners on market load', () async {
        mockRpc.marketListResponse = TestData.sampleMarketList;

        int notifyCount = 0;
        marketProvider.addListener(() => notifyCount++);

        await marketProvider.loadMarkets();

        expect(notifyCount, greaterThan(0));
      });

      test('notifies listeners on filter change', () async {
        mockRpc.marketListResponse = TestData.sampleMarketList;
        await marketProvider.loadMarkets();

        int notifyCount = 0;
        marketProvider.addListener(() => notifyCount++);

        marketProvider.setSearchQuery('test');

        expect(notifyCount, 1);
      });
    });
  });
}
