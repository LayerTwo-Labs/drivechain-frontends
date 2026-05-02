import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sail_ui/sail_ui.dart';

/// Represents detailed information about a blockchain
class SyncInfo {
  final double progressCurrent;
  final double progressGoal;
  final Timestamp? lastBlockAt;
  final DownloadInfo downloadInfo;

  // progress returns the download progress if it's currently downloading, else
  // the blockchain sync progress compared to headers
  double get progress => downloadInfo.progressPercent < 1
      ? downloadInfo.progressPercent
      : progressGoal == 0
      ? 0
      : progressCurrent / progressGoal;
  bool get isSynced => progressGoal > 0 && progressCurrent == progressGoal;

  SyncInfo({
    required this.progressCurrent,
    required this.progressGoal,
    required this.lastBlockAt,
    required this.downloadInfo,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncInfo &&
        other.progressCurrent == progressCurrent &&
        other.progressGoal == progressGoal &&
        other.lastBlockAt == lastBlockAt &&
        other.progress == progress &&
        other.isSynced == isSynced &&
        other.downloadInfo.toString() == downloadInfo.toString();
  }

  @override
  int get hashCode => Object.hash(progressCurrent, progressGoal, lastBlockAt);
}

/// Represents a binary that has some sort of sync-status
class SyncConnection {
  final RPCConnection rpc;
  final String name;

  SyncConnection({required this.rpc, required this.name});
}

/// Polls a single orchestrator RPC (`GetSyncStatus`) for an atomic snapshot
/// of mainchain + enforcer + (optionally) sidechain tip data. Three numbers
/// taken at one wall-clock instant means the three daemon cards in the UI
/// can never disagree mid-tick.
///
/// Cadence is 200 ms while any tracked daemon is still syncing or
/// disconnected, then drops to 1 s once everything is fully caught up.
class SyncProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();

  // Kept around for callers that ask the provider which daemons it tracks.
  // The actual RPC calls happen exclusively via [_orchestrator].
  BitcoindConnection get mainchainRPC => GetIt.I.get<BitcoindConnection>();
  EnforcerRPC get enforcerRPC => GetIt.I.get<EnforcerRPC>();

  SyncConnection get mainchain => SyncConnection(rpc: mainchainRPC, name: BitcoinCore().name);
  SyncConnection get enforcer => SyncConnection(rpc: enforcerRPC, name: Enforcer().name);
  final SyncConnection? additionalConnection;

  /// Returns true only when all tracked daemons are fully synced.
  bool get isSynced =>
      (mainchainSyncInfo?.isSynced ?? false) &&
      (enforcerSyncInfo?.isSynced ?? false) &&
      (additionalConnection == null || (additionalSyncInfo?.isSynced ?? false));

  /// True while bitcoind is still pulling its initial header set. Derived
  /// from the latest snapshot; consumers used to read this off
  /// `BitcoindConnection.inHeaderSync` (now removed).
  bool get inHeaderSync {
    final m = mainchainSyncInfo;
    if (m == null) return true;
    return m.progressGoal < 10;
  }

  static const Duration AGGRESSIVE_INTERVAL = Duration(milliseconds: 200);
  static const Duration PASSIVE_INTERVAL = Duration(seconds: 1);

  SyncInfo? mainchainSyncInfo;
  String? mainchainError;

  SyncInfo? enforcerSyncInfo;
  String? enforcerError;

  SyncInfo? additionalSyncInfo;
  String? additionalError;

  Timer? _timer;
  bool _isFetching = false;
  Duration _currentInterval = AGGRESSIVE_INTERVAL;

  SyncProvider({this.additionalConnection, bool startTimer = true}) {
    binaryProvider.addListener(_checkDownloadProgress);

    if (startTimer && !Environment.isInTest) {
      _scheduleNextTick();
    }
    fetch();
  }

