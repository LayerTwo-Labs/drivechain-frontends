import 'package:sail_ui/bitcoin.dart';

/// Market state enum matching the original truthcoin implementation
enum MarketState {
  trading(1, 'LIVE'),
  cancelled(3, 'CANCELLED'),
  invalid(4, 'INVALID'),
  ossified(5, 'RESOLVED')
  ;

  final int value;
  final String displayName;

  const MarketState(this.value, this.displayName);

  static MarketState fromValue(int value) {
    return MarketState.values.firstWhere(
      (s) => s.value == value,
      orElse: () => MarketState.trading,
    );
  }

  static MarketState fromString(String str) {
    final lower = str.toLowerCase();
    if (lower == 'trading' || lower == 'live') return MarketState.trading;
    if (lower == 'cancelled') return MarketState.cancelled;
    if (lower == 'invalid') return MarketState.invalid;
    if (lower == 'ossified' || lower == 'resolved') return MarketState.ossified;
    return MarketState.trading;
  }

  bool get canTrade => this == MarketState.trading;
  bool get isResolved => this == MarketState.ossified;
}

/// Represents a prediction market
class Market {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String creatorAddress;
  final List<String> decisionSlots;
  final int createdAtHeight;
  final int? expiresAtHeight;
  final MarketState state;
  final double beta; // LMSR liquidity parameter
  final double tradingFee; // Fee percentage (e.g., 0.005 = 0.5%)
  final List<int> shares; // Share quantities per outcome
  final List<double> prices; // Current prices for each outcome
  final List<String> outcomeLabels; // Labels for each outcome
  final int totalVolumeSats;
  final List<int> outcomeVolumeSats;

