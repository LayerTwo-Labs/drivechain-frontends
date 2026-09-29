import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/models/market.dart';
import 'package:truthcoin/models/voting.dart';

/// The node field names come from the truthcoin openapi schema.
Map<String, dynamic> nodeMarket() => {
  'market_id': 'a41f92c8',
  'title': r'Will BTC close above $150,000?',
  'description': 'The market pays Yes above the price.',
  'tags': ['bitcoin'],
  'creator_address': 'tc1q8f4m2v',
  'created_at_height': 182914,
  'expires_at_height': 214000,
  'state': 'settled',
  'beta': 7.0,
  'trading_fee_rate': 0.005,
  'liquidity_base_sats': 485000,
  'treasury_sats': 1200000,
  'total_volume_sats': 241000000,
  'dimensions': [
    {'dimension_index': 0, 'decision_id': '004008', 'name': 'BTC price', 'kind': 'binary'},
  ],
  'outcomes': [
    {'outcome_index': 0, 'label': 'No', 'price': 0.38, 'volume_sats': 91000000, 'full_state_index': 0},
    {'outcome_index': 1, 'label': 'Yes', 'price': 0.62, 'volume_sats': 150000000, 'full_state_index': 1},
  ],
};

/// The node counts a share as one satoshi, so a position value is in satoshis.
Map<String, dynamic> nodeHoldings() => {
  'address': 'tc1q8f4m2v',
  'total_value': 4820.0,
  'total_cost_basis': 2600.0,
  'total_unrealized_pnl': 2220.0,
  'active_markets': 1,
  'last_updated_height': 182914,
  'positions': [
    {
      'market_id': 'a41f92c8',
      'outcome_index': 1,
      'outcome_name': 'Yes',
      'shares': 7774,
      'avg_purchase_price': 0.54,
      'current_price': 0.62,
      'current_value': 4820.0,
      'unrealized_pnl': 2220.0,
      'cost_basis': 2600.0,
    },
  ],
};

void main() {
  group('MarketOutcome.fromJson', () {
    test('reads the node field names', () {
      final outcome = MarketOutcome.fromJson(nodeMarket()['outcomes'][1] as Map<String, dynamic>);

      expect(outcome.name, 'Yes');
      expect(outcome.currentPrice, 0.62);
      expect(outcome.probability, 0.62);
      expect(outcome.index, 1);
      expect(outcome.displayIndex, 1);
      expect(outcome.volumeSats, 150000000);
    });

    test('still reads the older field names', () {
      final outcome = MarketOutcome.fromJson({
        'index': 2,
        'name': 'Maybe',
        'current_price': 0.25,
        'probability': 0.25,
        'volume_sats': 10,
        'display_index': 2,
      });

      expect(outcome.name, 'Maybe');
      expect(outcome.currentPrice, 0.25);
      expect(outcome.index, 2);
    });
  });

  group('MarketData.fromJson', () {
    test('reads the node field names', () {
      final market = MarketData.fromJson(nodeMarket());

      expect(market.marketMaker, 'tc1q8f4m2v');
      expect(market.expiresAt, 214000);
      expect(market.tradingFee, 0.005);
      expect(market.tradingFeePercent, '0.50%');
      expect(market.liquidity, 0.00485);
      expect(market.treasury, 0.012);
      expect(market.decisionSlots, ['004008']);
      expect(market.outcomes.length, 2);
      expect(market.outcomes.first.name, 'No');
    });

    test('a settled market reads as resolved', () {
      final market = MarketData.fromJson(nodeMarket());

      expect(market.marketState, MarketState.ossified);
      expect(market.isResolved, true);
      expect(market.isTrading, false);
    });
  });

  group('UserHoldings.fromJson', () {
    test('a position value reads as satoshis', () {
      final holdings = UserHoldings.fromJson(nodeHoldings());
      final position = holdings.positions.single;

      expect(position.currentValueSats, 4820);
      expect(position.costBasisSats, 2600);
      expect(position.unrealizedPnlSats, 2220);
      expect(position.isProfit, true);

      expect(holdings.totalValueSats, 4820);
      expect(holdings.totalCostBasisSats, 2600);
      expect(holdings.totalUnrealizedPnlSats, 2220);
    });
  });
}
