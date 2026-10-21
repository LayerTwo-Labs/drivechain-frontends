import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:truthcoin/pages/market_detail_page.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/price_history_provider.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.marketGetResponse = TestData.sampleMarketDetail;
    mockRpc.marketBuyResponse = TestData.sampleMarketBuyDryRun;
    mockRpc.marketSellResponse = TestData.sampleMarketSellDryRun;
    mockRpc.marketPositionsResponse = TestData.sampleMarketPositions;

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final marketProvider = MarketProvider();
    GetIt.I.registerLazySingleton<MarketProvider>(() => marketProvider);
    GetIt.I.registerLazySingleton<PriceHistoryProvider>(() => PriceHistoryProvider());

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

      expect(find.textContaining('Markets'), findsWidgets);
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

  group('MarketDetailPage with two decisions', () {
    Map<String, dynamic> twoDimensions() =>
        jsonDecode(File('test/fixtures/market_two_dimensions.json').readAsStringSync()) as Map<String, dynamic>;

    testWidgets('shows the questions and one answer column per question', (tester) async {
      mockRpc.marketGetResponse = twoDimensions();
      addTearDown(() => mockRpc.marketGetResponse = TestData.sampleMarketDetail);

      await tester.pumpSailPage(const MarketDetailPage(marketId: '5e5ed0d19c4f'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Pick your outcome'), findsOneWidget);
      expect(find.text('Any answer'), findsNWidgets(2));
      expect(find.text('4 of 4 outcomes match'), findsOneWidget);
      expect(find.text('Will eCash use a different DAA than Bitcoin by Jan 1, 2027?'), findsWidgets);
      expect(find.text('Trade'), findsNWidgets(4));
      expect(find.text('Not picked'), findsNWidgets(2));
      expect(find.textContaining('Pick an answer for each question'), findsOneWidget);
    });

    testWidgets('Trade on a row picks its answers and hides the other rows', (tester) async {
      mockRpc.marketGetResponse = twoDimensions();
      addTearDown(() => mockRpc.marketGetResponse = TestData.sampleMarketDetail);

      await tester.pumpSailPage(const MarketDetailPage(marketId: '5e5ed0d19c4f'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Trade').at(1));
      await tester.tap(find.text('Trade').at(1));
      await tester.pumpAndSettle();

      expect(find.text('Selected'), findsOneWidget);
      expect(find.text('Trade'), findsNothing);
      expect(find.text('1 of 4 outcomes match'), findsOneWidget);
      expect(find.text('3 outcomes hidden by your picks.'), findsOneWidget);
      expect(find.text('Not picked'), findsNothing);
      expect(find.text('Buy No · Yes'), findsWidgets);
    });

    test('picks filter the outcomes and select the one full match', () async {
      mockRpc.marketGetResponse = twoDimensions();
      addTearDown(() => mockRpc.marketGetResponse = TestData.sampleMarketDetail);
      final model = MarketDetailViewModel(marketId: '5e5ed0d19c4f');
      addTearDown(model.dispose);
      await model.load();

      expect(model.hasQuestions, isTrue);
      expect(model.picks, [null, null]);
      expect(model.matchingOutcomes.length, 4);
      expect(model.selectedOutcome, isNull);

      model.setPick(0, 1);
      expect([for (final o in model.matchingOutcomes) o.index], [2, 3]);
      expect(model.selectedOutcome, isNull);

      model.setPick(1, 0);
      expect([for (final o in model.matchingOutcomes) o.index], [2]);
      expect(model.selectedOutcome?.index, 2);

      model.setPick(1, null);
      expect(model.matchingOutcomes.length, 2);
      expect(model.selectedOutcome, isNull);

      model.setPick(1, 1);
      model.clearPicks();
      expect(model.picks, [null, null]);
      expect(model.matchingOutcomes.length, 4);
      expect(model.selectedOutcome, isNull);
    });

    test('Trade on a row sets every pick to the answers of the row', () async {
      mockRpc.marketGetResponse = twoDimensions();
      addTearDown(() => mockRpc.marketGetResponse = TestData.sampleMarketDetail);
      final model = MarketDetailViewModel(marketId: '5e5ed0d19c4f');
      addTearDown(model.dispose);
      await model.load();

      model.selectOutcome(model.orderedOutcomes[1]);

      expect(model.picks, [0, 1]);
      expect(model.selectedOutcome?.index, 1);
      expect([for (final o in model.matchingOutcomes) o.index], [1]);
    });

    test('an outcome from the market grid sets the picks', () async {
      mockRpc.marketGetResponse = twoDimensions();
      addTearDown(() => mockRpc.marketGetResponse = TestData.sampleMarketDetail);
      final model = MarketDetailViewModel(marketId: '5e5ed0d19c4f', initialOutcomeIndex: 2);
      addTearDown(model.dispose);
      await model.load();

      expect(model.picks, [1, 0]);
      expect(model.selectedOutcome?.index, 2);
    });
  });

  group('MarketDetailPage with one decision', () {
    testWidgets('shows no question picker', (tester) async {
      mockRpc.marketGetResponse = {
        ...TestData.sampleMarketDetail,
        'dimensions': [
          {
            'dimension_index': 0,
            'decision_id': '004008',
            'name': r'Will BTC close above $150,000?',
            'kind': {'type': 'binary', 'lower_label': 'No', 'upper_label': 'Yes'},
          },
        ],
      };
      addTearDown(() => mockRpc.marketGetResponse = TestData.sampleMarketDetail);

      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      expect(find.text('Pick your outcome'), findsNothing);
      expect(find.text('Any answer'), findsNothing);
    });
  });

  group('MarketDetailPage add liquidity', () {
    testWidgets('hides the card from a wallet that did not create the market', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();
      expect(find.text('Liquidity now'), findsNothing);
    });

    testWidgets('shows the card to the market creator', (WidgetTester tester) async {
      mockRpc.marketGetResponse = {...TestData.sampleMarketDetail, 'creator_address': 'tb1qtest1234567890'};
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();
      expect(find.text('Liquidity now'), findsOneWidget);

      mockRpc.marketGetResponse = TestData.sampleMarketDetail;
    });

    testWidgets('sends market_amplify_beta with the amount', (WidgetTester tester) async {
      mockRpc.marketGetResponse = {...TestData.sampleMarketDetail, 'creator_address': 'tb1qtest1234567890'};
      await tester.pumpSailPage(const MarketDetailPage(marketId: 'market_001'));
      await tester.pumpAndSettle();

      final model = MarketDetailViewModel(marketId: 'market_001');
      await model.load();
      expect(model.canAddLiquidity, true);

      model.liquidityController.text = '50000';
      await model.addLiquidity(tester.element(find.byType(MarketDetailPage)));
      await tester.pumpAndSettle();

      expect(mockRpc.lastAmplifyMarketId, 'market_001');
      expect(mockRpc.lastAmplifyAmountSats, 50000);
      expect(model.liquidityController.text, isEmpty);

      mockRpc.marketGetResponse = TestData.sampleMarketDetail;
      model.dispose();
      // The success toast closes on a timer.
      await tester.pump(const Duration(seconds: 10));
    });
  });

  group('MarketDetailViewModel price history', () {
    test('a load during a load runs one more load after it', () async {
      Map<String, dynamic> point(int height, double yes) => {
        'height': height,
        'block_hash': 'aa',
        'timestamp': 1700000000 + height,
        'prices': [1 - yes, yes],
      };
      final slow = Completer<List<Map<String, dynamic>>?>();
      var calls = 0;
      mockRpc.marketPriceHistoryAnswer = () {
        calls++;
        return calls == 1 ? slow.future : Future.value([point(410, 0.5), point(416, 0.4)]);
      };
      final model = MarketDetailViewModel(marketId: 'm');

      final first = model.loadPriceHistory();
      await model.loadPriceHistory();
      await model.loadPriceHistory();
      expect(calls, 1);

      slow.complete([point(410, 0.5)]);
      await first;

      expect(calls, 2);
      expect(GetIt.I.get<PriceHistoryProvider>().lastTradeHeight('m'), 416);
      expect(model.priceHistoryError, isNull);
      mockRpc.marketPriceHistoryAnswer = null;
      model.dispose();
    });
  });
}
