import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
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

  /// True when this app is itself a sidechain GUI — force --headless so the
  /// orchestrator boots the rust backend, not another .app bundle.
  final bool isSidechainApp;

  /// Manages daemon processes spawned directly by Flutter.
  late final ProcessManager _processManager;

  BinaryProvider._({
    required this.appDir,
    required this.binaries,
    required ProcessManager processManager,
    required this.isSidechainApp,
  }) : _processManager = processManager {
    _processManager.addListener(notifyListeners);
    _startMetadataRefreshTimer();
    _wireSettingsListener();
  }

  Timer? _metadataRefreshTimer;
  VoidCallback? _settingsListener;
  bool? _lastKnownUseTestSidechains;

  /// Refresh remote release timestamps every 5 minutes so newly published
  /// builds light up the daemon-card update indicator and the chain-settings
  /// modal without needing an app restart. `loadBinaryCreationTimestamp`
  /// already runs once during create(); this keeps it ticking after.
  void _startMetadataRefreshTimer() {
    _metadataRefreshTimer?.cancel();
    _metadataRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshMetadata();
    });
  }

  /// Watch SettingsProvider so a toggle of "use test sidechains" flips the
  /// cached download URLs immediately. Without this, the modal + sidechains-
  /// page update indicator would keep showing the *prod* URL's release date
  /// until the next 5-min refresh tick fired — and on first-boot the toggle
  /// reconciles AFTER BinaryProvider.create has already cached prod dates.
  void _wireSettingsListener() {
    if (!GetIt.I.isRegistered<SettingsProvider>()) return;
    final settings = GetIt.I.get<SettingsProvider>();
    _lastKnownUseTestSidechains = settings.useTestSidechains;
    _settingsListener = () {
      if (settings.useTestSidechains != _lastKnownUseTestSidechains) {
        _lastKnownUseTestSidechains = settings.useTestSidechains;
        _refreshMetadata();
      }
    };
    settings.addListener(_settingsListener!);
  }

  Future<void> _refreshMetadata() async {
    final refreshed = await loadBinaryCreationTimestamp(binaries, appDir);
    for (final b in refreshed) {
      updateBinary(b.type, (_) => b);
    }
  }

  @override
  void dispose() {
    _metadataRefreshTimer?.cancel();
    if (_settingsListener != null && GetIt.I.isRegistered<SettingsProvider>()) {
      GetIt.I.get<SettingsProvider>().removeListener(_settingsListener!);
    }
    super.dispose();
  }

  static Future<BinaryProvider> create({
    required Directory appDir,
    required List<Binary> initialBinaries,
    bool isSidechainApp = false,
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
      isSidechainApp: isSidechainApp,
    );

    // Adopt any processes from a previous session via PID files.
    await provider._adoptOrphanedProcesses();

    return provider;
  }

  @visibleForTesting
  BinaryProvider.test({
    required this.appDir,
    required this.binaries,
    this.isSidechainApp = false,
  });

  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  // =========================================================================
  // Lifecycle operations
  // =========================================================================

  /// Start a binary. Daemon binaries (Orchestratord) are spawned directly;
  /// everything else is delegated to the orchestrator. The L1 boot stream
  /// is drained for stage logs + done/error — download bytes come through
  /// SyncProvider's polled GetSyncStatus, not this stream.
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

    // Only force --headless when we *are* the sidechain GUI. BitWindow
    // wants Start to lift the full Thunder.app for the user.
    final forceBackend = isSidechainApp && binary.chainLayer == 2;

    log.i('BinaryProvider: starting $name via orchestrator (forceBackend=$forceBackend)');
    // Fire-and-forget: orch dispatches boot in the background. Connection
    // state shows up via BackendStateProvider's listBinaries poll.
    await _orchestrator.startWithL1(name, forceBackend: forceBackend);
  }

  /// Restart a single binary in-place. Unlike [start], which routes through
  /// the orchestrator's full L1 boot chain (Core -> Enforcer -> target),
  /// this stops + starts only the named binary. Restarting the enforcer
  /// never tries to spawn or adopt bitcoind — fixes the "bitcoind is already
  /// running" phantom error that surfaced on Bitcoin Core's card whenever a
  /// user clicked Restart on a sibling daemon.
  ///
  /// Use this for the per-daemon Restart buttons in daemon status cards,
  /// chain-settings modals, the persistent status bar, and the sidechains
  /// page. Reserve [start] for first-time chain bootstrap.
  Future<void> restart(Binary binary) async {
    if (_isDaemonBinary(binary)) {
      await _stopDaemonBinary(binary);
      await _startDaemonBinary(binary);
      return;
    }

    final name = _orchestratorName(binary);
    if (name == null) {
      log.e('BinaryProvider: unknown binary ${binary.name}');
      return;
    }

    log.i('BinaryProvider: restarting $name via orchestrator');
    await _orchestrator.restartDaemon(name);
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

    // Fire-and-forget: orch dispatches the download in a background goroutine
    // and returns. SyncProvider's polled GetSyncStatus picks up MB progress
    // for the matching sidechain slot. Connection state once the binary's
    // up arrives via BackendStateProvider's listBinaries poll.
    await _orchestrator.downloadBinary(name, force: shouldUpdate);
  }

  /// Force-download a binary and restart it if it was running. Used by the
  /// "Update" buttons on daemon cards / chain-settings modal.
  ///
  /// The orchestrator's DownloadBinary RPC is fire-and-forget — calling
  /// restart() immediately after download() races the running daemon against
  /// its still-downloading replacement. So this method:
  ///   1. force-dispatches the download
  ///   2. polls GetDownloadStatus until the binary's entry disappears
  ///   3. refreshes the local metadata (`downloadedTimestamp` from mtime)
  ///      so `updateAvailable` flips to false
  ///   4. restarts the daemon (only if it was running before) so it picks
  ///      up the new executable
  Future<void> update(Binary binary) async {
    final name = _orchestratorName(binary);
    if (name == null) {
      log.i('BinaryProvider: skipping update for ${binary.name} (not orchestrator-managed)');
      return;
    }

    final wasRunning = isConnected(binary);

    log.i('BinaryProvider: starting update for $name');

    // Stop first so the on-disk binary isn't pinned by a running process.
    // Re-extract over a running .app would fail mid-way on a symlink/dir
    // conflict and silently leave the old binary in place.
    if (wasRunning) {
      try {
        await _orchestrator.stopBinary(name);
      } catch (e) {
        log.w('BinaryProvider: stop before update failed for $name: $e');
      }
    }

    await _orchestrator.downloadBinary(name, force: true);

    // Poll until the orchestrator drops the binary out of its in-flight map.
    // First tick might miss the entry if our poll lands before the server's
    // goroutine has stored it, so we let the first miss slide.
    const tick = Duration(milliseconds: 500);
    const timeout = Duration(minutes: 15);
    final deadline = DateTime.now().add(timeout);
    bool seenInFlight = false;
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(tick);
      try {
        final resp = await _orchestrator.getDownloadStatus();
        final entry = resp.downloads.where((d) => d.binary == binary.type).firstOrNull;
        if (entry != null) {
          seenInFlight = true;
          continue;
        }
        if (seenInFlight) break;
      } catch (e) {
        log.w('BinaryProvider: getDownloadStatus failed during update poll: $e');
      }
    }

    // Refresh remote/downloaded timestamps so `updateAvailable` flips off.
    final refreshed = await binary.updateMetadata(appDir);
    updateBinary(binary.type, (_) => refreshed);

    if (wasRunning) {
      log.i('BinaryProvider: restarting $name after update');
      bool started = false;
      int attempts = 0;
      const maxAttempts = 3;
      const retryDelay = Duration(seconds: 5);
      while (!started && attempts < maxAttempts) {
        attempts++;
        try {
          await restart(binary);
          started = true;
        } catch (e) {
          if (attempts < maxAttempts) {
            await Future.delayed(retryDelay);
          } else {
            rethrow;
          }
        }
      }
    }
  }

  Future<bool> onShutdown({ShutdownOptions? shutdownOptions}) async {
    _shuttingDown = true;

    // Only the Flutter app that originally spawned the backend stack is
    // allowed to tear it down. A non-originator app (e.g. thunder Flutter
    // attached to bitwindow's already-running orchestratord) must exit
    // quietly so it doesn't kill bitwindow's backend out from under it.
    if (!_isBackendOriginator) {
      log.i('BinaryProvider: skipping backend shutdown — this app did not originate the stack');
      shutdownOptions?.onComplete();
      return true;
    }

    // Fire-and-forget. orchestratord acks immediately and drains
    // bitcoind/enforcer/sidechains in its own goroutine over up to ~90s —
    // detached from us, so it survives this Flutter process exiting.
    log.i('BinaryProvider: relaying Shutdown to orchestratord (fire-and-forget)');
    try {
      await _orchestrator.shutdown();
    } catch (error) {
      log.e('error calling orchestrator.shutdown: $error');
    }

    // Reap any Flutter-spawned children. For bitwindow that's bitwindowd
    // (which itself idempotently relays Shutdown to orchestratord on exit,
    // belt-and-suspenders). For sidechain apps that spawn orchestratord
    // directly from Dart, this catches it via SIGTERM — orchestratord's
    // signal handler routes through the same BeginShutdown path.
    try {
      await _processManager.stopAll();
    } catch (error) {
      log.e('error stopping flutter children: $error');
    }

    shutdownOptions?.onComplete();
    return true;
  }

  // =========================================================================
  // Daemon binary lifecycle — spawned directly via ProcessManager
  // =========================================================================

  bool _shuttingDown = false;

  /// True when *this* Flutter instance is the one that originally spawned
  /// orchestratord (cold-start path). False when we attached to an
  /// already-running orchestratord from another Flutter app (hot-start path).
  ///
  /// Only the originator is allowed to issue shutdownAll on shutdown —
  /// otherwise closing thunder Flutter while bitwindow is running would kill
  /// bitwindow's backend stack out from under it.
  bool _isBackendOriginator = false;

  /// Mark this BinaryProvider as the originator of the live backend stack.
  /// Set by bootBackendManagedSidechain on the cold-start branch (we
  /// spawned orchestratord ourselves) and by app startup paths that boot
  /// the L1 stack directly. Idempotent.
  void markBackendOriginator() {
    _isBackendOriginator = true;
  }

  bool get isBackendOriginator => _isBackendOriginator;

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

  /// Daemon binaries are spawned directly by Flutter rather than via the
  /// orchestrator RPC (it can't start itself, and bitwindowd is the host
  /// process for the embedded orchestrator).
  bool _isDaemonBinary(Binary binary) => binary is BitWindow || binary is Orchestratord;

  /// Start a daemon binary by spawning it via ProcessManager.
  /// Watches for exit and auto-restarts unless we're shutting down.
  Future<void> _startDaemonBinary(Binary binary) async {
    if (_processManager.isRunning(binary)) {
      log.i('BinaryProvider: ${binary.name} already running');
      return;
    }

    // Flip initializing + seed a startup log so the DaemonConnectionCard
    // shows the "Initializing..." spinner + message during the spawn.
    // Without this the card stays on "Not connected" until
    // _syncDaemonConnectionState fires after the process is up.
    final rpc = _rpcFor(binary);
    if (rpc != null) {
      rpc.initializingBinary = true;
      rpc.connectionError = null;
      rpc.markStateChanged();
    }
    addStartupLogForBinary(binary.type, 'Starting ${binary.name}...');

    // Get proper args from the RPC (e.g. BitwindowRPC.binaryArgs() assembles
    // bitcoincore config flags). Fall back to extraBootArgs if no RPC.
    final args = rpc != null ? await rpc.binaryArgs() : binary.extraBootArgs;

    log.i('BinaryProvider: starting daemon ${binary.name} with args: $args');
    await _processManager.start(binary, args, () async {
      final process = _processManager.runningProcesses[binary.name];
      if (process == null) return;
      try {
        Process.killPid(process.pid, ProcessSignal.sigint);
      } catch (e) {
        log.w('SIGINT to ${binary.name} pid=${process.pid} failed: $e');
        return;
      }
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (DateTime.now().isBefore(deadline)) {
        if (!await _processManager.isPidAlive(process.pid)) return;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });

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

  // =========================================================================
  // State mutation — called by BackendStateProvider to sync download/log state
  // =========================================================================

  void updateBinary(BinaryType type, Binary Function(Binary) updater) {
    for (int i = 0; i < binaries.length; i++) {
      if (binaries[i].type == type) {
        final prev = binaries[i];
        final next = updater(prev);
        if (identical(prev, next)) return;
        binaries[i] = next;
        // BackendStateProvider's 1s poll flips Binary.metadata.binaryPath
        // here when a download completes — without this notify, every
        // consumer reading binary.isDownloaded stays stale until something
        // else (a click, a sync tick) forces a rebuild.
        notifyListeners();
        return;
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
      var b when b is BitcoinCore => _getRegistered<BitcoindConnection>(),
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
