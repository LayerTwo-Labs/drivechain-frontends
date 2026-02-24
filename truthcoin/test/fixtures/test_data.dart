/// Test data factories for Truthcoin market and voting tests.
/// Provides consistent, reusable test data across all test files.
library;

class TestData {
  TestData._();

  /// Sample market list response from RPC
  static List<Map<String, dynamic>> get sampleMarketList => [
    {
      'market_id': 'market_001',
      'title': 'Will BTC reach \$100k by end of 2026?',
      'description': 'This market resolves YES if Bitcoin reaches \$100,000 USD on any major exchange.',
      'state': 'trading',
      'volume_sats': 150000000, // 1.5 BTC
      'outcome_count': 2,
      'trading_fee_percent': 0.5,
      'created_at': '2026-01-15T10:00:00Z',
      'tags': ['bitcoin', 'crypto', 'price'],
    },
    {
      'market_id': 'market_002',
      'title': 'US Presidential Election 2028 Winner',
      'description': 'Which party will win the 2028 US presidential election?',
      'state': 'trading',
      'volume_sats': 250000000, // 2.5 BTC
      'outcome_count': 3,
      'trading_fee_percent': 1.0,
      'created_at': '2026-02-01T12:00:00Z',
      'tags': ['politics', 'election', 'usa'],
    },
    {
      'market_id': 'market_003',
      'title': 'Cancelled Market Example',
      'description': 'This market was cancelled.',
      'state': 'cancelled',
      'volume_sats': 5000000,
      'outcome_count': 2,
      'trading_fee_percent': 0.5,
      'created_at': '2026-01-01T08:00:00Z',
      'tags': [],
    },
  ];

  /// Sample market detail response from RPC
  static Map<String, dynamic> get sampleMarketDetail => {
    'market_id': 'market_001',
    'title': 'Will BTC reach \$100k by end of 2026?',
    'description':
        'This market resolves YES if Bitcoin reaches \$100,000 USD on any major exchange by December 31, 2026 23:59 UTC.',
    'state': 'trading',
    'volume_sats': 150000000,
    'liquidity_sats': 50000000,
    'trading_fee_percent': 0.5,
    'created_at': '2026-01-15T10:00:00Z',
    'tags': ['bitcoin', 'crypto', 'price'],
    'outcomes': [
      {
        'index': 0,
        'name': 'Yes',
        'probability': 0.65,
        'shares_outstanding': 1000,
      },
      {
        'index': 1,
        'name': 'No',
        'probability': 0.35,
        'shares_outstanding': 500,
      },
    ],
  };

  /// Sample market buy response (dry run)
  static Map<String, dynamic> get sampleMarketBuyDryRun => {
    'cost_sats': 15000,
    'shares_received': 100.0,
    'new_probability': 0.68,
    'price_impact': 0.03,
  };

  /// Sample market buy response (actual)
  static Map<String, dynamic> get sampleMarketBuyActual => {
    'txid': 'abc123def456',
    'cost_sats': 15000,
    'shares_received': 100.0,
    'new_probability': 0.68,
  };

  /// Sample market sell response (dry run)
  static Map<String, dynamic> get sampleMarketSellDryRun => {
    'proceeds_sats': 12000,
    'shares_sold': 100,
    'new_probability': 0.62,
    'price_impact': -0.03,
  };

  /// Sample market positions response
  static Map<String, dynamic> get sampleMarketPositions => {
    'address': 'tb1qtest1234567890',
    'total_value': 0.0005,
    'total_cost_basis': 0.0004,
    'total_unrealized_pnl': 0.0001,
    'active_markets': 2,
    'last_updated_height': 1000,
    'positions': [
      {
        'market_id': 'market_001',
        'outcome_index': 0,
        'outcome_name': 'Yes',
        'shares': 100,
        'avg_purchase_price': 0.6,
        'current_price': 0.65,
        'current_value': 65.0,
        'unrealized_pnl': 5.0,
        'cost_basis': 60.0,
      },
      {
        'market_id': 'market_002',
        'outcome_index': 1,
        'outcome_name': 'Republican',
        'shares': 50,
        'avg_purchase_price': 0.48,
        'current_price': 0.52,
        'current_value': 26.0,
        'unrealized_pnl': 2.0,
        'cost_basis': 24.0,
      },
    ],
  };

  /// Sample slot status response
  static Map<String, dynamic> get sampleSlotStatus => {
    'is_period_testing': false,
    'blocks_per_period': 1008,
    'current_period': 42,
    'current_period_name': 'Q1 2026',
    'blocks_remaining': 500,
    'period_start_block': 100000,
    'period_end_block': 101008,
  };

  /// Sample slot list response
  static List<Map<String, dynamic>> get sampleSlotList => [
    {
      'slot_id_hex': '002a0001',
      'period_index': 42,
      'slot_index': 1,
      'state': 'claimed',
      'decision': {
        'id': 'decision_001',
        'question': 'Will BTC reach \$100k by Q2 2026?',
        'is_standard': true,
        'is_scaled': false,
      },
    },
    {
      'slot_id_hex': '002a0002',
      'period_index': 42,
      'slot_index': 2,
      'state': 'claimed',
      'decision': {
        'id': 'decision_002',
        'question': 'US inflation rate Q1 2026',
        'is_standard': true,
        'is_scaled': true,
        'min': 0,
        'max': 100,
      },
    },
    {
      'slot_id_hex': '002a0003',
      'period_index': 42,
      'slot_index': 3,
      'state': 'unclaimed',
      'decision': null,
    },
  ];

  /// Sample voter info response
  static Map<String, dynamic> get sampleVoterInfo => {
    'address': 'tb1qtest1234567890',
    'is_active': true,
    'reputation': 0.85,
    'votecoin_balance': 1000,
    'total_votes': 156,
    'accuracy_score': 0.78,
    'current_period_participation': {
      'period_id': 42,
      'votes_cast': 8,
      'decisions_available': 12,
    },
  };

  /// Sample voting period response
  static Map<String, dynamic> get sampleVotingPeriod => {
    'period_id': 42,
    'status': 'active',
    'start_block': 100000,
    'end_block': 101008,
    'decisions': [
      {
        'slot_id_hex': '002a0001',
        'question': 'Will BTC reach \$100k by Q2 2026?',
        'is_standard': true,
        'is_scaled': false,
        'consensus_value': null,
        'vote_count': 35,
      },
      {
        'slot_id_hex': '002a0002',
        'question': 'US inflation rate Q1 2026',
        'is_standard': true,
        'is_scaled': true,
        'min': 0,
        'max': 100,
        'consensus_value': null,
        'vote_count': 28,
      },
    ],
    'stats': {
      'active_voters': 42,
      'total_votes': 156,
      'participation_rate': 0.65,
      'decisions_count': 12,
    },
  };

  /// Sample voters list response
  static List<Map<String, dynamic>> get sampleVotersList => [
    {
      'address': 'tb1qvoter1',
      'is_active': true,
      'reputation': 0.92,
      'votecoin_balance': 5000,
      'total_votes': 500,
      'accuracy_score': 0.85,
    },
    {
      'address': 'tb1qvoter2',
      'is_active': true,
      'reputation': 0.78,
      'votecoin_balance': 2000,
      'total_votes': 200,
      'accuracy_score': 0.72,
    },
    {
      'address': 'tb1qvoter3',
      'is_active': false,
      'reputation': 0.45,
      'votecoin_balance': 100,
      'total_votes': 50,
      'accuracy_score': 0.55,
    },
  ];
}
