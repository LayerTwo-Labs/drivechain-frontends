import 'package:truthcoin/models/market.dart';

/// Slot system status and configuration
class SlotStatus {
  final bool isTestingMode;
  final int blocksPerPeriod;
  final int currentPeriod;
  final String currentPeriodName;

  SlotStatus({
    required this.isTestingMode,
    required this.blocksPerPeriod,
    required this.currentPeriod,
    required this.currentPeriodName,
  });

  factory SlotStatus.fromJson(Map<String, dynamic> json) {
    return SlotStatus(
      isTestingMode: json['is_testing_mode'] as bool? ?? false,
      blocksPerPeriod: (json['blocks_per_period'] ?? 0) as int,
      currentPeriod: (json['current_period'] ?? 0) as int,
      currentPeriodName: json['current_period_name']?.toString() ?? '',
    );
  }
}

/// Slot state enum
enum SlotState {
  available,
  claimed,
  voting,
  ossified
  ;

  static SlotState fromString(String str) {
    final lower = str.toLowerCase();
    if (lower == 'available') return SlotState.available;
    if (lower == 'claimed') return SlotState.claimed;
    if (lower == 'voting') return SlotState.voting;
    if (lower == 'ossified') return SlotState.ossified;
    return SlotState.available;
  }

  String get displayName {
    switch (this) {
      case SlotState.available:
        return 'Available';
      case SlotState.claimed:
        return 'Claimed';
      case SlotState.voting:
        return 'Voting';
      case SlotState.ossified:
        return 'Resolved';
    }
  }
}

/// Slot list item
class SlotListItem {
  final String slotIdHex;
  final int periodIndex;
  final int slotIndex;
  final SlotState state;
  final DecisionInfo? decision;

  SlotListItem({
    required this.slotIdHex,
    required this.periodIndex,
    required this.slotIndex,
    required this.state,
    this.decision,
  });

  factory SlotListItem.fromJson(Map<String, dynamic> json) {
    return SlotListItem(
      slotIdHex: json['slot_id_hex']?.toString() ?? '',
      periodIndex: (json['period_index'] ?? 0) as int,
      slotIndex: (json['slot_index'] ?? 0) as int,
      state: json['state'] != null ? SlotState.fromString(json['state'].toString()) : SlotState.available,
      decision: json['decision'] != null ? DecisionInfo.fromJson(json['decision'] as Map<String, dynamic>) : null,
    );
  }
}

/// Decision information within a slot
class DecisionInfo {
  final String id;
  final String marketMakerPubkeyHash;
  final bool isStandard;
  final bool isScaled;
  final String question;
  final int? min;
  final int? max;

  DecisionInfo({
    required this.id,
    required this.marketMakerPubkeyHash,
    required this.isStandard,
    required this.isScaled,
    required this.question,
    this.min,
    this.max,
  });

  factory DecisionInfo.fromJson(Map<String, dynamic> json) {
    return DecisionInfo(
      id: json['id']?.toString() ?? '',
      marketMakerPubkeyHash: json['market_maker_pubkey_hash']?.toString() ?? '',
      isStandard: json['is_standard'] as bool? ?? true,
      isScaled: json['is_scaled'] as bool? ?? false,
      question: json['question']?.toString() ?? '',
      min: json['min'] as int?,
      max: json['max'] as int?,
    );
  }

  bool get isBinary => !isScaled;
}

/// Full voter information
class VoterInfoFull {
  final String address;
  final bool isRegistered;
  final double reputation;
  final int votecoinBalance;
  final int totalVotes;
  final int periodsActive;
  final double accuracyScore;
  final int registeredAtHeight;
  final bool isActive;
  final ParticipationStats? currentPeriodParticipation;

  VoterInfoFull({
    required this.address,
    required this.isRegistered,
    required this.reputation,
    required this.votecoinBalance,
    required this.totalVotes,
    required this.periodsActive,
    required this.accuracyScore,
    required this.registeredAtHeight,
    required this.isActive,
    this.currentPeriodParticipation,
  });

