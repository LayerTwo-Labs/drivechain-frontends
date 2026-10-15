import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/gen/drivechain/v1/drivechain.pb.dart' as drivechainpb;
import 'package:sidechain_core/gen/m4/v1/m4.pb.dart' as m4pb;
import 'package:sidechain_core/providers/bitcoin_conf_provider.dart';
import 'package:sidechain_core/providers/sync_provider.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';

class M4Provider extends ChangeNotifier {
  final Logger log = Logger(level: Level.debug);
  final BitwindowRPC _bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  SyncProvider get _syncProvider => GetIt.I.get<SyncProvider>();

  // M4 data per sidechain slot
  Map<int, List<drivechainpb.WithdrawalBundle>> withdrawalBundlesBySidechain = {};
  List<m4pb.M4HistoryEntry> history = [];
  m4pb.VotePolicy votePolicy = m4pb.VotePolicy.VOTE_POLICY_UNSPECIFIED;
  Map<int, String> upvotes = {};
  bool isLoading = false;
  String? modelError;

  Timer? _pollTimer;
  bool _disposed = false;
  bool _settingVote = false;
  Future<void> _voteQueue = Future.value();
  int _voteChanges = 0;

  M4Provider() {
    _bitwindowRPC.addListener(_onBitwindowConnectionChanged);
    _syncProvider.addListener(_onNewBlock);
    _init();
  }

  Future<void> _init() async {
    if (_bitwindowRPC.connected) {
      await fetchAll();
    }
  }

  void _onBitwindowConnectionChanged() {
    if (_bitwindowRPC.connected) {
      fetchAll();
    }
  }

  void _onNewBlock() {
    if (_syncProvider.isSynced) {
      fetchAll();
    }
  }

  // Fetch M4 data for all active sidechains
  Future<void> fetchAll() async {
    if (_disposed || _settingVote) {
      return;
    }
    if (!GetIt.I.get<BitcoinConfProvider>().drivechainFeaturesAvailable) {
      return;
    }

    isLoading = true;
    modelError = null;
    notifyListeners();
    final voteChanges = _voteChanges;

    try {
      // Get list of active sidechains
      final sidechains = await _bitwindowRPC.drivechain.listSidechains();

      // Fetch withdrawal bundles for each active sidechain in parallel
      final bundleFutures = sidechains.map((sidechain) async {
        try {
          final bundles = await _bitwindowRPC.drivechain.listWithdrawals(
            sidechainId: sidechain.slot,
            startBlockHeight: 0,
            endBlockHeight: 999999999,
          );
          return MapEntry(sidechain.slot, bundles);
        } catch (e) {
          log.w('Failed to fetch withdrawal bundles for sidechain ${sidechain.slot}: $e');
          return MapEntry(sidechain.slot, <drivechainpb.WithdrawalBundle>[]);
        }
      });

      final results = await Future.wait([
        Future.wait(bundleFutures),
        _bitwindowRPC.m4.getM4History(limit: 10),
        _bitwindowRPC.m4.getVotes(),
      ]);

      withdrawalBundlesBySidechain = Map.fromEntries(
        results[0] as List<MapEntry<int, List<drivechainpb.WithdrawalBundle>>>,
      );
      history = results[1] as List<m4pb.M4HistoryEntry>;
      // A vote change after this fetch started holds newer votes.
      if (voteChanges == _voteChanges) {
        _applyVotes(results[2] as m4pb.GetVotesResponse);
      }
      modelError = null;
    } catch (e) {
      if (!isExpectedBootError(e)) {
        log.e('Failed to fetch M4 data: $e');
      }
      modelError = e.toString();
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // Get withdrawal bundles for a specific sidechain
  List<drivechainpb.WithdrawalBundle> getWithdrawalBundles(int sidechainSlot) {
    return withdrawalBundlesBySidechain[sidechainSlot] ?? [];
  }

  void _applyVotes(m4pb.GetVotesResponse votes) {
    votePolicy = votes.policy;
    upvotes = {for (final upvote in votes.upvotes) upvote.sidechainSlot: upvote.m6id};
  }

  /// Upvotes [m6id] for [sidechainSlot], or clears the upvote when [m6id] is null.
  Future<void> setBundleUpvote({required int sidechainSlot, String? m6id}) async {
    await _changeVotes(() => _bitwindowRPC.m4.setBundleUpvote(sidechainSlot: sidechainSlot, m6id: m6id));
  }

  Future<void> setVotePolicy(m4pb.VotePolicy policy) async {
    await _changeVotes(() => _bitwindowRPC.m4.setVotePolicy(policy));
  }

  Future<void> _changeVotes(Future<void> Function() change) {
    final next = _voteQueue.then((_) => _applyChange(change));
    _voteQueue = next.catchError((_) {});
    return next;
  }

  Future<void> _applyChange(Future<void> Function() change) async {
    if (_disposed) {
      return;
    }
    _settingVote = true;
    _voteChanges++;
    try {
      await change();
      final votes = await _bitwindowRPC.m4.getVotes();
      if (_disposed) {
        return;
      }
      _applyVotes(votes);
      notifyListeners();
    } finally {
      _settingVote = false;
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    stopPolling();
    _pollTimer = Timer.periodic(interval, (_) async {
      await fetchAll();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _bitwindowRPC.removeListener(_onBitwindowConnectionChanged);
    _syncProvider.removeListener(_onNewBlock);
    stopPolling();
    super.dispose();
  }
}
