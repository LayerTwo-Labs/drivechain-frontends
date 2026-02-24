import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/mocks/mocks.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/truthcoin_rpc.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/widgets/trading_position_widget.dart';

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

  group('TradingPositionWidget', () {
    testWidgets('renders widget', (WidgetTester tester) async {
      await tester.pumpSailPage(const TradingPositionWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TradingPositionWidget), findsOneWidget);
    });

    testWidgets('shows positions section', (WidgetTester tester) async {
      await tester.pumpSailPage(const TradingPositionWidget());
      await tester.pumpAndSettle();

      // Position-related text
      expect(find.textContaining('Position'), findsWidgets);
    });

    testWidgets('handles empty positions', (WidgetTester tester) async {
      // Set empty positions
      mockRpc.marketPositionsResponse = {
        'address': 'tb1qtest',
        'total_value': 0.0,
        'active_markets': 0,
        'positions': [],
      };

      await tester.pumpSailPage(const TradingPositionWidget());
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(TradingPositionWidget), findsOneWidget);

      // Restore for other tests
      mockRpc.marketPositionsResponse = TestData.sampleMarketPositions;
    });
  });
}