  factory VoterInfoFull.fromJson(Map<String, dynamic> json) {
    return VoterInfoFull(
      address: json['address']?.toString() ?? '',
      isRegistered: json['is_registered'] as bool? ?? false,
      reputation: (json['reputation'] ?? 0.0) as double,
      votecoinBalance: (json['votecoin_balance'] ?? 0) as int,
      totalVotes: (json['total_votes'] ?? 0) as int,
      periodsActive: (json['periods_active'] ?? 0) as int,
      accuracyScore: (json['accuracy_score'] ?? 0.0) as double,
      registeredAtHeight: (json['registered_at_height'] ?? 0) as int,
      isActive: json['is_active'] as bool? ?? false,
      currentPeriodParticipation: json['current_period_participation'] != null
          ? ParticipationStats.fromJson(json['current_period_participation'] as Map<String, dynamic>)
          : null,
    );
  }

  String get accuracyPercent => '${(accuracyScore * 100).toStringAsFixed(1)}%';
  String get reputationDisplay => reputation.toStringAsFixed(2);
}

/// Participation stats for current period
class ParticipationStats {
  final int periodId;
  final int votesCast;
  final int decisionsAvailable;
  final double participationRate;

  ParticipationStats({
    required this.periodId,
    required this.votesCast,
    required this.decisionsAvailable,
    required this.participationRate,
  });

  factory ParticipationStats.fromJson(Map<String, dynamic> json) {
    return ParticipationStats(
      periodId: (json['period_id'] ?? 0) as int,
      votesCast: (json['votes_cast'] ?? 0) as int,
      decisionsAvailable: (json['decisions_available'] ?? 0) as int,
      participationRate: (json['participation_rate'] ?? 0.0) as double,
    );
  }

  String get participationPercent => '${(participationRate * 100).toStringAsFixed(1)}%';
}

/// Full voting period information
class VotingPeriodFull {
  final int periodId;
  final String status;
  final int startHeight;
  final int endHeight;
  final int startTime;
  final int endTime;
  final List<DecisionSummary> decisions;
  final PeriodStats stats;
  final ConsensusResults? consensus;
  final RedistributionInfo? redistribution;

  VotingPeriodFull({
    required this.periodId,
    required this.status,
    required this.startHeight,
    required this.endHeight,
    required this.startTime,
    required this.endTime,
    required this.decisions,
    required this.stats,
    this.consensus,
    this.redistribution,
  });

