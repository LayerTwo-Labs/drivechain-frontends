import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/coinshift_rpc.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';
import 'package:sail_ui/rpcs/photon_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/truthcoin_rpc.dart';
import 'package:sail_ui/rpcs/zside_rpc.dart';

/// Tracks startup progress from the backend's StartWithL1 stream.
class BackendStartupProgress {
  final String stage;
  final String message;
  final bool done;
  final String? error;
  final int bytesDownloaded;
  final int totalBytes;

  BackendStartupProgress({
    required this.stage,
    required this.message,
    required this.done,
    this.error,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
  });

  double get downloadPercent => totalBytes > 0 ? bytesDownloaded / totalBytes : 0;
  bool get isDownloading => stage.startsWith('downloading-');
  String? get downloadingBinary => isDownloading ? stage.replaceFirst('downloading-', '') : null;
}

/// Syncs binary state from the Go backend to the Flutter frontend.
///
/// Listens to:
/// - `watchBinaries()` stream for live binary status
/// - `StartWithL1` progress for startup stages and download progress
///
/// Updates `BinaryProvider`'s download info so existing UI progress bars work.
class BackendStateProvider extends ChangeNotifier {
  final OrchestratorRPC _orchestrator;
  final Logger _log = GetIt.I.get<Logger>();

  /// Live binary status from the backend.
  Map<String, BinaryStatusMsg> binaries = {};

  /// Current startup progress (null if not starting up).
  BackendStartupProgress? startupProgress;

  /// Whether the initial startup sequence has completed.
  bool startupComplete = false;

  StreamSubscription<WatchBinariesResponse>? _watchSub;

  BackendStateProvider(this._orchestrator);

