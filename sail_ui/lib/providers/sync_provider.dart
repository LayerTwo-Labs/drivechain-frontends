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

class SyncProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  BitcoindConnection get mainchainRPC => GetIt.I.get<BitcoindConnection>();
  EnforcerRPC get enforcerRPC => GetIt.I.get<EnforcerRPC>();
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();
  BackendStateProvider? get _backendState =>
      GetIt.I.isRegistered<BackendStateProvider>() ? GetIt.I.get<BackendStateProvider>() : null;

  SyncConnection get mainchain => SyncConnection(rpc: mainchainRPC, name: BitcoinCore().name);
  SyncConnection get enforcer => SyncConnection(rpc: enforcerRPC, name: Enforcer().name);
  final SyncConnection? additionalConnection;

  /// Returns true only when all connections (mainchain, enforcer, and additional if present) are fully synced.
  bool get isSynced =>
      (mainchainSyncInfo?.isSynced ?? false) &&
      (enforcerSyncInfo?.isSynced ?? false) &&
      (additionalConnection == null || (additionalSyncInfo?.isSynced ?? false));

  static const Duration AGGRESSIVE_INTERVAL = Duration(milliseconds: 100);
  static const Duration PASSIVE_INTERVAL = Duration(seconds: 5);

  // Mainchain state
  SyncInfo? mainchainSyncInfo;
  String? mainchainError;

  // Enforcer state
  SyncInfo? enforcerSyncInfo;
  String? enforcerError;

  // Additional connection state (sidechain — orchestrator doesn't proxy
  // sidechain blockchain info, so we still poll directly here).
  SyncInfo? additionalSyncInfo;
  String? additionalError;
  Timer? _additionalTimer;
  bool _isFetchingAdditional = false;

  SyncProvider({this.additionalConnection, bool startTimer = true}) {
    binaryProvider.addListener(_checkDownloadProgress);
    _backendState?.addListener(_onBackendStateChanged);

    if (startTimer && !Environment.isInTest) {
      if (additionalConnection != null) {
        _startAdditionalTimer();
      }
    }
    _onBackendStateChanged();
    fetch();
  }

  // opts into the provider also notifying of download progress
  void listenDownloads() {
    binaryProvider.addListener(_checkDownloadProgress);
  }

  // Orchestrator binary names — same keys used by BackendStateProvider's
  // `binaries` map (status.name from the proto). Don't use Binary.binaryName,
  // which encodes the executable filename and diverges (e.g.
  // "bip300301-enforcer" vs the orchestrator's "enforcer").
  static const String _kMainchainBinary = 'bitcoind';
  static const String _kEnforcerBinary = 'enforcer';

  void _onBackendStateChanged() {
    final state = _backendState;
    if (state == null) return;

    bool hasChanges = false;
    if (_applyBackendBinary(state.binaries[_kMainchainBinary], _kMainchainBinary)) {
      hasChanges = true;
    }
    if (_applyBackendBinary(state.binaries[_kEnforcerBinary], _kEnforcerBinary)) {
      hasChanges = true;
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  bool _applyBackendBinary(BinaryStatusMsg? status, String name) {
    final isMainchain = name == _kMainchainBinary;
    final isEnforcer = name == _kEnforcerBinary;
    if (!isMainchain && !isEnforcer) return false;

    final orch_pb.BlockchainSyncMsg? sync = (status?.hasBlockchainSync() ?? false) ? status!.blockchainSync : null;
    final SyncInfo? prev = isMainchain ? mainchainSyncInfo : enforcerSyncInfo;

    if (sync == null) {
      // No backend sample yet — keep the previous SyncInfo so the UI doesn't
      // flicker between "loading" and "synced" if a stream hiccup arrives.
      return false;
    }

    final goal = isEnforcer ? (mainchainSyncInfo?.progressGoal ?? sync.headers.toDouble()) : sync.headers.toDouble();

    final newSyncInfo = SyncInfo(
      progressCurrent: sync.blocks.toDouble(),
      progressGoal: goal,
      lastBlockAt: sync.time != 0 ? Timestamp(seconds: sync.time) : null,
      downloadInfo: prev?.downloadInfo ?? DownloadInfo(),
    );

    if (!_syncInfoHasChanged(prev, newSyncInfo)) {
      return false;
    }
    if (isMainchain) {
      mainchainSyncInfo = newSyncInfo;
      mainchainError = null;
    } else {
      enforcerSyncInfo = newSyncInfo;
      enforcerError = null;
    }
    return true;
  }

  void _startAdditionalTimer() {
    if (Environment.isInTest) {
      return;
    }

    _additionalTimer?.cancel();
    void tick() async {
      if (_isFetchingAdditional) return;
      _isFetchingAdditional = true;

      try {
        bool wasSynced = additionalSyncInfo?.isSynced ?? false;
        await _fetchAdditional();
        bool isSynced = additionalSyncInfo?.isSynced ?? false;

        if (wasSynced != isSynced) {
          // changed sync status, so we must apply the correct timer
          _additionalTimer?.cancel();
          _additionalTimer = Timer.periodic(
            isSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL,
            (_) => tick(),
          );
        }
      } catch (e) {
        // swallow
      } finally {
        _isFetchingAdditional = false;
      }
    }

    _additionalTimer = Timer.periodic(AGGRESSIVE_INTERVAL, (_) => tick());
  }

  Future<void> _fetchAdditional() async {
    if (additionalConnection == null) return;

    bool hasChanges = false;
    try {
      if (!additionalConnection!.rpc.connected) return;

      final newBlockchainInfo = await additionalConnection!.rpc.getBlockchainInfo();
      final newSyncInfo = SyncInfo(
        progressCurrent: newBlockchainInfo.blocks.toDouble(),
        progressGoal: newBlockchainInfo.headers.toDouble(),
        lastBlockAt: newBlockchainInfo.time != 0 ? Timestamp(seconds: Int64(newBlockchainInfo.time)) : null,
        downloadInfo: additionalSyncInfo?.downloadInfo ?? DownloadInfo(),
      );

      if (_syncInfoHasChanged(additionalSyncInfo, newSyncInfo) || additionalError != null) {
        additionalSyncInfo = newSyncInfo;
        additionalError = null;
        hasChanges = true;
      }
    } catch (e) {
      final newError = extractConnectException(e);
      if (additionalError != newError) {
        additionalError = newError;
        hasChanges = true;
      }
    } finally {
      _isFetchingAdditional = false;
      if (hasChanges) {
        notifyListeners();
      }
    }
  }

  void _checkDownloadProgress() {
    bool hasChanges = false;

    var downloadInfo = binaryProvider.downloadProgress(
      enforcer.rpc.binary.type,
    );
    if (downloadInfo.isDownloading || (enforcerSyncInfo?.downloadInfo.isDownloading != downloadInfo.isDownloading)) {
      final (currentMB, totalMB) = (downloadInfo.progress, downloadInfo.total);

      enforcerSyncInfo = SyncInfo(
        progressCurrent: currentMB.toDouble(),
        progressGoal: totalMB.toDouble(),
        lastBlockAt: null,
        downloadInfo: downloadInfo,
      );
      hasChanges = true;
    }

    downloadInfo = binaryProvider.downloadProgress(mainchain.rpc.binary.type);
    if (downloadInfo.isDownloading || (mainchainSyncInfo?.downloadInfo.isDownloading != downloadInfo.isDownloading)) {
      final (currentMB, totalMB) = (downloadInfo.progress, downloadInfo.total);

      mainchainSyncInfo = SyncInfo(
        progressCurrent: currentMB,
        progressGoal: totalMB,
        lastBlockAt: null,
        downloadInfo: downloadInfo,
      );
      hasChanges = true;
    }

    if (additionalConnection != null) {
      downloadInfo = binaryProvider.downloadProgress(
        additionalConnection!.rpc.binary.type,
      );
      if (downloadInfo.isDownloading ||
          (additionalSyncInfo?.downloadInfo.isDownloading != downloadInfo.isDownloading)) {
        final (currentMB, totalMB) = (
          downloadInfo.progress,
          downloadInfo.total,
        );

        additionalSyncInfo = SyncInfo(
          progressCurrent: currentMB,
          progressGoal: totalMB,
          lastBlockAt: null,
          downloadInfo: downloadInfo,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  bool _syncInfoHasChanged(SyncInfo? oldInfo, SyncInfo? newInfo) {
    if (oldInfo == null || newInfo == null) return true;
    return oldInfo != newInfo;
  }

  // Pull state from all sources. Mainchain + enforcer come from the backend
  // stream (no fetch needed); the sidechain still polls.
  Future<void> fetch() async {
    _onBackendStateChanged();
    if (additionalConnection != null) {
      await _fetchAdditional();
    }
  }

  /// Clear all sync state - useful when network changes or services restart
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
    _additionalTimer?.cancel();
    binaryProvider.removeListener(_checkDownloadProgress);
    _backendState?.removeListener(_onBackendStateChanged);
    super.dispose();
  }
}
