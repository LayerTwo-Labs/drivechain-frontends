import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/mocks/mocks.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/truthcoin_rpc.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:truthcoin/pages/voting_dashboard_page.dart';
import 'package:truthcoin/providers/voting_provider.dart';

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
    mockRpc.slotStatusResponse = TestData.sampleSlotStatus;
    mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;
    mockRpc.voteVoterResponse = TestData.sampleVoterInfo;
    mockRpc.slotListResponse = TestData.sampleSlotList;

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<MainchainRPC>(() => MockMainchainRPC());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final votingProvider = VotingProvider();
    GetIt.I.registerLazySingleton<VotingProvider>(() => votingProvider);

    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  group('VotingDashboardPage', () {
    testWidgets('renders voting dashboard page', (WidgetTester tester) async {
      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      expect(find.byType(VotingDashboardPage), findsOneWidget);
    });

    testWidgets('shows page title', (WidgetTester tester) async {
      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('Voting'), findsWidgets);
    });

    testWidgets('shows voter status section', (WidgetTester tester) async {
      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      // Look for voter-related text
      expect(find.textContaining('Voter'), findsWidgets);
    });

    testWidgets('shows period section', (WidgetTester tester) async {
      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      // Look for period-related text
      expect(find.textContaining('Period'), findsWidgets);
    });

    testWidgets('handles unregistered voter gracefully', (WidgetTester tester) async {
      // Simulate unregistered user
      mockRpc.voteVoterResponse = null;

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      // Page still renders
      expect(find.byType(VotingDashboardPage), findsOneWidget);

      // Restore for other tests
      mockRpc.voteVoterResponse = TestData.sampleVoterInfo;
    });

    testWidgets('handles empty period gracefully', (WidgetTester tester) async {
      mockRpc.votePeriodResponse = null;

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      // Should show empty state or message
      expect(find.byType(VotingDashboardPage), findsOneWidget);

      // Restore for other tests
      mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;
    });
  });
}
