import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/models/voting.dart';

/// Provider for voting/oracle system data
class VotingProvider extends ChangeNotifier {
  final TruthcoinRPC _rpc = GetIt.I.get<TruthcoinRPC>();
  final Logger _log = GetIt.I.get<Logger>();

  SlotStatus? slotStatus;
  List<SlotListItem> slots = [];
  VotingPeriodFull? currentPeriod;
  VoterInfoFull? currentVoter;
  List<VoteInfo> votes = [];
  bool isLoading = false;
  String? error;

  // Pending votes (not yet submitted)
  Map<String, double> pendingVotes = {};

  /// Load slot system status
  Future<void> loadSlotStatus() async {
    try {
      final response = await _rpc.slotStatus();
      slotStatus = SlotStatus.fromJson(response);
      _log.d('Loaded slot status: period ${slotStatus!.currentPeriod}');
      notifyListeners();
    } catch (e) {
      _log.e('Failed to load slot status: $e');
    }
  }

  /// Load slots list
  Future<void> loadSlots({int? period, String? status}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _rpc.slotList(period: period, status: status);
      slots = response.map((s) => SlotListItem.fromJson(s)).toList();
      _log.d('Loaded ${slots.length} slots');
    } catch (e) {
      error = 'Failed to load slots: $e';
      _log.e(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load current voting period
  Future<void> loadCurrentPeriod() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _rpc.votePeriod();
      if (response != null) {
        currentPeriod = VotingPeriodFull.fromJson(response);
        _log.d('Loaded period ${currentPeriod!.periodId}: ${currentPeriod!.status}');
      }
    } catch (e) {
      error = 'Failed to load period: $e';
      _log.e(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load specific period
  Future<void> loadPeriod(int periodId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _rpc.votePeriod(periodId: periodId);
      if (response != null) {
        currentPeriod = VotingPeriodFull.fromJson(response);
        _log.d('Loaded period ${currentPeriod!.periodId}');
      }
    } catch (e) {
      error = 'Failed to load period: $e';
      _log.e(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load voter info for an address
  Future<void> loadVoterInfo(String address) async {
    try {
      final response = await _rpc.voteVoter(address);
      if (response != null) {
        currentVoter = VoterInfoFull.fromJson(response);
        _log.d('Loaded voter info for $address');
      } else {
        currentVoter = null;
      }
      notifyListeners();
    } catch (e) {
      _log.e('Failed to load voter info: $e');
      currentVoter = null;
      notifyListeners();
    }
  }

  /// Load votes with filters
  Future<void> loadVotes({String? voter, String? decisionId, int? periodId}) async {
    try {
      final response = await _rpc.voteList(voter: voter, decisionId: decisionId, periodId: periodId);
      votes = response.map((v) => VoteInfo.fromJson(v)).toList();
      _log.d('Loaded ${votes.length} votes');
      notifyListeners();
    } catch (e) {
      _log.e('Failed to load votes: $e');
    }
  }

  /// Add a pending vote
  void addPendingVote(String decisionId, double value) {
    pendingVotes[decisionId] = value;
    notifyListeners();
  }

  /// Remove a pending vote
  void removePendingVote(String decisionId) {
    pendingVotes.remove(decisionId);
    notifyListeners();
  }

  /// Clear all pending votes
  void clearPendingVotes() {
    pendingVotes.clear();
    notifyListeners();
  }

  /// Submit pending votes
  Future<String?> submitVotes(int feeSats) async {
    if (pendingVotes.isEmpty) {
      error = 'No votes to submit';
      notifyListeners();
      return null;
    }

    try {
      final votesList = pendingVotes.entries
          .map(
            (e) => {
              'decision_id': e.key,
              'vote_value': e.value,
            },
          )
          .toList();

      final txid = await _rpc.voteSubmit(votes: votesList, feeSats: feeSats);
      _log.i('Submitted ${pendingVotes.length} votes: $txid');
      clearPendingVotes();
      // Reload votes
      await loadCurrentPeriod();
      return txid;
    } catch (e) {
      error = 'Failed to submit votes: $e';
      _log.e(error);
      notifyListeners();
      return null;
    }
  }

  /// Register as a voter
  Future<String?> registerAsVoter({int? bondSats, required int feeSats}) async {
    try {
      final txid = await _rpc.voteRegister(feeSats: feeSats, reputationBondSats: bondSats);
      _log.i('Registered as voter: $txid');
      return txid;
    } catch (e) {
      error = 'Failed to register: $e';
      _log.e(error);
      notifyListeners();
      return null;
    }
  }

  /// Claim a decision slot
  Future<String?> claimSlot({
    required int periodIndex,
    required int slotIndex,
    required String question,
    required bool isStandard,
    bool isScaled = false,
    int? min,
    int? max,
    required int feeSats,
  }) async {
    try {
      final txid = await _rpc.slotClaim(
        feeSats: feeSats,
        periodIndex: periodIndex,
        slotIndex: slotIndex,
        question: question,
        isStandard: isStandard,
        isScaled: isScaled,
        min: min,
        max: max,
      );
      _log.i('Claimed slot: $txid');
      // Reload slots
      await loadSlots();
      return txid;
    } catch (e) {
      error = 'Failed to claim slot: $e';
      _log.e(error);
      notifyListeners();
      return null;
    }
  }

  /// Get votecoin balance for an address
  Future<int> getVotecoinBalance(String address) async {
    try {
      return await _rpc.votecoinBalance(address);
    } catch (e) {
      _log.e('Failed to get votecoin balance: $e');
      return 0;
    }
  }

  /// Get all registered voters
  Future<List<VoterInfo>> getVoters() async {
    try {
      final response = await _rpc.voteVoters();
      return response.map((v) => VoterInfo.fromJson(v)).toList();
    } catch (e) {
      _log.e('Failed to get voters: $e');
      return [];
    }
  }

  /// Load all data for voting dashboard
  Future<void> loadDashboardData(String? userAddress) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadSlotStatus(),
        loadCurrentPeriod(),
        if (userAddress != null) loadVoterInfo(userAddress),
      ]);
    } catch (e) {
      error = 'Failed to load dashboard: $e';
      _log.e(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Get decisions that need votes
  List<DecisionSummary> get pendingDecisions {
    if (currentPeriod == null) return [];
    return currentPeriod!.decisions.where((d) {
      // Exclude decisions we've already voted on
      return !pendingVotes.containsKey(d.slotIdHex);
    }).toList();
  }

  /// Check if user has voted on a decision
  bool hasVotedOn(String decisionId) {
    return pendingVotes.containsKey(decisionId);
  }

  /// Get pending vote value for a decision
  double? getPendingVote(String decisionId) {
    return pendingVotes[decisionId];
  }
}

/// Simple VoterInfo from voters list
class VoterInfo {
  final String address;
  final double reputation;
  final int totalVotes;
  final int periodsActive;
  final double accuracyScore;
  final int registeredAtHeight;
  final bool isActive;

  VoterInfo({
    required this.address,
    required this.reputation,
    required this.totalVotes,
    required this.periodsActive,
    required this.accuracyScore,
    required this.registeredAtHeight,
    required this.isActive,
  });

  factory VoterInfo.fromJson(Map<String, dynamic> json) {
    return VoterInfo(
      address: json['address']?.toString() ?? '',
      reputation: (json['reputation'] ?? 0.0) as double,
      totalVotes: (json['total_votes'] ?? 0) as int,
      periodsActive: (json['periods_active'] ?? 0) as int,
      accuracyScore: (json['accuracy_score'] ?? 0.0) as double,
      registeredAtHeight: (json['registered_at_height'] ?? 0) as int,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
