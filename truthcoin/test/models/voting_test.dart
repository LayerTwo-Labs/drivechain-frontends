import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';

import '../fixtures/test_data.dart';

void main() {
  group('VotingModels', () {
    group('SlotStatus', () {
      test('parses from JSON correctly', () {
        final status = SlotStatus.fromJson(TestData.sampleSlotStatus);

        expect(status.blocksPerPeriod, 1008);
        expect(status.currentPeriod, 42);
        expect(status.currentPeriodName, 'Q1 2026');
      });

      test('handles empty JSON', () {
        final status = SlotStatus.fromJson({});

        expect(status.currentPeriod, 0);
      });
    });

    group('SlotListItem', () {
      test('parses from JSON correctly', () {
        final slot = SlotListItem.fromJson(TestData.sampleSlotList.first);

        expect(slot.slotIdHex, '002a0001');
        expect(slot.periodIndex, 42);
        expect(slot.slotIndex, 1);
        expect(slot.state, SlotState.claimed);
        expect(slot.decision, isNotNull);
      });

      test('handles unclaimed slot', () {
        final slot = SlotListItem.fromJson(TestData.sampleSlotList.last);

        expect(slot.state, SlotState.available);
        expect(slot.decision, isNull);
      });
    });

    group('DecisionInfo', () {
      test('parses binary decision correctly', () {
        final json = TestData.sampleSlotList.first['decision'] as Map<String, dynamic>;
        final decision = DecisionInfo.fromJson(json);

        expect(decision.isScaled, false);
        expect(decision.question, contains('BTC'));
      });

      test('parses scaled decision correctly', () {
        final json = TestData.sampleSlotList[1]['decision'] as Map<String, dynamic>;
        final decision = DecisionInfo.fromJson(json);

        expect(decision.isScaled, true);
        expect(decision.min, 0);
        expect(decision.max, 100);
      });
    });

    group('VoterInfoFull', () {
      test('parses from JSON correctly', () {
        final voter = VoterInfoFull.fromJson(TestData.sampleVoterInfo);

        expect(voter.address, 'tb1qtest1234567890');
        expect(voter.isActive, true);
        expect(voter.reputation, 0.85);
        expect(voter.votecoinBalance, 1000);
        expect(voter.totalVotes, 156);
        expect(voter.accuracyScore, 0.78);
      });

      test('calculates display values correctly', () {
        final voter = VoterInfoFull.fromJson(TestData.sampleVoterInfo);

        expect(voter.reputationDisplay, isNotEmpty);
        expect(voter.accuracyPercent, contains('78'));
      });

      test('parses period participation', () {
        final voter = VoterInfoFull.fromJson(TestData.sampleVoterInfo);

        expect(voter.currentPeriodParticipation, isNotNull);
        expect(voter.currentPeriodParticipation!.votesCast, 8);
        expect(voter.currentPeriodParticipation!.decisionsAvailable, 12);
      });
    });

    group('VotingPeriodFull', () {
      test('parses from JSON correctly', () {
        final period = VotingPeriodFull.fromJson(TestData.sampleVotingPeriod);

        expect(period.periodId, 42);
        expect(period.status, 'active');
        expect(period.isActive, true);
        expect(period.decisions.length, 2);
      });

      test('parses period stats correctly', () {
        final period = VotingPeriodFull.fromJson(TestData.sampleVotingPeriod);

        expect(period.stats.activeVoters, 42);
        expect(period.stats.totalVotes, 156);
        expect(period.stats.participationRate, 0.65);
      });

      test('parses decisions correctly', () {
        final period = VotingPeriodFull.fromJson(TestData.sampleVotingPeriod);

        expect(period.decisions.first.question, contains('BTC'));
        expect(period.decisions.last.isScaled, true);
      });
    });

    group('MarketSummary', () {
      test('parses from JSON correctly', () {
        final market = MarketSummary.fromJson(TestData.sampleMarketList.first);

        expect(market.marketId, 'market_001');
        expect(market.title, contains('BTC'));
        expect(market.marketState, MarketState.trading);
        expect(market.volumeSats, 150000000);
        expect(market.outcomeCount, 2);
      });

      test('identifies trading state correctly', () {
        final trading = MarketSummary.fromJson(TestData.sampleMarketList.first);
        final cancelled = MarketSummary.fromJson(TestData.sampleMarketList.last);

        expect(trading.isTrading, true);
        expect(cancelled.isTrading, false);
      });
    });

    group('MarketData', () {
      test('parses from JSON correctly', () {
        final market = MarketData.fromJson(TestData.sampleMarketDetail);

        expect(market.marketId, 'market_001');
        expect(market.title, contains('BTC'));
        expect(market.outcomes.length, 2);
      });

      test('parses outcomes correctly', () {
        final market = MarketData.fromJson(TestData.sampleMarketDetail);

        expect(market.outcomes.first.name, 'Yes');
        expect(market.outcomes.first.probability, 0.65);
        expect(market.outcomes.last.name, 'No');
        expect(market.outcomes.last.probability, 0.35);
      });
    });

    group('SharePosition', () {
      test('parses from JSON correctly', () {
        final positionJson = (TestData.sampleMarketPositions['positions'] as List).first as Map<String, dynamic>;
        final position = SharePosition.fromJson(positionJson);

        expect(position.marketId, 'market_001');
        expect(position.outcomeIndex, 0);
        expect(position.shares, 100);
      });
    });

    group('UserHoldings', () {
      test('parses from JSON correctly', () {
        final holdings = UserHoldings.fromJson(TestData.sampleMarketPositions);

        expect(holdings.address, 'tb1qtest1234567890');
        expect(holdings.positions.length, 2);
      });

      test('calculates active markets correctly', () {
        final holdings = UserHoldings.fromJson(TestData.sampleMarketPositions);

        expect(holdings.activeMarkets, 2);
      });
    });

    group('MarketState', () {
      test('parses state strings correctly', () {
        expect(MarketState.fromString('trading'), MarketState.trading);
        expect(MarketState.fromString('ossified'), MarketState.ossified);
        expect(MarketState.fromString('cancelled'), MarketState.cancelled);
        expect(MarketState.fromString('invalid'), MarketState.invalid);
      });

      test('handles unknown states', () {
        expect(MarketState.fromString('unknown'), MarketState.trading);
      });

      test('provides display names', () {
        expect(MarketState.trading.displayName, isNotEmpty);
        expect(MarketState.ossified.displayName, isNotEmpty);
        expect(MarketState.cancelled.displayName, isNotEmpty);
        expect(MarketState.invalid.displayName, isNotEmpty);
      });
    });
  });
}
