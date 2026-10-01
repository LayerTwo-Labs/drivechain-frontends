import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:truthcoin/pages/tabs/portfolio_page.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

Map<String, dynamic> positionsFor(String address, String marketId, String outcome, int shares, double cost) => {
  'address': address,
  'total_value': shares.toDouble(),
  'total_cost_basis': cost,
  'total_unrealized_pnl': shares - cost,
  'active_markets': 1,
  'last_updated_height': 100,
  'positions': [
    {
      'market_id': marketId,
      'outcome_index': 1,
      'outcome_name': outcome,
      'shares': shares,
      'avg_purchase_price': 0.54,
      'current_price': 0.62,
      'current_value': shares.toDouble(),
      'unrealized_pnl': shares - cost,
      'cost_basis': cost,
    },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.marketListResponse = TestData.sampleMarketList;
    mockRpc.marketPositionsResponse = TestData.sampleMarketPositions;
    mockRpc.votecoinBalanceResponse = 1240;
    mockRpc.walletAddresses = ['tb1qfirst', 'tb1qsecond'];
    mockRpc.marketPositionsByAddress = {
      'tb1qfirst': positionsFor('tb1qfirst', 'market_001', 'Yes', 4820, 2600.0),
      'tb1qsecond': positionsFor('tb1qsecond', 'market_002', 'Republican', 1200, 900.0),
    };

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    GetIt.I.registerLazySingleton<MarketProvider>(() => MarketProvider());
    GetIt.I.registerLazySingleton<PriceHistoryProvider>(() => PriceHistoryProvider());
    GetIt.I.registerLazySingleton<VotingProvider>(() => VotingProvider());

    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  group('PortfolioPage', () {
    testWidgets('shows the four stat tiles', (tester) async {
      await tester.pumpSailPage(const PortfolioPage());
      await tester.pumpAndSettle();

      expect(find.text('Portfolio value'), findsOneWidget);
      expect(find.text('Profit and loss'), findsOneWidget);
      expect(find.text('Open positions'), findsWidgets);
      expect(find.text('Votecoin'), findsOneWidget);
      // Two addresses each report 1240 Votecoin.
      expect(find.text('2480'), findsOneWidget);
    });

    testWidgets('lists the positions of every wallet address', (tester) async {
      await tester.pumpSailPage(const PortfolioPage());
      await tester.pumpAndSettle();

      expect(find.text('Open positions'), findsWidgets);
      expect(find.textContaining('BTC reach'), findsWidgets);
      expect(find.text('Yes'), findsWidgets);
      expect(find.text('Republican'), findsWidgets);
      expect(find.text('tb1qfirst'), findsOneWidget);
      expect(find.text('tb1qsecond'), findsOneWidget);
    });

    testWidgets('a position load failure shows the error', (tester) async {
      mockRpc.shouldThrowOnMarketPositions = true;

      await tester.pumpSailPage(const PortfolioPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load the positions'), findsOneWidget);
      expect(find.text('You hold no share yet'), findsNothing);

      mockRpc.shouldThrowOnMarketPositions = false;
    });

    testWidgets('an address without a share shows the empty state', (tester) async {
      mockRpc.marketPositionsByAddress = {};
      mockRpc.marketPositionsResponse = {
        'address': 'tb1qtest1234567890',
        'total_value': 0.0,
        'total_cost_basis': 0.0,
        'total_unrealized_pnl': 0.0,
        'active_markets': 0,
        'last_updated_height': 0,
        'positions': <Map<String, dynamic>>[],
      };

      await tester.pumpSailPage(const PortfolioPage());
      await tester.pumpAndSettle();

      expect(find.text('You hold no share yet'), findsWidgets);
    });

    test('a Votecoin failure stops the load and clears the totals', () async {
      mockRpc.marketPositionsByAddress = {
        'tb1qfirst': positionsFor('tb1qfirst', 'market_001', 'Yes', 4820, 2600.0),
        'tb1qsecond': positionsFor('tb1qsecond', 'market_002', 'Republican', 1200, 900.0),
      };

      final model = PortfolioViewModel();
      await model.load();
      expect(model.totalValueSats, 6020);

      mockRpc.shouldThrowOnVotecoinBalance = true;
      await model.load();

      expect(model.loadError, contains('Votecoin'));
      expect(model.totalValueSats, 0);
      expect(model.votecoinBalance, 0);

      mockRpc.shouldThrowOnVotecoinBalance = false;
      model.dispose();
    });

    test('an address read failure clears the old snapshot', () async {
      mockRpc.marketPositionsByAddress = {
        'tb1qfirst': positionsFor('tb1qfirst', 'market_001', 'Yes', 4820, 2600.0),
        'tb1qsecond': positionsFor('tb1qsecond', 'market_002', 'Republican', 1200, 900.0),
      };

      final model = PortfolioViewModel();
      await model.load();
      expect(model.totalValueSats, 6020);

      mockRpc.shouldThrowOnWalletAddresses = true;
      await model.load();

      expect(model.loadError, contains('wallet addresses'));
      expect(model.addresses, isEmpty);
      expect(model.positions, isEmpty);
      expect(model.totalValueSats, 0);
      expect(model.votecoinBalance, 0);

      mockRpc.shouldThrowOnWalletAddresses = false;
      model.dispose();
    });

    test('the totals add up every address', () async {
      mockRpc.marketPositionsByAddress = {
        'tb1qfirst': positionsFor('tb1qfirst', 'market_001', 'Yes', 4820, 2600.0),
        'tb1qsecond': positionsFor('tb1qsecond', 'market_002', 'Republican', 1200, 900.0),
      };

      final model = PortfolioViewModel();
      await model.load();

      expect(model.addresses, ['tb1qfirst', 'tb1qsecond']);
      expect(model.positions.length, 2);
      expect(model.totalValueSats, 6020);
      expect(model.totalCostBasisSats, 3500);
      expect(model.totalProfitSats, 2520);
      expect(model.activeMarkets, 2);
      expect(model.votecoinBalance, 2480);

      model.dispose();
    });
  });
}
