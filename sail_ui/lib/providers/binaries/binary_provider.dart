import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

/// Manages binaries via the Go orchestrator daemon.
///
/// Orchestrator-managed binaries (bitcoind, enforcer, sidechains) are
/// delegated to the orchestrator via OrchestratorRPC.
///
/// Daemon binaries (orchestratord) are spawned directly via ProcessManager
/// since the orchestrator can't manage itself.
class BinaryProvider extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;

  List<Binary> binaries;

  /// Manages daemon processes spawned directly by Flutter.
  late final ProcessManager _processManager;

  BinaryProvider._({
    required this.appDir,
    required this.binaries,
    required ProcessManager processManager,
  }) : _processManager = processManager {
    _processManager.addListener(notifyListeners);
  }

  static Future<BinaryProvider> create({
    required Directory appDir,
    required List<Binary> initialBinaries,
  }) async {
    final binaries = await loadBinaryCreationTimestamp(initialBinaries, appDir);
    final pidDir = Directory(path.join(appDir.path, 'pids'));
    final processManager = ProcessManager(
      appDir: appDir,
      pidFileManager: PidFileManager(pidDir: pidDir),
    );
    final provider = BinaryProvider._(
      appDir: appDir,
      binaries: binaries,
      processManager: processManager,
    );

    // Adopt any processes from a previous session via PID files.
    await provider._adoptOrphanedProcesses();

    return provider;
  }

  @visibleForTesting
  BinaryProvider.test({
    required this.appDir,
    required this.binaries,
  });

  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  BackendStateProvider? get _backendState =>
      GetIt.I.isRegistered<BackendStateProvider>() ? GetIt.I.get<BackendStateProvider>() : null;

  // =========================================================================
  // Lifecycle operations
  // =========================================================================

  /// Start a binary. Daemon binaries (Orchestratord) are spawned directly;
  /// everything else is delegated to the orchestrator.
  Future<void> start(Binary binary) async {
    if (_isDaemonBinary(binary)) {
      await _startDaemonBinary(binary);
      return;
    }

    final name = _orchestratorName(binary);
    if (name == null) {
      log.e('BinaryProvider: unknown binary ${binary.name}');
      return;
    }

    log.i('BinaryProvider: starting $name via orchestrator');

    final backendState = _backendState;
    if (backendState != null) {
      await backendState.trackStartup(
        _orchestrator.startWithL1(name),
      );
    } else {
      await for (final progress in _orchestrator.startWithL1(name)) {
        log.i('${progress.stage}: ${progress.message}');
        if (progress.error.isNotEmpty) {
          throw StateError(progress.error);
        }
        if (progress.done) break;
      }
    }
  }

  Future<void> stop(Binary binary, {bool skipDownstream = false}) async {
    if (_isDaemonBinary(binary)) {
      await _stopDaemonBinary(binary);
      return;
    }

    final name = _orchestratorName(binary);
    if (name == null) {
      log.e('BinaryProvider: unknown binary ${binary.name}');
      return;
    }

    log.i('BinaryProvider: stopping $name via orchestrator');
    await _orchestrator.stopBinary(name);
  }

  Future<void> download(Binary binary, {bool shouldUpdate = false}) async {
    final name = _orchestratorName(binary);
    if (name == null) {
      log.i('BinaryProvider: skipping download for ${binary.name} (not orchestrator-managed)');
      return;
    }

    log.i('BinaryProvider: downloading $name via orchestrator');

    try {
      await for (final progress in _orchestrator.downloadBinary(
        name,
        force: shouldUpdate,
      )) {
        updateBinary(binary.type, (b) {
          return b.copyWith(
            downloadInfo: DownloadInfo(
              progress: progress.bytesDownloaded.toDouble(),
              total: progress.totalBytes.toDouble(),
              message: progress.message,
              isDownloading: !progress.done && progress.error.isEmpty,
            ),
          );
        });
        notifyListeners();

        if (progress.error.isNotEmpty) {
          throw StateError(progress.error);
        }
        if (progress.done) break;
      }

      // Refresh metadata so the "update available" flag clears.
      final updated = await binary.updateMetadata(appDir);
      updateBinary(binary.type, (b) {
        return b.copyWith(
          metadata: updated.metadata,
          downloadInfo: const DownloadInfo(progress: 0.0, isDownloading: false),
        );
      });
      notifyListeners();
    } catch (e) {
      updateBinary(binary.type, (b) {
        return b.copyWith(
          downloadInfo: DownloadInfo(
            progress: 0.0,
            message: e.toString(),
            isDownloading: false,
          ),
        );
      });
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> onShutdown({ShutdownOptions? shutdownOptions}) async {
    log.i('BinaryProvider: shutting down all via orchestrator');
    _shuttingDown = true;

    final showShutdownPage = shutdownOptions?.showShutdownPage ?? false;
    final forceKill = shutdownOptions?.forceKill ?? false;

    StreamController<ShutdownProgress>? progressController;
    if (showShutdownPage) {
      progressController = StreamController<ShutdownProgress>.broadcast();
    }

    try {
      if (showShutdownPage && shutdownOptions != null) {
        if (shutdownOptions.router.current.name != ShutDownRoute.name) {
          unawaited(
            shutdownOptions.router.push(
              ShutDownRoute(
                binaries: binaries,
                shutdownStream: progressController!.stream,
                onComplete: shutdownOptions.onComplete,
              ),
            ),
          );
        }
      }

      await for (final progress in _orchestrator.shutdownAll(force: forceKill)) {
        progressController?.add(
          ShutdownProgress(
            totalCount: progress.totalCount,
            completedCount: progress.completedCount,
            currentBinary: progress.currentBinary.isNotEmpty ? progress.currentBinary : null,
            isForceKill: forceKill,
          ),
        );

        if (progress.error.isNotEmpty) {
          log.e('BinaryProvider: shutdown error: ${progress.error}');
        }
        if (progress.done) break;
      }

      await progressController?.close();

      // Stop any daemon binaries spawned directly by Flutter (e.g. orchestratord)
      await _processManager.stopAll();

      if (!showShutdownPage) {
        shutdownOptions?.onComplete();
      }
    } catch (error) {
      log.e('error shutting down: $error');
    }

    return true;
  }

  // =========================================================================
  // Daemon binary lifecycle — spawned directly via ProcessManager
  // =========================================================================

  bool _shuttingDown = false;

  /// Returns true for binaries that Flutter must spawn directly because
  /// the orchestrator can't manage itself.
  /// Adopt processes from a previous session by reading PID files.
  /// If a PID file exists and the process is still alive, register it
  /// in ProcessManager so we can track and stop it properly.
  Future<void> _adoptOrphanedProcesses() async {
    await Future.wait(
      binaries.map((binary) async {
        final pid = await _processManager.pidFileManager.readPidFile(binary);
        if (pid != null && await _processManager.pidFileManager.validatePid(pid, binary)) {
          log.i('Adopting ${binary.name} (PID $pid) from previous session');
          _processManager.runningProcesses[binary.name] = SailProcess(
            binary: binary,
            pid: pid,
            cleanup: () async {},
            adopted: true,
          );
        }
      }),
    );
  }

  /// Daemon binaries are spawned directly by Flutter.
  /// BitWindow embeds the orchestrator — Flutter just starts bitwindowd,
  /// and bitwindowd manages orchestratord + everything else internally.
  bool _isDaemonBinary(Binary binary) => binary is BitWindow;

  /// Start a daemon binary by spawning it via ProcessManager.
  /// Watches for exit and auto-restarts unless we're shutting down.
  Future<void> _startDaemonBinary(Binary binary) async {
    if (_processManager.isRunning(binary)) {
      log.i('BinaryProvider: ${binary.name} already running');
      return;
    }

    // Get proper args from the RPC (e.g. BitwindowRPC.binaryArgs() assembles
    // bitcoincore config flags). Fall back to extraBootArgs if no RPC.
    final rpc = _rpcFor(binary);
    final args = rpc != null ? await rpc.binaryArgs() : binary.extraBootArgs;

    log.i('BinaryProvider: starting daemon ${binary.name} with args: $args');
    await _processManager.start(binary, args, () async {});

    // Sync RPCConnection state — daemon is running.
    _syncDaemonConnectionState(binary, running: true);
    notifyListeners();

    _watchDaemonExit(binary);
  }

  /// Watch for daemon exit and auto-restart unless shutting down.
  void _watchDaemonExit(Binary binary) {
    final process = _processManager.runningProcesses[binary.name];
    if (process == null) return;

    _processManager.addListener(() {
      if (_shuttingDown) return;
      if (!_processManager.isRunning(binary)) {
        _syncDaemonConnectionState(binary, running: false);
        log.w('${binary.name} exited unexpectedly, restarting in 2s');
        Future.delayed(const Duration(seconds: 2), () {
          if (!_shuttingDown && !_processManager.isRunning(binary)) {
            _startDaemonBinary(binary);
          }
        });
      }
    });
  }

  /// Sync RPCConnection.connected for daemon binaries based on process state.
  void _syncDaemonConnectionState(Binary binary, {required bool running}) {
    final rpc = _rpcFor(binary);
    if (rpc == null) {
      log.w('_syncDaemonConnectionState: no RPC for ${binary.name}');
      return;
    }
    log.i('_syncDaemonConnectionState: ${binary.name} connected=$running');
    rpc.connected = running;
    rpc.initializingBinary = false;
    rpc.connectionError = null;
    rpc.markStateChanged();
  }

  /// Stop a daemon binary via ProcessManager.
  Future<void> _stopDaemonBinary(Binary binary) async {
    await _processManager.kill(binary);
    notifyListeners();
  }

  // =========================================================================
  // State queries — read from RPCConnections (synced by BackendStateProvider)
  // =========================================================================

  bool isConnected(Binary binary) {
    if (_isDaemonBinary(binary)) {
      return _processManager.isRunning(binary);
    }
    return _rpcFor(binary)?.connected ?? false;
  }

  bool isInitializing(Binary binary) {
    return _rpcFor(binary)?.initializingBinary ?? false;
  }

  bool isStopping(Binary binary) {
    return _rpcFor(binary)?.stoppingBinary ?? false;
  }

  String? connectionError(Binary binary) {
    return _rpcFor(binary)?.connectionError;
  }

  /// Download progress for a binary type.
  DownloadInfo downloadProgress(BinaryType type) {
    final binary = binaries.where((b) => b.type == type).firstOrNull;
    return binary?.downloadInfo ?? const DownloadInfo(progress: 0.0, isDownloading: false);
  }

  // =========================================================================
  // State mutation — called by BackendStateProvider to sync download/log state
  // =========================================================================

  void updateBinary(BinaryType type, Binary Function(Binary) updater) {
    for (int i = 0; i < binaries.length; i++) {
      if (binaries[i].type == type) {
        binaries[i] = updater(binaries[i]);
        break;
      }
    }
  }

  void addStartupLogForBinary(BinaryType type, String message) {
    for (final binary in binaries) {
      if (binary.type == type) {
        binary.addStartupLog(DateTime.now(), message);
        break;
      }
    }
    notifyListeners();
  }

  // =========================================================================
  // Helpers
  // =========================================================================

  RPCConnection? _rpcFor(Binary binary) {
    return switch (binary) {
      var b when b is BitcoinCore => _getRegistered<MainchainRPC>(),
      var b when b is Enforcer => _getRegistered<EnforcerRPC>(),
      var b when b is BitWindow => _getRegistered<BitwindowRPC>(),
      var b when b is Thunder => _getRegistered<ThunderRPC>(),
      var b when b is Truthcoin => _getRegistered<TruthcoinRPC>(),
      var b when b is Photon => _getRegistered<PhotonRPC>(),
      var b when b is BitNames => _getRegistered<BitnamesRPC>(),
      var b when b is BitAssets => _getRegistered<BitAssetsRPC>(),
      var b when b is ZSide => _getRegistered<ZSideRPC>(),
      var b when b is CoinShift => _getRegistered<CoinShiftRPC>(),
      _ => null,
    };
  }

  T? _getRegistered<T extends Object>() {
    return GetIt.I.isRegistered<T>() ? GetIt.I.get<T>() : null;
  }

  String? _orchestratorName(Binary binary) {
    return switch (binary) {
      BitcoinCore() => 'bitcoind',
      Enforcer() => 'enforcer',
      Thunder() => 'thunder',
      ZSide() => 'zside',
      BitWindow() => 'bitwindowd',
      BitNames() => 'bitnames',
      BitAssets() => 'bitassets',
      Truthcoin() => 'truthcoin',
      Photon() => 'photon',
      CoinShift() => 'coinshift',
      _ => null,
    };
  }
}

// ============================================================================
// Supporting types
// ============================================================================

class ShutdownOptions {
  final RootStackRouter router;
  final VoidCallback onComplete;
  final bool showShutdownPage;
  final bool forceKill;

  const ShutdownOptions({
    required this.router,
    required this.onComplete,
    required this.showShutdownPage,
    this.forceKill = false,
  });
}

Future<List<Binary>> loadBinaryCreationTimestamp(
  List<Binary> binaries,
  Directory appDir,
) async {
  return await Future.wait(
    binaries.map((binary) => binary.updateMetadata(appDir)),
  );
}

Directory binDir(String appDir) => Directory(path.join(appDir, 'assets', 'bin'));
