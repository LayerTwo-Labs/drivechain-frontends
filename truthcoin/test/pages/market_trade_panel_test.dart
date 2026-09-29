import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:truthcoin/pages/market_detail_page.dart';
import 'package:truthcoin/providers/market_provider.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

Map<String, dynamic> walletPositions() => {
  'address': 'tb1qfirstaddress',
  'total_value': 0.001,
  'total_cost_basis': 0.0008,
  'total_unrealized_pnl': 0.0002,
  'active_markets': 1,
  'last_updated_height': 100,
  'positions': [
    {
      'market_id': 'market_001',
      'outcome_index': 1,
      'outcome_name': 'Yes',
      'shares': 4820,
      'avg_purchase_price': 0.54,
      'current_price': 0.65,
      'current_value': 0.00313,
      'unrealized_pnl': 0.0005,
      'cost_basis': 0.0026,
    },
  ],
};

Map<String, dynamic> tradingMarket() => {
  'market_id': 'market_001',
  'title': r'Will BTC reach $100k by end of 2026?',
  'description': 'The market pays Yes above the price.',
  'state': 'trading',
  'beta': 7.0,
  'trading_fee_rate': 0.005,
  'total_volume_sats': 150000000,
  'created_at_height': 100,
  'outcomes': [
    {'outcome_index': 0, 'label': 'No', 'price': 0.35, 'volume_sats': 50000000, 'full_state_index': 0},
    {'outcome_index': 1, 'label': 'Yes', 'price': 0.65, 'volume_sats': 100000000, 'full_state_index': 1},
  ],
};