  /// Start listening to the watchBinaries stream from the backend.
  /// Call this after the daemon process is running and serving gRPC.
  ///
  /// Syncs connection state from the Go ConnectionMonitor to Flutter
  /// RPCConnections so the UI shows proper connected/startup/error states.
  void startWatching() {
    _watchSub?.cancel();
    _watchSub = _orchestrator.watchBinaries().listen(
      (response) {
        final changedRpcs = <RPCConnection>{};
        for (final status in response.binaries) {
          binaries[status.name] = status;

          final rpc = _syncConnectionState(status);
          if (rpc != null) changedRpcs.add(rpc);
        }
        // Batch notifications: one per changed RPC, then one for ourselves
        for (final rpc in changedRpcs) {
          rpc.notifyListeners();
        }
        notifyListeners();
      },
      onError: (error) {
        _log.w('BackendStateProvider: watchBinaries error: $error');

        // Backend is gone — mark all orchestrator-managed binaries as disconnected.
        for (final status in binaries.values) {
          final rpc = _rpcForBinaryName(status.name);
          if (rpc != null) {
            rpc.connected = false;
            rpc.initializingBinary = false;
            rpc.stoppingBinary = false;
            rpc.markStateChanged();
          }
        }
        binaries.clear();
        notifyListeners();

        // Stream broke — retry after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (_watchSub != null) startWatching();
        });
      },
    );
  }

  /// Sync all connection state from the Go backend to the Flutter RPCConnection.
  /// The Go ConnectionMonitor is the single source of truth — just assign all fields.
  /// Returns the RPC if state changed (caller batches notifyListeners), null otherwise.
  RPCConnection? _syncConnectionState(BinaryStatusMsg status) {
    final rpc = _rpcForBinaryName(status.name);
    if (rpc == null) return null;

    final startupError = status.startupError.isNotEmpty ? status.startupError : null;
    final connectionError = status.connectionError.isNotEmpty ? status.connectionError : null;

    // Check if anything actually changed to avoid unnecessary rebuilds
    if (rpc.connected == status.connected &&
        rpc.stoppingBinary == status.stopping &&
        rpc.initializingBinary == status.initializing &&
        rpc.connectModeOnly == status.connectModeOnly &&
        rpc.startupError == startupError &&
        rpc.connectionError == connectionError) {
      return null;
    }

    rpc.connected = status.connected;
    rpc.stoppingBinary = status.stopping;
    rpc.initializingBinary = status.initializing;
    rpc.connectModeOnly = status.connectModeOnly;
    rpc.startupError = startupError;
    rpc.connectionError = connectionError;
    return rpc;
  }

  /// Get the RPCConnection for a backend binary name, or null.
  RPCConnection? _rpcForBinaryName(String name) {
    return switch (name) {
      'bitcoind' => GetIt.I.isRegistered<MainchainRPC>() ? GetIt.I.get<MainchainRPC>() : null,
      'enforcer' => GetIt.I.isRegistered<EnforcerRPC>() ? GetIt.I.get<EnforcerRPC>() : null,
      // bitwindowd state is managed by BinaryProvider (daemon binary), not the orchestrator stream.
      'thunder' => GetIt.I.isRegistered<ThunderRPC>() ? GetIt.I.get<ThunderRPC>() : null,
      'zside' => GetIt.I.isRegistered<ZSideRPC>() ? GetIt.I.get<ZSideRPC>() : null,
      'bitnames' => GetIt.I.isRegistered<BitnamesRPC>() ? GetIt.I.get<BitnamesRPC>() : null,
      'bitassets' => GetIt.I.isRegistered<BitAssetsRPC>() ? GetIt.I.get<BitAssetsRPC>() : null,
      'truthcoin' => GetIt.I.isRegistered<TruthcoinRPC>() ? GetIt.I.get<TruthcoinRPC>() : null,
      'photon' => GetIt.I.isRegistered<PhotonRPC>() ? GetIt.I.get<PhotonRPC>() : null,
      'coinshift' => GetIt.I.isRegistered<CoinShiftRPC>() ? GetIt.I.get<CoinShiftRPC>() : null,
      _ => null,
    };
  }

  /// Track startup progress from a StartWithL1 stream.
  /// Updates download progress on BinaryProvider so existing progress bars work.
  /// Connection state (initializingBinary, connected, etc.) is synced via
  /// watchBinaries → _syncConnectionState, not set here.
  Future<void> trackStartup(Stream<StartWithL1Response> stream) async {
    startupComplete = false;
    StartWithL1Response? lastProgress;
    notifyListeners();

    try {
      await for (final progress in stream) {
        final previousDownloadingBinary = startupProgress?.isDownloading == true
            ? startupProgress?.downloadingBinary
            : null;

        lastProgress = progress;
        startupProgress = BackendStartupProgress(
          stage: progress.stage,
          message: progress.message,
          done: progress.done,
          error: progress.error.isNotEmpty ? progress.error : null,
          bytesDownloaded: progress.bytesDownloaded.toInt(),
          totalBytes: progress.totalBytes.toInt(),
        );

        if (previousDownloadingBinary != null && previousDownloadingBinary != startupProgress!.downloadingBinary) {
          _clearDownloadProgress(previousDownloadingBinary);
        }

        // Sync stage to the relevant RPCConnection's startup message
        _syncStageToRpc(progress.stage, progress.message);

        // Pipe download progress into BinaryProvider so existing progress bars update
        if (startupProgress!.isDownloading && startupProgress!.totalBytes > 0) {
          _updateDownloadProgress(
            startupProgress!.downloadingBinary!,
            startupProgress!.bytesDownloaded,
            startupProgress!.totalBytes,
            startupProgress!.message,
          );
        }

        notifyListeners();

        if (progress.error.isNotEmpty) {
          _log.e('BackendStateProvider: startup error: ${progress.error}');
          throw StateError(progress.error);
        }

        if (progress.done) {
          startupComplete = true;
          return;
        }
      }

      throw StateError(
        'Backend startup stream ended before completion'
        '${lastProgress == null ? '' : ' (last stage: ${lastProgress.stage})'}',
      );
    } finally {
      final downloadingBinary = startupProgress?.isDownloading == true ? startupProgress?.downloadingBinary : null;
      if (downloadingBinary != null) {
        _clearDownloadProgress(downloadingBinary);
      }
      startupProgress = null;
      notifyListeners();
    }
  }

  /// Sync the current startup stage message to the relevant RPCConnection
  /// so the DaemonConnectionCard shows it.
  void _syncStageToRpc(String stage, String message) {
    // Extract the binary name from stage (e.g. "downloading-bitcoind" → "bitcoind")
    final parts = stage.split('-');
    if (parts.length < 2) return;
    final binaryName = parts.sublist(1).join('-');

    final type = _binaryTypeFromName(binaryName);
    if (type != null && GetIt.I.isRegistered<BinaryProvider>()) {
      // Add a startup log entry so the DaemonConnectionCard shows the message
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      binaryProvider.addStartupLogForBinary(type, message);
    }
  }

  /// Map backend binary name to BinaryType for updating download progress.
  void _updateDownloadProgress(
    String binaryName,
    int bytesDownloaded,
    int totalBytes,
    String message,
  ) {
    if (!GetIt.I.isRegistered<BinaryProvider>()) return;
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final type = _binaryTypeFromName(binaryName);
    if (type == null) return;

    binaryProvider.updateBinary(type, (b) {
      return b.copyWith(
        downloadInfo: DownloadInfo(
          progress: bytesDownloaded.toDouble(),
          total: totalBytes.toDouble(),
          message: message,
          isDownloading: true,
        ),
      );
    });
    binaryProvider.notifyListeners();
  }

  void _clearDownloadProgress(String binaryName) {
    if (!GetIt.I.isRegistered<BinaryProvider>()) return;
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final type = _binaryTypeFromName(binaryName);
    if (type == null) return;

    binaryProvider.updateBinary(type, (b) {
      return b.copyWith(
        downloadInfo: const DownloadInfo(progress: 0.0, isDownloading: false),
      );
    });
    binaryProvider.notifyListeners();
  }

  BinaryType? _binaryTypeFromName(String name) {
    switch (name) {
      case 'bitcoind':
        return BinaryType.bitcoinCore;
      case 'enforcer':
        return BinaryType.enforcer;
      case 'thunder':
        return BinaryType.thunder;
      case 'zside':
        return BinaryType.zSide;
      case 'bitwindow':
      case 'bitwindowd':
        return BinaryType.bitWindow;
      case 'bitnames':
        return BinaryType.bitnames;
      case 'bitassets':
        return BinaryType.bitassets;
      case 'truthcoin':
        return BinaryType.truthcoin;
      case 'photon':
        return BinaryType.photon;
      case 'coinshift':
        return BinaryType.coinShift;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    _watchSub = null;
    super.dispose();
  }
}
