import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';

/// Tracks startup progress from the backend's startWithDeps stream.
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
/// - `startWithDeps` progress for startup stages and download progress
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
  void startWatching() {
    _watchSub?.cancel();
    _watchSub = _orchestrator.watchBinaries().listen(
      (response) {
        for (final status in response.binaries) {
          binaries[status.name] = status;
        }
        notifyListeners();
      },
      onError: (error) {
        _log.w('BackendStateProvider: watchBinaries error: $error');
        // Stream broke — retry after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (_watchSub != null) startWatching();
        });
      },
    );
  }

  /// Track startup progress from a startWithDeps stream.
  /// Updates download progress on BinaryProvider and syncs initializingBinary
  /// on RPCConnections so the UI shows proper loading states.
  Future<void> trackStartup(Stream<StartWithDepsResponse> stream) async {
    startupComplete = false;

    // Mark all RPCConnections as initializing — the backend is starting everything
    _setAllInitializing(true);
    notifyListeners();

    await for (final progress in stream) {
      startupProgress = BackendStartupProgress(
        stage: progress.stage,
        message: progress.message,
        done: progress.done,
        error: progress.error.isNotEmpty ? progress.error : null,
        bytesDownloaded: progress.bytesDownloaded.toInt(),
        totalBytes: progress.totalBytes.toInt(),
      );

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
        _setAllInitializing(false);
        break;
      }

      if (progress.done) {
        _setAllInitializing(false);
        break;
      }
    }

    startupComplete = true;
    startupProgress = null;
    notifyListeners();
  }

  /// Set initializingBinary on all registered RPCConnections.
  void _setAllInitializing(bool value) {
    for (final rpc in _getAllRpcConnections()) {
      rpc.initializingBinary = value;
      rpc.notifyListeners();
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

  /// Get all registered RPCConnections.
  List<RPCConnection> _getAllRpcConnections() {
    final rpcs = <RPCConnection>[];
    if (GetIt.I.isRegistered<MainchainRPC>()) rpcs.add(GetIt.I.get<MainchainRPC>());
    if (GetIt.I.isRegistered<EnforcerRPC>()) rpcs.add(GetIt.I.get<EnforcerRPC>());
    if (GetIt.I.isRegistered<SidechainRPC>()) rpcs.add(GetIt.I.get<SidechainRPC>());
    return rpcs;
  }

  /// Map backend binary name to BinaryType for updating download progress.
  void _updateDownloadProgress(String binaryName, int bytesDownloaded, int totalBytes, String message) {
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
