import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
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

  MainchainRPC get mainchainRPC => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcerRPC => GetIt.I.get<EnforcerRPC>();
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();

  SyncConnection get mainchain => SyncConnection(rpc: mainchainRPC, name: BitcoinCore().name);
  SyncConnection get enforcer => SyncConnection(rpc: enforcerRPC, name: Enforcer().name);
  final SyncConnection? additionalConnection;

  static const Duration AGGRESSIVE_INTERVAL = Duration(milliseconds: 100);
  static const Duration PASSIVE_INTERVAL = Duration(seconds: 5);

  // Mainchain state
  SyncInfo? mainchainSyncInfo;
  String? mainchainError;
  Timer? _mainchainTimer;
  bool _isFetchingMainchain = false;

  // Enforcer state
  SyncInfo? enforcerSyncInfo;
  String? enforcerError;
  Timer? _enforcerTimer;
  bool _isFetchingEnforcer = false;

  // Additional connection state
  SyncInfo? additionalSyncInfo;
  String? additionalError;
  Timer? _additionalTimer;
  bool _isFetchingAdditional = false;

  SyncProvider({this.additionalConnection, bool startTimer = true}) {
    binaryProvider.addListener(_checkDownloadProgress);

    if (startTimer && !Environment.isInTest) {
      _startAllTimers();
    }
    fetch();
  }

  // opts into the provider also notifying of download progress
  void listenDownloads() {
    binaryProvider.listenDownloadManager(_checkDownloadProgress);
  }

  void _startAllTimers() {
    _startMainchainTimer();
    _startEnforcerTimer();
    if (additionalConnection != null) {
      _startAdditionalTimer();
    }
  }

  void _startMainchainTimer() {
    if (Environment.isInTest) {
      return;
    }

    _mainchainTimer?.cancel();
    void tick() async {
      if (_isFetchingMainchain) return;
      _isFetchingMainchain = true;

      try {
        bool wasSynced = mainchainSyncInfo?.isSynced ?? false;
        await _fetchMainchain();
        bool isSynced = mainchainSyncInfo?.isSynced ?? false;

        if (wasSynced != isSynced) {
          // changed sync status, so we must apply the correct timer
          _mainchainTimer?.cancel();
          _mainchainTimer = Timer.periodic(isSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL, (_) => tick());
        }
      } catch (e) {
        // swallow
      } finally {
        _isFetchingMainchain = false;
      }
    }

    _mainchainTimer = Timer.periodic(AGGRESSIVE_INTERVAL, (_) => tick());
  }

  void _startEnforcerTimer() {
    if (Environment.isInTest) {
      return;
    }

    _enforcerTimer?.cancel();
    void tick() async {
      if (_isFetchingEnforcer) return;
      _isFetchingEnforcer = true;

      try {
        bool wasSynced = enforcerSyncInfo?.isSynced ?? false;
        await _fetchEnforcer();
        bool isSynced = enforcerSyncInfo?.isSynced ?? false;

        if (wasSynced != isSynced) {
          // changed sync status, so we must apply the correct timer
          _enforcerTimer?.cancel();
          _enforcerTimer = Timer.periodic(isSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL, (_) => tick());
        }
      } catch (e) {
        // swallow
      } finally {
        _isFetchingEnforcer = false;
      }
    }

    _enforcerTimer = Timer.periodic(AGGRESSIVE_INTERVAL, (_) => tick());
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
          _additionalTimer = Timer.periodic(isSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL, (_) => tick());
        }
      } catch (e) {
        // swallow
      } finally {
        _isFetchingAdditional = false;
      }
    }

    _additionalTimer = Timer.periodic(AGGRESSIVE_INTERVAL, (_) => tick());
  }

  Future<void> _fetchMainchain() async {
    bool hasChanges = false;
    try {
      if (!mainchain.rpc.connected) return;

      final newBlockchainInfo = await mainchain.rpc.getBlockchainInfo();
      final newSyncInfo = SyncInfo(
        progressCurrent: newBlockchainInfo.blocks.toDouble(),
        progressGoal: newBlockchainInfo.headers.toDouble(),
        lastBlockAt: newBlockchainInfo.time != 0 ? Timestamp(seconds: Int64(newBlockchainInfo.time)) : null,
        downloadInfo: mainchainSyncInfo?.downloadInfo ?? DownloadInfo(),
      );

      if (_syncInfoHasChanged(mainchainSyncInfo, newSyncInfo) || mainchainError != null) {
        mainchainSyncInfo = newSyncInfo;
        mainchainError = null;
        hasChanges = true;
      }
    } catch (e) {
      final newError = extractConnectException(e);
      if (mainchainError != newError) {
        mainchainError = newError;
        hasChanges = true;
      }
    } finally {
      _isFetchingMainchain = false;
      if (hasChanges) {
        notifyListeners();
      }
    }
  }

  Future<void> _fetchEnforcer() async {
    bool hasChanges = false;
    try {
      if (!enforcer.rpc.connected) return;

      final newBlockchainInfo = await enforcer.rpc.getBlockchainInfo();
      final newSyncInfo = SyncInfo(
        progressCurrent: newBlockchainInfo.blocks.toDouble(),
        progressGoal: mainchainSyncInfo?.progressGoal ?? 0,
        lastBlockAt: newBlockchainInfo.time != 0 ? Timestamp(seconds: Int64(newBlockchainInfo.time)) : null,
        downloadInfo: enforcerSyncInfo?.downloadInfo ?? DownloadInfo(),
      );

      if (_syncInfoHasChanged(enforcerSyncInfo, newSyncInfo) || enforcerError != null) {
        enforcerSyncInfo = newSyncInfo;
        enforcerError = null;
        hasChanges = true;
      }
    } catch (e) {
      final newError = extractConnectException(e);
      if (enforcerError != newError) {
        enforcerError = newError;
        hasChanges = true;
      }
    } finally {
      _isFetchingEnforcer = false;
      if (hasChanges) {
        notifyListeners();
      }
    }
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

    var downloadInfo = binaryProvider.downloadProgress(enforcer.rpc.binary.type);
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
      downloadInfo = binaryProvider.downloadProgress(additionalConnection!.rpc.binary.type);
      if (downloadInfo.isDownloading ||
          (additionalSyncInfo?.downloadInfo.isDownloading != downloadInfo.isDownloading)) {
        final (currentMB, totalMB) = (downloadInfo.progress, downloadInfo.total);

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

  // For manual fetching of all connections
  Future<void> fetch() async {
    await Future.wait([_fetchMainchain(), _fetchEnforcer(), if (additionalConnection != null) _fetchAdditional()]);
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
    _mainchainTimer?.cancel();
    _enforcerTimer?.cancel();
    _additionalTimer?.cancel();
    binaryProvider.removeDownloadManagerListener(_checkDownloadProgress);
    super.dispose();
  }
}