  factory VotingPeriodFull.fromJson(Map<String, dynamic> json) {
    List<DecisionSummary> parseDecisions(dynamic decisions) {
      if (decisions == null) return [];
      if (decisions is List) {
        return decisions.map((d) => DecisionSummary.fromJson(d as Map<String, dynamic>)).toList();
      }
      return [];
    }

    return VotingPeriodFull(
      periodId: (json['period_id'] ?? 0) as int,
      status: json['status']?.toString() ?? 'pending',
      startHeight: (json['start_height'] ?? 0) as int,
      endHeight: (json['end_height'] ?? 0) as int,
      startTime: (json['start_time'] ?? 0) as int,
      endTime: (json['end_time'] ?? 0) as int,
      decisions: parseDecisions(json['decisions']),
      stats: json['stats'] != null
          ? PeriodStats.fromJson(json['stats'] as Map<String, dynamic>)
          : PeriodStats(totalVoters: 0, activeVoters: 0, totalVotes: 0, participationRate: 0),
      consensus: json['consensus'] != null
          ? ConsensusResults.fromJson(json['consensus'] as Map<String, dynamic>)
          : null,
      redistribution: json['redistribution'] != null
          ? RedistributionInfo.fromJson(json['redistribution'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isClosed => status == 'closed' || status == 'resolved';
}

/// Decision summary in a period
class DecisionSummary {
  final String slotIdHex;
  final String question;
  final bool isStandard;
  final bool isScaled;

  DecisionSummary({
    required this.slotIdHex,
    required this.question,
    required this.isStandard,
    required this.isScaled,
  });

  factory DecisionSummary.fromJson(Map<String, dynamic> json) {
    return DecisionSummary(
      slotIdHex: json['slot_id_hex']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      isStandard: json['is_standard'] as bool? ?? true,
      isScaled: json['is_scaled'] as bool? ?? false,
    );
  }

  bool get isBinary => !isScaled;
}

/// Period statistics
class PeriodStats {
  final int totalVoters;
  final int activeVoters;
  final int totalVotes;
  final double participationRate;

  PeriodStats({
    required this.totalVoters,
    required this.activeVoters,
    required this.totalVotes,
    required this.participationRate,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) {
    return PeriodStats(
      totalVoters: (json['total_voters'] ?? 0) as int,
      activeVoters: (json['active_voters'] ?? 0) as int,
      totalVotes: (json['total_votes'] ?? 0) as int,
      participationRate: (json['participation_rate'] ?? 0.0) as double,
    );
  }

  String get participationPercent => '${(participationRate * 100).toStringAsFixed(1)}%';
}

/// Consensus results from SVD algorithm
class ConsensusResults {
  final Map<String, double> outcomes;
  final List<double> firstLoading;
  final double certainty;
  final Map<String, ReputationUpdate> reputationUpdates;
  final List<String> outliers;
  final (int, int) voteMatrixDimensions;
  final String algorithmVersion;

  ConsensusResults({
    required this.outcomes,
    required this.firstLoading,
    required this.certainty,
    required this.reputationUpdates,
    required this.outliers,
    required this.voteMatrixDimensions,
    required this.algorithmVersion,
  });

  factory ConsensusResults.fromJson(Map<String, dynamic> json) {
    Map<String, double> parseOutcomes(dynamic outcomes) {
      if (outcomes == null) return {};
      if (outcomes is Map) {
        return outcomes.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
      }
      return {};
    }

    Map<String, ReputationUpdate> parseReputationUpdates(dynamic updates) {
      if (updates == null) return {};
      if (updates is Map) {
        return updates.map(
          (k, v) => MapEntry(k.toString(), ReputationUpdate.fromJson(v as Map<String, dynamic>)),
        );
      }
      return {};
    }

    List<String> parseOutliers(dynamic outliers) {
      if (outliers == null) return [];
      if (outliers is List) return outliers.map((o) => o.toString()).toList();
      return [];
    }

    List<double> parseFirstLoading(dynamic loading) {
      if (loading == null) return [];
      if (loading is List) return loading.map((l) => (l as num).toDouble()).toList();
      return [];
    }

    final dims = json['vote_matrix_dimensions'];
    final parsedDims = dims is List && dims.length == 2 ? ((dims[0] as int), (dims[1] as int)) : (0, 0);

    return ConsensusResults(
      outcomes: parseOutcomes(json['outcomes']),
      firstLoading: parseFirstLoading(json['first_loading']),
      certainty: (json['certainty'] ?? 0.0) as double,
      reputationUpdates: parseReputationUpdates(json['reputation_updates']),
      outliers: parseOutliers(json['outliers']),
      voteMatrixDimensions: parsedDims,
      algorithmVersion: json['algorithm_version']?.toString() ?? '',
    );
  }
}

/// Reputation update from consensus
class ReputationUpdate {
  final double oldReputation;
  final double newReputation;
  final double votecoinProportion;
  final double complianceScore;

  ReputationUpdate({
    required this.oldReputation,
    required this.newReputation,
    required this.votecoinProportion,
    required this.complianceScore,
  });

  factory ReputationUpdate.fromJson(Map<String, dynamic> json) {
    return ReputationUpdate(
      oldReputation: (json['old_reputation'] ?? 0.0) as double,
      newReputation: (json['new_reputation'] ?? 0.0) as double,
      votecoinProportion: (json['votecoin_proportion'] ?? 0.0) as double,
      complianceScore: (json['compliance_score'] ?? 0.0) as double,
    );
  }

  double get change => newReputation - oldReputation;
  bool get improved => change > 0;
}

/// Redistribution info after period resolution
class RedistributionInfo {
  final int periodId;
  final int totalRedistributed;
  final int winnersCount;
  final int losersCount;
  final int unchangedCount;
  final int conservationCheck;
  final int blockHeight;
  final bool isApplied;
  final List<String> slotsAffected;

  RedistributionInfo({
    required this.periodId,
    required this.totalRedistributed,
    required this.winnersCount,
    required this.losersCount,
    required this.unchangedCount,
    required this.conservationCheck,
    required this.blockHeight,
    required this.isApplied,
    required this.slotsAffected,
  });

  factory RedistributionInfo.fromJson(Map<String, dynamic> json) {
    List<String> parseSlots(dynamic slots) {
      if (slots == null) return [];
      if (slots is List) return slots.map((s) => s.toString()).toList();
      return [];
    }

    return RedistributionInfo(
      periodId: (json['period_id'] ?? 0) as int,
      totalRedistributed: (json['total_redistributed'] ?? 0) as int,
      winnersCount: (json['winners_count'] ?? 0) as int,
      losersCount: (json['losers_count'] ?? 0) as int,
      unchangedCount: (json['unchanged_count'] ?? 0) as int,
      conservationCheck: (json['conservation_check'] ?? 0) as int,
      blockHeight: (json['block_height'] ?? 0) as int,
      isApplied: json['is_applied'] as bool? ?? false,
      slotsAffected: parseSlots(json['slots_affected']),
    );
  }
}

/// Vote info from the chain
class VoteInfo {
  final String voterAddress;
  final String decisionId;
  final double voteValue;
  final int periodId;
  final int blockHeight;
  final String txid;
  final bool isBatchVote;

  VoteInfo({
    required this.voterAddress,
    required this.decisionId,
    required this.voteValue,
    required this.periodId,
    required this.blockHeight,
    required this.txid,
    required this.isBatchVote,
  });

  factory VoteInfo.fromJson(Map<String, dynamic> json) {
    return VoteInfo(
      voterAddress: json['voter_address']?.toString() ?? '',
      decisionId: json['decision_id']?.toString() ?? '',
      voteValue: (json['vote_value'] ?? 0.0) as double,
      periodId: (json['period_id'] ?? 0) as int,
      blockHeight: (json['block_height'] ?? 0) as int,
      txid: json['txid']?.toString() ?? '',
      isBatchVote: json['is_batch_vote'] as bool? ?? false,
    );
  }
}

/// Vote batch item for submission
class VoteBatchItem {
  final String decisionId;
  final double voteValue;

  VoteBatchItem({
    required this.decisionId,
    required this.voteValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'decision_id': decisionId,
      'vote_value': voteValue,
    };
  }
}

/// Market summary from list
class MarketSummary {
  final String marketId;
  final String title;
  final String description;
  final int outcomeCount;
  final String state;
  final int volumeSats;
  final int createdAtHeight;

  MarketSummary({
    required this.marketId,
    required this.title,
    required this.description,
    required this.outcomeCount,
    required this.state,
    required this.volumeSats,
    required this.createdAtHeight,
  });

  factory MarketSummary.fromJson(Map<String, dynamic> json) {
    return MarketSummary(
      marketId: json['market_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      outcomeCount: (json['outcome_count'] ?? 2) as int,
      state: json['state']?.toString() ?? 'trading',
      volumeSats: (json['volume_sats'] ?? 0) as int,
      createdAtHeight: (json['created_at_height'] ?? 0) as int,
    );
  }

  MarketState get marketState => MarketState.fromString(state);
  bool get isTrading => marketState == MarketState.trading;
  String get shortId => marketId.length > 8 ? marketId.substring(0, 8) : marketId;
}

/// Market outcome from market detail
class MarketOutcome {
  final String name;
  final double currentPrice;
  final double probability;
  final int volumeSats;
  final int index;
  final int displayIndex;

  MarketOutcome({
    required this.name,
    required this.currentPrice,
    required this.probability,
    required this.volumeSats,
    required this.index,
    required this.displayIndex,
  });

  factory MarketOutcome.fromJson(Map<String, dynamic> json) {
    return MarketOutcome(
      name: json['name']?.toString() ?? '',
      currentPrice: (json['current_price'] ?? 0.0) as double,
      probability: (json['probability'] ?? 0.0) as double,
      volumeSats: (json['volume_sats'] ?? 0) as int,
      index: (json['index'] ?? 0) as int,
      displayIndex: (json['display_index'] ?? 0) as int,
    );
  }

  String get probabilityPercent => '${(probability * 100).toStringAsFixed(1)}%';
  String get pricePercent => '${(currentPrice * 100).toStringAsFixed(1)}%';
}

/// Full market data
class MarketData {
  final String marketId;
  final String title;
  final String description;
  final List<MarketOutcome> outcomes;
  final String state;
  final String marketMaker;
  final int? expiresAt;
  final double beta;
  final double tradingFee;
  final List<String> tags;
  final int createdAtHeight;
  final double treasury;
  final int totalVolumeSats;
  final double liquidity;
  final List<String> decisionSlots;
  final MarketResolution? resolution;

  MarketData({
    required this.marketId,
    required this.title,
    required this.description,
    required this.outcomes,
    required this.state,
    required this.marketMaker,
    this.expiresAt,
    required this.beta,
    required this.tradingFee,
    required this.tags,
    required this.createdAtHeight,
    required this.treasury,
    required this.totalVolumeSats,
    required this.liquidity,
    required this.decisionSlots,
    this.resolution,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    List<MarketOutcome> parseOutcomes(dynamic outcomes) {
      if (outcomes == null) return [];
      if (outcomes is List) {
        return outcomes.map((o) => MarketOutcome.fromJson(o as Map<String, dynamic>)).toList();
      }
      return [];
    }

    List<String> parseTags(dynamic tags) {
      if (tags == null) return [];
      if (tags is List) return tags.map((t) => t.toString()).toList();
      return [];
    }

    List<String> parseSlots(dynamic slots) {
      if (slots == null) return [];
      if (slots is List) return slots.map((s) => s.toString()).toList();
      return [];
    }

    return MarketData(
      marketId: json['market_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      outcomes: parseOutcomes(json['outcomes']),
      state: json['state']?.toString() ?? 'trading',
      marketMaker: json['market_maker']?.toString() ?? '',
      expiresAt: json['expires_at'] as int?,
      beta: (json['beta'] ?? 7.0) as double,
      tradingFee: (json['trading_fee'] ?? 0.005) as double,
      tags: parseTags(json['tags']),
      createdAtHeight: (json['created_at_height'] ?? 0) as int,
      treasury: (json['treasury'] ?? 0.0) as double,
      totalVolumeSats: (json['total_volume_sats'] ?? 0) as int,
      liquidity: (json['liquidity'] ?? 0.0) as double,
      decisionSlots: parseSlots(json['decision_slots']),
      resolution: json['resolution'] != null
          ? MarketResolution.fromJson(json['resolution'] as Map<String, dynamic>)
          : null,
    );
  }

  MarketState get marketState => MarketState.fromString(state);
  bool get isTrading => marketState == MarketState.trading;
  bool get isResolved => marketState == MarketState.ossified;
  String get tradingFeePercent => '${(tradingFee * 100).toStringAsFixed(2)}%';
  String get shortId => marketId.length > 8 ? marketId.substring(0, 8) : marketId;
}

/// Market resolution info
class MarketResolution {
  final List<WinningOutcome> winningOutcomes;
  final String summary;

  MarketResolution({
    required this.winningOutcomes,
    required this.summary,
  });

  factory MarketResolution.fromJson(Map<String, dynamic> json) {
    List<WinningOutcome> parseWinners(dynamic winners) {
      if (winners == null) return [];
      if (winners is List) {
        return winners.map((w) => WinningOutcome.fromJson(w as Map<String, dynamic>)).toList();
      }
      return [];
    }

    return MarketResolution(
      winningOutcomes: parseWinners(json['winning_outcomes']),
      summary: json['summary']?.toString() ?? '',
    );
  }
}

/// Winning outcome in a resolved market
class WinningOutcome {
  final int outcomeIndex;
  final String outcomeName;
  final double finalPrice;

  WinningOutcome({
    required this.outcomeIndex,
    required this.outcomeName,
    required this.finalPrice,
  });

  factory WinningOutcome.fromJson(Map<String, dynamic> json) {
    return WinningOutcome(
      outcomeIndex: (json['outcome_index'] ?? 0) as int,
      outcomeName: json['outcome_name']?.toString() ?? '',
      finalPrice: (json['final_price'] ?? 0.0) as double,
    );
  }
}

/// Share position in a market
class SharePosition {
  final String marketId;
  final int outcomeIndex;
  final String outcomeName;
  final int shares;
  final double avgPurchasePrice;
  final double currentPrice;
  final double currentValue;
  final double unrealizedPnl;
  final double costBasis;

  SharePosition({
    required this.marketId,
    required this.outcomeIndex,
    required this.outcomeName,
    required this.shares,
    required this.avgPurchasePrice,
    required this.currentPrice,
    required this.currentValue,
    required this.unrealizedPnl,
    required this.costBasis,
  });

  factory SharePosition.fromJson(Map<String, dynamic> json) {
    return SharePosition(
      marketId: json['market_id']?.toString() ?? '',
      outcomeIndex: (json['outcome_index'] ?? 0) as int,
      outcomeName: json['outcome_name']?.toString() ?? '',
      shares: (json['shares'] ?? 0) as int,
      avgPurchasePrice: (json['avg_purchase_price'] ?? 0.0) as double,
      currentPrice: (json['current_price'] ?? 0.0) as double,
      currentValue: (json['current_value'] ?? 0.0) as double,
      unrealizedPnl: (json['unrealized_pnl'] ?? 0.0) as double,
      costBasis: (json['cost_basis'] ?? 0.0) as double,
    );
  }

  double get pnlPercent => costBasis > 0 ? (unrealizedPnl / costBasis) * 100 : 0;
  bool get isProfit => unrealizedPnl > 0;
  String get pnlDisplay => '${unrealizedPnl >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%';
}

/// User holdings across all markets
class UserHoldings {
  final String address;
  final List<SharePosition> positions;
  final double totalValue;
  final double totalCostBasis;
  final double totalUnrealizedPnl;
  final int activeMarkets;
  final int lastUpdatedHeight;

  UserHoldings({
    required this.address,
    required this.positions,
    required this.totalValue,
    required this.totalCostBasis,
    required this.totalUnrealizedPnl,
    required this.activeMarkets,
    required this.lastUpdatedHeight,
  });

  factory UserHoldings.fromJson(Map<String, dynamic> json) {
    List<SharePosition> parsePositions(dynamic positions) {
      if (positions == null) return [];
      if (positions is List) {
        return positions.map((p) => SharePosition.fromJson(p as Map<String, dynamic>)).toList();
      }
      return [];
    }

    return UserHoldings(
      address: json['address']?.toString() ?? '',
      positions: parsePositions(json['positions']),
      totalValue: (json['total_value'] ?? 0.0) as double,
      totalCostBasis: (json['total_cost_basis'] ?? 0.0) as double,
      totalUnrealizedPnl: (json['total_unrealized_pnl'] ?? 0.0) as double,
      activeMarkets: (json['active_markets'] ?? 0) as int,
      lastUpdatedHeight: (json['last_updated_height'] ?? 0) as int,
    );
  }

  double get totalPnlPercent => totalCostBasis > 0 ? (totalUnrealizedPnl / totalCostBasis) * 100 : 0;
  bool get hasProfits => totalUnrealizedPnl > 0;
}

/// Market sell response
class MarketSellResponse {
  final String? txid;
  final int proceedsSats;
  final int tradingFeeSats;
  final int netProceedsSats;
  final double newPrice;

  MarketSellResponse({
    this.txid,
    required this.proceedsSats,
    required this.tradingFeeSats,
    required this.netProceedsSats,
    required this.newPrice,
  });

  factory MarketSellResponse.fromJson(Map<String, dynamic> json) {
    return MarketSellResponse(
      txid: json['txid']?.toString(),
      proceedsSats: (json['proceeds_sats'] ?? 0) as int,
      tradingFeeSats: (json['trading_fee_sats'] ?? 0) as int,
      netProceedsSats: (json['net_proceeds_sats'] ?? 0) as int,
      newPrice: (json['new_price'] ?? 0.0) as double,
    );
  }

  bool get isDryRun => txid == null;
  String get newPricePercent => '${(newPrice * 100).toStringAsFixed(1)}%';
}

/// Initial liquidity calculation result
class InitialLiquidityCalculation {
  final double beta;
  final int numOutcomes;
  final int initialLiquiditySats;
  final int minTreasurySats;
  final String marketConfig;
  final String outcomeBreakdown;

  InitialLiquidityCalculation({
    required this.beta,
    required this.numOutcomes,
    required this.initialLiquiditySats,
    required this.minTreasurySats,
    required this.marketConfig,
    required this.outcomeBreakdown,
  });

  factory InitialLiquidityCalculation.fromJson(Map<String, dynamic> json) {
    return InitialLiquidityCalculation(
      beta: (json['beta'] ?? 0.0) as double,
      numOutcomes: (json['num_outcomes'] ?? 2) as int,
      initialLiquiditySats: (json['initial_liquidity_sats'] ?? 0) as int,
      minTreasurySats: (json['min_treasury_sats'] ?? 0) as int,
      marketConfig: json['market_config']?.toString() ?? '',
      outcomeBreakdown: json['outcome_breakdown']?.toString() ?? '',
    );
  }
}
