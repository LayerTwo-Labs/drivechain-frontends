import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/models/voting.dart';
import 'package:truthcoin/providers/voting_provider.dart';

// Responses of the truthcoin 0.20.0 betanet seed node, decoded as the client
// decodes them.
Map<String, dynamic> _decode(String raw) => jsonDecode(raw) as Map<String, dynamic>;

const _voteVoter =
    '{"address":"3dWL5oSH54rxzXbU5RVi7bBkeuWd","votecoin_balance":1.0,"total_votes":0,"periods_active":0,'
    '"is_active":false,"current_period_participation":{"period_id":7,"votes_cast":0,"decisions_available":2,'
    '"participation_rate":0.0}}';

const _voteVoters =
    '[{"address":"3dWL5oSH54rxzXbU5RVi7bBkeuWd","votecoin_balance":1.0,"total_votes":0,"is_active":false}]';

const _votePeriod =
    '{"period_id":7,"status":"Active","start_height":0,"end_height":0,"start_time":1792163238,'
    '"end_time":1792249638,"decisions":[{"decision_id_hex":"860000","header":"betanet reaches block 972,000 '
    'before October 15, 2026","is_standard":true,"decision_type":"Binary"}],"stats":{"total_voters":0,'
    '"active_voters":0,"total_votes":0,"participation_rate":0.0},"consensus":null}';

const _decisionList =
    '[{"decision_id_hex":"870002","period_index":7,"decision_index":2,"state":"Created","decision":null},'
    '{"decision_id_hex":"870000","period_index":7,"decision_index":0,"state":"Claimed","decision":{"id":'
    '"f18522134ce292dfd48abb38f7afb591b5ab3a1da29215c67e1bb523bbcb7fc9","market_maker_pubkey_hash":'
    '"b5867348450fe8f3504650eaeb7f88e2d96084de","is_standard":true,"decision_type":"Binary","header":'
    '"Will eCash use a different DAA than Bitcoin by Jan 1, 2027?","description":"","tags":[]}}]';

const _marketGet =
    '{"market_id":"5e5ed0d19c4f","title":"eCash DAA and Block Time by January 1, 2027","description":"",'
    '"tags":[],"creator_address":"3XgPhux7Z1YFTEjMoR8bqWTCTJUV","created_at_height":540,"expires_at_height":null,'
    '"dimensions":[{"dimension_index":0,"decision_id":"870000","name":"DAA","kind":{"type":"binary",'
    '"lower_label":"No","upper_label":"Yes"}},{"dimension_index":1,"decision_id":"870001","name":"Block time",'
    '"kind":{"type":"binary","lower_label":"No","upper_label":"Yes"}}],"outcomes":[{"outcome_index":0,'
    '"label":"DAA: No, Block time: No","price":0.14354427275850792,"volume_sats":0,"full_state_index":0,'
    '"coordinates":[0,0]},{"outcome_index":1,"label":"DAA: No, Block time: Yes","price":0.5693671817244762,'
    '"volume_sats":85430943,"full_state_index":1,"coordinates":[0,1]},{"outcome_index":2,"label":'
    '"DAA: Yes, Block time: No","price":0.14354427275850792,"volume_sats":0,"full_state_index":3,'
    '"coordinates":[1,0]},{"outcome_index":3,"label":"DAA: Yes, Block time: Yes","price":0.14354427275850792,'
    '"volume_sats":0,"full_state_index":4,"coordinates":[1,1]}],"state":"trading","beta":153214213.3424079,'
    '"liquidity_base_sats":212400000,"treasury_sats":297405913,"total_volume_sats":85430943,'
    '"trading_fee_rate":0.005,"resolution":null,"tx_pow_hash_selector":0,"tx_pow_ordering":0,'
    '"tx_pow_difficulty":0}';

const _marketList =
    '[{"market_id":"5e5ed0d19c4f","title":"eCash DAA and Block Time by January 1, 2027","description":"",'
    '"outcome_count":4,"state":"trading","volume_sats":85430943,"created_at_height":540}]';

