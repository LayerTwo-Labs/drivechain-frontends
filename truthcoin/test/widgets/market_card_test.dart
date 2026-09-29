import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/widgets/market_card.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

MarketSummary binarySummary() => MarketSummary.fromJson({
  'market_id': 'a41f92c8',
  'title': r'Will BTC close above $150,000?',
  'description': 'The market pays Yes above the price.',
  'outcome_count': 2,
  'state': 'trading',
  'volume_sats': 241000000,
  'created_at_height': 182914,
});

MarketData binaryDetail() => MarketData.fromJson({
  'market_id': 'a41f92c8',
  'title': r'Will BTC close above $150,000?',
  'description': 'The market pays Yes above the price.',
  'state': 'trading',
  'beta': 7.0,
  'trading_fee_rate': 0.005,
  'total_volume_sats': 241000000,
  'created_at_height': 182914,
  'outcomes': [
    {'outcome_index': 0, 'label': 'No', 'price': 0.38, 'volume_sats': 91000000, 'full_state_index': 0},
    {'outcome_index': 1, 'label': 'Yes', 'price': 0.62, 'volume_sats': 150000000, 'full_state_index': 1},
  ],
});

MarketSummary multiSummary() => MarketSummary.fromJson({
  'market_id': 'c7e21a04',
  'title': 'Which sidechain holds the most BTC?',
  'description': 'One outcome pays.',
  'outcome_count': 3,
  'state': 'trading',
  'volume_sats': 117000000,
  'created_at_height': 190204,
});

MarketData multiDetail() => MarketData.fromJson({
  'market_id': 'c7e21a04',
  'title': 'Which sidechain holds the most BTC?',
  'description': 'One outcome pays.',
  'state': 'trading',
  'beta': 8.0,
  'trading_fee_rate': 0.005,
  'total_volume_sats': 117000000,
  'created_at_height': 190204,
  'outcomes': [
    {'outcome_index': 0, 'label': 'Thunder', 'price': 0.41, 'volume_sats': 51000000, 'full_state_index': 0},
    {'outcome_index': 1, 'label': 'BitNames', 'price': 0.27, 'volume_sats': 28000000, 'full_state_index': 1},
    {'outcome_index': 2, 'label': 'Truthcoin', 'price': 0.19, 'volume_sats': 21000000, 'full_state_index': 2},
  ],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final mockRpc = TestTruthcoinRPC();
    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  group('MarketCard', () {
    testWidgets('a binary market shows the Yes chance and both buy buttons', (tester) async {
      var traded = -1;

      await tester.pumpSailPage(
        SizedBox(
          width: 440,
          child: MarketCard(
            market: binarySummary(),
            detail: binaryDetail(),
            onTap: () {},
            onTradeOutcome: (index) => traded = index,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buy Yes'), findsOneWidget);
      expect(find.text('Buy No'), findsOneWidget);
      expect(find.text('62%'), findsNWidgets(2));
      expect(find.text('38%'), findsOneWidget);

      await tester.tap(find.text('Buy Yes'));
      await tester.pumpAndSettle();
      expect(traded, 1);
    });

    testWidgets('a market with many outcomes lists the three best', (tester) async {
      await tester.pumpSailPage(
        SizedBox(
          width: 440,
          child: MarketCard(
            market: multiSummary(),
            detail: multiDetail(),
            onTap: () {},
            onTradeOutcome: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thunder'), findsOneWidget);
      expect(find.text('BitNames'), findsOneWidget);
      expect(find.text('Truthcoin'), findsOneWidget);
      expect(find.text('41%'), findsOneWidget);
      expect(find.text('Yes'), findsNWidgets(3));
    });

    testWidgets('a closed market shows prices without a buy button', (tester) async {
      final closed = MarketSummary.fromJson({
        'market_id': 'a41f92c8',
        'title': r'Will BTC close above $150,000?',
        'description': 'The market ended.',
        'outcome_count': 2,
        'state': 'settled',
        'volume_sats': 241000000,
        'created_at_height': 182914,
      });

      await tester.pumpSailPage(
        SizedBox(
          width: 440,
          child: MarketCard(
            market: closed,
            detail: binaryDetail(),
            onTap: () {},
            onTradeOutcome: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RESOLVED'), findsOneWidget);
      expect(find.text('Buy Yes'), findsNothing);
      expect(find.text('Buy No'), findsNothing);
      expect(find.text('62%'), findsWidgets);
    });

    testWidgets('a card without prices shows a placeholder', (tester) async {
      await tester.pumpSailPage(
        SizedBox(
          width: 440,
          child: MarketCard(
            market: binarySummary(),
            detail: null,
            onTap: () {},
            onTradeOutcome: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('price loads'), findsNWidgets(2));
      expect(find.text('Buy Yes'), findsNothing);
    });
  });

  group('market card helpers', () {
    test('formatChance rounds to a whole percent', () {
      expect(formatChance(0.384), '38%');
    });

    test('marketInitials takes the first two words', () {
      expect(marketInitials('Will BTC close'), 'WB');
      expect(marketInitials(''), '?');
    });
  });
}