  // opts into the provider also notifying of download progress
  void listenDownloads() {
    binaryProvider.addListener(_checkDownloadProgress);
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    _timer = Timer.periodic(_currentInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final wasAllSynced = isSynced;
      await _fetch();
      final nowAllSynced = isSynced;

      // Switch cadence on sync-state edge so a freshly-synced daemon stops
      // burning CPU on 200 ms ticks, and a regression back into IBD
      // immediately speeds back up.
      final nextInterval = nowAllSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL;
      if (nextInterval != _currentInterval || wasAllSynced != nowAllSynced) {
        _currentInterval = nextInterval;
        _scheduleNextTick();
      }
    } catch (_) {
      // swallow — _fetch() already records errors per-chain
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _fetch() async {
    final orch_pb.GetSyncStatusResponse resp;
    try {
      resp = await _orchestrator.getSyncStatus(
        sidechain: additionalConnection?.name ?? '',
      );
    } catch (e) {
      final err = extractConnectException(e);
      var changed = false;
      if (mainchainError != err) {
        mainchainError = err;
        changed = true;
      }
      if (enforcerError != err) {
        enforcerError = err;
        changed = true;
      }
      if (additionalConnection != null && additionalError != err) {
        additionalError = err;
        changed = true;
      }
      if (changed) notifyListeners();
      return;
    }

    var changed = false;

    final newMainchain = _toSyncInfo(resp.mainchain, mainchainSyncInfo);
    if (_diff(mainchainSyncInfo, newMainchain) || mainchainError != _errOrNull(resp.mainchain)) {
      mainchainSyncInfo = newMainchain;
      mainchainError = _errOrNull(resp.mainchain);
      changed = true;
    }

    final newEnforcer = _toSyncInfo(resp.enforcer, enforcerSyncInfo);
    if (_diff(enforcerSyncInfo, newEnforcer) || enforcerError != _errOrNull(resp.enforcer)) {
      enforcerSyncInfo = newEnforcer;
      enforcerError = _errOrNull(resp.enforcer);
      changed = true;
    }

    if (additionalConnection != null) {
      final newAdditional = _toSyncInfo(resp.sidechain, additionalSyncInfo);
      if (_diff(additionalSyncInfo, newAdditional) || additionalError != _errOrNull(resp.sidechain)) {
        additionalSyncInfo = newAdditional;
        additionalError = _errOrNull(resp.sidechain);
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  SyncInfo _toSyncInfo(orch_pb.ChainSync? cs, SyncInfo? prev) {
    final blocks = (cs?.blocks ?? 0).toDouble();
    final headers = (cs?.headers ?? 0).toDouble();
    return SyncInfo(
      progressCurrent: blocks,
      progressGoal: headers,
      lastBlockAt: (cs?.time ?? Int64(0)) != Int64(0) ? Timestamp(seconds: cs!.time) : null,
      downloadInfo: prev?.downloadInfo ?? DownloadInfo(),
    );
  }

  String? _errOrNull(orch_pb.ChainSync? cs) {
    final e = cs?.error ?? '';
    return e.isEmpty ? null : e;
  }

  bool _diff(SyncInfo? a, SyncInfo? b) {
    if (a == null || b == null) return true;
    return a != b;
  }

  void _checkDownloadProgress() {
    bool hasChanges = false;

    var downloadInfo = binaryProvider.downloadProgress(enforcer.rpc.binary.type);
    if (downloadInfo.isDownloading || (enforcerSyncInfo?.downloadInfo.isDownloading != downloadInfo.isDownloading)) {
      enforcerSyncInfo = SyncInfo(
        progressCurrent: downloadInfo.progress.toDouble(),
        progressGoal: downloadInfo.total.toDouble(),
        lastBlockAt: null,
        downloadInfo: downloadInfo,
      );
      hasChanges = true;
    }

    downloadInfo = binaryProvider.downloadProgress(mainchain.rpc.binary.type);
    if (downloadInfo.isDownloading || (mainchainSyncInfo?.downloadInfo.isDownloading != downloadInfo.isDownloading)) {
      mainchainSyncInfo = SyncInfo(
        progressCurrent: downloadInfo.progress,
        progressGoal: downloadInfo.total,
        lastBlockAt: null,
        downloadInfo: downloadInfo,
      );
      hasChanges = true;
    }

    if (additionalConnection != null) {
      downloadInfo = binaryProvider.downloadProgress(additionalConnection!.rpc.binary.type);
      if (downloadInfo.isDownloading ||
          (additionalSyncInfo?.downloadInfo.isDownloading != downloadInfo.isDownloading)) {
        additionalSyncInfo = SyncInfo(
          progressCurrent: downloadInfo.progress,
          progressGoal: downloadInfo.total,
          lastBlockAt: null,
          downloadInfo: downloadInfo,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) notifyListeners();
  }

  /// Manual one-shot fetch — same as a single tick but without rescheduling.
  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      await _fetch();
    } finally {
      _isFetching = false;
    }
  }

  /// Clear all sync state — useful when network changes or services restart.
  void clearState() {
    mainchainSyncInfo = null;
    mainchainError = null;
    enforcerSyncInfo = null;
    enforcerError = null;
    additionalSyncInfo = null;
    additionalError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    binaryProvider.removeListener(_checkDownloadProgress);
    super.dispose();
  }
}