/// A context that never mounts, so a view model can run without a widget.
class _FakeContext implements BuildContext {
  @override
  bool get mounted => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.marketGetResponse = tradingMarket();
    mockRpc.marketListResponse = [
      {
        'market_id': 'market_001',
        'title': 'Will BTC reach 100k?',
        'description': '',
        'outcome_count': 2,
        'state': 'trading',
        'volume_sats': 1,
        'created_at_height': 1,
      },
    ];
    mockRpc.marketPositionsResponse = walletPositions();
    mockRpc.walletAddresses = ['tb1qfirstaddress', 'tb1qsecondaddress'];

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));
    GetIt.I.registerLazySingleton<MarketProvider>(() => MarketProvider());

    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  group('trade panel', () {
    testWidgets('the buy side names the selected outcome and the balance', (tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      expect(find.text('Buy Yes'), findsWidgets);
      expect(find.textContaining('balance'), findsWidgets);
    });

    testWidgets('the sell side picks a wallet address and reads the holding', (tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();

      expect(find.text('tb1qfirstaddress'), findsWidgets);
      expect(find.text('you hold 4820'), findsOneWidget);
      expect(find.text('Max'), findsWidgets);
    });
  });

  group('MarketDetailViewModel', () {
    test('the wallet address loads its holding of the market', () async {
      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.load();

      expect(model.walletAddresses.length, 2);
      expect(model.sellerAddress, 'tb1qfirstaddress');
      expect(model.selectedOutcome!.name, 'Yes');
      expect(model.sellerShares, 4820);

      await model.sellEverything();
      expect(model.sellSharesController.text, '4820');

      model.dispose();
    });

    test('a position read names an address', () async {
      mockRpc.lastPositionsAddress = null;

      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.load();

      expect(mockRpc.lastPositionsAddress, isNotNull);
      expect(model.positions.map((p) => p.address), contains('tb1qfirstaddress'));
      expect(model.positionsError, null);

      model.dispose();
    });

    test('a failed load drops the market of the last route', () async {
      final first = MarketDetailViewModel(marketId: 'market_001');
      await first.loadMarket();
      expect(first.market, isNotNull);
      first.dispose();

      mockRpc.marketGetResponse = null;
      final second = MarketDetailViewModel(marketId: 'market_002');
      await second.loadMarket();

      expect(second.market, null);
      expect(second.selectedOutcome, null);

      mockRpc.marketGetResponse = tradingMarket();
      second.dispose();
    });

    test('a market load refreshes the price the grid shows', () async {
      final provider = GetIt.I.get<MarketProvider>();
      await provider.loadMarkets();
      await provider.loadMarketPrices();
      expect(provider.marketDetails['market_001']!.outcomes.last.currentPrice, 0.65);

      // A trade moves the price, and the reload after it feeds the grid.
      mockRpc.marketGetResponse = {
        ...tradingMarket(),
        'outcomes': [
          {'outcome_index': 0, 'label': 'No', 'price': 0.25, 'volume_sats': 50000000, 'full_state_index': 0},
          {'outcome_index': 1, 'label': 'Yes', 'price': 0.75, 'volume_sats': 100000000, 'full_state_index': 1},
        ],
      };
      await provider.loadMarket('market_001');

      expect(provider.marketDetails['market_001']!.outcomes.last.currentPrice, 0.75);

      mockRpc.marketGetResponse = tradingMarket();
    });

    test('a market that the node drops leaves no price behind', () async {
      final provider = GetIt.I.get<MarketProvider>();
      await provider.loadMarkets();
      await provider.loadMarketPrices();
      expect(provider.marketDetails.containsKey('market_001'), true);

      mockRpc.marketGetResponse = null;
      await provider.loadMarket('market_001');
      expect(provider.marketDetails.containsKey('market_001'), false);

      mockRpc.marketGetResponse = tradingMarket();
    });

    test('a new route never shows the market of the last one', () async {
      final first = MarketDetailViewModel(marketId: 'market_001');
      await first.load();
      expect(first.market, isNotNull);
      first.dispose();

      final second = MarketDetailViewModel(marketId: 'market_002');
      final pending = second.load();

      // The wallet read runs first, and the page holds no market until then.
      expect(second.market, null);
      expect(second.selectedOutcome, null);

      await pending;
      second.dispose();
    });

    test('the preview counts the trading fee one time', () async {
      mockRpc.marketBuyResponse = {'cost_sats': 15000, 'trading_fee_sats': 100, 'new_price': 0.66};

      final provider = GetIt.I.get<MarketProvider>();
      final preview = await provider.buySharesPreview(marketId: 'market_001', outcomeIndex: 1, shares: 100);

      expect(preview.totalCostSats, 15000);
      expect(preview.feeSats, 100);
      expect(preview.costSats, 14900);
    });

    test('a buy sends the cost limit the node asks for', () async {
      mockRpc.marketBuyResponse = {'cost_sats': 15000, 'trading_fee_sats': 100, 'new_price': 0.66};
      mockRpc.lastBuyMaxCost = null;

      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.loadMarket();
      model.sharesController.text = '100';
      await model.updatePreview();
      await model.executeBuy(_FakeContext());

      // 15000 market cost plus a 2 percent step. The node pays its own
      // miner fee, which max_cost never covers.
      expect(mockRpc.lastBuyMaxCost, 15000 + 300);

      model.dispose();
    });

    test('a reload drops every open quote', () async {
      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.load();

      model.sharesController.text = '100';
      await model.updatePreview();
      expect(model.preview, isNotNull);

      await model.load();

      expect(model.preview, null);
      expect(model.sellPreview, null);
      expect(model.sharesController.text, '');

      model.dispose();
    });

    test('an address failure stands, and no share list hides it', () async {
      mockRpc.shouldThrowOnWalletAddresses = true;

      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.load();

      expect(model.positionsError, contains('wallet addresses'));
      expect(model.positions, isEmpty);

      mockRpc.shouldThrowOnWalletAddresses = false;
      model.dispose();
    });

    test('a new share count drops the old quote at once', () async {
      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.load();

      model.sharesController.text = '100';
      await model.updatePreview();
      expect(model.preview, isNotNull);

      model.sharesController.text = '200';
      final pending = model.updatePreview();

      // The button holds no quote while the new one loads.
      expect(model.preview, null);

      await pending;
      expect(model.preview, isNotNull);

      model.dispose();
    });

    test('a late sell preview never wins', () async {
      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.load();

      model.sellSharesController.text = '10';
      final tenShares = model.updateSellPreview();

      // A second edit starts while the first answer waits.
      model.sellSharesController.text = '1';
      final oneShare = model.updateSellPreview();

      await Future.wait([tenShares, oneShare]);

      expect(model.sellShares, 1);
      expect(model.sellPreview, isNotNull);

      model.dispose();
    });

    test('a buy above the balance blocks the button', () async {
      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.loadMarket();

      mockRpc.marketBuyResponse = {'cost_sats': 500000000, 'trading_fee_sats': 1000};
      model.sharesController.text = '5000';
      await model.updatePreview();

      expect(model.preview, isNotNull);
      expect(model.buyCostsTooMuch, true);

      mockRpc.marketBuyResponse = {'cost_sats': 15000, 'trading_fee_sats': 100};
      await model.updatePreview();
      expect(model.buyCostsTooMuch, false);

      model.dispose();
    });
  });
}
