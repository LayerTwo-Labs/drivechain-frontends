import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sail_ui/sail_ui.dart';

/// Detailed sync info for one chain. While downloading, progressCurrent /
/// progressGoal are MB downloaded / MB total — the same fields used for
/// blocks/headers when synced. The UI uses [DownloadInfo.isDownloading] to
/// pick the right label ("MB" vs "blocks").
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
/// of mainchain + enforcer + every known sidechain (including bitwindowd).
/// One RPC carries both sync state AND download progress — when a binary is
/// being downloaded its slot's [SyncInfo.downloadInfo] is populated, with
/// progressCurrent/progressGoal holding MB downloaded / MB total.
///
/// Cadence is 100 ms while anything is still syncing or downloading,
/// then drops to 1 s once everything is fully caught up.
class SyncProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  // Kept for callers that want the typed RPC handle. SyncProvider itself
  // doesn't dial these — it polls the orchestrator only.
  BitcoindConnection get mainchainRPC => GetIt.I.get<BitcoindConnection>();
  EnforcerRPC get enforcerRPC => GetIt.I.get<EnforcerRPC>();

  SyncConnection get mainchain => SyncConnection(rpc: mainchainRPC, name: BitcoinCore().name);
  SyncConnection get enforcer => SyncConnection(rpc: enforcerRPC, name: Enforcer().name);
  final SyncConnection? additionalConnection;

  /// Returns true when bitcoind and enforcer are fully synced. Per-app
  /// "is everything ready" checks should also confirm their own additional
  /// daemon (read [bitwindowdSyncInfo] or [sidechains] directly).
  bool get isSynced => (mainchainSyncInfo?.isSynced ?? false) && (enforcerSyncInfo?.isSynced ?? false);

  /// All tracked SyncInfo slots in one list — null entries mean the
  /// daemon hasn't reported yet. Both [_anyDownloading] and
  /// [shouldPollAggressively] iterate this so the set stays in sync.
  List<SyncInfo?> get _trackedSyncInfos => [
    mainchainSyncInfo,
    enforcerSyncInfo,
    bitwindowdSyncInfo,
    ...sidechains.values,
  ];

  /// True if any tracked daemon is downloading binaries.
  bool get _anyDownloading => _trackedSyncInfos.any(
    (s) => s?.downloadInfo.isDownloading ?? false,
  );

  /// Cadence signal — true only when there's actual progress to display.
  /// A null SyncInfo (daemon not running) does NOT count: polling fast
  /// for something with nothing to show would just burn CPU.
  bool get shouldPollAggressively => _anyDownloading || _trackedSyncInfos.any((s) => s != null && !s.isSynced);

  /// True while bitcoind is still pulling its initial header set.
  bool get inHeaderSync {
    final m = mainchainSyncInfo;
    if (m == null) return true;
    return m.progressGoal < 10;
  }

  static const Duration AGGRESSIVE_INTERVAL = Duration(milliseconds: 100);
  static const Duration PASSIVE_INTERVAL = Duration(seconds: 1);

  SyncInfo? mainchainSyncInfo;
  String? mainchainError;

  SyncInfo? enforcerSyncInfo;
  String? enforcerError;

  /// Per-sidechain sync state, keyed by [SidechainType]. Populated from
  /// `GetSyncStatusResponse.sidechains` on every poll. Includes every L2
  /// chain the orchestrator manages — entries that aren't running yet
  /// carry `error="not running"`.
  ///
  /// bitwindowd is NOT in here. The orchestrator doesn't know bitwindowd
  /// exists — bitwindow's own daemon card reads [bitwindowdSyncInfo]
  /// instead, populated by polling bitwindowd's GetSyncInfo directly.
  Map<orch_pb.SidechainType, SyncInfo> sidechains = const {};
  Map<orch_pb.SidechainType, String?> sidechainErrors = const {};

  /// bitwindow's own daemon state, populated by polling bitwindowd
  /// directly each tick. Stays null when no [BitwindowRPC] is registered
  /// (every non-bitwindow app).
  SyncInfo? bitwindowdSyncInfo;
  String? bitwindowdError;

  Timer? _timer;
  bool _isFetching = false;
  Duration _currentInterval = AGGRESSIVE_INTERVAL;

  SyncProvider({this.additionalConnection, bool startTimer = true}) {
    if (startTimer && !Environment.isInTest) {
      _scheduleNextTick();
      fetch();
    }
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    _timer = Timer.periodic(_currentInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      await _fetch();

      final nextInterval = shouldPollAggressively ? AGGRESSIVE_INTERVAL : PASSIVE_INTERVAL;
      if (nextInterval != _currentInterval) {
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
    // Fan out two parallel polls: orchestrator for L1 + sidechains, and
    // (when applicable) bitwindowd directly for the bitwindow daemon card.
    // The orchestrator deliberately doesn't know bitwindowd exists, so its
    // GetSyncStatus skips it and we hit bitwindowd ourselves. The check is
    // by GetIt registration — every non-bitwindow app skips the second
    // poll automatically because BitwindowRPC isn't wired in.
    final orchFuture = _orchestrator.getSyncStatus();
    final BitwindowRPC? bitwindowRpc = GetIt.I.isRegistered<BitwindowRPC>() ? GetIt.I.get<BitwindowRPC>() : null;
    final bitwindowFuture = bitwindowRpc?.bitwindowd.getSyncInfo();

    orch_pb.GetSyncStatusResponse? resp;
    String? orchErr;
    try {
      resp = await orchFuture;
    } catch (e) {
      orchErr = extractConnectException(e);
    }

    var changed = false;

    if (resp != null) {
      final newMainchain = _toSyncInfo(resp.mainchain);
      if (_diff(mainchainSyncInfo, newMainchain) || mainchainError != _errOrNull(resp.mainchain)) {
        mainchainSyncInfo = newMainchain;
        mainchainError = _errOrNull(resp.mainchain);
        changed = true;
      }

      final newEnforcer = _toSyncInfo(resp.enforcer);
      if (_diff(enforcerSyncInfo, newEnforcer) || enforcerError != _errOrNull(resp.enforcer)) {
        enforcerSyncInfo = newEnforcer;
        enforcerError = _errOrNull(resp.enforcer);
        changed = true;
      }

      final newSidechains = <orch_pb.SidechainType, SyncInfo>{};
      final newSidechainErrors = <orch_pb.SidechainType, String?>{};
      for (final entry in resp.sidechains) {
        newSidechains[entry.type] = _toSyncInfo(entry.sync);
        newSidechainErrors[entry.type] = _errOrNull(entry.sync);
      }
      if (!_sidechainMapEquals(sidechains, newSidechains) ||
          !_sidechainMapEquals(sidechainErrors, newSidechainErrors)) {
        sidechains = newSidechains;
        sidechainErrors = newSidechainErrors;
        changed = true;
      }
    } else {
      if (mainchainError != orchErr) {
        mainchainError = orchErr;
        changed = true;
      }
      if (enforcerError != orchErr) {
        enforcerError = orchErr;
        changed = true;
      }
      if (sidechainErrors.values.any((e) => e != orchErr)) {
        sidechainErrors = {for (final k in sidechainErrors.keys) k: orchErr};
        changed = true;
      }
    }

    if (bitwindowFuture != null) {
      try {
        final info = await bitwindowFuture;
        final next = SyncInfo(
          progressCurrent: info.tipBlockHeight.toDouble(),
          progressGoal: info.headerHeight.toDouble(),
          lastBlockAt: info.tipBlockTime != Int64(0) ? Timestamp(seconds: info.tipBlockTime) : null,
          downloadInfo: const DownloadInfo(),
        );
        if (_diff(bitwindowdSyncInfo, next) || bitwindowdError != null) {
          bitwindowdSyncInfo = next;
          bitwindowdError = null;
          changed = true;
        }
      } catch (e) {
        final err = extractConnectException(e);
        if (bitwindowdError != err) {
          bitwindowdError = err;
          changed = true;
        }
      }
    }

    if (changed) notifyListeners();
  }

  /// Builds a SyncInfo from the proto. When `is_downloading=true`,
  /// blocks/headers carry MB downloaded / MB total — populate
  /// [DownloadInfo] so the existing UI code that switches on
  /// `syncInfo.downloadInfo.isDownloading` keeps working.
  SyncInfo _toSyncInfo(orch_pb.ChainSync? cs) {
    final blocks = (cs?.blocks ?? 0).toDouble();
    final headers = (cs?.headers ?? 0).toDouble();
    if (cs?.isDownloading ?? false) {
      return SyncInfo(
        progressCurrent: blocks,
        progressGoal: headers,
        lastBlockAt: null,
        downloadInfo: DownloadInfo(progress: blocks, total: headers, isDownloading: true),
      );
    }
    return SyncInfo(
      progressCurrent: blocks,
      progressGoal: headers,
      lastBlockAt: (cs?.time ?? Int64(0)) != Int64(0) ? Timestamp(seconds: cs!.time) : null,
      downloadInfo: const DownloadInfo(),
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

  bool _sidechainMapEquals<V>(Map<orch_pb.SidechainType, V> a, Map<orch_pb.SidechainType, V> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || a[k] != b[k]) return false;
    }
    return true;
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
    bitwindowdSyncInfo = null;
    bitwindowdError = null;
    sidechains = const {};
    sidechainErrors = const {};
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