const _marketPositions =
    '{"address":"3Nw6A68GUSXfaCuTmHCENMedVfvj","positions":[],"total_value":0.0,"total_cost_basis":0.0,'
    '"total_unrealized_pnl":0.0,"active_markets":0,"last_updated_height":0}';

const _calculateInitialLiquidity =
    '{"beta":7.0,"num_outcomes":2,"initial_liquidity_sats":5,"min_treasury_sats":5,"market_config":"1 dimensions",'
    '"outcome_breakdown":"binary(2) = 2 outcomes"}';

const _decisionStatus =
    '{"is_testing_mode":false,"blocks_per_period":0,"current_period":7,"current_period_name":"Q3 Y2010"}';

void main() {
  test('vote_voter reads Votecoin as a fraction', () {
    final voter = VoterInfoFull.fromJson(_decode(_voteVoter));

    expect(voter.address, '3dWL5oSH54rxzXbU5RVi7bBkeuWd');
    expect(voter.votecoinBalance, 1.0);
    expect(voter.currentPeriodParticipation?.decisionsAvailable, 2);
  });

  test('vote_voters reads every voter', () {
    final voters = (jsonDecode(_voteVoters) as List).map((v) => VoterInfo.fromJson(v as Map<String, dynamic>));

    expect(voters.single.address, '3dWL5oSH54rxzXbU5RVi7bBkeuWd');
  });

  test('vote_period reads the decisions of the period', () {
    final period = VotingPeriodFull.fromJson(_decode(_votePeriod));

    expect(period.periodId, 7);
    expect(period.isActive, isTrue);
    expect(period.decisions.single.slotIdHex, '860000');
    expect(period.decisions.single.isBinary, isTrue);
  });

  test('decision_list reads a free slot and a claimed slot', () {
    final slots = (jsonDecode(_decisionList) as List).map((s) => SlotListItem.fromJson(s as Map<String, dynamic>));

    expect(slots.first.decision, isNull);
    expect(slots.last.slotIdHex, '870000');
    expect(slots.last.decision?.isBinary, isTrue);
  });

  test('decision_status reads the current period', () {
    expect(SlotStatus.fromJson(_decode(_decisionStatus)).currentPeriod, 7);
  });

  test('market_list and market_get read a market of two dimensions', () {
    final summary = MarketSummary.fromJson((jsonDecode(_marketList) as List).single as Map<String, dynamic>);
    final market = MarketData.fromJson(_decode(_marketGet));

    expect(summary.outcomeCount, 4);
    expect(market.outcomes.length, 4);
    expect(market.outcomes[1].currentPrice, 0.5693671817244762);
    expect(market.decisionSlots, ['870000', '870001']);
    expect([for (final o in market.outcomes) o.label], ['No · No', 'No · Yes', 'Yes · No', 'Yes · Yes']);
    expect(market.isTrading, isTrue);
  });

  test('market_get keeps the question and answers of each dimension, and the coordinates of each outcome', () {
    final market = MarketData.fromJson(_decode(_marketGet));

    expect([for (final d in market.dimensions) d.name], ['DAA', 'Block time']);
    expect([for (final d in market.dimensions) d.decisionId], ['870000', '870001']);
    expect([for (final d in market.dimensions) d.kind], [MarketDimensionKind.binary, MarketDimensionKind.binary]);
    expect(market.dimensions.first.options, ['No', 'Yes']);
    expect(
      [for (final o in market.outcomes) o.coordinates],
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
      ],
    );
  });

  test('market_positions reads an address with no position', () {
    final holdings = UserHoldings.fromJson(_decode(_marketPositions));

    expect(holdings.positions, isEmpty);
    expect(holdings.totalValueSats, 0);
  });

  test('calculate_initial_liquidity reads the subsidy', () {
    expect(InitialLiquidityCalculation.fromJson(_decode(_calculateInitialLiquidity)).initialLiquiditySats, 5);
  });
}
