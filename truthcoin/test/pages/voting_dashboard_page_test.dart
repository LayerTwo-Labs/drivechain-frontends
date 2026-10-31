import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:truthcoin/pages/voting_dashboard_page.dart';
import 'package:truthcoin/providers/voting_provider.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.slotStatusResponse = TestData.sampleSlotStatus;
    mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;
    mockRpc.voteVoterResponse = TestData.sampleVoterInfo;
    mockRpc.slotListResponse = TestData.sampleSlotList;

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final votingProvider = VotingProvider();
    GetIt.I.registerLazySingleton<VotingProvider>(() => votingProvider);

    final balanceProvider = SidechainBalanceProvider(sidechain: mockRpc);
    GetIt.I.registerLazySingleton<SidechainBalanceProvider>(() => balanceProvider);
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

      expect(find.textContaining('Oracle voting'), findsWidgets);
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

    testWidgets('offers the options of a category decision', (WidgetTester tester) async {
      mockRpc.votePeriodResponse = {
        ...TestData.sampleVotingPeriod,
        'decisions': [
          {
            'decision_id_hex': '002a0004',
            'header': 'Who wins the election?',
            'is_standard': true,
            'decision_type': {
              'Category': {
                'options': ['Alice', 'Bob', 'Carol'],
              },
            },
          },
        ],
      };

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('category slot'), findsOneWidget);
      for (final option in ['Alice', 'Bob', 'Carol']) {
        expect(find.text(option), findsOneWidget);
      }
      expect(find.text('Yes'), findsNothing);

      mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;
    });

    testWidgets('shows the voter address, your decisions and your votes', (WidgetTester tester) async {
      mockRpc.voterAddressResponse = 'Xc3D7ZjNez3ReowLm1yz1zSvYe1';
      mockRpc.walletAddresses = ['Xc3D7ZjNez3ReowLm1yz1zSvYe1'];
      mockRpc.slotListResponse = [
        ...TestData.sampleSlotList,
        {
          'decision_id_hex': '910000',
          'period_index': 17,
          'decision_index': 0,
          'state': 'Claimed',
          'decision': {
            'id': 'e86e',
            'market_maker_pubkey_hash': '25dfe6769e56d1184b4d56c7c68885a2040bf7b6',
            'is_standard': true,
            'decision_type': 'Binary',
            'header': 'Lula wins the 2026 Brazilian presidential election',
            'description': '',
            'tags': <String>[],
          },
        },
      ];
      mockRpc.voteListResponse = [
        {
          'voter_address': 'Xc3D7ZjNez3ReowLm1yz1zSvYe1',
          'decision_id': '870000',
          'vote_value': 1.0,
          'period_id': 8,
          'block_height': 600,
          'txid': 'aa',
          'is_batch_vote': true,
        },
      ];
      mockRpc.votePeriodById = {
        8: {
          'period_id': 8,
          'status': 'Resolved',
          'decisions': [
            {
              'decision_id_hex': '870000',
              'header': 'Will eCash use a different DAA than Bitcoin by Jan 1, 2027?',
              'is_standard': true,
              'decision_type': 'Binary',
            },
          ],
          'consensus': {
            'outcomes': {'870000': 0.0},
          },
        },
      };

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      expect(find.text('Voter address'), findsOneWidget);
      expect(find.text('Xc3D7ZjN…vYe1'), findsOneWidget);
      expect(find.text('Your decisions'), findsOneWidget);
      expect(find.text('Lula wins the 2026 Brazilian presidential election (binary)'), findsOneWidget);
      expect(find.text('Will BTC reach \$100k by Q2 2026? (binary)'), findsNothing);
      expect(find.text('Your votes'), findsOneWidget);
      expect(find.text('Will eCash use a different DAA than Bitcoin by Jan 1, 2027?'), findsOneWidget);
      expect(find.text('Yes'), findsWidgets);
      expect(find.text('No'), findsWidgets);
      expect(mockRpc.votePeriodCalls, contains(8));

      mockRpc.walletAddresses = ['tb1qtest1234567890'];
      mockRpc.slotListResponse = TestData.sampleSlotList;
      mockRpc.voteListResponse = [];
      mockRpc.votePeriodById = {};
    });

    testWidgets('shows a slot list failure in your decisions', (WidgetTester tester) async {
      mockRpc.shouldThrowOnSlotList = true;

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load slots'), findsWidgets);

      mockRpc.shouldThrowOnSlotList = false;
    });

    testWidgets('keeps a period load failure on screen', (WidgetTester tester) async {
      mockRpc.shouldThrowOnVotePeriod = true;

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load period'), findsWidgets);

      mockRpc.shouldThrowOnVotePeriod = false;
    });

    testWidgets('reads the voter stats of the voter address', (WidgetTester tester) async {
      mockRpc.walletAddresses = ['1aaaaaaaaaaaaaaaaaaaaaaaaaa', 'Xc3D7ZjNez3ReowLm1yz1zSvYe1'];
      mockRpc.voterAddressResponse = 'Xc3D7ZjNez3ReowLm1yz1zSvYe1';
      mockRpc.voteVoterCalls.clear();

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();

      expect(mockRpc.voteVoterCalls, contains('Xc3D7ZjNez3ReowLm1yz1zSvYe1'));
      expect(mockRpc.voteVoterCalls, isNot(contains('1aaaaaaaaaaaaaaaaaaaaaaaaaa')));

      mockRpc.walletAddresses = ['tb1qtest1234567890'];
    });

    testWidgets('shows a sent ballot in your votes', (WidgetTester tester) async {
      mockRpc.voterAddressResponse = 'Xc3D7ZjNez3ReowLm1yz1zSvYe1';
      mockRpc.voteListResponse = [];

      await tester.pumpSailPage(const VotingDashboardPage());
      await tester.pumpAndSettle();
      expect(find.text('Will eCash use a different DAA than Bitcoin by Jan 1, 2027?'), findsNothing);

      mockRpc.voteListResponse = [
        {
          'voter_address': 'Xc3D7ZjNez3ReowLm1yz1zSvYe1',
          'decision_id': '870000',
          'vote_value': 1.0,
          'period_id': 8,
          'block_height': 600,
          'txid': 'aa',
          'is_batch_vote': true,
        },
      ];
      mockRpc.votePeriodById = {
        8: {
          'period_id': 8,
          'status': 'Active',
          'decisions': [
            {
              'decision_id_hex': '870000',
              'header': 'Will eCash use a different DAA than Bitcoin by Jan 1, 2027?',
              'is_standard': true,
              'decision_type': 'Binary',
            },
          ],
        },
      };
      GetIt.I<VotingProvider>().addPendingVote('870000', 1.0);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit ballot').first);
      await tester.pumpAndSettle();

      expect(find.text('Will eCash use a different DAA than Bitcoin by Jan 1, 2027?'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));

      mockRpc.voteListResponse = [];
      mockRpc.votePeriodById = {};
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