  Market({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.creatorAddress,
    required this.decisionSlots,
    required this.createdAtHeight,
    this.expiresAtHeight,
    required this.state,
    required this.beta,
    required this.tradingFee,
    required this.shares,
    required this.prices,
    required this.outcomeLabels,
    required this.totalVolumeSats,
    required this.outcomeVolumeSats,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    // Parse shares - can be a list of ints
    List<int> parseShares(dynamic shares) {
      if (shares == null) return [0, 0];
      if (shares is List) {
        return shares.map((s) => (s as num).toInt()).toList();
      }
      return [0, 0];
    }

    // Parse prices - can be a list of doubles
    List<double> parsePrices(dynamic prices) {
      if (prices == null) return [0.5, 0.5];
      if (prices is List) {
        return prices.map((p) => (p as num).toDouble()).toList();
      }
      return [0.5, 0.5];
    }

    // Parse outcome labels
    List<String> parseOutcomeLabels(dynamic labels, int numOutcomes) {
      if (labels is List) {
        return labels.map((l) => l.toString()).toList();
      }
      // Default binary labels
      if (numOutcomes == 2) return ['No', 'Yes'];
      return List.generate(numOutcomes, (i) => 'Outcome ${i + 1}');
    }

    // Parse tags
    List<String> parseTags(dynamic tags) {
      if (tags == null) return [];
      if (tags is List) {
        return tags.map((t) => t.toString()).toList();
      }
      if (tags is String) {
        return tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      }
      return [];
    }

    // Parse decision slots
    List<String> parseSlots(dynamic slots) {
      if (slots == null) return [];
      if (slots is List) {
        return slots.map((s) => s.toString()).toList();
      }
      return [];
    }

    // Parse outcome volumes
    List<int> parseOutcomeVolumes(dynamic volumes) {
      if (volumes == null) return [];
      if (volumes is List) {
        return volumes.map((v) => (v as num).toInt()).toList();
      }
      return [];
    }

    final shares = parseShares(json['shares']);
    final prices = parsePrices(json['prices']);
    final numOutcomes = shares.isNotEmpty ? shares.length : (prices.isNotEmpty ? prices.length : 2);

    return Market(
      id: json['id']?.toString() ?? json['market_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Market',
      description: json['description']?.toString() ?? '',
      tags: parseTags(json['tags']),
      creatorAddress: json['creator_address']?.toString() ?? json['creator']?.toString() ?? '',
      decisionSlots: parseSlots(json['decision_slots'] ?? json['slots']),
      createdAtHeight: (json['created_at_height'] ?? json['created_height'] ?? 0) as int,
      expiresAtHeight: json['expires_at_height'] as int?,
      state: json['state'] != null
          ? (json['state'] is int
                ? MarketState.fromValue(json['state'] as int)
                : MarketState.fromString(json['state'].toString()))
          : MarketState.trading,
      beta: (json['beta'] ?? json['b'] ?? 7.0) as double,
      tradingFee: (json['trading_fee'] ?? json['fee'] ?? 0.005) as double,
      shares: shares,
      prices: prices,
      outcomeLabels: parseOutcomeLabels(json['outcome_labels'] ?? json['outcomes'], numOutcomes),
      totalVolumeSats: (json['total_volume_sats'] ?? json['volume'] ?? 0) as int,
      outcomeVolumeSats: parseOutcomeVolumes(json['outcome_volumes_sats'] ?? json['outcome_volumes']),
    );
  }

  /// Number of possible outcomes
  int get numOutcomes => shares.length;

  /// Whether this is a binary (Yes/No) market
  bool get isBinary => numOutcomes == 2;

  /// Total volume in BTC
  double get totalVolumeBTC => satoshiToBTC(totalVolumeSats);

  /// Liquidity in BTC (derived from beta parameter)
  double get liquidityBTC => beta * 0.01; // Approximate conversion

  /// Get probability for an outcome (0.0 to 1.0)
  double getProbability(int outcomeIndex) {
    if (outcomeIndex < 0 || outcomeIndex >= prices.length) return 0.0;
    return prices[outcomeIndex];
  }

  /// Get probability as percentage string
  String getProbabilityPercent(int outcomeIndex) {
    return '${(getProbability(outcomeIndex) * 100).toStringAsFixed(1)}%';
  }

  /// Short ID for display (first 8 characters)
  String get shortId => id.length > 8 ? id.substring(0, 8) : id;
}

/// Represents a trading position in a market
class Position {
  final String marketId;
  final String marketTitle;
  final MarketState marketState;
  final int outcomeIndex;
  final String outcomeLabel;
  final double shares;
  final double currentPrice;
  final double tradingFeePct;
  final String ownerAddress;

  Position({
    required this.marketId,
    required this.marketTitle,
    required this.marketState,
    required this.outcomeIndex,
    required this.outcomeLabel,
    required this.shares,
    required this.currentPrice,
    required this.tradingFeePct,
    required this.ownerAddress,
  });

  factory Position.fromJson(Map<String, dynamic> json, {Market? market}) {
    return Position(
      marketId: json['market_id']?.toString() ?? market?.id ?? '',
      marketTitle: json['market_title']?.toString() ?? market?.title ?? 'Unknown Market',
      marketState: json['market_state'] != null
          ? (json['market_state'] is int
                ? MarketState.fromValue(json['market_state'] as int)
                : MarketState.fromString(json['market_state'].toString()))
          : (market?.state ?? MarketState.trading),
      outcomeIndex: (json['outcome_index'] ?? json['outcome'] ?? 0) as int,
      outcomeLabel:
          json['outcome_label']?.toString() ??
          (market != null && (json['outcome_index'] ?? 0) < market.outcomeLabels.length
              ? market.outcomeLabels[json['outcome_index'] ?? 0]
              : 'Unknown'),
      shares: (json['shares'] ?? 0.0) as double,
      currentPrice: (json['current_price'] ?? json['price'] ?? 0.0) as double,
      tradingFeePct: (json['trading_fee_pct'] ?? json['fee'] ?? market?.tradingFee ?? 0.005) as double,
      ownerAddress: json['owner_address']?.toString() ?? json['address']?.toString() ?? '',
    );
  }

  /// Current value in BTC
  double get currentValueBTC => shares * currentPrice / 100000000;

  /// Current value in satoshis
  int get currentValueSats => (shares * currentPrice).round();

  /// Whether this position can be sold (market is trading and has shares)
  bool get canSell => marketState.canTrade && shares > 0;

  /// Price as percentage
  String get pricePercent => '${(currentPrice * 100).toStringAsFixed(1)}%';
}

/// Represents a decision slot for oracle voting
class DecisionSlot {
  final String id;
  final int periodIndex;
  final int slotIndex;
  final String question;
  final bool isStandard;
  final bool isScaled;
  final int? min;
  final int? max;
  final String? option0Label;
  final String? option1Label;
  final String status;
  final String? claimedBy;

  DecisionSlot({
    required this.id,
    required this.periodIndex,
    required this.slotIndex,
    required this.question,
    required this.isStandard,
    required this.isScaled,
    this.min,
    this.max,
    this.option0Label,
    this.option1Label,
    required this.status,
    this.claimedBy,
  });

  factory DecisionSlot.fromJson(Map<String, dynamic> json) {
    return DecisionSlot(
      id: json['id']?.toString() ?? json['slot_id']?.toString() ?? '',
      periodIndex: (json['period_index'] ?? json['period'] ?? 0) as int,
      slotIndex: (json['slot_index'] ?? json['index'] ?? 0) as int,
      question: json['question']?.toString() ?? '',
      isStandard: json['is_standard'] as bool? ?? true,
      isScaled: json['is_scaled'] as bool? ?? false,
      min: json['min'] as int?,
      max: json['max'] as int?,
      option0Label: json['option_0_label']?.toString(),
      option1Label: json['option_1_label']?.toString(),
      status: json['status']?.toString() ?? 'unclaimed',
      claimedBy: json['claimed_by']?.toString(),
    );
  }

  /// Display label for option 0 (No / lower bound)
  String get option0Display => option0Label ?? (isScaled ? 'Lower' : 'No');

  /// Display label for option 1 (Yes / upper bound)
  String get option1Display => option1Label ?? (isScaled ? 'Higher' : 'Yes');

  /// Whether this slot is available for claiming
  bool get isAvailable => status == 'unclaimed' || status == 'available';
}

/// Represents a voter in the oracle system
class Voter {
  final String address;
  final double reputation;
  final double votecoinProportion;
  final int totalDecisions;
  final int correctDecisions;
  final int votecoinBalance;

  Voter({
    required this.address,
    required this.reputation,
    required this.votecoinProportion,
    required this.totalDecisions,
    required this.correctDecisions,
    required this.votecoinBalance,
  });

  factory Voter.fromJson(Map<String, dynamic> json) {
    return Voter(
      address: json['address']?.toString() ?? '',
      reputation: (json['reputation'] ?? 0.0) as double,
      votecoinProportion: (json['votecoin_proportion'] ?? 0.0) as double,
      totalDecisions: (json['total_decisions'] ?? 0) as int,
      correctDecisions: (json['correct_decisions'] ?? 0) as int,
      votecoinBalance: (json['votecoin_balance'] ?? json['balance'] ?? 0) as int,
    );
  }

  /// Accuracy percentage
  double get accuracy => totalDecisions > 0 ? correctDecisions / totalDecisions : 0.0;

  /// Accuracy as percentage string
  String get accuracyPercent => '${(accuracy * 100).toStringAsFixed(1)}%';

  /// Voting weight (reputation * votecoin proportion)
  double get votingWeight => reputation * votecoinProportion;
}

/// Represents a voting period
class VotingPeriod {
  final int id;
  final int startHeight;
  final int endHeight;
  final String status; // pending, active, closed, resolved
  final List<String> decisionSlots;

  VotingPeriod({
    required this.id,
    required this.startHeight,
    required this.endHeight,
    required this.status,
    required this.decisionSlots,
  });

  factory VotingPeriod.fromJson(Map<String, dynamic> json) {
    List<String> parseSlots(dynamic slots) {
      if (slots == null) return [];
      if (slots is List) return slots.map((s) => s.toString()).toList();
      return [];
    }

    return VotingPeriod(
      id: (json['id'] ?? json['period_id'] ?? 0) as int,
      startHeight: (json['start_height'] ?? json['start_timestamp'] ?? 0) as int,
      endHeight: (json['end_height'] ?? json['end_timestamp'] ?? 0) as int,
      status: json['status']?.toString() ?? 'pending',
      decisionSlots: parseSlots(json['decision_slots'] ?? json['slots']),
    );
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isClosed => status == 'closed' || status == 'resolved';
}

/// Represents a vote submission
class Vote {
  final String voterAddress;
  final int periodId;
  final String decisionId;
  final VoteValue value;
  final int blockHeight;

  Vote({
    required this.voterAddress,
    required this.periodId,
    required this.decisionId,
    required this.value,
    required this.blockHeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'decision_id': decisionId,
      'value': value.toJson(),
    };
  }
}

/// Vote value - can be binary, scalar, or abstain
abstract class VoteValue {
  dynamic toJson();
}

class BinaryVote extends VoteValue {
  final bool value;
  BinaryVote(this.value);

  @override
  dynamic toJson() => {'binary': value};
}

class ScalarVote extends VoteValue {
  final double value;
  ScalarVote(this.value);

  @override
  dynamic toJson() => {'scalar': value};
}

class AbstainVote extends VoteValue {
  @override
  dynamic toJson() => 'abstain';
}

/// Trade preview result from dry run
class TradePreview {
  final int shares;
  final int costSats;
  final int feeSats;
  final int totalCostSats;
  final double postTradePrice;
  final String? error;

  TradePreview({
    required this.shares,
    required this.costSats,
    required this.feeSats,
    required this.totalCostSats,
    required this.postTradePrice,
    this.error,
  });

  factory TradePreview.fromJson(Map<String, dynamic> json) {
    return TradePreview(
      shares: (json['shares'] ?? 0) as int,
      costSats: (json['cost_sats'] ?? json['cost'] ?? 0) as int,
      feeSats: (json['fee_sats'] ?? json['fee'] ?? 0) as int,
      totalCostSats: (json['total_cost_sats'] ?? json['total'] ?? 0) as int,
      postTradePrice: (json['post_trade_price'] ?? json['new_price'] ?? 0.0) as double,
      error: json['error']?.toString(),
    );
  }

  factory TradePreview.error(String message) {
    return TradePreview(
      shares: 0,
      costSats: 0,
      feeSats: 0,
      totalCostSats: 0,
      postTradePrice: 0.0,
      error: message,
    );
  }

  bool get hasError => error != null;

  double get costBTC => satoshiToBTC(costSats);
  double get feeBTC => satoshiToBTC(feeSats);
  double get totalCostBTC => satoshiToBTC(totalCostSats);
}
