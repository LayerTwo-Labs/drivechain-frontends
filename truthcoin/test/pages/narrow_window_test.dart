import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:truthcoin/pages/market_creation_page.dart';
import 'package:truthcoin/pages/market_detail_page.dart';
import 'package:truthcoin/pages/market_explorer_page.dart';
import 'package:truthcoin/pages/tabs/portfolio_page.dart';
import 'package:truthcoin/pages/voting_dashboard_page.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

/// The app allows a window of 400 pixels, so every page fits that width.
const Size _narrow = Size(400, 800);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final mockRpc = TestTruthcoinRPC();
    mockRpc.marketListResponse = TestData.sampleMarketList;
    mockRpc.marketGetResponse = TestData.sampleMarketDetail;
    mockRpc.marketPositionsResponse = TestData.sampleMarketPositions;
    mockRpc.slotStatusResponse = TestData.sampleSlotStatus;
    mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;
    mockRpc.voteVoterResponse = TestData.sampleVoterInfo;
    mockRpc.slotListResponse = TestData.sampleSlotList;

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

  Future<void> pumpNarrow(WidgetTester tester, Widget page) async {
    await tester.pumpSailPage(page);
    await tester.binding.setSurfaceSize(_narrow);
    await tester.pumpAndSettle();
  }

  group('a 400 pixel window', () {
    testWidgets('holds the market grid', (tester) async {
      await pumpNarrow(tester, const MarketExplorerPage());
      expect(find.byType(MarketExplorerPage), findsOneWidget);
    });

    testWidgets('holds the market page', (tester) async {
      await pumpNarrow(tester, const MarketDetailPage(marketId: 'market_001'));
      expect(find.byType(MarketDetailPage), findsOneWidget);
    });

    testWidgets('holds the create form', (tester) async {
      await pumpNarrow(tester, const MarketCreationPage());
      expect(find.byType(MarketCreationPage), findsOneWidget);
    });

    testWidgets('holds the portfolio', (tester) async {
      await pumpNarrow(tester, const PortfolioPage());
      expect(find.byType(PortfolioPage), findsOneWidget);
    });

    testWidgets('holds the oracle ballot', (tester) async {
      await pumpNarrow(tester, const VotingDashboardPage());
      expect(find.byType(VotingDashboardPage), findsOneWidget);
    });
  });
}
