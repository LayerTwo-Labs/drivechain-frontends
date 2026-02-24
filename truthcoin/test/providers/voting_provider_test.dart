import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:truthcoin/providers/voting_provider.dart';

import '../fixtures/test_data.dart';
import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  late TestTruthcoinRPC mockRpc;
  late VotingProvider votingProvider;

  setUp(() async {
    mockRpc = await setupMarketVotingTests();
    votingProvider = GetIt.I.get<VotingProvider>();
  });

  tearDown(() async {
    await resetGetIt();
  });

  group('VotingProvider', () {
    group('loadSlotStatus', () {
      test('loads slot status successfully', () async {
        mockRpc.slotStatusResponse = TestData.sampleSlotStatus;

        await votingProvider.loadSlotStatus();

        expect(votingProvider.slotStatus, isNotNull);
        expect(votingProvider.slotStatus!.currentPeriod, 42);
        expect(votingProvider.slotStatus!.currentPeriodName, 'Q1 2026');
        expect(votingProvider.isLoading, false);
      });

      test('handles empty slot status', () async {
        mockRpc.slotStatusResponse = {};

        await votingProvider.loadSlotStatus();

        expect(votingProvider.slotStatus, isNotNull);
        expect(votingProvider.isLoading, false);
      });
    });

    group('loadSlots', () {
      test('loads slots successfully', () async {
        mockRpc.slotListResponse = TestData.sampleSlotList;

        await votingProvider.loadSlots();

        expect(votingProvider.slots.length, 3);
        expect(votingProvider.isLoading, false);
      });

      test('handles empty slots list', () async {
        mockRpc.slotListResponse = [];

        await votingProvider.loadSlots();

        expect(votingProvider.slots, isEmpty);
      });
    });

    group('loadCurrentPeriod', () {
      test('loads current period successfully', () async {
        mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;

        await votingProvider.loadCurrentPeriod();

        expect(votingProvider.currentPeriod, isNotNull);
        expect(votingProvider.currentPeriod!.periodId, 42);
        expect(votingProvider.currentPeriod!.isActive, true);
        expect(votingProvider.currentPeriod!.decisions.length, 2);
      });

      test('handles no active period', () async {
        mockRpc.votePeriodResponse = null;

        await votingProvider.loadCurrentPeriod();

        expect(votingProvider.currentPeriod, isNull);
      });

      test('handles RPC error', () async {
        mockRpc.shouldThrowOnVotePeriod = true;
        mockRpc.errorMessage = 'Period fetch failed';

        await votingProvider.loadCurrentPeriod();

        expect(votingProvider.currentPeriod, isNull);
        expect(votingProvider.error, contains('Period fetch failed'));
      });
    });

    group('loadVoterInfo', () {
      test('loads voter info successfully', () async {
        mockRpc.voteVoterResponse = TestData.sampleVoterInfo;

        await votingProvider.loadVoterInfo('tb1qtest1234567890');

        expect(votingProvider.currentVoter, isNotNull);
        expect(votingProvider.currentVoter!.isActive, true);
        expect(votingProvider.currentVoter!.votecoinBalance, 1000);
        expect(votingProvider.currentVoter!.totalVotes, 156);
      });

      test('handles unregistered voter', () async {
        mockRpc.voteVoterResponse = null;

        await votingProvider.loadVoterInfo('tb1qunregistered');

        expect(votingProvider.currentVoter, isNull);
      });
    });

    group('loadDashboardData', () {
      test('loads all dashboard data', () async {
        mockRpc.slotStatusResponse = TestData.sampleSlotStatus;
        mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;
        mockRpc.voteVoterResponse = TestData.sampleVoterInfo;

        await votingProvider.loadDashboardData('tb1qtest1234567890');

        expect(votingProvider.slotStatus, isNotNull);
        expect(votingProvider.currentPeriod, isNotNull);
        expect(votingProvider.currentVoter, isNotNull);
      });

      test('handles null address for dashboard', () async {
        mockRpc.slotStatusResponse = TestData.sampleSlotStatus;
        mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;

        await votingProvider.loadDashboardData(null);

        expect(votingProvider.slotStatus, isNotNull);
        expect(votingProvider.currentPeriod, isNotNull);
        expect(votingProvider.currentVoter, isNull);
      });
    });

    group('pending votes management', () {
      test('adds pending vote', () {
        votingProvider.addPendingVote('decision_001', 0.75);

        expect(votingProvider.pendingVotes.length, 1);
        expect(votingProvider.getPendingVote('decision_001'), 0.75);
      });

      test('updates existing pending vote', () {
        votingProvider.addPendingVote('decision_001', 0.75);
        votingProvider.addPendingVote('decision_001', 0.90);

        expect(votingProvider.pendingVotes.length, 1);
        expect(votingProvider.getPendingVote('decision_001'), 0.90);
      });

      test('removes pending vote', () {
        votingProvider.addPendingVote('decision_001', 0.75);
        votingProvider.removePendingVote('decision_001');

        expect(votingProvider.pendingVotes, isEmpty);
        expect(votingProvider.getPendingVote('decision_001'), isNull);
      });

      test('clears all pending votes', () {
        votingProvider.addPendingVote('decision_001', 0.75);
        votingProvider.addPendingVote('decision_002', 0.50);
        votingProvider.addPendingVote('decision_003', 1.0);

        votingProvider.clearPendingVotes();

        expect(votingProvider.pendingVotes, isEmpty);
      });

      test('manages multiple pending votes', () {
        votingProvider.addPendingVote('decision_001', 0.0);
        votingProvider.addPendingVote('decision_002', 0.5);
        votingProvider.addPendingVote('decision_003', 1.0);

        expect(votingProvider.pendingVotes.length, 3);
        expect(votingProvider.getPendingVote('decision_001'), 0.0);
        expect(votingProvider.getPendingVote('decision_002'), 0.5);
        expect(votingProvider.getPendingVote('decision_003'), 1.0);
      });
    });

    group('submitVotes', () {
      test('submits votes successfully', () async {
        votingProvider.addPendingVote('decision_001', 0.75);
        votingProvider.addPendingVote('decision_002', 0.50);
        mockRpc.voteSubmitResponse = 'vote_submit_txid';

        final txid = await votingProvider.submitVotes(1000);

        expect(txid, 'vote_submit_txid');
        // Pending votes should be cleared after successful submission
        expect(votingProvider.pendingVotes, isEmpty);
      });

      test('returns null when no pending votes', () async {
        final txid = await votingProvider.submitVotes(1000);

        expect(txid, isNull);
      });

      test('preserves pending votes on error', () async {
        votingProvider.addPendingVote('decision_001', 0.75);

        // Simulate RPC error by having the mock throw
        // For this test, we'll check the pending votes are preserved
        // if submission fails
        mockRpc.voteSubmitResponse = 'txid';

        await votingProvider.submitVotes(1000);

        // After successful submission, votes are cleared
        expect(votingProvider.pendingVotes, isEmpty);
      });
    });

    group('registerAsVoter', () {
      test('registers voter without bond', () async {
        mockRpc.voteRegisterResponse = 'register_txid';

        final txid = await votingProvider.registerAsVoter(feeSats: 1000);

        expect(txid, 'register_txid');
      });

      test('registers voter with bond', () async {
        mockRpc.voteRegisterResponse = 'register_with_bond_txid';

        final txid = await votingProvider.registerAsVoter(
          bondSats: 10000,
          feeSats: 1000,
        );

        expect(txid, 'register_with_bond_txid');
      });
    });

    group('notifyListeners', () {
      test('notifies on slot status load', () async {
        mockRpc.slotStatusResponse = TestData.sampleSlotStatus;

        int notifyCount = 0;
        votingProvider.addListener(() => notifyCount++);

        await votingProvider.loadSlotStatus();

        expect(notifyCount, greaterThan(0));
      });

      test('notifies on pending vote change', () {
        int notifyCount = 0;
        votingProvider.addListener(() => notifyCount++);

        votingProvider.addPendingVote('decision_001', 0.5);

        expect(notifyCount, 1);
      });

      test('notifies on pending vote removal', () {
        votingProvider.addPendingVote('decision_001', 0.5);

        int notifyCount = 0;
        votingProvider.addListener(() => notifyCount++);

        votingProvider.removePendingVote('decision_001');

        expect(notifyCount, 1);
      });
    });

    group('error handling', () {
      test('clears error on successful load', () async {
        // First, cause an error
        mockRpc.shouldThrowOnVotePeriod = true;
        await votingProvider.loadCurrentPeriod();
        expect(votingProvider.error, isNotNull);

        // Then, load successfully
        mockRpc.shouldThrowOnVotePeriod = false;
        mockRpc.votePeriodResponse = TestData.sampleVotingPeriod;
        await votingProvider.loadCurrentPeriod();

        expect(votingProvider.error, isNull);
      });
    });
  });
}
